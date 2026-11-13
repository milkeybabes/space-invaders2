"""ROM title carving and startup-status placement regression.
Run: python part2_title_carve_regression_test.py
"""
from hashlib import sha256
from part2_title import Part2Title

# Bitmap-only snapshot: deliberately exclude the later $4127 DrawScores call.
EXPECTED_CARVED_ROM_SHA256 = 'f49c623624f6f2b8de478aab1d8d9b2ee146bffc0edf398cfe61c55a7f3f9afd'


def check():
    title = Part2Title()
    assert not any(title.mem[0x2400:0x4000]), '$0CDD ClearScreen must precede title'
    title.advance_to(title.stage_ends[4])  # $41CD/$4148/$4133 only
    digest = sha256(title.mem[0x2400:0x4000]).hexdigest()
    assert digest == EXPECTED_CARVED_ROM_SHA256, 'Title carve bitmap changed: ' + digest
    assert title.mem[0x3501] == 0, 'credit label appeared before $4127'
    title.advance_to(title.stage_ends[5])  # $4127/$1719 DrawScores
    assert title.mem[0x3501] != 0, '$16FA credit label missing'
    assert title.mem[0x3c01] != 0, '$1705 credit digit missing'
    print('PASS: ROM title carving; blank startup; $4127 score/credit draw')


if __name__ == '__main__':
    check()
