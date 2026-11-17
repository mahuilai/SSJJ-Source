# -*- coding: utf-8 -*-
"""直接运行原版大厅启动器 AirLobbyPreloader.exe（AIR 应用自带 runtime）。

这才是真正的「原版大厅启动器」：Lobby/ 目录是完整的 .air 包，
包含 Adobe AIR/Versions/1.0/Adobe AIR.dll + NPSWF32.dll + CaptiveAppEntry.exe。
Ruffle 跑不了是因为大厅依赖 AIR API（NativeApplication / Window 等），不是纯 SWF。
"""
import os, subprocess, sys, time
from PIL import ImageGrab

LOBBY = r"D:\SSJJ\SSJJ-4399\Lobby"
EXE = os.path.join(LOBBY, "AirLobbyPreloader.exe")
OUT = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\out"
WAIT = int(sys.argv[1]) if len(sys.argv) > 1 else 18


def main():
    if not os.path.exists(EXE):
        print("missing", EXE)
        return
    p = subprocess.Popen([EXE], cwd=LOBBY)
    print("started pid", p.pid)
    for i in range(WAIT):
        time.sleep(1)
        if p.poll() is not None:
            print(f"exited after {i+1}s code={p.returncode}")
            break
    img = ImageGrab.grab()
    os.makedirs(OUT, exist_ok=True)
    shot = os.path.join(OUT, "air_lobby.png")
    img.save(shot)
    img.thumbnail((1280, 1280))
    prev = os.path.join(OUT, "air_lobby_prev.png")
    img.save(prev)
    print("shot", shot, img.size, "alive", p.poll() is None)


if __name__ == "__main__":
    main()
