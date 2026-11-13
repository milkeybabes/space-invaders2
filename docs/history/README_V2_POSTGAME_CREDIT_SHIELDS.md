# Part II v2 — credit prompt before/after a played game

The credit prompt now distinguishes the cold-start presentation from the one seen in the supplied MAME screenshot after a prior game:

- Before any game: the score/credit prompt retains an empty lower field.
- After a game has been started: the prompt shows four red-overlay shield shapes using the authentic Part II ROM bitmap at $1D1C, positioned using the shield layout constants. It does **not** draw cyan reserve cannon sprites.
- TAITO high-score name and the original $1F3E PUSH / $184D/$1838 start messages are retained.
- F3 resets the session distinction.

This follows the observed difference between the supplied MAME states. Precise timing/interrupt-level origin of the post-game shields remains to be verified against MAME; no claim of frame-perfect parity is made.

Regression: `python part2_credit_prompt_test.py` verifies empty first-use screen versus post-game shields. All 29 existing test scripts pass.
