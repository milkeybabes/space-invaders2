"""Stage 10 rack arrival translation tests. Run: python part2_stage10_test.py"""
from rack import Rack
from part2_rack_arrive import Part2RackArrival
from part2_attract import Part2AttractPreview


def check():
    for count, delta in ((55,4), (25,2), (9,1)):
        r = Rack(part2=True)
        # A reduced-rack fixture preserves the 55-slot layout.
        for i in range(count,55):
            r.mem[0x2100+i] = 0
        r.mem[0x2009] = 0x78
        r.mem[0x200A] = 0x38
        original = bytes(r.mem[0x2000:0x2010])
        arrival = Part2RackArrival(r)
        assert arrival.step_size == delta
        assert r.mem[0x2300:0x2310] == original
        assert r.mem[0x2009] == r.mem[0x200B] == 0xA8
        assert r.mem[0x2008] == 0 and r.mem[0x200E] == ((-delta) & 255)
        assert r.mem[0x20B9] == 1 and r.mem[0x20E9] == 0
        for _ in range(8000):
            if arrival.advance():
                break
        else:
            raise AssertionError(f'arrival never landed: count={count}')
        assert arrival.complete
        assert arrival.history[0] == 0xA8
        assert arrival.history[-1] == 0x78
        assert all((b - a) % 256 == 256-delta for a,b in zip(arrival.history,arrival.history[1:])), arrival.history
        assert bytes(r.mem[0x2000:0x2010]) == original
        assert r.mem[0x20B9] == 0 and r.mem[0x20E9] == 1
        assert r.mem[0x2300:0x2310] == original
    # A different round's starting height must be taken from the saved
    # reference coordinate, never hardcoded to 0x78.
    r = Rack(part2=True)
    r.mem[0x2009] = 0x90
    a = Part2RackArrival(r)
    for _ in range(4000):
        if a.advance(): break
    assert a.complete and a.history[-1] == 0x90
    d = Part2AttractPreview()
    while d.phase != 'demo':d.step()
    assert d.phase == 'demo' and d.arrival is not None
    assert d.arrival.start_y == 0xA8
    assert d.rack.mem[0x20B9] == 1
    for _ in range(150):d.step()
    assert d.arrival.complete, 'autonomous preview never completed arrival'
    assert d.rack.scheduler.mid_count == d.rack.scheduler.end_count == 150
    print('PASS: $09CA original state save/restore, 4/2/1 pixel rack drops,')
    print('      variable target height, $20B9 ISR gate and live demo arrival')

if __name__ == '__main__':check()
