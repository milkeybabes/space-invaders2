"""Regression: 2P start key and unequal remaining lives."""
from part2_play import start_key_selection
from part2_two_player import Part2TwoPlayer


def force_completed_death(game):
    if not game.arrival.complete:
        for _ in range(350):
            if game.arrival.complete:
                break
            game.step()
    m = game.rack.mem
    m[0x2015] = 0
    m[0x2016] = 1
    m[0x2017] = 1


def die_until_swap(two):
    current = two.active
    # The ROM handoff now owns the main loop until its prompt and rack
    # arrival finish. Do not advance the player directly behind its back.
    for _ in range(550):
        if two.transition is None and two.games[current].arrival.complete:
            break
        two.step()
    assert two.transition is None and two.games[current].arrival.complete
    force_completed_death(two.games[current])
    for _ in range(320):
        two.step()
        if two.active != current or two.finished:
            break
    return current


def main():
    assert start_key_selection('2', 2) == (2, 0)
    assert start_key_selection('2', 3) == (2, 1)
    assert start_key_selection('2', 1) == (0, 1)
    assert start_key_selection('1', 1) == (1, 0)
    assert start_key_selection('1', 0) == (0, 0)
    assert start_key_selection('2', 2, already_playing=True) == (0, 2)
    two = Part2TwoPlayer(debug=False)
    # P1 loses twice, P2 once; then P1 exhausts all reserves while P2
    # still has two ships total. The second player must continue alone.
    for expected in (0, 1, 0, 1, 0):
        assert two.active == expected
        assert die_until_swap(two) == expected
    assert two.done == [True, False], two.done
    assert two.active == 1 and not two.finished
    assert two.games[1].rack.lives.stash == 0
    assert two.games[0].rack.lives.stash == 0
    # P2 now loses its last ship, ending the game only after both are out.
    for _ in range(550):
        if two.transition is None and two.games[1].arrival.complete:
            break
        two.step()
    assert two.transition is None and two.games[1].arrival.complete
    force_completed_death(two.games[1])
    for _ in range(320): two.step()
    assert two.finished and two.done == [True, True]
    print('PASS Part II two-player start input and unequal-lives continuation')


if __name__ == '__main__':
    main()
