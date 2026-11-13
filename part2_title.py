"""Space Invaders Part II title, built from original $40DC ROM bitmaps.

This translates the FillDots/CarveBitmap/CopyBitmap *graphics operations*,
not the 8080 CPU. The source-driven foreground scheduler executes dot-erasure operations
across frame budgets, including the $0EC9 delay inside $41A4 CarveGroup.
"""
from __future__ import annotations
from part2_rom import load_rom

W, H = 224, 256
VRAM_START = 0x2400
VRAM_END = 0x4000


def portrait_luma(mem):
    pixels = bytearray(W * H)
    for x in range(W):
        a = VRAM_START + x*32
        for j in range(32):
            v = mem[a+j]
            if v:
                for b in range(8):
                    if v & (1<<b):
                        pixels[(255-(j*8+b))*W+x] = 255
    return bytes(pixels)


class Part2Title:
    """Translate $40DC, $41CD, $4148, $4133, with $41A4 busy-waits."""
    def __init__(self):
        lower, extra = load_rom()
        self.mem = bytearray(0x4800)
        self.mem[:0x2000] = lower
        self.mem[0x4000:0x4800] = extra
        # The title is drawn into screen RAM. Render it with the 1979 ROM font.
        from part2_display import Part2ScoreDisplay
        class Screen:
            pass
        screen = Screen()
        screen.mem = self.mem
        self.scores = Part2ScoreDisplay(screen)
        # $169A initially draws status, but $0CDD ClearScreen erases it
        # before the one-second wait and $40DC title sequence. The title
        # redraws status at $4127; do not show it at frame zero.
        self.ops = []
        self.stage_ends = []
        self._build_ops()
        self.index = 0
        self.pending_cycles = 0
        self.extra_cycles = 0

    def write(self, addr, value, op='set'):
        if VRAM_START <= addr < VRAM_END:
            if op == 'and':
                self.mem[addr] &= value
            else:
                self.mem[addr] = value

    def _fill(self, addr, width, columns, pattern=0x41E4):
        # $41CD: for each row, DrawSimpSprite writes C groups of 8 bytes,
        # moving HL by $20 per byte. After each row, DCX H.
        for row in range(width):
            start = addr - row
            for col in range(columns):
                for i in range(8):
                    self.ops.append((start + (col*8+i)*32,
                                     self.mem[pattern+i], 'fill_byte'))

    def _carve(self, addr, bitmap, count_bytes, passes):
        # $4148 CarveBitmap: C counts PASSES (not paired columns).
        # The $20B0 toggle selects masks 0x0E then 0xE0, and HL is
        # decremented only AFTER the second pass.  DE advances B bytes
        # on EACH pass, rather than reusing the same bitmap bytes.
        for pass_index in range(passes):
            base = addr - (pass_index // 2)
            mask = 0x0E if pass_index % 2 == 0 else 0xE0
            for b in range(count_bytes):
                bits = self.mem[bitmap + pass_index * count_bytes + b]
                for bit in range(8):
                    if bits & (1 << bit):
                        # $4151-$415D: four DAD D steps, even for kept dots.
                        self.ops.append(('skip_group', 0, None))
                    else:
                        pos = base + (b * 32 + bit * 4) * 32
                        for k in range(3):
                            self.ops.append((pos + k * 32, mask, 'carve_byte'))
                        # $41BC-$41C5: each erased three-byte group invokes
                        # DelayBC($0250). The wait occurs AFTER the pixels clear.
                        self.ops.append(('delay_bc', 0x0250, None))

    def _copy(self, addr, bitmap, rows, columns):
        # $4133 CopyBitmap: B rows separated by $20, C source bytes per row.
        for row in range(rows):
            for col in range(columns):
                self.ops.append((addr + row*32 + col,
                                 self.mem[bitmap + row*columns + col], 'set'))

    def _build_ops(self):
        self._fill(0x2617, 8, 24)
        self.stage_ends.append(len(self.ops))
        self._carve(0x2617, 0x41EC, 6, 16)
        self.stage_ends.append(len(self.ops))
        self._fill(0x260D, 4, 24)
        self.stage_ends.append(len(self.ops))
        self._carve(0x260D, 0x424C, 6, 8)
        self.stage_ends.append(len(self.ops))
        self._copy(0x2E06, 0x427C, 56, 2)
        self.stage_ends.append(len(self.ops))
        # Original title calls DrawScores after drawing title.
        self.ops.append(('scores', None, None))
        self.stage_ends.append(len(self.ops))

    @staticmethod
    def _delay_bc_cycles(bc):
        """Count the actual 8080 DCR/JNZ loops at ROM $0EC9-$0ED1.

        DCR C wraps through 0x00 before DCR B is reached. The loop
        does not simply count BC down as a 16-bit integer.
        """
        b, c = (bc >> 8) & 255, bc & 255
        cycles = 0
        while True:
            c = (c - 1) & 255
            cycles += 5  # DCR C
            if c:
                cycles += 10  # JNZ taken
                continue
            cycles += 7  # JNZ not taken
            b = (b - 1) & 255
            cycles += 5  # DCR B
            if b:
                cycles += 10  # JNZ taken
                continue
            cycles += 7 + 10  # JNZ not taken, RET
            return cycles

    # Approximate per-operation source instruction budgets (8080 T-states).
    # Each DrawSimpSprite eight-byte call executes about 607 cycles in the
    # recursive loop, plus its CALL, FillDots loop and row bookkeeping.
    # 85 cycles/byte captures the actual instruction work without interpreting
    # each 8080 opcode. Frame pacing is independent of host CPU speed.
    FILL_BYTE_CYCLES = 85
    # In CarveGroup each of the three pixel writes includes loads, masking,
    # pointer addition, loop bookkeeping and call/return overhead; final
    # DelayBC is accounted separately, with its actual source loop count.
    CARVE_BYTE_CYCLES = 115
    # Set bits execute the non-carve ($4151-$415D) branch, advancing four
    # columns in a loop instead of performing the slow erasure.
    SKIP_GROUP_CYCLES = 150
    # CopyBitmap is a plain LDAX/MOV/INX byte-copy loop, not DrawSimpSprite.
    COPY_BYTE_CYCLES = 48

    def advance_cycles(self, cycles, target):
        """Run foreground title drawing within an 8080 cycle budget.

        DelayBC is opcode-counted. Ordinary VRAM writes use a minimum
        opcode estimate; the entire CPU is not being emulated.
        """
        while cycles > 0 and self.index < target:
            if self.pending_cycles:
                spent = min(cycles, self.pending_cycles)
                self.pending_cycles -= spent
                cycles -= spent
                if self.pending_cycles:
                    break
                self.index += 1
                continue
            addr, value, op = self.ops[self.index]
            if addr == 'delay_bc':
                self.pending_cycles = self._delay_bc_cycles(value)
                continue
            if addr == 'scores':
                self.scores.redraw_scores()
                self.index += 1
                continue
            if addr == 'skip_group':
                cycles -= self.SKIP_GROUP_CYCLES
            else:
                self.write(addr, value, 'and' if op == 'carve_byte' else 'set')
                cycles -= {
                    'fill_byte': self.FILL_BYTE_CYCLES,
                    'carve_byte': self.CARVE_BYTE_CYCLES,
                    'set': self.COPY_BYTE_CYCLES,
                }[op]
            self.index += 1
        return self.index >= target and not self.pending_cycles

    def advance_to(self, target):
        target = min(len(self.ops), max(0, int(target)))
        while self.index < target:
            addr, value, op = self.ops[self.index]
            if addr in ('delay_bc', 'skip_group'):
                self.index += 1
                continue
            if addr == 'scores':
                self.scores.redraw_scores()
            else:
                self.write(addr, value, 'and' if op == 'carve_byte' else 'set')
            self.index += 1

    def seek(self, fraction):
        self.advance_to(round(len(self.ops) * fraction))

    def image(self):
        return portrait_luma(self.mem)
