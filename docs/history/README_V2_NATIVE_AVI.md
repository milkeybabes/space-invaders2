Space Invaders Part II — native AVI capture

The single native game RGB bitmap (224x256) now feeds both the nearest-neighbour pygame window and the AVI writer. Unlike the previous recorder, AVI capture does NOT read the scaled window surface.

MAME invadpt2 describes a 224x260 visible output (59.541985 Hz). Default AVI is 224x260, with the 4 additional lines currently blank at the bottom. Exact vertical positioning of these non-game pixels must be verified against a MAME raw capture; no game pixels are scaled or discarded.

Run: python part2_play.py --scale 3 --record diagnostics\part2_attract.avi
Optional raw game-only image: python part2_play.py --scale 3 --avi-height 256 --record diagnostics\part2_native256.avi
F5 pause/resume; F8 single frame; F12 screenshot; F3 reset. FFmpeg required on PATH.
Codec: uncompressed 24-bit BGR AVI; 59.541985 fps.

Synthetic-frame test: FFmpeg RGB24 decoded frame matched the exact source bytes at 224x260. This test does not verify Premiere's particular AVI import handling or the 4-line MAME placement.
