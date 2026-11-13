# Part II v2 — coin interrupts attract

The first credit now interrupts any title/score-table/demo/insert-coin attract
screen and enters a stationary ROM-derived $0845 WaitForStart presentation.

- 5 once: $1F3E "PUSH" plus $184D "ONLY 1PLAYER  BUTTON".
- 5 again: $1838 "1 OR 2PLAYERS BUTTON".
- The credit digit and four start-screen cannon sprites are displayed.
- 1 with credit: starts the current single-player Part II translation.
- F3: resets credits, gameplay and resumes normal attract sequence.

The original ROM's $087E one-player start remains wired to the existing
single-player integration. The two-player gameplay controller is not yet
translated for Part II, so the original two-player prompt is displayed but
pressing 2 does not start a two-player game.

Test: `python part2_credit_prompt_test.py`.
