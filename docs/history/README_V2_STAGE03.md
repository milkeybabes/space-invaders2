# Space Invaders Part II — Python v2.0, Stage 03

This is a **full replacement** for the existing working folder, not a new Stage03 directory. Extract the ZIP contents **directly over** your current `SpaceInvaders_PartII_Python_v2_Stage01` working folder (Windows Explorer: replace files). Your previous 1978 v1 directory is not changed.

## Source-led implementations

- `$028E` Part II `RunGameObjs` handler addresses restored for the player (`$02D4`) and player shot (`$0400`). The objects are read from the Part II `$1B10` initialization ROM mirror. The old 1978 `$03BB` shot handler no longer accidentally registers for a Part II rack.
- `$12D8/$1307` hit and crab-splitting code from Stage 02 is now connected to the renderer using **32 rows** of authentic sprite `$1AE0`; previously, the collision routine left a blank image for this case.
- `$128A/$1330` explosion timeout translates the Part II **18-row** cleanup. A normal explosion clears two framebuffer bytes over 18 rows; a split crab draws two consecutive small-alien sprites (`AlienSprB`, `$1C31`) using the original shifted-sprite overwrite operation, 18 rows then 16 rows.
- The shot reset now copies the seven-byte object descriptor from Part II's actual ROM mirror `$1B25..$1B2B` rather than using 1978 hard-coded constants.

## Verification (Windows CMD)

```
py part2_stage03_test.py
py part2_stage02_test.py
py part2_diagnostic.py
py verify_asm8080.py reference_invadpt2.asm roms
```

The Stage 03 test includes an actual Part II object dispatch, sprite draw/erase framebuffer comparisons and 20 frame pairs of mid-screen / VBlank interrupts.

## Not yet implemented / validated

This **is not a complete playable Part II conversion**. The front-end's standard `PLAY*.cmd` launchers still use the original 1978 gameplay, and the experimental Part II rack has a diagnostic, once-per-frame main-loop service rather than original continuous foreground timing. Part II's shot-to-alien/saucer/drop classification `$1249`, new alien-shot handlers `$04C3/$0503/$06D9`, saucer/drop, wave transitions, title, bonus and name entry are outstanding. No frame-perfect MAME validation is claimed. Stage 03 explicitly tests and documents a subset, not a full v2 replacement game.
