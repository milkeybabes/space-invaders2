# Space Invaders Part II Python v2 — Stage 10: rack arrival

**Installation:** Extract this ZIP directly into your existing Part II working directory, overwriting files. This is a complete, flat project archive. Your 1978 v1 project remains separate.

## Translation

`part2_rack_arrive.py` translates the core logic of **$09CA RackArrive** in `invadpt2.asm`. It copies RAM `$2000–$200F` to the `$2300–$230F` save area, zeros sideways rack motion, starts the rack at Y `$A8`, determines the drop increment from the live alien count (26+ => 4, 10–25 => 2, fewer than 10 => 1), and repeatedly invokes the translated alien cursor/drawer to descend. It compares the reference Y coordinate against the **saved** original target Y and restores the saved rack descriptor when it arrives. It asserts `$20B9` during arrival.

The Stage 08/09 autonomous demo now calls this translation at the beginning of the demo formation. The two simulated interrupt phases continue firing while normal game tasks are temporarily suspended, then live demo processing resumes.

**Important timing qualification:** The ROM invokes RackArrive synchronously in the foreground and uses sound/delay routines; Stage 10 currently drives **eight cursor/draw operations per displayed frame**. This is a preview pacing choice, NOT a verified instruction-cycle or frame-perfect timing reconstruction. The target position is taken from the existing reference position; the full round-start and round-to-round target-height progression in the original ROM is NOT yet integrated. The ROM-specific attract intro and score table are also still provisional. No claim of MAME visual parity is made.

## Commands (Windows Command Prompt)

```bat
python part2_stage10_test.py
python part2_stage09_test.py
python part2_play.py
```

Optional headless smoke test:

```bat
python part2_play.py --headless --frames 1500
```

Older Stage 02–08 tests and `part2_diagnostic.py` remain available and have been rerun.
