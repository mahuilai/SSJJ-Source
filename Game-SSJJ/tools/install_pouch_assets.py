# -*- coding: utf-8 -*-
"""安装手雷包三槽需要的投掷物资源：weapon/flashgrenade、weapon/smoke（含 $2）。

这两个包不在官方清单里（prepare_launch_assets 会跳过），但资源全集里有。
这里直接按“池文件 <leaf>_<md5>” 复制到 StreamingAssets 并写入本地清单。
可重复执行；会先备份 AssetBundles -> AssetBundles.pouch.bak。
"""
import os
import re
import shutil
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prepare_launch_assets as P

TARGETS = [
    "weapon/flashgrenade",
    "weapon/flashgrenade$2",
    "weapon/smoke",
    "weapon/smoke$2",
]
HEX32 = re.compile(r"_([0-9a-fA-F]{32})$")


def find_pool_file(name):
    leaf = name.split("/")[-1]
    sub = name.split("/")[0]
    directory = P.POOL / sub
    if not directory.is_dir():
        return None
    prefix = leaf + "_"
    for f in directory.iterdir():
        if not f.is_file() or not f.name.startswith(prefix):
            continue
        m = HEX32.search(f.name)
        if m:
            return f, m.group(1)
    return None


def main():
    dry = "--dry" in sys.argv
    tree = ET.parse(P.MANIFEST)
    root = tree.getroot()
    existing = {e.get("name", "").lower(): e for e in root.findall("AssetBundle")}
    added = copied = 0
    for name in TARGETS:
        hit = find_pool_file(name)
        if not hit:
            P.log("install-pouch: %s not found in pool" % name)
            continue
        src, md5 = hit
        dst_dir = P.BUNDLE_ROOT / name.split("/")[0]
        dst = dst_dir / (name.split("/")[-1] + "_" + md5)
        if not dry:
            dst_dir.mkdir(parents=True, exist_ok=True)
            if not dst.is_file() or dst.stat().st_size != src.stat().st_size:
                shutil.copy2(src, dst)
                copied += 1
                P.log("install-pouch: copied %s -> %s" % (name, dst))
        node = existing.get(name.lower())
        if node is None:
            if not dry:
                node = ET.SubElement(root, "AssetBundle", {"name": name, "md5": md5, "crc": "0"})
                if name.endswith("$2"):
                    pass
                else:
                    dep = "weapon/" + name.split("/")[-1] + "$2"
                    if dep.lower() in existing:
                        ET.SubElement(node, "Dependency", {"name": dep})
                existing[name.lower()] = node
                added += 1
                P.log("install-pouch: manifest + %s" % name)
        elif node.get("md5") != md5:
            if not dry:
                node.set("md5", md5)
                P.log("install-pouch: manifest ~ %s" % name)
    if (added or copied) and not dry:
        if not (P.BUNDLE_ROOT / "AssetBundles.pouch.bak").is_file():
            shutil.copy2(P.MANIFEST, P.BUNDLE_ROOT / "AssetBundles.pouch.bak")
        if hasattr(ET, "indent"):
            ET.indent(tree, space="  ")
        tmp = P.MANIFEST.with_suffix(".tmp")
        tree.write(tmp, encoding="utf-8", xml_declaration=True)
        ET.parse(tmp)
        os.replace(tmp, P.MANIFEST)
        P.log("install-pouch: manifest saved, total=%d" % len(existing))
    P.log("install-pouch: done added=%d copied=%d%s" % (added, copied, " (dry)" if dry else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
