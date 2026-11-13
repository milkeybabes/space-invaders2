"""Save ROM PROM colour diagnostics for MAME's full-video-RAM $FF test.

Run from Windows Command Prompt:
    python part2_colour_lookup_test.py
Output files are placed in ./diagnostics/. This test needs Pillow.
"""
from pathlib import Path
from PIL import Image
from part2_colour import Part2Colour, W, H, prom_address, palette_rgb
from part2_title import Part2Title


def save(path, data):
    Image.frombytes('RGB', (W, H), data).save(path)
    print('Saved:', path)


def main():
    out = Path(__file__).resolve().parents[1] / 'diagnostics'
    out.mkdir(exist_ok=True)
    colour = Part2Colour()
    for player in (1, 2):
        prom = colour.proms[player - 1]
        for x, y in ((0, 0), (64, 32), (120, 120), (223, 255)):
            i = 3 * (y * W + x)
            assert colour.maps[player - 1][i:i + 3] == bytes(palette_rgb(prom[prom_address(x, y)] & 7))
        save(out / f'part2_colour_fullfill_player{player}.png',
             colour.apply(bytes([255]) * (W * H), player=player))
    title = Part2Title()
    title.seek(1)
    save(out / 'part2_colour_title.png', colour.apply(title.image(), player=1))
    print('PASS: native rotated MAME PROM addressing and PNG exports')


if __name__ == '__main__':
    main()
