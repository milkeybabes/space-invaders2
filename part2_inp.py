"""Decode MAME 0.282 INP v3 for Taito Space Invaders Part II (invadpt2).

The recording stream is zlib compressed after the 64-byte MAME header.
Per video frame: signed seconds (4), attoseconds (8), speed (4), then six
input ports with unsigned 32-bit default and digital state (8 each).
Only port 4 digital bits 0/1 change in the attached no-controls recording.

The logical pulse events are saved, not guesses based on AVI frames. No
hardcoded input frame numbers are used by the replay runner.
"""
from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
import argparse
import csv
import struct
import zlib

HEADER_SIZE = 64
PORT_COUNT = 6
FRAME_SIZE = 16 + PORT_COUNT * 8
FRAME_FORMAT = '<iqI' + 'II' * PORT_COUNT
DRIVER = 'invadpt2'
INPUT_PORT = 4
INPUT_BITS = {0x01: 'coin', 0x02: 'start2'}

@dataclass(frozen=True)
class InputEvent:
    frame: int
    name: str
    pressed: bool

@dataclass(frozen=True)
class InputRecording:
    driver: str
    version: str
    frames: int
    events: tuple[InputEvent, ...]


def decode(path: str | Path) -> InputRecording:
    data = Path(path).read_bytes()
    if len(data) < HEADER_SIZE or data[:8] != b'MAMEINP\x00':
        raise ValueError('Not a MAME INP file (magic/header mismatch)')
    major, minor = data[0x10:0x12]
    if major != 3:
        raise ValueError(f'Unsupported MAME INP major version {major}')
    driver = data[0x14:0x20].partition(b'\0')[0].decode('ascii')
    if driver != DRIVER:
        raise ValueError(f'Only {DRIVER} input layout is supported; got {driver!r}')
    try:
        stream = zlib.decompress(data[HEADER_SIZE:])
    except zlib.error as exc:
        raise ValueError('Invalid compressed INP input stream') from exc
    if len(stream) % FRAME_SIZE:
        raise ValueError(f'INP byte count {len(stream)} is not a multiple of {FRAME_SIZE}')
    events = []
    prev = 0
    previous_t = -1
    total = len(stream) // FRAME_SIZE
    for frame in range(total):
        row = struct.unpack_from(FRAME_FORMAT, stream, frame * FRAME_SIZE)
        sec, attosec, speed = row[:3]
        instant = sec * 10**18 + attosec
        if instant <= previous_t:
            raise ValueError(f'Non-monotonic MAME clock at frame {frame}')
        previous_t = instant
        defaults = row[3::2]
        digital = row[4::2]
        if any(digital[n] for n in range(PORT_COUNT) if n != INPUT_PORT):
            raise ValueError(f'Unexpected active port at frame {frame}')
        value = digital[INPUT_PORT]
        if value & ~0x03:
            raise ValueError(f'Unknown input bits 0x{value:x} at frame {frame}')
        changes = prev ^ value
        for bit, name in INPUT_BITS.items():
            if changes & bit:
                events.append(InputEvent(frame, name, bool(value & bit)))
        prev = value
    if prev:
        raise ValueError('Recording ends with an input still held')
    return InputRecording(driver, f'{major}.{minor}', total, tuple(events))


def write_events_csv(recording: InputRecording, outfile: str | Path) -> None:
    with Path(outfile).open('w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(('frame', 'input', 'pressed'))
        for event in recording.events:
            writer.writerow((event.frame, event.name, int(event.pressed)))


def event_lookup(recording: InputRecording):
    grouped = {}
    for ev in recording.events:
        grouped.setdefault(ev.frame, []).append(ev)
    return grouped


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('inp', type=Path)
    p.add_argument('--csv', type=Path, help='write exact press/release frame CSV')
    args = p.parse_args()
    recording = decode(args.inp)
    print(f'{recording.driver}: MAME INP v{recording.version}, {recording.frames} frames')
    for ev in recording.events:
        print(f'frame {ev.frame:5}: {ev.name:8} {"DOWN" if ev.pressed else "UP"}')
    if args.csv:
        write_events_csv(recording, args.csv)
        print('CSV:', args.csv)

if __name__ == '__main__':
    main()
