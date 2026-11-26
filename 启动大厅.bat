@echo off
setlocal
chcp 65001 >nul
title 4399生死狙击 - 官方离线大厅
cd /d "%~dp0" || goto :failed

set "PYTHONIOENCODING=utf-8"
echo 正在启动官方 AIR 大厅及本地后台服务，请等大厅窗口出现...
python -u "%~dp0_work\launch_lobby.py" %*
if errorlevel 1 goto :failed
exit /b 0

:failed
set "lobby_exit=%errorlevel%"
echo.
echo 大厅启动失败，退出码 %lobby_exit%。请保留上方错误信息。
pause
exit /b %lobby_exit%
