"""Stage 07 source-port regression checks. Run: python part2_stage07_test.py"""
from rack import Rack
from part2_rom import load_rom

def new():
    r = Rack(part2=True)
    r.enable_part2_enemy_shots_diagnostic()
    return r

def check():
    base, _ = load_rom()
    r = new(); m = r.mem
    assert r.objects.handlers.get(0x04C3) and r.objects.handlers.get(0x0503)
    assert r.objects.handlers.get(0x06D9) == r.saucer.handler
    assert r.enemy_shots.rom == base
    # Original mirror, skip one rolling-shot fire at startup.
    m[0x2038:0x203A] = b'\x00\x00'
    assert r.enemy_shots.handler('rolling', 0x2030) == 'ROLLING_FIRST_SKIP'
    assert m[0x2038:0x203A] == b'\xff\xff'
    assert m[0x2032] == base[0x1B32] == 2
    # Rounds 0..3 permit the plunger branch; round 4 disables it.
    m[0x21F9] = 4; m[0x206E] = 0; m[0x2080] = 1
    assert r.enemy_shots.handler('plunger', 0x2040) == 'PLUNGER_DISABLED_ROUND4'
    assert m[0x206E] == 1
    q = new(); x = q.mem; x[0x21F9]=3; x[0x2080]=0
    assert q.enemy_shots.handler('plunger', 0x2040) == 'PLUNGER_WAIT_SYNC'
    x[0x2080]=1; x[0x206E]=1
    assert q.enemy_shots.handler('plunger', 0x2040) == 'PLUNGER_SKIPPED_ONE_ALIEN'
    # $05B8 must not alter the saved per-shot descriptor while halted.
    x[0x206E]=0; x[0x20E4]=1
    before=bytes(x[0x2045:0x2050])
    assert q.enemy_shots.handler('plunger', 0x2040) == 'SHOTS_HALTED'
    assert x[0x2045:0x2050] == before
    x[0x20E4]=0
    # Part II uses relocated column tables and sprite image ends.
    x[0x2048]=0x90; x[0x2049]=0x1A
    q.enemy_shots.handler('plunger', 0x2040)
    assert x[0x207F] == 0xF0
    # Force live plunger pointer while the shot remains active.
    x[0x2045]=0x80; x[0x2046]=1; x[0x2048]=0x90; x[0x2049]=0x1A
    x[0x204D]=0x80; x[0x2072]=0  # wrong beam -> no movement
    q.enemy_shots.handler('plunger',0x2040)
    assert x[0x2048]==base[0x1B48]==0x80
    # Explicit squiggly fallback through the shared saucer handler.
    z=new(); a=z.mem; a[0x2080]=2; a[0x2083]=0
    assert z.saucer.handler(0x2050) != 'SQUIGGLY_NOT_PORTED'
    assert a[0x207F]==0xDE
    # Original shot memory and sprite data must remain untouched.
    assert z.mem[0x1CD0:0x1D15] == base[0x1CD0:0x1D15]
    # Live dispatcher exercises relocated handler from original ROM mirror.
    w=new(); wm=w.mem; wm[0x2030:0x2033]=b'\x00\x00\x00'
    wm[0x2038:0x203A]=b'\x00\x00'
    w.objects.run(0x2030,0x2040)
    assert wm[0x2038:0x203A]==b'\xff\xff'
    f=new()
    for _ in range(20):f.step_frame()
    assert f.scheduler.mid_count==f.scheduler.end_count==20
    assert not Rack(part2=True).enemy_shots_enabled
    assert not Rack(part2=False).enemy_shots_enabled
    print('PASS: Part II rolling/plunger/squiggly missile handlers, round-4')
    print('      disable, shotsHalted, native ROM reset/tables, saucer fallback,')
    print('      original dispatcher and 20 two-interrupt frames')

if __name__ == '__main__':
    check()
