"""Read-only per-frame Part II title trace for comparison with MAME.

Run from the project directory:
    python trace_part2_title_python.py
Output: diagnostics/part2_title_python_frames.csv
The trace uses absolute frame numbers from cold start (same as Part2AttractPreview).
"""
from __future__ import annotations
import argparse
import csv
from pathlib import Path
from part2_attract import Part2AttractPreview


def trace(first=250, last=400, output=Path('diagnostics/part2_title_python_frames.csv')):
    preview = Part2AttractPreview()
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    previous = None
    with output.open('w', newline='', encoding='utf-8') as out:
        writer = csv.writer(out)
        writer.writerow(('frame', 'phase', 'title_action', 'irq_wait', 'operation_index',
                         'pending_cycles', 'vram_bits_set', 'bytes_changed',
                         'bits_cleared', 'bits_added', 'first_changed_address'))
        for _ in range(last):
            preview.step()
            vram = bytes(preview.title.mem[0x2400:0x4000])
            changed = removed = added = 0
            first_address = ''
            if previous is not None:
                for i, (before, after) in enumerate(zip(previous, vram)):
                    if before != after:
                        changed += 1
                        removed += (before & ~after).bit_count()
                        added += (~before & after & 255).bit_count()
                        if not first_address:
                            first_address = f'{0x2400 + i:04X}'
            if preview.frame >= first:
                writer.writerow((preview.frame, preview.phase, preview.action,
                                 preview.wait, preview.title.index,
                                 preview.title.pending_cycles,
                                 sum(x.bit_count() for x in vram), changed,
                                 removed, added, first_address))
            previous = vram
    print(f'Title frame trace saved: {output}')
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--first', type=int, default=250)
    parser.add_argument('--last', type=int, default=400)
    parser.add_argument('--output', type=Path, default=Path('diagnostics/part2_title_python_frames.csv'))
    args = parser.parse_args()
    if args.first < 1 or args.last < args.first:
        parser.error('invalid frame range')
    trace(args.first, args.last, args.output)
