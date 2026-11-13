# Space Invaders → Space Invaders Part II: what changed

Companion to `SpaceInvadersPartII_Code.md` (annotated listing) and `invadpt2.asm` (source that
reassembles byte-for-byte to pv01–pv05). The CPU is an Intel 8080 throughout.

## ROM layout

| Original (Midway) | Part II (Taito) | |
|---|---|---|
| 0000–1FFF in 4 × 2K (h, g, f, e) | 0000–1FFF in 4 × 2K (pv01–pv04) | Same base code, but almost every routine has moved |
| — | 4000–47FF (pv05) | New expansion ROM |
| — | pv06, pv07 | Colour PROMs (colour map by screen position; no code) |

About 3,900 bytes of the original code survive unchanged. They have just moved to new
addresses. About 3,600 bytes of code are new or rewritten, mostly in the 1000–13FF hole
(the diagnostics area in the original), around 0D83–113F, 1896–1ABE and in the new 4000 ROM.
RAM usage is the same as the original except for new variables in 20A0–20E4, 21F8–21FA/22F8–22FA
and 2300–2354.

## New gameplay features (with entry points)

| Feature | Where | Notes |
|---|---|---|
| Formations change by round | `InitAliens` 01DE, table 1E10, formations 4000 | The bottom 4 rows are copied from one of 5 patterns; the top row is always squids. Rounds past 16 go back to round 9. |
| Four alien types | `DrawAlien` 010F, sprites 1C01 | Each alien's status byte is now 1/3/5/7 (octopus, crab, squid, small). Its picture comes from the status byte, not the row. |
| Splitting crabs | `AlienHit` 12D8 / `CrabHit` 1307 | From round 3 a crab that is shot splits into two small aliens, in its own slot and the slot to its right. Explosion picture at 1AE0. |
| Saucer drops reinforcements | `SaucerDrop` 42EC, `SaucerDropMove` 4383 | From round 2 the saucer stops over a gap in the top row and drops a squid into it. Rounds 2–3 get one drop per rack. You can shoot the falling alien. |
| Flashing 500-point saucer | 073A–0788 | The 2nd saucer in a rack blinks and is always worth 500. |
| Rack slides in from the top | `RackArrive` 09CA | Each new rack drops into position. |
| Round number cut into the shields | `CarveRoundNum` 0997 | |
| Last-alien bonus | 13D2, `RackBonus` 4410 | Last alien in the bottom-left corner: 1000. Bottom-row middle: 800. Any octopus in the bottom two rows: 500. Shown with a fan of "beams". |
| Extra ship for an efficient rack | `FewShotsShip` 4682 | Clearing a rack in fewer than 56 shots adds a ship (shots counted in 2xF8). |
| End-of-rack intermission | `Intermission` 1896, `IntermissionISR` 192D | The last alien shot escapes in a little saucer calling "SOS !!". If both saucers in the rack were hit it stops with "ENGINE TROUBLE". |
| No plunger shot from round 4 | `GameObj3` 0503 | |
| High-score name entry | `NameEntry` 0DFA, timing in the mid-screen ISR 0D83 | "HI-SCORER REGISTRATION" screen with up to 10 letters and RUB/END. On a cocktail cabinet it flips for player 2. The name is shown flashing with "HI-SCORE". |
| 5-digit scores | `Print4Digits0` 107A | Internal BCD is unchanged; a fixed "0" is printed after it. Aliens score 10/20/30, saucer 50–300 or 500. |
| Original bug fixed | `CodeBug1` 1249 | A shot past column 11 no longer hits an alien in the row above. The saucer score table still wraps one entry early (0499). |

## Presentation and attract mode

* New 5-byte font at 1E21 (was 8 bytes at 1E00), with a new character code layout:
  space = 1B, digits from 1C. Every message was re-encoded.
