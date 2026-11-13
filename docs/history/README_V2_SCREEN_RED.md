# Part II red flash on player death

MAME `invadpt2_sh_port_1_w` uses OUT `$03` bit 2 as both the explosion signal and `m_screen_red`. `screen_update_invadpt2` uses palette pen 1 (255,0,0) for **all lit VRAM pixels** while this latch is high. The background stays black. This build routes the signal through the existing `RomSoundDriver` to `Part2Colour.apply(...,screen_red=True)`.

The sound driver's first-pass explosion hold is currently **38 rendered frames**; this is NOT claimed to be ROM-cycle-exact, and should be aligned to MAME later. VRAM is never modified by the red effect. No red flash occurs with `--mono` since that bypasses the colour board.

Test with `python part2_screen_red_test.py` and visually check a death in `PLAY_PART2.cmd`.
