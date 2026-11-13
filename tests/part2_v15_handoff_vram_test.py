"""ROM $0373/$0907: two-player handoff uses ordered $0BA3 VRAM clears."""
from part2_two_player import Part2TwoPlayer


def until(two, predicate, limit=1200):
    for _ in range(limit):
        if predicate():
            return
        two.step()
    raise AssertionError('state was not reached')


def main():
    two = Part2TwoPlayer()
    # First start follows its established timing path, and must not inherit
    # the extra player-handoff clear (v6's frame check remains intact).
    until(two, lambda: two.transition is None and two.games[0].arrival.complete)
    p1 = two.rack
    p1.mem[0x2015] = 0
    p1.mem[0x2016] = 1
    p1.mem[0x2017] = 1
    until(two, lambda: two.active == 1)
    assert two.transition['phase'] == 'wait'
    until(two, lambda: two.transition['phase'] == 'clear_for_prompt', 140)
    incoming = two.rack.mem
    outgoing = two.games[0].rack.mem
    assert incoming[0x2400:0x4000] == outgoing[0x2400:0x4000], 'outgoing display not retained before ROM clear'
    assert two.transition['clear'].offset == 0
    two.step()
    assert two.transition['phase'] == 'clear_for_prompt', 'ROM clear finished in one Python frame'
    offset = two.transition['clear'].offset
    assert 0 < offset < 26 * 223, offset
    assert incoming[0x2402] == 0, 'first $0BA3 byte not erased'
    until(two, lambda: two.transition['phase'] == 'prompt', 20)
    until(two, lambda: two.transition['phase'] == 'clear_for_arrival', 220)
    two.step()
    assert two.transition['phase'] == 'clear_for_arrival', 'second $0BA3 also must take multiple frames'
    until(two, lambda: two.transition is None, 20)
    assert two.games[1].arrival is not None
    print('PASS v15: both handoff VRAM clears follow ordered $0BA3 writes; first start unchanged')


if __name__ == '__main__':
    main()
