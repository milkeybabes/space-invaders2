# Space Invaders Part II (Taito, 1979)

>>> cpu 8080

>>> binary 0000:roms/pv01 + roms/pv02 + roms/pv03 + roms/pv04, 4000:roms/pv05

This is a reconstruction of the Part II code in the style of the Computer Archeology
commentary on the original Space Invaders. The CPU is an Intel 8080 and the listing uses
8080 mnemonics (the original page uses Z80-style mnemonics for the same opcodes).

How this was made:

  * Both ROM sets were disassembled and lined up instruction by instruction, ignoring
    absolute addresses (Part II moved almost everything). Where an instruction is unchanged
    the original commentary is carried over, with ROM addresses in the comments translated
    to their Part II locations.
  * Everything Part II added or changed was worked out by hand and checked by running the
    ROMs in an 8080 emulator.
  * The companion `invadpt2.asm` is built from this listing and reassembles byte-for-byte
    to pv01-pv05.

Memory map: 0000-1FFF ROM (pv01-pv04), 2000-23FF RAM, 2400-3FFF video RAM,
4000-47FF ROM (pv05, new in Part II). pv06/pv07 are the colour PROMs (no code).

Scores in Part II have five digits: the four BCD digits in RAM plus a fixed trailing "0".
So a score value of 0050 is shown as 00500.

Notation (as on the original page): {code.X} is a code label, {ram.X} a RAM location,
{hard.X} an I/O port, {} an unnamed jump target.

[RAM Usage](RAMUse.md) (the original page) plus the Part II additions below.

## RAM used or re-purposed by Part II

| | | |
| --- | --- | --- |
|20A0|dropColumn|Saucer-drop: bit 7=a drop is pending, low nibble=column (1-11) of the empty top-row slot being refilled|
|20A1|dropActive|Saucer-drop: 1 while a new alien is falling from the saucer into the rack|
|20A2|dropDeltaY|Saucer-drop: falling alien's Y step (FE = down 2)|
|20A3|dropDeltaX|Saucer-drop: falling alien's X step (0)|
|20A4|dropYr|Saucer-drop: falling alien's Y coordinate|
|20A5|dropXr|Saucer-drop: falling alien's X coordinate|
|20A6|dropPicL|Saucer-drop: falling alien's picture (LSB)|
|20A7|dropPicM|Saucer-drop: falling alien's picture (MSB)|
|20A8|dropSize|Saucer-drop: falling alien's picture size (8)|
|20A9|dropTargetY|Saucer-drop: Y coordinate where the falling alien joins the rack|
|20AA|dropSlotL|Saucer-drop: pointer (LSB) to the empty alien slot being refilled|
|20AB|dropSlotM|Saucer-drop: pointer (MSB) to the empty alien slot being refilled|
|20AD|dropHit|1 when the player's shot has hit the alien that the saucer is dropping|
|20AE|lastAlienBonus|1 when the last alien of a rack qualifies for the end-of-rack BONUS|
|20AF|scoreTableOn|Always 1 (from the RAM mirror). AlienScoreValue skips the lookup if it is 0|
|20B1|nameFireHeld|Name entry: fire button debounce|
|20B2|nameFirePressed|Name entry: fire button pressed (select letter)|
|20B3|bonus1000|End-of-rack bonus is 1000 points|
|20B4|bonus800|End-of-rack bonus is 800 points|
|20B5|bonusBeams|Number of times the bonus beam animation is repeated|
|20B7|dropDone|Saucer has dropped an alien this rack|
|20B8|dropOnce|Copy of dropDone (rounds 2 and 3 only get one drop per rack)|
|20B9|rackArriving|1 while the new rack is sliding down into position (ISR keeps the fleet sound going)|
|20BA|flashSaucerArmed|Flashing saucer: set when the saucer score is to be shown as 500|
|20BB|flashSaucer|Flashing saucer is on this pass|
|20BC|saucerBlink|Flashing saucer blink counter|
|20BD|saucerBlinkTmr|Flashing saucer blink timer|
|20BE|bonusBeamCnt|Counts the bonus beam animation repeats|
|20BF|nameStartHit|A start button was pressed during name entry (ends entry)|
|20CC|creditShadow|Second copy of the credit count. ISR resets the machine if it ever differs from numCoins (anti-tamper)|
|20D0|sosActive|1 while the end-of-rack "SOS" intermission animation is running (ISR task)|
|20D1|sosStage|Intermission stage flag|
|20D2|sosDeltaX|Intermission sprite descriptor (delta X)|
|20D3|sosDeltaY|Intermission sprite descriptor (delta Y)|
|20D4|sosPosL|Intermission saucer position (LSB)|
|20D5|sosPosM|Intermission saucer position (MSB)|
|20D6|sosPicL|Intermission saucer picture (LSB)|
|20D7|sosPicM|Intermission saucer picture (MSB)|
|20D8|sosSize|Intermission saucer picture size|
|20D9|sosResume|1 after the "ENGINE TROUBLE" stop (saucer then flies off)|
|20DA|sosWobble|Intermission: alternates the sideways wobble|
|20DB|lastAlienType|Status byte (type) of the last alien that was shot|
|20DC|sosAnim|Intermission: animation counter for the alien's picture|
|20DD|sosAlienPicL|Intermission: picture of the alien riding in the saucer (LSB)|
|20DE|sosAlienPicM|Intermission: picture of the alien riding in the saucer (MSB)|
|20DF|sosBlink|Intermission blink counter|
|20E0|namePending|1 when the player beat the high score and will enter a name at game over|
|20E1|nameFlip|Player entering the name: 00=player 1, 20=player 2 (port-5 cocktail bit and port-2 controls)|
|20E2|tamperFlag|Cleared when the copyright text checks out; left set if it was altered|
|20E3|hwFlag|Cleared in attract mode when port 0 bits 1 and 3 are both 0 (checked hardware)|
|20E4|shotsHalted|1 stops the alien shots (used during name entry and rack start)|
|2300|rackSave|Copy of 2000-200F while the new rack slides into place|
|2310|beamCount|Bonus beam animation: current beam length|
|2311|beamStep|Bonus beam animation: spread per step|
|2312|beamOriginL|Bonus beam animation: origin (LSB)|
|2313|beamOriginM|Bonus beam animation: origin (MSB)|
|233E|hiNamePosL|Screen address of the centered high-score name (LSB)|
|233F|hiNamePosM|Screen address of the centered high-score name (MSB)|
|2340|hiName|High-score holder's name (10 characters)|
|234A|nameTimerL|Name entry timer (counts up in the ISR)|
|234B|nameTimerM|Name entry timer MSB (entry ends at 20)|
|234C|nameLength|Number of letters entered so far (0-10)|
|234D|nameEntry|FF while the name-entry screen is active|
|234E|nameCursorL|Name entry: screen address of the letter cursor (LSB)|
|234F|nameCursorM|Name entry: screen address of the letter cursor (MSB)|
|2350|nameOutL|Name entry: screen address where the next letter is printed (LSB)|
|2351|nameOutM|Name entry: screen address where the next letter is printed (MSB)|

```code
```

# Startup and Interrupts

```code

Reset:
; Execution begins here on power-up and reset.
0000: 00              NOP                         ; This provides a slot ...
0001: 00              NOP                         ; ... to put in a JP for ...
0002: 00              NOP                         ; ... development
0003: C3 8F 16        JMP     0x168F              ; {code.init} Continue startup at 168F
0006: 00 00   ; Padding before fixed ISR address

ScanLine96:
;Interrupt brings us here when the beam is *near* the middle of the screen. The real middle
;would be 224/2 = 112. The code pretends this interrupt happens at line 128.
0008: F5              PUSH    PSW                 ; Save ...
0009: C5              PUSH    B                   ; ...
000A: D5              PUSH    D                   ; ...
000B: E5              PUSH    H                   ; ... everything
000C: C3 83 0D        JMP     0x0D83              ; {code.ScanLine96Cont} Continue ISR at 0D83 (Part II checks the name-reset switch and runs name-entry timing first)
000F: 00   ; Padding before fixed ISR address

ScanLine224:
; Interrupt brings us here when the beam is at the end of the screen (line 224) when the VBLANK begins.
0010: F5              PUSH    PSW                 ; Save ...
0011: C5              PUSH    B                   ; ...
0012: D5              PUSH    D                   ; ...
0013: E5              PUSH    H                   ; ... everything
0014: 3E 80           MVI     A,0x80              ; Flag that tells objects ...
0016: 32 72 20        STA     0x2072              ; {ram.vblankStatus} ... on the lower half of the screen to draw/move
0019: 21 C0 20        LXI     H,0x20C0            ; {+ram.isrDelay} Decrement ...
001C: 35              DCR     M                   ; ... the general countdown (used for pauses)
001D: CD F5 15        CALL    0x15F5              ; {code.CheckHandleTilt} Check and handle TILT
0020: DB 01           IN      0x01                ; {hard.INP1} Read coin switch
0022: 0F              RRC                         ; Has a coin been deposited (bit 0)?
0023: DA 70 00        JC      0x0070              ; {} Yes ... note that switch is closed and continue at 3F with A=1
0026: 3A EA 20        LDA     0x20EA              ; {ram.coinSwitch} Switch is now open. Was it ...
0029: A7              ANA     A                   ; ... closed last time?
002A: CA 4B 00        JZ      0x004B              ; {} No ... skip registering the credit

;
; Handle bumping credit count
002D: 3A EB 20        LDA     0x20EB              ; {ram.numCoins} Number of credits in BCD
0030: FE 09           CPI     0x09                ; Part II: credits max out at 9 (the original allowed 99) ...
0032: CA 47 00        JZ      0x0047              ; {} ... ignore the coin if already at 9
0035: C6 01           ADI     0x01                ; Bump number of credits
0037: 27              DAA                         ; Make it binary coded decimal
0038: 32 EB 20        STA     0x20EB              ; {ram.numCoins} New number of credits
003B: 3A CC 20        LDA     0x20CC              ; {ram.creditShadow} Part II keeps a second copy ...
003E: C6 01           ADI     0x01                ; ... of the credit count ...
0040: 27              DAA                         ; ... (BCD) ...
0041: 32 CC 20        STA     0x20CC              ; {ram.creditShadow} ... checked at the end of every interrupt (see 0094)
0044: CD 05 17        CALL    0x1705              ; {code.DrawNumCredits} Draw credits on screen
0047: AF              XRA     A                   ; Credit switch ...
0048: 32 EA 20        STA     0x20EA              ; {ram.coinSwitch} ... has opened

;
004B: 3A E9 20        LDA     0x20E9              ; {ram.suspendPlay} Are we moving ...
004E: A7              ANA     A                   ; ... game objects?
004F: CA 8A 00        JZ      0x008A              ; {} No ... restore registers and out
0052: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Are we in ...
0055: A7              ANA     A                   ; ... game mode?
0056: C2 75 00        JNZ     0x0075              ; {} Yes ... go process game-play things and out
0059: 3A EB 20        LDA     0x20EB              ; {ram.numCoins} Number of credits
005C: A7              ANA     A                   ; Are there any credits (player standing there)?
005D: C2 66 00        JNZ     0x0066              ; {} Yes ... skip any ISR animations for the splash screens
0060: CD AE 0C        CALL    0x0CAE              ; {code.ISRSplTasks} Process ISR tasks for splash screens
0063: C3 8A 00        JMP     0x008A              ; {} Restore registers and out

;
; At this point no game is going and there are credits
0066: 3A 93 20        LDA     0x2093              ; {ram.waitStartLoop} Are we in the ...
0069: A7              ANA     A                   ; ... "press start" loop?
006A: C2 94 00        JNZ     0x0094              ; {} Yes ... restore registers and out
006D: C3 45 08        JMP     0x0845              ; {code.WaitForStart} Start the "press start" loop

;
; Mark credit as needing registering
0070: 3E 01           MVI     A,0x01              ; Remember switch ...
0072: C3 48 00        JMP     0x0048              ; {} Continue
0075: CD 69 15        CALL    0x1569              ; {code.TimeFleetSound}

;
; Main game-play timing loop
0078: CD 83 43        CALL    0x4383              ; {code.SaucerDropMove} Part II: move/draw the alien that the saucer is dropping into the rack
007B: 3A 32 20        LDA     0x2032              ; {ram.obj2TimerExtra} Use rolling shot's timer to sync ...
007E: 32 80 20        STA     0x2080              ; {ram.shotSync} ... other two shots
0081: CD 0F 01        CALL    0x010F              ; {code.DrawAlien} Draw the current alien (or exploding alien)
0084: CD 8E 02        CALL    0x028E              ; {code.RunGameObjs} Process game objects (including player object)
0087: CD FC 0A        CALL    0x0AFC              ; {code.TimeToSaucer} Count down time to saucer
008A: 3A B9 20        LDA     0x20B9              ; {ram.rackArriving} Is the new rack sliding down into place?
008D: A7              ANA     A                   ; Set flags
008E: C4 69 15        CNZ     0x1569              ; {code.TimeFleetSound} Yes ... keep the fleet sound timing going (the game loop is not running yet)
0091: CD 2D 19        CALL    0x192D              ; {code.IntermissionISR} Part II: protection checks in attract mode and the "SOS" intermission animation

ISRExit:
; Part II anti-tamper: the credit count is kept twice (20EB and 20CC). If the two ever
; disagree (someone poked the credits) the machine restarts.
0094: 21 EB 20        LXI     H,0x20EB            ; {ram.numCoins} Credit count
0097: 7E              MOV     A,M                 ; Get it
0098: 2E CC           MVI     L,0xCC              ; Point to the shadow copy (20CC)
009A: BE              CMP     M                   ; Do they agree?
009B: C2 03 00        JNZ     0x0003              ; {} No ... restart the machine

;
009E: E1              POP     H                   ; Restore ...
009F: D1              POP     D                   ; ...
00A0: C1              POP     B                   ; ...
00A1: F1              POP     PSW                 ; ... everything
00A2: FB              EI                          ; Enable interrupts
00A3: C9              RET                         ; Return from interrupt

; Continues here at scanline 96
;
00A4: AF              XRA     A                   ; Flag that tells ...
00A5: 32 72 20        STA     0x2072              ; {ram.vblankStatus} ... objects on the upper half of screen to draw/move
00A8: 3A E9 20        LDA     0x20E9              ; {ram.suspendPlay} Are we moving ...
00AB: A7              ANA     A                   ; ... game objects?
00AC: CA 8A 00        JZ      0x008A              ; {} No ... restore and return
00AF: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Are we in ...
00B2: A7              ANA     A                   ; ... game mode?
00B3: C2 BD 00        JNZ     0x00BD              ; {} Yes .... process game objects and out
00B6: 3A C1 20        LDA     0x20C1              ; {ram.isrSplashTask} Splash-animation tasks
00B9: 0F              RRC                         ; If we are in demo-mode then we'll process the tasks anyway
00BA: D2 94 00        JNC     0x0094              ; {} Not in demo mode ... done
00BD: CD EC 42        CALL    0x42EC              ; {code.SaucerDrop} Part II: let the saucer drop a new alien into a gap in the top row

;
00C0: 21 20 20        LXI     H,0x2020            ; {ram.obj1TimerMSB} Game object table (skip player-object at 2010)
00C3: CD 91 02        CALL    0x0291              ; {} Process all game objects (except player object)
00C6: CD 5F 01        CALL    0x015F              ; {code.CursorNextAlien} Advance cursor to next alien (move the alien if it is last one)
00C9: C3 94 00        JMP     0x0094              ; {} Restore and return
```

# The Aliens

```code

InitRack:
; Initialize the player's rack of aliens. Copy the reference-location and deltas from the
; player's data bank.
;
00CC: CD 6C 0A        CALL    0x0A6C              ; {code.GetAlRefPtr} 2xFC Get current player's ref-alien position pointer
00CF: E5              PUSH    H                   ; Hold pointer
00D0: 7E              MOV     A,M                 ; Get player's ...
00D1: 23              INX     H                   ; ... ref-alien ...
00D2: 66              MOV     H,M                 ; ...
00D3: 6F              MOV     L,A                 ; ... coordinates
00D4: 22 09 20        SHLD    0x2009              ; {ram.refAlienYr} Set game's reference alien's X,Y
00D7: 22 0B 20        SHLD    0x200B              ; {ram.alienPosLSB} Set game's alien cursor bit position
00DA: E1              POP     H                   ; Restore pointer
00DB: 2B              DCX     H                   ; 21FB or 22FB ref alien's delta (left or right)
00DC: 7E              MOV     A,M                 ; Get ref alien's delta X
00DD: FE 03           CPI     0x03                ; If there is one alien it will move right at 3
00DF: C2 E3 00        JNZ     0x00E3              ; {} Not 3 ... keep it
00E2: 3D              DCR     A                   ; If it is 3, back it down to 2 until it switches again
00E3: 32 08 20        STA     0x2008              ; {ram.refAlienDXr} Store alien deltaY
00E6: FE FE           CPI     0xFE                ; Moving left?
00E8: 3E 00           MVI     A,0x00              ; Value of 0 for rack-moving-right (not XOR so flags are unaffected)
00EA: C2 EE 00        JNZ     0x00EE              ; {} Not FE ... keep the value 0 for right
00ED: 3C              INR     A                   ; It IS FE ... use 1 for left
00EE: 32 0D 20        STA     0x200D              ; {ram.rackDirection} Store rack direction
00F1: C9              RET                         ; Done
00F2: 3E 02           MVI     A,0x02              ; Set ...
00F4: 32 FB 21        STA     0x21FB              ; {ram.p1RefAlienDX} ... player 1 and 2 ...
00F7: 32 FB 22        STA     0x22FB              ; {ram.p2RefAlienDX} ... alien delta to 2 (right 2 pixels)
00FA: C3 CA 0A        JMP     0x0ACA              ; {}

SetFlipDelay:
; Part II: write port 5 (the cocktail-flip bit, which on Part II hardware also selects the
; colour map) with interrupts off and wait a moment for the hardware to settle.
00FD: F3              DI                          ; No interrupts while we wait
00FE: 78              MOV     A,B                 ; B holds the new port-5 value (cocktail bit)
00FF: D3 05           OUT     0x05                ; {hard.SOUND2} Set the cocktail/colour-map bit
0101: 06 0A           MVI     B,0x0A              ; Outer count of 10
0103: 0E 00           MVI     C,0x00              ; Inner count of 256
0105: 0D              DCR     C                   ; Count ...
0106: C2 05 01        JNZ     0x0105              ; {} ... down inner
0109: 05              DCR     B                   ; Count ...
010A: C2 03 01        JNZ     0x0103              ; {} ... down outer
010D: FB              EI                          ; Interrupts back on
010E: C9              RET                         ; Done

DrawAlien:
; 2006 holds the index into the alien flag data grid. 2067 holds the MSB of the pointer (21xx or 22xx).
; If there is an alien exploding time it down. Otherwise draw the alien if it alive (or skip if
; it isn't). If an alien is drawn (or blank) then the 2000 alien-drawing flag is cleared.
;
; Part II: the alien's picture comes from its status byte instead of its row. The status
; byte is 0 for an empty slot, otherwise 1, 3, 5 or 7 (bit 0 = alive, bits 1-2 = type).
; There are four alien pictures per animation frame (octopus, crab, squid and the small
; "split" alien) so frame 1 is $40 bytes after frame 0.
010F: 21 02 20        LXI     H,0x2002            ; {ram.alienIsExploding} Is there an ...
0112: 7E              MOV     A,M                 ; ... alien ...
0113: A7              ANA     A                   ; ... exploding?
0114: C2 8A 12        JNZ     0x128A              ; {code.AExplodeTime} Yes ... go time it down and out

;
0117: E5              PUSH    H                   ; 2002 on the stack
0118: 3A 06 20        LDA     0x2006              ; {ram.alienCurIndex} Get alien index ...
011B: 6F              MOV     L,A                 ; ... for the 21xx or 22xx pointer
011C: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Get MSB ...
011F: 67              MOV     H,A                 ; ... of data area (21xx or 22xx)
0120: 7E              MOV     A,M                 ; Get alien status byte
0121: A7              ANA     A                   ; Is the alien alive?
0122: E1              POP     H                   ; HL=2002
0123: CA 44 01        JZ      0x0144              ; {} No alien ... skip drawing alien sprite (but flag done)
0126: 23              INX     H                   ; HL=2003 Bump descriptor
0127: 23              INX     H                   ; HL=2004 Point to alien's row
0128: 23              INX     H                   ; HL=2005 Animation frame
0129: 46              MOV     B,M                 ; Get animation number
012A: E6 F6           ANI     0xF6                ; Status 1,3,5,7 -> 0,2,4,6 (bit 3 ignored) ...
012C: 07              RLC                         ; ... *2 ...
012D: 07              RLC                         ; ... *4 ...
012E: 07              RLC                         ; ... *8 = 00,10,20,30 offset to the alien type
012F: 5F              MOV     E,A                 ; Sprite offset LSB
0130: 16 00           MVI     D,0x00              ; MSB is 0
0132: 21 01 1C        LXI     H,0x1C01            ; Position 0 alien sprites (1C01)
0135: 19              DAD     D                   ; Offset to sprite type
0136: EB              XCHG                        ; Sprite offset to DE
0137: 78              MOV     A,B                 ; Animation frame number
0138: A7              ANA     A                   ; Is it position 0?
0139: C4 59 01        CNZ     0x0159              ; {} No ... add 30 and use position 1 alien sprites
013C: 06 10           MVI     B,0x10              ; 16 rows in alien sprites
013E: CD 49 01        CALL    0x0149              ; {} Adjust for the lone fast alien
0141: CD 96 13        CALL    0x1396              ; {code.DrawSprite} Draw shifted sprite
0144: AF              XRA     A                   ; Let the ISR routine ...
0145: 32 00 20        STA     0x2000              ; {ram.waitOnDraw} ... advance the cursor to the next alien
0148: C9              RET                         ; Out

OneAlienAdjust:
; Part II: when only one alien is left it moves 3 pixels at a time. Near the left of the
; screen draw it 17 columns wide starting one column early (one blank sprite byte) so the
; trailing column of the old image gets wiped.
0149: 2A 0B 20        LHLD    0x200B              ; {ram.alienPosLSB} Pixel position of the alien
014C: 3A 6B 20        LDA     0x206B              ; {ram.oneAlien} Only one alien left?
014F: A7              ANA     A                   ; Set flags
0150: C8              RZ                          ; No ... draw normally
0151: 7C              MOV     A,H                 ; Column (MSB of pixel number)
0152: FE 30           CPI     0x30                ; Near the left side?
0154: D0              RNC                         ; No ... draw normally
0155: 04              INR     B                   ; Draw 17 bytes instead of 16
0156: 25              DCR     H                   ; Start one column to the left
0157: 1B              DCX     D                   ; ... and one byte earlier in the sprite data (a blank byte)
0158: C9              RET                         ; Out

;
0159: 21 40 00        LXI     H,0x0040            ; Offset sprite pointer to frame 1 (4 sprites * 16 bytes = 40 in Part II)
015C: 19              DAD     D                   ; ... to animation frame 1 sprites
015D: EB              XCHG                        ; Back to DE
015E: C9              RET                         ; Out

CursorNextAlien:
; This is called from the mid-screen ISR to set the cursor for the next alien to draw.
; When the cursor moves over all aliens then it is reset to the beginning and the reference
; alien is moved to its next position.
;
; The flag at 2000 keeps this in sync with the alien-draw routine called from the end-screen ISR.
; When the cursor is moved here then the flag at 2000 is set to 1. This routine will not change
; the cursor until the alien-draw routine at 100 clears the flag. Thus no alien is skipped.
;
015F: 3A 68 20        LDA     0x2068              ; {ram.playerOK} Is the player ...
0162: A7              ANA     A                   ; ... blowing up?
0163: C8              RZ                          ; Yes ... ignore the aliens
0164: 3A 00 20        LDA     0x2000              ; {ram.waitOnDraw} Still waiting on ...
0167: A7              ANA     A                   ; ... this alien to be drawn?
0168: C0              RNZ                         ; Yes ... leave cursor in place
0169: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Load alien-data ...
016C: 67              MOV     H,A                 ; ... MSB (either 21xx or 22xx)
016D: 3A 06 20        LDA     0x2006              ; {ram.alienCurIndex} Load the xx part of the alien flag pointer
0170: 16 02           MVI     D,0x02              ; When all are gone this triggers 1A1 to return from this stack frame
0172: 3C              INR     A                   ; Have we drawn all aliens ...
0173: FE 37           CPI     0x37                ; ... at last position?
0175: CC BF 01        CZ      0x01BF              ; {code.MoveRefAlien} Yes ... move the bottom/right alien and reset index to 0
0178: 6F              MOV     L,A                 ; HL now points to alien flag
0179: 7E              MOV     A,M                 ; Get alien status
017A: A7              ANA     A                   ; Is alien alive (any type)?
017B: 7D              MOV     A,L                 ; Index back to A (flags kept)
017C: CA 72 01        JZ      0x0172              ; {} No ... skip to next alien
017F: 32 06 20        STA     0x2006              ; {ram.alienCurIndex} New alien index
0182: CD 98 01        CALL    0x0198              ; {code.GetAlienCoords} Calculate bit position and type for index
0185: 61              MOV     H,C                 ; The calculation returns the MSB in C
0186: 22 0B 20        SHLD    0x200B              ; {ram.alienPosLSB} Store new bit position
0189: 7D              MOV     A,L                 ; Has this alien ...
018A: FE 28           CPI     0x28                ; ... reached the end of screen?
018C: DA 37 17        JC      0x1737              ; {code.AliensInvade} Yes ... kill the player
018F: 7A              MOV     A,D                 ; This alien's ...
0190: 32 04 20        STA     0x2004              ; {ram.alienRow} ... row index
0193: 3C              INR     A                   ; Non-zero value for the ...
0194: 32 00 20        STA     0x2000              ; {ram.waitOnDraw} ... draw-alien routine to clear
0197: C9              RET                         ; Done

GetAlienCoords:
; Convert alien index in L to screen bit position in C,L.
; Return alien row index (converts to type) in D.
;
0198: 16 00           MVI     D,0x00              ; Row 0
019A: 7D              MOV     A,L                 ; Hold onto alien index
019B: 21 09 20        LXI     H,0x2009            ; {ram.refAlienYr} Get alien X ...
019E: 46              MOV     B,M                 ; ... to B
019F: 23              INX     H                   ; Get alien y ...
01A0: 4E              MOV     C,M                 ; ... to C
01A1: FE 0B           CPI     0x0B                ; Can we take a full row off of index?
01A3: FA B2 01        JM      0x01B2              ; {} No ... we have the row
01A6: DE 0B           SBI     0x0B                ; Subtract off 11 (one whole row)
01A8: 5F              MOV     E,A                 ; Hold the new index
01A9: 78              MOV     A,B                 ; Add ...
01AA: C6 10           ADI     0x10                ; ... 16 to bit ...
01AC: 47              MOV     B,A                 ; ... position Y (1 row in rack)
01AD: 7B              MOV     A,E                 ; Restore tallied index
01AE: 14              INR     D                   ; Next row
01AF: C3 A1 01        JMP     0x01A1              ; {} Keep skipping whole rows

;
01B2: 68              MOV     L,B                 ; We have the LSB (the row)
01B3: A7              ANA     A                   ; Are we in the right column?
01B4: C8              RZ                          ; Yes ... X and Y are right
01B5: 5F              MOV     E,A                 ; Hold index
01B6: 79              MOV     A,C                 ; Add ...
01B7: C6 10           ADI     0x10                ; ... 16 to bit ...
01B9: 4F              MOV     C,A                 ; ... position X (1 column in rack)
01BA: 7B              MOV     A,E                 ; Restore index
01BB: 3D              DCR     A                   ; We adjusted for 1 column
01BC: C3 B3 01        JMP     0x01B3              ; {} Keep moving over column

MoveRefAlien:
; The "reference alien" is the bottom left. All other aliens are drawn relative to this
; reference. This routine moves the reference alien (the delta is set elsewhere) and toggles
; the animation frame number between 0 and 1.
;
01BF: 15              DCR     D                   ; This decrements with each call to move
01C0: CA 13 02        JZ      0x0213              ; {code.ReturnTwo} Return out of TWO call frames (only used if no aliens left)
01C3: 21 06 20        LXI     H,0x2006            ; {ram.alienCurIndex} Set current alien ...
01C6: 36 00           MVI     M,0x00              ; ... index to 0
01C8: 23              INX     H                   ; Point to DeltaX
01C9: 4E              MOV     C,M                 ; Load DX into C
01CA: 36 00           MVI     M,0x00              ; Set DX to 0
01CC: CD 1F 02        CALL    0x021F              ; {code.AddDelta} Move alien
01CF: 21 05 20        LXI     H,0x2005            ; {ram.alienFrame} Alien animation frame number
01D2: 7E              MOV     A,M                 ; Toggle ...
01D3: 3C              INR     A                   ; ... animation ...
01D4: E6 01           ANI     0x01                ; ... number between ...
01D6: 77              MOV     M,A                 ; ... 0 and 1
01D7: AF              XRA     A                   ; Alien index in A is now 0
01D8: 21 67 20        LXI     H,0x2067            ; {ram.playerDataMSB} Restore H ...
01DB: 66              MOV     H,M                 ; ... to player data MSB (21 or 22)
01DC: C9              RET                         ; Done
01DD: 21

InitAliens:
; Part II: the starting formation is no longer five identical rows. The bottom four rows
; (44 aliens) are copied from one of the formation tables in the 4000 ROM. The table at
; 1E10 picks the formation from the player's round number (rounds past 16 restart at 9).
; The top row is always 11 squids (status 5).
01DE: 21 00 21        LXI     H,0x2100            ; Start of alien structures (player 1)

InitAliensHL:
01E1: 06 2C           MVI     B,0x2C              ; 44 aliens (4 rows) come from the table
01E3: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
01E5: E5              PUSH    H                   ; Hold pointer to aliens
01E6: CD F9 07        CALL    0x07F9              ; {code.GetRoundNum} Get player's round count (HL=2xF9)
01E9: C5              PUSH    B                   ; Hold count
01EA: 16 40           MVI     D,0x40              ; Formation tables are at 40xx
01EC: 01 10 1E        LXI     B,0x1E10            ; Table of formation LSBs by round
01EF: A7              ANA     A                   ; First round?
01F0: CA FD 01        JZ      0x01FD              ; {} Yes ... use entry 0
01F3: FE 11           CPI     0x11                ; Past round 16?
01F5: D4 0F 02        CNC     0x020F              ; {} Yes ... wrap back to round 9
01F8: 03              INX     B                   ; Index ...
01F9: 3D              DCR     A                   ; ... into ...
01FA: C2 F8 01        JNZ     0x01F8              ; {} ... the table
01FD: 0A              LDAX    B                   ; Get formation LSB
01FE: 5F              MOV     E,A                 ; DE now points to formation
01FF: C1              POP     B                   ; Restore count
0200: E1              POP     H                   ; Restore pointer to aliens
0201: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Copy 44 aliens from formation table
0204: 06 0B           MVI     B,0x0B              ; 11 aliens in the top row
0206: 3E 05           MVI     A,0x05              ; Status 5 = squid
0208: 77              MOV     M,A                 ; Store alien
0209: 23              INX     H                   ; Next
020A: 05              DCR     B                   ; All done?
020B: C2 08 02        JNZ     0x0208              ; {} No ... do the whole row
020E: C9              RET                         ; Done

WrapRound:
020F: 36 09           MVI     M,0x09              ; Set round count back to 9
0211: 7E              MOV     A,M                 ; A = 9
0212: C9              RET                         ; Out

ReturnTwo:
; If there are no aliens left on the screen then MoveDrawAlien comes here which returns from the
; caller's stack frame.
;
0213: E1              POP     H                   ; Drop return to caller
0214: C9              RET                         ; Return to caller's caller
```

# Misc

```code

DrawBottomLine:
; Draw a 1px line across the player's stash at the bottom of the screen.
;
0215: 3E 01           MVI     A,0x01              ; Bit 1 set ... going to draw a 1-pixel stripe down left side
0217: 06 E0           MVI     B,0xE0              ; All the way down the screen
0219: 21 02 24        LXI     H,0x2402            ; Screen coordinates (3rd byte from upper left)
021C: C3 11 12        JMP     0x1211              ; {} Draw line down left side

AddDelta:
; HL points to descriptor: DX DY XX YY except DX is already loaded in C
; ** Why the "already loaded" part? Why not just load it here?
;
021F: 23              INX     H                   ; We loaded delta-x already ... skip over it
0220: 46              MOV     B,M                 ; Get delta-y
0221: 23              INX     H                   ; Skip over it
0222: 79              MOV     A,C                 ; Add delta-x ...
0223: 86              ADD     M                   ; ... to x
0224: 77              MOV     M,A                 ; Store new x
0225: 23              INX     H                   ; Skip to y
0226: 78              MOV     A,B                 ; Add delta-y ...
0227: 86              ADD     M                   ; ... to y
0228: 77              MOV     M,A                 ; Store new y
0229: C9              RET                         ; Done

CopyRAMMirror:
; Block copy ROM mirror 1B00-1881 to initialize RAM at 2000-20BF.
;
022A: 06 C0           MVI     B,0xC0              ; Number of bytes

CopyMirrorB:
022C: 11 00 1B        LXI     D,0x1B00            ; RAM mirror in ROM
022F: 21 00 20        LXI     H,0x2000            ; {ram.waitOnDraw} Start of RAM
0232: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} Copy [DE]->[HL] and return
```

# Copy/Restore Shields

```code

DrawShieldPl1:
; Draw the shields for player 1 (draws it in the buffer in the player's data area).
;
0235: 21 42 21        LXI     H,0x2142            ; Player 1 shield buffer (remember between games in multi-player)
0238: C3 3E 02        JMP     0x023E              ; {} Common draw point

;
DrawShieldPl2:
; Draw the shields for player 1 (draws it in the buffer in the player's data area).
;
023B: 21 42 22        LXI     H,0x2242            ; Player 2 shield buffer (remember between games in multi-player)

;
023E: 0E 04           MVI     C,0x04              ; Going to draw 4 shields
0240: 11 1C 1D        LXI     D,0x1D1C            ; Shield pixel pattern
0243: D5              PUSH    D                   ; Hold the start for the next shield
0244: 06 2C           MVI     B,0x2C              ; 44 bytes to copy
0246: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Block copy DE to HL (B bytes)
0249: D1              POP     D                   ; Restore start of shield pattern
024A: 0D              DCR     C                   ; Drawn all shields?
024B: C2 43 02        JNZ     0x0243              ; {} No ... go draw them all
024E: C9              RET                         ; Done

RememberShields1:
; Copy shields on the screen to player 1's data area.
;
024F: 3E 01           MVI     A,0x01              ; Not zero means remember
0251: C3 61 02        JMP     0x0261              ; {} Shuffle-shields player 1

RememberShields2:
; Copy shields on the screen to player 2's data area.
;
0254: 3E 01           MVI     A,0x01              ; Not zero means remember
0256: C3 5A 02        JMP     0x025A              ; {} Shuffle-shields player 2

RestoreShields2:
; Copy shields from player 2's data area to screen.
;
0259: AF              XRA     A                   ; Zero means restore
025A: 11 42 22        LXI     D,0x2242            ; Player 2 shield buffer (remember between games in multi-player)
025D: C3 64 02        JMP     0x0264              ; {code.CopyShields} Shuffle-shields player 2

RestoreShields1:
; Copy shields from player 1's data area to screen.
;
0260: AF              XRA     A                   ; Zero means restore
0261: 11 42 21        LXI     D,0x2142            ; Player 1 shield buffer (remember between games in multi-player)

CopyShields:
; A is 1 for screen-to-buffer, 0 for to buffer-to-screen
; HL is screen coordinates of first shield. There are 23 rows between shields.
; DE is sprite buffer in memory.
;
0264: 32 81 20        STA     0x2081              ; {ram.tmp2081} Remember copy/restore flag
0267: 01 02 16        LXI     B,0x1602            ; 22 rows, 2 bytes/row (for 1 shield pattern)
026A: 21 06 28        LXI     H,0x2806            ; Screen coordinates
026D: 3E 04           MVI     A,0x04              ; Four shields to move
026F: F5              PUSH    PSW                 ; Hold shield count
0270: C5              PUSH    B                   ; Hold sprite-size
0271: 3A 81 20        LDA     0x2081              ; {ram.tmp2081} Get back copy/restore flag
0274: A7              ANA     A                   ; Not zero ...
0275: C2 88 02        JNZ     0x0288              ; {} ... means remember shidles
0278: CD E9 17        CALL    0x17E9              ; {code.RestoreShields} Restore player's shields
027B: C1              POP     B                   ; Get back sprite-size
027C: F1              POP     PSW                 ; Get back shield count
027D: 3D              DCR     A                   ; Have we moved all shields?
027E: C8              RZ                          ; Yes ... out
027F: D5              PUSH    D                   ; Hold sprite buffer
0280: 11 E0 02        LXI     D,0x02E0            ; Add 2E0 (23 rows) to get to ...
0283: 19              DAD     D                   ; ... next shield on screen
0284: D1              POP     D                   ; restore sprite buffer
0285: C3 6F 02        JMP     0x026F              ; {} Go back and do all

;
0288: CD C1 11        CALL    0x11C1              ; {code.RememberShields} Remember player's shields
028B: C3 7B 02        JMP     0x027B              ; {} Continue with next shield
```

# Game Objects

```code

RunGameObjs:
; Process game objects. Each game object has a 16 byte structure. The handler routine for the object
; is at xx03 and xx04 of the structure. The pointer to xx04 is pushed onto the stack before calling
; the handler.
;
; All game objects (except task 0 ... the player) are called at the mid-screen and end-screen renderings.
; Each object decides when to run based on its Y (not rotated) coordinate. If an object is on the lower
; half of the screen then it does its work when the beam is at the top of the screen. If an object is
; on the top of the screen then it does its work when the beam is at the bottom. This keeps the
; object from updating while it is being drawn which would result in an ugly flicker.
;
;
; The player is only processed at the mid-screen interrupt. I am not sure why.
;
; The first three bytes of the structure are used for status and timers.
;
; If the first byte is FF then the end of the game-task list has been reached.
; If the first byte is FE then the object is skipped.
;
; If the first-two bytes are non-zero then they are treated like a two-byte counter
; and decremented as such. The 2nd byte is the LSB (moves the fastest).
;
; If the first-two bytes are zero then the third byte is treated as an additional counter. It
; is decremented as such.
;
; When all three bytes reach zero the task is executed.
;
; The third-byte-counter was used as a speed-governor for the player's object, but evidently even the slowest
; setting was too slow. It got changed to 0 (fastest possible).
;
028E: 21 10 20        LXI     H,0x2010            ; {ram.obj0TimerMSB} First game object (active player)
0291: 7E              MOV     A,M                 ; Have we reached the ...
0292: FE FF           CPI     0xFF                ; ... end of the object list?
0294: C8              RZ                          ; Yes ... done
0295: FE FE           CPI     0xFE                ; Is object active?
0297: CA C7 02        JZ      0x02C7              ; {} No ... skip it
029A: 23              INX     H                   ; xx01
029B: 46              MOV     B,M                 ; First byte to B
029C: 4F              MOV     C,A                 ; Hold 1st byte
029D: B0              ORA     B                   ; OR 1st and 2nd byte
029E: 79              MOV     A,C                 ; Restore 1st byte
029F: C2 BD 02        JNZ     0x02BD              ; {} If word at xx00,xx02 is non zero then decrement it

;
02A2: 23              INX     H                   ; xx02
02A3: 7E              MOV     A,M                 ; Get byte counter
02A4: A7              ANA     A                   ; Is it 0?
02A5: C2 CE 02        JNZ     0x02CE              ; {} No ... decrement byte counter at xx02
02A8: 23              INX     H                   ; xx03
02A9: 5E              MOV     E,M                 ; Get handler address LSB
02AA: 23              INX     H                   ; xx04
02AB: 56              MOV     D,M                 ; Get handler address MSB
02AC: E5              PUSH    H                   ; Remember pointer to MSB
02AD: EB              XCHG                        ; Handler address to HL
02AE: E5              PUSH    H                   ; Now to stack (making room for indirect call)
02AF: 21 B5 02        LXI     H,0x02B5            ; Return address to 02B5
02B2: E3              XTHL                        ; Return address (02B5) now on stack. Handler in HL.
02B3: D5              PUSH    D                   ; Push pointer to data struct (xx04) for handler to use
02B4: E9              PCHL                        ; Run object's code (will return to next line)
02B5: E1              POP     H                   ; Restore pointer to xx04
02B6: 11 0C 00        LXI     D,0x000C            ; Offset to next ...
02B9: 19              DAD     D                   ; ... game task (C+4=10)
02BA: C3 91 02        JMP     0x0291              ; {} Do next game task

;
; Word at xx00 and xx01 is non-zero. Decrement it and move to next task.
02BD: 05              DCR     B                   ; Decrement ...
02BE: 04              INR     B                   ; ... two ...
02BF: C2 C3 02        JNZ     0x02C3              ; {} ... byte ...
02C2: 3D              DCR     A                   ; ... value ...
02C3: 05              DCR     B                   ; ... at ...
02C4: 70              MOV     M,B                 ; ... xx00 ...
02C5: 2B              DCX     H                   ; ... and ...
02C6: 77              MOV     M,A                 ; ... xx01

;
02C7: 11 10 00        LXI     D,0x0010            ; Next ...
02CA: 19              DAD     D                   ; ... object descriptor
02CB: C3 91 02        JMP     0x0291              ; {} Keep processing game objects

;
; Word at xx00 and xx01 is zero and byte at xx02 is non-zero. Decrement xx02 and
; move to next task.
02CE: 35              DCR     M                   ; Decrement the xx02 counter
02CF: 2B              DCX     H                   ; Back up to ...
02D0: 2B              DCX     H                   ; ... start of game task
02D1: C3 C7 02        JMP     0x02C7              ; {} Next game task

GameObj0:
; Game object 0: Move/draw the player
;
; This task is only called at the mid-screen ISR. It ALWAYS does its work here, even though
; the player can be on the top or bottom of the screen (not rotated).
;
02D4: E1              POP     H                   ; Get player object structure 2014
02D5: 23              INX     H                   ; Point to blow-up status
02D6: 7E              MOV     A,M                 ; Get player blow-up status
02D7: FE FF           CPI     0xFF                ; Player is blowing up?
02D9: CA 88 03        JZ      0x0388              ; {} No ... go do normal movement

;
; Handle blowing up player
02DC: 23              INX     H                   ; Point to blow-up delay count
02DD: 35              DCR     M                   ; Decrement the blow-up delay
02DE: C0              RNZ                         ; Not time for a new blow-up sprite ... out
02DF: 47              MOV     B,A                 ; Hold sprite image number
02E0: AF              XRA     A                   ; 0
02E1: 32 68 20        STA     0x2068              ; {ram.playerOK} Player is NOT OK ... player is blowing up
02E4: 32 69 20        STA     0x2069              ; {ram.enableAlienFire} Alien fire is disabled
02E7: 3E 30           MVI     A,0x30              ; Reset count ...
02E9: 32 6A 20        STA     0x206A              ; {ram.alienFireDelay} ... till alien shots are enabled
02EC: 78              MOV     A,B                 ; Restore sprite image number (used if we go to 39B)
02ED: 36 05           MVI     M,0x05              ; Reload time between blow-up changes
02EF: 23              INX     H                   ; Point to number of blow-up changes
02F0: 35              DCR     M                   ; Count down blow-up changes
02F1: C2 EB 03        JNZ     0x03EB              ; {code.DrawPlayerDie} Still blowing up ... go draw next sprite

;
; Blow up finished
02F4: 2A 1A 20        LHLD    0x201A              ; {ram.playerYr} Player's coordinates
02F7: 06 10           MVI     B,0x10              ; 16 Bytes
02F9: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert player position to screen address
02FC: CD 10 12        CALL    0x1210              ; {code.ClearSmallSprite} Erase the player (16 rows)
02FF: 21 10 20        LXI     H,0x2010            ; {ram.obj0TimerMSB} Restore player ...
0302: 11 10 1B        LXI     D,0x1B10            ; ... structure ...
0305: 06 10           MVI     B,0x10              ; ... from ...
0307: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} ... ROM mirror
030A: 06 00           MVI     B,0x00              ; Turn off ...
030C: CD 5C 17        CALL    0x175C              ; {code.SoundBits3Off} ... all sounds
030F: 3A 6D 20        LDA     0x206D              ; {ram.invaded} Has rack reached ...
0312: A7              ANA     A                   ; ... the bottom of the screen?
0313: C0              RNZ                         ; Yes ... done here
0314: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Are we in ...
0317: A7              ANA     A                   ; ... game mode?
0318: C8              RZ                          ; No ... return to splash screens
0319: 31 00 24        LXI     SP,0x2400           ; We aren't going to return
031C: FB              EI                          ; Enable interrupts (we just dropped the ISR context)
031D: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks} Disable game tasks
0320: CD 17 0B        CALL    0x0B17              ; {} Get number of ships for active player
0323: A7              ANA     A                   ; Any left?
0324: CA 53 14        JZ      0x1453              ; {} No ... handle game over for player
0327: CD A5 16        CALL    0x16A5              ; {} Get player-alive status pointer
032A: 7E              MOV     A,M                 ; Is player ...
032B: A7              ANA     A                   ; ... alive?
032C: CA 7C 03        JZ      0x037C              ; {} Yes ... remove a ship from player's stash and reenter game loop
032F: 3A CE 20        LDA     0x20CE              ; {ram.twoPlayers} Multi-player game
0332: A7              ANA     A                   ; Only one player?
0333: CA 7C 03        JZ      0x037C              ; {} Yes ... remove a ship from player's stash and reenter game loop
0336: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Player data MSB
0339: F5              PUSH    PSW                 ; Hold the MSB
033A: 0F              RRC                         ; Player 1 is active player?
033B: DA 82 03        JC      0x0382              ; {} Yes ... go store player 1 shields and come back to 0349
033E: CD 54 02        CALL    0x0254              ; {code.RememberShields2} No ... go store player 2 shields
0341: 3A 08 20        LDA     0x2008              ; {ram.refAlienDXr} Part II reads the ref-alien info directly ...
0344: 47              MOV     B,A                 ; ... B = delta X
0345: 2A 09 20        LHLD    0x2009              ; {ram.refAlienYr} ... DE = Y,X ...
0348: EB              XCHG                        ; ... coordinates
0349: CD 6C 0A        CALL    0x0A6C              ; {code.GetAlRefPtr} Get ref-alien info and pointer to storage
034C: 73              MOV     M,E                 ; Hold the ...
034D: 23              INX     H                   ; ... ref-alien ...
034E: 72              MOV     M,D                 ; ... screen coordinates
034F: 2B              DCX     H                   ; Back up ...
0350: 2B              DCX     H                   ; .. to delta storage
0351: 70              MOV     M,B                 ; Store ref-alien's delta (direction)
0352: CD 2A 02        CALL    0x022A              ; {code.CopyRAMMirror} Copy RAM mirror (getting ready to switch players)
0355: F1              POP     PSW                 ; Restore active player MSB
0356: 0F              RRC                         ; Player 1?
0357: 3E 21           MVI     A,0x21              ; Player 1 data pointer
0359: 06 00           MVI     B,0x00              ; Cocktail bit=0 (player 1)
035B: D2 62 03        JNC     0x0362              ; {} It was player one ... keep data for player 2
035E: 06 20           MVI     B,0x20              ; Cocktail bit=1 (player 2)
0360: 3E 22           MVI     A,0x22              ; Player 2 data pointer
0362: 32 67 20        STA     0x2067              ; {ram.playerDataMSB} Change players
0365: CD A2 0C        CALL    0x0CA2              ; {code.TwoSecDelay} Two second delay
0368: AF              XRA     A                   ; Clear the player-object ...
0369: 32 11 20        STA     0x2011              ; {ram.obj0TimerLSB} ... timer (player can move instantly after switching players)
036C: CD FD 00        CALL    0x00FD              ; {code.SetFlipDelay} Set the cocktail bit (B) on port 5
036F: 3C              INR     A                   ; Fleet sound 1 (first tone)
0370: 32 98 20        STA     0x2098              ; {ram.soundPort5} Set the port 5 hold
0373: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear center window
0376: CD FF 17        CALL    0x17FF              ; {code.RemoveShip} Remove a ship and update indicators
0379: C3 FD 08        JMP     0x08FD              ; {} Tell the players that the switch has been made

;
037C: CD FF 17        CALL    0x17FF              ; {code.RemoveShip} Remove a ship and update indicators
037F: C3 36 09        JMP     0x0936              ; {} Continue into game loop

;
0382: CD 4F 02        CALL    0x024F              ; {code.RememberShields1} Remember the shields for player 1
0385: C3 41 03        JMP     0x0341              ; {} Back to switching-players above

; Player not blowing up ... handle inputs
0388: 21 68 20        LXI     H,0x2068            ; {ram.playerOK} Player OK flag
038B: 36 01           MVI     M,0x01              ; Flag 1 ... player is OK
038D: 23              INX     H                   ; 2069
038E: 7E              MOV     A,M                 ; Alien shots enabled?
038F: A7              ANA     A                   ; Set flags
0390: C2 9B 03        JNZ     0x039B              ; {} Alien fire already enabled ... skip
0393: 23              INX     H                   ; 206A alien-fire delay
0394: 35              DCR     M                   ; Count down until aliens can fire
0395: C2 9B 03        JNZ     0x039B              ; {} Not yet
0398: 2B              DCX     H                   ; 2069
0399: 36 01           MVI     M,0x01              ; Enable alien fire
039B: 3A 1B 20        LDA     0x201B              ; {ram.playerXr} Current player coordinates
039E: 47              MOV     B,A                 ; Hold it
039F: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Are we in ...
03A2: A7              ANA     A                   ; ... game mode?
03A3: C2 B4 03        JNZ     0x03B4              ; {} Yes ... use switches as player controls

;
03A6: 3A 1D 20        LDA     0x201D              ; {ram.nextDemoCmd} Get demo command
03A9: 0F              RRC                         ; Is it right?
03AA: DA D1 03        JC      0x03D1              ; {code.MovePlayerRight} Yes ... do right
03AD: 0F              RRC                         ; Is it left?
03AE: DA DE 03        JC      0x03DE              ; {code.MovePlayerLeft} Yes ... do left
03B1: C3 C0 03        JMP     0x03C0              ; {} Skip over movement (draw player and out)

; Player is in control
03B4: CD E8 15        CALL    0x15E8              ; {code.ReadInputs} Read active player controls
03B7: 07              RLC                         ; Test for ...
03B8: 07              RLC                         ; ... right button
03B9: DA D1 03        JC      0x03D1              ; {code.MovePlayerRight} Yes ... handle move right
03BC: 07              RLC                         ; Test for left button
03BD: DA DE 03        JC      0x03DE              ; {code.MovePlayerLeft} Yes ... handle move left

; Draw player sprite
03C0: 21 18 20        LXI     H,0x2018            ; {ram.plyrSprPicL} Active player descriptor
03C3: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Load 5 byte sprite descriptor in order: EDLHB
03C6: CD C7 17        CALL    0x17C7              ; {code.ConvToScr} Convert HL to screen coordinates
03C9: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw player
03CC: AF              XRA     A                   ; Clear the task timer. Nobody changes this but it could have ...
03CD: 32 12 20        STA     0x2012              ; {ram.obj0TimerExtra} ... been speed set for the player with a value other than 0
03D0: C9              RET                         ; Out

MovePlayerRight:
03D1: 78              MOV     A,B                 ; Player coordinate
03D2: FE D8           CPI     0xD8                ; At right edge? (Part II stops one pixel sooner: D8 instead of D9)
03D4: CA C0 03        JZ      0x03C0              ; {} Yes ... ignore this
03D7: 3C              INR     A                   ; Bump X coordinate
03D8: 32 1B 20        STA     0x201B              ; {ram.playerXr} New X coordinate
03DB: C3 C0 03        JMP     0x03C0              ; {} Draw player and out

MovePlayerLeft:
; Handle player moving left
03DE: 78              MOV     A,B                 ; Player coordinate
03DF: FE 30           CPI     0x30                ; At left edge
03E1: CA C0 03        JZ      0x03C0              ; {} Yes ... ignore this
03E4: 3D              DCR     A                   ; Bump X coordinate
03E5: 32 1B 20        STA     0x201B              ; {ram.playerXr} New X coordinate
03E8: C3 C0 03        JMP     0x03C0              ; {} Draw player and out

DrawPlayerDie:
; Toggle the player's blowing-up sprite between two pictures and draw it
03EB: 3C              INR     A                   ; Toggle blowing-up ...
03EC: E6 01           ANI     0x01                ; ... player sprite (0,1,0,1)
03EE: 32 15 20        STA     0x2015              ; {ram.playerAlive} Hold current state
03F1: 07              RLC                         ; *2
03F2: 07              RLC                         ; *4
03F3: 07              RLC                         ; *8
03F4: 07              RLC                         ; *16
03F5: 21 91 1C        LXI     H,0x1C91            ; Base blow-up sprite location
03F8: 85              ADD     L                   ; Offset sprite ...
03F9: 6F              MOV     L,A                 ; ... pointer
03FA: 22 18 20        SHLD    0x2018              ; {ram.plyrSprPicL} New blow-up sprite picture
03FD: C3 C0 03        JMP     0x03C0              ; {} Draw player and out

GameObj1:
; Game object 1: Move/draw the player shot
;
; This task executes at either mid-screen ISR (if it is on the top half of the non-rotated screen) or
; at the end-screen ISR (if it is on the bottom half of the screen).
;
0400: 11 2A 20        LXI     D,0x202A            ; {ram.obj1CoorXr} Object's Yn coordiante
0403: CD 86 17        CALL    0x1786              ; {code.CompYToBeam} Compare to screen-update location
0406: E1              POP     H                   ; Pointer to task data
0407: D0              RNC                         ; Make sure we are in the right ISR
0408: 23              INX     H                   ; Point to 2025 ... the shot status
0409: 7E              MOV     A,M                 ; Get shot status
040A: A7              ANA     A                   ; Return if ...
040B: C8              RZ                          ; ... no shot is active

;
040C: FE 01           CPI     0x01                ; Shot just starting (requested elsewhere)?
040E: CA 3F 04        JZ      0x043F              ; {code.InitPlyShot} Yes ... go initiate shot

;
0411: FE 02           CPI     0x02                ; Progressing normally?
0413: CA 4F 04        JZ      0x044F              ; {code.MovePlyShot} Yes ... go move it

;
0416: 23              INX     H                   ; 2026
0417: FE 03           CPI     0x03                ; Shot blowing up (not because of alien)?
0419: C2 6F 04        JNZ     0x046F              ; {} No ... try other options

;
; Shot blowing up because it left the playfield, hit a shield, or hit another bullet
041C: 35              DCR     M                   ; Decrement the timer
041D: CA 7B 04        JZ      0x047B              ; {code.EndOfBlowup} If done then
0420: 7E              MOV     A,M                 ; Get timer value
0421: FE 0F           CPI     0x0F                ; Starts at 10 ... first decrement brings us here
0423: C0              RNZ                         ; Not the first time ... explosion has been drawn

; Draw explosion first pass through timer loop
0424: E5              PUSH    H                   ; Hold pointer to data
0425: CD 75 04        CALL    0x0475              ; {code.ReadPlyShot} Read shot descriptor
0428: CD 97 11        CALL    0x1197              ; {code.EraseShifted} Erase the sprite
042B: E1              POP     H                   ; 2026 (timer flag)
042C: 23              INX     H                   ; 2027 point to sprite LSB
042D: 34              INR     M                   ; Change 1CB1 to 1CB2
042E: 23              INX     H                   ; 2028
042F: 23              INX     H                   ; 2029
0430: 35              DCR     M                   ; Drop X coordinate ...
0431: 35              DCR     M                   ; ... by 2
0432: 23              INX     H                   ; 202A
0433: 35              DCR     M                   ; Drop Y ...
0434: 35              DCR     M                   ; ... coordinate ...
0435: 35              DCR     M                   ; ... by ...
0436: 23              INX     H                   ; ... 3
0437: 36 08           MVI     M,0x08              ; 202B 8 bytes in size of sprite
0439: CD 75 04        CALL    0x0475              ; {code.ReadPlyShot} Read player shot structure
043C: C3 4E 11        JMP     0x114E              ; {code.DrawShiftedSprite} Draw sprite and out

;
InitPlyShot:
043F: 3C              INR     A                   ; Type is now ...
0440: 77              MOV     M,A                 ; ... 2 (in progress)
0441: 3A 1B 20        LDA     0x201B              ; {ram.playerXr} Players Y coordinate
0444: C6 08           ADI     0x08                ; To center of player
0446: 32 2A 20        STA     0x202A              ; {ram.obj1CoorXr} Shot's Y coordinate
0449: CD 75 04        CALL    0x0475              ; {code.ReadPlyShot} Read 5 byte structure
044C: C3 4E 11        JMP     0x114E              ; {code.DrawShiftedSprite} Draw sprite and out

;
MovePlyShot:
044F: CD 75 04        CALL    0x0475              ; {code.ReadPlyShot} Read the shot structure
0452: D5              PUSH    D                   ; Hold pointer to sprite image
0453: E5              PUSH    H                   ; Hold sprite coordinates
0454: C5              PUSH    B                   ; Hold sprite size (in B)
0455: CD 97 11        CALL    0x1197              ; {code.EraseShifted} Erase the sprite from the screen
0458: C1              POP     B                   ; Restore size
0459: E1              POP     H                   ; Restore coords
045A: D1              POP     D                   ; Restore pointer to sprite image
045B: 3A 2C 20        LDA     0x202C              ; {ram.shotDeltaX} DeltaX for shot
045E: 85              ADD     L                   ; Move the shot ...
045F: 6F              MOV     L,A                 ; ... up the screen
0460: 32 29 20        STA     0x2029              ; {ram.obj1CoorYr} Store shot's new X coordinate
0463: CD D6 11        CALL    0x11D6              ; {code.DrawSprCollision} Draw sprite with collision detection
0466: 3A 61 20        LDA     0x2061              ; {ram.collision} Test for ...
0469: A7              ANA     A                   ; ... collision
046A: C8              RZ                          ; No collision ... out

;
; Collision with alien detected
046B: 32 02 20        STA     0x2002              ; {ram.alienIsExploding} Set to not-0 indicating ...
046E: C9              RET                         ; ... an alien is blowing up

;
; Other shot-status options
046F: FE 05           CPI     0x05                ; Alien explosion in progress?
0471: C8              RZ                          ; Yes ... nothing to do
0472: C3 7B 04        JMP     0x047B              ; {code.EndOfBlowup} Anything else erases the shot and removes it from duty

ReadPlyShot:
0475: 21 27 20        LXI     H,0x2027            ; {ram.obj1ImageLSB} Read 5 byte sprite structure for ...
0478: C3 BB 17        JMP     0x17BB              ; {code.ReadDesc} ... player shot

EndOfBlowup:
047B: CD 75 04        CALL    0x0475              ; {code.ReadPlyShot} Read the shot structure
047E: CD 97 11        CALL    0x1197              ; {code.EraseShifted} Erase the player's shot
0481: 21 25 20        LXI     H,0x2025            ; {ram.plyrShotStatus} Reinit ...
0484: 11 25 1B        LXI     D,0x1B25            ; ... shot structure ...
0487: 06 07           MVI     B,0x07              ; ... from ...
0489: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} ... ROM mirror
048C: 2A 8D 20        LHLD    0x208D              ; {ram.sauScoreLSB} Get pointer to saucer-score table
048F: 2C              INR     L                   ; Every shot explosion advances it one
0490: E5              PUSH    H                   ; Hold saucer-score pointer
0491: CD F9 13        CALL    0x13F9              ; {code.GetPlayerDataPage} H = active player's data page
0494: 2E F8           MVI     L,0xF8              ; 2xF8 counts ...
0496: 34              INR     M                   ; ... the player's shots for this rack
0497: E1              POP     H                   ; Restore saucer-score pointer
0498: 7D              MOV     A,L                 ; Have we passed ...
0499: FE 5F           CPI     0x5F                ; ... the end at 1D5F (the same off-by-one as the original: the last entry is never used)
049B: DA A0 04        JC      0x04A0              ; {} No .... keep it
049E: 2E 50           MVI     L,0x50              ; Wrap back around to 1D50
04A0: 22 8D 20        SHLD    0x208D              ; {ram.sauScoreLSB} New score pointer
04A3: 2A 8F 20        LHLD    0x208F              ; {ram.shotCountLSB} Increments with every shot ...
04A6: 2C              INR     L                   ; ... but only LSB ** ...
04A7: 22 8F 20        SHLD    0x208F              ; {ram.shotCountLSB} ... used for saucer direction

;
04AA: 3A 84 20        LDA     0x2084              ; {ram.saucerActive} Is saucer ...
04AD: A7              ANA     A                   ; ... on screen?
04AE: C0              RNZ                         ; Yes ... don't reset it

;
; Setup saucer direction for next trip
04AF: 7E              MOV     A,M                 ; Shot counter
04B0: E6 01           ANI     0x01                ; Lowest bit set?
04B2: 01 29 02        LXI     B,0x0229            ; Xr delta of 2 starting at Xr=29
04B5: C2 BB 04        JNZ     0x04BB              ; {} Yes ... use 2/29
04B8: 01 E0 FE        LXI     B,0xFEE0            ; No ... Xr delta of -2 starting at Xr=E0
04BB: 21 8A 20        LXI     H,0x208A            ; {ram.saucerPriPicMSB} Saucer descriptor
04BE: 71              MOV     M,C                 ; Store Xr coordinate
04BF: 23              INX     H                   ; Point to ...
04C0: 23              INX     H                   ; ... delta Xr
04C1: 70              MOV     M,B                 ; Store delta Xr
04C2: C9              RET                         ; Done

GameObj2:
; Game object 2: Alien rolling-shot (targets player specifically)
;
; The 2-byte value at 2038 is where the firing-column-table-pointer would be (see other
; shots ... next game objects). This shot doesn't use that table. It targets the player
; specifically. Instead the value is used as a flag to have the shot skip its first
; attempt at firing every time it is reinitialized (when it blows up).
;
; The task-timer at 2032 is copied to 2080 in the game loop. The flag is used as a
; synchronization flag to keep all the shots processed on separate interrupt ticks. This
; has the main effect of slowing the shots down.
;
; When the timer is 2 the squiggly-shot/saucer (object 4 ) runs.
; When the timer is 1 the plunger-shot (object 3) runs.
; When the timer is 0 this object, the rolling-shot, runs.
;
04C3: E1              POP     H                   ; Game object data
04C4: 3A 32 1B        LDA     0x1B32              ; {} Restore delay from ...
04C7: 32 32 20        STA     0x2032              ; {ram.obj2TimerExtra} ... ROM mirror (value 2)
04CA: 2A 38 20        LHLD    0x2038              ; {ram.rolShotCFirLSB} Get pointer to ...
04CD: 7D              MOV     A,L                 ; ... column-firing table.
04CE: B4              ORA     H                   ; All zeros?
04CF: C2 D7 04        JNZ     0x04D7              ; {} No ... must be a valid column. Go fire.
04D2: 2B              DCX     H                   ; Decrement the counter
04D3: 22 38 20        SHLD    0x2038              ; {ram.rolShotCFirLSB} Store new counter value (run the shot next time)
04D6: C9              RET                         ; And out
04D7: 11 35 20        LXI     D,0x2035            ; {ram.rolShotStatus} Rolling-shot data structure
04DA: 3E FC           MVI     A,0xFC              ; LSB of last byte of last picture of the rolling shot
04DC: CD A5 05        CALL    0x05A5              ; {code.ToShotStruct} Set code to handle rolling-shot
04DF: 3A 46 20        LDA     0x2046              ; {ram.pluShotStepCnt} Get the plunger-shot step count
04E2: 32 70 20        STA     0x2070              ; {ram.otherShot1} Hold it
04E5: 3A 56 20        LDA     0x2056              ; {ram.squShotStepCnt} Get the squiggly-shot step count
04E8: 32 71 20        STA     0x2071              ; {ram.otherShot2} Hold it
04EB: CD B8 05        CALL    0x05B8              ; {code.HandleAlienShot} Handle active shot structure
04EE: 3A 78 20        LDA     0x2078              ; {ram.aShotBlowCnt} Blow up counter
04F1: A7              ANA     A                   ; Test if shot has cycled through blowing up
04F2: 21 35 20        LXI     H,0x2035            ; {ram.rolShotStatus} Rolling-shot data structure
04F5: C2 B0 05        JNZ     0x05B0              ; {code.FromShotStruct} If shot is still running, copy the updated data and out

ResetShot:
; The rolling-shot has blown up. Reset the data structure.
04F8: 11 30 1B        LXI     D,0x1B30            ; Reload ...
04FB: 21 30 20        LXI     H,0x2030            ; {ram.obj2TimerMSB} ... object ...
04FE: 06 10           MVI     B,0x10              ; ... structure ...
0500: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} ... from ROM mirror and out

GameObj3:
; Game object 3: Alien plunger shot
;
; This is the plunger shot that drops from the column-firing table. Part II does not use the
; plunger shot at all from round 4 on.
0503: CD F9 07        CALL    0x07F9              ; {code.GetRoundNum} Get the player's round number
0506: FE 04           CPI     0x04                ; Round 4 or later?
0508: E1              POP     H                   ; Game object data (not used)
0509: D2 58 05        JNC     0x0558              ; {} Yes ... permanently disable the plunger shot
050C: 3A 6E 20        LDA     0x206E              ; {ram.skipPlunger} One alien left? Skip plunger shot?
050F: A7              ANA     A                   ; Check
0510: C0              RNZ                         ; Yes. Only one alien. Skip this shot.
0511: 3A 80 20        LDA     0x2080              ; {ram.shotSync} Sync flag (copied from GO-2's timer value)
0514: FE 01           CPI     0x01                ; GO-2 and GO-4 are idle?
0516: C0              RNZ                         ; No ... only one shot at a time
0517: 11 45 20        LXI     D,0x2045            ; {ram.pluShotStatus} Plunger alien shot data structure
051A: 3E F0           MVI     A,0xF0              ; LSB of last byte of last picture of the plunger shot
051C: CD A5 05        CALL    0x05A5              ; {code.ToShotStruct} Copy the plunger alien to the active structure
051F: 3A 36 20        LDA     0x2036              ; {ram.rolShotStepCnt} Step count from rolling-shot
0522: 32 70 20        STA     0x2070              ; {ram.otherShot1} Hold it
0525: 3A 56 20        LDA     0x2056              ; {ram.squShotStepCnt} Step count from squiggly shot
0528: 32 71 20        STA     0x2071              ; {ram.otherShot2} Hold it
052B: CD B8 05        CALL    0x05B8              ; {code.HandleAlienShot} Handle active shot structure
052E: 3A 76 20        LDA     0x2076              ; {ram.aShotCFirLSB} LSB of column-firing table
0531: FE 90           CPI     0x90                ; Been through all entries in the table (table is now at 1A80)?
0533: DA 3C 05        JC      0x053C              ; {} Not yet ... table is OK
0536: 3A 48 1B        LDA     0x1B48              ; {} Been through all ..
0539: 32 76 20        STA     0x2076              ; {ram.aShotCFirLSB} ... so reset pointer into firing-column table
053C: 3A 78 20        LDA     0x2078              ; {ram.aShotBlowCnt} Get the blow up timer
053F: A7              ANA     A                   ; Zero means shot is done
0540: 21 45 20        LXI     H,0x2045            ; {ram.pluShotStatus} Plunger shot data
0543: C2 B0 05        JNZ     0x05B0              ; {code.FromShotStruct} If shot is still running, go copy the updated data and out

;
0546: 11 40 1B        LXI     D,0x1B40            ; Reload ...
0549: 21 40 20        LXI     H,0x2040            ; {ram.obj3TimerMSB} ... object ...
054C: 06 10           MVI     B,0x10              ; ... structure ...
054E: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} ... from mirror

;
0551: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens on screen
0554: 3D              DCR     A                   ; Is there only one left?
0555: C2 5D 05        JNZ     0x055D              ; {} No ... move on
0558: 3E 01           MVI     A,0x01              ; Disable plunger shot ...
055A: 32 6E 20        STA     0x206E              ; {ram.skipPlunger} ... when only one alien remains
055D: 2A 76 20        LHLD    0x2076              ; {ram.aShotCFirLSB} Set the plunger shot's ...
0560: C3 D5 06        JMP     0x06D5              ; {} ... column-firing pointer data
0563: E1

HandleSquiggly:
0564: 11 55 20        LXI     D,0x2055            ; {ram.squShotStatus}
0567: 3E DE           MVI     A,0xDE              ; LSB of last byte of the squiggly picture
0569: CD A5 05        CALL    0x05A5              ; {code.ToShotStruct} Copy squiggly shot to
056C: 3A 46 20        LDA     0x2046              ; {ram.pluShotStepCnt} Get plunger ...
056F: 32 70 20        STA     0x2070              ; {ram.otherShot1} ... step count
0572: 3A 36 20        LDA     0x2036              ; {ram.rolShotStepCnt} Get rolling ...
0575: 32 71 20        STA     0x2071              ; {ram.otherShot2} ... step count
0578: CD B8 05        CALL    0x05B8              ; {code.HandleAlienShot} Handle active shot structure
057B: 3A 76 20        LDA     0x2076              ; {ram.aShotCFirLSB} LSB of column-firing table pointer
057E: FE 95           CPI     0x95                ; Have we processed all entries?
0580: DA 89 05        JC      0x0589              ; {} No ... don't reset it
0583: 3A 58 1B        LDA     0x1B58              ; {} Reset the pointer ...
0586: 32 76 20        STA     0x2076              ; {ram.aShotCFirLSB} ... back to the start of the table
0589: 3A 78 20        LDA     0x2078              ; {ram.aShotBlowCnt} Check to see if squiggly shot is done
058C: A7              ANA     A                   ; 0 means blow-up timer expired
058D: 21 55 20        LXI     H,0x2055            ; {ram.squShotStatus} Squiggly shot data structure
0590: C2 B0 05        JNZ     0x05B0              ; {code.FromShotStruct} If shot is still running, go copy the updated data and out

; Shot explosion is over. Remove the shot.
0593: 11 50 1B        LXI     D,0x1B50            ; Reload
0596: 21 50 20        LXI     H,0x2050            ; {ram.obj4TimerMSB} ... object ...
0599: 06 10           MVI     B,0x10              ; ... structure ...
059B: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} ... from mirror
059E: 2A 76 20        LHLD    0x2076              ; {ram.aShotCFirLSB} Copy pointer to column-firing table ...
05A1: 22 58 20        SHLD    0x2058              ; {ram.squShotCFirLSB} ... back to data structure (for next shot)
05A4: C9              RET                         ; Done

ToShotStruct:
05A5: 32 7F 20        STA     0x207F              ; {ram.shotPicEnd} LSB of last byte of last picture in sprite
05A8: 21 73 20        LXI     H,0x2073            ; {ram.aShotStatus} Destination is the shot-structure
05AB: 06 0B           MVI     B,0x0B              ; 11 bytes
05AD: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} Block copy and out

FromShotStruct:
05B0: 11 73 20        LXI     D,0x2073            ; {ram.aShotStatus} Source is the shot-structure
05B3: 06 0B           MVI     B,0x0B              ; 11 bytes
05B5: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} Block copy and out

HandleAlienShotChk:
; Part II: no alien shots while shots are halted (rack arrival, name entry).
05B8: 3A E4 20        LDA     0x20E4              ; {ram.shotsHalted} Are alien shots halted?
05BB: A7              ANA     A                   ; Set flags
05BC: C0              RNZ                         ; Yes ... nothing to do

HandleAlienShot:
; Each of the 3 shots copy their data to the 2073 structure (0B bytes) and call this.
; Then they copy back if the shot is still active. Otherwise they copy from the mirror.
;
; The alien "fire rate" is based on the number of steps the other two shots on the screen
; have made. The smallest number-of-steps is compared to the reload-rate. If it is too
; soon then no shot is made. The reload-rate is based on the player's score. The MSB
; is looked up in a table to get the reload-rate. The smaller the rate the faster the
; aliens fire. Setting rate this way keeps shots from walking on each other.
;
05BD: 21 73 20        LXI     H,0x2073            ; {ram.aShotStatus} Start of active shot structure
05C0: 7E              MOV     A,M                 ; Get the shot status
05C1: E6 80           ANI     0x80                ; Is the shot active?
05C3: C2 1A 06        JNZ     0x061A              ; {} Yes ... go move it
05C6: 3A C1 20        LDA     0x20C1              ; {ram.isrSplashTask} ISR splash task
05C9: FE 04           CPI     0x04                ; Shooting the "C" ? (left over from the original: Part II has no "CCOIN" animation)
05CB: 3A 69 20        LDA     0x2069              ; {ram.enableAlienFire} Alien fire enabled flag
05CE: CA 10 06        JZ      0x0610              ; {} (Never taken in Part II)
05D1: A7              ANA     A                   ; Is alien fire enabled?
05D2: C8              RZ                          ; No ... don't start a new shot
05D3: 23              INX     H                   ; 2074 step count of current shot
05D4: 36 00           MVI     M,0x00              ; clear the step count

; Make sure it isn't too soon to fire another shot
05D6: 3A 70 20        LDA     0x2070              ; {ram.otherShot1} Get the step count of the 1st "other shot"
05D9: A7              ANA     A                   ; Any steps made?
05DA: CA E3 05        JZ      0x05E3              ; {} No ... ignore this count
05DD: 47              MOV     B,A                 ; Shuffle off step count
05DE: 3A CF 20        LDA     0x20CF              ; {ram.aShotReloadRate} Get the reload rate (based on MSB of score)
05E1: B8              CMP     B                   ; Too soon to fire again?
05E2: D0              RNC                         ; Yes ... don't fire
05E3: 3A 71 20        LDA     0x2071              ; {ram.otherShot2} Get the step count of the 2nd "other shot"
05E6: A7              ANA     A                   ; Any steps made?
05E7: CA F0 05        JZ      0x05F0              ; {} No steps on any shot ... we are clear to fire
05EA: 47              MOV     B,A                 ; Shuffle off step count
05EB: 3A CF 20        LDA     0x20CF              ; {ram.aShotReloadRate} Get the reload rate (based on MSB of score)
05EE: B8              CMP     B                   ; Too soon to fire again?
05EF: D0              RNC                         ; Yes ... don't fire
05F0: 23              INX     H                   ; 2075
05F1: 7E              MOV     A,M                 ; Get tracking flag
05F2: A7              ANA     A                   ; Does this shot track the player?
05F3: CA 73 06        JZ      0x0673              ; {} Yes ... go make a tracking shot;
05F6: 2A 76 20        LHLD    0x2076              ; {ram.aShotCFirLSB} Column-firing table
05F9: 4E              MOV     C,M                 ; Get next column to fire from
05FA: 23              INX     H                   ; Bump the ...
05FB: 22 76 20        SHLD    0x2076              ; {ram.aShotCFirLSB} ... pointer into column table
05FE: CD 87 06        CALL    0x0687              ; {code.FindInColumn} Find alien in target column
0601: D0              RNC                         ; No alien is alive in target column ... out

;
0602: CD 98 01        CALL    0x0198              ; {code.GetAlienCoords} Get coordinates of alien (lowest alien in firing column)
0605: 79              MOV     A,C                 ; Offset ...
0606: C6 07           ADI     0x07                ; ... Y by 7
0608: 67              MOV     H,A                 ; To H
0609: 7D              MOV     A,L                 ; Offset ...
060A: D6 0A           SUI     0x0A                ; ... X down 10
060C: 6F              MOV     L,A                 ; To L
060D: 22 7B 20        SHLD    0x207B              ; {ram.alienShotYr} Set shot coordinates below alien

;
0610: 21 73 20        LXI     H,0x2073            ; {ram.aShotStatus} Alien shot status
0613: 7E              MOV     A,M                 ; Get the status
0614: F6 80           ORI     0x80                ; Mark this shot ...
0616: 77              MOV     M,A                 ; ... as actively running
0617: 23              INX     H                   ; 2074 step count
0618: 34              INR     M                   ; Give this shot 1 step (it just started)
0619: C9              RET                         ; Out

;
; Move the alien shot
061A: 11 7C 20        LXI     D,0x207C            ; {ram.alienShotXr} Alien-shot Y coordinate
061D: CD 86 17        CALL    0x1786              ; {code.CompYToBeam} Compare to beam position
0620: D0              RNC                         ; Not the right ISR for this shot

;
0621: 23              INX     H                   ; 2073 status
0622: 7E              MOV     A,M                 ; Get shot status
0623: E6 01           ANI     0x01                ; Bit 0 is 1 if blowing up
0625: C2 9B 06        JNZ     0x069B              ; {code.ShotBlowingUp} Go do shot-is-blowing-up sequence
0628: 23              INX     H                   ; 2074 step count
0629: 34              INR     M                   ; Count the steps (used for fire rate)
062A: CD CC 06        CALL    0x06CC              ; {} Erase shot
062D: 3A 79 20        LDA     0x2079              ; {ram.aShotImageLSB} Get LSB of the image pointer
0630: C6 03           ADI     0x03                ; Next set of images
0632: 21 7F 20        LXI     H,0x207F            ; {ram.shotPicEnd} End of image
0635: BE              CMP     M                   ; Have we reached the end of the set?
0636: DA 3B 06        JC      0x063B              ; {} No ... keep it
0639: D6 0C           SUI     0x0C                ; Back up to the 1st image in the set
063B: 32 79 20        STA     0x2079              ; {ram.aShotImageLSB} New LSB image pointer
063E: 3A 7B 20        LDA     0x207B              ; {ram.alienShotYr} Get shot's Y coordinate
0641: 47              MOV     B,A                 ; Hold it
0642: 3A 7E 20        LDA     0x207E              ; {ram.alienShotDelta} Get alien shot delta
0645: 80              ADD     B                   ; Add to shots coordinate
0646: 32 7B 20        STA     0x207B              ; {ram.alienShotYr} New shot Y coordinate
0649: CD C3 06        CALL    0x06C3              ; {} Draw the alien shot
064C: 3A 7B 20        LDA     0x207B              ; {ram.alienShotYr} Shot's Y coordinate
064F: FE 15           CPI     0x15                ; Still in the active playfield?
0651: DA 6A 06        JC      0x066A              ; {} No ... end it
0654: 3A 61 20        LDA     0x2061              ; {ram.collision} Did shot collide ...
0657: A7              ANA     A                   ; ... with something?
0658: C8              RZ                          ; No ... we are done here
0659: 3A 7B 20        LDA     0x207B              ; {ram.alienShotYr} Shot's Y coordinate
065C: FE 1E           CPI     0x1E                ; Is it below player's area?
065E: DA 6A 06        JC      0x066A              ; {} Yes ... end it
0661: FE 27           CPI     0x27                ; Is it above player's area?
0663: D2 6A 06        JNC     0x066A              ; {} Yes ... end it
0666: 97              SUB     A                   ; Flag that player ...
0667: 32 15 20        STA     0x2015              ; {ram.playerAlive} ... has been struck

;
066A: 3A 73 20        LDA     0x2073              ; {ram.aShotStatus} Flag to ...
066D: F6 01           ORI     0x01                ; ... start shot ...
066F: 32 73 20        STA     0x2073              ; {ram.aShotStatus} ... blowing up
0672: C9              RET                         ; Out

;
; Start a shot right over the player
0673: 3A 1B 20        LDA     0x201B              ; {ram.playerXr} Player's X coordinate
0676: C6 08           ADI     0x08                ; Center of player
0678: 67              MOV     H,A                 ; To H for routine
0679: CD C0 12        CALL    0x12C0              ; {code.FindColumn} Find the column
067C: 79              MOV     A,C                 ; Get the column right over player
067D: FE 0C           CPI     0x0C                ; Is it a valid column?
067F: DA FE 05        JC      0x05FE              ; {} Yes ... use what we found
0682: 0E 0B           MVI     C,0x0B              ; Else use ...
0684: C3 FE 05        JMP     0x05FE              ; {} ... as far over as we can

FindInColumn:
; C contains the target column. Look for a live alien in the column starting with
; the lowest position. Return C=1 if found ... HL points to found slot.
0687: 0D              DCR     C                   ; Column that is firing
0688: CD F9 13        CALL    0x13F9              ; {code.GetPlayerDataPage}
068B: 69              MOV     L,C                 ; Column to L
068C: 16 05           MVI     D,0x05              ; 5 rows of aliens
068E: 7E              MOV     A,M                 ; Get alien's status
068F: A7              ANA     A                   ; 0 means dead
0690: 37              STC                         ; In case not 0
0691: C0              RNZ                         ; Alien is alive? Yes ... return
0692: 7D              MOV     A,L                 ; Get the flag pointer LSB
0693: C6 0B           ADI     0x0B                ; Jump to same column on next row of rack (+11 aliens per row)
0695: 6F              MOV     L,A                 ; New alien index
0696: 15              DCR     D                   ; Tested all rows?
0697: C2 8E 06        JNZ     0x068E              ; {} No ... keep looking for a live alien up the rack
069A: C9              RET                         ; Didn't find a live alien. Return with C=0.

ShotBlowingUp:
; Alien shot is blowing up
069B: 21 78 20        LXI     H,0x2078            ; {ram.aShotBlowCnt} Blow up timer
069E: 35              DCR     M                   ; Decrement the value
069F: 7E              MOV     A,M                 ; Get the value
06A0: FE 03           CPI     0x03                ; First tick, 4, we draw the explosion
06A2: C2 BE 06        JNZ     0x06BE              ; {} After that just wait
06A5: CD CC 06        CALL    0x06CC              ; {} Erase the shot
06A8: 21 DE 1C        LXI     H,0x1CDE            ; Alien shot ...
06AB: 22 79 20        SHLD    0x2079              ; {ram.aShotImageLSB} ... explosion sprite
06AE: 21 7C 20        LXI     H,0x207C            ; {ram.alienShotXr} Alien shot Y
06B1: 35              DCR     M                   ; Left two for ...
06B2: 35              DCR     M                   ; ... explosion
06B3: 2B              DCX     H                   ; Point slien shot X
06B4: 35              DCR     M                   ; Up two for ...
06B5: 35              DCR     M                   ; ... explosion
06B6: 3E 06           MVI     A,0x06              ; Alien shot descriptor ...
06B8: 32 7D 20        STA     0x207D              ; {ram.alienShotSize} ... size 6
06BB: C3 C3 06        JMP     0x06C3              ; {} Draw alien shot explosion
06BE: A7              ANA     A                   ; Have we reached 0?
06BF: C0              RNZ                         ; No ... keep waiting
06C0: C3 CC 06        JMP     0x06CC              ; {} Erase the explosion and out

;
06C3: 21 79 20        LXI     H,0x2079            ; {ram.aShotImageLSB} Alien shot descriptor
06C6: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Read 5 byte structure
06C9: C3 D6 11        JMP     0x11D6              ; {code.DrawSprCollision} Draw shot and out

;
06CC: 21 79 20        LXI     H,0x2079            ; {ram.aShotImageLSB} Alien shot descriptor
06CF: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Read 5 byte structure
06D2: C3 97 11        JMP     0x1197              ; {code.EraseShifted} Erase the shot and out
06D5: 22 48 20        SHLD    0x2048              ; {ram.pluShotCFirLSB} From 50B, update ...
06D8: C9              RET                         ; ... column-firing table pointer and out

GameObj4:
; Game object 4: Flying Saucer OR squiggly shot
;
; This task is shared by the squiggly-shot and the flying saucer. The saucer waits until the
; squiggly-shot is over before it begins.
;
06D9: E1              POP     H                   ; Pull data pointer from the stack (not going to use it)
06DA: 3A 80 20        LDA     0x2080              ; {ram.shotSync} Sync flag (copied from GO-2's timer value)
06DD: FE 02           CPI     0x02                ; Are GO-2 and GO-3 idle?
06DF: C0              RNZ                         ; No ... only one at a time
06E0: 21 83 20        LXI     H,0x2083            ; {ram.saucerStart} Time-till-saucer flag
06E3: 7E              MOV     A,M                 ; Is it time ...
06E4: A7              ANA     A                   ; ... for a saucer?
06E5: CA 64 05        JZ      0x0564              ; {code.HandleSquiggly} No ... go process squiggly shot
06E8: 3A 56 20        LDA     0x2056              ; {ram.squShotStepCnt} Is there a ...
06EB: A7              ANA     A                   ; ... squiggly shot going?
06EC: C2 64 05        JNZ     0x0564              ; {code.HandleSquiggly} Yes ... go handle squiggly shot
06EF: 23              INX     H                   ; Saucer on screen flag
06F0: 7E              MOV     A,M                 ; (2084) Is the saucer ...
06F1: A7              ANA     A                   ; ... already on the screen?
06F2: C2 05 07        JNZ     0x0705              ; {} Yes ... go handle it
06F5: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens remaining
06F8: FE 08           CPI     0x08                ; Less than ...
06FA: DA 64 05        JC      0x0564              ; {code.HandleSquiggly} ... 8 ... no saucer
06FD: 36 01           MVI     M,0x01              ; (2084) The saucer is on the screen
06FF: CD 59 07        CALL    0x0759              ; {code.SaucerStart} Count this saucer (the 2nd one in a rack is the flashing one)
0702: CD 11 08        CALL    0x0811              ; {code.DrawSaucer} Draw the flying saucer
0705: 11 8A 20        LXI     D,0x208A            ; {ram.saucerPriPicMSB} Saucer's Y coordinate
0708: CD 86 17        CALL    0x1786              ; {code.CompYToBeam} Compare to beam position
070B: D0              RNC                         ; Not the right ISR for moving saucer
070C: 21 85 20        LXI     H,0x2085            ; {ram.saucerHit} Saucer hit flag
070F: 7E              MOV     A,M                 ; Has saucer ...
0710: A7              ANA     A                   ; ... been hit?
0711: C2 8C 07        JNZ     0x078C              ; {} Yes ... don't move it
0714: 3A A1 20        LDA     0x20A1              ; {ram.dropActive} Is the saucer dropping an alien into the rack?
0717: A7              ANA     A                   ; Set flags
0718: 21 8A 20        LXI     H,0x208A            ; {ram.saucerPriPicMSB} Saucer's structure
071B: CA 21 07        JZ      0x0721              ; {} No ... move it
071E: C3 11 08        JMP     0x0811              ; {code.DrawSaucer} Yes ... hover in place (just redraw)
0721: 7E              MOV     A,M                 ; Get saucer's Y coordinate
0722: 23              INX     H                   ; Bump to ...
0723: 23              INX     H                   ; ... delta Y
0724: 86              ADD     M                   ; Move saucer
0725: 32 8A 20        STA     0x208A              ; {ram.saucerPriPicMSB} New coordinate
0728: CD 3A 07        CALL    0x073A              ; {code.DrawSaucerBlink} Draw the flying saucer
072B: 21 8A 20        LXI     H,0x208A            ; {ram.saucerPriPicMSB} Saucer's structure
072E: 7E              MOV     A,M                 ; Y coordinate
072F: FE 28           CPI     0x28                ; Too low? End of screen?
0731: DA AC 07        JC      0x07AC              ; {} Yes ... remove from play
0734: FE E1           CPI     0xE1                ; Too high? End of screen?
0736: D2 AC 07        JNC     0x07AC              ; {} Yes ... remove from play
0739: C9              RET                         ; Done

DrawSaucerBlink:
; Part II: the second saucer of a rack is the flashing saucer. It is drawn only half
; the time (4 ticks on, 4 ticks off).
073A: CD 53 07        CALL    0x0753              ; {code.IsFlashSaucer} Is this the flashing saucer?
073D: C2 11 08        JNZ     0x0811              ; {code.DrawSaucer} No ... just draw it
0740: 21 BD 20        LXI     H,0x20BD            ; {ram.saucerBlinkTmr} Blink timer
0743: 34              INR     M                   ; Tick it
0744: 7E              MOV     A,M                 ; Get value
0745: E6 04           ANI     0x04                ; Visible or invisible half of the cycle?
0747: C2 4D 07        JNZ     0x074D              ; {} Invisible ... erase it
074A: C3 11 08        JMP     0x0811              ; {code.DrawSaucer} Visible ... draw it
074D: CD 17 08        CALL    0x0817              ; {code.SaucerToScreen} Get the saucer's screen coordinates
0750: C3 10 12        JMP     0x1210              ; {code.ClearSmallSprite} Erase it and out

IsFlashSaucer:
; Return Z set if this is the 2nd saucer of the rack (the flashing one).
0753: 3A BC 20        LDA     0x20BC              ; {ram.saucerBlink} Number of saucers this rack
0756: FE 02           CPI     0x02                ; Is this the 2nd one?
0758: C9              RET                         ; Z=yes

SaucerStart:
; Count the saucers. The 2nd one uses the flashing-saucer picture at 187E.
0759: 21 BC 20        LXI     H,0x20BC            ; {ram.saucerBlink} Number of saucers this rack
075C: 34              INR     M                   ; One more
075D: 7E              MOV     A,M                 ; Get count
075E: FE 02           CPI     0x02                ; Is this the 2nd one?
0760: C0              RNZ                         ; No ... normal saucer
0761: 21 7E 18        LXI     H,0x187E            ; Flashing-saucer picture
0764: 22 87 20        SHLD    0x2087              ; {ram.saucerPriLocLSB} Use it for the saucer
0767: 3A 8C 20        LDA     0x208C              ; {ram.saucerDeltaY} (Reads and writes the delta back ... no effect)
076A: 32 8C 20        STA     0x208C              ; {ram.saucerDeltaY}
076D: C9              RET                         ; Done

FlashSaucerScore:
; If the flashing saucer was hit it is always worth 500 (this returns to the caller's
; caller with B=50 and the "500" message).
076E: CD 53 07        CALL    0x0753              ; {code.IsFlashSaucer} Was it the flashing saucer?
0771: C0              RNZ                         ; No ... normal mystery score
0772: 21 A8 1D        LXI     H,0x1DA8            ; "500" message
0775: CD 81 07        CALL    0x0781              ; {} Flag if the first saucer was also hit
0778: 22 87 20        SHLD    0x2087              ; {ram.saucerPriLocLSB} Message to print beside the saucer
077B: 06 50           MVI     B,0x50              ; Score of 50 (displayed as 500)
077D: E1              POP     H                   ; Drop the return (we finish the caller's job here)
077E: C3 ED 07        JMP     0x07ED              ; {} Add the score and print it
0781: 3A BA 20        LDA     0x20BA              ; {ram.flashSaucerArmed} Was the first saucer of the rack hit?
0784: A7              ANA     A                   ; Set flags
0785: C8              RZ                          ; No ... done
0786: 3E 01           MVI     A,0x01              ; Yes ... remember that ...
0788: 32 BB 20        STA     0x20BB              ; {ram.flashSaucer} ... both saucers were hit
078B: C9              RET                         ; Done
078C: 06 FE           MVI     B,0xFE              ; Turn off ...
078E: CD 5C 17        CALL    0x175C              ; {code.SoundBits3Off} ... flying saucer sound
0791: 23              INX     H                   ; (2086) show-hit timer
0792: 35              DCR     M                   ; Count down show-hit timer
0793: 7E              MOV     A,M                 ; Get current value
0794: FE 1F           CPI     0x1F                ; Starts at 20 ... is this the first tick of show-hit timer?
0796: CA 20 08        JZ      0x0820              ; {} Yes ... go show the explosion
0799: FE 18           CPI     0x18                ; A little later ...
079B: CA BF 07        JZ      0x07BF              ; {} ... show the score besides the saucer and add it
079E: A7              ANA     A                   ; Has timer expired?
079F: C0              RNZ                         ; No ... let it run
07A0: 06 EF           MVI     B,0xEF              ; 1110_1111 (mask off saucer hit sound)
07A2: 21 98 20        LXI     H,0x2098            ; {ram.soundPort5} Get current ...
07A5: 7E              MOV     A,M                 ; ... value of port 5 sound
07A6: A0              ANA     B                   ; Mask off the saucer-hit sound
07A7: 77              MOV     M,A                 ; Set the new value
07A8: E6 20           ANI     0x20                ; All sound off but ...
07AA: D3 05           OUT     0x05                ; {hard.SOUND2} ... cocktail cabinet bit

;
07AC: CD 17 08        CALL    0x0817              ; {} Covert pixel pos from descriptor to HL screen and shift
07AF: CD 10 12        CALL    0x1210              ; {code.ClearSmallSprite} Clear a one byte sprite at HL
07B2: 21 83 20        LXI     H,0x2083            ; {ram.saucerStart} Saucer structure
07B5: 06 0A           MVI     B,0x0A              ; 10 bytes in saucer structure
07B7: CD 3F 08        CALL    0x083F              ; {} Re-initialize saucer structure

SaucerSndOff:
07BA: 06 FE           MVI     B,0xFE              ; Turn off UFO ...
07BC: C3 5C 17        JMP     0x175C              ; {code.SoundBits3Off} ... sound and out
07BF: 3E 01           MVI     A,0x01              ; Flag the score ...
07C1: 32 F1 20        STA     0x20F1              ; {ram.adjustScore} ... needs updating
07C4: 3A BC 20        LDA     0x20BC              ; {ram.saucerBlink} Was this ...
07C7: FE 01           CPI     0x01                ; ... the first saucer of the rack?
07C9: C2 CF 07        JNZ     0x07CF              ; {} No
07CC: 32 BA 20        STA     0x20BA              ; {ram.flashSaucerArmed} Yes ... remember it was hit
07CF: CD 6E 07        CALL    0x076E              ; {code.FlashSaucerScore} The flashing saucer is always 500
07D2: 2A 8D 20        LHLD    0x208D              ; {ram.sauScoreLSB} Saucer score table
07D5: 46              MOV     B,M                 ; Get score for this saucer
07D6: 0E 04           MVI     C,0x04              ; There are only 4 possibilities
07D8: 21 4C 1D        LXI     H,0x1D4C            ; Possible scores table (1D4C)
07DB: 11 48 1D        LXI     D,0x1D48            ; Score values for each message (1D48)
07DE: 1A              LDAX    D                   ; Find ...
07DF: B8              CMP     B                   ; ... the ...
07E0: CA E9 07        JZ      0x07E9              ; {} ... print ...
07E3: 23              INX     H                   ; ... string ...
07E4: 13              INX     D                   ; ... for ...
07E5: 0D              DCR     C                   ; ... the ...
07E6: C2 DE 07        JNZ     0x07DE              ; {} ... score
07E9: 7E              MOV     A,M                 ; Get LSB of message (MSB is 2088 which is 1D)
07EA: 32 87 20        STA     0x2087              ; {ram.saucerPriLocLSB} Message's LSB (50=1D90 100=1D93 150=1D96 300=1D99)
07ED: 26 00           MVI     H,0x00              ; MSB = 0 ...
07EF: 68              MOV     L,B                 ; HL = B
07F0: CD 01 08        CALL    0x0801              ; {} Add score (only in game mode)
07F3: CD 17 08        CALL    0x0817              ; {code.SaucerToScreen} Get the saucer's screen coordinates
07F6: C3 D7 0A        JMP     0x0AD7              ; {code.PrintSauScore} Print the score where the saucer was (3 characters)

GetRoundNum:
; Return A = the active player's round count (2xF9) and HL pointing to it.
07F9: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Active player's ...
07FC: 67              MOV     H,A                 ; ... data page
07FD: 2E F9           MVI     L,0xF9              ; 2xF9 is the round counter
07FF: 7E              MOV     A,M                 ; Get it
0800: C9              RET                         ; Done

SaucerAddScore:
; Store the saucer's score as the score delta (only in game mode).
0801: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Game mode?
0804: A7              ANA     A                   ; Set flags
0805: CA 0C 08        JZ      0x080C              ; {} No ... no score in demo
0808: 22 F2 20        SHLD    0x20F2              ; {ram.scoreDeltaLSB} Score delta
080B: C9              RET                         ; Done
080C: AF              XRA     A                   ; In demo mode ...
080D: 32 F1 20        STA     0x20F1              ; {ram.adjustScore} ... cancel the score adjustment
0810: C9              RET                         ; Done

DrawSaucer:
0811: CD 17 08        CALL    0x0817              ; {} Draw the ...
0814: C3 83 11        JMP     0x1183              ; {code.DrawSimpSprite} ... flying saucer

SaucerToScreen:
0817: 21 87 20        LXI     H,0x2087            ; {ram.saucerPriLocLSB} Read flying saucer ...
081A: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} ... structure
081D: C3 C7 17        JMP     0x17C7              ; {code.ConvToScr} Convert pixel number to screen and shift and out

;
0820: 06 10           MVI     B,0x10              ; Saucer hit sound bit
0822: 21 98 20        LXI     H,0x2098            ; {ram.soundPort5} Current state of sounds
0825: 7E              MOV     A,M                 ; OR ...
0826: B0              ORA     B                   ; ... in ...
0827: 77              MOV     M,A                 ; ... saucer-hit sound
0828: CD 99 15        CALL    0x1599              ; {} Turn off fleet sound and start saucer-hit
082B: CD 34 08        CALL    0x0834              ; {code.SaucerExplPic} Get the explosion picture
082E: 22 87 20        SHLD    0x2087              ; {ram.saucerPriLocLSB} Use it
0831: C3 11 08        JMP     0x0811              ; {code.DrawSaucer} Draw the exploding saucer

SaucerExplPic:
0834: 21 78 1D        LXI     H,0x1D78            ; Saucer explosion picture
0837: CD 53 07        CALL    0x0753              ; {code.IsFlashSaucer} Flashing saucer?
083A: C0              RNZ                         ; No ... use this picture
083B: 21 78 1D        LXI     H,0x1D78            ; (Same picture for the flashing saucer)
083E: C9              RET                         ; Done

;
083F: 11 83 1B        LXI     D,0x1B83            ; Data for saucer (702 sets count to 0A)
0842: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} Reset saucer object data

WaitForStart:
; Wait for player 1 start button press
0845: 3E 01           MVI     A,0x01              ; Tell ISR that we ...
0847: 32 93 20        STA     0x2093              ; {ram.waitStartLoop} ... have started to wait
084A: 31 00 24        LXI     SP,0x2400           ; Reset stack
084D: FB              EI                          ; Enable interrupts
084E: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks}
0851: CD 05 17        CALL    0x1705              ; {code.DrawNumCredits}
0854: CD FA 16        CALL    0x16FA              ; {code.DrawCreditLabel} Print "CREDIT "
0857: CD 16 17        CALL    0x1716              ; {code.DrawStatus} Print scores and credits
085A: 21 13 30        LXI     H,0x3013            ; Screen coordinates
085D: 11 3E 1F        LXI     D,0x1F3E            ; "PUSH" (Part II says PUSH instead of PRESS)
0860: 0E 04           MVI     C,0x04              ; Message length
0862: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print it
0865: 3A EB 20        LDA     0x20EB              ; {ram.numCoins} Number of credits
0868: 3D              DCR     A                   ; Set flags
0869: 21 10 28        LXI     H,0x2810            ; Screen coordinates
086C: 0E 14           MVI     C,0x14              ; Message length
086E: C2 73 09        JNZ     0x0973              ; {} Take 1 or 2 player start
0871: 11 4D 18        LXI     D,0x184D            ; "ONLY 1PLAYER  BUTTON"
0874: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print message
0877: DB 01           IN      0x01                ; {hard.INP1} Read player controls
0879: E6 04           ANI     0x04                ; 1Player start button?
087B: CA 65 08        JZ      0x0865              ; {} No ... wait for button or credit
```

# Start New Game

```code

NewGame:
; 1 Player start
087E: 06 99           MVI     B,0x99              ; Essentially a -1 for DAA
0880: AF              XRA     A                   ; Clear two player flag

;
; 2 player start sequence enters here with a=1 and B=98 (-2)
0881: 32 CE 20        STA     0x20CE              ; {ram.twoPlayers} Set flag for 1 or 2 players
0884: 3A EB 20        LDA     0x20EB              ; {ram.numCoins} Number of credits
0887: 80              ADD     B                   ; Take away credits
0888: 27              DAA                         ; Convert back to DAA
0889: 32 EB 20        STA     0x20EB              ; {ram.numCoins} New credit count
088C: 3A CC 20        LDA     0x20CC              ; {ram.creditShadow} Take the credits ...
088F: 80              ADD     B                   ; ... away from the ...
0890: 27              DAA                         ; ... shadow copy ...
0891: 32 CC 20        STA     0x20CC              ; {ram.creditShadow} ... too
0894: CD 05 17        CALL    0x1705              ; {code.DrawNumCredits} Show the new credit count
0897: 21 00 00        LXI     H,0x0000            ; Zero
089A: 22 F8 20        SHLD    0x20F8              ; {ram.P1ScorL} Clear player 1 score
089D: 22 FC 20        SHLD    0x20FC              ; {ram.P2ScorL} Clear player 2 score
08A0: 22 F8 21        SHLD    0x21F8              ; Clear player 1 shot count (21F8) and round count (21F9)
08A3: 22 F8 22        SHLD    0x22F8              ; Clear player 2 shot count (22F8) and round count (22F9)
08A6: CD E3 16        CALL    0x16E3              ; {code.DrawScoreP1} Print player-1 score
08A9: CD E9 16        CALL    0x16E9              ; {code.DrawScoreP2} Print player-2 score
08AC: CD 97 10        CALL    0x1097              ; {code.CenterHiName} Work out where the high-score name goes
08AF: CD 30 10        CALL    0x1030              ; {code.PrintHiName} Print the high-score holder's name
08B2: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks} Disable game tasks
08B5: 21 01 01        LXI     H,0x0101            ; Two bytes 1, 1
08B8: 7C              MOV     A,H                 ; 1 to A
08B9: 32 EF 20        STA     0x20EF              ; {ram.gameMode} 20EF=1 ... game mode
08BC: 22 E7 20        SHLD    0x20E7              ; {ram.player1Alive} 20E7 and 20E8 both one ... players 1 and 2 are alive
08BF: 22 E5 20        SHLD    0x20E5              ; {ram.player1Ex} Extra-ship is available for player-1 and player-2
08C2: CD 16 17        CALL    0x1716              ; {code.DrawStatus} Print scores and credits
08C5: CD 35 02        CALL    0x0235              ; {code.DrawShieldPl1} Draw shields for player-1
08C8: CD 3B 02        CALL    0x023B              ; {code.DrawShieldPl2} Draw shields for player-2
08CB: CD B7 0A        CALL    0x0AB7              ; {code.GetShipsPerCred} Get number of ships from DIP settings
08CE: 32 FF 21        STA     0x21FF              ; {ram.p1ShipsRem} Player-1 ships
08D1: 32 FF 22        STA     0x22FF              ; {ram.p2ShipsRem} Player-2 ships
08D4: CD F2 00        CALL    0x00F2              ; {} Set player-1 and player-2 alien racks going right
08D7: AF              XRA     A                   ; Make a 0
08D8: 32 FE 21        STA     0x21FE              ; {ram.p1RackCnt} Player 1 is on first rack of aliens
08DB: 32 FE 22        STA     0x22FE              ; {ram.p2RackCnt} Player 2 is on first rack of aliens
08DE: 32 E4 20        STA     0x20E4              ; {ram.shotsHalted} Alien shots are allowed
08E1: 3C              INR     A                   ; 1
08E2: 32 FA 21        STA     0x21FA              ; Player 1 round display (21FA) starts at 1
08E5: 32 FA 22        STA     0x22FA              ; Player 2 round display (22FA) starts at 1
08E8: CD DE 01        CALL    0x01DE              ; {code.InitAliens} Initialize aliens for player 1
08EB: CD C2 16        CALL    0x16C2              ; {code.InitAliensP2} Initialize 55 aliens for player 2
08EE: 21 78 38        LXI     H,0x3878            ; Screen coordinates for lower-left alien
08F1: 22 FC 21        SHLD    0x21FC              ; {ram.p1RefAlienY} Initialize reference alien for player 1
08F4: 22 FC 22        SHLD    0x22FC              ; {ram.p2RefAlienYr} Initialize reference alien for player 2
08F7: CD 2A 02        CALL    0x022A              ; {code.CopyRAMMirror} Copy ROM mirror to RAM (2000 - 20C0)
08FA: CD FF 17        CALL    0x17FF              ; {code.RemoveShip} Initialize ship hold indicator
08FD: DB 02           IN      0x02                ; {hard.INP2} DIP switch 4 ...
08FF: E6 08           ANI     0x08                ; ... (bit 3) is the "preset mode" switch
0901: C4 B9 45        CNZ     0x45B9              ; {code.PresetMode} Switch is on ... operator preset mode
0904: CD 73 0A        CALL    0x0A73              ; {code.PromptPlayer} Print "PLAY PLAYER<n>" and blink the score
0907: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear the playfield
090A: AF              XRA     A                   ; Make a 0
090B: 32 C1 20        STA     0x20C1              ; {ram.isrSplashTask} Stop the demo task
090E: CD 15 02        CALL    0x0215              ; {code.DrawBottomLine} Draw line across screen under player
0911: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Current player
0914: 0F              RRC                         ; Right bit tells all
0915: DA 8E 09        JC      0x098E              ; {} Go do player 1

;
0918: CD 59 02        CALL    0x0259              ; {code.RestoreShields2} Restore shields for player 2
091B: CD 97 09        CALL    0x0997              ; {code.CarveRoundNum} Cut the round number into the shields
091E: CD 15 02        CALL    0x0215              ; {code.DrawBottomLine} Draw line across screen under player
0921: CD CC 00        CALL    0x00CC              ; {code.InitRack} Initialize alien rack for current player
0924: 3E 01           MVI     A,0x01              ; Flag that ...
0926: 32 B9 20        STA     0x20B9              ; {ram.rackArriving} ... the rack is sliding into place
0929: 06 20           MVI     B,0x20              ; Enable ...
092B: CD B8 16        CALL    0x16B8              ; {code.SoundBits3On} ... sound amplifier
092E: CD CA 09        CALL    0x09CA              ; {code.RackArrive} Part II: slide the new rack down into position
0931: 3E 00           MVI     A,0x00              ; Rack is ...
0933: 32 B9 20        STA     0x20B9              ; {ram.rackArriving} ... in place
0936: CD 52 17        CALL    0x1752              ; {code.EnableGameTasks} Enable game tasks in ISR
0939: 06 20           MVI     B,0x20              ; Enable ...
093B: CD B8 16        CALL    0x16B8              ; {code.SoundBits3On} ... sound amplifier

;
; GAME LOOP
;
093E: CD FE 13        CALL    0x13FE              ; {code.PlrFireOrDemo} Initiate player shot if button pressed
0941: CD C8 16        CALL    0x16C8              ; {code.PlyrShotAndBump} Collision detect player's shot and rack-bump
0944: CD B5 13        CALL    0x13B5              ; {code.CountAliens} Count aliens (count to 2082)
0947: CD 58 0B        CALL    0x0B58              ; {code.AdjustScore} Adjust score (and print) if there is an adjustment
094A: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of live aliens
094D: A7              ANA     A                   ; All aliens gone?
094E: CA CA 0B        JZ      0x0BCA              ; {code.EndOfRack} Yes ... end of turn
0951: CD 91 11        CALL    0x1191              ; {code.AShotReloadRate} Update alien-shot-rate based on player's score
0954: CD 1E 0B        CALL    0x0B1E              ; {code.ExtraShipCheck} Check (and handle) extra ship award
0957: CD BE 0A        CALL    0x0ABE              ; {code.SpeedShots} Adjust alien shot speed
095A: CD 58 15        CALL    0x1558              ; {code.ShotSound} Shot sound on or off with 2025
095D: CD 5E 0C        CALL    0x0C5E              ; {code.PlayerHitChk} Check if player is hit
0960: CA 68 09        JZ      0x0968              ; {} No hit ... jump handler
0963: 06 04           MVI     B,0x04              ; Player hit sound
0965: CD B8 16        CALL    0x16B8              ; {code.SoundBits3On} Make explosion sound
0968: CD 9E 15        CALL    0x159E              ; {code.FleetDelayExShip} Extra-ship sound timer, set fleet-delay, play fleet movement sound
096B: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed the watchdog
096D: CD 2E 16        CALL    0x162E              ; {code.CtrlSaucerSound} Control saucer sound
0970: C3 3E 09        JMP     0x093E              ; {} Continue game loop

; Test for 1 or 2 player start button press
0973: 11 38 18        LXI     D,0x1838            ; "1 OR 2PLAYERS BUTTON"
0976: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print message
0979: 06 98           MVI     B,0x98              ; -2 (take away 2 credits)
097B: DB 01           IN      0x01                ; {hard.INP1} Read player controls
097D: 0F              RRC                         ; Test ...
097E: 0F              RRC                         ; ... bit 2
097F: DA 89 09        JC      0x0989              ; {} 2 player button pressed ... do it
0982: 0F              RRC                         ; Test bit 3
0983: DA 7E 08        JC      0x087E              ; {code.NewGame} One player start ... do it
0986: C3 65 08        JMP     0x0865              ; {} Keep waiting on credit or button

; 2 PLAYER START
0989: 3E 01           MVI     A,0x01              ; Flag 2 player game
098B: C3 81 08        JMP     0x0881              ; {} Continue normal startup
098E: CD 60 02        CALL    0x0260              ; {code.RestoreShields1} Restore shields for player 1
0991: CD 97 09        CALL    0x0997              ; {code.CarveRoundNum} Cut the round number into the shields
0994: C3 1E 09        JMP     0x091E              ; {} Continue with the rack

CarveRoundNum:
; Part II: cut the current round number (0-9) into the top of each of the four shields.
0997: 21 27 29        LXI     H,0x2927            ; Screen position in the first shield
099A: 0E 04           MVI     C,0x04              ; 4 shields
099C: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Active player ...
099F: 57              MOV     D,A                 ; ... data page
09A0: 1E FA           MVI     E,0xFA              ; 2xFA is the round number for display
09A2: 1A              LDAX    D                   ; Get it
09A3: C6 1C           ADI     0x1C                ; Convert to the digit character
09A5: F5              PUSH    PSW                 ; Hold character
09A6: C5              PUSH    B                   ; Hold counters
09A7: CD 24 1A        CALL    0x1A24              ; {code.CharPtr} DE = character picture
09AA: 06 05           MVI     B,0x05              ; 5 columns in a character
09AC: C5              PUSH    B                   ; Hold count
09AD: 1A              LDAX    D                   ; Character pixels
09AE: A6              ANA     M                   ; AND then XOR with the screen ...
09AF: AE              XRA     M                   ; ... clears the character's pixels out of the shield
09B0: 77              MOV     M,A                 ; Back to screen
09B1: 13              INX     D                   ; Next column of character
09B2: 01 20 00        LXI     B,0x0020            ; Next ...
09B5: 09              DAD     B                   ; ... column on screen
09B6: C1              POP     B                   ; Restore count
09B7: 05              DCR     B                   ; All columns?
09B8: C2 AC 09        JNZ     0x09AC              ; {} No ... do them all
09BB: 01 00 05        LXI     B,0x0500            ; Offset ...
09BE: 09              DAD     B                   ; ... to the next shield
09BF: C1              POP     B                   ; Restore counters
09C0: F1              POP     PSW                 ; Restore character
09C1: 0D              DCR     C                   ; All 4 shields?
09C2: C2 A5 09        JNZ     0x09A5              ; {} No ... do them all
09C5: C9              RET                         ; Done
09C6: 1B 24 1D 1C                         ; " 810"

RackArrive:
; Part II: the new rack slides down into position from the top of the screen. The
; reference alien is moved up to Y=A8 and the rack is "bumped" down step by step until
; it reaches its real starting height. The fewer aliens there are the smaller the steps.
09CA: 21 00 23        LXI     H,0x2300            ; {ram.rackSave} Save the alien-rack variables ...
09CD: 11 00 20        LXI     D,0x2000            ; {ram.waitOnDraw} ... 2000-200F ...
09D0: E5              PUSH    H                   ; ... to 2300 ...
09D1: D5              PUSH    D                   ; ... (and keep the pointers for the restore)
09D2: 06 10           MVI     B,0x10              ; 16 bytes
09D4: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Copy
09D7: 21 08 20        LXI     H,0x2008            ; {ram.refAlienDXr} refAlienDXr
09DA: 36 00           MVI     M,0x00              ; No sideways motion
09DC: 23              INX     H                   ; refAlienYr
09DD: 36 A8           MVI     M,0xA8              ; Start rack at the top of the screen
09DF: 23              INX     H                   ; Skip refAlienXr
09E0: 23              INX     H                   ; alienPosLSB
09E1: 36 A8           MVI     M,0xA8              ; Alien cursor starts at the top too
09E3: 23              INX     H                   ; Skip 200C,200D
09E4: 23              INX     H                   ; Point to ...
09E5: 23              INX     H                   ; ... rackDownDelta ...
09E6: E5              PUSH    H                   ; ... and hold the pointer
09E7: CD B5 13        CALL    0x13B5              ; {code.CountAliens} Count the aliens in this rack
09EA: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens
09ED: FE 1A           CPI     0x1A                ; 26 or more?
09EF: D2 60 0A        JNC     0x0A60              ; {} Yes ... drop 4 pixels at a time
09F2: FE 0A           CPI     0x0A                ; 10 or more?
09F4: D2 66 0A        JNC     0x0A66              ; {} Yes ... drop 2 pixels at a time
09F7: E1              POP     H                   ; Pointer to rackDownDelta
09F8: 36 FF           MVI     M,0xFF              ; Otherwise drop 1 pixel at a time
09FA: CD 5F 01        CALL    0x015F              ; {code.CursorNextAlien} Next alien (moves the rack after the last one)
09FD: CD 0F 01        CALL    0x010F              ; {code.DrawAlien} Draw it
0A00: 3A 0E 20        LDA     0x200E              ; {ram.rackDownDelta} Keep ...
0A03: 32 07 20        STA     0x2007              ; {ram.refAlienDYr} ... dropping the rack
0A06: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens
0A09: FE 05           CPI     0x05                ; Fewer than 5?
0A0B: D2 16 0A        JNC     0x0A16              ; {} No ... no extra delay
0A0E: C5              PUSH    B                   ; Hold
0A0F: 01 50 03        LXI     B,0x0350            ; Small delay ...
0A12: CD C9 0E        CALL    0x0EC9              ; {code.DelayBC} ... so a few aliens don't drop too fast
0A15: C1              POP     B                   ; Restore
0A16: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} (Read twice ...)
0A19: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} Current rack height
0A1C: 47              MOV     B,A                 ; To B
0A1D: 3A 09 23        LDA     0x2309              ; Saved (target) rack height
0A20: F5              PUSH    PSW                 ; Hold target ...
0A21: C5              PUSH    B                   ; ... and current
0A22: 3E 0A           MVI     A,0x0A              ; Delay value
0A24: CD B8 15        CALL    0x15B8              ; {code.SoundDelay} Fleet sound and delay
0A27: C1              POP     B                   ; Restore current
0A28: F1              POP     PSW                 ; Restore target
0A29: B8              CMP     B                   ; Has the rack reached its starting height?
0A2A: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog (flags kept)
0A2C: F5              PUSH    PSW                 ; Hold compare result
0A2D: 26 20           MVI     H,0x20              ; Hidden test feature: 20E2 ...
0A2F: 2E E1           MVI     L,0xE1              ; ... (the address is built in pieces) ...
0A31: 2C              INR     L                   ; ... is still set only if the copyright check failed
0A32: 7E              MOV     A,M                 ; Get flag
0A33: A7              ANA     A                   ; Is it set?
0A34: CA 4A 0A        JZ      0x0A4A              ; {} No ... skip
0A37: CD 49 1F        CALL    0x1F49              ; {code.ReadPort1} Read the switches
0A3A: E6 76           ANI     0x76                ; Start1, Start2, fire, left, right
0A3C: FE 56           CPI     0x56                ; Start1+Start2+fire+right held?
0A3E: C2 4A 0A        JNZ     0x0A4A              ; {} No ... skip
0A41: 2E EA           MVI     L,0xEA              ; Point ...
0A43: 2C              INR     L                   ; ... to 20EB
0A44: 36 02           MVI     M,0x02              ; 2 free credits
0A46: 2E CC           MVI     L,0xCC              ; Shadow copy ...
0A48: 36 02           MVI     M,0x02              ; ... too
0A4A: F1              POP     PSW                 ; Restore compare result
0A4B: C2 FA 09        JNZ     0x09FA              ; {} Keep dropping until the rack is in place
0A4E: E1              POP     H                   ; Restore the rack variables ...
0A4F: D1              POP     D                   ; ... from 2300
0A50: 06 10           MVI     B,0x10              ; 16 bytes
0A52: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Copy them back
0A55: CD 19 17        CALL    0x1719              ; {code.DrawScores} Redraw the scores
0A58: 3A E7 20        LDA     0x20E7              ; {ram.player1Alive} (Checked as a 2-player flag)
0A5B: A7              ANA     A                   ; Set flags
0A5C: C8              RZ                          ; Zero ... done
0A5D: C3 CA 0A        JMP     0x0ACA              ; {code.ClrP2ScoreIf1P} Blank player 2's score in a one player game
0A60: E1              POP     H                   ; Drop 4 ...
0A61: 36 FC           MVI     M,0xFC              ; ... pixels per bump
0A63: C3 FA 09        JMP     0x09FA              ; {} Continue
0A66: E1              POP     H                   ; Drop 2 ...
0A67: 36 FE           MVI     M,0xFE              ; ... pixels per bump
0A69: C3 FA 09        JMP     0x09FA              ; {} Continue

GetAlRefPtr:
; Get pointer to player's alien ref coordiantes
0A6C: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Player data MSB (21 or 22)
0A6F: 67              MOV     H,A                 ; To H
0A70: 2E FC           MVI     L,0xFC              ; 21FC or 22FC ... alien coordinates
0A72: C9              RET                         ; Done

PromptPlayer:
; Print "PLAY PLAYER <n>" and blink score for 2 seconds.
;
0A73: 21 11 2B        LXI     H,0x2B11            ; Screen coordinates
0A76: 11 70 1B        LXI     D,0x1B70            ; Message "PLAY PLAYER<1>"
0A79: 0E 0E           MVI     C,0x0E              ; 14 bytes in message
0A7B: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print the message
0A7E: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Get the player number
0A81: 0F              RRC                         ; C will be set for player 1
0A82: 3E 1E           MVI     A,0x1E              ; Character "2"
0A84: 21 11 37        LXI     H,0x3711            ; Replace the "<1>" with "<2">
0A87: D4 E5 0A        CNC     0x0AE5              ; {code.DrawChar} If player 2 ... change the message
0A8A: 3E B0           MVI     A,0xB0              ; Delay of 176 (roughly 2 seconds)
0A8C: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} Set the ISR delay value

;
0A8F: 3A C0 20        LDA     0x20C0              ; {ram.isrDelay} Get the ISR delay value
0A92: A7              ANA     A                   ; Has the 2 second delay expired?
0A93: C8              RZ                          ; Yes ... done
0A94: E6 04           ANI     0x04                ; Every 4 ISRs ...
0A96: C2 A2 0A        JNZ     0x0AA2              ; {} ... flash the player's score
0A99: CD 97 0B        CALL    0x0B97              ; {code.GetScoreDesc} Get the score descriptor for the active player
0A9C: CD EF 16        CALL    0x16EF              ; {code.DrawScore} Draw the score
0A9F: C3 8F 0A        JMP     0x0A8F              ; {} Back to the top of the wait loop
0AA2: 06 28           MVI     B,0x28              ; 40 rows (5 digits now)
0AA4: 21 1C 26        LXI     H,0x261C            ; Player-1 score on the screen
0AA7: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Get the player number
0AAA: 0F              RRC                         ; C will be set for player 1
0AAB: DA B1 0A        JC      0x0AB1              ; {} We have the right score coordinates
0AAE: 21 1C 39        LXI     H,0x391C            ; Use coordinates for player-2's score
0AB1: CD 10 12        CALL    0x1210              ; {code.ClearSmallSprite} Erase the score
0AB4: C3 8F 0A        JMP     0x0A8F              ; {} Back to the top of the wait loop

GetShipsPerCred:
; Get number of ships from DIP settings
0AB7: DB 02           IN      0x02                ; {hard.INP2} DIP settings
0AB9: E6 01           ANI     0x01                ; Bit 0: 3 or 4 ships (only one DIP switch for ships in Part II)
0ABB: C6 03           ADI     0x03                ; From 3-6
0ABD: C9              RET                         ; Out

SpeedShots:
; With less than 9 aliens on the screen the alien shots get a tad bit faster. Probably
; because the advancing rack can catch them.
;
0ABE: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens on screen
0AC1: FE 09           CPI     0x09                ; More than 8?
0AC3: D0              RNC                         ; Yes ... leave shot speed alone
0AC4: 3E FB           MVI     A,0xFB              ; Normally FF (-4) ... now FB (-5)
0AC6: 32 7E 20        STA     0x207E              ; {ram.alienShotDelta} Speed up alien shots
0AC9: C9              RET                         ; Done

ClrP2ScoreIf1P:
0ACA: 3A CE 20        LDA     0x20CE              ; {ram.twoPlayers} Number of players
0ACD: A7              ANA     A                   ; Skip if ...
0ACE: C0              RNZ                         ; ... two player
0ACF: 21 1C 39        LXI     H,0x391C            ; Player 2's score
0AD2: 06 28           MVI     B,0x28              ; 40 rows
0AD4: C3 10 12        JMP     0x1210              ; {code.ClearSmallSprite} Clear a one byte sprite (32 rows long) at HL

PrintSauScore:
0AD7: 0E 03           MVI     C,0x03              ; Length of saucer-score message ... fall into print

PrintMessage:
; Print a message on the screen
; HL = coordinates
; DE = message buffer
; C = length
0AD9: 1A              LDAX    D                   ; Get character
0ADA: D5              PUSH    D                   ; Preserve
0ADB: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Print character
0ADE: D1              POP     D                   ; Restore
0ADF: 13              INX     D                   ; Next character
0AE0: 0D              DCR     C                   ; All done?
0AE1: C2 D9 0A        JNZ     0x0AD9              ; {code.PrintMessage} Print all of message
0AE4: C9              RET                         ; Out

DrawChar:
; Part II: characters are 5 bytes each (8 in the original) and the font is at 1E21.
; The 3 blank bytes under each character are written explicitly.
0AE5: CD 24 1A        CALL    0x1A24              ; {code.CharPtr} Get pointer to the character's picture in DE
0AE8: 06 05           MVI     B,0x05              ; 5 bytes each
0AEA: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
0AEC: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw the 5 columns
0AEF: C5              PUSH    B                   ; Hold count
0AF0: AF              XRA     A                   ; Blank column
0AF1: 77              MOV     M,A                 ; Column 6
0AF2: 01 20 00        LXI     B,0x0020            ; Next ...
0AF5: 09              DAD     B                   ; ... column
0AF6: 77              MOV     M,A                 ; Column 7
0AF7: 09              DAD     B                   ; Next column
0AF8: 77              MOV     M,A                 ; Column 8
0AF9: 09              DAD     B                   ; Leave HL at the next character position
0AFA: C1              POP     B                   ; Restore
0AFB: C9              RET                         ; Done

TimeToSaucer:
0AFC: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} Reference alien's X coordinate
0AFF: FE 78           CPI     0x78                ; Don't process saucer timer ... ($78 is 1st rack Yr)
0B01: D0              RNC                         ; ... unless aliens are closer to bottom
0B02: 2A 91 20        LHLD    0x2091              ; {ram.tillSaucerLSB} Time to saucer
0B05: 7D              MOV     A,L                 ; Is it time ...
0B06: B4              ORA     H                   ; ... for a saucer
0B07: C2 12 0B        JNZ     0x0B12              ; {} No ... skip flagging
0B0A: 21 00 06        LXI     H,0x0600            ; Reset timer to 600 game loops
0B0D: 3E 01           MVI     A,0x01              ; Flag a ...
0B0F: 32 83 20        STA     0x2083              ; {ram.saucerStart} ... saucer sequence
0B12: 2B              DCX     H                   ; Decrement the ...
0B13: 22 91 20        SHLD    0x2091              ; {ram.tillSaucerLSB} ... time-to-saucer
0B16: C9              RET                         ; Done

GetNumShips:
0B17: CD F7 13        CALL    0x13F7              ; {code.GetPlayerDataPtr} HL points to player data
0B1A: 2E FF           MVI     L,0xFF              ; Last byte = numbe of ships
0B1C: 7E              MOV     A,M                 ; Get number of ships
0B1D: C9              RET                         ; Done

ExtraShipCheck:
0B1E: CD CE 16        CALL    0x16CE              ; {code.CurPlyAlive} Get descriptor of sorts
0B21: 2B              DCX     H                   ; Back up ...
0B22: 2B              DCX     H                   ; ... two bytes
0B23: 7E              MOV     A,M                 ; Has extra ship ...
0B24: A7              ANA     A                   ; already been awarded?
0B25: C8              RZ                          ; Yes ... ignore
0B26: 06 15           MVI     B,0x15              ; Extra ship at 1500 (Part II has no DIP choice: the old switch is now preset mode)
0B28: CD 8A 10        CALL    0x108A              ; {code.ScoreHundreds} Get the score's thousands/hundreds digits
0B2B: B8              CMP     B                   ; Have we reached the extra ship score?
0B2C: D8              RC                          ; No ... out
0B2D: CD 37 46        CALL    0x4637              ; {code.AwardShip} Add a ship and print the number of ships
0B30: CD CE 16        CALL    0x16CE              ; {code.CurPlyAlive} Get descriptor for active player of some sort
0B33: 2B              DCX     H                   ; Back up ...
0B34: 2B              DCX     H                   ; ... two bytes
0B35: 36 00           MVI     M,0x00              ; Flag extra ship has been awarded
0B37: 3E FF           MVI     A,0xFF              ; Set timer ...
0B39: 32 99 20        STA     0x2099              ; {ram.extraHold} ... for extra-ship sound

ExtraShipSnd:
0B3C: 06 10           MVI     B,0x10              ; Make sound ...
0B3E: C3 B8 16        JMP     0x16B8              ; {code.SoundBits3On} ... for extra man

AlienScoreValue:
; Part II: B is the alien's status byte (1,3,5 or 7) instead of its row.
0B41: F5              PUSH    PSW                 ; Hold alien type
0B42: 3A AF 20        LDA     0x20AF              ; {ram.scoreTableOn} Always 1 (set from the RAM mirror)
0B45: A7              ANA     A                   ; Set flags
0B46: CA 56 0B        JZ      0x0B56              ; {} Zero ... skip the lookup
0B49: 21 9C 1D        LXI     H,0x1D9C            ; Score table (10, 20, 30)
0B4C: F1              POP     PSW                 ; Restore type
0B4D: FE 02           CPI     0x02                ; Octopus (1) ...
0B4F: D8              RC                          ; ... is worth 10
0B50: 23              INX     H                   ; next value
0B51: FE 04           CPI     0x04                ; Crab (3) ...
0B53: D8              RC                          ; ... is worth 20
0B54: 23              INX     H                   ; Squid (5) and small alien (7) are worth 30
0B55: C9              RET                         ; Done
0B56: F1              POP     PSW                 ; Restore
0B57: C9              RET                         ; Done

AdjustScore:
; Adjust the score for the active player. 20F1 is 1 if there is a new value to add.
; The adjustment is in 20F2,20F3. Then print the score.
0B58: CD 97 0B        CALL    0x0B97              ; {} Get score structure for active player
0B5B: 3A F1 20        LDA     0x20F1              ; {ram.adjustScore} Does the score ...
0B5E: A7              ANA     A                   ; ... need increasing?
0B5F: C8              RZ                          ; No ... done
0B60: AF              XRA     A                   ; Mark score ...
0B61: 32 F1 20        STA     0x20F1              ; {ram.adjustScore} ... as adjusted
0B64: E5              PUSH    H                   ; Hold the pointer to the structure
0B65: 2A F2 20        LHLD    0x20F2              ; {ram.scoreDeltaLSB} Get requested adjustment
0B68: EB              XCHG                        ; Adjustment to DE
0B69: E1              POP     H                   ; Get back pointer to structure
0B6A: 7E              MOV     A,M                 ; Add adjustment ...
0B6B: 83              ADD     E                   ; ... first byte
0B6C: 27              DAA                         ; Adjust it for BCD
0B6D: 77              MOV     M,A                 ; Store new LSB
0B6E: 5F              MOV     E,A                 ; Add adjustment ...
0B6F: 23              INX     H                   ; ... to ...
0B70: 7E              MOV     A,M                 ; ... second ...
0B71: 8A              ADC     D                   ; ... byte
0B72: 27              DAA                         ; Adjust for BCD (cary gets dropped)
0B73: 77              MOV     M,A                 ; Store second byte
0B74: 57              MOV     D,A                 ; Second byte to D (first byte still in E)
0B75: 23              INX     H                   ; Load ...
0B76: 7E              MOV     A,M                 ; ... the ...
0B77: 23              INX     H                   ; ... screen ...
0B78: 66              MOV     H,M                 ; ... coordinates ...
0B79: 6F              MOV     L,A                 ; ... to HL

Print4Digits:
; Print 4 digits in DE
0B7A: 7A              MOV     A,D                 ; Get first 2 digits of BCD or hex
0B7B: CD 7F 0B        CALL    0x0B7F              ; {code.DrawHexByte} Print them
0B7E: 7B              MOV     A,E                 ; Get second 2 digits of BCD or hex (fall into print)

DrawHexByte:
; Display 2 digits in A to screen at HL
0B7F: D5              PUSH    D                   ; Preserve
0B80: F5              PUSH    PSW                 ; Save for later
0B81: 0F              RRC                         ; Get ...
0B82: 0F              RRC                         ; ...
0B83: 0F              RRC                         ; ...
0B84: 0F              RRC                         ; ... left digit
0B85: E6 0F           ANI     0x0F                ; Mask out lower digit's bits
0B87: CD 92 0B        CALL    0x0B92              ; {code.DrawDigit} To screen at HL
0B8A: F1              POP     PSW                 ; Restore digit
0B8B: E6 0F           ANI     0x0F                ; Mask out upper digit
0B8D: CD 92 0B        CALL    0x0B92              ; {code.DrawDigit} To screen
0B90: D1              POP     D                   ; Restore
0B91: C9              RET                         ; Done

DrawDigit:
0B92: C6 1C           ADI     0x1C                ; Digit to character (digits start at 1C)
0B94: C3 E5 0A        JMP     0x0AE5              ; {code.DrawChar} Draw it

GetScoreDesc:
0B97: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Get active player
0B9A: 0F              RRC                         ; Test for player
0B9B: 21 F8 20        LXI     H,0x20F8            ; {ram.P1ScorL} Player 1 score descriptor
0B9E: D8              RC                          ; Keep it if player 1 is active
0B9F: 21 FC 20        LXI     H,0x20FC            ; {ram.P2ScorL} Else get player 2 descriptor
0BA2: C9              RET                         ; Out

ClearPlayField:
; Part II clears the playfield column by column (26 bytes of each of 223 columns).
0BA3: 21 02 24        LXI     H,0x2402            ; Third byte from the bottom, left edge
0BA6: 0E 1A           MVI     C,0x1A              ; 26 bytes high
0BA8: 06 DF           MVI     B,0xDF              ; 223 columns
0BAA: E5              PUSH    H                   ; Hold start
0BAB: C5              PUSH    B                   ; Hold counts
0BAC: 36 00           MVI     M,0x00              ; Clear byte
0BAE: 11 20 00        LXI     D,0x0020            ; Next ...
0BB1: 19              DAD     D                   ; ... column
0BB2: 05              DCR     B                   ; All columns?
0BB3: C2 AC 0B        JNZ     0x0BAC              ; {} No ... do the row
0BB6: C1              POP     B                   ; Restore counts
0BB7: E1              POP     H                   ; Restore start
0BB8: 23              INX     H                   ; Next byte up
0BB9: 0D              DCR     C                   ; All 26?
0BBA: C2 A8 0B        JNZ     0x0BA8              ; {} No ... do them all
0BBD: C9              RET                         ; Done

FlashBothHit:
; (20BA is only ever set to 0 or 1, so this never fires.)
0BBE: 3A BA 20        LDA     0x20BA              ; {ram.flashSaucerArmed} First saucer hit ...
0BC1: FE 02           CPI     0x02                ; ... marker of 2?
0BC3: C0              RNZ                         ; No ... out
0BC4: 3E 01           MVI     A,0x01              ; Flag ...
0BC6: 32 BB 20        STA     0x20BB              ; {ram.flashSaucer} ... both saucers
0BC9: C9              RET                         ; Done

EndOfRack:
; The rack has been cleared. Part II adds the end-of-rack bonus, the "fewer than 56
; shots" extra ship, and the intermission animation before the next rack.
0BCA: CD 41 0C        CALL    0x0C41              ; {code.WaitPlayerExp} Wait for player to finish exploding
0BCD: CD 10 44        CALL    0x4410              ; {code.RackBonus} Award the last-alien bonus (with the beam animation)
0BD0: CD 82 46        CALL    0x4682              ; {code.FewShotsShip} Extra ship if the rack took fewer than 56 shots
0BD3: CD F9 13        CALL    0x13F9              ; {code.GetPlayerDataPage} Player's data page
0BD6: 2E F8           MVI     L,0xF8              ; Reset the shot count ...
0BD8: 36 00           MVI     M,0x00              ; ... for the next rack
0BDA: CD BE 0B        CALL    0x0BBE              ; {code.FlashBothHit} (Never true)
0BDD: CD 96 18        CALL    0x1896              ; {code.Intermission} Run the intermission animation
0BE0: AF              XRA     A                   ; Suspend ...
0BE1: 32 E9 20        STA     0x20E9              ; {ram.suspendPlay} ... ISR game tasks
0BE4: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear playfield
0BE7: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Hold current player number ...
0BEA: F5              PUSH    PSW                 ; ... on stack
0BEB: CD 2A 02        CALL    0x022A              ; {code.CopyRAMMirror} Block copy RAM mirror from ROM
0BEE: F1              POP     PSW                 ; Restore ...
0BEF: 32 67 20        STA     0x2067              ; {ram.playerDataMSB} ... current player number
0BF2: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} ** Why load this again? Nobody ever jumps to 0BF2?
0BF5: 67              MOV     H,A                 ; To H
0BF6: 2E FE           MVI     L,0xFE              ; 2xFE rack count
0BF8: E5              PUSH    H                   ; Hold pointer
0BF9: 2E FA           MVI     L,0xFA              ; 2xFA round number for display
0BFB: 34              INR     M                   ; Next round
0BFC: 7E              MOV     A,M                 ; Get it
0BFD: E5              PUSH    H                   ; Hold pointer
0BFE: 2E F9           MVI     L,0xF9              ; 2xF9 round count
0C00: 34              INR     M                   ; Next round
0C01: E1              POP     H                   ; Restore pointer to display number
0C02: FE 0A           CPI     0x0A                ; Display wraps at 10 ...
0C04: C2 09 0C        JNZ     0x0C09              ; {} ... not yet
0C07: 36 00           MVI     M,0x00              ; ... back to 0
0C09: E1              POP     H                   ; Restore rack count pointer
0C0A: 7E              MOV     A,M                 ; Get rack count
0C0B: CD 21 0C        CALL    0x0C21              ; {code.SetRackStart} Bump rack count and set starting height
0C0E: 7C              MOV     A,H                 ; Player ...
0C0F: 0F              RRC                         ; ... number to carry
0C10: DA 38 0C        JC      0x0C38              ; {} 2nd player stuff
0C13: 3E 21           MVI     A,0x21              ; Start fleet with ...
0C15: 32 98 20        STA     0x2098              ; {ram.soundPort5} ... first sound
0C18: CD 3B 02        CALL    0x023B              ; {code.DrawShieldPl2} Draw shields for player 2
0C1B: CD C2 16        CALL    0x16C2              ; {code.InitAliensP2} Initalize aliens for player 2
0C1E: C3 0E 09        JMP     0x090E              ; {} Continue at top of game loop

SetRackStart:
0C21: E6 07           ANI     0x07                ; 0-7
0C23: 3C              INR     A                   ; Now 1-8
0C24: 77              MOV     M,A                 ; Update count since player just beat a rack
0C25: 21 9F 1D        LXI     H,0x1D9F            ; Alien start table (first entry used is 1DA0)
0C28: 23              INX     H                   ; Find the ...
0C29: 3D              DCR     A                   ; ... right entry ...
0C2A: C2 28 0C        JNZ     0x0C28              ; {} ... in the table
0C2D: 46              MOV     B,M                 ; Starting Y for this rack
0C2E: CD F9 13        CALL    0x13F9              ; {code.GetPlayerDataPage} Player's data
0C31: 2E FC           MVI     L,0xFC              ; Reference alien ...
0C33: 70              MOV     M,B                 ; ... Y
0C34: 23              INX     H                   ; Reference alien ...
0C35: 36 38           MVI     M,0x38              ; ... X starts at 38
0C37: C9              RET                         ; Done

;
0C38: CD 35 02        CALL    0x0235              ; {code.DrawShieldPl1} Draw shields for player 1
0C3B: CD DE 01        CALL    0x01DE              ; {code.InitAliens} Initialize aliens for player 1
0C3E: C3 0E 09        JMP     0x090E              ; {} Continue at top of game loop

WaitPlayerExp:
0C41: CD 5E 0C        CALL    0x0C5E              ; {} Check player collision
0C44: C2 57 0C        JNZ     0x0C57              ; {} Player is not alive ... skip delay
0C47: 3E 30           MVI     A,0x30              ; Half second delay
0C49: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} Set ISR timer
0C4C: 3A C0 20        LDA     0x20C0              ; {ram.isrDelay} Has timer expired?
0C4F: A7              ANA     A                   ; Check exipre
0C50: C8              RZ                          ; Out if done
0C51: CD 5E 0C        CALL    0x0C5E              ; {} Check player collision
0C54: CA 4C 0C        JZ      0x0C4C              ; {} No collision ... wait on timer
0C57: CD 5E 0C        CALL    0x0C5E              ; {} Wait for ...
0C5A: C2 57 0C        JNZ     0x0C57              ; {} ... collision to end
0C5D: C9              RET                         ; Done

PlayerHitChk:
0C5E: 3A 15 20        LDA     0x2015              ; {ram.playerAlive} Active player hit flag
0C61: FE FF           CPI     0xFF                ; All FFs means player is OK
0C63: C9              RET                         ; Out

ScoreForAlien:
; Start the hit-alien sound and flag the adjustment for the score.
; B contains the row, which determines the score value.
0C64: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Are we in ...
0C67: A7              ANA     A                   ; ... game mode?
0C68: CA 81 0C        JZ      0x0C81              ; {} No ... skip scoring in demo
0C6B: 48              MOV     C,B                 ; Hold row number
0C6C: 06 08           MVI     B,0x08              ; Alien hit sound
0C6E: CD B8 16        CALL    0x16B8              ; {code.SoundBits3On} Enable sound
0C71: 41              MOV     B,C                 ; Restore row number
0C72: 78              MOV     A,B                 ; Into A
0C73: CD 41 0B        CALL    0x0B41              ; {code.AlienScoreValue} Look up the score for the alien
0C76: 7E              MOV     A,M                 ; Get the score value
0C77: 21 F3 20        LXI     H,0x20F3            ; {ram.scoreDeltaMSB} Pointer to score delta
0C7A: 36 00           MVI     M,0x00              ; Upper byte of score delta is "00"
0C7C: 2B              DCX     H                   ; Point to score delta LSB
0C7D: 77              MOV     M,A                 ; Set score for hitting alien
0C7E: 2B              DCX     H                   ; Point to adjust-score-flag
0C7F: 36 01           MVI     M,0x01              ; The score will get changed elsewhere
0C81: 21 62 20        LXI     H,0x2062            ; {ram.expAlienLSB} Return exploding-alien descriptor
0C84: C9              RET                         ; Out

PrintMessageDel:
; Print message from DE to screen at HL (length in C) with a
; delay between letters.
0C85: D5              PUSH    D                   ; Preserve
0C86: 1A              LDAX    D                   ; Get character
0C87: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Draw character on screen
0C8A: D1              POP     D                   ; Preserve
0C8B: 3E 07           MVI     A,0x07              ; Delay between letters
0C8D: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} Set counter
0C90: 3A C0 20        LDA     0x20C0              ; {ram.isrDelay} Get counter
0C93: 3D              DCR     A                   ; Is it 1?
0C94: C2 90 0C        JNZ     0x0C90              ; {} No ... wait on it
0C97: 13              INX     D                   ; Next in message
0C98: 0D              DCR     C                   ; All done?
0C99: C2 85 0C        JNZ     0x0C85              ; {code.PrintMessageDel} No ... do all
0C9C: C9              RET                         ; Out

OneSecDelay:
; Delay 64 interrupts
0C9D: 3E 40           MVI     A,0x40              ; Delay of 64 (tad over 1 sec)
0C9F: C3 B6 0C        JMP     0x0CB6              ; {code.WaitOnDelay} Do delay

TwoSecDelay:
; Delay 128 interrupts
0CA2: 3E 80           MVI     A,0x80              ; Delay of 80 (tad over 2 sec)
0CA4: C3 B6 0C        JMP     0x0CB6              ; {code.WaitOnDelay} Do delay

SplashDemo:
0CA7: E1              POP     H                   ; Drop the call to ABF and ...
0CA8: CD 83 43        CALL    0x4383              ; {code.SaucerDropMove} Drop alien (demo too)
0CAB: C3 7B 00        JMP     0x007B              ; {} Continue with the game ISR tasks

ISRSplTasks:
; Part II only has the demo as an ISR splash task (the animations are gone).
0CAE: 3A C1 20        LDA     0x20C1              ; {ram.isrSplashTask} Demo running?
0CB1: 0F              RRC                         ; Bit 0
0CB2: DA A7 0C        JC      0x0CA7              ; {code.SplashDemo} Yes ... run the game objects
0CB5: C9              RET                         ; Done

WaitOnDelay:
; Wait on ISR counter to reach 0
0CB6: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} Delay counter
0CB9: 3A C0 20        LDA     0x20C0              ; {ram.isrDelay} Get current delay
0CBC: A7              ANA     A                   ; Zero yet?
0CBD: C2 B9 0C        JNZ     0x0CB9              ; {} No ... wait on it
0CC0: C9              RET                         ; Out

DemoAliens:
; Part II: alternate the demo between two formations (round 0 and round 3).
0CC1: 21 EC 20        LXI     H,0x20EC            ; {ram.splashAnimate} Alternates every demo
0CC4: 7E              MOV     A,M                 ; Get it
0CC5: A7              ANA     A                   ; Set flags
0CC6: C2 D1 0C        JNZ     0x0CD1              ; {} Was 1 ... use round 3
0CC9: 36 01           MVI     M,0x01              ; Next time use round 3
0CCB: 32 F9 21        STA     0x21F9              ; Player 1 round count
0CCE: C3 DE 01        JMP     0x01DE              ; {code.InitAliens} Build the formation
0CD1: 36 00           MVI     M,0x00              ; Next time use round 0
0CD3: 3E 03           MVI     A,0x03              ; Round 3
0CD5: C3 CB 0C        JMP     0x0CCB              ; {} Set round and build formation

SplashLoop:
;=============================================================
; After initialization ... splash screens
0CD8: AF              XRA     A                   ; Make a 0
0CD9: D3 03           OUT     0x03                ; {hard.SOUND1} Turn off sound
0CDB: D3 05           OUT     0x05                ; {hard.SOUND2} Turn off sound
0CDD: CD DC 17        CALL    0x17DC              ; {code.ClearScreen} Clear the screen
0CE0: FB              EI                          ; Enable interrupts (using them for delays)
0CE1: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} One second delay
0CE4: CD DC 40        CALL    0x40DC              ; {code.TitleScreen} Part II: big "SPACE INVADERS PART II" title
0CE7: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay}
0CEA: CD 3F 16        CALL    0x163F              ; {code.DrawAdvTable} "SCORE ADVANCE TABLE"
0CED: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} One second delay

;
; Play demo
0CF0: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear playfield
0CF3: 3A FF 21        LDA     0x21FF              ; {ram.p1ShipsRem} Number of ships for player-1
0CF6: A7              ANA     A                   ; If non zero ...
0CF7: C2 03 0D        JNZ     0x0D03              ; {} ... keep it (counts down between demos)
0CFA: CD B7 0A        CALL    0x0AB7              ; {code.GetShipsPerCred} Get number of ships from DIP settings
0CFD: 32 FF 21        STA     0x21FF              ; {ram.p1ShipsRem} Reset number of ships for player-1
0D00: CD FF 17        CALL    0x17FF              ; {code.RemoveShip} Remove a ship from stash and update indicators

;
0D03: CD 2A 02        CALL    0x022A              ; {code.CopyRAMMirror} Block copy ROM mirror to initialize RAM
0D06: CD C1 0C        CALL    0x0CC1              ; {code.DemoAliens} Initialize the demo formation
0D09: CD 35 02        CALL    0x0235              ; {code.DrawShieldPl1} Draw shields for player 1 (to buffer)
0D0C: CD 60 02        CALL    0x0260              ; {code.RestoreShields1} Restore shields for player 1 (to screen)
0D0F: CD 15 02        CALL    0x0215              ; {code.DrawBottomLine}
0D12: CD CA 09        CALL    0x09CA              ; {code.RackArrive} Slide the demo rack into place
0D15: 3E 01           MVI     A,0x01              ; Start ...
0D17: 32 C1 20        STA     0x20C1              ; {ram.isrSplashTask} ... the demo

;
0D1A: CD FE 13        CALL    0x13FE              ; {code.PlrFireOrDemo} In demo ... process demo movement and always fire
0D1D: CD 68 0D        CALL    0x0D68              ; {code.DemoBumpAndHidden} Check player shot and aliens bumping edges (and the hidden message)
0D20: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
0D22: CD 5E 0C        CALL    0x0C5E              ; {} Has demo player been hit?
0D25: CA 1A 0D        JZ      0x0D1A              ; {} No ... continue game
0D28: AF              XRA     A                   ; Remove player shot ...
0D29: 32 25 20        STA     0x2025              ; {ram.plyrShotStatus} ... from activity
0D2C: CD 5E 0C        CALL    0x0C5E              ; {} Wait for demo player ...
0D2F: C2 2C 0D        JNZ     0x0D2C              ; {} ... to stop exploding

;
; Credit information
0D32: AF              XRA     A                   ; Turn off ...
0D33: 32 C1 20        STA     0x20C1              ; {ram.isrSplashTask} ... the demo
0D36: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} One second delay
0D39: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear the playfield
0D3C: 0E 0C           MVI     C,0x0C              ; Message size
0D3E: 21 11 2C        LXI     H,0x2C11            ; Screen coordinates
0D41: 11 17 11        LXI     D,0x1117            ; "INSERT  COIN"
0D44: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print message
0D47: CD D2 0D        CALL    0x0DD2              ; {code.FlashHiName} Show the high score holder (and *TAITO CORPORATION*)
0D4A: 01 23 11        LXI     B,0x1123            ; Descriptor for "<1 OR 2 PLAYERS>  "
0D4D: CD 7D 16        CALL    0x167D              ; {code.ReadPriStruct} Load the screen,pointer
0D50: CD 73 16        CALL    0x1673              ; {} Print the message
0D53: DB 02           IN      0x02                ; {hard.INP2} Display coin info (bit 7) ...
0D55: 07              RLC                         ; ... on demo screen?
0D56: DA 5F 0D        JC      0x0D5F              ; {} 1 means no ... skip it
0D59: 01 27 11        LXI     B,0x1127            ; Descriptors for "*1 PLAYER  1 COIN " and "*2 PLAYERS 2 COINS"
0D5C: CD 61 16        CALL    0x1661              ; {} Load the descriptor
0D5F: CD A2 0C        CALL    0x0CA2              ; {code.TwoSecDelay} Two second delay
0D62: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear playfield
0D65: C3 9D 16        JMP     0x169D              ; {code.SplashRestart} Back to the top of the splash loop

DemoBumpAndHidden:
0D68: CD C8 16        CALL    0x16C8              ; {code.PlyrShotAndBump} Shot and rack bump
0D6B: C3 19 45        JMP     0x4519              ; {code.CheckHiddenMes} Check for the hidden message

; Hidden message "TAITO CORP." stored backwards with $3F subtracted from each character
; (printed by 4536).
0D6E: DB D0 D2 CF C3 DC CF D4 C9 C1 D4
0D79: 1B 07 08 2B 12 02 0E 11 04 1B       ; " HI-SCORE "
```

# Part II: High Score Name Entry

```code

ScanLine96Cont:
; Part II: the mid-screen interrupt first checks the "name reset" switch and, while the
; high-score name is being entered, reads the fire button and times the entry. During
; name entry none of the normal mid-screen tasks run.
0D83: DB 00           IN      0x00                ; {hard.INP0} Read port 0
0D85: E6 40           ANI     0x40                ; Bit 6 (active low) is the NAME RESET switch
0D87: CC C9 0D        CZ      0x0DC9              ; {code.NameReset} Pressed ... restore the default name "TAITO"
0D8A: 3A 4D 23        LDA     0x234D              ; {ram.nameEntry} Is name entry in progress?
0D8D: A7              ANA     A                   ; Set flags
0D8E: CA A4 00        JZ      0x00A4              ; {} No ... continue the normal mid-screen ISR
0D91: DB 01           IN      0x01                ; {hard.INP1} Either start button ...
0D93: E6 06           ANI     0x06                ; ... (bits 1 and 2) ...
0D95: C4 C3 0D        CNZ     0x0DC3              ; {code.NameStartHit} ... ends name entry
0D98: CD B9 0D        CALL    0x0DB9              ; {code.NameInputs} Read the entering player's controls
0D9B: E6 10           ANI     0x10                ; Fire button?
0D9D: 06 01           MVI     B,0x01              ; Flag value 1
0D9F: 21 B1 20        LXI     H,0x20B1            ; {ram.nameFireHeld} Fire-held flag
0DA2: C2 AE 0D        JNZ     0x0DAE              ; {} Fire is down ... set the held flag
0DA5: 7E              MOV     A,M                 ; Fire is up. Was it ...
0DA6: A7              ANA     A                   ; ... down last time?
0DA7: 23              INX     H                   ; Point to fire-pressed flag (20B2)
0DA8: C2 AE 0D        JNZ     0x0DAE              ; {} Yes ... it was just released ... flag a letter selection
0DAB: 2B              DCX     H                   ; Back to held flag
0DAC: 06 00           MVI     B,0x00              ; Clear it
0DAE: 70              MOV     M,B                 ; Store flag
0DAF: 2A 4A 23        LHLD    0x234A              ; {ram.nameTimerL} Name entry ...
0DB2: 23              INX     H                   ; ... timer ...
0DB3: 22 4A 23        SHLD    0x234A              ; {ram.nameTimerL} ... counts up
0DB6: C3 94 00        JMP     0x0094              ; {code.ISRExit} Restore and out (skip the normal tasks)

NameInputs:
; Read the controls of the player entering a name (20E1 is 0 for player 1).
0DB9: 3A E1 20        LDA     0x20E1              ; {ram.nameFlip} Player 2 entering the name?
0DBC: A7              ANA     A                   ; Set flags
0DBD: C2 F2 15        JNZ     0x15F2              ; {} Yes ... read port 2 and return
0DC0: DB 01           IN      0x01                ; {hard.INP1} Player 1 controls
0DC2: C9              RET                         ; Done

NameStartHit:
0DC3: 3E 01           MVI     A,0x01              ; Flag that ...
0DC5: 32 BF 20        STA     0x20BF              ; {ram.nameStartHit} ... a start button was pressed (finishes the entry)
0DC8: C9              RET                         ; Done

NameReset:
0DC9: CD 30 11        CALL    0x1130              ; {code.DefaultName} Copy "TAITO" (and cleared entry variables) to the name buffer
0DCC: CD 97 10        CALL    0x1097              ; {code.CenterHiName} Work out where to print it
0DCF: C3 30 10        JMP     0x1030              ; {code.PrintHiName} Print it

FlashHiName:
0DD2: E5              PUSH    H                   ; Hold registers
0DD3: C5              PUSH    B                   ; ...
0DD4: CD BA 10        CALL    0x10BA              ; {code.FlashHiNameDo} Flash " HI-SCORE " and the holder's name
0DD7: C1              POP     B                   ; Restore ...
0DD8: E1              POP     H                   ; ... registers
0DD9: C9              RET                         ; Done

Delay32:
0DDA: 3E 20           MVI     A,0x20              ; Half second
0DDC: C3 B6 0C        JMP     0x0CB6              ; {code.WaitOnDelay} Wait

Delay5:
0DDF: 3E 05           MVI     A,0x05              ; 5 ISR ticks
0DE1: C3 B6 0C        JMP     0x0CB6              ; {code.WaitOnDelay} Wait

NameMoveDelay:
; Wait (about 1600 loops) for the joystick to be released. If it is released the caller
; is skipped (one move per push).
0DE4: 01 50 06        LXI     B,0x0650            ; Loop count
0DE7: CD B9 0D        CALL    0x0DB9              ; {code.NameInputs} Read controls
0DEA: E6 60           ANI     0x60                ; Left or right still held?
0DEC: CA F8 0D        JZ      0x0DF8              ; {} No ... drop the caller
0DEF: 0D              DCR     C                   ; Count ...
0DF0: C2 E7 0D        JNZ     0x0DE7              ; {} ... down
0DF3: 05              DCR     B                   ; Count ...
0DF4: C2 E7 0D        JNZ     0x0DE7              ; {} ... down
0DF7: C9              RET                         ; Held long enough ... auto-repeat the move
0DF8: E1              POP     H                   ; Drop the caller (no move)
0DF9: C9              RET                         ; Return to caller's caller

NameEntry:
; Part II: HI-SCORER REGISTRATION. The player that beat the high score picks up to
; 10 letters from a grid (A-Z, "." and RUB/END) with left/right and fire. A start
; button or the timer ends the entry.
0DFA: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear the playfield
0DFD: CD 28 10        CALL    0x1028              ; {code.EraseHiName} Erase the name area
0E00: 06 15           MVI     B,0x15              ; 21 bytes
0E02: 11 65 10        LXI     D,0x1065            ; Initial name-entry variables (blank name, timer, cursor ...)
0E05: 21 40 23        LXI     H,0x2340            ; {ram.hiName} To 2340-2354
0E08: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Copy
0E0B: 11 3D 10        LXI     D,0x103D            ; "HI-SCORER  REGISTRATION"
0E0E: 21 17 27        LXI     H,0x2717            ; Screen coordinates
0E11: 0E 17           MVI     C,0x17              ; 23 characters
0E13: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print it
0E16: 21 12 27        LXI     H,0x2712            ; First row of letters
0E19: 11 21 1E        LXI     D,0x1E21            ; Character "A"
0E1C: CD A7 0E        CALL    0x0EA7              ; {code.DrawLetterRow} A-K
0E1F: 21 10 27        LXI     H,0x2710            ; Second row
0E22: CD A7 0E        CALL    0x0EA7              ; {code.DrawLetterRow} L-V
0E25: 21 0E 27        LXI     H,0x270E            ; Third row
0E28: 0E 05           MVI     C,0x05              ; Five letters
0E2A: CD A9 0E        CALL    0x0EA9              ; {code.DrawLetters} W X Y Z .
0E2D: 21 0E 33        LXI     H,0x330E            ; After the letters
0E30: 11 16 1F        LXI     D,0x1F16            ; "RUB  END" picture
0E33: 06 28           MVI     B,0x28              ; 40 bytes
0E35: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw it
0E38: 11 54 10        LXI     D,0x1054            ; "NAME [~~~~~~~~~~]"
0E3B: 0E 11           MVI     C,0x11              ; 17 characters
0E3D: 21 06 2A        LXI     H,0x2A06            ; Screen coordinates
0E40: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print it

NameLoop:
0E43: 3A 4D 23        LDA     0x234D              ; {ram.nameEntry} Still entering?
0E46: A7              ANA     A                   ; Set flags
0E47: CA 1B 10        JZ      0x101B              ; {code.NameDone} No ... done
0E4A: 3A 4B 23        LDA     0x234B              ; {ram.nameTimerM} Time ...
0E4D: FE 20           CPI     0x20                ; ... up?
0E4F: D2 1B 10        JNC     0x101B              ; {code.NameDone} Yes ... done
0E52: CD B9 0E        CALL    0x0EB9              ; {code.DrawNameCursor} Draw the cursor under the current letter
0E55: CD B9 0D        CALL    0x0DB9              ; {code.NameInputs} Read controls
0E58: E6 76           ANI     0x76                ; Start2, Start1, fire, left, right
0E5A: FE 40           CPI     0x40                ; Just right?
0E5C: CC D2 0E        CZ      0x0ED2              ; {code.CursorRight} Yes ... move cursor right
0E5F: FE 20           CPI     0x20                ; Just left?
0E61: CC 28 0F        CZ      0x0F28              ; {code.CursorLeft} Yes ... move cursor left
0E64: 3A BF 20        LDA     0x20BF              ; {ram.nameStartHit} Start pressed?
0E67: A7              ANA     A                   ; Set flags
0E68: C2 1B 10        JNZ     0x101B              ; {code.NameDone} Yes ... done
0E6B: 3A B2 20        LDA     0x20B2              ; {ram.nameFirePressed} Fire pressed (and released)?
0E6E: A7              ANA     A                   ; Set flags
0E6F: C2 72 0F        JNZ     0x0F72              ; {code.NameSelect} Yes ... select the letter
0E72: 01 30 01        LXI     B,0x0130            ; Short ...
0E75: CD C9 0E        CALL    0x0EC9              ; {code.DelayBC} ... delay
0E78: CD C1 0E        CALL    0x0EC1              ; {code.EraseNameCursor} Erase cursor (it flickers)
0E7B: 3A 4B 23        LDA     0x234B              ; {ram.nameTimerM} Time running out?
0E7E: FE 1D           CPI     0x1D                ; Warning time?
0E80: C2 43 0E        JNZ     0x0E43              ; {} No ... keep going
0E83: 06 05           MVI     B,0x05              ; Flash "NAME" 5 times
0E85: C5              PUSH    B                   ; Hold count
0E86: 21 06 2A        LXI     H,0x2A06            ; "NAME"
0E89: 06 20           MVI     B,0x20              ; 32 rows
0E8B: CD 71 11        CALL    0x1171              ; {code.ClearRows} Erase "NAME"
0E8E: CD DF 0D        CALL    0x0DDF              ; {code.Delay5} Wait
0E91: 11 54 10        LXI     D,0x1054            ; "NAME"
0E94: 21 06 2A        LXI     H,0x2A06            ; Screen coordinates
0E97: 0E 04           MVI     C,0x04              ; 4 characters
0E99: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print "NAME"
0E9C: CD DF 0D        CALL    0x0DDF              ; {code.Delay5} Wait
0E9F: C1              POP     B                   ; Restore count
0EA0: 05              DCR     B                   ; All 5 flashes?
0EA1: C2 85 0E        JNZ     0x0E85              ; {} No ... do them all
0EA4: C3 43 0E        JMP     0x0E43              ; {code.NameLoop} Back to the loop

DrawLetterRow:
0EA7: 0E 0B           MVI     C,0x0B              ; 11 letters

DrawLetters:
0EA9: 06 05           MVI     B,0x05              ; 5 bytes each
0EAB: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw letter
0EAE: C5              PUSH    B                   ; Hold
0EAF: 01 60 01        LXI     B,0x0160            ; 11 columns ...
0EB2: 09              DAD     B                   ; ... over for the next letter
0EB3: C1              POP     B                   ; Restore
0EB4: 0D              DCR     C                   ; All letters?
0EB5: C2 A9 0E        JNZ     0x0EA9              ; {} No ... do them all
0EB8: C9              RET                         ; Done

DrawNameCursor:
0EB9: 2A 4E 23        LHLD    0x234E              ; {ram.nameCursorL} Cursor position
0EBC: 3E 2A           MVI     A,0x2A              ; Cursor character "_"
0EBE: C3 E5 0A        JMP     0x0AE5              ; {code.DrawChar} Draw it

EraseNameCursor:
0EC1: 2A 4E 23        LHLD    0x234E              ; {ram.nameCursorL} Cursor position
0EC4: 3E 1B           MVI     A,0x1B              ; Space
0EC6: C3 E5 0A        JMP     0x0AE5              ; {code.DrawChar} Draw it

DelayBC:
; Busy-wait for BC counts.
0EC9: 0D              DCR     C                   ; Count ...
0ECA: C2 C9 0E        JNZ     0x0EC9              ; {} ... C
0ECD: 05              DCR     B                   ; Count ...
0ECE: C2 C9 0E        JNZ     0x0EC9              ; {} ... B
0ED1: C9              RET                         ; Done

CursorRight:
0ED2: CD E4 0D        CALL    0x0DE4              ; {code.NameMoveDelay} One move per push
0ED5: CD C1 0E        CALL    0x0EC1              ; {code.EraseNameCursor} Erase cursor
0ED8: 2A 4E 23        LHLD    0x234E              ; {ram.nameCursorL} Cursor position
0EDB: 7D              MOV     A,L                 ; Which row?
0EDC: FE 11           CPI     0x11                ; Top row?
0EDE: CA 03 0F        JZ      0x0F03              ; {} Yes
0EE1: FE 0F           CPI     0x0F                ; Middle row?
0EE3: CA 0C 0F        JZ      0x0F0C              ; {} Yes
0EE6: 7C              MOV     A,H                 ; Bottom row: on "."?
0EE7: FE 33           CPI     0x33                ; (column of ".")
0EE9: CA 17 0F        JZ      0x0F17              ; {} Yes ... jump over to RUB
0EEC: 24              INR     H                   ; Move right ...
0EED: 24              INR     H                   ; ... one letter
0EEE: 7C              MOV     A,H                 ; Past ...
0EEF: FE 35           CPI     0x35                ; ... END?
0EF1: D2 F7 0E        JNC     0x0EF7              ; {} Yes ... wrap
0EF4: C3 FD 0E        JMP     0x0EFD              ; {} No ... store it
0EF7: CD C1 0E        CALL    0x0EC1              ; {code.EraseNameCursor} Erase cursor
0EFA: 21 0D 36        LXI     H,0x360D            ; Wrap to the top row ("A")
0EFD: 22 4E 23        SHLD    0x234E              ; {ram.nameCursorL} New cursor position
0F00: C3 B9 0E        JMP     0x0EB9              ; {code.DrawNameCursor} Draw it
0F03: 7C              MOV     A,H                 ; Top row ... at "K"?
0F04: FE 3B           CPI     0x3B                ; (last column)
0F06: D2 1C 0F        JNC     0x0F1C              ; {} Yes ... wrap to next row
0F09: C3 12 0F        JMP     0x0F12              ; {} No ... move right
0F0C: 7C              MOV     A,H                 ; Middle row ... at "V"?
0F0D: FE 3B           CPI     0x3B                ; (last column)
0F0F: D2 22 0F        JNC     0x0F22              ; {} Yes ... wrap to next row
0F12: 24              INR     H                   ; Move right ...
0F13: 24              INR     H                   ; ... one letter
0F14: C3 FD 0E        JMP     0x0EFD              ; {} Store it
0F17: 26 34           MVI     H,0x34              ; Skip the gap ...
0F19: C3 EC 0E        JMP     0x0EEC              ; {} ... before RUB
0F1C: 21 0F 27        LXI     H,0x270F            ; "L"
0F1F: C3 FD 0E        JMP     0x0EFD              ; {} Store it
0F22: 21 0D 27        LXI     H,0x270D            ; "W"
0F25: C3 FD 0E        JMP     0x0EFD              ; {} Store it

CursorLeft:
0F28: CD E4 0D        CALL    0x0DE4              ; {code.NameMoveDelay} One move per push
0F2B: CD C1 0E        CALL    0x0EC1              ; {code.EraseNameCursor} Erase cursor
0F2E: 2A 4E 23        LHLD    0x234E              ; {ram.nameCursorL} Cursor position
0F31: 7D              MOV     A,L                 ; Which row?
0F32: FE 11           CPI     0x11                ; Top row?
0F34: CA 4C 0F        JZ      0x0F4C              ; {} Yes
0F37: FE 0F           CPI     0x0F                ; Middle row?
0F39: CA 5D 0F        JZ      0x0F5D              ; {} Yes
0F3C: 7C              MOV     A,H                 ; Bottom row: at "W"?
0F3D: FE 28           CPI     0x28                ; (first column)
0F3F: DA 66 0F        JC      0x0F66              ; {} Yes ... wrap to "K"
0F42: FE 34           CPI     0x34                ; On RUB?
0F44: C2 52 0F        JNZ     0x0F52              ; {} No ... move left
0F47: 26 33           MVI     H,0x33              ; Skip the gap back to "."
0F49: C3 52 0F        JMP     0x0F52              ; {} Move left
0F4C: 7C              MOV     A,H                 ; Top row: at "A"?
0F4D: FE 28           CPI     0x28                ; (first column)
0F4F: DA 57 0F        JC      0x0F57              ; {} Yes ... wrap to END
0F52: 25              DCR     H                   ; Move left ...
0F53: 25              DCR     H                   ; ... one letter
0F54: C3 FD 0E        JMP     0x0EFD              ; {} Store it
0F57: 21 11 27        LXI     H,0x2711            ; END
0F5A: C3 FD 0E        JMP     0x0EFD              ; {} Store it
0F5D: 7C              MOV     A,H                 ; Middle row: at "L"?
0F5E: FE 28           CPI     0x28                ; (first column)
0F60: DA 6C 0F        JC      0x0F6C              ; {} Yes ... wrap to "K"
0F63: C3 52 0F        JMP     0x0F52              ; {} Move left
0F66: 21 0F 3B        LXI     H,0x3B0F            ; "V"
0F69: C3 FD 0E        JMP     0x0EFD              ; {} Store it
0F6C: 21 11 3B        LXI     H,0x3B11            ; "K"
0F6F: C3 FD 0E        JMP     0x0EFD              ; {} Store it

NameSelect:
0F72: 01 FF 20        LXI     B,0x20FF            ; {ram.P2ScorLoM} Debounce ...
0F75: CD C9 0E        CALL    0x0EC9              ; {code.DelayBC} ... delay
0F78: 3A 4C 23        LDA     0x234C              ; {ram.nameLength} Letters so far
0F7B: FE 0A           CPI     0x0A                ; Name full?
0F7D: D2 00 10        JNC     0x1000              ; {code.NameFull} Yes ... only RUB or END allowed
0F80: 3A 4E 23        LDA     0x234E              ; {ram.nameCursorL} Cursor row
0F83: FE 11           CPI     0x11                ; Top row?
0F85: CA A0 0F        JZ      0x0FA0              ; {} Yes ... A-K
0F88: FE 0F           CPI     0x0F                ; Middle row?
0F8A: CA A6 0F        JZ      0x0FA6              ; {} Yes ... L-V
0F8D: 3A 4F 23        LDA     0x234F              ; {ram.nameCursorM} Bottom row ... cursor column
0F90: FE 32           CPI     0x32                ; On RUB or END?
0F92: D2 AE 0F        JNC     0x0FAE              ; {} Yes
0F95: CD DE 0F        CALL    0x0FDE              ; {code.CursorColumn} Column number
0F98: C6 16           ADI     0x16                ; + 22 ("W")
0F9A: CD E5 0F        CALL    0x0FE5              ; {code.AddLetter} Add letter to name
0F9D: C3 43 0E        JMP     0x0E43              ; {code.NameLoop} Continue
0FA0: CD DE 0F        CALL    0x0FDE              ; {code.CursorColumn} Column number ("A"+column)
0FA3: C3 E5 0F        JMP     0x0FE5              ; {code.AddLetter} Add letter
0FA6: CD DE 0F        CALL    0x0FDE              ; {code.CursorColumn} Column number
0FA9: C6 0B           ADI     0x0B                ; + 11 ("L")
0FAB: C3 E5 0F        JMP     0x0FE5              ; {code.AddLetter} Add letter
0FAE: FE 35           CPI     0x35                ; END?
0FB0: D2 1B 10        JNC     0x101B              ; {code.NameDone} Yes ... done

NameRub:
0FB3: 3A 4C 23        LDA     0x234C              ; {ram.nameLength} Any letters ...
0FB6: A7              ANA     A                   ; ... to rub out?
0FB7: CA D4 0F        JZ      0x0FD4              ; {} No ... nothing to do
0FBA: 2A 50 23        LHLD    0x2350              ; {ram.nameOutL} Back up ...
0FBD: 25              DCR     H                   ; ... the print ...
0FBE: 22 50 23        SHLD    0x2350              ; {ram.nameOutL} ... position
0FC1: 3E 1B           MVI     A,0x1B              ; Space
0FC3: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Erase the letter
0FC6: 21 4C 23        LXI     H,0x234C            ; {ram.nameLength} One less ...
0FC9: 35              DCR     M                   ; ... letter
0FCA: 21 40 23        LXI     H,0x2340            ; {ram.hiName} Name buffer
0FCD: 3A 4C 23        LDA     0x234C              ; {ram.nameLength} Offset ...
0FD0: 85              ADD     L                   ; ... to ...
0FD1: 6F              MOV     L,A                 ; ... last letter
0FD2: 36 1B           MVI     M,0x1B              ; Blank it
0FD4: AF              XRA     A                   ; Clear ...
0FD5: 32 B1 20        STA     0x20B1              ; {ram.nameFireHeld} ... fire ...
0FD8: 32 B2 20        STA     0x20B2              ; {ram.nameFirePressed} ... flags
0FDB: C3 43 0E        JMP     0x0E43              ; {code.NameLoop} Continue

CursorColumn:
; A = column number of the cursor (0-10).
0FDE: 3A 4F 23        LDA     0x234F              ; {ram.nameCursorM} Cursor column
0FE1: D6 27           SUI     0x27                ; First column is 27
0FE3: 0F              RRC                         ; Columns are 2 apart
0FE4: C9              RET                         ; Done

AddLetter:
0FE5: 21 40 23        LXI     H,0x2340            ; {ram.hiName} Name buffer
0FE8: F5              PUSH    PSW                 ; Hold letter
0FE9: 3A 4C 23        LDA     0x234C              ; {ram.nameLength} Offset ...
0FEC: 85              ADD     L                   ; ... to next ...
0FED: 6F              MOV     L,A                 ; ... letter
0FEE: F1              POP     PSW                 ; Restore letter
0FEF: 77              MOV     M,A                 ; Store it in the name
0FF0: 2A 50 23        LHLD    0x2350              ; {ram.nameOutL} Print position
0FF3: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Print the letter
0FF6: 22 50 23        SHLD    0x2350              ; {ram.nameOutL} Next print position
0FF9: 21 4C 23        LXI     H,0x234C            ; {ram.nameLength} One more ...
0FFC: 34              INR     M                   ; ... letter
0FFD: C3 D4 0F        JMP     0x0FD4              ; {} Clear the fire flags and continue

NameFull:
1000: 3A 4E 23        LDA     0x234E              ; {ram.nameCursorL} Must be ...
1003: FE 0D           CPI     0x0D                ; ... on the bottom row
1005: C2 1B 10        JNZ     0x101B              ; {code.NameDone} No ... (letters) ... done
1008: 3A 4F 23        LDA     0x234F              ; {ram.nameCursorM} Cursor column
100B: FE 32           CPI     0x32                ; RUB or END?
100D: D2 13 10        JNC     0x1013              ; {} Yes
1010: C3 1B 10        JMP     0x101B              ; {code.NameDone} No ... done
1013: FE 36           CPI     0x36                ; END?
1015: D2 1B 10        JNC     0x101B              ; {code.NameDone} Yes ... done
1018: C3 B3 0F        JMP     0x0FB3              ; {code.NameRub} RUB ... rub out the last letter

NameDone:
101B: AF              XRA     A                   ; Name entry ...
101C: 32 4D 23        STA     0x234D              ; {ram.nameEntry} ... is over
101F: CD 97 10        CALL    0x1097              ; {code.CenterHiName} Center the new name
1022: CD 30 10        CALL    0x1030              ; {code.PrintHiName} Print it
1025: C3 A3 0B        JMP     0x0BA3              ; {code.ClearPlayField} Clear the playfield and out

EraseHiName:
1028: 06 50           MVI     B,0x50              ; 80 rows
102A: 21 1E 2D        LXI     H,0x2D1E            ; Where the name is printed
102D: C3 71 11        JMP     0x1171              ; {code.ClearRows} Erase it

PrintHiName:
1030: 2A 3E 23        LHLD    0x233E              ; {ram.hiNamePosL} Where to print
1033: 11 40 23        LXI     D,0x2340            ; {ram.hiName} The name
1036: 3A 4C 23        LDA     0x234C              ; {ram.nameLength} Number of letters
1039: 4F              MOV     C,A                 ; To C
103A: C3 D9 0A        JMP     0x0AD9              ; {code.PrintMessage} Print it
103D: 07 08 2B 12 02 0E 11 04 11 1B 1B 11 ; "HI-SCORER  R"
1049: 04 06 08 12 13 11 00 13 08 0E 0D    ; "EGISTRATION"
1054: 0D 00 0C 04 1B 2E 2F 2F 2F 2F 2F 2F ; "NAME [~~~~~~"
1060: 2F 2F 2F 2F 30                      ; "~~~~]"
1065: 1B 1B 1B 1B 1B 1B 1B 1B 1B 1B 00 00 00 FF 11 27
1075: 07 30 00 00 00

Print4Digits0:
; Part II scores have 5 digits: the 4 BCD digits and a fixed "0".
107A: E5              PUSH    H                   ; Hold ...
107B: D5              PUSH    D                   ; ... registers
107C: 11 00 04        LXI     D,0x0400            ; 32 columns ...
107F: 19              DAD     D                   ; ... over (after the 4 digits)
1080: 3E 1C           MVI     A,0x1C              ; "0"
1082: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Print the trailing 0
1085: D1              POP     D                   ; Restore ...
1086: E1              POP     H                   ; ... registers
1087: C3 7A 0B        JMP     0x0B7A              ; {code.Print4Digits} Print the 4 BCD digits

ScoreHundreds:
; A = score shifted left 4 bits, MSB (the thousands and hundreds of the displayed score).
108A: CD 97 0B        CALL    0x0B97              ; {code.GetScoreDesc} Active player's score
108D: 7E              MOV     A,M                 ; Score ...
108E: 23              INX     H                   ; ... into ...
108F: 66              MOV     H,M                 ; ... HL
1090: 6F              MOV     L,A                 ; ...
1091: 29              DAD     H                   ; *2
1092: 29              DAD     H                   ; *4
1093: 29              DAD     H                   ; *8
1094: 29              DAD     H                   ; *16
1095: 7C              MOV     A,H                 ; The two digits
1096: C9              RET                         ; Done

CenterHiName:
; Work out the screen position that centers the high-score name above "HI-SCORE".
1097: 3A 4C 23        LDA     0x234C              ; {ram.nameLength} Letters in name
109A: A7              ANA     A                   ; Any?
109B: CA AE 10        JZ      0x10AE              ; {} No ... use the default
109E: 47              MOV     B,A                 ; To B
109F: 3E 0A           MVI     A,0x0A              ; 10 ...
10A1: 90              SUB     B                   ; ... minus length
10A2: 37              STC                         ; Clear ...
10A3: 3F              CMC                         ; ... carry
10A4: 1F              RAR                         ; Half the spare characters
10A5: C6 2D           ADI     0x2D                ; Plus the left-most column
10A7: 67              MOV     H,A                 ; To H
10A8: 2E 1E           MVI     L,0x1E              ; Row
10AA: 22 3E 23        SHLD    0x233E              ; {ram.hiNamePosL} Store position
10AD: C9              RET                         ; Done
10AE: 21 1E 2D        LXI     H,0x2D1E            ; Default ...
10B1: 22 3E 23        SHLD    0x233E              ; {ram.hiNamePosL} ... position
10B4: 3E 0A           MVI     A,0x0A              ; Default ...
10B6: 32 4C 23        STA     0x234C              ; {ram.nameLength} ... length of 10
10B9: C9              RET                         ; Done

FlashHiNameDo:
10BA: CD 73 45        CALL    0x4573              ; {code.PrintCorp} Print *TAITO CORPORATION*
10BD: AF              XRA     A                   ; Alien shots ...
10BE: 32 E4 20        STA     0x20E4              ; {ram.shotsHalted} ... allowed
10C1: FB              EI                          ; Interrupts on (we use them to time)
10C2: 06 05           MVI     B,0x05              ; Flash 5 times
10C4: C5              PUSH    B                   ; Hold count
10C5: 11 79 0D        LXI     D,0x0D79            ; " HI-SCORE "
10C8: 0E 0A           MVI     C,0x0A              ; 10 characters
10CA: 21 1E 2D        LXI     H,0x2D1E            ; Over the name
10CD: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print " HI-SCORE "
10D0: CD DA 0D        CALL    0x0DDA              ; {code.Delay32} Wait
10D3: CD 28 10        CALL    0x1028              ; {code.EraseHiName} Erase it
10D6: CD 97 10        CALL    0x1097              ; {code.CenterHiName} Center the name
10D9: CD 30 10        CALL    0x1030              ; {code.PrintHiName} Print the name
10DC: CD DA 0D        CALL    0x0DDA              ; {code.Delay32} Wait
10DF: C1              POP     B                   ; Restore count
10E0: 05              DCR     B                   ; All done?
10E1: C2 C4 10        JNZ     0x10C4              ; {} No ... flash again
10E4: C9              RET                         ; Done
10E5: 26 1D 1B 0E 11 1B 1E 1B 0F 0B 00 18 ; "<1 OR 2 PLAY"
10F1: 04 11 12 27 1B 1B                   ; "ERS>  "
10F7: 29 1D 1B 0F 0B 00 18 04 11 1B 1B 1D ; "*1 PLAYER  1"
1103: 1B 02 0E 08 0D 1B                   ; " COIN "
1109: 1B 1B 13 00 08 13 0E 1B 1B 1B       ; "  TAITO   "
1113: 00 00 00 00

MessageCoin:
1117: 08 0D 12 04 11 13 1B 1B 02 0E 08 0D ; "INSERT  COIN"

CreditTable:
1123: 0D 2A E5 10 0A 2A F7 10 07 2A 3C 11 FF

DefaultName:
1130: 06 0E           MVI     B,0x0E              ; 14 bytes
1132: 11 09 11        LXI     D,0x1109            ; Default name and variables
1135: 21 40 23        LXI     H,0x2340            ; {ram.hiName} Name buffer
1138: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Copy
113B: C9              RET                         ; Done
113C: 29 1E 1B 0F 0B 00 18 04 11 12 1B 1E ; "*2 PLAYERS 2"
1148: 1B 02 0E 08 0D 12                   ; " COINS"

DrawShiftedSprite:
; Part II: same as the original but CnvtPixNumber is called here instead of the caller.
114E: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert pixel number to screen/shift
1151: C5              PUSH    B                   ; Hold count
1152: E5              PUSH    H                   ; Hold start coordinate
1153: 1A              LDAX    D                   ; Get the picture bits
1154: D3 04           OUT     0x04                ; {hard.SHFT_DATA} Store in shift register
1156: DB 03           IN      0x03                ; {hard.SHFT_IN} Read the shifted pixels
1158: B6              ORA     M                   ; OR them onto the screen
1159: 77              MOV     M,A                 ; Store them back to screen
115A: 23              INX     H                   ; Next colummn on screen
115B: 13              INX     D                   ; Next in picture
115C: AF              XRA     A                   ; Shift over ...
115D: D3 04           OUT     0x04                ; {hard.SHFT_DATA} ... to next byte in register (shift in 0)
115F: DB 03           IN      0x03                ; {hard.SHFT_IN} Read the shifted pixels
1161: B6              ORA     M                   ; OR them onto the screen
1162: 77              MOV     M,A                 ; Store them back to screen
1163: E1              POP     H                   ; Restore starting coordinate
1164: 01 20 00        LXI     B,0x0020            ; Add 32 ...
1167: 09              DAD     B                   ; ... to coordinate (move to next row)
1168: C1              POP     B                   ; Restore count
1169: 05              DCR     B                   ; All done?
116A: C2 51 11        JNZ     0x1151              ; {} No ... go do all rows
116D: C9              RET                         ; Done

EraseSimpleSprite:
; Clear a sprite from the screen (standard pixel number descriptor).
; ** We clear 2 bytes even though the draw-simple only draws one.
116E: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert pixel number in HL

ClearRows:
1171: C5              PUSH    B                   ; Hold
1172: E5              PUSH    H                   ; Hold
1173: AF              XRA     A                   ; 0
1174: 77              MOV     M,A                 ; Clear screen byte
1175: 23              INX     H                   ; Next byte
1176: 77              MOV     M,A                 ; Clear byte
1177: 23              INX     H                   ; ** Is this to mimic timing? We increment then pop
1178: E1              POP     H                   ; Restore screen coordinate
1179: 01 20 00        LXI     B,0x0020            ; Add 1 row ...
117C: 09              DAD     B                   ; ... to screen coordinate
117D: C1              POP     B                   ; Restore counter
117E: 05              DCR     B                   ; All rows done?
117F: C2 71 11        JNZ     0x1171              ; {} Do all rows
1182: C9              RET                         ; out

DrawSimpSprite:
; Display character to screen
; HL = screen coordinates
; DE = character data
; B = number of rows
1183: C5              PUSH    B                   ; Preserve counter
1184: 1A              LDAX    D                   ; From character set ...
1185: 77              MOV     M,A                 ; ... to screen
1186: 13              INX     D                   ; Next in character set
1187: 01 20 00        LXI     B,0x0020            ; Next row ...
118A: 09              DAD     B                   ; ... on screen
118B: C1              POP     B                   ; Restore counter
118C: 05              DCR     B                   ; Decrement counter
118D: C2 83 11        JNZ     0x1183              ; {code.DrawSimpSprite} Do all
1190: C9              RET                         ; Out

AShotReloadRate:
; Part II looks up the alien shot reload rate from the score's thousands/hundreds digits.
1191: CD 8A 10        CALL    0x108A              ; {code.ScoreHundreds} Score digits
1194: C3 3F 15        JMP     0x153F              ; {} Look them up in the table (the rest is the original routine)

EraseShifted:
; Erases a shifted sprite from screen (like for player's explosion)
1197: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert pixel number in HL to coorinates with shift
119A: C5              PUSH    B                   ; Hold BC
119B: E5              PUSH    H                   ; Hold coordinate
119C: 1A              LDAX    D                   ; Get picture value
119D: D3 04           OUT     0x04                ; {hard.SHFT_DATA} Value into shift register
119F: DB 03           IN      0x03                ; {hard.SHFT_IN} Read shifted sprite picture
11A1: 2F              CMA                         ; Reverse it (erasing bits)
11A2: A6              ANA     M                   ; Erase the bits from the screen
11A3: 77              MOV     M,A                 ; Store the erased pattern back
11A4: 23              INX     H                   ; Next column on screen
11A5: 13              INX     D                   ; Next in image
11A6: AF              XRA     A                   ; Shift register over ...
11A7: D3 04           OUT     0x04                ; {hard.SHFT_DATA} ... 8 bits (shift in 0)
11A9: DB 03           IN      0x03                ; {hard.SHFT_IN} Read 2nd byte of image
11AB: 2F              CMA                         ; Reverse it (erasing bits)
11AC: A6              ANA     M                   ; Erase the bits from the screen
11AD: 77              MOV     M,A                 ; Store the erased pattern back
11AE: E1              POP     H                   ; Restore starting coordinate
11AF: 01 20 00        LXI     B,0x0020            ; Add 32 ...
11B2: 09              DAD     B                   ; ... to next row
11B3: C1              POP     B                   ; Restore BC (count)
11B4: 05              DCR     B                   ; All rows done?
11B5: C2 9A 11        JNZ     0x119A              ; {} No ... erase all
11B8: C9              RET                         ; Done

CnvtPixNumber:
11B9: 7D              MOV     A,L                 ; Get X coordinate
11BA: E6 07           ANI     0x07                ; Shift by pixel position
11BC: D3 02           OUT     0x02                ; {hard.SHFTAMNT} Write shift amount to hardware
11BE: C3 C7 17        JMP     0x17C7              ; {code.ConvToScr} HL = HL/8 + 2000 (screen coordinate)

RememberShields:
; In a multi-player game the player's shields are block-copied to and from RAM between turns.
; HL = screen pointer
; DE = memory buffer
; B = number of rows
; C = number of columns
11C1: C5              PUSH    B                   ; Hold counter
11C2: E5              PUSH    H                   ; Hold start
11C3: 7E              MOV     A,M                 ; From sprite ... (should be DE)
11C4: 12              STAX    D                   ; ... to screen ... (should be HL)
11C5: 13              INX     D                   ; Next in sprite
11C6: 23              INX     H                   ; Next on screen
11C7: 0D              DCR     C                   ; All columns done?
11C8: C2 C3 11        JNZ     0x11C3              ; {} No ... do multi columns
11CB: E1              POP     H                   ; Restore screen start
11CC: 01 20 00        LXI     B,0x0020            ; Add 32 ...
11CF: 09              DAD     B                   ; ... to get to next row
11D0: C1              POP     B                   ; Pop the counters
11D1: 05              DCR     B                   ; All rows done?
11D2: C2 C1 11        JNZ     0x11C1              ; {code.RememberShields} No ... do multi rows
11D5: C9              RET                         ; Done

DrawSprCollision:
11D6: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert pixel number to coord and shift
11D9: AF              XRA     A                   ; Clear the ...
11DA: 32 61 20        STA     0x2061              ; {ram.collision} ... collision-detection flag
11DD: C5              PUSH    B                   ; Hold count
11DE: E5              PUSH    H                   ; Hold screen
11DF: 1A              LDAX    D                   ; Get byte
11E0: D3 04           OUT     0x04                ; {hard.SHFT_DATA} Write first byte to shift register
11E2: DB 03           IN      0x03                ; {hard.SHFT_IN} Read shifted pattern
11E4: F5              PUSH    PSW                 ; Hold the pattern
11E5: A6              ANA     M                   ; Any bits from pixel collide with bits on screen?
11E6: CA EE 11        JZ      0x11EE              ; {} No ... leave flag alone
11E9: 3E 01           MVI     A,0x01              ; Yes ... set ...
11EB: 32 61 20        STA     0x2061              ; {ram.collision} ... collision flag
11EE: F1              POP     PSW                 ; Restore the pixel pattern
11EF: B6              ORA     M                   ; OR it onto the screen
11F0: 77              MOV     M,A                 ; Store new screen value
11F1: 23              INX     H                   ; Next byte on screen
11F2: 13              INX     D                   ; Next in pixel pattern
11F3: AF              XRA     A                   ; Write zero ...
11F4: D3 04           OUT     0x04                ; {hard.SHFT_DATA} ... to shift register
11F6: DB 03           IN      0x03                ; {hard.SHFT_IN} Read 2nd half of shifted sprite
11F8: F5              PUSH    PSW                 ; Hold pattern
11F9: A6              ANA     M                   ; Any bits from pixel collide with bits on screen?
11FA: CA 02 12        JZ      0x1202              ; {} No ... leave flag alone
11FD: 3E 01           MVI     A,0x01              ; Yes ... set ...
11FF: 32 61 20        STA     0x2061              ; {ram.collision} ... collision flag
1202: F1              POP     PSW                 ; Restore the pixel pattern
1203: B6              ORA     M                   ; OR it onto the screen
1204: 77              MOV     M,A                 ; Store new screen pattern
1205: E1              POP     H                   ; Starting screen coordinate
1206: 01 20 00        LXI     B,0x0020            ; Add 32 ...
1209: 09              DAD     B                   ; ... to get to next row
120A: C1              POP     B                   ; Restore count
120B: 05              DCR     B                   ; All done?
120C: C2 DD 11        JNZ     0x11DD              ; {} No ... do all rows
120F: C9              RET                         ; Done

ClearSmallSprite:
1210: AF              XRA     A                   ; 0
1211: C5              PUSH    B                   ; Preserve BC
1212: 77              MOV     M,A                 ; Clear screen byte
1213: 01 20 00        LXI     B,0x0020            ; Bump HL ...
1216: 09              DAD     B                   ; ... one screen row
1217: C1              POP     B                   ; Restore
1218: 05              DCR     B                   ; All done?
1219: C2 11 12        JNZ     0x1211              ; {} No ... clear all
121C: C9              RET                         ; Done

PlayerShotHit:
; The player's shot hit something (or is being removed from play)
;
121D: 3A 25 20        LDA     0x2025              ; {ram.plyrShotStatus} Player shot flag
1220: FE 05           CPI     0x05                ; Alien explosion in progress?
1222: C8              RZ                          ; Yes ... ignore this function
1223: FE 02           CPI     0x02                ; Normal movement?
1225: C0              RNZ                         ; No ... out

;
1226: 3A 29 20        LDA     0x2029              ; {ram.obj1CoorYr} Get Yr coordinate of player shot
1229: FE D8           CPI     0xD8                ; Compare to 216 (40 from Top-rotated)
122B: 47              MOV     B,A                 ; Hold value for later
122C: D2 82 12        JNC     0x1282              ; {} Yr is within 40 from top initiate miss-explosion (shot flag 3)
122F: 3A 02 20        LDA     0x2002              ; {ram.alienIsExploding} Is an alien ...
1232: A7              ANA     A                   ; ... blowing up?
1233: C8              RZ                          ; No ... out

;
1234: 78              MOV     A,B                 ; Get original Yr coordinate back to A
1235: FE CE           CPI     0xCE                ; Compare to 206 (50 from rotated top)
1237: D2 D0 12        JNC     0x12D0              ; {code.ShotHitSaucer} Yr is within 50 from top? Yes ... saucer must be hit
123A: C6 06           ADI     0x06                ; Offset to coordinate for wider "explosion" picture
123C: 47              MOV     B,A                 ; Hold that
123D: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} Ref alien Y coordianate

; If the lower 4 rows are all empty then the reference alien's Y coordinate will wrap around from 0 to F8.
; At this point the top row of aliens is in the shields and we will assume that everything is within
; the rack.
1240: FE 90           CPI     0x90                ; This is true if ...
1242: D2 49 12        JNC     0x1249              ; {code.CodeBug1} ... aliens are down in the shields
1245: B8              CMP     B                   ; Compare to shot's coordinate
1246: D2 82 12        JNC     0x1282              ; {} Outside the rack-square ... do miss explosion

CodeBug1:
;
; We get here if the player's shot hit something within the rack area (a shot or an alien).
; Find the alien that is (or would be) where the shot hit. If there is no alien alive at the row/column
; thn the player hit an alien missile. If there is an alien then explode the alien.
;
; There is a code bug here, but it is extremely subtle. The algorithm for finding the row/column in the
; rack works by adding 16 to the reference coordinates (X for column, Y for row) until it passes or equals
; the target coordinates. This works great as long as the target point is within the alien's rack area.
; If the reference point is far to the right, the column number will be greater than 11, which messes
; up the column/row-to-pointer math.
;
; The entire rack of aliens is based on the lower left alien. Imagine all aliens are dead except the
; upper left. It wiggles down the screen and enters the players shields on the lower left where it begins
; to eat them. Imagine the player is under his own shields on the right side of the screen and fires a
; shot into his own shield.
;
; The alien is in the rack on row 4 (rows are numbered from bottom up starting with 0). The shot hits
; the shields below the alien's Y coordinate and gets correctly assigned to row 3. The alien is in the rack
; at column 0 (columns are numbered from left to right starting with 0). The shot hits the shields far to
; the right of the alien's X coordinate. The algorithm says it is in column 11. But 0-10 are the only
; correct values.
;
; The column/row-to-pointer math works by multiplying the row by 11 and adding the column. For the alien
; that is 11*4 + 0 = 44. For the shot that is 11*3 +11 = 44. The game thinks the shot hit the alien.
;
; PART II: this bug is fixed. After FindColumn the column count is checked (125D) and a
; shot that lands past the 11th column is treated as a miss.
1249: 68              MOV     L,B                 ; L now holds the shot coordinate (adjusted)
124A: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} Top of the rack ...
124D: C6 50           ADI     0x50                ; ... is 5 rows (50) above the reference alien
124F: BD              CMP     L                   ; Is the shot above the rack?
1250: DC CA 12        CC      0x12CA              ; {code.ShotHitDrop} Shot is above the rack ... it hit the falling alien
1253: CD B3 12        CALL    0x12B3              ; {code.FindRow} Look up row number to B
1256: 3A 2A 20        LDA     0x202A              ; {ram.obj1CoorXr} Player's shot's Xr coordinate ...
1259: 67              MOV     H,A                 ; ... to H
125A: CD C0 12        CALL    0x12C0              ; {code.FindColumn} Get alien's coordinate
125D: 79              MOV     A,C                 ; Part II fixes "CodeBug1" (see above): column ...
125E: FE 0C           CPI     0x0C                ; ... number past the 11th?
1260: D2 82 12        JNC     0x1282              ; {} Yes ... it can't be an alien
1263: 22 64 20        SHLD    0x2064              ; {ram.expAlienYr} Put it in the exploding-alien descriptor
1266: 3E 05           MVI     A,0x05              ; Flag alien explosion ...
1268: 32 25 20        STA     0x2025              ; {ram.plyrShotStatus} ... in progress
126B: CD 45 13        CALL    0x1345              ; {code.GetAlienStatPtr} Get descriptor for alien
126E: 7E              MOV     A,M                 ; Is alien ...
126F: A7              ANA     A                   ; ... alive
1270: CA 82 12        JZ      0x1282              ; {} No ... must have been an alien shot
1273: CD D8 12        CALL    0x12D8              ; {code.AlienHit} Kill (or split) the alien and score it
1276: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Load 5 byte sprite descriptor
1279: CD 96 13        CALL    0x1396              ; {code.DrawSprite} Draw explosion sprite on screen
127C: 3E 10           MVI     A,0x10              ; Initiate alien-explosion
127E: 32 03 20        STA     0x2003              ; {ram.expAlienTimer} ... timer to 16
1281: C9              RET                         ; Out

;
; Player shot leaving playfield, hitting shield, or hitting an alien shot
1282: 3E 03           MVI     A,0x03              ; Mark ...
1284: 32 25 20        STA     0x2025              ; {ram.plyrShotStatus} ... player shot hit something other than alien
1287: C3 9C 12        JMP     0x129C              ; {} Finish up

;
AExplodeTime:
; Time down the alien explosion. Remove when done.
128A: 21 03 20        LXI     H,0x2003            ; {ram.expAlienTimer} Decrement alien explosion ...
128D: 35              DCR     M                   ; ... timer
128E: C0              RNZ                         ; Not done  ... out
128F: 2A 64 20        LHLD    0x2064              ; {ram.expAlienYr} Pixel pointer for exploding alien
1292: 06 12           MVI     B,0x12              ; 18 rows (the split explosion is wider)
1294: CD 30 13        CALL    0x1330              ; {code.EraseAlienExp} Erase the explosion (or draw the two halves of a split alien)
1297: 3E 04           MVI     A,0x04              ; 4 means that ...
1299: 32 25 20        STA     0x2025              ; {ram.plyrShotStatus} ... alien has exploded (remove from active duty)

;
129C: AF              XRA     A                   ; Turn off ...
129D: 32 02 20        STA     0x2002              ; {ram.alienIsExploding} ... alien-is-blowing-up flag
12A0: 06 F7           MVI     B,0xF7              ; Turn off ...
12A2: C3 5C 17        JMP     0x175C              ; {code.SoundBits3Off} ... alien exploding sound

Cnt16s:
; Count number of 16s needed to bring reference (in A) up to target (in H).
; If the reference starts out beyond the target then we add 16s as long as
; the reference has a signed bit. But these aren't signed quantities. This
; doesn't make any sense. This counting algorithm produces questionable
; results if the reference is beyond the target.
;
12A5: 0E 00           MVI     C,0x00              ; Count of 16s
12A7: BC              CMP     H                   ; Compare reference coordinate to target
12A8: D4 54 13        CNC     0x1354              ; {code.WrapRef} If reference is greater or equal then do something questionable ... see below
12AB: BC              CMP     H                   ; Compare reference coordinate to target
12AC: D0              RNC                         ; If reference is greater or equal then done
12AD: C6 10           ADI     0x10                ; Add 16 to reference
12AF: 0C              INR     C                   ; Bump 16s count
12B0: C3 AB 12        JMP     0x12AB              ; {} Keep testing

FindRow:
; L contains a Yr coordinate. Find the row number within the rack that corresponds
; to the Yr coordinate. Return the row coordinate in L and the row number in C.
;
12B3: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} Reference alien Yr coordinate
12B6: 65              MOV     H,L                 ; Target Yr coordinate to H
12B7: CD A5 12        CALL    0x12A5              ; {code.Cnt16s} Count 16s needed to bring ref alien to target
12BA: 41              MOV     B,C                 ; Count to B
12BB: 05              DCR     B                   ; Base 0
12BC: DE 10           SBI     0x10                ; The counting also adds 16 no matter what
12BE: 6F              MOV     L,A                 ; To coordinate
12BF: C9              RET                         ; Done

FindColumn:
; H contains a Xr coordinate. Find the column number within the rack that corresponds
; to the Xr coordinate. Return the column coordinate in H and the column number in C.
;
12C0: 3A 0A 20        LDA     0x200A              ; {ram.refAlienXr} Reference alien Yn coordinate
12C3: CD A5 12        CALL    0x12A5              ; {code.Cnt16s} Count 16s to bring Y to target Y
12C6: DE 10           SBI     0x10                ; Subtract off extra 16
12C8: 67              MOV     H,A                 ; To H
12C9: C9              RET                         ; Done

ShotHitDrop:
12CA: 3E 01           MVI     A,0x01              ; Flag the ...
12CC: 32 AD 20        STA     0x20AD              ; {ram.dropHit} ... falling alien as hit
12CF: C9              RET                         ; Done

ShotHitSaucer:
12D0: 3E 01           MVI     A,0x01              ; Mark flying ...
12D2: 32 85 20        STA     0x2085              ; {ram.saucerHit} ... saucer has been hit
12D5: C3 97 12        JMP     0x1297              ; {} Remove player shot

AlienHit:
; Part II: the alien's type comes from its status byte. A crab (3) hit in round 3 or later
; splits into two small aliens (7) in its slot and the slot to its right. The explosion
; picture is then the 32-column "split" image at 1AE0.
12D8: 7E              MOV     A,M                 ; Alien status (type)
12D9: 32 DB 20        STA     0x20DB              ; {ram.lastAlienType} Remember the type for the intermission
12DC: 06 05           MVI     B,0x05              ; Default score type 5 (squid, 30 points)
12DE: 36 00           MVI     M,0x00              ; Kill the alien
12E0: E5              PUSH    H                   ; Hold alien pointer
12E1: 21 62 20        LXI     H,0x2062            ; {ram.expAlienLSB} Exploding-alien descriptor
12E4: 36 C2           MVI     M,0xC2              ; Picture LSB
12E6: 23              INX     H                   ; Next
12E7: 36 1C           MVI     M,0x1C              ; ... 1CC2 (normal explosion)
12E9: 23              INX     H                   ; ...
12EA: 23              INX     H                   ; ...
12EB: 23              INX     H                   ; Size ...
12EC: 36 10           MVI     M,0x10              ; ... 16
12EE: E1              POP     H                   ; Restore pointer
12EF: FE 01           CPI     0x01                ; Octopus?
12F1: CC 01 13        CZ      0x1301              ; {} Yes ... 10 points
12F4: FE 03           CPI     0x03                ; Crab?
12F6: CC 07 13        CZ      0x1307              ; {code.CrabHit} Yes ... 20 points (or split)
12F9: FE 07           CPI     0x07                ; Small (split) alien?
12FB: CC 04 13        CZ      0x1304              ; {} Yes ... 30 points
12FE: C3 64 0C        JMP     0x0C64              ; {code.ScoreForAlien} Explosion sound and score
1301: 06 01           MVI     B,0x01              ; Octopus
1303: C9              RET                         ; Done
1304: 06 07           MVI     B,0x07              ; Small alien
1306: C9              RET                         ; Done

CrabHit:
1307: E5              PUSH    H                   ; Hold pointer
1308: F5              PUSH    PSW                 ; Hold type
1309: CD F9 07        CALL    0x07F9              ; {code.GetRoundNum} Round number
130C: FE 03           CPI     0x03                ; Round 3 or later?
130E: D2 27 13        JNC     0x1327              ; {} Yes ... split the crab
1311: F1              POP     PSW                 ; Restore type
1312: E1              POP     H                   ; Restore pointer
1313: 06 03           MVI     B,0x03              ; Crab score
1315: C9              RET                         ; Done
1316: 23              INX     H                   ; The slot to the right ...
1317: 36 07           MVI     M,0x07              ; ... becomes a small alien too
1319: 21 62 20        LXI     H,0x2062            ; {ram.expAlienLSB} Exploding-alien descriptor
131C: 36 E0           MVI     M,0xE0              ; Picture LSB
131E: 23              INX     H                   ; Next
131F: 36 1A           MVI     M,0x1A              ; ... 1AE0 (crab splitting into two)
1321: 23              INX     H                   ; ...
1322: 23              INX     H                   ; ...
1323: 23              INX     H                   ; Size ...
1324: 36 20           MVI     M,0x20              ; ... 32
1326: C9              RET                         ; Done
1327: F1              POP     PSW                 ; Restore type
1328: E1              POP     H                   ; Restore pointer
1329: 36 07           MVI     M,0x07              ; This slot becomes a small alien
132B: 06 03           MVI     B,0x03              ; Crab score
132D: C3 16 13        JMP     0x1316              ; {} Fill the slot to the right and set the split picture

EraseAlienExp:
; At the end of an alien explosion erase it. For a split crab draw the two small aliens.
1330: 3A 62 20        LDA     0x2062              ; {ram.expAlienLSB} Exploding-alien picture LSB
1333: FE C2           CPI     0xC2                ; Normal explosion?
1335: CA 6E 11        JZ      0x116E              ; {code.EraseSimpleSprite} Yes ... erase it
1338: 11 31 1C        LXI     D,0x1C31            ; Small-alien picture
133B: D5              PUSH    D                   ; Hold it
133C: CD 96 13        CALL    0x1396              ; {code.DrawSprite} Draw the left small alien (B=18 rows)
133F: D1              POP     D                   ; Picture again
1340: 06 10           MVI     B,0x10              ; 16 rows
1342: C3 99 13        JMP     0x1399              ; {} Draw the right small alien and out

GetAlienStatPtr:
; B is row number. C is column number (starts at 1).
; Return pointer to alien-status flag for current player.
1345: 78              MOV     A,B                 ; Hold original
1346: 07              RLC                         ; *2
1347: 07              RLC                         ; *4
1348: 07              RLC                         ; *8
1349: 80              ADD     B                   ; *9
134A: 80              ADD     B                   ; *10
134B: 80              ADD     B                   ; *11
134C: 81              ADD     C                   ; Add row offset to column offset
134D: 3D              DCR     A                   ; -1
134E: 6F              MOV     L,A                 ; Set LSB of HL
134F: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Set ...
1352: 67              MOV     H,A                 ; ... MSB of HL with active player indicator
1353: C9              RET                         ; Done

WrapRef:
; This is called if the reference point is greater than the target point. I believe the goal is to
; wrap the reference back around until it is lower than the target point. But the algorithm simply adds
; until the sign bit of the the reference is 0. If the target is 2 and the reference is 238 then this
; algorithm moves the reference 238+16=244 then 244+16=4. Then the algorithm stops. But the reference is
; STILL greater than the target.
;
; Also imagine that the target is 20 and the reference is 40. The algorithm adds 40+16=56, which is not
; negative, so it stops there.
;
; I think the intended code is "JP NC" instead of "JP M", but even that doesn't make sense.
;
1354: 0C              INR     C                   ; Increase 16s count
1355: C6 10           ADI     0x10                ; Add 16 to ref
1357: FA 54 13        JM      0x1354              ; {code.WrapRef} Keep going till result is positive
135A: C9              RET                         ; Out

RackBump:
; When rack bumps the edge of the screen then the direction flips and the rack
; drops 8 pixels. The deltaX and deltaY values are changed here. Interestingly
; if there is only one alien left then the right value is 3 instead of the
; usual 2. The left direction is always -2.
135B: 3A 0D 20        LDA     0x200D              ; {ram.rackDirection} Get rack direction
135E: A7              ANA     A                   ; Moving right?
135F: C2 7B 13        JNZ     0x137B              ; {} No ... handle moving left

;
1362: 21 A4 3E        LXI     H,0x3EA4            ; Line down the right edge of playfield
1365: CD 89 13        CALL    0x1389              ; {} Check line down the edge
1368: D0              RNC                         ; Nothing is there ... return
1369: 06 FE           MVI     B,0xFE              ; Delta X of -2
136B: 3E 01           MVI     A,0x01              ; Rack now moving right

;
136D: 32 0D 20        STA     0x200D              ; {ram.rackDirection} Set new rack direction
1370: 78              MOV     A,B                 ; B has delta X
1371: 32 08 20        STA     0x2008              ; {ram.refAlienDXr} Set new delta X
1374: 3A 0E 20        LDA     0x200E              ; {ram.rackDownDelta} Set delta Y ...
1377: 32 07 20        STA     0x2007              ; {ram.refAlienDYr} ... to drop rack by 8
137A: C9              RET                         ; Done

;
137B: 21 24 25        LXI     H,0x2524            ; Line down the left edge of playfield
137E: CD 89 13        CALL    0x1389              ; {} Check line down the edge
1381: D0              RNC                         ; Nothing is there ... return
1382: CD AF 16        CALL    0x16AF              ; {} Get moving-right delta X value of 2 (3 if just one alien left)
1385: AF              XRA     A                   ; Rack now moving left
1386: C3 6D 13        JMP     0x136D              ; {} Set rack direction

;
1389: 06 17           MVI     B,0x17              ; Checking 23 bytes in a line up the screen from near the bottom
138B: 7E              MOV     A,M                 ; Get screen memory
138C: A7              ANA     A                   ; Is screen memory empty?
138D: C2 51 14        JNZ     0x1451              ; {} No ... set carry flag and out
1390: 23              INX     H                   ; Next byte on screen
1391: 05              DCR     B                   ; All column done?
1392: C2 8B 13        JNZ     0x138B              ; {} No ... keep looking
1395: C9              RET                         ; Return with carry flag clear

DrawSprite:
1396: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert pixel number to screen/shift
1399: 00              NOP                         ; (Space where the original saved HL)
139A: C5              PUSH    B                   ; Hold for a second
139B: E5              PUSH    H                   ; Hold for a second
139C: 1A              LDAX    D                   ; From sprite data
139D: D3 04           OUT     0x04                ; {hard.SHFT_DATA} Write data to shift register
139F: DB 03           IN      0x03                ; {hard.SHFT_IN} Read back shifted amount
13A1: 77              MOV     M,A                 ; Shifted sprite to screen
13A2: 23              INX     H                   ; Adjacent cell
13A3: 13              INX     D                   ; Next in sprite data
13A4: AF              XRA     A                   ; 0
13A5: D3 04           OUT     0x04                ; {hard.SHFT_DATA} Write 0 to shift register
13A7: DB 03           IN      0x03                ; {hard.SHFT_IN} Read back remainder of previous
13A9: 77              MOV     M,A                 ; Write remainder to adjacent
13AA: E1              POP     H                   ; Old screen coordinate
13AB: 01 20 00        LXI     B,0x0020            ; Offset screen ...
13AE: 09              DAD     B                   ; ... to next row
13AF: C1              POP     B                   ; Restore count
13B0: 05              DCR     B                   ; All done?
13B1: C2 9A 13        JNZ     0x139A              ; {} No ... do all
13B4: C9              RET                         ; Done

CountAliens:
; Count number of aliens remaining in active game and return count 2082 holds the current count.
; If only 1, 206B gets a flag of 1 ** but ever nobody checks this
13B5: CD F7 13        CALL    0x13F7              ; {code.GetPlayerDataPtr} Get active player descriptor
13B8: 01 00 37        LXI     B,0x3700            ; B=55 aliens to check?
13BB: 7E              MOV     A,M                 ; Get byte
13BC: A7              ANA     A                   ; Is it a zero?
13BD: CA C1 13        JZ      0x13C1              ; {} Yes ... don't count it
13C0: 0C              INR     C                   ; Count the live aliens
13C1: 23              INX     H                   ; Next alien
13C2: 05              DCR     B                   ; Count ...
13C3: C2 BB 13        JNZ     0x13BB              ; {} ... all alien indicators
13C6: 79              MOV     A,C                 ; Get the count
13C7: 32 82 20        STA     0x2082              ; {ram.numAliens} Hold it
13CA: FE 01           CPI     0x01                ; Just one?
13CC: C0              RNZ                         ; No keep going
13CD: 21 6B 20        LXI     H,0x206B            ; {ram.oneAlien} Set flag if ...
13D0: 36 01           MVI     M,0x01              ; ... only one alien left
13D2: CD F7 13        CALL    0x13F7              ; {code.GetPlayerDataPtr} Part II: check for the last-alien bonus. Point to alien 0 (bottom left)
13D5: 7E              MOV     A,M                 ; Is the bottom-left alien ...
13D6: A7              ANA     A                   ; ... the one left?
13D7: C2 77 46        JNZ     0x4677              ; {code.Bonus1000} Yes ... 1000 point bonus when it is shot
13DA: 06 16           MVI     B,0x16              ; Look through the bottom two rows (22 aliens)
13DC: 7E              MOV     A,M                 ; Is this ...
13DD: A7              ANA     A                   ; ... the live one?
13DE: C2 E7 13        JNZ     0x13E7              ; {} Yes ... check it
13E1: 23              INX     H                   ; Next alien
13E2: 05              DCR     B                   ; All 22 checked?
13E3: C2 DC 13        JNZ     0x13DC              ; {} No ... keep looking
13E6: C9              RET                         ; Not in the bottom two rows ... no bonus
13E7: FE 01           CPI     0x01                ; Must be an octopus (10 points)
13E9: C0              RNZ                         ; No ... no bonus
13EA: 2E 05           MVI     L,0x05              ; Bottom-row middle alien (index 5)
13EC: 7E              MOV     A,M                 ; Is it ...
13ED: A7              ANA     A                   ; ... the one left?
13EE: C4 7E 46        CNZ     0x467E              ; {code.Bonus800} Yes ... 800 point bonus
13F1: 3E 01           MVI     A,0x01              ; Flag ...
13F3: 32 AE 20        STA     0x20AE              ; {ram.lastAlienBonus} ... a bonus for the last alien (500 unless 800/1000 were flagged)
13F6: C9              RET                         ; Done

GetPlayerDataPtr:
; Set HL with 2100 if player 1 is active or 2200 if player 2 is active
;
13F7: 2E 00           MVI     L,0x00              ; Byte boundary

GetPlayerDataPage:
; H = active player's data page (21 or 22). L is left alone.
13F9: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Active player number
13FC: 67              MOV     H,A                 ; Set HL to data
13FD: C9              RET                         ; Done

PlrFireOrDemo:
; Initiate player fire if button is pressed.
; Demo commands are parsed here if in demo mode
13FE: 3A 15 20        LDA     0x2015              ; {ram.playerAlive} Is there an active player?
1401: FE FF           CPI     0xFF                ; FF = alive
1403: C0              RNZ                         ; Player has been shot - no firing
1404: 21 10 20        LXI     H,0x2010            ; {ram.obj0TimerMSB} Get player ...
1407: 7E              MOV     A,M                 ; ... task ...
1408: 23              INX     H                   ; ... timer ...
1409: 46              MOV     B,M                 ; ... value
140A: B0              ORA     B                   ; Is the timer 0 (object active)?
140B: C0              RNZ                         ; No ... no firing till player object starts
140C: 3A 25 20        LDA     0x2025              ; {ram.plyrShotStatus} Does the player have ...
140F: A7              ANA     A                   ; ... a shot on the screen?
1410: C0              RNZ                         ; Yes ... ignore
1411: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Are we in ...
1414: A7              ANA     A                   ; ... game mode?
1415: CA 38 14        JZ      0x1438              ; {} No ... in demo mode ... constant firing in demo
1418: 3A 2D 20        LDA     0x202D              ; {ram.fireBounce} Is fire button ...
141B: A7              ANA     A                   ; ... being held down?
141C: C2 2E 14        JNZ     0x142E              ; {} Yes ... wait for bounce
141F: CD E8 15        CALL    0x15E8              ; {code.ReadInputs} Read active player controls
1422: E6 10           ANI     0x10                ; Fire-button pressed?
1424: C8              RZ                          ; No ... out
1425: 3E 01           MVI     A,0x01              ; Flag
1427: 32 25 20        STA     0x2025              ; {ram.plyrShotStatus} Flag shot active
142A: 32 2D 20        STA     0x202D              ; {ram.fireBounce} Flag that fire button is down
142D: C9              RET                         ; Out
142E: CD E8 15        CALL    0x15E8              ; {code.ReadInputs} Read active player controls
1431: E6 10           ANI     0x10                ; Fire-button pressed?
1433: C0              RNZ                         ; Yes ... ignore
1434: 32 2D 20        STA     0x202D              ; {ram.fireBounce} Else ... clear flag
1437: C9              RET                         ; Out

; Handle demo (constant fire, parse demo commands)
1438: 21 25 20        LXI     H,0x2025            ; {ram.plyrShotStatus} Demo fires ...
143B: 36 01           MVI     M,0x01              ; ... constantly
143D: 2A ED 20        LHLD    0x20ED              ; {ram.demoCmdPtrLSB} Demo command bufer
1440: 23              INX     H                   ; Next position
1441: 7D              MOV     A,L                 ; Command buffer ...
1442: FE CA           CPI     0xCA                ; Past the end of the demo commands (1ABF-1AC9)?
1444: DA 49 14        JC      0x1449              ; {}
1447: 2E BF           MVI     L,0xBF              ; Wrap back to the start (1ABF)
1449: 22 ED 20        SHLD    0x20ED              ; {ram.demoCmdPtrLSB} Next demo command
144C: 7E              MOV     A,M                 ; Get next command
144D: 32 1D 20        STA     0x201D              ; {ram.nextDemoCmd} Set command for movement
1450: C9              RET                         ; Done
1451: 37              STC                         ; Set carry flag
1452: C9              RET                         ; Done
1453: AF              XRA     A                   ; 0
1454: CD 0B 18        CALL    0x180B              ; {} Print ZERO ships remain
1457: CD CE 16        CALL    0x16CE              ; {code.CurPlyAlive} Get active-flag ptr for current player
145A: 36 00           MVI     M,0x00              ; Flag player is dead
145C: CD 97 0B        CALL    0x0B97              ; {} Get score descriptor for current player
145F: 23              INX     H                   ; Point to high two digits
1460: 11 F5 20        LXI     D,0x20F5            ; {ram.HiScorM} Current high score upper two digits
1463: 1A              LDAX    D                   ; Is player score greater ...
1464: BE              CMP     M                   ; ... than high score?
1465: 1B              DCX     D                   ; Point to LSB
1466: 2B              DCX     H                   ; Point to LSB
1467: 1A              LDAX    D                   ; Go ahead and fetch high score lower two digits
1468: CA 71 14        JZ      0x1471              ; {} Upper two are the same ... have to check lower two
146B: D2 81 14        JNC     0x1481              ; {} Player score is lower than high ... nothing to do
146E: C3 75 14        JMP     0x1475              ; {} Player socre is higher ... go copy the new high score

;
1471: BE              CMP     M                   ; Is lower digit higher? (upper was the same)
1472: D2 81 14        JNC     0x1481              ; {} No ... high score is still greater than player's score
1475: 7E              MOV     A,M                 ; Copy the new ...
1476: 12              STAX    D                   ; ... high score lower two digits
1477: 13              INX     D                   ; Point to MSB
1478: 23              INX     H                   ; Point to MSB
1479: 7E              MOV     A,M                 ; Copy the new ...
147A: 12              STAX    D                   ; ... high score upper two digits
147B: CD 10 17        CALL    0x1710              ; {code.PrintHiScore} Draw the new high score
147E: CD B2 14        CALL    0x14B2              ; {code.NewHiScore} Clear the old name and flag a name entry for this player
1481: 3A CE 20        LDA     0x20CE              ; {ram.twoPlayers} Number of players
1484: A7              ANA     A                   ; Is this a single player game?
1485: CA F2 14        JZ      0x14F2              ; {code.GameOverMsg} Yes ... short message
1488: 21 03 28        LXI     H,0x2803            ; Screen coordinates
148B: 11 24 18        LXI     D,0x1824            ; "GAME OVER PLAYER< >"
148E: 0E 14           MVI     C,0x14              ; 20 characters
1490: CD 85 0C        CALL    0x0C85              ; {code.PrintMessageDel} Print message
1493: 25              DCR     H                   ; Back up ...
1494: 25              DCR     H                   ; ... to player indicator
1495: 06 1D           MVI     B,0x1D              ; Character "1"
1497: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB}
149A: 0F              RRC                         ; Is this player 1?
149B: DA A0 14        JC      0x14A0              ; {} Yes ... keep the digit
149E: 06 1E           MVI     B,0x1E              ; Else ... character "2"
14A0: 78              MOV     A,B                 ; To A
14A1: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Print player number
14A4: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Short delay
14A7: CD A5 16        CALL    0x16A5              ; {} Get current player "alive" flag
14AA: 7E              MOV     A,M                 ; Is player ...
14AB: A7              ANA     A                   ; ... alive?
14AC: CA F2 14        JZ      0x14F2              ; {code.GameOverMsg} No ... skip to "GAME OVER" sequence
14AF: C3 36 03        JMP     0x0336              ; {} Switch players and game loop

NewHiScore:
14B2: CD E4 14        CALL    0x14E4              ; {code.ClearHiName} Erase the old name and blank the buffer
14B5: 21 E0 20        LXI     H,0x20E0            ; {ram.namePending} Flag a ...
14B8: 36 01           MVI     M,0x01              ; ... name entry at game over
14BA: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Which player?
14BD: FE 21           CPI     0x21                ; Player 1?
14BF: C2 C6 14        JNZ     0x14C6              ; {} No
14C2: 23              INX     H                   ; 20E1 ...
14C3: 36 00           MVI     M,0x00              ; ... = 00 (player 1 controls, screen not flipped)
14C5: C9              RET                         ; Done
14C6: 23              INX     H                   ; 20E1 ...
14C7: 36 20           MVI     M,0x20              ; ... = 20 (player 2 controls, screen flipped in a cocktail cabinet)
14C9: C9              RET                         ; Done

DoNameEntry:
14CA: 21 E0 20        LXI     H,0x20E0            ; {ram.namePending} Is there ...
14CD: 7E              MOV     A,M                 ; ... a name ...
14CE: A7              ANA     A                   ; ... to enter?
14CF: C8              RZ                          ; No ... done
14D0: 23              INX     H                   ; 20E1
14D1: E5              PUSH    H                   ; Hold pointer
14D2: 46              MOV     B,M                 ; Cocktail bit for the player
14D3: CD FD 00        CALL    0x00FD              ; {code.SetFlipDelay} Flip the screen for player 2 (cocktail)
14D6: CD FA 0D        CALL    0x0DFA              ; {code.NameEntry} HI-SCORER REGISTRATION
14D9: E1              POP     H                   ; Restore pointer
14DA: 36 FF           MVI     M,0xFF              ; 20E1=FF
14DC: 2B              DCX     H                   ; Back to 20E0
14DD: 36 00           MVI     M,0x00              ; No name pending
14DF: 06 00           MVI     B,0x00              ; Screen back to normal
14E1: C3 FD 00        JMP     0x00FD              ; {code.SetFlipDelay} Set it and out

ClearHiName:
14E4: CD 28 10        CALL    0x1028              ; {code.EraseHiName} Erase the name on screen
14E7: 06 0A           MVI     B,0x0A              ; 10 bytes
14E9: 11 65 10        LXI     D,0x1065            ; Spaces
14EC: 21 40 23        LXI     H,0x2340            ; {ram.hiName} Name buffer
14EF: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} Blank the name

GameOverMsg:
14F2: 21 18 2D        LXI     H,0x2D18            ; Screen coordinates
14F5: 11 24 18        LXI     D,0x1824            ; "GAME OVER PLAYER< >"
14F8: 0E 0A           MVI     C,0x0A              ; Just the "GAME OVER" part
14FA: CD 85 0C        CALL    0x0C85              ; {code.PrintMessageDel} Print message
14FD: CD A2 0C        CALL    0x0CA2              ; {code.TwoSecDelay} Long delay
1500: CD CA 14        CALL    0x14CA              ; {code.DoNameEntry} Name entry if the high score was beaten
1503: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear center window
1506: AF              XRA     A                   ; Now in ...
1507: 32 EF 20        STA     0x20EF              ; {ram.gameMode} ... demo mode
150A: D3 05           OUT     0x05                ; {hard.SOUND2} All sound off
150C: CD 52 17        CALL    0x1752              ; {code.EnableGameTasks} Enable ISR game tasks
150F: C3 32 0D        JMP     0x0D32              ; {} Print credit information and do splash

PlayerHit:
1512: 31 00 24        LXI     SP,0x2400           ; Reset stack
1515: FB              EI                          ; Enable interrupts
1516: AF              XRA     A                   ; Flag ...
1517: 32 15 20        STA     0x2015              ; {ram.playerAlive} ... player is shot
151A: CD 1D 12        CALL    0x121D              ; {code.PlayerShotHit} Player's shot collision detection
151D: 06 04           MVI     B,0x04              ; Player has been hit ...
151F: CD B8 16        CALL    0x16B8              ; {code.SoundBits3On} ... sound
1522: CD 5E 0C        CALL    0x0C5E              ; {} Has flag been set?
1525: C2 1A 15        JNZ     0x151A              ; {} No ... wait for the flag
1528: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks} Disable ISR game tasks
152B: 21 01 27        LXI     H,0x2701            ; Player's stash of ships
152E: CD 7A 17        CALL    0x177A              ; {} Erase the stash of shps
1531: AF              XRA     A                   ; Print ...
1532: CD 0B 18        CALL    0x180B              ; {} ... a zero (number of ships)
1535: 06 FB           MVI     B,0xFB              ; Turn off ...
1537: C3 31 17        JMP     0x1731              ; {} ... player shot sound
153A: CD 97 0B 23 7E
153F: 11 BA 1C        LXI     D,0x1CBA            ; Score MSB table
1542: 21 1F 18        LXI     H,0x181F            ; Corresponding fire reload rate table
1545: 0E 04           MVI     C,0x04              ; Only 4 entries (a 5th value of 7 is used after that)
1547: 47              MOV     B,A                 ; Hold the score value
1548: 1A              LDAX    D                   ; Get lookup from table
1549: B8              CMP     B                   ; Compare them
154A: D2 53 15        JNC     0x1553              ; {} Equal or below ... use this table entry
154D: 23              INX     H                   ; Next ...
154E: 13              INX     D                   ; ... entry in table
154F: 0D              DCR     C                   ; Do all ...
1550: C2 48 15        JNZ     0x1548              ; {} ... 4 entries in the tables
1553: 7E              MOV     A,M                 ; Load the shot reload value
1554: 32 CF 20        STA     0x20CF              ; {ram.aShotReloadRate} Save the value for use in shot routine
1557: C9              RET                         ; Done

; Shot sound on or off depending on 2025
ShotSound:
1558: 3A 25 20        LDA     0x2025              ; {ram.plyrShotStatus} Player shot flag
155B: A7              ANA     A                   ; Is the shot ...
155C: C2 64 15        JNZ     0x1564              ; {} Yes ... go
155F: 06 FD           MVI     B,0xFD              ; Sound mask
1561: C3 5C 17        JMP     0x175C              ; {code.SoundBits3Off} Mask off sound

;
1564: 06 02           MVI     B,0x02              ; Sound bit
1566: C3 B8 16        JMP     0x16B8              ; {code.SoundBits3On} OR on sound

TimeFleetSound:
; This called from the ISR times down the fleet and sets the flag at 2095 if
; the fleet needs a change in sound handling (new delay, new sound)
1569: 21 9B 20        LXI     H,0x209B            ; {ram.fleetSndHold} Pointer to hold time for fleet
156C: 35              DCR     M                   ; Decrement hold time
156D: CC 96 15        CZ      0x1596              ; {} If 0 turn fleet movement sound off
1570: 3A 68 20        LDA     0x2068              ; {ram.playerOK} Is player OK?
1573: A7              ANA     A                   ; 1  means OK
1574: CA 96 15        JZ      0x1596              ; {} Player not OK ... fleet movement sound off and out
1577: 21 96 20        LXI     H,0x2096            ; {ram.fleetSndCnt} Current time on fleet sound
157A: 35              DCR     M                   ; Count down
157B: C0              RNZ                         ; Not time to change sound ... out
157C: 21 98 20        LXI     H,0x2098            ; {ram.soundPort5} Current sound port 3 value
157F: 7E              MOV     A,M                 ; Get value
1580: D3 05           OUT     0x05                ; {hard.SOUND2} Set sounds
1582: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens on active screen
1585: A7              ANA     A                   ; Is it zero?
1586: CA 96 15        JZ      0x1596              ; {} Yes ... turn off fleet movement sound and out
1589: 2B              DCX     H                   ; (2097) Point to fleet timer reload
158A: 7E              MOV     A,M                 ; Get fleet delay value
158B: 2B              DCX     H                   ; (2096) Point to fleet timer
158C: 77              MOV     M,A                 ; Reload the timer
158D: 2B              DCX     H                   ; Point to change-sound
158E: 36 01           MVI     M,0x01              ; (2095) time to change sound
1590: 3E 04           MVI     A,0x04              ; Set hold ...
1592: 32 9B 20        STA     0x209B              ; {ram.fleetSndHold} ... time for fleet sound
1595: C9              RET                         ; Done
1596: 3A 98 20        LDA     0x2098              ; {ram.soundPort5} Current sound port 3 value
1599: E6 30           ANI     0x30                ; Mask off fleet movement sounds
159B: D3 05           OUT     0x05                ; {hard.SOUND2} Set sounds
159D: C9              RET                         ; Out

FleetDelayExShip:
; This game-loop routine handles two sound functions. The routine does:
; 1) Time out the extra-ship awarded sound and turn it off when done
; 2) Load the fleet sound delay based on number of remaining aliens
; 3) Make the changing fleet sound
;
; The 2095 flag is set by the ISR and cleared here. The ISR does the timing and sets 2095 when it
; is time to make a new fleet sound.
;
159E: 3A 95 20        LDA     0x2095              ; {ram.changeFleetSnd} Time for new ...
15A1: A7              ANA     A                   ; ... fleet movement sound?
15A2: CA D3 15        JZ      0x15D3              ; {} No ... skip to extra-man timing
15A5: 21 91 17        LXI     H,0x1791            ; Number of aliens list coupled ...
15A8: 11 A1 17        LXI     D,0x17A1            ; ... with delay list
15AB: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Get the number of aliens on the screen
15AE: BE              CMP     M                   ; Compare it to the first list value
15AF: D2 B7 15        JNC     0x15B7              ; {} Number of live aliens is higher than value ... use the delay
15B2: 23              INX     H                   ; Move to ...
15B3: 13              INX     D                   ; ... next list value
15B4: C3 AE 15        JMP     0x15AE              ; {} Find the right delay
15B7: 1A              LDAX    D                   ; Get the delay from the second list

SoundDelay:
15B8: 32 97 20        STA     0x2097              ; {ram.fleetSndReload} Store the new alien sound delay
15BB: 21 98 20        LXI     H,0x2098            ; {ram.soundPort5} Get current state ...
15BE: 7E              MOV     A,M                 ; ... of sound port
15BF: E6 30           ANI     0x30                ; Mask off all fleet movement sounds
15C1: 47              MOV     B,A                 ; Hold the value
15C2: 7E              MOV     A,M                 ; Get current state
15C3: E6 0F           ANI     0x0F                ; This time ONLY the fleet movement sounds
15C5: 07              RLC                         ; Shift next to next sound
15C6: FE 10           CPI     0x10                ; Overflow?
15C8: C2 CD 15        JNZ     0x15CD              ; {} No ... keep it
15CB: 3E 01           MVI     A,0x01              ; Reset back to first sound
15CD: B0              ORA     B                   ; Add fleet sounds to current sound value
15CE: 77              MOV     M,A                 ; Store new sound value
15CF: AF              XRA     A                   ; Restart ...
15D0: 32 95 20        STA     0x2095              ; {ram.changeFleetSnd} ... waiting on fleet time

;
15D3: 21 99 20        LXI     H,0x2099            ; {ram.extraHold} Sound timer for award extra ship
15D6: 35              DCR     M                   ; Time expired?
15D7: C0              RNZ                         ; No ... leave sound playing
15D8: 06 EF           MVI     B,0xEF              ; Turn off bit set with #$10 (award extra ship)
15DA: C3 5C 17        JMP     0x175C              ; {code.SoundBits3Off} Stop sound and out

SndOffExtPly:
15DD: 06 EF           MVI     B,0xEF              ; Mask off sound bit 4 (Extended play)
15DF: 21 98 20        LXI     H,0x2098            ; {ram.soundPort5} Current sound content
15E2: 7E              MOV     A,M                 ; Get current sound bits
15E3: A0              ANA     B                   ; Turn off extended play
15E4: 77              MOV     M,A                 ; Remember settings
15E5: D3 05           OUT     0x05                ; {hard.SOUND2} Turn off extended play
15E7: C9              RET                         ; Out

ReadInputs:
; Read control inputs for active player
15E8: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Get active player
15EB: 0F              RRC                         ; Test player
15EC: D2 F2 15        JNC     0x15F2              ; {} Player 2 ... read port 2
15EF: DB 01           IN      0x01                ; {hard.INP1} Player 1 ... read port 1
15F1: C9              RET                         ; Out
15F2: DB 02           IN      0x02                ; {hard.INP2} Get controls for player 2
15F4: C9              RET                         ; Out

; Check and handle TILT
CheckHandleTilt:
15F5: DB 02           IN      0x02                ; {hard.INP2} Read input port
15F7: E6 04           ANI     0x04                ; Tilt?
15F9: C8              RZ                          ; No tilt ... return
15FA: 3A 9A 20        LDA     0x209A              ; {ram.tilt} Already in TILT handle?
15FD: A7              ANA     A                   ; 1 = yes
15FE: C0              RNZ                         ; Yes ... ignore it now
15FF: C3 50 1A        JMP     0x1A50              ; {code.TiltPart2}
1602: 06 04           MVI     B,0x04              ; Clear the playfield 4 times (Part II)
1604: C5              PUSH    B                   ; Hold count
1605: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear
1608: C1              POP     B                   ; Restore count
1609: 05              DCR     B                   ; All done?
160A: C2 04 16        JNZ     0x1604              ; {} No ... do again
160D: 3E 01           MVI     A,0x01              ; Flag ...
160F: 32 9A 20        STA     0x209A              ; {ram.tilt} ... handling TILT
1612: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks} Disable game tasks
1615: FB              EI                          ; Re-enable interrupts
1616: 11 BE 1C        LXI     D,0x1CBE            ; Message "TILT"
1619: 21 16 30        LXI     H,0x3016            ; Center of screen
161C: 0E 04           MVI     C,0x04              ; Four letters
161E: CD 85 0C        CALL    0x0C85              ; {code.PrintMessageDel} Print "TILT"
1621: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Short delay
1624: AF              XRA     A                   ; Zero
1625: 32 9A 20        STA     0x209A              ; {ram.tilt} TILT handle over
1628: 32 93 20        STA     0x2093              ; {ram.waitStartLoop} Back into splash screens
162B: C3 F2 14        JMP     0x14F2              ; {code.GameOverMsg} Handle game over for player

CtrlSaucerSound:
162E: 21 84 20        LXI     H,0x2084            ; {ram.saucerActive} Saucer on screen flag
1631: 7E              MOV     A,M                 ; Is the saucer ...
1632: A7              ANA     A                   ; ... on the screen?
1633: CA BA 07        JZ      0x07BA              ; {} No ... UFO sound off
1636: 23              INX     H                   ; Saucer hit flag
1637: 7E              MOV     A,M                 ; (2085) Get saucer hit flag
1638: A7              ANA     A                   ; Is saucer in "hit" sequence?
1639: C0              RNZ                         ; Yes ... out

SaucerSndOn:
163A: 06 01           MVI     B,0x01              ; Retrigger saucer ...
163C: C3 B8 16        JMP     0x16B8              ; {code.SoundBits3On} ... sound (retrigger makes it warble?)

DrawAdvTable:
; Draw "SCORE ADVANCE TABLE"
163F: 21 12 28        LXI     H,0x2812            ; 0x410 is 1040 rotCol=32, rotRow=16
1642: 11 CB 1A        LXI     D,0x1ACB            ; "*SCORE ADVANCE TABLE*"
1645: 0E 15           MVI     C,0x15              ; 21 bytes in message
1647: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print message
164A: 3E 0B           MVI     A,0x0B              ; 11 characters per line now ("=500 POINTS")
164C: 32 6C 20        STA     0x206C              ; {ram.temp206C} Hold the count
164F: 01 AB 1D        LXI     B,0x1DAB            ; Coordinate/sprite for drawing table
1652: CD 7D 16        CALL    0x167D              ; {code.ReadPriStruct} Get HL=coordinate, DE=image
1655: DA 5E 16        JC      0x165E              ; {} Move on if done
1658: CD 6B 16        CALL    0x166B              ; {} Draw 16-byte sprite
165B: C3 52 16        JMP     0x1652              ; {} Do all in table
165E: 01 C4 1D        LXI     B,0x1DC4            ; Coordinate/message for drawing table
1661: CD 7D 16        CALL    0x167D              ; {code.ReadPriStruct} Get HL=coordinate, DE=message
1664: D8              RC                          ; Out if done
1665: CD 73 16        CALL    0x1673              ; {} Print message
1668: C3 61 16        JMP     0x1661              ; {} Do all in table

;
166B: C5              PUSH    B                   ; Hold BC
166C: 06 10           MVI     B,0x10              ; 16 bytes
166E: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw simple
1671: C1              POP     B                   ; Restore BC
1672: C9              RET                         ; Out

;
1673: C5              PUSH    B                   ; Hold BC
1674: 3A 6C 20        LDA     0x206C              ; {ram.temp206C} Count of 10 ...
1677: 4F              MOV     C,A                 ; ... to C
1678: CD 85 0C        CALL    0x0C85              ; {code.PrintMessageDel} Print the message with delay between letters
167B: C1              POP     B                   ; Restore BC
167C: C9              RET                         ; Out

ReadPriStruct:
; Read a 4-byte print-structure pointed to by BC
; HL=Screen coordiante, DE=pointer to message
; If the first byte is FF then return with Carry Set, Carry Cleared otherwise.
167D: 0A              LDAX    B                   ; Get the screen LSB
167E: FE FF           CPI     0xFF                ; Valid?
1680: 37              STC                         ; If not Carry will be Set
1681: C8              RZ                          ; Return if 255
1682: 6F              MOV     L,A                 ; Screen LSB to L
1683: 03              INX     B                   ; Next
1684: 0A              LDAX    B                   ; Read screen MSB
1685: 67              MOV     H,A                 ; Screen MSB to H
1686: 03              INX     B                   ; Next
1687: 0A              LDAX    B                   ; Read message LSB
1688: 5F              MOV     E,A                 ; Message LSB to E
1689: 03              INX     B                   ; Next
168A: 0A              LDAX    B                   ; Read message MSB
168B: 57              MOV     D,A                 ; Message MSB to D
168C: 03              INX     B                   ; Next (for next print)
168D: A7              ANA     A                   ; Clear Carry
168E: C9              RET                         ; Done

init:
168F: 31 00 24        LXI     SP,0x2400           ; Set stack pointer just below screen
1692: 06 00           MVI     B,0x00              ; Count 256 bytes
1694: CD 2C 02        CALL    0x022C              ; {code.CopyMirrorB} Copy ROM to RAM (2000-20FF)
1697: CD 30 11        CALL    0x1130              ; {code.DefaultName} Set the default high-score name
169A: CD 16 17        CALL    0x1716              ; {code.ClearAndStatus} Clear the screen and print scores and credits

SplashRestart:
169D: 3E 08           MVI     A,0x08              ; Set alien ...
169F: 32 CF 20        STA     0x20CF              ; {ram.aShotReloadRate} ... shot reload rate
16A2: C3 D8 0C        JMP     0x0CD8              ; {} Top of splash screen loop

; Get player-alive flag for OTHER player
16A5: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Player data MSB
16A8: 21 E7 20        LXI     H,0x20E7            ; {ram.player1Alive} Alive flags (player 1 and 2)
16AB: 0F              RRC                         ; Bit 1=1 for player 1
16AC: D0              RNC                         ; Player 2 ... we have it ... out
16AD: 23              INX     H                   ; Player 1's flag
16AE: C9              RET                         ; Done

; If there is one alien left then the right motion is 3 instead of 2. That's
; why the timing is hard to hit after the change.
16AF: 06 02           MVI     B,0x02              ; Rack moving right delta X
16B1: 3A 82 20        LDA     0x2082              ; {ram.numAliens} Number of aliens on screen
16B4: 3D              DCR     A                   ; Just one left?
16B5: C0              RNZ                         ; No ... use right delta X of 2
16B6: 04              INR     B                   ; Just one alien ... move right at 3 instead of 2
16B7: C9              RET                         ; Done

SoundBits3On:
; Add in bit for sound
16B8: 3A 94 20        LDA     0x2094              ; {ram.soundPort3} Current value of sound port
16BB: B0              ORA     B                   ; Add in new sounds
16BC: 32 94 20        STA     0x2094              ; {ram.soundPort3} New value of sound port
16BF: D3 03           OUT     0x03                ; {hard.SOUND1} Write new value to sound hardware
16C1: C9              RET                         ; Done

InitAliensP2:
16C2: 21 00 22        LXI     H,0x2200            ; Player 2 data area
16C5: C3 E1 01        JMP     0x01E1              ; {code.InitAliensHL} Initialize player 2 aliens

PlyrShotAndBump:
16C8: CD 1D 12        CALL    0x121D              ; {code.PlayerShotHit} Player's shot collision detection
16CB: C3 5B 13        JMP     0x135B              ; {code.RackBump} Change alien deltaX and deltaY when rack bumps edges

CurPlyAlive:
; Get the current player's alive status
16CE: 21 E7 20        LXI     H,0x20E7            ; {ram.player1Alive} Alive flags
16D1: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Player 1 or 2
16D4: 0F              RRC                         ; Will be 1 if player 1
16D5: D8              RC                          ; Return if player 1
16D6: 23              INX     H                   ; Bump to player 2
16D7: C9              RET                         ; Return

DrawScoreHead:
; Print score header " SCORE<1> HI-SCORE SCORE<2> "
16D8: 0E 1C           MVI     C,0x1C              ; 28 bytes in message
16DA: 21 1E 24        LXI     H,0x241E            ; Screen coordinates
16DD: 11 62 18        LXI     D,0x1862            ; Score header message (1862)
16E0: C3 D9 0A        JMP     0x0AD9              ; {code.PrintMessage} Print score header

DrawScoreP1:
16E3: 21 F8 20        LXI     H,0x20F8            ; {ram.P1ScorL} Player 1 score descriptor
16E6: C3 EF 16        JMP     0x16EF              ; {code.DrawScore} Print score

DrawScoreP2:
16E9: 21 FC 20        LXI     H,0x20FC            ; {ram.P2ScorL} Player 2 score descriptor
16EC: C3 EF 16        JMP     0x16EF              ; {code.DrawScore} Print score

DrawScore:
; Print score.
; HL = descriptor
16EF: 5E              MOV     E,M                 ; Get score LSB
16F0: 23              INX     H                   ; Next
16F1: 56              MOV     D,M                 ; Get score MSB
16F2: 23              INX     H                   ; Next
16F3: 7E              MOV     A,M                 ; Get coordinate LSB
16F4: 23              INX     H                   ; Next
16F5: 66              MOV     H,M                 ; Get coordiante MSB
16F6: 6F              MOV     L,A                 ; Set LSB
16F7: C3 7A 10        JMP     0x107A              ; {code.Print4Digits0} Print the score (4 digits plus a 0)

DrawCreditLabel:
16FA: 0E 07           MVI     C,0x07              ; 7 bytes in message
16FC: 21 01 35        LXI     H,0x3501            ; Screen coordinates
16FF: 11 42 1F        LXI     D,0x1F42            ; Message = "CREDIT "
1702: C3 D9 0A        JMP     0x0AD9              ; {code.PrintMessage} Print message

DrawNumCredits:
; Display number of credits on screen
1705: 3A EB 20        LDA     0x20EB              ; {ram.numCoins} Number of credits
1708: 21 01 3C        LXI     H,0x3C01            ; Screen coordinates
170B: C6 1C           ADI     0x1C                ; Digit character (only 0-9 credits now)
170D: C3 E5 0A        JMP     0x0AE5              ; {code.DrawChar} Print it

PrintHiScore:
1710: 21 F4 20        LXI     H,0x20F4            ; {ram.HiScorL} Hi-score descriptor
1713: C3 EF 16        JMP     0x16EF              ; {code.DrawScore} Print it

ClearAndStatus:
1716: CD DC 17        CALL    0x17DC              ; {code.ClearScreen} Clear the screen

DrawScores:
1719: CD D8 16        CALL    0x16D8              ; {code.DrawScoreHead} Print score header

DrawStatus:
171C: CD E3 16        CALL    0x16E3              ; {code.DrawScoreP1} Print player 1 score
171F: CD E9 16        CALL    0x16E9              ; {code.DrawScoreP2} Print player 2 score
1722: CD 10 17        CALL    0x1710              ; {code.PrintHiScore} Print hi score
1725: CD 97 10        CALL    0x1097              ; {code.CenterHiName} Center the high-score name
1728: CD 30 10        CALL    0x1030              ; {code.PrintHiName} Print it
172B: CD FA 16        CALL    0x16FA              ; {} Print credit lable
172E: C3 05 17        JMP     0x1705              ; {code.DrawNumCredits} Number of credits
1731: CD 5C 17        CALL    0x175C              ; {code.SoundBits3Off} From 1537 with B=FB. Turn off player shot sound
1734: C3 57 14        JMP     0x1457              ; {} Update high-score if player's score is greater

AliensInvade:
1737: 3E 01           MVI     A,0x01              ; Set flag that ...
1739: 32 6D 20        STA     0x206D              ; {ram.invaded} ... aliens reached bottom of screen
173C: C3 12 15        JMP     0x1512              ; {} End of round
173F: F1 D5 D6 D0 DB C8 D9 D6 D7 D9 D6 CA E3 D6 DB D0
174F: C8 DB F1

EnableGameTasks:
; Enable ISR game tasks
1752: 3E 01           MVI     A,0x01              ; Set ISR ...
1754: 32 E9 20        STA     0x20E9              ; {ram.suspendPlay} ... game tasks enabled
1757: C9              RET                         ; Done

DsableGameTasks:
; Disable ISR game tasks
; Clear 20E9 flag
1758: AF              XRA     A                   ; Clear ISR game tasks flag
1759: C3 54 17        JMP     0x1754              ; {} Save a byte (the RET)

SoundBits3Off:
; Turn off bit in sound port
175C: 3A 94 20        LDA     0x2094              ; {ram.soundPort3} Current sound effects value
175F: A0              ANA     B                   ; Mask bits off
1760: 32 94 20        STA     0x2094              ; {ram.soundPort3} Store new hold value
1763: D3 03           OUT     0x03                ; {hard.SOUND1} Change sounds
1765: C9              RET                         ; Done

DrawNumShips:
; Show ships remaining in hold for the player
1766: 21 01 27        LXI     H,0x2701            ; Screen coordinates
1769: CA 7A 17        JZ      0x177A              ; {} None in reserve ... skip display

; Draw line of ships
176C: 11 81 1C        LXI     D,0x1C81            ; Player sprite
176F: 06 10           MVI     B,0x10              ; 16 rows
1771: 4F              MOV     C,A                 ; Hold count
1772: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Display 1byte sprite to screen
1775: 79              MOV     A,C                 ; Restore remaining
1776: 3D              DCR     A                   ; All done?
1777: C2 6C 17        JNZ     0x176C              ; {} No ... keep going

; Clear remainder of line
177A: 06 10           MVI     B,0x10              ; 16 rows
177C: CD 10 12        CALL    0x1210              ; {code.ClearSmallSprite} Clear 1byte sprite at HL
177F: 7C              MOV     A,H                 ; Get Y coordinate
1780: FE 35           CPI     0x35                ; At edge?
1782: C2 7A 17        JNZ     0x177A              ; {} No ... do all
1785: C9              RET                         ; Out

CompYToBeam:
;
; The ISRs set the upper bit of 2072 based on where the beam is. This is compared to the
; upper bit of an object's Y coordinate to decide whic ISR should handle it. When the
; beam passes the halfway point (or near it ... at scanline 96), the upper bit is cleared.
; When the beam reaches the end of the screen the upper bit is set.
;
; The task then runs in the ISR if the Y coordiante bit matches the 2072 flag. Objects that
; are at the top of the screen (upper bit of Y clear) run in the mid-screen ISR when
; the beam has moved to the bottom of the screen. Objects that are at the bottom of the screen
; (upper bit of Y set) run in the end-screen ISR when the beam is moving back to the top.
;
; The pointer to the object's Y coordinate is passed in DE. CF is set if the upper bits are
; the same (the calling ISR should execute the task).
;
1786: 21 72 20        LXI     H,0x2072            ; {ram.vblankStatus} Get the ...
1789: 46              MOV     B,M                 ; ... beam position status
178A: 1A              LDAX    D                   ; Get the task structure flag
178B: E6 80           ANI     0x80                ; Only upper bits count
178D: A8              XRA     B                   ; XOR them together
178E: C0              RNZ                         ; Not the same (CF cleared)
178F: 37              STC                         ; Set the CF if the same
1790: C9              RET                         ; Done

; Alien delay lists. First list is the number of aliens. The second list is the corresponding delay.
; This delay is only for the rate of change in the fleet's sound.
; The check takes the first num-aliens-value that is lower or the same as the actual num-aliens on screen.
;
; The game starts with 55 aliens. The aliens are move/drawn one per interrupt which means it
; takes 55 interrupts. The first delay value is 52 ... which is almost in sync with the number
; of aliens. It is a tad faster and you can observe the sound and steps getting out of sync.
;
1791: 32 2B 24 1C 16 11 0D 0A 08 07 06 05 04 03 02 01
17A1: 34 2E 27 22 1C 18 15 13 10 0E 0D 0C 0B 09 07 05
17B1: FF   ; ** Needless terminator. The list value "1" catches everything.

BlockCopy:
; Copy from [DE] to [HL] (b bytes)
17B2: 1A              LDAX    D                   ; Copy from [DE] to ...
17B3: 77              MOV     M,A                 ; ... [HL]
17B4: 23              INX     H                   ; Next destination
17B5: 13              INX     D                   ; Next source
17B6: 05              DCR     B                   ; Count in B
17B7: C2 B2 17        JNZ     0x17B2              ; {code.BlockCopy} Do all
17BA: C9              RET                         ; Done

ReadDesc:
; Load 5 bytes sprite descriptor from [HL]
17BB: 5E              MOV     E,M                 ; Descriptor ...
17BC: 23              INX     H                   ; ... sprite ...
17BD: 56              MOV     D,M                 ; ...
17BE: 23              INX     H                   ; ... picture
17BF: 7E              MOV     A,M                 ; Descriptor ...
17C0: 23              INX     H                   ; ... screen ...
17C1: 4E              MOV     C,M                 ; ...
17C2: 23              INX     H                   ; ... location
17C3: 46              MOV     B,M                 ; Number of bytes in sprite
17C4: 61              MOV     H,C                 ; From A,C to ...
17C5: 6F              MOV     L,A                 ; ... H,L
17C6: C9              RET                         ; Done

ConvToScr:
; The screen is organized as one-bit-per-pixel.
; In: HL contains pixel number (bbbbbbbbbbbbbppp)
; Convert from pixel number to screen coordinates (without shift)
; Shift HL right 3 bits (clearing the top 2 bits)
; and set the third bit from the left.
17C7: C5              PUSH    B                   ; Hold B (will mangle)
17C8: 06 03           MVI     B,0x03              ; 3 shifts (divide by 8)
17CA: 7C              MOV     A,H                 ; H to A
17CB: 1F              RAR                         ; Shift right (into carry, from doesn't matter)
17CC: 67              MOV     H,A                 ; Back to H
17CD: 7D              MOV     A,L                 ; L to A
17CE: 1F              RAR                         ; Shift right (from/to carry)
17CF: 6F              MOV     L,A                 ; Back to L
17D0: 05              DCR     B                   ; Do all ...
17D1: C2 CA 17        JNZ     0x17CA              ; {} ... 3 shifts
17D4: 7C              MOV     A,H                 ; H to A
17D5: E6 3F           ANI     0x3F                ; Mask off all but screen (less than or equal 3F)
17D7: F6 20           ORI     0x20                ; Offset into RAM
17D9: 67              MOV     H,A                 ; Back to H
17DA: C1              POP     B                   ; Restore B
17DB: C9              RET                         ; Done

ClearScreen:
17DC: 21 00 24        LXI     H,0x2400            ; Screen coordinate
17DF: 36 00           MVI     M,0x00              ; Clear it
17E1: 23              INX     H                   ; Next byte
17E2: 7C              MOV     A,H                 ; Have we done ...
17E3: FE 40           CPI     0x40                ; ... all the screen?
17E5: C2 DF 17        JNZ     0x17DF              ; {} No ... keep going
17E8: C9              RET                         ; Out

RestoreShields:
; Logically OR the player's shields back onto the playfield
; DE = sprite
; HL = screen
; C = bytes per row
; B = number of rows
17E9: C5              PUSH    B                   ; Preserve BC
17EA: E5              PUSH    H                   ; Hold for a bit
17EB: 1A              LDAX    D                   ; From sprite
17EC: B6              ORA     M                   ; OR with screen
17ED: 77              MOV     M,A                 ; Back to screen
17EE: 13              INX     D                   ; Next sprite
17EF: 23              INX     H                   ; Next on screen
17F0: 0D              DCR     C                   ; Row done?
17F1: C2 EB 17        JNZ     0x17EB              ; {} No ... do entire row
17F4: E1              POP     H                   ; Original start
17F5: 01 20 00        LXI     B,0x0020            ; Bump HL by ...
17F8: 09              DAD     B                   ; ... one screen row
17F9: C1              POP     B                   ; Restore
17FA: 05              DCR     B                   ; Row counter
17FB: C2 E9 17        JNZ     0x17E9              ; {code.RestoreShields} Do all rows
17FE: C9              RET                         ; Done

RemoveShip:
; Remove a ship from the players stash and update the
; hold indicators on the screen.
17FF: CD 17 0B        CALL    0x0B17              ; {} Get last byte from player data
1802: A7              ANA     A                   ; Is it 0?
1803: C8              RZ                          ; Skip
1804: F5              PUSH    PSW                 ; Preserve number remaining
1805: 3D              DCR     A                   ; Remove a ship from the stash
1806: 77              MOV     M,A                 ; New number of ships
1807: CD 66 17        CALL    0x1766              ; {code.DrawNumShips} Draw the line of ships
180A: F1              POP     PSW                 ; Restore number
180B: 21 01 25        LXI     H,0x2501            ; Screen coordinates
180E: E6 0F           ANI     0x0F                ; Make sure it is a digit
1810: C3 92 0B        JMP     0x0B92              ; {code.DrawDigit} Print number remaining
```

# Data (Part II squeezes new code in between the tables)

```code
1813: 00 00
1815: FF B8 FE 21 1C 10 9E 00 21 1C

ShotReloadRate:
; The tables at 1CBA and 181F control how fast shots are created. The speed is based
; on the upper byte of the player's score. For a score of less than or equal 0200 then
; the fire speed is 30. For a score less than or equal 1000 the shot speed is 10. Less
; than or equal 2000 the speed is 0B. Less than or equal 3000 is 08. And anything
; above 3000 is 07.
;
; 1CBA: 02 10 20 30
;
181F: 30 10 0B 08
1823: 07   ; Fastest shot firing speed

MessageGOver:
1824: 06 00 0C 04 1B 0E 15 04 11 1B 1B 0F ; "GAME OVER  P"
1830: 0B 00 18 04 11 26 1B 27             ; "LAYER< >"

MessageB1or2:
1838: 1D 1B 0E 11 1B 1E 0F 0B 00 18 04 11 ; "1 OR 2PLAYER"
1844: 12 1B 01 14 13 13 0E 0D             ; "S BUTTON"

Message1Only:
184C: 1B 0E 0D 0B 18 1B 1D 0F 0B 00 18 04 ; " ONLY 1PLAYE"
1858: 11 1B 1B 01 14 13 13 0E 0D 1B       ; "R  BUTTON "

MessageScore:
1862: 1B 12 02 0E 11 04 2B 1D 1B 1B 1B 1B ; " SCORE-1    "
186E: 1B 1B 1B 1B 1B 1B 1B 1B 12 02 0E 11 ; "        SCOR"
187A: 04 2B 1E 1B                         ; "E-2 "

SpriteSaucerFlash:
;  ........
;  ........
;  ........
;  ........
;  ..**....
;  ..*.*...
;  ..***...
;  .**.*...
;  .*****..
;  .**.***.
;  .****.**
;  .**.****
;  .****.**
;  .**.***.
;  .*****..
;  .**.*...
;  ..***...
;  ..*.*...
;  ..**....
;  ........
;  ........
;  ........
;  ........
;  ........
187E: 00 00 00 00 0C 14 1C 16 3E 76 DE F6 DE 76 3E 16 1C 14 0C 00 00 00 00 00
```

# Part II: End-of-Rack Intermission

```code

Intermission:
; Part II: after every rack the last alien that was shot escapes in a little saucer.
; It zig-zags up the screen calling "SOS !!". If both saucers of the rack were hit
; (20BB) the saucer stops part way with "ENGINE TROUBLE" and then carries on.
; The ISR (IntermissionISR) does the moving and drawing while 20D0 is set.
1896: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks} Stop the game tasks
1899: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear the playfield
189C: 21 01 1C        LXI     H,0x1C01            ; Octopus picture
189F: 11 10 00        LXI     D,0x0010            ; 16 bytes per alien picture
18A2: 3A DB 20        LDA     0x20DB              ; {ram.lastAlienType} Type of the last alien shot
18A5: FE 01           CPI     0x01                ; Octopus?
18A7: CA B7 18        JZ      0x18B7              ; {} Yes ... use it
18AA: 19              DAD     D                   ; Next picture (crab)
18AB: FE 03           CPI     0x03                ; Crab?
18AD: CA B7 18        JZ      0x18B7              ; {} Yes ... use it
18B0: 19              DAD     D                   ; Next picture (squid)
18B1: FE 05           CPI     0x05                ; Squid?
18B3: CA B7 18        JZ      0x18B7              ; {} Yes ... use it
18B6: 19              DAD     D                   ; Otherwise the small alien
18B7: 22 DD 20        SHLD    0x20DD              ; {ram.sosAlienPicL} Alien riding in the saucer
18BA: 21 D1 20        LXI     H,0x20D1            ; {ram.sosStage} Intermission variables
18BD: 11 D1 1B        LXI     D,0x1BD1            ; Initial values
18C0: 06 0C           MVI     B,0x0C              ; 12 bytes
18C2: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Initialize them
18C5: 2A 0B 20        LHLD    0x200B              ; {ram.alienPosLSB} Start where the last alien was
18C8: 22 D4 20        SHLD    0x20D4              ; {ram.sosPosL} Saucer position
18CB: 21 01 01        LXI     H,0x0101            ; Move 1,1
18CE: 22 D2 20        SHLD    0x20D2              ; {ram.sosDeltaX} Deltas
18D1: 3E 01           MVI     A,0x01              ; Start ...
18D3: 32 D0 20        STA     0x20D0              ; {ram.sosActive} ... the ISR animation
18D6: 3A D4 20        LDA     0x20D4              ; {ram.sosPosL} Has the saucer ...
18D9: FE D0           CPI     0xD0                ; ... left the screen?
18DB: D2 0E 19        JNC     0x190E              ; {} Yes ... intermission over
18DE: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
18E0: 3A D9 20        LDA     0x20D9              ; {ram.sosResume} Already had the engine trouble stop?
18E3: A7              ANA     A                   ; Set flags
18E4: C2 D6 18        JNZ     0x18D6              ; {} Yes ... just wait for it to fly off
18E7: 3A D1 20        LDA     0x20D1              ; {ram.sosStage} Has the ...
18EA: A7              ANA     A                   ; ... saucer stopped (engine trouble)?
18EB: CA D6 18        JZ      0x18D6              ; {} No ... wait
18EE: AF              XRA     A                   ; Stop ...
18EF: 32 D0 20        STA     0x20D0              ; {ram.sosActive} ... ISR animation
18F2: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
18F5: 21 10 28        LXI     H,0x2810            ; Screen coordinates
18F8: 0E 0E           MVI     C,0x0E              ; 14 characters
18FA: 11 16 1A        LXI     D,0x1A16            ; "ENGINE TROUBLE"
18FD: CD 85 0C        CALL    0x0C85              ; {code.PrintMessageDel} Print it
1900: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
1903: 3E 01           MVI     A,0x01              ; Restart ...
1905: 32 D0 20        STA     0x20D0              ; {ram.sosActive} ... the animation
1908: 32 D9 20        STA     0x20D9              ; {ram.sosResume} ... and let it fly off
190B: C3 D6 18        JMP     0x18D6              ; {} Wait for it to leave
190E: CD BA 07        CALL    0x07BA              ; {code.SaucerSndOff} Saucer sound off
1911: AF              XRA     A                   ; Stop ...
1912: 32 D0 20        STA     0x20D0              ; {ram.sosActive} ... the animation
1915: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear the playfield
1918: C3 9D 0C        JMP     0x0C9D              ; {code.OneSecDelay} Wait and out

SosSound:
; Pulse the saucer sound on and off.
191B: 21 DF 20        LXI     H,0x20DF            ; {ram.sosBlink} Count ...
191E: 35              DCR     M                   ; ... down
191F: 7E              MOV     A,M                 ; Get count
1920: E6 02           ANI     0x02                ; Every other 2 ticks ...
1922: CA BA 07        JZ      0x07BA              ; {code.SaucerSndOff} ... sound off
1925: C3 3A 16        JMP     0x163A              ; {code.SaucerSndOn} ... sound on
1928: 12 0E 12 1B 2D                      ; "SOS |"

IntermissionISR:
; Part II: called at the end of every interrupt (both halves). In attract mode it runs
; the protection checks. While 20D0 is set it moves and draws the intermission saucer.
192D: 3A EF 20        LDA     0x20EF              ; {ram.gameMode} Game running?
1930: A7              ANA     A                   ; Set flags
1931: CC 53 1F        CZ      0x1F53              ; {code.ProtChecks} No ... hardware and copyright checks
1934: 3A D0 20        LDA     0x20D0              ; {ram.sosActive} Intermission running?
1937: A7              ANA     A                   ; Set flags
1938: C8              RZ                          ; No ... out
1939: 11 D5 20        LXI     D,0x20D5            ; {ram.sosPosM} Saucer's position (for the beam compare)
193C: C3 40 1A        JMP     0x1A40              ; {code.SosBeamChk} Draw it on the correct half of the screen

SosBeamSide:
193F: FE 22           CPI     0x22                ; Player 2 (cocktail) ...
1941: C2 4B 19        JNZ     0x194B              ; {} No ... normal

SosBeamNorm:
1944: CD 86 17        CALL    0x1786              ; {code.CompYToBeam} Compare to beam position
1947: D0              RNC                         ; Not this half ... out
1948: C3 4F 19        JMP     0x194F              ; {} Move it
194B: CD 86 17        CALL    0x1786              ; {code.CompYToBeam} Compare to beam position
194E: D8              RC                          ; Not this half ... out
194F: 3A BB 20        LDA     0x20BB              ; {ram.flashSaucer} Were both saucers hit this rack?
1952: A7              ANA     A                   ; Set flags
1953: C2 BC 19        JNZ     0x19BC              ; {} Yes ... engine trouble version
1956: CD 1B 19        CALL    0x191B              ; {code.SosSound} Pulse the sound
1959: 3A D5 20        LDA     0x20D5              ; {ram.sosPosM} Saucer's position
195C: FE B0           CPI     0xB0                ; At the right side?
195E: D4 A4 19        CNC     0x19A4              ; {code.PrintSOS} Yes ... print "SOS !!" and bounce
1961: FE 50           CPI     0x50                ; At the left side?
1963: DC 9B 19        CC      0x199B              ; {code.PrintSOSL} Yes ... print "SOS !!" and bounce
1966: 21 D4 20        LXI     H,0x20D4            ; {ram.sosPosL} Saucer descriptor
1969: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Read it
196C: EB              XCHG                        ; Position to HL, picture to DE
196D: E5              PUSH    H                   ; Hold position
196E: CD 96 13        CALL    0x1396              ; {code.DrawSprite} Draw the saucer
1971: 2A DD 20        LHLD    0x20DD              ; {ram.sosAlienPicL} Alien's picture
1974: EB              XCHG                        ; To DE
1975: 01 08 07        LXI     B,0x0708            ; Offset inside ...
1978: E1              POP     H                   ; Restore position
1979: 09              DAD     B                   ; ... the saucer
197A: 06 10           MVI     B,0x10              ; 16 rows
197C: CD A0 1A        CALL    0x1AA0              ; {code.DrawSprOr} OR the alien into the saucer
197F: 21 DA 20        LXI     H,0x20DA            ; {ram.sosWobble} Wobble ...
1982: 35              DCR     M                   ; ... counter
1983: 7E              MOV     A,M                 ; Get it
1984: E6 01           ANI     0x01                ; Every other move ...
1986: C2 94 19        JNZ     0x1994              ; {} ... no sideways step
1989: 3C              INR     A                   ; Sideways ...
198A: 32 D2 20        STA     0x20D2              ; {ram.sosDeltaX} ... step of 1
198D: 21 D2 20        LXI     H,0x20D2            ; {ram.sosDeltaX} Move ...
1990: 4E              MOV     C,M                 ; ... the ...
1991: C3 1F 02        JMP     0x021F              ; {code.AddDelta} ... saucer and out
1994: AF              XRA     A                   ; No ...
1995: 32 D2 20        STA     0x20D2              ; {ram.sosDeltaX} ... sideways step
1998: C3 8D 19        JMP     0x198D              ; {} Move it

PrintSOSL:
199B: 3E 01           MVI     A,0x01              ; Move ...
199D: 32 D3 20        STA     0x20D3              ; {ram.sosDeltaY} ... the other way
19A0: F5              PUSH    PSW                 ; Hold
19A1: C3 AA 19        JMP     0x19AA              ; {} Print "SOS !!"

PrintSOS:
19A4: F5              PUSH    PSW                 ; Hold
19A5: 3E FF           MVI     A,0xFF              ; Move ...
19A7: 32 D3 20        STA     0x20D3              ; {ram.sosDeltaY} ... the other way
19AA: 2A D4 20        LHLD    0x20D4              ; {ram.sosPosL} Saucer's height ...
19AD: 26 D0           MVI     H,0xD0              ; ... at the right edge column
19AF: 11 28 19        LXI     D,0x1928            ; "SOS !!"
19B2: 0E 05           MVI     C,0x05              ; 5 characters
19B4: CD C7 17        CALL    0x17C7              ; {code.ConvToScr} Screen address
19B7: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print it
19BA: F1              POP     PSW                 ; Restore
19BB: C9              RET                         ; Done

SosEngineTrouble:
19BC: 3A D4 20        LDA     0x20D4              ; {ram.sosPosL} Saucer height
19BF: FE 98           CPI     0x98                ; High enough to stop?
19C1: D2 C7 19        JNC     0x19C7              ; {} Yes
19C4: C3 56 19        JMP     0x1956              ; {} No ... keep flying
19C7: 3A D1 20        LDA     0x20D1              ; {ram.sosStage} Already stopped?
19CA: A7              ANA     A                   ; Set flags
19CB: C2 E9 19        JNZ     0x19E9              ; {} Yes ... just animate
19CE: 2A D4 20        LHLD    0x20D4              ; {ram.sosPosL} Saucer position
19D1: 01 08 07        LXI     B,0x0708            ; Move to where ...
19D4: 09              DAD     B                   ; ... the alien sits
19D5: 22 D4 20        SHLD    0x20D4              ; {ram.sosPosL} New position
19D8: 2A DD 20        LHLD    0x20DD              ; {ram.sosAlienPicL} The alien gets out ...
19DB: 22 D6 20        SHLD    0x20D6              ; {ram.sosPicL} ... (draw only the alien)
19DE: 21 D8 20        LXI     H,0x20D8            ; {ram.sosSize} Picture ...
19E1: 36 10           MVI     M,0x10              ; ... size 16
19E3: 21 01 00        LXI     H,0x0001            ; Deltas ...
19E6: 22 D2 20        SHLD    0x20D2              ; {ram.sosDeltaX} ... 1,0
19E9: 21 DF 20        LXI     H,0x20DF            ; {ram.sosBlink} Count ...
19EC: 35              DCR     M                   ; ... down
19ED: 7E              MOV     A,M                 ; Get count
19EE: E6 01           ANI     0x01                ; Every other tick ...
19F0: C2 F6 19        JNZ     0x19F6              ; {} ... no move
19F3: CD 8D 19        CALL    0x198D              ; {} Move
19F6: 3E 01           MVI     A,0x01              ; Flag ...
19F8: 32 D1 20        STA     0x20D1              ; {ram.sosStage} ... stopped (main code prints ENGINE TROUBLE)
19FB: 21 D4 20        LXI     H,0x20D4            ; {ram.sosPosL} Descriptor
19FE: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Read it
1A01: EB              XCHG                        ; Position to HL, picture to DE
1A02: E5              PUSH    H                   ; Hold position
1A03: 21 DC 20        LXI     H,0x20DC            ; {ram.sosAnim} Animate ...
1A06: 35              DCR     M                   ; ... the alien ...
1A07: 7E              MOV     A,M                 ; Get count
1A08: E6 04           ANI     0x04                ; ... every 4 ticks
1A0A: CC 11 1A        CZ      0x1A11              ; {} Use the frame-1 picture
1A0D: E1              POP     H                   ; Restore position
1A0E: C3 96 13        JMP     0x1396              ; {code.DrawSprite} Draw it and out
1A11: 3E 40           MVI     A,0x40              ; Frame-1 picture ...
1A13: 83              ADD     E                   ; ... is 40 bytes on
1A14: 5F              MOV     E,A                 ; To DE
1A15: C9              RET                         ; Done
1A16: 04 0D 06 08 0D 04 1B 13 11 0E 14 01 ; "ENGINE TROUB"
1A22: 0B 04                               ; "LE"

CharPtr:
; DE = picture of character A (5 bytes per character, font at 1E21).
1A24: 11 21 1E        LXI     D,0x1E21            ; Font (character 0 is "A")
1A27: A7              ANA     A                   ; Character 0?
1A28: C8              RZ                          ; Yes ... done
1A29: E5              PUSH    H                   ; Hold
1A2A: 21 00 00        LXI     H,0x0000            ; Offset ...
1A2D: C5              PUSH    B                   ; Hold
1A2E: 01 05 00        LXI     B,0x0005            ; 5 bytes ...
1A31: 09              DAD     B                   ; ... per character
1A32: 3D              DCR     A                   ; All counted?
1A33: C2 2E 1A        JNZ     0x1A2E              ; {} No ... keep adding
1A36: 19              DAD     D                   ; Add the font base
1A37: EB              XCHG                        ; Pointer to DE
1A38: C1              POP     B                   ; Restore ...
1A39: E1              POP     H                   ; ... registers
1A3A: C9              RET                         ; Done
1A3B: 21 00 24 11 50

SosBeamChk:
1A40: DB 02           IN      0x02                ; {hard.INP2} DIP: upright or cocktail?
1A42: E6 02           ANI     0x02                ; Bit 1
1A44: C2 44 19        JNZ     0x1944              ; {code.SosBeamNorm} (normal compare)
1A47: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Player 2's turn in a cocktail ...
1A4A: C3 3F 19        JMP     0x193F              ; {code.SosBeamSide} ... flips the screen
1A4D: 09 44 42                                        ; \tDB

TiltPart2:
; Part II tilt: stop the intermission and all sounds then reset the stack.
1A50: 32 D0 20        STA     0x20D0              ; {ram.sosActive} A=0 ... stop the intermission
1A53: D3 03           OUT     0x03                ; {hard.SOUND1} All sound ...
1A55: D3 05           OUT     0x05                ; {hard.SOUND2} ... off
1A57: 32 98 20        STA     0x2098              ; {ram.soundPort5} Remember it
1A5A: 31 00 24        LXI     SP,0x2400           ; Reset stack
1A5D: C3 02 16        JMP     0x1602              ; {} Continue with the original tilt code
```

# More Data

```code
1A60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1A70: 37 30 48 2C 30 44 43 48 0D 0A 09 44 42 09 30 44 ; 70H,0DCH\r\n\tDB\t0D

ColFireTable:
; This table decides which column a shot will fall from. The column number is read from the
; table (1-11) and the pointer increases for the shot type. For instance, the "squiggly" shot
; will fall from columns in this order: 0B, 01, 06, 03. If you play the game you'll see that
; order.
;
; The "plunger" shot uses index 00-0F (inclusive)
; The "squiggly" shot uses index 06-14 (inclusive)
; The "rolling" shot targets the player
; (Part II moved the table from 1D00 to 1A80.)
1A80: 01 07 01 01 01 04 0B 01 06 03 01 01 0B 09 02 08
1A90: 02 0B 04 07 0A

;
; This appears to be part of the column-firing table, but it is never used.
; Perhaps this was originally intended for the "rolling" shot but then the
; "rolling" was change to target the player specifically.
1A95: 05 02 05 04 06 07 08 0A 06 0A 03

DrawSprOr:
; Draw a shifted sprite ORed onto the screen (HL=pixel number, DE=picture, B=rows).
1AA0: CD B9 11        CALL    0x11B9              ; {code.CnvtPixNumber} Convert pixel number to screen/shift
1AA3: C5              PUSH    B                   ; Hold count
1AA4: E5              PUSH    H                   ; Hold screen position
1AA5: 1A              LDAX    D                   ; Picture byte
1AA6: D3 04           OUT     0x04                ; {hard.SHFT_DATA} To shift register
1AA8: DB 03           IN      0x03                ; {hard.SHFT_IN} Shifted
1AAA: B6              ORA     M                   ; OR with screen
1AAB: 77              MOV     M,A                 ; Store
1AAC: 23              INX     H                   ; Next byte on screen
1AAD: 13              INX     D                   ; Next picture byte
1AAE: AF              XRA     A                   ; Shift in ...
1AAF: D3 04           OUT     0x04                ; {hard.SHFT_DATA} ... zero
1AB1: DB 03           IN      0x03                ; {hard.SHFT_IN} Remainder
1AB3: 77              MOV     M,A                 ; Store
1AB4: E1              POP     H                   ; Restore screen position
1AB5: 01 20 00        LXI     B,0x0020            ; Next ...
1AB8: 09              DAD     B                   ; ... row
1AB9: C1              POP     B                   ; Restore count
1ABA: 05              DCR     B                   ; All rows?
1ABB: C2 A3 1A        JNZ     0x1AA3              ; {} No ... do them all
1ABE: C9              RET                         ; Done

DemoCommands:
; (1=Right, 2=Left)
1ABF: 01 01 00 00 01 00 02 01 00 02 01 00

MessageAdv:
; "*SCORE ADVANCE TABLE*"
1ACB: 29 12 02 0E 11 04 1B 00 03 15 00 0D ; "*SCORE ADVAN"
1AD7: 02 04 1B 13 00 01 0B 04 29          ; "CE TABLE*"

AlienSplitExp:
; Part II: picture of a crab splitting into two small aliens (32 bytes, used as the
; "explosion" when a crab is shot in round 3 or later).
;  ........ .*.****.
;  ........ ..***.**
;  ........ ..*.****
;  ........ ..*.****
;  *...**.. ..***.**
;  .*.****. .*.****.
;  ..***.** *...**..
;  ..*.**** ........
;  ..*.**** ........
;  ..***.** ........
;  .*.****. ........
;  *...**.. ........
;  .*.***.. ........
;  ..**..*. ........
;  .*.***.. ........
;  *...**.. ........
1AE0: 00 00 00 00 31 7A DC F4 F4 DC 7A 31 3A 4C 3A 31
1AF0: 7A DC F4 F4 DC 7A 31 00 00 00 00 00 00 00 00 00

;-------------------------- RAM initialization -----------------------------
; Coppied to RAM (2000) C0 bytes as initialization.
; See the description of RAM at the top of this file for the details on this data.
1B00: 01 00 00 10 00 00 00 00 02 78 38 78 38 00 F8 00
1B10: 00 80 00 D4 02 FF 05 0C 81 1C 20 30 10 01 00 00
1B20: 00 00 00 00 04 00 10 B1 1C 28 30 01 04 00 FF FF
1B30: 00 00 02 C3 04 00 00 00 00 00 04 F0 1C 00 00 03
1B40: 00 00 00 03 05 00 00 01 80 1A 04 E4 1C 00 00 03
1B50: 00 00 00 D9 06 00 00 01 86 1A 04 D2 1C 00 00 03
1B60: FF 00 C2 1C 00 00 10 21 01 00 30 00 12 00 00 00

; These don't need to be copied over to RAM (see 1BA0 below).
MesssageP1:
; "PLAY PLAYER<1>"
1B70: 0F 0B 00 18 1B 0F 0B 00 18 04
1B7A: 11 26 1D 27 FC
1B7F: 00
1B80: 01 FF FF 00 00 00 20 60 1D D0 29 18 02 50 1D 00
1B90: 08 00 06 00 00 01 40 00 01 00 00 10 9E 00 21 1C

; Part II uses these 32 bytes: they are no longer "extra".
; Part II additions to the RAM mirror (copied to 20A0-20BF):
;   20A0-20AD saucer-drop variables (falling squid at Y=C8 stepping -2, picture 1C25, 8 bytes)
;   20AF=1 (score table on), 20B5=2 (default number of bonus beam fans)
1BA0: 00 00 FE 00 C8 00 25 1C 08 00 00 00 00 00 00 01
1BB0: 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00

;--------------------------- End of initialization copy -------------------------
; Copied to 20C0-20FF only at power-up (init copies 256 bytes):
;   20C1=10, 20D1-20DC intermission (picture 1CFC, size 1D), 20E1=FF, 20E2=1 (tamper flag),
;   20E3=1 (hardware flag), 20E9=1, 20EC=1, 20ED=1ABF (demo commands), 20F4=0500 high score
;   (shown as 05000) at 2F1C, player scores at 261C and 391C.
1BC0: 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1BD0: 00 00 00 00 00 00 FC 1C 1D 00 00 00 00 00 00 00
1BE0: 00 FF 01 01 00 00 00 00 00 01 00 00 01 BF 1A 00
1BF0: 78 00 00 00 00 05 1C 2F 00 00 1C 26 00 00 1C 39
1C00: 00

AlienSprA:
; Part II alien pictures, 16 bytes each (the screen is turned so rotate these counter-clockwise).
; Frame 0: octopus (1C01), crab (1C11), squid (1C21), small alien (1C31)
; Frame 1: octopus (1C41), crab (1C51), squid (1C61), small alien (1C71)
;  ........ ........ ........ ........
;  ........ ........ ........ ........
;  *..***.. ........ ........ ........
;  *..****. ...****. ........ ........
;  .*.****. *.***... *..**... ....**..
;  .***.**. .*****.* .*.***.. .*.****.
;  ..**.*** ..**.**. *.**.**. *.***.**
;  .*.***** ..****.. .*.***** ..*.****
;  .*.***** ..****.. .*.***** ..*.****
;  ..**.*** ..****.. *.**.**. *.***.**
;  .***.**. ..**.**. .*.***.. .*.****.
;  .*.****. .*****.* *..**... ....**..
;  *..****. *.***... ........ ........
;  *..***.. ...****. ........ ........
;  ........ ........ ........ ........
;  ........ ........ ........ ........
1C01: 00 00 39 79 7A 6E EC FA FA EC 6E 7A 79 39 00 00
1C11: 00 00 00 78 1D BE 6C 3C 3C 3C 6C BE 1D 78 00 00
1C21: 00 00 00 00 19 3A 6D FA FA 6D 3A 19 00 00 00 00
1C31: 00 00 00 00 30 7A DD F4 F4 DD 7A 30 00 00 00 00
;  ........ ........ ........ ........
;  ........ ........ ........ ........
;  ...***.. ........ ........ ........
;  .*.****. .***.... ........ ........
;  *******. ...**... .*.**... ........
;  *.**.**. .*****.* *.****.. ....*...
;  ..**.*** *.**.**. ...*.**. .*.*.*..
;  .*.***** *.****.. ..****** ..*****.
;  .*.***** ..****.. ..****** ..*****.
;  ..**.*** *.****.. ...*.**. .*.*.*..
;  *.**.**. *.**.**. *.****.. ....*...
;  *******. .*****.* .*.**... ........
;  .*.****. ...**... ........ ........
;  ...***.. .***.... ........ ........
;  ........ ........ ........ ........
;  ........ ........ ........ ........
1C41: 00 00 38 7A 7F 6D EC FA FA EC 6D 7F 7A 38 00 00
1C51: 00 00 00 0E 18 BE 6D 3D 3C 3D 6D BE 18 0E 00 00
1C61: 00 00 00 00 1A 3D 68 FC FC 68 3D 1A 00 00 00 00
1C71: 00 00 00 00 00 10 2A 7C 7C 2A 10 00 00 00 00 00

PlayerSprite:
;  ........
;  ........
;  ****....
;  *****...
;  *****...
;  *****...
;  *****...
;  *******.
;  ********
;  *******.
;  *****...
;  *****...
;  *****...
;  *****...
;  ****....
;  ........
1C81: 00 00 0F 1F 1F 1F 1F 7F FF 7F 1F 1F 1F 1F 0F 00

PlrBlowupSprites:
;  ........
;  ..*.....
;  *.......
;  **..*...
;  **......
;  ***.....
;  **..**.*
;  ****....
;  ****.*..
;  **......
;  ****.*..
;  *..*..*.
;  ..*.....
;  **......
;  ........
;  *.......
;
1C91: 00 04 01 13 03 07 B3 0F 2F 03 2F 49 04 03 00 01

;
;  ......*.
;  ...*....
;  *.*.....
;  **...*.*
;  .*.*....
;  **......
;  **.**.*.
;  ****....
;  ***..*..
;  ***..*..
;  **.*....
;  **.*..*.
;  ......*.
;  ..*....*
;  *...*...
;  ...*..*.
1CA1: 40 08 05 A3 0A 03 5B 0F 27 27 0B 4B 40 84 11 48

PlayerShotSpr:
1CB1: 0F   ; ++++....

ShotExploding:
; *..**..*
; ..****..
; .******.
; *.****..
; ..****.*
; .*****..
; ..*****.
; *..**..*
1CB2: 99 3C 7E 3D BC 3E 7C 99

AReloadScoreTab:
; The tables at 1CBA and 181F control how fast shots are created. The speed is based
; on the upper byte of the player's score. For a score of less than or equal 0200 then
; the fire speed is 30. For a score less than or equal 1000 the shot speed is 10. Less
; than or equal 2000 the speed is 0B. Less than or equal 3000 is 08. And anything
; above 3000 is 07.
;
; 181F: 30 10 0B 08
; 1823: 07           ; Fastest shot firing speed
;
1CBA: 02 10 20 30

MessageTilt:
1CBE: 13 08 0B 13   ; "TILT"

; Alien exploding sprite
AlienExplode:
;  ........
;  ...*....
;  *..*..*.
;  .*...*..
;  ..*.*...
;  *......*
;  .*....*.
;  ........
;  .*....*.
;  *......*
;  ..*.*...
;  .*...*..
;  *..*..*.
;  ...*....
;  ........
;  ........
1CC2: 00 08 49 22 14 81 42 00 42 81 14 22 49 08 00 00

; Squigly shot picture in 4 animation frames
SquiglyShot:
1CD2: 44   ; ..*...*.
1CD3: AA   ; .*.*.*.*
1CD4: 10   ; ....*...
1CD5: 88   ; ...*...*
1CD6: 54   ; ..*.*.*.
1CD7: 22   ; .*...*..
1CD8: 10   ; ....*...
1CD9: AA   ; .*.*.*.*
1CDA: 44   ; ..*...*.
1CDB: 22   ; .*...*..
1CDC: 54   ; ..*.*.*.
1CDD: 88   ; ...*...*

; Alien shot exploding
AShotExplo:
; .*.*..*.
; *.*.*...
; .*****.*
; ******..
; .****.*.
; *.*..*..
1CDE: 4A 15 BE 3F 5E 25

; Alien shot ... the plunger looking one
PlungerShot:
1CE4: 04   ; ..*.....
1CE5: FC   ; ..******
1CE6: 04   ; ..*.....
1CE7: 10   ; ....*...
1CE8: FC   ; ..******
1CE9: 10   ; ....*...
1CEA: 20   ; .....*..
1CEB: FC   ; ..******
1CEC: 20   ; .....*..
1CED: 80   ; .......*
1CEE: FC   ; ..******
1CEF: 80   ; .......*

; Alien shot ... the rolling one
RollShot:
1CF0: 00   ; ........
1CF1: FE   ; .*******
1CF2: 00   ; ........
1CF3: 24   ; ..*..*..
1CF4: FE   ; .*******
1CF5: 12   ; .*..*...
1CF6: 00   ; ........
1CF7: FE   ; .*******
1CF8: 00   ; ........
1CF9: 48   ; ...*..*.
1CFA: FE   ; .*******
1CFB: 90   ; ....*..*

SpriteSosSaucer:
; The little saucer the last alien escapes in during the intermission.
;  ........ ..**.***
;  ........ ..**.***
;  ........ ..******
;  ..*..... .******.
;  ..**.... .***.**.
;  ..**.... .***.*..
;  .****... .*****..
;  .*****.. .****...
;  .***.*.. ..**....
;  .***.**. ..**....
;  .******. ..*.....
;  ..****** ........
;  ..**.*** ........
;  ..**.*** ........
;  ..****** ........
;  ..****** ........
1CFC: 00 00 00 04 0C 0C 1E 3E 2E 6E 7E FC EC EC FC FC
1D0C: EC EC FC 7E 6E 2E 3E 1E 0C 0C 04 00 00 00 00 00

ShieldImage:
; Shield image pattern. 2 x 22 = 44 bytes.
;
;************....
;*************...
;**************..
;***************.
;****************
;..**************
;...*************
;....************
;....************
;....************
;....************
;....************
;....************
;....************
;...*************
;..**************
;****************
;****************
;***************.
;**************..
;*************...
;************....
;
1D1C: FF 0F FF 1F FF 3F FF 7F FF FF FC FF F8 FF F0 FF F0 FF F0 FF F0 FF
1D32: F0 FF F0 FF F0 FF F8 FF FC FF FF FF FF FF FF 7F FF 3F FF 1F FF 0F
1D48: 05 10 15 30
1D4C: 90 93 96 99

SaucerScrTab:
; 208D points here to the score given when the saucer is shot. It advances
; every time the player-shot is removed. The code wraps after 15, but there
; are 16 values in this table. This is a bug in the code at 044E (thanks to
; Colin Dooley for finding this).
;
; Thus the one and only 300 comes up every 15 shots (after an initial 8).
1D50: 10 05 05 10 15 10 10 05 30 10 10 10 05 15 10 05

SpriteSaucer:
; ........
; ........
; ........
; ........
; ..*.....
; ..**....
; .****...
; ***.**..
; .*****..
; ..*****.
; ..*.***.
; .******.
; .******.
; ..*.***.
; ..*****.
; .*****..
; ***.**..
; .****...
; ..**....
; ..*.....
; ........
; ........
; ........
; ........
1D60: 00 00 00 00 04 0C 1E 37 3E 7C 74 7E 7E 74 7C 3E 37 1E 0C 04 00 00 00 00

SpriteSaucerExp:
;........
;.*...*..
;........
;*.*..*.*
;......*.
;...*....
;...**..*
;*.****..
;.**.**.*
;..****..
;.**.**..
;*.***...
;....*...
;...*..*.
;.*...**.
;.**.**.*
;*.***...
;...**..*
;...*....
;.*....*.
;....*..*
;...*....
;........
;........
1D78: 00 22 00 A5 40 08 98 3D B6 3C 36 1D 10 48 62 B6 1D 98 08 42 90 08 00 00
1D90: 1B 21 1C 1D 1C 1C 1D 21 1C 1F 1C 1C ; " 50100150300"
1D9C: 01 02 03
1D9F: 05

AlienStartTable:
; Starting Y coordinates for aliens at beginning of rounds. The first round is initialized to $78 at 08EE.
; After that this table is used for 2nd, 3rd, 4th, 5th, 6th, 7th, 8th, and 9th. The 10th starts over at
; 1DA0 (60).
1DA0: 60
1DA1: 50
1DA2: 48
1DA3: 48
1DA4: 48
1DA5: 40
1DA6: 40
1DA7: 40
1DA8: 21 1C 1C                            ; "500"

AdvTableSprites:
; Score table pictures: screen coordinate, picture (flashing saucer, saucer, small alien,
; squid, crab, octopus)
1DAB: 0E 2C 82 18 
1DAF: 0C 2C 64 1D 
1DB3: 0A 2A 31 1C 
1DB7: 0A 2C 21 1C 
1DBB: 08 2C 51 1C 
1DBF: 06 2C 01 1C 
1DC3: FF          

AdvTableMessages:
; Score table messages: screen coordinate, message
1DC4: 0E 2E D9 1D 
1DC8: 0C 2E E4 1D 
1DCC: 0A 2E EF 1D 
1DD0: 08 2E FA 1D 
1DD4: 06 2E 05 1E 
1DD8: FF          

MessagePoints:
1DD9: 28 21 1C 1C 1B 0F 0E 08 0D 13 12 28 ; "=500 POINTS="
1DE5: 1B 2C 1B 0C 18 12 13 04 11 18 28 1B ; " ? MYSTERY= "
1DF1: 1F 1C 1B 0F 0E 08 0D 13 12 28 1B 1E ; "30 POINTS= 2"
1DFD: 1C 1B 0F 0E 08 0D 13 12 28 1B 1D 1C ; "0 POINTS= 10"
1E09: 1B 0F 0E 08 0D 13 12                ; " POINTS"

FormationTable:
; Low byte of the formation (40xx) for rounds 0-16 (see InitAliens)
1E10: 00 00 00 2C 2C 84 84 58 58 B0 B0 B0 2C 58 58 84
1E20: 84

Characters:
; Part II font: 5 bytes per character (one byte per column, bit 7 at the top in this listing).
; 00-19 A-Z, 1A ".", 1B space, 1C-25 0-9, 26 "<", 27 ">", 28 "=", 29 "*", 2A cursor "_",
; 2B "-", 2C "?", 2D "!!", 2E-30 the name-entry box.
1E21: 1F 24 44 24 1F ; A   <00>  ..... ..*.. .*.*. *...* *...* ***** *...*
1E26: 7F 49 49 49 36 ; B   <01>  ..... ****. *...* *...* ****. *...* *...*
1E2B: 3E 41 41 41 22 ; C   <02>  ..... .***. *...* *.... *.... *.... *...*
1E30: 7F 41 41 41 3E ; D   <03>  ..... ****. *...* *...* *...* *...* *...*
1E35: 7F 49 49 49 41 ; E   <04>  ..... ***** *.... *.... ****. *.... *....
1E3A: 7F 48 48 48 40 ; F   <05>  ..... ***** *.... *.... ****. *.... *....
1E3F: 3E 41 41 45 47 ; G   <06>  ..... .**** *.... *.... *.... *..** *...*
1E44: 7F 08 08 08 7F ; H   <07>  ..... *...* *...* *...* ***** *...* *...*
1E49: 00 41 7F 41 00 ; I   <08>  ..... .***. ..*.. ..*.. ..*.. ..*.. ..*..
1E4E: 02 01 01 01 7E ; J   <09>  ..... ....* ....* ....* ....* ....* *...*
1E53: 7F 08 14 22 41 ; K   <0A>  ..... *...* *..*. *.*.. **... *.*.. *..*.
1E58: 7F 01 01 01 01 ; L   <0B>  ..... *.... *.... *.... *.... *.... *....
1E5D: 7F 20 18 20 7F ; M   <0C>  ..... *...* **.** *.*.* *.*.* *...* *...*
1E62: 7F 10 08 04 7F ; N   <0D>  ..... *...* *...* **..* *.*.* *..** *...*
1E67: 3E 41 41 41 3E ; O   <0E>  ..... .***. *...* *...* *...* *...* *...*
1E6C: 7F 48 48 48 30 ; P   <0F>  ..... ****. *...* *...* ****. *.... *....
1E71: 3E 41 45 42 3D ; Q   <10>  ..... .***. *...* *...* *...* *.*.* *..*.
1E76: 7F 48 4C 4A 31 ; R   <11>  ..... ****. *...* *...* ****. *.*.. *..*.
1E7B: 32 49 49 49 26 ; S   <12>  ..... .***. *...* *.... .***. ....* *...*
1E80: 40 40 7F 40 40 ; T   <13>  ..... ***** ..*.. ..*.. ..*.. ..*.. ..*..
1E85: 7E 01 01 01 7E ; U   <14>  ..... *...* *...* *...* *...* *...* *...*
1E8A: 7C 02 01 02 7C ; V   <15>  ..... *...* *...* *...* *...* *...* .*.*.
1E8F: 7F 02 0C 02 7F ; W   <16>  ..... *...* *...* *...* *.*.* *.*.* **.**
1E94: 63 14 08 14 63 ; X   <17>  ..... *...* *...* .*.*. ..*.. .*.*. *...*
1E99: 60 10 0F 10 60 ; Y   <18>  ..... *...* *...* .*.*. ..*.. ..*.. ..*..
1E9E: 43 45 49 51 61 ; Z   <19>  ..... ***** ....* ...*. ..*.. .*... *....
1EA3: 00 00 03 03 00 ; .   <1A>  ..... ..... ..... ..... ..... ..... ..**.
1EA8: 00 00 00 00 00 ; spc <1B>  ..... ..... ..... ..... ..... ..... .....
1EAD: 3E 45 49 51 3E ; 0   <1C>  ..... .***. *...* *..** *.*.* **..* *...*
1EB2: 00 21 7F 01 00 ; 1   <1D>  ..... ..*.. .**.. ..*.. ..*.. ..*.. ..*..
1EB7: 23 45 49 49 31 ; 2   <1E>  ..... .***. *...* ....* ..**. .*... *....
1EBC: 42 41 49 59 66 ; 3   <1F>  ..... ***** ....* ...*. ..**. ....* *...*
1EC1: 0C 14 24 7F 04 ; 4   <20>  ..... ...*. ..**. .*.*. *..*. ***** ...*.
1EC6: 72 51 51 51 4E ; 5   <21>  ..... ***** *.... ****. ....* ....* *...*
1ECB: 1E 29 49 49 46 ; 6   <22>  ..... ..*** .*... *.... ****. *...* *...*
1ED0: 40 47 48 50 60 ; 7   <23>  ..... ***** ....* ...*. ..*.. .*... .*...
1ED5: 36 49 49 49 36 ; 8   <24>  ..... .***. *...* *...* .***. *...* *...*
1EDA: 31 49 49 4A 3C ; 9   <25>  ..... .***. *...* *...* .**** ....* ...*.
1EDF: 08 14 22 41 00 ; <   <26>  ..... ...*. ..*.. .*... *.... .*... ..*..
1EE4: 00 41 22 14 08 ; >   <27>  ..... .*... ..*.. ...*. ....* ...*. ..*..
1EE9: 14 14 14 14 14 ; =   <28>  ..... ..... ..... ***** ..... ***** .....
1EEE: 22 14 7F 14 22 ; *   <29>  ..... ..*.. *.*.* .***. ..*.. .***. *.*.*
1EF3: 18 18 18 18 18 ; _   <2A>  ..... ..... ..... ***** ***** ..... .....
1EF8: 08 08 08 08 08 ; -   <2B>  ..... ..... ..... ..... ***** ..... .....
1EFD: 20 40 4D 50 20 ; ?   <2C>  ..... .***. *...* ...*. ..*.. ..*.. .....
1F02: 00 00 79 00 79 ; |   <2D>  ..... ..*.* ..*.* ..*.* ..*.* ..... .....
1F07: 00 00 00 00 C0 ; [   <2E>  ....* ....* ..... ..... ..... ..... .....
1F0C: 40 40 40 40 40 ; ~   <2F>  ..... ***** ..... ..... ..... ..... .....
1F11: C0 00 00 00 00 ; ]   <30>  *.... *.... ..... ..... ..... ..... .....

PicRubEnd:
; "RUB END" for the name-entry screen (40 columns)
; ........................................
; ........................................
; ........................................
; .***..*..*.***...........****.*..*.***..
; .*..*.*..*.*..*..........*....**.*.*..*.
; .***..*..*.***...........***..*.**.*..*.
; .*.*..*..*.*..*..........*....*..*.*..*.
; .*..*..**..***...........****.*..*.***..
1F16: 00 1F 14 16 09 00 1E 01 01 1E 00 1F 15 15 0A 00
1F26: 00 00 00 00 00 00 00 00 00 1F 15 15 11 00 1F 08
1F36: 04 1F 00 1F 11 11 0E 00
1F3E: 0F 14 12 07                         ; "PUSH"

MessageCredit:
1F42: 02 11 04 03 08 13 1B                ; "CREDIT "

ReadPort1:
; A = port 1 (player 1 controls). The address of the IN instruction is built in pieces
; and reached with JP (HL) so a disassembler won't see it (1F52 is the return).
1F49: 21 52 1F        LXI     H,0x1F52            ; Return address ...
1F4C: E5              PUSH    H                   ; ... on the stack
1F4D: 2E EF           MVI     L,0xEF              ; Build the address ...
1F4F: 26 15           MVI     H,0x15              ; ... 15EF (IN A,(01) / RET)
1F51: E9              PCHL                        ; Go read port 1
1F52: C9              RET                         ; (Return point)

ProtChecks:
; Attract mode protection checks (run every interrupt while not in a game).
1F53: CD 9C 45        CALL    0x459C              ; {code.HardwareCheck} Port 0 check
1F56: C3 4F 45        JMP     0x454F              ; {code.CopyrightCheck} Copyright check

; Leftover 8080 assembler source text from the development system (it shows the original
; was written with Intel mnemonics and labels like EXIN1/EXIN2/EXIN3 and PU).
1F59: 0D 0A 09 4A 4E 5A 09 45 58 49 4E 34 0D 0A 09 44 ; \r\n\tJNZ\tEXIN4\r\n\tD
1F69: 43 58 09 48 0D 0A 09 4D 4F 56 09 41 2C 4D 0D 0A ; CX\tH\r\n\tMOV\tA,M\r\n
1F79: 09 41 4E 49 09 38 30 48 0D 0A 09 52 5A 0D 0A 45 ; \tANI\t80H\r\n\tRZ\r\nE
1F89: 58 49 4E 31 3A 09 4C 44 41 09 50 55 2B 30 41 30 ; XIN1:\tLDA\tPU+0A0
1F99: 48 0D 0A 09 41 4E 49 09 30 46 48 0D 0A 09 4D 4F ; H\r\n\tANI\t0FH\r\n\tMO
1FA9: 56 09 42 2C 41 0D 0A 09 4C 44 41 09 50 55 2B 30 ; V\tB,A\r\n\tLDA\tPU+0
1FB9: 41 48 0D 0A 45 58 49 4E 32 3A 09 44 43 52 09 42 ; AH\r\nEXIN2:\tDCR\tB
1FC9: 0D 0A 09 4A 5A 09 45 58 49 4E 33 0D 0A 09 41 44 ; \r\n\tJZ\tEXIN3\r\n\tAD
1FD9: 49 09 31 30 48 0D 0A 09 4A 4D 50 09 45 58 49 4E ; I\t10H\r\n\tJMP\tEXIN
1FE9: 32 0D 0A 3B 0D 0A 45 58 49 4E 33 3A 09 41 44 49 ; 2\r\n;\r\nEXIN3:\tADI
1FF9: 09 30 34 48 FF FF 09                            ; \t04H..\t
```

```code
```

# The Part II Expansion ROM (4000-47FF)

```code

Formations:
; Part II: starting formations for the bottom four rows of aliens (4 rows of 11, bottom row
; first). 0=empty, 1=octopus, 3=crab, 5=squid, 7=small alien. InitAliens picks one with the
; table at 1E10 and always adds a top row of squids.
; Formation 0 (4000):  O=octopus C=crab S=squid s=small .=empty
;    C C C C C C C C C C C
;    C C C C C C C C C C C
;    O O O O O O O O O O O
;    O O O O O O O O O O O
4000: 01 01 01 01 01 01 01 01 01 01 01   ; Row 0 (bottom)
400B: 01 01 01 01 01 01 01 01 01 01 01   ; Row 1
4016: 03 03 03 03 03 03 03 03 03 03 03   ; Row 2
4021: 03 03 03 03 03 03 03 03 03 03 03   ; Row 3
; Formation 1 (402C):  O=octopus C=crab S=squid s=small .=empty
;    S S S S S S S S S S S
;    S S . C C . C C . S S
;    O O O O C C C O O O O
;    O O O O O O O O O O O
402C: 01 01 01 01 01 01 01 01 01 01 01   ; Row 0 (bottom)
4037: 01 01 01 01 03 03 03 01 01 01 01   ; Row 1
4042: 05 05 00 03 03 00 03 03 00 05 05   ; Row 2
404D: 05 05 05 05 05 05 05 05 05 05 05   ; Row 3
; Formation 2 (4058):  O=octopus C=crab S=squid s=small .=empty
;    s s C . S S S . C s s
;    s . S . C S C . S . s
;    O O . C C C C C . O O
;    O C O O O O O O O C O
4058: 01 03 01 01 01 01 01 01 01 03 01   ; Row 0 (bottom)
4063: 01 01 00 03 03 03 03 03 00 01 01   ; Row 1
406E: 07 00 05 00 03 05 03 00 05 00 07   ; Row 2
4079: 07 07 03 00 05 05 05 00 03 07 07   ; Row 3
; Formation 3 (4084):  O=octopus C=crab S=squid s=small .=empty
;    s s s s s s s s s s s
;    S S S . C C C . S S S
;    O C C C . O . C C C O
;    O O O O O O O O O O O
4084: 01 01 01 01 01 01 01 01 01 01 01   ; Row 0 (bottom)
408F: 01 03 03 03 00 01 00 03 03 03 01   ; Row 1
409A: 05 05 05 00 03 03 03 00 05 05 05   ; Row 2
40A5: 07 07 07 07 07 07 07 07 07 07 07   ; Row 3
; Formation 4 (40B0):  O=octopus C=crab S=squid s=small .=empty
;    S S S S C C C S S S S
;    S C C C C C C C C C S
;    O O C C C C C C C O O
;    O O C C C C C C C O O
40B0: 01 01 03 03 03 03 03 03 03 01 01   ; Row 0 (bottom)
40BB: 01 01 03 03 03 03 03 03 03 01 01   ; Row 1
40C6: 05 03 03 03 03 03 03 03 03 03 05   ; Row 2
40D1: 05 05 05 05 03 03 03 05 05 05 05   ; Row 3

TitleScreen:
; Part II: the big "SPACE INVADERS PART II" title. A block of dots is drawn and the
; letters are "carved" out of it a column at a time, then "PART II" is drawn below.
40DC: 21 17 26        LXI     H,0x2617            ; Screen position for the "SPACE" block
40DF: 11 E4 41        LXI     D,0x41E4            ; Dot pattern
40E2: 01 18 08        LXI     B,0x0818            ; 8 columns of 24 bytes
40E5: CD CD 41        CALL    0x41CD              ; {code.FillDots} Fill the block with dots
40E8: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
40EB: 21 17 26        LXI     H,0x2617            ; Same position
40EE: 11 EC 41        LXI     D,0x41EC            ; "SPACE" bitmap
40F1: 01 10 06        LXI     B,0x0610            ; 6 bytes by 16 columns
40F4: CD 48 41        CALL    0x4148              ; {code.CarveBitmap} Carve the letters out of the dots
40F7: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
40FA: 21 0D 26        LXI     H,0x260D            ; Screen position for the "INVADERS" block
40FD: 11 E4 41        LXI     D,0x41E4            ; Dot pattern
4100: 01 18 04        LXI     B,0x0418            ; 4 columns of 24 bytes
4103: CD CD 41        CALL    0x41CD              ; {code.FillDots} Fill the block with dots
4106: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
4109: 21 0D 26        LXI     H,0x260D            ; Same position
410C: 11 4C 42        LXI     D,0x424C            ; "INVADERS" bitmap
410F: 01 08 06        LXI     B,0x0608            ; 6 bytes by 8 columns
4112: CD 48 41        CALL    0x4148              ; {code.CarveBitmap} Carve it
4115: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
4118: 21 06 2E        LXI     H,0x2E06            ; Screen position for "PART II"
411B: 11 7C 42        LXI     D,0x427C            ; "PART II" bitmap
411E: 01 02 38        LXI     B,0x3802            ; 56 rows of 2 bytes
4121: CD 33 41        CALL    0x4133              ; {code.CopyBitmap} Draw it
4124: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
4127: CD 19 17        CALL    0x1719              ; {code.DrawScores} Redraw the score lines
412A: CD D2 0D        CALL    0x0DD2              ; {code.FlashHiName} *TAITO CORPORATION* and flash the high score holder
412D: CD 9D 0C        CALL    0x0C9D              ; {code.OneSecDelay} Wait
4130: C3 A3 0B        JMP     0x0BA3              ; {code.ClearPlayField} Clear and out

CopyBitmap:
; Copy a C-byte by B-row bitmap from DE to the screen at HL.
4133: C5              PUSH    B                   ; Hold counts
4134: E5              PUSH    H                   ; Hold screen position
4135: 1A              LDAX    D                   ; Get bitmap byte
4136: 77              MOV     M,A                 ; To screen
4137: 23              INX     H                   ; Next screen byte
4138: 13              INX     D                   ; Next bitmap byte
4139: 0D              DCR     C                   ; All bytes in this row?
413A: C2 35 41        JNZ     0x4135              ; {} No ... do them all
413D: E1              POP     H                   ; Restore screen position
413E: 01 20 00        LXI     B,0x0020            ; Next ...
4141: 09              DAD     B                   ; ... row
4142: C1              POP     B                   ; Restore counts
4143: 05              DCR     B                   ; All rows?
4144: C2 33 41        JNZ     0x4133              ; {} No ... do them all
4147: C9              RET                         ; Done

CarveBitmap:
; For each bit of the bitmap that is 0 erase a 4-pixel wide group of dots. The erasing
; is slowed down so the letters appear to be cut out of the block.
4148: E5              PUSH    H                   ; Hold screen position
4149: C5              PUSH    B                   ; Hold counts
414A: D5              PUSH    D                   ; Hold bitmap pointer
414B: 0E 08           MVI     C,0x08              ; 8 bits per byte
414D: 1A              LDAX    D                   ; Bitmap byte
414E: 0F              RRC                         ; Next bit to carry
414F: F5              PUSH    PSW                 ; Hold remaining bits
4150: D2 A4 41        JNC     0x41A4              ; {code.CarveGroup} A 0 bit ... erase this group of dots
4153: C5              PUSH    B                   ; Hold counts
4154: 0E 04           MVI     C,0x04              ; Skip ...
4156: 11 20 00        LXI     D,0x0020            ; ... 4 ...
4159: 19              DAD     D                   ; ... columns
415A: 0D              DCR     C                   ; ...
415B: C2 59 41        JNZ     0x4159              ; {} ...
415E: C1              POP     B                   ; Restore counts
415F: F1              POP     PSW                 ; Restore remaining bits
4160: 0D              DCR     C                   ; All 8 bits?
4161: C2 4E 41        JNZ     0x414E              ; {} No ... next bit
4164: D1              POP     D                   ; Restore bitmap pointer
4165: 13              INX     D                   ; Next bitmap byte
4166: 05              DCR     B                   ; All bytes in this column?
4167: C2 4A 41        JNZ     0x414A              ; {} No ... keep going
416A: 21 B0 20        LXI     H,0x20B0            ; Two passes ...
416D: 34              INR     M                   ; ... (the dots are offset by a byte ...
416E: 7E              MOV     A,M                 ; ... every other pass)
416F: E6 02           ANI     0x02                ; Second pass?
4171: CA 7C 41        JZ      0x417C              ; {} No
4174: 36 00           MVI     M,0x00              ; Reset pass counter
4176: C1              POP     B                   ; Restore counts
4177: E1              POP     H                   ; Restore screen position
4178: 2B              DCX     H                   ; Back one byte for the next column
4179: C3 7E 41        JMP     0x417E              ; {} Continue
417C: C1              POP     B                   ; Restore counts
417D: E1              POP     H                   ; Restore screen position
417E: 0D              DCR     C                   ; All columns?
417F: C2 48 41        JNZ     0x4148              ; {code.CarveBitmap} No ... do them all
4182: AF              XRA     A                   ; Clear ...
4183: 32 B0 20        STA     0x20B0              ; ... pass counter
4186: 26 1F           MVI     H,0x1F              ; Hidden test feature: build 20E3 ...
4188: 2E E4           MVI     L,0xE4              ; ... in pieces ...
418A: 24              INR     H                   ; ...
418B: 2D              DCR     L                   ; ...
418C: 7E              MOV     A,M                 ; Is the hardware-check flag still set?
418D: A7              ANA     A                   ; Set flags
418E: C8              RZ                          ; No ... done
418F: CD 49 1F        CALL    0x1F49              ; {code.ReadPort1} Read the switches
4192: E6 76           ANI     0x76                ; Start1, Start2, fire, left, right
4194: FE 36           CPI     0x36                ; Start1+Start2+fire+left held?
4196: C0              RNZ                         ; No ... done
4197: 2E EC           MVI     L,0xEC              ; Build 20EB ...
4199: 2D              DCR     L                   ; ... (credits) ...
419A: 26 1F           MVI     H,0x1F              ; ... in ...
419C: 24              INR     H                   ; ... pieces
419D: 36 02           MVI     M,0x02              ; 2 credits
419F: 2E CC           MVI     L,0xCC              ; Shadow copy ...
41A1: 36 02           MVI     M,0x02              ; ... too
41A3: C9              RET                         ; Done

CarveGroup:
41A4: C5              PUSH    B                   ; Hold counts
41A5: 0E 03           MVI     C,0x03              ; Three bytes
41A7: 3A B0 20        LDA     0x20B0              ; Which pass?
41AA: FE 01           CPI     0x01                ; Pass 1?
41AC: C2 C8 41        JNZ     0x41C8              ; {} No ... other mask
41AF: 3E E0           MVI     A,0xE0              ; Mask for pass 1
41B1: 46              MOV     B,M                 ; Screen byte
41B2: A0              ANA     B                   ; Mask it
41B3: 77              MOV     M,A                 ; Back to screen
41B4: 11 20 00        LXI     D,0x0020            ; Next ...
41B7: 19              DAD     D                   ; ... column
41B8: 0D              DCR     C                   ; All 3?
41B9: C2 B1 41        JNZ     0x41B1              ; {} No ... do them all
41BC: 19              DAD     D                   ; Skip a column
41BD: 01 50 02        LXI     B,0x0250            ; Short ...
41C0: CD C9 0E        CALL    0x0EC9              ; {code.DelayBC} ... delay
41C3: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
41C5: C3 5E 41        JMP     0x415E              ; {} Continue
41C8: 3E 0E           MVI     A,0x0E              ; Mask for pass 2
41CA: C3 B1 41        JMP     0x41B1              ; {} Continue

FillDots:
; Fill a block of the screen with the 8-byte dot pattern at DE (C columns of B bytes).
41CD: E5              PUSH    H                   ; Hold screen position
41CE: C5              PUSH    B                   ; Hold counts
41CF: D5              PUSH    D                   ; Hold pattern pointer
41D0: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
41D2: 06 08           MVI     B,0x08              ; 8 bytes in the pattern
41D4: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw it
41D7: D1              POP     D                   ; Restore pattern pointer
41D8: 0D              DCR     C                   ; All columns?
41D9: C2 CF 41        JNZ     0x41CF              ; {} No ... do them all
41DC: C1              POP     B                   ; Restore counts
41DD: E1              POP     H                   ; Restore screen position
41DE: 2B              DCX     H                   ; Next byte up
41DF: 05              DCR     B                   ; All rows?
41E0: C2 CD 41        JNZ     0x41CD              ; {code.FillDots} No ... do them all
41E3: C9              RET                         ; Done
41E4: EE EE EE 00 EE EE EE 00
; ....******...***....***.***.......***...***.....
; ....******..*****...***.***.......***..*****....
; ....******.*******.***...***......***..******...
; .......***.***.***.***...***......***..**..**...
; .......**..***.***..***.***.......***..**..**...
; .......**......***..***.***.......***..***......
; ...******......***...*****.....******..*****....
; ...******......***.*********..*******...******..
; ...*****......***..***.*.***.*********....*****.
; .....***......***..***.*.***.***...***......***.
; .....***.***..***..*********.***...***..***..***
; .....***.***..***..*********.***...***..***...**
; *******..********...*******..*********..********
; *******..********...*******..*********..********
; *******...******.....*****....********...*******
; *******....****......*****.....*******.....****.
41EC: 1E FC C1 07 1E FE
41F2: 7F FC C3 07 3F FE
41F8: FF FC E7 8F 7F FE
41FE: FF FC E7 8F 7F FE
4204: E3 1C F7 9F 73 07
420A: E7 1C F7 9F 73 07
4210: 0E 1C 77 9D 03 07
4216: 3E FC 77 9D 03 1F
421C: FC F8 F3 DF 81 1F
4222: F0 F9 C1 C7 81 1F
4228: C0 39 E0 CE 81 01
422E: 98 39 E0 CE 9D 01
4234: 98 39 70 DC DD 01
423A: F8 39 70 DC DF 0F
4240: F0 39 E0 8E CF 0F
4246: E0 38 E0 0E C7 0F
; ..***..**.**.*****..****.**.**...**...**..**.**.
; .**.**.**.**....**.**.**.**.**...**...**..**.**.
; .**....**.**....**.**.**.**.**..****..***.**.**.
; ..***...****..****.**.**.*****..****..******.**.
; ....**.**.**....**.**.**.**.**.**..**.******.**.
; ....**.**.**....**.**.**.**.**.**..**.**.***.**.
; .**.**.**.**....**.**.**..***..**..**.**..**.**.
; ..***...****.*****..****..***..**..**.**..**.**.
424C: 36 9B 39 CF F7 38
4252: 36 9B 39 DB B0 6D
4258: 76 9B 6D DB B0 0D
425E: F6 9B 6D DB B0 0D
4264: F6 F3 7C DB F3 38
426A: B6 F3 6C DB B0 61
4270: 36 63 6C DB B0 6D
4276: 36 63 6C CF B7 39
; ******......****....******....*********.......**********
; *******.....****....*******...*********.......**********
; ********...******...********..*********.......**********
; ********...******...********..*********.......**********
; ***..***..***..***..***..***.....***...........***..***.
; ***..***..***..***..***..***.....***...........***..***.
; ***..***..***..***..***..***.....***...........***..***.
; ********..********..********.....***...........***..***.
; *******...********..*******......***...........***..***.
; ******....********..******.......***...........***..***.
; ***.......***..***..***.***......***...........***..***.
; ***.......***..***..***..***.....***...........***..***.
; ***.......***..***..***..***.....***...........***..***.
; ***.......***..***..***..***.....***..........**********
; ***.......***..***..***..***.....***..........**********
; ***.......***..***..***..***.....***..........**********
427C: FF FF FF FF FF FF C0 F1 C0 F1 C0 FF 80 7F 00 3F
428C: 00 00 00 00 FF 0F FF 3F FF FF C0 F1 C0 F1 FF FF
429C: FF 3F FF 0F 00 00 00 00 FF FF FF FF FF FF C0 F1
42AC: E0 F1 FF FF BF 7F 1F 3F 00 00 00 00 00 F0 00 F0
42BC: 00 F0 FF FF FF FF FF FF 00 F0 00 F0 00 F0 00 00
42CC: 00 00 00 00 00 00 00 00 00 00 00 00 07 F0 FF FF
42DC: FF FF FF FF 07 F0 07 F0 FF FF FF FF FF FF 07 F0

SaucerDrop:
; Part II: from round 2 on the saucer refills gaps in the top row of the rack. While the
; saucer flies, the first empty slot of the top row (searching from the end it is heading
; toward) is picked. When the saucer is over that column it stops and a new alien
; drops from it down to the rack. In rounds 2 and 3 only one alien is dropped per rack.
; Runs in the mid-screen ISR. It finishes by running the other game objects itself.
42EC: CD F9 07        CALL    0x07F9              ; {code.GetRoundNum} Round number
42EF: FE 02           CPI     0x02                ; Round 0 or 1?
42F1: D8              RC                          ; Yes ... no drops
42F2: FE 04           CPI     0x04                ; Round 4 or more?
42F4: D2 FC 42        JNC     0x42FC              ; {} Yes ... any number of drops
42F7: 3A B8 20        LDA     0x20B8              ; {ram.dropOnce} Already dropped one this rack?
42FA: A7              ANA     A                   ; Set flags
42FB: C0              RNZ                         ; Yes ... no more
42FC: 3A AD 20        LDA     0x20AD              ; {ram.dropHit} Was the falling alien just shot?
42FF: A7              ANA     A                   ; Set flags
4300: C0              RNZ                         ; Yes ... nothing more until it is cleaned up
4301: CD BB 43        CALL    0x43BB              ; {code.FindDropSlot} Pick an empty slot if the saucer is flying
4304: 21 A1 20        LXI     H,0x20A1            ; {ram.dropActive} Already dropping?
4307: 7E              MOV     A,M                 ; Get flag
4308: A7              ANA     A                   ; Set flags
4309: C2 5E 43        JNZ     0x435E              ; {} Yes ... keep it going
430C: 2B              DCX     H                   ; 20A0
430D: 7E              MOV     A,M                 ; Slot picked ...
430E: E6 80           ANI     0x80                ; ... (bit 7)?
4310: C8              RZ                          ; No ... out
4311: 3A A0 20        LDA     0x20A0              ; {ram.dropColumn} Column (1-11) ...
4314: E6 0F           ANI     0x0F                ; ... of the slot
4316: 47              MOV     B,A                 ; To B
4317: 3A 0A 20        LDA     0x200A              ; {ram.refAlienXr} Rack's X
431A: 05              DCR     B                   ; Count ...
431B: CA 23 43        JZ      0x4323              ; {} ... columns
431E: C6 10           ADI     0x10                ; 16 pixels per column
4320: C3 1A 43        JMP     0x431A              ; {} Keep counting
4323: C6 04           ADI     0x04                ; Center of the slot
4325: 32 A5 20        STA     0x20A5              ; {ram.dropXr} Falling alien's X
4328: DE 08           SBI     0x08                ; Back up ...
432A: E6 FE           ANI     0xFE                ; ... (even)
432C: 47              MOV     B,A                 ; To B
432D: 21 8A 20        LXI     H,0x208A            ; {ram.saucerPriPicMSB} Saucer's X
4330: 7E              MOV     A,M                 ; Get it
4331: E6 FE           ANI     0xFE                ; (even)
4333: B8              CMP     B                   ; Is the saucer over the slot?
4334: C0              RNZ                         ; No ... out
4335: 3A 09 20        LDA     0x2009              ; {ram.refAlienYr} Rack Y ...
4338: C6 40           ADI     0x40                ; ... plus 4 rows
433A: 32 A9 20        STA     0x20A9              ; {ram.dropTargetY} Where the alien joins the rack
433D: 3A 06 20        LDA     0x2006              ; {ram.alienCurIndex} Has the alien cursor ...
4340: 21 AA 20        LXI     H,0x20AA            ; {ram.dropSlotL} ... passed the slot?
4343: BE              CMP     M                   ; Compare
4344: D2 59 43        JNC     0x4359              ; {} Yes
4347: 06 02           MVI     B,0x02              ; Adjust X ...
4349: 3A 0D 20        LDA     0x200D              ; {ram.rackDirection} ... for the rack's ...
434C: A7              ANA     A                   ; ... direction ...
434D: C2 52 43        JNZ     0x4352              ; {} ... of motion
4350: 06 FE           MVI     B,0xFE              ; ... left
4352: 3A A5 20        LDA     0x20A5              ; {ram.dropXr} Adjust ...
4355: 80              ADD     B                   ; ... the ...
4356: 32 A5 20        STA     0x20A5              ; {ram.dropXr} ... X
4359: 3E 01           MVI     A,0x01              ; Start ...
435B: 32 A1 20        STA     0x20A1              ; {ram.dropActive} ... the drop
435E: 21 A4 20        LXI     H,0x20A4            ; {ram.dropYr} Falling-alien descriptor (20A4)
4361: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Read it
4364: EB              XCHG                        ; Position to HL
4365: 3A A9 20        LDA     0x20A9              ; {ram.dropTargetY} Has it fallen ...
4368: BD              CMP     L                   ; ... to the rack?
4369: DA 79 43        JC      0x4379              ; {} No ... keep going
436C: 2A AA 20        LHLD    0x20AA              ; {ram.dropSlotL} Yes ... the slot ...
436F: 36 05           MVI     M,0x05              ; ... gets a squid
4371: CD A3 43        CALL    0x43A3              ; {code.ResetDrop} Reset the drop variables
4374: 3E 01           MVI     A,0x01              ; Flag ...
4376: 32 B7 20        STA     0x20B7              ; {ram.dropDone} ... an alien was dropped
4379: 21 20 20        LXI     H,0x2020            ; {ram.obj1TimerMSB} Game objects (skip the player)
437C: CD 91 02        CALL    0x0291              ; {} Run them
437F: E1              POP     H                   ; Drop our return
4380: C3 94 00        JMP     0x0094              ; {code.ISRExit} Out of the ISR

SaucerDropMove:
; Part II: (end-of-screen ISR) move and draw the alien falling from the saucer.
4383: 21 A1 20        LXI     H,0x20A1            ; {ram.dropActive} Dropping?
4386: 7E              MOV     A,M                 ; Get flag
4387: A7              ANA     A                   ; Set flags
4388: C8              RZ                          ; No ... out
4389: 21 A2 20        LXI     H,0x20A2            ; {ram.dropDeltaY} Falling-alien deltas
438C: 4E              MOV     C,M                 ; Delta X
438D: CD 1F 02        CALL    0x021F              ; {code.AddDelta} Move it
4390: 21 A4 20        LXI     H,0x20A4            ; {ram.dropYr} Falling-alien descriptor
4393: CD BB 17        CALL    0x17BB              ; {code.ReadDesc} Read it
4396: EB              XCHG                        ; Position to HL
4397: 7D              MOV     A,L                 ; Still above ...
4398: FE 2F           CPI     0x2F                ; ... the player area?
439A: D2 AE 43        JNC     0x43AE              ; {} Yes ... draw it
439D: 11 8C 45        LXI     D,0x458C            ; Fell all the way: squid on its side
43A0: CD 96 13        CALL    0x1396              ; {code.DrawSprite} Erase it

ResetDrop:
43A3: 06 0E           MVI     B,0x0E              ; 14 bytes
43A5: 21 A0 20        LXI     H,0x20A0            ; {ram.dropColumn} Drop variables
43A8: 11 A0 1B        LXI     D,0x1BA0            ; From the RAM mirror (1BA0)
43AB: C3 B2 17        JMP     0x17B2              ; {code.BlockCopy} Reset them
43AE: 3A AD 20        LDA     0x20AD              ; {ram.dropHit} Was it shot?
43B1: A7              ANA     A                   ; Set flags
43B2: CA B8 43        JZ      0x43B8              ; {} No ... draw the alien
43B5: 11 94 45        LXI     D,0x4594            ; Yes ... draw it upside down (4594)
43B8: C3 96 13        JMP     0x1396              ; {code.DrawSprite} Draw it and out

FindDropSlot:
43BB: 3A 84 20        LDA     0x2084              ; {ram.saucerActive} Saucer flying?
43BE: A7              ANA     A                   ; Set flags
43BF: CA FF 43        JZ      0x43FF              ; {} No ... clear the pending flag
43C2: 3A A1 20        LDA     0x20A1              ; {ram.dropActive} Already dropping?
43C5: A7              ANA     A                   ; Set flags
43C6: C0              RNZ                         ; Yes ... out
43C7: 4F              MOV     C,A                 ; (Hold a 0)
43C8: 3A 8C 20        LDA     0x208C              ; {ram.saucerDeltaY} Saucer moving ...
43CB: FE 02           CPI     0x02                ; ... right?
43CD: 79              MOV     A,C                 ; (no effect)
43CE: 3A 67 20        LDA     0x2067              ; {ram.playerDataMSB} Player's ...
43D1: 67              MOV     H,A                 ; ... aliens
43D2: 06 0B           MVI     B,0x0B              ; 11 slots in the top row
43D4: C2 E4 43        JNZ     0x43E4              ; {} Moving left ... search from the right
43D7: 2E 2C           MVI     L,0x2C              ; Top row starts at 2C
43D9: 7E              MOV     A,M                 ; Empty ...
43DA: A7              ANA     A                   ; ... slot?
43DB: CA F1 43        JZ      0x43F1              ; {} Yes ... pick it
43DE: 23              INX     H                   ; Next slot
43DF: 05              DCR     B                   ; All 11?
43E0: C2 D9 43        JNZ     0x43D9              ; {} No ... keep looking
43E3: C9              RET                         ; Top row is full
43E4: 2E 36           MVI     L,0x36              ; Top row ends at 36
43E6: 7E              MOV     A,M                 ; Empty ...
43E7: A7              ANA     A                   ; ... slot?
43E8: CA F1 43        JZ      0x43F1              ; {} Yes ... pick it
43EB: 2B              DCX     H                   ; Previous slot
43EC: 05              DCR     B                   ; All 11?
43ED: C2 E6 43        JNZ     0x43E6              ; {} No ... keep looking
43F0: C9              RET                         ; Top row is full
43F1: 22 AA 20        SHLD    0x20AA              ; {ram.dropSlotL} Remember the slot
43F4: 7D              MOV     A,L                 ; Slot number ...
43F5: C6 05           ADI     0x05                ; ... to column ...
43F7: E6 0F           ANI     0x0F                ; ... 1-11
43F9: F6 80           ORI     0x80                ; Flag "slot picked"
43FB: 32 A0 20        STA     0x20A0              ; {ram.dropColumn} Store it
43FE: C9              RET                         ; Done
43FF: 3A A0 20        LDA     0x20A0              ; {ram.dropColumn} Saucer gone ...
4402: E6 7F           ANI     0x7F                ; ... clear ...
4404: 32 A0 20        STA     0x20A0              ; {ram.dropColumn} ... the pending flag
4407: 21 B7 20        LXI     H,0x20B7            ; {ram.dropDone} Did we drop an alien?
440A: 7E              MOV     A,M                 ; Get flag
440B: A7              ANA     A                   ; Set flags
440C: C8              RZ                          ; No ... out
440D: 23              INX     H                   ; 20B8
440E: 77              MOV     M,A                 ; Remember it (rounds 2-3 only get one)
440F: C9              RET                         ; Done

RackBonus:
; Part II: the last alien was a bonus alien (see 13D2). Award 500, 800 or 1000 and show
; "BONUS xxx POINTS" with light beams fanning out from where the alien was.
4410: 3A AE 20        LDA     0x20AE              ; {ram.lastAlienBonus} Bonus earned?
4413: A7              ANA     A                   ; Set flags
4414: C8              RZ                          ; No ... out
4415: CD 58 17        CALL    0x1758              ; {code.DsableGameTasks} Stop the game tasks
4418: CD 53 46        CALL    0x4653              ; {code.BonusValue} HL = bonus (50, 80 or 100 = 500/800/1000)
441B: 22 F2 20        SHLD    0x20F2              ; {ram.scoreDeltaLSB} Score delta
441E: 3E 01           MVI     A,0x01              ; Flag ...
4420: 32 F1 20        STA     0x20F1              ; {ram.adjustScore} ... the score change
4423: CD 58 0B        CALL    0x0B58              ; {code.AdjustScore} Add it to the score
4426: 3E 02           MVI     A,0x02              ; Start ...
4428: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} ... the sound pulse timer
442B: 21 04 29        LXI     H,0x2904            ; Screen coordinates
442E: 11 08 45        LXI     D,0x4508            ; "BONUS  500 POINTS"
4431: 0E 11           MVI     C,0x11              ; 17 characters
4433: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print it
4436: 01 B4 20        LXI     B,0x20B4            ; {ram.bonus800} 800?
4439: 0A              LDAX    B                   ; Get flag
443A: A7              ANA     A                   ; Set flags
443B: 11 C6 09        LXI     D,0x09C6            ; " 8" (800)
443E: C2 49 44        JNZ     0x4449              ; {} Yes ... patch the message
4441: 0B              DCX     B                   ; 20B3
4442: 0A              LDAX    B                   ; 1000?
4443: A7              ANA     A                   ; Set flags
4444: CA 51 44        JZ      0x4451              ; {} No ... leave "500"
4447: 13              INX     D                   ; "10" ...
4448: 13              INX     D                   ; ... (1000)
4449: 21 04 2F        LXI     H,0x2F04            ; Over the " 5"
444C: 0E 02           MVI     C,0x02              ; 2 characters
444E: CD D9 0A        CALL    0x0AD9              ; {code.PrintMessage} Print it
4451: 21 10 23        LXI     H,0x2310            ; {ram.beamCount} Beam variables
4454: 11 04 45        LXI     D,0x4504            ; Initial values
4457: 06 04           MVI     B,0x04              ; 4 bytes
4459: CD B2 17        CALL    0x17B2              ; {code.BlockCopy} Initialize
445C: 2A 0B 20        LHLD    0x200B              ; {ram.alienPosLSB} Where the alien was
445F: 3E 07           MVI     A,0x07              ; Center ...
4461: 84              ADD     H                   ; ... of ...
4462: 67              MOV     H,A                 ; ... it
4463: 22 12 23        SHLD    0x2312              ; {ram.beamOriginL} Beam origin
4466: CD 89 44        CALL    0x4489              ; {code.BeamDot} Plot the origin
4469: CD E3 44        CALL    0x44E3              ; {code.BeamNextRow} Move up a row
446C: 7D              MOV     A,L                 ; Top ...
446D: FE C8           CPI     0xC8                ; ... of screen?
446F: D2 EB 44        JNC     0x44EB              ; {code.BeamDone} Yes ... this fan is done
4472: CD CF 44        CALL    0x44CF              ; {code.BeamDot} Center dot
4475: E5              PUSH    H                   ; Hold position
4476: CD A3 44        CALL    0x44A3              ; {code.BeamLeft} Dots to the left
4479: E1              POP     H                   ; Restore position
447A: CD B9 44        CALL    0x44B9              ; {code.BeamRight} Dots to the right
447D: 21 10 23        LXI     H,0x2310            ; {ram.beamCount} Wider ...
4480: 34              INR     M                   ; ... each row
4481: 23              INX     H                   ; Spread ...
4482: 34              INR     M                   ; ... more each row
4483: CD E0 44        CALL    0x44E0              ; {code.BeamNext} Next row up
4486: C3 6C 44        JMP     0x446C              ; {} Keep going

BeamDot1:
4489: CD CF 44        CALL    0x44CF              ; {code.BeamDot} Plot the origin
448C: 3A C0 20        LDA     0x20C0              ; {ram.isrDelay} Sound pulse
448F: A7              ANA     A                   ; Set flags
4490: CA 9B 44        JZ      0x449B              ; {} Timer done ... sound off
4493: 3E 02           MVI     A,0x02              ; Restart ...
4495: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} ... the timer
4498: C3 3A 16        JMP     0x163A              ; {code.SaucerSndOn} Saucer sound on
449B: 3E 00           MVI     A,0x00              ; Timer ...
449D: 32 C0 20        STA     0x20C0              ; {ram.isrDelay} ... cleared
44A0: C3 BA 07        JMP     0x07BA              ; {code.SaucerSndOff} Saucer sound off

BeamLeft:
44A3: 3A 10 23        LDA     0x2310              ; {ram.beamCount} Number of dots
44A6: 4F              MOV     C,A                 ; To C
44A7: 3A 11 23        LDA     0x2311              ; {ram.beamStep} Spread
44AA: 47              MOV     B,A                 ; To B
44AB: 7C              MOV     A,H                 ; Move ...
44AC: 90              SUB     B                   ; ... left
44AD: 67              MOV     H,A                 ; ...
44AE: FE 38           CPI     0x38                ; Off the left side?
44B0: D8              RC                          ; Yes ... done
44B1: CD CF 44        CALL    0x44CF              ; {code.BeamDot} Plot a dot
44B4: 0D              DCR     C                   ; All dots?
44B5: C2 A7 44        JNZ     0x44A7              ; {} No ... do them all
44B8: C9              RET                         ; Done

BeamRight:
44B9: 3A 10 23        LDA     0x2310              ; {ram.beamCount} Number of dots
44BC: 4F              MOV     C,A                 ; To C
44BD: 3A 11 23        LDA     0x2311              ; {ram.beamStep} Spread
44C0: 47              MOV     B,A                 ; To B
44C1: 7C              MOV     A,H                 ; Move ...
44C2: 80              ADD     B                   ; ... right
44C3: 67              MOV     H,A                 ; ...
44C4: FE E8           CPI     0xE8                ; Off the right side?
44C6: D0              RNC                         ; Yes ... done
44C7: CD CF 44        CALL    0x44CF              ; {code.BeamDot} Plot a dot
44CA: 0D              DCR     C                   ; All dots?
44CB: C2 BD 44        JNZ     0x44BD              ; {} No ... do them all
44CE: C9              RET                         ; Done

BeamDot:
44CF: E5              PUSH    H                   ; Hold position
44D0: CD C7 17        CALL    0x17C7              ; {code.ConvToScr} Screen address
44D3: 3E 0F           MVI     A,0x0F              ; 4 pixel dash
44D5: 77              MOV     M,A                 ; Plot it
44D6: E1              POP     H                   ; Restore position
44D7: C5              PUSH    B                   ; Hold counts
44D8: 01 20 03        LXI     B,0x0320            ; Short ...
44DB: CD C9 0E        CALL    0x0EC9              ; {code.DelayBC} ... delay
44DE: C1              POP     B                   ; Restore counts
44DF: C9              RET                         ; Done

BeamNext:
44E0: 2A 12 23        LHLD    0x2312              ; {ram.beamOriginL} Current row

BeamNextRow:
44E3: 3E 08           MVI     A,0x08              ; Up ...
44E5: 85              ADD     L                   ; ... 8 ...
44E6: 6F              MOV     L,A                 ; ... pixels
44E7: 22 12 23        SHLD    0x2312              ; {ram.beamOriginL} Store
44EA: C9              RET                         ; Done

BeamDone:
44EB: 21 BE 20        LXI     H,0x20BE            ; {ram.bonusBeamCnt} Count ...
44EE: 34              INR     M                   ; ... the fans
44EF: 3A B5 20        LDA     0x20B5              ; {ram.bonusBeams} Number of fans for this bonus
44F2: BE              CMP     M                   ; Done them all?
44F3: DA FC 44        JC      0x44FC              ; {} Yes
44F6: CD A3 0B        CALL    0x0BA3              ; {code.ClearPlayField} Clear ...
44F9: C3 2B 44        JMP     0x442B              ; {} ... and do it again
44FC: 36 00           MVI     M,0x00              ; Reset count
44FE: CD BA 07        CALL    0x07BA              ; {code.SaucerSndOff} Sound off
4501: C3 A2 0C        JMP     0x0CA2              ; {code.TwoSecDelay} Wait and out
4504: 01 02 00 00
4508: 01 0E 0D 14 12 1B 1B 21 1C 1C 1B 0F ; "BONUS  500 P"
4514: 0E 08 0D 13 12                      ; "OINTS"

CheckHiddenMes:
; Part II version of the hidden message: in the demo hold Start2+fire+right and then
; Start1+fire+left to see "TAITO CORP." (the text is scrambled in ROM at 0D6E).
4519: 26 20           MVI     H,0x20              ; Build 201E ...
451B: 2E 1E           MVI     L,0x1E              ; ... in pieces
451D: 7E              MOV     A,M                 ; {ram.hidMessSeq} First sequence done?
451E: A7              ANA     A                   ; Set flags
451F: C2 2E 45        JNZ     0x452E              ; {} Yes ... look for the second
4522: CD 49 1F        CALL    0x1F49              ; {code.ReadPort1} Read switches
4525: E6 76           ANI     0x76                ; Start1, Start2, fire, left, right
4527: D6 52           SUI     0x52                ; Start2+fire+right?
4529: C0              RNZ                         ; No ... out
452A: 3C              INR     A                   ; 1
452B: 32 1E 20        STA     0x201E              ; {ram.hidMessSeq} First sequence done
452E: CD 49 1F        CALL    0x1F49              ; {code.ReadPort1} Read switches
4531: E6 76           ANI     0x76                ; Start1, Start2, fire, left, right
4533: FE 34           CPI     0x34                ; Start1+fire+left?
4535: C0              RNZ                         ; No ... out
4536: 26 2C           MVI     H,0x2C              ; Screen ...
4538: 2E 1B           MVI     L,0x1B              ; ... position
453A: 16 0D           MVI     D,0x0D              ; Scrambled ...
453C: 1E 78           MVI     E,0x78              ; ... message (end of 0D6E-0D78)
453E: 0E 0A           MVI     C,0x0A              ; 10 ...
4540: 0C              INR     C                   ; ... +1 = 11 characters
4541: 1A              LDAX    D                   ; Scrambled character
4542: C6 3F           ADI     0x3F                ; Unscramble
4544: D5              PUSH    D                   ; Hold pointer
4545: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Print it
4548: D1              POP     D                   ; Restore pointer
4549: 1B              DCX     D                   ; Backwards through the message
454A: 0D              DCR     C                   ; All done?
454B: C2 41 45        JNZ     0x4541              ; {} No ... do them all
454E: C9              RET                         ; Done

CopyrightCheck:
; If the scrambled "TAITO" at 174C is intact clear the tamper flag 20E2.
454F: 21 D0 DB        LXI     H,0xDBD0            ; (HL = D0 DB)
4552: 01 DB C8        LXI     B,0xC8DB            ; (BC = DB C8)
4555: 11 4C 17        LXI     D,0x174C            ; Scrambled "TAITO" in "*TAITO CORPORATION*"
4558: 1A              LDAX    D                   ; First byte ...
4559: FE D6           CPI     0xD6                ; ... D6?
455B: C0              RNZ                         ; No ... leave flag set
455C: 13              INX     D                   ; Next
455D: 1A              LDAX    D                   ; Get byte
455E: BC              CMP     H                   ; DB?
455F: C0              RNZ                         ; No ... leave flag set
4560: 13              INX     D                   ; Next
4561: 1A              LDAX    D                   ; Get byte
4562: BD              CMP     L                   ; D0?
4563: C0              RNZ                         ; No ... leave flag set
4564: 13              INX     D                   ; Next
4565: 1A              LDAX    D                   ; Get byte
4566: B8              CMP     B                   ; DB?
4567: C0              RNZ                         ; No ... leave flag set
4568: 13              INX     D                   ; Next
4569: 1A              LDAX    D                   ; Get byte
456A: B9              CMP     C                   ; C8?
456B: C0              RNZ                         ; No ... leave flag set
456C: 2E E2           MVI     L,0xE2              ; Build 20E2 ...
456E: 26 20           MVI     H,0x20              ; ... in pieces
4570: 36 00           MVI     M,0x00              ; Clear the tamper flag
4572: C9              RET                         ; Done

PrintCorp:
; Print "*TAITO CORPORATION*" (scrambled backwards at 173F).
4573: 26 28           MVI     H,0x28              ; Screen ...
4575: 2E 03           MVI     L,0x03              ; ... position
4577: 1E 51           MVI     E,0x51              ; End of ...
4579: 16 17           MVI     D,0x17              ; ... the scrambled text (1751)
457B: 0E 12           MVI     C,0x12              ; 18 ...
457D: 0C              INR     C                   ; ... +1 = 19 characters
457E: 1A              LDAX    D                   ; Scrambled character
457F: C6 38           ADI     0x38                ; Unscramble
4581: D5              PUSH    D                   ; Hold pointer
4582: CD E5 0A        CALL    0x0AE5              ; {code.DrawChar} Print it
4585: D1              POP     D                   ; Restore pointer
4586: 1B              DCX     D                   ; Backwards
4587: 0D              DCR     C                   ; All done?
4588: C2 7E 45        JNZ     0x457E              ; {} No ... do them all
458B: C9              RET                         ; Done
; ...**..*
; ..***.*.
; .**.**.*
; *****.*.
; *****.*.
; .**.**.*
; ..***.*.
; ...**..*
458C: 18 3C 7E DB FF 24 5A A5
; *.*..*.*
; .*.**.*.
; ..*..*..
; ********
; **.**.**
; .******.
; ..****..
; ...**...
4594: 98 5C B6 5F 5F B6 5C 98

HardwareCheck:
; Port 0 bits 1 and 3: both set means the wrong hardware ... restart. Both clear clears
; the 20E3 flag (which otherwise allows a hidden free-credit button combination).
459C: DB 00           IN      0x00                ; {hard.INP0} Read port 0
459E: E6 0A           ANI     0x0A                ; Bits 1 and 3
45A0: FE 0A           CPI     0x0A                ; Both set?
45A2: CA 00 00        JZ      0x0000              ; {code.Reset} Yes ... restart
45A5: A7              ANA     A                   ; Set flags
45A6: 00              NOP                         ; (padding)
45A7: C0              RNZ                         ; One set ... leave the flag
45A8: 21 E3 20        LXI     H,0x20E3            ; {ram.hwFlag} Both clear ...
45AB: 36 00           MVI     M,0x00              ; ... clear the flag
45AD: C9              RET                         ; Done
45AE: 0F 11 04 12 04 13 1B 0C 0E 03 04    ; "PRESET MODE"

PresetMode:
; Part II operator "preset mode" (DIP switch 4 on). Before play starts:
;   Start1 : add 1000 points        left  : stop the alien shots
;   Start2 : skip to the next rack  right : allow the alien shots
;   fire   : start playing
45B9: 21 15 2D        LXI     H,0x2D15            ; Screen coordinates
45BC: 11 AE 45        LXI     D,0x45AE            ; "PRESET MODE"
45BF: 0E 0B           MVI     C,0x0B              ; 11 characters
45C1: CD 85 0C        CALL    0x0C85              ; {code.PrintMessageDel} Print it
45C4: DB 01           IN      0x01                ; {hard.INP1} Read switches
45C6: E6 76           ANI     0x76                ; Start1, Start2, fire, left, right
45C8: FE 10           CPI     0x10                ; Fire?
45CA: C8              RZ                          ; Yes ... start the game
45CB: FE 04           CPI     0x04                ; Start1?
45CD: CC E4 45        CZ      0x45E4              ; {code.PresetScore} Yes ... add 1000 points
45D0: FE 20           CPI     0x20                ; Left?
45D2: CC F9 45        CZ      0x45F9              ; {code.PresetShotsOff} Yes ... stop alien shots
45D5: FE 02           CPI     0x02                ; Start2?
45D7: CC FF 45        CZ      0x45FF              ; {code.PresetRound} Yes ... next rack
45DA: FE 40           CPI     0x40                ; Right?
45DC: CC 31 46        CZ      0x4631              ; {code.PresetShotsOn} Yes ... alien shots on
45DF: D3 06           OUT     0x06                ; {hard.WATCHDOG} Feed watchdog
45E1: C3 C4 45        JMP     0x45C4              ; {} Keep checking

PresetScore:
45E4: DB 01           IN      0x01                ; {hard.INP1} Wait for ...
45E6: E6 04           ANI     0x04                ; ... start1 ...
45E8: C2 E4 45        JNZ     0x45E4              ; {} ... to be released
45EB: 21 00 01        LXI     H,0x0100            ; 1000 points
45EE: 22 F2 20        SHLD    0x20F2              ; {ram.scoreDeltaLSB} Score delta
45F1: 3E 01           MVI     A,0x01              ; Flag ...
45F3: 32 F1 20        STA     0x20F1              ; {ram.adjustScore} ... the change
45F6: C3 58 0B        JMP     0x0B58              ; {code.AdjustScore} Add it and print it

PresetShotsOff:
45F9: 21 E4 20        LXI     H,0x20E4            ; {ram.shotsHalted} Halt ...
45FC: 36 01           MVI     M,0x01              ; ... the alien shots
45FE: C9              RET                         ; Done

PresetRound:
45FF: DB 01           IN      0x01                ; {hard.INP1} Wait for ...
4601: E6 02           ANI     0x02                ; ... start2 ...
4603: C2 FF 45        JNZ     0x45FF              ; {} ... to be released
4606: CD F9 07        CALL    0x07F9              ; {code.GetRoundNum} Round number
4609: FE 12           CPI     0x12                ; Past round 17?
460B: DA 10 46        JC      0x4610              ; {} No
460E: 36 09           MVI     M,0x09              ; Back to 9
4610: 34              INR     M                   ; Next round
4611: 2E FA           MVI     L,0xFA              ; Display round
4613: 34              INR     M                   ; Next
4614: 7E              MOV     A,M                 ; Get it
4615: FE 0A           CPI     0x0A                ; Past 9?
4617: C2 1C 46        JNZ     0x461C              ; {} No
461A: 36 00           MVI     M,0x00              ; Back to 0
461C: CD 59 02        CALL    0x0259              ; {code.RestoreShields2} Fresh shields (player 2's buffer is a clean copy)
461F: CD 97 09        CALL    0x0997              ; {code.CarveRoundNum} Cut the round number into them
4622: CD DE 01        CALL    0x01DE              ; {code.InitAliens} New formation for player 1
4625: CD C2 16        CALL    0x16C2              ; {code.InitAliensP2} ... and player 2
4628: CD F9 13        CALL    0x13F9              ; {code.GetPlayerDataPage} Player's data
462B: 2E FE           MVI     L,0xFE              ; Rack count
462D: 7E              MOV     A,M                 ; Get it
462E: C3 21 0C        JMP     0x0C21              ; {code.SetRackStart} Set starting height and out

PresetShotsOn:
4631: 21 E4 20        LXI     H,0x20E4            ; {ram.shotsHalted} Allow ...
4634: 36 00           MVI     M,0x00              ; ... the alien shots
4636: C9              RET                         ; Done

AwardShip:
4637: CD 17 0B        CALL    0x0B17              ; {} Get pointer to number of ships
463A: 34              INR     M                   ; Bump number of ships
463B: 7E              MOV     A,M                 ; Get the new total

DrawNewShip:
463C: F5              PUSH    PSW                 ; Hang onto it for a bit
463D: 21 01 25        LXI     H,0x2501            ; Screen coords for ship hold
4640: 24              INR     H                   ; Bump to ...
4641: 24              INR     H                   ; ... next
4642: 3D              DCR     A                   ; ... spot
4643: C2 40 46        JNZ     0x4640              ; {} Find spot for new ship
4646: 06 10           MVI     B,0x10              ; 16 byte sprite
4648: 11 81 1C        LXI     D,0x1C81            ; Player sprite
464B: CD 83 11        CALL    0x1183              ; {code.DrawSimpSprite} Draw the sprite
464E: F1              POP     PSW                 ; Restore the count
464F: 3C              INR     A                   ; +1
4650: C3 0B 18        JMP     0x180B              ; {}

BonusValue:
; HL = last-alien bonus (BCD/10): 100 (1000), 80 (800) or 50 (500). Also sets the number
; of beam fans.
4653: 21 B3 20        LXI     H,0x20B3            ; {ram.bonus1000} 1000?
4656: 7E              MOV     A,M                 ; Get flag
4657: A7              ANA     A                   ; Set flags
4658: C2 65 46        JNZ     0x4665              ; {} Yes
465B: 23              INX     H                   ; 20B4
465C: 7E              MOV     A,M                 ; 800?
465D: A7              ANA     A                   ; Set flags
465E: C2 6E 46        JNZ     0x466E              ; {} Yes
4661: 21 50 00        LXI     H,0x0050            ; 500
4664: C9              RET                         ; Done
4665: 21 00 01        LXI     H,0x0100            ; 1000
4668: 3E 04           MVI     A,0x04              ; 4 ...
466A: 32 B5 20        STA     0x20B5              ; {ram.bonusBeams} ... fans
466D: C9              RET                         ; Done
466E: 21 80 00        LXI     H,0x0080            ; 800
4671: 3E 03           MVI     A,0x03              ; 3 ...
4673: 32 B5 20        STA     0x20B5              ; {ram.bonusBeams} ... fans
4676: C9              RET                         ; Done

Bonus1000:
4677: 32 B3 20        STA     0x20B3              ; {ram.bonus1000} Flag 1000
467A: 32 AE 20        STA     0x20AE              ; {ram.lastAlienBonus} Flag bonus
467D: C9              RET                         ; Done

Bonus800:
467E: 32 B4 20        STA     0x20B4              ; {ram.bonus800} Flag 800
4681: C9              RET                         ; Done

FewShotsShip:
; Part II: clearing a rack with fewer than 56 shots earns an extra ship (up to 6).
4682: CD F9 13        CALL    0x13F9              ; {code.GetPlayerDataPage} Player's data
4685: 2E F8           MVI     L,0xF8              ; 2xF8 shots this rack
4687: 7E              MOV     A,M                 ; Get count
4688: FE 38           CPI     0x38                ; 56 or more?
468A: D0              RNC                         ; Yes ... no ship
468B: CD 17 0B        CALL    0x0B17              ; {code.GetNumShips} Number of ships
468E: 34              INR     M                   ; One more
468F: 7E              MOV     A,M                 ; Get it
4690: FE 07           CPI     0x07                ; 7 or more?
4692: D0              RNC                         ; Yes ... no ship
4693: CD 3C 46        CALL    0x463C              ; {code.DrawNewShip} Draw it and update the count
4696: CD 3C 0B        CALL    0x0B3C              ; {code.ExtraShipSnd} Extra ship sound
4699: 01 00 00        LXI     B,0x0000            ; Long ...
469C: CD C9 0E        CALL    0x0EC9              ; {code.DelayBC} ... delay
469F: 06 EF           MVI     B,0xEF              ; Mask off ...
46A1: C3 5C 17        JMP     0x175C              ; {code.SoundBits3Off} ... the sound and out

; Leftover 8080 assembler source text: the end of a data table and the start of the
; original font, labeled CHROM ("***** CHARACTER DATA *****").
46A4: 42 30 48 2C 30 42 30 48 2C 30 42 30 48 0D 0A 09 ; B0H,0B0H,0B0H\r\n\t
46B4: 44 42 09 32 43 48 2C 35 38 48 2C 35 38 48 2C 38 ; DB\t2CH,58H,58H,8
46C4: 34 48 0D 0A 09 44 42 09 38 34 48 0D 0A 3B 0D 0A ; 4H\r\n\tDB\t84H\r\n;\r\n
46D4: 3B 0D 0A 3B 09 2A 2A 2A 2A 2A 20 43 48 41 52 41 ; ;\r\n;\t***** CHARA
46E4: 43 54 45 52 20 44 41 54 41 20 2A 2A 2A 2A 2A 0D ; CTER DATA *****\r
46F4: 0A 3B 0D 0A 43 48 52 4F 4D 3A 09 44 42 09 31 46 ; \n;\r\nCHROM:\tDB\t1F
4704: 48 2C 32 34 48 2C 34 34 48 09 20 20 20 3B 20 20 ; H,24H,44H\t   ;  
4714: 41 20 20 20 3C 30 30 3E 0D 0A 09 44 42 09 32 34 ; A   <00>\r\n\tDB\t24
4724: 48 2C 31 46 48 0D 0A 09 44 42 09 37 46 48 2C 34 ; H,1FH\r\n\tDB\t7FH,4
4734: 39 48 2C 34 39 48 09 20 20 20 3B 20 20 42 20 20 ; 9H,49H\t   ;  B  
4744: 20 3C 30 31 3E 0D 0A 09 44 42 09 34 39 48 2C 33 ;  <01>\r\n\tDB\t49H,3
4754: 36 48 0D 0A 09 44 42 09 33 45 48 2C 34 31 48 2C ; 6H\r\n\tDB\t3EH,41H,
4764: 34 31 48 09 20 20 20 3B 20 20 43 20 20 20 3C 30 ; 41H\t   ;  C   <0
4774: 32 3E 0D 0A 09 44 42 09 34 31 48 2C 32 32 48 0D ; 2>\r\n\tDB\t41H,22H\r
4784: 0A 09 44 42 09 37 46 48 2C 34 31 48 2C 34 31 48 ; \n\tDB\t7FH,41H,41H
4794: 09 20 20 20 3B 20 20 44 20 20 20 3C 30 33 3E 0D ; \t   ;  D   <03>\r
47A4: 0A 09 44 42 09 34 31 48 2C 33 45 48 0D 0A 09 44 ; \n\tDB\t41H,3EH\r\n\tD
47B4: 42 09 37 46 48 2C 34 39 48 2C 34 39 48 09 20 20 ; B\t7FH,49H,49H\t  
47C4: 20 3B 20 20 45 20 20 20 3C 30 34 3E 0D 0A 09 44 ;  ;  E   <04>\r\n\tD
47D4: 42 09 34 39 48 2C 34 31 48 0D 0A 09 44 42 09 37 ; B\t49H,41H\r\n\tDB\t7
47E4: 46 48 2C 34 38 48 2C 34 38 48 09 20 20 20 3B 20 ; FH,48H,48H\t   ; 
47F4: 20 46 20 20 20 3C 30 35 3E 0D 0A 09             ;  F   <05>\r\n\t
```
