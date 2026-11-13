@echo off
cd /d "%~dp0"
REM Part II with the included Midway bezel.
python part2_play.py --artwork bezel %*
if errorlevel 1 pause
