"""Regression: two-player final-life message must print before switching."""
from part2_two_player import Part2TwoPlayer


def main():
    p = Part2TwoPlayer()
    p.transition = None
    p.games[0].arrival.complete = True
    r = p.rack
    # Simulate the state at the end of the original player explosion.
    r.mem[r.lives.stash_address] = 0
    r.lives.game_over = True
    r.lives.deaths += 1
    r.lives.game_over_sequence.begin()
    p.step()
    assert p.active == 0 and p.done[0], 'final-life event switched before printing message'
    assert r.lives.game_over_sequence.phase == 'multi_message'
    for _ in range(150):
        p.step()
    assert p.active == 0, 'switched player before ROM game-over hold'
    assert r.lives.game_over_sequence.phase in ('multi_letter_wait', 'multi_hold')
    assert any(r.mem[0x2803 + 0x100 * i + 32 * j]
               for i in range(20) for j in range(5)), 'no GAME OVER text in VRAM'
    for _ in range(125):
        if p.active == 1:
            break
        p.step()
    assert p.active == 1 and p.transition is not None, 'did not hand off after message hold'
    # P2's final-life path must not assume P1 is still alive in its own RAM.
    p.transition = None
    p.games[1].arrival.complete = True
    r2 = p.rack
    r2.mem[r2.lives.stash_address] = 0
    r2.lives.game_over = True
    r2.lives.deaths += 1
    r2.lives.game_over_sequence.begin()
    p.step()
    assert p.done == [True, True]
    assert not r2.mem[0x20E7] and not r2.mem[0x20E8]
    assert p.active == 1 and not p.finished
    for _ in range(550):
        if p.finished:
            break
        p.step()
    assert p.finished, 'final game should return to title after both messages'
    print('PASS v10: held GAME OVER PLAYER message, delayed handoff, both-player ending')


if __name__ == '__main__':
    main()
