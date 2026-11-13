# Space Invaders Part II v23 — ROM $00CC InitRack restoration

This is a focused source-derived correction to the **resumed-player rack state**, based on the included Part II disassembly and the recorded MAME INP/RAM trace. It is not a claim of full 7,300-frame synchronization.

## Issue exposed at MAME/Python frame 3929

- MAME begins Player 1 rack arrival at **3915**; v22 Python begins it at **3925**. The ten-frame lag is **not** corrected in v23.
- MAME loads the returning Player 1 rack from the saved reference ($21FB-$21FD): movement delta `$FE`, reference Y `$70`, reference X `$2E`.
- v22 Python copied the ROM mirror at `$0352` but skipped **`InitRack` at `$0921`**, leaving the shared reference at the default Y `$78`, X `$38`. That changes the whole resumed formation position and the arrival target.
- Python also saves X `$2C` rather than `$2E` because the earlier first-life hit remains late. That separate two-pixel difference is **not** papered over.

## Changes

**part2_two_player.py**

1. Perform the ROM's initial bank setup (`$08D4`, `$08EE-$08F4`): each independent Python rack gets the initial direction +2 and saved reference X=`$38`, Y=`$78` (or the requested starting round's configured target height). Because the original machine has one shared address space and Python has two, both copies must be initialized.
2. Implement the actual `$00CC-$00F1` `InitRack` algorithm, restoring `$2009/$200A` (reference coordinates), `$200B/$200C` (cursor coordinates), `$2008` (movement delta, including the original single-alien 3-to-2 case), and `$200D` (left/right flag) from the current player's saved bank.
3. Call `InitRack` after restoring the returning player's playfield and immediately before constructing `$09CA` `RackArrive`, exactly where the ROM calls it at `$0921`. The verified first Player 1 startup path is deliberately unchanged.

**part2_v23_init_rack_restore_test.py** checks ROM-default player banks and each player's restored coordinates/direction.

## Verified

- New InitRack restoration test passes.
- v22 first-start checkpoint regression passes, including gameplay enable frame 680, enemy-fire enable frame 856, and first rolling missile frame 986.
- ROM mirror, progressive handoff clear, reserve/life HUD, first-start/resumed timer, palette and game-over regressions pass.
- Full **7,300-frame** headless INP replay completes.

## Remaining differences (important)

- MAME's Player 1 return starts rack arrival frame **3915**, Python remains **3925**. MAME's player-switch wait starts about 3592; Python about 3605 because preceding Player 2 gameplay/death is late. Shortening the return animation to hide this would not be ROM-correct.
- Player 1's saved rack X is MAME `$2E`, Python `$2C`, the consequence of the earlier first-life collision difference. The fixed restore now uses that real saved value, not default `$38`.
- Investigate projectile-object service/collision around the **first** rolling missile launch at frame 986 and the first death (MAME 1881; Python later), then the Player 2 death that determines the return timing.

## Run

```cmd
python part2_play.py --playback-inp part2_2player.inp --record part2_v23_replay.avi
```

For headless confirmation:

```cmd
python part2_play.py --headless --playback-inp part2_2player.inp
python part2_v23_init_rack_restore_test.py
```

No arbitrary offsets or frame delays have been introduced.
