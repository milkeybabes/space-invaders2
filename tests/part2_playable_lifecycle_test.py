"""Part II playable integration checks: death, score, ROM preservation."""
from part2_first_play import Part2FirstPlay
from part2_rom import load_rom, formation_for_round


def check():
    p = Part2FirstPlay()
    r = p.rack
    rom, _ = load_rom()
    assert r.mem[0x1C70:0x1CB0] == rom[0x1C70:0x1CB0], 'Part II sprites overwritten by 1978 lives code'
    assert r.mem[0x1ED0:0x1F08] == rom[0x1ED0:0x1F08], 'Part II font overwritten'
    assert r.alive == 55 and len([v for v in formation_for_round(3) if v]) == 52
    while not p.arrival.complete:
        p.step()
    r.mem[0x2085] = 1
    r.mem[0x2086] = 0x19
    r.mem[0x2083] = 1
    r.mem[0x2080] = 2
    r.mem[0x2084] = 1
    # Select the ROM table entry worth 150 points for this focused graphic test.
    # Normal startup intentionally begins at $1D50, whose award is 100.
    r.mem[0x208D:0x208F] = bytes((0x54, 0x1D))
    position, _ = r.pixel_to_address(r.mem[0x2089], r.mem[0x208A])
    r.saucer._hit_sequence()
    assert r.saucer.awarded[-1] == 150
    assert r.mem[0x2087:0x2089] == bytes((0x96, 0x1D))
    assert r.mem[position] == rom[0x1E21 + rom[0x1D96] * 5], 'saucer score label not rendered' 
    r.combat.adjust_score()
    assert r.combat.score == 15, 'Combat.score is in tens; screen shows 150'
    assert r.mem[0x20F8] == 0x15
    for i in range(3):
        # Force the death object status in test only, not gameplay.
        r.mem[0x2010] = r.mem[0x2011] = 0
        r.mem[0x2015] = 0
        r.mem[0x2016] = r.mem[0x2017] = 1
        for _ in range(15):
            p.step()
        assert r.lives.deaths == i + 1
        if i < 2:
            assert not r.lives.game_over and not r.enemy_demo_halted
            assert r.mem[0x2015] == 0xFF
            assert r.mem[0x2018:0x201A] == rom[0x1B18:0x1B1A], 'respawn must restore Part II player sprite pointer'
            assert r.mem[0x2018:0x201A] == bytes((0x81, 0x1C))
    assert r.lives.game_over
    for _ in range(500):
        p.step()
    assert r.lives.game_over_sequence.phase == 'attract_pending'
    print('PASS: Part II sprite ROM preserved, saucer BCD score, three deaths, respawn, game-over handoff')

if __name__ == '__main__':
    check()
