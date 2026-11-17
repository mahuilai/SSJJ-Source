# -*- coding: utf-8 -*-
"""守护启动：拉起战斗客户端并持有到它自己退出

用途：命令行一结束，直接 Popen 出来的子进程会被回收到，游戏随之消失。
这里让本进程一直 wait() 到游戏退出，从而把游戏留住。
"""
import subprocess
import sys
import time

EXE = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity.exe"
CWD = r"D:\SSJJ-4399\battle\3_64"

args = [EXE, "-screen-fullscreen", "0", "-screen-width", "2240", "-screen-height", "1260"]
print("[hold] launch:", " ".join(args), flush=True)

p = subprocess.Popen(args, cwd=CWD, close_fds=True)
print("[hold] pid:", p.pid, flush=True)

t0 = time.time()
while True:
    rc = p.poll()
    if rc is not None:
        print("[hold] game exited rc=%s after %.0fs" % (rc, time.time() - t0), flush=True)
        break
    time.sleep(10)
    print("[hold] alive %.0fs" % (time.time() - t0), flush=True)
