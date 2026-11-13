# Space Invaders Part II — missile launch and rack-reference phase audit

This is an **investigation build**, not a gameplay fix. It is based on v20 and preserves the existing executable behaviour. Do not assume the frame mismatch has been corrected.

Evidence from the recorded MAME and v20 Python player-1 RAM snapshots:

| Event | MAME | Python v20 |
|---|---:|---:|
| Rack reference `$200A` changes `30 -> 2E` | frame 1835 | frame 1832 |
| Rolling missile status `$2035` becomes `80` | frame 1835 | frame 1837 |
| Rolling missile launch coordinate `$203E` | `37` | `35` |
| Other missile coordinate `$203D` | `66` | `66` |
| Player hit `$2015` changes from `FF` | frame 1881 | frame 1887 |
| Next rack reference shift to `2C` | not before hit | frame 1887 |

**Important correction to earlier analysis:** `$203B/$203C` hold the missile sprite image pointer (`F0 1C`), NOT the launch position. Position bytes in the rolling-shot object are `$203D/$203E`. Their scratch equivalents are `$207B/$207C`.

MAME's frame 1835 has both the rack-reference update and the rolling-shot activation. The source-defined mid-screen interrupt dispatches non-player objects **before** `CursorNextAlien`, which explains how the shot can use the previous reference (`30`) while end-of-frame RAM already shows the new reference (`2E`).

In Python, the rack shifts at 1832 but the rolling missile launches at 1837. Calling the same launch formula at that later time naturally uses `2E` and gives a launch coordinate two units different. **Do not add a `+2` pixel offset to missile creation.** The fault is the relative phase of object service and rack update.

Both systems use a rolling counter and the original relative coordinate calculation. The initial cursor and missile service are already phase-shifted earlier in the game; isolating their first divergence (at the initial rack arrival / gameplay enabling boundary) is the next source-level task. Also MAME log `$2072=00` and Python end-frame log `$2072=80`; avoid interpreting end-frame samples as identical sub-frame sample points.

To reproduce the audit with existing CSVs:

```
python diagnose_part2_launch_phase.py part2_mame_inp_ram.csv v20_compare_p1.csv --start 1800 --end 1900
```

The comparison script is diagnostic only; no random missile changes, rack-position offsets, or frame-specific patches are introduced.
