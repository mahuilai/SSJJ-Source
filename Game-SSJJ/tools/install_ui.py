# -*- coding: utf-8 -*-
"""
安装原版战斗 HUD 所需的 UI 资源包到客户端。

用法:
    python install_ui.py            # 安装默认 HUD 包集合
    python install_ui.py --dry-run  # 只打印，不落盘

做的事:
  1. 从线上 manifest (_manifest_cache.xml) 递归求闭包：uiprefabs/weapon, uiprefabs/common,
     uiprefabs/group, uiprefabs/pvecommon 及其全部 Dependency
  2. 从 资源全集/{name}_{md5} 拷到客户端 StreamingAssets/AssetBundles/Windows/...
  3. 把条目（含 Dependency）写进本地 AssetBundles manifest（幂等，已存在则更新）
  4. 备份 AssetBundles -> AssetBundles.before-ui.bak
"""
import io
import os
import sys
import shutil
import hashlib
import xml.etree.ElementTree as ET

ROOT = r"D:\逆向\SSJJ双塔惊魂"
FULL_MANIFEST = os.path.join(ROOT, "_manifest_cache.xml")
POOL = os.path.join(ROOT, "资源全集")
CLIENT = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows"
LOCAL_MANIFEST = os.path.join(CLIENT, "AssetBundles")
BACKUP = os.path.join(CLIENT, "AssetBundles.before-ui.bak")

# 战斗 HUD 需要的顶层包。武器 HUD -> uiprefabs/weapon，其余模式按需。
SEEDS = [
    "uiprefabs/weapon",       # 弹药 / 武器图标 / 准星 / KillText / BulletNum
    "uiprefabs/common",       # 击杀播报 / HP 条 / 玩家列表
    "uiprefabs/group",        # 团队模式计分
    "uiprefabs/pvecommon",    # PVE 计分（保留，避免部分模式加载失败）
]


def load_full_index():
    tree = ET.parse(FULL_MANIFEST)
    idx = {}
    for ab in tree.getroot().findall("AssetBundle"):
        name = ab.get("name")
        idx[name] = {
            "md5": ab.get("md5") or "",
            "size": ab.get("size") or "0",
            "crc": ab.get("crc") or "0",
            "deps": [d.get("name") for d in ab.findall("Dependency")],
        }
    return idx


def closure(full, seeds):
    seen = []
    todo = list(seeds)
    while todo:
        n = todo.pop(0)
        if n in seen:
            continue
        if n not in full:
            print("  [WARN] 线上 manifest 里没有: %s" % n)
            continue
        seen.append(n)
        todo.extend(full[n]["deps"])
    return seen


def pool_path(name, md5):
    return os.path.join(POOL, "%s_%s" % (name.replace("/", "_"), md5)) if False else None


def find_in_pool(name, md5):
    """资源全集布局：{dir}/{base}_{md5}"""
    if "/" in name:
        d, base = name.rsplit("/", 1)
        p = os.path.join(POOL, d, "%s_%s" % (base, md5))
    else:
        p = os.path.join(POOL, "%s_%s" % (name, md5))
    return p


def client_path(name, md5):
    if "/" in name:
        d, base = name.rsplit("/", 1)
        return os.path.join(CLIENT, d, "%s_%s" % (base, md5))
    return os.path.join(CLIENT, "%s_%s" % (name, md5))


def md5_file(path, limit=None):
    h = hashlib.md5()
    with open(path, "rb") as f:
        while True:
            b = f.read(1 << 20)
            if not b:
                break
            h.update(b)
    return h.hexdigest()


def main():
    dry = "--dry-run" in sys.argv
    full = load_full_index()
    print("[1/4] 线上 manifest 条目: %d" % len(full))

    names = closure(full, SEEDS)
    print("[2/4] 闭包共 %d 个包" % len(names))

    # 检查资源是否齐全
    missing = []
    plan = []
    total_bytes = 0
    for n in names:
        info = full[n]
        src = find_in_pool(n, info["md5"])
        if not os.path.isfile(src):
            # 有的包 md5 与线上不一致（本地补充包），按前缀找
            alt = None
            d = os.path.dirname(src)
            base = os.path.basename(n) + "_"
            if os.path.isdir(d):
                for f in os.listdir(d):
                    if f.startswith(base):
                        alt = os.path.join(d, f)
                        break
            if alt is None:
                missing.append(n)
                continue
            src = alt
        plan.append((n, info, src))
        total_bytes += os.path.getsize(src)

    if missing:
        print("  [ERR] 资源全集缺 %d 个包: %s" % (len(missing), missing[:10]))
        return 1
    print("     总计 %.1f MB" % (total_bytes / 1048576.0))

    if dry:
        for n, info, src in plan:
            print("  %-45s %8d  deps=%s" % (n, os.path.getsize(src), info["deps"]))
        return 0

    # 备份 manifest
    if not os.path.exists(BACKUP):
        shutil.copy2(LOCAL_MANIFEST, BACKUP)
        print("[3/4] manifest 备份 -> %s" % BACKUP)

    # 拷包
    copied = skipped = 0
    for n, info, src in plan:
        dst = client_path(n, info["md5"])
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.isfile(dst) and os.path.getsize(dst) == os.path.getsize(src):
            skipped += 1
            continue
        shutil.copy2(src, dst)
        copied += 1
    print("[3/4] 拷贝 %d 个，跳过已有 %d 个" % (copied, skipped))

    # 更新 manifest
    tree = ET.parse(LOCAL_MANIFEST)
    root = tree.getroot()
    existing = {ab.get("name"): ab for ab in root.findall("AssetBundle")}
    added = updated = 0

    for n, info, src in plan:
        if n in existing:
            ab = existing[n]
            ab.set("md5", info["md5"])
            ab.set("crc", info["crc"])
            updated += 1
            continue
        ab = ET.SubElement(root, "AssetBundle")
        ab.set("name", n)
        ab.set("md5", info["md5"])
        ab.set("crc", info["crc"])
        for d in info["deps"]:
            e = ET.SubElement(ab, "Dependency")
            e.set("name", d)
        added += 1

    tree.write(LOCAL_MANIFEST, encoding="utf-8", xml_declaration=True)
    print("[4/4] manifest: 新增 %d 条，更新 %d 条，总条目 %d" % (added, updated, len(list(root))))

    # 校验可解析
    ET.parse(LOCAL_MANIFEST)
    print("      XML 校验通过")
    return 0


if __name__ == "__main__":
    sys.exit(main())
