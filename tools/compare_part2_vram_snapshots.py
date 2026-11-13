"""Compare cold-start MAME and Python raw title VRAM at event checkpoints.

Usage:
    python compare_part2_vram_snapshots.py . diagnostics
The first argument is MAME's snapshot directory, the second Python's.
This does NOT assume that lit-pixel counts imply identical image contents.
"""
import argparse
import zlib
from pathlib import Path
PAIRS = ((270,273,'INVADERS dot fill end'),
         (334,337,'First INVADERS carve'),
         (360,364,'INVADERS carve end'))

def compare(mame_dir, python_dir):
    for pf,mf,label in PAIRS:
        mpath = Path(mame_dir)/f'part2_mame_vram_{mf:03d}.bin'
        ppath = Path(python_dir)/f'part2_python_vram_{pf:03d}.bin'
        if not mpath.is_file() or not ppath.is_file():
            print(f'{label}: missing file ({mpath if not mpath.is_file() else ppath})')
            continue
        m,p=mpath.read_bytes(),ppath.read_bytes()
        if len(m)!=7168 or len(p)!=7168:
            raise ValueError(f'Unexpected VRAM file sizes: MAME={len(m)} Python={len(p)}')
        diffs=[i for i,(a,b) in enumerate(zip(m,p)) if a!=b]
        bits_m=sum(a.bit_count() for a in m)
        bits_p=sum(a.bit_count() for a in p)
        first=(f'{0x2400+diffs[0]:04X}' if diffs else 'none')
        print(f'{label}: MAME {mf} vs Python {pf}: mismatched bytes={len(diffs)}, '
              f'first={first}, lit bits={bits_m}/{bits_p}, '
              f'CRC32={zlib.crc32(m):08X}/{zlib.crc32(p):08X}')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mame_dir',nargs='?',type=Path,default=Path('.'))
    parser.add_argument('python_dir',nargs='?',type=Path,default=Path('diagnostics'))
    args=parser.parse_args()
    compare(args.mame_dir,args.python_dir)
