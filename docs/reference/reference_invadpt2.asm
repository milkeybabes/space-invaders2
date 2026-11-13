; ==========================================================================
; Space Invaders Part II (Taito, 1979)  -  reconstructed 8080 source
; ROMs: pv01 (0000) pv02 (0800) pv03 (1000) pv04 (1800) pv05 (4000)
; Rebuilt from the Computer Archeology commentary of the original Space Invaders
; code (computerarcheology.com, Chris Cantrell) by aligning both ROM sets, plus new
; analysis of everything Part II adds. Assembles byte-for-byte to the original ROMs.
; Syntax: ASMX-style 8080 (as used by the invaders.asm on Computer Archeology).
; ==========================================================================

        CPU     8080

; ---- Hardware ports
INP0             EQU 0x00
INP1             EQU 0x01
INP2             EQU 0x02
SHFT_IN          EQU 0x03
SHFTAMNT         EQU 0x02
SOUND1           EQU 0x03
SHFT_DATA        EQU 0x04
SOUND2           EQU 0x05
WATCHDOG         EQU 0x06

; ---- RAM
waitOnDraw       EQU 0x2000
alienIsExploding EQU 0x2002
expAlienTimer    EQU 0x2003
alienRow         EQU 0x2004
alienFrame       EQU 0x2005
alienCurIndex    EQU 0x2006
refAlienDYr      EQU 0x2007
refAlienDXr      EQU 0x2008
refAlienYr       EQU 0x2009
refAlienXr       EQU 0x200A
alienPosLSB      EQU 0x200B
alienPosMSB      EQU 0x200C
rackDirection    EQU 0x200D
rackDownDelta    EQU 0x200E
obj0TimerMSB     EQU 0x2010
obj0TimerLSB     EQU 0x2011
obj0TimerExtra   EQU 0x2012
obj0HanlderLSB   EQU 0x2013
oBJ0HanlderMSB   EQU 0x2014
playerAlive      EQU 0x2015
expAnimateTimer  EQU 0x2016
expAnimateCnt    EQU 0x2017
plyrSprPicL      EQU 0x2018
plyrSprPicM      EQU 0x2019
playerYr         EQU 0x201A
playerXr         EQU 0x201B
plyrSprSiz       EQU 0x201C
nextDemoCmd      EQU 0x201D
hidMessSeq       EQU 0x201E
obj1TimerMSB     EQU 0x2020
obj1TimerLSB     EQU 0x2021
obj1TimerExtra   EQU 0x2022
obj1HandlerLSB   EQU 0x2023
obj1HandlerMSB   EQU 0x2024
plyrShotStatus   EQU 0x2025
blowUpTimer      EQU 0x2026
obj1ImageLSB     EQU 0x2027
obj1ImageMSB     EQU 0x2028
obj1CoorYr       EQU 0x2029
obj1CoorXr       EQU 0x202A
obj1ImageSize    EQU 0x202B
shotDeltaX       EQU 0x202C
fireBounce       EQU 0x202D
obj2TimerMSB     EQU 0x2030
obj2TimerLSB     EQU 0x2031
obj2TimerExtra   EQU 0x2032
obj2HandlerLSB   EQU 0x2033
obj2HandlerMSB   EQU 0x2034
rolShotStatus    EQU 0x2035
rolShotStepCnt   EQU 0x2036
rolShotTrack     EQU 0x2037
rolShotCFirLSB   EQU 0x2038
rolShotCFirMSB   EQU 0x2039
rolShotBlowCnt   EQU 0x203A
rolShotImageLSB  EQU 0x203B
rolShotImageMSB  EQU 0x203C
rolShotYr        EQU 0x203D
rolShotXr        EQU 0x203E
rolShotSize      EQU 0x203F
obj3TimerMSB     EQU 0x2040
obj3TimerLSB     EQU 0x2041
obj3TimerExtra   EQU 0x2042
obj3HandlerLSB   EQU 0x2043
obj3HandlerMSB   EQU 0x2044
pluShotStatus    EQU 0x2045
pluShotStepCnt   EQU 0x2046
pluShotTrack     EQU 0x2047
pluShotCFirLSB   EQU 0x2048
pluShotCFirMSB   EQU 0x2049
pluShotBlowCnt   EQU 0x204A
pluShotImageLSB  EQU 0x204B
pluShotImageMSB  EQU 0x204C
pluShotYr        EQU 0x204D
pluSHotXr        EQU 0x204E
pluShotSize      EQU 0x204F
obj4TimerMSB     EQU 0x2050
obj4TimerLSB     EQU 0x2051
obj4TimerExtra   EQU 0x2052
obj4HandlerLSB   EQU 0x2053
obj4HandlerMSB   EQU 0x2054
squShotStatus    EQU 0x2055
squShotStepCnt   EQU 0x2056
squShotTrack     EQU 0x2057
squShotCFirLSB   EQU 0x2058
squShotCFirMSB   EQU 0x2059
squSHotBlowCnt   EQU 0x205A
squShotImageLSB  EQU 0x205B
squShotImageMSB  EQU 0x205C
squShotYr        EQU 0x205D
squShotXr        EQU 0x205E
squShotSize      EQU 0x205F
endOfTasks       EQU 0x2060
collision        EQU 0x2061
expAlienLSB      EQU 0x2062
expAlienMSB      EQU 0x2063
expAlienYr       EQU 0x2064
expAlienXr       EQU 0x2065
expAlienSize     EQU 0x2066
playerDataMSB    EQU 0x2067
playerOK         EQU 0x2068
enableAlienFire  EQU 0x2069
alienFireDelay   EQU 0x206A
oneAlien         EQU 0x206B
temp206C         EQU 0x206C
invaded          EQU 0x206D
skipPlunger      EQU 0x206E
otherShot1       EQU 0x2070
otherShot2       EQU 0x2071
vblankStatus     EQU 0x2072
aShotStatus      EQU 0x2073
aShotStepCnt     EQU 0x2074
aShotTrack       EQU 0x2075
aShotCFirLSB     EQU 0x2076
aShotCFirMSB     EQU 0x2077
aShotBlowCnt     EQU 0x2078
aShotImageLSB    EQU 0x2079
aShotImageMSB    EQU 0x207A
alienShotYr      EQU 0x207B
alienShotXr      EQU 0x207C
alienShotSize    EQU 0x207D
alienShotDelta   EQU 0x207E
shotPicEnd       EQU 0x207F
shotSync         EQU 0x2080
tmp2081          EQU 0x2081
numAliens        EQU 0x2082
saucerStart      EQU 0x2083
saucerActive     EQU 0x2084
saucerHit        EQU 0x2085
saucerHitTime    EQU 0x2086
saucerPriLocLSB  EQU 0x2087
saucerPriLocMSB  EQU 0x2088
saucerPriPicLSB  EQU 0x2089
saucerPriPicMSB  EQU 0x208A
saucerPriSize    EQU 0x208B
saucerDeltaY     EQU 0x208C
sauScoreLSB      EQU 0x208D
sauScoreMSB      EQU 0x208E
shotCountLSB     EQU 0x208F
shotCountMSB     EQU 0x2090
tillSaucerLSB    EQU 0x2091
tillSaucerMSB    EQU 0x2092
waitStartLoop    EQU 0x2093
soundPort3       EQU 0x2094
changeFleetSnd   EQU 0x2095
fleetSndCnt      EQU 0x2096
fleetSndReload   EQU 0x2097
soundPort5       EQU 0x2098
extraHold        EQU 0x2099
tilt             EQU 0x209A
fleetSndHold     EQU 0x209B
dropColumn       EQU 0x20A0	; Saucer-drop: bit 7=a drop is pending, low nibble=column (1-11) of the empty top-row slot being refilled
dropActive       EQU 0x20A1	; Saucer-drop: 1 while a new alien is falling from the saucer into the rack
dropDeltaY       EQU 0x20A2	; Saucer-drop: falling alien's Y step (FE = down 2)
dropDeltaX       EQU 0x20A3	; Saucer-drop: falling alien's X step (0)
dropYr           EQU 0x20A4	; Saucer-drop: falling alien's Y coordinate
dropXr           EQU 0x20A5	; Saucer-drop: falling alien's X coordinate
dropPicL         EQU 0x20A6	; Saucer-drop: falling alien's picture (LSB)
dropPicM         EQU 0x20A7	; Saucer-drop: falling alien's picture (MSB)
dropSize         EQU 0x20A8	; Saucer-drop: falling alien's picture size (8)
dropTargetY      EQU 0x20A9	; Saucer-drop: Y coordinate where the falling alien joins the rack
dropSlotL        EQU 0x20AA	; Saucer-drop: pointer (LSB) to the empty alien slot being refilled
dropSlotM        EQU 0x20AB	; Saucer-drop: pointer (MSB) to the empty alien slot being refilled
dropHit          EQU 0x20AD	; 1 when the player's shot has hit the alien that the saucer is dropping
lastAlienBonus   EQU 0x20AE	; 1 when the last alien of a rack qualifies for the end-of-rack BONUS
scoreTableOn     EQU 0x20AF	; Always 1 (from the RAM mirror). AlienScoreValue skips the lookup if it is 0
nameFireHeld     EQU 0x20B1	; Name entry: fire button debounce
nameFirePressed  EQU 0x20B2	; Name entry: fire button pressed (select letter)
bonus1000        EQU 0x20B3	; End-of-rack bonus is 1000 points
bonus800         EQU 0x20B4	; End-of-rack bonus is 800 points
bonusBeams       EQU 0x20B5	; Number of times the bonus beam animation is repeated
dropDone         EQU 0x20B7	; Saucer has dropped an alien this rack
dropOnce         EQU 0x20B8	; Copy of dropDone (rounds 2 and 3 only get one drop per rack)
rackArriving     EQU 0x20B9	; 1 while the new rack is sliding down into position (ISR keeps the fleet sound going)
flashSaucerArmed EQU 0x20BA	; Flashing saucer: set when the saucer score is to be shown as 500
flashSaucer      EQU 0x20BB	; Flashing saucer is on this pass
saucerBlink      EQU 0x20BC	; Flashing saucer blink counter
saucerBlinkTmr   EQU 0x20BD	; Flashing saucer blink timer
bonusBeamCnt     EQU 0x20BE	; Counts the bonus beam animation repeats
nameStartHit     EQU 0x20BF	; A start button was pressed during name entry (ends entry)
isrDelay         EQU 0x20C0
isrSplashTask    EQU 0x20C1
splashAnForm     EQU 0x20C2
splashDeltaX     EQU 0x20C3
splashDeltaY     EQU 0x20C4
splashYr         EQU 0x20C5
splashXr         EQU 0x20C6
splashImageLSB   EQU 0x20C7
splashImageMSB   EQU 0x20C8
splashImageSize  EQU 0x20C9
splashTargetY    EQU 0x20CA
splashReached    EQU 0x20CB
creditShadow     EQU 0x20CC	; Second copy of the credit count. ISR resets the machine if it ever differs from numCoins (anti-tamper)
splashImRestMSB  EQU 0x20CD
twoPlayers       EQU 0x20CE
aShotReloadRate  EQU 0x20CF
sosActive        EQU 0x20D0	; 1 while the end-of-rack "SOS" intermission animation is running (ISR task)
sosStage         EQU 0x20D1	; Intermission stage flag
sosDeltaX        EQU 0x20D2	; Intermission sprite descriptor (delta X)
sosDeltaY        EQU 0x20D3	; Intermission sprite descriptor (delta Y)
sosPosL          EQU 0x20D4	; Intermission saucer position (LSB)
sosPosM          EQU 0x20D5	; Intermission saucer position (MSB)
sosPicL          EQU 0x20D6	; Intermission saucer picture (LSB)
sosPicM          EQU 0x20D7	; Intermission saucer picture (MSB)
sosSize          EQU 0x20D8	; Intermission saucer picture size
sosResume        EQU 0x20D9	; 1 after the "ENGINE TROUBLE" stop (saucer then flies off)
sosWobble        EQU 0x20DA	; Intermission: alternates the sideways wobble
lastAlienType    EQU 0x20DB	; Status byte (type) of the last alien that was shot
sosAnim          EQU 0x20DC	; Intermission: animation counter for the alien's picture
sosAlienPicL     EQU 0x20DD	; Intermission: picture of the alien riding in the saucer (LSB)
sosAlienPicM     EQU 0x20DE	; Intermission: picture of the alien riding in the saucer (MSB)
sosBlink         EQU 0x20DF	; Intermission blink counter
namePending      EQU 0x20E0	; 1 when the player beat the high score and will enter a name at game over
nameFlip         EQU 0x20E1	; Player entering the name: 00=player 1, 20=player 2 (port-5 cocktail bit and port-2 controls)
tamperFlag       EQU 0x20E2	; Cleared when the copyright text checks out; left set if it was altered
hwFlag           EQU 0x20E3	; Cleared in attract mode when port 0 bits 1 and 3 are both 0 (checked hardware)
shotsHalted      EQU 0x20E4	; 1 stops the alien shots (used during name entry and rack start)
player1Ex        EQU 0x20E5
player2Ex        EQU 0x20E6
player1Alive     EQU 0x20E7
player2Alive     EQU 0x20E8
suspendPlay      EQU 0x20E9
coinSwitch       EQU 0x20EA
numCoins         EQU 0x20EB
splashAnimate    EQU 0x20EC
demoCmdPtrLSB    EQU 0x20ED
demoCmdPtrMSB    EQU 0x20EE
gameMode         EQU 0x20EF
adjustScore      EQU 0x20F1
scoreDeltaLSB    EQU 0x20F2
scoreDeltaMSB    EQU 0x20F3
HiScorL          EQU 0x20F4
HiScorM          EQU 0x20F5
HiScorLoL        EQU 0x20F6
HiScorLoM        EQU 0x20F7
P1ScorL          EQU 0x20F8
P1ScorM          EQU 0x20F9
P1ScorLoL        EQU 0x20FA
P1ScorLoM        EQU 0x20FB
P2ScorL          EQU 0x20FC
P2ScorM          EQU 0x20FD
P2ScorLoL        EQU 0x20FE
P2ScorLoM        EQU 0x20FF
p1RefAlienDX     EQU 0x21FB
p1RefAlienY      EQU 0x21FC
p1RefAlienX      EQU 0x21FD
p1RackCnt        EQU 0x21FE
p1ShipsRem       EQU 0x21FF
p2RefAlienDX     EQU 0x22FB
p2RefAlienYr     EQU 0x22FC
p2RefAlienXr     EQU 0x22FD
p2RackCnt        EQU 0x22FE
p2ShipsRem       EQU 0x22FF
rackSave         EQU 0x2300	; Copy of 2000-200F while the new rack slides into place
beamCount        EQU 0x2310	; Bonus beam animation: current beam length
beamStep         EQU 0x2311	; Bonus beam animation: spread per step
beamOriginL      EQU 0x2312	; Bonus beam animation: origin (LSB)
beamOriginM      EQU 0x2313	; Bonus beam animation: origin (MSB)
hiNamePosL       EQU 0x233E	; Screen address of the centered high-score name (LSB)
hiNamePosM       EQU 0x233F	; Screen address of the centered high-score name (MSB)
hiName           EQU 0x2340	; High-score holder's name (10 characters)
nameTimerL       EQU 0x234A	; Name entry timer (counts up in the ISR)
nameTimerM       EQU 0x234B	; Name entry timer MSB (entry ends at 20)
nameLength       EQU 0x234C	; Number of letters entered so far (0-10)
nameEntry        EQU 0x234D	; FF while the name-entry screen is active
nameCursorL      EQU 0x234E	; Name entry: screen address of the letter cursor (LSB)
nameCursorM      EQU 0x234F	; Name entry: screen address of the letter cursor (MSB)
nameOutL         EQU 0x2350	; Name entry: screen address where the next letter is printed (LSB)
nameOutM         EQU 0x2351	; Name entry: screen address where the next letter is printed (MSB)


;======================================================================
; Startup and Interrupts
;======================================================================


; Execution begins here on power-up and reset.

        ORG     0x0000

Reset:
        NOP                             ; This provides a slot ...
        NOP                             ; ... to put in a JP for ...
        NOP                             ; ... development
L_0003:
        JMP     init                    ; Continue startup at 168F
        DB      0x00,0x00               ; Padding before fixed ISR address

;Interrupt brings us here when the beam is *near* the middle of the screen. The real middle
;would be 224/2 = 112. The code pretends this interrupt happens at line 128.
ScanLine96:
        PUSH    PSW                     ; Save ...
        PUSH    B                       ; ...
        PUSH    D                       ; ...
        PUSH    H                       ; ... everything
        JMP     ScanLine96Cont          ; Continue ISR at 0D83 (Part II checks the name-reset switch and runs name-entry timing first)
        DB      0x00                    ; Padding before fixed ISR address

; Interrupt brings us here when the beam is at the end of the screen (line 224) when the VBLANK begins.
ScanLine224:
        PUSH    PSW                     ; Save ...
        PUSH    B                       ; ...
        PUSH    D                       ; ...
        PUSH    H                       ; ... everything
        MVI     A,0x80                  ; Flag that tells objects ...
        STA     vblankStatus            ; ... on the lower half of the screen to draw/move
        LXI     H,isrDelay              ; Decrement ...
        DCR     M                       ; ... the general countdown (used for pauses)
        CALL    CheckHandleTilt         ; Check and handle TILT
        IN      INP1                    ; Read coin switch
        RRC                             ; Has a coin been deposited (bit 0)?
        JC      L_0070                  ; Yes ... note that switch is closed and continue at 3F with A=1
        LDA     coinSwitch              ; Switch is now open. Was it ...
        ANA     A                       ; ... closed last time?
        JZ      L_004B                  ; No ... skip registering the credit

;
; Handle bumping credit count
        LDA     numCoins                ; Number of credits in BCD
        CPI     0x09                    ; Part II: credits max out at 9 (the original allowed 99) ...
        JZ      L_0047                  ; ... ignore the coin if already at 9
        ADI     0x01                    ; Bump number of credits
        DAA                             ; Make it binary coded decimal
        STA     numCoins                ; New number of credits
        LDA     creditShadow            ; Part II keeps a second copy ...
        ADI     0x01                    ; ... of the credit count ...
        DAA                             ; ... (BCD) ...
        STA     creditShadow            ; ... checked at the end of every interrupt (see 0094)
        CALL    DrawNumCredits          ; Draw credits on screen
L_0047:
        XRA     A                       ; Credit switch ...
L_0048:
        STA     coinSwitch              ; ... has opened

;
L_004B:
        LDA     suspendPlay             ; Are we moving ...
        ANA     A                       ; ... game objects?
        JZ      L_008A                  ; No ... restore registers and out
        LDA     gameMode                ; Are we in ...
        ANA     A                       ; ... game mode?
        JNZ     L_0075                  ; Yes ... go process game-play things and out
        LDA     numCoins                ; Number of credits
        ANA     A                       ; Are there any credits (player standing there)?
        JNZ     L_0066                  ; Yes ... skip any ISR animations for the splash screens
        CALL    ISRSplTasks             ; Process ISR tasks for splash screens
        JMP     L_008A                  ; Restore registers and out

;
; At this point no game is going and there are credits
L_0066:
        LDA     waitStartLoop           ; Are we in the ...
        ANA     A                       ; ... "press start" loop?
        JNZ     ISRExit                 ; Yes ... restore registers and out
        JMP     WaitForStart            ; Start the "press start" loop

;
; Mark credit as needing registering
L_0070:
        MVI     A,0x01                  ; Remember switch ...
        JMP     L_0048                  ; Continue
L_0075:
        CALL    TimeFleetSound

;
; Main game-play timing loop
        CALL    SaucerDropMove          ; Part II: move/draw the alien that the saucer is dropping into the rack
L_007B:
        LDA     obj2TimerExtra          ; Use rolling shot's timer to sync ...
        STA     shotSync                ; ... other two shots
        CALL    DrawAlien               ; Draw the current alien (or exploding alien)
        CALL    RunGameObjs             ; Process game objects (including player object)
        CALL    TimeToSaucer            ; Count down time to saucer
L_008A:
        LDA     rackArriving            ; Is the new rack sliding down into place?
        ANA     A                       ; Set flags
        CNZ     TimeFleetSound          ; Yes ... keep the fleet sound timing going (the game loop is not running yet)
        CALL    IntermissionISR         ; Part II: protection checks in attract mode and the "SOS" intermission animation

; Part II anti-tamper: the credit count is kept twice (20EB and 20CC). If the two ever
; disagree (someone poked the credits) the machine restarts.
ISRExit:
        LXI     H,numCoins              ; Credit count
        MOV     A,M                     ; Get it
        MVI     L,0xCC                  ; Point to the shadow copy (20CC)
        CMP     M                       ; Do they agree?
        JNZ     L_0003                  ; No ... restart the machine

;
        POP     H                       ; Restore ...
        POP     D                       ; ...
        POP     B                       ; ...
        POP     PSW                     ; ... everything
        EI                              ; Enable interrupts
        RET                             ; Return from interrupt

; Continues here at scanline 96
;
L_00A4:
        XRA     A                       ; Flag that tells ...
        STA     vblankStatus            ; ... objects on the upper half of screen to draw/move
        LDA     suspendPlay             ; Are we moving ...
        ANA     A                       ; ... game objects?
        JZ      L_008A                  ; No ... restore and return
        LDA     gameMode                ; Are we in ...
        ANA     A                       ; ... game mode?
        JNZ     L_00BD                  ; Yes .... process game objects and out
        LDA     isrSplashTask           ; Splash-animation tasks
        RRC                             ; If we are in demo-mode then we'll process the tasks anyway
        JNC     ISRExit                 ; Not in demo mode ... done
L_00BD:
        CALL    SaucerDrop              ; Part II: let the saucer drop a new alien into a gap in the top row

;
        LXI     H,obj1TimerMSB          ; Game object table (skip player-object at 2010)
        CALL    L_0291                  ; Process all game objects (except player object)
        CALL    CursorNextAlien         ; Advance cursor to next alien (move the alien if it is last one)
        JMP     ISRExit                 ; Restore and return

;======================================================================
; The Aliens
;======================================================================


; Initialize the player's rack of aliens. Copy the reference-location and deltas from the
; player's data bank.
;
InitRack:
        CALL    GetAlRefPtr             ; 2xFC Get current player's ref-alien position pointer
        PUSH    H                       ; Hold pointer
        MOV     A,M                     ; Get player's ...
        INX     H                       ; ... ref-alien ...
        MOV     H,M                     ; ...
        MOV     L,A                     ; ... coordinates
        SHLD    refAlienYr              ; Set game's reference alien's X,Y
        SHLD    alienPosLSB             ; Set game's alien cursor bit position
        POP     H                       ; Restore pointer
        DCX     H                       ; 21FB or 22FB ref alien's delta (left or right)
        MOV     A,M                     ; Get ref alien's delta X
        CPI     0x03                    ; If there is one alien it will move right at 3
        JNZ     L_00E3                  ; Not 3 ... keep it
        DCR     A                       ; If it is 3, back it down to 2 until it switches again
L_00E3:
        STA     refAlienDXr             ; Store alien deltaY
        CPI     0xFE                    ; Moving left?
        MVI     A,0x00                  ; Value of 0 for rack-moving-right (not XOR so flags are unaffected)
        JNZ     L_00EE                  ; Not FE ... keep the value 0 for right
        INR     A                       ; It IS FE ... use 1 for left
L_00EE:
        STA     rackDirection           ; Store rack direction
        RET                             ; Done
L_00F2:
        MVI     A,0x02                  ; Set ...
        STA     p1RefAlienDX            ; ... player 1 and 2 ...
        STA     p2RefAlienDX            ; ... alien delta to 2 (right 2 pixels)
        JMP     ClrP2ScoreIf1P

; Part II: write port 5 (the cocktail-flip bit, which on Part II hardware also selects the
; colour map) with interrupts off and wait a moment for the hardware to settle.
SetFlipDelay:
        DI                              ; No interrupts while we wait
        MOV     A,B                     ; B holds the new port-5 value (cocktail bit)
        OUT     SOUND2                  ; Set the cocktail/colour-map bit
        MVI     B,0x0A                  ; Outer count of 10
L_0103:
        MVI     C,0x00                  ; Inner count of 256
L_0105:
        DCR     C                       ; Count ...
        JNZ     L_0105                  ; ... down inner
        DCR     B                       ; Count ...
        JNZ     L_0103                  ; ... down outer
        EI                              ; Interrupts back on
        RET                             ; Done

