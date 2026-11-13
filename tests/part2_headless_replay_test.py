"""Regression checks for the deterministic Part II INP replay machinery."""
import csv
import tempfile
from pathlib import Path
import unittest
from part2_inp import decode
from part2_headless import run_headless

ROOT = Path(__file__).resolve().parents[1]


class HeadlessINPReplay(unittest.TestCase):
    def test_real_inp_events(self):
        rec = decode(ROOT / 'part2_2player.inp')
        self.assertEqual(rec.frames, 7300)
        self.assertEqual([(e.frame, e.name, e.pressed) for e in rec.events], [
            (297, 'coin', True), (301, 'coin', False),
            (333, 'coin', True), (336, 'coin', False),
            (393, 'start2', True), (397, 'start2', False)])

    def test_credit_and_two_player_start(self):
        with tempfile.TemporaryDirectory() as d:
            trace = Path(d) / 'trace.csv'
            run_headless(frames=410, playback_inp=ROOT / 'part2_2player.inp', state_trace=trace)
            with trace.open(newline='') as f:
                rows = list(csv.DictReader(f))
            self.assertEqual(len(rows), 410)
            self.assertEqual((rows[296]['phase'], rows[296]['credits']), ('title', '0'))
            self.assertEqual((rows[297]['phase'], rows[297]['credits']), ('wait_start', '1'))
            self.assertEqual(rows[333]['credits'], '2')
            self.assertEqual((rows[392]['phase'], rows[392]['credits']), ('wait_start', '2'))
            self.assertEqual((rows[393]['phase'], rows[393]['credits'], rows[393]['player']),
                             ('play', '0', '1'))
            self.assertEqual((rows[393]['p1_lives'], rows[393]['p2_lives']), ('2', '2'))
            self.assertEqual((rows[393]['p1_done'], rows[393]['p2_done']), ('0', '0'))

    def test_headless_crc_without_pygame(self):
        with tempfile.TemporaryDirectory() as d:
            csv_path = Path(d) / 'crc.csv'
            run_headless(frames=5, playback_inp=ROOT / 'part2_2player.inp', frame_crc=csv_path)
            with csv_path.open(newline='') as f:
                rows = list(csv.DictReader(f))
            self.assertEqual(len(rows), 5)
            self.assertTrue(all(len(row['rgb_crc32']) == 8 for row in rows))

if __name__ == '__main__':
    unittest.main()
