"""Space Invaders Part II PROM palette, using MAME's video-RAM address wiring.

The 8080 framebuffer is rotated in memory: each video row has 32 bytes,
with eight adjacent hardware X pixels packed into each byte.  The native
Python framebuffer is already upright (224 x 256), so PROM address selection
must undo that rotation and account for the 0x20 non-blank scanline start.

Reference: MAME src/mame/midw8080/8080bw_v.cpp,
_8080bw_state::screen_update_invadpt2().
"""
from part2_static_data import PLAYER1_PROM, PLAYER2_PROM

W, H = 224, 256


def palette_rgb(pen):
    # MAME palette_device::RBG_3BIT: bit0=red, bit1=blue, bit2=green.
    return (255 if pen & 1 else 0,
            255 if pen & 4 else 0,
            255 if pen & 2 else 0)


def prom_address(x, y):
    """Map an upright displayed pixel to the PROM address MAME uses.

    Original video memory offset for pixel (x, y):
      offs = ((x + 0x20) << 5) | ((255 - y) >> 3)
    MAME: color_address = (offs >> 8 << 5) | (offs & 0x1f)
    Each PROM cell covers 8x8 displayed pixels.
    """
    if not (0 <= x < W and 0 <= y < H):
        raise ValueError('pixel outside native 224x256 screen')
    return (((x + 0x20) >> 3) << 5) | ((255 - y) >> 3)


class Part2Colour:
    def __init__(self):
        self.proms = (PLAYER1_PROM, PLAYER2_PROM)
        assert all(len(p) == 1024 for p in self.proms)
        self.maps = []
        for prom in self.proms:
            rgb = bytearray(W * H * 3)
            for y in range(H):
                for x in range(W):
                    pixel = (y * W + x) * 3
                    rgb[pixel:pixel + 3] = bytes(palette_rgb(prom[prom_address(x, y)] & 7))
            self.maps.append(bytes(rgb))

    def apply(self, luma, player=1, *, screen_red=False):
        if len(luma) != W * H:
            raise ValueError('expected 224x256 native pixels')
        if player not in (1, 2):
            raise ValueError('player must be 1 or 2')
        # MAME screen_update_invadpt2: when port $03 bit 2 is set,
        # use foreground pen 1 (pure red) for *all lit pixels*.
        # Black background and VRAM remain unchanged.
        colors = self.maps[player - 1]
        rgb = bytearray(len(luma) * 3)
        for i, lit in enumerate(luma):
            if lit:
                rgb[i * 3:i * 3 + 3] = b"\xff\x00\x00" if screen_red else colors[i * 3:i * 3 + 3]
        return bytes(rgb)
