# -*- coding: utf-8 -*-
"""生成双击启动脚本（GBK 写盘，避免中文路径在 cmd 里变问号）。"""
import os

ROOT = r"D:\逆向\SSJJ双塔惊魂\离线大厅"
CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

BAT = r"""@echo off
chcp 936 >nul
title 生死狙击 · 离线大厅
set LOCAL=%~dp0
set PAGE=%LOCAL%大厅.html
set BROWSER=
if exist "%CHROME%" set BROWSER=%CHROME%
if not defined BROWSER if exist "%EDGE%" set BROWSER=%EDGE%
if not defined BROWSER (
  echo 未找到 Chrome / Edge，请手动用浏览器打开:
  echo %PAGE%
  pause
  exit /b
)
start "" "%BROWSER%" --app="file:///%PAGE:\=/%" --window-size=1040,760 --allow-file-access-from-files
exit
"""


def main():
    bat = BAT.replace("%CHROME%", CHROME).replace("%EDGE%", EDGE)
    path = os.path.join(ROOT, "启动大厅.bat")
    with open(path, "w", encoding="gbk", errors="replace", newline="\r\n") as fh:
        fh.write(bat)
    print("wrote", path)
    # 顺便放一个说明
    txt = os.path.join(ROOT, "说明.txt")
    with open(txt, "w", encoding="gbk", errors="replace", newline="\r\n") as fh:
        fh.write(
            "生死狙击 · 离线大厅（原版界面还原版）\n"
            "=====================================\n\n"
            "双击 启动大厅.bat 打开。\n\n"
            "当前能力：\n"
            "  · 大厅主界面按原版 FairyGUI 布局 1:1 渲染\n"
            "  · 顶栏 15 个按钮可点，弹层打开对应系统界面\n"
            "  · screens\\index.html 可查看全部 287 个系统界面\n\n"
            "当前限制：\n"
            "  · 各界面是静态渲染快照，内部按钮尚无业务逻辑\n"
            "  · 玩家数据（仓库/角色/喷漆/金币）尚未注入\n"
            "  · 不能从大厅启动战斗\n"
        )
    print("wrote", txt)


if __name__ == "__main__":
    main()
