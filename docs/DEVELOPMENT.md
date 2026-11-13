# Part II — developer and verification guide

This guide documents the **current v25 source layout**. Older progress reports live in `docs/history/` and are intentionally not the main README.

## Current runtime modules

Run `python part2_play.py`. It imports other root-level Python modules; these are the active Part II program, including reused 1978 routines. Do not replace them with files from previous release ZIPs.

| Subsystem | Current modules |
| --- | --- |
| Entry / headless | `part2_play.py`, `part2_headless.py`, `part2_inp.py` |
| First game / turns / arrival | `part2_first_play.py`, `part2_two_player.py`, `part2_rack_arrive.py`, `part2_startup.py` |
| Alien behavior / shots / collisions | `rack.py`, `part2_enemy_shots.py`, `enemy_shots.py`, `part2_hits.py`, `combat.py`, `interrupts.py` |
| Attract / titles / screens | `part2_attract.py`, `part2_attract_screens.py`, `part2_title.py`, `part2_display.py`, `part2_colour.py` |
| Lives / scoring / high score | `lives.py`, `score_display.py`, `part2_hi_score_entry.py`, `game_over.py` |
| Saucer / shields / waves | `part2_saucer.py`, `part2_saucer_drop.py`, `part2_rack_bonus.py`, `saucer.py`, `shields.py`, `waves.py` |
| Audio / artwork | `part2_audio.py`, `sound_ports.py`, `sound_driver.py`, `wav_audio.py`, `part2_bezel.py` |
| ROM / shared state / other | `part2_rom.py`, `rom_objects.py`, `game_objects.py` and remaining root `.py` modules |

## Run tests

From the project directory, run tests **as modules** so the active root modules are importable:

```cmd
python -m tests.part2_v25_sound_test
python -m tests.part2_v24_final_features_test
python -m tests.part2_v23_init_rack_restore_test
python -m tests.part2_v20_rom_mirror_handoff_test
python -m unittest tests.part2_headless_replay_test
```

Other historical tests are preserved under `tests/`. Some are development snapshots and may represent a historical intermediate stage rather than a release requirement.

## Original MAME replay

```cmd
python part2_play.py --headless --playback-inp part2_2player.inp --ram-trace diagnostics\python_ram.csv
```

The MAME Lua scripts are in `tools/mame/`. To log the same replay on your MAME installation, give MAME a path to the Lua script; the resulting CSV will be written in MAME's working directory:

```cmd
mame.exe invadpt2 -playback part2_2player.inp -video none -sound none -nothrottle -autoboot_script tools\mame\trace_part2_inp_ram_mame.lua
```

The `.inp` and the Lua script must be reachable from the working directory; supply absolute paths if using a separate MAME folder. This game uses the `invadpt2` driver. The Lua traces are for diagnostics, not required for running Python.

### Python comparison tools

Since these utilities live under `tools/`, run them with `-m` from the project directory:

```cmd
python -m tools.trace_part2_python_missile_phases --inp part2_2player.inp --start 1800 --end 1900
python -m tools.diagnose_part2_launch_phase part2_mame_inp_ram.csv python_ram_p1.csv --start 1800 --end 1900
```

Use saved MAME/Python CSV paths as appropriate. Some tools take extra arguments; use their `--help` where available.

## Source references and legacy materials

`docs/reference/` preserves the Part II disassembly, the reconstructed 8080 assembly listing and notes. `docs/history/` preserves all previous `README_V...` files, including early Part I-based stages. `archive/legacy_source/` contains unused old Python entry points and utilities; they are not used by `part2_play.py` and are kept solely for historical comparison. Old batch-file shortcuts are in `archive/old_launchers/` and are not recommended for launching v25.
