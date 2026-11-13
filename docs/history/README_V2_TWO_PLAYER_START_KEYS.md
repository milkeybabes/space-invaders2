# Part II — Two-player START key reliability

This build keeps the existing two-player turn controller and makes START input
explicit and testable:

- Press `5` twice for two credits, then press `2` (or numeric keypad 2).
- One credit is insufficient for two-player start; this now prints a readable
  diagnostic instead of ignoring the key without explanation.
- `1` (or keypad 1) starts a one-player game with one available credit.
- Additional credits remain available after starting.
- Start key auto-repeat is ignored; start keys do not start a second game
  during a game in progress.
- New `part2_two_player_start_test.py` validates credit selection, independent
  lives, and the survivor continuing until both players have finished.

Known limitations: Two-player ROM transition screen and exact timing remain
unfinished. Existing Part II gameplay, level selection, debug mode and F12
capture are retained unchanged.
