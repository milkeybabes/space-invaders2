# Space Invaders Part II — invasion game-over and non-overwriting F12 screenshots

## Invaders at bottom

Part II's original ROM checks the moving alien position at `$0189`–`$018C`, using `$28` as its invasion threshold. At `$1737` it sets RAM `$206D` (`invaded=1`) and jumps to the player-hit/end-of-round code at `$1512`. This must end the run even if the player still has reserve ships.

The playable integration now routes the existing invasion threshold through `PlayerLives.invasion_reached_bottom()`, setting the original flag and running its existing player-death/game-over sequence. It does not use the normal reserve-ship respawn or advance to another wave. The resulting game-over transition is still a translated/integrated approximation rather than exact foreground-cycle timing.

Unlike unlimited-lives protection for ordinary projectiles, `--debug` deliberately **does not** prevent an invasion-ending game-over: the rack has reached the player baseline and the original ROM treats that as a separate failure condition.

## F12 screenshots

F12 writes screenshots inside `diagnostics/` with filenames such as `part2_frame_0001234_000.png`. Repeat captures from the same game frame increment `_001`, `_002`, and so on. Existing captures are not overwritten. The same behaviour works during attract mode and while the game is paused.

## Verification

Run `python part2_invasion_screenshot_test.py`. The test checks the original `$28` boundary, the $206D flag, game over despite reserve ships, no respawn or new wave, debug behaviour and repeated F12 naming. All 25 project `*test.py` scripts pass in this build.

The previously completed 1978 Space Invaders game was **not modified** here. It still needs a separate invasion-trigger regression check before we can call its bottom-of-screen logic verified.
