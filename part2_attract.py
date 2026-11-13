"""Part II attract-mode foreground sequencing, translated from 8080 ROM.

Source references: $0CD8 SplashLoop, $40DC TitleScreen, $163F DrawAdvTable,
$0C85 PrintMessageDel, $0CB6 WaitOnDelay, $0D03 demo and $0D32 coin.
One step is one pair of screen IRQs. Title erasure uses opcode-counted
$0EC9 DelayBC inside $41A4 CarveGroup. 64/128/7 are ROM counter loads, not
MAME-derived timings. Foreground drawing instruction overhead is estimated, while the
$0EC9 busy-wait is opcode-counted. Exact CPU instruction pacing is not
claimed. No invented timeout is used to end demo gameplay.
"""
from __future__ import annotations
from rack import Rack
from part2_rom import load_rom, install_formation
from part2_rack_arrive import Part2RackArrival
from part2_title import Part2Title
from part2_startup import Part2Startup
from part2_attract_screens import Part2AttractScreen

DEMO_ROM_START = 0x1ABF
DEMO_ROM_END = 0x1ACA


class Part2AttractPreview:
    PHASES = ('title', 'score_table', 'demo', 'insert_coin')
    # No phase lengths. The foreground proceeds on ROM delay expiries or state.

    def __init__(self, mame_timing=None, *, post_game=False, post_game_mem=None):
        # Retain old caller signature without enabling AVI-derived scheduling.
        self.screen = None
        self.round_toggle = 0
        self.lo, self.hi = load_rom()
        self.frame = 0
        self.phase = ''
        self.phase_frame = 0
        self.rack = None
        self.command_ptr = DEMO_ROM_START - 1
        self.command = 0
        self.fire_pressed = False
        self.arrival = None
        self.title = None
        self.sequence_log = []
        self._demo_was_hit = False
        self._cold_boot = not post_game
        self._post_game_mem = post_game_mem
        # $1BED/$1BEE supplies the initial pointer ($1ABF); subsequent
        # $0D03 CopyRAMMirror only copies $2000-$20BF, so it persists.
        self._demo_cmd_ptr = self.lo[0x1BED] | (self.lo[0x1BEE] << 8)
        # ROM $150F exits the final GAME OVER through $0D32 rather than
        # the cold-start title at $0CD8. Continue the normal coin-information
        # phase, whose own $0D65 return eventually resumes the title loop.
        self._set_phase('insert_coin' if post_game else 'title')

    def _make_rack(self):
        rack = Rack(part2=True)
        rack.enable_part2_enemy_shots_diagnostic()
        # $02D4 demo player explosion/return, not the 1978 lives/respawn path.
        from part2_demo_death import Part2DemoDeath
        rack.part2_demo_death = Part2DemoDeath(rack)
        rack.part2_demo_death_enabled = True
        rack.objects.handlers[0x02D4] = rack.part2_demo_death.handler
        # $0CC1 DemoAliens: alternating rounds 0 and 3.
        round_index = (0, 3)[self.round_toggle]
        install_formation(rack, round_index)
        rack.mem[0x21F9] = round_index
        rack.mem[0x21FA] = (round_index + 1) % 10
        from part2_display import Part2Shields
        rack.shields = Part2Shields(rack)
        rack.shields.init_playfield(player=1)
        rack.shields_enabled = True
        rack.mem[0x20E4] = 0
        if self._post_game_mem is not None:
            rack.mem[0x20F4:0x20F6] = self._post_game_mem[0x20F4:0x20F6]
            rack.mem[0x2340:0x234D] = self._post_game_mem[0x2340:0x234D]
            rack.mem[0x233E:0x2340] = self._post_game_mem[0x233E:0x2340]
            rack.score_display.redraw_scores()
        # Demonstration: $20EF = 0, no score for hits.
        rack.mem[0x20EF] = 0
        # $0D1A sets $20C1 after RackArrive returns.
        self.round_toggle ^= 1
        self.command_ptr = DEMO_ROM_START - 1
        self.command = 0
        self.fire_pressed = False
        rack.mem[0x20ED] = self._demo_cmd_ptr & 0xFF
        rack.mem[0x20EE] = self._demo_cmd_ptr >> 8
        self.arrival = Part2RackArrival(rack)
        self._demo_was_hit = False
        return rack

    def _set_phase(self, phase):
        self.phase = phase
        self.phase_frame = 0
        self.sequence_log.append((self.frame, phase))
        self.wait = 0
        self.action = 0
        if phase == 'title':
            self.title = Part2Title()
            # $168F initialization and both $17DA clears must execute
            # before $0CD8 starts its $40 interrupt countdown.
            self.startup = Part2Startup(self.title, cold_boot=self._cold_boot,
                                       retained_name_mem=self._post_game_mem)
            self._cold_boot = False
            self.wait = 0
        elif phase == 'score_table':
            self.screen = Part2AttractScreen('score_table')
            if self._post_game_mem is not None:
                m = self.screen.mem
                m[0x20F4:0x20F6] = self._post_game_mem[0x20F4:0x20F6]
                m[0x2340:0x234D] = self._post_game_mem[0x2340:0x234D]
                m[0x233E:0x2340] = self._post_game_mem[0x233E:0x2340]
                self.screen.scores.redraw_scores()
            self.screen.advance_ticks(0)
        elif phase == 'demo':
            self.rack = self._make_rack()
        elif phase == 'insert_coin':
            # $0D32 is an ordered foreground routine, not an instant image.
            from part2_coin_foreground import Part2CoinForeground
            self.coin_foreground = Part2CoinForeground(self._post_game_mem)
            self.screen = self.coin_foreground.screen
            self.wait = 0x40
        if self.rack is None:
            self.rack = Rack(part2=True)

    def _title_tick(self):
        # $40DC: FillDots, wait 64; CarveBitmap, wait 64; FillDots,
        # wait 64; CarveBitmap, wait 64; CopyBitmap, wait 64;
        # DrawScores/FlashHiName, wait 64; $0CD8 waits another 64.
        # Dot erasure takes foreground time: $41A4 calls DelayBC($0250)
        # for every removed dot group, not one instantaneous bitmap write.
        if not self.startup.done:
            self.startup.step(self.frame)
            if self.startup.done:
                self.wait = 0x40  # $0CDF OneSecDelay begins after ClearScreen
            return
        if self.wait:
            self.wait -= 1
            if self.wait:
                return  # $0CB9: resume foreground as soon as IRQ reaches zero
        if self.action < len(self.title.stage_ends):
            # 8080 CPU 1,996,800 Hz; one 59.542 Hz video frame.
            # Tick-local budget is sufficient to make the source DelayBC
            # visible without inventing a fixed animation length.
            complete = self.title.advance_cycles(33535, self.title.stage_ends[self.action])
            if complete:
                self.action += 1
                self.wait = 0x40
        elif self.action == len(self.title.stage_ends):
            # TitleScreen has returned; $0CD8 OneSecDelay.
            self.action += 1
            self.wait = 0x40
        else:
            self._set_phase('score_table')

    def _score_tick(self):
        # $163F: 6 sprites and 5 * 11 delayed characters. $0C85 stores
        # 7 in $20C0; $0C90 exits when the value becomes 1 (6 ticks).
        if not self.screen.complete:
            self.screen.advance_ticks(1)
        elif self.action == 0:
            # $0CD8 OneSecDelay after DrawAdvTable returns.
            self.action = 1
            self.wait = 0x40
        elif self.wait:
            self.wait -= 1
        else:
            self._set_phase('demo')

    def _demo_tick(self):
        r = self.rack
        # $1438 is serviced by Combat.fire_from_controls() during the
        # foreground main-loop pass, when the shot is idle. Its ROM command
        # and pointer live in $201D and $20ED; player $03A6 reads $201D.
        # Do not issue commands from this presentation scheduler.
        if self.arrival and not self.arrival.complete:
            r.scheduler.scanline_96()
            r.scheduler.scanline_224()
            r.frames += 1
            # Provisional foreground work rate; not a ROM timing value.
            self.arrival.advance(operations=8)
        else:
            r.mem[0x20C1] = 1  # $0D1A: isrSplashTask = demo
            r.step_frame()
            self.command_ptr = 0x1A00 + r.mem[0x20ED] if r.mem[0x20ED] >= 0xBF else DEMO_ROM_START - 1
            self.command = r.mem[0x201D]
            # $0D1A PlayerHitChk observes $2015 != $FF, then $0D2C
            # waits for it to return to $FF when the explosion is done.
            # No synthetic 15-second or death countdown is permitted.
            if r.mem[0x2015] != 0xFF:
                if not self._demo_was_hit:
                    # $0D2A: remove active player shot upon collision.
                    r.mem[0x2025] = 0
                self._demo_was_hit = True
            elif self._demo_was_hit:
                r.mem[0x20C1] = 0  # $0D32 disables demo ISR task
                self._demo_cmd_ptr = r.mem[0x20ED] | (r.mem[0x20EE] << 8)
                self._post_game_mem = bytearray(r.mem)
                self._set_phase('insert_coin')

    def _coin_tick(self):
        self.coin_foreground.step()
        self.wait = self.coin_foreground.wait
        if self.coin_foreground.complete:
            self._set_phase('title')

    def step(self):
        self.frame += 1
        self.phase_frame += 1
        if self.phase == 'title':
            self._title_tick()
        elif self.phase == 'score_table':
            self._score_tick()
        elif self.phase == 'demo':
            self._demo_tick()
        else:
            self._coin_tick()

    @property
    def status(self):
        return {'phase': self.phase, 'frame': self.frame,
                'phase_frame': self.phase_frame,
                'demo_round': self.rack.mem[0x21F9],
                'aliens': self.rack.alive,
                'rack_arriving': bool(self.arrival and not self.arrival.complete),
                'score': getattr(self.rack.combat, 'score', 0) if self.rack.combat else 0}
