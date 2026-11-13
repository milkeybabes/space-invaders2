"""Standalone regression for Part II final controls and high-score entry."""
from rack import Rack
from part2_first_play import Part2FirstPlay
from part2_two_player import Part2TwoPlayer
from part2_hi_score_entry import Part2HighScoreEntry, pending_registration

for lives in (3, 4):
    one = Part2FirstPlay(starting_lives=lives)
    two = Part2TwoPlayer(starting_lives=lives)
    assert one.rack.lives.initial_lives == lives
    assert one.rack.lives.stash == lives - 1
    assert [g.rack.lives.stash for g in two.games] == [lives-1]*2
    assert two.games[1].rack.mem[0x22FF] == lives - 1

# ROM $147E/$14B2 NewHiScore: a >5000 update marks registration.
one = Part2FirstPlay()
m = one.rack.mem
old_hi = (m[0x20F5], m[0x20F4])
m[0x20F8:0x20FA] = b'\x00\x06'  # 6000 (packed BCD)
one.rack.lives.game_over_sequence.begin()
assert (m[0x20F5],m[0x20F4]) > old_hi
assert m[0x20E0] == 1 and m[0x20E1] == 0
assert pending_registration(one) is not None

entry = Part2HighScoreEntry(m)
for _ in range(16):
    entry.step()
assert entry.phase == 'active'
assert entry.mem[0x20F8:0x20FA] == b'\x00\x06'  # entry does not lose earned P1 score
entry.step(fire=True)
entry.step(fire=False)
assert entry.name == 'A' and entry.mem[0x234C] == 1
entry.move(1)
entry.step(fire=True)
entry.step(fire=False)
assert entry.name == 'AB'
assert entry.mem[0x2350:0x2352] == b'\x07\x32'  # ROM nameOutput pointer after two letters
# Move across bottom row to RUB / END and verify max-name handling.
entry.position = 27
entry.select()
assert entry.name == 'A'
entry.position = 28
entry.select()
assert entry.finished and entry.mem[0x234D] == 0
assert entry.mem[0x20E0] == 0 and entry.name == 'A'
assert len(entry.image()) == 224*256

# Original ROM $0DAF timeout (0x2000 interrupts) completes registration.
timed = Part2HighScoreEntry(m)
for _ in range(16): timed.step()
timed.mem[0x234A:0x234C] = (0x1FFF).to_bytes(2,'little')
timed.step()
assert timed.finished
blank = Part2HighScoreEntry(m)
for _ in range(16): blank.step()
blank.finish()
assert len(blank.mem) == 16384
assert blank.name == 'TAITO'
assert blank._letter_location(27) == 0x340D  # ROM RUB column
print('PASS: 3/4 lives, 2P DIP, high-score flag, ROM grid, fire-release, RUB, END, timeout')
