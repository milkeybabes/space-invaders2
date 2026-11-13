"""Space Invaders Part II — source-translated Python arcade game.

  python part2_play.py
  python part2_play.py --lives 4
  python part2_play.py --debug
  python part2_play.py --artwork bezel
  python part2_play.py --test-high-score --artwork bezel
  python part2_play.py --playback-inp part2_2player.inp --record replay.avi

Original 8080 gameplay algorithms have been translated into native Python.
Original graphics/text/formation/colour tables are static Python resources;
no external arcade ROM files are needed. Foreground CPU-work pacing is
approximated where the 8080 disassembly uses instruction timing.
"""
from __future__ import annotations
import argparse
import csv
import zlib
import shutil
import subprocess
from pathlib import Path
from part2_attract import Part2AttractPreview
from part2_colour import Part2Colour

WIDTH, HEIGHT = 224, 256
MAME_HEIGHT = 260  # MAME visible output; original game bitmap remains 224x256.
FPS = 59.541985


def start_avi_recording(path: Path, width: int, height: int):
    """Open a standard uncompressed 24-bit AVI writer (Premiere-friendly)."""
    ffmpeg = shutil.which('ffmpeg')
    if ffmpeg is None:
        raise SystemExit('AVI capture requires FFmpeg on PATH (ffmpeg.exe).')
    path.parent.mkdir(parents=True, exist_ok=True)
    command = [ffmpeg, '-hide_banner', '-loglevel', 'error', '-y',
               '-f', 'rawvideo', '-pixel_format', 'rgb24',
               '-video_size', f'{width}x{height}', '-framerate', str(FPS),
               '-i', '-', '-an', '-c:v', 'rawvideo', '-pix_fmt', 'bgr24',
               '-f', 'avi', str(path)]
    return subprocess.Popen(command, stdin=subprocess.PIPE)


def native_avi_frame(rgb: bytes, height: int = MAME_HEIGHT) -> bytes:
    """Take the exact upright 224x256 RGB game bitmap, optionally pad to MAME 260.

    The extra scanlines are blank; their precise vertical alignment against
    MAME captures remains to be checked (never stretch or interpolate pixels).
    """
    expected = WIDTH * HEIGHT * 3
    if len(rgb) != expected:
        raise ValueError(f'Native RGB frame must have {expected} bytes, got {len(rgb)}')
    if height not in (HEIGHT, MAME_HEIGHT):
        raise ValueError('AVI height must be 256 or 260')
    return rgb + bytes(WIDTH * (height - HEIGHT) * 3)


def unique_screenshot_path(folder: Path, frame_number: int) -> Path:
    """Keep every F12 PNG, including repeated captures of a paused frame."""
    folder = Path(folder)
    for sequence in range(100000):
        candidate = folder / f'part2_frame_{frame_number:07d}_{sequence:03d}.png'
        if not candidate.exists():
            return candidate
    raise RuntimeError('Too many snapshots with one frame number')


def start_key_selection(key_name: str, credits: int, already_playing: bool = False):
    """Select the physical 1P/2P start input, without inventing credits.

    Keys from the number row and numeric keypad share the same ROM input.
    Returns (player_count, remaining_credits); 0 means no new game.
    """
    if already_playing:
        return 0, credits
    required = {'1': 1, '2': 2}.get(key_name, 0)
    if not required or credits < required:
        return 0, credits
    return required, credits - required


