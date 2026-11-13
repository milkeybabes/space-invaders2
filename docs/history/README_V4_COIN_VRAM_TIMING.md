# Part II v4: progressive coin VRAM clear (MAME INP timing pass)

The 297 coin edge in `part2_2player.inp` originally constructed a fresh, fully populated credit framebuffer in one Python call. MAME visibly clears the previous SPACE INVADERS title over successive frames and finishes its credit screen at approximately frame 310.

`Part2CreditWipe` in `part2_attract_screens.py` now retains the old 0x2400..0x3FFF VRAM, uses the existing 37-8080-cycle ClearScreen byte-loop cost, and budgets subsequent output bytes instead of immediately displaying the final credit scene. The source clock is 1,996,800 Hz with ~59.542 video frames/s. Foreground time is currently estimated as 80% of that per frame, accounting approximately for other work; output writes use a provisional 125-cycle/nonzero-byte cost. This is *not* a claim of ROM-exact foreground instruction ordering or measured cycle accuracy.

Checkpoint result for the supplied recording:

- Frame 297: first coin edge; old VRAM not immediately erased.
- Around frame 308: complete credit screen; target MAME approximately 310 (2 frames early).
- Frame 333: second coin edge; two-credit prompt remains functional.
- Frame 393: two-player start edge unchanged.
- Full 7,300-frame headless replay completes; gameplay timing and first-rack presentation are still not frame-matched.

The pygame UI and window-free replay share this code. Tests: `python -m unittest part2_credit_wipe_test part2_headless_replay_test -v`.

Next tasks, not yet solved: reproduce original start-button screen clear and subsequent incremental VRAM writes for `PLAY PLAYER<1>`, HUD/shields, and alien arrival. Compare especially frames 569 and 593. Continue to inspect death/turn timing only after startup visual transitions are close.
