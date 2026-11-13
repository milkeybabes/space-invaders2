# Part II v7 — original player object startup countdown

MAME/Python side-by-side at frame 680: MAME has no player ship while Python v6
has already drawn it. The cause is an inherited diagnostic shortcut.

`Rack.enable_part2_enemy_shots_diagnostic()` ultimately calls
`enable_game_objects(immediate_player=True)`, zeroing `$2010:$2011` to
bypass the source ROM's initial `$0080` 16-bit player-object timer.
This shortcut is useful for direct combat fixtures but not correct for
normal gameplay.

`Part2FirstPlay.start_round()` now restores `$2010:$2011` from the actual
ROM mirror `$1B10:$1B11` after diagnostic setup. The translated object
scheduler decrements the timer normally; the ship is not drawn during
rack arrival or on MAME reference frame 680. Player-object driven alien
fire countdown `$206A` also waits until the player-object handler runs.
No fixed frame delays or random seed alterations were added.

Added `part2_v7_player_timer_test.py`; updated `part2_two_player_test.py`
to wait for a live player object before manually forcing death. This test
change is necessary because the old fixture assumed the removed instant
player shortcut.

Remaining MAME differences: score-header erasure/redraw during alien rack
arrival, precisely when the bottom-row alien completes, and later first
projectile/turn timing. These are not claimed to be resolved by this build.

Run replay in Windows Command Prompt:

    python part2_play.py --playback-inp part2_2player.inp --record part2_v7_replay.avi

No DIP/language options were added in this timing build.
