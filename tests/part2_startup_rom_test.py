"""ROM $168F/$17DA power-on VRAM/timing regression, not AVI-derived logic."""
from part2_attract import Part2AttractPreview
from part2_startup import CYCLES_PER_FRAME, VRAM_SIZE, startup_status_cycles


def check():
    p = Part2AttractPreview()
    assert p.startup.stage == 'init_copy'
    assert p.startup.status_cycles == startup_status_cycles(p.title.mem)
    assert (2 * (VRAM_SIZE * 37 - 3 + 10)) / CYCLES_PER_FRAME > 15.0
    for frame in range(1, 84):
        p.step()
        if frame == 9:
            assert p.startup.stage == 'draw_status'
        if frame == 11:
            assert p.startup.stage == 'clear_splash'
            # Header and credits written by ROM algorithms between clears.
            assert p.title.mem[0x3501] != 0
            assert p.title.mem[0x3c01] != 0
            # Default high-score name appears over the HI-SCORE header.
            assert any(p.title.mem[a] for a in range(0x2d1e, 0x3300, 32))
        if frame == 19:
            assert p.startup.done and p.wait == 0x40
            assert not any(p.title.mem[0x2400:0x4000])
        if frame < 83:
            assert p.title.index == 0
    assert p.frame == 83 and p.title.index > 0
    # A later attract cycle must NOT execute the cold-boot init/status routine.
    p._set_phase('title')
    assert p.startup.stage == 'clear_splash'
    for _ in range(8): p.step()
    assert p.startup.done and p.wait == 0x40
    print('PASS: 8080 two $17DA screen clears, initial status display, 64-tick wait, title first draw')


if __name__ == '__main__':
    check()
