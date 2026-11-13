# Part II v6 — initial 2-player drawing timing

This is an incremental timing adjustment on top of the v5 corrected alien-fire
countdown. It does not replace the existing native-Python game logic.

## Changes

- `part2_two_player.py`: the initial `PLAY PLAYER<1>` state now accounts for
  23 additional approximate video frames of foreground startup work in addition
  to the existing 176-tick player prompt. This 23-frame estimate comes from the
  *recorded MAME input replay* checkpoint and is **not** a measured exact 8080
  execution-cycle count. Later turn handoffs retain their previous 176-tick
  prompt pending separate comparisons.
- `part2_first_play.py`: the first rack-arrival scheduler slice executes just
  one `CursorNextAlien/DrawAlien` operation; subsequent slices retain eight.
- `part2_two_player_initial_prompt_test.py`: updated to account for longer
  first-start prompt.
- `part2_v6_startup_timing_test.py`: validates specific replay checkpoints.

## Frame checks (zero-based MAME INP frame numbering)

- 393: two-player start edge.
- 574: player prompt still showing, arrival has not begun.
- 592: player prompt released; no alien arrival draws.
- 593: first alien draw operation.
- 594: nine alien draw operations total.

These are *internal draw-operation* counts, and visual comparison to the MAME
AVI is still needed; this is not pixel-perfect parity. The ROM startup and
arrival foreground CPU cycle breakdown remains a worthwhile future improvement.

## Run (Windows Command Prompt)

    python part2_play.py --playback-inp part2_2player.inp --record part2_v6_replay.avi

Or headless without pygame:

    python part2_play.py --headless --playback-inp part2_2player.inp --state-trace diagnostics\v6_state.csv

The complete 7,300-frame INP replay and 38 standalone regression tests were
run in this build's environment (all passed). The visual MAME comparison must
be confirmed on the user's machine.
