"""Stage 09 ROM glyph/score/shield checks. Run: python part2_stage09_test.py"""
from rack import Rack
from part2_rom import load_rom
from part2_display import Part2ScoreDisplay, Part2Shields, FONT
from part2_attract import Part2AttractPreview


def check():
    rom, _ = load_rom()
    r = Rack(part2=True)
    r.enable_part2_enemy_shots_diagnostic()
    m = r.mem
    assert isinstance(r.score_display, Part2ScoreDisplay)
    assert m[0x1E21:0x1E21+80] == rom[0x1E21:0x1E21+80], 'ROM font overwritten'
    # Part II characters are 5 bytes plus 3 explicit zeroes.
    addr=0x3210
    assert r.score_display.draw_char(0x1C,addr) == addr+0x100
    assert [m[addr+32*i] for i in range(8)] == list(rom[FONT+0x1c*5:FONT+0x1c*5+5])+[0,0,0]
    # $107A writes one more '0' than the 1978 four-digit routine.
    m[0x20F8:0x20FC]=bytes((0x02,0x00,0x1C,0x27))
    r.score_display.draw_score(0x20F8)
    assert [m[0x271c+0x100*i] for i in range(5)] == [rom[FONT+0x1c*5]]*3 + [rom[FONT+0x1e*5],rom[FONT+0x1c*5]]
    # The first shield exactly matches the 1979 shield bitmap before carving.
    s=Rack(part2=True);sh=Part2Shields(s);mm=s.mem
    mm[0x21FA]=1
    sh.init_playfield()
    assert mm[0x2806] == rom[0x1D1C]
    for shield in range(4):
        for col in range(5):
            a=0x2927+shield*0x5A0+col*32
            glyph=rom[FONT+(0x1c+1)*5+col]
            assert mm[a] & glyph == 0, 'round number not carved into shield'
    d=Part2AttractPreview()
    while d.phase != 'demo':d.step()
    assert d.phase == 'demo' and d.rack.shields_enabled
    assert isinstance(d.rack.score_display,Part2ScoreDisplay)
    for _ in range(60):d.step()
    assert d.rack.scheduler.mid_count==d.rack.scheduler.end_count==60
    print('PASS: Part II 5-byte ROM font, 5-digit score, four shields,')
    print('      round-number pixel carving and 60 live preview IRQ pairs')

if __name__=='__main__':check()
