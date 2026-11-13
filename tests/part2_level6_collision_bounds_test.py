"""Regression: a level-six shot must not treat other RAM as an alien slot."""
from part2_first_play import Part2FirstPlay
from part2_hits import apply_alien_hit


def check():
    game = Part2FirstPlay(start_level=6, debug=True)
    rack = game.rack
    m = rack.mem
    assert m[0x21F9] == 5
    # A hit outside the five rack rows can yield status index 55 (the
    # byte immediately after the alien bank). Real Part II RAM may hold a
    # nonzero value here: the previous build then raised ValueError.
    m[0x2067] = 0x21
    m[0x2009] = 0x18
    m[0x200A] = 0x30
    m[0x2025] = 2
    m[0x2029] = 0x70
    m[0x202A] = 0x31
    m[0x2002] = 1
    m[0x2137] = 3
    snapshot = bytes(m[0x2100:0x2138])
    rack.combat.player_shot_hit()
    assert m[0x2025] == 3, 'out-of-bank shot must end as non-alien collision'
    assert bytes(m[0x2100:0x2138]) == snapshot, 'non-alien hit changed status RAM'
    assert any(e[1] == 'PART2_SHOT_OUTSIDE_ALIEN_BANK' for e in rack.combat.events)

    # The original helper still rejects invalid slots if used incorrectly.
    try:
        apply_alien_hit(m, 0x2137)
    except ValueError:
        pass
    else:
        raise AssertionError('invalid alien slot accepted')

    # A legitimate split crab remains processed by the original Part II
    # hit routine; do not disable later-level splitting to mask this crash.
    m[0x2100] = 3
    hit = apply_alien_hit(m, 0x2100, round_number=5)
    assert hit.split and m[0x2100] == 7 and m[0x2101] == 7
    print('PASS: level-six out-of-bank collision handled; split-crab logic preserved')


if __name__ == '__main__':
    check()
