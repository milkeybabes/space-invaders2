# Space Invaders Part II — Python v2.0, Stage 01

This is the **first verified development stage**, not a complete/playable Part II port.

## Proven so far

The included `verify_asm8080.py` assembles `reference_invadpt2.asm` into **exactly 10,240 bytes**, with **zero mismatches** against `roms/pv01`–`roms/pv05`. All files were taken from the user's inputs.

This package is a separate copy of the v1.0 GitHub project, with limited v2 changes introduced behind `Rack(part2=True)`. The original v1 paths remain default and unchanged in behaviour.

## V2 translation delivered in this stage

- `$01DE` / `$01E1` **InitAliensHL**: selects the original 44-byte formation (some later patterns deliberately contain empty slots) from `$4000` ROM, adds 11 squids to the top row; `round_number >= 16` selects the round-nine index.
- `$010F` **DrawAlien**, sprite selection: uses each alien status byte (`1/3/5/7`), `$1C01` sprite table, and `$40` animation-frame offset. The existing Python video-memory renderer is reused.
- `$015F` **CursorNextAlien**: recognises nonzero alien status rather than only `1` in the v2 opt-in path.
- ROM-backed data supplied without modifying the original ROM files.

## Run diagnostics (Windows Command Prompt)

```
py part2_diagnostic.py
py verify_asm8080.py reference_invadpt2.asm roms
```

The diagnostic generates `diagnostics/part2_first_100_frames.png` using the current v1 interrupt scheduler.

## Not yet translated; do NOT interpret the diagnostic as an authentic v2 game

The starting rack's timing and initialization mirror, saucer-drop ISR, splitting crabs, altered hit/scoring, intermissions, per-round arrival, name entry, 5-digit scores, sound/colour hardware and Part II input/protection are **not** in this stage. Various v1 modules still assume `1` means alive and still contain 1978 ROM constants. They must be translated and validated before enabling the full-game path. The v1 `.cmd` launchers intentionally continue starting v1, never the incomplete v2 diagnostic.

## Translation principle

Native Python algorithms corresponding to 8080 source routines, NOT instruction emulation. Original 1978 game kept as a baseline. Verify subsequent functionality and frame/event timing against `invadpt2` in MAME. Preserve unusual authentic behaviours.
