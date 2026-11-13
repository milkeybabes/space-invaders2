# Part II v9 — 2-player PROM, death red, deferred reserve removal

This is a complete source build based on v8. No CPU emulation.

Changes:
- `part2_play.py`, `part2_headless.py`: pass the active visible player's number to `Part2Colour.apply` so 2P uses colour PROM #2; while the previous screen is visible during the `$0CA2` wait, keep that player's PROM selected.
- `part2_two_player.py`: `visible_player`; defer a player's reserve ship removal until their *next* turn's prompt, preserving the remaining ship icons during the explosion and the other player's turn.
- `lives.py`: optional two-player deferral of RemoveShip; normal single-player respawn is unchanged.
- `part2_first_play.py`: hold red-screen presentation until the translated player explosion has actually completed, instead of ending it solely on the sound driver's provisional 38-frame latch.
- Tests updated for the observed two-player reserve behaviour, plus `part2_v9_two_player_palette_and_death_test.py`.

Verified: 7,300-frame headless INP replay completes; focused tests `part2_two_player_test.py`, `part2_two_player_transition_test.py`, `part2_screen_red_test.py`, `part2_v9_two_player_palette_and_death_test.py` pass. A complete wider suite was attempted but did not finish within the run limit; no claim of all-tests-passing.

Recorded-vs-MAME differences still open:
- 2P handoff prompt/alien arrival starts several frames earlier around MAME 2254. Do not add an ungrounded hard delay.
- The exact port-3 red latch timing and timing of reserve removal at the moment of turn resumption still need MAME frame verification.
- Later deaths/turn switches and post-game return-to-attract still diverge; no full frame/CRC parity claim.

For Windows cmd.exe:
    python part2_play.py --playback-inp part2_2player.inp --record part2_v9_replay.avi

For a window-free state trace:
    python part2_play.py --headless --playback-inp part2_2player.inp --state-trace diagnostics\\v9_state.csv
