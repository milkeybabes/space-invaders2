"""Stage 11 ROM title and colour-PROM regression tests.
Run: python part2_stage11_test.py
"""
from part2_title import Part2Title
from part2_colour import Part2Colour
from part2_attract import Part2AttractPreview


def check():
    title = Part2Title()
    assert title.mem[0x41E4:0x41EC] == bytes.fromhex('EE EE EE 00 EE EE EE 00')
    assert title.mem[0x41EC] == 0x1E
    base = title.image()
    title.seek(0.2)
    midway = title.image()
    assert base != midway, 'title animation must change video RAM'
    title.seek(1)
    final = title.image()
    assert final != midway
    assert sum(final) > 100000, 'expected ROM title and scoring pixels'
    assert title.index == len(title.ops)
    colors = Part2Colour()
    assert all(len(p) == 1024 for p in colors.proms)
    assert len(colors.apply(final)) == 224 * 256 * 3
    coloured = colors.apply(final)
    assert len({coloured[i:i+3] for i in range(0, len(coloured), 3)}) >= 5
    assert colors.apply(bytes(224*256)) == bytes(224*256*3)
    demo = Part2AttractPreview()
    assert demo.phase == 'title'
    while demo.phase == 'title':
        demo.step()
    assert demo.phase == 'score_table'
    while demo.phase == 'score_table':
        demo.step()
    assert demo.phase == 'demo', 'original live demo must remain connected'
    print('PASS: original 1979 title dot fill, ROM bitmap carve/copy,')
    print('      score restore, two colour PROMs, phased attract transition')


if __name__ == '__main__':
    check()
