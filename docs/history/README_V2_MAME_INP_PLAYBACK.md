# MAME Part II input replay

The included `part2_2player.inp` is a standard MAME 0.282 INP file (renamed from the uploaded `.imp` typo without changing its contents).

Decode recorded input edges:

```cmd
python part2_inp.py part2_2player.inp --csv diagnostics\part2_2player_inputs.csv
```

Record a Python AVI and frame CRC trace from the same input sequence:

```cmd
python part2_play.py --playback-inp part2_2player.inp --headless --record diagnostics\part2_2player_python.avi --frame-crc diagnostics\part2_2player_python_crc.csv
```

Requires pygame-ce and ffmpeg for AVI output. Playback ends after the INP's 7,300 frames. Frame 0 is the first decoded MAME input frame.

The exact input edges are: first coin pressed frame 297/released 301; second coin pressed 333/released 336; two-player START pressed 393/released 397. No movement or fire input occurs in the recording. During playback, live gameplay keys are disabled.

IMPORTANT: Input replay aligns button events, but does not by itself guarantee frame-identical game state/AVI. ROM sequence, interrupt scheduling, initial RAM state and rendering must still be aligned. The frame CRC log reports Python unscaled RGB frames, for later pixel matching against decoded MAME video.
