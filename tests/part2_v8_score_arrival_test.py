"""Regression: shared HUD is not repainted on every rack-arrival frame."""
from part2_two_player import Part2TwoPlayer


def check():
    g = Part2TwoPlayer()
    for frame in range(393, 601):
        g.step()
    r = g.rack
    assert not g.games[0].arrival.complete
    # Choose a scoreboard header address away from the moving sprites.
    header_byte = 0x241E
    old = r.mem[header_byte]
    r.mem[header_byte] = 0xAA
    g.step()
    assert r.mem[header_byte] == 0xAA, 'score heading repainted before rack arrival finished'
    # It must be restored by RackArrive.finish(), not by the game-frame loop.
    while not g.games[0].arrival.complete:
        g.step()
    assert r.mem[header_byte] == old, 'ROM DrawScores did not restore heading at arrival end'
    print('PASS v8: score HUD survives the rack shuffle without premature redraw')


if __name__ == '__main__':
    check()
