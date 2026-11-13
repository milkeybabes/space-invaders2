"""Stage 03 Part II live object and explosion tests; Windows: py part2_stage03_test.py.

Tests translate the source routines and their handoff state. They are NOT
MAME frame-perfect assertions or a complete playable Part II test.
"""
from rack import Rack
from part2_rom import load_rom
from part2_hits import apply_alien_hit


def new_rack():
    r = Rack(part2=True)
    r.enable_combat_demo()
    return r


def check():
    lo, extra = load_rom()
    r = new_rack()
    assert (r.mem[0x2013] | r.mem[0x2014] << 8) == 0x02D4
    assert (r.mem[0x2023] | r.mem[0x2024] << 8) == 0x0400
    assert 0x02D4 in r.objects.handlers and 0x0400 in r.objects.handlers
    assert 0x03BB not in r.objects.handlers  # not mistakenly v1 handler
    # Verify an actual dispatcher invocation of the Part II player shot.
    r.mem[0x2020:0x2023] = b'\x00\x00\x00'
    r.mem[0x2025] = 1
    r.mem[0x202A] = 0x30
    r.mem[0x2072] = 0
    r.objects.run(0x2020)
    assert r.mem[0x2025] == 2
    assert any(x[1] == 'SHOT_START' for x in r.combat.events)
    # The explosion image $1AE0 is 32 rows in the actual original ROM.
    r = new_rack()
    m = r.mem
    slot = 0x2104
    m[0x21F9] = 3
    m[slot:slot+2] = b'\x03\x05'
    hit = apply_alien_hit(m, slot)
    assert hit.split and hit.explosion_rom == 0x1AE0 and hit.explosion_size == 32
    x, y = 0x78, 0x60
    m[0x2064], m[0x2065] = x, y
    r.draw_shifted_sprite(x, y, hit.explosion_rom - 0x1C00, hit.explosion_size)
    before = r.video_ram().tobytes()
    assert before.count(0) < len(before)
    m[0x2002], m[0x2003], m[0x2025] = 1, 1, 5
    r.draw_alien()   # actual vblank draw path -> AExplodeTime -> EraseAlienExp
    assert m[0x2002] == 0 and m[0x2025] == 4
    after = r.video_ram().tobytes()
    # Reconstruct expected copy of the source $1330: DrawSprite 18 rows of
    # small aliens, next another 16 rows at already-advanced screen pointer.
    expected = new_rack()
    expected.mem[0x2400:0x4000] = before
    expected.draw_shifted_sprite(x, y, 0x31, 18)
    expected.draw_shifted_sprite(x, y + 18, 0x31, 16)
    assert after == expected.video_ram().tobytes()
    # Original $128A normal splat clears 18 rows *two bytes* (not 16).
    r = new_rack()
    m = r.mem
    x, y = 0x78, 0x60
    m[0x2064], m[0x2065] = x, y
    m[0x2062], m[0x2063] = 0xC2, 0x1C
    addr, _ = r.pixel_to_address(x, y)
    for row in range(20):
        m[addr + row * 32] = 0xFF
        m[addr + row * 32 + 1] = 0xFF
    m[0x2002], m[0x2003], m[0x2025] = 1, 1, 5
    r.draw_alien()
    for row in range(18):
        assert m[addr + row * 32:addr + row * 32 + 2] == b'\x00\x00'
    assert m[addr + 18 * 32:addr + 18 * 32 + 2] == b'\xff\xff'
    # Part II shot reset uses the genuine 1979 ROM mirror.
    r = new_rack()
    r.mem[0x2025] = 4
    r.combat.end_of_blowup()
    assert r.mem[0x2025:0x202C] == lo[0x1B25:0x1B2C]
    # Two-IRQ headless diagnostic remains operational with combat enabled.
    r = new_rack()
    for _ in range(20):
        r.step_frame()
    assert r.scheduler.mid_count == 20 and r.scheduler.end_count == 20
    print('PASS: Part II relocated object dispatch, shot call, 32-row crab split,')
    print('      18-row explosion cleanup, twin small sprites, original shot mirror,')
    print('      and 20-frame two-interrupt diagnostic')

if __name__ == '__main__':
    check()
