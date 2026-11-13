# Part II — two-player playable milestone

Start with two credits (press `5` twice) then press `2`. One credit and `1` retains single-player mode. Both players use the same arrow/Space controls in alternating turns.

This integrates a first functional two-player path into the Part II playable frontend. Each player has an independent `Rack` with Part II's original `$21xx` (P1) or `$22xx` (P2) alien status bank, distinct wave/rack progress, own reserve ships, sprite state and shields. Packed-BCD scores are synchronized to the original P1 `$20F8` / P2 `$20FC` scoreboard slots and the high score `$20F4`. Player turns switch after the existing death-animation sequence completes. Game ends after both players are out. Debug unlimited lives and `--start-level N` remain available.

## Limits to test against MAME

This is a **playable integration**, not yet a frame-accurate 8080 `SwitchPlayer` translation: it retains separate Python Rack instances rather than copying one active rack to the original `$21xx/$22xx` buffers on every turn. The ROM `PLAY PLAYER<n>` transition prompt, score flashing, and per-turn ISR delays are not integrated yet. Also two-player game-over and credits/attract presentation need full visual comparison. The goal is to validate complete turn-based gameplay first, then replace the provisional transition with the source-exact implementation.

## Tests

Run `python part2_two_player_test.py` or the existing Part II regression scripts. First automated full-death sequence was run through six losses and confirmed game finish only after both players lost three ships.
