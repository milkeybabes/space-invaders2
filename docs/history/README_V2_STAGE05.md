# Space Invaders Part II — v2.0 Stage 05

Native Python source translation of new Part II saucer reinforcement routines:
- $42EC SaucerDrop / $43BB FindDropSlot, run before the non-player object dispatch in the mid-screen interrupt.
- $4383 SaucerDropMove / $43A3 ResetDrop, run before DrawAlien in the VBlank interrupt.
- Actual 14-byte RAM mirror for $20A0-$20AD, original 8-row sprites in $1C25, $458C and $4594.
- Round gate, saucer-direction slot selection, exact even-coordinate alignment, signed deltas expressed as byte arithmetic, 8080 unsigned carry/compare landing check, dropDone/dropOnce persistence, high-score hit flag from Stage 04, early ISR exit.

## Installation
Extract this archive directly over your one existing Part II working folder. It is a *flat* ZIP, with no new enclosing directory. v1 is untouched.

## Windows Command Prompt
```
py part2_stage05_test.py
py part2_stage04_test.py
py part2_stage03_test.py
py part2_stage02_test.py
py part2_diagnostic.py
```

## Scope and limitations
This stage adds the source-matched falling-alien subsystem as an **opt-in** fixture (`Rack(part2=True).enable_part2_drop_diagnostic()`). By design it does not pretend the original 1978 saucer handler has already been replaced with a complete Part II handler. Tests inject the original game RAM values for a flying saucer and a later round. Real saucer spawning, simultaneous shot/collision timing and MAME parity still await an integrated live Part II gameplay loop.

The source-level ISR remains a partial deterministic test harness. Main-loop timing, game start, and other handlers are not yet cycle-accurate Part II gameplay. Older tests remain unchanged.
