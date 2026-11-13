# v17: restore the ROM lives HUD after the two-player VRAM handoff

## Fault reproduced

v16 correctly decremented $21FF/$22FF on return to a player, but its
`Part2TwoPlayer._show_player_prompt()` updated the life digit and reserve icons
**before** copying the outgoing player's $2400-$3FFF display into the incoming
bank. That VRAM copy replaced the correct life glyph and icons with stale ones.
The state trace therefore showed Player 1 with stash=1 (2 displayed lives)
while frame 3950 visibly retained a `3` and two reserve icons.

## Correction

In `part2_two_player.py`, `_finish_arrival_clear()` now calls the existing ROM
sprite/glyph routines `PlayerLives.draw_reserve_ships()` ($19E6) and
`PlayerLives.draw_lives_number()` ($1A8B) *after* the incoming player's
screen has completed the $0BA3 clear and before rack arrival resumes.
The actual per-player reserve counts and deferred decrement logic are unchanged.
Initial Player 1 startup and alien shooting logic are unchanged.

## Regression

`python part2_v17_lives_vram_test.py`

This simulates both player deaths and the Player 1 return, checking the actual
bytes in video RAM for the displayed digit and 16-column reserve sprites.
Previous tests checked only $21FF/$22FF and could not catch this display bug.

Other passing focused tests: v9 palette/death, v12 handoff timer,
v15 VRAM wipe, v16 reserve accounting. Full 7,300-frame headless INP replay
completed. Visual comparison against MAME at frame 3950 remains to be done.
