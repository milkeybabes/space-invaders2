"""Part II v2 Stage 01: headless tests and frame snapshots, no pygame needed.

Windows CMD: py part2_diagnostic.py
"""
from pathlib import Path
from rack import Rack
from part2_rom import load_rom, formation_for_round, sprite_rom_address, sprite_bytes, install_formation
from main import save_native_png


def check():
    lo, hi = load_rom()
    assert lo[0x1E10:0x1E13] == bytes([0, 0, 0])
    for i in range(17):
        flags = formation_for_round(i, lo, hi)
        assert len(flags) == 55 and set(flags) <= {0,1,3,5,7}
        assert flags[-11:] == bytes([5])*11
    assert formation_for_round(16, lo, hi) == formation_for_round(8, lo, hi)
    assert len({formation_for_round(i, lo, hi) for i in range(16)}) == 5
    for frame in (0,1):
        for status in (1,3,5,7):
            a = sprite_rom_address(status,frame)
            assert len(sprite_bytes(status,frame,lo)) == 16
            assert sprite_bytes(status,frame,lo) == lo[a:a+16]
    r = Rack(part2=True)
    assert r.alive == 55
    assert r.mem[0x2100:0x2137] == formation_for_round(0, lo, hi)
    # Call the existing v1 cursor and framebuffer renderer with Part II data.
    for _ in range(100):
        r.step_frame()
    assert r.frames == 100
    folder = Path(__file__).resolve().parent / 'diagnostics'
    save_native_png(folder/'part2_first_100_frames.png',r)
    install_formation(r,7)
    assert r.mem[0x2100:0x2137] == formation_for_round(7, lo, hi)
    print('PASS: five formations, 17 round indices, 8 sprite states,\n'
          '      ROM-based alien flags, 100 frame v2 rack diagnostic')
    print('Screenshot:',folder/'part2_first_100_frames.png')

if __name__=='__main__':
    check()
