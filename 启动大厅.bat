@echo off
chcp 65001 >nul
title 4399生死狙击 - 官方离线大厅
cd /d "%~dp0"

echo 正在清理旧大厅进程...
taskkill /f /im AirLobbyPreloader.exe >nul 2>&1
taskkill /f /im AirAloneChat.exe >nul 2>&1
taskkill /f /im adl.exe >nul 2>&1

echo 正在启动官方 AIR 大厅及本地后台服务...
python _work\launch_lobby.py %*
