# Part II v19: matched INP RAM logging (no gameplay changes)

We already recorded a deterministic 7,300-frame MAME INP. This build adds
per-frame RAM evidence, **not another gameplay adjustment**.

## 1. MAME 0.282 (Windows Command Prompt)

Put `trace_part2_inp_ram_mame.lua` and the original `part2_2player.inp` next to
`mame.exe`, or use full absolute paths. Start with the same game ROM/DIP settings
as the source recording and **do not press F3/reset after playback begins**:

```cmd
mame.exe invadpt2 -playback part2_2player.inp -video none -sound none -nothrottle -autoboot_script trace_part2_inp_ram_mame.lua -seconds_to_run 124
```

`part2_mame_inp_ram.csv` will appear in the MAME working directory, containing
one row per frame with the actual address range `$2000-$22FF` encoded as hex.
This includes object state, missile pointers/timers, common state and both
player banks. The logger is read-only and does not drive inputs: MAME's own
`-playback` supplies them. If the recording stops earlier, that is normal.
The 124-second cutoff is only a guard (7300 / ~59.542 = ~122.6 seconds
of *emulated* time); remove it if the last rows are missing.

## 2. Python (no pygame necessary)

```cmd
python part2_play.py --headless --playback-inp part2_2player.inp --ram-trace diagnostics\part2_python_ram.csv --state-trace diagnostics\part2_state.csv
```

Writes `diagnostics\part2_python_ram_p1.csv` and
`diagnostics\part2_python_ram_p2.csv` with the same `$2000-$22FF` hex schema.
The Python implementation keeps *two independent Rack memory objects*; both
are logged, not just the currently displayed one. There is no gameplay change.

## 3. Compare

Copy the MAME CSV into the Python directory and run:

```cmd
python compare_part2_inp_ram.py part2_mame_inp_ram.csv diagnostics\part2_python_ram_p1.csv --start 1750 --end 2050 --player 1
python compare_part2_inp_ram.py part2_mame_inp_ram.csv diagnostics\part2_python_ram_p1.csv --start 3600 --end 4100 --player 1
python compare_part2_inp_ram.py part2_mame_inp_ram.csv diagnostics\part2_python_ram_p2.csv --start 1900 --end 3700 --player 2
```

Check the frame origin: MAME's `screen:frame_number()` and Python's zero-based
INP index may differ by a fixed offset. `--offset N` applies `MAME=Python+N`.
Calibrate using the known recorded coin/start events, rather than assuming
frame-number equality. Also, the two implementations can differ in gameplay
phase; *first raw byte difference is not automatically the cause*. Compare
meaningful event boundaries and missile object/timer values first, especially
`$2030-$205F`, `$2069-$206A`, `$2080`, and `$20CF`.

**Limitation:** MAME has a shared `$2000-$20FF` area plus banked state at
`$21xx/$22xx`; Python has separate Rack objects. Byte-for-byte equality of
all fields is not expected. The compare tool focuses on selected common
subranges and prints MAME/Python values for diagnostic inspection.

The Lua code has been checked against the style/API of our existing MAME
scripts, but has not been executed under Windows MAME in this environment.
