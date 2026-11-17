#!/usr/bin/env python3
"""Extract official lobby item icons from the locally cached single-icon SWFs.

The UI SWFs and naming rules come from ``资源下载/大厅资源/SSJJ-main``.
The individual lazy-loaded icon SWFs are already present in
``_work/lobby_host/cache``.  These are the actual JPEG/alpha payloads used by
the Flash lobby; this deliberately does not render Unity material atlases.
"""
from __future__ import annotations

import json
import re
import shutil
import subprocess
import tempfile
import zlib
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
LOBBY_SOURCE = ROOT / "资源下载" / "大厅资源" / "SSJJ-main"
CACHE = ROOT / "_work" / "lobby_host" / "cache"
OUT = ROOT / "lobby-launcher" / "data" / "previews" / "official_lobby"
INDEX = ROOT / "lobby-launcher" / "data" / "official_lobby_preview_index.json"
WEAPONS = ROOT / "_work" / "all_weapons.json"
ROLES = ROOT / "_work" / "all_roles.json"
SKINS = ROOT / "_work" / "all_skins.json"

PREFIXES = {
    "weapons": "resource_swf_WeaponAssets_weapon_",
    "characters": "resource_swf_RoleAssets_avatar_",
    "items": "resource_swf_StuffAssets_item_",
    "recommend_items": "resource_swf_RecommendStuffAssets_item_",
    "parts": "resource_swf_PartsAssets_parts_",
    "weapon_skins": "resource_swf_SkinAssets_skin_",
    "maps": "resource_swf_MapAssets_map_",
    "titles": "resource_swf_titleIcon_title_",
    "medals": "resource_swf_MedalAssets_charInfoIcon_medal_",
}


def extract_swf_icon(source: Path) -> Image.Image:
    data = source.read_bytes()
    if len(data) < 8:
        raise ValueError("truncated SWF")
    signature = data[:3]
    if signature == b"CWS":
        body = zlib.decompress(data[8:])
    elif signature == b"FWS":
        body = data[8:]
    else:
        raise ValueError(f"unsupported SWF signature {signature!r}")

    start = body.find(b"\xff\xd8")
    end_marker = body.find(b"\xff\xd9", start + 2)
    if start < 0 or end_marker < 0:
        raise ValueError("no embedded JPEG icon")
    end = end_marker + 2
    image = Image.open(BytesIO(body[start:end])).convert("RGBA")

    # These lazy icon SWFs use JPEG plus a separately zlib-compressed alpha
    # plane (same format as the official medal/title SWFs).
    alpha_payload = body[end:]
    if alpha_payload:
        try:
            alpha = zlib.decompress(alpha_payload)
        except zlib.error:
            alpha = b""
        if len(alpha) == image.width * image.height:
            image.putalpha(Image.frombytes("L", image.size, alpha))
    return image


def parse_id(filename: str, prefix: str) -> str | None:
    if not filename.startswith(prefix) or not filename.endswith(".swf"):
        return None
    return filename[len(prefix) : -4]


def add_mapping(target: dict[str, str], key: object, relpath: str) -> None:
    if key is None:
        return
    normalized = str(key).strip().casefold()
    if normalized:
        target.setdefault(normalized, relpath)


def strip_prefix(value: str, prefix: str) -> str:
    return value[len(prefix) :] if value.startswith(prefix) else value


def pick_role_icon(files: dict[str, str], role_id: int) -> str | None:
    # `_2` is the official warehouse/role-card variant used by the original UI.
    for suffix in ("_2", "_4", ""):
        stem = f"RoleAssets_avatar_{role_id:03d}{suffix}"
        if stem in files:
            return files[stem]
    return None


