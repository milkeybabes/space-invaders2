"""ROM $0845 credit/start prompt: reproduce MAME one- and two-credit screens."""
from part2_attract_screens import Part2AttractScreen
from part2_rom import load_rom
from part2_display import SHIELD_START, SHIELD_IMAGE, SHIELD_PITCH_BYTES


def check():
    low, _ = load_rom()
    for credits, source in ((1, 0x184D), (2, 0x1838)):
        s = Part2AttractScreen('wait_start', credits)
        assert s.mem[0x20EB] == credits
        # Verify exact 8080 ROM message, not a 1978 hand-written substitute.
        for dst, ptr, count in ((0x3013, 0x1F3E, 4), (0x2810, source, 20)):
            for code in low[ptr:ptr + count]:
                glyph = low[0x1E21 + code*5]
                assert s.mem[dst] == glyph, (credits, hex(dst), hex(ptr))
                dst += 0x100
        assert s.mem[0x3C01] == low[0x1E21 + (0x1C + credits)*5]
        # Wait-for-start has no spare-ship cannon row, matching MAME.
        for x in (24, 56, 88, 120):
            assert all(s.mem[0x2404 + x*32 + 32*n] == 0 for n in range(16))
        # But the default high-score name is visible over the scoreboard.
        assert any(s.mem[0x2D1E + 32*n] for n in range(10*8))
        assert s.image() != Part2AttractScreen('score_table').image()
    # Credit prompts after a completed game retain the original shields,
    # while the first (cold-start) prompt has an empty lower playfield.
    cold = Part2AttractScreen('wait_start', 1, post_game=False)
    replay = Part2AttractScreen('wait_start', 1, post_game=True)
    assert cold.mem[SHIELD_START] == 0
    for shield in range(4):
        base = SHIELD_START + shield * SHIELD_PITCH_BYTES
        assert replay.mem[base:base+2] == low[SHIELD_IMAGE:SHIELD_IMAGE+2]
        assert any(replay.mem[base+32*r] for r in range(22))
    assert cold.image() != replay.image()
    print('PASS: coin prompts, cold-start empty field, post-game ROM shields, no cyan reserve ship row')


if __name__ == '__main__':
    check()
