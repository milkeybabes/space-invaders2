"""Part II Stage 04: player-shot classification paths from $121D-$12D8.

Run in Windows CMD: py part2_stage04_test.py
These are deterministic source-branch tests, not MAME synchronization tests.
"""
from rack import Rack


def fixture(y, *, part2=True, x=0x38, collision=True):
    r = Rack(part2=part2)
    r.enable_combat_demo()
    m = r.mem
    m[0x2025] = 2  # Player shot in normal movement
    m[0x2029] = y
    m[0x202A] = x
    m[0x2002] = int(collision)  # Actual collision flag set by shot-draw path
    return r


def check():
    # Short-circuit: without a pixel overlap, nothing is classified.
    r = fixture(0xCE, collision=False)
    r.combat.player_shot_hit()
    assert r.mem[0x2025] == 2 and r.mem[0x2085] == 0

    # $12D0 saucer collision: threshold $CE, status->4, hit flag $2085.
    r = fixture(0xCE)
    r.combat.player_shot_hit()
    assert r.mem[0x2085] == 1 and r.mem[0x2025] == 4
    assert r.mem[0x2002] == 0
    assert any(event == 'PART2_SAUCER_HIT' for _, event, _ in r.combat.events)

    # $1282 outside playfield: threshold $D8 takes precedence over saucer.
    r = fixture(0xD8)
    r.combat.player_shot_hit()
    assert r.mem[0x2025] == 3 and r.mem[0x2085] == 0

    # $12CA: the source compares the TOP of the rack ($78+$50=$C8)
    # against shot Y plus six. Shot $C2 -> $C8 does not set carry.
    r = fixture(0xC2)
    r.combat.player_shot_hit()
    assert r.mem[0x20AD] == 0

    # Shot $C3 -> adjusted $C9: carry, sets dropHit even if the rest
    # of the branch concludes this was not a normal alien.
    r = fixture(0xC3)
    r.combat.player_shot_hit()
    assert r.mem[0x20AD] == 1
    assert any(event == 'PART2_FALLING_ALIEN_HIT_FLAG' for _, event, _ in r.combat.events)

    # The original 1978 path must not use Part II's new drop flag.
    r = fixture(0xC3, part2=False)
    r.combat.player_shot_hit()
    assert r.mem[0x20AD] == 0

    # Existing working crab hit via actual main-loop collision routine.
    r = fixture(0x80)
    m = r.mem
    m[0x21F9] = 3  # round 3
    m[0x2100] = 3  # crab in bottom-left slot
    m[0x2101] = 1  # adjacent slot is overwritten by original code
    r.combat.player_shot_hit()
    assert m[0x2100:0x2102] == b'\x07\x07'
    assert m[0x2025] == 5 and m[0x2066] == 0x20
    assert (m[0x2062] | m[0x2063] << 8) == 0x1AE0

    # The diagnostic interrupt pair remains operational after branch work.
    r = Rack(part2=True)
    r.enable_combat_demo()
    for _ in range(20):
        r.step_frame()
    assert r.scheduler.mid_count == 20 and r.scheduler.end_count == 20

    print('PASS: Part II saucer / offscreen / falling alien shot branches,')
    print('      v1 isolation, live crab split handoff and 20 two-IRQ frames')


if __name__ == '__main__':
    check()
