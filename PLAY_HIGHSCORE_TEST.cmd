@echo off
cd /d "%~dp0"
REM Jump directly into Part II high-score registration screen.
python part2_play.py --test-high-score --artwork bezel %*
if errorlevel 1 pause
