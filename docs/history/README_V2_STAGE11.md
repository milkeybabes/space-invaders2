# Space Invaders Part II — Stage 11, ROM title and colour preview

This release replaces the temporary pygame-font title screen with a translated implementation of the ROM routines at $40DC (TitleScreen), $41CD (FillDots), $4148 (CarveBitmap), and $4133 (CopyBitmap). The actual dot pattern ($41E4) and lettering bitmaps ($41EC, $424C, $427C) come from the original pv05 ROM. It also adds both 1 KB original colour PROMs `pv06.1` and `pv07.2`. The display colours the 224×256 native bitmap from PROM entries rather than applying a generic coloured graphic.

The timing of the animation is distributed over the current 160-frame preview title phase. This is NOT yet a translation of the original foreground delays and is NOT MAME frame-matched. The PROM lookup orientation is provisional until verified against a colour MAME frame. The title's high-score-name/copyright flashing text and true transitions to the score table remain pending; the previous score table is still a placeholder.

## Run (Windows Command Prompt)

    python part2_stage11_test.py
    python part2_play.py

Optional monochrome comparison:

    python part2_play.py --mono

The zip is flat: extract OVER the existing SpaceInvaders_PartII_Python_v2_Stage01 working directory. All earlier source remains present and the 1978 project remains unchanged.
