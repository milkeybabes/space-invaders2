# v15: ROM $0373 / $0907 progressive VRAM clear on player handoff

## MAME reference
The first player-to-player transition around frame 2073 does not blank the
playfield instantly. The outgoing aliens are gradually erased before the
PLAY PLAYER<2> prompt is established. The later clear before rack arrival
is likewise incremental.

## Source-backed correction
Original Part II disassembly:
- $0365: TwoSecDelay
- $0368/$0369: reset player object timer (only subsequent turns)
- $0373: CALL $0BA3 ClearPlayField
- $0379: go to $08FD, which eventually calls $0A73 PromptPlayer
- $0907: CALL $0BA3 ClearPlayField before playfield restore and rack arrival
- $0BA3-$0BBD: C=26 rows, B=223 columns, HL starts $2402 and advances
  $20 between consecutive column writes, then by 1 for the next row.

The native Python scheduler now runs both clears over successive video frames
instead of calling the immediate clear helper. It uses the **same approximate
41 8080 cycles per VRAM byte** as part2_coin_foreground.py, within the
shared CYCLES_PER_FRAME budget. This is not a full CPU emulator and is not
claimed to be cycle exact. No arbitrary fixed wait was introduced.

Because Python keeps an independent RAM/video memory for each player whereas
the arcade has a *shared* VRAM, the outgoing player's video bytes are copied
onto the incoming display immediately before the progressive $0373 erase.
The incoming player's shield bytes are saved first and restored after the
second erase. The first-ever Player 1 startup retains its validated v6 schedule.

## Regression
- `python part2_v15_handoff_vram_test.py`
- `python part2_two_player_transition_test.py`
- `python part2_v6_startup_timing_test.py`
- Full INP replay: `python part2_play.py --headless --playback-inp part2_2player.inp`

MAME pixel-by-pixel confirmation of the intermediate transition frames is
still pending. Gameplay, first-start countdown, and enemy firing logic are
unchanged.
