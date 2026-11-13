"""Run: python part2_first_play_test.py"""
from part2_first_play import Part2FirstPlay

def check():
    p = Part2FirstPlay()
    assert p.rack.part2 and p.rack.mem[0x20EF] == 1
    assert p.rack.shields_enabled and p.rack.enemy_shots_enabled
    for i in range(1200):
        p.step(left=(i//90)%2 == 0, right=(i//90)%2 == 1, fire=i%13<5)
    assert p.arrival.complete
    assert p.rack.combat.shots_fired > 0
    assert p.rack.alive < 55, 'shots must be able to destroy aliens'
    assert len(p.image()) == 224*256
    print('PASS: native Part II first playable controls, firing, kills and shield setup')

if __name__ == '__main__': check()
