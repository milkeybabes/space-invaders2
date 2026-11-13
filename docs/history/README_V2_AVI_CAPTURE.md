# Part II — lossless AVI capture for MAME comparisons

Requires FFmpeg (`ffmpeg.exe`) accessible on your Windows PATH.
Recording does not set gameplay timers or alter the ROM-driven logic; it records one image per completed simulation step.

From your existing Part II working directory:

    python part2_play.py --scale 3 --record diagnostics\part2_attract.avi

Stop with Esc or close the window. FFmpeg finalizes the AVI when the game closes.
Record a fixed-length run (4,500 frames):

    python part2_play.py --scale 3 --record diagnostics\part2_attract_4500.avi --frames 4500

Or capture without showing a window (useful for a deterministic run):

    python part2_play.py --scale 3 --headless --record diagnostics\part2_attract_4500.avi --frames 4500

AVI codec: lossless FFV1; exact 672x768 RGB frames at 59.542 fps for --scale 3.
The FFV1 AVI may be large but preserves pixel edges for comparison. FFmpeg-based conversion can be done afterward if needed.
F5 pauses simulation (paused frames aren't recorded); F3 resets it. Window scaling keys are disabled during capture to keep frame dimensions fixed. No sound track is included.

Notes: The --headless recording option still requires pygame-ce, using its dummy display driver. The original `--headless` smoke-check mode without --record remains unchanged.
