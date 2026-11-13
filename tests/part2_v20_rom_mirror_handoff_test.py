"""Part II $0352 -> $022A: verify exact shared RAM mirror on player handoff.

This checks a real handoff (not an isolated table-pointer assignment) and
ensures player banks, scores, and VRAM are not overwritten by the ROM copy.
"""
from part2_two_player import Part2TwoPlayer


def test_rom_mirror_handoff():
    two = Part2TwoPlayer()
    # Initial start is not a player switch and must retain its startup object.
    initial = two.games[0].rack.mem
    assert initial[0x2010:0x2012] == b'\x00\x80'
    # Simulate the working missile state after Player 2's previous turn.
    incoming = two.games[1].rack.mem
    incoming[0x2048:0x204A] = b'\x85\x1a'
    incoming[0x2058:0x205A] = b'\x8f\x1a'
    incoming[0x2032] = 0
    incoming[0x2080] = 2
    incoming[0x21FC:0x21FE] = b'\x79\x39'
    incoming[0x22FC:0x22FE] = b'\x77\x36'
    incoming[0x20F8:0x20FA] = b'\x12\x34'
    incoming[0x2500] = 0xA5
    two.active = 1
    outgoing = two.games[0].rack.mem
    outgoing[0x2008:0x200B] = b'\x02\x78\x38'
    two._begin_transition()
    assert bytes(incoming[0x2000:0x2067]) == bytes(incoming[0x1B00:0x1B67])
    assert bytes(incoming[0x2068:0x20C0]) == bytes(incoming[0x1B68:0x1BC0])
    assert incoming[0x2067] == 0x22  # ROM selects incoming bank after copy
    assert incoming[0x2048:0x204A] == b'\x80\x1a'
    assert incoming[0x2058:0x205A] == b'\x86\x1a'
    assert incoming[0x2032] == incoming[0x1B32]
    assert incoming[0x2080] == incoming[0x1B80]
    assert incoming[0x21FC:0x21FE] == b'\x79\x39'
    assert incoming[0x22FC:0x22FE] == b'\x77\x36'
    assert incoming[0x20F8:0x20FA] == b'\x12\x34'
    assert incoming[0x2500] == 0xA5
    assert outgoing[0x21FB:0x21FE] == b'\x02\x78\x38'
    assert two.transition['phase'] == 'wait'


if __name__ == '__main__':
    test_rom_mirror_handoff()
    print('PASS v20 ROM mirror and persistent player-state boundaries')
