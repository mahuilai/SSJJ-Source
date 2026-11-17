@echo off
chcp 65001 >nul
set DUMPCAP="D:\RE_Tools\Wireshark\dumpcap.exe"
set OUT=D:\逆向\SSJJ双塔惊魂\_work\cap_login.pcapng
set LOG=D:\逆向\SSJJ双塔惊魂\_work\dumpcap_run.log

if exist "%OUT%" del /q "%OUT%"

%DUMPCAP% -i 5 -a duration:900 -s 1600 -w "%OUT%" > "%LOG%" 2>&1
