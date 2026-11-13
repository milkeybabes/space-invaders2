"""Regression for first/normal Part II saucer awards becoming zero after shots.
Run: python part2_saucer_score_pointer_test.py
"""
from rack import Rack
from part2_rom import load_rom


def check():
    rom, _ = load_rom()
    r = Rack(part2=True)
    r.enable_combat_demo()
    m = r.mem
    assert m[0x208D:0x208F] == rom[0x1B8D:0x1B8F] == b'\x50\x1d'
    assert m[0x1D50:0x1D60] == rom[0x1D50:0x1D60]
    # The 8080 increments only the low byte after each player shot ends.
    # ROM wraps at $1D5F => $1D50; $1D5F itself is never awarded.
    observed = []
    for _ in range(60):
        ptr = m[0x208D] | m[0x208E] << 8
        assert 0x1D50 <= ptr <= 0x1D5E, hex(ptr)
        assert m[ptr] in (0x05, 0x10, 0x15, 0x30), (hex(ptr), hex(m[ptr]))
        observed.append(ptr)
        r.combat.end_of_blowup()
    assert observed[:15] == list(range(0x1D50, 0x1D5F)), observed[:15]
    assert observed[15:30] == observed[:15]

    # The real saucer scoring transition, not just a table lookup.
    # Test the first saucer with each legal pointer, including the wrap.
    for off in range(0x50, 0x5F):
        x = Rack(part2=True)
        x.enable_part2_saucer_live_diagnostic()
        a = x.mem
        a[0x20EF] = 1
        a[0x208D], a[0x208E] = off, 0x1D
        a[0x2083] = a[0x2084] = a[0x2085] = 1
        a[0x20BC] = 1
        a[0x2086] = 0x19
        x.saucer._hit_sequence()
        expected = ((rom[0x1D00 + off] >> 4) * 10 + (rom[0x1D00 + off] & 15)) * 10
        assert x.saucer.awarded == [expected] and expected > 0, (off, x.saucer.awarded)
        assert any(e[1] == 'SAUCER_SCORE_LABEL' for e in x.saucer.events)
    print('PASS: authentic $1D50-$1D5E 15-value shot pointer cycle, no zero awards, first-saucer labels')


if __name__ == '__main__':
    check()
