"""ROM-backed Space Invaders Part II score-advance and coin screens.

Translates the $163F table descriptor walk, $167D ReadPriStruct,
$166B sprite copy, $1673 message output and $0D32 coin messages.
Letter pacing models $0C85: load 7; poll until it reaches 1 (6 decrements).
The foreground CPU execution time for immediate draw calls is not yet modelled.
"""
from part2_rom import load_rom
from part2_display import Part2ScoreDisplay
from part2_title import portrait_luma
from part2_startup import CYCLES_PER_FRAME, VRAM_BEGIN, VRAM_END


class Part2AttractScreen:
    def __init__(self, kind, credits=0, post_game=False):
        if kind not in ('score_table', 'insert_coin', 'wait_start'):
            raise ValueError(kind)
        self.kind = kind
        low, high = load_rom()
        self.mem = bytearray(0x4800)
        self.mem[:0x2000] = low
        self.mem[0x4000:] = high
        self.scores = Part2ScoreDisplay(self)
        self.scores.redraw_scores()
        self.events = []
        self.next_event = 0
        self.ticks = 0
        if kind == 'score_table':
            self._prepare_score_table()
        elif kind == 'wait_start':
            self._prepare_wait_start(credits, post_game=post_game)
        else:
            self._prepare_coin_screen()
        self.complete = False

    def _write_message(self, address, data):
        for code in data:
            address = self.scores.draw_char(code, address)

    def _write_sprite(self, addr, source):
        # $166B: B=16; DrawSimpSprite increments VRAM pointer by 32.
        for n in range(16):
            at = addr + 32*n
            if 0x2400 <= at < 0x4000:
                self.mem[at] = self.mem[source+n]

    def _prepare_score_table(self):
        # $163F: title message, all six sprites, then 5x11 characters.
        # $0C85 PrintMessageDel loads $20C0 with 7 after EVERY char; the loop stops at 1.
        self.events.append((0, 'message', 0x2812, 0x1ACB, 21))
        cursor = 0x1DAB
        while self.mem[cursor] != 0xFF:
            dst = self.mem[cursor] | self.mem[cursor+1] << 8
            src = self.mem[cursor+2] | self.mem[cursor+3] << 8
            self.events.append((0, 'sprite', dst, src, 16))
            cursor += 4
        cursor = 0x1DC4
        tick = 0
        while self.mem[cursor] != 0xFF:
            dst = self.mem[cursor] | self.mem[cursor+1] << 8
            src = self.mem[cursor+2] | self.mem[cursor+3] << 8
            for j in range(11):
                self.events.append((tick, 'character', dst+j*0x100, src+j, 1))
                tick += 6  # $0C90: poll DCR A until isrDelay reaches 1
            cursor += 4
        self.finish_tick = tick  # final 7->1 countdown also runs

    def _prepare_coin_screen(self):
        # $0D32 outputs these via PrintMessage / ReadPriStruct, not
        # time-staggered at guessed seconds.
        self.events.extend((
            (0, 'message', 0x2C11, 0x1117, 12),
            (0, 'message', 0x2A0D, 0x10E5, 18),
            (0, 'message', 0x2A0A, 0x10F7, 18),
            (0, 'message', 0x2A07, 0x113C, 18),
        ))
        self.finish_tick = 0

    def _prepare_wait_start(self, credits, post_game=False):
        """ROM $0845-$0877 / $0973: coin interrupt enters WaitForStart.

        Clear the old attract VRAM, restore $1716 status, then use the actual
        Part II message bytes at $1F3E, $184D or $1838. A new credit count
        selects the new prompt without resuming the attract animation.
        """
        if not 1 <= credits <= 9:
            raise ValueError('wait-start credits must be 1..9')
        self.mem[0x2400:0x4000] = bytes(0x1C00)
        self.mem[0x20EB] = credits
        self.scores.redraw_scores()
        # $0845 WaitForStart clears the attract playfield.  Unlike the
        # later active-game HUD it does NOT draw reserve ship illustrations.
        # Print the ROM default high-score name in the centre of the score
        # header; the original MAME credit screen still shows TAITO here.
        self.mem[0x2340:0x234e] = self.mem[0x1109:0x1117]
        at = 0x2D1E
        for code in self.mem[0x2340:0x234a]:
            at = self.scores.draw_char(code, at)
        # The start-screen presentation depends on the preceding state.
        # At initial startup the lower field is empty. After a completed game
        # the arcade's subsequent coin prompt shows the red shields, NOT the
        # four cyan reserve-ship icons used in gameplay. Draw the actual Part II
        # shield bitmap, rather than using the incorrect cannon descriptors.
        if post_game:
            from part2_display import SHIELD_IMAGE, SHIELD_SIZE, SHIELD_START, SHIELD_PITCH_BYTES
            for shield in range(4):
                base = SHIELD_START + shield * SHIELD_PITCH_BYTES
                for row in range(22):
                    for column in range(2):
                        self.mem[base + 32 * row + column] |= self.mem[SHIELD_IMAGE + 2 * row + column]
        self._write_message(0x3013, self.mem[0x1F3E:0x1F42])
        source = 0x184D if credits == 1 else 0x1838
        self._write_message(0x2810, self.mem[source:source+20])
        self.finish_tick = 0

    def advance_ticks(self, tick_count):
        self.ticks += tick_count
        while (self.next_event < len(self.events) and
               self.events[self.next_event][0] <= self.ticks):
            _, kind, dst, src, count = self.events[self.next_event]
            if kind == 'sprite':
                self._write_sprite(dst, src)
            elif kind == 'character':
                self.scores.draw_char(self.mem[src], dst)
            else:
                self._write_message(dst, self.mem[src:src+count])
            self.next_event += 1
        self.complete = self.next_event == len(self.events) and self.ticks >= self.finish_tick

    def advance(self, seconds):
        """Compatibility helper for historical diagnostics only.

        The live attract scheduler calls advance_ticks(), never this method.
        """
        self.advance_ticks(max(0, round(seconds*59.542) - self.ticks))

    def image(self):
        return portrait_luma(self.mem)


