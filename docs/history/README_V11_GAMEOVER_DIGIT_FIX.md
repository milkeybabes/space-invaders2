# v11 — Two-player GAME OVER player number fix

The v10 game-over renderer substituted 0x1B for player 1 and 0x1C for player 2 at character 18 of the ROM message. In the Space Invaders Part II five-column ROM font, numeric 0 starts at code 0x1C, so numeric 1 is 0x1D and 2 is 0x1E. The old substitution drew no digit or the wrong glyph.

Updated: `game_over.py`, in `GameOver.step_frame()` when `phase == 'multi_message'`.

Added: `part2_v11_gameover_digit_test.py`, checking that each player number's actual ROM glyph bytes are written at the message's number position.

Passed: v11 digit test, v10 game-over handoff test, v9 player palette/death test, two-player state test.

The change affects only the displayed player number; timing, firing, handoff, colours and all other gameplay routines are unchanged.

Windows CMD replay:

    python part2_play.py --playback-inp part2_2player.inp --record part2_v11_replay.avi
