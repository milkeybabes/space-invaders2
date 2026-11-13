"""Debug ships never run out; normal mode continues to consume them."""
from part2_first_play import Part2FirstPlay
from part2_rom import load_rom

def check():
    debug = Part2FirstPlay(debug=True)
    normal = Part2FirstPlay()
    assert debug.rack.lives.life_decrement == 0
    assert normal.rack.lives.life_decrement == 1
    rom, _ = load_rom()
    for game in (debug, normal):
        while not game.arrival.complete:
            game.step()
    initial = debug.rack.lives.stash
    for i in range(5):
        r = debug.rack
        r.mem[0x2010] = r.mem[0x2011] = 0
        r.mem[0x2015] = 0
        r.mem[0x2016] = r.mem[0x2017] = 1
        for _ in range(15): game_step(debug)
        assert r.lives.deaths == i+1
        assert not r.lives.game_over
        assert r.lives.stash == initial
        assert r.mem[0x2015] == 0xFF
        assert r.mem[0x2018:0x201A] == bytes((0x81, 0x1C))
    r = normal.rack
    r.mem[0x2010] = r.mem[0x2011] = 0
    r.mem[0x2015] = 0
    r.mem[0x2016] = r.mem[0x2017] = 1
    for _ in range(15): normal.step()
    assert r.lives.stash == initial-1
    assert not r.lives.game_over
    print('PASS: debug unlimited lives, original death animation and Part II respawn, normal stock decrement')

def game_step(game):
    game.step()

if __name__ == '__main__': check()
