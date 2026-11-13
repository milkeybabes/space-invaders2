"""Regression for $09CA -> $1719 DrawScores restoration after rack arrival.
Run: python part2_stage10_score_hotfix_test.py
"""
from rack import Rack
from part2_rack_arrive import Part2RackArrival
from part2_display import Part2ScoreDisplay
from part2_attract import Part2AttractPreview


def score_positions(r):
    m = r.mem
    # The glyph columns in each five-digit field and the complete headings
    # are checked; this does not assume all other VRAM is untouched.
    positions = set()
    for base in (0x20F4, 0x20F8, 0x20FC):
        addr = m[base + 2] | (m[base + 3] << 8)
        for digit in range(5):
            for column in range(8):
                a = addr + digit * 0x100 + column * 32
                if 0x2400 <= a < 0x4000:
                    positions.add(a)
    for start, n in ((0x241E, 28), (0x2E1E, 8)):
        for digit in range(n):
            for column in range(8):
                a = start + digit * 0x100 + column * 32
                if 0x2400 <= a < 0x4000:
                    positions.add(a)
    return sorted(positions)


def check():
    r = Rack(part2=True)
    r.enable_part2_enemy_shots_diagnostic()
    assert isinstance(r.score_display, Part2ScoreDisplay)
    m = r.mem
    fields = score_positions(r)
    # Obtain expected ROM-font output by repainting the unmodified scoreboard.
    r.score_display.redraw_scores()
    expected = bytes(m[a] for a in fields)
    arrival = Part2RackArrival(r)
    # Simulate scoreboard damage while the rack moves across the display.
    for a in fields:
        m[a] = 0xFF
    for _ in range(8000):
        if arrival.advance():
            break
    assert arrival.complete, 'rack never reached target'
    assert bytes(m[a] for a in fields) == expected, 'scoreboard not redrawn after rack arrival'
    # Also exercise the real autonomous preview wiring, not only a naked rack.
    demo = Part2AttractPreview()
    while demo.phase != 'demo':
        demo.step()
    assert demo.phase == 'demo'
    for _ in range(170):
        demo.step()
    assert demo.arrival.complete
    assert demo.rack.score_display.initialised
    print('PASS: Stage 10 $09CA rack-arrival restores the Part II scoreboard,')
    print('      all five-digit fields and headings after framebuffer damage')


if __name__ == '__main__':
    check()
