"""Presentation-only artwork for the provided Space Invaders Part II bezel.

Original pixel coordinates/RAM stay unchanged. Decorative bezel is scaled to
window if required, while native gameplay uses only nearest-neighbour integer
scaling. Black game pixels stay black (not transparent) because we have no
verified authentic backdrop for this particular artwork.
"""
from pathlib import Path

BEZEL_W, BEZEL_H = (1920, 1080)


def prepare_bezel(pygame):
    path = Path(__file__).with_name('artwork') / 'part2_bezel.png'
    if not path.exists():
        raise FileNotFoundError(f'Part II bezel missing: {path}')
    # Loading a PNG does not require a display, but convert_alpha() does.
    # The display is created by part2_play.py immediately after this call.
    screen = pygame.image.load(str(path))
    if screen.get_size() != (BEZEL_W, BEZEL_H):
        raise ValueError('Part II bezel image must be 1920x1080')
    desktop = pygame.display.Info()
    w, h = desktop.current_w, desktop.current_h
    # Fixed 16:9 presentation that stays inside Windows taskbar/title bar.
    ratio = min(1.0, (w-40)/BEZEL_W, (h-100)/BEZEL_H)
    ratio = max(ratio, 0.35)
    out_w = round(BEZEL_W * ratio)
    out_h = round(BEZEL_H * ratio)
    return screen, (out_w, out_h)


# Cache the converted, scaled overlay. The PNG is converted only after the
# display mode has been established, and only when the output size changes.
_cached_overlay_key = None
_cached_overlay = None


def draw_bezel(pygame, destination, game_224x256, bezel):
    global _cached_overlay_key, _cached_overlay
    w, h = destination.get_size()
    destination.fill((0, 0, 0))
    # 3x native at 1080p, 2x at 720-972p, 1x below. Never interpolate game.
    factor = max(1, min(3, (w - 160)//224, (h-70)//256))
    native = pygame.transform.scale(game_224x256, (224*factor, 256*factor))
    # Centre screen in the actual transparent monitor window.
    destination.blit(native, ((w - 224*factor)//2, (h - 256*factor)//2))
    cache_key = (id(bezel), w, h)
    if cache_key != _cached_overlay_key:
        # This runs only after pygame.display.set_mode(), so alpha conversion
        # is now valid and remains efficient for subsequent display frames.
        overlay = bezel.convert_alpha()
        if (w, h) != (BEZEL_W, BEZEL_H):
            overlay = pygame.transform.smoothscale(overlay, (w, h))
        _cached_overlay = overlay
        _cached_overlay_key = cache_key
    destination.blit(_cached_overlay, (0, 0))
