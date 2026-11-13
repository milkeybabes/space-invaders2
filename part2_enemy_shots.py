"""Space Invaders Part II: $04C3 / $0503 / $0564 / $05B8 missile handlers.

Source-level algorithm translation, NOT 8080 emulation. Reuses the verified
1978 missile movement implementation for shared, relocated logic while
preserving Part II's new control flow and its own ROM mirror and pointers.
Opt-in diagnostic: full foreground game sequencing is not translated yet.
"""
from enemy_shots import EnemyShots
from part2_rom import load_rom

PART2_CONFIG = {
    'rolling': (0x04C3, 0x2030, 0x2035, 0xFC, (0x2046, 0x2056)),
    'plunger': (0x0503, 0x2040, 0x2045, 0xF0, (0x2036, 0x2056)),
    'squiggly': (0x06D9, 0x2050, 0x2055, 0xDE, (0x2046, 0x2036)),
}

class Part2EnemyShots(EnemyShots):
    def __init__(self, rack):
        if not rack.part2:
            raise ValueError('Part II shots require Part II rack')
        super().__init__(rack)
        self.rom, _ = load_rom()

    def current_round(self):
        # $07F9 GetRoundNum returns the active player's zero-based rack count.
        return self.rack.mem[0x21F9 if (self.rack.mem[0x2067] & 1) else 0x22F9]

    def handler(self, kind, base):
        if kind not in PART2_CONFIG:
            raise ValueError('unknown Part II missile kind')
        m = self.rack.mem
        _, expected, source, sprite_end, other = PART2_CONFIG[kind]
        if base != expected:
            raise ValueError('incorrect original object base')
        if kind == 'rolling':
            # $04C3-$04D6. Timer is reloaded regardless of subsequent firing.
            m[0x2032] = self.rom[0x1B32]
            if not (m[0x2038] | m[0x2039]):
                m[0x2038:0x203A] = b'\xff\xff'
                return 'ROLLING_FIRST_SKIP'
        if kind == 'plunger':
            # $0503: round 4 onward immediately and permanently blocks plunger.
            if self.current_round() >= 4:
                m[0x206E] = 1
                return 'PLUNGER_DISABLED_ROUND4'
            if m[0x206E]:
                return 'PLUNGER_SKIPPED_ONE_ALIEN'
            if m[0x2080] != 1:
                return 'PLUNGER_WAIT_SYNC'
        if kind == 'squiggly' and m[0x2080] != 2:
            return 'SQUIGGLY_WAIT_SYNC'
        # $0564/$05B8: 11-byte source descriptor copied to $2073 scratch.
        m[0x2073:0x207E] = m[source:source+11]
        m[0x207F] = sprite_end
        m[0x2070], m[0x2071] = m[other[0]], m[other[1]]
        if m[0x20E4]:
            # $05B8 returns WITHOUT calling $05BD; avoid changing scratch or
            # writing anything back to the persistent missile descriptor.
            return 'SHOTS_HALTED'
        action = self._handle_shared(kind)
        # $052B/$057C compare LSB with an end in the Part II table at $1A80.
        # Unlike 1978, the Part II pointers start at 1A80 / 1A86.
        if kind == 'plunger' and m[0x2076] >= 0x90:
            m[0x2076] = self.rom[0x1B48]
        elif kind == 'squiggly' and m[0x2076] >= 0x95:
            m[0x2076] = self.rom[0x1B58]
        if m[0x2078]:
            m[source:source+11] = m[0x2073:0x207E]
        else:
            # Reset from Part II ROM, never v1's hard-coded OBJECT_MIRROR.
            offset = 0x1B00 + (base - 0x2000)
            m[base:base+16] = self.rom[offset:offset+16]
            if kind == 'plunger':
                if m[0x2082] == 1:
                    m[0x206E] = 1
                m[0x2048:0x204A] = m[0x2076:0x2078]
            elif kind == 'squiggly':
                m[0x2058:0x205A] = m[0x2076:0x2078]
            self.emit('SHOT_RESET', kind)
        return action
