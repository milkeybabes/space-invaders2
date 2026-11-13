"""Stage 08 continuous attract-preview smoke test."""
from part2_attract import Part2AttractPreview, DEMO_ROM_START, DEMO_ROM_END

def check():
    d = Part2AttractPreview()
    assert d.phase == 'title'
    while d.phase == 'title': d.step()
    assert d.phase == 'score_table'
    while d.phase == 'score_table': d.step()
    assert d.phase == 'demo' and d.rack.part2
    assert d.rack.mem[0x21F9] == 0
    # The Part II startup RAM mirror supplies alienShotDelta=$FC.
    # A static screenshot and prior ISR tests did not catch a zero delta.
    assert d.rack.mem[0x207E] == d.rack.mem[0x1B7E] == 0xFC
    for _ in range(240): d.step()
    assert DEMO_ROM_START <= d.command_ptr < DEMO_ROM_END
    assert d.rack.scheduler.mid_count == d.rack.scheduler.end_count == 240
    # SHOT_MOVE events record the missile's ROM-coordinate Y after each
    # movement. Consecutive moves of a given missile must advance by the
    # ROM-specified signed delta ($FC => -4), not stay frozen at zero.
    moves = [e for e in d.rack.enemy_shots.events if e[1] == 'SHOT_MOVE']
    assert len(moves) >= 3, 'shots never moved'
    by_kind = {}
    for e in moves:
        by_kind.setdefault(e[2], []).append(e[3])
    assert any(((values[i + 1] - values[i]) & 255) == 0xFC
               for values in by_kind.values() for i in range(len(values)-1)), \
           'missile vertical position did not advance by ROM delta'
    # $0D1A/$0D2C: natural demo death, ROM timer/descriptor,
    # not a guessed AVI duration or forcibly injected player state.
    r = d.rack
    for _ in range(2500):
        if d.phase == 'insert_coin':
            break
        d.step()
    else:
        raise AssertionError('ROM-driven demo never completed its death')
    assert r.part2_demo_death.completed
    assert len([x for x in r.part2_demo_death.events if x[1]=='sprite']) == 11
    while d.phase == 'insert_coin': d.step()
    assert d.phase == 'title'
    while d.phase in ('title', 'score_table'): d.step()
    assert d.phase == 'demo' and d.rack.mem[0x21F9] == 3
    print('PASS: Stage 08 autonomous loop, Part II ROM commands, two interrupt phases, alternating formations')

if __name__ == '__main__': check()
