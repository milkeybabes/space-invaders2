# Part II v2 — actual MAME title VRAM comparison (2026-11-10)

The user supplied `part2_title_mame_frames.csv`, captured at cold boot with
`trace_part2_title_mame.lua`, frames 250–400. The Python trace was regenerated
from the unchanged build, not adjusted to make MAME match.

| Visible event | MAME frame | Python frame |
|---|---:|---:|
| Last INVADERS dot pixels added | 273 | 270 |
| First INVADERS carve pixels removed | 337 | 334 |
| Last INVADERS carve pixels removed | 364 | 360 |
| Total lit VRAM pixels after carving | 5958 | 5958 |

Both images reach **7398 lit VRAM pixels before carving** and **5958 after**.
The MAME dot fill happens at 271 (1710 bits), 272 (1710), 273 (36),
whereas Python fills at 269 (1782 bits), 270 (1674). The MAME carve removes
1440 bits over frames 337–364. Python removes the same 1440 bits over frames
334–360, but has different per-frame grouping (and occasional 45/63-bit
removals versus MAME's 45/54).

**Interpretation:** there is a three-frame relative onset offset but also a
small difference in intra-operation pacing. The `Part2Title` foreground
`FILL_BYTE_CYCLES`, `CARVE_BYTE_CYCLES`, and `SKIP_GROUP_CYCLES` remain estimates;
its `DelayBC` count is modeled from source. The fixed `33535`-cycle per-frame
budget does not represent actual scanline IRQ opportunities / foreground
consumption. These are plausible causes, not proven ones. The current evidence
is *not* sufficient to insert a fixed three- or four-frame delay.

The trace only carries bit counts and the **first** changed address per frame;
matching totals do not establish pixel-for-pixel equality. For tighter
validation, compare full VRAM snapshots at 273, 337, 364 and then separately
phase-align by event. The MAME script and Python comparison are available in
this ZIP. No code governing gameplay, graphics, IRQ timing, or screens was
changed in this diagnostic release.

To compare again:

```cmd
python compare_part2_title_traces.py part2_title_mame_frames.csv
```

Outputs `diagnostics\part2_title_python_frames.csv` and
`diagnostics\part2_title_comparison.csv`.
