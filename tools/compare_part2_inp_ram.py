"""Compare common RAM ($2000-$20FF) in MAME and Python INP traces.

Python maintains independent per-player Racks; the MAME program uses shared RAM
and bank-switched $21xx/$22xx data. Therefore this is a diagnostic comparison,
NOT a guarantee all per-bank bytes are directly equivalent.
"""
import argparse
import csv
from pathlib import Path

AREAS = {
    'alien_and_player_objects': (0x2000, 0x202F),
    'missile_objects': (0x2030, 0x205F),
    'firing_and_bank': (0x2060, 0x206F),
    'shot_sync': (0x2080, 0x208F),
    'rates_and_state': (0x20C0, 0x20EF),
    'scores': (0x20F0, 0x20FF),
}

def rows(path):
    with open(path, newline='', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            yield int(row['frame']), bytes.fromhex(row['ram_2000_22ff'])

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mame', type=Path)
    p.add_argument('python', type=Path)
    p.add_argument('--offset', type=int, default=0,
                   help='MAME frame = Python frame + offset (calibrate using input edge)')
    p.add_argument('--start', type=int, default=1750)
    p.add_argument('--end', type=int, default=4200)
    p.add_argument('--player', type=int, choices=[1,2], default=1,
                   help='Select the corresponding Python per-player rack, even when inactive')
    p.add_argument('--limit', type=int, default=80)
    a = p.parse_args()
    mame = dict(rows(a.mame))
    python = dict(rows(a.python))
    count = 0
    for frame in range(a.start, a.end + 1):
        m = mame.get(frame+a.offset)
        py = python.get(frame)
        if m is None or py is None or len(m) != 0x300 or len(py) != 0x300:
            continue
        for name, (start, end) in AREAS.items():
            differences = [(addr, m[addr-0x2000], py[addr-0x2000])
                           for addr in range(start,end+1)
                           if m[addr-0x2000] != py[addr-0x2000]]
            if differences and count < a.limit:
                print(f'P{a.player} Python {frame} / MAME {frame+a.offset}: {name}: ' +
                      ', '.join(f'${addr:04X}={mv:02X}/{pv:02X}' for addr,mv,pv in differences[:12]) +
                      (' ...' if len(differences)>12 else ''))
                count += 1
        if count >= a.limit: break
    print('Each value is MAME/Python; differences in non-active banks or phase are expected.')
if __name__ == '__main__': main()