def load_weapon_metadata() -> dict[str, dict[str, int]]:
    """Read exact shop_weapon sorting/quality fields using the existing decoder."""
    data = ROOT / "_work" / "GameData.final.bin"
    decoder = ROOT / "_work" / "lobby_host" / "java"
    if not data.is_file() or not (decoder / "com/strikegod/downloader/service/Amf3Decoder.class").is_file():
        return {}
    source = r'''
import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
class ExportLobbyWeaponMetadata {
  static int n(Map<?,?> r, String k) {
    Object v=r.get(k); return v instanceof Number ? ((Number)v).intValue() : 0;
  }
  public static void main(String[] args) throws Exception {
    Map<?,?> root=(Map<?,?>)new Amf3Decoder(Files.readAllBytes(Path.of(args[0]))).decodeOne();
    Map<?,?> rows=(Map<?,?>)root.get("shop_weapon");
    for(Object value:rows.values()) {
      if(!(value instanceof Map<?,?> r) || r.get("codeName")==null) continue;
      String key=String.valueOf(r.get("codeName"));
      System.out.print(Base64.getEncoder().encodeToString(key.getBytes(StandardCharsets.UTF_8)));
      for(String field:new String[]{"id","sortLv","priceType","weaponType","clientBgType","xlv"})
        System.out.print("\t"+n(r,field));
      System.out.println();
    }
  }
}
'''
    with tempfile.TemporaryDirectory(prefix="ssjj-lobby-weapon-metadata-") as temp:
        java = Path(temp) / "ExportLobbyWeaponMetadata.java"
        java.write_text(source, encoding="utf-8")
        result = subprocess.run(
            ["java", "-cp", str(decoder), str(java), str(data)],
            check=True, capture_output=True, text=True, encoding="utf-8",
        )
    import base64
    metadata: dict[str, dict[str, int]] = {}
    fields = ("id", "sort_lv", "money_type", "speciality", "client_bg_type", "xlv")
    for line in result.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) != 7:
            continue
        key = base64.b64decode(parts[0]).decode("utf-8").strip().casefold()
        row = dict(zip(fields, map(int, parts[1:])))
        # Duplicate code names represent variants; use the highest official ID
        # consistently, as the original warehouse's final tie-breaker does.
        if key not in metadata or row["id"] > metadata[key]["id"]:
            metadata[key] = row
    return metadata


