"""Ensure initial 2P launch performs ROM $0A73 prompt before rack arrival."""
from part2_two_player import Part2TwoPlayer


def main():
    two = Part2TwoPlayer()
    assert two.active == 0 and two.transition is not None
    assert two.transition['phase'] == 'wait' and two.transition['initial_start']
    assert not two.games[0].arrival.complete
    two.step()
    assert two.transition['phase'] == 'prompt', two.transition
    assert two.games[0].arrival.complete, 'prearrival descriptor was not saved'
    m = two.rack.mem
    assert any(m[0x2B11 + 32*i] for i in range(14*8)), 'PLAY PLAYER 1 missing'
    for _ in range(199):
        two.step()
    assert two.transition is None, 'prompt did not release gameplay'
    assert not two.games[0].arrival.complete, 'rack should slide in after prompt'
    for _ in range(400):
        two.step()
        if two.games[0].arrival.complete:
            break
    assert two.games[0].arrival.complete, 'P1 rack did not finish arrival'
    assert two.active == 0
    print('PASS Part II initial 2-player PLAY PLAYER 1 prompt and rack arrival')

if __name__ == '__main__':
    main()
