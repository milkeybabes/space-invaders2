# Space Invaders Part II v22 — $09CA foreground workload / first-life alignment

This is a measured timing improvement based on Part II's disassembly and the MAME 0.282 7,300-frame INP recording. It remains a **native Python source translation**, not an 8080 CPU emulator.

## Evidence and root cause

The previous gameplay transition completed the foreground `$09CA` `RackArrive` loop by performing **exactly eight alien operations per frame** and instantly concluding `$0A55` `DrawScores`. The 8080 ROM does not operate in whole multiples of eight: the `$09FA-$0A4B` foreground loop, its calls to `CursorNextAlien` / `DrawAlien`, and the final `$1719` scoreboard drawing take CPU time. As a result Python resumed game tasks early, producing a constant ~3-frame lead in all later 55-alien rack-reference moves.

## Changes

- `part2_rack_arrive.py`: keeps a fractional approximate 8080 cycle budget (`CYCLES_PER_FRAME` from `part2_startup.py`) for the `RackArrive` loop, rather than a fixed eight operations every video frame. The per-iteration **4327-cycle estimate** and initial budget carry are empirical calibrations against the MAME arrival snapshots. They are **not** claims of instruction-cycle exactness.
- `part2_rack_arrive.py`: after `$0A4D` restores the saved 16-byte descriptor, models the nontrivial foreground `$0A55 CALL $1719 DrawScores` cost using the project's already existing source-level `startup_status_cycles()`. During that work, interrupts continue but normal game tasks stay suspended. The current scoreboard pixel rendering still happens as a single operation; its byte-by-byte timing remains a possible future refinement.
- `part2_two_player.py`: starts the first two `$09FA` operations during the same foreground frame that the first start's `$0907` preparation completes. Matches MAME's frame-592 alien cursor value rather than waiting until frame 593.
- `part2_first_play.py`: dispatches per-frame accumulated work rather than passing `operations=8`.
- `rack.py`: matches `$0193-$0194`: `waitOnDraw` (`$2000`) stores **row+1** for Part II, not the constant 1. `DrawAlien` still clears it to zero. The original 1978 translation is unchanged.
- `part2_v22_arrival_cycle_test.py`: deterministic MAME checkpoint regression; old `part2_v6_startup_timing_test.py` updated to reflect the more accurate timing.

## Comparison after v22

| Event | MAME frame | Python v21/v20 | Python v22 |
|---|---:|---:|---:|
| First arrival cursor index 1 | 592 | ~593 / index 0 | **592 / index 1** |
| Rack reaches target height | 677 | 676 | **677** |
| `$20E9` game-task gate enabled | 680 | 676 | **680** |
| `$2069` enemy-fire gate enabled | 856 | 852 | **856** |
| First rolling-shot activation | 986 | 982 | **986** |
| Rack reference `30 -> 2E` | 1835 | 1832 | 1836 (**+1**) |
| Later rolling-shot activation | 1835 | ~1837 | 1841 (**+6**) |
| First Player 1 hit | 1881 | 1887 | 1891 (**+10**) |

The later rolling-shot timing and death are **still wrong**. Frame 986 is matched, but later missile-object service gradually diverges; the late death allows an extra rack reference movement and can cause the next Player 1 life to differ. **Do not assume later 7,300-frame parity**. No pixel offsets, random tables, or missile-timer overrides have been added.

The MAME half-frame trace and the Python phase tracer are included for continued work. An experiment that merely reversed the per-frame interrupt order was **rejected**, because it caused new early deaths and did not reproduce MAME; that experiment is not in v22.

## Validation and commands

The full original 7,300-frame `.inp` replay completes under v22. Ten focused regression scripts covering the timing change, missile startup, handoff state, lives and VRAM clears passed. A broader test sweep exceeded the available runtime and is **not** reported as passing.

Run playable replay and AVI capture:

```
python part2_play.py --playback-inp part2_2player.inp --record part2_v22_replay.avi
```

Run headless replay:

```
python part2_play.py --headless --playback-inp part2_2player.inp --ram-trace diagnostics\part2_v22_ram.csv
```

Run targeted test:

```
python part2_v22_arrival_cycle_test.py
```

Recommended next audit: compare the first mismatch in missile movement/collision after the matched rolling launch at frame 986, then its effect on the later launch at frame 1835 and the first death at 1881. Keep following the Part II disassembly, not tuned projectile coordinates.
