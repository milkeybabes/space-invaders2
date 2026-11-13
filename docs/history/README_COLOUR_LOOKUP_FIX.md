Space Invaders Part II — PROM colour lookup correction

The Stage 11 colour lookup accidentally used the upright framebuffer as
if it were the PROM address. MAME's hardware lookup is based on the rotated
VRAM byte offset and includes the 0x20 visible-scanline offset.

This release corrects part2_colour.py and includes a self-contained PNG test:

    python part2_colour_lookup_test.py
    python part2_stage11_test.py
    python part2_play.py

The script saves:
  diagnostics/part2_colour_fullfill_player1.png
  diagnostics/part2_colour_fullfill_player2.png
  diagnostics/part2_colour_title.png

These are at native 224x256 resolution. Compare the full-fill P1 screenshot
with MAME's fill 2400,1c00,ff experiment. Title timing and the rest of the
attract-mode state machine remain works in progress.