def main() -> int:
    if not (LOBBY_SOURCE / "cache" / "res_config.xml").is_file():
        raise SystemExit(f"SSJJ-main lobby resource config not found: {LOBBY_SOURCE}")
    if not CACHE.is_dir():
        raise SystemExit(f"official lobby icon cache not found: {CACHE}")

    found: dict[str, dict[str, str]] = {category: {} for category in PREFIXES}
    failures: list[dict[str, str]] = []
    candidates: list[tuple[str, Path, str]] = []
    for category, prefix in PREFIXES.items():
        for source in sorted(CACHE.glob(f"{prefix}*.swf")):
            ident = parse_id(source.name, prefix)
            if ident is not None:
                candidates.append((category, source, ident))

    for number, (category, source, ident) in enumerate(candidates, start=1):
        stem = strip_prefix(source.stem, "resource_swf_")
        target = OUT / category / f"{stem}.png"
        relpath = target.relative_to(OUT).as_posix()
        try:
            if not target.is_file():
                image = extract_swf_icon(source)
                target.parent.mkdir(parents=True, exist_ok=True)
                image.save(target, format="PNG", optimize=True)
            found[category][stem] = relpath
        except Exception as exc:
            failures.append({"source": source.name, "error": str(exc)})
        if number % 250 == 0:
            print(f"icon SWFs: {number}/{len(candidates)}")

    by_key: dict[str, dict[str, str]] = {
        "ui": {},
        "weapons": {},
        "characters": {},
        "career_skins": {},
        "weapon_skins": {},
        "items": {},
        "parts": {},
        "maps": {},
        "titles": {},
        "medals": {},
    }

    weapon_id_to_icon = {
        int(row["id"]): str(row["codeName"])
        for row in json.loads(WEAPONS.read_text(encoding="utf-8"))
        if row.get("id") is not None and row.get("codeName")
    }
    for icon_stem, relpath in found["weapons"].items():
        match = re.fullmatch(r"WeaponAssets_weapon_(\d+)", icon_stem)
        if match:
            code = weapon_id_to_icon.get(int(match.group(1)))
            add_mapping(by_key["weapons"], code, relpath)

    roles = json.loads(ROLES.read_text(encoding="utf-8"))
    for row in roles:
        try:
            relpath = pick_role_icon(found["characters"], int(row["id"]))
        except (KeyError, TypeError, ValueError):
            continue
        if relpath is None:
            continue
        category = "career_skins" if int(row.get("isSkin", 0)) == 1 else "characters"
        add_mapping(by_key[category], row.get("carrer"), relpath)

    skin_id_to_code = {
        int(row["id"]): str(row["codeName"])
        for row in json.loads(SKINS.read_text(encoding="utf-8"))
        if row.get("id") is not None and row.get("codeName")
    }
    for icon_stem, relpath in found["weapon_skins"].items():
        match = re.fullmatch(r"SkinAssets_skin_(\d+)", icon_stem)
        if match:
            add_mapping(by_key["weapon_skins"], skin_id_to_code.get(int(match.group(1))), relpath)

    # Keep the raw official icon names indexed too. This covers IDs/variants
    # without pretending that a texture atlas is an item thumbnail.
    for category, entries in found.items():
        if category in ("characters", "career_skins"):
            continue
        target_category = "items" if category == "recommend_items" else category
        for stem, relpath in entries.items():
            add_mapping(by_key[target_category], stem, relpath)
            add_mapping(by_key[target_category], strip_prefix(stem, "weapon_"), relpath)

    for icon_stem, relpath in found["titles"].items():
        match = re.fullmatch(r"titleIcon_title_(\d+)", icon_stem)
        if match:
            add_mapping(by_key["titles"], match.group(1), relpath)
    for icon_stem, relpath in found["medals"].items():
        match = re.fullmatch(r"MedalAssets_charInfoIcon_medal_(\d+)", icon_stem)
        if match:
            add_mapping(by_key["medals"], match.group(1), relpath)
    for icon_stem, relpath in found["maps"].items():
        match = re.fullmatch(r"MapAssets_map_(\d+)", icon_stem)
        if match:
            # The local map package keys use map1/map2/...; the official AIR
            # lobby resolves that numeric map id through AssetsPath.map_<id>.
            add_mapping(by_key["maps"], f"map{match.group(1)}", relpath)

    index = {
        "schema_version": 1,
        "source": {
            "ui_catalog": "资源下载/大厅资源/SSJJ-main/cache/res_config.xml",
            "icon_swfs": "_work/lobby_host/cache",
            "rendering": "official Flash lobby JPEG + alpha icons",
        },
        "by_key": by_key,
        "weapons": load_weapon_metadata(),
        "character_names": {
            str(row["carrer"]).strip().casefold(): str(row["name"])
            for row in roles
            if row.get("carrer") and row.get("name")
        },
        "icons": found,
        "failures": failures,
    }
    # Original 224x103 warehouse card states and quality backgrounds, exported
    # by FFDec from the supplied SSJJ-main MallAssets SWF. Preserve their pixels.
    sprite_root = LOBBY_SOURCE / "export" / "MallAssets" / "sprites"
    ui_symbols = {
        "mall_item_new1": 1008,
        "storage_item_new2": 1122,
        "storage_item_new3": 1125,
        "bg_weapon_31": 417,
        "bg_weapon_41": 420,
        "brilliant_bg": 438,
        "god_ItemBg": 648,
        "goldItemBg": 654,
        "hero_bg": 693,
        "ledengBg": 798,
        "gp_layer": 669,
        "heishi_bg": 675,
        "rmb_layer": 1065,
        "nerver_expired_weapon_icon": 1032,
    }
    for symbol, symbol_id in ui_symbols.items():
        source = sprite_root / f"DefineSprite_{symbol_id}_MallAssets.{symbol}" / "1.png"
        if not source.is_file():
            continue
        target = OUT / "ui" / f"{symbol}.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        add_mapping(by_key["ui"], symbol, target.relative_to(OUT).as_posix())
    index["source"]["ui_sprites"] = sprite_root.relative_to(ROOT).as_posix()
    index["source"]["weapon_metadata"] = "_work/GameData.final.bin:shop_weapon (original AMF3 table)"
    INDEX.write_text(json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    counts = {category: len(rows) for category, rows in found.items()}
    mapped = {category: len(rows) for category, rows in by_key.items()}
    print(f"official lobby SWF icons extracted: {sum(counts.values())}/{len(candidates)}")
    print("by SWF class:", counts)
    print("by local item key:", mapped)
    print(f"decode failures: {len(failures)}; index: {INDEX}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
