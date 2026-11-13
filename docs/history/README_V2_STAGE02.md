# Space Invaders Part II — Stage 02: alien hit rules

Incremental source-based additions to the Stage 01 archive; v1 defaults untouched.

## Implemented and tested

- `$12D8` AlienHit: status-specific points 1/2/3/3 packed BCD (shown as 10/20/30/30 by Part II's extra display zero); last alien type `$20DB` for SOS; correct explosion descriptor `$2062..66`.
- `$1307` CrabHit: at stored zero-based round count >=3 a crab becomes two small aliens (statuses 7/7); intentionally overwrites adjacent slot without checking, following ROM.
- `$125D` CodeBug1 boundary: column 12 is no longer treated as an alien, unlike the v1 glitch.
- Enable-combat diagnostic now keeps Part II's `$1B10` object RAM mirror and `$1C90` sprite art intact instead of accidentally overlaying v1 constants.

## Run

From the extracted directory in Windows Command Prompt:

```
py part2_diagnostic.py
py part2_stage02_test.py
py verify_asm8080.py reference_invadpt2.asm roms
```

## Still incomplete

This is a **logic and RAM-state milestone**, not a playable Part II build. The existing dispatch and `Combat.player_shot_hit` are still based in part on 1978 flow. In particular the split-explosion 32-row sprite and its end-of-explosion replacement rendering, `$1249` saucer/drop classification, Part II object handler addresses, and true two-IRQ gameplay integration need subsequent work. Do not interpret a 100-frame image as proof of end-to-end correctness. The normal v1 launchers still run v1.
