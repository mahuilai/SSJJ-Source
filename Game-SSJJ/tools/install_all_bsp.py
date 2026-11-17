# -*- coding: utf-8 -*-
"""把所有地图包里的 IBSP 原始数据抽到 StreamingAssets/map<id>/model.bsp.raw。

离线端的出生点/碰撞兜底读这个文件；官方只带了少数几张图的 raw，
其余地图（如 map791）会因缺 raw 出生在界外。
- 只处理 Quake3 IBSP（头 4 字节 = IBSP）；自定义格式（如 SCE）跳过并记日志。
- 可重复执行；已存在且头合法的直接跳过。
- 用法：python install_all_bsp.py [--dry]
"""
import os
import re
import sys
import time
from pathlib import Path

import UnityPy

POOL = Path(r"D:\逆向\SSJJ双塔惊魂\资源全集\maps")
OUT = Path(r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets")
NAME = re.compile(r"^map(\d+)_([0-9a-f]{32})$")


def log(msg):
    print(msg, flush=True)


def main():
    dry = "--dry" in sys.argv
    bundles = []
    for f in POOL.iterdir():
        m = NAME.match(f.name)
        if m and f.is_file():
            bundles.append((int(m.group(1)), f))
    bundles.sort()
    log("install-bsp: bundles=%d" % len(bundles))
    done = skipped = custom = failed = 0
    t0 = time.time()
    for i, (sid, f) in enumerate(bundles, 1):
        outdir = OUT / ("map%d" % sid)
        out = outdir / "model.bsp.raw"
        if out.is_file():
            try:
                head = out.open("rb").read(4)
                if head == b"IBSP":
                    skipped += 1
                    continue
            except Exception:
                pass
        try:
            env = UnityPy.load(str(f))
            saved = None
            for o in env.objects:
                if o.type.name != "TextAsset":
                    continue
                d = o.read()
                raw = d.m_Script
                if isinstance(raw, str):
                    raw = raw.encode("latin-1", "surrogateescape")
                if raw[:4] == b"IBSP":
                    saved = raw
                    break
            if saved is None:
                custom += 1
                log("install-bsp: map%d 非 IBSP（跳过）" % sid)
                continue
            if not dry:
                outdir.mkdir(parents=True, exist_ok=True)
                out.write_bytes(saved)
            done += 1
            log("install-bsp: map%d ok %.1fMB (%d/%d)" % (sid, len(saved) / 1048576.0, i, len(bundles)))
        except Exception as ex:
            failed += 1
            log("install-bsp: map%d FAIL %r" % (sid, ex))
        if i % 25 == 0:
            log("install-bsp: progress %d/%d done=%d skip=%d custom=%d fail=%d %.0fs"
                % (i, len(bundles), done, skipped, custom, failed, time.time() - t0))
    log("install-bsp: finished done=%d skipped=%d custom=%d failed=%d in %.0fs"
        % (done, skipped, custom, failed, time.time() - t0))
    return 0


if __name__ == "__main__":
    sys.exit(main())
