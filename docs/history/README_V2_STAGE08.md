# Space Invaders Part II — Stage 08: first runnable attract preview

**Run:** `python part2_play.py` from the project directory. This is the *first autonomous v2 preview*, **not yet the ROM-accurate attract mode** or a complete playable sequel.

## What is live

- Real Part II graphics and formation data are loaded from pv01–pv05.
- The previously translated v2 player, player-shot, alien movement, crab splitting, enemy shots and saucer/drop handlers run in one autonomous window.
- Two interrupt phases are serviced by the established diagnostic scheduler.
- Demo steering uses the Part II ROM's command bytes at `$1ABF–$1AC9`; the command advances on a newly requested shot in this provisional simulation.
- `DemoAliens` alternates round-index 0 and round-index 3 formations in successive demo cycles.
- Title → score-table → demo → insert-coin → title repeats automatically.

## What is deliberately not claimed

- The first two presentation screens and insert-coin screen are **placeholder lettering**, not the ROM's dot-matrix title/carving animation (`$40DC`) or native font/score table (`$163F`).
- Durations of presentation phases are **placeholder intervals** and have not been measured against the supplied MAME AVI.
- The existing diagnostic scheduler services the foreground loop once per frame; the real 8080 foreground loop is asynchronous to the two interrupts. Demo shot timing, death, and transitions cannot yet be called MAME-synchronised.
- v1's score-display and initial player-head-up display are still used during the demo; Part II five-digit scoring needs a separate source translation.
- Coin/start controls, high-score name entry, operator modes and game-over are not yet integrated into this executable.
- The auto-restart after the fixed demo interval is temporary, pending the authentic death/handoff path.

## Windows CMD

```bat
python part2_play.py
python part2_play.py --scale 2
python part2_stage08_test.py
python part2_play.py --headless --frames 2700
```

Keys: **Esc** quits, **F5** pauses, **F3** restarts, **F12** saves a screenshot, **+/-** changes nearest-neighbour integer scaling.

Keep the existing v1 PLAY.cmd files unchanged; these still start the original 1978 version. `PLAY_PART2.cmd` is the v2 preview launcher.

## Development order after Stage 08

First translate the native Part II title and score-table rendering; then wire in the actual `$0CC1/$0CD8` attract state machine and its demo command update cadence, validate screen-transition frames against the user's MAME recording, and finish death/coin handoff. Preserve old test fixtures. This stage intentionally prioritises something observable rather than claiming parity prematurely.

## Stage 08 hotfix — enemy shots stationary

The provisional attract preview enabled Part II enemy objects without
copying the startup ROM mirror's alien shot delta byte at `$1B7E` into
RAM `$207E`. That left the signed movement increment at zero: bullets
appeared and animated but did not descend. The Part II fixture now
initializes `$207E` from the original ROM byte (`$FC`, i.e. -4).
The Stage 08 regression test verifies actual per-shot Y-coordinate changes.
This fixes movement only; the overall demo schedule is still provisional.
