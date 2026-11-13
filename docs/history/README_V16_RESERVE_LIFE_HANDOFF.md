# v16 — Two-player reserve-life decrement at ROM player change

MAME comparison around frame 3950 showed the outgoing/resumed player lives HUD display 2 while Python remained at 3.

Cause: `lives.py` returned `PLAYER_CHANGE_PENDING` from the ordinary death branch before setting `pending_turn_reserve`. Consequently, `Part2TwoPlayer._show_player_prompt()` (which already consumes the flag upon that player's next turn) had nothing to do and left the reserve count, reserve sprites, and numerical display untouched.

Fix: set `pending_turn_reserve=True` before returning from the two-player branch, only when `life_decrement` is active. `remove_ship()` remains deferred to the original player-bank reactivation, so the previous player's displayed lives remain intact until their next turn. No gameplay or alien-fire timing constants were changed.

Regression: `python part2_v16_reserve_handoff_test.py` forces one genuine death on each side and verifies deferred flags, preserved outgoing HUD, and Player 1 reserve decrement on return. Existing v15 VRAM-wipe and v12 startup-timer tests pass. A full 7,300-frame MAME INP playback also completed. The precise frame-by-frame visual match at 3950 remains to be checked in a new AVI.
