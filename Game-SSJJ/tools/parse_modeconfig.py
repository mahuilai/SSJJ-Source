#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""解析 modeconfig 包：401 个游戏模式的类型/图标/特效/UI 资源，输出模式目录。"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

import UnityPy

DEST = r"D:/逆向/SSJJ双塔惊魂/资源全集"
OUT_JSON = r"D:/逆向/SSJJ双塔惊魂/资源全集/MODES.json"
OUT_TXT = r"D:/逆向/SSJJ双塔惊魂/资源全集/MODES.txt"


def find_bundle(prefix):
    for f in os.listdir(DEST):
        if f.startswith(prefix):
            return os.path.join(DEST, f)
    return None


def main():
    p = find_bundle("modeconfig_")
    if not p:
        print("modeconfig 包未找到")
        return
    env = UnityPy.load(p)
    modes = {}
    for o in env.objects:
        if o.type.name != "TextAsset":
            continue
        try:
            d = o.read()
        except Exception:
            continue
        raw = d.m_Script
        txt = raw if isinstance(raw, str) else bytes(raw).decode("utf-8", "replace")
        try:
            root = ET.fromstring(txt)
        except Exception:
            continue
        rec = {
            "id": d.m_Name,
            "type": (root.findtext("modeType") or "").strip(),
            "image": (root.findtext("modeImage") or "").strip(),
            "title_image": [],
            "effect": [],
            "ui": [],
        }
        ti = root.find("modeTitleImage")
        if ti is not None:
            if (ti.text or "").strip():
                rec["title_image"].append(ti.text.strip())
            for c in ti:
                if (c.text or "").strip():
                    rec["title_image"].append(c.text.strip())
        er = root.find("effectRes")
        if er is not None:
            for c in er:
                if (c.text or "").strip():
                    rec["effect"].append(c.text.strip())
        ur = root.find("uiRes")
        if ur is not None:
            for c in ur:
                if (c.text or "").strip():
                    rec["ui"].append(c.text.strip())
        modes[rec["id"]] = rec

    by_type = {}
    for m in modes.values():
        by_type.setdefault(m["type"] or "(空)", []).append(m["id"])

    def sid(x):
        try:
            return (0, int(x))
        except ValueError:
            return (1, x)

    lines = []
    lines.append("SSJJ 模式配置目录（来自 modeconfig 包，%d 个模式）" % len(modes))
    lines.append("")
    lines.append("== 按 modeType 统计 ==")
    for t, ids in sorted(by_type.items(), key=lambda x: -len(x[1])):
        lines.append("  %-8s %4d 个" % (t, len(ids)))
    lines.append("")
    for t, ids in sorted(by_type.items(), key=lambda x: -len(x[1])):
        lines.append("== %s (%d) ==" % (t, len(ids)))
        for mid in sorted(ids, key=sid):
            m = modes[mid]
            eff = ",".join(m["effect"]) if m["effect"] else "-"
            lines.append("  %-8s img=%-22s effect=%s" % (mid, m["image"][:22], eff[:60]))
        lines.append("")

    open(OUT_TXT, "w", encoding="utf-8").write("\n".join(lines))
    json.dump({
        "source": "modeconfig bundle (AssetBundle)",
        "count": len(modes),
        "by_type": {k: len(v) for k, v in by_type.items()},
        "modes": modes,
    }, open(OUT_JSON, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    print("[*] 模式总数: %d" % len(modes))
    print("[*] 类型分布:", {k: len(v) for k, v in sorted(by_type.items(), key=lambda x: -len(x[1]))})
    print("[*] 输出:", OUT_JSON, "/", OUT_TXT)


if __name__ == "__main__":
    main()
