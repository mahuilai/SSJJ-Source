# -*- coding: utf-8 -*-
"""用计划任务拉起游戏：进程完全独立于当前 shell / 作业对象，不会被回收"""
import subprocess
import sys
import time

EXE = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity.exe"
LOG = r"D:\SSJJ-4399\battle\3_64\log\offline.log"
TASK = "SSJJ_Offline_Battle"

tr = '"%s" -screen-fullscreen 0 -logFile %s' % (EXE, LOG)

r = subprocess.run(
    ["schtasks", "/create", "/tn", TASK, "/tr", tr, "/sc", "once", "/st", "23:59", "/f"],
    capture_output=True,
)
print("create rc:", r.returncode, r.stdout.decode("gbk", "replace").strip()[:120])

r = subprocess.run(["schtasks", "/run", "/tn", TASK], capture_output=True)
print("run rc:", r.returncode, r.stdout.decode("gbk", "replace").strip()[:120])
sys.stdout.flush()

for i in range(1, 7):
    time.sleep(20)
    out = subprocess.run(
        ["tasklist", "/fi", "IMAGENAME eq SSJJ_BattleClient_Unity.exe"],
        capture_output=True,
    )
    txt = out.stdout.decode("gbk", "replace")
    alive = "SSJJ_BattleClient_Unity" in txt
    print("t=%ds alive=%s" % (i * 20, alive))
    sys.stdout.flush()
