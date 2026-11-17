#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把 资源全集 整理成启动器可直接消费的索引：武器/角色/地图/皮肤，标注主包+$2 完整性。"""
import json
import os
import sys

sys.path.insert(0, r"D:/逆向/SSJJ双塔惊魂/Game-SSJJ/tools")
from pull_resources import parse_manifest

DEST = r"D:/逆向/SSJJ双塔惊魂/资源全集"
MANIFEST = r"D:/逆向/SSJJ双塔惊魂/_manifest_cache.xml"
OUT = r"D:/逆向/SSJJ双塔惊魂/资源全集/INDEX.json"
OUT_TXT = r"D:/逆向/SSJJ双塔惊魂/资源全集/INDEX.txt"


def main():
    items = parse_manifest(open(MANIFEST, encoding="utf-8", errors="replace").read())
    by_name = {i["name"]: i for i in items}

    def entry(name):
        it = by_name.get(name)
        if not it:
            return None
        rel = ("%s_%s" % (it["name"], it["md5"])).replace("/", "\\")
        return {"name": it["name"], "md5": it["md5"], "size": it["size"],
                "file": rel, "exists": os.path.isfile(os.path.join(DEST, rel.replace("\\", os.sep)))}

    def collect(prefix):
        """把 X 和 X$2 配成一对：main=主包，mesh=网格包"""
        out = {}
        for it in items:
            n = it["name"]
            if not n.startswith(prefix):
                continue
            rest = n[len(prefix):]
            if "/" in rest:
                continue
            is_mesh = rest.endswith("$2")
            base = rest[:-2] if is_mesh else rest
            rec = out.setdefault(base, {"main": None, "mesh": None})
            rec["mesh" if is_mesh else "main"] = entry(n)
        return out

    weapons = collect("weapon/")
    players = collect("player/")
    maps = {}
    for it in items:
        n = it["name"]
        if n.startswith("maps/") and "/" not in n[5:] and not n.endswith(".bytes"):
            maps[n] = entry(n)
    viewhand = collect("viewhand/")
    playerskin = collect("playerskin/")
    weaponskin = collect("weaponskin/")

    def summarize(d, label):
        full, main_only = [], []
        for k, v in sorted(d.items()):
            if not v["main"]:
                continue
            (full if v["mesh"] else main_only).append(k)
        return {"total": len(full) + len(main_only), "complete": len(full),
                "complete_names": full, "main_only_names": main_only}

    index = {
        "generated_from": "cdn.4399ssjj.com/s3/Windows 官方清单",
        "bundle_total": len(items),
        "bundle_bytes": sum(i["size"] for i in items),
        "weapons": {k: {"main": v["main"], "mesh": v["mesh"]} for k, v in sorted(weapons.items())},
        "players": {k: {"main": v["main"], "mesh": v["mesh"]} for k, v in sorted(players.items())},
        "viewhand": {k: {"main": v["main"], "mesh": v["mesh"]} for k, v in sorted(viewhand.items())},
        "maps": {k: v for k, v in sorted(maps.items())},
        "weaponskin": {k: {"main": v["main"], "mesh": v["mesh"]} for k, v in sorted(weaponskin.items())},
        "playerskin": {k: {"main": v["main"], "mesh": v["mesh"]} for k, v in sorted(playerskin.items())},
        "summary": {
            "weapons": summarize(weapons, "weapon"),
            "players": summarize(players, "player"),
            # 手模包自身内含 Mesh，不需要 $2 配对
            "viewhand": {"total": sum(1 for v in viewhand.values() if v["main"]),
                         "complete": sum(1 for v in viewhand.values() if v["main"]),
                         "complete_names": [k for k, v in sorted(viewhand.items()) if v["main"]],
                         "main_only_names": []},
            "weaponskin": summarize(weaponskin, "weaponskin"),
            "playerskin": summarize(playerskin, "playerskin"),
            "maps": {"total": len(maps)},
        },
    }
    json.dump(index, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    lines = []
    lines.append("SSJJ 资源全集索引")
    lines.append("来源: cdn.4399ssjj.com/s3/Windows  共 %d 包 / %.1f GB" % (len(items), index["bundle_bytes"] / 2**30))
    lines.append("")
    for key, title in [("weapons", "武器"), ("players", "角色"), ("viewhand", "手模"),
                       ("weaponskin", "武器皮肤"), ("playerskin", "角色皮肤")]:
        s = index["summary"][key]
        lines.append("== %s: %d 个（主包+网格完整 %d）" % (title, s["total"], s["complete"]))
        lines.append("   完整: " + ", ".join(s["complete_names"][:60]))
        if s["main_only_names"]:
            lines.append("   仅主包(无网格): " + ", ".join(s["main_only_names"][:30]))
        lines.append("")
    lines.append("== 地图包: %d 个" % len(maps))
    for k, v in sorted(maps.items()):
        lines.append("   %-28s %7.1f MB" % (k, (v["size"] if v else 0) / 1048576))
    open(OUT_TXT, "w", encoding="utf-8").write("\n".join(lines))

    print("[*] INDEX.json 已生成: %s" % OUT)
    print("[*] 武器 %d（完整 %d）/ 角色 %d（完整 %d）/ 视图模型 %d / 地图包 %d" % (
        index["summary"]["weapons"]["total"], index["summary"]["weapons"]["complete"],
        index["summary"]["players"]["total"], index["summary"]["players"]["complete"],
        index["summary"]["viewhand"]["total"], len(maps)))
    print("\n".join(lines[:18]))


if __name__ == "__main__":
    main()
