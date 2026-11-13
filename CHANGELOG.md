# Part II release notes — current v25

This page is the **current** release summary. Earlier stage notes are preserved under `docs/history/` and should not be read as release instructions.

| Release | Major completed work |
| --- | --- |
| **v25** | Pygame sound output wired to sound-port events; ten provisional WAVs; F9 mute. Corrected bezel loader included. |
| **v24** | Part II ROM high-score entry; 3/4-life DIP CLI; `--debug`; optional supplied bezel. |
| **v23** | ROM `InitRack` restoration on two-player handoffs. |
| **v22** | Startup/arrival cycle pacing compared with MAME. |
| **v20** | Original ROM mirror initialization in player handoff. |
| v16–v19 | Reserve lives display, VRAM restoration and replay RAM diagnostics. |
| Earlier | Initial Part II translation, colour PROM, titles, play, score, player switches and recordings. |

**Project-layout cleanup:** README rewritten for Part II; historical README files, tests, diagnostic tools, old launchers and unused 1978 entry points sorted into dedicated directories. No changes to active gameplay source code.

**Known limitations:** Approximate (not exact) execution timing in some missile/death cases; synthesized sound placeholders are not authentic cabinet recordings; high-score data is retained during the running program, not stored as persistent disk NVRAM.

## v26 — Standalone, no ROM files required
- Converted the original game text, sprite, formation, title and colour-table resources to embedded Python data constants.
- Removed the requirement for the seven original ROM/PROM files from gameplay.
- Preserved original address-indexed values for source-comparison.
- Included the quiet-console update: development event logging is available under `--debug`.
- Gameplay algorithms and frame timing are unchanged.
