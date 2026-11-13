"""Compare Part II missile launch, rack-wrap and player-hit frames in MAME/Python RAM.

Usage:
  python diagnose_part2_launch_phase.py part2_mame_inp_ram.csv v20_compare_p1.csv --start 1800 --end 1900

This is a diagnostic, not a frame-offset correction. RAM samples are from
separate emulator and translator capture points; review $2072 when interpreting
sub-frame differences.
"""
import argparse
import csv
from pathlib import Path

BASE = 0x2000

def read(path):
    result = {}
    with Path(path).open(newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        field = next((x for x in reader.fieldnames if x.startswith('ram_')), None)
        if field is None:
            raise ValueError(f'No RAM column in {path}')
        for row in reader:
            if row[field]:
                b = bytes.fromhex(row[field])
                if len(b) < 0x100:
                    raise ValueError(f'Incomplete RAM at frame {row["frame"]}')
                result[int(row['frame'])] = b
    return result

def get(b, address):
    return b[address-BASE]

def changes(rows, begin, end):
    out = []
    for n in range(begin, end + 1):
        if n not in rows:
            continue
        b = rows[n]; previous = rows.get(n - 1)
        if previous is None:
            continue
        reasons = []
        if get(previous, 0x2035) & 0x80 == 0 and get(b, 0x2035) & 0x80:
            reasons.append('ROLLING_LAUNCH')
        if get(previous, 0x200A) != get(b, 0x200A):
            reasons.append('RACK_REF_CHANGE')
        if get(previous, 0x2015) == 0xFF and get(b, 0x2015) != 0xFF:
            reasons.append('PLAYER_HIT')
        if reasons:
            out.append((n, ','.join(reasons), get(previous, 0x200A), get(b, 0x200A),
                        get(b, 0x2006), get(b, 0x2035), get(b, 0x203D), get(b, 0x203E),
                        get(b, 0x2032), get(b, 0x2080), get(b, 0x2072)))
    return out

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mame_csv')
    p.add_argument('python_csv')
    p.add_argument('--start', type=int, default=1800)
    p.add_argument('--end', type=int, default=1900)
    args = p.parse_args()
    print('source,frame,event,ref_before,ref_after,cursor,rolling_status,shot_203D,shot_203E,timer_2032,sync_2080,beam_2072')
    for name, path in [('MAME', args.mame_csv), ('PYTHON', args.python_csv)]:
        for v in changes(read(path), args.start, args.end):
            n, reason, ref0, ref1, cursor, status, b, c, timer, sync, beam = v
            print(f'{name},{n},{reason},{ref0:02X},{ref1:02X},{cursor:02X},{status:02X},{b:02X},{c:02X},{timer:02X},{sync:02X},{beam:02X}')

if __name__ == '__main__':
    main()
