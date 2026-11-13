"""ROM $13D2/$4410 bonus eligibility, BCD award, beams and rack continuation."""
from part2_first_play import Part2FirstPlay
from part2_rack_bonus import check_last_alien


def verify(index, alien_type, expected):
    p = Part2FirstPlay()
    for _ in range(180):
        p.step()
        if p.arrival.complete:
            break
    assert p.arrival.complete
    r = p.rack
    m = r.mem
    m[0x2100:0x2137] = bytes(55)
    m[0x2100 + index] = alien_type
    assert check_last_alien(r) == expected
    m[0x2100 + index] = 0
    m[0x200B], m[0x200C] = 0x28, 0x70
    oldscore = r.combat.score
    max_ink = 0
    for _ in range(600):
        p.step()
        if r.waves.phase == 'BONUS':
            max_ink = max(max_ink, sum(bool(v) for v in m[0x2904:0x3104]))
        if r.waves.completed:
            break
    assert r.waves.completed == 1
    assert r.combat.score == oldscore + expected // 10, (index, r.combat.score, oldscore)
    assert r.mem[0x21F9] == 1
    if expected:
        assert any(e[1] == f'PART2_RACK_BONUS_{expected}' for e in r.waves.events)
        assert max_ink > 0
    else:
        assert not any('BONUS' in e[1] for e in r.waves.events)
    print(f'PASS: survivor {index}, type {alien_type}, bonus {expected}')


def check():
    verify(0, 1, 1000)
    verify(5, 1, 800)
    verify(9, 1, 500)
    verify(11, 1, 500)
    verify(22, 5, 0)
    verify(6, 3, 0)


if __name__ == '__main__':
    check()
