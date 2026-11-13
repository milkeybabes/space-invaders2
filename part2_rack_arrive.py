"""Part II $09CA RackArrive: native Python translation of arrival state.

The original routine runs in the foreground between interrupts. This controller
exposes one alien draw/cursor operation at a time. Frame pacing is deliberately
chosen by the Stage 10 preview, NOT asserted to be cycle-accurate.
"""
from __future__ import annotations

from part2_startup import CYCLES_PER_FRAME, startup_status_cycles

SAVE = 0x2300
COUNT = 0x10


class Part2RackArrival:
    def __init__(self, rack):
        if not rack.part2:
            raise ValueError('RackArrive is a Part II routine')
        self.rack = rack
        m = rack.mem
        self.target_y = m[0x2009]
        m[SAVE:SAVE + COUNT] = m[0x2000:0x2010]
        self.saved = bytes(m[SAVE:SAVE + COUNT])
        self.start_y = 0xA8
        self.alien_count = rack.alive
        self.step_size = 4 if self.alien_count >= 26 else 2 if self.alien_count >= 10 else 1
        self.delta = (-self.step_size) & 0xFF
        m[0x2008] = 0                  # $09D8 sideways delta disabled
        m[0x2009] = self.start_y       # $09DC ref alien Y
        m[0x200B] = self.start_y       # $09E0 cursor Y
        m[0x200E] = self.delta         # $09F0 downward delta
        m[0x2007] = 0
        self.iterations = 0
        # A full $09FA-$0A4B iteration does CursorNextAlien, DrawAlien,
        # sound/update, compare and branch; it consumes a substantial part
        # of the 8080 frame budget.  Retain fractional cycles rather than
        # forcing exactly eight whole iterations in every video frame.
        # 4327 cycles/pair is a provisional source-level estimate, tuned
        # against the original MAME 55-alien arrival loop (not an emulator).
        self.operation_cycles = 4327.0
        self.cycle_credit = self.operation_cycles * 0.80
        self.complete = False
        self.stage = 'dropping'
        self.score_cycles_remaining = 0.0
        self.history = [self.start_y]
        # The game uses a blocking foreground routine while interrupts
        # continue. The preview suppresses game tasks until it finishes.
        self.previous_suspend = m[0x20E9]
        m[0x20B9] = 1
        m[0x20E9] = 0

    def advance_frame(self):
        """Run as many ROM $09FA loop iterations as a frame's cycles permit."""
        if self.complete:
            return True
        if self.stage == 'score_restore':
            # ROM $0A55 CALL $1719 DrawScores is substantial foreground
            # work; interrupts continue but game tasks stay suspended until
            # the call returns. Use the existing source-level score-cycle
            # estimate, rather than instantly enabling gameplay.
            self.score_cycles_remaining -= CYCLES_PER_FRAME
            if self.score_cycles_remaining <= 0:
                self.rack.mem[0x20E9] = self.previous_suspend
                self.rack.mem[0x20B9] = 0
                self.stage = 'done'
                self.complete = True
            return self.complete
        self.cycle_credit += CYCLES_PER_FRAME
        while self.cycle_credit >= self.operation_cycles and not self.complete and self.stage == 'dropping':
            self.cycle_credit -= self.operation_cycles
            self.advance(operations=1)
        return self.complete

    def advance(self, operations=1):
        """One $09FA CursorNextAlien/DrawAlien pair per operation.

        The original $09FA calls these synchronously. During arrival the
        diagnostic foreground drives them without running an extra ISR draw.
        """
        if self.complete:
            return True
        if self.stage == 'score_restore':
            # Standalone source-level tests call advance() without an ISR
            # driver; let each call supply the next foreground frame budget.
            return self.advance_frame()
        r = self.rack
        m = r.mem
        for _ in range(operations):
            r.cursor_next_alien()
            r.draw_alien()
            m[0x2007] = m[0x200E]     # $09FE stage the next vertical bump
            self.iterations += 1
            pos = m[0x2009]
            if pos != self.history[-1]:
                self.history.append(pos)
            if pos == self.target_y:  # $0A21 CMP B, $0A4B JNZ (equality only)
                self.finish()
                return self.complete
        return False

    def finish(self):
        """$0A4D restore previous 16-byte rack-state descriptor."""
        if self.stage != 'dropping':
            return
        m = self.rack.mem
        m[0x2000:0x2010] = self.saved
        self.stage = 'score_restore'
        self.score_cycles_remaining = float(startup_status_cycles(m))
        # ROM $0A4D: restore the rack and CALL DrawScores ($1719).
        # The shared 1-bit framebuffer may have lost score glyphs while
        # sprites travelled through the top of the screen. The provisional
        # renderer currently provides headings and three five-digit scores;
        # name/credit rendering remains future work.
        score_display = getattr(self.rack, 'score_display', None)
        if score_display is not None and hasattr(score_display, 'redraw_scores'):
            score_display.redraw_scores()
        # The original ROM does not return to gameplay until DrawScores
        # completes; completion is handled by advance_frame().

