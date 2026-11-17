# -*- coding: utf-8 -*-
"""把 ssjj-port 的 jar 装进 OneClient 的 1.21.1 Fabric 集群（幂等）。"""
import glob
import os
import shutil

SRC = r"D:\逆向\SSJJ双塔惊魂\ssjj-port\build\libs"
DST = r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft\mods\1.21.1 Fabric"


def main():
    cands = [p for p in glob.glob(os.path.join(SRC, "ssjj-port-*.jar"))
             if "sources" not in os.path.basename(p)]
    if not cands:
        print("no jar in", SRC)
        return 1
    jar = max(cands, key=os.path.getmtime)
    for old in glob.glob(os.path.join(DST, "ssjj-port-*.jar")):
        os.remove(old)
        print("removed old:", os.path.basename(old))
    dst = os.path.join(DST, os.path.basename(jar))
    shutil.copy2(jar, dst)
    print("installed:", dst, os.path.getsize(dst), "B")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
