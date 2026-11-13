"""Two-player native integration regression (not an ISR-cycle parity claim)."""
from part2_two_player import Part2TwoPlayer


def force_completed_death(game):
    rack = game.rack
    if not game.arrival.complete:
        for _ in range(300):
            if game.arrival.complete:
                break
            game.step()
    # Playable mode now preserves the ROM $0080 player-object startup timer.
    # A forced death must wait until the player handler is actually running.
    for _ in range(200):
        if rack.objects.player_draws:
            break
        game.step()
    assert rack.objects.player_draws, 'player object did not become active'
    rack.mem[0x2015] = 0
    rack.mem[0x2016] = 1
    rack.mem[0x2017] = 1


def main():
    both = Part2TwoPlayer(start_level=6)
    assert [g.rack.mem[0x2067] for g in both.games] == [0x21, 0x22]
    assert [g.rack.lives.stash for g in both.games] == [2, 2]
    assert all(g.rack.alive == 51 for g in both.games)
    for _ in range(650):
        if both.transition is None and both.games[0].arrival.complete:
            break
        both.step()
    assert both.transition is None and both.games[0].arrival.complete
    p1_frame = both.games[0].frame
    force_completed_death(both.games[0])
    for _ in range(20):
        both.step()
        if both.active == 1:break
    assert both.active == 1
    assert both.games[0].rack.lives.stash == 2
    assert both.games[1].rack.lives.stash == 2
    assert both.games[0].frame >= p1_frame
    p1_parked = both.games[0].frame
    for _ in range(650):both.step()
    assert both.games[0].frame == p1_parked
    assert both.transition is None and both.games[1].arrival.complete
    force_completed_death(both.games[1])
    for _ in range(20):
        both.step()
        if both.active == 0:break
    assert both.active == 0 and both.switch_count == 2
    assert both.games[1].rack.lives.stash == 2
    assert both.games[0].rack.lives.stash == 2
    # Distinct P1/P2 score fields must survive the handoff unchanged.
    a, b = both.games[0].rack.mem, both.games[1].rack.mem
    a[0x20F8:0x20FA] = b'\x45\x12'
    b[0x20FC:0x20FE] = b'\x67\x23'
    both._sync_scores()
    for m in (a,b):
        assert bytes(m[0x20F8:0x20FA]) == b'\x45\x12'
        assert bytes(m[0x20FC:0x20FE]) == b'\x67\x23'
    print('PASS Part II two-player independent banks, reserves, turn switch and BCD scores')

if __name__ == '__main__':main()
