@echo off
REM 一键：生成启动场景 + 构建 Windows x64
REM 用法：双击，或在 cmd 里执行
setlocal
set UNITY=D:\Unity\Editor\Unity.exe
set PROJ=%~dp0..
set LOG=%~dp0..\..\Game-SSJJ-logs

if not exist "%LOG%" mkdir "%LOG%"

echo [1/2] 生成启动场景...
"%UNITY%" -batchmode -nographics -quit -projectPath "%PROJ%" -executeMethod ProjectSetup.CreateBootScene -logFile "%LOG%\setup.log"
if errorlevel 1 goto fail

echo [2/2] 构建 Windows64...
"%UNITY%" -batchmode -nographics -quit -projectPath "%PROJ%" -executeMethod BuildGame.BuildWin64 -logFile "%LOG%\build.log"
if errorlevel 1 goto fail

echo 完成：%PROJ%\Build\SSJJ-SP\SSJJ-SP.exe
pause
exit /b 0

:fail
echo 失败，看日志：%LOG%
pause
exit /b 1
