"""Observe native Python Part II ISR stages during the existing INP replay.

Diagnostic only; does not modify any ROM data, scheduling or game logic.
Snapshots occur at source-level dispatch boundaries, not individual byte stores.
"""
from __future__ import annotations
import argparse
import csv
from pathlib import Path

WATCH = (0x2072,0x2008,0x200A,0x200B,0x200D,0x2032,
         0x2035,0x2036,0x203D,0x203E,0x2080,0x2015,0x2069,0x206A)
NAMES = ('2072','2008','200A','200B','200D','2032','2035','2036',
         '203D','203E','2080','2015','2069','206A')

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--inp', default='part2_2player.inp')
    p.add_argument('--output', default='part2_python_missile_phases.csv')
    p.add_argument('--start', type=int, default=1800)
    p.add_argument('--end', type=int, default=1900)
    args = p.parse_args()
    from part2_inp import decode
    from interrupts import InterruptScheduler
    from part2_two_player import Part2TwoPlayer
    from part2_headless import run_headless
    rec = decode(args.inp)
    starts = [e.frame for e in rec.events if e.name == 'start2' and e.pressed]
    if len(starts) != 1:
        raise ValueError('Expected one 2-player start in the recorded INP')
    game_start = starts[0]
    absolute_frame = -1
    current_player = 1
    sequence = 0
    previous = {}
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    original_step = Part2TwoPlayer.step
    original_emit = InterruptScheduler.emit
    original_96 = InterruptScheduler.scanline_96
    original_224 = InterruptScheduler.scanline_224
    original_main = InterruptScheduler.main_loop_service
    with output.open('w', newline='', encoding='utf-8') as fp:
        out = csv.writer(fp)
        out.writerow(('frame','sequence','player','phase','event','changed_addresses',*(f'm_{n}' for n in NAMES)))
        def snapshot(scheduler, phase, event):
            nonlocal sequence
            if not args.start <= absolute_frame <= args.end:
                return
            mem = scheduler.rack.mem
            state = tuple(mem[a] for a in WATCH)
            key = id(scheduler)
            prior = previous.get(key)
            changed = ','.join(f'{WATCH[i]:04X}' for i,(a,b) in enumerate(zip(prior, state)) if a != b) if prior else ''
            sequence += 1
            out.writerow((absolute_frame,sequence,current_player,phase,event,changed,
                          *(f'{v:02X}' for v in state)))
            previous[key] = state
        def step(self, *, left=False, right=False, fire=False):
            nonlocal absolute_frame,current_player
            absolute_frame = game_start + self.frame
            current_player = self.active + 1
            return original_step(self,left=left,right=right,fire=fire)
        def emit(self, phase, rom, name, status):
            snapshot(self, phase, rom + ':' + name)
            return original_emit(self,phase,rom,name,status)
        def mid(self):
            snapshot(self, 'SCANLINE96','ENTER')
            result=original_96(self)
            snapshot(self, 'SCANLINE96','EXIT')
            return result
        def end(self):
            snapshot(self, 'VBLANK','ENTER')
            result=original_224(self)
            snapshot(self, 'VBLANK','EXIT')
            return result
        def mainloop(self):
            snapshot(self,'MAIN','ENTER')
            result=original_main(self)
            snapshot(self,'MAIN','EXIT')
            return result
        Part2TwoPlayer.step = step
        InterruptScheduler.emit = emit
        InterruptScheduler.scanline_96 = mid
        InterruptScheduler.scanline_224 = end
        InterruptScheduler.main_loop_service = mainloop
        try:
            run_headless(playback_inp=args.inp, frames=args.end+1)
        finally:
            Part2TwoPlayer.step = original_step
            InterruptScheduler.emit = original_emit
            InterruptScheduler.scanline_96 = original_96
            InterruptScheduler.scanline_224 = original_224
            InterruptScheduler.main_loop_service = original_main
    print(f'Saved {output}; Python ISR dispatch snapshots for frames {args.start}–{args.end}.')

if __name__ == '__main__':
    main()
