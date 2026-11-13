"""Original ROM countdown and event-order tests (no MAME-derived seconds)."""
from part2_attract import Part2AttractPreview
from part2_attract_screens import Part2AttractScreen


def reach(d, name, limit=5000):
    for _ in range(limit):
        if d.phase == name:
            return
        d.step()
    raise AssertionError(f'never entered {name}: {d.status}')


def check():
    d = Part2AttractPreview()
    assert d.phase == 'title' and d.startup.stage == 'init_copy'
    for _ in range(18): d.step()
    assert not d.startup.done and d.title.index == 0
    d.step()
    assert d.startup.done and d.wait == 0x40
    for _ in range(63): d.step()
    assert d.title.index == 0, 'pre-title 64-tick wait omitted'
    d.step()
    assert d.title.index > 0, 'title must begin when ROM IRQ countdown expires'
    # FillDots is executed across foreground budgets, not instantly.
    while d.action == 0:
        d.step()
    assert d.title.index == d.title.stage_ends[0]
    assert d.wait == 0x40
    for _ in range(63): d.step()
    assert d.title.index == d.title.stage_ends[0]
    # $41A4 erases groups gradually, with $0EC9 DelayBC($0250) after
    # each three-byte erasure. The bitmap must NOT materialize instantly.
    d.step()
    assert d.action == 1 and d.title.index < d.title.stage_ends[1]
    assert d.title.index > d.title.stage_ends[0]
    first_carve_start = d.frame
    while d.action == 1:
        d.step()
    assert d.frame - first_carve_start > 1
    assert d.title.index == d.title.stage_ends[1]
    # The same source-level slow reveal also applies to INVADERS.
    while d.action < 3:
        d.step()
    while d.wait:
        d.step()
    assert d.action == 3 and d.title.index < d.title.stage_ends[3]
    assert d.title.index > d.title.stage_ends[2]
    reach(d, 'score_table')
    assert d.title.index == len(d.title.ops)
    assert d.screen.finish_tick == 5 * 11 * 6
    assert len(d.screen.events) == 62
    start = d.frame
    for _ in range(329): d.step()
    assert d.phase == 'score_table' and not d.screen.complete
    d.step()
    assert d.screen.complete and d.screen.next_event == len(d.screen.events)
    reach(d, 'demo')
    assert d.frame - start >= 330 + 64
    assert d.rack.mem[0x21F9] == 0
    # $0D1A/$0D2C: wait for a REAL missile hit, twelve ROM-timed
    # death-image intervals, descriptor restore, and return to attract.
    # No forced $2015 values and no AVI-derived demo timeout.
    demo_rack = d.rack
    reach(d, 'insert_coin', limit=2500)
    assert demo_rack.part2_demo_death.completed
    events = demo_rack.part2_demo_death.events
    sprites = [e for e in events if e[1] == 'sprite']
    assert len(sprites) == 11 and events[-1][1] == 'complete', events
    assert all(b[0] - a[0] == 5 for a,b in zip(events,events[1:])), events
    assert not demo_rack.enemy_demo_halted
    assert demo_rack.mem[0x2010:0x2020] == demo_rack.mem[0x1B10:0x1B20]
    assert d.phase == 'insert_coin' and d.coin_foreground.stage == 'one_sec'
    for _ in range(64): d.step()
    assert d.coin_foreground.stage == 'one_sec'
    assert not d.coin_foreground.complete
    d.step()
    assert d.phase == 'insert_coin' and not d.screen.complete
    reach(d, 'title', limit=1600)
    assert d.startup.stage == 'clear_splash'
    reach(d, 'demo')
    assert d.rack.mem[0x21F9] == 3
    print('PASS: ROM $40/$80 waits, $07->01 per printed character, title call order,')
    print('      PlayerHitChk-driven demo exit, and alternating ROM formations')

if __name__ == '__main__':
    check()
