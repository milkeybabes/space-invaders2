@echo off
cd /d "%~dp0"
python part2_play.py --playback-inp part2_2player.inp --headless --record diagnostics\part2_2player_python.avi --frame-crc diagnostics\part2_2player_python_crc.csv
pause
