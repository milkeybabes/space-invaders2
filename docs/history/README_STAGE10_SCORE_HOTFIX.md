# Space Invaders Part II — Stage 10 scoreboard restoration hotfix

This is an incremental overwrite for the Stage 10 project, not a new folder.
Extract these files over your existing SpaceInvaders_PartII_Python_v2_Stage01 directory.

## Fix

The original 8080 `RackArrive` routine at $09CA restores $2000-$200F
and then calls `DrawScores` ($1719). Our Python Stage 10 rack arrival
restored the rack variables but omitted the redraw. Because the alien
sprites and the scoreboard share 1-bit video memory, the descent could
rub out the displayed scores and headings.

`part2_rack_arrive.py` now invokes a ROM-font-based `redraw_scores()` after
restoring the saved rack state. `part2_display.py` implements that redraw
for the three 5-digit scores and headings currently supported in the
provisional Stage 10 attract preview. Name and credit text are not yet
ported, so this is not a complete replacement for every operation in the
original 1979 DrawScores routine.

The player-shot explosion in the screenshot was *not* changed.

## Verify (Windows Command Prompt)

    python part2_stage10_score_hotfix_test.py
    python part2_stage10_test.py
    python part2_play.py

The new regression test intentionally corrupts the score glyph pixels
and verifies that rack-arrival completion paints them correctly again.
All Stage 02–10 regression tests and the 1,500-frame smoke test passed.

Note: The provisional foreground pacing still differs from the original
8080 timing, so comparison with the MAME footage remains necessary.
