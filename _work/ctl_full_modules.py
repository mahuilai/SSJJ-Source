# -*- coding: utf-8 -*-
"""对照实验：full_modules=false，看是否同样在 ~2 分钟内静默退出。"""
import json
import os
import shutil
import subprocess
import time

CFG = r"D:\SSJJ-4399\battle\3_64\launch_config.json"
BAK = CFG + ".ctl.bak"
PY = r"C:\Users\Mahuilai\.workbuddy\binaries\python\envs\default\Scripts\python.exe"

shutil.copy2(CFG, BAK)
cfg = json.load(open(CFG, encoding="utf-8"))
cfg["full_modules"] = False
json.dump(cfg, open(CFG, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("[ctl] full_modules=false")

try:
    subprocess.run([PY, r"D:\SSJJ-4399\start_offline.py"], capture_output=True)
    t0 = time.time()
    for i in range(10):
        time.sleep(20)
        r = subprocess.run(["tasklist", "/FI", "IMAGENAME eq SSJJ_BattleClient_Unity.exe"],
                           capture_output=True, text=True, errors="replace")
        alive = "SSJJ_BattleClient" in (r.stdout or "")
        print("[ctl] t=%3ds alive=%s" % (int(time.time() - t0), alive), flush=True)
        if not alive:
            break
finally:
    shutil.copy2(BAK, CFG)
    os.remove(BAK)
    print("[ctl] config restored")
