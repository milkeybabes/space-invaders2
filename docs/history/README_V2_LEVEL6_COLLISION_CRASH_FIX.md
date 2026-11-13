# Part II v2 — Level-six collision crash correction

Reported crash when shooting during `--start-level 6`:

```
ValueError: alien status slot must be in active 55-alien bank
```

In the Part II ROM, `PlayerShotHit` ($121D) computes the status pointer through `FindRow` ($12B3), `FindColumn` ($12C0), and `GetAlienStatPtr` ($1345). The returned low byte is derived from 8-bit arithmetic. When a shot collides with shield/missile pixels or displaced/split aliens, the computed position can fall outside the actual 55 status slots, even when adjacent RAM has a nonzero value. The previous integration read that RAM, assumed it was a live alien, then passed it to `apply_alien_hit()`, which correctly rejected the invalid status address by raising an exception.

The Part II combat caller now classifies out-of-bank values as non-alien collisions rather than invoking `AlienHit`. It also accepts only documented alien status bytes (1/3/5/7) inside the bank. This does not modify the original status-pointer arithmetic, ROM formation tables, scoring, or crab-splitting algorithm; the stricter policy is a defensive native Python integration rule, **not a claim that the ROM itself performed a status-bank bounds check**. The existing `$125D` invalid-column check remains intact.

Regression: `python part2_level6_collision_bounds_test.py`, plus the existing Part II scripts. All 27 Part II tests pass. A synthetic 6,500-frame run for each of levels 4, 6, 8, 10 and 17 also completed without a Python exception. Actual field testing remains useful for differences in sprite erasure and split-alien trails.

Test launch:

```
python part2_play.py --start-level 6 --debug
```

F12 continues using unique frame-numbered captures.
