# Space Invaders Part II — Python v2.0 Stage 06

**Install:** Extract this complete, flat ZIP over the existing `SpaceInvaders_PartII_Python_v2_Stage01` working folder. There is no new parent directory. Original 1978 v1 files are not altered.

## Implementation

- Added `part2_saucer.py`: an opt-in source-level translation of Part II's shared `GameObj4` saucer branch at `$06D9–$083F`, including the original $2083–$208C ROM-mirror descriptor.
- Replaced the v1 saucer in the Part II diagnostic (not in the playable frontend): the original object dispatcher invokes the 1979 handler at `$06D9`.
- The saucer can appear, move, exit, and stay stationary when `dropActive` ($20A1) is set while Stage 05 manages the falling alien at the mid-screen/VBlank interrupt points.
- The second saucer increments the source `$20BC` counter, selects the special `$187E` sprite, alternates 4 updates visible / 4 updates erased, and awards the source-fixed 500 points on a hit.
- Hit events are coupled to Stage 04's `$2085` collision flag, with the original `$20` count-down milestones `$1F` explosion, `$18` score and `$00` reset. The first-saucer-hit and both-hit flags `$20BA/$20BB` are retained.
- Part II ROM imagery is used directly; no v1 saucer tables are patched into its ROM.

## Run (Windows Command Prompt)

```bat
python part2_stage06_test.py
python part2_stage05_test.py
python part2_stage04_test.py
python part2_stage03_test.py
python part2_stage02_test.py
python part2_diagnostic.py
```

The new test includes direct saucer lifecycle checks, Stage 04 collision-to-saucer handoff, formation slot selection, VBlank drop movement and an actual two-interrupt dispatch through the original Part II object pointer. All existing regression tests pass locally.

## Scope / accuracy

**Stage 06 remains a development diagnostic, not yet full playable Part II.** The diagnostic can enable the new path using `Rack(part2=True).enable_part2_saucer_live_diagnostic()`; this method is not called by the standard `PLAY*.cmd` launchers. Original Part II enemy-shot variants, full startup state, score-message rendering and cycle-accurate main-loop interactions still require separate translation and comparison with MAME. The fallback to squiggly enemy fire is deliberately marked `SQUIGGLY_NOT_PORTED` in this opt-in fixture rather than silently running the 1978 logic.

The source itself is generated/reconstructed and has been assembled against all five binary ROMs (10,240/10,240 bytes identical), but code annotations and gameplay timing still need runtime validation.
