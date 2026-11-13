# v18 — Two-player lives during the player prompt

At MAME frame 3734, Player 1 resumes with **2 displayed lives / 1 reserve icon**, whereas v17 still displayed the outgoing frame's 3 / 2 reserves throughout `PLAY PLAYER<1>`.

Root cause: v17 had already corrected the bank's reserve count and its final playfield HUD, but restored the incoming HUD **only** in `_finish_arrival_clear()`, after the full prompt hold. At the earlier `_finish_player_prompt()` screen, RAM video contents copied from the previous player's screen still included its stale lives display.

Correction: after the `$0373` progressive clear finishes and the `$0A73` `PLAY PLAYER<n>` text and scores are drawn, refresh the incoming bank's ROM digit and reserve icons via `draw_lives_number()` and `draw_reserve_ships()`. Keep the v17 refresh after the second `$0907` clear as it is necessary there too. No change to reserve count/death accounting, timer values, projectile logic, or first Player 1 start.

Verification:

- `python part2_v18_prompt_lives_test.py` — confirms actual VRAM glyph bytes during `prompt` and after the arrival clear.
- `python part2_v17_lives_vram_test.py`, `python part2_v15_handoff_vram_test.py`, `python part2_v12_handoff_timer_test.py`, `python part2_v16_reserve_handoff_test.py`, `python part2_v9_two_player_palette_and_death_test.py`, `python part2_v10_gameover_handoff_test.py` — pass.
- `python part2_play.py --headless --playback-inp part2_2player.inp` — all 7300 frames processed.

Record:

`python part2_play.py --playback-inp part2_2player.inp --record part2_v18_replay.avi`

Target comparison: frame 3734, then frame 3950. Exact MAME pixel/frame parity remains to be checked on the user's machine.
