# Space Invaders Part II v2 — playable life-cycle correction

Addresses the report that the first playable build froze when the player's ship was hit.

- Connects the **existing translated player-death/respawn** state machine via the original game-object dispatcher instead of triggering the diagnostic halt-on-hit branch. Three ships (one active, two reserves); death animation, reserve subtraction, respawn and game-over handoff now run.
- Keeps the Part II graphics/font bytes intact: do **not** overwrite $1C70/$1C80/$1ED0 with 1978-only fixtures. The Part II blow-up sprites start at **$1C90**, as shown by `PlrBlowupSprites` in the annotated Part II disassembly.
- Returns from the playable session to attract mode after the existing game-over sequence reports `attract_pending`. The game-over presentation itself is still provisional and needs Part II-specific message-source translation.
- Adds a test for the saucer score award. The ROM score byte `$15` means **150 displayed points**, while `Combat.score` is internally in units of ten (`15`). The normal game saucer timing, visual score effect, and hit recognition still need on-screen MAME validation; this is not yet a confirmed fix for the user's observation.
- Formation: the original first GAME round (`round 0`) has 55 aliens. The Part II attract DEMO alternates rounds 0 and 3, with round 3 having three holes. The main executable keeps the original distinction: it must not force the round-3 formation into the player's first round.

Run `PLAY_PART2.cmd` or `python part2_play.py`. Keys 5=coin, 1=start, arrows/A-D=move, Space/Ctrl=fire.

Regression: `python part2_playable_lifecycle_test.py`; `python part2_first_play_test.py` and the existing `part2_*test.py` suite.

**Limitations:** start/coin flow, Part II-specific game-over lettering, score presentation on saucer hit, alien wave transitions, accurate timing, and high-score flashing remain under development. The original 1978 game-over controller is temporarily reused for flow in this milestone without writing over Part II ROM graphics.
