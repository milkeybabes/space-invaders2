"""Part II v7: ROM player-object delay after RackArrive."""
from part2_first_play import Part2FirstPlay
from part2_two_player import Part2TwoPlayer


def check():
    play = Part2FirstPlay()
    r = play.rack
    assert bytes(r.mem[0x2010:0x2012]) == bytes(r.mem[0x1B10:0x1B12]) == b'\x00\x80'
    while not play.arrival.complete:
        play.step()
    assert r.objects.player_draws == 0
    for _ in range(127):
        play.step()
        assert r.objects.player_draws == 0
        assert r.mem[0x2069] == 0
    play.step()
    assert r.objects.player_draws == 0, '128th decrement should not draw'
    play.step()
    assert r.objects.player_draws == 1, 'ship appears after ROM timer expires'

    game = Part2TwoPlayer()
    for frame in range(393, 681):
        game.step()
        if frame == 680:
            assert game.games[0].arrival.complete
            assert game.games[0].rack.objects.player_draws == 0
    print('PASS: Part II uses ROM $0080 player startup timer, no ship at frame 680')


if __name__ == '__main__':
    check()
