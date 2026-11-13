"""The coin wipe must preserve VRAM and finish near MAME frame 310."""
import unittest
from part2_attract import Part2AttractPreview
from part2_attract_screens import Part2CreditWipe, Part2AttractScreen


class CreditWipeChecks(unittest.TestCase):
    def test_progressive_clear_and_converge(self):
        demo = Part2AttractPreview()
        for _ in range(297):
            demo.step()
        before = bytes(demo.title.mem[0x2400:0x4000])
        wipe = Part2CreditWipe(demo.title.mem, credits=1)
        wipe.step()  # MAME frame 297
        after = bytes(wipe.mem[0x2400:0x4000])
        self.assertNotEqual(before, after)
        self.assertTrue(any(after))
        self.assertFalse(wipe.complete)
        for _ in range(13):
            wipe.step()
        self.assertTrue(wipe.complete)
        exact = Part2AttractScreen('wait_start', credits=1)
        self.assertEqual(wipe.image(), exact.image())

    def test_second_coin_updates_pending_status(self):
        demo = Part2AttractPreview()
        wipe = Part2CreditWipe(demo.title.mem, credits=1)
        wipe.step()
        wipe.set_credits(2)
        for _ in range(20):
            wipe.step()
        self.assertEqual(wipe.image(), Part2AttractScreen('wait_start', 2).image())

if __name__ == '__main__':
    unittest.main()
