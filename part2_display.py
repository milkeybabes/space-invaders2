"""Part II $0997 CarveRoundNum and $107A Print4Digits0, ROM-backed.

Stage 09 presentation layer for autonomous *provisional* demo. The 1978
score/font routines are intentionally not invoked for Part II. The five-byte
font at $1E21, shield bitmap at $1D1C and message at $1862 are preserved in ROM.
"""
from __future__ import annotations

FONT = 0x1E21
SHIELD_IMAGE = 0x1D1C
SHIELD_SIZE = 44
SHIELD_START = 0x2806
SHIELD_PITCH_BYTES = 0x05A0  # 22 drawn columns + $02E0 gap, $0264 CopyShields
PLAYER_BUFFERS = {1: 0x2142, 2: 0x2242}


class Part2ScoreDisplay:
    def __init__(self, rack):
        self.rack = rack
        self.initialised = False
        # The Part II ROM mirror supplies the *real* score descriptors; the
        # 1978 ScoreDisplay constructor must never rewrite Part II ROM data.
        m = rack.mem
        for offs in range(12):
            m[0x20F4 + offs] = m[0x1BF4 + offs]

    def draw_char(self, code, address):
        """8080 $0AE5 DrawChar, $1A24 CharPtr: 5 data + 3 zero columns."""
        m = self.rack.mem
        ptr = FONT + code * 5
        for col in range(8):
            at = address + col * 32
            if 0x2400 <= at < 0x4000:
                m[at] = m[ptr + col] if col < 5 else 0
        return (address + 0x100) & 0xffff

    def draw_header(self):
        # $16D8 DrawScoreHead prints the *actual* 28-character ROM message.
        at = 0x241E
        for code in self.rack.mem[0x1862:0x1862 + 28]:
            at = self.draw_char(code, at)

    def draw_score(self, base):
        """$171C/$107A: four BCD digits followed by literal digit 0."""
        m = self.rack.mem
        at = m[base + 2] | m[base + 3] << 8
        for v in (m[base + 1], m[base]):
            at = self.draw_char(0x1C + ((v >> 4) & 15), at)
            at = self.draw_char(0x1C + (v & 15), at)
        self.draw_char(0x1C, at)

    def redraw_scores(self):
        """$1719 DrawScores: restore the Part II score headings and BCD digits.

        $09CA RackArrive calls DrawScores on completion because moving sprites
        may have overwritten text in the shared framebuffer. The full ROM
        DrawScores additionally prints name and credits; those presentation
        routines are not yet implemented in the provisional attract preview.
        """
        self.draw_header()
        # The cabinet's default high-score initials are the ROM's TAITO
        # name (the same 10-glyph sequence used by WaitForStart). Keep this
        # in the score-area restore, not in a per-frame presentation overlay.
        m = self.rack.mem
        length = min(10, m[0x234C])
        if length:
            start_col = 0x2D + (10 - length) // 2
            at = (start_col << 8) | 0x1E
            name = m[0x2340:0x2340 + length]
        elif m[0x20E0]:
            name = ()   # $14B2 cleared the previous name for registration
            at = 0x2D1E
        else:
            at = 0x2D1E
            name = m[0x1109:0x1113]  # cold boot TAITO
        for code in name:
            at = self.draw_char(code, at)
        for addr in (0x20F8, 0x20FC, 0x20F4):
            self.draw_score(addr)
        self.draw_credits()

    def draw_credits(self):
        """$16FA/$1705: seven ROM message characters and BCD credit digit."""
        m = self.rack.mem
        at = 0x3501
        for code in m[0x1F42:0x1F49]:
            at = self.draw_char(code, at)
        self.draw_char(0x1C + (m[0x20EB] & 0x0F), 0x3C01)

    def initialise(self):
        if self.initialised:
            return
        self.initialised = True
        self.redraw_scores()

    def score_adjusted(self, base):
        if self.initialised:
            self.draw_score(base)

    def high_score_updated(self):
        self.score_adjusted(0x20F4)


class Part2Shields:
    """$0235/$0264/$0997 shield transfer and subtractive number carving."""
    def __init__(self, rack):
        self.rack = rack

    def init_playfield(self, player=1):
        m = self.rack.mem
        for bank in (1, 2):
            buf = PLAYER_BUFFERS[bank]
            m[buf:buf + SHIELD_SIZE * 4] = bytes(m[SHIELD_IMAGE:SHIELD_IMAGE + SHIELD_SIZE]) * 4
        buf = PLAYER_BUFFERS[player]
        for shield in range(4):
            for row in range(22):
                vram = SHIELD_START + SHIELD_PITCH_BYTES * shield + row * 32
                for b in range(2):
                    m[vram + b] |= m[buf + shield * SHIELD_SIZE + row * 2 + b]
        self.carve_round_number(player)
        # $0215 DrawBottomLine
        for x in range(224):
            m[0x2402 + 32*x] = 1

    def carve_round_number(self, player=1):
        """Exact $0997: (character & screen) XOR screen, five columns."""
        m = self.rack.mem
        # $0997 uses 2xFA as a round-display digit (0..9).
        number = m[0x21FA if player == 1 else 0x22FA]
        code = (number + 0x1C) & 0xff
        if code > 0x25:
            raise ValueError('displayed round is not a single decimal digit')
        for shield in range(4):
            at = 0x2927 + shield * SHIELD_PITCH_BYTES
            for col in range(5):
                addr = at + col * 32
                original = m[addr]
                ink = m[FONT + code * 5 + col]
                m[addr] = original ^ (original & ink)
