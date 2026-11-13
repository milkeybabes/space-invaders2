# Space Invaders Part II v12 — Player handoff timer correction

The v7 correction restored the original $0080 player-object startup timer for the very first game start. That timer was erroneously left in place when switching to a second player's rack, so the ship did not appear promptly when the alien rack reached its normal playing position.

The existing native `two_players.py` ROM $02ED-$0335 handoff translation already documents `$0318`: it clears the player-object timer's low byte (`$2011`). The higher-level playable `Part2TwoPlayer` controller had omitted that write.

v12 applies `$2011 = 0` in `part2_two_player.py` when a **subsequent player handoff** exits the prompt and begins its rack arrival. It does not alter the initial Player 1 startup, the row-drawing cadence, score restoration, or the alien firing algorithm. The high timer byte is already zero in the initial object mirror.

Tests: `python part2_v12_handoff_timer_test.py`, `python part2_two_player_transition_test.py`, `python part2_v7_player_timer_test.py`, `python part2_v6_startup_timing_test.py`, `python part2_v9_two_player_palette_and_death_test.py`, `python part2_v10_gameover_handoff_test.py`, `python part2_v11_gameover_digit_test.py` all pass. Complete 7,300-frame INP replay completes. **Pixel-perfect MAME parity is not yet confirmed**, and end-game handoff frames still require comparison.

Record from Command Prompt:

    python part2_play.py --playback-inp part2_2player.inp --record part2_v12_replay.avi

Check frame ~2355 for the early Player 2 ship, and the next Player 1 handoff. Initial Player 1 start near frame 810 should remain unchanged.