* Big dot-matrix "SPACE INVADERS PART II" title is carved out of a block of dots (`TitleScreen` 40DC).
* The "CCOIN" and upside-down-Y splash animations are gone. The demo alternates between two formations (0CC1).
* The score table adds the 500-point flashing saucer and the small alien.
* *TAITO CORPORATION* is printed from scrambled text (173F). There is a new hidden message
  "TAITO CORP.": in the demo hold Start2+fire+right, then Start1+fire+left (`CheckHiddenMes` 4519).

## Operator / hardware changes

* At most 9 credits (was 99).
* DIP switch 4 (IN2 bit 3), the 1000/1500 extra-ship switch in the original, is now **PRESET MODE** (`PresetMode` 45B9).
  It is an operator mode: Start1 adds 1000 points, Start2 skips a rack, left/right stops/starts alien shots, fire starts play.
  The extra ship is always at 1500.
* Ships: only IN2 bit 0 is used (3 or 4 ships).
* IN0 bit 6 (active low) is a NAME RESET switch. It puts the default name "TAITO" back.
* Port 5 bit 5 (cocktail flip) also selects the colour map. It is set through `SetFlipDelay` 00FD.
* Watchdog writes are added in more places.

## Protection and anti-tamper

* The credit count is kept twice (20EB and 20CC). The end of every interrupt compares them and restarts the machine if they differ (0094).
* In attract mode, IN0 bits 1 and 3 both high (other hardware) restarts the machine (`HardwareCheck` 459C).
* The scrambled "TAITO" inside the copyright text is checked (`CopyrightCheck` 454F).
* Two hidden "2 free credits" button combinations exist (0A2D during rack arrival, 4186 on the title). They only work while
  flag 20E2 or 20E3 is still set, which means a failed copyright or hardware check. Addresses in these routines are built a byte
  at a time (and port 1 is read through `JP (HL)` at 1F49) so a disassembler wouldn't easily see them.

## Leftover assembler source in the ROM

The unused space at 1A70, 1F59–1FFF and 46A4–47FF contains ASCII fragments of Taito's original source,
for example `EXIN1: LDA PU+0A0H / ANI 0FH ...` and `;***** CHARACTER DATA *****  CHROM: DB 1FH,24H,44H ; A <00>`.
This confirms the game was written in Intel 8080 mnemonics.

## Where the original routines went

Status compares instruction streams. "changed" means some instructions differ.

