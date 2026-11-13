Space Invaders Part II v2: title-carving correction
===================================================

Corrected part2_title.py to reproduce CarveBitmap ($4148) faithfully:
- The C parameter is the total number of passes, not the number of pairs.
- The source DE pointer consumes B bitmap bytes on EACH pass.
- The destination HL is decremented by one byte only after the second pass.
- The masks alternate 0x0E (first pass) and 0xE0 (second pass).

Before, the two passes were grouped into a single column, reusing the
same source and shifting the destination on the wrong pass. That caused
misshapen SPACE and INVADERS letters. PART II was already correct.

The colour PROM renderer is NOT modified by this fix.

To test in Windows Command Prompt:
    python part2_title_carve_regression_test.py
    python part2_stage11_test.py
    python part2_colour_lookup_test.py
    python part2_play.py

The title preview is saved in diagnostics/part2_colour_title.png.
Current attract timing and the copyright text remain provisional.
