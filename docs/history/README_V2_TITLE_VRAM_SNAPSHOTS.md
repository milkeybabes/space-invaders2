# Part II exact title-frame checkpoint test

The per-frame comparison supplied by the user verifies that the title fill ends
at MAME frame 273 vs Python 270, first carving occurs at MAME 337 vs Python
334, and final carving at MAME 364 vs Python 360. The fill and final carve
pixel counts match (7398 and 5958), but that does NOT prove the VRAM bytes
match. The apparent pacing discrepancy persists after aligning the beginning.

These three scripts extract and compare exact video-RAM contents without
changing title logic, animation, or scheduler constants.

From the MAME directory (cold start, no reset):

    mame.exe invadpt2 -video none -autoboot_script trace_part2_title_vram_mame.lua

Wait until MAME frame 365 or later, then exit. Copy the generated
`part2_mame_vram_*.bin` files to your Part II project directory.

From the project directory (Windows cmd.exe):

    python trace_part2_title_vram_python.py
    python compare_part2_vram_snapshots.py . diagnostics

The comparison reports mismatched bytes, the first changed RAM address,
bit totals and CRC32 for each corresponding event. A match at the final
checkpoint would validate final bytes, not intermediate frame cadence.

MAME snapshots also include frames 270, 334 and 360 so we can later compare
unaligned exact frame numbers if needed. Sampling uses `emu.register_frame_done`,
matching the original MAME title logger.
