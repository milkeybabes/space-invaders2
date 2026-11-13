"""Part II $06D9-$083F: source-led flying saucer lifecycle.

Works with the Stage 05 SaucerDrop module. Deliberately opt-in: the rest of
Part II's live enemy-shot/startup paths are still being translated. This is
not an 8080 emulator or an assertion of frame-accurate MAME parity.
"""
from part2_rom import load_rom

class Part2Saucer:
    def __init__(self, rack):
        if not rack.part2:
            raise ValueError('Part II saucer requires Part II rack')
        self.rack = rack
        self.events = []
        self.awarded = []
        self.rom, _ = load_rom()
        self.reset()
        # Source $0AFC timer, $0600 (counted in VBlank game-object ticks).
        rack.mem[0x2091:0x2093] = b'\x00\x06'

    def emit(self, name, *values):
        self.events.append((self.rack.frames + 1, name, *values))

    def reset(self):
        """$083F: reset ten bytes of saucer descriptor from $1B83 ROM mirror."""
        self.rack.mem[0x2083:0x208D] = self.rom[0x1B83:0x1B8D]

    def time_to_saucer(self):
        """$0AFC: countdown only after the alien rack moves below $78."""
        m = self.rack.mem
        if m[0x2009] >= 0x78:
            return
        t = m[0x2091] | (m[0x2092] << 8)
        if t == 0:
            t = 0x600
            m[0x2083] = 1
            self.emit('SAUCER_DUE')
        t = (t - 1) & 0xffff
        m[0x2091], m[0x2092] = t & 255, t >> 8

    def draw(self):
        m = self.rack.mem
        ptr = m[0x2087] | m[0x2088] << 8
        self.rack.draw_simple_sprite(m[0x2089], m[0x208A], ptr, m[0x208B])

    def clear(self):
        m = self.rack.mem
        start, _ = self.rack.pixel_to_address(m[0x2089], m[0x208A])
        for i in range(m[0x208B]):
            a = start + i * 32
            if 0x2400 <= a < 0x4000:
                m[a] = 0

    def handler(self, base):
        """$06D9 GameObj4. Retains squiggly shot fallback and VBlank gates."""
        if base != 0x2050:
            raise ValueError('saucer must use original shared object $2050')
        m = self.rack.mem
        if m[0x2080] != 2:
            return 'SAUCER_SYNC_WAIT'
        if not m[0x2083] or m[0x2056]:
            return self._squiggly(base)
        if not m[0x2084]:
            if m[0x2082] < 8:
                return self._squiggly(base)
            m[0x2084] = 1
            m[0x20BC] = (m[0x20BC] + 1) & 255  # $0759 SaucerStart
            if m[0x20BC] == 2:
                m[0x2087:0x2089] = b'\x7E\x18'  # $187E flashing sprite
            self.draw()
            self.emit('SAUCER_APPEARED', m[0x20BC])
        # Original CompYToBeam tests the high coordinate's bit 7.
        if (m[0x208A] & 0x80) != m[0x2072]:
            return 'SAUCER_WRONG_BEAM'
        if m[0x2085]:
            return self._hit_sequence()
        if m[0x20A1]:  # $0716: dropActive makes saucer hover in place
            self.draw()
            self.emit('SAUCER_HOVER_DROP', m[0x208A])
            return 'SAUCER_HOVER_DROP'
        self.clear()
        m[0x208A] = (m[0x208A] + m[0x208C]) & 255
        if m[0x208A] < 0x28 or m[0x208A] >= 0xE1:
            self.clear()
            self.reset()
            self.emit('SAUCER_LEFT')
            return 'SAUCER_LEFT'
        if m[0x20BC] == 2:
            m[0x20BD] = (m[0x20BD] + 1) & 255
            if m[0x20BD] & 4:
                self.clear()
                self.emit('SAUCER_BLINK_OFF')
                return 'SAUCER_BLINK_OFF'
        self.draw()
        self.emit('SAUCER_MOVED', m[0x208A])
        return 'SAUCER_MOVE'

    def _squiggly(self, base):
        if self.rack.enemy_shots_enabled:
            return self.rack.enemy_shots.handler('squiggly', base)
        return 'SQUIGGLY_NOT_PORTED'

    def _hit_sequence(self):
        """$078C timer: $1F explosion, $18 score, $00 reset."""
        m = self.rack.mem
        m[0x2086] = (m[0x2086] - 1) & 255
        t = m[0x2086]
        if t == 0x1F:
            m[0x2087:0x2089] = b'\x7C\x1D' # $1D7C explosion sprite
            self.draw()
            self.emit('SAUCER_EXPLOSION')
        elif t == 0x18:
            m[0x20F1] = 1
            if m[0x20BC] == 1:
                m[0x20BA] = 1
            if m[0x20BC] == 2:
                score = 0x50 # $076E fixed 500 displayed points
                if m[0x20BA]:
                    m[0x20BB] = 1
            else:
                ptr = m[0x208D] | (m[0x208E] << 8)
                score = m[ptr]
            if m[0x20EF]:
                m[0x20F2], m[0x20F3] = score, 0
                # BCD value is in tens; displayed Part II scores append zero.
                points = ((score >> 4) * 10 + (score & 15)) * 10
                self.awarded.append(points)
                self.emit('SAUCER_SCORE', points)
            else:
                m[0x20F1] = 0
                self.emit('SAUCER_DEMO_NO_SCORE')
            self.clear()
            # ROM $07CF-$07ED -> PrintSauScore: select an actual three-digit
            # ROM message, then draw it where the saucer was shot. The Part II
            # screen font uses five data bytes and three blank columns.
            msg_low = (0xA8 if m[0x20BC] == 2 else
                       {0x05: 0x90, 0x10: 0x93, 0x15: 0x96, 0x30: 0x99}.get(score))
            if msg_low is not None:
                m[0x2087], m[0x2088] = msg_low, 0x1D
                addr, _ = self.rack.pixel_to_address(m[0x2089], m[0x208A])
                for i in range(3):
                    addr = self.rack.score_display.draw_char(m[0x1D00 + msg_low + i], addr)
                self.emit('SAUCER_SCORE_LABEL', points if m[0x20EF] else 0)
        elif t == 0:
            self.clear()
            self.reset()
            self.emit('SAUCER_FINISHED')
        return 'SAUCER_HIT_SEQUENCE'
