# v20 — Part II ROM $0352 / $022A handoff initialization

**Source:** bundled `SpaceInvadersPartII_Code(1).md`, addresses $0336–$0379 and $022A–$0232.

After a normal two-player death, the original code saves the outgoing rack reference in the player's $21xx/$22xx bank and calls `CopyRAMMirror`: 192 original ROM bytes ($1B00–$1BBF) become shared RAM ($2000–$20BF). It then selects the other player in $2067 and waits for the two-second handoff. This resets all three alien missile objects, including their 1979 firing-table pointers, and the $2032 and $2080 scheduler state. The player banks, score RAM and VRAM are *outside* that copy and must survive.

Previously the Python two-player implementation kept each player's complete working missile objects between turns. This caused Player 1's pointers at replay frame 3950 to remain at $1A85/$1A8F, whereas MAME had $1A80/$1A86. v20 executes the ROM-derived copy at each normal player handoff. At the same replay frame Python now has $1A80/$1A86.

**Scope:** `part2_two_player.py` and a new regression `part2_v20_rom_mirror_handoff_test.py`. No changes to missile selection, firing-table data, ship startup, VRAM clears, death HUD, or the first Player 1 start.

**Verification:** 7,300-frame Python headless INP replay, both player-bank RAM snapshots, and focused regressions for player timers, progressive VRAM clearing, lives HUD, game-over handoffs and ROM mirror/persistent-bank boundaries. The first-life missile pointers are unchanged.

**Remaining work:** MAME and Python still differ in the missile-object service phase near frame 4065. This build does *not* claim exact firing parity. Compare the ROM's interrupt ordering and $2032/$2080 synchronization next, using the existing MAME RAM CSV; do not insert frame-number shortcuts.

**Replay:** `python part2_play.py --playback-inp part2_2player.inp --record part2_v20_replay.avi`

**Headless trace:** `python part2_play.py --headless --playback-inp part2_2player.inp --ram-trace diagnostics\\part2_v20_ram.csv`
