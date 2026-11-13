"""Part II hardware red-screen regression: port $03 bit 2."""
from part2_colour import Part2Colour, W, H
from part2_first_play import Part2FirstPlay

def main():
    col = Part2Colour()
    lit = bytearray(W*H)
    lit[(H//2)*W+W//2] = 255
    normal = col.apply(lit)
    red = col.apply(lit, screen_red=True)
    p = ((H//2)*W+W//2)*3
    assert red[p:p+3] == bytes((255, 0, 0))
    assert red[:3] == bytes((0, 0, 0))
    assert normal[p:p+3] == col.maps[0][p:p+3]
    assert col.apply(lit) == normal
    g = Part2FirstPlay()
    # Allow intro rack arrival to settle, then force normal player-death
    # state to exercise the existing port-03 explosion-sound latch.
    for _ in range(100): g.step()
    assert not g.screen_red
    g.rack.mem[0x2015] = 0
    g.step()
    assert g.screen_red, "explosion must set red hardware control"
    for _ in range(250):
        g.step()
        if g.rack.lives.deaths:
            break
        assert g.screen_red, "screen-red must survive until explosion finishes"
    assert g.rack.lives.deaths, "death sequence never completed"
    assert not g.screen_red, "screen-red control must be released"
    print("PASS: Part II death drives port 03 red-screen and restores colours")

if __name__ == "__main__": main()
