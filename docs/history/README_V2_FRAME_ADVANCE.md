# Part II v2 — Frame-by-frame stepping

Controls: F5 toggles pause/resume. While paused, F8 advances exactly one simulation frame per key press; F8 while running does nothing. F3 resets the game as before. F12 saves the current displayed frame, even while paused. Escape exits.

Paused status is in the window title rather than drawn over the game, keeping F12 screenshots and AVI frames clean.

AVI capture records one frame per simulation step: paused idle time creates no duplicate frames; an F8 step is included. The --frames limit likewise counts simulation frames only.

Run: `python part2_play.py --scale 3` or `python part2_play.py --scale 3 --record diagnostics\part2_attract.avi`.
