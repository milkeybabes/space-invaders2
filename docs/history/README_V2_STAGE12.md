# Space Invaders Part II — Stage 12: ROM attract screens and AVI timing reference

This full replacement build supersedes the title-carving fix. It keeps the corrected title graphics and authentic colour PROM lookup, then replaces the **placeholder** score-advance and INSERT COIN pages with actual 1979 ROM data.

- **$163F DrawAdvTable**: the 21-byte heading at $1ACB, all six sprite descriptors from $1DAB and the five 11-character descriptions at $1DC4. ROM artwork copied with the original 32-byte framebuffer stride.
- **$0D32 coin screen**: INSERT COIN, the 1-or-2-player instruction and both player/coin messages; all use the Part II five-byte ROM font.
- **MAME video reference**: your 8,933-frame / 59.542 fps recording was sampled to identify *approximate* phase boundaries. The running preview now uses roughly title 15 s, score table 9 s, demo 15 s, coin 8 s, then repeats. The title drawing ends earlier and stays visible. These are **not** yet interrupt/foreground cycle-perfect durations. The demo itself still needs genuine 1979 foreground/death sequencing.
- Legacy diagnostics preserve their shorter phase schedule, so all old tests continue to run without changing their assertions. `part2_play.py` uses the longer AVI-derived schedule by default.

## Windows Command Prompt

    python part2_stage12_test.py
    python part2_play.py

Optional 4× native pixel window:

    python part2_play.py --scale 4

The original 1978 source is unchanged. The ZIP is flat; overwrite files in your existing single v2 working folder. No new enclosing Stage folder is needed.

## Still to do

The TAITO/high-score name flashing, copyright and credit footer, full attract death/game-state transitions and precise title character draw timing. Keep comparing Python and MAME at the **same attract-relative frame index**.
