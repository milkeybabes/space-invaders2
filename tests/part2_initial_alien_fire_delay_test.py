"""Regression: Part II playable startup must not use the Stage-7 shot shortcut."""
import unittest
from part2_first_play import Part2FirstPlay


class AlienFireStartupTest(unittest.TestCase):
    def test_first_rack_waits_for_player_object_countdown(self):
        game = Part2FirstPlay()
        rack = game.rack
        self.assertEqual(rack.mem[0x2069], 0)
        self.assertEqual(rack.mem[0x206A], 0x30)
        for _ in range(200):
            if game.arrival.complete:
                break
            game.step()
            self.assertEqual(rack.mem[0x2069], 0)
        self.assertTrue(game.arrival.complete)
        for _ in range(400):
            if rack.mem[0x2069]:
                break
            game.step()
        self.assertEqual(rack.mem[0x2069], 1)
        self.assertEqual(rack.mem[0x206A], 0)


if __name__ == '__main__':
    unittest.main()
