"""Part II two-player playable integration.

Use the original $21xx/$22xx player banks and original Part II formation,
shield and sprite data. Each player retains a separate native rack while the
other player takes a turn. Foreground $0336's intermediate player prompt and
its exact wait/flash schedule remain to be translated; not cycle exact.
"""
from part2_first_play import Part2FirstPlay
from part2_rom import install_formation
from part2_rack_arrive import Part2RackArrival
from part2_display import SHIELD_START, SHIELD_PITCH_BYTES
from part2_startup import CYCLES_PER_FRAME

class _ROMClearPlayField:
    """$0BA3-$0BBD: 26 byte rows, 223 columns, video RAM +0x20.

    This is the same ordered ROM write sequence used by the post-game coin
    foreground. An approximate 8080 work budget limits writes per frame.
    """
    def __init__(self, memory):
        self.memory = memory
        self.offset = 0
        self.cycle_credit = 0.0

    @property
    def complete(self):
        return self.offset == 26 * 223

    def step(self):
        self.cycle_credit += CYCLES_PER_FRAME
        # Consistent with Part2CoinForeground's $0BA3 work accounting.
        writes = min(26 * 223 - self.offset, int(self.cycle_credit / 41))
        for _ in range(writes):
            row, col = divmod(self.offset, 223)
            self.memory[0x2402 + row + col * 32] = 0
            self.offset += 1
        self.cycle_credit -= writes * 41
        return self.complete


