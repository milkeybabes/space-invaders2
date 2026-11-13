# Part II ROM startup/status drawing correction

The initial scoreboard/credits are not visible when the splash title begins.
The 8080 init calls `ClearAndStatus` at $169A, but `SplashLoop` clears the
entire VRAM at $0CDD before waiting and entering `TitleScreen` at $40DC.

`Part2Title.__init__` now leaves VRAM cleared. The title draws the status
at the translated $4127 / $1719 operation, after the dot-carving and
PART II bitmap stages. `DrawScores` now translates the missing $16FA/$1705
credit-label and count operations directly from the Part II ROM data.

The title's ROM carving test hashes only the bitmap phase so status
changes do not accidentally invalidate a carving regression.

The remaining foreground CPU execution spans and high-score name/
flashing presentation are not yet instruction-timed; do not treat this
fix as full frame-perfect attract timing.

Run:
  python part2_title_carve_regression_test.py
  python part2_source_timing_test.py
  python part2_play.py --scale 3
