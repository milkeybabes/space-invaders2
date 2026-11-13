# v8 — rack-arrival scoreboard restoration

MAME comparison (frames 597-600) showed the original invaders temporarily overwriting the score/TAITO area as they travel downward. Python v7 was repainting all scores **every game frame** through `Part2TwoPlayer._sync_scores()`, preventing that authentic effect.

v8 changes:

- Synchronize both players' score bytes in RAM every frame without unconditionally repainting the HUD.
- Repaint an individual score field on actual value changes, outside an active rack arrival.
- Preserve the `$0A4D` completion call to `redraw_scores()` at the end of rack arrival.
- Draw the ROM's default TAITO high-score name with the standard score-display restoration, using the same original glyph bytes as the credit/start display.
- Leave v6 alien drawing cadence and v7 $0080 player ship / enemy firing gates unchanged.

Regression: `python part2_v8_score_arrival_test.py`; also passes v6, v7, stage10, two-player transition and credit tests. Headless 7,300-frame INP replay completes.

This corrects a verified premature redraw. Exact per-frame pixel parity around frame 597 and the claimed ~5-frame ship difference are still pending independent MAME AVI verification; no ship-timing adjustment has been made.

Replay:

    python part2_play.py --playback-inp part2_2player.inp --record part2_v8_replay.avi
