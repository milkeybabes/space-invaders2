"""Space Invaders Part II: source-led translation of 12D8/1307 and 0B41.

This module changes RAM as the original routines do. It does NOT emulate an
8080 CPU. The caller supplies the status slot returned by GetAlienStatPtr.
This is a collision/score logic stage, not a validated live-game scheduler.
"""
from dataclasses import dataclass

STATUS_POINTS_BCD = {1: 0x01, 3: 0x02, 5: 0x03, 7: 0x03}


@dataclass(frozen=True)
class AlienHitResult:
    status: int
    bcd_points: int
    split: bool
    explosion_rom: int
    explosion_size: int


def apply_alien_hit(memory: bytearray, slot: int, *, round_number: int | None = None) -> AlienHitResult:
    """$12D8 AlienHit and $1307 CrabHit; $0C64/$0B41 score delta.

    In 8080 source GetRoundNum reads current player's bank at $2xF9.
    Round count is ZERO based: split happens when stored count >= 3.
    The original writes slot+1 unconditionally. Keep this even for an
    occupied neighbouring cell, rather than inserting a validity guard.
    """
    page = memory[0x2067] << 8
    if not (page <= slot < page + 55):
        raise ValueError('alien status slot must be in active 55-alien bank')
    status = memory[slot]
    if status not in STATUS_POINTS_BCD:
        raise ValueError('no live alien at slot: %02X' % status)
    if round_number is None:
        round_number = memory[page | 0xF9]
    memory[0x20DB] = status                # lastAlienType / intermission
    memory[slot] = 0
    explosion_rom = 0x1CC2
    explosion_size = 0x10
    split = (status == 3 and round_number >= 3)
    if split:
        memory[slot] = 7
        # $1316 does not check the adjacent slot; preserve 8080 write.
        memory[slot + 1] = 7
        explosion_rom = 0x1AE0
        explosion_size = 0x20
    memory[0x2062] = explosion_rom & 255
    memory[0x2063] = explosion_rom >> 8
    memory[0x2066] = explosion_size
    points = STATUS_POINTS_BCD[status]
    if memory[0x20EF]:
        memory[0x20F3] = 0
        memory[0x20F2] = points
        memory[0x20F1] = 1
    return AlienHitResult(status, points, split, explosion_rom, explosion_size)


def legal_column(column_one_based: int) -> bool:
    """$125D fixes original CodeBug1: reject column >= $0C."""
    return 1 <= column_one_based < 12
