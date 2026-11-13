"""ROM-derived title operation pacing and full image-equivalence regression."""
from part2_attract import Part2AttractPreview
from part2_title import Part2Title

# Ordinary framebuffer values must be unchanged by timing refactor.
a = Part2Title()
a.advance_to(a.stage_ends[-1])
b = Part2Title()
while b.index < b.stage_ends[-1]:
    b.advance_cycles(33535, b.stage_ends[-1])
assert a.image() == b.image(), 'Timed and untimed title VRAM differ'

p = Part2AttractPreview()
marks = {}
old = p.action
for _ in range(650):
    p.step()
    if p.phase == 'title' and p.action != old:
        marks[p.action] = p.frame
        old = p.action
    if p.phase != 'title':
        break

# These are diagnostic *ranges*, not forced presentation timestamps.
# Check that execution-cost work isn't silently replaced by the old
# instantaneous approximation (stage 2 completed at frame 198).
assert 201 <= marks[2] <= 212, marks
assert 266 <= marks[3] <= 279, marks
assert marks[4] > marks[3] + 64, marks
print('PASS: source-derived title presentation, unchanged final VRAM')
print('Title stage completion frames:', marks)
