# Space Invaders Part II — Stage 09 (shields and score display)

This is a complete flat overwrite package for the existing working directory.

## Added

- `part2_display.py`: Part II ROM-based `$0AE5` five-column font and `$107A` four BCD digits plus fixed zero; no 1978 font or display data installed over the 1979 ROM.
- Native shield source image `$1D1C`, displayed through the original 22-column copy layout (pitch `$05A0`). The existing framebuffer collision/erosion remains bitwise and destructible.
- `$0997 CarveRoundNum`: five-byte font glyph is subtracted from the four shield images in the VRAM (`screen XOR (screen AND glyph)`).
- Stage 08 autonomous demo now calls this presentation setup for each new formation.
- `part2_stage09_test.py` tests glyph width, trailing zero, all four numbers, IRQs and the original ROM font's integrity.
- `diagnostics/part2_stage09_preview.png` was rendered from the live Python framebuffer in a 3x nearest-neighbour enlargement.

## Important distinctions

- The **shield carving** and **score-digit rendering** are 8080-routine translations, but this is STILL the provisional Stage 08 demo state machine, not MAME-parity attract mode.
- The centered `HI-SCORE` label is a temporary presentation choice; Part II's authentic high-score holder-name display, full title animation, score-advance screen, and rack-arrival sequence remain to port.
- `$21FA` is the round digit shown in the shields. The preview selects 1 or 4 as it alternates its two development formations, but authentic round initialization and transitions are not yet connected.
- The v2 RAM score descriptors are copied from the Part II ROM mirror `$1BF4`, including its default high-score value.
- Enemy-shot movement hotfix from Stage 08 is included; all v1 files retain their existing behaviour.

## Run (Windows Command Prompt)

    python part2_play.py
    python part2_stage09_test.py
    python part2_stage08_test.py
    python part2_stage07_test.py
    python part2_stage06_test.py
    python part2_stage05_test.py
    python part2_stage04_test.py
    python part2_stage03_test.py
    python part2_stage02_test.py
    python part2_diagnostic.py

Next: translate `$09CA RackArrive` and build the real Part II startup/attract transitions; compare to the supplied MAME movie.
