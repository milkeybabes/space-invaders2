"""MAME INP initial 2P start: approximate screen sequencing regression.

Frame indices follow the input replay's zero-based numbering; start2 at 393.
This checks ROM-derived state operations, not full pixel parity with MAME.
"""
from part2_two_player import Part2TwoPlayer


def main():
    game = Part2TwoPlayer()
    snapshots = {}
    for frame in range(393, 595):
        game.step()
        if frame in (574, 592, 593, 594):
            snapshots[frame] = (
                game.transition['phase'] if game.transition else None,
                game.games[0].arrival.iterations,
                game.rack.last_drawn,
            )
    assert snapshots[574][0] == 'prompt' and snapshots[574][1] == 0, snapshots
    # v22: the first two $09FA operations execute in the remaining
    # foreground portion of frame 592. MAME's RAM has index 01 then,
    # followed by 09 at 593 and 11 at 594.
    assert snapshots[592][0] is None and snapshots[592][1] == 2 and snapshots[592][2] == 1, snapshots
    assert snapshots[593][1] == 10 and snapshots[593][2] == 9, snapshots
    assert snapshots[594][1] == 18 and snapshots[594][2] == 17, snapshots
    print('PASS $09CA initial start: 574 prompt; 592 cursor 1; 593 cursor 9; 594 cursor 17')


if __name__ == '__main__':
    main()
