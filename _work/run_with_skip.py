# -*- coding: utf-8 -*-
"""带 skip_modules 跑一局，监控存活时长；结束后打印模块日志与异常摘要。"""
import json
import os
import shutil
import subprocess
import sys
import time

CFG = r"D:\SSJJ-4399\battle\3_64\launch_config.json"
LOG = r"D:\SSJJ-4399\battle\3_64\log\offline.log"
BAK = CFG + ".run.bak"
PY = r"C:\Users\Mahuilai\.workbuddy\binaries\python\envs\default\Scripts\python.exe"

skip = sys.argv[1] if len(sys.argv) > 1 else ""
limit = int(sys.argv[2]) if len(sys.argv) > 2 else 200

shutil.copy2(CFG, BAK)
cfg = json.load(open(CFG, encoding="utf-8"))
cfg["full_modules"] = True
cfg["skip_modules"] = skip
json.dump(cfg, open(CFG, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("[run] skip=[%s] limit=%ds" % (skip, limit), flush=True)

try:
    subprocess.run([PY, r"D:\SSJJ-4399\start_offline.py"], capture_output=True)
    t0 = time.time()
    died = None
    while time.time() - t0 < limit:
        time.sleep(10)
        r = subprocess.run(["tasklist", "/FI", "IMAGENAME eq SSJJ_BattleClient_Unity.exe"],
                           capture_output=True, text=True, errors="replace")
        if "SSJJ_BattleClient" not in (r.stdout or ""):
            died = int(time.time() - t0)
            break
    print("[run] died_at=%s" % (died if died else "alive@%ds" % limit), flush=True)
    time.sleep(1)
    txt = open(LOG, "r", encoding="utf-8", errors="replace").read()
    for l in txt.splitlines():
        if "[OFFLINE-MODULE]" in l:
            print("  ", l.strip()[:120])
    errs = [l for l in txt.splitlines() if "error executing" in l]
    print("[run] system errors =", len(errs))
    for l in errs[:5]:
        print("  ", l.strip()[:150])
    nre = [l for l in txt.splitlines() if "NullReferenceException" in l]
    print("[run] NRE lines =", len(nre))
finally:
    shutil.copy2(BAK, CFG)
    os.remove(BAK)
    print("[run] config restored", flush=True)
