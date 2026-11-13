"""Stage 12: ROM-backed attract screens and MAME AVI phase reference."""
from part2_attract import Part2AttractPreview
from part2_attract_screens import Part2AttractScreen
from part2_rom import load_rom


def check():
    lo, _ = load_rom()
    score = Part2AttractScreen('score_table')
    assert score.mem[0x1ACB:0x1ACB+21] == bytes(lo[0x1ACB:0x1ACB+21])
    base = score.image()
    score.advance(1.3)
    assert score.image() != base, 'first score-table sprite never rendered'
    score.advance(8)
    assert score.next_event == len(score.events)
    assert len(score.events) == 62
    # Original image at $1882 is the flashing saucer (first descriptor).
    assert score.mem[0x2C0E] == lo[0x1882]
    assert score.mem[0x2C0E + 32*15] == lo[0x1882+15]
    assert score.mem[0x2812] == lo[0x1E21 + 0x29*5], 'ROM font title not printed'
    coin = Part2AttractScreen('insert_coin')
    coin.advance(8)
    assert coin.next_event == len(coin.events)
    assert coin.mem[0x2C11] == lo[0x1E21+0x08*5], 'INSERT COIN does not begin with I'
    assert coin.image() != base
    demo = Part2AttractPreview()
    while demo.phase == 'title': demo.step()
    assert demo.phase == 'score_table'
    while demo.phase == 'score_table': demo.step()
    assert demo.phase == 'demo'
    assert demo.rack.mem[0x21F9] == 0
    # Do not advance by a guessed AVI length: the source waits for death.
    for _ in range(100): demo.step()
    assert demo.phase == 'demo'
    demo.rack.mem[0x2015] = 0
    demo.step()
    demo.rack.mem[0x2015] = 0xFF
    demo.step()
    assert demo.phase == 'insert_coin'
    while demo.phase == 'insert_coin': demo.step()
    assert demo.phase == 'title'
    while demo.phase != 'demo': demo.step()
    assert demo.rack.mem[0x21F9] == 3
    print('PASS: Part II ROM score-advance sprites and character messages,')
    print('      coin instructions, colour-screen buffers, ROM-delay sequenced attract loop')


if __name__ == '__main__':
    check()