class Part2TwoPlayer:
    def __init__(self, *, debug=False, start_level=1, starting_lives=3):
        self.games = [Part2FirstPlay(debug=debug, start_level=start_level, starting_lives=starting_lives),
                      Part2FirstPlay(debug=debug, start_level=start_level, starting_lives=starting_lives)]
        self.active = 0
        self.frame = 0
        self.switch_count = 0
        self.done = [False, False]
        self.death_seen = [0, 0]
        self.finished = False
        self.transition = None  # ROM $0A73 foreground prompt during player handoff
        # ROM $08D4/$08EE-$08F4: both racks initially move right (+2)
        # from the same $3878 reference. The two native Python Rack objects
        # each own a separate memory, so initialize their banked reference
        # values in BOTH memories (the original ROM has one common RAM).
        # A later handoff saves a player's progressed coordinates over these.
        for game in self.games:
            m = game.rack.mem
            reference = bytes((0x02, game.arrival.target_y, game.arrival.saved[0x0A]))
            m[0x21FB:0x21FE] = reference
            m[0x22FB:0x22FE] = reference
        # Reserve icons must stay intact until their owner resumes a turn.
        for game in self.games:
            game.rack.lives.defer_reserve_until_turn = True
        # Player 2 must be addressed using the ROM's $22xx bank. Player 1
        # remains in $21xx. No shared mutable game RAM between turns.
        g = self.games[1]
        r = g.rack
        m = r.mem
        m[0x2067] = 0x22
        m[0x20CE] = 1
        m[0x20E7] = m[0x20E8] = 1
        m[0x20E5] = m[0x20E6] = 1
        m[0x22FF] = m[0x21FF]  # initial reserve count
        m[0x22F9] = m[0x21F9]
        m[0x22FA] = m[0x21FA]
        m[0x22FE] = m[0x21FE]
        m[0x21FF] = 0
        install_formation(r, g.round, 0x2200)
        r.shields.init_playfield(player=2)
        r.lives.draw_reserve_ships()
        r.lives.draw_lives_number(min(6, r.lives.stash + 1))
        for game in self.games:
            game.rack.mem[0x20CE] = 1
        self._sync_scores()
        # $0904 calls PromptPlayer ($0A73) for the very first Player 1 turn,
        # before $09CA brings the rack into view. The older integration only
        # invoked this presentation after the first death/turn handoff.
        # Reuse that same transition path so initial start and later player
        # changes show the identical ROM characters and score flashing.
        self.transition = {'phase': 'wait', 'frames': 1, 'previous': 0,
                           'initial_start': True}

    @property
    def rack(self):
        return self.games[self.active].rack

    @property
    def visible_player(self):
        """Which player owns the *displayed* RAM during a handoff."""
        visible = (self.transition['previous'] if self.transition and
                   self.transition['phase'] == 'wait' else self.active)
        return visible + 1

    @property
    def screen_red(self):
        visible = (self.transition['previous'] if self.transition and
                   self.transition['phase'] == 'wait' else self.active)
        return self.games[visible].screen_red

    def image(self):
        visible = (self.transition['previous'] if self.transition and
                   self.transition['phase'] == 'wait' else self.active)
        return self.games[visible].image()

    def _sync_scores(self):
        p1 = self.games[0].rack.mem
        p2 = self.games[1].rack.mem
        # $20F4 high score, $20F8 P1, $20FC P2 (2-byte packed BCD).
        a = bytes(p1[0x20F8:0x20FA])
        b = bytes(p2[0x20FC:0x20FE])
        high = max((bytes(p1[0x20F4:0x20F6]),bytes(p2[0x20F4:0x20F6]),a,b), key=lambda x:(x[1],x[0]))
        for game in self.games:
            r = game.rack
            m = r.mem
            # Synchronise shared score RAM without repainting the HUD on
            # every game tick. During $09CA RackArrive the invaders genuinely
            # overwrite the shared 1-bit video RAM; the ROM restores the
            # heading/digits only at the END of arrival ($0A4D/$1719).
            # The old unconditional repaint erased that visible progression.
            updates = ((0x20F8, a), (0x20FC, b), (0x20F4, high))
            for base, data in updates:
                changed = bytes(m[base:base + 2]) != data
                m[base:base + 2] = data
                if changed and r.score_display.initialised and (
                    game.arrival is None or game.arrival.complete
                ):
                    r.score_display.draw_score(base)

    def _begin_transition(self):
        """$0341-$0365: save outgoing rack reference, then copy ROM RAM mirror.

        The 8080 has ONE shared $2000-$20BF working area, reinitialized by
        $0352 -> $022A on every ordinary two-player handoff.  Our separate
        Python Rack instances otherwise retain missile descriptors between
        turns, incorrectly continuing the old plunger/squiggly table pointers.
        The $21xx/$22xx player banks, scores and VRAM are not part of this copy.
        """
        previous = 1 - self.active
        outgoing = self.games[previous].rack.mem
        bank = outgoing[0x2067] << 8
        # $0341-$0351: Remember the outgoing alien reference in its player bank.
        # The high-level rack may have an arrival descriptor active, but a
        # normal death enters this path after arrival has completed.
        outgoing[bank + 0xFB] = outgoing[0x2008]
        outgoing[bank + 0xFC] = outgoing[0x2009]
        outgoing[bank + 0xFD] = outgoing[0x200A]
        incoming = self.games[self.active].rack.mem
        # $0352: CopyRAMMirror, exact 192 bytes $1B00-$1BBF -> $2000-$20BF.
        # Crucially includes all three missile objects, $2032, $2080 and
        # both ROM firing-column pointers. No manually invented values.
        incoming[0x2000:0x20C0] = incoming[0x1B00:0x1BC0]
        # $0355-$0362 selects the incoming player's bank AFTER the copy.
        incoming[0x2067] = 0x21 + self.active
        self.transition = {'phase': 'wait', 'frames': 128,
                           'previous': previous, 'initial_start': False}

    def _show_player_prompt(self):
        """$0A73: player prompt, then restore shields and rack arrival.

        Each player's Rack is deliberately independent. We save the exact
        damaged shield VRAM before clearing the centre field for $0A73;
        the next rack arrival must not install a new formation or heal shields.
        """
        game = self.games[self.active]
        r = game.rack
        m = r.mem
        # A player's first turn may not yet have begun. RackArrive's
        # constructor suspends ISR game tasks while holding the real rack
        # descriptor in `saved`. Restore that logical state before the
        # ROM player-change prompt, otherwise a second RackArrive mistakes
        # $A8 for the target height and leaves suspendPlay stuck at zero.
        if not game.arrival.complete:
            m[0x2000:0x2010] = game.arrival.saved
            m[0x20E9] = game.arrival.previous_suspend
            m[0x20B9] = 0
            game.arrival.complete = True
        # ROM RemoveShip is deferred until the saved player resumes, not
        # executed as the death sprite finishes on the outgoing screen.
        if r.lives.pending_turn_reserve:
            if r.lives.life_decrement:
                r.lives.remove_ship()
            r.lives.pending_turn_reserve = False
        shields = []
        for shield in range(4):
            base = SHIELD_START + shield * SHIELD_PITCH_BYTES
            shields.append(bytes(m[base + 32 * row + col]
                                 for row in range(22) for col in range(2)))
        # $0373/$0907: the real 8080 clears shared video RAM byte by byte.
        # The outgoing player's image remains in the single arcade VRAM
        # until these writes erase it. Independent Python racks must copy that
        # outgoing *display* first, after saving the incoming shields.
        if not self.transition.get('initial_start', False):
            previous = self.games[self.transition['previous']].rack.mem
            m[0x2400:0x4000] = previous[0x2400:0x4000]
            self.transition.update(phase='clear_for_prompt',
                                   clear=_ROMClearPlayField(m), shields=shields)
            return
        r.lives.game_over_sequence.clear_playfield()
        self._finish_player_prompt(shields)

    def _finish_player_prompt(self, shields):
        game = self.games[self.active]
        r = game.rack
        m = r.mem
        # $0A73: ROM PLAY PLAYER<1> text, $0A87 substitutes digit 2.
        at = 0x2B11
        for code in m[0x1B70:0x1B7E]:
            at = r.score_display.draw_char(code, at)
        if self.active:
            r.score_display.draw_char(0x1E, 0x3711)
        r.score_display.redraw_scores()
        if not self.transition.get('initial_start', False):
            # The $0373 shared-VRAM clear follows the bank's $032C reserve
            # removal. Recreate the incoming bank's lives HUD NOW, before
            # displaying PLAY PLAYER<n>. The later $0907 clear erases this
            # region again, so _finish_arrival_clear() must restore it too.
            # Previously only that late restoration ran: MAME showed 2 in
            # the player prompt while Python inherited the outgoing 3.
            r.lives.draw_reserve_ships()
            r.lives.draw_lives_number(min(6, r.lives.stash + 1))
        # The 176-tick translated prompt countdown omits the original
        # foreground work (screen clear / player field setup) which runs
        # while interrupts continue.  Approximate that work as an additional
        # 23 video-frame budget on the *initial* game start.  The replay's
        # MAME reference has the prompt at 574 and first alien at 593;
        # this is a measured approximation, not a ROM-exact cycle count.
        foreground_setup_frames = 23 if self.transition.get('initial_start') else 0
        self.transition.update(phase='prompt',
                               frames=176 + foreground_setup_frames,
                               shields=shields)

    def _complete_prompt_clear(self, state):
        self._finish_player_prompt(state['shields'])

    def _init_rack_from_player_bank(self):
        """ROM $00CC-$00F1 InitRack, called by $0921 for each new turn.

        The ROM-mirror copy at $0352 resets the working descriptor, but the
        *incoming player's* reference and movement direction live in the
        $21FB-$21FD / $22FB-$22FD bank. Restore them before $09CA RackArrive
        saves its target. In particular, do not treat the mirror's $3878 as
        the position of a returning player.
        """
        m = self.rack.mem
        bank = (m[0x2067] << 8)
        y = m[bank + 0xFC]
        x = m[bank + 0xFD]
        delta = m[bank + 0xFB]
        if delta == 0x03:
            delta = 0x02  # $00DD-$00E2: special one-alien case
        m[0x2009] = m[0x200B] = y
        m[0x200A] = m[0x200C] = x
        m[0x2008] = delta
        m[0x200D] = int(delta == 0xFE)

    def _finish_arrival_clear(self, state):
        game = self.games[self.active]
        r = game.rack
        m = r.mem
        # Restore the player's already-damaged shields (not a fresh template).
        for shield, blob in enumerate(state['shields']):
            base = SHIELD_START + shield * SHIELD_PITCH_BYTES
            for row in range(22):
                for col in range(2):
                    m[base + 32 * row + col] = blob[row * 2 + col]
        for x in range(224):
            m[0x2402 + 32*x] = 1
        if not state.get('initial_start', False):
            # $032C/$1A7F reserve accounting happened at this player's
            # reactivation, but the handoff subsequently copied the outgoing
            # player's VRAM over the corrected HUD. Restore the active bank's
            # ROM life glyph and reserve sprites only AFTER the shared field
            # has been reconstructed; otherwise the incoming screen inherits
            # the outgoing player's stale 3-ships display.
            r.lives.draw_reserve_ships()
            r.lives.draw_lives_number(min(6, r.lives.stash + 1))
        r.score_display.redraw_scores()
        m[0x2068] = 1
        m[0x2000] = 1
        if not state.get('initial_start', False):
            # $0368-$0369 clears obj0 timer on the bank handoff.
            m[0x2011] = 0
        # $0921 calls InitRack AFTER restoring the current player's shields
        # and BEFORE the $092E RackArrive foreground loop. The original
        # initial start is already set up by Part2FirstPlay; on later handoffs
        # the mirror copy has reset $2008-$200C to default rack coordinates.
        if not state.get('initial_start', False):
            self._init_rack_from_player_bank()
        game.arrival = Part2RackArrival(r)
        if state.get('initial_start', False):
            # The ROM runs the beginning of $09CA *in the same frame* that
            # the $0907 setup returns. MAME's first arrival snapshot already
            # has alien cursor index 1 (two operations), not index 0.
            game.arrival.advance(operations=2)
        self.transition = None

    def _advance_transition(self):
        """$0A8A-$0AB4: roughly 176 ISR ticks; flash active score.

        Actual ISR/frame phase is a later MAME timing check. The ROM alternates
        draw/erase using bit 2 of the ISR countdown.
        """
        state = self.transition
        if state is None:
            return False
        if state['phase'] in ('clear_for_prompt', 'clear_for_arrival'):
            if state['clear'].step():
                if state['phase'] == 'clear_for_prompt':
                    self._complete_prompt_clear(state)
                else:
                    self._finish_arrival_clear(state)
            return True
        if state['phase'] == 'wait':
            state['frames'] -= 1
            if state['frames'] == 0:
                self._show_player_prompt()
            return True
        game = self.games[self.active]
        r = game.rack
        m = r.mem
        counter = state['frames']
        score_base = 0x20FC if self.active else 0x20F8
        if counter & 4:
            at = 0x391C if self.active else 0x261C
            for col in range(40):
                m[at + 32 * col] = 0
        else:
            r.score_display.draw_score(score_base)
        state['frames'] -= 1
        if state['frames'] > 0:
            return True
        if not state.get('initial_start', False):
            # $0907 and $0373 both use $0BA3, not an instantaneous fill.
            # The player-specific RAM remains intact while shared VRAM clears.
            state.update(phase='clear_for_arrival', clear=_ROMClearPlayField(m))
        else:
            r.lives.game_over_sequence.clear_playfield()
            self._finish_arrival_clear(state)
        return True

    def step(self, *, left=False, right=False, fire=False):
        if self.finished:
            return
        if self._advance_transition():
            self.frame += 1
            return
        game = self.games[self.active]
        game.step(left=left,right=right,fire=fire)
        self.frame += 1
        self._sync_scores()
        index = self.active
        lives = game.rack.lives
        # Switch after the original death/explosion handler has completed,
        # not at initial collision. The current rack remains saved intact.
        if lives.deaths != self.death_seen[index]:
            self.death_seen[index] = lives.deaths
            if lives.game_over:
                # $166D/$169F: a final-life explosion enters the ROM's
                # two-player GAME OVER PLAYER<n> printer.  Do not switch
                # immediately: the message needs its 7-tick character pacing
                # and the following hold while the outgoing VRAM is visible.
                self.done[index] = True
                self._synchronise_alive_flags()
            elif not self.done[1-index]:
                # Ordinary death: no GAME OVER message, switch as before.
                self.active = 1-index
                self.switch_count += 1
                self._sync_scores()
                self._begin_transition()
        elif lives.game_over:
            phase = lives.game_over_sequence.phase
            if phase == 'switch_ready':
                # The ROM has finished showing GAME OVER PLAYER<n>.
                if not self.done[1-index]:
                    self.active = 1-index
                    self.switch_count += 1
                    self._sync_scores()
                    self._begin_transition()
                else:
                    self.finished = True
            elif phase == 'attract_pending':
                # Both players have finished and the final end screen held.
                self.finished = True

    def _synchronise_alive_flags(self):
        """Share ROM $20E7/$20E8 player-alive flags across independent racks.

        Each player is modelled by a separate Rack, so an ending player's
        local RAM must know whether the *other* player is already finished.
        """
        p1_alive = 0 if self.done[0] else 1
        p2_alive = 0 if self.done[1] else 1
        for game in self.games:
            game.rack.mem[0x20E7] = p1_alive
            game.rack.mem[0x20E8] = p2_alive
