@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0" || exit /b 1
set "PYTHONIOENCODING=utf-8"
python -u "%~dp0_work\launch_lobby.py" --local-dual %*
if errorlevel 1 pause
exit /b %errorlevel%
