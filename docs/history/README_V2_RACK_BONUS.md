# Space Invaders Part II v2 — rack bonus integration

The native-Python version now connects the Part II ROM routines `CountAliens` ($13D2), `RackBonus` ($4410), `BonusValue` ($4653), and the relevant portion of `EndOfRack` ($0BCA) to the playable game.

When exactly one invader remains, the original ROM checks its status: the bottom-left alien earns 1000, the bottom-row middle octopus earns 800, other surviving octopuses within the bottom two rows earn 500; otherwise there is no bonus. The original `BONUS ... POINTS` character codes are used (including ROM replacement digits for 800/1000). Bonus score is added using the game's packed-BCD path. The source's fan geometry is implemented with actual video-RAM `0x0F` pixel writes and repeated beam fans. The next rack begins after the bonus sequence.

**Important fidelity limits**: the foreground delay loops are stepped at an approximate one beam-row per video frame, and the original end-of-rack `Intermission` and the separate under-56-shots extra-ship rule are not yet connected. Their source exists in `reference_invadpt2.asm`. No claim of cycle-accurate animation timing is made.

Run `PLAY_PART2.cmd` for gameplay. Run `python part2_rack_bonus_test.py` for six qualifying/nonqualifying end-of-wave scenarios. The other included Part II test scripts pass.