; 2006 holds the index into the alien flag data grid. 2067 holds the MSB of the pointer (21xx or 22xx).
; If there is an alien exploding time it down. Otherwise draw the alien if it alive (or skip if
; it isn't). If an alien is drawn (or blank) then the 2000 alien-drawing flag is cleared.
;
; Part II: the alien's picture comes from its status byte instead of its row. The status
; byte is 0 for an empty slot, otherwise 1, 3, 5 or 7 (bit 0 = alive, bits 1-2 = type).
; There are four alien pictures per animation frame (octopus, crab, squid and the small
; "split" alien) so frame 1 is $40 bytes after frame 0.
DrawAlien:
        LXI     H,alienIsExploding      ; Is there an ...
        MOV     A,M                     ; ... alien ...
        ANA     A                       ; ... exploding?
        JNZ     AExplodeTime            ; Yes ... go time it down and out

;
        PUSH    H                       ; 2002 on the stack
        LDA     alienCurIndex           ; Get alien index ...
        MOV     L,A                     ; ... for the 21xx or 22xx pointer
        LDA     playerDataMSB           ; Get MSB ...
        MOV     H,A                     ; ... of data area (21xx or 22xx)
        MOV     A,M                     ; Get alien status byte
        ANA     A                       ; Is the alien alive?
        POP     H                       ; HL=2002
        JZ      L_0144                  ; No alien ... skip drawing alien sprite (but flag done)
        INX     H                       ; HL=2003 Bump descriptor
        INX     H                       ; HL=2004 Point to alien's row
        INX     H                       ; HL=2005 Animation frame
        MOV     B,M                     ; Get animation number
        ANI     0xF6                    ; Status 1,3,5,7 -> 0,2,4,6 (bit 3 ignored) ...
        RLC                             ; ... *2 ...
        RLC                             ; ... *4 ...
        RLC                             ; ... *8 = 00,10,20,30 offset to the alien type
        MOV     E,A                     ; Sprite offset LSB
        MVI     D,0x00                  ; MSB is 0
        LXI     H,AlienSprA             ; Position 0 alien sprites (1C01)
        DAD     D                       ; Offset to sprite type
        XCHG                            ; Sprite offset to DE
        MOV     A,B                     ; Animation frame number
        ANA     A                       ; Is it position 0?
        CNZ     L_0159                  ; No ... add 30 and use position 1 alien sprites
        MVI     B,0x10                  ; 16 rows in alien sprites
        CALL    OneAlienAdjust          ; Adjust for the lone fast alien
        CALL    DrawSprite              ; Draw shifted sprite
L_0144:
        XRA     A                       ; Let the ISR routine ...
        STA     waitOnDraw              ; ... advance the cursor to the next alien
        RET                             ; Out

; Part II: when only one alien is left it moves 3 pixels at a time. Near the left of the
; screen draw it 17 columns wide starting one column early (one blank sprite byte) so the
; trailing column of the old image gets wiped.
OneAlienAdjust:
        LHLD    alienPosLSB             ; Pixel position of the alien
        LDA     oneAlien                ; Only one alien left?
        ANA     A                       ; Set flags
        RZ                              ; No ... draw normally
        MOV     A,H                     ; Column (MSB of pixel number)
        CPI     0x30                    ; Near the left side?
        RNC                             ; No ... draw normally
        INR     B                       ; Draw 17 bytes instead of 16
        DCR     H                       ; Start one column to the left
        DCX     D                       ; ... and one byte earlier in the sprite data (a blank byte)
        RET                             ; Out

;
L_0159:
        LXI     H,0x0040                ; Offset sprite pointer to frame 1 (4 sprites * 16 bytes = 40 in Part II)
        DAD     D                       ; ... to animation frame 1 sprites
        XCHG                            ; Back to DE
        RET                             ; Out

; This is called from the mid-screen ISR to set the cursor for the next alien to draw.
; When the cursor moves over all aliens then it is reset to the beginning and the reference
; alien is moved to its next position.
;
; The flag at 2000 keeps this in sync with the alien-draw routine called from the end-screen ISR.
; When the cursor is moved here then the flag at 2000 is set to 1. This routine will not change
; the cursor until the alien-draw routine at 100 clears the flag. Thus no alien is skipped.
;
CursorNextAlien:
        LDA     playerOK                ; Is the player ...
        ANA     A                       ; ... blowing up?
        RZ                              ; Yes ... ignore the aliens
        LDA     waitOnDraw              ; Still waiting on ...
        ANA     A                       ; ... this alien to be drawn?
        RNZ                             ; Yes ... leave cursor in place
        LDA     playerDataMSB           ; Load alien-data ...
        MOV     H,A                     ; ... MSB (either 21xx or 22xx)
        LDA     alienCurIndex           ; Load the xx part of the alien flag pointer
        MVI     D,0x02                  ; When all are gone this triggers 1A1 to return from this stack frame
L_0172:
        INR     A                       ; Have we drawn all aliens ...
        CPI     0x37                    ; ... at last position?
        CZ      MoveRefAlien            ; Yes ... move the bottom/right alien and reset index to 0
        MOV     L,A                     ; HL now points to alien flag
        MOV     A,M                     ; Get alien status
        ANA     A                       ; Is alien alive (any type)?
        MOV     A,L                     ; Index back to A (flags kept)
        JZ      L_0172                  ; No ... skip to next alien
        STA     alienCurIndex           ; New alien index
        CALL    GetAlienCoords          ; Calculate bit position and type for index
        MOV     H,C                     ; The calculation returns the MSB in C
        SHLD    alienPosLSB             ; Store new bit position
        MOV     A,L                     ; Has this alien ...
        CPI     0x28                    ; ... reached the end of screen?
        JC      AliensInvade            ; Yes ... kill the player
        MOV     A,D                     ; This alien's ...
        STA     alienRow                ; ... row index
        INR     A                       ; Non-zero value for the ...
        STA     waitOnDraw              ; ... draw-alien routine to clear
        RET                             ; Done

; Convert alien index in L to screen bit position in C,L.
; Return alien row index (converts to type) in D.
;
GetAlienCoords:
        MVI     D,0x00                  ; Row 0
        MOV     A,L                     ; Hold onto alien index
        LXI     H,refAlienYr            ; Get alien X ...
        MOV     B,M                     ; ... to B
        INX     H                       ; Get alien y ...
        MOV     C,M                     ; ... to C
L_01A1:
        CPI     0x0B                    ; Can we take a full row off of index?
        JM      L_01B2                  ; No ... we have the row
        SBI     0x0B                    ; Subtract off 11 (one whole row)
        MOV     E,A                     ; Hold the new index
        MOV     A,B                     ; Add ...
        ADI     0x10                    ; ... 16 to bit ...
        MOV     B,A                     ; ... position Y (1 row in rack)
        MOV     A,E                     ; Restore tallied index
        INR     D                       ; Next row
        JMP     L_01A1                  ; Keep skipping whole rows

;
L_01B2:
        MOV     L,B                     ; We have the LSB (the row)
L_01B3:
        ANA     A                       ; Are we in the right column?
        RZ                              ; Yes ... X and Y are right
        MOV     E,A                     ; Hold index
        MOV     A,C                     ; Add ...
        ADI     0x10                    ; ... 16 to bit ...
        MOV     C,A                     ; ... position X (1 column in rack)
        MOV     A,E                     ; Restore index
        DCR     A                       ; We adjusted for 1 column
        JMP     L_01B3                  ; Keep moving over column

; The "reference alien" is the bottom left. All other aliens are drawn relative to this
; reference. This routine moves the reference alien (the delta is set elsewhere) and toggles
; the animation frame number between 0 and 1.
;
MoveRefAlien:
        DCR     D                       ; This decrements with each call to move
        JZ      ReturnTwo               ; Return out of TWO call frames (only used if no aliens left)
        LXI     H,alienCurIndex         ; Set current alien ...
        MVI     M,0x00                  ; ... index to 0
        INX     H                       ; Point to DeltaX
        MOV     C,M                     ; Load DX into C
        MVI     M,0x00                  ; Set DX to 0
        CALL    AddDelta                ; Move alien
        LXI     H,alienFrame            ; Alien animation frame number
        MOV     A,M                     ; Toggle ...
        INR     A                       ; ... animation ...
        ANI     0x01                    ; ... number between ...
        MOV     M,A                     ; ... 0 and 1
        XRA     A                       ; Alien index in A is now 0
        LXI     H,playerDataMSB         ; Restore H ...
        MOV     H,M                     ; ... to player data MSB (21 or 22)
        RET                             ; Done
        DB      0x21

; Part II: the starting formation is no longer five identical rows. The bottom four rows
; (44 aliens) are copied from one of the formation tables in the 4000 ROM. The table at
; 1E10 picks the formation from the player's round number (rounds past 16 restart at 9).
; The top row is always 11 squids (status 5).
InitAliens:
        LXI     H,0x2100                ; Start of alien structures (player 1)

InitAliensHL:
        MVI     B,0x2C                  ; 44 aliens (4 rows) come from the table
        OUT     WATCHDOG                ; Feed watchdog
        PUSH    H                       ; Hold pointer to aliens
        CALL    GetRoundNum             ; Get player's round count (HL=2xF9)
        PUSH    B                       ; Hold count
        MVI     D,0x40                  ; Formation tables are at 40xx
        LXI     B,FormationTable        ; Table of formation LSBs by round
        ANA     A                       ; First round?
        JZ      L_01FD                  ; Yes ... use entry 0
        CPI     0x11                    ; Past round 16?
        CNC     WrapRound               ; Yes ... wrap back to round 9
L_01F8:
        INX     B                       ; Index ...
        DCR     A                       ; ... into ...
        JNZ     L_01F8                  ; ... the table
L_01FD:
        LDAX    B                       ; Get formation LSB
        MOV     E,A                     ; DE now points to formation
        POP     B                       ; Restore count
        POP     H                       ; Restore pointer to aliens
        CALL    BlockCopy               ; Copy 44 aliens from formation table
        MVI     B,0x0B                  ; 11 aliens in the top row
        MVI     A,0x05                  ; Status 5 = squid
L_0208:
        MOV     M,A                     ; Store alien
        INX     H                       ; Next
        DCR     B                       ; All done?
        JNZ     L_0208                  ; No ... do the whole row
        RET                             ; Done

WrapRound:
        MVI     M,0x09                  ; Set round count back to 9
        MOV     A,M                     ; A = 9
        RET                             ; Out

; If there are no aliens left on the screen then MoveDrawAlien comes here which returns from the
; caller's stack frame.
;
ReturnTwo:
        POP     H                       ; Drop return to caller
        RET                             ; Return to caller's caller

;======================================================================
; Misc
;======================================================================


; Draw a 1px line across the player's stash at the bottom of the screen.
;
DrawBottomLine:
        MVI     A,0x01                  ; Bit 1 set ... going to draw a 1-pixel stripe down left side
        MVI     B,0xE0                  ; All the way down the screen
        LXI     H,0x2402                ; Screen coordinates (3rd byte from upper left)
        JMP     L_1211                  ; Draw line down left side

; HL points to descriptor: DX DY XX YY except DX is already loaded in C
; ** Why the "already loaded" part? Why not just load it here?
;
AddDelta:
        INX     H                       ; We loaded delta-x already ... skip over it
        MOV     B,M                     ; Get delta-y
        INX     H                       ; Skip over it
        MOV     A,C                     ; Add delta-x ...
        ADD     M                       ; ... to x
        MOV     M,A                     ; Store new x
        INX     H                       ; Skip to y
        MOV     A,B                     ; Add delta-y ...
        ADD     M                       ; ... to y
        MOV     M,A                     ; Store new y
        RET                             ; Done

; Block copy ROM mirror 1B00-1881 to initialize RAM at 2000-20BF.
;
CopyRAMMirror:
        MVI     B,0xC0                  ; Number of bytes

CopyMirrorB:
        LXI     D,D_1B00                ; RAM mirror in ROM
        LXI     H,waitOnDraw            ; Start of RAM
        JMP     BlockCopy               ; Copy [DE]->[HL] and return

;======================================================================
; Copy/Restore Shields
;======================================================================


; Draw the shields for player 1 (draws it in the buffer in the player's data area).
;
DrawShieldPl1:
        LXI     H,0x2142                ; Player 1 shield buffer (remember between games in multi-player)
        JMP     L_023E                  ; Common draw point

;
; Draw the shields for player 1 (draws it in the buffer in the player's data area).
;
DrawShieldPl2:
        LXI     H,0x2242                ; Player 2 shield buffer (remember between games in multi-player)

;
L_023E:
        MVI     C,0x04                  ; Going to draw 4 shields
        LXI     D,ShieldImage           ; Shield pixel pattern
L_0243:
        PUSH    D                       ; Hold the start for the next shield
        MVI     B,0x2C                  ; 44 bytes to copy
        CALL    BlockCopy               ; Block copy DE to HL (B bytes)
        POP     D                       ; Restore start of shield pattern
        DCR     C                       ; Drawn all shields?
        JNZ     L_0243                  ; No ... go draw them all
        RET                             ; Done

; Copy shields on the screen to player 1's data area.
;
RememberShields1:
        MVI     A,0x01                  ; Not zero means remember
        JMP     L_0261                  ; Shuffle-shields player 1

; Copy shields on the screen to player 2's data area.
;
RememberShields2:
        MVI     A,0x01                  ; Not zero means remember
        JMP     L_025A                  ; Shuffle-shields player 2

; Copy shields from player 2's data area to screen.
;
RestoreShields2:
        XRA     A                       ; Zero means restore
L_025A:
        LXI     D,0x2242                ; Player 2 shield buffer (remember between games in multi-player)
        JMP     CopyShields             ; Shuffle-shields player 2

; Copy shields from player 1's data area to screen.
;
RestoreShields1:
        XRA     A                       ; Zero means restore
L_0261:
        LXI     D,0x2142                ; Player 1 shield buffer (remember between games in multi-player)

; A is 1 for screen-to-buffer, 0 for to buffer-to-screen
; HL is screen coordinates of first shield. There are 23 rows between shields.
; DE is sprite buffer in memory.
;
CopyShields:
        STA     tmp2081                 ; Remember copy/restore flag
        LXI     B,0x1602                ; 22 rows, 2 bytes/row (for 1 shield pattern)
        LXI     H,0x2806                ; Screen coordinates
        MVI     A,0x04                  ; Four shields to move
L_026F:
        PUSH    PSW                     ; Hold shield count
        PUSH    B                       ; Hold sprite-size
        LDA     tmp2081                 ; Get back copy/restore flag
        ANA     A                       ; Not zero ...
        JNZ     L_0288                  ; ... means remember shidles
        CALL    RestoreShields          ; Restore player's shields
L_027B:
        POP     B                       ; Get back sprite-size
        POP     PSW                     ; Get back shield count
        DCR     A                       ; Have we moved all shields?
        RZ                              ; Yes ... out
        PUSH    D                       ; Hold sprite buffer
        LXI     D,0x02E0                ; Add 2E0 (23 rows) to get to ...
        DAD     D                       ; ... next shield on screen
        POP     D                       ; restore sprite buffer
        JMP     L_026F                  ; Go back and do all

;
L_0288:
        CALL    RememberShields         ; Remember player's shields
        JMP     L_027B                  ; Continue with next shield

;======================================================================
; Game Objects
;======================================================================


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
RunGameObjs:
        LXI     H,obj0TimerMSB          ; First game object (active player)
L_0291:
        MOV     A,M                     ; Have we reached the ...
        CPI     0xFF                    ; ... end of the object list?
        RZ                              ; Yes ... done
        CPI     0xFE                    ; Is object active?
        JZ      L_02C7                  ; No ... skip it
        INX     H                       ; xx01
        MOV     B,M                     ; First byte to B
        MOV     C,A                     ; Hold 1st byte
        ORA     B                       ; OR 1st and 2nd byte
        MOV     A,C                     ; Restore 1st byte
        JNZ     L_02BD                  ; If word at xx00,xx02 is non zero then decrement it

;
        INX     H                       ; xx02
        MOV     A,M                     ; Get byte counter
        ANA     A                       ; Is it 0?
        JNZ     L_02CE                  ; No ... decrement byte counter at xx02
        INX     H                       ; xx03
        MOV     E,M                     ; Get handler address LSB
        INX     H                       ; xx04
        MOV     D,M                     ; Get handler address MSB
        PUSH    H                       ; Remember pointer to MSB
        XCHG                            ; Handler address to HL
        PUSH    H                       ; Now to stack (making room for indirect call)
        LXI     H,L_02B5                ; Return address to 02B5
        XTHL                            ; Return address (02B5) now on stack. Handler in HL.
        PUSH    D                       ; Push pointer to data struct (xx04) for handler to use
        PCHL                            ; Run object's code (will return to next line)
L_02B5:
        POP     H                       ; Restore pointer to xx04
        LXI     D,0x000C                ; Offset to next ...
        DAD     D                       ; ... game task (C+4=10)
        JMP     L_0291                  ; Do next game task

;
; Word at xx00 and xx01 is non-zero. Decrement it and move to next task.
L_02BD:
        DCR     B                       ; Decrement ...
        INR     B                       ; ... two ...
        JNZ     L_02C3                  ; ... byte ...
        DCR     A                       ; ... value ...
L_02C3:
        DCR     B                       ; ... at ...
        MOV     M,B                     ; ... xx00 ...
        DCX     H                       ; ... and ...
        MOV     M,A                     ; ... xx01

;
L_02C7:
        LXI     D,0x0010                ; Next ...
        DAD     D                       ; ... object descriptor
        JMP     L_0291                  ; Keep processing game objects

;
; Word at xx00 and xx01 is zero and byte at xx02 is non-zero. Decrement xx02 and
; move to next task.
L_02CE:
        DCR     M                       ; Decrement the xx02 counter
        DCX     H                       ; Back up to ...
        DCX     H                       ; ... start of game task
        JMP     L_02C7                  ; Next game task

; Game object 0: Move/draw the player
;
; This task is only called at the mid-screen ISR. It ALWAYS does its work here, even though
; the player can be on the top or bottom of the screen (not rotated).
;
GameObj0:
        POP     H                       ; Get player object structure 2014
        INX     H                       ; Point to blow-up status
        MOV     A,M                     ; Get player blow-up status
        CPI     0xFF                    ; Player is blowing up?
        JZ      L_0388                  ; No ... go do normal movement

;
; Handle blowing up player
        INX     H                       ; Point to blow-up delay count
        DCR     M                       ; Decrement the blow-up delay
        RNZ                             ; Not time for a new blow-up sprite ... out
        MOV     B,A                     ; Hold sprite image number
        XRA     A                       ; 0
        STA     playerOK                ; Player is NOT OK ... player is blowing up
        STA     enableAlienFire         ; Alien fire is disabled
        MVI     A,0x30                  ; Reset count ...
        STA     alienFireDelay          ; ... till alien shots are enabled
        MOV     A,B                     ; Restore sprite image number (used if we go to 39B)
        MVI     M,0x05                  ; Reload time between blow-up changes
        INX     H                       ; Point to number of blow-up changes
        DCR     M                       ; Count down blow-up changes
        JNZ     DrawPlayerDie           ; Still blowing up ... go draw next sprite

;
; Blow up finished
        LHLD    playerYr                ; Player's coordinates
        MVI     B,0x10                  ; 16 Bytes
        CALL    CnvtPixNumber           ; Convert player position to screen address
        CALL    ClearSmallSprite        ; Erase the player (16 rows)
        LXI     H,obj0TimerMSB          ; Restore player ...
        LXI     D,D_1B10                ; ... structure ...
        MVI     B,0x10                  ; ... from ...
        CALL    BlockCopy               ; ... ROM mirror
        MVI     B,0x00                  ; Turn off ...
        CALL    SoundBits3Off           ; ... all sounds
        LDA     invaded                 ; Has rack reached ...
        ANA     A                       ; ... the bottom of the screen?
        RNZ                             ; Yes ... done here
        LDA     gameMode                ; Are we in ...
        ANA     A                       ; ... game mode?
        RZ                              ; No ... return to splash screens
        LXI     SP,0x2400               ; We aren't going to return
        EI                              ; Enable interrupts (we just dropped the ISR context)
        CALL    DsableGameTasks         ; Disable game tasks
        CALL    GetNumShips             ; Get number of ships for active player
        ANA     A                       ; Any left?
        JZ      L_1453                  ; No ... handle game over for player
        CALL    L_16A5                  ; Get player-alive status pointer
        MOV     A,M                     ; Is player ...
        ANA     A                       ; ... alive?
        JZ      L_037C                  ; Yes ... remove a ship from player's stash and reenter game loop
        LDA     twoPlayers              ; Multi-player game
        ANA     A                       ; Only one player?
        JZ      L_037C                  ; Yes ... remove a ship from player's stash and reenter game loop
L_0336:
        LDA     playerDataMSB           ; Player data MSB
        PUSH    PSW                     ; Hold the MSB
        RRC                             ; Player 1 is active player?
        JC      L_0382                  ; Yes ... go store player 1 shields and come back to 0349
        CALL    RememberShields2        ; No ... go store player 2 shields
L_0341:
        LDA     refAlienDXr             ; Part II reads the ref-alien info directly ...
        MOV     B,A                     ; ... B = delta X
        LHLD    refAlienYr              ; ... DE = Y,X ...
        XCHG                            ; ... coordinates
        CALL    GetAlRefPtr             ; Get ref-alien info and pointer to storage
        MOV     M,E                     ; Hold the ...
        INX     H                       ; ... ref-alien ...
        MOV     M,D                     ; ... screen coordinates
        DCX     H                       ; Back up ...
        DCX     H                       ; .. to delta storage
        MOV     M,B                     ; Store ref-alien's delta (direction)
        CALL    CopyRAMMirror           ; Copy RAM mirror (getting ready to switch players)
        POP     PSW                     ; Restore active player MSB
        RRC                             ; Player 1?
        MVI     A,0x21                  ; Player 1 data pointer
        MVI     B,0x00                  ; Cocktail bit=0 (player 1)
        JNC     L_0362                  ; It was player one ... keep data for player 2
        MVI     B,0x20                  ; Cocktail bit=1 (player 2)
        MVI     A,0x22                  ; Player 2 data pointer
L_0362:
        STA     playerDataMSB           ; Change players
        CALL    TwoSecDelay             ; Two second delay
        XRA     A                       ; Clear the player-object ...
        STA     obj0TimerLSB            ; ... timer (player can move instantly after switching players)
        CALL    SetFlipDelay            ; Set the cocktail bit (B) on port 5
        INR     A                       ; Fleet sound 1 (first tone)
        STA     soundPort5              ; Set the port 5 hold
        CALL    ClearPlayField          ; Clear center window
        CALL    RemoveShip              ; Remove a ship and update indicators
        JMP     L_08FD                  ; Tell the players that the switch has been made

;
L_037C:
        CALL    RemoveShip              ; Remove a ship and update indicators
        JMP     L_0936                  ; Continue into game loop

;
L_0382:
        CALL    RememberShields1        ; Remember the shields for player 1
        JMP     L_0341                  ; Back to switching-players above

; Player not blowing up ... handle inputs
L_0388:
        LXI     H,playerOK              ; Player OK flag
        MVI     M,0x01                  ; Flag 1 ... player is OK
        INX     H                       ; 2069
        MOV     A,M                     ; Alien shots enabled?
        ANA     A                       ; Set flags
        JNZ     L_039B                  ; Alien fire already enabled ... skip
        INX     H                       ; 206A alien-fire delay
        DCR     M                       ; Count down until aliens can fire
        JNZ     L_039B                  ; Not yet
        DCX     H                       ; 2069
        MVI     M,0x01                  ; Enable alien fire
L_039B:
        LDA     playerXr                ; Current player coordinates
        MOV     B,A                     ; Hold it
        LDA     gameMode                ; Are we in ...
        ANA     A                       ; ... game mode?
        JNZ     L_03B4                  ; Yes ... use switches as player controls

;
        LDA     nextDemoCmd             ; Get demo command
        RRC                             ; Is it right?
        JC      MovePlayerRight         ; Yes ... do right
        RRC                             ; Is it left?
        JC      MovePlayerLeft          ; Yes ... do left
        JMP     L_03C0                  ; Skip over movement (draw player and out)

; Player is in control
L_03B4:
        CALL    ReadInputs              ; Read active player controls
        RLC                             ; Test for ...
        RLC                             ; ... right button
        JC      MovePlayerRight         ; Yes ... handle move right
        RLC                             ; Test for left button
        JC      MovePlayerLeft          ; Yes ... handle move left

; Draw player sprite
L_03C0:
        LXI     H,plyrSprPicL           ; Active player descriptor
        CALL    ReadDesc                ; Load 5 byte sprite descriptor in order: EDLHB
        CALL    ConvToScr               ; Convert HL to screen coordinates
        CALL    DrawSimpSprite          ; Draw player
        XRA     A                       ; Clear the task timer. Nobody changes this but it could have ...
        STA     obj0TimerExtra          ; ... been speed set for the player with a value other than 0
        RET                             ; Out

MovePlayerRight:
        MOV     A,B                     ; Player coordinate
        CPI     0xD8                    ; At right edge? (Part II stops one pixel sooner: D8 instead of D9)
        JZ      L_03C0                  ; Yes ... ignore this
        INR     A                       ; Bump X coordinate
        STA     playerXr                ; New X coordinate
        JMP     L_03C0                  ; Draw player and out

; Handle player moving left
MovePlayerLeft:
        MOV     A,B                     ; Player coordinate
        CPI     0x30                    ; At left edge
        JZ      L_03C0                  ; Yes ... ignore this
        DCR     A                       ; Bump X coordinate
        STA     playerXr                ; New X coordinate
        JMP     L_03C0                  ; Draw player and out

; Toggle the player's blowing-up sprite between two pictures and draw it
DrawPlayerDie:
        INR     A                       ; Toggle blowing-up ...
        ANI     0x01                    ; ... player sprite (0,1,0,1)
        STA     playerAlive             ; Hold current state
        RLC                             ; *2
        RLC                             ; *4
        RLC                             ; *8
        RLC                             ; *16
        LXI     H,PlrBlowupSprites      ; Base blow-up sprite location
        ADD     L                       ; Offset sprite ...
        MOV     L,A                     ; ... pointer
        SHLD    plyrSprPicL             ; New blow-up sprite picture
        JMP     L_03C0                  ; Draw player and out

; Game object 1: Move/draw the player shot
;
; This task executes at either mid-screen ISR (if it is on the top half of the non-rotated screen) or
; at the end-screen ISR (if it is on the bottom half of the screen).
;
GameObj1:
        LXI     D,obj1CoorXr            ; Object's Yn coordiante
        CALL    CompYToBeam             ; Compare to screen-update location
        POP     H                       ; Pointer to task data
        RNC                             ; Make sure we are in the right ISR
        INX     H                       ; Point to 2025 ... the shot status
        MOV     A,M                     ; Get shot status
        ANA     A                       ; Return if ...
        RZ                              ; ... no shot is active

;
        CPI     0x01                    ; Shot just starting (requested elsewhere)?
        JZ      InitPlyShot             ; Yes ... go initiate shot

;
        CPI     0x02                    ; Progressing normally?
        JZ      MovePlyShot             ; Yes ... go move it

;
        INX     H                       ; 2026
        CPI     0x03                    ; Shot blowing up (not because of alien)?
        JNZ     L_046F                  ; No ... try other options

;
; Shot blowing up because it left the playfield, hit a shield, or hit another bullet
        DCR     M                       ; Decrement the timer
        JZ      EndOfBlowup             ; If done then
        MOV     A,M                     ; Get timer value
        CPI     0x0F                    ; Starts at 10 ... first decrement brings us here
        RNZ                             ; Not the first time ... explosion has been drawn

; Draw explosion first pass through timer loop
        PUSH    H                       ; Hold pointer to data
        CALL    ReadPlyShot             ; Read shot descriptor
        CALL    EraseShifted            ; Erase the sprite
        POP     H                       ; 2026 (timer flag)
        INX     H                       ; 2027 point to sprite LSB
        INR     M                       ; Change 1CB1 to 1CB2
        INX     H                       ; 2028
        INX     H                       ; 2029
        DCR     M                       ; Drop X coordinate ...
        DCR     M                       ; ... by 2
        INX     H                       ; 202A
        DCR     M                       ; Drop Y ...
        DCR     M                       ; ... coordinate ...
        DCR     M                       ; ... by ...
        INX     H                       ; ... 3
        MVI     M,0x08                  ; 202B 8 bytes in size of sprite
        CALL    ReadPlyShot             ; Read player shot structure
        JMP     DrawShiftedSprite       ; Draw sprite and out

;
InitPlyShot:
        INR     A                       ; Type is now ...
        MOV     M,A                     ; ... 2 (in progress)
        LDA     playerXr                ; Players Y coordinate
        ADI     0x08                    ; To center of player
        STA     obj1CoorXr              ; Shot's Y coordinate
        CALL    ReadPlyShot             ; Read 5 byte structure
        JMP     DrawShiftedSprite       ; Draw sprite and out

;
MovePlyShot:
        CALL    ReadPlyShot             ; Read the shot structure
        PUSH    D                       ; Hold pointer to sprite image
        PUSH    H                       ; Hold sprite coordinates
        PUSH    B                       ; Hold sprite size (in B)
        CALL    EraseShifted            ; Erase the sprite from the screen
        POP     B                       ; Restore size
        POP     H                       ; Restore coords
        POP     D                       ; Restore pointer to sprite image
        LDA     shotDeltaX              ; DeltaX for shot
        ADD     L                       ; Move the shot ...
        MOV     L,A                     ; ... up the screen
        STA     obj1CoorYr              ; Store shot's new X coordinate
        CALL    DrawSprCollision        ; Draw sprite with collision detection
        LDA     collision               ; Test for ...
        ANA     A                       ; ... collision
        RZ                              ; No collision ... out

;
; Collision with alien detected
        STA     alienIsExploding        ; Set to not-0 indicating ...
        RET                             ; ... an alien is blowing up

;
; Other shot-status options
L_046F:
        CPI     0x05                    ; Alien explosion in progress?
        RZ                              ; Yes ... nothing to do
        JMP     EndOfBlowup             ; Anything else erases the shot and removes it from duty

ReadPlyShot:
        LXI     H,obj1ImageLSB          ; Read 5 byte sprite structure for ...
        JMP     ReadDesc                ; ... player shot

EndOfBlowup:
        CALL    ReadPlyShot             ; Read the shot structure
        CALL    EraseShifted            ; Erase the player's shot
        LXI     H,plyrShotStatus        ; Reinit ...
        LXI     D,D_1B25                ; ... shot structure ...
        MVI     B,0x07                  ; ... from ...
        CALL    BlockCopy               ; ... ROM mirror
        LHLD    sauScoreLSB             ; Get pointer to saucer-score table
        INR     L                       ; Every shot explosion advances it one
        PUSH    H                       ; Hold saucer-score pointer
        CALL    GetPlayerDataPage       ; H = active player's data page
        MVI     L,0xF8                  ; 2xF8 counts ...
        INR     M                       ; ... the player's shots for this rack
        POP     H                       ; Restore saucer-score pointer
        MOV     A,L                     ; Have we passed ...
        CPI     0x5F                    ; ... the end at 1D5F (the same off-by-one as the original: the last entry is never used)
        JC      L_04A0                  ; No .... keep it
        MVI     L,0x50                  ; Wrap back around to 1D50
L_04A0:
        SHLD    sauScoreLSB             ; New score pointer
        LHLD    shotCountLSB            ; Increments with every shot ...
        INR     L                       ; ... but only LSB ** ...
        SHLD    shotCountLSB            ; ... used for saucer direction

;
        LDA     saucerActive            ; Is saucer ...
        ANA     A                       ; ... on screen?
        RNZ                             ; Yes ... don't reset it

;
; Setup saucer direction for next trip
        MOV     A,M                     ; Shot counter
        ANI     0x01                    ; Lowest bit set?
        LXI     B,0x0229                ; Xr delta of 2 starting at Xr=29
        JNZ     L_04BB                  ; Yes ... use 2/29
        LXI     B,0xFEE0                ; No ... Xr delta of -2 starting at Xr=E0
L_04BB:
        LXI     H,saucerPriPicMSB       ; Saucer descriptor
        MOV     M,C                     ; Store Xr coordinate
        INX     H                       ; Point to ...
        INX     H                       ; ... delta Xr
        MOV     M,B                     ; Store delta Xr
        RET                             ; Done

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
GameObj2:
        POP     H                       ; Game object data
        LDA     D_1B32                  ; Restore delay from ...
        STA     obj2TimerExtra          ; ... ROM mirror (value 2)
        LHLD    rolShotCFirLSB          ; Get pointer to ...
        MOV     A,L                     ; ... column-firing table.
        ORA     H                       ; All zeros?
        JNZ     L_04D7                  ; No ... must be a valid column. Go fire.
        DCX     H                       ; Decrement the counter
        SHLD    rolShotCFirLSB          ; Store new counter value (run the shot next time)
        RET                             ; And out
L_04D7:
        LXI     D,rolShotStatus         ; Rolling-shot data structure
        MVI     A,0xFC                  ; LSB of last byte of last picture of the rolling shot
        CALL    ToShotStruct            ; Set code to handle rolling-shot
        LDA     pluShotStepCnt          ; Get the plunger-shot step count
        STA     otherShot1              ; Hold it
        LDA     squShotStepCnt          ; Get the squiggly-shot step count
        STA     otherShot2              ; Hold it
        CALL    HandleAlienShotChk      ; Handle active shot structure
        LDA     aShotBlowCnt            ; Blow up counter
        ANA     A                       ; Test if shot has cycled through blowing up
        LXI     H,rolShotStatus         ; Rolling-shot data structure
        JNZ     FromShotStruct          ; If shot is still running, copy the updated data and out

; The rolling-shot has blown up. Reset the data structure.
ResetShot:
        LXI     D,D_1B30                ; Reload ...
        LXI     H,obj2TimerMSB          ; ... object ...
        MVI     B,0x10                  ; ... structure ...
        JMP     BlockCopy               ; ... from ROM mirror and out

; Game object 3: Alien plunger shot
;
; This is the plunger shot that drops from the column-firing table. Part II does not use the
; plunger shot at all from round 4 on.
GameObj3:
        CALL    GetRoundNum             ; Get the player's round number
        CPI     0x04                    ; Round 4 or later?
        POP     H                       ; Game object data (not used)
        JNC     L_0558                  ; Yes ... permanently disable the plunger shot
        LDA     skipPlunger             ; One alien left? Skip plunger shot?
        ANA     A                       ; Check
        RNZ                             ; Yes. Only one alien. Skip this shot.
        LDA     shotSync                ; Sync flag (copied from GO-2's timer value)
        CPI     0x01                    ; GO-2 and GO-4 are idle?
        RNZ                             ; No ... only one shot at a time
        LXI     D,pluShotStatus         ; Plunger alien shot data structure
        MVI     A,0xF0                  ; LSB of last byte of last picture of the plunger shot
        CALL    ToShotStruct            ; Copy the plunger alien to the active structure
        LDA     rolShotStepCnt          ; Step count from rolling-shot
        STA     otherShot1              ; Hold it
        LDA     squShotStepCnt          ; Step count from squiggly shot
        STA     otherShot2              ; Hold it
        CALL    HandleAlienShotChk      ; Handle active shot structure
        LDA     aShotCFirLSB            ; LSB of column-firing table
        CPI     0x90                    ; Been through all entries in the table (table is now at 1A80)?
        JC      L_053C                  ; Not yet ... table is OK
        LDA     D_1B48                  ; Been through all ..
        STA     aShotCFirLSB            ; ... so reset pointer into firing-column table
L_053C:
        LDA     aShotBlowCnt            ; Get the blow up timer
        ANA     A                       ; Zero means shot is done
        LXI     H,pluShotStatus         ; Plunger shot data
        JNZ     FromShotStruct          ; If shot is still running, go copy the updated data and out

;
        LXI     D,D_1B40                ; Reload ...
        LXI     H,obj3TimerMSB          ; ... object ...
        MVI     B,0x10                  ; ... structure ...
        CALL    BlockCopy               ; ... from mirror

;
        LDA     numAliens               ; Number of aliens on screen
        DCR     A                       ; Is there only one left?
        JNZ     L_055D                  ; No ... move on
L_0558:
        MVI     A,0x01                  ; Disable plunger shot ...
        STA     skipPlunger             ; ... when only one alien remains
L_055D:
        LHLD    aShotCFirLSB            ; Set the plunger shot's ...
        JMP     L_06D5                  ; ... column-firing pointer data
        DB      0xE1

HandleSquiggly:
        LXI     D,squShotStatus
        MVI     A,0xDE                  ; LSB of last byte of the squiggly picture
        CALL    ToShotStruct            ; Copy squiggly shot to
        LDA     pluShotStepCnt          ; Get plunger ...
        STA     otherShot1              ; ... step count
        LDA     rolShotStepCnt          ; Get rolling ...
        STA     otherShot2              ; ... step count
        CALL    HandleAlienShotChk      ; Handle active shot structure
        LDA     aShotCFirLSB            ; LSB of column-firing table pointer
        CPI     0x95                    ; Have we processed all entries?
        JC      L_0589                  ; No ... don't reset it
        LDA     D_1B58                  ; Reset the pointer ...
        STA     aShotCFirLSB            ; ... back to the start of the table
L_0589:
        LDA     aShotBlowCnt            ; Check to see if squiggly shot is done
        ANA     A                       ; 0 means blow-up timer expired
        LXI     H,squShotStatus         ; Squiggly shot data structure
        JNZ     FromShotStruct          ; If shot is still running, go copy the updated data and out

; Shot explosion is over. Remove the shot.
        LXI     D,D_1B50                ; Reload
        LXI     H,obj4TimerMSB          ; ... object ...
        MVI     B,0x10                  ; ... structure ...
        CALL    BlockCopy               ; ... from mirror
        LHLD    aShotCFirLSB            ; Copy pointer to column-firing table ...
        SHLD    squShotCFirLSB          ; ... back to data structure (for next shot)
        RET                             ; Done

ToShotStruct:
        STA     shotPicEnd              ; LSB of last byte of last picture in sprite
        LXI     H,aShotStatus           ; Destination is the shot-structure
        MVI     B,0x0B                  ; 11 bytes
        JMP     BlockCopy               ; Block copy and out

FromShotStruct:
        LXI     D,aShotStatus           ; Source is the shot-structure
        MVI     B,0x0B                  ; 11 bytes
        JMP     BlockCopy               ; Block copy and out

; Part II: no alien shots while shots are halted (rack arrival, name entry).
HandleAlienShotChk:
        LDA     shotsHalted             ; Are alien shots halted?
        ANA     A                       ; Set flags
        RNZ                             ; Yes ... nothing to do

; Each of the 3 shots copy their data to the 2073 structure (0B bytes) and call this.
; Then they copy back if the shot is still active. Otherwise they copy from the mirror.
;
; The alien "fire rate" is based on the number of steps the other two shots on the screen
; have made. The smallest number-of-steps is compared to the reload-rate. If it is too
; soon then no shot is made. The reload-rate is based on the player's score. The MSB
; is looked up in a table to get the reload-rate. The smaller the rate the faster the
; aliens fire. Setting rate this way keeps shots from walking on each other.
;
HandleAlienShot:
        LXI     H,aShotStatus           ; Start of active shot structure
        MOV     A,M                     ; Get the shot status
        ANI     0x80                    ; Is the shot active?
        JNZ     L_061A                  ; Yes ... go move it
        LDA     isrSplashTask           ; ISR splash task
        CPI     0x04                    ; Shooting the "C" ? (left over from the original: Part II has no "CCOIN" animation)
        LDA     enableAlienFire         ; Alien fire enabled flag
        JZ      L_0610                  ; (Never taken in Part II)
        ANA     A                       ; Is alien fire enabled?
        RZ                              ; No ... don't start a new shot
        INX     H                       ; 2074 step count of current shot
        MVI     M,0x00                  ; clear the step count

; Make sure it isn't too soon to fire another shot
        LDA     otherShot1              ; Get the step count of the 1st "other shot"
        ANA     A                       ; Any steps made?
        JZ      L_05E3                  ; No ... ignore this count
        MOV     B,A                     ; Shuffle off step count
        LDA     aShotReloadRate         ; Get the reload rate (based on MSB of score)
        CMP     B                       ; Too soon to fire again?
        RNC                             ; Yes ... don't fire
L_05E3:
        LDA     otherShot2              ; Get the step count of the 2nd "other shot"
        ANA     A                       ; Any steps made?
        JZ      L_05F0                  ; No steps on any shot ... we are clear to fire
        MOV     B,A                     ; Shuffle off step count
        LDA     aShotReloadRate         ; Get the reload rate (based on MSB of score)
        CMP     B                       ; Too soon to fire again?
        RNC                             ; Yes ... don't fire
L_05F0:
        INX     H                       ; 2075
        MOV     A,M                     ; Get tracking flag
        ANA     A                       ; Does this shot track the player?
        JZ      L_0673                  ; Yes ... go make a tracking shot;
        LHLD    aShotCFirLSB            ; Column-firing table
        MOV     C,M                     ; Get next column to fire from
        INX     H                       ; Bump the ...
        SHLD    aShotCFirLSB            ; ... pointer into column table
L_05FE:
        CALL    FindInColumn            ; Find alien in target column
        RNC                             ; No alien is alive in target column ... out

;
        CALL    GetAlienCoords          ; Get coordinates of alien (lowest alien in firing column)
        MOV     A,C                     ; Offset ...
        ADI     0x07                    ; ... Y by 7
        MOV     H,A                     ; To H
        MOV     A,L                     ; Offset ...
        SUI     0x0A                    ; ... X down 10
        MOV     L,A                     ; To L
        SHLD    alienShotYr             ; Set shot coordinates below alien

;
L_0610:
        LXI     H,aShotStatus           ; Alien shot status
        MOV     A,M                     ; Get the status
        ORI     0x80                    ; Mark this shot ...
        MOV     M,A                     ; ... as actively running
        INX     H                       ; 2074 step count
        INR     M                       ; Give this shot 1 step (it just started)
        RET                             ; Out

;
; Move the alien shot
L_061A:
        LXI     D,alienShotXr           ; Alien-shot Y coordinate
        CALL    CompYToBeam             ; Compare to beam position
        RNC                             ; Not the right ISR for this shot

;
        INX     H                       ; 2073 status
        MOV     A,M                     ; Get shot status
        ANI     0x01                    ; Bit 0 is 1 if blowing up
        JNZ     ShotBlowingUp           ; Go do shot-is-blowing-up sequence
        INX     H                       ; 2074 step count
        INR     M                       ; Count the steps (used for fire rate)
        CALL    L_06CC                  ; Erase shot
        LDA     aShotImageLSB           ; Get LSB of the image pointer
        ADI     0x03                    ; Next set of images
        LXI     H,shotPicEnd            ; End of image
        CMP     M                       ; Have we reached the end of the set?
        JC      L_063B                  ; No ... keep it
        SUI     0x0C                    ; Back up to the 1st image in the set
L_063B:
        STA     aShotImageLSB           ; New LSB image pointer
        LDA     alienShotYr             ; Get shot's Y coordinate
        MOV     B,A                     ; Hold it
        LDA     alienShotDelta          ; Get alien shot delta
        ADD     B                       ; Add to shots coordinate
        STA     alienShotYr             ; New shot Y coordinate
        CALL    L_06C3                  ; Draw the alien shot
        LDA     alienShotYr             ; Shot's Y coordinate
        CPI     0x15                    ; Still in the active playfield?
        JC      L_066A                  ; No ... end it
        LDA     collision               ; Did shot collide ...
        ANA     A                       ; ... with something?
        RZ                              ; No ... we are done here
        LDA     alienShotYr             ; Shot's Y coordinate
        CPI     0x1E                    ; Is it below player's area?
        JC      L_066A                  ; Yes ... end it
        CPI     0x27                    ; Is it above player's area?
        JNC     L_066A                  ; Yes ... end it
        SUB     A                       ; Flag that player ...
        STA     playerAlive             ; ... has been struck

;
L_066A:
        LDA     aShotStatus             ; Flag to ...
        ORI     0x01                    ; ... start shot ...
        STA     aShotStatus             ; ... blowing up
        RET                             ; Out

;
; Start a shot right over the player
L_0673:
        LDA     playerXr                ; Player's X coordinate
        ADI     0x08                    ; Center of player
        MOV     H,A                     ; To H for routine
        CALL    FindColumn              ; Find the column
        MOV     A,C                     ; Get the column right over player
        CPI     0x0C                    ; Is it a valid column?
        JC      L_05FE                  ; Yes ... use what we found
        MVI     C,0x0B                  ; Else use ...
        JMP     L_05FE                  ; ... as far over as we can

; C contains the target column. Look for a live alien in the column starting with
; the lowest position. Return C=1 if found ... HL points to found slot.
FindInColumn:
        DCR     C                       ; Column that is firing
        CALL    GetPlayerDataPage
        MOV     L,C                     ; Column to L
        MVI     D,0x05                  ; 5 rows of aliens
L_068E:
        MOV     A,M                     ; Get alien's status
        ANA     A                       ; 0 means dead
        STC                             ; In case not 0
        RNZ                             ; Alien is alive? Yes ... return
        MOV     A,L                     ; Get the flag pointer LSB
        ADI     0x0B                    ; Jump to same column on next row of rack (+11 aliens per row)
        MOV     L,A                     ; New alien index
        DCR     D                       ; Tested all rows?
        JNZ     L_068E                  ; No ... keep looking for a live alien up the rack
        RET                             ; Didn't find a live alien. Return with C=0.

; Alien shot is blowing up
ShotBlowingUp:
        LXI     H,aShotBlowCnt          ; Blow up timer
        DCR     M                       ; Decrement the value
        MOV     A,M                     ; Get the value
        CPI     0x03                    ; First tick, 4, we draw the explosion
        JNZ     L_06BE                  ; After that just wait
        CALL    L_06CC                  ; Erase the shot
        LXI     H,AShotExplo            ; Alien shot ...
        SHLD    aShotImageLSB           ; ... explosion sprite
        LXI     H,alienShotXr           ; Alien shot Y
        DCR     M                       ; Left two for ...
        DCR     M                       ; ... explosion
        DCX     H                       ; Point slien shot X
        DCR     M                       ; Up two for ...
        DCR     M                       ; ... explosion
        MVI     A,0x06                  ; Alien shot descriptor ...
        STA     alienShotSize           ; ... size 6
        JMP     L_06C3                  ; Draw alien shot explosion
L_06BE:
        ANA     A                       ; Have we reached 0?
        RNZ                             ; No ... keep waiting
        JMP     L_06CC                  ; Erase the explosion and out

;
L_06C3:
        LXI     H,aShotImageLSB         ; Alien shot descriptor
        CALL    ReadDesc                ; Read 5 byte structure
        JMP     DrawSprCollision        ; Draw shot and out

;
L_06CC:
        LXI     H,aShotImageLSB         ; Alien shot descriptor
        CALL    ReadDesc                ; Read 5 byte structure
        JMP     EraseShifted            ; Erase the shot and out
L_06D5:
        SHLD    pluShotCFirLSB          ; From 50B, update ...
        RET                             ; ... column-firing table pointer and out

; Game object 4: Flying Saucer OR squiggly shot
;
; This task is shared by the squiggly-shot and the flying saucer. The saucer waits until the
; squiggly-shot is over before it begins.
;
GameObj4:
        POP     H                       ; Pull data pointer from the stack (not going to use it)
        LDA     shotSync                ; Sync flag (copied from GO-2's timer value)
        CPI     0x02                    ; Are GO-2 and GO-3 idle?
        RNZ                             ; No ... only one at a time
        LXI     H,saucerStart           ; Time-till-saucer flag
        MOV     A,M                     ; Is it time ...
        ANA     A                       ; ... for a saucer?
        JZ      HandleSquiggly          ; No ... go process squiggly shot
        LDA     squShotStepCnt          ; Is there a ...
        ANA     A                       ; ... squiggly shot going?
        JNZ     HandleSquiggly          ; Yes ... go handle squiggly shot
        INX     H                       ; Saucer on screen flag
        MOV     A,M                     ; (2084) Is the saucer ...
        ANA     A                       ; ... already on the screen?
        JNZ     L_0705                  ; Yes ... go handle it
        LDA     numAliens               ; Number of aliens remaining
        CPI     0x08                    ; Less than ...
        JC      HandleSquiggly          ; ... 8 ... no saucer
        MVI     M,0x01                  ; (2084) The saucer is on the screen
        CALL    SaucerStart             ; Count this saucer (the 2nd one in a rack is the flashing one)
        CALL    DrawSaucer              ; Draw the flying saucer
L_0705:
        LXI     D,saucerPriPicMSB       ; Saucer's Y coordinate
        CALL    CompYToBeam             ; Compare to beam position
        RNC                             ; Not the right ISR for moving saucer
        LXI     H,saucerHit             ; Saucer hit flag
        MOV     A,M                     ; Has saucer ...
        ANA     A                       ; ... been hit?
        JNZ     L_078C                  ; Yes ... don't move it
        LDA     dropActive              ; Is the saucer dropping an alien into the rack?
        ANA     A                       ; Set flags
        LXI     H,saucerPriPicMSB       ; Saucer's structure
        JZ      L_0721                  ; No ... move it
        JMP     DrawSaucer              ; Yes ... hover in place (just redraw)
L_0721:
        MOV     A,M                     ; Get saucer's Y coordinate
        INX     H                       ; Bump to ...
        INX     H                       ; ... delta Y
        ADD     M                       ; Move saucer
        STA     saucerPriPicMSB         ; New coordinate
        CALL    DrawSaucerBlink         ; Draw the flying saucer
        LXI     H,saucerPriPicMSB       ; Saucer's structure
        MOV     A,M                     ; Y coordinate
        CPI     0x28                    ; Too low? End of screen?
        JC      L_07AC                  ; Yes ... remove from play
        CPI     0xE1                    ; Too high? End of screen?
        JNC     L_07AC                  ; Yes ... remove from play
        RET                             ; Done

; Part II: the second saucer of a rack is the flashing saucer. It is drawn only half
; the time (4 ticks on, 4 ticks off).
DrawSaucerBlink:
        CALL    IsFlashSaucer           ; Is this the flashing saucer?
        JNZ     DrawSaucer              ; No ... just draw it
        LXI     H,saucerBlinkTmr        ; Blink timer
        INR     M                       ; Tick it
        MOV     A,M                     ; Get value
        ANI     0x04                    ; Visible or invisible half of the cycle?
        JNZ     L_074D                  ; Invisible ... erase it
        JMP     DrawSaucer              ; Visible ... draw it
L_074D:
        CALL    SaucerToScreen          ; Get the saucer's screen coordinates
        JMP     ClearSmallSprite        ; Erase it and out

; Return Z set if this is the 2nd saucer of the rack (the flashing one).
IsFlashSaucer:
        LDA     saucerBlink             ; Number of saucers this rack
        CPI     0x02                    ; Is this the 2nd one?
        RET                             ; Z=yes

; Count the saucers. The 2nd one uses the flashing-saucer picture at 187E.
SaucerStart:
        LXI     H,saucerBlink           ; Number of saucers this rack
        INR     M                       ; One more
        MOV     A,M                     ; Get count
        CPI     0x02                    ; Is this the 2nd one?
        RNZ                             ; No ... normal saucer
        LXI     H,SpriteSaucerFlash     ; Flashing-saucer picture
        SHLD    saucerPriLocLSB         ; Use it for the saucer
        LDA     saucerDeltaY            ; (Reads and writes the delta back ... no effect)
        STA     saucerDeltaY
        RET                             ; Done

; If the flashing saucer was hit it is always worth 500 (this returns to the caller's
; caller with B=50 and the "500" message).
FlashSaucerScore:
        CALL    IsFlashSaucer           ; Was it the flashing saucer?
        RNZ                             ; No ... normal mystery score
        LXI     H,D_1DA8                ; "500" message
        CALL    L_0781                  ; Flag if the first saucer was also hit
        SHLD    saucerPriLocLSB         ; Message to print beside the saucer
        MVI     B,0x50                  ; Score of 50 (displayed as 500)
        POP     H                       ; Drop the return (we finish the caller's job here)
        JMP     L_07ED                  ; Add the score and print it
L_0781:
        LDA     flashSaucerArmed        ; Was the first saucer of the rack hit?
        ANA     A                       ; Set flags
        RZ                              ; No ... done
        MVI     A,0x01                  ; Yes ... remember that ...
        STA     flashSaucer             ; ... both saucers were hit
        RET                             ; Done
L_078C:
        MVI     B,0xFE                  ; Turn off ...
        CALL    SoundBits3Off           ; ... flying saucer sound
        INX     H                       ; (2086) show-hit timer
        DCR     M                       ; Count down show-hit timer
        MOV     A,M                     ; Get current value
        CPI     0x1F                    ; Starts at 20 ... is this the first tick of show-hit timer?
        JZ      L_0820                  ; Yes ... go show the explosion
        CPI     0x18                    ; A little later ...
        JZ      L_07BF                  ; ... show the score besides the saucer and add it
        ANA     A                       ; Has timer expired?
        RNZ                             ; No ... let it run
        MVI     B,0xEF                  ; 1110_1111 (mask off saucer hit sound)
        LXI     H,soundPort5            ; Get current ...
        MOV     A,M                     ; ... value of port 5 sound
        ANA     B                       ; Mask off the saucer-hit sound
        MOV     M,A                     ; Set the new value
        ANI     0x20                    ; All sound off but ...
        OUT     SOUND2                  ; ... cocktail cabinet bit

;
L_07AC:
        CALL    SaucerToScreen          ; Covert pixel pos from descriptor to HL screen and shift
        CALL    ClearSmallSprite        ; Clear a one byte sprite at HL
        LXI     H,saucerStart           ; Saucer structure
        MVI     B,0x0A                  ; 10 bytes in saucer structure
        CALL    L_083F                  ; Re-initialize saucer structure

SaucerSndOff:
        MVI     B,0xFE                  ; Turn off UFO ...
        JMP     SoundBits3Off           ; ... sound and out
L_07BF:
        MVI     A,0x01                  ; Flag the score ...
        STA     adjustScore             ; ... needs updating
        LDA     saucerBlink             ; Was this ...
        CPI     0x01                    ; ... the first saucer of the rack?
        JNZ     L_07CF                  ; No
        STA     flashSaucerArmed        ; Yes ... remember it was hit
L_07CF:
        CALL    FlashSaucerScore        ; The flashing saucer is always 500
        LHLD    sauScoreLSB             ; Saucer score table
        MOV     B,M                     ; Get score for this saucer
        MVI     C,0x04                  ; There are only 4 possibilities
        LXI     H,D_1D4C                ; Possible scores table (1D4C)
        LXI     D,D_1D48                ; Score values for each message (1D48)
L_07DE:
        LDAX    D                       ; Find ...
        CMP     B                       ; ... the ...
        JZ      L_07E9                  ; ... print ...
        INX     H                       ; ... string ...
        INX     D                       ; ... for ...
        DCR     C                       ; ... the ...
        JNZ     L_07DE                  ; ... score
L_07E9:
        MOV     A,M                     ; Get LSB of message (MSB is 2088 which is 1D)
        STA     saucerPriLocLSB         ; Message's LSB (50=1D90 100=1D93 150=1D96 300=1D99)
L_07ED:
        MVI     H,0x00                  ; MSB = 0 ...
        MOV     L,B                     ; HL = B
        CALL    SaucerAddScore          ; Add score (only in game mode)
        CALL    SaucerToScreen          ; Get the saucer's screen coordinates
        JMP     PrintSauScore           ; Print the score where the saucer was (3 characters)

; Return A = the active player's round count (2xF9) and HL pointing to it.
GetRoundNum:
        LDA     playerDataMSB           ; Active player's ...
        MOV     H,A                     ; ... data page
        MVI     L,0xF9                  ; 2xF9 is the round counter
        MOV     A,M                     ; Get it
        RET                             ; Done

; Store the saucer's score as the score delta (only in game mode).
SaucerAddScore:
        LDA     gameMode                ; Game mode?
        ANA     A                       ; Set flags
        JZ      L_080C                  ; No ... no score in demo
        SHLD    scoreDeltaLSB           ; Score delta
        RET                             ; Done
L_080C:
        XRA     A                       ; In demo mode ...
        STA     adjustScore             ; ... cancel the score adjustment
        RET                             ; Done

DrawSaucer:
        CALL    SaucerToScreen          ; Draw the ...
        JMP     DrawSimpSprite          ; ... flying saucer

SaucerToScreen:
        LXI     H,saucerPriLocLSB       ; Read flying saucer ...
        CALL    ReadDesc                ; ... structure
        JMP     ConvToScr               ; Convert pixel number to screen and shift and out

;
L_0820:
        MVI     B,0x10                  ; Saucer hit sound bit
        LXI     H,soundPort5            ; Current state of sounds
        MOV     A,M                     ; OR ...
        ORA     B                       ; ... in ...
        MOV     M,A                     ; ... saucer-hit sound
        CALL    L_1599                  ; Turn off fleet sound and start saucer-hit
        CALL    SaucerExplPic           ; Get the explosion picture
        SHLD    saucerPriLocLSB         ; Use it
        JMP     DrawSaucer              ; Draw the exploding saucer

SaucerExplPic:
        LXI     H,SpriteSaucerExp       ; Saucer explosion picture
        CALL    IsFlashSaucer           ; Flashing saucer?
        RNZ                             ; No ... use this picture
        LXI     H,SpriteSaucerExp       ; (Same picture for the flashing saucer)
        RET                             ; Done

;
L_083F:
        LXI     D,D_1B83                ; Data for saucer (702 sets count to 0A)
        JMP     BlockCopy               ; Reset saucer object data

; Wait for player 1 start button press
WaitForStart:
        MVI     A,0x01                  ; Tell ISR that we ...
        STA     waitStartLoop           ; ... have started to wait
        LXI     SP,0x2400               ; Reset stack
        EI                              ; Enable interrupts
        CALL    DsableGameTasks
        CALL    DrawNumCredits
        CALL    DrawCreditLabel         ; Print "CREDIT "
        CALL    ClearAndStatus          ; Print scores and credits
        LXI     H,0x3013                ; Screen coordinates
        LXI     D,D_1F3E                ; "PUSH" (Part II says PUSH instead of PRESS)
        MVI     C,0x04                  ; Message length
        CALL    PrintMessage            ; Print it
L_0865:
        LDA     numCoins                ; Number of credits
        DCR     A                       ; Set flags
        LXI     H,0x2810                ; Screen coordinates
        MVI     C,0x14                  ; Message length
        JNZ     L_0973                  ; Take 1 or 2 player start
        LXI     D,D_184D                ; "ONLY 1PLAYER  BUTTON"
        CALL    PrintMessage            ; Print message
        IN      INP1                    ; Read player controls
        ANI     0x04                    ; 1Player start button?
        JZ      L_0865                  ; No ... wait for button or credit

;======================================================================
; Start New Game
;======================================================================


; 1 Player start
NewGame:
        MVI     B,0x99                  ; Essentially a -1 for DAA
        XRA     A                       ; Clear two player flag

;
; 2 player start sequence enters here with a=1 and B=98 (-2)
L_0881:
        STA     twoPlayers              ; Set flag for 1 or 2 players
        LDA     numCoins                ; Number of credits
        ADD     B                       ; Take away credits
        DAA                             ; Convert back to DAA
        STA     numCoins                ; New credit count
        LDA     creditShadow            ; Take the credits ...
        ADD     B                       ; ... away from the ...
        DAA                             ; ... shadow copy ...
        STA     creditShadow            ; ... too
        CALL    DrawNumCredits          ; Show the new credit count
        LXI     H,0x0000                ; Zero
        SHLD    P1ScorL                 ; Clear player 1 score
        SHLD    P2ScorL                 ; Clear player 2 score
        SHLD    0x21F8                  ; Clear player 1 shot count (21F8) and round count (21F9)
        SHLD    0x22F8                  ; Clear player 2 shot count (22F8) and round count (22F9)
        CALL    DrawScoreP1             ; Print player-1 score
        CALL    DrawScoreP2             ; Print player-2 score
        CALL    CenterHiName            ; Work out where the high-score name goes
        CALL    PrintHiName             ; Print the high-score holder's name
        CALL    DsableGameTasks         ; Disable game tasks
        LXI     H,0x0101                ; Two bytes 1, 1
        MOV     A,H                     ; 1 to A
        STA     gameMode                ; 20EF=1 ... game mode
        SHLD    player1Alive            ; 20E7 and 20E8 both one ... players 1 and 2 are alive
        SHLD    player1Ex               ; Extra-ship is available for player-1 and player-2
        CALL    ClearAndStatus          ; Print scores and credits
        CALL    DrawShieldPl1           ; Draw shields for player-1
        CALL    DrawShieldPl2           ; Draw shields for player-2
        CALL    GetShipsPerCred         ; Get number of ships from DIP settings
        STA     p1ShipsRem              ; Player-1 ships
        STA     p2ShipsRem              ; Player-2 ships
        CALL    L_00F2                  ; Set player-1 and player-2 alien racks going right
        XRA     A                       ; Make a 0
        STA     p1RackCnt               ; Player 1 is on first rack of aliens
        STA     p2RackCnt               ; Player 2 is on first rack of aliens
        STA     shotsHalted             ; Alien shots are allowed
        INR     A                       ; 1
        STA     0x21FA                  ; Player 1 round display (21FA) starts at 1
        STA     0x22FA                  ; Player 2 round display (22FA) starts at 1
        CALL    InitAliens              ; Initialize aliens for player 1
        CALL    InitAliensP2            ; Initialize 55 aliens for player 2
        LXI     H,0x3878                ; Screen coordinates for lower-left alien
        SHLD    p1RefAlienY             ; Initialize reference alien for player 1
        SHLD    p2RefAlienYr            ; Initialize reference alien for player 2
        CALL    CopyRAMMirror           ; Copy ROM mirror to RAM (2000 - 20C0)
        CALL    RemoveShip              ; Initialize ship hold indicator
L_08FD:
        IN      INP2                    ; DIP switch 4 ...
        ANI     0x08                    ; ... (bit 3) is the "preset mode" switch
        CNZ     PresetMode              ; Switch is on ... operator preset mode
        CALL    PromptPlayer            ; Print "PLAY PLAYER<n>" and blink the score
        CALL    ClearPlayField          ; Clear the playfield
        XRA     A                       ; Make a 0
        STA     isrSplashTask           ; Stop the demo task
L_090E:
        CALL    DrawBottomLine          ; Draw line across screen under player
        LDA     playerDataMSB           ; Current player
        RRC                             ; Right bit tells all
        JC      L_098E                  ; Go do player 1

;
        CALL    RestoreShields2         ; Restore shields for player 2
        CALL    CarveRoundNum           ; Cut the round number into the shields
L_091E:
        CALL    DrawBottomLine          ; Draw line across screen under player
        CALL    InitRack                ; Initialize alien rack for current player
        MVI     A,0x01                  ; Flag that ...
        STA     rackArriving            ; ... the rack is sliding into place
        MVI     B,0x20                  ; Enable ...
        CALL    SoundBits3On            ; ... sound amplifier
        CALL    RackArrive              ; Part II: slide the new rack down into position
        MVI     A,0x00                  ; Rack is ...
        STA     rackArriving            ; ... in place
L_0936:
        CALL    EnableGameTasks         ; Enable game tasks in ISR
        MVI     B,0x20                  ; Enable ...
        CALL    SoundBits3On            ; ... sound amplifier

;
; GAME LOOP
;
L_093E:
        CALL    PlrFireOrDemo           ; Initiate player shot if button pressed
        CALL    PlyrShotAndBump         ; Collision detect player's shot and rack-bump
        CALL    CountAliens             ; Count aliens (count to 2082)
        CALL    AdjustScore             ; Adjust score (and print) if there is an adjustment
        LDA     numAliens               ; Number of live aliens
        ANA     A                       ; All aliens gone?
        JZ      EndOfRack               ; Yes ... end of turn
        CALL    AShotReloadRate         ; Update alien-shot-rate based on player's score
        CALL    ExtraShipCheck          ; Check (and handle) extra ship award
        CALL    SpeedShots              ; Adjust alien shot speed
        CALL    ShotSound               ; Shot sound on or off with 2025
        CALL    PlayerHitChk            ; Check if player is hit
        JZ      L_0968                  ; No hit ... jump handler
        MVI     B,0x04                  ; Player hit sound
        CALL    SoundBits3On            ; Make explosion sound
L_0968:
        CALL    FleetDelayExShip        ; Extra-ship sound timer, set fleet-delay, play fleet movement sound
        OUT     WATCHDOG                ; Feed the watchdog
        CALL    CtrlSaucerSound         ; Control saucer sound
        JMP     L_093E                  ; Continue game loop

; Test for 1 or 2 player start button press
L_0973:
        LXI     D,MessageB1or2          ; "1 OR 2PLAYERS BUTTON"
        CALL    PrintMessage            ; Print message
        MVI     B,0x98                  ; -2 (take away 2 credits)
        IN      INP1                    ; Read player controls
        RRC                             ; Test ...
        RRC                             ; ... bit 2
        JC      L_0989                  ; 2 player button pressed ... do it
        RRC                             ; Test bit 3
        JC      NewGame                 ; One player start ... do it
        JMP     L_0865                  ; Keep waiting on credit or button

; 2 PLAYER START
L_0989:
        MVI     A,0x01                  ; Flag 2 player game
        JMP     L_0881                  ; Continue normal startup
L_098E:
        CALL    RestoreShields1         ; Restore shields for player 1
        CALL    CarveRoundNum           ; Cut the round number into the shields
        JMP     L_091E                  ; Continue with the rack

; Part II: cut the current round number (0-9) into the top of each of the four shields.
CarveRoundNum:
        LXI     H,0x2927                ; Screen position in the first shield
        MVI     C,0x04                  ; 4 shields
        LDA     playerDataMSB           ; Active player ...
        MOV     D,A                     ; ... data page
        MVI     E,0xFA                  ; 2xFA is the round number for display
        LDAX    D                       ; Get it
        ADI     0x1C                    ; Convert to the digit character
L_09A5:
        PUSH    PSW                     ; Hold character
        PUSH    B                       ; Hold counters
        CALL    CharPtr                 ; DE = character picture
        MVI     B,0x05                  ; 5 columns in a character
L_09AC:
        PUSH    B                       ; Hold count
        LDAX    D                       ; Character pixels
        ANA     M                       ; AND then XOR with the screen ...
        XRA     M                       ; ... clears the character's pixels out of the shield
        MOV     M,A                     ; Back to screen
        INX     D                       ; Next column of character
        LXI     B,0x0020                ; Next ...
        DAD     B                       ; ... column on screen
        POP     B                       ; Restore count
        DCR     B                       ; All columns?
        JNZ     L_09AC                  ; No ... do them all
        LXI     B,0x0500                ; Offset ...
        DAD     B                       ; ... to the next shield
        POP     B                       ; Restore counters
        POP     PSW                     ; Restore character
        DCR     C                       ; All 4 shields?
        JNZ     L_09A5                  ; No ... do them all
        RET                             ; Done
D_09C6:
        DB      0x1B,0x24,0x1D,0x1C     ; " 810"

; Part II: the new rack slides down into position from the top of the screen. The
; reference alien is moved up to Y=A8 and the rack is "bumped" down step by step until
; it reaches its real starting height. The fewer aliens there are the smaller the steps.
RackArrive:
        LXI     H,rackSave              ; Save the alien-rack variables ...
        LXI     D,waitOnDraw            ; ... 2000-200F ...
        PUSH    H                       ; ... to 2300 ...
        PUSH    D                       ; ... (and keep the pointers for the restore)
        MVI     B,0x10                  ; 16 bytes
        CALL    BlockCopy               ; Copy
        LXI     H,refAlienDXr           ; refAlienDXr
        MVI     M,0x00                  ; No sideways motion
        INX     H                       ; refAlienYr
        MVI     M,0xA8                  ; Start rack at the top of the screen
        INX     H                       ; Skip refAlienXr
        INX     H                       ; alienPosLSB
        MVI     M,0xA8                  ; Alien cursor starts at the top too
        INX     H                       ; Skip 200C,200D
        INX     H                       ; Point to ...
        INX     H                       ; ... rackDownDelta ...
        PUSH    H                       ; ... and hold the pointer
        CALL    CountAliens             ; Count the aliens in this rack
        LDA     numAliens               ; Number of aliens
        CPI     0x1A                    ; 26 or more?
        JNC     L_0A60                  ; Yes ... drop 4 pixels at a time
        CPI     0x0A                    ; 10 or more?
        JNC     L_0A66                  ; Yes ... drop 2 pixels at a time
        POP     H                       ; Pointer to rackDownDelta
        MVI     M,0xFF                  ; Otherwise drop 1 pixel at a time
L_09FA:
        CALL    CursorNextAlien         ; Next alien (moves the rack after the last one)
        CALL    DrawAlien               ; Draw it
        LDA     rackDownDelta           ; Keep ...
        STA     refAlienDYr             ; ... dropping the rack
        LDA     numAliens               ; Number of aliens
        CPI     0x05                    ; Fewer than 5?
        JNC     L_0A16                  ; No ... no extra delay
        PUSH    B                       ; Hold
        LXI     B,0x0350                ; Small delay ...
        CALL    DelayBC                 ; ... so a few aliens don't drop too fast
        POP     B                       ; Restore
L_0A16:
        LDA     refAlienYr              ; (Read twice ...)
        LDA     refAlienYr              ; Current rack height
        MOV     B,A                     ; To B
        LDA     0x2309                  ; Saved (target) rack height
        PUSH    PSW                     ; Hold target ...
        PUSH    B                       ; ... and current
        MVI     A,0x0A                  ; Delay value
        CALL    SoundDelay              ; Fleet sound and delay
        POP     B                       ; Restore current
        POP     PSW                     ; Restore target
        CMP     B                       ; Has the rack reached its starting height?
        OUT     WATCHDOG                ; Feed watchdog (flags kept)
        PUSH    PSW                     ; Hold compare result
        MVI     H,0x20                  ; Hidden test feature: 20E2 ...
        MVI     L,0xE1                  ; ... (the address is built in pieces) ...
        INR     L                       ; ... is still set only if the copyright check failed
        MOV     A,M                     ; Get flag
        ANA     A                       ; Is it set?
        JZ      L_0A4A                  ; No ... skip
        CALL    ReadPort1               ; Read the switches
        ANI     0x76                    ; Start1, Start2, fire, left, right
        CPI     0x56                    ; Start1+Start2+fire+right held?
        JNZ     L_0A4A                  ; No ... skip
        MVI     L,0xEA                  ; Point ...
        INR     L                       ; ... to 20EB
        MVI     M,0x02                  ; 2 free credits
        MVI     L,0xCC                  ; Shadow copy ...
        MVI     M,0x02                  ; ... too
L_0A4A:
        POP     PSW                     ; Restore compare result
        JNZ     L_09FA                  ; Keep dropping until the rack is in place
        POP     H                       ; Restore the rack variables ...
        POP     D                       ; ... from 2300
        MVI     B,0x10                  ; 16 bytes
        CALL    BlockCopy               ; Copy them back
        CALL    DrawScores              ; Redraw the scores
        LDA     player1Alive            ; (Checked as a 2-player flag)
        ANA     A                       ; Set flags
        RZ                              ; Zero ... done
        JMP     ClrP2ScoreIf1P          ; Blank player 2's score in a one player game
L_0A60:
        POP     H                       ; Drop 4 ...
        MVI     M,0xFC                  ; ... pixels per bump
        JMP     L_09FA                  ; Continue
L_0A66:
        POP     H                       ; Drop 2 ...
        MVI     M,0xFE                  ; ... pixels per bump
        JMP     L_09FA                  ; Continue

; Get pointer to player's alien ref coordiantes
GetAlRefPtr:
        LDA     playerDataMSB           ; Player data MSB (21 or 22)
        MOV     H,A                     ; To H
        MVI     L,0xFC                  ; 21FC or 22FC ... alien coordinates
        RET                             ; Done

; Print "PLAY PLAYER <n>" and blink score for 2 seconds.
;
PromptPlayer:
        LXI     H,0x2B11                ; Screen coordinates
        LXI     D,MesssageP1            ; Message "PLAY PLAYER<1>"
        MVI     C,0x0E                  ; 14 bytes in message
        CALL    PrintMessage            ; Print the message
        LDA     playerDataMSB           ; Get the player number
        RRC                             ; C will be set for player 1
        MVI     A,0x1E                  ; Character "2"
        LXI     H,0x3711                ; Replace the "<1>" with "<2">
        CNC     DrawChar                ; If player 2 ... change the message
        MVI     A,0xB0                  ; Delay of 176 (roughly 2 seconds)
        STA     isrDelay                ; Set the ISR delay value

;
L_0A8F:
        LDA     isrDelay                ; Get the ISR delay value
        ANA     A                       ; Has the 2 second delay expired?
        RZ                              ; Yes ... done
        ANI     0x04                    ; Every 4 ISRs ...
        JNZ     L_0AA2                  ; ... flash the player's score
        CALL    GetScoreDesc            ; Get the score descriptor for the active player
        CALL    DrawScore               ; Draw the score
        JMP     L_0A8F                  ; Back to the top of the wait loop
L_0AA2:
        MVI     B,0x28                  ; 40 rows (5 digits now)
        LXI     H,0x261C                ; Player-1 score on the screen
        LDA     playerDataMSB           ; Get the player number
        RRC                             ; C will be set for player 1
        JC      L_0AB1                  ; We have the right score coordinates
        LXI     H,0x391C                ; Use coordinates for player-2's score
L_0AB1:
        CALL    ClearSmallSprite        ; Erase the score
        JMP     L_0A8F                  ; Back to the top of the wait loop

; Get number of ships from DIP settings
GetShipsPerCred:
        IN      INP2                    ; DIP settings
        ANI     0x01                    ; Bit 0: 3 or 4 ships (only one DIP switch for ships in Part II)
        ADI     0x03                    ; From 3-6
        RET                             ; Out

; With less than 9 aliens on the screen the alien shots get a tad bit faster. Probably
; because the advancing rack can catch them.
;
SpeedShots:
        LDA     numAliens               ; Number of aliens on screen
        CPI     0x09                    ; More than 8?
        RNC                             ; Yes ... leave shot speed alone
        MVI     A,0xFB                  ; Normally FF (-4) ... now FB (-5)
        STA     alienShotDelta          ; Speed up alien shots
        RET                             ; Done

ClrP2ScoreIf1P:
        LDA     twoPlayers              ; Number of players
        ANA     A                       ; Skip if ...
        RNZ                             ; ... two player
        LXI     H,0x391C                ; Player 2's score
        MVI     B,0x28                  ; 40 rows
        JMP     ClearSmallSprite        ; Clear a one byte sprite (32 rows long) at HL

PrintSauScore:
        MVI     C,0x03                  ; Length of saucer-score message ... fall into print

; Print a message on the screen
; HL = coordinates
; DE = message buffer
; C = length
PrintMessage:
        LDAX    D                       ; Get character
        PUSH    D                       ; Preserve
        CALL    DrawChar                ; Print character
        POP     D                       ; Restore
        INX     D                       ; Next character
        DCR     C                       ; All done?
        JNZ     PrintMessage            ; Print all of message
        RET                             ; Out

; Part II: characters are 5 bytes each (8 in the original) and the font is at 1E21.
; The 3 blank bytes under each character are written explicitly.
DrawChar:
        CALL    CharPtr                 ; Get pointer to the character's picture in DE
        MVI     B,0x05                  ; 5 bytes each
        OUT     WATCHDOG                ; Feed watchdog
        CALL    DrawSimpSprite          ; Draw the 5 columns
        PUSH    B                       ; Hold count
        XRA     A                       ; Blank column
        MOV     M,A                     ; Column 6
        LXI     B,0x0020                ; Next ...
        DAD     B                       ; ... column
        MOV     M,A                     ; Column 7
        DAD     B                       ; Next column
        MOV     M,A                     ; Column 8
        DAD     B                       ; Leave HL at the next character position
        POP     B                       ; Restore
        RET                             ; Done

TimeToSaucer:
        LDA     refAlienYr              ; Reference alien's X coordinate
        CPI     0x78                    ; Don't process saucer timer ... ($78 is 1st rack Yr)
        RNC                             ; ... unless aliens are closer to bottom
        LHLD    tillSaucerLSB           ; Time to saucer
        MOV     A,L                     ; Is it time ...
        ORA     H                       ; ... for a saucer
        JNZ     L_0B12                  ; No ... skip flagging
        LXI     H,0x0600                ; Reset timer to 600 game loops
        MVI     A,0x01                  ; Flag a ...
        STA     saucerStart             ; ... saucer sequence
L_0B12:
        DCX     H                       ; Decrement the ...
        SHLD    tillSaucerLSB           ; ... time-to-saucer
        RET                             ; Done

GetNumShips:
        CALL    GetPlayerDataPtr        ; HL points to player data
        MVI     L,0xFF                  ; Last byte = numbe of ships
        MOV     A,M                     ; Get number of ships
        RET                             ; Done

ExtraShipCheck:
        CALL    CurPlyAlive             ; Get descriptor of sorts
        DCX     H                       ; Back up ...
        DCX     H                       ; ... two bytes
        MOV     A,M                     ; Has extra ship ...
        ANA     A                       ; already been awarded?
        RZ                              ; Yes ... ignore
        MVI     B,0x15                  ; Extra ship at 1500 (Part II has no DIP choice: the old switch is now preset mode)
        CALL    ScoreHundreds           ; Get the score's thousands/hundreds digits
        CMP     B                       ; Have we reached the extra ship score?
        RC                              ; No ... out
        CALL    AwardShip               ; Add a ship and print the number of ships
        CALL    CurPlyAlive             ; Get descriptor for active player of some sort
        DCX     H                       ; Back up ...
        DCX     H                       ; ... two bytes
        MVI     M,0x00                  ; Flag extra ship has been awarded
        MVI     A,0xFF                  ; Set timer ...
        STA     extraHold               ; ... for extra-ship sound

ExtraShipSnd:
        MVI     B,0x10                  ; Make sound ...
        JMP     SoundBits3On            ; ... for extra man

; Part II: B is the alien's status byte (1,3,5 or 7) instead of its row.
AlienScoreValue:
        PUSH    PSW                     ; Hold alien type
        LDA     scoreTableOn            ; Always 1 (set from the RAM mirror)
        ANA     A                       ; Set flags
        JZ      L_0B56                  ; Zero ... skip the lookup
        LXI     H,D_1D9C                ; Score table (10, 20, 30)
        POP     PSW                     ; Restore type
        CPI     0x02                    ; Octopus (1) ...
        RC                              ; ... is worth 10
        INX     H                       ; next value
        CPI     0x04                    ; Crab (3) ...
        RC                              ; ... is worth 20
        INX     H                       ; Squid (5) and small alien (7) are worth 30
        RET                             ; Done
L_0B56:
        POP     PSW                     ; Restore
        RET                             ; Done

; Adjust the score for the active player. 20F1 is 1 if there is a new value to add.
; The adjustment is in 20F2,20F3. Then print the score.
AdjustScore:
        CALL    GetScoreDesc            ; Get score structure for active player
        LDA     adjustScore             ; Does the score ...
        ANA     A                       ; ... need increasing?
        RZ                              ; No ... done
        XRA     A                       ; Mark score ...
        STA     adjustScore             ; ... as adjusted
        PUSH    H                       ; Hold the pointer to the structure
        LHLD    scoreDeltaLSB           ; Get requested adjustment
        XCHG                            ; Adjustment to DE
        POP     H                       ; Get back pointer to structure
        MOV     A,M                     ; Add adjustment ...
        ADD     E                       ; ... first byte
        DAA                             ; Adjust it for BCD
        MOV     M,A                     ; Store new LSB
        MOV     E,A                     ; Add adjustment ...
        INX     H                       ; ... to ...
        MOV     A,M                     ; ... second ...
        ADC     D                       ; ... byte
        DAA                             ; Adjust for BCD (cary gets dropped)
        MOV     M,A                     ; Store second byte
        MOV     D,A                     ; Second byte to D (first byte still in E)
        INX     H                       ; Load ...
        MOV     A,M                     ; ... the ...
        INX     H                       ; ... screen ...
        MOV     H,M                     ; ... coordinates ...
        MOV     L,A                     ; ... to HL

; Print 4 digits in DE
Print4Digits:
        MOV     A,D                     ; Get first 2 digits of BCD or hex
        CALL    DrawHexByte             ; Print them
        MOV     A,E                     ; Get second 2 digits of BCD or hex (fall into print)

; Display 2 digits in A to screen at HL
DrawHexByte:
        PUSH    D                       ; Preserve
        PUSH    PSW                     ; Save for later
        RRC                             ; Get ...
        RRC                             ; ...
        RRC                             ; ...
        RRC                             ; ... left digit
        ANI     0x0F                    ; Mask out lower digit's bits
        CALL    DrawDigit               ; To screen at HL
        POP     PSW                     ; Restore digit
        ANI     0x0F                    ; Mask out upper digit
        CALL    DrawDigit               ; To screen
        POP     D                       ; Restore
        RET                             ; Done

DrawDigit:
        ADI     0x1C                    ; Digit to character (digits start at 1C)
        JMP     DrawChar                ; Draw it

GetScoreDesc:
        LDA     playerDataMSB           ; Get active player
        RRC                             ; Test for player
        LXI     H,P1ScorL               ; Player 1 score descriptor
        RC                              ; Keep it if player 1 is active
        LXI     H,P2ScorL               ; Else get player 2 descriptor
        RET                             ; Out

; Part II clears the playfield column by column (26 bytes of each of 223 columns).
ClearPlayField:
        LXI     H,0x2402                ; Third byte from the bottom, left edge
        MVI     C,0x1A                  ; 26 bytes high
L_0BA8:
        MVI     B,0xDF                  ; 223 columns
        PUSH    H                       ; Hold start
        PUSH    B                       ; Hold counts
L_0BAC:
        MVI     M,0x00                  ; Clear byte
        LXI     D,0x0020                ; Next ...
        DAD     D                       ; ... column
        DCR     B                       ; All columns?
        JNZ     L_0BAC                  ; No ... do the row
        POP     B                       ; Restore counts
        POP     H                       ; Restore start
        INX     H                       ; Next byte up
        DCR     C                       ; All 26?
        JNZ     L_0BA8                  ; No ... do them all
        RET                             ; Done

; (20BA is only ever set to 0 or 1, so this never fires.)
FlashBothHit:
        LDA     flashSaucerArmed        ; First saucer hit ...
        CPI     0x02                    ; ... marker of 2?
        RNZ                             ; No ... out
        MVI     A,0x01                  ; Flag ...
        STA     flashSaucer             ; ... both saucers
        RET                             ; Done

; The rack has been cleared. Part II adds the end-of-rack bonus, the "fewer than 56
; shots" extra ship, and the intermission animation before the next rack.
EndOfRack:
        CALL    WaitPlayerExp           ; Wait for player to finish exploding
        CALL    RackBonus               ; Award the last-alien bonus (with the beam animation)
        CALL    FewShotsShip            ; Extra ship if the rack took fewer than 56 shots
        CALL    GetPlayerDataPage       ; Player's data page
        MVI     L,0xF8                  ; Reset the shot count ...
        MVI     M,0x00                  ; ... for the next rack
        CALL    FlashBothHit            ; (Never true)
        CALL    Intermission            ; Run the intermission animation
        XRA     A                       ; Suspend ...
        STA     suspendPlay             ; ... ISR game tasks
        CALL    ClearPlayField          ; Clear playfield
        LDA     playerDataMSB           ; Hold current player number ...
        PUSH    PSW                     ; ... on stack
        CALL    CopyRAMMirror           ; Block copy RAM mirror from ROM
        POP     PSW                     ; Restore ...
        STA     playerDataMSB           ; ... current player number
        LDA     playerDataMSB           ; ** Why load this again? Nobody ever jumps to 0BF2?
        MOV     H,A                     ; To H
        MVI     L,0xFE                  ; 2xFE rack count
        PUSH    H                       ; Hold pointer
        MVI     L,0xFA                  ; 2xFA round number for display
        INR     M                       ; Next round
        MOV     A,M                     ; Get it
        PUSH    H                       ; Hold pointer
        MVI     L,0xF9                  ; 2xF9 round count
        INR     M                       ; Next round
        POP     H                       ; Restore pointer to display number
        CPI     0x0A                    ; Display wraps at 10 ...
        JNZ     L_0C09                  ; ... not yet
        MVI     M,0x00                  ; ... back to 0
L_0C09:
        POP     H                       ; Restore rack count pointer
        MOV     A,M                     ; Get rack count
        CALL    SetRackStart            ; Bump rack count and set starting height
        MOV     A,H                     ; Player ...
        RRC                             ; ... number to carry
        JC      L_0C38                  ; 2nd player stuff
        MVI     A,0x21                  ; Start fleet with ...
        STA     soundPort5              ; ... first sound
        CALL    DrawShieldPl2           ; Draw shields for player 2
        CALL    InitAliensP2            ; Initalize aliens for player 2
        JMP     L_090E                  ; Continue at top of game loop

SetRackStart:
        ANI     0x07                    ; 0-7
        INR     A                       ; Now 1-8
        MOV     M,A                     ; Update count since player just beat a rack
        LXI     H,D_1D9F                ; Alien start table (first entry used is 1DA0)
L_0C28:
        INX     H                       ; Find the ...
        DCR     A                       ; ... right entry ...
        JNZ     L_0C28                  ; ... in the table
        MOV     B,M                     ; Starting Y for this rack
        CALL    GetPlayerDataPage       ; Player's data
        MVI     L,0xFC                  ; Reference alien ...
        MOV     M,B                     ; ... Y
        INX     H                       ; Reference alien ...
        MVI     M,0x38                  ; ... X starts at 38
        RET                             ; Done

;
L_0C38:
        CALL    DrawShieldPl1           ; Draw shields for player 1
        CALL    InitAliens              ; Initialize aliens for player 1
        JMP     L_090E                  ; Continue at top of game loop

WaitPlayerExp:
        CALL    PlayerHitChk            ; Check player collision
        JNZ     L_0C57                  ; Player is not alive ... skip delay
        MVI     A,0x30                  ; Half second delay
        STA     isrDelay                ; Set ISR timer
L_0C4C:
        LDA     isrDelay                ; Has timer expired?
        ANA     A                       ; Check exipre
        RZ                              ; Out if done
        CALL    PlayerHitChk            ; Check player collision
        JZ      L_0C4C                  ; No collision ... wait on timer
L_0C57:
        CALL    PlayerHitChk            ; Wait for ...
        JNZ     L_0C57                  ; ... collision to end
        RET                             ; Done

PlayerHitChk:
        LDA     playerAlive             ; Active player hit flag
        CPI     0xFF                    ; All FFs means player is OK
        RET                             ; Out

; Start the hit-alien sound and flag the adjustment for the score.
; B contains the row, which determines the score value.
ScoreForAlien:
        LDA     gameMode                ; Are we in ...
        ANA     A                       ; ... game mode?
        JZ      L_0C81                  ; No ... skip scoring in demo
        MOV     C,B                     ; Hold row number
        MVI     B,0x08                  ; Alien hit sound
        CALL    SoundBits3On            ; Enable sound
        MOV     B,C                     ; Restore row number
        MOV     A,B                     ; Into A
        CALL    AlienScoreValue         ; Look up the score for the alien
        MOV     A,M                     ; Get the score value
        LXI     H,scoreDeltaMSB         ; Pointer to score delta
        MVI     M,0x00                  ; Upper byte of score delta is "00"
        DCX     H                       ; Point to score delta LSB
        MOV     M,A                     ; Set score for hitting alien
        DCX     H                       ; Point to adjust-score-flag
        MVI     M,0x01                  ; The score will get changed elsewhere
L_0C81:
        LXI     H,expAlienLSB           ; Return exploding-alien descriptor
        RET                             ; Out

; Print message from DE to screen at HL (length in C) with a
; delay between letters.
PrintMessageDel:
        PUSH    D                       ; Preserve
        LDAX    D                       ; Get character
        CALL    DrawChar                ; Draw character on screen
        POP     D                       ; Preserve
        MVI     A,0x07                  ; Delay between letters
        STA     isrDelay                ; Set counter
L_0C90:
        LDA     isrDelay                ; Get counter
        DCR     A                       ; Is it 1?
        JNZ     L_0C90                  ; No ... wait on it
        INX     D                       ; Next in message
        DCR     C                       ; All done?
        JNZ     PrintMessageDel         ; No ... do all
        RET                             ; Out

; Delay 64 interrupts
OneSecDelay:
        MVI     A,0x40                  ; Delay of 64 (tad over 1 sec)
        JMP     WaitOnDelay             ; Do delay

; Delay 128 interrupts
TwoSecDelay:
        MVI     A,0x80                  ; Delay of 80 (tad over 2 sec)
        JMP     WaitOnDelay             ; Do delay

SplashDemo:
        POP     H                       ; Drop the call to ABF and ...
        CALL    SaucerDropMove          ; Drop alien (demo too)
        JMP     L_007B                  ; Continue with the game ISR tasks

; Part II only has the demo as an ISR splash task (the animations are gone).
ISRSplTasks:
        LDA     isrSplashTask           ; Demo running?
        RRC                             ; Bit 0
        JC      SplashDemo              ; Yes ... run the game objects
        RET                             ; Done

; Wait on ISR counter to reach 0
WaitOnDelay:
        STA     isrDelay                ; Delay counter
L_0CB9:
        LDA     isrDelay                ; Get current delay
        ANA     A                       ; Zero yet?
        JNZ     L_0CB9                  ; No ... wait on it
        RET                             ; Out

; Part II: alternate the demo between two formations (round 0 and round 3).
DemoAliens:
        LXI     H,splashAnimate         ; Alternates every demo
        MOV     A,M                     ; Get it
        ANA     A                       ; Set flags
        JNZ     L_0CD1                  ; Was 1 ... use round 3
        MVI     M,0x01                  ; Next time use round 3
L_0CCB:
        STA     0x21F9                  ; Player 1 round count
        JMP     InitAliens              ; Build the formation
L_0CD1:
        MVI     M,0x00                  ; Next time use round 0
        MVI     A,0x03                  ; Round 3
        JMP     L_0CCB                  ; Set round and build formation

;=============================================================
; After initialization ... splash screens
SplashLoop:
        XRA     A                       ; Make a 0
        OUT     SOUND1                  ; Turn off sound
        OUT     SOUND2                  ; Turn off sound
        CALL    ClearScreen             ; Clear the screen
        EI                              ; Enable interrupts (using them for delays)
        CALL    OneSecDelay             ; One second delay
        CALL    TitleScreen             ; Part II: big "SPACE INVADERS PART II" title
        CALL    OneSecDelay
        CALL    DrawAdvTable            ; "SCORE ADVANCE TABLE"
        CALL    OneSecDelay             ; One second delay

;
; Play demo
        CALL    ClearPlayField          ; Clear playfield
        LDA     p1ShipsRem              ; Number of ships for player-1
        ANA     A                       ; If non zero ...
        JNZ     L_0D03                  ; ... keep it (counts down between demos)
        CALL    GetShipsPerCred         ; Get number of ships from DIP settings
        STA     p1ShipsRem              ; Reset number of ships for player-1
        CALL    RemoveShip              ; Remove a ship from stash and update indicators

;
L_0D03:
        CALL    CopyRAMMirror           ; Block copy ROM mirror to initialize RAM
        CALL    DemoAliens              ; Initialize the demo formation
        CALL    DrawShieldPl1           ; Draw shields for player 1 (to buffer)
        CALL    RestoreShields1         ; Restore shields for player 1 (to screen)
        CALL    DrawBottomLine
        CALL    RackArrive              ; Slide the demo rack into place
        MVI     A,0x01                  ; Start ...
        STA     isrSplashTask           ; ... the demo

;
L_0D1A:
        CALL    PlrFireOrDemo           ; In demo ... process demo movement and always fire
        CALL    DemoBumpAndHidden       ; Check player shot and aliens bumping edges (and the hidden message)
        OUT     WATCHDOG                ; Feed watchdog
        CALL    PlayerHitChk            ; Has demo player been hit?
        JZ      L_0D1A                  ; No ... continue game
        XRA     A                       ; Remove player shot ...
        STA     plyrShotStatus          ; ... from activity
L_0D2C:
        CALL    PlayerHitChk            ; Wait for demo player ...
        JNZ     L_0D2C                  ; ... to stop exploding

;
; Credit information
L_0D32:
        XRA     A                       ; Turn off ...
        STA     isrSplashTask           ; ... the demo
        CALL    OneSecDelay             ; One second delay
        CALL    ClearPlayField          ; Clear the playfield
        MVI     C,0x0C                  ; Message size
        LXI     H,0x2C11                ; Screen coordinates
        LXI     D,MessageCoin           ; "INSERT  COIN"
        CALL    PrintMessage            ; Print message
        CALL    FlashHiName             ; Show the high score holder (and *TAITO CORPORATION*)
        LXI     B,CreditTable           ; Descriptor for "<1 OR 2 PLAYERS>  "
        CALL    ReadPriStruct           ; Load the screen,pointer
        CALL    L_1673                  ; Print the message
        IN      INP2                    ; Display coin info (bit 7) ...
        RLC                             ; ... on demo screen?
        JC      L_0D5F                  ; 1 means no ... skip it
        LXI     B,D_1127                ; Descriptors for "*1 PLAYER  1 COIN " and "*2 PLAYERS 2 COINS"
        CALL    L_1661                  ; Load the descriptor
L_0D5F:
        CALL    TwoSecDelay             ; Two second delay
        CALL    ClearPlayField          ; Clear playfield
        JMP     SplashRestart           ; Back to the top of the splash loop

DemoBumpAndHidden:
        CALL    PlyrShotAndBump         ; Shot and rack bump
        JMP     CheckHiddenMes          ; Check for the hidden message

; Hidden message "TAITO CORP." stored backwards with $3F subtracted from each character
; (printed by 4536).
        DB      0xDB,0xD0,0xD2,0xCF,0xC3,0xDC,0xCF,0xD4,0xC9,0xC1,0xD4
D_0D79:
        DB      0x1B,0x07,0x08,0x2B,0x12,0x02,0x0E,0x11,0x04,0x1B; " HI-SCORE "

;======================================================================
; Part II: High Score Name Entry
;======================================================================


; Part II: the mid-screen interrupt first checks the "name reset" switch and, while the
; high-score name is being entered, reads the fire button and times the entry. During
; name entry none of the normal mid-screen tasks run.
ScanLine96Cont:
        IN      INP0                    ; Read port 0
        ANI     0x40                    ; Bit 6 (active low) is the NAME RESET switch
        CZ      NameReset               ; Pressed ... restore the default name "TAITO"
        LDA     nameEntry               ; Is name entry in progress?
        ANA     A                       ; Set flags
        JZ      L_00A4                  ; No ... continue the normal mid-screen ISR
        IN      INP1                    ; Either start button ...
        ANI     0x06                    ; ... (bits 1 and 2) ...
        CNZ     NameStartHit            ; ... ends name entry
        CALL    NameInputs              ; Read the entering player's controls
        ANI     0x10                    ; Fire button?
        MVI     B,0x01                  ; Flag value 1
        LXI     H,nameFireHeld          ; Fire-held flag
        JNZ     L_0DAE                  ; Fire is down ... set the held flag
        MOV     A,M                     ; Fire is up. Was it ...
        ANA     A                       ; ... down last time?
        INX     H                       ; Point to fire-pressed flag (20B2)
        JNZ     L_0DAE                  ; Yes ... it was just released ... flag a letter selection
        DCX     H                       ; Back to held flag
        MVI     B,0x00                  ; Clear it
L_0DAE:
        MOV     M,B                     ; Store flag
        LHLD    nameTimerL              ; Name entry ...
        INX     H                       ; ... timer ...
        SHLD    nameTimerL              ; ... counts up
        JMP     ISRExit                 ; Restore and out (skip the normal tasks)

; Read the controls of the player entering a name (20E1 is 0 for player 1).
NameInputs:
        LDA     nameFlip                ; Player 2 entering the name?
        ANA     A                       ; Set flags
        JNZ     L_15F2                  ; Yes ... read port 2 and return
        IN      INP1                    ; Player 1 controls
        RET                             ; Done

NameStartHit:
        MVI     A,0x01                  ; Flag that ...
        STA     nameStartHit            ; ... a start button was pressed (finishes the entry)
        RET                             ; Done

NameReset:
        CALL    DefaultName             ; Copy "TAITO" (and cleared entry variables) to the name buffer
        CALL    CenterHiName            ; Work out where to print it
        JMP     PrintHiName             ; Print it

FlashHiName:
        PUSH    H                       ; Hold registers
        PUSH    B                       ; ...
        CALL    FlashHiNameDo           ; Flash " HI-SCORE " and the holder's name
        POP     B                       ; Restore ...
        POP     H                       ; ... registers
        RET                             ; Done

Delay32:
        MVI     A,0x20                  ; Half second
        JMP     WaitOnDelay             ; Wait

Delay5:
        MVI     A,0x05                  ; 5 ISR ticks
        JMP     WaitOnDelay             ; Wait

; Wait (about 1600 loops) for the joystick to be released. If it is released the caller
; is skipped (one move per push).
NameMoveDelay:
        LXI     B,0x0650                ; Loop count
L_0DE7:
        CALL    NameInputs              ; Read controls
        ANI     0x60                    ; Left or right still held?
        JZ      L_0DF8                  ; No ... drop the caller
        DCR     C                       ; Count ...
        JNZ     L_0DE7                  ; ... down
        DCR     B                       ; Count ...
        JNZ     L_0DE7                  ; ... down
        RET                             ; Held long enough ... auto-repeat the move
L_0DF8:
        POP     H                       ; Drop the caller (no move)
        RET                             ; Return to caller's caller

; Part II: HI-SCORER REGISTRATION. The player that beat the high score picks up to
; 10 letters from a grid (A-Z, "." and RUB/END) with left/right and fire. A start
; button or the timer ends the entry.
NameEntry:
        CALL    ClearPlayField          ; Clear the playfield
        CALL    EraseHiName             ; Erase the name area
        MVI     B,0x15                  ; 21 bytes
        LXI     D,D_1065                ; Initial name-entry variables (blank name, timer, cursor ...)
        LXI     H,hiName                ; To 2340-2354
        CALL    BlockCopy               ; Copy
        LXI     D,D_103D                ; "HI-SCORER  REGISTRATION"
        LXI     H,0x2717                ; Screen coordinates
        MVI     C,0x17                  ; 23 characters
        CALL    PrintMessage            ; Print it
        LXI     H,0x2712                ; First row of letters
        LXI     D,Characters            ; Character "A"
        CALL    DrawLetterRow           ; A-K
        LXI     H,0x2710                ; Second row
        CALL    DrawLetterRow           ; L-V
        LXI     H,0x270E                ; Third row
        MVI     C,0x05                  ; Five letters
        CALL    DrawLetters             ; W X Y Z .
        LXI     H,0x330E                ; After the letters
        LXI     D,PicRubEnd             ; "RUB  END" picture
        MVI     B,0x28                  ; 40 bytes
        CALL    DrawSimpSprite          ; Draw it
        LXI     D,D_1054                ; "NAME [~~~~~~~~~~]"
        MVI     C,0x11                  ; 17 characters
        LXI     H,0x2A06                ; Screen coordinates
        CALL    PrintMessage            ; Print it

NameLoop:
        LDA     nameEntry               ; Still entering?
        ANA     A                       ; Set flags
        JZ      NameDone                ; No ... done
        LDA     nameTimerM              ; Time ...
        CPI     0x20                    ; ... up?
        JNC     NameDone                ; Yes ... done
        CALL    DrawNameCursor          ; Draw the cursor under the current letter
        CALL    NameInputs              ; Read controls
        ANI     0x76                    ; Start2, Start1, fire, left, right
        CPI     0x40                    ; Just right?
        CZ      CursorRight             ; Yes ... move cursor right
        CPI     0x20                    ; Just left?
        CZ      CursorLeft              ; Yes ... move cursor left
        LDA     nameStartHit            ; Start pressed?
        ANA     A                       ; Set flags
        JNZ     NameDone                ; Yes ... done
        LDA     nameFirePressed         ; Fire pressed (and released)?
        ANA     A                       ; Set flags
        JNZ     NameSelect              ; Yes ... select the letter
        LXI     B,0x0130                ; Short ...
        CALL    DelayBC                 ; ... delay
        CALL    EraseNameCursor         ; Erase cursor (it flickers)
        LDA     nameTimerM              ; Time running out?
        CPI     0x1D                    ; Warning time?
        JNZ     NameLoop                ; No ... keep going
        MVI     B,0x05                  ; Flash "NAME" 5 times
L_0E85:
        PUSH    B                       ; Hold count
        LXI     H,0x2A06                ; "NAME"
        MVI     B,0x20                  ; 32 rows
        CALL    ClearRows               ; Erase "NAME"
        CALL    Delay5                  ; Wait
        LXI     D,D_1054                ; "NAME"
        LXI     H,0x2A06                ; Screen coordinates
        MVI     C,0x04                  ; 4 characters
        CALL    PrintMessage            ; Print "NAME"
        CALL    Delay5                  ; Wait
        POP     B                       ; Restore count
        DCR     B                       ; All 5 flashes?
        JNZ     L_0E85                  ; No ... do them all
        JMP     NameLoop                ; Back to the loop

DrawLetterRow:
        MVI     C,0x0B                  ; 11 letters

DrawLetters:
        MVI     B,0x05                  ; 5 bytes each
        CALL    DrawSimpSprite          ; Draw letter
        PUSH    B                       ; Hold
        LXI     B,0x0160                ; 11 columns ...
        DAD     B                       ; ... over for the next letter
        POP     B                       ; Restore
        DCR     C                       ; All letters?
        JNZ     DrawLetters             ; No ... do them all
        RET                             ; Done

DrawNameCursor:
        LHLD    nameCursorL             ; Cursor position
        MVI     A,0x2A                  ; Cursor character "_"
        JMP     DrawChar                ; Draw it

EraseNameCursor:
        LHLD    nameCursorL             ; Cursor position
        MVI     A,0x1B                  ; Space
        JMP     DrawChar                ; Draw it

; Busy-wait for BC counts.
DelayBC:
        DCR     C                       ; Count ...
        JNZ     DelayBC                 ; ... C
        DCR     B                       ; Count ...
        JNZ     DelayBC                 ; ... B
        RET                             ; Done

CursorRight:
        CALL    NameMoveDelay           ; One move per push
        CALL    EraseNameCursor         ; Erase cursor
        LHLD    nameCursorL             ; Cursor position
        MOV     A,L                     ; Which row?
        CPI     0x11                    ; Top row?
        JZ      L_0F03                  ; Yes
        CPI     0x0F                    ; Middle row?
        JZ      L_0F0C                  ; Yes
        MOV     A,H                     ; Bottom row: on "."?
        CPI     0x33                    ; (column of ".")
        JZ      L_0F17                  ; Yes ... jump over to RUB
L_0EEC:
        INR     H                       ; Move right ...
        INR     H                       ; ... one letter
        MOV     A,H                     ; Past ...
        CPI     0x35                    ; ... END?
        JNC     L_0EF7                  ; Yes ... wrap
        JMP     L_0EFD                  ; No ... store it
L_0EF7:
        CALL    EraseNameCursor         ; Erase cursor
        LXI     H,0x360D                ; Wrap to the top row ("A")
L_0EFD:
        SHLD    nameCursorL             ; New cursor position
        JMP     DrawNameCursor          ; Draw it
L_0F03:
        MOV     A,H                     ; Top row ... at "K"?
        CPI     0x3B                    ; (last column)
        JNC     L_0F1C                  ; Yes ... wrap to next row
        JMP     L_0F12                  ; No ... move right
L_0F0C:
        MOV     A,H                     ; Middle row ... at "V"?
        CPI     0x3B                    ; (last column)
        JNC     L_0F22                  ; Yes ... wrap to next row
L_0F12:
        INR     H                       ; Move right ...
        INR     H                       ; ... one letter
        JMP     L_0EFD                  ; Store it
L_0F17:
        MVI     H,0x34                  ; Skip the gap ...
        JMP     L_0EEC                  ; ... before RUB
L_0F1C:
        LXI     H,0x270F                ; "L"
        JMP     L_0EFD                  ; Store it
L_0F22:
        LXI     H,0x270D                ; "W"
        JMP     L_0EFD                  ; Store it

CursorLeft:
        CALL    NameMoveDelay           ; One move per push
        CALL    EraseNameCursor         ; Erase cursor
        LHLD    nameCursorL             ; Cursor position
        MOV     A,L                     ; Which row?
        CPI     0x11                    ; Top row?
        JZ      L_0F4C                  ; Yes
        CPI     0x0F                    ; Middle row?
        JZ      L_0F5D                  ; Yes
        MOV     A,H                     ; Bottom row: at "W"?
        CPI     0x28                    ; (first column)
        JC      L_0F66                  ; Yes ... wrap to "K"
        CPI     0x34                    ; On RUB?
        JNZ     L_0F52                  ; No ... move left
        MVI     H,0x33                  ; Skip the gap back to "."
        JMP     L_0F52                  ; Move left
L_0F4C:
        MOV     A,H                     ; Top row: at "A"?
        CPI     0x28                    ; (first column)
        JC      L_0F57                  ; Yes ... wrap to END
L_0F52:
        DCR     H                       ; Move left ...
        DCR     H                       ; ... one letter
        JMP     L_0EFD                  ; Store it
L_0F57:
        LXI     H,0x2711                ; END
        JMP     L_0EFD                  ; Store it
L_0F5D:
        MOV     A,H                     ; Middle row: at "L"?
        CPI     0x28                    ; (first column)
        JC      L_0F6C                  ; Yes ... wrap to "K"
        JMP     L_0F52                  ; Move left
L_0F66:
        LXI     H,0x3B0F                ; "V"
        JMP     L_0EFD                  ; Store it
L_0F6C:
        LXI     H,0x3B11                ; "K"
        JMP     L_0EFD                  ; Store it

NameSelect:
        LXI     B,P2ScorLoM             ; Debounce ...
        CALL    DelayBC                 ; ... delay
        LDA     nameLength              ; Letters so far
        CPI     0x0A                    ; Name full?
        JNC     NameFull                ; Yes ... only RUB or END allowed
        LDA     nameCursorL             ; Cursor row
        CPI     0x11                    ; Top row?
        JZ      L_0FA0                  ; Yes ... A-K
        CPI     0x0F                    ; Middle row?
        JZ      L_0FA6                  ; Yes ... L-V
        LDA     nameCursorM             ; Bottom row ... cursor column
        CPI     0x32                    ; On RUB or END?
        JNC     L_0FAE                  ; Yes
        CALL    CursorColumn            ; Column number
        ADI     0x16                    ; + 22 ("W")
        CALL    AddLetter               ; Add letter to name
        JMP     NameLoop                ; Continue
L_0FA0:
        CALL    CursorColumn            ; Column number ("A"+column)
        JMP     AddLetter               ; Add letter
L_0FA6:
        CALL    CursorColumn            ; Column number
        ADI     0x0B                    ; + 11 ("L")
        JMP     AddLetter               ; Add letter
L_0FAE:
        CPI     0x35                    ; END?
        JNC     NameDone                ; Yes ... done

NameRub:
        LDA     nameLength              ; Any letters ...
        ANA     A                       ; ... to rub out?
        JZ      L_0FD4                  ; No ... nothing to do
        LHLD    nameOutL                ; Back up ...
        DCR     H                       ; ... the print ...
        SHLD    nameOutL                ; ... position
        MVI     A,0x1B                  ; Space
        CALL    DrawChar                ; Erase the letter
        LXI     H,nameLength            ; One less ...
        DCR     M                       ; ... letter
        LXI     H,hiName                ; Name buffer
        LDA     nameLength              ; Offset ...
        ADD     L                       ; ... to ...
        MOV     L,A                     ; ... last letter
        MVI     M,0x1B                  ; Blank it
L_0FD4:
        XRA     A                       ; Clear ...
        STA     nameFireHeld            ; ... fire ...
        STA     nameFirePressed         ; ... flags
        JMP     NameLoop                ; Continue

; A = column number of the cursor (0-10).
CursorColumn:
        LDA     nameCursorM             ; Cursor column
        SUI     0x27                    ; First column is 27
        RRC                             ; Columns are 2 apart
        RET                             ; Done

AddLetter:
        LXI     H,hiName                ; Name buffer
        PUSH    PSW                     ; Hold letter
        LDA     nameLength              ; Offset ...
        ADD     L                       ; ... to next ...
        MOV     L,A                     ; ... letter
        POP     PSW                     ; Restore letter
        MOV     M,A                     ; Store it in the name
        LHLD    nameOutL                ; Print position
        CALL    DrawChar                ; Print the letter
        SHLD    nameOutL                ; Next print position
        LXI     H,nameLength            ; One more ...
        INR     M                       ; ... letter
        JMP     L_0FD4                  ; Clear the fire flags and continue

NameFull:
        LDA     nameCursorL             ; Must be ...
        CPI     0x0D                    ; ... on the bottom row
        JNZ     NameDone                ; No ... (letters) ... done
        LDA     nameCursorM             ; Cursor column
        CPI     0x32                    ; RUB or END?
        JNC     L_1013                  ; Yes
        JMP     NameDone                ; No ... done
L_1013:
        CPI     0x36                    ; END?
        JNC     NameDone                ; Yes ... done
        JMP     NameRub                 ; RUB ... rub out the last letter

NameDone:
        XRA     A                       ; Name entry ...
        STA     nameEntry               ; ... is over
        CALL    CenterHiName            ; Center the new name
        CALL    PrintHiName             ; Print it
        JMP     ClearPlayField          ; Clear the playfield and out

EraseHiName:
        MVI     B,0x50                  ; 80 rows
        LXI     H,0x2D1E                ; Where the name is printed
        JMP     ClearRows               ; Erase it

PrintHiName:
        LHLD    hiNamePosL              ; Where to print
        LXI     D,hiName                ; The name
        LDA     nameLength              ; Number of letters
        MOV     C,A                     ; To C
        JMP     PrintMessage            ; Print it
D_103D:
        DB      0x07,0x08,0x2B,0x12,0x02,0x0E,0x11,0x04,0x11,0x1B,0x1B,0x11; "HI-SCORER  R"
        DB      0x04,0x06,0x08,0x12,0x13,0x11,0x00,0x13,0x08,0x0E,0x0D; "EGISTRATION"
D_1054:
        DB      0x0D,0x00,0x0C,0x04,0x1B,0x2E,0x2F,0x2F,0x2F,0x2F,0x2F,0x2F; "NAME [~~~~~~"
        DB      0x2F,0x2F,0x2F,0x2F,0x30; "~~~~]"
D_1065:
        DB      0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x00,0x00,0x00,0xFF,0x11,0x27
        DB      0x07,0x30,0x00,0x00,0x00

; Part II scores have 5 digits: the 4 BCD digits and a fixed "0".
Print4Digits0:
        PUSH    H                       ; Hold ...
        PUSH    D                       ; ... registers
        LXI     D,0x0400                ; 32 columns ...
        DAD     D                       ; ... over (after the 4 digits)
        MVI     A,0x1C                  ; "0"
        CALL    DrawChar                ; Print the trailing 0
        POP     D                       ; Restore ...
        POP     H                       ; ... registers
        JMP     Print4Digits            ; Print the 4 BCD digits

; A = score shifted left 4 bits, MSB (the thousands and hundreds of the displayed score).
ScoreHundreds:
        CALL    GetScoreDesc            ; Active player's score
        MOV     A,M                     ; Score ...
        INX     H                       ; ... into ...
        MOV     H,M                     ; ... HL
        MOV     L,A                     ; ...
        DAD     H                       ; *2
        DAD     H                       ; *4
        DAD     H                       ; *8
        DAD     H                       ; *16
        MOV     A,H                     ; The two digits
        RET                             ; Done

; Work out the screen position that centers the high-score name above "HI-SCORE".
CenterHiName:
        LDA     nameLength              ; Letters in name
        ANA     A                       ; Any?
        JZ      L_10AE                  ; No ... use the default
        MOV     B,A                     ; To B
        MVI     A,0x0A                  ; 10 ...
        SUB     B                       ; ... minus length
        STC                             ; Clear ...
        CMC                             ; ... carry
        RAR                             ; Half the spare characters
        ADI     0x2D                    ; Plus the left-most column
        MOV     H,A                     ; To H
        MVI     L,0x1E                  ; Row
        SHLD    hiNamePosL              ; Store position
        RET                             ; Done
L_10AE:
        LXI     H,0x2D1E                ; Default ...
        SHLD    hiNamePosL              ; ... position
        MVI     A,0x0A                  ; Default ...
        STA     nameLength              ; ... length of 10
        RET                             ; Done

FlashHiNameDo:
        CALL    PrintCorp               ; Print *TAITO CORPORATION*
        XRA     A                       ; Alien shots ...
        STA     shotsHalted             ; ... allowed
        EI                              ; Interrupts on (we use them to time)
        MVI     B,0x05                  ; Flash 5 times
L_10C4:
        PUSH    B                       ; Hold count
        LXI     D,D_0D79                ; " HI-SCORE "
        MVI     C,0x0A                  ; 10 characters
        LXI     H,0x2D1E                ; Over the name
        CALL    PrintMessage            ; Print " HI-SCORE "
        CALL    Delay32                 ; Wait
        CALL    EraseHiName             ; Erase it
        CALL    CenterHiName            ; Center the name
        CALL    PrintHiName             ; Print the name
        CALL    Delay32                 ; Wait
        POP     B                       ; Restore count
        DCR     B                       ; All done?
        JNZ     L_10C4                  ; No ... flash again
        RET                             ; Done
        DB      0x26,0x1D,0x1B,0x0E,0x11,0x1B,0x1E,0x1B,0x0F,0x0B,0x00,0x18; "<1 OR 2 PLAY"
        DB      0x04,0x11,0x12,0x27,0x1B,0x1B; "ERS>  "
        DB      0x29,0x1D,0x1B,0x0F,0x0B,0x00,0x18,0x04,0x11,0x1B,0x1B,0x1D; "*1 PLAYER  1"
        DB      0x1B,0x02,0x0E,0x08,0x0D,0x1B; " COIN "
D_1109:
        DB      0x1B,0x1B               ; "  TAITO   "
MessageCorp:
        DB      0x13,0x00,0x08,0x13,0x0E,0x1B,0x1B,0x1B
        DB      0x00,0x00,0x00,0x00

MessageCoin:
        DB      0x08,0x0D,0x12,0x04,0x11,0x13,0x1B,0x1B,0x02,0x0E,0x08,0x0D; "INSERT  COIN"

CreditTable:
        DB      0x0D,0x2A,0xE5,0x10
D_1127:
        DB      0x0A,0x2A,0xF7,0x10,0x07,0x2A,0x3C,0x11,0xFF

DefaultName:
        MVI     B,0x0E                  ; 14 bytes
        LXI     D,D_1109                ; Default name and variables
        LXI     H,hiName                ; Name buffer
        CALL    BlockCopy               ; Copy
        RET                             ; Done
        DB      0x29,0x1E,0x1B,0x0F,0x0B,0x00,0x18,0x04,0x11,0x12,0x1B,0x1E; "*2 PLAYERS 2"
        DB      0x1B,0x02,0x0E,0x08,0x0D,0x12; " COINS"

; Part II: same as the original but CnvtPixNumber is called here instead of the caller.
DrawShiftedSprite:
        CALL    CnvtPixNumber           ; Convert pixel number to screen/shift
L_1151:
        PUSH    B                       ; Hold count
        PUSH    H                       ; Hold start coordinate
        LDAX    D                       ; Get the picture bits
        OUT     SHFT_DATA               ; Store in shift register
        IN      SHFT_IN                 ; Read the shifted pixels
        ORA     M                       ; OR them onto the screen
        MOV     M,A                     ; Store them back to screen
        INX     H                       ; Next colummn on screen
        INX     D                       ; Next in picture
        XRA     A                       ; Shift over ...
        OUT     SHFT_DATA               ; ... to next byte in register (shift in 0)
        IN      SHFT_IN                 ; Read the shifted pixels
        ORA     M                       ; OR them onto the screen
        MOV     M,A                     ; Store them back to screen
        POP     H                       ; Restore starting coordinate
        LXI     B,0x0020                ; Add 32 ...
        DAD     B                       ; ... to coordinate (move to next row)
        POP     B                       ; Restore count
        DCR     B                       ; All done?
        JNZ     L_1151                  ; No ... go do all rows
        RET                             ; Done

; Clear a sprite from the screen (standard pixel number descriptor).
; ** We clear 2 bytes even though the draw-simple only draws one.
EraseSimpleSprite:
        CALL    CnvtPixNumber           ; Convert pixel number in HL

ClearRows:
        PUSH    B                       ; Hold
        PUSH    H                       ; Hold
        XRA     A                       ; 0
        MOV     M,A                     ; Clear screen byte
        INX     H                       ; Next byte
        MOV     M,A                     ; Clear byte
        INX     H                       ; ** Is this to mimic timing? We increment then pop
        POP     H                       ; Restore screen coordinate
        LXI     B,0x0020                ; Add 1 row ...
        DAD     B                       ; ... to screen coordinate
        POP     B                       ; Restore counter
        DCR     B                       ; All rows done?
        JNZ     ClearRows               ; Do all rows
        RET                             ; out

; Display character to screen
; HL = screen coordinates
; DE = character data
; B = number of rows
DrawSimpSprite:
        PUSH    B                       ; Preserve counter
        LDAX    D                       ; From character set ...
        MOV     M,A                     ; ... to screen
        INX     D                       ; Next in character set
        LXI     B,0x0020                ; Next row ...
        DAD     B                       ; ... on screen
        POP     B                       ; Restore counter
        DCR     B                       ; Decrement counter
        JNZ     DrawSimpSprite          ; Do all
        RET                             ; Out

; Part II looks up the alien shot reload rate from the score's thousands/hundreds digits.
AShotReloadRate:
        CALL    ScoreHundreds           ; Score digits
        JMP     L_153F                  ; Look them up in the table (the rest is the original routine)

; Erases a shifted sprite from screen (like for player's explosion)
EraseShifted:
        CALL    CnvtPixNumber           ; Convert pixel number in HL to coorinates with shift
L_119A:
        PUSH    B                       ; Hold BC
        PUSH    H                       ; Hold coordinate
        LDAX    D                       ; Get picture value
        OUT     SHFT_DATA               ; Value into shift register
        IN      SHFT_IN                 ; Read shifted sprite picture
        CMA                             ; Reverse it (erasing bits)
        ANA     M                       ; Erase the bits from the screen
        MOV     M,A                     ; Store the erased pattern back
        INX     H                       ; Next column on screen
        INX     D                       ; Next in image
        XRA     A                       ; Shift register over ...
        OUT     SHFT_DATA               ; ... 8 bits (shift in 0)
        IN      SHFT_IN                 ; Read 2nd byte of image
        CMA                             ; Reverse it (erasing bits)
        ANA     M                       ; Erase the bits from the screen
        MOV     M,A                     ; Store the erased pattern back
        POP     H                       ; Restore starting coordinate
        LXI     B,0x0020                ; Add 32 ...
        DAD     B                       ; ... to next row
        POP     B                       ; Restore BC (count)
        DCR     B                       ; All rows done?
        JNZ     L_119A                  ; No ... erase all
        RET                             ; Done

CnvtPixNumber:
        MOV     A,L                     ; Get X coordinate
        ANI     0x07                    ; Shift by pixel position
        OUT     SHFTAMNT                ; Write shift amount to hardware
        JMP     ConvToScr               ; HL = HL/8 + 2000 (screen coordinate)

; In a multi-player game the player's shields are block-copied to and from RAM between turns.
; HL = screen pointer
; DE = memory buffer
; B = number of rows
; C = number of columns
RememberShields:
        PUSH    B                       ; Hold counter
        PUSH    H                       ; Hold start
L_11C3:
        MOV     A,M                     ; From sprite ... (should be DE)
        STAX    D                       ; ... to screen ... (should be HL)
        INX     D                       ; Next in sprite
        INX     H                       ; Next on screen
        DCR     C                       ; All columns done?
        JNZ     L_11C3                  ; No ... do multi columns
        POP     H                       ; Restore screen start
        LXI     B,0x0020                ; Add 32 ...
        DAD     B                       ; ... to get to next row
        POP     B                       ; Pop the counters
        DCR     B                       ; All rows done?
        JNZ     RememberShields         ; No ... do multi rows
        RET                             ; Done

DrawSprCollision:
        CALL    CnvtPixNumber           ; Convert pixel number to coord and shift
        XRA     A                       ; Clear the ...
        STA     collision               ; ... collision-detection flag
L_11DD:
        PUSH    B                       ; Hold count
        PUSH    H                       ; Hold screen
        LDAX    D                       ; Get byte
        OUT     SHFT_DATA               ; Write first byte to shift register
        IN      SHFT_IN                 ; Read shifted pattern
        PUSH    PSW                     ; Hold the pattern
        ANA     M                       ; Any bits from pixel collide with bits on screen?
        JZ      L_11EE                  ; No ... leave flag alone
        MVI     A,0x01                  ; Yes ... set ...
        STA     collision               ; ... collision flag
L_11EE:
        POP     PSW                     ; Restore the pixel pattern
        ORA     M                       ; OR it onto the screen
        MOV     M,A                     ; Store new screen value
        INX     H                       ; Next byte on screen
        INX     D                       ; Next in pixel pattern
        XRA     A                       ; Write zero ...
        OUT     SHFT_DATA               ; ... to shift register
        IN      SHFT_IN                 ; Read 2nd half of shifted sprite
        PUSH    PSW                     ; Hold pattern
        ANA     M                       ; Any bits from pixel collide with bits on screen?
        JZ      L_1202                  ; No ... leave flag alone
        MVI     A,0x01                  ; Yes ... set ...
        STA     collision               ; ... collision flag
L_1202:
        POP     PSW                     ; Restore the pixel pattern
        ORA     M                       ; OR it onto the screen
        MOV     M,A                     ; Store new screen pattern
        POP     H                       ; Starting screen coordinate
        LXI     B,0x0020                ; Add 32 ...
        DAD     B                       ; ... to get to next row
        POP     B                       ; Restore count
        DCR     B                       ; All done?
        JNZ     L_11DD                  ; No ... do all rows
        RET                             ; Done

ClearSmallSprite:
        XRA     A                       ; 0
L_1211:
        PUSH    B                       ; Preserve BC
        MOV     M,A                     ; Clear screen byte
        LXI     B,0x0020                ; Bump HL ...
        DAD     B                       ; ... one screen row
        POP     B                       ; Restore
        DCR     B                       ; All done?
        JNZ     L_1211                  ; No ... clear all
        RET                             ; Done

; The player's shot hit something (or is being removed from play)
;
PlayerShotHit:
        LDA     plyrShotStatus          ; Player shot flag
        CPI     0x05                    ; Alien explosion in progress?
        RZ                              ; Yes ... ignore this function
        CPI     0x02                    ; Normal movement?
        RNZ                             ; No ... out

;
        LDA     obj1CoorYr              ; Get Yr coordinate of player shot
        CPI     0xD8                    ; Compare to 216 (40 from Top-rotated)
        MOV     B,A                     ; Hold value for later
        JNC     L_1282                  ; Yr is within 40 from top initiate miss-explosion (shot flag 3)
        LDA     alienIsExploding        ; Is an alien ...
        ANA     A                       ; ... blowing up?
        RZ                              ; No ... out

;
        MOV     A,B                     ; Get original Yr coordinate back to A
        CPI     0xCE                    ; Compare to 206 (50 from rotated top)
        JNC     ShotHitSaucer           ; Yr is within 50 from top? Yes ... saucer must be hit
        ADI     0x06                    ; Offset to coordinate for wider "explosion" picture
        MOV     B,A                     ; Hold that
        LDA     refAlienYr              ; Ref alien Y coordianate

; If the lower 4 rows are all empty then the reference alien's Y coordinate will wrap around from 0 to F8.
; At this point the top row of aliens is in the shields and we will assume that everything is within
; the rack.
        CPI     0x90                    ; This is true if ...
        JNC     CodeBug1                ; ... aliens are down in the shields
        CMP     B                       ; Compare to shot's coordinate
        JNC     L_1282                  ; Outside the rack-square ... do miss explosion

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
CodeBug1:
        MOV     L,B                     ; L now holds the shot coordinate (adjusted)
        LDA     refAlienYr              ; Top of the rack ...
        ADI     0x50                    ; ... is 5 rows (50) above the reference alien
        CMP     L                       ; Is the shot above the rack?
        CC      ShotHitDrop             ; Shot is above the rack ... it hit the falling alien
        CALL    FindRow                 ; Look up row number to B
        LDA     obj1CoorXr              ; Player's shot's Xr coordinate ...
        MOV     H,A                     ; ... to H
        CALL    FindColumn              ; Get alien's coordinate
        MOV     A,C                     ; Part II fixes "CodeBug1" (see above): column ...
        CPI     0x0C                    ; ... number past the 11th?
        JNC     L_1282                  ; Yes ... it can't be an alien
        SHLD    expAlienYr              ; Put it in the exploding-alien descriptor
        MVI     A,0x05                  ; Flag alien explosion ...
        STA     plyrShotStatus          ; ... in progress
        CALL    GetAlienStatPtr         ; Get descriptor for alien
        MOV     A,M                     ; Is alien ...
        ANA     A                       ; ... alive
        JZ      L_1282                  ; No ... must have been an alien shot
        CALL    AlienHit                ; Kill (or split) the alien and score it
        CALL    ReadDesc                ; Load 5 byte sprite descriptor
        CALL    DrawSprite              ; Draw explosion sprite on screen
        MVI     A,0x10                  ; Initiate alien-explosion
        STA     expAlienTimer           ; ... timer to 16
        RET                             ; Out

;
; Player shot leaving playfield, hitting shield, or hitting an alien shot
L_1282:
        MVI     A,0x03                  ; Mark ...
        STA     plyrShotStatus          ; ... player shot hit something other than alien
        JMP     L_129C                  ; Finish up

;
; Time down the alien explosion. Remove when done.
AExplodeTime:
        LXI     H,expAlienTimer         ; Decrement alien explosion ...
        DCR     M                       ; ... timer
        RNZ                             ; Not done  ... out
        LHLD    expAlienYr              ; Pixel pointer for exploding alien
        MVI     B,0x12                  ; 18 rows (the split explosion is wider)
        CALL    EraseAlienExp           ; Erase the explosion (or draw the two halves of a split alien)
L_1297:
        MVI     A,0x04                  ; 4 means that ...
        STA     plyrShotStatus          ; ... alien has exploded (remove from active duty)

;
L_129C:
        XRA     A                       ; Turn off ...
        STA     alienIsExploding        ; ... alien-is-blowing-up flag
        MVI     B,0xF7                  ; Turn off ...
        JMP     SoundBits3Off           ; ... alien exploding sound

; Count number of 16s needed to bring reference (in A) up to target (in H).
; If the reference starts out beyond the target then we add 16s as long as
; the reference has a signed bit. But these aren't signed quantities. This
; doesn't make any sense. This counting algorithm produces questionable
; results if the reference is beyond the target.
;
Cnt16s:
        MVI     C,0x00                  ; Count of 16s
        CMP     H                       ; Compare reference coordinate to target
        CNC     WrapRef                 ; If reference is greater or equal then do something questionable ... see below
L_12AB:
        CMP     H                       ; Compare reference coordinate to target
        RNC                             ; If reference is greater or equal then done
        ADI     0x10                    ; Add 16 to reference
        INR     C                       ; Bump 16s count
        JMP     L_12AB                  ; Keep testing

; L contains a Yr coordinate. Find the row number within the rack that corresponds
; to the Yr coordinate. Return the row coordinate in L and the row number in C.
;
FindRow:
        LDA     refAlienYr              ; Reference alien Yr coordinate
        MOV     H,L                     ; Target Yr coordinate to H
        CALL    Cnt16s                  ; Count 16s needed to bring ref alien to target
        MOV     B,C                     ; Count to B
        DCR     B                       ; Base 0
        SBI     0x10                    ; The counting also adds 16 no matter what
        MOV     L,A                     ; To coordinate
        RET                             ; Done

; H contains a Xr coordinate. Find the column number within the rack that corresponds
; to the Xr coordinate. Return the column coordinate in H and the column number in C.
;
FindColumn:
        LDA     refAlienXr              ; Reference alien Yn coordinate
        CALL    Cnt16s                  ; Count 16s to bring Y to target Y
        SBI     0x10                    ; Subtract off extra 16
        MOV     H,A                     ; To H
        RET                             ; Done

ShotHitDrop:
        MVI     A,0x01                  ; Flag the ...
        STA     dropHit                 ; ... falling alien as hit
        RET                             ; Done

ShotHitSaucer:
        MVI     A,0x01                  ; Mark flying ...
        STA     saucerHit               ; ... saucer has been hit
        JMP     L_1297                  ; Remove player shot

; Part II: the alien's type comes from its status byte. A crab (3) hit in round 3 or later
; splits into two small aliens (7) in its slot and the slot to its right. The explosion
; picture is then the 32-column "split" image at 1AE0.
AlienHit:
        MOV     A,M                     ; Alien status (type)
        STA     lastAlienType           ; Remember the type for the intermission
        MVI     B,0x05                  ; Default score type 5 (squid, 30 points)
        MVI     M,0x00                  ; Kill the alien
        PUSH    H                       ; Hold alien pointer
        LXI     H,expAlienLSB           ; Exploding-alien descriptor
        MVI     M,0xC2                  ; Picture LSB
        INX     H                       ; Next
        MVI     M,0x1C                  ; ... 1CC2 (normal explosion)
        INX     H                       ; ...
        INX     H                       ; ...
        INX     H                       ; Size ...
        MVI     M,0x10                  ; ... 16
        POP     H                       ; Restore pointer
        CPI     0x01                    ; Octopus?
        CZ      L_1301                  ; Yes ... 10 points
        CPI     0x03                    ; Crab?
        CZ      CrabHit                 ; Yes ... 20 points (or split)
        CPI     0x07                    ; Small (split) alien?
        CZ      L_1304                  ; Yes ... 30 points
        JMP     ScoreForAlien           ; Explosion sound and score
L_1301:
        MVI     B,0x01                  ; Octopus
        RET                             ; Done
L_1304:
        MVI     B,0x07                  ; Small alien
        RET                             ; Done

CrabHit:
        PUSH    H                       ; Hold pointer
        PUSH    PSW                     ; Hold type
        CALL    GetRoundNum             ; Round number
        CPI     0x03                    ; Round 3 or later?
        JNC     L_1327                  ; Yes ... split the crab
        POP     PSW                     ; Restore type
        POP     H                       ; Restore pointer
        MVI     B,0x03                  ; Crab score
        RET                             ; Done
L_1316:
        INX     H                       ; The slot to the right ...
        MVI     M,0x07                  ; ... becomes a small alien too
        LXI     H,expAlienLSB           ; Exploding-alien descriptor
        MVI     M,0xE0                  ; Picture LSB
        INX     H                       ; Next
        MVI     M,0x1A                  ; ... 1AE0 (crab splitting into two)
        INX     H                       ; ...
        INX     H                       ; ...
        INX     H                       ; Size ...
        MVI     M,0x20                  ; ... 32
        RET                             ; Done
L_1327:
        POP     PSW                     ; Restore type
        POP     H                       ; Restore pointer
        MVI     M,0x07                  ; This slot becomes a small alien
        MVI     B,0x03                  ; Crab score
        JMP     L_1316                  ; Fill the slot to the right and set the split picture

; At the end of an alien explosion erase it. For a split crab draw the two small aliens.
EraseAlienExp:
        LDA     expAlienLSB             ; Exploding-alien picture LSB
        CPI     0xC2                    ; Normal explosion?
        JZ      EraseSimpleSprite       ; Yes ... erase it
        LXI     D,AlienSprB             ; Small-alien picture
        PUSH    D                       ; Hold it
        CALL    DrawSprite              ; Draw the left small alien (B=18 rows)
        POP     D                       ; Picture again
        MVI     B,0x10                  ; 16 rows
        JMP     L_1399                  ; Draw the right small alien and out

; B is row number. C is column number (starts at 1).
; Return pointer to alien-status flag for current player.
GetAlienStatPtr:
        MOV     A,B                     ; Hold original
        RLC                             ; *2
        RLC                             ; *4
        RLC                             ; *8
        ADD     B                       ; *9
        ADD     B                       ; *10
        ADD     B                       ; *11
        ADD     C                       ; Add row offset to column offset
        DCR     A                       ; -1
        MOV     L,A                     ; Set LSB of HL
        LDA     playerDataMSB           ; Set ...
        MOV     H,A                     ; ... MSB of HL with active player indicator
        RET                             ; Done

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
WrapRef:
        INR     C                       ; Increase 16s count
        ADI     0x10                    ; Add 16 to ref
        JM      WrapRef                 ; Keep going till result is positive
        RET                             ; Out

; When rack bumps the edge of the screen then the direction flips and the rack
; drops 8 pixels. The deltaX and deltaY values are changed here. Interestingly
; if there is only one alien left then the right value is 3 instead of the
; usual 2. The left direction is always -2.
RackBump:
        LDA     rackDirection           ; Get rack direction
        ANA     A                       ; Moving right?
        JNZ     L_137B                  ; No ... handle moving left

;
        LXI     H,0x3EA4                ; Line down the right edge of playfield
        CALL    L_1389                  ; Check line down the edge
        RNC                             ; Nothing is there ... return
        MVI     B,0xFE                  ; Delta X of -2
        MVI     A,0x01                  ; Rack now moving right

;
L_136D:
        STA     rackDirection           ; Set new rack direction
        MOV     A,B                     ; B has delta X
        STA     refAlienDXr             ; Set new delta X
        LDA     rackDownDelta           ; Set delta Y ...
        STA     refAlienDYr             ; ... to drop rack by 8
        RET                             ; Done

;
L_137B:
        LXI     H,0x2524                ; Line down the left edge of playfield
        CALL    L_1389                  ; Check line down the edge
        RNC                             ; Nothing is there ... return
        CALL    L_16AF                  ; Get moving-right delta X value of 2 (3 if just one alien left)
        XRA     A                       ; Rack now moving left
        JMP     L_136D                  ; Set rack direction

;
L_1389:
        MVI     B,0x17                  ; Checking 23 bytes in a line up the screen from near the bottom
L_138B:
        MOV     A,M                     ; Get screen memory
        ANA     A                       ; Is screen memory empty?
        JNZ     L_1451                  ; No ... set carry flag and out
        INX     H                       ; Next byte on screen
        DCR     B                       ; All column done?
        JNZ     L_138B                  ; No ... keep looking
        RET                             ; Return with carry flag clear

DrawSprite:
        CALL    CnvtPixNumber           ; Convert pixel number to screen/shift
L_1399:
        NOP                             ; (Space where the original saved HL)
L_139A:
        PUSH    B                       ; Hold for a second
        PUSH    H                       ; Hold for a second
        LDAX    D                       ; From sprite data
        OUT     SHFT_DATA               ; Write data to shift register
        IN      SHFT_IN                 ; Read back shifted amount
        MOV     M,A                     ; Shifted sprite to screen
        INX     H                       ; Adjacent cell
        INX     D                       ; Next in sprite data
        XRA     A                       ; 0
        OUT     SHFT_DATA               ; Write 0 to shift register
        IN      SHFT_IN                 ; Read back remainder of previous
        MOV     M,A                     ; Write remainder to adjacent
        POP     H                       ; Old screen coordinate
        LXI     B,0x0020                ; Offset screen ...
        DAD     B                       ; ... to next row
        POP     B                       ; Restore count
        DCR     B                       ; All done?
        JNZ     L_139A                  ; No ... do all
        RET                             ; Done

; Count number of aliens remaining in active game and return count 2082 holds the current count.
; If only 1, 206B gets a flag of 1 ** but ever nobody checks this
CountAliens:
        CALL    GetPlayerDataPtr        ; Get active player descriptor
        LXI     B,0x3700                ; B=55 aliens to check?
L_13BB:
        MOV     A,M                     ; Get byte
        ANA     A                       ; Is it a zero?
        JZ      L_13C1                  ; Yes ... don't count it
        INR     C                       ; Count the live aliens
L_13C1:
        INX     H                       ; Next alien
        DCR     B                       ; Count ...
        JNZ     L_13BB                  ; ... all alien indicators
        MOV     A,C                     ; Get the count
        STA     numAliens               ; Hold it
        CPI     0x01                    ; Just one?
        RNZ                             ; No keep going
        LXI     H,oneAlien              ; Set flag if ...
        MVI     M,0x01                  ; ... only one alien left
        CALL    GetPlayerDataPtr        ; Part II: check for the last-alien bonus. Point to alien 0 (bottom left)
        MOV     A,M                     ; Is the bottom-left alien ...
        ANA     A                       ; ... the one left?
        JNZ     Bonus1000               ; Yes ... 1000 point bonus when it is shot
        MVI     B,0x16                  ; Look through the bottom two rows (22 aliens)
L_13DC:
        MOV     A,M                     ; Is this ...
        ANA     A                       ; ... the live one?
        JNZ     L_13E7                  ; Yes ... check it
        INX     H                       ; Next alien
        DCR     B                       ; All 22 checked?
        JNZ     L_13DC                  ; No ... keep looking
        RET                             ; Not in the bottom two rows ... no bonus
L_13E7:
        CPI     0x01                    ; Must be an octopus (10 points)
        RNZ                             ; No ... no bonus
        MVI     L,0x05                  ; Bottom-row middle alien (index 5)
        MOV     A,M                     ; Is it ...
        ANA     A                       ; ... the one left?
        CNZ     Bonus800                ; Yes ... 800 point bonus
        MVI     A,0x01                  ; Flag ...
        STA     lastAlienBonus          ; ... a bonus for the last alien (500 unless 800/1000 were flagged)
        RET                             ; Done

; Set HL with 2100 if player 1 is active or 2200 if player 2 is active
;
GetPlayerDataPtr:
        MVI     L,0x00                  ; Byte boundary

; H = active player's data page (21 or 22). L is left alone.
GetPlayerDataPage:
        LDA     playerDataMSB           ; Active player number
        MOV     H,A                     ; Set HL to data
        RET                             ; Done

; Initiate player fire if button is pressed.
; Demo commands are parsed here if in demo mode
PlrFireOrDemo:
        LDA     playerAlive             ; Is there an active player?
        CPI     0xFF                    ; FF = alive
        RNZ                             ; Player has been shot - no firing
        LXI     H,obj0TimerMSB          ; Get player ...
        MOV     A,M                     ; ... task ...
        INX     H                       ; ... timer ...
        MOV     B,M                     ; ... value
        ORA     B                       ; Is the timer 0 (object active)?
        RNZ                             ; No ... no firing till player object starts
        LDA     plyrShotStatus          ; Does the player have ...
        ANA     A                       ; ... a shot on the screen?
        RNZ                             ; Yes ... ignore
        LDA     gameMode                ; Are we in ...
        ANA     A                       ; ... game mode?
        JZ      L_1438                  ; No ... in demo mode ... constant firing in demo
        LDA     fireBounce              ; Is fire button ...
        ANA     A                       ; ... being held down?
        JNZ     L_142E                  ; Yes ... wait for bounce
        CALL    ReadInputs              ; Read active player controls
        ANI     0x10                    ; Fire-button pressed?
        RZ                              ; No ... out
        MVI     A,0x01                  ; Flag
        STA     plyrShotStatus          ; Flag shot active
        STA     fireBounce              ; Flag that fire button is down
        RET                             ; Out
L_142E:
        CALL    ReadInputs              ; Read active player controls
        ANI     0x10                    ; Fire-button pressed?
        RNZ                             ; Yes ... ignore
        STA     fireBounce              ; Else ... clear flag
        RET                             ; Out

; Handle demo (constant fire, parse demo commands)
L_1438:
        LXI     H,plyrShotStatus        ; Demo fires ...
        MVI     M,0x01                  ; ... constantly
        LHLD    demoCmdPtrLSB           ; Demo command bufer
        INX     H                       ; Next position
        MOV     A,L                     ; Command buffer ...
        CPI     0xCA                    ; Past the end of the demo commands (1ABF-1AC9)?
        JC      L_1449
        MVI     L,0xBF                  ; Wrap back to the start (1ABF)
L_1449:
        SHLD    demoCmdPtrLSB           ; Next demo command
        MOV     A,M                     ; Get next command
        STA     nextDemoCmd             ; Set command for movement
        RET                             ; Done
L_1451:
        STC                             ; Set carry flag
        RET                             ; Done
L_1453:
        XRA     A                       ; 0
        CALL    L_180B                  ; Print ZERO ships remain
L_1457:
        CALL    CurPlyAlive             ; Get active-flag ptr for current player
        MVI     M,0x00                  ; Flag player is dead
        CALL    GetScoreDesc            ; Get score descriptor for current player
        INX     H                       ; Point to high two digits
        LXI     D,HiScorM               ; Current high score upper two digits
        LDAX    D                       ; Is player score greater ...
        CMP     M                       ; ... than high score?
        DCX     D                       ; Point to LSB
        DCX     H                       ; Point to LSB
        LDAX    D                       ; Go ahead and fetch high score lower two digits
        JZ      L_1471                  ; Upper two are the same ... have to check lower two
        JNC     L_1481                  ; Player score is lower than high ... nothing to do
        JMP     L_1475                  ; Player socre is higher ... go copy the new high score

;
L_1471:
        CMP     M                       ; Is lower digit higher? (upper was the same)
        JNC     L_1481                  ; No ... high score is still greater than player's score
L_1475:
        MOV     A,M                     ; Copy the new ...
        STAX    D                       ; ... high score lower two digits
        INX     D                       ; Point to MSB
        INX     H                       ; Point to MSB
        MOV     A,M                     ; Copy the new ...
        STAX    D                       ; ... high score upper two digits
        CALL    PrintHiScore            ; Draw the new high score
        CALL    NewHiScore              ; Clear the old name and flag a name entry for this player
L_1481:
        LDA     twoPlayers              ; Number of players
        ANA     A                       ; Is this a single player game?
        JZ      GameOverMsg             ; Yes ... short message
        LXI     H,0x2803                ; Screen coordinates
        LXI     D,MessageGOver          ; "GAME OVER PLAYER< >"
        MVI     C,0x14                  ; 20 characters
        CALL    PrintMessageDel         ; Print message
        DCR     H                       ; Back up ...
        DCR     H                       ; ... to player indicator
        MVI     B,0x1D                  ; Character "1"
        LDA     playerDataMSB
        RRC                             ; Is this player 1?
        JC      L_14A0                  ; Yes ... keep the digit
        MVI     B,0x1E                  ; Else ... character "2"
L_14A0:
        MOV     A,B                     ; To A
        CALL    DrawChar                ; Print player number
        CALL    OneSecDelay             ; Short delay
        CALL    L_16A5                  ; Get current player "alive" flag
        MOV     A,M                     ; Is player ...
        ANA     A                       ; ... alive?
        JZ      GameOverMsg             ; No ... skip to "GAME OVER" sequence
        JMP     L_0336                  ; Switch players and game loop

NewHiScore:
        CALL    ClearHiName             ; Erase the old name and blank the buffer
        LXI     H,namePending           ; Flag a ...
        MVI     M,0x01                  ; ... name entry at game over
        LDA     playerDataMSB           ; Which player?
        CPI     0x21                    ; Player 1?
        JNZ     L_14C6                  ; No
        INX     H                       ; 20E1 ...
        MVI     M,0x00                  ; ... = 00 (player 1 controls, screen not flipped)
        RET                             ; Done
L_14C6:
        INX     H                       ; 20E1 ...
        MVI     M,0x20                  ; ... = 20 (player 2 controls, screen flipped in a cocktail cabinet)
        RET                             ; Done

DoNameEntry:
        LXI     H,namePending           ; Is there ...
        MOV     A,M                     ; ... a name ...
        ANA     A                       ; ... to enter?
        RZ                              ; No ... done
        INX     H                       ; 20E1
        PUSH    H                       ; Hold pointer
        MOV     B,M                     ; Cocktail bit for the player
        CALL    SetFlipDelay            ; Flip the screen for player 2 (cocktail)
        CALL    NameEntry               ; HI-SCORER REGISTRATION
        POP     H                       ; Restore pointer
        MVI     M,0xFF                  ; 20E1=FF
        DCX     H                       ; Back to 20E0
        MVI     M,0x00                  ; No name pending
        MVI     B,0x00                  ; Screen back to normal
        JMP     SetFlipDelay            ; Set it and out

ClearHiName:
        CALL    EraseHiName             ; Erase the name on screen
        MVI     B,0x0A                  ; 10 bytes
        LXI     D,D_1065                ; Spaces
        LXI     H,hiName                ; Name buffer
        JMP     BlockCopy               ; Blank the name

GameOverMsg:
        LXI     H,0x2D18                ; Screen coordinates
        LXI     D,MessageGOver          ; "GAME OVER PLAYER< >"
        MVI     C,0x0A                  ; Just the "GAME OVER" part
        CALL    PrintMessageDel         ; Print message
        CALL    TwoSecDelay             ; Long delay
        CALL    DoNameEntry             ; Name entry if the high score was beaten
        CALL    ClearPlayField          ; Clear center window
        XRA     A                       ; Now in ...
        STA     gameMode                ; ... demo mode
        OUT     SOUND2                  ; All sound off
        CALL    EnableGameTasks         ; Enable ISR game tasks
        JMP     L_0D32                  ; Print credit information and do splash

PlayerHit:
        LXI     SP,0x2400               ; Reset stack
        EI                              ; Enable interrupts
        XRA     A                       ; Flag ...
        STA     playerAlive             ; ... player is shot
L_151A:
        CALL    PlayerShotHit           ; Player's shot collision detection
        MVI     B,0x04                  ; Player has been hit ...
        CALL    SoundBits3On            ; ... sound
        CALL    PlayerHitChk            ; Has flag been set?
        JNZ     L_151A                  ; No ... wait for the flag
        CALL    DsableGameTasks         ; Disable ISR game tasks
        LXI     H,0x2701                ; Player's stash of ships
        CALL    L_177A                  ; Erase the stash of shps
        XRA     A                       ; Print ...
        CALL    L_180B                  ; ... a zero (number of ships)
        MVI     B,0xFB                  ; Turn off ...
        JMP     L_1731                  ; ... player shot sound
        DB      0xCD,0x97,0x0B,0x23,0x7E
L_153F:
        LXI     D,AReloadScoreTab       ; Score MSB table
        LXI     H,ShotReloadRate        ; Corresponding fire reload rate table
        MVI     C,0x04                  ; Only 4 entries (a 5th value of 7 is used after that)
        MOV     B,A                     ; Hold the score value
L_1548:
        LDAX    D                       ; Get lookup from table
        CMP     B                       ; Compare them
        JNC     L_1553                  ; Equal or below ... use this table entry
        INX     H                       ; Next ...
        INX     D                       ; ... entry in table
        DCR     C                       ; Do all ...
        JNZ     L_1548                  ; ... 4 entries in the tables
L_1553:
        MOV     A,M                     ; Load the shot reload value
        STA     aShotReloadRate         ; Save the value for use in shot routine
        RET                             ; Done

; Shot sound on or off depending on 2025
ShotSound:
        LDA     plyrShotStatus          ; Player shot flag
        ANA     A                       ; Is the shot ...
        JNZ     L_1564                  ; Yes ... go
        MVI     B,0xFD                  ; Sound mask
        JMP     SoundBits3Off           ; Mask off sound

;
L_1564:
        MVI     B,0x02                  ; Sound bit
        JMP     SoundBits3On            ; OR on sound

; This called from the ISR times down the fleet and sets the flag at 2095 if
; the fleet needs a change in sound handling (new delay, new sound)
TimeFleetSound:
        LXI     H,fleetSndHold          ; Pointer to hold time for fleet
        DCR     M                       ; Decrement hold time
        CZ      L_1596                  ; If 0 turn fleet movement sound off
        LDA     playerOK                ; Is player OK?
        ANA     A                       ; 1  means OK
        JZ      L_1596                  ; Player not OK ... fleet movement sound off and out
        LXI     H,fleetSndCnt           ; Current time on fleet sound
        DCR     M                       ; Count down
        RNZ                             ; Not time to change sound ... out
        LXI     H,soundPort5            ; Current sound port 3 value
        MOV     A,M                     ; Get value
        OUT     SOUND2                  ; Set sounds
        LDA     numAliens               ; Number of aliens on active screen
        ANA     A                       ; Is it zero?
        JZ      L_1596                  ; Yes ... turn off fleet movement sound and out
        DCX     H                       ; (2097) Point to fleet timer reload
        MOV     A,M                     ; Get fleet delay value
        DCX     H                       ; (2096) Point to fleet timer
        MOV     M,A                     ; Reload the timer
        DCX     H                       ; Point to change-sound
        MVI     M,0x01                  ; (2095) time to change sound
        MVI     A,0x04                  ; Set hold ...
        STA     fleetSndHold            ; ... time for fleet sound
        RET                             ; Done
L_1596:
        LDA     soundPort5              ; Current sound port 3 value
L_1599:
        ANI     0x30                    ; Mask off fleet movement sounds
        OUT     SOUND2                  ; Set sounds
        RET                             ; Out

; This game-loop routine handles two sound functions. The routine does:
; 1) Time out the extra-ship awarded sound and turn it off when done
; 2) Load the fleet sound delay based on number of remaining aliens
; 3) Make the changing fleet sound
;
; The 2095 flag is set by the ISR and cleared here. The ISR does the timing and sets 2095 when it
; is time to make a new fleet sound.
;
FleetDelayExShip:
        LDA     changeFleetSnd          ; Time for new ...
        ANA     A                       ; ... fleet movement sound?
        JZ      L_15D3                  ; No ... skip to extra-man timing
        LXI     H,D_1791                ; Number of aliens list coupled ...
        LXI     D,D_17A1                ; ... with delay list
        LDA     numAliens               ; Get the number of aliens on the screen
L_15AE:
        CMP     M                       ; Compare it to the first list value
        JNC     L_15B7                  ; Number of live aliens is higher than value ... use the delay
        INX     H                       ; Move to ...
        INX     D                       ; ... next list value
        JMP     L_15AE                  ; Find the right delay
L_15B7:
        LDAX    D                       ; Get the delay from the second list

SoundDelay:
        STA     fleetSndReload          ; Store the new alien sound delay
        LXI     H,soundPort5            ; Get current state ...
        MOV     A,M                     ; ... of sound port
        ANI     0x30                    ; Mask off all fleet movement sounds
        MOV     B,A                     ; Hold the value
        MOV     A,M                     ; Get current state
        ANI     0x0F                    ; This time ONLY the fleet movement sounds
        RLC                             ; Shift next to next sound
        CPI     0x10                    ; Overflow?
        JNZ     L_15CD                  ; No ... keep it
        MVI     A,0x01                  ; Reset back to first sound
L_15CD:
        ORA     B                       ; Add fleet sounds to current sound value
        MOV     M,A                     ; Store new sound value
        XRA     A                       ; Restart ...
        STA     changeFleetSnd          ; ... waiting on fleet time

;
L_15D3:
        LXI     H,extraHold             ; Sound timer for award extra ship
        DCR     M                       ; Time expired?
        RNZ                             ; No ... leave sound playing
        MVI     B,0xEF                  ; Turn off bit set with #$10 (award extra ship)
        JMP     SoundBits3Off           ; Stop sound and out

SndOffExtPly:
        MVI     B,0xEF                  ; Mask off sound bit 4 (Extended play)
        LXI     H,soundPort5            ; Current sound content
        MOV     A,M                     ; Get current sound bits
        ANA     B                       ; Turn off extended play
        MOV     M,A                     ; Remember settings
        OUT     SOUND2                  ; Turn off extended play
        RET                             ; Out

; Read control inputs for active player
ReadInputs:
        LDA     playerDataMSB           ; Get active player
        RRC                             ; Test player
        JNC     L_15F2                  ; Player 2 ... read port 2
        IN      INP1                    ; Player 1 ... read port 1
        RET                             ; Out
L_15F2:
        IN      INP2                    ; Get controls for player 2
        RET                             ; Out

; Check and handle TILT
CheckHandleTilt:
        IN      INP2                    ; Read input port
        ANI     0x04                    ; Tilt?
        RZ                              ; No tilt ... return
        LDA     tilt                    ; Already in TILT handle?
        ANA     A                       ; 1 = yes
        RNZ                             ; Yes ... ignore it now
        JMP     TiltPart2
L_1602:
        MVI     B,0x04                  ; Clear the playfield 4 times (Part II)
L_1604:
        PUSH    B                       ; Hold count
        CALL    ClearPlayField          ; Clear
        POP     B                       ; Restore count
        DCR     B                       ; All done?
        JNZ     L_1604                  ; No ... do again
        MVI     A,0x01                  ; Flag ...
        STA     tilt                    ; ... handling TILT
        CALL    DsableGameTasks         ; Disable game tasks
        EI                              ; Re-enable interrupts
        LXI     D,MessageTilt           ; Message "TILT"
        LXI     H,0x3016                ; Center of screen
        MVI     C,0x04                  ; Four letters
        CALL    PrintMessageDel         ; Print "TILT"
        CALL    OneSecDelay             ; Short delay
        XRA     A                       ; Zero
        STA     tilt                    ; TILT handle over
        STA     waitStartLoop           ; Back into splash screens
        JMP     GameOverMsg             ; Handle game over for player

CtrlSaucerSound:
        LXI     H,saucerActive          ; Saucer on screen flag
        MOV     A,M                     ; Is the saucer ...
        ANA     A                       ; ... on the screen?
        JZ      SaucerSndOff            ; No ... UFO sound off
        INX     H                       ; Saucer hit flag
        MOV     A,M                     ; (2085) Get saucer hit flag
        ANA     A                       ; Is saucer in "hit" sequence?
        RNZ                             ; Yes ... out

SaucerSndOn:
        MVI     B,0x01                  ; Retrigger saucer ...
        JMP     SoundBits3On            ; ... sound (retrigger makes it warble?)

; Draw "SCORE ADVANCE TABLE"
DrawAdvTable:
        LXI     H,0x2812                ; 0x410 is 1040 rotCol=32, rotRow=16
        LXI     D,MessageAdv            ; "*SCORE ADVANCE TABLE*"
        MVI     C,0x15                  ; 21 bytes in message
        CALL    PrintMessage            ; Print message
        MVI     A,0x0B                  ; 11 characters per line now ("=500 POINTS")
        STA     temp206C                ; Hold the count
        LXI     B,AdvTableSprites       ; Coordinate/sprite for drawing table
L_1652:
        CALL    ReadPriStruct           ; Get HL=coordinate, DE=image
        JC      L_165E                  ; Move on if done
        CALL    L_166B                  ; Draw 16-byte sprite
        JMP     L_1652                  ; Do all in table
L_165E:
        LXI     B,AdvTableMessages      ; Coordinate/message for drawing table
L_1661:
        CALL    ReadPriStruct           ; Get HL=coordinate, DE=message
        RC                              ; Out if done
        CALL    L_1673                  ; Print message
        JMP     L_1661                  ; Do all in table

;
L_166B:
        PUSH    B                       ; Hold BC
        MVI     B,0x10                  ; 16 bytes
        CALL    DrawSimpSprite          ; Draw simple
        POP     B                       ; Restore BC
        RET                             ; Out

;
L_1673:
        PUSH    B                       ; Hold BC
        LDA     temp206C                ; Count of 10 ...
        MOV     C,A                     ; ... to C
        CALL    PrintMessageDel         ; Print the message with delay between letters
        POP     B                       ; Restore BC
        RET                             ; Out

; Read a 4-byte print-structure pointed to by BC
; HL=Screen coordiante, DE=pointer to message
; If the first byte is FF then return with Carry Set, Carry Cleared otherwise.
ReadPriStruct:
        LDAX    B                       ; Get the screen LSB
        CPI     0xFF                    ; Valid?
        STC                             ; If not Carry will be Set
        RZ                              ; Return if 255
        MOV     L,A                     ; Screen LSB to L
        INX     B                       ; Next
        LDAX    B                       ; Read screen MSB
        MOV     H,A                     ; Screen MSB to H
        INX     B                       ; Next
        LDAX    B                       ; Read message LSB
        MOV     E,A                     ; Message LSB to E
        INX     B                       ; Next
        LDAX    B                       ; Read message MSB
        MOV     D,A                     ; Message MSB to D
        INX     B                       ; Next (for next print)
        ANA     A                       ; Clear Carry
        RET                             ; Done

init:
        LXI     SP,0x2400               ; Set stack pointer just below screen
        MVI     B,0x00                  ; Count 256 bytes
        CALL    CopyMirrorB             ; Copy ROM to RAM (2000-20FF)
        CALL    DefaultName             ; Set the default high-score name
        CALL    ClearAndStatus          ; Clear the screen and print scores and credits

SplashRestart:
        MVI     A,0x08                  ; Set alien ...
        STA     aShotReloadRate         ; ... shot reload rate
        JMP     SplashLoop              ; Top of splash screen loop

; Get player-alive flag for OTHER player
L_16A5:
        LDA     playerDataMSB           ; Player data MSB
        LXI     H,player1Alive          ; Alive flags (player 1 and 2)
        RRC                             ; Bit 1=1 for player 1
        RNC                             ; Player 2 ... we have it ... out
        INX     H                       ; Player 1's flag
        RET                             ; Done

; If there is one alien left then the right motion is 3 instead of 2. That's
; why the timing is hard to hit after the change.
L_16AF:
        MVI     B,0x02                  ; Rack moving right delta X
        LDA     numAliens               ; Number of aliens on screen
        DCR     A                       ; Just one left?
        RNZ                             ; No ... use right delta X of 2
        INR     B                       ; Just one alien ... move right at 3 instead of 2
        RET                             ; Done

; Add in bit for sound
SoundBits3On:
        LDA     soundPort3              ; Current value of sound port
        ORA     B                       ; Add in new sounds
        STA     soundPort3              ; New value of sound port
        OUT     SOUND1                  ; Write new value to sound hardware
        RET                             ; Done

InitAliensP2:
        LXI     H,0x2200                ; Player 2 data area
        JMP     InitAliensHL            ; Initialize player 2 aliens

PlyrShotAndBump:
        CALL    PlayerShotHit           ; Player's shot collision detection
        JMP     RackBump                ; Change alien deltaX and deltaY when rack bumps edges

; Get the current player's alive status
CurPlyAlive:
        LXI     H,player1Alive          ; Alive flags
        LDA     playerDataMSB           ; Player 1 or 2
        RRC                             ; Will be 1 if player 1
        RC                              ; Return if player 1
        INX     H                       ; Bump to player 2
        RET                             ; Return

; Print score header " SCORE<1> HI-SCORE SCORE<2> "
DrawScoreHead:
        MVI     C,0x1C                  ; 28 bytes in message
        LXI     H,0x241E                ; Screen coordinates
        LXI     D,MessageScore          ; Score header message (1862)
        JMP     PrintMessage            ; Print score header

DrawScoreP1:
        LXI     H,P1ScorL               ; Player 1 score descriptor
        JMP     DrawScore               ; Print score

DrawScoreP2:
        LXI     H,P2ScorL               ; Player 2 score descriptor
        JMP     DrawScore               ; Print score

; Print score.
; HL = descriptor
DrawScore:
        MOV     E,M                     ; Get score LSB
        INX     H                       ; Next
        MOV     D,M                     ; Get score MSB
        INX     H                       ; Next
        MOV     A,M                     ; Get coordinate LSB
        INX     H                       ; Next
        MOV     H,M                     ; Get coordiante MSB
        MOV     L,A                     ; Set LSB
        JMP     Print4Digits0           ; Print the score (4 digits plus a 0)

DrawCreditLabel:
        MVI     C,0x07                  ; 7 bytes in message
        LXI     H,0x3501                ; Screen coordinates
        LXI     D,MessageCredit         ; Message = "CREDIT "
        JMP     PrintMessage            ; Print message

; Display number of credits on screen
DrawNumCredits:
        LDA     numCoins                ; Number of credits
        LXI     H,0x3C01                ; Screen coordinates
        ADI     0x1C                    ; Digit character (only 0-9 credits now)
        JMP     DrawChar                ; Print it

PrintHiScore:
        LXI     H,HiScorL               ; Hi-score descriptor
        JMP     DrawScore               ; Print it

ClearAndStatus:
        CALL    ClearScreen             ; Clear the screen

DrawScores:
        CALL    DrawScoreHead           ; Print score header

DrawStatus:
        CALL    DrawScoreP1             ; Print player 1 score
        CALL    DrawScoreP2             ; Print player 2 score
        CALL    PrintHiScore            ; Print hi score
        CALL    CenterHiName            ; Center the high-score name
        CALL    PrintHiName             ; Print it
        CALL    DrawCreditLabel         ; Print credit lable
        JMP     DrawNumCredits          ; Number of credits
L_1731:
        CALL    SoundBits3Off           ; From 1537 with B=FB. Turn off player shot sound
        JMP     L_1457                  ; Update high-score if player's score is greater

AliensInvade:
        MVI     A,0x01                  ; Set flag that ...
        STA     invaded                 ; ... aliens reached bottom of screen
        JMP     PlayerHit               ; End of round
        DB      0xF1,0xD5,0xD6,0xD0,0xDB,0xC8,0xD9,0xD6,0xD7,0xD9,0xD6,0xCA,0xE3
D_174C:
        DB      0xD6,0xDB,0xD0
        DB      0xC8,0xDB,0xF1

; Enable ISR game tasks
EnableGameTasks:
        MVI     A,0x01                  ; Set ISR ...
L_1754:
        STA     suspendPlay             ; ... game tasks enabled
        RET                             ; Done

; Disable ISR game tasks
; Clear 20E9 flag
DsableGameTasks:
        XRA     A                       ; Clear ISR game tasks flag
        JMP     L_1754                  ; Save a byte (the RET)

; Turn off bit in sound port
SoundBits3Off:
        LDA     soundPort3              ; Current sound effects value
        ANA     B                       ; Mask bits off
        STA     soundPort3              ; Store new hold value
        OUT     SOUND1                  ; Change sounds
        RET                             ; Done

; Show ships remaining in hold for the player
DrawNumShips:
        LXI     H,0x2701                ; Screen coordinates
        JZ      L_177A                  ; None in reserve ... skip display

; Draw line of ships
L_176C:
        LXI     D,PlayerSprite          ; Player sprite
        MVI     B,0x10                  ; 16 rows
        MOV     C,A                     ; Hold count
        CALL    DrawSimpSprite          ; Display 1byte sprite to screen
        MOV     A,C                     ; Restore remaining
        DCR     A                       ; All done?
        JNZ     L_176C                  ; No ... keep going

; Clear remainder of line
L_177A:
        MVI     B,0x10                  ; 16 rows
        CALL    ClearSmallSprite        ; Clear 1byte sprite at HL
        MOV     A,H                     ; Get Y coordinate
        CPI     0x35                    ; At edge?
        JNZ     L_177A                  ; No ... do all
        RET                             ; Out

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
CompYToBeam:
        LXI     H,vblankStatus          ; Get the ...
        MOV     B,M                     ; ... beam position status
        LDAX    D                       ; Get the task structure flag
        ANI     0x80                    ; Only upper bits count
        XRA     B                       ; XOR them together
        RNZ                             ; Not the same (CF cleared)
        STC                             ; Set the CF if the same
        RET                             ; Done

; Alien delay lists. First list is the number of aliens. The second list is the corresponding delay.
; This delay is only for the rate of change in the fleet's sound.
; The check takes the first num-aliens-value that is lower or the same as the actual num-aliens on screen.
;
; The game starts with 55 aliens. The aliens are move/drawn one per interrupt which means it
; takes 55 interrupts. The first delay value is 52 ... which is almost in sync with the number
; of aliens. It is a tad faster and you can observe the sound and steps getting out of sync.
;
D_1791:
        DB      0x32,0x2B,0x24,0x1C,0x16,0x11,0x0D,0x0A,0x08,0x07,0x06,0x05,0x04,0x03,0x02,0x01
D_17A1:
        DB      0x34,0x2E,0x27,0x22,0x1C,0x18,0x15,0x13,0x10,0x0E,0x0D,0x0C,0x0B,0x09,0x07,0x05
        DB      0xFF                    ; ** Needless terminator. The list value "1" catches everything.

; Copy from [DE] to [HL] (b bytes)
BlockCopy:
        LDAX    D                       ; Copy from [DE] to ...
        MOV     M,A                     ; ... [HL]
        INX     H                       ; Next destination
        INX     D                       ; Next source
        DCR     B                       ; Count in B
        JNZ     BlockCopy               ; Do all
        RET                             ; Done

; Load 5 bytes sprite descriptor from [HL]
ReadDesc:
        MOV     E,M                     ; Descriptor ...
        INX     H                       ; ... sprite ...
        MOV     D,M                     ; ...
        INX     H                       ; ... picture
        MOV     A,M                     ; Descriptor ...
        INX     H                       ; ... screen ...
        MOV     C,M                     ; ...
        INX     H                       ; ... location
        MOV     B,M                     ; Number of bytes in sprite
        MOV     H,C                     ; From A,C to ...
        MOV     L,A                     ; ... H,L
        RET                             ; Done

; The screen is organized as one-bit-per-pixel.
; In: HL contains pixel number (bbbbbbbbbbbbbppp)
; Convert from pixel number to screen coordinates (without shift)
; Shift HL right 3 bits (clearing the top 2 bits)
; and set the third bit from the left.
ConvToScr:
        PUSH    B                       ; Hold B (will mangle)
        MVI     B,0x03                  ; 3 shifts (divide by 8)
L_17CA:
        MOV     A,H                     ; H to A
        RAR                             ; Shift right (into carry, from doesn't matter)
        MOV     H,A                     ; Back to H
        MOV     A,L                     ; L to A
        RAR                             ; Shift right (from/to carry)
        MOV     L,A                     ; Back to L
        DCR     B                       ; Do all ...
        JNZ     L_17CA                  ; ... 3 shifts
        MOV     A,H                     ; H to A
        ANI     0x3F                    ; Mask off all but screen (less than or equal 3F)
        ORI     0x20                    ; Offset into RAM
        MOV     H,A                     ; Back to H
        POP     B                       ; Restore B
        RET                             ; Done

ClearScreen:
        LXI     H,0x2400                ; Screen coordinate
L_17DF:
        MVI     M,0x00                  ; Clear it
        INX     H                       ; Next byte
        MOV     A,H                     ; Have we done ...
        CPI     0x40                    ; ... all the screen?
        JNZ     L_17DF                  ; No ... keep going
        RET                             ; Out

; Logically OR the player's shields back onto the playfield
; DE = sprite
; HL = screen
; C = bytes per row
; B = number of rows
RestoreShields:
        PUSH    B                       ; Preserve BC
        PUSH    H                       ; Hold for a bit
L_17EB:
        LDAX    D                       ; From sprite
        ORA     M                       ; OR with screen
        MOV     M,A                     ; Back to screen
        INX     D                       ; Next sprite
        INX     H                       ; Next on screen
        DCR     C                       ; Row done?
        JNZ     L_17EB                  ; No ... do entire row
        POP     H                       ; Original start
        LXI     B,0x0020                ; Bump HL by ...
        DAD     B                       ; ... one screen row
        POP     B                       ; Restore
        DCR     B                       ; Row counter
        JNZ     RestoreShields          ; Do all rows
        RET                             ; Done

; Remove a ship from the players stash and update the
; hold indicators on the screen.
RemoveShip:
        CALL    GetNumShips             ; Get last byte from player data
        ANA     A                       ; Is it 0?
        RZ                              ; Skip
        PUSH    PSW                     ; Preserve number remaining
        DCR     A                       ; Remove a ship from the stash
        MOV     M,A                     ; New number of ships
        CALL    DrawNumShips            ; Draw the line of ships
        POP     PSW                     ; Restore number
L_180B:
        LXI     H,0x2501                ; Screen coordinates
        ANI     0x0F                    ; Make sure it is a digit
        JMP     DrawDigit               ; Print number remaining

;======================================================================
; Data (Part II squeezes new code in between the tables)
;======================================================================

        DB      0x00,0x00
        DB      0xFF,0xB8,0xFE,0x21,0x1C,0x10,0x9E,0x00,0x21,0x1C

; The tables at 1CBA and 181F control how fast shots are created. The speed is based
; on the upper byte of the player's score. For a score of less than or equal 0200 then
; the fire speed is 30. For a score less than or equal 1000 the shot speed is 10. Less
; than or equal 2000 the speed is 0B. Less than or equal 3000 is 08. And anything
; above 3000 is 07.
;
; 1CBA: 02 10 20 30
;
ShotReloadRate:
        DB      0x30,0x10,0x0B,0x08
        DB      0x07                    ; Fastest shot firing speed

MessageGOver:
        DB      0x06,0x00,0x0C,0x04,0x1B,0x0E,0x15,0x04,0x11,0x1B,0x1B,0x0F; "GAME OVER  P"
        DB      0x0B,0x00,0x18,0x04,0x11,0x26,0x1B,0x27; "LAYER< >"

MessageB1or2:
        DB      0x1D,0x1B,0x0E,0x11,0x1B,0x1E,0x0F,0x0B,0x00,0x18,0x04,0x11; "1 OR 2PLAYER"
        DB      0x12,0x1B,0x01,0x14,0x13,0x13,0x0E,0x0D; "S BUTTON"

Message1Only:
        DB      0x1B                    ; " ONLY 1PLAYE"
D_184D:
        DB      0x0E,0x0D,0x0B,0x18,0x1B,0x1D,0x0F,0x0B,0x00,0x18,0x04
        DB      0x11,0x1B,0x1B,0x01,0x14,0x13,0x13,0x0E,0x0D,0x1B; "R  BUTTON "

MessageScore:
        DB      0x1B,0x12,0x02,0x0E,0x11,0x04,0x2B,0x1D,0x1B,0x1B,0x1B,0x1B; " SCORE-1    "
        DB      0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x12,0x02,0x0E,0x11; "        SCOR"
        DB      0x04,0x2B,0x1E,0x1B     ; "E-2 "

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
SpriteSaucerFlash:
        DB      0x00,0x00,0x00,0x00,0x0C,0x14,0x1C,0x16,0x3E,0x76,0xDE,0xF6,0xDE,0x76,0x3E,0x16,0x1C,0x14,0x0C,0x00,0x00,0x00,0x00,0x00

;======================================================================
; Part II: End-of-Rack Intermission
;======================================================================


; Part II: after every rack the last alien that was shot escapes in a little saucer.
; It zig-zags up the screen calling "SOS !!". If both saucers of the rack were hit
; (20BB) the saucer stops part way with "ENGINE TROUBLE" and then carries on.
; The ISR (IntermissionISR) does the moving and drawing while 20D0 is set.
Intermission:
        CALL    DsableGameTasks         ; Stop the game tasks
        CALL    ClearPlayField          ; Clear the playfield
        LXI     H,AlienSprA             ; Octopus picture
        LXI     D,0x0010                ; 16 bytes per alien picture
        LDA     lastAlienType           ; Type of the last alien shot
        CPI     0x01                    ; Octopus?
        JZ      L_18B7                  ; Yes ... use it
        DAD     D                       ; Next picture (crab)
        CPI     0x03                    ; Crab?
        JZ      L_18B7                  ; Yes ... use it
        DAD     D                       ; Next picture (squid)
        CPI     0x05                    ; Squid?
        JZ      L_18B7                  ; Yes ... use it
        DAD     D                       ; Otherwise the small alien
L_18B7:
        SHLD    sosAlienPicL            ; Alien riding in the saucer
        LXI     H,sosStage              ; Intermission variables
        LXI     D,D_1BD1                ; Initial values
        MVI     B,0x0C                  ; 12 bytes
        CALL    BlockCopy               ; Initialize them
        LHLD    alienPosLSB             ; Start where the last alien was
        SHLD    sosPosL                 ; Saucer position
        LXI     H,0x0101                ; Move 1,1
        SHLD    sosDeltaX               ; Deltas
        MVI     A,0x01                  ; Start ...
        STA     sosActive               ; ... the ISR animation
L_18D6:
        LDA     sosPosL                 ; Has the saucer ...
        CPI     0xD0                    ; ... left the screen?
        JNC     L_190E                  ; Yes ... intermission over
        OUT     WATCHDOG                ; Feed watchdog
        LDA     sosResume               ; Already had the engine trouble stop?
        ANA     A                       ; Set flags
        JNZ     L_18D6                  ; Yes ... just wait for it to fly off
        LDA     sosStage                ; Has the ...
        ANA     A                       ; ... saucer stopped (engine trouble)?
        JZ      L_18D6                  ; No ... wait
        XRA     A                       ; Stop ...
        STA     sosActive               ; ... ISR animation
        CALL    OneSecDelay             ; Wait
        LXI     H,0x2810                ; Screen coordinates
        MVI     C,0x0E                  ; 14 characters
        LXI     D,D_1A16                ; "ENGINE TROUBLE"
        CALL    PrintMessageDel         ; Print it
        CALL    OneSecDelay             ; Wait
        MVI     A,0x01                  ; Restart ...
        STA     sosActive               ; ... the animation
        STA     sosResume               ; ... and let it fly off
        JMP     L_18D6                  ; Wait for it to leave
L_190E:
        CALL    SaucerSndOff            ; Saucer sound off
        XRA     A                       ; Stop ...
        STA     sosActive               ; ... the animation
        CALL    ClearPlayField          ; Clear the playfield
        JMP     OneSecDelay             ; Wait and out

; Pulse the saucer sound on and off.
SosSound:
        LXI     H,sosBlink              ; Count ...
        DCR     M                       ; ... down
        MOV     A,M                     ; Get count
        ANI     0x02                    ; Every other 2 ticks ...
        JZ      SaucerSndOff            ; ... sound off
        JMP     SaucerSndOn             ; ... sound on
D_1928:
        DB      0x12,0x0E,0x12,0x1B,0x2D; "SOS |"

; Part II: called at the end of every interrupt (both halves). In attract mode it runs
; the protection checks. While 20D0 is set it moves and draws the intermission saucer.
IntermissionISR:
        LDA     gameMode                ; Game running?
        ANA     A                       ; Set flags
        CZ      ProtChecks              ; No ... hardware and copyright checks
        LDA     sosActive               ; Intermission running?
        ANA     A                       ; Set flags
        RZ                              ; No ... out
        LXI     D,sosPosM               ; Saucer's position (for the beam compare)
        JMP     SosBeamChk              ; Draw it on the correct half of the screen

SosBeamSide:
        CPI     0x22                    ; Player 2 (cocktail) ...
        JNZ     L_194B                  ; No ... normal

SosBeamNorm:
        CALL    CompYToBeam             ; Compare to beam position
        RNC                             ; Not this half ... out
        JMP     L_194F                  ; Move it
L_194B:
        CALL    CompYToBeam             ; Compare to beam position
        RC                              ; Not this half ... out
L_194F:
        LDA     flashSaucer             ; Were both saucers hit this rack?
        ANA     A                       ; Set flags
        JNZ     SosEngineTrouble        ; Yes ... engine trouble version
L_1956:
        CALL    SosSound                ; Pulse the sound
        LDA     sosPosM                 ; Saucer's position
        CPI     0xB0                    ; At the right side?
        CNC     PrintSOS                ; Yes ... print "SOS !!" and bounce
        CPI     0x50                    ; At the left side?
        CC      PrintSOSL               ; Yes ... print "SOS !!" and bounce
        LXI     H,sosPosL               ; Saucer descriptor
        CALL    ReadDesc                ; Read it
        XCHG                            ; Position to HL, picture to DE
        PUSH    H                       ; Hold position
        CALL    DrawSprite              ; Draw the saucer
        LHLD    sosAlienPicL            ; Alien's picture
        XCHG                            ; To DE
        LXI     B,0x0708                ; Offset inside ...
        POP     H                       ; Restore position
        DAD     B                       ; ... the saucer
        MVI     B,0x10                  ; 16 rows
        CALL    DrawSprOr               ; OR the alien into the saucer
        LXI     H,sosWobble             ; Wobble ...
        DCR     M                       ; ... counter
        MOV     A,M                     ; Get it
        ANI     0x01                    ; Every other move ...
        JNZ     L_1994                  ; ... no sideways step
        INR     A                       ; Sideways ...
        STA     sosDeltaX               ; ... step of 1
L_198D:
        LXI     H,sosDeltaX             ; Move ...
        MOV     C,M                     ; ... the ...
        JMP     AddDelta                ; ... saucer and out
L_1994:
        XRA     A                       ; No ...
        STA     sosDeltaX               ; ... sideways step
        JMP     L_198D                  ; Move it

PrintSOSL:
        MVI     A,0x01                  ; Move ...
        STA     sosDeltaY               ; ... the other way
        PUSH    PSW                     ; Hold
        JMP     L_19AA                  ; Print "SOS !!"

PrintSOS:
        PUSH    PSW                     ; Hold
        MVI     A,0xFF                  ; Move ...
        STA     sosDeltaY               ; ... the other way
L_19AA:
        LHLD    sosPosL                 ; Saucer's height ...
        MVI     H,0xD0                  ; ... at the right edge column
        LXI     D,D_1928                ; "SOS !!"
        MVI     C,0x05                  ; 5 characters
        CALL    ConvToScr               ; Screen address
        CALL    PrintMessage            ; Print it
        POP     PSW                     ; Restore
        RET                             ; Done

SosEngineTrouble:
        LDA     sosPosL                 ; Saucer height
        CPI     0x98                    ; High enough to stop?
        JNC     L_19C7                  ; Yes
        JMP     L_1956                  ; No ... keep flying
L_19C7:
        LDA     sosStage                ; Already stopped?
        ANA     A                       ; Set flags
        JNZ     L_19E9                  ; Yes ... just animate
        LHLD    sosPosL                 ; Saucer position
        LXI     B,0x0708                ; Move to where ...
        DAD     B                       ; ... the alien sits
        SHLD    sosPosL                 ; New position
        LHLD    sosAlienPicL            ; The alien gets out ...
        SHLD    sosPicL                 ; ... (draw only the alien)
        LXI     H,sosSize               ; Picture ...
        MVI     M,0x10                  ; ... size 16
        LXI     H,0x0001                ; Deltas ...
        SHLD    sosDeltaX               ; ... 1,0
L_19E9:
        LXI     H,sosBlink              ; Count ...
        DCR     M                       ; ... down
        MOV     A,M                     ; Get count
        ANI     0x01                    ; Every other tick ...
        JNZ     L_19F6                  ; ... no move
        CALL    L_198D                  ; Move
L_19F6:
        MVI     A,0x01                  ; Flag ...
        STA     sosStage                ; ... stopped (main code prints ENGINE TROUBLE)
        LXI     H,sosPosL               ; Descriptor
        CALL    ReadDesc                ; Read it
        XCHG                            ; Position to HL, picture to DE
        PUSH    H                       ; Hold position
        LXI     H,sosAnim               ; Animate ...
        DCR     M                       ; ... the alien ...
        MOV     A,M                     ; Get count
        ANI     0x04                    ; ... every 4 ticks
        CZ      L_1A11                  ; Use the frame-1 picture
        POP     H                       ; Restore position
        JMP     DrawSprite              ; Draw it and out
L_1A11:
        MVI     A,0x40                  ; Frame-1 picture ...
        ADD     E                       ; ... is 40 bytes on
        MOV     E,A                     ; To DE
        RET                             ; Done
D_1A16:
        DB      0x04,0x0D,0x06,0x08,0x0D,0x04,0x1B,0x13,0x11,0x0E,0x14,0x01; "ENGINE TROUB"
        DB      0x0B,0x04               ; "LE"

; DE = picture of character A (5 bytes per character, font at 1E21).
CharPtr:
        LXI     D,Characters            ; Font (character 0 is "A")
        ANA     A                       ; Character 0?
        RZ                              ; Yes ... done
        PUSH    H                       ; Hold
        LXI     H,0x0000                ; Offset ...
        PUSH    B                       ; Hold
L_1A2E:
        LXI     B,0x0005                ; 5 bytes ...
        DAD     B                       ; ... per character
        DCR     A                       ; All counted?
        JNZ     L_1A2E                  ; No ... keep adding
        DAD     D                       ; Add the font base
        XCHG                            ; Pointer to DE
        POP     B                       ; Restore ...
        POP     H                       ; ... registers
        RET                             ; Done
        DB      0x21,0x00,0x24,0x11,0x50

SosBeamChk:
        IN      INP2                    ; DIP: upright or cocktail?
        ANI     0x02                    ; Bit 1
        JNZ     SosBeamNorm             ; (normal compare)
        LDA     playerDataMSB           ; Player 2's turn in a cocktail ...
        JMP     SosBeamSide             ; ... flips the screen
        DB      0x09,0x44,0x42          ; \tDB

; Part II tilt: stop the intermission and all sounds then reset the stack.
TiltPart2:
        STA     sosActive               ; A=0 ... stop the intermission
        OUT     SOUND1                  ; All sound ...
        OUT     SOUND2                  ; ... off
        STA     soundPort5              ; Remember it
        LXI     SP,0x2400               ; Reset stack
        JMP     L_1602                  ; Continue with the original tilt code

;======================================================================
; More Data
;======================================================================

        DB      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        DB      0x37,0x30,0x48,0x2C,0x30,0x44,0x43,0x48,0x0D,0x0A,0x09,0x44,0x42,0x09,0x30,0x44; 70H,0DCH\r\n\tDB\t0D

; This table decides which column a shot will fall from. The column number is read from the
; table (1-11) and the pointer increases for the shot type. For instance, the "squiggly" shot
; will fall from columns in this order: 0B, 01, 06, 03. If you play the game you'll see that
; order.
;
; The "plunger" shot uses index 00-0F (inclusive)
; The "squiggly" shot uses index 06-14 (inclusive)
; The "rolling" shot targets the player
; (Part II moved the table from 1D00 to 1A80.)
ColFireTable:
        DB      0x01,0x07,0x01,0x01,0x01,0x04,0x0B,0x01,0x06,0x03,0x01,0x01,0x0B,0x09,0x02,0x08
        DB      0x02,0x0B,0x04,0x07,0x0A

;
; This appears to be part of the column-firing table, but it is never used.
; Perhaps this was originally intended for the "rolling" shot but then the
; "rolling" was change to target the player specifically.
        DB      0x05,0x02,0x05,0x04,0x06,0x07,0x08,0x0A,0x06,0x0A,0x03

; Draw a shifted sprite ORed onto the screen (HL=pixel number, DE=picture, B=rows).
DrawSprOr:
        CALL    CnvtPixNumber           ; Convert pixel number to screen/shift
L_1AA3:
        PUSH    B                       ; Hold count
        PUSH    H                       ; Hold screen position
        LDAX    D                       ; Picture byte
        OUT     SHFT_DATA               ; To shift register
        IN      SHFT_IN                 ; Shifted
        ORA     M                       ; OR with screen
        MOV     M,A                     ; Store
        INX     H                       ; Next byte on screen
        INX     D                       ; Next picture byte
        XRA     A                       ; Shift in ...
        OUT     SHFT_DATA               ; ... zero
        IN      SHFT_IN                 ; Remainder
        MOV     M,A                     ; Store
        POP     H                       ; Restore screen position
        LXI     B,0x0020                ; Next ...
        DAD     B                       ; ... row
        POP     B                       ; Restore count
        DCR     B                       ; All rows?
        JNZ     L_1AA3                  ; No ... do them all
        RET                             ; Done

; (1=Right, 2=Left)
DemoCommands:
        DB      0x01,0x01,0x00,0x00,0x01,0x00,0x02,0x01,0x00,0x02,0x01,0x00

; "*SCORE ADVANCE TABLE*"
MessageAdv:
        DB      0x29,0x12,0x02,0x0E,0x11,0x04,0x1B,0x00,0x03,0x15,0x00,0x0D; "*SCORE ADVAN"
        DB      0x02,0x04,0x1B,0x13,0x00,0x01,0x0B,0x04,0x29; "CE TABLE*"

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
AlienSplitExp:
        DB      0x00,0x00,0x00,0x00,0x31,0x7A,0xDC,0xF4,0xF4,0xDC,0x7A,0x31,0x3A,0x4C,0x3A,0x31
        DB      0x7A,0xDC,0xF4,0xF4,0xDC,0x7A,0x31,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

;-------------------------- RAM initialization -----------------------------
; Coppied to RAM (2000) C0 bytes as initialization.
; See the description of RAM at the top of this file for the details on this data.
D_1B00:
        DB      0x01,0x00,0x00,0x10,0x00,0x00,0x00,0x00,0x02,0x78,0x38,0x78,0x38,0x00,0xF8,0x00
D_1B10:
        DB      0x00,0x80,0x00,0xD4,0x02,0xFF,0x05,0x0C,0x81,0x1C,0x20,0x30,0x10,0x01,0x00,0x00
        DB      0x00,0x00,0x00,0x00,0x04
D_1B25:
        DB      0x00,0x10,0xB1,0x1C,0x28,0x30,0x01,0x04,0x00,0xFF,0xFF
D_1B30:
        DB      0x00,0x00
D_1B32:
        DB      0x02,0xC3,0x04,0x00,0x00,0x00,0x00,0x00,0x04,0xF0,0x1C,0x00,0x00,0x03
D_1B40:
        DB      0x00,0x00,0x00,0x03,0x05,0x00,0x00,0x01
D_1B48:
        DB      0x80,0x1A,0x04,0xE4,0x1C,0x00,0x00,0x03
D_1B50:
        DB      0x00,0x00,0x00,0xD9,0x06,0x00,0x00,0x01
D_1B58:
        DB      0x86,0x1A,0x04,0xD2,0x1C,0x00,0x00,0x03
        DB      0xFF,0x00,0xC2,0x1C,0x00,0x00,0x10,0x21,0x01,0x00,0x30,0x00,0x12,0x00,0x00,0x00

; These don't need to be copied over to RAM (see 1BA0 below).
; "PLAY PLAYER<1>"
MesssageP1:
        DB      0x0F,0x0B,0x00,0x18,0x1B,0x0F,0x0B,0x00,0x18,0x04
        DB      0x11,0x26,0x1D,0x27,0xFC
        DB      0x00
        DB      0x01,0xFF,0xFF
D_1B83:
        DB      0x00,0x00,0x00,0x20,0x60,0x1D,0xD0,0x29,0x18,0x02,0x50,0x1D,0x00
        DB      0x08,0x00,0x06,0x00,0x00,0x01,0x40,0x00,0x01,0x00,0x00,0x10,0x9E,0x00,0x21,0x1C

; Part II uses these 32 bytes: they are no longer "extra".
; Part II additions to the RAM mirror (copied to 20A0-20BF):
;   20A0-20AD saucer-drop variables (falling squid at Y=C8 stepping -2, picture 1C25, 8 bytes)
;   20AF=1 (score table on), 20B5=2 (default number of bonus beam fans)
D_1BA0:
        DB      0x00,0x00,0xFE,0x00,0xC8,0x00,0x25,0x1C,0x08,0x00,0x00,0x00,0x00,0x00,0x00,0x01
        DB      0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

;--------------------------- End of initialization copy -------------------------
; Copied to 20C0-20FF only at power-up (init copies 256 bytes):
;   20C1=10, 20D1-20DC intermission (picture 1CFC, size 1D), 20E1=FF, 20E2=1 (tamper flag),
;   20E3=1 (hardware flag), 20E9=1, 20EC=1, 20ED=1ABF (demo commands), 20F4=0500 high score
;   (shown as 05000) at 2F1C, player scores at 261C and 391C.
        DB      0x00,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        DB      0x00
D_1BD1:
        DB      0x00,0x00,0x00,0x00,0x00,0xFC,0x1C,0x1D,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        DB      0x00,0xFF,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x01,0xBF,0x1A,0x00
        DB      0x78,0x00,0x00,0x00,0x00,0x05,0x1C,0x2F,0x00,0x00,0x1C,0x26,0x00,0x00,0x1C,0x39
        DB      0x00

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
AlienSprA:
        DB      0x00,0x00,0x39,0x79,0x7A,0x6E,0xEC,0xFA,0xFA,0xEC,0x6E,0x7A,0x79,0x39,0x00,0x00
        DB      0x00,0x00,0x00,0x78,0x1D,0xBE,0x6C,0x3C,0x3C,0x3C,0x6C,0xBE,0x1D,0x78,0x00,0x00
        DB      0x00,0x00,0x00,0x00,0x19,0x3A,0x6D,0xFA,0xFA,0x6D,0x3A,0x19,0x00,0x00,0x00,0x00
AlienSprB:
        DB      0x00,0x00,0x00,0x00,0x30,0x7A,0xDD,0xF4,0xF4,0xDD,0x7A,0x30,0x00,0x00,0x00,0x00
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
        DB      0x00,0x00,0x38,0x7A,0x7F,0x6D,0xEC,0xFA,0xFA,0xEC,0x6D,0x7F,0x7A,0x38,0x00,0x00
        DB      0x00,0x00,0x00,0x0E,0x18,0xBE,0x6D,0x3D,0x3C,0x3D,0x6D,0xBE,0x18,0x0E,0x00,0x00
        DB      0x00,0x00,0x00,0x00,0x1A,0x3D,0x68,0xFC,0xFC,0x68,0x3D,0x1A,0x00,0x00,0x00,0x00
        DB      0x00,0x00,0x00,0x00,0x00,0x10,0x2A,0x7C,0x7C,0x2A,0x10,0x00,0x00,0x00,0x00,0x00

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
PlayerSprite:
        DB      0x00,0x00,0x0F,0x1F,0x1F,0x1F,0x1F,0x7F,0xFF,0x7F,0x1F,0x1F,0x1F,0x1F,0x0F,0x00

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
PlrBlowupSprites:
        DB      0x00,0x04,0x01,0x13,0x03,0x07,0xB3,0x0F,0x2F,0x03,0x2F,0x49,0x04,0x03,0x00,0x01

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
        DB      0x40,0x08,0x05,0xA3,0x0A,0x03,0x5B,0x0F,0x27,0x27,0x0B,0x4B,0x40,0x84,0x11,0x48

PlayerShotSpr:
        DB      0x0F                    ; ++++....

; *..**..*
; ..****..
; .******.
; *.****..
; ..****.*
; .*****..
; ..*****.
; *..**..*
ShotExploding:
        DB      0x99,0x3C,0x7E,0x3D,0xBC,0x3E,0x7C,0x99

; The tables at 1CBA and 181F control how fast shots are created. The speed is based
; on the upper byte of the player's score. For a score of less than or equal 0200 then
; the fire speed is 30. For a score less than or equal 1000 the shot speed is 10. Less
; than or equal 2000 the speed is 0B. Less than or equal 3000 is 08. And anything
; above 3000 is 07.
;
; 181F: 30 10 0B 08
; 1823: 07           ; Fastest shot firing speed
;
AReloadScoreTab:
        DB      0x02,0x10,0x20,0x30

MessageTilt:
        DB      0x13,0x08,0x0B,0x13     ; "TILT"

; Alien exploding sprite
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
AlienExplode:
        DB      0x00,0x08,0x49,0x22,0x14,0x81,0x42,0x00,0x42,0x81,0x14,0x22,0x49,0x08,0x00,0x00

; Squigly shot picture in 4 animation frames
SquiglyShot:
        DB      0x44                    ; ..*...*.
        DB      0xAA                    ; .*.*.*.*
        DB      0x10                    ; ....*...
        DB      0x88                    ; ...*...*
        DB      0x54                    ; ..*.*.*.
        DB      0x22                    ; .*...*..
        DB      0x10                    ; ....*...
        DB      0xAA                    ; .*.*.*.*
        DB      0x44                    ; ..*...*.
        DB      0x22                    ; .*...*..
        DB      0x54                    ; ..*.*.*.
        DB      0x88                    ; ...*...*

; Alien shot exploding
; .*.*..*.
; *.*.*...
; .*****.*
; ******..
; .****.*.
; *.*..*..
AShotExplo:
        DB      0x4A,0x15,0xBE,0x3F,0x5E,0x25

; Alien shot ... the plunger looking one
PlungerShot:
        DB      0x04                    ; ..*.....
        DB      0xFC                    ; ..******
        DB      0x04                    ; ..*.....
        DB      0x10                    ; ....*...
        DB      0xFC                    ; ..******
        DB      0x10                    ; ....*...
        DB      0x20                    ; .....*..
        DB      0xFC                    ; ..******
        DB      0x20                    ; .....*..
        DB      0x80                    ; .......*
        DB      0xFC                    ; ..******
        DB      0x80                    ; .......*

; Alien shot ... the rolling one
RollShot:
        DB      0x00                    ; ........
        DB      0xFE                    ; .*******
        DB      0x00                    ; ........
        DB      0x24                    ; ..*..*..
        DB      0xFE                    ; .*******
        DB      0x12                    ; .*..*...
        DB      0x00                    ; ........
        DB      0xFE                    ; .*******
        DB      0x00                    ; ........
        DB      0x48                    ; ...*..*.
        DB      0xFE                    ; .*******
        DB      0x90                    ; ....*..*

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
SpriteSosSaucer:
        DB      0x00,0x00,0x00,0x04,0x0C,0x0C,0x1E,0x3E,0x2E,0x6E,0x7E,0xFC,0xEC,0xEC,0xFC,0xFC
        DB      0xEC,0xEC,0xFC,0x7E,0x6E,0x2E,0x3E,0x1E,0x0C,0x0C,0x04,0x00,0x00,0x00,0x00,0x00

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
ShieldImage:
        DB      0xFF,0x0F,0xFF,0x1F,0xFF,0x3F,0xFF,0x7F,0xFF,0xFF,0xFC,0xFF,0xF8,0xFF,0xF0,0xFF,0xF0,0xFF,0xF0,0xFF,0xF0,0xFF
        DB      0xF0,0xFF,0xF0,0xFF,0xF0,0xFF,0xF8,0xFF,0xFC,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7F,0xFF,0x3F,0xFF,0x1F,0xFF,0x0F
D_1D48:
        DB      0x05,0x10,0x15,0x30
D_1D4C:
        DB      0x90,0x93,0x96,0x99

; 208D points here to the score given when the saucer is shot. It advances
; every time the player-shot is removed. The code wraps after 15, but there
; are 16 values in this table. This is a bug in the code at 044E (thanks to
; Colin Dooley for finding this).
;
; Thus the one and only 300 comes up every 15 shots (after an initial 8).
SaucerScrTab:
        DB      0x10,0x05,0x05,0x10,0x15,0x10,0x10,0x05,0x30,0x10,0x10,0x10,0x05,0x15,0x10,0x05

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
SpriteSaucer:
        DB      0x00,0x00,0x00,0x00,0x04,0x0C,0x1E,0x37,0x3E,0x7C,0x74,0x7E,0x7E,0x74,0x7C,0x3E,0x37,0x1E,0x0C,0x04,0x00,0x00,0x00,0x00

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
SpriteSaucerExp:
        DB      0x00,0x22,0x00,0xA5,0x40,0x08,0x98,0x3D,0xB6,0x3C,0x36,0x1D,0x10,0x48,0x62,0xB6,0x1D,0x98,0x08,0x42,0x90,0x08,0x00,0x00
        DB      0x1B,0x21,0x1C,0x1D,0x1C,0x1C,0x1D,0x21,0x1C,0x1F,0x1C,0x1C; " 50100150300"
D_1D9C:
        DB      0x01,0x02,0x03
D_1D9F:
        DB      0x05

; Starting Y coordinates for aliens at beginning of rounds. The first round is initialized to $78 at 08EE.
; After that this table is used for 2nd, 3rd, 4th, 5th, 6th, 7th, 8th, and 9th. The 10th starts over at
; 1DA0 (60).
AlienStartTable:
        DB      0x60
        DB      0x50
        DB      0x48
        DB      0x48
        DB      0x48
        DB      0x40
        DB      0x40
        DB      0x40
D_1DA8:
        DB      0x21,0x1C,0x1C          ; "500"

; Score table pictures: screen coordinate, picture (flashing saucer, saucer, small alien,
; squid, crab, octopus)
AdvTableSprites:
        DB      0x0E,0x2C,0x82,0x18
        DB      0x0C,0x2C,0x64,0x1D
        DB      0x0A,0x2A,0x31,0x1C
        DB      0x0A,0x2C,0x21,0x1C
        DB      0x08,0x2C,0x51,0x1C
        DB      0x06,0x2C,0x01,0x1C
        DB      0xFF

; Score table messages: screen coordinate, message
AdvTableMessages:
        DB      0x0E,0x2E,0xD9,0x1D
        DB      0x0C,0x2E,0xE4,0x1D
        DB      0x0A,0x2E,0xEF,0x1D
        DB      0x08,0x2E,0xFA,0x1D
        DB      0x06,0x2E,0x05,0x1E
        DB      0xFF

MessagePoints:
        DB      0x28,0x21,0x1C,0x1C,0x1B,0x0F,0x0E,0x08,0x0D,0x13,0x12,0x28; "=500 POINTS="
        DB      0x1B,0x2C,0x1B,0x0C,0x18,0x12,0x13,0x04,0x11,0x18,0x28,0x1B; " ? MYSTERY= "
        DB      0x1F,0x1C,0x1B,0x0F,0x0E,0x08,0x0D,0x13,0x12,0x28,0x1B,0x1E; "30 POINTS= 2"
        DB      0x1C,0x1B,0x0F,0x0E,0x08,0x0D,0x13,0x12,0x28,0x1B,0x1D,0x1C; "0 POINTS= 10"
        DB      0x1B,0x0F,0x0E,0x08,0x0D,0x13,0x12; " POINTS"

; Low byte of the formation (40xx) for rounds 0-16 (see InitAliens)
FormationTable:
        DB      0x00,0x00,0x00,0x2C,0x2C,0x84,0x84,0x58,0x58,0xB0,0xB0,0xB0,0x2C,0x58,0x58,0x84
        DB      0x84

; Part II font: 5 bytes per character (one byte per column, bit 7 at the top in this listing).
; 00-19 A-Z, 1A ".", 1B space, 1C-25 0-9, 26 "<", 27 ">", 28 "=", 29 "*", 2A cursor "_",
; 2B "-", 2C "?", 2D "!!", 2E-30 the name-entry box.
Characters:
        DB      0x1F,0x24,0x44,0x24,0x1F; A   <00>  ..... ..*.. .*.*. *...* *...* ***** *...*
        DB      0x7F,0x49,0x49,0x49,0x36; B   <01>  ..... ****. *...* *...* ****. *...* *...*
        DB      0x3E,0x41,0x41,0x41,0x22; C   <02>  ..... .***. *...* *.... *.... *.... *...*
        DB      0x7F,0x41,0x41,0x41,0x3E; D   <03>  ..... ****. *...* *...* *...* *...* *...*
        DB      0x7F,0x49,0x49,0x49,0x41; E   <04>  ..... ***** *.... *.... ****. *.... *....
        DB      0x7F,0x48,0x48,0x48,0x40; F   <05>  ..... ***** *.... *.... ****. *.... *....
        DB      0x3E,0x41,0x41,0x45,0x47; G   <06>  ..... .**** *.... *.... *.... *..** *...*
        DB      0x7F,0x08,0x08,0x08,0x7F; H   <07>  ..... *...* *...* *...* ***** *...* *...*
        DB      0x00,0x41,0x7F,0x41,0x00; I   <08>  ..... .***. ..*.. ..*.. ..*.. ..*.. ..*..
        DB      0x02,0x01,0x01,0x01,0x7E; J   <09>  ..... ....* ....* ....* ....* ....* *...*
        DB      0x7F,0x08,0x14,0x22,0x41; K   <0A>  ..... *...* *..*. *.*.. **... *.*.. *..*.
        DB      0x7F,0x01,0x01,0x01,0x01; L   <0B>  ..... *.... *.... *.... *.... *.... *....
        DB      0x7F,0x20,0x18,0x20,0x7F; M   <0C>  ..... *...* **.** *.*.* *.*.* *...* *...*
        DB      0x7F,0x10,0x08,0x04,0x7F; N   <0D>  ..... *...* *...* **..* *.*.* *..** *...*
        DB      0x3E,0x41,0x41,0x41,0x3E; O   <0E>  ..... .***. *...* *...* *...* *...* *...*
        DB      0x7F,0x48,0x48,0x48,0x30; P   <0F>  ..... ****. *...* *...* ****. *.... *....
        DB      0x3E,0x41,0x45,0x42,0x3D; Q   <10>  ..... .***. *...* *...* *...* *.*.* *..*.
        DB      0x7F,0x48,0x4C,0x4A,0x31; R   <11>  ..... ****. *...* *...* ****. *.*.. *..*.
        DB      0x32,0x49,0x49,0x49,0x26; S   <12>  ..... .***. *...* *.... .***. ....* *...*
        DB      0x40,0x40,0x7F,0x40,0x40; T   <13>  ..... ***** ..*.. ..*.. ..*.. ..*.. ..*..
        DB      0x7E,0x01,0x01,0x01,0x7E; U   <14>  ..... *...* *...* *...* *...* *...* *...*
        DB      0x7C,0x02,0x01,0x02,0x7C; V   <15>  ..... *...* *...* *...* *...* *...* .*.*.
        DB      0x7F,0x02,0x0C,0x02,0x7F; W   <16>  ..... *...* *...* *...* *.*.* *.*.* **.**
        DB      0x63,0x14,0x08,0x14,0x63; X   <17>  ..... *...* *...* .*.*. ..*.. .*.*. *...*
        DB      0x60,0x10,0x0F,0x10,0x60; Y   <18>  ..... *...* *...* .*.*. ..*.. ..*.. ..*..
        DB      0x43,0x45,0x49,0x51,0x61; Z   <19>  ..... ***** ....* ...*. ..*.. .*... *....
        DB      0x00,0x00,0x03,0x03,0x00; .   <1A>  ..... ..... ..... ..... ..... ..... ..**.
        DB      0x00,0x00,0x00,0x00,0x00; spc <1B>  ..... ..... ..... ..... ..... ..... .....
        DB      0x3E,0x45,0x49,0x51,0x3E; 0   <1C>  ..... .***. *...* *..** *.*.* **..* *...*
        DB      0x00,0x21,0x7F,0x01,0x00; 1   <1D>  ..... ..*.. .**.. ..*.. ..*.. ..*.. ..*..
        DB      0x23,0x45,0x49,0x49,0x31; 2   <1E>  ..... .***. *...* ....* ..**. .*... *....
        DB      0x42,0x41,0x49,0x59,0x66; 3   <1F>  ..... ***** ....* ...*. ..**. ....* *...*
        DB      0x0C,0x14,0x24,0x7F,0x04; 4   <20>  ..... ...*. ..**. .*.*. *..*. ***** ...*.
        DB      0x72,0x51,0x51,0x51,0x4E; 5   <21>  ..... ***** *.... ****. ....* ....* *...*
        DB      0x1E,0x29,0x49,0x49,0x46; 6   <22>  ..... ..*** .*... *.... ****. *...* *...*
        DB      0x40,0x47,0x48,0x50,0x60; 7   <23>  ..... ***** ....* ...*. ..*.. .*... .*...
        DB      0x36,0x49,0x49,0x49,0x36; 8   <24>  ..... .***. *...* *...* .***. *...* *...*
        DB      0x31,0x49,0x49,0x4A,0x3C; 9   <25>  ..... .***. *...* *...* .**** ....* ...*.
        DB      0x08,0x14,0x22,0x41,0x00; <   <26>  ..... ...*. ..*.. .*... *.... .*... ..*..
        DB      0x00,0x41,0x22,0x14,0x08; >   <27>  ..... .*... ..*.. ...*. ....* ...*. ..*..
        DB      0x14,0x14,0x14,0x14,0x14; =   <28>  ..... ..... ..... ***** ..... ***** .....
        DB      0x22,0x14,0x7F,0x14,0x22; *   <29>  ..... ..*.. *.*.* .***. ..*.. .***. *.*.*
        DB      0x18,0x18,0x18,0x18,0x18; _   <2A>  ..... ..... ..... ***** ***** ..... .....
        DB      0x08,0x08,0x08,0x08,0x08; -   <2B>  ..... ..... ..... ..... ***** ..... .....
        DB      0x20,0x40,0x4D,0x50,0x20; ?   <2C>  ..... .***. *...* ...*. ..*.. ..*.. .....
        DB      0x00,0x00,0x79,0x00,0x79; |   <2D>  ..... ..*.* ..*.* ..*.* ..*.* ..... .....
        DB      0x00,0x00,0x00,0x00,0xC0; [   <2E>  ....* ....* ..... ..... ..... ..... .....
        DB      0x40,0x40,0x40,0x40,0x40; ~   <2F>  ..... ***** ..... ..... ..... ..... .....
        DB      0xC0,0x00,0x00,0x00,0x00; ]   <30>  *.... *.... ..... ..... ..... ..... .....

; "RUB END" for the name-entry screen (40 columns)
; ........................................
; ........................................
; ........................................
; .***..*..*.***...........****.*..*.***..
; .*..*.*..*.*..*..........*....**.*.*..*.
; .***..*..*.***...........***..*.**.*..*.
; .*.*..*..*.*..*..........*....*..*.*..*.
; .*..*..**..***...........****.*..*.***..
PicRubEnd:
        DB      0x00,0x1F,0x14,0x16,0x09,0x00,0x1E,0x01,0x01,0x1E,0x00,0x1F,0x15,0x15,0x0A,0x00
        DB      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1F,0x15,0x15,0x11,0x00,0x1F,0x08
        DB      0x04,0x1F,0x00,0x1F,0x11,0x11,0x0E,0x00
D_1F3E:
        DB      0x0F,0x14,0x12,0x07     ; "PUSH"

MessageCredit:
        DB      0x02,0x11,0x04,0x03,0x08,0x13,0x1B; "CREDIT "

; A = port 1 (player 1 controls). The address of the IN instruction is built in pieces
; and reached with JP (HL) so a disassembler won't see it (1F52 is the return).
ReadPort1:
        LXI     H,L_1F52                ; Return address ...
        PUSH    H                       ; ... on the stack
        MVI     L,0xEF                  ; Build the address ...
        MVI     H,0x15                  ; ... 15EF (IN A,(01) / RET)
        PCHL                            ; Go read port 1
L_1F52:
        RET                             ; (Return point)

; Attract mode protection checks (run every interrupt while not in a game).
ProtChecks:
        CALL    HardwareCheck           ; Port 0 check
        JMP     CopyrightCheck          ; Copyright check

; Leftover 8080 assembler source text from the development system (it shows the original
; was written with Intel mnemonics and labels like EXIN1/EXIN2/EXIN3 and PU).
        DB      0x0D,0x0A,0x09,0x4A,0x4E,0x5A,0x09,0x45,0x58,0x49,0x4E,0x34,0x0D,0x0A,0x09,0x44; \r\n\tJNZ\tEXIN4\r\n\tD
        DB      0x43,0x58,0x09,0x48,0x0D,0x0A,0x09,0x4D,0x4F,0x56,0x09,0x41,0x2C,0x4D,0x0D,0x0A; CX\tH\r\n\tMOV\tA,M\r\n
        DB      0x09,0x41,0x4E,0x49,0x09,0x38,0x30,0x48,0x0D,0x0A,0x09,0x52,0x5A,0x0D,0x0A,0x45; \tANI\t80H\r\n\tRZ\r\nE
        DB      0x58,0x49,0x4E,0x31,0x3A,0x09,0x4C,0x44,0x41,0x09,0x50,0x55,0x2B,0x30,0x41,0x30; XIN1:\tLDA\tPU+0A0
        DB      0x48,0x0D,0x0A,0x09,0x41,0x4E,0x49,0x09,0x30,0x46,0x48,0x0D,0x0A,0x09,0x4D,0x4F; H\r\n\tANI\t0FH\r\n\tMO
        DB      0x56,0x09,0x42,0x2C,0x41,0x0D,0x0A,0x09,0x4C,0x44,0x41,0x09,0x50,0x55,0x2B,0x30; V\tB,A\r\n\tLDA\tPU+0
        DB      0x41,0x48,0x0D,0x0A,0x45,0x58,0x49,0x4E,0x32,0x3A,0x09,0x44,0x43,0x52,0x09,0x42; AH\r\nEXIN2:\tDCR\tB
        DB      0x0D,0x0A,0x09,0x4A,0x5A,0x09,0x45,0x58,0x49,0x4E,0x33,0x0D,0x0A,0x09,0x41,0x44; \r\n\tJZ\tEXIN3\r\n\tAD
        DB      0x49,0x09,0x31,0x30,0x48,0x0D,0x0A,0x09,0x4A,0x4D,0x50,0x09,0x45,0x58,0x49,0x4E; I\t10H\r\n\tJMP\tEXIN
        DB      0x32,0x0D,0x0A,0x3B,0x0D,0x0A,0x45,0x58,0x49,0x4E,0x33,0x3A,0x09,0x41,0x44,0x49; 2\r\n;\r\nEXIN3:\tADI
        DB      0x09,0x30,0x34,0x48,0xFF,0xFF,0x09; \t04H..\t


;======================================================================
; The Part II Expansion ROM (4000-47FF)
;======================================================================


; Part II: starting formations for the bottom four rows of aliens (4 rows of 11, bottom row
; first). 0=empty, 1=octopus, 3=crab, 5=squid, 7=small alien. InitAliens picks one with the
; table at 1E10 and always adds a top row of squids.
; Formation 0 (4000):  O=octopus C=crab S=squid s=small .=empty
;    C C C C C C C C C C C
;    C C C C C C C C C C C
;    O O O O O O O O O O O
;    O O O O O O O O O O O

        ORG     0x4000

Formations:
        DB      0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01; Row 0 (bottom)
        DB      0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01; Row 1
        DB      0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03; Row 2
        DB      0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03; Row 3
; Formation 1 (402C):  O=octopus C=crab S=squid s=small .=empty
;    S S S S S S S S S S S
;    S S . C C . C C . S S
;    O O O O C C C O O O O
;    O O O O O O O O O O O
        DB      0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01; Row 0 (bottom)
        DB      0x01,0x01,0x01,0x01,0x03,0x03,0x03,0x01,0x01,0x01,0x01; Row 1
        DB      0x05,0x05,0x00,0x03,0x03,0x00,0x03,0x03,0x00,0x05,0x05; Row 2
        DB      0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05; Row 3
; Formation 2 (4058):  O=octopus C=crab S=squid s=small .=empty
;    s s C . S S S . C s s
;    s . S . C S C . S . s
;    O O . C C C C C . O O
;    O C O O O O O O O C O
        DB      0x01,0x03,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x03,0x01; Row 0 (bottom)
        DB      0x01,0x01,0x00,0x03,0x03,0x03,0x03,0x03,0x00,0x01,0x01; Row 1
        DB      0x07,0x00,0x05,0x00,0x03,0x05,0x03,0x00,0x05,0x00,0x07; Row 2
        DB      0x07,0x07,0x03,0x00,0x05,0x05,0x05,0x00,0x03,0x07,0x07; Row 3
; Formation 3 (4084):  O=octopus C=crab S=squid s=small .=empty
;    s s s s s s s s s s s
;    S S S . C C C . S S S
;    O C C C . O . C C C O
;    O O O O O O O O O O O
        DB      0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01; Row 0 (bottom)
        DB      0x01,0x03,0x03,0x03,0x00,0x01,0x00,0x03,0x03,0x03,0x01; Row 1
        DB      0x05,0x05,0x05,0x00,0x03,0x03,0x03,0x00,0x05,0x05,0x05; Row 2
        DB      0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07; Row 3
; Formation 4 (40B0):  O=octopus C=crab S=squid s=small .=empty
;    S S S S C C C S S S S
;    S C C C C C C C C C S
;    O O C C C C C C C O O
;    O O C C C C C C C O O
        DB      0x01,0x01,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x01,0x01; Row 0 (bottom)
        DB      0x01,0x01,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x01,0x01; Row 1
        DB      0x05,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x05; Row 2
        DB      0x05,0x05,0x05,0x05,0x03,0x03,0x03,0x05,0x05,0x05,0x05; Row 3

; Part II: the big "SPACE INVADERS PART II" title. A block of dots is drawn and the
; letters are "carved" out of it a column at a time, then "PART II" is drawn below.
TitleScreen:
        LXI     H,0x2617                ; Screen position for the "SPACE" block
        LXI     D,D_41E4                ; Dot pattern
        LXI     B,0x0818                ; 8 columns of 24 bytes
        CALL    FillDots                ; Fill the block with dots
        CALL    OneSecDelay             ; Wait
        LXI     H,0x2617                ; Same position
        LXI     D,D_41EC                ; "SPACE" bitmap
        LXI     B,0x0610                ; 6 bytes by 16 columns
        CALL    CarveBitmap             ; Carve the letters out of the dots
        CALL    OneSecDelay             ; Wait
        LXI     H,0x260D                ; Screen position for the "INVADERS" block
        LXI     D,D_41E4                ; Dot pattern
        LXI     B,0x0418                ; 4 columns of 24 bytes
        CALL    FillDots                ; Fill the block with dots
        CALL    OneSecDelay             ; Wait
        LXI     H,0x260D                ; Same position
        LXI     D,D_424C                ; "INVADERS" bitmap
        LXI     B,0x0608                ; 6 bytes by 8 columns
        CALL    CarveBitmap             ; Carve it
        CALL    OneSecDelay             ; Wait
        LXI     H,0x2E06                ; Screen position for "PART II"
        LXI     D,D_427C                ; "PART II" bitmap
        LXI     B,0x3802                ; 56 rows of 2 bytes
        CALL    CopyBitmap              ; Draw it
        CALL    OneSecDelay             ; Wait
        CALL    DrawScores              ; Redraw the score lines
        CALL    FlashHiName             ; *TAITO CORPORATION* and flash the high score holder
        CALL    OneSecDelay             ; Wait
        JMP     ClearPlayField          ; Clear and out

; Copy a C-byte by B-row bitmap from DE to the screen at HL.
CopyBitmap:
        PUSH    B                       ; Hold counts
        PUSH    H                       ; Hold screen position
L_4135:
        LDAX    D                       ; Get bitmap byte
        MOV     M,A                     ; To screen
        INX     H                       ; Next screen byte
        INX     D                       ; Next bitmap byte
        DCR     C                       ; All bytes in this row?
        JNZ     L_4135                  ; No ... do them all
        POP     H                       ; Restore screen position
        LXI     B,0x0020                ; Next ...
        DAD     B                       ; ... row
        POP     B                       ; Restore counts
        DCR     B                       ; All rows?
        JNZ     CopyBitmap              ; No ... do them all
        RET                             ; Done

; For each bit of the bitmap that is 0 erase a 4-pixel wide group of dots. The erasing
; is slowed down so the letters appear to be cut out of the block.
CarveBitmap:
        PUSH    H                       ; Hold screen position
        PUSH    B                       ; Hold counts
L_414A:
        PUSH    D                       ; Hold bitmap pointer
        MVI     C,0x08                  ; 8 bits per byte
        LDAX    D                       ; Bitmap byte
L_414E:
        RRC                             ; Next bit to carry
        PUSH    PSW                     ; Hold remaining bits
        JNC     CarveGroup              ; A 0 bit ... erase this group of dots
        PUSH    B                       ; Hold counts
        MVI     C,0x04                  ; Skip ...
        LXI     D,0x0020                ; ... 4 ...
L_4159:
        DAD     D                       ; ... columns
        DCR     C                       ; ...
        JNZ     L_4159                  ; ...
L_415E:
        POP     B                       ; Restore counts
        POP     PSW                     ; Restore remaining bits
        DCR     C                       ; All 8 bits?
        JNZ     L_414E                  ; No ... next bit
        POP     D                       ; Restore bitmap pointer
        INX     D                       ; Next bitmap byte
        DCR     B                       ; All bytes in this column?
        JNZ     L_414A                  ; No ... keep going
        LXI     H,0x20B0                ; Two passes ...
        INR     M                       ; ... (the dots are offset by a byte ...
        MOV     A,M                     ; ... every other pass)
        ANI     0x02                    ; Second pass?
        JZ      L_417C                  ; No
        MVI     M,0x00                  ; Reset pass counter
        POP     B                       ; Restore counts
        POP     H                       ; Restore screen position
        DCX     H                       ; Back one byte for the next column
        JMP     L_417E                  ; Continue
L_417C:
        POP     B                       ; Restore counts
        POP     H                       ; Restore screen position
L_417E:
        DCR     C                       ; All columns?
        JNZ     CarveBitmap             ; No ... do them all
        XRA     A                       ; Clear ...
        STA     0x20B0                  ; ... pass counter
        MVI     H,0x1F                  ; Hidden test feature: build 20E3 ...
        MVI     L,0xE4                  ; ... in pieces ...
        INR     H                       ; ...
        DCR     L                       ; ...
        MOV     A,M                     ; Is the hardware-check flag still set?
        ANA     A                       ; Set flags
        RZ                              ; No ... done
        CALL    ReadPort1               ; Read the switches
        ANI     0x76                    ; Start1, Start2, fire, left, right
        CPI     0x36                    ; Start1+Start2+fire+left held?
        RNZ                             ; No ... done
        MVI     L,0xEC                  ; Build 20EB ...
        DCR     L                       ; ... (credits) ...
        MVI     H,0x1F                  ; ... in ...
        INR     H                       ; ... pieces
        MVI     M,0x02                  ; 2 credits
        MVI     L,0xCC                  ; Shadow copy ...
        MVI     M,0x02                  ; ... too
        RET                             ; Done

CarveGroup:
        PUSH    B                       ; Hold counts
        MVI     C,0x03                  ; Three bytes
        LDA     0x20B0                  ; Which pass?
        CPI     0x01                    ; Pass 1?
        JNZ     L_41C8                  ; No ... other mask
        MVI     A,0xE0                  ; Mask for pass 1
L_41B1:
        MOV     B,M                     ; Screen byte
        ANA     B                       ; Mask it
        MOV     M,A                     ; Back to screen
        LXI     D,0x0020                ; Next ...
        DAD     D                       ; ... column
        DCR     C                       ; All 3?
        JNZ     L_41B1                  ; No ... do them all
        DAD     D                       ; Skip a column
        LXI     B,0x0250                ; Short ...
        CALL    DelayBC                 ; ... delay
        OUT     WATCHDOG                ; Feed watchdog
        JMP     L_415E                  ; Continue
L_41C8:
        MVI     A,0x0E                  ; Mask for pass 2
        JMP     L_41B1                  ; Continue

; Fill a block of the screen with the 8-byte dot pattern at DE (C columns of B bytes).
FillDots:
        PUSH    H                       ; Hold screen position
        PUSH    B                       ; Hold counts
L_41CF:
        PUSH    D                       ; Hold pattern pointer
        OUT     WATCHDOG                ; Feed watchdog
        MVI     B,0x08                  ; 8 bytes in the pattern
        CALL    DrawSimpSprite          ; Draw it
        POP     D                       ; Restore pattern pointer
        DCR     C                       ; All columns?
        JNZ     L_41CF                  ; No ... do them all
        POP     B                       ; Restore counts
        POP     H                       ; Restore screen position
        DCX     H                       ; Next byte up
        DCR     B                       ; All rows?
        JNZ     FillDots                ; No ... do them all
        RET                             ; Done
D_41E4:
        DB      0xEE,0xEE,0xEE,0x00,0xEE,0xEE,0xEE,0x00
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
D_41EC:
        DB      0x1E,0xFC,0xC1,0x07,0x1E,0xFE
        DB      0x7F,0xFC,0xC3,0x07,0x3F,0xFE
        DB      0xFF,0xFC,0xE7,0x8F,0x7F,0xFE
        DB      0xFF,0xFC,0xE7,0x8F,0x7F,0xFE
        DB      0xE3,0x1C,0xF7,0x9F,0x73,0x07
        DB      0xE7,0x1C,0xF7,0x9F,0x73,0x07
        DB      0x0E,0x1C,0x77,0x9D,0x03,0x07
        DB      0x3E,0xFC,0x77,0x9D,0x03,0x1F
        DB      0xFC,0xF8,0xF3,0xDF,0x81,0x1F
        DB      0xF0,0xF9,0xC1,0xC7,0x81,0x1F
        DB      0xC0,0x39,0xE0,0xCE,0x81,0x01
        DB      0x98,0x39,0xE0,0xCE,0x9D,0x01
        DB      0x98,0x39,0x70,0xDC,0xDD,0x01
        DB      0xF8,0x39,0x70,0xDC,0xDF,0x0F
        DB      0xF0,0x39,0xE0,0x8E,0xCF,0x0F
        DB      0xE0,0x38,0xE0,0x0E,0xC7,0x0F
; ..***..**.**.*****..****.**.**...**...**..**.**.
; .**.**.**.**....**.**.**.**.**...**...**..**.**.
; .**....**.**....**.**.**.**.**..****..***.**.**.
; ..***...****..****.**.**.*****..****..******.**.
; ....**.**.**....**.**.**.**.**.**..**.******.**.
; ....**.**.**....**.**.**.**.**.**..**.**.***.**.
; .**.**.**.**....**.**.**..***..**..**.**..**.**.
; ..***...****.*****..****..***..**..**.**..**.**.
D_424C:
        DB      0x36,0x9B,0x39,0xCF,0xF7,0x38
        DB      0x36,0x9B,0x39,0xDB,0xB0,0x6D
        DB      0x76,0x9B,0x6D,0xDB,0xB0,0x0D
        DB      0xF6,0x9B,0x6D,0xDB,0xB0,0x0D
        DB      0xF6,0xF3,0x7C,0xDB,0xF3,0x38
        DB      0xB6,0xF3,0x6C,0xDB,0xB0,0x61
        DB      0x36,0x63,0x6C,0xDB,0xB0,0x6D
        DB      0x36,0x63,0x6C,0xCF,0xB7,0x39
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
D_427C:
        DB      0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xC0,0xF1,0xC0,0xF1,0xC0,0xFF,0x80,0x7F,0x00,0x3F
        DB      0x00,0x00,0x00,0x00,0xFF,0x0F,0xFF,0x3F,0xFF,0xFF,0xC0,0xF1,0xC0,0xF1,0xFF,0xFF
        DB      0xFF,0x3F,0xFF,0x0F,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xC0,0xF1
        DB      0xE0,0xF1,0xFF,0xFF,0xBF,0x7F,0x1F,0x3F,0x00,0x00,0x00,0x00,0x00,0xF0,0x00,0xF0
        DB      0x00,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0xF0,0x00,0xF0,0x00,0xF0,0x00,0x00
        DB      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0xF0,0xFF,0xFF
        DB      0xFF,0xFF,0xFF,0xFF,0x07,0xF0,0x07,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x07,0xF0

; Part II: from round 2 on the saucer refills gaps in the top row of the rack. While the
; saucer flies, the first empty slot of the top row (searching from the end it is heading
; toward) is picked. When the saucer is over that column it stops and a new alien
; drops from it down to the rack. In rounds 2 and 3 only one alien is dropped per rack.
; Runs in the mid-screen ISR. It finishes by running the other game objects itself.
SaucerDrop:
        CALL    GetRoundNum             ; Round number
        CPI     0x02                    ; Round 0 or 1?
        RC                              ; Yes ... no drops
        CPI     0x04                    ; Round 4 or more?
        JNC     L_42FC                  ; Yes ... any number of drops
        LDA     dropOnce                ; Already dropped one this rack?
        ANA     A                       ; Set flags
        RNZ                             ; Yes ... no more
L_42FC:
        LDA     dropHit                 ; Was the falling alien just shot?
        ANA     A                       ; Set flags
        RNZ                             ; Yes ... nothing more until it is cleaned up
        CALL    FindDropSlot            ; Pick an empty slot if the saucer is flying
        LXI     H,dropActive            ; Already dropping?
        MOV     A,M                     ; Get flag
        ANA     A                       ; Set flags
        JNZ     L_435E                  ; Yes ... keep it going
        DCX     H                       ; 20A0
        MOV     A,M                     ; Slot picked ...
        ANI     0x80                    ; ... (bit 7)?
        RZ                              ; No ... out
        LDA     dropColumn              ; Column (1-11) ...
        ANI     0x0F                    ; ... of the slot
        MOV     B,A                     ; To B
        LDA     refAlienXr              ; Rack's X
L_431A:
        DCR     B                       ; Count ...
        JZ      L_4323                  ; ... columns
        ADI     0x10                    ; 16 pixels per column
        JMP     L_431A                  ; Keep counting
L_4323:
        ADI     0x04                    ; Center of the slot
        STA     dropXr                  ; Falling alien's X
        SBI     0x08                    ; Back up ...
        ANI     0xFE                    ; ... (even)
        MOV     B,A                     ; To B
        LXI     H,saucerPriPicMSB       ; Saucer's X
        MOV     A,M                     ; Get it
        ANI     0xFE                    ; (even)
        CMP     B                       ; Is the saucer over the slot?
        RNZ                             ; No ... out
        LDA     refAlienYr              ; Rack Y ...
        ADI     0x40                    ; ... plus 4 rows
        STA     dropTargetY             ; Where the alien joins the rack
        LDA     alienCurIndex           ; Has the alien cursor ...
        LXI     H,dropSlotL             ; ... passed the slot?
        CMP     M                       ; Compare
        JNC     L_4359                  ; Yes
        MVI     B,0x02                  ; Adjust X ...
        LDA     rackDirection           ; ... for the rack's ...
        ANA     A                       ; ... direction ...
        JNZ     L_4352                  ; ... of motion
        MVI     B,0xFE                  ; ... left
L_4352:
        LDA     dropXr                  ; Adjust ...
        ADD     B                       ; ... the ...
        STA     dropXr                  ; ... X
L_4359:
        MVI     A,0x01                  ; Start ...
        STA     dropActive              ; ... the drop
L_435E:
        LXI     H,dropYr                ; Falling-alien descriptor (20A4)
        CALL    ReadDesc                ; Read it
        XCHG                            ; Position to HL
        LDA     dropTargetY             ; Has it fallen ...
        CMP     L                       ; ... to the rack?
        JC      L_4379                  ; No ... keep going
        LHLD    dropSlotL               ; Yes ... the slot ...
        MVI     M,0x05                  ; ... gets a squid
        CALL    ResetDrop               ; Reset the drop variables
        MVI     A,0x01                  ; Flag ...
        STA     dropDone                ; ... an alien was dropped
L_4379:
        LXI     H,obj1TimerMSB          ; Game objects (skip the player)
        CALL    L_0291                  ; Run them
        POP     H                       ; Drop our return
        JMP     ISRExit                 ; Out of the ISR

; Part II: (end-of-screen ISR) move and draw the alien falling from the saucer.
SaucerDropMove:
        LXI     H,dropActive            ; Dropping?
        MOV     A,M                     ; Get flag
        ANA     A                       ; Set flags
        RZ                              ; No ... out
        LXI     H,dropDeltaY            ; Falling-alien deltas
        MOV     C,M                     ; Delta X
        CALL    AddDelta                ; Move it
        LXI     H,dropYr                ; Falling-alien descriptor
        CALL    ReadDesc                ; Read it
        XCHG                            ; Position to HL
        MOV     A,L                     ; Still above ...
        CPI     0x2F                    ; ... the player area?
        JNC     L_43AE                  ; Yes ... draw it
        LXI     D,D_458C                ; Fell all the way: squid on its side
        CALL    DrawSprite              ; Erase it

ResetDrop:
        MVI     B,0x0E                  ; 14 bytes
        LXI     H,dropColumn            ; Drop variables
        LXI     D,D_1BA0                ; From the RAM mirror (1BA0)
        JMP     BlockCopy               ; Reset them
L_43AE:
        LDA     dropHit                 ; Was it shot?
        ANA     A                       ; Set flags
        JZ      L_43B8                  ; No ... draw the alien
        LXI     D,D_4594                ; Yes ... draw it upside down (4594)
L_43B8:
        JMP     DrawSprite              ; Draw it and out

FindDropSlot:
        LDA     saucerActive            ; Saucer flying?
        ANA     A                       ; Set flags
        JZ      L_43FF                  ; No ... clear the pending flag
        LDA     dropActive              ; Already dropping?
        ANA     A                       ; Set flags
        RNZ                             ; Yes ... out
        MOV     C,A                     ; (Hold a 0)
        LDA     saucerDeltaY            ; Saucer moving ...
        CPI     0x02                    ; ... right?
        MOV     A,C                     ; (no effect)
        LDA     playerDataMSB           ; Player's ...
        MOV     H,A                     ; ... aliens
        MVI     B,0x0B                  ; 11 slots in the top row
        JNZ     L_43E4                  ; Moving left ... search from the right
        MVI     L,0x2C                  ; Top row starts at 2C
L_43D9:
        MOV     A,M                     ; Empty ...
        ANA     A                       ; ... slot?
        JZ      L_43F1                  ; Yes ... pick it
        INX     H                       ; Next slot
        DCR     B                       ; All 11?
        JNZ     L_43D9                  ; No ... keep looking
        RET                             ; Top row is full
L_43E4:
        MVI     L,0x36                  ; Top row ends at 36
L_43E6:
        MOV     A,M                     ; Empty ...
        ANA     A                       ; ... slot?
        JZ      L_43F1                  ; Yes ... pick it
        DCX     H                       ; Previous slot
        DCR     B                       ; All 11?
        JNZ     L_43E6                  ; No ... keep looking
        RET                             ; Top row is full
L_43F1:
        SHLD    dropSlotL               ; Remember the slot
        MOV     A,L                     ; Slot number ...
        ADI     0x05                    ; ... to column ...
        ANI     0x0F                    ; ... 1-11
        ORI     0x80                    ; Flag "slot picked"
        STA     dropColumn              ; Store it
        RET                             ; Done
L_43FF:
        LDA     dropColumn              ; Saucer gone ...
        ANI     0x7F                    ; ... clear ...
        STA     dropColumn              ; ... the pending flag
        LXI     H,dropDone              ; Did we drop an alien?
        MOV     A,M                     ; Get flag
        ANA     A                       ; Set flags
        RZ                              ; No ... out
        INX     H                       ; 20B8
        MOV     M,A                     ; Remember it (rounds 2-3 only get one)
        RET                             ; Done

; Part II: the last alien was a bonus alien (see 13D2). Award 500, 800 or 1000 and show
; "BONUS xxx POINTS" with light beams fanning out from where the alien was.
RackBonus:
        LDA     lastAlienBonus          ; Bonus earned?
        ANA     A                       ; Set flags
        RZ                              ; No ... out
        CALL    DsableGameTasks         ; Stop the game tasks
        CALL    BonusValue              ; HL = bonus (50, 80 or 100 = 500/800/1000)
        SHLD    scoreDeltaLSB           ; Score delta
        MVI     A,0x01                  ; Flag ...
        STA     adjustScore             ; ... the score change
        CALL    AdjustScore             ; Add it to the score
        MVI     A,0x02                  ; Start ...
        STA     isrDelay                ; ... the sound pulse timer
L_442B:
        LXI     H,0x2904                ; Screen coordinates
        LXI     D,D_4508                ; "BONUS  500 POINTS"
        MVI     C,0x11                  ; 17 characters
        CALL    PrintMessage            ; Print it
        LXI     B,bonus800              ; 800?
        LDAX    B                       ; Get flag
        ANA     A                       ; Set flags
        LXI     D,D_09C6                ; " 8" (800)
        JNZ     L_4449                  ; Yes ... patch the message
        DCX     B                       ; 20B3
        LDAX    B                       ; 1000?
        ANA     A                       ; Set flags
        JZ      L_4451                  ; No ... leave "500"
        INX     D                       ; "10" ...
        INX     D                       ; ... (1000)
L_4449:
        LXI     H,0x2F04                ; Over the " 5"
        MVI     C,0x02                  ; 2 characters
        CALL    PrintMessage            ; Print it
L_4451:
        LXI     H,beamCount             ; Beam variables
        LXI     D,D_4504                ; Initial values
        MVI     B,0x04                  ; 4 bytes
        CALL    BlockCopy               ; Initialize
        LHLD    alienPosLSB             ; Where the alien was
        MVI     A,0x07                  ; Center ...
        ADD     H                       ; ... of ...
        MOV     H,A                     ; ... it
        SHLD    beamOriginL             ; Beam origin
        CALL    BeamDot1                ; Plot the origin
        CALL    BeamNextRow             ; Move up a row
L_446C:
        MOV     A,L                     ; Top ...
        CPI     0xC8                    ; ... of screen?
        JNC     BeamDone                ; Yes ... this fan is done
        CALL    BeamDot                 ; Center dot
        PUSH    H                       ; Hold position
        CALL    BeamLeft                ; Dots to the left
        POP     H                       ; Restore position
        CALL    BeamRight               ; Dots to the right
        LXI     H,beamCount             ; Wider ...
        INR     M                       ; ... each row
        INX     H                       ; Spread ...
        INR     M                       ; ... more each row
        CALL    BeamNext                ; Next row up
        JMP     L_446C                  ; Keep going

BeamDot1:
        CALL    BeamDot                 ; Plot the origin
        LDA     isrDelay                ; Sound pulse
        ANA     A                       ; Set flags
        JZ      L_449B                  ; Timer done ... sound off
        MVI     A,0x02                  ; Restart ...
        STA     isrDelay                ; ... the timer
        JMP     SaucerSndOn             ; Saucer sound on
L_449B:
        MVI     A,0x00                  ; Timer ...
        STA     isrDelay                ; ... cleared
        JMP     SaucerSndOff            ; Saucer sound off

BeamLeft:
        LDA     beamCount               ; Number of dots
        MOV     C,A                     ; To C
L_44A7:
        LDA     beamStep                ; Spread
        MOV     B,A                     ; To B
        MOV     A,H                     ; Move ...
        SUB     B                       ; ... left
        MOV     H,A                     ; ...
        CPI     0x38                    ; Off the left side?
        RC                              ; Yes ... done
        CALL    BeamDot                 ; Plot a dot
        DCR     C                       ; All dots?
        JNZ     L_44A7                  ; No ... do them all
        RET                             ; Done

BeamRight:
        LDA     beamCount               ; Number of dots
        MOV     C,A                     ; To C
L_44BD:
        LDA     beamStep                ; Spread
        MOV     B,A                     ; To B
        MOV     A,H                     ; Move ...
        ADD     B                       ; ... right
        MOV     H,A                     ; ...
        CPI     0xE8                    ; Off the right side?
        RNC                             ; Yes ... done
        CALL    BeamDot                 ; Plot a dot
        DCR     C                       ; All dots?
        JNZ     L_44BD                  ; No ... do them all
        RET                             ; Done

BeamDot:
        PUSH    H                       ; Hold position
        CALL    ConvToScr               ; Screen address
        MVI     A,0x0F                  ; 4 pixel dash
        MOV     M,A                     ; Plot it
        POP     H                       ; Restore position
        PUSH    B                       ; Hold counts
        LXI     B,0x0320                ; Short ...
        CALL    DelayBC                 ; ... delay
        POP     B                       ; Restore counts
        RET                             ; Done

BeamNext:
        LHLD    beamOriginL             ; Current row

BeamNextRow:
        MVI     A,0x08                  ; Up ...
        ADD     L                       ; ... 8 ...
        MOV     L,A                     ; ... pixels
        SHLD    beamOriginL             ; Store
        RET                             ; Done

BeamDone:
        LXI     H,bonusBeamCnt          ; Count ...
        INR     M                       ; ... the fans
        LDA     bonusBeams              ; Number of fans for this bonus
        CMP     M                       ; Done them all?
        JC      L_44FC                  ; Yes
        CALL    ClearPlayField          ; Clear ...
        JMP     L_442B                  ; ... and do it again
L_44FC:
        MVI     M,0x00                  ; Reset count
        CALL    SaucerSndOff            ; Sound off
        JMP     TwoSecDelay             ; Wait and out
D_4504:
        DB      0x01,0x02,0x00,0x00
D_4508:
        DB      0x01,0x0E,0x0D,0x14,0x12,0x1B,0x1B,0x21,0x1C,0x1C,0x1B,0x0F; "BONUS  500 P"
        DB      0x0E,0x08,0x0D,0x13,0x12; "OINTS"

; Part II version of the hidden message: in the demo hold Start2+fire+right and then
; Start1+fire+left to see "TAITO CORP." (the text is scrambled in ROM at 0D6E).
CheckHiddenMes:
        MVI     H,0x20                  ; Build 201E ...
        MVI     L,0x1E                  ; ... in pieces
        MOV     A,M                     ; First sequence done?
        ANA     A                       ; Set flags
        JNZ     L_452E                  ; Yes ... look for the second
        CALL    ReadPort1               ; Read switches
        ANI     0x76                    ; Start1, Start2, fire, left, right
        SUI     0x52                    ; Start2+fire+right?
        RNZ                             ; No ... out
        INR     A                       ; 1
        STA     hidMessSeq              ; First sequence done
L_452E:
        CALL    ReadPort1               ; Read switches
        ANI     0x76                    ; Start1, Start2, fire, left, right
        CPI     0x34                    ; Start1+fire+left?
        RNZ                             ; No ... out
        MVI     H,0x2C                  ; Screen ...
        MVI     L,0x1B                  ; ... position
        MVI     D,0x0D                  ; Scrambled ...
        MVI     E,0x78                  ; ... message (end of 0D6E-0D78)
        MVI     C,0x0A                  ; 10 ...
        INR     C                       ; ... +1 = 11 characters
L_4541:
        LDAX    D                       ; Scrambled character
        ADI     0x3F                    ; Unscramble
        PUSH    D                       ; Hold pointer
        CALL    DrawChar                ; Print it
        POP     D                       ; Restore pointer
        DCX     D                       ; Backwards through the message
        DCR     C                       ; All done?
        JNZ     L_4541                  ; No ... do them all
        RET                             ; Done

; If the scrambled "TAITO" at 174C is intact clear the tamper flag 20E2.
CopyrightCheck:
        LXI     H,0xDBD0                ; (HL = D0 DB)
        LXI     B,0xC8DB                ; (BC = DB C8)
        LXI     D,D_174C                ; Scrambled "TAITO" in "*TAITO CORPORATION*"
        LDAX    D                       ; First byte ...
        CPI     0xD6                    ; ... D6?
        RNZ                             ; No ... leave flag set
        INX     D                       ; Next
        LDAX    D                       ; Get byte
        CMP     H                       ; DB?
        RNZ                             ; No ... leave flag set
        INX     D                       ; Next
        LDAX    D                       ; Get byte
        CMP     L                       ; D0?
        RNZ                             ; No ... leave flag set
        INX     D                       ; Next
        LDAX    D                       ; Get byte
        CMP     B                       ; DB?
        RNZ                             ; No ... leave flag set
        INX     D                       ; Next
        LDAX    D                       ; Get byte
        CMP     C                       ; C8?
        RNZ                             ; No ... leave flag set
        MVI     L,0xE2                  ; Build 20E2 ...
        MVI     H,0x20                  ; ... in pieces
        MVI     M,0x00                  ; Clear the tamper flag
        RET                             ; Done

; Print "*TAITO CORPORATION*" (scrambled backwards at 173F).
PrintCorp:
        MVI     H,0x28                  ; Screen ...
        MVI     L,0x03                  ; ... position
        MVI     E,0x51                  ; End of ...
        MVI     D,0x17                  ; ... the scrambled text (1751)
        MVI     C,0x12                  ; 18 ...
        INR     C                       ; ... +1 = 19 characters
L_457E:
        LDAX    D                       ; Scrambled character
        ADI     0x38                    ; Unscramble
        PUSH    D                       ; Hold pointer
        CALL    DrawChar                ; Print it
        POP     D                       ; Restore pointer
        DCX     D                       ; Backwards
        DCR     C                       ; All done?
        JNZ     L_457E                  ; No ... do them all
        RET                             ; Done
; ...**..*
; ..***.*.
; .**.**.*
; *****.*.
; *****.*.
; .**.**.*
; ..***.*.
; ...**..*
D_458C:
        DB      0x18,0x3C,0x7E,0xDB,0xFF,0x24,0x5A,0xA5
; *.*..*.*
; .*.**.*.
; ..*..*..
; ********
; **.**.**
; .******.
; ..****..
; ...**...
D_4594:
        DB      0x98,0x5C,0xB6,0x5F,0x5F,0xB6,0x5C,0x98

; Port 0 bits 1 and 3: both set means the wrong hardware ... restart. Both clear clears
; the 20E3 flag (which otherwise allows a hidden free-credit button combination).
HardwareCheck:
        IN      INP0                    ; Read port 0
        ANI     0x0A                    ; Bits 1 and 3
        CPI     0x0A                    ; Both set?
        JZ      Reset                   ; Yes ... restart
        ANA     A                       ; Set flags
        NOP                             ; (padding)
        RNZ                             ; One set ... leave the flag
        LXI     H,hwFlag                ; Both clear ...
        MVI     M,0x00                  ; ... clear the flag
        RET                             ; Done
D_45AE:
        DB      0x0F,0x11,0x04,0x12,0x04,0x13,0x1B,0x0C,0x0E,0x03,0x04; "PRESET MODE"

; Part II operator "preset mode" (DIP switch 4 on). Before play starts:
;   Start1 : add 1000 points        left  : stop the alien shots
;   Start2 : skip to the next rack  right : allow the alien shots
;   fire   : start playing
PresetMode:
        LXI     H,0x2D15                ; Screen coordinates
        LXI     D,D_45AE                ; "PRESET MODE"
        MVI     C,0x0B                  ; 11 characters
        CALL    PrintMessageDel         ; Print it
L_45C4:
        IN      INP1                    ; Read switches
        ANI     0x76                    ; Start1, Start2, fire, left, right
        CPI     0x10                    ; Fire?
        RZ                              ; Yes ... start the game
        CPI     0x04                    ; Start1?
        CZ      PresetScore             ; Yes ... add 1000 points
        CPI     0x20                    ; Left?
        CZ      PresetShotsOff          ; Yes ... stop alien shots
        CPI     0x02                    ; Start2?
        CZ      PresetRound             ; Yes ... next rack
        CPI     0x40                    ; Right?
        CZ      PresetShotsOn           ; Yes ... alien shots on
        OUT     WATCHDOG                ; Feed watchdog
        JMP     L_45C4                  ; Keep checking

PresetScore:
        IN      INP1                    ; Wait for ...
        ANI     0x04                    ; ... start1 ...
        JNZ     PresetScore             ; ... to be released
        LXI     H,0x0100                ; 1000 points
        SHLD    scoreDeltaLSB           ; Score delta
        MVI     A,0x01                  ; Flag ...
        STA     adjustScore             ; ... the change
        JMP     AdjustScore             ; Add it and print it

PresetShotsOff:
        LXI     H,shotsHalted           ; Halt ...
        MVI     M,0x01                  ; ... the alien shots
        RET                             ; Done

PresetRound:
        IN      INP1                    ; Wait for ...
        ANI     0x02                    ; ... start2 ...
        JNZ     PresetRound             ; ... to be released
        CALL    GetRoundNum             ; Round number
        CPI     0x12                    ; Past round 17?
        JC      L_4610                  ; No
        MVI     M,0x09                  ; Back to 9
L_4610:
        INR     M                       ; Next round
        MVI     L,0xFA                  ; Display round
        INR     M                       ; Next
        MOV     A,M                     ; Get it
        CPI     0x0A                    ; Past 9?
        JNZ     L_461C                  ; No
        MVI     M,0x00                  ; Back to 0
L_461C:
        CALL    RestoreShields2         ; Fresh shields (player 2's buffer is a clean copy)
        CALL    CarveRoundNum           ; Cut the round number into them
        CALL    InitAliens              ; New formation for player 1
        CALL    InitAliensP2            ; ... and player 2
        CALL    GetPlayerDataPage       ; Player's data
        MVI     L,0xFE                  ; Rack count
        MOV     A,M                     ; Get it
        JMP     SetRackStart            ; Set starting height and out

PresetShotsOn:
        LXI     H,shotsHalted           ; Allow ...
        MVI     M,0x00                  ; ... the alien shots
        RET                             ; Done

AwardShip:
        CALL    GetNumShips             ; Get pointer to number of ships
        INR     M                       ; Bump number of ships
        MOV     A,M                     ; Get the new total

DrawNewShip:
        PUSH    PSW                     ; Hang onto it for a bit
        LXI     H,0x2501                ; Screen coords for ship hold
L_4640:
        INR     H                       ; Bump to ...
        INR     H                       ; ... next
        DCR     A                       ; ... spot
        JNZ     L_4640                  ; Find spot for new ship
        MVI     B,0x10                  ; 16 byte sprite
        LXI     D,PlayerSprite          ; Player sprite
        CALL    DrawSimpSprite          ; Draw the sprite
        POP     PSW                     ; Restore the count
        INR     A                       ; +1
        JMP     L_180B

; HL = last-alien bonus (BCD/10): 100 (1000), 80 (800) or 50 (500). Also sets the number
; of beam fans.
BonusValue:
        LXI     H,bonus1000             ; 1000?
        MOV     A,M                     ; Get flag
        ANA     A                       ; Set flags
        JNZ     L_4665                  ; Yes
        INX     H                       ; 20B4
        MOV     A,M                     ; 800?
        ANA     A                       ; Set flags
        JNZ     L_466E                  ; Yes
        LXI     H,0x0050                ; 500
        RET                             ; Done
L_4665:
        LXI     H,0x0100                ; 1000
        MVI     A,0x04                  ; 4 ...
        STA     bonusBeams              ; ... fans
        RET                             ; Done
L_466E:
        LXI     H,0x0080                ; 800
        MVI     A,0x03                  ; 3 ...
        STA     bonusBeams              ; ... fans
        RET                             ; Done

Bonus1000:
        STA     bonus1000               ; Flag 1000
        STA     lastAlienBonus          ; Flag bonus
        RET                             ; Done

Bonus800:
        STA     bonus800                ; Flag 800
        RET                             ; Done

; Part II: clearing a rack with fewer than 56 shots earns an extra ship (up to 6).
FewShotsShip:
        CALL    GetPlayerDataPage       ; Player's data
        MVI     L,0xF8                  ; 2xF8 shots this rack
        MOV     A,M                     ; Get count
        CPI     0x38                    ; 56 or more?
        RNC                             ; Yes ... no ship
        CALL    GetNumShips             ; Number of ships
        INR     M                       ; One more
        MOV     A,M                     ; Get it
        CPI     0x07                    ; 7 or more?
        RNC                             ; Yes ... no ship
        CALL    DrawNewShip             ; Draw it and update the count
        CALL    ExtraShipSnd            ; Extra ship sound
        LXI     B,0x0000                ; Long ...
        CALL    DelayBC                 ; ... delay
        MVI     B,0xEF                  ; Mask off ...
        JMP     SoundBits3Off           ; ... the sound and out

; Leftover 8080 assembler source text: the end of a data table and the start of the
; original font, labeled CHROM ("***** CHARACTER DATA *****").
        DB      0x42,0x30,0x48,0x2C,0x30,0x42,0x30,0x48,0x2C,0x30,0x42,0x30,0x48,0x0D,0x0A,0x09; B0H,0B0H,0B0H\r\n\t
        DB      0x44,0x42,0x09,0x32,0x43,0x48,0x2C,0x35,0x38,0x48,0x2C,0x35,0x38,0x48,0x2C,0x38; DB\t2CH,58H,58H,8
        DB      0x34,0x48,0x0D,0x0A,0x09,0x44,0x42,0x09,0x38,0x34,0x48,0x0D,0x0A,0x3B,0x0D,0x0A; 4H\r\n\tDB\t84H\r\n;\r\n
        DB      0x3B,0x0D,0x0A,0x3B,0x09,0x2A,0x2A,0x2A,0x2A,0x2A,0x20,0x43,0x48,0x41,0x52,0x41; ;\r\n;\t***** CHARA
        DB      0x43,0x54,0x45,0x52,0x20,0x44,0x41,0x54,0x41,0x20,0x2A,0x2A,0x2A,0x2A,0x2A,0x0D; CTER DATA *****\r
        DB      0x0A,0x3B,0x0D,0x0A,0x43,0x48,0x52,0x4F,0x4D,0x3A,0x09,0x44,0x42,0x09,0x31,0x46; \n;\r\nCHROM:\tDB\t1F
        DB      0x48,0x2C,0x32,0x34,0x48,0x2C,0x34,0x34,0x48,0x09,0x20,0x20,0x20,0x3B,0x20,0x20; H,24H,44H\t   ;
        DB      0x41,0x20,0x20,0x20,0x3C,0x30,0x30,0x3E,0x0D,0x0A,0x09,0x44,0x42,0x09,0x32,0x34; A   <00>\r\n\tDB\t24
        DB      0x48,0x2C,0x31,0x46,0x48,0x0D,0x0A,0x09,0x44,0x42,0x09,0x37,0x46,0x48,0x2C,0x34; H,1FH\r\n\tDB\t7FH,4
        DB      0x39,0x48,0x2C,0x34,0x39,0x48,0x09,0x20,0x20,0x20,0x3B,0x20,0x20,0x42,0x20,0x20; 9H,49H\t   ;  B
        DB      0x20,0x3C,0x30,0x31,0x3E,0x0D,0x0A,0x09,0x44,0x42,0x09,0x34,0x39,0x48,0x2C,0x33; <01>\r\n\tDB\t49H,3
        DB      0x36,0x48,0x0D,0x0A,0x09,0x44,0x42,0x09,0x33,0x45,0x48,0x2C,0x34,0x31,0x48,0x2C; 6H\r\n\tDB\t3EH,41H,
        DB      0x34,0x31,0x48,0x09,0x20,0x20,0x20,0x3B,0x20,0x20,0x43,0x20,0x20,0x20,0x3C,0x30; 41H\t   ;  C   <0
        DB      0x32,0x3E,0x0D,0x0A,0x09,0x44,0x42,0x09,0x34,0x31,0x48,0x2C,0x32,0x32,0x48,0x0D; 2>\r\n\tDB\t41H,22H\r
        DB      0x0A,0x09,0x44,0x42,0x09,0x37,0x46,0x48,0x2C,0x34,0x31,0x48,0x2C,0x34,0x31,0x48; \n\tDB\t7FH,41H,41H
        DB      0x09,0x20,0x20,0x20,0x3B,0x20,0x20,0x44,0x20,0x20,0x20,0x3C,0x30,0x33,0x3E,0x0D; \t   ;  D   <03>\r
        DB      0x0A,0x09,0x44,0x42,0x09,0x34,0x31,0x48,0x2C,0x33,0x45,0x48,0x0D,0x0A,0x09,0x44; \n\tDB\t41H,3EH\r\n\tD
        DB      0x42,0x09,0x37,0x46,0x48,0x2C,0x34,0x39,0x48,0x2C,0x34,0x39,0x48,0x09,0x20,0x20; B\t7FH,49H,49H\t
        DB      0x20,0x3B,0x20,0x20,0x45,0x20,0x20,0x20,0x3C,0x30,0x34,0x3E,0x0D,0x0A,0x09,0x44; ;  E   <04>\r\n\tD
        DB      0x42,0x09,0x34,0x39,0x48,0x2C,0x34,0x31,0x48,0x0D,0x0A,0x09,0x44,0x42,0x09,0x37; B\t49H,41H\r\n\tDB\t7
        DB      0x46,0x48,0x2C,0x34,0x38,0x48,0x2C,0x34,0x38,0x48,0x09,0x20,0x20,0x20,0x3B,0x20; FH,48H,48H\t   ;
        DB      0x20,0x46,0x20,0x20,0x20,0x3C,0x30,0x35,0x3E,0x0D,0x0A,0x09; F   <05>\r\n\t


        END
