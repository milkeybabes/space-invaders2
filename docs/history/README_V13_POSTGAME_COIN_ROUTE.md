# v13 — GAME OVER exits through the ROM credit-information phase

MAME at recorded frame 7232 shows `INSERT COIN`, while v12 had already
restarted the large title. The disassembly settles the transition:

- `$14F2` GameOverMsg prints `GAME OVER`, waits, then clears the field.
- `$150F` jumps directly to `$0D32`, the credit-information routine.
- `$0D32` waits one second, clears the field, prints `INSERT COIN` and
  the operator information, waits two seconds, then `$0D65` branches to
  `$169D` SplashRestart, finally reaching the title at `$0CD8`.

v13 uses this **same screen order** in the windowed and headless loop:
`game -> insert_coin -> title`. It does not reset the attract system to
cold boot after a game. The original ROM-derived 64- and 128-tick waits
are reused without a fabricated target frame number.

The full existing INP run of 7300 frames completes, and the v13 state log
shows the `insert_coin` phase at frame 6850 and title at frame 7044.
**MAME still shows the coin screen at 7232**, so the exact late-game timing
remains different. This is a correctness fix to the branch, not full
frame synchronization. Additional comparison of the last GAME OVER exit
will locate the remaining time discrepancy.

Changed Python: `part2_attract.py`, `part2_play.py`, `part2_headless.py`.
Added regression test: `part2_v13_postgame_attract_test.py`.

To capture:

    python part2_play.py --playback-inp part2_2player.inp --record part2_v13_replay.avi

Headless state trace:

    python part2_play.py --headless --playback-inp part2_2player.inp --state-trace diagnostics/v13_state.csv
