# -*- coding: utf-8 -*-
"""按需自行拉起 Blender GUI（用户已授权：以后自己打开就行）。

Blender 5.4 便携版装了官方 Lab MCP 扩展 bl_ext.user_default.mcp，
注册 1 秒后自动监听 localhost:9876。本脚本幂等：端口已在监听就跳过启动。

用法: python mc-port/tools/start_blender.py [--wait 90]
"""
import argparse
import os
import socket
import subprocess
import time

BLENDER = (r"D:\blender\blender-5.4.0-alpha+main.3fe0f2ab2a29-windows.amd64-release"
           r"\blender.exe")
HOST, PORT = "127.0.0.1", 9876


def port_open(timeout=1.5):
    s = socket.socket()
    s.settimeout(timeout)
    try:
        s.connect((HOST, PORT))
        return True
    except Exception:
        return False
    finally:
        s.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--wait", type=int, default=90)
    args = ap.parse_args()
    if port_open():
        print("Blender MCP socket %d already listening, nothing to do" % PORT)
        return
    if not os.path.isfile(BLENDER):
        raise RuntimeError("blender.exe not found: " + BLENDER)
    flags = 0
    if hasattr(subprocess, "DETACHED_PROCESS"):
        flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP
    p = subprocess.Popen([BLENDER], cwd=os.path.dirname(BLENDER),
                         creationflags=flags,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("launched blender pid=%d" % p.pid, flush=True)
    for i in range(args.wait):
        time.sleep(1)
        if port_open(timeout=0.6):
            print("socket %d listening after %ds -> MCP ready" % (PORT, i + 1))
            return
    print("TIMEOUT: socket %d not listening after %ds (check add-on enabled in Blender)"
          % (PORT, args.wait))


if __name__ == "__main__":
    main()
