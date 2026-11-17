# -*- coding: utf-8 -*-
"""离线喷漆资源安装：把 spray/<id> 及其依赖复制到 StreamingAssets/AssetBundles/Windows。

背景（已核实）：
  - 原版喷漆资源名由 ResourceUtility.GetSparyRequest(id) 决定：
      bundle = spray/<id>，asset = <id>（prefab，贴图/材质都在包里）
  - 每张喷漆都依赖 spray/materials，spray/materials 又依赖 ssjj_shader/scene
  - 离线端按 <leaf>_<md5> 平铺存放，清单是 Windows/AssetBundles（XML）

用法：
  python install_spray_assets.py            # 安装默认图案（2/10/51/100）
  python install_spray_assets.py --dry      # 只看缺什么，不写盘
  python install_spray_assets.py --ids 2,10,51,100,219
可重复执行：已存在且大小一致的文件不会重拷，清单只在有变化时重写。
"""
import os
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prepare_launch_assets as P

# 与 OfflineSpray.cs 的 DefaultIds 保持一致
DEFAULT_SPRAY_IDS = [2, 10, 51, 100]
# 所有喷漆共用的材质/贴图包（每个 spray/<id> 都声明依赖它）
EXTRA_BUNDLES = ["spray/materials"]


def parse_ids(argv):
    for i, a in enumerate(argv):
        if a == "--ids" and i + 1 < len(argv):
            return [int(x) for x in argv[i + 1].split(",") if x.strip()]
        if a.startswith("--ids="):
            return [int(x) for x in a.split("=", 1)[1].split(",") if x.strip()]
    return list(DEFAULT_SPRAY_IDS)


def out_path(name, md5):
    if "/" in name:
        cat, leaf = name.rsplit("/", 1)
        return P.BUNDLE_ROOT / cat / ("%s_%s" % (leaf, md5))
    return P.BUNDLE_ROOT / ("%s_%s" % (name, md5))


def source_state(name, official):
    """(状态, info)：状态 ∈ NOT-IN-MANIFEST / NO-SOURCE / MD5-MISMATCH / INSTALLED / READY"""
    info = official.get(name.lower())
    if info is None:
        return "NOT-IN-MANIFEST", None
    src, md5 = P.find_source(name, info)
    if src is None:
        return "NO-SOURCE", info
    if md5 != info["md5"]:
        return "MD5-MISMATCH", info
    dest = out_path(name, info["md5"])
    if dest.is_file() and dest.stat().st_size == src.stat().st_size:
        return "INSTALLED", info
    return "READY", info


def closure(names, official):
    """按官方清单展开依赖（含间接依赖），顺序稳定。"""
    order, seen = [], set()
    queue = list(names)
    while queue:
        name = queue.pop(0)
        if name.lower() in seen:
            continue
        seen.add(name.lower())
        order.append(name)
        info = official.get(name.lower())
        if not info:
            continue
        for d in info["deps"]:
            if d.lower() not in seen:
                queue.append(d)
    return order


def main():
    argv = sys.argv[1:]
    dry = "--dry" in argv
    ids = parse_ids(argv)
    roots = ["spray/%d" % i for i in ids] + EXTRA_BUNDLES

    official = P.load_official_manifest()
    if not official:
        P.log("install-spray: official manifest missing (%s), abort" % P.FULL_MANIFEST)
        return 1

    names = closure(roots, official)
    P.log("install-spray: ids=%s bundles=%d%s"
          % (ids, len(names), " (dry)" if dry else ""))

    if dry:
        counts = {}
        for name in names:
            state, _ = source_state(name, official)
            counts[state] = counts.get(state, 0) + 1
            P.log("  [dry] %-30s %s" % (name, state))
        P.log("install-spray: dry done  " + " ".join("%s=%d" % (k, counts[k]) for k in sorted(counts)))
        return 0

    entries, copied, unchanged, failed = {}, [], [], []
    for name in names:
        c, u = [], []
        e = P.ensure_bundle(name, official, c, u)
        if e:
            entries[name] = e
            if c:
                copied.extend(c)
            else:
                unchanged.extend(u or [name])
        else:
            failed.append(name)

    # 依赖闭包里如果还有没拿到的（比如某个间接依赖缺源），这里再兜一遍清单声明
    deps_by_name = {}
    for name, e in entries.items():
        deps_by_name[name] = [d for d in e["deps"] if d in entries]

    manifest_added = manifest_updated = 0
    existing = {}
    if entries:
        if not P.MANIFEST.is_file():
            P.log("install-spray: manifest missing %s" % P.MANIFEST)
            return 1
        bak = P.BUNDLE_ROOT / "AssetBundles.spray.bak"
        if not bak.is_file():
            import shutil
            shutil.copy2(P.MANIFEST, bak)

        tree = ET.parse(P.MANIFEST)
        root = tree.getroot()
        existing = {n.get("name").lower(): n for n in root.findall("AssetBundle") if n.get("name")}
        dirty = False
        for name in names:
            e = entries.get(name)
            if not e:
                continue
            node = existing.get(name.lower())
            if node is None:
                node = ET.SubElement(root, "AssetBundle",
                                     {"name": e["name"], "md5": e["md5"], "crc": e["crc"]})
                existing[name.lower()] = node
                dirty = True
                manifest_added += 1
                P.log("install-spray: manifest + %s" % name)
            else:
                changed = False
                if node.get("md5") != e["md5"]:
                    node.set("md5", e["md5"])
                    changed = True
                if node.get("crc") is None:
                    node.set("crc", e["crc"])
                    changed = True
                if changed:
                    dirty = True
                    manifest_updated += 1
                    P.log("install-spray: manifest ~ %s" % name)
            wanted = [d for d in deps_by_name.get(name, [])]
            cur = {d.get("name").lower() for d in node.findall("Dependency") if d.get("name")}
            for d in wanted:
                if d.lower() not in cur:
                    ET.SubElement(node, "Dependency", {"name": d})
                    dirty = True
                    P.log("install-spray: manifest %s -> dep %s" % (name, d))

        if dirty:
            if hasattr(ET, "indent"):
                ET.indent(tree, space="  ")
            tmp = P.MANIFEST.with_suffix(".tmp")
            tree.write(tmp, encoding="utf-8", xml_declaration=True)
            ET.parse(tmp)
            os.replace(tmp, P.MANIFEST)

    P.log("install-spray: ready=%d/%d copied=%d unchanged=%d failed=%d manifest(+%d ~%d) total=%d"
          % (len(entries), len(names), len(copied), len(unchanged), len(failed),
             manifest_added, manifest_updated, len(existing)))
    if failed:
        P.log("install-spray: FAILED " + ", ".join(failed))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
