# Space Invaders Part II — verified MAME/Python title VRAM checkpoints

2026-11-10. Captured original MAME video memory from user-supplied `Mame.zip`, with six 7168-byte snapshots. Compared to Python title output from the current unchanged project.

| Event | MAME frame | Python frame | Different bytes | CRC32 both |
|---|---:|---:|---:|---|
| INVADERS dot fill complete | 273 | 270 | 0 | 5A0CA546 |
| First INVADERS carved pixels | 337 | 334 | 0 | 6C286695 |
| INVADERS carving complete | 364 | 360 | 0 | EDE5CE98 |

The exact contents of all 7168 bytes of RAM from $2400 through $3FFF agree for all three event-aligned checkpoints. This is stronger evidence than matching pixel totals. At a fixed common frame number, MAME/Python need not match: at frame 334 they differ by 18 bytes / 54 bits; at frame 337 they differ by 54 bytes / 162 bits. Thus animation timing still differs even though the event-aligned render is identical.

Both are identical again at frame 364, as the Python carve stage has already finished. Note that matching final VRAM does NOT prove all intermediate write timing, CPU cycles, or interruption points agree.

MAME 270 vs Python 270: 576 bytes differ; 3456 different bits.
MAME 337 vs Python 337: 54 bytes differ; 162 different bits.
MAME 360 vs Python 360: 63 bytes differ; 207 different bits.

Conclusion: pixel/drawing content at the named milestones is verified. Remaining work should address foreground/IRQ cycle phase and per-frame pacing, without arbitrary fixed delays or altering the bitmap/data translation. All 18 standalone regression test scripts passed in this build. No title/gameplay timing parameters changed.

Run `python compare_part2_vram_snapshots.py diagnostics/mame diagnostics` to repeat the three event-aligned checkpoint checks.
