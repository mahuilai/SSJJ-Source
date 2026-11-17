# -*- coding: utf-8 -*-
"""按资源全集重建大厅资源清单。

武器：游戏 Weapon 表的全部 id（中文名/类型来自表），bundle 取 INDEX.json；
角色：player/default 内 careerConfig.xml 的全部 career（官方角色/怪物清单）；
地图：沿用上次清单（离线端只接入 map1，避免引入不可用地图）。

用法：python build_asset_inventory.py
输出：asset_inventory.json + lobby-launcher/data/asset_inventory.json
"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

import UnityPy

ROOT = r"D:\逆向\SSJJ双塔惊魂"
POOL = os.path.join(ROOT, "资源全集")
INDEX = os.path.join(POOL, "INDEX.json")
ROOT_INV = os.path.join(ROOT, "asset_inventory.json")
LAUNCHER_INV = os.path.join(ROOT, "lobby-launcher", "data", "asset_inventory.json")
TABLES = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows\tables_610a381509f56f92e2226c8955b02aad"
BAD_CHARS = re.compile("[\ufffd\ue000-\uf8ff]")


def bundle_path(entry):
    if not entry or not entry.get("file"):
        return None
    return os.path.join(POOL, entry["file"].replace("\\", "/"))


def load_text_assets(path):
    out = {}
    env = UnityPy.load(path)
    for obj in env.objects:
        if obj.type.name != "TextAsset":
            continue
        data = obj.read()
        text = data.m_Script
        try:
            text = bytes(text).decode("utf-8", "replace")
        except Exception:
            text = str(text)
        out[data.m_Name] = text
    return out


def load_weapon_table():
    """Weapon 表 -> {id: (中文名, 类型)}。表里 id 保持原始大小写。"""
    text = load_text_assets(TABLES).get("Weapon", "")
    table = {}
    for line in text.splitlines():
        parts = line.split(",")
        if len(parts) > 3 and parts[0].startswith('"'):
            wid = parts[0].strip('"')
            table[wid] = (parts[2].strip('"'), parts[3].strip('"'))
    return table


def build_pool_index():
    """扫描资源全集，bundle 名（小写）-> {name, md5, file}。

    INDEX.json 只覆盖官方 manifest 里出现过的名字，npc/ 角色和部分 base-only
    资源不在里面，直接按磁盘文件名解析才不会漏。
    """
    pool = {}
    for dirname in os.listdir(POOL):
        directory = os.path.join(POOL, dirname)
        if not os.path.isdir(directory):
            continue
        for fname in os.listdir(directory):
            match = re.match(r"^(.*)_([0-9a-f]{32})$", fname)
            if not match:
                continue
            pool[(dirname + "/" + match.group(1)).lower()] = {
                "name": dirname + "/" + match.group(1),
                "md5": match.group(2),
                "file": os.path.join(dirname, fname),
            }
    return pool


def bundle_has_mesh(entry):
    path = bundle_path(entry)
    if not path:
        return False
    try:
        env = UnityPy.load(path)
        return any(obj.type.name in ("Mesh", "SkinnedMeshRenderer") for obj in env.objects)
    except Exception:
        return False


def load_careers():
    index = json.load(open(INDEX, encoding="utf-8"))
    default_entry = index["players"].get("default", {}).get("main")
    path = bundle_path(default_entry)
    if not path:
        raise SystemExit("player/default main bundle missing in 资源全集")
    text = load_text_assets(path).get("careerConfig")
    if not text:
        raise SystemExit("careerConfig not found in player/default")
    root = ET.fromstring(text)
    careers = []
    for node in root.findall("career"):
        row = {child.tag: (child.text or "").strip() for child in node}
        if row.get("careerName"):
            careers.append(row)
    return careers


def truthy(value):
    return str(value).lower() == "true"


def career_kind(row):
    if truthy(row.get("isPet")):
        return "pet"
    if truthy(row.get("isMech")) or truthy(row.get("isMech2")):
        return "mech"
    if truthy(row.get("isNormalZombie")) or truthy(row.get("isZombieHero")):
        return "zombie"
    if truthy(row.get("isHumanity")):
        return "human"
    return "other"


def main():
    pool = build_pool_index()

    def find_bundle(name):
        return pool.get(name.lower())

    def weapon_bundles(key):
        return find_bundle("weapon/" + key), find_bundle("weapon/" + key + "$2")

    def player_bundles(key):
        return find_bundle("player/" + key), find_bundle("player/" + key + "$2")

    table = load_weapon_table()
    names_lower = {key.lower() for key in table}

    weapons = {}
    for key, (cn, wtype) in table.items():
        if BAD_CHARS.search(key):
            continue
        main, mesh = weapon_bundles(key)
        # 少数武器（如 quadraticelement）网格直接在主包里，没有 $2；
        # 只看 $2 会把它们误判成缺资源，大厅里就无法选择。
        complete = bool(main and (mesh or bundle_has_mesh(main)))
        row = {"name": key, "cn": cn, "type": wtype}
        if main:
            row["bundle"] = main["md5"]
            row["bundle_src"] = "pool"
        if mesh:
            row["mesh_bundle"] = mesh["md5"]
            row["mesh_src"] = "pool"
        row["complete"] = complete
        weapons[key] = row

    # 表里没有但资源完整的武器（改名/活动遗留），也一并放进仓库。
    for name_lower, entry in pool.items():
        if not name_lower.startswith("weapon/"):
            continue
        leaf = name_lower[len("weapon/"):]
        if leaf.endswith("$2") or leaf in names_lower:
            continue
        mesh = find_bundle("weapon/" + leaf + "$2")
        if not mesh:
            continue
        if BAD_CHARS.search(leaf):
            continue
        original = entry["name"].split("/", 1)[1]
        weapons[original] = {
            "name": original,
            "cn": "",
            "type": "",
            "bundle": entry["md5"],
            "bundle_src": "pool",
            "mesh_bundle": mesh["md5"],
            "mesh_src": "pool",
            "complete": True,
        }

    characters = {}
    for row in load_careers():
        key = row["careerName"]
        if BAD_CHARS.search(key):
            continue
        main, mesh = player_bundles(key)
        complete = bool(main and (mesh or bundle_has_mesh(main)))
        item = {"name": key, "kind": career_kind(row), "complete": complete}
        if main:
            item["bundle"] = main["md5"]
        if mesh:
            item["mesh_bundle"] = mesh["md5"]
        if not main and find_bundle("npc/" + key):
            # 只有 NPC 包，能出示例图但不能当玩家角色用。
            item["npc_only"] = True
        characters[key] = item

    previous = json.load(open(ROOT_INV, encoding="utf-8"))
    # modeconfig / maps/common / unitymaps 不是可玩地图，留着只会让大厅出现空卡。
    maps = {
        key: value
        for key, value in previous.get("maps", {}).items()
        if re.match(r"^maps/map\d+$", key)
    }

    payload = {"weapons": weapons, "characters": characters, "maps": maps}
    for path in (ROOT_INV, LAUNCHER_INV):
        with open(path, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)

    weapon_available = sum(1 for w in weapons.values() if w["complete"])
    char_available = sum(1 for c in characters.values() if c["complete"])
    print("weapons: %d total / %d complete" % (len(weapons), weapon_available))
    print("characters: %d total / %d complete" % (len(characters), char_available))
    print("maps kept:", len(maps))
    missing = [k for k, c in characters.items() if not c["complete"]]
    print("characters missing bundles:", len(missing), ", ".join(missing[:20]))
    print("JSON:", ROOT_INV, "|", LAUNCHER_INV)


if __name__ == "__main__":
    main()
