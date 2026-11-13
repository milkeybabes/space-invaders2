# Part II v2 — initial Player 1 announcement

The first playable 2P build already displayed the ROM `PLAY PLAYER 1` / `PLAY PLAYER 2` messages on handoff, but it omitted the **initial** `PLAY PLAYER 1` message before the first rack arrived. This release routes initial two-player start through the same ROM `$0A73–$0AB4` prompt and score flash controller, followed by the preserved `$09CA` rack arrival. It does not create or erase a fresh formation during player handoff.

## Repeatable no-input MAME comparison

In MAME, hard-reset first (if necessary), insert two credits, start with the 2-player button, then leave all controls untouched until both players are exhausted. Capture the MAME recording and, if possible, the input (`.inp`) recording so the credit/start frame can be identified. In Python, press `5`, `5`, `2` at the corresponding moment and then leave the controls untouched. Input timing, initial RNG/state, animation delays, player transitions, scoring, and game over are not yet claimed frame-exact. The current build specifically fixes the absent **initial** player announcement.

For AVI in Python: `python part2_play.py --record part2_2p_idle.avi` (FFmpeg required, already a project dependency). Use `PLAY_PART2_2PLAYERS.cmd` for interactive viewing.

## Regression

`python part2_two_player_initial_prompt_test.py` checks the initial prompt, the score/rack transition, and Player 1's first rack arrival. The older two-player tests have been updated to wait for the prompt to complete instead of assuming the first rack is already active at a hardcoded frame. All 34 `part2_*test.py` scripts pass.
