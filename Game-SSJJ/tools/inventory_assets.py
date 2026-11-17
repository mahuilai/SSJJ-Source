# -*- coding: utf-8 -*-
"""盘点可用资源：StreamingAssets（本地预装）+ 资源缓存（下载过的），
输出武器/角色清单（含是否有 $2 网格包、中文名）。

用法：python inventory_assets.py [--json out.json]
"""
import json
import os
import struct
import sys

import UnityPy

CACHE = r"D:/逆向/SSJJ双塔惊魂/资源缓存"
WIN = r"D:/SSJJ-4399/battle/3_64/SSJJ_BattleClient_Unity_Data/StreamingAssets/AssetBundles/Windows"
TABLES = WIN + r"/tables_610a381509f56f92e2226c8955b02aad"


def read_bundle_name(path):
    """读 bundle 内部 AssetBundle 名（判断是 X 还是 X$2）"""
    try:
        env = UnityPy.load(path)
        for o in env.objects:
            if o.type.name == "AssetBundle":
                return o.read().m_Name
    except Exception:
        pass
    return None


def has_mesh(path):
    try:
        env = UnityPy.load(path)
        return any(o.type.name == "Mesh" for o in env.objects)
    except Exception:
        return False


def scan_streaming():
    out = {}
    for root, dirs, files in os.walk(WIN):
        for fn in files:
            us = fn.rfind("_")
            if us <= 0:
                continue
            md5 = fn[us + 1:]
            if len(md5) != 32:
                continue
            rel = os.path.relpath(root, WIN).replace("\\", "/")
            name = (rel + "/" + fn[:us]) if rel != "." else fn[:us]
            out[name] = {"md5": md5, "path": os.path.join(root, fn), "src": "streaming"}
    return out


def scan_cache():
    out = {}
    if not os.path.isdir(CACHE):
        return out
    for d in os.listdir(CACHE):
        p = os.path.join(CACHE, d, "data")
        if not os.path.isfile(p):
            continue
        nm = read_bundle_name(p)
        if not nm:
            continue
        out[nm] = {"md5": d, "path": p, "src": "cache"}
    return out


def load_weapon_names():
    """Weapon 表：id -> 中文名"""
    mapping = {}
    try:
        env = UnityPy.load(TABLES)
        for o in env.objects:
            if o.type.name != "TextAsset":
                continue
            d = o.read()
            if d.m_Name != "Weapon":
                continue
            txt = d.m_Script
            if not isinstance(txt, str):
                txt = txt.decode("utf-8", "replace")
            for line in txt.splitlines():
                parts = line.split(",")
                if len(parts) > 3 and parts[0].startswith('"'):
                    wid = parts[0].strip('"')
                    cn = parts[2].strip('"') if len(parts) > 2 else ""
                    wtype = parts[3].strip('"') if len(parts) > 3 else ""
                    mapping.setdefault(wid, (cn, wtype))
    except Exception as ex:
        print("weapon table err:", ex)
    return mapping


def main():
    streaming = scan_streaming()
    cache = scan_cache()

    merged = {}
    for name, info in cache.items():
        merged[name] = dict(info)
    for name, info in streaming.items():
        base = name
        # streaming 里 weapon/ak47$2 形式也可能存在
        if base in merged:
            merged[base]["streaming_path"] = info["path"]
            merged[base]["streaming_md5"] = info["md5"]
        else:
            merged[base] = dict(info)

    # 武器：weapon/X + weapon/X$2
    weapons = {}
    for name, info in merged.items():
        if not name.startswith("weapon/"):
            continue
        short = name[7:]
        is_split = short.endswith("$2")
        short = short.replace("$2", "")
        w = weapons.setdefault(short, {"name": short})
        if is_split:
            w["mesh_bundle"] = info["md5"]
            w["mesh_src"] = info["src"]
        else:
            w["bundle"] = info["md5"]
            w["bundle_src"] = info["src"]

    names = load_weapon_names()
    for k, w in weapons.items():
        cn, wtype = names.get(k, ("", ""))
        w["cn"] = cn
        w["type"] = wtype
        w["complete"] = bool(w.get("mesh_bundle"))

    # 角色
    chars = {}
    for name, info in merged.items():
        if not name.startswith("player/"):
            continue
        short = name[7:]
        is_split = short.endswith("$2")
        short = short.replace("$2", "")
        c = chars.setdefault(short, {"name": short})
        if is_split:
            c["mesh_bundle"] = info["md5"]
        else:
            c["bundle"] = info["md5"]
        c["complete"] = bool(c.get("mesh_bundle"))

    # 地图
    maps = {}
    for name, info in merged.items():
        if name.startswith(("maps/", "unitymaps/", "modeconfig")):
            maps[name] = {"md5": info["md5"], "src": info["src"]}

    print("=" * 70)
    print("武器总数:", len(weapons), " 网格完整:", sum(1 for w in weapons.values() if w["complete"]))
    print("角色总数:", len(chars), " 网格完整:", sum(1 for c in chars.values() if c["complete"]))
    print("地图包  :", len(maps))

    print("\n--- 武器（网格完整）---")
    for k in sorted(weapons):
        w = weapons[k]
        if w["complete"]:
            print("  %-24s %-14s %s" % (k, w["cn"], w["type"]))

    print("\n--- 武器（缺网格）---")
    miss = [k for k in sorted(weapons) if not weapons[k]["complete"]]
    print("  " + ", ".join(miss))

    print("\n--- 角色（网格完整）---")
    for k in sorted(chars):
        if chars[k]["complete"]:
            print("  ", k)

    print("\n--- 角色（缺网格）---")
    print("  " + ", ".join(k for k in sorted(chars) if not chars[k]["complete"]))

    print("\n--- 地图包 ---")
    for k in sorted(maps):
        print("  ", k)

    if "--json" in sys.argv:
        outp = sys.argv[sys.argv.index("--json") + 1]
        json.dump({"weapons": weapons, "characters": chars, "maps": maps},
                  open(outp, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
        print("\nJSON:", outp)


if __name__ == "__main__":
    main()
