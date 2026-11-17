#!/usr/bin/env python3
"""Write truthful local-preview/unlock/client-status fields to the inventory."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LAUNCHER = ROOT / "lobby-launcher"
PREVIEWS = LAUNCHER / "assets" / "previews"
DATA_PREVIEWS = LAUNCHER / "data" / "previews"
INVENTORIES = [
    LAUNCHER / "data" / "asset_inventory.json",
    ROOT / "Game-SSJJ" / "data" / "asset_inventory.json",
]


def preview_for(category: str, key: str) -> str:
    direct = {
        "weapons": (PREVIEWS / "weapons", key),
        "characters": (PREVIEWS / "characters", key),
        "maps": (PREVIEWS / "maps", key.rsplit("/", 1)[-1]),
        "weapon_skins": (DATA_PREVIEWS / "weapon_skins", key),
        "career_skins": (DATA_PREVIEWS / "career_skins", key),
        "sprays": (PREVIEWS / "sprays", key),
        "accessories": (DATA_PREVIEWS / "accessories", key),
        "avatar_parts": (DATA_PREVIEWS / "avatar_parts", key),
        "medals": (PREVIEWS / "medals", f"medal_{key}"),
        "titles": (PREVIEWS / "titles", f"title_{key}"),
    }
    item = direct.get(category)
    if not item:
        return ""
    folder, stem = item
    path = folder / f"{stem}.png"
    return path.relative_to(LAUNCHER).as_posix() if path.is_file() else ""


def display_name(category: str, key: str, item: dict) -> str:
    return str(item.get("cn") or item.get("name") or item.get("display_name") or key)


def update(path: Path) -> tuple[int, int]:
    if not path.is_file():
        return 0, 0
    data = json.loads(path.read_text(encoding="utf-8"))
    with_preview = total = 0
    categories = (
        "weapons", "characters", "maps", "weapon_skins", "career_skins",
        "sprays", "accessories", "avatar_parts", "medals", "titles",
    )
    for category in categories:
        items = data.get(category, {})
        if not isinstance(items, dict):
            continue
        for key, item in items.items():
            if not isinstance(item, dict):
                continue
            key = str(key)
            preview = preview_for(category, key)
            item["display_name"] = display_name(category, key, item)
            item["preview_available"] = bool(preview)
            item["preview_path"] = preview
            item["locally_unlocked"] = True
            item.setdefault("client_available", None)
            item["resource_available"] = bool(item.get("complete", False))
            total += 1
            with_preview += bool(preview)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return total, with_preview


if __name__ == "__main__":
    for inventory in INVENTORIES:
        total, previews = update(inventory)
        if total:
            print(f"{inventory}: indexed={total}, local previews={previews}")