| Original | Routine | Part II | Status |
|---|---|---|---|
| 0000 | Reset | 0000 | same |
| 0008 | ScanLine96 | 0008 | same |
| 0010 | ScanLine224 | 0010 | changed |
| 00B1 | InitRack | 00CC | same |
| 0100 | DrawAlien | 010F | changed |
| 0141 | CursorNextAlien | 015F | changed |
| 017A | GetAlienCoords | 0198 | same |
| 01A1 | MoveRefAlien | 01BF | changed |
| 01C0 | InitAliens | 01DE | rewritten |
| 01CD | ReturnTwo | 0213 | same |
| 01CF | DrawBottomLine | 0215 | same |
| 01D9 | AddDelta | 021F | same |
| 01E4 | CopyRAMMirror | 022A | same |
| 01EF | DrawShieldPl1 | 0235 | same |
| 01F5 | DrawShieldPl2 | 023B | same |
| 0209 | RememberShields1 | 024F | same |
| 020E | RememberShields2 | 0254 | same |
| 0213 | RestoreShields2 | 0259 | same |
| 021A | RestoreShields1 | 0260 | same |
| 021E | CopyShields | 0264 | same |
| 0248 | RunGameObjs | 028E | same |
| 028E | GameObj0 | 02D4 | changed |
| 0381 | MovePlayerRight | 03D1 | changed |
| 038E | MovePlayerLeft | 03DE | same |
| 039B | DrawPlayerDie | 03EB | changed |
| 03BB | GameObj1 | 0400 | same |
| 03FA | InitPlyShot | 043F | same |
| 040A | MovePlyShot | 044F | same |
| 0430 | ReadPlyShot | 0475 | same |
| 0436 | EndOfBlowup | 047B | changed |
| 0476 | GameObj2 | 04C3 | changed |
| 04AB | ResetShot | 04F8 | same |
| 04B6 | GameObj3 | 0503 | changed |
| 0550 | ToShotStruct | 05A5 | same |
| 055B | FromShotStruct | 05B0 | same |
| 0563 | HandleAlienShot | 05BD | changed |
| 062F | FindInColumn | 0687 | changed |
| 0644 | ShotBlowingUp | 069B | same |
| 0682 | GameObj4 | 06D9 | changed |
| 0765 | WaitForStart | 0845 | same |
| 0798 | NewGame | 087E | changed |
| 0886 | GetAlRefPtr | 0A6C | same |
| 088D | PromptPlayer | 0A73 | changed |
| 08D1 | GetShipsPerCred | 0AB7 | changed |
| 08D8 | SpeedShots | 0ABE | changed |
| 08F3 | PrintMessage | 0AD9 | same |
| 08FF | DrawChar | 0AE5 | rewritten (5-byte font) |
| 0913 | TimeToSaucer | 0AFC | changed |
| 097C | AlienScoreValue | 0B41 | changed |
| 0988 | AdjustScore | 0B58 | changed |
| 09AD | Print4Digits | 0B7A | same |
| 09B2 | DrawHexByte | 0B7F | changed |
| 09D6 | ClearPlayField | 0BA3 | changed |
| 0A5F | ScoreForAlien | 0C64 | same |
| 0A80 | Animate | ~18E7 | changed |
| 0A93 | PrintMessageDel | 0C85 | same |
| 0AAB | SplashSquiggly | — | removed / replaced |
| 0AB1 | OneSecDelay | 0C9D | same |
| 0AB6 | TwoSecDelay | 0CA2 | same |
| 0ABB | SplashDemo | 0CA7 | changed |
| 0ABF | ISRSplTasks | 0CAE | rewritten (demo only) |
| 0AD7 | WaitOnDelay | 0CB6 | same |
| 0AE2 | IniSplashAni | — | removed (0CC1 DemoAliens) |
| 1400 | DrawShiftedSprite | 114E | changed |
| 1424 | EraseSimpleSprite | 116E | same |
| 1439 | DrawSimpSprite | 1183 | same |
| 1452 | EraseShifted | 1197 | same |
| 1474 | CnvtPixNumber | 11B9 | same |
| 147C | RememberShields | 11C1 | same |
| 1491 | DrawSprCollision | 11D6 | same |
| 14CB | ClearSmallSprite | 1210 | same |
| 14D8 | PlayerShotHit | 121D | same |
| 1504 | CodeBug1 | 1249 | changed |
| 1538 | AExplodeTime | 128A | changed |
| 1554 | Cnt16s | 12A5 | same |
| 1562 | FindRow | 12B3 | same |
| 156F | FindColumn | 12C0 | same |
| 1581 | GetAlienStatPtr | 1345 | same |
| 1590 | WrapRef | 1354 | same |
| 1597 | RackBump | 135B | changed |
| 15D3 | DrawSprite | 1396 | changed |
| 15F3 | CountAliens | 13B5 | same |
| 1611 | GetPlayerDataPtr | 13F7 | same |
| 1618 | PlrFireOrDemo | 13FE | changed |
| 170E | AShotReloadRate | 1191 | changed |
| 172C | ShotSound | 1558 | changed |
| 1740 | TimeFleetSound | 1569 | same |
| 1775 | FleetDelayExShip | 159E | same |
| 17B4 | SndOffExtPly | 15DD | changed |
| 17C0 | ReadInputs | 15E8 | same |
| 17CD | CheckHandleTilt | 15F5 | changed |
| 1804 | CtrlSaucerSound | 162E | same |
| 1815 | DrawAdvTable | 163F | changed |
| 1856 | ReadPriStruct | 167D | same |
| 1868 | SplashSprite | — | removed / replaced |
| 18D4 | init | 168F | changed |
| 18FA | SoundBits3On | 16B8 | same |
| 1904 | InitAliensP2 | 16C2 | same |
| 190A | PlyrShotAndBump | 16C8 | same |
| 1910 | CurPlyAlive | 16CE | same |
| 191A | DrawScoreHead | 16D8 | same |
| 1931 | DrawScore | 16EF | same |
| 1947 | DrawNumCredits | 1705 | changed |
| 1950 | PrintHiScore | 1710 | same (moved) |
| 1956 | DrawStatus | 171C | rewritten |
| 199A | CheckHiddenMes | 4519 | rewritten (new message) |
| 19D1 | EnableGameTasks | 1752 | same |
| 19D7 | DsableGameTasks | 1758 | changed |
| 19DC | SoundBits3Off | 175C | same |
| 19E6 | DrawNumShips | 1766 | same |
| 1A06 | CompYToBeam | 1786 | same |
| 1A32 | BlockCopy | 17B2 | same |
| 1A3B | ReadDesc | 17BB | same |
| 1A47 | ConvToScr | 17C7 | same |
| 1A5C | ClearScreen | 17DC | same |
| 1A69 | RestoreShields | 17E9 | same |
| 1A7F | RemoveShip | 17FF | changed |

