"""Part II $13D2 / $4410 / $4653: end-of-rack bonus, native Python.

ROM eligibility and BCD score are exact; pacing uses the frame scheduler
until the foreground DelayBC / ISR timing is modelled. No 8080 emulation.
"""

BONUS_TEXT_ROM = 0x4508


def check_last_alien(rack):
    """$13D2 CountAliens: flag 1000/800/500 when precisely one survives."""
    m = rack.mem
    bank = m[0x2067] << 8
    survivors = [i for i in range(55) if m[bank + i]]
    if len(survivors) != 1:
        return 0
    idx = survivors[0]
    status = m[bank + idx]
    if idx == 0:
        m[0x20AE] = m[0x20B3] = status
        return 1000
    # The $13DC search covers only the bottom two rows, and demands octopus.
    if idx >= 22 or status != 1:
        return 0
    m[0x20AE] = 1
    if idx == 5:
        m[0x20B4] = 1
        return 800
    return 500


class Part2RackBonus:
    """$4410 beam and ROM message presentation with frame-stepped foreground."""
    def __init__(self, rack):
        self.rack = rack
        m = rack.mem
        self.points = (1000 if m[0x20B3] else 800 if m[0x20B4] else 500) if m[0x20AE] else 0
        self.fans = 4 if self.points == 1000 else 3 if self.points == 800 else 2
        self.fan = 0
        self.y = m[0x200B]
        self.origin_x = (m[0x200C] + 7) & 255
        self.count = 1
        self.spread = 2
        self.wait = 0
        self.finished = self.points == 0
        if self.points:
            # $441B -> AdjustScore: packed BCD in units of ten points.
            score_units = self.points // 10
            m[0x20F2] = ((score_units // 10) << 4) | (score_units % 10)
            m[0x20F3] = 0
            if self.points == 1000:
                m[0x20F2], m[0x20F3] = 0x00, 0x01
            m[0x20F1] = 1
            rack.combat.adjust_score()
            m[0x20B5] = self.fans
            m[0x20BE] = 0
            self._message()
            self._dot(self.origin_x, self.y)
            self.y = (self.y + 8) & 255

    def _message(self):
        m = self.rack.mem
        # $442B PrintMessage, $4449 patch of ' 5' to ' 8' or '10'.
        from part2_rom import load_rom
        _, extra = load_rom()
        codes = list(extra[BONUS_TEXT_ROM - 0x4000:BONUS_TEXT_ROM - 0x4000 + 17])
        if self.points == 800:
            codes[6:8] = list(m[0x09C6:0x09C8])
        elif self.points == 1000:
            codes[6:8] = list(m[0x09C8:0x09CA])
        pos = 0x2904
        for code in codes:
            pos = self.rack.score_display.draw_char(code, pos)

    def _dot(self, x, y):
        addr = 0x2000 | (((y << 8) | x) >> 3)
        if 0x2400 <= addr < 0x4000:
            self.rack.mem[addr] = 0x0F   # $44D0 BeamDot: overwrite, do not OR

    def step(self):
        if self.finished:
            return True
        if self.wait:
            self.wait -= 1
            if not self.wait:
                self.finished = True
            return self.finished
        if self.y >= 0xC8:
            self.fan += 1
            self.rack.mem[0x20BE] = self.fan
            if self.fan > self.fans:  # $44F4 CMP M; JC done
                self.wait = 120   # $44FC TwoSecDelay, ISR frame approximation
                return False
            # $44F0 ClearPlayField before drawing the next fan.
            m = self.rack.mem
            for addr in range(0x2402, 0x4000):
                if 2 <= (addr & 31) < 28:
                    m[addr] = 0
            self._message()
            self.y = m[0x200B]
            self.count, self.spread = 1, 2
            self._dot(self.origin_x, self.y)
            self.y = (self.y + 8) & 255
            return False
        x = self.origin_x
        self._dot(x, self.y)
        for _ in range(self.count):
            x -= self.spread
            if x < 0x38:
                break
            self._dot(x, self.y)
        x = self.origin_x
        for _ in range(self.count):
            x += self.spread
            if x >= 0xE8:
                break
            self._dot(x, self.y)
        self.count = (self.count + 1) & 255
        self.spread = (self.spread + 1) & 255
        self.y = (self.y + 8) & 255
        return False
