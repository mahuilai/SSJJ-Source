#!/usr/bin/env python3
"""Extract honest material previews for indexed accessory/avatar-part bundles.

These are source Texture2D images from the official local Unity bundles. They
are material maps, not rendered 3D item thumbnails. Missing textures stay
explicitly missing in the inventory index.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import UnityPy

ROOT = Path(__file__).resolve().parents[2]
POOL = ROOT / "资源全集"
LAUNCHER = ROOT / "lobby-launcher"
INVENTORY = LAUNCHER / "data" / "asset_inventory.json"
OUTPUTS = {
    "accessories": ("accessories", "accessory"),
    "avatar_parts": ("avatar_parts", "avatarplayer"),
}
EFFECT_WORDS = (
    "glow", "line", "mask", "turbulence", "noise", "dissolve", "shadow",
    "normal", "specular", "bump", "flow", "particle", "emission", "fx_",
)


def safe_key(key: str) -> bool:
    return bool(key) and not any(ch in key for ch in '<>:"/\\|?*') and ".." not in key


def texture_rank(texture, key: str):
    name = str(texture.m_Name or "")
    low_name = name.casefold()
    low_key = key.casefold()
    width, height = int(texture.m_Width), int(texture.m_Height)
    if min(width, height) < 32:
        return None
    if any(word in low_name for word in EFFECT_WORDS):
        return None
    # Prefer an item-specific diffuse texture, then the largest plausible map.
    key_match = int(low_key in low_name or low_name in low_key)
    useful_size = min(width * height, 2048 * 2048)
    square_bonus = int(0.7 <= width / max(height, 1) <= 1.5)
    return (key_match, square_bonus, useful_size)


def source_for(category: str, key: str, row: dict) -> Path | None:
    digest = row.get("md5") or row.get("bundle")
    if not digest:
        digest = row.get("mesh_bundle")
    if not digest:
        return None
    candidate = POOL / category / f"{key}_{digest}"
    if candidate.is_file():
        return candidate
    # Some inventory entries carry the digest of the supplemental mesh bundle.
    for path in (POOL / category).glob(f"{key}*_{digest}"):
        if path.is_file():
            return path
    return None


def extract(source: Path, key: str):
    env = UnityPy.load(str(source))
    candidates = []
    for obj in env.objects:
        if obj.type.name != "Texture2D":
            continue
        try:
            texture = obj.read()
            rank = texture_rank(texture, key)
            if rank is not None:
                candidates.append((rank, texture))
        except Exception:
            continue
    if not candidates:
        return None
    _, best = max(candidates, key=lambda item: item[0])
    return best.image.convert("RGBA")


def build(force: bool = False, limit: int = 0) -> tuple[int, int]:
    inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    saved = missed = 0
    for group, (folder, bundle_dir) in OUTPUTS.items():
        target_dir = LAUNCHER / "data" / "previews" / folder
        target_dir.mkdir(parents=True, exist_ok=True)
        rows = inventory.get(group, {})
        pairs = sorted(rows.items())
        if limit:
            pairs = pairs[:limit]
        for key, row in pairs:
            if not safe_key(key):
                row["preview_available"] = False
                row["preview_path"] = ""
                missed += 1
                continue
            target = target_dir / f"{key}.png"
            if target.is_file() and not force:
                row["preview_available"] = True
                row["preview_path"] = target.relative_to(LAUNCHER).as_posix()
                saved += 1
                continue
            source = source_for(bundle_dir, key, row)
            if source is None:
                row["preview_available"] = False
                row["preview_path"] = ""
                missed += 1
                continue
            try:
                image = extract(source, key)
                if image is None:
                    raise ValueError("bundle has no suitable non-effect Texture2D")
                image.save(target, format="PNG", optimize=True)
                row["preview_available"] = True
                row["preview_path"] = target.relative_to(LAUNCHER).as_posix()
                saved += 1
            except Exception as exc:
                row["preview_available"] = False
                row["preview_path"] = ""
                missed += 1
                print(f"[MISS] {group}/{key}: {exc}")

    INVENTORY.write_text(
        json.dumps(inventory, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return saved, missed


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--limit", type=int, default=0)
    args = parser.parse_args()
    ok, missing = build(force=args.force, limit=args.limit)
    print(f"材质预览已索引：{ok}，缺失/无法提取：{missing}")
