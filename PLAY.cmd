@echo off
cd /d "%~dp0"
REM Space Invaders Part II: playable current Python version.
python part2_play.py %*
if errorlevel 1 pause
