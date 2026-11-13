"""Regression: the resumed player's displayed reserve HUD matches its ROM stash.

v16 verified only $21FF/$22FF, permitting old pixels from the outgoing
player's copied VRAM to leave '3' displayed even though the stash was 1.
"""
from part2_two_player import Part2TwoPlayer
from rom_objects import PLAYER_SPRITE
from lives import HOLD_START, HOLD_PITCH


def until(two, condition, limit=1300):
    for _ in range(limit):
        if condition():
            return
        two.step()
    raise AssertionError('state not reached within frame limit')


def check_hud(rack):
    m = rack.mem
    reserve = rack.lives.stash
    code = 0x1C + reserve + 1
    for col in range(8):
        expected = m[0x1E21 + code * 5 + col] if col < 5 else 0
        assert m[0x2501 + 32 * col] == expected, (
            f'life numeral mismatch at col {col}, stash={reserve}')
    for slot in range(7):
        base = HOLD_START + slot * HOLD_PITCH
        for col in range(16):
            expected = PLAYER_SPRITE[col] if slot < reserve else 0
            assert m[base + col * 32] == expected, (
                f'reserve sprite mismatch at slot {slot}, col {col}, stash={reserve}')


def main():
    p = Part2TwoPlayer()
    until(p, lambda: p.transition is None and p.games[0].arrival.complete)
    p1 = p.games[0].rack
    assert p1.lives.stash == 2
    p1.mem[0x2015] = 0
    p1.mem[0x2016] = 1
    p1.mem[0x2017] = 1
    until(p, lambda: p.active == 1)
    assert p1.lives.stash == 2  # Not consumed during the other turn
    until(p, lambda: p.transition is None and p.games[1].arrival.complete)
    p2 = p.games[1].rack
    check_hud(p2)
    p2.mem[0x2015] = 0
    p2.mem[0x2016] = 1
    p2.mem[0x2017] = 1
    until(p, lambda: p.active == 0)
    until(p, lambda: p.transition is None)
    assert p1.lives.stash == 1
    check_hud(p1)  # 2 displayed, 1 reserve icon
    assert p2.lives.stash == 2
    print('PASS v17: live 2-player handoff draws updated ROM digit and reserve icons')


if __name__ == '__main__':
    main()
