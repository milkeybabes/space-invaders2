"""ROM $150F -> $0D32 post-game attract regression."""
from part2_attract import Part2AttractPreview


def test_postgame_insert_coin_before_title():
    post = Part2AttractPreview(post_game=True)
    assert post.phase == 'insert_coin', post.phase
    # $0D32 waits one second, clears $0BA3, prints $0AD9, executes
    # $10BA five high-name flashes and $1673 delayed message descriptors.
    for _ in range(64):
        post.step()
        assert post.phase == 'insert_coin'
    assert not post.screen.complete
    post.step()
    assert not post.screen.complete
    for _ in range(1600):
        if post.phase == 'title':
            break
        post.step()
    assert post.phase == 'title'
    assert 'player_descriptor' in post.coin_foreground.stages_visited
    assert post._cold_boot is False
    cold = Part2AttractPreview()
    assert cold.phase == 'title'
    assert cold._cold_boot is False  # startup initialised by _set_phase


if __name__ == '__main__':
    test_postgame_insert_coin_before_title()
    print('PASS: post-game returns via ROM $0D32 credit-info screen')
