# Part II: attract demo commands and firing restored

Cause: the preview advanced a Python-side `command` variable while the original
$03A6 player object read RAM $201D, which stayed at 01 (move right). Also the
combat branch of $1438 was explicitly unimplemented in demo mode, so shots
were not fired from the original ROM demo routine.

Source-derived corrections:
- $1438-$1450: when the player is alive, no timer is running and the old shot
  is idle, flag a new player shot, advance ROM demo command pointer $20ED/EE,
  wrap $1ACA to $1ABF, and copy the actual ROM command into $201D.
- $03A6: existing player handler reads $201D (1=right, 2=left, 0=no motion).
- Initial command pointer comes from the ROM mirror $1BED/EE = $1ABF.
  This pointer persists across attract cycles because the subsequent $0D03
  mirror-copy updates only RAM $2000-$20BF.
- The attract presentation loop no longer invents/duplicates a separate
  command/shot issuing path; the ROM branch is called by foreground service.

Verified: ROM command changes 1,0,0,1,0,2,1, real left and neutral player
motion, actual player shots; 16 source/graphics/startup/regression tests passed.
The foreground is still a partially translated per-frame service rather than
cycle-perfect execution, so exact shot/frame timing requires MAME comparison.

Windows:
  python part2_demo_commands_rom_test.py
  python part2_play.py --scale 3 --record diagnostics\part2_attract.avi

This is a full flat overwrite of the existing project directory. F3/F5/F8/F12,
ROM-drawn title, startup timing and native uncompressed AVI remain included.
