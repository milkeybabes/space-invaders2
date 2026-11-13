# Space Invaders Part II — v24 final polish

Built on v23 (ROM InitRack restore), preserving the existing gameplay and
7,300-frame INP reproducibility. No artificial missile offsets or death-timing
changes were added. Frame-exact matching is not claimed.

## Play

    python part2_play.py
    python part2_play.py --lives 4
    python part2_play.py --debug
    python part2_play.py --artwork bezel
    python part2_play.py --lives 4 --artwork bezel

Default: three lives, ROM Part II colour, black backdrop, no bezel, standard
screen at 224 x 256 logical pixels. `--lives 3` or `--lives 4` implements
both original DIP choices. The displayed reserve ships follow total lives
minus the active player. `--debug` preserves the existing unlimited-life
behaviour for testing (not authentic gameplay).

## ROM high-score registration

    python part2_play.py --test-high-score
    python part2_play.py --test-high-score --artwork bezel

The $0DFA-$1025 "HI-SCORER REGISTRATION" is now integrated into natural
post-game transitions when a player beats the existing high score. Use LEFT
or RIGHT (A/D also supported) to select from A-Z, period, RUB, END. Press
and release SPACE (or left CTRL) to enter the highlighted character. Press
ENTER to finish the test quickly. Maximum ten characters, with the ROM
$2000 interrupt timeout. Selecting END completes entry; selecting RUB removes
one character. An empty name defaults to TAITO. The saved name and score
carry into the post-game insert-coin and attract display and further new
plays within the same execution. F3 resets the machine as before.

The name-entry drawing order / CPU timing remains approximate; the ROM
character data, RAM buffer layout, controls and input semantics are used.
Persistence across *process restarts* is not supplied; this game preserves
RAM-based high scores only while the program runs, like power-cycle RAM.

## Artwork

Artwork `artwork/part2_bezel.png` was supplied by the user and can be shown
with `--artwork bezel`. Its 1920 x 1080 art surrounds a nearest-neighbour
integer-scaled game image; the original 224 x 256 game buffer is unchanged.
The game backdrop stays black. The Part I moon backdrop is NOT copied to
Part II without confirmation that it belongs to this specific Taito/Midway
cabinet version. AVI capture uses the original game bitmap, without artwork.

## Reproducible replay

    python part2_play.py --playback-inp part2_2player.inp --record part2_v24_replay.avi
    python part2_play.py --headless --playback-inp part2_2player.inp --lives 3

The original 7,300-frame replay and 12 selected older stage regressions
passed in the build container. Actual pygame-ce display needs testing on
Windows with installed pygame-ce; GUI was not available in this environment.

## Principal changed files

- part2_play.py, part2_headless.py
- part2_first_play.py, part2_two_player.py
- part2_hi_score_entry.py (new), game_over.py
- part2_display.py, part2_coin_foreground.py
- part2_startup.py, part2_attract.py
- part2_bezel.py (new), artwork/part2_bezel.png (supplied)
- part2_v24_final_features_test.py (new)

Full package, not incremental patches.
