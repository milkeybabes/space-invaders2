# Part II title foreground timing refinement

The title remains a translation of the ROM's `FillDots`, `CarveBitmap`,
`CarveGroup`, `CopyBitmap` and `DelayBC` algorithms. This update replaces
an overly optimistic 32-cycle charge per rendered video-memory byte with
instruction-count-based operation budgets:

* `FillDots` -> `DrawSimpSprite`: approximately 85 8080 T-states per written byte,
  including recursive draw-loop and caller overhead;
* `CarveGroup`: approximately 115 T-states per mask/write, plus the already
  counted $0250 `DelayBC` call;
* the *set* bits in the carve bitmap now consume approximately 150 T-states
  traversing the unmodified four-dot group, rather than being free;
* `CopyBitmap` uses a shorter plain byte-copy budget.

Original bitmaps, dot order, colour PROM, `0x40` IRQ waits and game/demo code
remain unchanged. Host CPU speed never controls the logical frame count.

Diagnostic from this build: SPACE carve stage ends at frame 205 (previously
198), INVADERS fill at frame 270 (previously 262). In the user's earlier MAME
reference the comparable checkpoints were around frames 207 and 272.
These are diagnostic observations, not hard-coded target frames. Further
frame-level refinement needs verification on Windows against the same
recording power-on/reset conditions.

```
python part2_title_foreground_timing_test.py
python part2_play.py --scale 3 --record diagnostics\part2_attract.avi
```
