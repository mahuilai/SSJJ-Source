#!/usr/bin/env python3
"""Build the launcher catalog from the original lobby's exported tables.

The weapon, role and skin JSON files in _work are exports of the official
Lobby GameData AMF3 tables. Preview availability is resolved only through the
icons extracted from lobby resource SWFs. Battle-cache inventory is never read.
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "lobby-launcher" / "data"
WEAPONS_PATH = ROOT / "_work" / "all_weapons.json"
ROLES_PATH = ROOT / "_work" / "all_roles.json"
SKINS_PATH = ROOT / "_work" / "all_skins.json"
PREVIEW_PATH = DATA / "official_lobby_preview_index.json"
OUTPUT_PATH = DATA / "official_lobby_dataset.json"


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def weapon_rows(rows: list[dict[str, Any]], preview_index: dict[str, Any]) -> list[dict[str, Any]]:
    # The lobby table can contain several rows with one codeName. The storage
    # view identifies a concrete weapon by id, so retain each distinct id.
    result: dict[tuple[str, int], dict[str, Any]] = {}
    metadata = preview_index.get("weapons", {})
    for row in rows:
        key = str(row.get("codeName") or "").strip().casefold()
        try:
            item_id = int(row.get("id"))
        except (TypeError, ValueError):
            continue
        if not key:
            continue
        meta = metadata.get(key, {})
        speciality = int(meta.get("speciality", 0))
        background, quality = {
            1: ("hero_bg", "英雄"),
            2: ("goldItemBg", "黄金"),
            3: ("brilliant_bg", "璀璨"),
            6: ("god_ItemBg", "传说"),
        }.get(speciality, ("rmb_layer", "普通"))
        weapon_type = int(row.get("weaponType", 0))
        category = {1: "副武器", 2: "近战武器", 3: "投掷武器", 4: "主武器"}.get(weapon_type, "主武器")
        result[(key, item_id)] = {
            "key": key,
            "id": item_id,
            "name": str(row.get("name") or key),
            "category": category,
            "categoryName": category,
            "qualityTag": quality,
            "background": background,
        }
    return sorted(result.values(), key=lambda item: (item["category"], item["id"]))


def character_rows(rows: list[dict[str, Any]], preview_index: dict[str, Any]) -> list[dict[str, Any]]:
    lobby_icons = preview_index.get("by_key", {}).get("characters", {})
    result = []
    for row in rows:
        key = str(row.get("carrer") or "").strip().casefold()
        if not key:
            continue
        raw_name = str(row.get("name") or "").strip()
        # Some legacy AMF rows contain replacement characters. Keep the
        # original internal name visible instead of showing corrupted text.
        display_name = key if "\ufffd" in raw_name or not raw_name else raw_name
        group = int(row.get("group", 1))
        result.append({
            "id": int(row.get("id") or 0),
            "key": key,
            "name": display_name,
            "faction": "风暴" if group == 2 else "联军",
            "isSkin": int(row.get("isSkin", 0)) == 1,
            "rootAvatarId": int(row.get("rootAvatarId", 0)),
            "lobbyIconAvailable": key in lobby_icons,
        })
    return result


def map_rows(preview_index: dict[str, Any]) -> list[dict[str, str]]:
    lobby_maps = preview_index.get("by_key", {}).get("maps", {})
    ids = set()
    for icon_key in lobby_maps:
        match = re.fullmatch(r"mapassets_map_(\d+)", icon_key)
        if match:
            ids.add(int(match.group(1)))
    return [
        {"key": f"map{item_id}", "name": f"地图 {item_id}", "category": "大厅资源"}
        for item_id in sorted(ids)
    ]


def main() -> int:
    weapons = load_json(WEAPONS_PATH)
    roles = load_json(ROLES_PATH)
    skins = load_json(SKINS_PATH)
    previews = load_json(PREVIEW_PATH)
    dataset = {
        "schemaVersion": 2,
        "source": {
            "catalog": "_work/GameData.final.bin: official Lobby shop_weapon/shop_avatar/shop_skin AMF3 tables",
            "visuals": "lobby-launcher/data/official_lobby_preview_index.json (exported lobby SWF icon assets)",
            "maps": "official Lobby MapAssets SWF icons; display names remain IDs until a localized lobby map table is available",
        },
        "weapons": weapon_rows(weapons, previews),
        "characters": character_rows(roles, previews),
        "skins": skins,
        "maps": map_rows(previews),
    }
    OUTPUT_PATH.write_text(json.dumps(dataset, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"Generated from lobby tables: {len(dataset['weapons'])} weapons, "
        f"{len(dataset['characters'])} roles, {len(dataset['skins'])} skins, "
        f"{len(dataset['maps'])} lobby map icons -> {OUTPUT_PATH}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
