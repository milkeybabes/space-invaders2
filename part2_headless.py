"""Window-free MAME INP replay, state logging and optional native RGB AVI capture.

Uses the same Part2AttractPreview, Part2FirstPlay and Part2TwoPlayer game
objects as the pygame UI. No CPU emulation and no pygame dependency.
"""
from __future__ import annotations
import csv
from pathlib import Path
import zlib
from part2_attract import Part2AttractPreview
from part2_colour import Part2Colour
from part2_inp import decode, event_lookup

WIDTH, HEIGHT = 224, 256


def run_headless(*, frames=0, playback_inp=None, frame_crc=None,
                 record=None, avi_height=260, mono=False,
                 debug=False, start_level=1, starting_lives=3, state_trace=None, ram_trace=None):
    # Local import avoids a pygame import: part2_play only imports pygame
    # after dispatching to this function.
    from part2_play import start_avi_recording, native_avi_frame
    from part2_attract_screens import Part2AttractScreen, Part2CreditWipe
    from part2_first_play import Part2FirstPlay
    from part2_two_player import Part2TwoPlayer

    if not playback_inp and not frames:
        frames = 1500
    rec = decode(playback_inp) if playback_inp else None
    events = event_lookup(rec) if rec else {}
    if rec is not None and not frames:
        frames = rec.frames
    if frames < 0 or (rec is not None and frames > rec.frames):
        raise ValueError('Requested frame count exceeds the available INP recording')

    demo = Part2AttractPreview()
    colour = Part2Colour() if record or frame_crc else None
    credits = 0
    credit_screen = None
    played_once = False
    game = None
    writer = None
    crc_file = None
    state_file = None
    ram_files = []
    captured = 0
    try:
        if record:
            writer = start_avi_recording(Path(record), WIDTH, avi_height)
        if frame_crc:
            target = Path(frame_crc)
            target.parent.mkdir(parents=True, exist_ok=True)
            crc_file = target.open('w', newline='', encoding='utf-8')
            crc_out = csv.writer(crc_file)
            crc_out.writerow(('frame', 'rgb_crc32', 'phase', 'player', 'credits'))
        if state_trace:
            target = Path(state_trace)
            target.parent.mkdir(parents=True, exist_ok=True)
            state_file = target.open('w', newline='', encoding='utf-8')
            state_out = csv.writer(state_file)
            state_out.writerow(('frame', 'phase', 'player', 'credits', 'transition',
                                'p1_lives', 'p2_lives', 'p1_deaths', 'p2_deaths',
                                'p1_done', 'p2_done', 'rack_frame', 'alien_count'))

        if ram_trace:
            target = Path(ram_trace)
            target.parent.mkdir(parents=True, exist_ok=True)
            # MAME has one address space; the Python translation has two
            # independent per-player racks. Preserve both for diagnosis.
            for player_number in (1, 2):
                path = target.with_name(target.stem + f'_p{player_number}' + (target.suffix or '.csv'))
                fp = path.open('w', newline='', encoding='utf-8')
                wr = csv.writer(fp)
                wr.writerow(('frame', 'ram_2000_22ff'))
                ram_files.append((fp, wr, player_number))

        for frame in range(frames):
            for event in events.get(frame, ()):
                if not event.pressed:
                    continue
                if event.name == 'coin':
                    credits = min(99, credits + 1)
                    if game is None:
                        if credit_screen is None and not played_once:
                            previous = (demo.title.mem if demo.phase == 'title' else
                                        demo.rack.mem if demo.phase == 'demo' else demo.screen.mem)
                            credit_screen = Part2CreditWipe(previous, credits=min(credits, 9))
                        elif isinstance(credit_screen, Part2CreditWipe) and not credit_screen.complete:
                            credit_screen.set_credits(credits)
                        else:
                            credit_screen = Part2AttractScreen('wait_start', credits=min(credits, 9), post_game=played_once)
                elif event.name == 'start2' and game is None and credits >= 2:
                    credits -= 2
                    game = Part2TwoPlayer(debug=debug, start_level=start_level, starting_lives=starting_lives)
                    played_once = True
                    credit_screen = None
            if game is None:
                if credit_screen is None:
                    demo.step()
                elif isinstance(credit_screen, Part2CreditWipe):
                    credit_screen.step()
            else:
                game.step(left=False, right=False, fire=False)
                if (getattr(game, 'finished', False) or
                        (not hasattr(game, 'games') and game.rack.lives.game_over and
                         game.rack.lives.game_over_sequence.phase == 'attract_pending')):
                    demo = Part2AttractPreview(post_game=True, post_game_mem=game.rack.mem)
                    game = None
                    credit_screen = None

            phase = (getattr(game, 'phase', 'play') if game is not None else
                     'wait_start' if credit_screen is not None else demo.phase)
            player = (game.active + 1 if hasattr(game, 'games') else 1) if game is not None else 0
            if state_file is not None:
                if game is not None and hasattr(game, 'games'):
                    gs = game.games
                    states = [(g.rack.lives.stash, g.rack.lives.deaths) for g in gs]
                    done = game.done
                    transition = game.transition['phase'] if game.transition else ''
                    player = game.active + 1
                elif game is not None:
                    states = [(game.rack.lives.stash, game.rack.lives.deaths), ('', '')]
                    done = [game.rack.lives.game_over, '']
                    transition = ''
                else:
                    states = [('', ''), ('', '')]
                    done = ['', '']
                    transition = ''
                rack = game.rack if game is not None else demo.rack
                state_out.writerow((frame, phase, player, credits, transition,
                                    states[0][0], states[1][0], states[0][1], states[1][1],
                                    int(done[0]) if done[0] != '' else '',
                                    int(done[1]) if done[1] != '' else '',
                                    rack.frames, rack.mem[0x206B]))
            if ram_files:
                if game is not None and hasattr(game, 'games'):
                    memories = [game.games[0].rack.mem, game.games[1].rack.mem]
                elif game is not None:
                    memories = [game.rack.mem, None]
                else:
                    current = (credit_screen.mem if credit_screen is not None and hasattr(credit_screen, 'mem')
                               else demo.rack.mem if demo.rack is not None else None)
                    memories = [current, None]
                for fp, wr, number in ram_files:
                    mem = memories[number - 1]
                    wr.writerow((frame, bytes(mem[0x2000:0x2300]).hex().upper() if mem is not None else ''))
            if writer is not None or crc_file is not None:
                if credit_screen is not None:
                    raw = credit_screen.image()
                elif game is not None:
                    raw = game.image()
                elif demo.phase == 'demo':
                    raw = demo.rack.portrait_luma()
                elif demo.phase == 'title':
                    raw = demo.title.image()
                else:
                    raw = demo.screen.image()
                rgb = (bytes(component for pixel in raw for component in (pixel, pixel, pixel)) if mono else
                       colour.apply(raw, player=(game.visible_player if game is not None and hasattr(game, "visible_player") else 1), screen_red=bool(game and game.screen_red)))
                if crc_file is not None:
                    crc_out.writerow((frame, f'{zlib.crc32(rgb):08X}', phase, player, credits))
                if writer is not None:
                    writer.stdin.write(native_avi_frame(rgb, avi_height))
                    captured += 1
        print(f'PASS: {frames} deterministic frames processed' +
              (f'; {len(rec.events)} INP edges' if rec else ''))
        return frames
    finally:
        if crc_file is not None:
            crc_file.close()
        if state_file is not None:
            state_file.close()
        for fp, _, _ in ram_files:
            fp.close()
        if writer is not None:
            writer.stdin.close()
            status = writer.wait()
            if status:
                raise RuntimeError(f'ffmpeg AVI encoding failed with code {status}')
            print(f'AVI saved: {record} ({captured} frames)')
