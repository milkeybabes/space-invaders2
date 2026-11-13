# Part II — source-timed cold start and first title dots

This release corrects the missing 8080 foreground work between reset and
`TitleScreen`. No wait length is copied from the MAME AVI.

- `init` at $168F copies 256 bytes of the ROM RAM mirror and the 14-byte
  default name (`TAITO`) from $1109.
- `ClearAndStatus` at $169A runs the original $17DA screen-clear loop, then
  `$1719 DrawScores` / `$171B DrawStatus`. The score values and CREDIT 0 are
  displayed and the default high-score name is printed over HI-SCORE.
- `SplashLoop` at $0CD8 clears all 7,168 VRAM bytes a **second** time.
- `OneSecDelay` uses exactly the ROM's $40 ISR countdown; foreground resumes
  on the decrement reaching zero.
- The existing `$40DC TitleScreen` bitmap operations then start.

The two `$17DA` clear loops alone require about 15.8 full video-frame times
at the original 1,996,800-Hz CPU clock. Timing work also counts the ROM's
memory-copy, text printing, and font-addressing instructions. This is source-
level operation counting, not an 8080 interpreter or an added screen delay.

In the Python frame diagnostic:
- Frame 11: initial score + TAITO + credit display, before the second clear.
- Frame 19: second clear finished; the original $40 wait has started.
- Frame 83: first title dot writes (previous implementation: frame 64).

These frame numbers are local diagnostic observations. MAME remains the
independent reference: no claim is made yet about exact per-pixel progress
within the fill/carve routines or global cycle-perfect execution. The startup
initialization runs only at power-on/F3 reset; following attract cycles execute
just the ROM splash clear.

Check:
    python part2_startup_rom_test.py
    python part2_source_timing_test.py
    python part2_play.py --scale 3 --record diagnostics\part2_attract.avi

Other gameplay, native AVI recording and F3/F5/F8/F12 controls are unchanged.
