# -*- coding: utf-8 -*-
"""用 Ruffle 跑原版大厅 SWF：把 paras.dat 里的启动参数作为 flashvars 传进去。

原版链路：AirLobbyPreloader.exe -> 读 Lobby/paras.dat -> 加载 lobbyFileName 指向的 SWF
        并把 paras 里的字段塞进 loaderInfo.parameters。
直接跑 SWF 时这些字段全空，大厅会卡在初始化（画面全黑）。
"""
import json, os, subprocess, sys, time
from PIL import ImageGrab

ROOT = r"D:\逆向\SSJJ双塔惊魂"
PARAS = r"D:\SSJJ\SSJJ-4399\Lobby\paras.dat"
RUFFLE = os.path.join(ROOT, "_tools", "ruffle", "ruffle.exe")
SWF = os.path.join(ROOT, "_work", "lobby_air", "Lobby_main.swf")
SHOT = os.path.join(ROOT, "_work", "lobby_ui", "out", "ruffle_lobby.png")
PREV = os.path.join(ROOT, "_work", "lobby_ui", "out", "ruffle_lobby_prev.png")


def main():
    paras = json.load(open(PARAS, encoding="utf-8"))
    args = [RUFFLE, "--width", "1280", "--height", "800", "-s", "show-all"]
    for k, v in paras.items():
        if isinstance(v, (dict, list)):
            continue
        args += ["-P", f"{k}={v}"]
    args.append(SWF)
    print("flashvars:", len(paras), "swf:", SWF)
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace")
    time.sleep(12)
    alive = p.poll() is None
    print("alive:", alive, "pid:", p.pid)
    img = ImageGrab.grab()
    img.save(SHOT)
    img.thumbnail((1280, 1280))
    img.save(PREV)
    print("shot:", SHOT, img.size)
    if not alive:
        o, e = p.communicate()
        print("OUT", (o or "")[-800:])
        print("ERR", (e or "")[-1200:])
    else:
        p.terminate()


if __name__ == "__main__":
    main()
