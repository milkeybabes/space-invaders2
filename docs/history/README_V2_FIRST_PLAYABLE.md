# Space Invaders Part II — first playable integration milestone

**Priority change:** proceed into gameplay rather than tune the few-frame title offset.

Start with `PLAY_PART2.cmd` or `python part2_play.py`.

- `5`: add a coin, `1`: start a **provisional** one-player Part II game (requires credit).
- Left/right arrows or A/D: move; Space or left Ctrl: fire.
- F3: return to attract and reset; F5: pause; F8: frame-step while paused; Esc: exit.
- Initial ROM-led attract presentation and demonstration still run without credit.

The new `part2_first_play.py` uses **Part II** ROM imagery and formation tables, the existing native 1979 player-object and missile handlers, Part II shields and the translated rack-arrival routine. It does not run an 8080 emulator or substitute 1978 game graphics.

**Important limitations**: this is a first playable *integration*, not the completed arcade start/game loop. The authentic `$087E` credit/start sequence, lives, player death and respawn, wave completion, two-player support, score/header detail and high-score flashing remain to be translated and validated. No invented game-over timer has been inserted. Score/shot gameplay in this integration can be exercised, but should not yet be treated as MAME-perfect. The attract screen flashing/hold timing is deferred by design.

Regression: `python part2_first_play_test.py` plus the existing `part2_stage*_test.py`.
