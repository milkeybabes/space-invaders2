"""Part II ROM $0336/$0A73/$092E player-change presentation regression."""
from part2_two_player import Part2TwoPlayer
from part2_display import SHIELD_START


def advance_until(two, predicate, maximum=1200):
    for _ in range(maximum):
        if predicate():
            return
        two.step()
    raise AssertionError('two-player transition failed to reach expected state')


def kill_current(two):
    advance_until(two, lambda: two.transition is None and two.games[two.active].arrival.complete)
    active = two.active
    r = two.rack
    r.mem[0x2015] = 0
    r.mem[0x2016] = 1
    r.mem[0x2017] = 1
    advance_until(two, lambda: two.active != active, 130)
    assert two.transition is not None


def main():
    two = Part2TwoPlayer(start_level=6)
    # Check that a previously shot alien remains absent when its owner
    # returns after the other player loses a ship.
    advance_until(two, lambda: two.transition is None and two.games[0].arrival.complete)
    p1 = two.games[0].rack
    status_addr = 0x2100 + 5
    assert p1.mem[status_addr] != 0
    p1.mem[status_addr] = 0
    old_shield = p1.mem[SHIELD_START + 32 * 9]
    p1.mem[SHIELD_START + 32 * 9] = old_shield & 0xEE
    damaged = p1.mem[SHIELD_START + 32 * 9]
    kill_current(two)
    assert two.active == 1
    assert two.transition['phase'] == 'wait'
    advance_until(two, lambda: two.transition['phase'] == 'prompt', 140)
    msg = two.rack.mem
    # Score flashing must be visible while the player prompt is on screen.
    assert any(msg[0x2B11 + 32*i] for i in range(14*8))
    advance_until(two, lambda: two.transition is None and two.games[1].arrival.complete)
    kill_current(two)
    assert two.active == 0
    advance_until(two, lambda: two.transition is None and two.games[0].arrival.complete)
    assert p1.mem[status_addr] == 0, 'destroyed alien resurrected on player switch'
    assert p1.mem[SHIELD_START + 32 * 9] == damaged, 'shield damage lost on player switch'
    assert p1.mem[0x20E9] == 1 and p1.mem[0x2068] == 1
    assert p1.mem[0x2009] != 0xA8, 'rack arrival never moved down'
    print('PASS Part II player-change ROM prompt, resumed rack arrival, alien holes and shield preservation')

if __name__ == '__main__':
    main()
