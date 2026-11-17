@echo off
REM 独立启动器：用 start 让游戏进程脱离当前 shell，关闭终端不会带走游戏
setlocal
set GAMEDIR=D:\SSJJ-4399\battle\3_64
set LOG=%GAMEDIR%\log\offline.log
if exist "%LOG%" del /f /q "%LOG%" >nul 2>&1
taskkill /f /im SSJJ_BattleClient_Unity.exe >nul 2>&1
cd /d "%GAMEDIR%"
start "SSJJ" "%GAMEDIR%\SSJJ_BattleClient_Unity.exe" -screen-fullscreen 0 -screen-width 1600 -screen-height 900 -logFile "%LOG%"
endlocal
