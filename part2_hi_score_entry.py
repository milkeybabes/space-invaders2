"""Part II $0DFA-$1025 HI-SCORER REGISTRATION, native Python translation.

The ROM lays out three rows of letters, RUB and END. Left/right select a
character, and Fire's release commits it ($0D9B/$0DA8). Up to 10 characters.
The original 16-bit timer counts interrupt ticks and stops at $2000.

CPU-cycle pacing for the initial VRAM clear and text print is approximate;
input handling, name RAM layout and ROM glyph data follow the disassembly.
"""
from part2_display import Part2ScoreDisplay
from part2_title import portrait_luma
from part2_two_player import _ROMClearPlayField


class Part2HighScoreEntry:
    # $0E16-$0E35 / $0F03-$0F25 / $0FA0-$0FAE
    OPTIONS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ.'

    def __init__(self, previous_mem, *, player=1):
        if player not in (1, 2):
            raise ValueError('player must be 1 or 2')
        self.mem = bytearray(previous_mem)
        self.player = player
        self.scores = Part2ScoreDisplay(self)
        self.mem[0x20F4:0x2100] = previous_mem[0x20F4:0x2100]  # retain both players' score registers
        self.mem[0x2340:0x234A] = bytes((0x1B,)) * 10
        self.mem[0x234A:0x234C] = b'\x00\x00'
        self.mem[0x234C] = 0
        self.mem[0x234D] = 1
        self.mem[0x234E:0x2350] = b'\x11\x27'  # $1065 cursor begins on A
        self.mem[0x2350:0x2352] = b'\x07\x30'  # $1065 name output
        self.mem[0x20E0] = 1
        self.mem[0x20E1] = 0x00 if player == 1 else 0x20
        self.mem[0x20E4] = 1  # shots halted while name is selected
        self.mem[0x20B1] = self.mem[0x20B2] = 0
        self.position = 0
        self.frames = 0
        self.finished = False
        self.phase = 'clear'
        self.fire_held = False
        self.clearer = _ROMClearPlayField(self.mem)

    def _letter_location(self, position):
        # Horizontal screen address high-byte increases by two per letter.
        if position < 11:   # A-K
            return (0x27 + 2 * position) << 8 | 0x11
        if position < 22:   # L-V
            return (0x27 + 2 * (position-11)) << 8 | 0x0F
        if position < 27:   # W-Z and .
            return (0x27 + 2 * (position-22)) << 8 | 0x0D
        # RUB, END ($0F90-$0FAE)
        return ((0x34 if position == 27 else 0x36) << 8) | 0x0D

    def _message(self, address, source, count):
        for i in range(count):
            self.scores.draw_char(self.mem[source + i], (address + 0x100 * i) & 0xFFFF)

    def _draw_letter_row(self, address, start, count):
        # $0EA7 DrawLetterRow / $1183 DrawSimpSprite. Each 5-column glyph
        # advances 5*32 bytes during drawing, then $0160 between letters.
        for n in range(count):
            at = address + n * 0x200
            for col in range(5):
                dst = at + col * 32
                if 0x2400 <= dst < 0x4000:
                    self.mem[dst] = self.mem[0x1E21 + 5 * (start + n) + col]

    def _erase_hi_name(self):
        # $1028: 80 scan rows, two bytes per row.
        for row in range(80):
            at = 0x2D1E + row * 32
            self.mem[at:at + 2] = b'\x00\x00'

    def _draw_form(self):
        self._erase_hi_name()
        self.scores.redraw_scores()  # ROM $1716 score/header margins persist
        self._message(0x2717, 0x103D, 23)  # HI-SCORER REGISTRATION
        self._draw_letter_row(0x2712, 0, 11)
        self._draw_letter_row(0x2710, 11, 11)
        self._draw_letter_row(0x270E, 22, 5)
        # $0E2D DrawSimpSprite 40-byte RUB/END graphic
        for row in range(40):
            address = 0x330E + 32 * row
            if 0x2400 <= address < 0x4000:
                self.mem[address] = self.mem[0x1F16 + row]
        self._message(0x2A06, 0x1054, 17)  # NAME [..........]
        self._draw_cursor()

    def _draw_cursor(self):
        addr = self._letter_location(self.position)
        self.mem[0x234E:0x2350] = bytes((addr & 255, addr >> 8))
        self.scores.draw_char(0x2A, addr)  # underline cursor

    def _erase_cursor(self):
        self.scores.draw_char(0x1B, self._letter_location(self.position))

    @property
    def name(self):
        codes = self.mem[0x2340:0x2340 + self.mem[0x234C]]
        return ''.join(chr(ord('A') + c) if c < 26 else '.' for c in codes)

    def move(self, delta):
        if self.phase != 'active':
            return
        self._erase_cursor()
        self.position = (self.position + delta) % 29
        self._draw_cursor()

    def select(self):
        if self.phase != 'active':
            return
        if self.position == 28:  # END
            self.finish()
        elif self.position == 27:  # RUB
            if self.mem[0x234C]:
                self.mem[0x234C] -= 1
                length = self.mem[0x234C]
                self.mem[0x2350] = 0x07
                self.mem[0x2351] = (0x30 + length) & 255
                self.mem[0x2340 + length] = 0x1B
                at = 0x3007 + length * 0x100
                self.scores.draw_char(0x1B, at)
        elif self.mem[0x234C] < 10:
            length = self.mem[0x234C]
            code = self.position
            self.mem[0x2340 + length] = code
            self.scores.draw_char(code, 0x3007 + length * 0x100)
            self.mem[0x234C] += 1
            self.mem[0x2350] = 0x07
            self.mem[0x2351] = (0x30 + self.mem[0x234C]) & 255
        # ROM clears the fire flags after AddLetter/NameRub.
        self.mem[0x20B1] = self.mem[0x20B2] = 0

    def finish(self):
        if self.finished:
            return
        self.mem[0x234D] = 0
        self.mem[0x20E0] = 0
        self.mem[0x20E1] = 0xFF
        length = self.mem[0x234C]
        if not length:
            # $10AE defaults to TAITO if no letters were selected.
            name = self.mem[0x110B:0x1110]  # TAITO, without five leading/trailing spaces
            self.mem[0x2340:0x234A] = bytes(name) + b'\x1b' * 5
            self.mem[0x234C] = 5
            length = 5
        col = 0x2D + (10 - length) // 2
        self.mem[0x233E] = 0x1E
        self.mem[0x233F] = col
        self.phase = 'done'
        self.finished = True

    def fire_down(self):
        if self.phase == 'active':
            self.fire_held = True
            self.mem[0x20B1] = 1

    def fire_up(self):
        if self.phase == 'active' and self.fire_held:
            self.fire_held = False
            self.select()

    def step(self, *, left=False, right=False, fire=False, start=False):
        if self.finished:
            return
        self.frames += 1
        if self.phase == 'clear':
            if self.clearer.step():
                self._draw_form()
                self.phase = 'active'
            return
        # $0DAF: nameTimer is incremented by the scanline-96 interrupt.
        ticks = (self.mem[0x234B] << 8 | self.mem[0x234A]) + 1
        self.mem[0x234A:0x234C] = (ticks & 0xFFFF).to_bytes(2, 'little')
        if ticks >= 0x2000 or start:
            self.finish()
            return
        if right and not left:
            self.move(1)
        elif left and not right:
            self.move(-1)
        if fire:
            self.fire_down()
        elif self.fire_held:
            self.fire_up()  # $0DA5-$0DA8: select on fire release

    def image(self):
        return portrait_luma(self.mem)


def pending_registration(game):
    """Return (player number, RAM) for the new high score, if one is due.

    Each translated player has a separate Rack; the original machine has one
    shared high-score value and a $20E0 flag. Resolve simultaneous flags by
    selecting the larger BCD high score, not by whichever player exits last.
    """
    games = game.games if hasattr(game, 'games') else (game,)
    options = []
    for i, g in enumerate(games):
        m = g.rack.mem
        if m[0x20E0]:
            options.append(((m[0x20F5], m[0x20F4]), i + 1, m))
    if not options:
        return None
    _, player, mem = max(options, key=lambda row: (row[0], row[1]))
    return player, mem
