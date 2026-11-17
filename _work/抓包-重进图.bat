@echo off
chcp 65001 >nul
setlocal
set DUMPCAP="D:\RE_Tools\Wireshark\dumpcap.exe"
set OUT=D:\逆向\SSJJ双塔惊魂\_work\cap_reinit.pcapng

cls
echo ================================================================
echo    SSJJ 进图初始化抓包  (900 秒)
echo ================================================================
echo.
echo   [抓包窗口] 现在开始。这个窗口会一直显示抓包进度，别关。
echo.
echo   ============ 你现在要做的事 ============
echo.
echo    1. 切回游戏，退出当前这一局
echo       （Esc - 退出房间 / 返回大厅）
echo.
echo    2. 重新选一个模式进图   ^<== 换个模式最好，能对比
echo       推荐顺序：团队(3) -> 爆破(2) -> 生化(6) -> 大头(19)
echo.
echo    3. 进图后站 3 秒，开两枪，切一次枪
echo.
echo    4. 想抓多个模式就重复 1-3，900 秒内随便搞
echo.
echo   ======================================
echo.
if exist "%OUT%" del /q "%OUT%"

%DUMPCAP% -i 5 -a duration:900 -s 1600 -w "%OUT%"

echo.
echo ================================================================
echo   抓包结束
if exist "%OUT%" for %%A in ("%OUT%") do echo   文件: %OUT%   (%%~zA 字节)
echo   回去告诉石井: 抓完了
echo ================================================================
timeout /t 8 >nul
