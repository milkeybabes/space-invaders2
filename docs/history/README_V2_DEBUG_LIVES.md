# Part II playable debug mode

Run `PLAY_PART2_DEBUG.cmd` or `python part2_play.py --debug`. Press 5 to credit, then 1 to start.

Debug mode retains enemy collisions and the normal explosion/respawn sequence, but does not deduct ships or trigger game-over for running out of lives. Alien splitting, saucer drops, scoring, wave bonuses and wave transitions remain enabled. It is for testing, **not** arcade-authentic play. `PLAY_PART2.cmd` and runs without `--debug` are unchanged. F3 reset keeps the chosen command-line debug mode.

Run `python part2_debug_lives_test.py` to test five consecutive deaths with no lost ships, plus the ordinary single-life deduction.
