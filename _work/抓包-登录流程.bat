@echo off
chcp 65001 >nul
setlocal
set DUMPCAP="D:\RE_Tools\Wireshark\dumpcap.exe"
set OUT=%~dp0cap_login.pcapng

echo ============================================================
echo  SSJJ 登录流程抓包  (180 秒 / 全量)
echo ============================================================
echo.
echo  网卡 : WLAN (接口 5)
echo  输出 : %OUT%
echo  时长 : 180 秒
echo.
echo  【现在立刻去做】
echo    1) 启动 4399 微端 / 原版生死狙击
echo    2) 登录账号
echo    3) 进入房间、进图，动一动、开两枪
echo.
echo  抓包会在 180 秒后自动停止。
echo ============================================================
echo.

if exist "%OUT%" del /q "%OUT%"

%DUMPCAP% -i 5 -a duration:180 -w "%OUT%"

echo.
echo ============================================================
echo  抓包结束: %OUT%
if exist "%OUT%" (
    for %%A in ("%OUT%") do echo  文件大小: %%~zA 字节
)
echo ============================================================
pause
