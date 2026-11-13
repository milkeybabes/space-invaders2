# Part II v2 — two-player handoff presentation

This full build integrates the original ROM-controlled player-change presentation into the working two-player mode:

- `$0336–$0379`: after a ship is lost, save the active player's game state and switch to the other living player.
- `$0CA2`: wait 128 end-screen interrupts before the next-player prompt.
- `$0A73–$0AB4`: draw the original ROM `PLAY PLAYER<1>` or `PLAY PLAYER<2>` message and flash that player's BCD score for 176 end-screen interrupts.
- `$0907–$0936`: clear the central playfield, restore the new player's existing shields, and run the rack-arrival animation. The gaps from destroyed aliens are retained; the rack is NOT re-created.

The two-player harness continues to use independent Python Rack instances, so the handoff is not yet an instruction-cycle-perfect recreation of the 8080 RAM-mirror copying procedure. Interrupt delays are represented as video frames; the exact display phase remains subject to final MAME comparison.

## Testing

Use `PLAY_PART2_2PLAYERS.cmd`, press `5` twice followed by `2`. After losing the first life, observe the pause, `PLAY PLAYER 2` and score flashing, and the alien rack descending into place. The reverse happens on Player 2's death. Your previous score, shot-away aliens, shield damage and remaining lives are preserved for both players. If one player runs out of ships, the other keeps playing.

Regression: `python part2_two_player_transition_test.py`. All 33 `part2_*test.py` scripts passed in this build.
