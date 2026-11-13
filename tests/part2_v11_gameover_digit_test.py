"""Regression: the ROM GAME OVER PLAYER<1>/<2> substitutes the real digit font."""
from part2_first_play import Part2FirstPlay


def main():
    for player, bank, digit in ((1, 0x21, 0x1D), (2, 0x22, 0x1E)):
        game = Part2FirstPlay()
        r = game.rack
        r.mem[0x2067] = bank
        seq = r.lives.game_over_sequence
        r.mem[0x20CE] = 1
        seq.begin()
        assert seq.phase == "multi_message"
        for _ in range(18 * 7 + 1):
            seq.step_frame()
        assert seq.index == 19, (player, seq.index)
        addr = 0x2803 + 18 * 0x100
        drawn = bytes(r.mem[addr + i * 32] for i in range(8))
        expected = bytes((r.mem[0x1E21 + digit * 5 + i] if i < 5 else 0) for i in range(8))
        assert drawn == expected and any(drawn), (player, drawn.hex(), expected.hex())
    print("PASS v11: GAME OVER PLAYER<1>/<2> digit glyphs")


if __name__ == "__main__":
    main()
