# Part II v5 — playable alien-fire startup gate

The Stage-7 diagnostic helper deliberately sets `$2069=1` to exercise missile logic without waiting for normal gameplay. `Part2FirstPlay.start_round()` previously inherited that bypass, enabling alien missiles too early.

Playable startup now overrides the diagnostic fixture after setup:

- `$2069 = 0`: alien fire disabled until the player object enables it
- `$206A = $30`: initial delay count used in the existing ROM-derived player object handler (`$0388–$039B`)

The player object countdown runs only when the original object dispatcher services GameObj0. The existing RackArrive controller suspends game tasks, so countdown is not advanced during rack arrival. This is **not** a new timer or a MAME-frame-specific offset.

This does not yet correct the partially instantaneous first-player setup, prompt, shield drawing, or alien rack drawing. Those remain separate synchronization tasks. The shot-column selection is table/position driven, rather than a new random seed introduced by this patch. More MAME comparison is necessary to establish the exact first shot frame and type.

Run:

`python part2_play.py --playback-inp part2_2player.inp`

Or for deterministic verification:

`python part2_play.py --headless --playback-inp part2_2player.inp --state-trace diagnostics\part2_v5_state.csv`

Regression: `python -m unittest part2_initial_alien_fire_delay_test -v`
