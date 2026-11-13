# Part II — title frame-verification checkpoint

The uploaded foreground-timing build has now been independently replayed in
Python. **No simulation timing constants have been changed in this ZIP.**
Instead, we added matching frame-done traces so the next timing adjustment can
be anchored to measured MAME VRAM transitions rather than approximate frame
labels.

## Current Python checkpoints (cold boot, `Part2AttractPreview.step()`)

| Event | Frame |
|---|---:|
| SPACE fill complete | 86 |
| SPACE carve complete | 205 |
| INVADERS fill complete | 270 |
| INVADERS carve **first VRAM pixels erased** | **334** |
| INVADERS carve complete | 360 |
| PART II bitmap complete | 424 |

At frame 325, the INVADERS stage still has **9 IRQ ticks to wait**. The
previous claim that a Python reveal *starts* at 325 was incorrect for this
uploaded build. Python frame 334 removes 54 lit pixels, then another 54
at frame 335. MAME ~338 is a prior *visual observation*, not yet a sampled
VRAM transition with matched frame-number origin.

## How to acquire the matching traces

From Windows Command Prompt in your Python project folder:

```cmd
python trace_part2_title_python.py
```

This writes `diagnostics\part2_title_python_frames.csv` for frames 250–400.

Copy `trace_part2_title_mame.lua` to your MAME folder, then run from Command
Prompt in the MAME folder:

```cmd
mame.exe invadpt2 -video none -autoboot_script trace_part2_title_mame.lua
```

The script writes `part2_title_mame_frames.csv` in the working directory.
After frame 400, you can exit MAME. The trace is read-only and captures
per-frame VRAM bit counts, changed bytes, cleared/added pixels and the first
changed VRAM address. If your MAME driver names Part II differently, retain
the ROM set name you normally use.

Important: use **cold power-on** for both runs, not F3 reset, and preserve
frame zero. These traces tell us whether MAME's initial `INVADERS` erasure
really occurs at frame 338, and whether a fixed frame offset exists.

This is a diagnostic build, not a claim of newly verified MAME timing parity.
Do not add a four-frame delay unless the two traces show its source.
