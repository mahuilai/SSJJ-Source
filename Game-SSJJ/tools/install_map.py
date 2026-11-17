#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把官方地图包装进离线客户端：拷包 + manifest 条目 + 校验 + 备份回滚 + 幂等。

用法：
    python install_map.py --scene-id 12           # 装 map12
    python install_map.py --scene-id 12,43,100000 # 一次多张
    python install_map.py --scene-id 12 --dry-run # 只打印不落盘

要点：
  * 文件名必须是 {bundleName}_{md5}，客户端按这个名字查找，不能改。
  * md5/crc/size 一律取自官方全量清单 _manifest_cache.xml，不要自己算。
  * manifest 是 XML，改坏一个标签客户端就卡加载 0%，所以：备份 -> 写临时文件 -> ET 校验 -> 才替换。
  * 幂等：已存在且 md5 一致就跳过。
"""
import argparse
import os
import re
import shutil
import sys
import time
import xml.etree.ElementTree as ET

GAME_ROOT = r"D:\SSJJ-4399\battle\3_64"
BUNDLE_ROOT = os.path.join(GAME_ROOT, "SSJJ_BattleClient_Unity_Data",
                           "StreamingAssets", "AssetBundles", "Windows")
MANIFEST = os.path.join(BUNDLE_ROOT, "AssetBundles")
BAK = MANIFEST + ".map.bak"
POOL = r"D:\逆向\SSJJ双塔惊魂\资源全集"
OFFICIAL = r"D:\逆向\SSJJ双塔惊魂\_manifest_cache.xml"


def log(msg):
    print("[install_map] %s" % msg, flush=True)


def load_official():
    """返回 {name: {md5, crc, size, deps}}"""
    txt = open(OFFICIAL, encoding="utf-8", errors="replace").read()
    out = {}
    for m in re.finditer(r"<AssetBundle\s+([^>]*?)(?:/>|>(.*?)</AssetBundle>)", txt, re.S):
        d = dict(re.findall(r'(\w+)="([^"]*)"', m.group(1)))
        name = d.get("name")
        if not name:
            continue
        deps = re.findall(r'<Dependency name="([^"]+)"', m.group(2) or "")
        out[name] = {"md5": d.get("md5", ""), "crc": d.get("crc", "0"),
                     "size": d.get("size", "0"), "deps": deps}
    return out


def find_map_file(scene_id):
    """在资源全集里找 map<id>_<md5>，返回 (文件名, 完整路径)"""
    d = os.path.join(POOL, "maps")
    if not os.path.isdir(d):
        return None, None
    pat = re.compile(r"^map%d_([0-9a-f]{32})$" % scene_id)
    best = None
    for f in os.listdir(d):
        m = pat.match(f)
        if m:
            p = os.path.join(d, f)
            if best is None or os.path.getsize(p) > os.path.getsize(best[1]):
                best = (f, p)
    return best if best else (None, None)


def backup():
    if not os.path.isfile(BAK):
        shutil.copy2(MANIFEST, BAK)
        log("backup -> %s" % os.path.basename(BAK))


def read_manifest():
    try:
        return ET.fromstring(open(MANIFEST, encoding="utf-8").read())
    except Exception as ex:
        log("manifest 解析失败 %r，尝试用备份恢复" % ex)
        if os.path.isfile(BAK):
            shutil.copy2(BAK, MANIFEST)
            return ET.fromstring(open(MANIFEST, encoding="utf-8").read())
        raise


def write_manifest(root):
    """写临时文件 -> ET 校验 -> 替换，任何一步失败都回滚"""
    backup()
    tmp = MANIFEST + ".tmp"
    data = ET.tostring(root, encoding="unicode")
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(data)
    ET.fromstring(open(tmp, encoding="utf-8").read())   # 校验
    os.replace(tmp, MANIFEST)
    log("manifest 已更新并通过 XML 校验")


def upsert(root, name, info):
    """插入或更新条目，返回 'added'/'updated'/'same'"""
    for node in root.findall("AssetBundle"):
        if (node.get("name") or "") == name:
            if node.get("md5") == info["md5"]:
                return "same"
            node.set("md5", info["md5"])
            node.set("crc", info["crc"])
            node.set("size", info["size"])
            return "updated"
    node = ET.SubElement(root, "AssetBundle")
    node.set("crc", info["crc"])
    node.set("md5", info["md5"])
    node.set("name", name)
    node.set("size", info["size"])
    return "added"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene-id", required=True, help="地图 ID，可逗号分隔，如 12,43,100000")
    ap.add_argument("--client-root", default=GAME_ROOT)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    global BUNDLE_ROOT, MANIFEST, BAK
    BUNDLE_ROOT = os.path.join(args.client_root, "SSJJ_BattleClient_Unity_Data",
                               "StreamingAssets", "AssetBundles", "Windows")
    MANIFEST = os.path.join(BUNDLE_ROOT, "AssetBundles")
    BAK = MANIFEST + ".map.bak"

    try:
        ids = [int(x) for x in re.split(r"[,\s]+", args.scene_id.strip()) if x]
    except ValueError:
        log("--scene-id 必须是数字（可逗号分隔）")
        return 2

    if not os.path.isfile(MANIFEST):
        log("manifest 不存在: %s" % MANIFEST)
        return 1
    if not os.path.isfile(OFFICIAL):
        log("官方清单不存在: %s" % OFFICIAL)
        return 1

    official = load_official()
    log("官方清单 %d 条" % len(official))
    root = read_manifest()

    todo = []   # (bundle_name, src_path, info, action)
    for sid in ids:
        name = "maps/map%d" % sid
        info = official.get(name)
        if not info:
            log("!! 官方清单里没有 %s（地图 ID 可能不存在）" % name)
            continue
        fname, src = find_map_file(sid)
        if not src:
            log("!! 资源全集里找不到 map%d_* 文件" % sid)
            continue
        # 官方 md5 与文件名里的 md5 必须一致
        if info["md5"] and not fname.endswith("_" + info["md5"]):
            log("!! %s md5 不一致：文件=%s 清单=%s" % (name, fname, info["md5"]))
            continue
        todo.append((name, src, info, fname))

    if not todo:
        log("没有可安装的地图")
        return 1

    # 连带依赖（官方清单里该地图的 Dependency）
    extra = []
    for name, src, info, fname in list(todo):
        for dep in info["deps"]:
            if dep in [t[0] for t in todo] or dep in [e[0] for e in extra]:
                continue
            dinfo = official.get(dep)
            if not dinfo:
                log("!! 依赖 %s 不在官方清单" % dep)
                continue
            dsrc = os.path.join(POOL, (dep + "_" + dinfo["md5"]).replace("/", os.sep))
            if os.path.isfile(dsrc):
                extra.append((dep, dsrc, dinfo, os.path.basename(dsrc)))
            else:
                log("!! 依赖文件缺失 %s" % dsrc)

    log("\n计划安装 %d 个主包 + %d 个依赖：" % (len(todo), len(extra)))
    total = 0
    for name, src, info, fname in todo + extra:
        sz = os.path.getsize(src)
        total += sz
        dst = os.path.join(BUNDLE_ROOT, (name + "_" + info["md5"]).replace("/", os.sep))
        exists = os.path.isfile(dst)
        log("  %-24s %8.2f MB  -> %s%s" % (name, sz / 1048576,
            os.path.basename(dst), "  (已存在)" if exists else ""))
    log("  合计 %.2f MB" % (total / 1048576))

    if args.dry_run:
        log("dry-run，未落盘")
        return 0

    # 1) 拷包（先拷后改 manifest，避免 manifest 有条目但文件没到）
    for name, src, info, fname in todo + extra:
        dst = os.path.join(BUNDLE_ROOT, (name + "_" + info["md5"]).replace("/", os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.isfile(dst) and os.path.getsize(dst) == int(info["size"] or 0):
            log("  跳过（已存在且体积一致）: %s" % os.path.basename(dst))
            continue
        tmp = dst + ".part"
        shutil.copyfile(src, tmp)
        os.replace(tmp, dst)
        log("  已拷贝 %s" % os.path.basename(dst))

    # 2) 更新 manifest
    acts = {}
    for name, src, info, fname in todo + extra:
        acts[name] = upsert(root, name, info)
    write_manifest(root)

    log("\n完成：")
    for name, act in acts.items():
        log("  %-24s %s" % (name, act))
    log("\n下一步：launch_config.json 设 \"map\": \"map%d\"，然后启动。" % ids[0])
    return 0


if __name__ == "__main__":
    sys.exit(main())
