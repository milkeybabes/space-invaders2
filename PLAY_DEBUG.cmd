@echo off
cd /d "%~dp0"
REM Part II unlimited ships for debugging.
python part2_play.py --debug %*
if errorlevel 1 pause
