@echo off
cd /d "%~dp0"
REM Optional recording: requires ffmpeg.exe on PATH; original 224x260 output.
python part2_play.py --record "recordings\SpaceInvadersPartII.avi" %*
if errorlevel 1 pause
