# Part II sprite restore and saucer-score graphic fix

Two independent omissions found from first playable user test:

* `lives.py` restored 1978 `OBJECT_MIRROR` after a death, yielding sprite pointer `$1C60`, which is alien artwork in Part II. Restore the native Part II mirror at `$1B10` instead (`$1C81` player picture). Also use Part II explosion pointer `$1C91` per its ROM demo handler.
* `part2_saucer.py` awarded the BCD score but omitted `$07ED -> PrintSauScore` drawing of the three-character ROM point label. The ROM pointer table `$1D4C` and messages `$1D90`/`$1D93`/`$1D96`/`$1D99` (or `$1DA8` for flashing 500) now supply the original label, drawn at the saucer coordinate.

This is not a change to attract-screen timing, and it does not claim frame-perfect saucer timing or an integrated arcade-exact two-player game. See `part2_playable_lifecycle_test.py` for descriptor and graphic regression checks.
