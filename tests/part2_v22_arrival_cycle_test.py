"""v22: MAME-INP source-level rack-arrival and first-life phase regression."""
from part2_two_player import Part2TwoPlayer


def main():
    g = Part2TwoPlayer()
    snapshots = {}
    for frame in range(393, 1900):
        g.step()
        if frame in (592,593,594,599,606,635,677,678,679,680,735,736,845,856,986,1835,1836,1881,1891):
            m = g.games[0].rack.mem
            snapshots[frame] = (m[0x2006],m[0x2009],m[0x200A],m[0x20E9],m[0x2069],m[0x2035],m[0x2015])
    assert snapshots[592][0] == 1, snapshots[592]
    assert snapshots[593][0] == 9, snapshots[593]
    assert snapshots[594][0] == 17, snapshots[594]
    assert snapshots[599][1] == 0xA4, snapshots[599]
    assert snapshots[606][1] == 0xA0, snapshots[606]
    assert snapshots[677][1] == 0x78 and snapshots[677][3] == 0, snapshots[677]
    assert snapshots[679][3] == 0 and snapshots[680][3] == 1, snapshots
    assert snapshots[856][4] == 1, snapshots[856]
    assert snapshots[986][5] == 0x80, snapshots[986]
    assert snapshots[1835][2] == 0x30 and snapshots[1836][2] == 0x2E, snapshots
    assert snapshots[1881][6] == 0xFF and snapshots[1891][6] == 0, snapshots
    print('PASS v22: MAME arrival cursor/height, game enable=680, fire enable=856, first rolling=986')
    print('Outstanding: rack advance +1 at 1836 and first death +10 at 1891 vs MAME 1881')

if __name__ == '__main__':
    main()
