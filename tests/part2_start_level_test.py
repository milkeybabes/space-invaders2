"""Check a later-level diagnostic starts at the ROM's formation and advances."""
from part2_first_play import Part2FirstPlay
from part2_rom import formation_for_round
from waves import START_HEIGHTS

def check():
    for level in (1, 2, 3, 4, 6, 8, 10, 17):
        p = Part2FirstPlay(start_level=level, debug=True)
        m = p.rack.mem
        assert p.round == level-1
        assert m[0x21F9] == level-1
        assert m[0x21FA] == level % 10
        assert m[0x21FE] == (level-1) & 7
        assert bytes(m[0x2100:0x2137]) == formation_for_round(level-1)
        expected_y = 0x78 if level == 1 else START_HEIGHTS[(level-2)&7]
        assert p.arrival.target_y == expected_y, (level,p.arrival.target_y,expected_y)
        assert p.rack.lives.life_decrement == 0
    for level in (1,4):
        p = Part2FirstPlay(start_level=level)
        for _ in range(250):
            if p.arrival.complete: break
            p.step()
        assert p.arrival.complete, level
        m = p.rack.mem
        m[0x20F8]=0x34
        m[0x2100:0x2137] = bytes(55)
        for _ in range(500):
            p.step()
            if p.rack.waves.completed: break
        assert p.rack.waves.completed == 1, ('wave transition',level)
        assert p.round == level
        assert bytes(m[0x2100:0x2137]) == formation_for_round(level)
        assert m[0x21F9] == level
    try: Part2FirstPlay(start_level=0)
    except ValueError: pass
    else: raise AssertionError('start level 0 accepted')
    print('PASS: start-level ROM formation, starting height, next-wave, normal/debug rules')

if __name__ == '__main__': check()
