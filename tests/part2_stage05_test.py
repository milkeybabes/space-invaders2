"""Native Part II saucer-reinforcement tests. CMD: py part2_stage05_test.py"""
from rack import Rack
from part2_rom import load_rom


def fixture(round_num=2, *, direction=2):
    r = Rack(part2=True)
    r.enable_part2_drop_diagnostic()
    m = r.mem
    m[0x21F9] = round_num
    m[0x2084] = 1  # saucer flying
    m[0x208C] = direction
    m[0x212C:0x2137] = bytes([5] * 11)
    m[0x212E] = 0  # first vacancy at column index 2
    return r


def check():
    lo, hi = load_rom()
    # Correct source mirror and reset: 14 consecutive bytes from original ROM.
    r = fixture()
    m = r.mem
    assert m[0x20A0:0x20AE] == lo[0x1BA0:0x1BAE]
    r.part2_drop.find_slot()
    assert (m[0x20AA] | (m[0x20AB] << 8)) == 0x212E
    assert m[0x20A0] == (0x80 | ((0x2E + 5) & 15))
    # Round 0 and 1: no drop (round counter is zero-based as in the ROM).
    for rnd in (0, 1):
        z = fixture(rnd)
        z.scheduler.scanline_96()
        assert z.mem[0x20A0] & 0x80 == 0
    # An approaching saucer must have exact even-position match before drop.
    r = fixture()
    m = r.mem
    r.part2_drop.find_slot()
    col = m[0x20A0] & 15
    target_x = (m[0x200A] + (col - 1) * 16 + 4) & 255
    expected = ((target_x - 8) & 255) & 0xFE
    m[0x208A] = (expected + 2) & 255
    assert not r.part2_drop.mid_screen() and m[0x20A1] == 0
    m[0x208A] = expected
    # Make sure a pending cursor action is skipped when SaucerDrop takes over.
    m[0x2000] = 0
    prior_cursor = m[0x2006]
    r.scheduler.scanline_96()
    assert m[0x20A1] == 1
    assert m[0x2006] == prior_cursor
    assert m[0x20A9] == (m[0x2009] + 0x40) & 255
    old_low = m[0x20A4]
    r.scheduler.scanline_224()
    assert m[0x20A4] == (old_low - 2) & 255
    # Falling sprite should contain actual ROM bytes.
    source = m[0x20A6] | m[0x20A7] << 8
    addr, _ = r.pixel_to_address(m[0x20A4], m[0x20A5])
    if 0x2400 <= addr < 0x4000:
        assert m[addr] == ((lo[source] << (m[0x20A4] & 7)) & 0xFF)
    # Force landing: squid is written into the chosen slot and dropDone set.
    m[0x20A4] = m[0x20A9]
    assert r.part2_drop.mid_screen()
    assert m[0x212E] == 5 and m[0x20B7] == 1 and m[0x20A1] == 0
    # When the saucer leaves, dropDone is copied to dropOnce.
    m[0x2084] = 0
    r.part2_drop.find_slot()
    assert m[0x20B8] == 1
    assert not r.part2_drop.mid_screen()
    # Round 4+ can make another drop despite dropOnce.
    m[0x21F9] = 4
    m[0x2084] = 1
    m[0x212F] = 0
    r.part2_drop.find_slot()
    assert m[0x20A0] & 0x80
    # Source-direction reverse search finds last empty slot.
    z = fixture(4, direction=0xFE)
    z.mem[0x2134] = 0
    z.part2_drop.find_slot()
    assert (z.mem[0x20AA] | z.mem[0x20AB] << 8) == 0x2134
    # Hit sprite at $4594 and offscreen reset use expansion graphics.
    z = fixture(4)
    z.mem[0x20A1] = 1
    z.mem[0x20AD] = 1
    z.mem[0x20A4] = 0x80
    z.mem[0x20A5] = 0x70
    z.part2_drop.end_screen()
    a, _ = z.pixel_to_address(z.mem[0x20A4], z.mem[0x20A5])
    assert z.mem[a] == ((hi[0x594] << (z.mem[0x20A4] & 7)) & 0xFF)
    z.mem[0x20A4] = 0x2F
    z.part2_drop.end_screen()
    assert z.mem[0x20A1] == 0
    assert any(ev[1] == 'DROP_OFFSCREEN' for ev in z.part2_drop.events)
    # Preserve baseline and Stage 04 branch integration.
    z = Rack(part2=True)
    for _ in range(20):
        z.step_frame()
    assert z.scheduler.mid_count == 20 and z.scheduler.end_count == 20
    print('PASS: saucer-drop round gates, direction-dependent slot selection,')
    print('      mid-screen takeover, VBlank movement, ROM sprites, landing,')
    print('      one-drop limit, hit graphic, offscreen reset and 20 IRQ pairs')


if __name__ == '__main__':
    check()
