"""Regression: Part II GAME OVER ROM glyphs and moving saucer alien VRAM."""
from rack import Rack
from part2_rom import load_rom


def check():
    rom, _ = load_rom()
    r = Rack(part2=True)
    r.enable_lives_demo()
    assert rom[0x1824:0x182E] == bytes.fromhex('06 00 0C 04 1B 0E 15 04 11 1B')
    assert rom[0x1E21+0x1b*5:0x1E21+0x1b*5+5] == bytes(5)
    assert any(rom[0x1E21+0x26*5:0x1E21+0x26*5+5])
    g=r.lives.game_over_sequence
    g.begin()
    assert g.phase=='message'
    for _ in range(80):
        g.step_frame()
    # The two gaps after GAME and OVER must be blank, not '<'.
    for idx in (4,9):
        address=(0x2D18+idx*0x100) & 0xffff
        assert all(r.mem[address+32*i] == 0 for i in range(8)),idx

    d=Rack(part2=True)
    d.enable_part2_drop_diagnostic()
    m=d.mem
    m[0x20A1]=1
    m[0x20A2]=0xFE
    m[0x20A3]=0
    m[0x20A4]=0x90
    m[0x20A5]=0x70
    m[0x20A8]=8
    m[0x20A6]=0x25
    m[0x20A7]=0x1C
    drop=d.part2_drop
    drop.end_screen()
    old=drop.last_drawn
    assert old is not None
    oldaddr,_=d.pixel_to_address(*old[:2])
    assert any(m[oldaddr+32*i] for i in range(8))
    drop.end_screen()
    new=drop.last_drawn
    assert new is not None and new[:2] != old[:2]
    # The topmost two old pixel rows are no longer within the new sprite.
    # Check exact bytes that have fallen outside the new shifted extent.
    newaddr,_=d.pixel_to_address(*new[:2])
    assert old[0] != new[0]  # moved two pixels within the same VRAM byte
    shift=new[0]&7
    for i in range(8):
        value=rom[0x1C25+i]
        at=newaddr+32*i
        assert m[at] == ((value << shift) & 255)
        assert m[at+1] == ((value >> (8-shift)) if shift else 0)
    drop.reset_drop()
    assert drop.last_drawn is None
    assert not any(m[newaddr+32*i] or m[newaddr+32*i+1] for i in range(8))
    print('PASS: Part II GAME OVER ROM spaces and falling alien erasure')

if __name__=='__main__': check()
