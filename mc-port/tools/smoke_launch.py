# -*- coding: utf-8 -*-
"""P0.5-G: 复用 OneClient 生成的启动命令，冒烟 1.21.1 Fabric 集群。

cluster-output.log 的前几行是启动器实际执行的 PowerShell 命令块（含 JDK21、
classpath、fabric.modsFolder、认证参数）。这里解析成 argv 直接拉起 javaw，
再轮询 clusters/1.21.1 Fabric/logs/latest.log 判断 TACZ / TML 是否载入。

用法:
  python smoke_launch.py --dry   只打印解析结果（脱敏），不启动
  python smoke_launch.py         启动并等待最多 180 秒，输出冒烟结论，然后保持守护
"""
import argparse
import os
import re
import subprocess
import sys
import time

BASE = r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient"
CLUSTER_LOG = os.path.join(BASE, "clusters", "1.21.1 Fabric", "cluster-output.log")
GAME_LOG = os.path.join(BASE, "clusters", "1.21.1 Fabric", "logs", "latest.log")
GAME_DIR = os.path.join(BASE, ".minecraft")


def redact(s):
    return re.sub(r"([A-Za-z0-9_.\-]{28,})", "<REDACTED>", s)


def parse_command():
    with open(CLUSTER_LOG, "r", encoding="utf-8", errors="replace") as f:
        lines = f.read().splitlines()
    start = None
    for i, ln in enumerate(lines[:40]):
        if ln.lstrip().startswith("& ") and "javaw.exe" in ln:
            start = i
            break
    if start is None:
        raise RuntimeError("cannot find javaw launch line in " + CLUSTER_LOG)

    java = re.search(r"&\s*'([^']+)'", lines[start]).group(1)
    argv = [java]
    end = start
    buf = lines[start].split("&", 1)[1]
    tokens = []
    for j in range(start, min(start + 80, len(lines))):
        raw = lines[j].rstrip()
        cont = raw.endswith("`")
        if cont:
            raw = raw[:-1].rstrip()
        if j == start:
            raw = raw.split("'", 2)[-1] if raw.count("'") >= 2 else ""
        for m in re.finditer(r"'([^']*)'|([^\s'`]+)", raw):
            tok = m.group(1) if m.group(1) is not None else m.group(2)
            if tok and tok not in ("&",):
                tokens.append(tok)
        end = j
        if not cont:
            break
    argv += tokens
    return argv, end - start + 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry", action="store_true")
    ap.add_argument("--wait", type=int, default=180)
    ap.add_argument("--no-hold", action="store_true")
    args = ap.parse_args()

    argv, nlines = parse_command()
    print("parsed %d lines, %d argv tokens" % (nlines, len(argv)))
    print("java:", argv[0])
    print("java exists:", os.path.isfile(argv[0]))
    print("modsFolder:", next((x for x in argv if x.startswith("-Dfabric.modsFolder=")), "MISSING"))
    if args.dry:
        for a in argv[1:]:
            print("  ", redact(a)[:150])
        return

    before = os.path.getsize(GAME_LOG) if os.path.isfile(GAME_LOG) else 0
    print("launching (cwd=%s) ..." % GAME_DIR, flush=True)
    flags = 0
    if hasattr(subprocess, "DETACHED_PROCESS"):
        flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP
    p = subprocess.Popen(argv, cwd=GAME_DIR, creationflags=flags,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("pid=%d" % p.pid, flush=True)

    deadline = time.time() + args.wait
    seen_fabric = seen_tacz = seen_tml = False
    errors = []
    last_size = -1
    while time.time() < deadline:
        time.sleep(5)
        if p.poll() is not None:
            print("process exited rc=%s" % p.returncode, flush=True)
            break
        if not os.path.isfile(GAME_LOG):
            continue
        sz = os.path.getsize(GAME_LOG)
        if sz == last_size:
            continue
        last_size = sz
        with open(GAME_LOG, "r", encoding="utf-8", errors="replace") as f:
            text = f.read()
        low = text.lower()
        if "fabric loader 0.20.1" in low:
            seen_fabric = True
        if "tacz" in low and ("loading" in low or "mod" in low):
            seen_tacz = True
        if "taczmeshloader" in low or "tacz mesh loader" in low or "mesh loader" in low:
            seen_tml = True
        for line in text.splitlines():
            if any(k in line for k in ("Mixin apply failed", "Caused by:", "Failed to load mod",
                                       "ModResolutionException", " crashed!", "---- Minecraft Crash Report ----")):
                if line not in errors:
                    errors.append(line)
        if seen_tacz and seen_tml and ("Loading 56 mods" in text or "Reloading" in text or sz > 120000):
            break

    print("=== 冒烟结论 ===", flush=True)
    print("  Fabric Loader 0.20.1 :", seen_fabric)
    print("  TACZ 载入痕迹        :", seen_tacz)
    print("  TML 载入痕迹         :", seen_tml)
    print("  latest.log 大小      :", last_size)
    print("  严重错误行数         :", len(errors))
    for e in errors[:6]:
        print("    ", redact(e[:160]))
    with open(GAME_LOG, "r", encoding="utf-8", errors="replace") as f:
        hits = [l for l in f if re.search(r"tacz|mesh.?loader|forgeconfig", l, re.I)]
    print("  模组相关日志 (末 8 条):")
    for h in hits[-8:]:
        print("    ", redact(h.strip())[:170])

    if not args.no_hold:
        print("holding game process (Ctrl-C to exit) ...", flush=True)
        try:
            p.wait()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
