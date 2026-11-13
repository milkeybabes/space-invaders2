# Space Invaders Part II v2 — playable wave completion

User-reported failures: saucer was hit without a visible award; removing all the
aliens on the first level halted play.

## Confirmed root cause and fix: first wave freezes

The first playable controller never enabled `waves_enabled`, so its main-loop
`CountAliens -> wave transition` handler was never called. The existing
`WaveTransitions` handler was 1978-specific and would have reloaded a 1978
object mirror and full 55-alien array. The Part II playable now enables the
wave handler; its new Part II branch advances the ROM round counter, copies
Part II object descriptors, installs the original per-round alien formation,
restores the original Part II cannon sprite, retains the player's score and
reserve lives, redraws the shields and HUD, and resumes `$09CA` rack arrival.

This is an integration milestone, not a claim of cycle-perfect inter-wave
timing or complete late-game intermission/bonus handling.

## Saucer score: targeted verification, NOT yet confirmed resolved in live play

The collision -> hit-state -> animation -> BCD adjustment -> visible ROM
points-label path DOES pass an integrated scheduled test (`part2_wave_and_saucer_integration_test.py`).
The actual flying saucer traversal, exact hit height and player's observed
missing award still need a live reproduction to isolate why it failed.
The playable terminal now prints three succinct events, when reached:

* `PART2 SAUCER: shot collided`
* `PART2 SAUCER: SAUCER_SCORE <points>`
* `PART2 SAUCER: SAUCER_SCORE_LABEL <points>`

If the player shoots the saucer and no points appear, these messages identify
whether the omission occurred before hit recognition, award or label drawing.
This logging is observation only; no frame delays or synthetic awards were added.

## Run and regression

`PLAY_PART2.cmd` or `python part2_play.py`

`python part2_wave_and_saucer_integration_test.py`

All 21 `part2_*test.py` scripts passing on this build.