## New labelled routines and tables in Part II

| Address | Name |
|---|---|
| 0094 | ISRExit |
| 00FD | SetFlipDelay |
| 0149 | OneAlienAdjust |
| 01E1 | InitAliensHL |
| 020F | WrapRound |
| 022C | CopyMirrorB |
| 0564 | HandleSquiggly |
| 05B8 | HandleAlienShotChk |
| 073A | DrawSaucerBlink |
| 0753 | IsFlashSaucer |
| 0759 | SaucerStart |
| 076E | FlashSaucerScore |
| 07BA | SaucerSndOff |
| 07F9 | GetRoundNum |
| 0801 | SaucerAddScore |
| 0811 | DrawSaucer |
| 0817 | SaucerToScreen |
| 0834 | SaucerExplPic |
| 0997 | CarveRoundNum |
| 09CA | RackArrive |
| 0ACA | ClrP2ScoreIf1P |
| 0AD7 | PrintSauScore |
| 0B17 | GetNumShips |
| 0B1E | ExtraShipCheck |
| 0B3C | ExtraShipSnd |
| 0B92 | DrawDigit |
| 0B97 | GetScoreDesc |
| 0BBE | FlashBothHit |
| 0BCA | EndOfRack |
| 0C21 | SetRackStart |
| 0C41 | WaitPlayerExp |
| 0C5E | PlayerHitChk |
| 0CC1 | DemoAliens |
| 0CD8 | SplashLoop |
| 0D68 | DemoBumpAndHidden |
| 0D83 | ScanLine96Cont |
| 0DB9 | NameInputs |
| 0DC3 | NameStartHit |
| 0DC9 | NameReset |
| 0DD2 | FlashHiName |
| 0DDA | Delay32 |
| 0DDF | Delay5 |
| 0DE4 | NameMoveDelay |
| 0DFA | NameEntry |
| 0E43 | NameLoop |
| 0EA7 | DrawLetterRow |
| 0EA9 | DrawLetters |
| 0EB9 | DrawNameCursor |
| 0EC1 | EraseNameCursor |
| 0EC9 | DelayBC |
| 0ED2 | CursorRight |
| 0F28 | CursorLeft |
| 0F72 | NameSelect |
| 0FB3 | NameRub |
| 0FDE | CursorColumn |
| 0FE5 | AddLetter |
| 1000 | NameFull |
| 101B | NameDone |
| 1028 | EraseHiName |
| 1030 | PrintHiName |
| 107A | Print4Digits0 |
| 108A | ScoreHundreds |
| 1097 | CenterHiName |
| 10BA | FlashHiNameDo |
| 1130 | DefaultName |
| 1171 | ClearRows |
| 12CA | ShotHitDrop |
| 12D0 | ShotHitSaucer |
| 12D8 | AlienHit |
| 1307 | CrabHit |
| 1330 | EraseAlienExp |
| 13F9 | GetPlayerDataPage |
| 14B2 | NewHiScore |
| 14CA | DoNameEntry |
| 14E4 | ClearHiName |
| 14F2 | GameOverMsg |
| 1512 | PlayerHit |
| 15B8 | SoundDelay |
| 163A | SaucerSndOn |
| 169D | SplashRestart |
| 16E3 | DrawScoreP1 |
| 16E9 | DrawScoreP2 |
| 16FA | DrawCreditLabel |
| 1716 | ClearAndStatus |
| 1719 | DrawScores |
| 1737 | AliensInvade |
| 187E | SpriteSaucerFlash |
| 1896 | Intermission |
| 191B | SosSound |
| 192D | IntermissionISR |
| 193F | SosBeamSide |
| 1944 | SosBeamNorm |
| 199B | PrintSOSL |
| 19A4 | PrintSOS |
| 19BC | SosEngineTrouble |
| 1A24 | CharPtr |
| 1A40 | SosBeamChk |
| 1A50 | TiltPart2 |
| 1AA0 | DrawSprOr |
| 1AE0 | AlienSplitExp |
| 1CFC | SpriteSosSaucer |
| 1DAB | AdvTableSprites |
| 1DC4 | AdvTableMessages |
| 1DD9 | MessagePoints |
| 1E10 | FormationTable |
| 1F16 | PicRubEnd |
| 1F49 | ReadPort1 |
| 1F53 | ProtChecks |
| 4000 | Formations |
| 40DC | TitleScreen |
| 4133 | CopyBitmap |
| 4148 | CarveBitmap |
| 41A4 | CarveGroup |
| 41CD | FillDots |
| 42EC | SaucerDrop |
| 4383 | SaucerDropMove |
| 43A3 | ResetDrop |
| 43BB | FindDropSlot |
| 4410 | RackBonus |
| 4489 | BeamDot1 |
| 44A3 | BeamLeft |
| 44B9 | BeamRight |
| 44CF | BeamDot |
| 44E0 | BeamNext |
| 44E3 | BeamNextRow |
| 44EB | BeamDone |
| 454F | CopyrightCheck |
| 4573 | PrintCorp |
| 459C | HardwareCheck |
| 45B9 | PresetMode |
| 45E4 | PresetScore |
| 45F9 | PresetShotsOff |
| 45FF | PresetRound |
| 4631 | PresetShotsOn |
| 4637 | AwardShip |
| 463C | DrawNewShip |
| 4653 | BonusValue |
| 4677 | Bonus1000 |
| 467E | Bonus800 |
| 4682 | FewShotsShip |

## Screenshots (from the emulator used to verify the analysis; monochrome, no colour overlay)

![title](screens/1_title.png) ![table](screens/2_score_table.png) ![name](screens/3_name_entry.png)
![bonus](screens/4_bonus_1000.png) ![sos](screens/5_sos_intermission.png) ![arrive](screens/6_rack_arriving.png)
![shields](screens/7_round_in_shields.png)

## Confidence

The listing and the .asm match the ROMs exactly, and every new routine was traced by hand.
The behaviour of the major features (title, score table, name entry, bonus, intermission, rack
arrival, shield numbers, protection reset) was confirmed by running the code. The splitting crab,
the saucer drop and the preset mode were read from the code but not watched in play.
Names given to new routines and RAM are my own. A few comments say where the purpose is unclear
(for example 0BBE, which can never fire).
