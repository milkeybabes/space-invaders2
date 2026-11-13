"""ROM-ordered $0D32 video sequence regression; not a frame-number fudge."""
from part2_attract import Part2AttractPreview


def test_coin_screen_is_not_created_instantaneously():
    p = Part2AttractPreview(post_game=True)
    assert p.phase == 'insert_coin'
    assert not p.screen.complete
    for _ in range(64):
        p.step()
        assert p.phase == 'insert_coin'
    assert p.coin_foreground.stage == 'one_sec'
    p.step()
    assert p.coin_foreground.stage != 'done'
    assert not p.screen.complete


def test_rom_flash_and_message_are_sequential():
    p = Part2AttractPreview(post_game=True)
    for frame in range(1600):
        p.step()
        if p.phase == 'title':
            break
    assert p.phase == 'title'
    stages = p.coin_foreground.stages_visited
    required = ['clear_before_coin', 'insert_coin', 'corporation',
                'flash_high_name', 'player_descriptor', 'coin_descriptors',
                'two_sec', 'clear_after_coin', 'done']
    assert [x for x in stages if x in required] == required, stages
    # 5 pairs of $0x20 waits, plus the drawing/erasing between them.
    assert frame > 5 * 2 * 32


def test_descriptor_count_from_live_ram():
    from part2_two_player import Part2TwoPlayer
    from part2_coin_foreground import Part2CoinForeground
    memory = bytearray(Part2TwoPlayer().rack.mem)
    assert memory[0x206c] == 0x12
    fg = Part2CoinForeground(memory)
    assert fg.letters_per_descriptor == 0x12


if __name__ == '__main__':
    test_coin_screen_is_not_created_instantaneously()
    test_rom_flash_and_message_are_sequential()
    test_descriptor_count_from_live_ram()
    print('PASS: $0D32 ordered drawing, ROM wait loops and live RAM descriptor count')
