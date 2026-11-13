"""Source-driven 8080 Part II boot/attract preparation (native algorithms).

$168F init: copy 256-byte RAM mirror, copy 14-byte name, $17DA clear
7168 video bytes, $1719 DrawScores; $0CD8 SplashLoop clears video again.
The CPU cycle values count the actual 8080 instructions in those loops.
This is operation timing, not CPU emulation, and does not insert an AVI delay.
"""
from __future__ import annotations

CPU_HZ = 1_996_800
# MAME screen refresh: (19,968,000 / 4) / (320 * 262) ≈ 59.54 Hz.
FPS = 59.541985
CYCLES_PER_FRAME = CPU_HZ / FPS
VRAM_BEGIN, VRAM_END = 0x2400, 0x4000
VRAM_SIZE = VRAM_END - VRAM_BEGIN


def block_copy_cycles(count):
    """$179? BlockCopy: LDAX D/MOV M,A/INX H/INX D/DCR B/JNZ."""
    # 7+7+5+5+5+10 = 39, except last JNZ is 7; RET=10.
    return 39 * count - 3 + 10


def char_ptr_cycles(code):
    """$1A24 CharPtr, including the 5*n repeated-add addressing loop."""
    if code == 0:
        return 10 + 4 + 11  # LXI D,ANA A,RZ
    # LXI D,ANA A,RZ(not),PUSH H,LXI H,PUSH B,
    # n * (LXI B,DAD B,DCR A,JNZ), tail DAD D ... RET.
    return (10+4+5+11+10+11 + (35 * code - 3)
            + 10+5+10+10+10)


def draw_char_cycles(code):
    """$0AE5 DrawChar via CharPtr and 5-byte DrawSimpSprite."""
    # 5 sprite iterations, explicit 3 blank bytes. Include calls/rets.
    simple_sprite = 5 * (11+7+7+5+10+10+10+5+10) - 3 + 10
    tail = 11+4+7+10+10+7+10+7+10+10+10
    return 17 + char_ptr_cycles(code) + 7+10+17+simple_sprite+tail


def print_message_cycles(codes):
    """$0AB4 PrintMessage including per-character call/loop overhead."""
    codes = list(codes)
    if not codes:
        return 10
    return sum(draw_char_cycles(v) + (7+11+17+10+5+5+10) for v in codes) - 3 + 10


def startup_status_cycles(mem):
    """Work performed by $1719/$171B/$170A/$1705 score/status printing.

    Includes font address walks, sprite columns, and PrintMessage loops;
    small setup/return overhead is accounted from the calling instructions.
    """
    header = mem[0x1862:0x1862+28]
    credit = mem[0x1F42:0x1F42+7]
    name = mem[0x1109:0x1109+10]  # $1120 DefaultName installs these in $2340.
    # Each score contains 4 BCD digits + one fixed 0, all zero at boot except
    # the 05000 hi-score (memory bytes $1BF4..$1BFF are real ROM descriptors).
    digits = []
    for desc in (0x20F8, 0x20FC, 0x20F4):
        lo, hi = mem[desc], mem[desc+1]
        for byte in (hi, lo):
            digits += [0x1c + (byte >> 4), 0x1c + (byte & 15)]
        digits.append(0x1c)
    # $170E DrawScore -> $107A Print4Digits0 -> $0AC2 DrawHexByte:
    # the five DrawChar calls plus four DrawDigit ADI/JMP transfers.
    score_wrappers = (20 + (5+5+5+5+7+5+7+5+10)
                      + (11+11+10+10+7+17+10+10+10)
                      + (5+17+5) + 2*(11+11+4*4+7+17+10+7+17+10+10)
                      + 4*(7+10))
    cycles = (37 + print_message_cycles(header))  # $16D8 DrawScoreHead
    cycles += sum(draw_char_cycles(d) for d in digits) + 3*score_wrappers
    cycles += 100 + 54 + print_message_cycles(name)  # $10A3,$1033
    cycles += 37 + print_message_cycles(credit)  # $16FA DrawCreditLabel
    cycles += 40 + draw_char_cycles(0x1c)  # $1705 DrawNumCredits
    cycles += 17 + 7*17 + 10  # $1719 DrawScores / $171B DrawStatus
    return cycles


