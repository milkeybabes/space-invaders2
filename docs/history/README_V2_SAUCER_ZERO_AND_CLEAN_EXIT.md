# Part II v2 — Saucer zero-score and clean-exit corrections

## Changes

- The saucer score pointer is initialised at ROM table `$1D50` (`$208D/$208E` = `50 1D`) rather than `$1D54`.
- After each player-shot reset, its low byte advances through `$1D50` to `$1D5E`, wrapping to `$1D50`; this prevents zero awards from unused memory.
- Original packed-BCD scores and ROM-based label drawing are preserved; the initial `$1D50` entry awards 100 points.
- Escape now stops the game before advancing and rendering another frame.
- Ctrl+C in Command Prompt exits through cleanup without printing a traceback.

## Verification

- `python part2_saucer_score_pointer_test.py` checks 60 pointer advances, every normal table entry and an actual saucer-score/label event for all 15 entries.
- `python part2_playable_lifecycle_test.py` now explicitly selects the 150-point ROM entry for its existing graphics test.
- All 30 `*test.py` scripts pass.

## Try

Launch `PLAY_PART2.cmd`; shoot the first flying saucer, and look for a nonzero `PART2 SAUCER: SAUCER_SCORE ...` line. Use Escape to exit normally. This build has not been visually validated in live MAME-matched play.
