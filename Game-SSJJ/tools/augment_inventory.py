"""把仓库清单扩展成「原版全量」：角色皮肤归属 / 喷漆 / 饰品 / 角色时装部件。

只做增量注入，不重算既有 weapons/characters/maps，保证与 build_asset_inventory.py 幂等共存。
运行顺序：build_asset_inventory.py -> build_spray_inventory.py -> 本脚本
"""
import json, os, re, glob, sys
from pathlib import Path

ROOT = r"D:\逆向\SSJJ双塔惊魂"
TABLES = os.path.join(ROOT, "Game source", "06_singleplayer", "tables_json")
POOL = os.path.join(ROOT, "资源全集")
LAUNCHER = os.path.join(ROOT, "lobby-launcher")
INV_PATHS = [
    os.path.join(LAUNCHER, "data", "asset_inventory.json"),
    os.path.join(ROOT, "Game-SSJJ", "data", "asset_inventory.json"),
]
SPRAY_JSON = os.path.join(LAUNCHER, "data", "sprays.json")
MD5_RE = re.compile(r"_([0-9a-f]{32})$")


def scan_bundles(subdir):
    """把 资源全集/<subdir> 的文件名还原成 {key: {md5, has_mesh}}。"""
    out = {}
    base = os.path.join(POOL, subdir)
    if not os.path.isdir(base):
        return out
    for fn in os.listdir(base):
        m = MD5_RE.search(fn)
        if not m:
            continue
        key = fn[: m.start()]
        if key.endswith("$2"):
            continue
        out[key] = {"md5": m.group(1), "complete": True}
    # 只有 $2 网格包、没有主包的条目要降级
    for fn in os.listdir(base):
        m = MD5_RE.search(fn)
        if not m:
            continue
        key = fn[: m.start()]
        if key.endswith("$2"):
            main = key[:-2]
            if main not in out:
                out[main] = {"md5": m.group(1), "complete": True, "mesh_only": True}
            out[main]["mesh_bundle"] = m.group(1)
    return out


def load_player_skin_owner():
    """PlayerSkinInfo.Player -> 皮肤归属角色。"""
    p = os.path.join(TABLES, "PlayerSkinInfo.json")
    if not os.path.exists(p):
        return {}
    d = json.load(open(p, encoding="utf-8"))
    out = {}
    for r in d["rows"]:
        name = (r.get("Name") or "").strip()
        owner = (r.get("Player") or "").strip()
        if name:
            out[name] = owner
    return out


def load_weapon_skin_owner():
    p = os.path.join(TABLES, "WeaponSkinInfo.json")
    if not os.path.exists(p):
        return {}
    d = json.load(open(p, encoding="utf-8"))
    out = {}
    for r in d["rows"]:
        name = (r.get("Name") or "").strip()
        wp = (r.get("Weapon") or "").strip()
        if name:
            out[name] = wp.split(":")[0] if wp else ""
    return out


def main():
    owner = load_player_skin_owner()
    wowner = load_weapon_skin_owner()
    sprays = json.load(open(SPRAY_JSON, encoding="utf-8"))["sprays"] if os.path.exists(SPRAY_JSON) else {}
    accessories = scan_bundles("accessory")
    avatar_parts = scan_bundles("avatarplayer")

    for inv_path in INV_PATHS:
        if not os.path.exists(inv_path):
            print("skip (missing):", inv_path)
            continue
        inv = json.load(open(inv_path, encoding="utf-8"))

        skins = inv.get("career_skins", {})
        owned = 0
        for key, row in skins.items():
            pl = owner.get(key, "")
            if pl:
                row["player"] = pl
                owned += 1
        # 表里有但资源目录没抓到的皮肤也补进来（标记 incomplete）
        for key, pl in owner.items():
            if key not in skins:
                skins[key] = {"complete": False, "player": pl} if pl else {"complete": False}
        inv["career_skins"] = dict(sorted(skins.items()))

        wskins = inv.get("weapon_skins", {})
        for key, row in wskins.items():
            base = wowner.get(key, "")
            if base:
                row["base"] = base
                row["base_src"] = "table"
        for key, base in wowner.items():
            if key not in wskins and base:
                wskins[key] = {"complete": False, "base": base, "base_src": "table"}
        inv["weapon_skins"] = dict(sorted(wskins.items()))

        inv["sprays"] = sprays
        inv["accessories"] = accessories
        inv["avatar_parts"] = avatar_parts

        with open(inv_path, "w", encoding="utf-8") as fh:
            json.dump(inv, fh, ensure_ascii=False, indent=1, sort_keys=True)

        print("==", inv_path)
        print("   career_skins:", len(inv["career_skins"]), "with owner:", owned)
        print("   weapon_skins:", len(inv["weapon_skins"]))
        print("   sprays:", len(sprays), "complete:", sum(1 for s in sprays.values() if s.get("complete")))
        print("   accessories:", len(accessories))
        print("   avatar_parts:", len(avatar_parts))

    # 勋章/称号图标来自大厅 SWF 缓存；与其余本地仓库一起进入最终索引。
    from build_lobby_collectibles import build as build_lobby_collectibles

    collectibles, preview_count = build_lobby_collectibles()
    print(
        "collectibles:",
        "medals", len(collectibles["medals"]),
        "titles", len(collectibles["titles"]),
        "previews", preview_count,
    )

    # These optional launcher tools keep the index explicit about image
    # availability; 3D bundle textures are labelled as material previews.
    sys.path.insert(0, os.path.join(LAUNCHER, "tools"))
    from build_cosmetic_previews import build as build_cosmetic_previews

    preview_count, missing_count = build_cosmetic_previews()
    print("cosmetic material previews:", preview_count, "indexed;", missing_count, "missing")

    from build_asset_preview_index import update as update_preview_index

    for inventory_path in INV_PATHS:
        indexed, previews = update_preview_index(Path(inventory_path))
        if indexed:
            print("preview metadata:", inventory_path, "entries", indexed, "previews", previews)


if __name__ == "__main__":
    main()
