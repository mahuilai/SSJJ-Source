@echo off
setlocal
chcp 936 >nul
title 4399生死狙击 - 原生3D微端战斗启动器

set "ROOT=%~dp0"
set "PYTHON=python"

where python >nul 2>&1
if errorlevel 1 goto no_python

echo =======================================================
echo    4399生死狙击 原生3D战斗启动器
echo =======================================================

netstat -ano | findstr /c:"127.0.0.1:8080" >nul
if not errorlevel 1 goto gateway_ready
if not exist "%ROOT%_work\gateway_8080.py" goto missing_gateway
echo [*] 正在启动全量资源网关 :8080 ...
start "SSJJ_Gateway" /min "%PYTHON%" "%ROOT%_work\gateway_8080.py"
timeout /t 2 /nobreak >nul
:gateway_ready

netstat -ano | findstr /c:"127.0.0.1:27100" >nul
if not errorlevel 1 goto server_ready
if not exist "%ROOT%SSJJ-Server\bin\Debug\net10.0\SSJJ-Server.exe" goto missing_server
echo [*] 正在启动 SSJJ-Server 战斗服务端 :27100 ...
start "SSJJ-Server" /min "%ROOT%SSJJ-Server\bin\Debug\net10.0\SSJJ-Server.exe"
timeout /t 2 /nobreak >nul
:server_ready

if not exist "%ROOT%_work\launch_battle_client.py" goto missing_launcher
echo [*] 正在拉起原版微端 SSJJ_BattleClient_Unity ...
"%PYTHON%" "%ROOT%_work\launch_battle_client.py"
if errorlevel 1 goto launch_failed
goto done

:no_python
echo [错误] 找不到 Python。请先安装 Python，并把 python.exe 加入 PATH。
goto failed
:missing_gateway
echo [错误] 找不到：%ROOT%_work\gateway_8080.py
goto failed
:missing_server
echo [错误] 找不到：%ROOT%SSJJ-Server\bin\Debug\net10.0\SSJJ-Server.exe
goto failed
:missing_launcher
echo [错误] 找不到：%ROOT%_work\launch_battle_client.py
goto failed
:launch_failed
echo [错误] 战斗客户端启动脚本执行失败，错误码 %errorlevel%。
:failed
pause
exit /b 1

:done
echo [OK] 战斗客户端启动流程已完成。
pause
exit /b 0
