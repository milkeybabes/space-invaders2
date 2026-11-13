"""Export equivalent raw VRAM snapshots at exact Python frame numbers.
Usage: python trace_part2_title_vram_python.py
"""
from pathlib import Path
from part2_attract import Part2AttractPreview
FRAMES = (270, 273, 334, 337, 360, 364)

def capture(output=Path('diagnostics')):
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    p = Part2AttractPreview()
    saved = []
    for _ in range(max(FRAMES)):
        p.step()
        if p.frame in FRAMES:
            file = output / f'part2_python_vram_{p.frame:03d}.bin'
            data = bytes(p.title.mem[0x2400:0x4000])
            assert len(data) == 7168
            file.write_bytes(data)
            saved.append(file)
    return saved

if __name__ == '__main__':
    for path in capture(): print('Saved', path)