class Part2CreditWipe:
    """Foreground-paced $0845 credit transition, using existing byte VRAM.

    The previously visible screen is retained. The 8080 ClearScreen loop
    writes one byte at a time (37 cycles per iteration); afterwards we
    progressively expose the ROM-generated status and prompt bytes. This
    is an operation-budget approximation, not a CPU emulator or a forced
    frame-number transition. It never changes the underlying game RAM.
    """
    def __init__(self, previous_mem, credits=1, post_game=False):
        self.target = Part2AttractScreen('wait_start', credits, post_game)
        self.mem = bytearray(self.target.mem)
        self.mem[VRAM_BEGIN:VRAM_END] = previous_mem[VRAM_BEGIN:VRAM_END]
        self.offset = 0
        self.stage = 'clear'
        self.cycle_carry = 0.0
        self.draw_offset = 0
        # The score/prompt drawing performs many ROM sprite/character writes.
        # Work is budgeted in equivalent operations rather than one frame.
        self.draw_addresses = [a for a in range(VRAM_BEGIN, VRAM_END)
                               if self.target.mem[a]]

    @property
    def complete(self):
        return self.stage == 'done'

    def set_credits(self, credits):
        """A second coin updates the eventual screen, without another wipe."""
        self.target = Part2AttractScreen('wait_start', min(credits, 9))
        self.draw_addresses = [a for a in range(VRAM_BEGIN, VRAM_END)
                               if self.target.mem[a]]
        self.draw_offset = min(self.draw_offset, len(self.draw_addresses))

    def step(self):
        if self.complete:
            return
        budget = CYCLES_PER_FRAME * 0.80 + self.cycle_carry
        self.cycle_carry = 0.0
        if self.stage == 'clear':
            count = min(VRAM_END - VRAM_BEGIN - self.offset, int(budget // 37))
            start = VRAM_BEGIN + self.offset
            self.mem[start:start + count] = bytes(count)
            self.offset += count
            budget -= count * 37
            if self.offset < VRAM_END - VRAM_BEGIN:
                self.cycle_carry = budget
                return
            self.stage = 'draw'
        # $0AE5 character drawing takes several hundred cycles per column.
        # Approximate the ROM's sprite/character work at 125 cycles per
        # nonzero destination byte, keeping the byte-write ordering visible.
        count = min(len(self.draw_addresses) - self.draw_offset, int(budget // 125))
        for a in self.draw_addresses[self.draw_offset:self.draw_offset + count]:
            self.mem[a] = self.target.mem[a]
        self.draw_offset += count
        if self.draw_offset >= len(self.draw_addresses):
            self.stage = 'done'
            self.mem[VRAM_BEGIN:VRAM_END] = self.target.mem[VRAM_BEGIN:VRAM_END]
        else:
            self.cycle_carry = budget - count * 125

    def image(self):
        return portrait_luma(self.mem)
