# -*- coding: utf-8 -*-
"""按模式武器池批量接入武器包。

复用 prepare_launch_assets 的 ensure_bundle / 依赖闭包 / manifest 写回逻辑，
但武器列表来自 OfflineModeTable 对应的实测池（刀锋 15 / 人机团战 2003）。

用法：
  python install_mode_weapons.py            # 装两个模式的武器池
  python install_mode_weapons.py 15         # 只装刀锋
  python install_mode_weapons.py 2003       # 只装团战
  python install_mode_weapons.py 15 --dry   # 只看缺什么，不写盘
"""
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, __file__.rsplit("\\", 1)[0])
import prepare_launch_assets as P

# 与 OfflineModeTable.cs 保持一致（2026-10-24 抓包实测）
MODE_WEAPONS = {
    15: ["double_fangs_g", "ice_ax", "axe_g", "shovel_g", "nbr_knife_g", "blood_shadow_sword"],
    2003: [
        "blood_machinegun", "aa12_hero1", "double_fangs_g", "m4a1_g1", "ice_ax",
        "deagle_g", "m4", "colt_boa", "shovel_g", "barrett_m107_g",
        "grenade_wukong", "grenade_star_dark", "axe_g", "grenade_pumpkin",
        "viper", "double_infinity_g", "grenade_mooncake", "nbr_knife_g", "viper_rage",
    ],
}


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry" in sys.argv
    targets = [int(a) for a in args] if args else sorted(MODE_WEAPONS.keys())

    official = P.load_official_manifest()
    if not official:
        P.log("install: official manifest missing, abort")
        return 1

    changed, skipped = [], []
    required = []

    def add(n):
        if n not in required:
            required.append(n)

    for rt in targets:
        for w in MODE_WEAPONS.get(rt, []):
            add("weapon/" + w)
            add("weapon/" + w + "$2")
            add("sound/weapon/" + w)

    P.log("install: modes=%s weapons=%d bundles_to_check=%d" % (targets, sum(len(MODE_WEAPONS.get(t, [])) for t in targets), len(required)))

    entries = {}
    for name in required:
        e = P.ensure_bundle(name, official, changed, skipped) if not dry else None
        if e:
            entries[name] = e
        elif dry:
            info = official.get(name.lower())
            st = "NO-SOURCE" if info else "NOT-IN-MANIFEST"
            if info and P.find_source(name, info)[0] is not None:
                st = "READY"
            P.log("  [dry] %-40s %s" % (name, st))

    if dry:
        P.log("install: dry run, nothing written")
        return 0

    # 依赖闭包（官方有的照抄；主包<->$2 互依）
    deps_by_name = {}
    q = list(required)
    seen = set()
    while q:
        name = q.pop(0)
        if name.lower() in seen:
            continue
        seen.add(name.lower())
        e = entries.get(name)
        if not e:
            continue
        deps = list(e["deps"])
        if not deps and name.endswith("$2") and name[:-2] in entries:
            deps = [name[:-2]]
        elif not deps and (name + "$2") in entries:
            deps = [name + "$2"]
        deps_by_name[name] = deps
        for d in deps:
            if d in entries:
                if d not in deps_by_name:
                    q.append(d)
                continue
            de = P.ensure_bundle(d, official, changed, skipped)
            if de:
                entries[d] = de
                if d not in required:
                    required.append(d)
                deps_by_name[d] = list(de["deps"])
            else:
                P.log("install: dependency missing %s (needed by %s)" % (d, name))

    # 写 manifest
    if not P.MANIFEST.is_file():
        P.log("install: manifest missing %s" % P.MANIFEST)
        return 1
    bak = P.BUNDLE_ROOT / "AssetBundles.mode.bak"
    if not bak.is_file():
        import shutil
        shutil.copy2(P.MANIFEST, bak)

    tree = ET.parse(P.MANIFEST)
    root = tree.getroot()
    existing = {n.get("name").lower(): n for n in root.findall("AssetBundle") if n.get("name")}
    dirty = False
    for name in required:
        e = entries.get(name)
        if not e:
            continue
        node = existing.get(name.lower())
        if node is None:
            node = ET.SubElement(root, "AssetBundle", {"name": e["name"], "md5": e["md5"], "crc": e["crc"]})
            existing[name.lower()] = node
            dirty = True
            P.log("install: manifest + %s" % name)
        else:
            if node.get("md5") != e["md5"]:
                node.set("md5", e["md5"]); dirty = True
            if node.get("crc") is None:
                node.set("crc", e["crc"]); dirty = True
        wanted = [d for d in deps_by_name.get(name, []) if d in entries]
        cur = {d.get("name").lower() for d in node.findall("Dependency") if d.get("name")}
        for d in wanted:
            if d.lower() not in cur:
                ET.SubElement(node, "Dependency", {"name": d})
                dirty = True
                P.log("install: manifest %s -> dep %s" % (name, d))

    if dirty:
        if hasattr(ET, "indent"):
            ET.indent(tree, space="  ")
        tmp = P.MANIFEST.with_suffix(".tmp")
        tree.write(tmp, encoding="utf-8", xml_declaration=True)
        ET.parse(tmp)
        import os
        os.replace(tmp, P.MANIFEST)
        P.log("install: manifest updated, total=%d" % len(existing))
    else:
        P.log("install: manifest unchanged, total=%d" % len(existing))

    P.log("install: files copied=%d skipped=%d" % (len(changed), len(skipped)))
    if skipped:
        P.log("install: skipped -> %s" % ", ".join(skipped))
    return 0


if __name__ == "__main__":
    sys.exit(main())
