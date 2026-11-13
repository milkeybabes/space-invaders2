"""Stage milestone: real playable object schedule and Part II rack transitions."""
from part2_first_play import Part2FirstPlay
from part2_rom import formation_for_round, load_rom


def ready():
    p = Part2FirstPlay()
    for _ in range(200):
        if p.arrival.complete:
            return p
        p.step()
    raise AssertionError('initial rack arrival did not complete')


def check():
    p = ready()
    r = p.rack
    m = r.mem
    rom, _ = load_rom()
    assert r.waves_enabled and r.waves.phase == 'PLAY'
    # Saucer hit travels through the SAME collision and frame scheduler as
    # live play. The setup injects a known framebuffer collision, not a
    # scripted full saucer traversal (still unverified against MAME).
    m[0x2083] = m[0x2084] = 1
    m[0x2086] = 0x20
    m[0x208A] = 0x29
    m[0x2025] = 2
    m[0x2029] = 0xD0
    m[0x2002] = 1
    r.combat.player_shot_hit()
    assert m[0x2085] == 1
    before = r.combat.score
    for _ in range(200):
        p.step()
        if r.saucer.awarded:
            break
    else:
        raise AssertionError('saucer collided but never awarded any points')
    assert r.combat.score == before + (r.saucer.awarded[-1] // 10)
    assert ('SAUCER_SCORE_LABEL' in [e[1] for e in r.saucer.events])
    at, _ = r.pixel_to_address(m[0x2089], m[0x208A])
    actual = [m[at + 32*i] for i in range(24)]
    assert any(actual), 'score was calculated but text remained blank'
    assert m[0x2088] == 0x1D and m[0x2087] in (0x90, 0x93, 0x96, 0x99, 0xA8)
    assert m[at] == rom[0x1E21 + rom[0x1D00 + m[0x2087]] * 5]
    assert r.waves.completed == 0

    # Only fake the alien status array to isolate last-alien wave service;
    # the wait and actual Part II recreation must run on normal frames.
    m[0x20F8] = 0x34
    m[0x21FF] = 1
    m[0x2100:0x2137] = bytes(55)
    for _ in range(400):
        p.step()
        if r.waves.completed:
            break
    else:
        raise AssertionError('last alien clears but play remains frozen')
    assert r.waves.phase == 'PLAY'
    assert m[0x21F9] == 1 and p.round == 1
    assert bytes(m[0x2100:0x2137]) == formation_for_round(1)
    assert m[0x2018:0x201A] == bytes((0x81, 0x1C)), 'next wave restored a 1978 sprite'
    assert m[0x20F8] == 0x34 and m[0x21FF] == 1
    for _ in range(400):
        if p.arrival.complete:
            break
        p.step()
    assert p.arrival.complete, 'second formation never arrived'
    assert r.alive == sum(bool(v) for v in formation_for_round(1))
    print('PASS: scheduled saucer collision/points/visible ROM score; next Part II wave, lives and score retained')


if __name__ == '__main__':
    check()
