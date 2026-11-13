# Part II — Premiere-compatible uncompressed AVI

The recording writer now uses ordinary **24-bit uncompressed AVI** (`rawvideo` / `bgr24`), not FFV1. It preserves exact rendered pixels, with no compression.

Run at 3×:

```cmd
python part2_play.py --scale 3 --record diagnostics\part2_attract.avi
```

Press Esc to close the file; F5 pauses, F8 advances one simulated frame while paused, and F12 saves a PNG. FFmpeg must be on PATH. All other game and timing logic is unchanged. AVI timebase remains the existing 59.542 fps.

The AVI is uncompressed and will be large (~93 MB/s at 672×768 and 59.542 fps); this is intentional.

This matches the conventional uncompressed AVI *approach* used for compatibility, but the precise codec metadata of the user's MAME-produced AVI has not been inspected.
