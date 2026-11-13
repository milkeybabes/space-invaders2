"""Part II Stage 06 saucer lifecycle tests: Windows CMD python part2_stage06_test.py"""
from rack import Rack
from part2_rom import load_rom

def fixture(round_num=2):
    r = Rack(part2=True)
    r.enable_part2_saucer_live_diagnostic()
    m = r.mem
    m[0x21F9] = round_num
    m[0x2080] = 2
    m[0x2083] = 1
    m[0x2082] = 40
    m[0x2072] = 0
    return r

def check():
    rom,_ = load_rom()
    r = fixture();m=r.mem
    assert m[0x2084:0x208D] == rom[0x1B84:0x1B8D]
    m[0x2083] = 1
    assert r.saucer.handler(0x2050) == 'SAUCER_MOVE'
    assert m[0x20BC] == 1 and m[0x2084] == 1
    assert any(e[1] == 'SAUCER_APPEARED' for e in r.saucer.events)
    # Correct source-driven pause when alien is descending.
    m[0x20A1] = 1
    x=m[0x208A]
    assert r.saucer.handler(0x2050) == 'SAUCER_HOVER_DROP' and m[0x208A] == x
    m[0x20A1]=0
    assert r.saucer.handler(0x2050) == 'SAUCER_MOVE' and m[0x208A] != x
    # Flying saucer triggers the Stage 05 slot-selection logic without
    # manually fabricating the active flag in the drop fixture.
    m[0x212E] = 0
    r.part2_drop.find_slot()
    assert m[0x20A0] & 0x80 and (m[0x20AA] | m[0x20AB] << 8) == 0x212E
    # Force location match then observe mid-screen initiation and VBlank drop.
    col=m[0x20A0]&15
    target=(m[0x200A] + (col-1)*16+4)&255
    m[0x208A]=((target-8)&255)&0xFE
    assert r.part2_drop.mid_screen() and m[0x20A1]==1
    low=m[0x20A4]
    r.part2_drop.end_screen()
    assert m[0x20A4] == (low + m[0x20A2])&255
    # Free saucer, then restart as the second saucer. Blink changes every 4 ticks.
    m[0x20A1]=0
    r.saucer.reset();m[0x2083]=1
    m[0x2080]=2;m[0x2072]=0
    r.saucer.handler(0x2050)
    assert m[0x20BC]==2 and (m[0x2087]|m[0x2088]<<8)==0x187E
    seq=[r.saucer.handler(0x2050) for _ in range(8)]
    assert 'SAUCER_BLINK_OFF' in seq and 'SAUCER_MOVE' in seq
    # Hit sequence: flag raised by Stage 04 collision; score 500 on second.
    m[0x2085]=1;m[0x2086]=0x20
    r.saucer.handler(0x2050)
    assert any(e[1]=='SAUCER_EXPLOSION' for e in r.saucer.events)
    for _ in range(7): r.saucer.handler(0x2050)
    assert r.saucer.awarded[-1]==500
    for _ in range(24):r.saucer.handler(0x2050)
    assert m[0x2084]==0
    # Stage 04's actual player-shot collision branch feeds Stage 06 hit handling.
    c=fixture();cm=c.mem
    c.saucer.handler(0x2050)
    cm[0x2025]=2;cm[0x2029]=0xCE;cm[0x2002]=1
    c.combat.player_shot_hit()
    assert cm[0x2085] == 1 and cm[0x2025] == 4
    assert c.saucer.handler(0x2050) == 'SAUCER_HIT_SEQUENCE'
    assert any(e[1]=='SAUCER_EXPLOSION' for e in c.saucer.events)
    # Exercise the actual ROM object descriptor through the two ISR entries.
    q=fixture();qm=q.mem
    qm[0x2032]=qm[0x2080]=2
    q.step_frame()
    assert qm[0x2084] == 1
    assert any(e[1]=='SAUCER_APPEARED' for e in q.saucer.events)
    assert q.scheduler.mid_count == q.scheduler.end_count == 1
    # Opt-in pathway is isolated from default and from original v1.
    assert not Rack(part2=True).saucer_enabled
    assert not Rack(part2=False).saucer_enabled
    # Actual ISR calling still runs without forcing other unported handlers.
    z=Rack(part2=True);z.enable_part2_saucer_live_diagnostic()
    for _ in range(20):z.step_frame()
    assert z.scheduler.mid_count==z.scheduler.end_count==20
    print('PASS: Part II saucer lifecycle, second-saucer blink, hover during drop,')
    print('      formation slot coupling, VBlank fall, 500-point saucer and 20 IRQ pairs')

if __name__ == '__main__':check()
