"""Check $00CC InitRack and $08EE initial bank values for each player."""
from part2_two_player import Part2TwoPlayer


def main():
    game = Part2TwoPlayer()
    for r in (g.rack for g in game.games):
        m = r.mem
        assert bytes(m[0x21FB:0x21FE]) == b'\x02\x78\x38'
        assert bytes(m[0x22FB:0x22FE]) == b'\x02\x78\x38'

    # A returning Player 1's saved coordinates are no longer $3878.
    # $00CC must restore all four shared descriptor fields *before* $09CA.
    game.active = 0
    m = game.games[0].rack.mem
    m[0x2067] = 0x21
    m[0x21FB:0x21FE] = b'\xfe\x70\x2e'
    m[0x2008:0x200E] = b'\x02\x78\x38\x78\x38\x00'
    game._init_rack_from_player_bank()
    assert bytes(m[0x2008:0x200E]) == b'\xfe\x70\x2e\x70\x2e\x01'

    # Player 2 has an independent bank and preserves its own direction.
    game.active = 1
    m = game.games[1].rack.mem
    m[0x2067] = 0x22
    m[0x22FB:0x22FE] = b'\x03\x73\x35'
    game._init_rack_from_player_bank()
    assert bytes(m[0x2008:0x200E]) == b'\x02\x73\x35\x73\x35\x00'
    print('PASS Part II $00CC InitRack initial bank and handoff restoration')


if __name__ == '__main__':
    main()
