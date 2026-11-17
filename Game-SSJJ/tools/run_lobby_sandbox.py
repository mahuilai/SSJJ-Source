# -*- coding: utf-8 -*-
"""搭建「原版大厅运行沙箱」：用 CDN 的真实配置 + 本地 HTTP 服务让 SWF 跑起来。

链路（从 paras.dat 和 AS 源码还原）：
  Lobby_main.swf 启动 -> URLLoader("config/hall_config.xml")
                     -> 读 res_config_*.xml（全局资源清单）
                     -> 按清单里的 url 逐项加载 resource/view/*.xml 与 resource/flas/*.swf
  所有 url 相对 resurl（CDN http://cdn.4399ssjj.com/s3/）。

做法：本地目录当 base，把 config/ 放本地，资源 url 改写成 CDN 绝对地址，
      再用 HTTP 服务把本地目录暴露给 Ruffle（file:// 下 URLLoader 容易被拦）。
"""
import os, re, json, shutil, http.server, socketserver, threading, subprocess, time, sys
from PIL import ImageGrab

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SANDBOX = os.path.join(ROOT, "_work", "lobby_run")
SRC_SWF = os.path.join(ROOT, "_work", "lobby_air", "Lobby_main.swf")
CFG_SRC = os.path.join(ROOT, "_work", "lobby_ui")
RUFFLE = os.path.join(ROOT, "_tools", "ruffle", "ruffle.exe")
OUT = os.path.join(ROOT, "_work", "lobby_ui", "out")
CDN = "http://cdn.4399ssjj.com/s3/"
PORT = 18877


def prepare():
    os.makedirs(os.path.join(SANDBOX, "config"), exist_ok=True)
    shutil.copy2(SRC_SWF, os.path.join(SANDBOX, "Lobby_main.swf"))

    # hall_config.xml 原样放本地
    hall = os.path.join(CFG_SRC, "hall_config.xml")
    if os.path.exists(hall):
        shutil.copy2(hall, os.path.join(SANDBOX, "config", "hall_config.xml"))

    # res_config：把相对 url 改写成 CDN 绝对地址，避免本地镜像整座 CDN
    rc = None
    for f in os.listdir(CFG_SRC):
        if f.startswith("res_config_") and f.endswith(".xml"):
            rc = os.path.join(CFG_SRC, f)
            break
    if rc:
        txt = open(rc, encoding="utf-8", errors="replace").read()
        n = [0]

        def repl(m):
            u = m.group(1)
            if u.startswith("http"):
                return m.group(0)
            n[0] += 1
            return f'url="{CDN}{u}"'

        txt2 = re.sub(r'url="([^"]+)"', repl, txt)
        open(os.path.join(SANDBOX, "config", "res_config.xml"), "w", encoding="utf-8").write(txt2)
        print(f"res_config rewritten: {n[0]} urls -> CDN")

    # i18n
    i18n = os.path.join(CFG_SRC, "i18n.txt")
    if os.path.exists(i18n):
        shutil.copy2(i18n, os.path.join(SANDBOX, "config", "i18n.txt"))
    print("sandbox:", SANDBOX)


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=SANDBOX, **kw)

    def log_message(self, fmt, *args):
        msg = fmt % args
        if "404" in msg or "500" in msg:
            print("[http]", msg)


def serve():
    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", PORT), Handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd


def main():
    prepare()
    serve()
    url = f"http://127.0.0.1:{PORT}/Lobby_main.swf"
    print("open", url)
    env = dict(os.environ)
    env["RUST_LOG"] = "info"
    p = subprocess.Popen(
        [RUFFLE, "--width", "1280", "--height", "800", url],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace", env=env,
    )
    wait = int(sys.argv[1]) if len(sys.argv) > 1 else 25
    time.sleep(wait)
    img = ImageGrab.grab()
    os.makedirs(OUT, exist_ok=True)
    img.save(os.path.join(OUT, "lobby_run.png"))
    img.thumbnail((1280, 1280))
    img.save(os.path.join(OUT, "lobby_run_prev.png"))
    p.terminate()
    try:
        o, e = p.communicate(timeout=6)
    except Exception:
        o, e = "", ""
    lines = [l for l in ((e or "") + (o or "")).splitlines() if "ERROR" in l or "WARN" in l]
    print("--- log tail ---")
    print("\n".join(lines[-18:]))
    print("shot:", os.path.join(OUT, "lobby_run_prev.png"))


if __name__ == "__main__":
    main()
