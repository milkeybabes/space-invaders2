"""Part II first playable *integration milestone*.

Uses the translated native Part II ROM rack, object dispatcher, projectiles,
shield graphics and player input. This is deliberately not yet a source-exact
$087E start/respawn/game-over foreground controller. Keep it separate from
Part2AttractPreview so established MAME traces cannot regress.
"""
from rack import Rack
from part2_display import Part2Shields
from part2_rack_arrive import Part2RackArrival
from part2_rom import install_formation
from waves import WaveTransitions

class Part2FirstPlay:
    def __init__(self, *, debug=False, start_level=1, starting_lives=3):
        if not 1 <= start_level <= 17:
            raise ValueError('start_level must be from 1 through 17')
        if starting_lives not in (3, 4):
            raise ValueError("Part II DIP lives must be 3 or 4")
        self.starting_lives = starting_lives
        self.debug = bool(debug)
        self.start_level = start_level
        self.frame = 0
        # Part II RAM $21F9 is zero-based; user-facing level 1 is round 0.
        self.round = start_level - 1
        self.rack = None
        self.arrival = None
        from sound_driver import RomSoundDriver
        self.sound = RomSoundDriver()
        self.start_round()

    def start_round(self):
        r = Rack(part2=True)
        r.enable_part2_enemy_shots_diagnostic()
        # The diagnostic object setup overrides the real ROM player timer
        # ($1B10-$1B11 = $0080) to draw a controllable ship immediately.
        # Gameplay must keep that 128-tick startup wait: otherwise the ship
        # appears as soon as RackArrive finishes and the firing countdown
        # ($206A) also begins 128 object-service ticks too early.
        r.mem[0x2010:0x2012] = r.mem[0x1B10:0x1B12]
        # The Stage-7 diagnostic forces $2069=1 to exercise projectile code.
        # Real gameplay must instead honour ROM $0388-$039B: alien firing
        # is initially disabled, then enabled by GameObj0 after the
        # $206A player-object countdown. Do not let diagnostic setup
        # bypass the normal first-rack startup gate.
        r.mem[0x2069] = 0
        r.mem[0x206A] = 0x30
        from lives import PlayerLives
        r.lives_enabled = True
        r.lives = PlayerLives(r, starting_lives=self.starting_lives)
        # Testing-only invulnerability: keep collision, explosion and respawn
        # intact, but do not consume spare ships or enter game-over.
        r.lives.life_decrement = 0 if self.debug else 1
        self.rack = r
        r.mem[0x20EF] = 1  # ROM gameMode: read player keys, not demo commands
        r.mem[0x20ED] = 0
        r.mem[0x20EE] = 0
        install_formation(r, self.round)
        r.mem[0x21F9] = self.round
        r.mem[0x21FA] = (self.round + 1) % 10
        if self.round:
            # A test starting on a later level should use that level's
            # rack start height rather than the first game's $78.
            from waves import START_HEIGHTS
            y = START_HEIGHTS[(self.round - 1) & 7]
            r.mem[0x2009] = r.mem[0x200B] = y
        r.shields = Part2Shields(r)
        r.shields.init_playfield(player=1)
        r.shields_enabled = True
        r.mem[0x20E4] = 0
        self.arrival = Part2RackArrival(r)
        # The Part II playable main loop must service $082B/$09EF when
        # CountAliens reaches zero; this was absent from the first playable.
        r.waves = WaveTransitions(r)
        # $21FE counts completed racks in the ROM's 8-height cycle.
        r.mem[0x21FE] = self.round & 7
        r.waves_enabled = True
        # The ROM original game-start/ship stock logic is the next milestone.
        # Do not synthesize a bogus completed life/death sequence here.

    def step(self, *, left=False, right=False, fire=False):
        self.frame += 1
        r = self.rack
        r.set_controls(left=left, right=right, fire=fire)
        if not self.arrival.complete:
            r.scheduler.scanline_96()
            r.scheduler.scanline_224()
            r.frames += 1
            # $09FA runs in the foreground between interrupts, rather than
            # magically performing a fixed eight alien writes per frame.
            # Account for approximate 8080 work and carry unused cycles.
            self.arrival.advance_frame()
        else:
            completed_before = r.waves.completed
            r.step_frame()
            if r.waves.completed != completed_before:
                self.round = r.mem[0x21F9]
                # $09CA moves the next formation into place after the
                # Part II-specific rack reset; no new Rack or lost score.
                self.arrival = Part2RackArrival(r)
        # Port $03 bit 2 is also the hardware screen-red control in Part II.
        # The translated sound driver currently estimates the hold duration;
        # it supplies the latch to the colour renderer without touching VRAM.
        self.sound.step(r, playing=True)
        # Original player-death controller runs via the game-object dispatcher.
        # The 1978-only scheduler halt is now disabled by lives_enabled.

    @property
    def screen_red(self):
        # Port 03 red remains asserted for the actual explosion sequence.
        # The provisional 38-frame sound hold alone ended before the last
        # death sprites on the two-player MAME reference.
        return bool(self.sound.bus.values[3] & 0x04) or (
            self.rack.mem[0x2015] != 0xFF and
            self.rack.mem[0x2017] != 0 and
            self.rack.lives_enabled
        )

    def image(self):
        return self.rack.portrait_luma()
