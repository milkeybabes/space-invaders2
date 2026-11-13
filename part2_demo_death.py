"""Part II ROM $02D4 / $03EB player blow-up, demo-mode branch only.

Translated from invadpt2.asm. No CPU emulation or synthesized death timeout:
$2016 is the original five-call image timer, and $2017 the original image
count. After the final image the $1B10 ROM descriptor is restored. Because
$20EF == 0 in attract mode, the ROM returns without gameplay respawn.
"""

class Part2DemoDeath:
    def __init__(self, rack):
        self.rack = rack
        self.events = []
        self.completed = False

    def handler(self, base):
        if base != 0x2010:
            raise ValueError('Part II player handler requires object $2010')
        r = self.rack
        m = r.mem
        if m[0x2015] == 0xFF:
            return r.objects.player_normal(base)
        if self.completed:
            return 'DEMO_DEATH_DONE'
        # $02DC-$02DE: DCR $2016; exit until next sprite interval.
        m[0x2016] = (m[0x2016] - 1) & 0xFF
        if m[0x2016]:
            return 'DEMO_DEATH_WAIT'
        # $02E0-$02F0: freeze aliens/shots, reload timer, count pictures.
        former = m[0x2015]
        m[0x2068] = 0
        m[0x2069] = 0
        m[0x206A] = 0x30
        m[0x2016] = 5
        m[0x2017] = (m[0x2017] - 1) & 0xFF
        if m[0x2017]:
            # $03EB DrawPlayerDie uses the Part II $1C91 + 16 * frame.
            state = (former + 1) & 1
            m[0x2015] = state
            source = 0x1C91 + state * 16
            m[0x2018], m[0x2019] = source & 255, source >> 8
            r.draw_simple_sprite(m[0x201A], m[0x201B], source, m[0x201C])
            self.events.append((r.frames, 'sprite', state))
            return 'DEMO_DEATH_SPRITE'
        # $02F4-$0307: erase 16 columns and restore ROM player descriptor.
        start, _ = r.pixel_to_address(m[0x201A], m[0x201B])
        for col in range(16):
            address = start + col * 32
            if 0x2400 <= address < 0x4000:
                m[address] = 0
        m[0x2010:0x2020] = m[0x1B10:0x1B20]
        self.completed = True
        self.events.append((r.frames, 'complete', 0))
        # $0314-$0318: gameMode==0 returns to the attract foreground.
        return 'DEMO_DEATH_COMPLETE'
