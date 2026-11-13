"""v9: per-player colour PROM, reserve handling and explosion red."""
from part2_two_player import Part2TwoPlayer
from part2_colour import Part2Colour, W, H


def main():
    col = Part2Colour()
    p = Part2TwoPlayer()
    assert p.visible_player == 1
    p.step()
    assert p.visible_player == 1
    # 2P turn and transition display must select their real PROM.
    p.active = 1
    p.transition = {'phase': 'prompt', 'frames': 10, 'previous': 0}
    assert p.visible_player == 2
    p.transition = {'phase': 'wait', 'frames': 10, 'previous': 0}
    assert p.visible_player == 1
    p.transition = None
    lit = bytes([255]) * W * H
    assert col.apply(lit, player=1) != col.apply(lit, player=2)
    p = Part2TwoPlayer()
    p.games[0].rack.lives.pending_turn_reserve = True
    before = p.games[0].rack.lives.stash
    assert before == 2
    p.active = 1
    p._show_player_prompt()
    assert p.games[0].rack.lives.stash == before, 'inactive player reserves must stay visible'
    p.active = 0
    p._show_player_prompt()
    assert p.games[0].rack.lives.stash == before-1, 'reserve must decrement on return'
    assert not p.games[0].rack.lives.pending_turn_reserve
    print('PASS v9: active-player PROM, deferred reserve removal on return')

if __name__ == '__main__':
    main()
