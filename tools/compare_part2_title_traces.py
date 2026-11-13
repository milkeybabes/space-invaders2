"""Compare cold-boot MAME and Python Part II title VRAM traces.

Usage:
  python compare_part2_title_traces.py part2_title_mame_frames.csv

Runs the translated Python scene independently, then writes a pair of diagnostic
CSVs to diagnostics/. This script never changes gameplay or timing constants.
"""
import argparse
import csv
from pathlib import Path
from trace_part2_title_python import trace


def load(path):
    with Path(path).open(newline='', encoding='utf-8-sig') as fp:
        return {int(row['frame']): row for row in csv.DictReader(fp)}


def as_int(row, col):
    return int(row[col]) if row and row.get(col) else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('mame_csv', type=Path)
    ap.add_argument('--output-dir', type=Path, default=Path('diagnostics'))
    args = ap.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    mame = load(args.mame_csv)
    if not mame:
        ap.error('empty MAME trace')
    first, last = min(mame), max(mame)
    python_path = args.output_dir / 'part2_title_python_frames.csv'
    trace(first, last, python_path)
    python = load(python_path)
    keys = ('vram_bits_set', 'bytes_changed', 'bits_cleared', 'bits_added')
    outpath = args.output_dir / 'part2_title_comparison.csv'
    with outpath.open('w', newline='', encoding='utf-8') as fp:
        writer = csv.writer(fp)
        writer.writerow(('mame_frame', 'python_frame', 'mame_bits', 'python_bits',
                         'mame_bytes_changed', 'python_bytes_changed',
                         'mame_cleared', 'python_cleared', 'mame_added', 'python_added',
                         'mame_first_address', 'python_first_address'))
        for f in sorted(mame.keys() & python.keys()):
            m,p = mame[f],python[f]
            writer.writerow((f,f,as_int(m,keys[0]),as_int(p,keys[0]),
                             as_int(m,keys[1]),as_int(p,keys[1]),
                             as_int(m,keys[2]),as_int(p,keys[2]),
                             as_int(m,keys[3]),as_int(p,keys[3]),
                             m.get('first_changed_address',''),p.get('first_changed_address','')))
    def onset(source, name):
        matches = [f for f,r in source.items() if as_int(r,'bits_cleared') > 0]
        return min(matches) if matches else None
    def fill_last(source):
        matches = [f for f,r in source.items() if as_int(r,'bits_added') > 0]
        return max(matches) if matches else None
    mcarve, pcarve = onset(mame,'MAME'), onset(python,'Python')
    mfill,pfill=fill_last(mame),fill_last(python)
    print(f'MAME last dot addition: {mfill}; Python: {pfill}')
    print(f'MAME first carving: {mcarve}; Python: {pcarve}')
    if mcarve is not None and pcarve is not None:
        print(f'Carve onset offset (MAME - Python): {mcarve-pcarve} frames')
    print(f'Comparison written: {outpath}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
