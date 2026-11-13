"""Compatibility helpers for original game data, embedded in Python.

Original addresses remain for disassembly cross-referencing, but NO ROM
files are opened or loaded. Execution is native translated Python.
"""
from functools import lru_cache
from part2_static_data import MAIN_DATA_BLOCKS, EXPANSION_DATA_BLOCKS

@lru_cache(maxsize=1)
def load_rom():
    """Return address-indexed *game data* arrays (not executable ROM images)."""
    main = bytearray(0x2000)
    expansion = bytearray(0x800)
    for offset, data in MAIN_DATA_BLOCKS:
        main[offset:offset + len(data)] = data
    for offset, data in EXPANSION_DATA_BLOCKS:
        expansion[offset:offset + len(data)] = data
    return bytes(main), bytes(expansion)


def formation_for_round(round_number, lower=None, extra=None):
    """Original InitAliens table selection (0-based round)."""
    if round_number < 0:
        raise ValueError('round_number must be >=0')
    if lower is None or extra is None:
        lower, extra = load_rom()
    index = 8 if round_number >= 16 else round_number
    offset = lower[0x1E10 + index]
    result = bytes(extra[offset:offset + 44])
    if len(result) != 44:
        raise ValueError('Incomplete translated formation')
    return result + bytes([5]) * 11


def sprite_rom_address(status, frame):
    if status not in (1, 3, 5, 7):
        raise ValueError('expected alien status 1,3,5,7')
    return 0x1C01 + ((status & 0xF6) << 3) + (0x40 if frame else 0)


def sprite_bytes(status, frame, lower=None):
    if lower is None:
        lower, _ = load_rom()
    addr = sprite_rom_address(status, frame)
    return lower[addr:addr+16]


def install_formation(rack, round_number=0, player_bank=None):
    if player_bank is None:
        player_bank = rack.mem[0x2067] << 8
    data = formation_for_round(round_number)
    rack.mem[player_bank:player_bank+55] = data
    rack.mem[0x2082] = sum(bool(x) for x in data)
    rack.mem[0x2006] = 0
    rack.mem[0x2000] = 1
    return data
