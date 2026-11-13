# Space Invaders Part II (1979) — native Python translation

**Current playable release: v26 (self-contained source, no external ROM files).** Run **`part2_play.py`**. This is the **Part II** game, not the earlier 1978 Part I project. The cleanup only reorganizes the release files; it does **not** change gameplay, audio, scoring or interrupt timing.

Based on the original Taito Space Invaders Part II Intel 8080 code and ROM disassembly. The code translates game routines into Python; it is **not an 8080 CPU emulator**. Some cycle/frame differences remain versus MAME, especially later missile collisions and handoffs.

## Quick start — Windows

1. Install Python and pygame-ce. Double-click **`INSTALL.cmd`** (once), or run `python -m pip install -r requirements.txt`.
2. Double-click **`PLAY.cmd`** to start the actual **Part II** game.
3. Alternatively use `PLAY_BEZEL.cmd` for the included Part II arcade artwork.

From Command Prompt in this folder:

```cmd
python part2_play.py
python part2_play.py --artwork bezel
python part2_play.py --lives 4
python part2_play.py --debug
python part2_play.py --mute
python part2_play.py --test-high-score --artwork bezel
```

Defaults: **3 lives, sound enabled, no bezel**, no AVI recording. `--lives 3`/`4` follows the original DIP setting. `--debug` enables unlimited lives while retaining collision and respawn handling. Other parameters: `python part2_play.py --help`.

## Keys

| Key | Function |
| --- | --- |
| `5` | Insert coin |
| `1` or `2` | Start one- or two-player game (needs 1 or 2 credits) |
| Left / Right arrows or A / D | Move ship |
| Space or left Ctrl | Fire |
| F9 | Toggle mute |
| F5 | Pause / resume |
| F8 *while paused* | Advance exactly one frame |
| F3 | Reset game |
| F12 | Save screenshot in `diagnostics/` |
| Esc | Exit |

In **high-score registration**, use Left/Right to select, press **and release** Space/Ctrl to enter a letter, or press Enter to finish. `PLAY_HIGHSCORE_TEST.cmd` opens the registration directly for testing.

## Sound and artwork

The `sounds/` folder contains ten **provisional synthesized** WAV effects (`0.wav`–`9.wav`), not recordings of the original analog hardware. Replace them with your authentic Part I WAV collection for closer sound. F9 mutes/unmutes; `--mute` starts muted. The optional cabinet bezel is `artwork/part2_bezel.png`; the **black-background game view is the default**. Audio and artwork do not change the native game RAM.

## Recording and MAME comparison (optional)

Recording is *off by default*. To record a native lossless AVI (FFmpeg must be on PATH):

```cmd
python part2_play.py --record recordings\SpaceInvadersPartII.avi
```

The recorded 7,300-frame, two-player reference is `part2_2player.inp`. Reproduce its inputs, without operating the GUI:

```cmd
python part2_play.py --headless --playback-inp part2_2player.inp --state-trace diagnostics\state.csv
```

All original font, sprite, title and table data used during play is embedded in Python. **No external arcade ROM files are required.** The game is playable without MAME; MAME is used only for comparison. For RAM/interrupt trace scripts and the source references, see [Development & verification](docs/DEVELOPMENT.md).

## Which files are current?

| Location | Contents |
| --- | --- |
| **`part2_play.py`** | **Only main Python entry point for this Part II release** |
| Root `*.py` (other than entry point) | Active game modules / shared 1978 routines imported by Part II |
| `artwork/`, `sounds/` | Optional artwork and audio assets |
| `tests/` | Regression tests, including earlier development stages |
| `tools/` | Python and MAME Lua diagnostics, not needed for ordinary play |
| `docs/history/` | **Old stage/version README files; retained for reference, not current instructions** |
| `docs/reference/` | ROM disassembly, reconstructed source and reference information |
| `archive/` | Old 1978 entry points, unused historical Python modules and launchers; **not the current game** |
| `diagnostics/` | Saved diagnostic examples and new screenshot/trace outputs |

Only six current `.cmd` launchers remain at the project root. See [Development & verification](docs/DEVELOPMENT.md) for the current source map and test commands, and [Release notes](CHANGELOG.md) for a concise version summary.

## Historical accuracy

The implementation was developed with ROM disassembly, MAME INP playback, RAM logging and frame comparisons. It closely reproduces the original, but is **not guaranteed frame-perfect** for every input sequence. Preserve the original game quirks rather than silently imposing modern game rules.
