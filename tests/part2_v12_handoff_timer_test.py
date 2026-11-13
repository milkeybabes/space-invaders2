"""Check the different initial-start and subsequent handoff player timers."""
from part2_two_player import Part2TwoPlayer


def test_initial_and_handoff_timers():
    game = Part2TwoPlayer()
    first_timer = bytes(game.games[0].rack.mem[0x2010:0x2012])
    assert first_timer == b'\x00\x80', first_timer
    # Finish the *first* prompt; its 128-tick player start stays intact.
    for _ in range(250):
        game.step()
        if game.transition is None:
            break
    assert game.transition is None
    assert bytes(game.games[0].rack.mem[0x2010:0x2012]) == first_timer
    # Exercise the normal handoff path independently of death randomness.
    game.active = 1
    game._begin_transition()
    for _ in range(330):
        game.step()
        if game.transition is None:
            break
    assert game.transition is None
    timer = bytes(game.games[1].rack.mem[0x2010:0x2012])
    assert timer == b'\x00\x00', timer
    assert not game.games[1].arrival.complete, 'handoff arrival must remain incremental'

if __name__ == '__main__':
    test_initial_and_handoff_timers()
    print('PASS v12 first-start $0080 timer; resumed-turn $0000 timer')
