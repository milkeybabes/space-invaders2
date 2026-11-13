"""Part II saucer reinforcement: source-level translation $42EC-$440D.

Only activated for explicit Stage 05 diagnostics. No Intel 8080 emulation.
The original ROM's five-byte falling-sprite descriptor lives at $20A4-$20A8.
Coordinates use the unrotated machine's low/high pixel-number convention.
"""
from part2_rom import load_rom


class SaucerDrop:
    def __init__(self, rack):
        if not rack.part2:
            raise ValueError('SaucerDrop is specific to Part II')
        self.rack = rack
        self.events = []
        self.base_rom, self.extra_rom = load_rom()
        self.last_drawn = None  # (low, high, height) of prior drawn fall sprite
        # $20A0-$20AD must be initialized by the original $1BA0 ROM mirror.
        rack.mem[0x20A0:0x20AE] = self.base_rom[0x1BA0:0x1BAE]

    def emit(self, name, *details):
        self.events.append((self.rack.frames + 1, name, *details))

    def round_number(self):
        m = self.rack.mem
        return m[(m[0x2067] << 8) | 0xF9]

    def reset_drop(self):
        """$43A3: copy precisely fourteen original ROM mirror bytes."""
        self._erase_previous()
        self.rack.mem[0x20A0:0x20AE] = self.base_rom[0x1BA0:0x1BAE]
        self.emit('DROP_RESET')

    def find_slot(self):
        """$43BB: select first empty top-row slot from saucer's travel end."""
        m = self.rack.mem
        if not m[0x2084]:
            m[0x20A0] &= 0x7F
            if m[0x20B7]:
                m[0x20B8] = m[0x20B7]
            return
        if m[0x20A1]:
            return
        page = m[0x2067] << 8
        # delta $02: scan $2C..$36, all other directions $36..$2C.
        slots = range(0x2C, 0x37) if m[0x208C] == 2 else range(0x36, 0x2B, -1)
        for off in slots:
            if m[page + off] == 0:
                m[0x20AA], m[0x20AB] = off, m[0x2067]
                m[0x20A0] = 0x80 | ((off + 5) & 0x0F)
                self.emit('DROP_SLOT_SELECTED', page + off)
                return

    def mid_screen(self):
        """$42EC: return True only if original jumps directly to ISRExit.

        Caller must run non-player objects once, then skip CursorNextAlien.
        """
        m = self.rack.mem
        rnd = self.round_number()
        if rnd < 2 or (rnd < 4 and m[0x20B8]) or m[0x20AD]:
            return False
        self.find_slot()
        if not m[0x20A1]:
            if not (m[0x20A0] & 0x80):
                return False
            column = m[0x20A0] & 15
            x = (m[0x200A] + (column - 1) * 16 + 4) & 0xFF
            m[0x20A5] = x
            # $4323: A -= 8 then even-mask, compare with saucer's *high* coordinate.
            at_column = ((x - 8) & 0xFF) & 0xFE
            if (m[0x208A] & 0xFE) != at_column:
                return False
            m[0x20A9] = (m[0x2009] + 0x40) & 0xFF
            if m[0x2006] < m[0x20AA]:
                delta = 2 if m[0x200D] else -2
                m[0x20A5] = (m[0x20A5] + delta) & 0xFF
            m[0x20A1] = 1
            self.emit('DROP_STARTED', m[0x20A5], m[0x20A9])
        # ReadDesc returns low (L) from $20A4, high (H) from $20A5.
        if m[0x20A9] >= m[0x20A4]:
            slot = m[0x20AA] | (m[0x20AB] << 8)
            m[slot] = 5
            self.reset_drop()
            m[0x20B7] = 1
            self.emit('DROP_LANDED', slot)
        return True

    def _paint(self, low, high, size, source=None):
        """$1396 DrawSprite: overwrite BOTH shifted screen bytes per row.

        Source is the ROM 5-byte descriptor's sprite address; None denotes a
        zero bitmap, used to erase the former position before movement.
        """
        m = self.rack.mem
        address, shift = self.rack.pixel_to_address(low, high)
        for i in range(size):
            target = address + 32 * i
            if source is None:
                value = 0
            elif source >= 0x4000:
                value = self.extra_rom[source + i - 0x4000]
            else:
                value = m[source + i]
            first = (value << shift) & 0xff
            second = (value >> (8 - shift)) if shift else 0
            if 0x2400 <= target < 0x4000:
                m[target] = first
            if 0x2400 <= target + 1 < 0x4000:
                m[target + 1] = second

    def _erase_previous(self):
        if self.last_drawn is not None:
            self._paint(*self.last_drawn)
            self.last_drawn = None

    def _draw(self, source):
        m = self.rack.mem
        size = m[0x20A8]
        low, high = m[0x20A4], m[0x20A5]
        self._erase_previous()
        self._paint(low, high, size, source)
        self.last_drawn = (low, high, size)

    def end_screen(self):
        """$4383: advance low and high descriptor coordinates, draw sprite.

        This is an overwrite operation like the original DrawSprite; no implicit
        framebuffer clearing or alpha compositing is introduced.
        """
        m = self.rack.mem
        if not m[0x20A1]:
            return
        m[0x20A4] = (m[0x20A4] + m[0x20A2]) & 0xFF
        m[0x20A5] = (m[0x20A5] + m[0x20A3]) & 0xFF
        if m[0x20A4] < 0x2F:
            self._draw(0x458C)
            self.reset_drop()
            self.emit('DROP_OFFSCREEN')
            return
        self._draw(0x4594 if m[0x20AD] else (m[0x20A6] | m[0x20A7] << 8))
        self.emit('DROP_MOVED', m[0x20A4], m[0x20A5])