class Part2Startup:
    """Two ROM ClearScreen passes with intervening ROM score drawing."""
    def __init__(self, title, cold_boot=True, retained_name_mem=None):
        self.title = title
        self.mem = title.mem
        self.stage = 'init_copy' if cold_boot else 'clear_splash'
        self.cycles = 0.0
        self.clear_offset = 0
        self.events = []
        # $168F: CopyMirrorB copies 2000..20FF, DefaultName installs TAITO.
        # Descriptor mirror is already installed by Part2ScoreDisplay.
        self.retained_name_mem = retained_name_mem
        if retained_name_mem is not None and retained_name_mem[0x234C]:
            self.mem[0x2340:0x234D] = retained_name_mem[0x2340:0x234D]
            self.mem[0x233E:0x2340] = retained_name_mem[0x233E:0x2340]
            self.mem[0x20F4:0x20F6] = retained_name_mem[0x20F4:0x20F6]
        else:
            self.mem[0x2340:0x234e] = self.mem[0x1109:0x1117]
            self.mem[0x234c] = 10  # $10AE CenterHiName fills default length.
            self.mem[0x234e] = 0x1e
            self.mem[0x234f] = 0x2d
        self.init_cycles = (10+7+17 + block_copy_cycles(256) +
                            17 + 7+10+10 + block_copy_cycles(14) + 10 +
                            17)  # init, mirror, DefaultName, ClearAndStatus
        self.status_cycles = startup_status_cycles(self.mem)

    @property
    def done(self):
        return self.stage == 'done'

    def step(self, frame):
        budget = CYCLES_PER_FRAME
        while budget > 0 and not self.done:
            if self.stage == 'init_copy':
                spend = min(budget, self.init_cycles - self.cycles)
                self.cycles += spend
                budget -= spend
                if self.cycles >= self.init_cycles:
                    self.cycles = 0
                    self.stage = 'clear_initial'
                    self.events.append((frame, self.stage))
            elif self.stage in ('clear_initial', 'clear_splash'):
                # Carry residual cycle budget between frames, no frame rounding.
                available = budget + self.cycles
                n = min(VRAM_SIZE - self.clear_offset, int(available / 37))
                if n:
                    start = VRAM_BEGIN + self.clear_offset
                    self.mem[start:start+n] = bytes(n)
                    self.clear_offset += n
                remaining = available - 37*n
                if self.clear_offset == VRAM_SIZE:
                    # Last JNZ is 7 rather than 10, then RET=10.
                    remaining -= 7
                    self.cycles = 0
                    self.clear_offset = 0
                    if self.stage == 'clear_initial':
                        self.stage = 'draw_status'
                    else:
                        self.stage = 'done'
                    self.events.append((frame, self.stage))
                    budget = max(0.0, remaining)
                else:
                    # Any fractional amount goes into the next frame.
                    self.cycles = remaining
                    budget = 0
            elif self.stage == 'draw_status':
                spend = min(budget, self.status_cycles - self.cycles)
                self.cycles += spend
                budget -= spend
                if self.cycles >= self.status_cycles:
                    self.title.scores.redraw_scores()
                    # $171B CenterHiName, PrintHiName: default name from ROM.
                    if self.retained_name_mem is not None and self.mem[0x234C]:
                        at = (self.mem[0x233F] << 8) | self.mem[0x233E]
                        codes = self.mem[0x2340:0x2340+min(self.mem[0x234C], 10)]
                    else:
                        at = 0x2d1e
                        codes = self.mem[0x2340:0x234a]
                    for code in codes:
                        at = self.title.scores.draw_char(code, at)
                    self.stage = 'clear_splash'
                    self.cycles = 0
                    self.events.append((frame, 'status_visible'))
            else:
                raise AssertionError(self.stage)
        return budget
