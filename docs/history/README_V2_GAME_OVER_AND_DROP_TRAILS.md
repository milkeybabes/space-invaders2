# Space Invaders Part II v2 — GAME OVER and falling-alien trail correction

Changes since Level 6 collision crash fix:

1. Game-over text now reads the *actual Part II ROM bytes at $1824*, not the
   1978 message at $1AA6. The ROM uses character $1B for space; $26 is an
   angle-bracket glyph. Single-player and two-player text use this mapping.
2. Saucer-dropped aliens now erase their prior 8-row sprite location when
   advancing and on reset/landing. The renderer writes both halves of the
   original $1396 shifted VRAM sprite, rather than a single unshifted byte.
   This prevents an accumulated vertical stack of sprites above the drop.
3. Updated legacy drop test to account for actual shifted bytes. Added
   `part2_gameover_drop_regression_test.py` to test both corrections.

Validation: 28/28 Python `*test.py` scripts pass. Headless 6500-frame smoke
run completed with exit code 0 (attract preview). The falling-alien screen
behaviour should still be verified visually in a live level-6 playthrough.

Commands (Windows Command Prompt):

    python part2_play.py --start-level 6 --debug

Normal play: `PLAY_PART2.cmd`; debug mode: `PLAY_PART2_DEBUG.cmd`.
