# Space Invaders Part II — Stage 07: enemy missiles

Stage 07 adds an opt-in `Part2EnemyShots` source translation for the 1979
rolling, plunger and squiggly handlers. It reuses the unchanged *shared*
1978 motion/collision core where appropriate, but loads the Part II ROM data
and implements the 1979 control-flow differences:

- Rolling shot at `$04C3`, including the initial skip and timer reload.
- Plunger shot at `$0503`, disabled from round 4 onward (`$206E`).
- `shotsHalted` at `$20E4` suppresses missile processing during transitions.
- Squiggly shot at `$0564` is selected by the shared `$06D9` saucer task.
- Part II shot sprites, column tables (`$1A80`), source descriptors and reset
  mirror bytes are read from **pv01–pv04**, not the 1978 constants.

To test from your existing CMD working directory:

```bat
python part2_stage07_test.py
python part2_stage06_test.py
python part2_stage05_test.py
python part2_stage04_test.py
python part2_stage03_test.py
python part2_stage02_test.py
python part2_diagnostic.py
```

The new integrated mode can be started programmatically using
`Rack(part2=True).enable_part2_enemy_shots_diagnostic()`. No existing PLAY
launcher changes: full Part II foreground startup, end-of-rack flow, shields,
life/death lifecycle and MAME frame parity are not yet established.

Unmodified original 1978 files remain available and independent.
