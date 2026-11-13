"""Post-game ROM $0D32 foreground, preserving the ordered 8080 VRAM writes.

Source: $0BA3 ClearPlayField, $0AD9/$0AE5 PrintMessage/DrawChar,
$0DD2->$10BA FlashHiNameDo, $167D/$1673 descriptor/PrintMessageDel.
CPU cycle accounting is an estimate using the translated instruction costs
(part2_startup), not a substitute for the interrupt-scheduled ROM delays.
"""
from part2_attract_screens import Part2AttractScreen
from part2_startup import CYCLES_PER_FRAME, draw_char_cycles


class Part2CoinForeground:
    def __init__(self, previous_mem=None):
        self.screen = Part2AttractScreen('insert_coin')
        self.mem = self.screen.mem
        if previous_mem is not None:
            self.mem[0x2400:0x4000] = previous_mem[0x2400:0x4000]
            self.mem[0x2340:0x2355] = previous_mem[0x2340:0x2355]
            self.mem[0x20F4:0x20F6] = previous_mem[0x20F4:0x20F6]
            self.mem[0x20E0] = previous_mem[0x20E0]
            # The high score printed on the post-game credits must be the
            # newly earned value, not the cold-boot ROM default.
            self.screen.scores.draw_score(0x20F4)
            self.mem[0x206c] = previous_mem[0x206c]
        # $164C loaded 11 for the score-advance table. Live post-game
        # RAM normally holds 18; retain it instead of choosing a font length.
        if previous_mem is None:
            # A standalone attract-mode test has no preceding game RAM.
            # Use the same Part II RAM mirror created by Rack, not a guessed
            # descriptor count or fabricated text length.
            from part2_two_player import Part2TwoPlayer
            self.mem[0x206c] = Part2TwoPlayer().rack.mem[0x206c]
        if not any(self.mem[0x2340:0x234a]):
            self.mem[0x2340:0x234a] = self.mem[0x1109:0x1113]
        self.letters_per_descriptor = self.mem[0x206c]
        self.stages_visited = []
        self._operations = self._rom_operations()
        self._pending = None
        self.wait = 0
        self.cycle_remainder = 0.0
        self.complete = False
        self.stage = 'one_sec'

    def _print(self, addr, src, count, *, delayed=False):
        for n in range(count):
            code = self.mem[src+n]
            yield ('char', addr+n*0x100, code, draw_char_cycles(code)+50)
            if delayed:
                # $0C85 writes 7 to $20C0; $0C90 returns when it is 1.
                yield ('wait', 6)

    def _clear_playfield(self):
        # $0BA3: C=0x1A, B=0xDF, HL=0x2402. Each row is a VRAM
        # byte position; the inner loop increments HL by 0x20.
        for row in range(26):
            for col in range(223):
                yield ('zero', 0x2402 + row + col*0x20, 41)

    def _erase_hi_name(self):
        # $1028: ClearRows(B=0x50, HL=0x2D1E), two bytes per row.
        for row in range(80):
            base = 0x2d1e + row*32
            yield ('zero', base, 24)
            yield ('zero', base+1, 24)

    def _rom_operations(self):
        self.stage = 'one_sec'
        yield ('wait', 0x40)  # $0D36 OneSecDelay
        self.stage = 'clear_before_coin'
        self.stages_visited.append('clear_before_coin')
        yield from self._clear_playfield()  # $0D39
        self.stage = 'insert_coin'
        self.stages_visited.append('insert_coin')
        yield from self._print(0x2c11, 0x1117, 12)  # $0D3C-$0D44
        self.stage = 'corporation'
        self.stages_visited.append('corporation')
        # $4573 PrintCorp reads 19 characters backwards and adds 0x38.
        for i in range(19):
            code = (self.mem[0x1751-i] + 0x38) & 0xff
            yield ('char', 0x2803+i*0x100, code, draw_char_cycles(code)+65)
        self.stage = 'flash_high_name'
        self.stages_visited.append('flash_high_name')
        # $10BA: five cycles of HI-SCORE and name; two 0x20 waits/cycle.
        for _ in range(5):
            yield from self._print(0x2d1e, 0x0d79, 10)
            yield ('wait', 0x20)
            yield from self._erase_hi_name()
            # $1030 PrintHiName uses $233E/$233F for centring and $234C
            # for the entered name's length. The cold ROM fallback retains
            # the original ten-character flash loop until a name exists.
            length = self.mem[0x234C]
            dst = (self.mem[0x233E] | self.mem[0x233F] << 8) if 1 <= length <= 10 else 0x2D1E
            yield from self._print(dst, 0x2340, length if 1 <= length <= 10 else 10)
            yield ('wait', 0x20)
        self.stage = 'player_descriptor'
        self.stages_visited.append('player_descriptor')
        # $0D4A ReadPriStruct($1123), $1673 uses RAM $206C.
        desc = 0x1123
        count = self.letters_per_descriptor
        if not 1 <= count <= 32:
            raise ValueError(f'Invalid ROM descriptor character count $206C={count:02X}')
        dst = self.mem[desc] | (self.mem[desc+1] << 8)
        src = self.mem[desc+2] | (self.mem[desc+3] << 8)
        yield from self._print(dst, src, count, delayed=True)
        # $0D53 INP2 bit 7 governs the two optional operator-credit lines.
        # Standard DIP case: bit 7 clear, descriptors $1127 and $112B.
        self.stage = 'coin_descriptors'
        self.stages_visited.append('coin_descriptors')
        for desc in (0x1127, 0x112b):
            dst = self.mem[desc] | (self.mem[desc+1] << 8)
            src = self.mem[desc+2] | (self.mem[desc+3] << 8)
            yield from self._print(dst, src, count, delayed=True)
        self.stage = 'two_sec'
        self.stages_visited.append('two_sec')
        yield ('wait', 0x80)  # $0D5F TwoSecDelay
        self.stage = 'clear_after_coin'
        self.stages_visited.append('clear_after_coin')
        yield from self._clear_playfield()  # $0D62
        self.stage = 'done'  # $0D65 -> $169D
        self.stages_visited.append('done')

    def step(self):
        if self.complete:
            return
        if self.wait:
            self.wait -= 1
            return
        budget = CYCLES_PER_FRAME + self.cycle_remainder
        self.cycle_remainder = 0.0
        while budget > 0:
            if self._pending is None:
                try:
                    self._pending = next(self._operations)
                except StopIteration:
                    self.complete = True
                    self.screen.complete = True
                    return
            kind, *args = self._pending
            if kind == 'wait':
                self.wait = args[0]
                self._pending = None
                return
            if kind == 'char':
                addr, code, cost = args
            else:
                addr, cost = args
            if budget < cost:
                self.cycle_remainder = budget
                return
            budget -= cost
            if kind == 'char':
                self.screen.scores.draw_char(code, addr)
            else:
                if 0x2400 <= addr < 0x4000:
                    self.mem[addr] = 0
            self._pending = None

    def image(self):
        return self.screen.image()
