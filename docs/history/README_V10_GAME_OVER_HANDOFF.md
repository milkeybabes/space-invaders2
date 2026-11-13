# Space Invaders Part II v10 — two-player final-life message

Based on v9, preserving the Player 2 colour PROM, deferred reserve removal,
ROM player-start timer, and the alien firing logic.

## Corrected

The previous two-player controller switched immediately when a player lost
his final ship. This prevented the existing ROM-derived $166D/$169F sequence
from drawing `GAME OVER PLAYER<1>` / `GAME OVER PLAYER<2>` one character at a
time and holding it before the next player's turn. Now it continues stepping
the ending player's game-over state until `switch_ready`, and only then begins
the existing player handoff. Ordinary non-final deaths still switch normally.

The independent per-player Rack instances now synchronize the original ROM's
$20E7 (P1 alive) and $20E8 (P2 alive) bytes when a player finishes. This lets
the second player's final game-over flow correctly progress to the final
message and title after both players are finished.

The v10 game-over-handoff regression exercises both paths and verifies that
ROM message bytes are written to VRAM before switching players.

## Verification

- 7,300-frame INP headless replay completed.
- Six focused tests passed, including game-over text/hold and two-player transition.
- Timing after final-life events necessarily changes compared with v9 and
  remains pending comparison to MAME at 5636 and 6381.
- This build does not claim shot timing parity at frame 4071. No projectile
  selection/timer code was altered.

## Windows Command Prompt

    python part2_play.py --playback-inp part2_2player.inp --record part2_v10_replay.avi

For a faster, window-free state trace:

    python part2_play.py --headless --playback-inp part2_2player.inp --state-trace v10_state.csv
