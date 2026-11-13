# Space Invaders Part II — v25 sound integration

The v24 game was effectively silent: `sound_driver.py` generated port signals but
`part2_play.py` never connected the bus to `WavBackend`. The v25 update wires
one sound bus into both player controllers and processes 8080 OUT $03/$05
transitions through the existing pygame WAV adapter. `F9` mutes/unmutes,
`--mute` starts muted, F5 pauses audio, and F3/reset and player handoffs
silence any stale continuous effects. These changes do not affect game RAM,
replay clocks, or sprite update order.

## Run

    python part2_play.py
    python part2_play.py --artwork bezel
    python part2_play.py --lives 4
    python part2_play.py --mute
    python part2_play.py --sound-trace diagnostics/audio.csv

## Samples

The `sounds/` folder contains **newly synthesized provisional placeholders**
with the standard Space Invaders mapping. They are NOT recordings of the
Taito/Midway analog sound circuitry and are not claimed to sound identical
to MAME. The source game drives analog circuits, not WAV samples. For closer
authenticity, replace `0.wav` through `9.wav` using your own original
Space Invaders Part I audio sample collection (the same sound names used by
its pygame sound backend):

    0.wav  UFO flying (continuous loop)
    1.wav  player shot
    2.wav  player explosion
    3.wav  alien explosion
    4.wav  fleet step 1
    5.wav  fleet step 2
    6.wav  fleet step 3
    7.wav  fleet step 4
    8.wav  UFO explosion
    9.wav  extra ship (optional in some sample collections)

The included effects are generated programmatically and are freely editable.
The audio engine still uses an *approximate* fleet-step and effect-hold schedule;
ROM-cycle-accurate sound timing has not been demonstrated. Visual INP replay
and AVI output remain deterministic; existing AVI capture stays video-only.

This release also includes the v24 `part2_bezel.py` pygame display-order fix.
