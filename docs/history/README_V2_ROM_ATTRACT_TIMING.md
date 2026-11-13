# Part II — source-driven attract timing pass

Run with Windows Command Prompt:

```bat
python part2_source_timing_test.py
python part2_stage12_test.py
python part2_play.py
```

## 8080 references and what has changed

- `$0CD8 SplashLoop`: all title/score-table waits now use `$0C9D OneSecDelay` and `$0CB6 WaitOnDelay` with the real `$40` VBlank countdown. No MAME-derived 15/9/15/8-second sequence is used.
- `$40DC TitleScreen`: the actual routine **order** is now FillDots, wait `$40`; CarveBitmap, wait `$40`; FillDots, wait `$40`; CarveBitmap, wait `$40`; CopyBitmap, wait `$40`; DrawScores/FlashHiName, wait `$40`. The surrounding `SplashLoop` waits `$40` before and after the title.
- `$163F DrawAdvTable` and `$0C85 PrintMessageDel`: the six ROM sprite descriptors are used, then five 11-character messages. Each character loads `$07` in `$20C0`; **the busy loop exits at `$01`**, after six VBlank decrements. All 55 messages' letters use that logic; there is an additional `$40` wait after the table.
- `$0CC1 DemoAliens`: alternate rounds 0 and 3. `$0D1A/$0D2C PlayerHitChk`: the attract demo no longer ends after a guessed number of frames; the state machine looks for `$2015 != $FF` followed by `$FF` (player explosion complete).
- `$0D32` credit screen: `$40` wait on entry and `$80` wait after messages.
- `$00BD` and `$0CA7 SplashDemo` ISR routing: in Part II demo mode (`$20C1 & 1`) game-object work continues despite `$20EF == 0`. No-score demo (`$20EF = 0`) remains intact.
- The older Stage 08–12 tests were updated only where they previously asserted hard-coded phase durations. Source-timing tests are now included.

## Still not cycle/frame-perfect

This **is not** a verified frame-perfect attract implementation yet. The title graphics operations are committed at the translated call boundaries, not paced by the original 8080 execution cycles. The score-table sprite calls and immediate text routines similarly lack instruction-cycle accounting. The rack-arrival foreground work rate is still provisional (eight operations per preview frame). The Part II **attract-demo** branch of `$02D4` / `$03EB` is now translated: its $2016 five-service image timer, $2017 12-image count, ROM blow-up sprites, $1B10 descriptor restoration, and $20EF=0 return to the attract foreground. Interactive gameplay lives/respawn remain incomplete.

MAME/AVI is **comparison-only**. No duration values were taken from it for this pass. The new tests exercise the original ROM countdowns and verify the **natural missile collision → eleven explosion sprites → ROM descriptor reset → coin screen** path; no manually injected player state or gameplay timeout is required.
