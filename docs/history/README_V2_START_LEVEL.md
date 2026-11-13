# Start directly on a later Part II level

Use `python part2_play.py --start-level 4 --debug` or double-click `PLAY_PART2_LEVEL4.cmd`.
Then press **5** for a credit and **1** to start. The requested level applies to the next new game (and after F3 reset). `--start 4` is an alias.

Levels are numbered **1–17** for test convenience; the original ROM stores a zero-based round counter at `$21F9`. The ROM wraps after round 16 back to round 9, so later play recycles patterns. This feature alters only the initial round and starting rack height, not the original alien graphics, splitting, missiles, score or next-wave routine.

The initial four Part II formation layouts are reused on some neighboring levels:
- Levels **1–3**: full 55-alien formation.
- Level **4**: first missing-alien pattern (52 aliens).
- Level **6**: 51 aliens, including small variants.
- Level **8**: another distinct pattern (47 aliens).
- Level **10**: further changed formation.

This is a **testing convenience**, not an arcade operator DIP option. Screen presentation and start sequence remain under development.

This release also contains the previous invasion game-over and unique F12 screenshot improvements.
