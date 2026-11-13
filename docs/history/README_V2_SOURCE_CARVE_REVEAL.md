Space Invaders Part II — title dot-carving reveal fix

The old attract preview rendered $4148 CarveBitmap instantly. ROM $41A4
CarveGroup actually clears a 3-byte group and then calls $0EC9 DelayBC
with BC=$0250 for *each* zero bit. The progressive carving is therefore
an original foreground effect, not an AVI-derived animation.

This update preserves the original FillDots, CarveBitmap and CopyBitmap
pixel operations, inserts an explicit DelayBC event after each group of
cleared dots, and drives foreground events with an 8080-cycle budget.
$0EC9 loop iterations are counted from the original opcode path. The
non-delay instruction overhead in the title render loop is currently
estimated at 32 cycles per screen write; this is not a CPU emulator and
should not be described as cycle-exact until measured against ROM timing.
The existing $40 interrupt waits between title operations are preserved.

Run:
  python part2_source_timing_test.py
  python part2_title_carve_regression_test.py
  python part2_play.py --scale 3

The preview diagnostic is:
  diagnostics/part2_carve_progress_contact.png

MAME remains the independent timing/pixel validation reference.
