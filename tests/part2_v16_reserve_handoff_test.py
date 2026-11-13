"""Regression: actual ordinary death sets deferred reserve removal before handoff."""
from part2_two_player import Part2TwoPlayer

def until(two, condition, limit=1200):
    for _ in range(limit):
        if condition():
            return
        two.step()
    raise AssertionError('expected transition did not occur')

def main():
    p = Part2TwoPlayer()
    until(p, lambda: p.transition is None and p.games[0].arrival.complete)
    p1 = p.games[0].rack
    assert p1.lives.stash == 2
    p1.mem[0x2015] = 0
    p1.mem[0x2016] = 1
    p1.mem[0x2017] = 1
    until(p, lambda: p.active == 1)
    assert p1.lives.pending_turn_reserve, 'actual player-death branch lost deferred removal'
    assert p1.lives.stash == 2, 'outgoing screen must retain reserves'
    until(p, lambda: p.transition is None and p.games[1].arrival.complete)
    p2 = p.games[1].rack
    p2.mem[0x2015] = 0
    p2.mem[0x2016] = 1
    p2.mem[0x2017] = 1
    until(p, lambda: p.active == 0)
    assert p2.lives.pending_turn_reserve
    assert p2.lives.stash == 2
    until(p, lambda: not p1.lives.pending_turn_reserve, 160)
    assert p1.lives.stash == 1
    assert p1.mem[0x21FF] == 1
    assert p2.lives.stash == 2, 'inactive player cannot lose reserve on P1 handoff'
    print('PASS v16: death flags both reserves; outgoing screen held; returning P1 drops 2->1')

if __name__ == '__main__':
    main()
