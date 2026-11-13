# v14 — translate the ROM $0D32 post-game coin foreground (not an instant framebuffer)

The v13 controller dispatched to the correct `$0D32` branch but cheated by
calling `Part2AttractScreen.advance_ticks(0x7FFF)` in one video frame. That
violated the original 8080 foreground execution order and missed several
subroutines and delays altogether.

v14 implements a sequential foreground job in `part2_coin_foreground.py`:

1. `$0D36` -> `$0C9D`: 64 IRQ-tick pause.
2. `$0D39` -> `$0BA3`: clear playfield in the **actual VRAM byte order**
   (26 rows, 223 addresses separated by `$20`), retaining the score display.
3. `$0D3C-$0D44` -> `$0AD9/$0AE5`: draw the 12-character `INSERT COIN`
   message, one character at a time, accounting for estimated 8080 cycles.
4. `$0D47` -> `$0DD2/$10BA`: write `*TAITO CORPORATION*` using the
   backwards scrambled ROM data at `$1751`, followed by **five** cycles of
   the high-score/name flash sequence with the actual `$20` tick waits.
5. `$0D4A` -> `$167D/$1673/$0C85`: read the ROM descriptor at `$1123` and
   print its characters with the **7 down to 1** interrupt countdown.
6. `$0D53-$0D5C`: for the normal (coin-info-visible) DIP mode, process
   the two descriptors at `$1127` and `$112B` with the same delay.
7. `$0D5F` -> `$0CA2`: 128 IRQ-tick pause; `$0D62` clear playfield again;
   `$0D65` resume the title/attract cycle.

The `$206C` character count is retained from the departing game's RAM,
not reconstructed from a static message string. The actual game path
supplies `$12` (18 characters). The previous VRAM is also carried over,
so each ROM clear/write affects the framebuffer as it happens. The same
controller is used by the windowed and headless replay paths.

**Faithfulness boundary:** instruction *order*, ROM bytes, write addresses,
character-delays, flash count, and `$40/$80/$20` IRQ waits are ROM-derived.
The foreground **instruction-cycle budget** uses `draw_char_cycles()` and
an approximate 41 cycles per `$0BA3` byte operation. This is a native-Python
translation, not an 8080 CPU emulator. Exact per-pixel frame parity has
not yet been established. The default operator-credit DIP branch is used;
the `$0D53` bit-7 skip branch requires wiring a DIP input.

Checks run: `part2_v14_coin_foreground_test.py`,
`part2_source_timing_test.py`, `part2_stage08_test.py`,
`part2_stage12_test.py`, `part2_v13_postgame_attract_test.py`,
`part2_v10_gameover_handoff_test.py`, `part2_v12_handoff_timer_test.py`,
Python `compileall`, and the entire 7300-frame `.inp` replay.

Replay:

    python part2_play.py --playback-inp part2_2player.inp --record part2_v14_replay.avi

Frame 7232 now remains in the `insert_coin` phase rather than
prematurely displaying the title. Further screenshot comparison is needed
to verify the exact point within the letter-printing/flash sequence.
