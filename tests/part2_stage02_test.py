"""Windows Command Prompt: py part2_stage02_test.py"""
from rack import Rack
from part2_rom import load_rom
from part2_hits import apply_alien_hit, legal_column
from combat import Combat


def check():
    base, extra = load_rom()
    assert legal_column(1) and legal_column(11)
    assert not legal_column(12) and not legal_column(0)
    for status, points in ((1,1),(3,2),(5,3),(7,3)):
        r = Rack(part2=True)
        r.mem[0x2104] = status
        r.mem[0x21F9] = 2
        x = apply_alien_hit(r.mem, 0x2104)
        assert (x.status,x.bcd_points,x.split)==(status,points,False)
        assert r.mem[0x2104] == 0
        assert r.mem[0x20DB] == status
        assert (r.mem[0x2062]|(r.mem[0x2063]<<8)) == 0x1CC2
        assert r.mem[0x20F2] == points and r.mem[0x20F1] == 1
    r = Rack(part2=True)
    r.mem[0x21F9] = 3
    r.mem[0x2104] = 3
    r.mem[0x2105] = 5  # occupied neighbour overwritten in authentic routine
    x=apply_alien_hit(r.mem,0x2104)
    assert x.split and r.mem[0x2104:0x2106]==bytes([7,7])
    assert (r.mem[0x2062]|(r.mem[0x2063]<<8)) == 0x1AE0
    assert r.mem[0x2066]==32 and r.mem[0x20F2]==2
    r=Rack(part2=True)
    r.mem[0x20EF]=0  # attract: no score adjustment
    r.mem[0x2104]=1
    apply_alien_hit(r.mem,0x2104)
    assert r.mem[0x20F1]==0
    # Source fixtures: keep v2 sprite and object mirror intact when enabling combat.
    r=Rack(part2=True)
    r.enable_combat_demo()
    expected = bytearray(base[0x1B10:0x1B70]); expected[1] = 0  # diagnostic immediate-player shortcut
    assert r.mem[0x2010:0x2070] == expected
    assert r.mem[0x1C90:0x1CD0]==base[0x1C90:0x1CD0]
    assert r.mem[0x2000:0x2010]==base[0x1B00:0x1B10]
    print('PASS: v2 source ROM mirror, 4 alien scores, crab split, occupied adjacent slot,')
    print('      no-score demo, explosion descriptor, fixed column boundary')

if __name__=='__main__':
    check()
