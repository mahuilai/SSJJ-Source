# -*- coding: utf-8 -*-
"""拉起战斗客户端，尽量脱离当前进程作业对象，避免被父进程回收

策略：
  1) CREATE_BREAKAWAY_FROM_JOB | DETACHED_PROCESS 直接 Popen
  2) 失败则退回计划任务（schtasks）触发，完全独立于当前会话
"""
import os
import subprocess
import sys
import time

EXE = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity.exe"
CWD = r"D:\SSJJ-4399\battle\3_64"
LOG = r"D:\SSJJ-4399\battle\3_64\log\offline.log"
TASK = "SSJJ_Offline_Battle"

args = [EXE, "-screen-fullscreen", "0", "-logFile", LOG]
print("cmdline:", " ".join(args))

DETACHED_PROCESS = 0x00000008
CREATE_BREAKAWAY_FROM_JOB = 0x01000000

launched = False
try:
    p = subprocess.Popen(
        args,
        cwd=CWD,
        close_fds=True,
        creationflags=DETACHED_PROCESS | CREATE_BREAKAWAY_FROM_JOB,
    )
    print("popen breakaway ok, pid:", p.pid)
    launched = True
except Exception as e:
    print("breakaway failed:", type(e).__name__, e)

if not launched:
    tr = '"%s" -screen-fullscreen 0 -logFile %s' % (EXE, LOG)
    subprocess.run(
        ["schtasks", "/create", "/tn", TASK, "/tr", tr,
         "/sc", "once", "/st", "23:59", "/f"],
        capture_output=True,
    )
    r = subprocess.run(["schtasks", "/run", "/tn", TASK], capture_output=True)
    print("schtasks run rc:", r.returncode)
    try:
        print(r.stdout.decode("gbk", "replace").strip()[:200])
    except Exception:
        pass

sys.stdout.flush()
time.sleep(6)
out = subprocess.run(
    ["tasklist", "/fi", "IMAGENAME eq SSJJ_BattleClient_Unity.exe"],
    capture_output=True,
)
txt = out.stdout.decode("gbk", "replace")
print("alive:", "SSJJ_BattleClient_Unity" in txt)
