"""Part II invaded flag $206D, forced game-over, and lossless F12 names."""
from tempfile import TemporaryDirectory
from pathlib import Path
from part2_first_play import Part2FirstPlay
from part2_play import unique_screenshot_path


def check():
    for debug in (False, True):
        game = Part2FirstPlay(debug=debug)
        for _ in range(200):
            if game.arrival.complete:
                break
            game.step()
        assert game.arrival.complete
        rack = game.rack
        stash_before = rack.lives.stash
        assert stash_before > 0
        # Choose an actual live alien from the original Part II bank and
        # place it exactly at the ROM check threshold: x=$27 vs $28.
        rack.mem[0x2000] = 0
        rack.mem[0x2068] = 1
        rack.mem[0x2006] = 0
        rack.mem[0x2009] = 0x27
        rack.cursor_next_alien()
        assert rack.mem[0x206D] == 1, 'ROM invaded flag was not raised'
        assert rack.lives.events[-1][1] == 'ALIENS_INVADE'
        assert rack.mem[0x2015] == 0
        for _ in range(250):
            game.step()
            if rack.lives.game_over:
                break
        assert rack.lives.game_over, 'invasion left the game playing'
        assert rack.mem[0x21FF] == 0, 'invasion must erase remaining reserves'
        assert rack.lives.respawns == 0, 'invasion must not respawn'
        assert rack.waves.completed == 0, 'invasion must not advance wave'
        assert rack.lives.game_over_sequence.phase != 'inactive'
    # $28 is the safe boundary; this should never trigger an invasion.
    game = Part2FirstPlay()
    for _ in range(200):
        if game.arrival.complete:
            break
        game.step()
    rack = game.rack
    rack.mem[0x2000] = 0
    rack.mem[0x2068] = 1
    rack.mem[0x2006] = 0
    rack.mem[0x2009] = 0x28
    rack.cursor_next_alien()
    assert rack.mem[0x206D] == 0
    with TemporaryDirectory() as temp:
        directory = Path(temp)
        a = unique_screenshot_path(directory, 123)
        a.write_bytes(b'older screenshot')
        b = unique_screenshot_path(directory, 123)
        assert a != b
        b.write_bytes(b'new screenshot')
        assert a.read_bytes() == b'older screenshot'
        assert unique_screenshot_path(directory, 124).name.startswith('part2_frame_0000124')
    print('PASS: Part II invasion game over (normal+debug), boundary, no wave/respawn, unique F12 PNG')


if __name__ == '__main__':
    check()