def run(headless=False, frames=0, scale=4, mono=False, record=None, avi_height=MAME_HEIGHT,
        debug=False, start_level=1, starting_lives=3, artwork='none', test_high_score=False,
        playback_inp=None, frame_crc=None, state_trace=None, ram_trace=None,
        mute=False, sound_trace=None):
    demo = Part2AttractPreview()
    from part2_first_play import Part2FirstPlay
    game = None
    hi_entry = None
    high_score_memory = None  # previous registration, kept for subsequent credits
    credits = 0
    credit_screen = None
    played_once = False
    recorded_inputs = None
    inp_events = {}
    if playback_inp:
        from part2_inp import decode, event_lookup
        recorded_inputs = decode(playback_inp)
        inp_events = event_lookup(recorded_inputs)
        if frames == 0:
            frames = recorded_inputs.frames
        print(f'INP replay: {recorded_inputs.frames} original MAME frames; {len(recorded_inputs.events)} input edges')
    if ram_trace and not headless:
        raise ValueError('--ram-trace currently requires --headless')
    if headless and not record and not playback_inp and not frame_crc and not ram_trace:
        for _ in range(frames or 1500):
            demo.step()
        print('PASS: Stage 08 automated attract preview', demo.status)
        return

    if headless:
        from part2_headless import run_headless
        return run_headless(frames=frames, playback_inp=playback_inp, frame_crc=frame_crc,
                            record=record, avi_height=avi_height, mono=mono,
                            debug=debug, start_level=start_level, starting_lives=starting_lives,
                            state_trace=state_trace, ram_trace=ram_trace)

    try:
        import pygame
    except ImportError as exc:
        raise SystemExit('Install pygame-ce using: python -m pip install pygame-ce') from exc
    if headless:
        # Useful for repeatable, unattended recording; no desktop window needed.
        import os
        os.environ.setdefault('SDL_VIDEODRIVER', 'dummy')
    pygame.mixer.pre_init(22050, -16, 1, 256)
    pygame.init()
    from part2_audio import Part2Audio
    audio = Part2Audio(pygame, muted=mute, sound_trace=sound_trace)
    if not audio.wav.available:
        print("[SOUND] Audio mixer unavailable; gameplay continues silently")
    else:
        loaded = len(audio.wav.samples)
        if debug:
            print(f"[SOUND] {loaded}/10 samples loaded from {audio.wav.folder}; F9 mutes/unmutes")
        if loaded < 10:
            print("[SOUND] Copy 0.wav through 9.wav from your Part I sounds folder for complete effects")
    colour = Part2Colour()
    scale = max(1, int(scale))
    bezel_surface = None
    if artwork == 'bezel':
        from part2_bezel import prepare_bezel
        bezel_surface, initial_window = prepare_bezel(pygame)
        screen = pygame.display.set_mode(initial_window)
    else:
        screen = pygame.display.set_mode((WIDTH * scale, HEIGHT * scale))
    pygame.display.set_caption('Space Invaders Part II — 5 coin, 1 / 2 start, arrows move, Space fire')
    clock = pygame.time.Clock()
    running = True
    paused = False
    captured = 0
    recorder = None
    crc_file = None
    crc_writer = None
    simulation_frame = 0
    if frame_crc:
        crc_path = Path(frame_crc)
        crc_path.parent.mkdir(parents=True, exist_ok=True)
        crc_file = crc_path.open('w', newline='', encoding='utf-8')
        crc_writer = csv.writer(crc_file)
        crc_writer.writerow(('frame', 'rgb_crc32', 'phase', 'player', 'credits'))
    if record:
        recorder = start_avi_recording(Path(record), WIDTH, avi_height)
        print(f'Recording native uncompressed RGB AVI: {record} ({WIDTH}x{avi_height}, {FPS} fps)')
    if test_high_score:
        from part2_first_play import Part2FirstPlay
        from part2_hi_score_entry import Part2HighScoreEntry
        mock = Part2FirstPlay().rack
        hi_entry = Part2HighScoreEntry(mock.mem)
        print('High-score entry ROM test: left/right, Space press+release to select; Enter to finish')

    def insert_coin():
        nonlocal credits, credit_screen
        credits = min(99, credits + 1)
        if debug:
            print('Part II credits:', credits)
        if game is None:
            from part2_attract_screens import Part2AttractScreen, Part2CreditWipe
            if credit_screen is None and not played_once:
                previous = (demo.title.mem if demo.phase == 'title' else
                            demo.rack.mem if demo.phase == 'demo' else demo.screen.mem)
                credit_screen = Part2CreditWipe(previous, credits=min(credits, 9))
            elif isinstance(credit_screen, Part2CreditWipe) and not credit_screen.complete:
                credit_screen.set_credits(credits)
            else:
                credit_screen = Part2AttractScreen('wait_start', credits=min(credits, 9), post_game=played_once)

    def start_requested(request):
        nonlocal credits, game, played_once, credit_screen
        players, remaining = start_key_selection(request, credits, game is not None)
        if players:
            credits = remaining
            if players == 2:
                from part2_two_player import Part2TwoPlayer
                game = Part2TwoPlayer(debug=debug, start_level=start_level, starting_lives=starting_lives)
            else:
                game = Part2FirstPlay(debug=debug, start_level=start_level, starting_lives=starting_lives)
            if high_score_memory is not None:
                racks = [g.rack for g in game.games] if hasattr(game, 'games') else [game.rack]
                for rack in racks:
                    m = rack.mem
                    m[0x20F4:0x20F6] = high_score_memory[0x20F4:0x20F6]
                    m[0x2340:0x234D] = high_score_memory[0x2340:0x234D]
                    rack.score_display.redraw_scores()
            audio.connect(game)
            played_once = True
            credit_screen = None
            if debug:
                print(f'Part II {players}-PLAYER game started at level {start_level}' + (' [DEBUG]' if debug else ''))
        elif game is None and debug:
            print(f'Part II: {request}-PLAYER START needs {request} credit(s); currently {credits}. Press 5 to insert coins.')

    try:
        while running:
            frame_advance = False
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.KEYUP and hi_entry is not None:
                    if event.key in (pygame.K_SPACE, pygame.K_LCTRL):
                        hi_entry.fire_up()
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE:
                        running = False
                    elif event.key == pygame.K_F9 and not getattr(event, 'repeat', False):
                        is_muted = audio.toggle()
                        if debug:
                            print('[SOUND]', 'MUTED' if is_muted else 'ON')
                    elif hi_entry is not None:
                        # Registration has its own ROM controls: do not
                        # interpret 1/2/5 as normal credit/start keys.
                        if event.key in (pygame.K_RIGHT, pygame.K_d):
                            hi_entry.move(1)
                        elif event.key in (pygame.K_LEFT, pygame.K_a):
                            hi_entry.move(-1)
                        elif event.key in (pygame.K_1, pygame.K_2, pygame.K_RETURN, pygame.K_KP_ENTER):
                            hi_entry.finish()
                        elif event.key in (pygame.K_SPACE, pygame.K_LCTRL):
                            hi_entry.fire_down()
                    elif event.key == pygame.K_F5:
                        paused = not paused
                        audio.pause(paused)
                        pygame.display.set_caption(
                            'Space Invaders Part II — PAUSED (F8: next frame, F5: resume)'
                            if paused else 'Space Invaders Part II — ROM-sequenced attract preview'
                        )
                    elif event.key == pygame.K_F8 and paused and not getattr(event, 'repeat', False):
                        # Advance exactly one simulated frame per physical key press.
                        frame_advance = True
                    elif event.key == pygame.K_5 and not getattr(event, 'repeat', False) and recorded_inputs is None:
                        insert_coin()
                    elif event.key in (pygame.K_1, pygame.K_KP1, pygame.K_2, pygame.K_KP2) and not getattr(event, 'repeat', False) and recorded_inputs is None:
                        # Ignore live coin/start keys during deterministic INP playback.
                        start_requested('2' if event.key in (pygame.K_2, pygame.K_KP2) else '1')
                    elif event.key == pygame.K_F3:
                        audio.reset()
                        demo = Part2AttractPreview()
                        game = None
                        credit_screen = None
                        credits = 0
                        played_once = False
                        credit_screen = None
                    elif event.key == pygame.K_F12:
                        folder = Path(__file__).parent / 'diagnostics'
                        folder.mkdir(exist_ok=True)
                        frame_id = game.frame if game is not None else demo.rack.frames
                        out = unique_screenshot_path(folder, frame_id)
                        pygame.image.save(screen, str(out))
                        print('Screenshot:', out)
                    elif artwork != 'bezel' and event.key in (pygame.K_PLUS, pygame.K_EQUALS, pygame.K_KP_PLUS):
                        scale = min(scale + 1, 8)
                        screen = pygame.display.set_mode((WIDTH * scale, HEIGHT * scale))
                    elif artwork != 'bezel' and event.key in (pygame.K_MINUS, pygame.K_KP_MINUS):
                        scale = max(scale - 1, 1)
                        screen = pygame.display.set_mode((WIDTH * scale, HEIGHT * scale))
            # ESC/QUIT terminates this iteration immediately; do not run another
            # game tick or expensive attract-screen render during shutdown.
            if not running:
                break
            advance = not paused or frame_advance
            if advance:
                # MAME's recorded input values are applied at the beginning of
                # each corresponding video frame (frame_update in ioport.cpp).
                # Only rising edges cause coin/start actions; releases are
                # retained in the decoder for exact replay verification.
                for inp in inp_events.get(simulation_frame, ()):
                    if inp.pressed:
                        if inp.name == 'coin':
                            insert_coin()
                        elif inp.name == 'start2':
                            start_requested('2')
                if hi_entry is not None:
                    hi_entry.step()
                    if hi_entry.finished:
                        high_score_memory = bytearray(hi_entry.mem)
                        demo = Part2AttractPreview(post_game=True, post_game_mem=hi_entry.mem)
                        hi_entry = None
                        game = None
                        audio.reset()
                        credit_screen = None
                elif game is None:
                    if credit_screen is None:
                        demo.step()
                    elif hasattr(credit_screen, 'step'):
                        credit_screen.step()
                else:
                    keys = pygame.key.get_pressed()
                    game.step(left=(keys[pygame.K_LEFT] or keys[pygame.K_a]) if recorded_inputs is None else False,
                              right=(keys[pygame.K_RIGHT] or keys[pygame.K_d]) if recorded_inputs is None else False,
                              fire=(keys[pygame.K_SPACE] or keys[pygame.K_LCTRL]) if recorded_inputs is None else False)
                    audio.switched(game)
                    # Console saucer events are diagnostics, not gameplay output.
                    # Skip scanning the event buffers during normal play.
                    if debug:
                        for event in game.rack.combat.events[-3:]:
                            if event[0] == game.rack.frames and event[1] == 'PART2_SAUCER_HIT':
                                print(f'PART2 SAUCER: shot collided (frame {event[0]})')
                        for event in game.rack.saucer.events[-3:]:
                            if event[0] == game.rack.frames and event[1] in ('SAUCER_SCORE', 'SAUCER_SCORE_LABEL'):
                                print(f'PART2 SAUCER: {event[1]} {event[2]} (frame {event[0]})')
                    # Game-over sequence has returned to ROM's attract handoff.
                    # Restart attract only then; never freeze the last game frame.
                    if (getattr(game, 'finished', False) or
                            (not hasattr(game, 'games') and game.rack.lives.game_over and
                             game.rack.lives.game_over_sequence.phase == 'attract_pending')):
                        from part2_hi_score_entry import Part2HighScoreEntry, pending_registration
                        pending = pending_registration(game)
                        if pending is not None:
                            player, memory = pending
                            hi_entry = Part2HighScoreEntry(memory, player=player)
                            if debug:
                                print(f'HI-SCORER REGISTRATION: Player {player}; LEFT/RIGHT and SPACE release, ENTER ends')
                        else:
                            demo = Part2AttractPreview(post_game=True, post_game_mem=game.rack.mem)
                        game = None
                        audio.reset()
                        credit_screen = None
            # RGB buffer shared by window renderer and recording path.
            rgb = bytes(WIDTH * HEIGHT * 3)
            canvas = pygame.Surface((WIDTH, HEIGHT))
            canvas.fill((0, 0, 0))
            if hi_entry is not None or credit_screen is not None or game is not None or demo.phase in ('demo', 'title', 'score_table', 'insert_coin'):
                raw = (hi_entry.image() if hi_entry is not None else credit_screen.image() if credit_screen is not None else game.image() if game is not None else demo.rack.portrait_luma() if demo.phase == 'demo' else
                       demo.title.image() if demo.phase == 'title' else demo.screen.image())
                # Native 1-bit grayscale expanded to explicit RGB, as in the
                # established v1 pygame-ce renderer (no indexed-P surface).
                rgb = colour.apply(raw, player=(game.visible_player if game is not None and hasattr(game, "visible_player") else 1), screen_red=bool(game and game.screen_red)) if not mono else bytes(channel for pixel in raw for channel in (pixel, pixel, pixel))
                native = pygame.image.frombytes(rgb, (WIDTH, HEIGHT), 'RGB')
                canvas.blit(native, (0, 0))
            # Pause status stays in the window caption, never in the game pixels;
            # F12 screenshots and AVI frames therefore remain clean.
            if artwork == 'bezel':
                from part2_bezel import draw_bezel
                draw_bezel(pygame, screen, canvas, bezel_surface)
            else:
                pygame.transform.scale(canvas, screen.get_size(), screen)
            pygame.display.flip()
            if crc_writer is not None and advance:
                phase = (getattr(game, 'phase', 'play') if game is not None else
                         'wait_start' if credit_screen is not None else demo.phase)
                player = (game.active + 1 if hasattr(game, 'games') else 1) if game is not None else 0
                crc_writer.writerow((simulation_frame, f'{zlib.crc32(rgb):08X}', phase, player, credits))
            if recorder is not None and advance:
                # Capture the game bitmap, NOT the scaled pygame window.
                recorder.stdin.write(native_avi_frame(rgb, avi_height))
                captured += 1
                if frames and captured >= frames:
                    running = False
            elif frames and recorder is None and advance:
                captured += 1
                if captured >= frames:
                    running = False
            if advance:
                simulation_frame += 1
            if not headless:
                clock.tick(FPS)
    except KeyboardInterrupt:
        # Ctrl+C from the attached Command Prompt is also a normal way to exit.
        if debug:
            print('Part II stopped by user.')
    except BrokenPipeError as exc:
        raise RuntimeError('FFmpeg failed while recording AVI') from exc
    finally:
        if crc_file is not None:
            crc_file.close()
            print(f'Frame CRC trace saved: {frame_crc} ({simulation_frame} frames)')
        if recorder is not None:
            recorder.stdin.close()
            rc = recorder.wait()
            if rc:
                raise RuntimeError(f'FFmpeg returned error {rc} while encoding AVI')
            print(f'AVI saved: {record} ({captured} frames)')
        audio.close()
        pygame.quit()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--scale', type=int, default=4)
    p.add_argument('--start-level', '--start', type=int, default=1, metavar='N',
                   help='begin a new game at Part II level N (1-17), after inserting credits and pressing 1 or 2')
    p.add_argument('--debug', action='store_true', help='unlimited ships for testing (collisions and respawns still occur)')
    p.add_argument('--mute', action='store_true', help='start with audio muted (F9 to toggle)')
    p.add_argument('--sound-trace', type=Path, metavar='CSV', help='log sound-port writes and edges during windowed gameplay')
    p.add_argument('--lives', type=int, choices=(3, 4), default=3,
                   help='original Part II 3/4 ships DIP setting (default 3)')
    p.add_argument('--artwork', choices=('none', 'bezel'), default='none',
                   help='optional supplied Part II cabinet bezel, black backing (default none)')
    p.add_argument('--test-high-score', action='store_true',
                   help='open the authentic ROM high-scorer registration controls directly for testing')
    p.add_argument('--headless', action='store_true')
    p.add_argument('--playback-inp', type=Path, metavar='FILE', help='replay MAME invadpt2 INP coin and start events on their exact recorded frame')
    p.add_argument('--ram-trace', type=Path, metavar='CSV', help='save per-frame $2000-$22FF RAM for both Python player states (headless)')
    p.add_argument('--state-trace', type=Path, metavar='CSV', help='log per-frame player lives, deaths, active player and state transitions (headless)')
    p.add_argument('--frame-crc', type=Path, metavar='CSV', help='record CRC32 of each unscaled Python RGB frame')
    p.add_argument('--mono', action='store_true', help='disable colour PROM for comparison')
    p.add_argument('--frames', type=int, default=0, help='stop after this many game frames (0=unlimited in GUI)')
    p.add_argument('--record', nargs='?', const='diagnostics/part2_attract.avi', metavar='AVI', help='record native uncompressed AVI (224x260 by default, independent of window scale)')
    p.add_argument('--avi-height', type=int, choices=(256, 260), default=260, help='AVI height: 260 with 4 blank lines (MAME) or 256 game pixels')
    args = p.parse_args()
    if args.headless and args.sound_trace:
        p.error("--sound-trace requires the interactive window")
    if args.headless and args.test_high_score:
        p.error('--test-high-score requires the interactive window')
    if not 1 <= args.start_level <= 17:
        p.error('--start-level must be between 1 and 17')
    run(headless=args.headless, frames=args.frames, scale=args.scale, mono=args.mono, record=args.record, avi_height=args.avi_height, debug=args.debug, start_level=args.start_level, starting_lives=args.lives,
        artwork=args.artwork, test_high_score=args.test_high_score, playback_inp=args.playback_inp, frame_crc=args.frame_crc, state_trace=args.state_trace, ram_trace=args.ram_trace, mute=args.mute, sound_trace=args.sound_trace)

if __name__ == '__main__':
    main()
