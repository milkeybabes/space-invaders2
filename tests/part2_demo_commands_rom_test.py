"""Part II $1438 demo firing/command pointer -> $03A6 player movement."""
from part2_attract import Part2AttractPreview


def check():
    d = Part2AttractPreview()
    while d.phase != 'demo':
        d.step()
    r = d.rack
    assert (r.mem[0x20ED], r.mem[0x20EE]) == (0xBF, 0x1A)
    assert r.mem[0x201D] == 1   # ROM mirror, before next command
    while not d.arrival.complete:
        d.step()
    commands = []
    left_seen = False
    neutral_seen = False
    for _ in range(600):
        prev_ptr = r.mem[0x20ED]
        previous_x = r.mem[0x201B]
        d.step()
        command = r.mem[0x201D]
        if r.mem[0x20ED] != prev_ptr:
            commands.append(command)
            assert command == r.mem[0x1A00 + r.mem[0x20ED]]
        if command == 2 and r.mem[0x2015] == 0xFF and r.mem[0x201B] < previous_x:
            left_seen = True
        if command == 0 and r.mem[0x2015] == 0xFF and r.mem[0x201B] == previous_x:
            neutral_seen = True
        if left_seen and neutral_seen and len(commands) >= 7:
            break
    assert commands[:7] == [1, 0, 0, 1, 0, 2, 1], commands
    assert left_seen, 'ROM command 02 never moved player left'
    assert neutral_seen, 'ROM command 00 never stopped player'
    assert r.combat.shots_fired >= 7, 'ROM demo branch did not fire shots'
    print('PASS: ROM $1438 command/firing sequence updates $201D and actual player movement')


if __name__ == '__main__':
    check()
