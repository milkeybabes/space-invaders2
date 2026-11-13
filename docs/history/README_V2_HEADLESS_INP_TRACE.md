# Part II: reproducible headless MAME INP replay and frame-state trace

This build extends the existing MAME 0.282 INP decoder and replay runner.

## Run the complete reference sequence without pygame

```cmd
python part2_play.py --headless --playback-inp part2_2player.inp --frame-crc diagnostics\part2_2player_python_crc.csv --state-trace diagnostics\part2_2player_state.csv
```

This requires Python only. Frames 0..7299 are simulated; the recorded input edges are used as before. `--frame-crc` calculates CRC32 on **unscaled 224x256 RGB game pixels**; `--state-trace` records active player, current foreground state, handoff substate, reserve lives, deaths, finished flags, rack frame and `0x206B` for every frame. The CSVs bundled here are from an actual completed 7,300-frame run.

For a standard native 224x260 uncompressed AVI, add `--record diagnostics\part2_python.avi` (FFmpeg must be on PATH). pygame-ce is only needed for the interactive window, not for headless replay/recording. The large AVI itself is intentionally not bundled.

## Findings from this Python run (not yet MAME synchronized)

- INP edges: coin frames 297-301 and 333-336, two-player start 393-397.
- Python first turn switch to P2: frame 1823.
- Python next switches: P1 at 3381; P2 at 4065; P1 at 4749; P2 at 5426.
- Python returns to attract/title at frame 6103.
- The reference MAME footage previously reviewed had the first death around 4049 and P2 prompt around 4347, with final attract return around 6907 (these are approximate visual checkpoints, not ROM-verified samples).

**The same input sequence is applied, but game-state/event timing still differs dramatically.** In particular, do NOT fix this by shifting video frames or adding delays to the replay input. Inspect alien missile/death and ROM player transition logic against the MAME recording, ideally tracing ROM memory around the first collision and game-over. Exact CRC comparisons additionally require the MAME AVI pixel canvas, its 4 extra scanlines, and color wiring to be aligned.

## Regression tests

```cmd
python -m unittest part2_headless_replay_test -v
```

The tests verify all six INP input edges, credit consumption, two-player initiation and headless RGB frame CRC generation. This build preserves the independent two-player game state; it does not declare MAME gameplay parity.
