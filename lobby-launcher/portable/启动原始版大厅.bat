@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0启动器引导.ps1" -Executable "ssjj-lobby-before-official-lobby-previews.exe"
if errorlevel 1 pause
