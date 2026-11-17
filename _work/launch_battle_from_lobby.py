# -*- coding: utf-8 -*-
"""Build the local battle launch config from the offline lobby profile."""
from __future__ import annotations

import argparse
import ctypes
import json
import os
from pathlib import Path
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parent.parent
PROFILE_PATH = ROOT / "_work" / "lobby_host" / "user_profile.json"
ROLES_PATH = ROOT / "_work" / "all_roles.json"
SKINS_PATH = ROOT / "_work" / "all_skins.json"
BATTLE_DIR = Path(r"D:\SSJJ-4399\battle\3_64")
LAUNCH_CONFIG = BATTLE_DIR / "launch_config.json"
STREAMING_ASSETS = BATTLE_DIR / "SSJJ_BattleClient_Unity_Data" / "StreamingAssets"
ASSET_MIRROR_MAPS = Path(r"D:\SSJJ\asset_mirror\Windows\maps")
SERVER_LAUNCHER = ROOT / "_work" / "launch_server_client.py"
LOG_PATH = ROOT / "_work" / "lobby_host" / "battle-bridge.log"
WEAPON_SLOTS = ("primary", "secondary", "melee", "throwable")
LOBBY_TITLES = ("4399生死狙击 - SSJJ_FlashAir", "SSJJ_FlashAir_Battle16397")

RACE_TYPE_TO_MODE = {
    2: "explode",
    3: "team",
    5: "personal",
    12: "deathmatch",
    15: "blade",
    19: "bighead",
    21: "team_ai",
    22: "team_ai",
    26: "blade",
    64: "weaponmaster",
    65: "blade_ai",
    74: "flyknife",
    2003: "team_ai",
    2019: "bighead",
    2041: "blade_ai",
}


def log(message: str) -> None:
    line = f"[LobbyBattleBridge] {message}"
    try:
        print(line, flush=True)
    except Exception:
        pass
    try:
        LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        with LOG_PATH.open("a", encoding="utf-8") as stream:
            stream.write(line + "\n")
    except OSError:
        pass


def read_json(path: Path, description: str):
    try:
        with path.open("r", encoding="utf-8-sig") as stream:
            return json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"Cannot read {description}: {path}: {exc}") from exc


def weapon_code(bag: dict, *slot_names: str, required: bool = False) -> str:
    for slot_name in slot_names:
        item = bag.get(slot_name)
        if isinstance(item, dict):
            code = item.get("codeName")
            if code:
                return str(code)
    if required:
        raise RuntimeError(f"Bag is missing its {slot_names[0]} weapon")
    return ""


_SKINS_CACHE: dict[int, str] | None = None


def load_skin_code_map() -> dict[int, str]:
    global _SKINS_CACHE
    if _SKINS_CACHE is not None:
        return _SKINS_CACHE
    mapping: dict[int, str] = {}
    if SKINS_PATH.is_file():
        try:
            rows = read_json(SKINS_PATH, "skin dictionary")
            if isinstance(rows, list):
                for row in rows:
                    if not isinstance(row, dict):
                        continue
                    skin_id = row.get("id")
                    code = row.get("codeName")
                    if skin_id is not None and code:
                        mapping[int(skin_id)] = str(code)
        except Exception as exc:
            log(f"warning: failed to load skin dictionary: {exc}")
    _SKINS_CACHE = mapping
    return mapping


def _norm_id_key(raw) -> str:
    if raw is None or raw == "":
        return ""
    if isinstance(raw, bool):
        return ""
    if isinstance(raw, (int, float)):
        return str(int(raw))
    text = str(raw).strip()
    if text.endswith(".0") and text[:-2].lstrip("-").isdigit():
        return text[:-2]
    return text


def resolve_skin_codename(value) -> str:
    if isinstance(value, dict):
        value = value.get("codeName") or value.get("skinCodeName") or value.get("skin") or value.get("tid") or value.get("id") or ""
    if value is None or value == "":
        return ""
    if isinstance(value, (int, float)) or (isinstance(value, str) and value.strip().lstrip("-").isdigit()):
        num = int(float(value))
        skin_id = num - 80000000 if num >= 80000000 else num
        code = load_skin_code_map().get(skin_id, "")
        return code
    return str(value).strip()


def weapon_skin(profile: dict, item: dict | None) -> str:
    if not isinstance(item, dict):
        return ""
    skins = profile.get("equippedSkins") or {}
    if not isinstance(skins, dict):
        return ""
    keys = (_norm_id_key(item.get("storageId")), _norm_id_key(item.get("tid")),
            str(item.get("codeName", "")).strip())
    value = next((skins[key] for key in keys if key and key in skins), "")
    return resolve_skin_codename(value)


def bag_weapons(profile: dict, bag: dict) -> dict:
    primary = bag.get("master")
    secondary = bag.get("secondary")
    melee = bag.get("closed")
    throwable = next((bag.get(name) for name in ("bom1", "bom2", "bom3")
                      if isinstance(bag.get(name), dict)), None)
    if not isinstance(primary, dict) or not isinstance(secondary, dict) or not isinstance(melee, dict):
        raise RuntimeError("Every battle bag must contain primary, secondary and melee weapons")
    if not isinstance(throwable, dict):
        raise RuntimeError("Every battle bag must contain a throwable weapon")
    items = (primary, secondary, melee, throwable)
    return {
        "primary": weapon_code(bag, "master", required=True),
        "secondary": weapon_code(bag, "secondary", required=True),
        "melee": weapon_code(bag, "closed", required=True),
        "throwable": weapon_code(bag, "bom1", "bom2", "bom3", required=True),
        "primary_skin": weapon_skin(profile, items[0]),
        "secondary_skin": weapon_skin(profile, items[1]),
        "melee_skin": weapon_skin(profile, items[2]),
        "throwable_skin": weapon_skin(profile, items[3]),
    }


def career_for_bag(profile: dict, bag: dict, roles_path: Path, team_override: int | None = None) -> str:
    roles = read_json(roles_path, "role dictionary")
    if not isinstance(roles, list):
        raise RuntimeError(f"Role dictionary must be a list: {roles_path}")
    team = int(profile.get("team", 1) if team_override is None else team_override)
    key = "roleCTID" if team == 2 else "roleTID"
    role_id = int(bag.get(key) or profile.get("defaultAvatar") or 0)
    role = next((row for row in roles if int(row.get("id", -1)) == role_id), None)
    if role is None or not role.get("carrer"):
        raise RuntimeError(f"No battle career mapping for role {role_id}")
    return str(role["carrer"])


def show_error_box(message: str) -> None:
    if os.name != "nt":
        return
    try:
        ctypes.windll.user32.MessageBoxW(0, message, "生死狙击离线大厅 - 战斗启动失败", 0x10)
    except Exception:
        pass


def find_lobby_hwnd() -> int:
    if os.name != "nt":
        return 0
    for title in LOBBY_TITLES:
        hwnd = ctypes.windll.user32.FindWindowW(None, title)
        if hwnd:
            return int(hwnd)
    return 0


def set_lobby_visible(visible: bool) -> None:
    hwnd = find_lobby_hwnd()
    if not hwnd:
        return
    user32 = ctypes.windll.user32
    if visible:
        user32.ShowWindow(hwnd, 9)   # SW_RESTORE
        user32.ShowWindow(hwnd, 5)   # SW_SHOW
        user32.SetForegroundWindow(hwnd)
    else:
        user32.ShowWindow(hwnd, 0)   # SW_HIDE


def battle_process_running() -> bool:
    if os.name != "nt":
        return False
    res = subprocess.run(
        ["tasklist", "/FI", "IMAGENAME eq SSJJ_BattleClient_Unity.exe", "/FO", "CSV", "/NH"],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
        creationflags=subprocess.CREATE_NO_WINDOW,
    )
    return '"SSJJ_BattleClient_Unity.exe"' in (res.stdout or "")


def validate_battle_assets(map_key: str, mode_key: str) -> None:
    if mode_key not in set(RACE_TYPE_TO_MODE.values()):
        raise RuntimeError(f"离线战斗端暂不支持模式: {mode_key}")
    has_map = (STREAMING_ASSETS / map_key).exists() or (ASSET_MIRROR_MAPS / map_key).exists()
    if not has_map:
        raise RuntimeError(f"本地缺少地图资产包: {map_key}（请先安装该地图或检查 D:\\SSJJ-4399 资源）")


def prepare_config(profile_path: Path, config_path: Path, template_path: Path | None = None,
                   career_override: str | None = None, bag_override: int | None = None,
                   scene_id: int | None = None, race_type: int | None = None,
                   team_override: int | None = None, ally_bots: int | None = None,
                   enemy_bots: int | None = None) -> dict:
    profile = read_json(profile_path, "lobby profile")
    bags = profile.get("bags")
    if not isinstance(bags, list) or len(bags) < 5:
        raise RuntimeError("Lobby profile must contain five bags")
    active_bag = int(profile.get("selectedBagIndex", 0) if bag_override is None else bag_override)
    if active_bag < 0 or active_bag >= 5:
        raise RuntimeError(f"Selected bag index is out of range: {active_bag}")

    base_path = template_path or config_path
    if base_path.exists():
        config = read_json(base_path, "battle launch config")
    else:
        config = {}
    if not isinstance(config, dict):
        raise RuntimeError(f"Battle launch config must be an object: {base_path}")

    map_key = f"map{int(scene_id)}" if scene_id is not None else str(config.get("map") or "map12")
    effective_race_type = int(race_type) if race_type is not None else int(config.get("race_type") or 0)
    if race_type is not None:
        if int(race_type) not in RACE_TYPE_TO_MODE:
            log(f"warning: raceType={race_type} 暂无独立规则实现，自动回退为 team_ai (2003)")
            mode_key = "team_ai"
            effective_race_type = 2003
        else:
            mode_key = RACE_TYPE_TO_MODE[int(race_type)]
    else:
        mode_key = str(config.get("mode") or "team_ai")
    validate_battle_assets(map_key, mode_key)

    battle_bags = [bag_weapons(profile, bag) for bag in bags[:5]]
    selected_bag = bags[active_bag]
    career = career_override or career_for_bag(profile, selected_bag, ROLES_PATH, team_override)
    team_val = int(profile.get("team", 1) if team_override is None else team_override)
    config["map"] = map_key
    config["mode"] = mode_key
    config["race_type"] = effective_race_type
    config["career"] = career
    config["hand"] = "woman" if ("woman" in career.lower() or "pandora" in career.lower() or "queen" in career.lower() or "rose" in career.lower()) else "man"
    config["player_team"] = 2 if team_val == 2 else 1
    if profile.get("playerName"):
        config["player_name"] = str(profile["playerName"])
    if ally_bots is not None:
        config["ally_bot_count"] = max(0, int(ally_bots))
    if enemy_bots is not None:
        config["enemy_bot_count"] = max(0, int(enemy_bots))
    if ally_bots is not None or enemy_bots is not None:
        config["bot_count"] = int(config.get("ally_bot_count", 0)) + int(config.get("enemy_bot_count", 0))
    config["active_bag"] = active_bag + 1
    config["bags"] = battle_bags
    if mode_key in ("blade", "blade_ai", "flyknife"):
        config["weapon"] = battle_bags[active_bag]["melee"]
        config["weapon_skin"] = battle_bags[active_bag]["melee_skin"]
        config["weapon_skin_weapon"] = battle_bags[active_bag]["melee"]
    else:
        config["weapon"] = battle_bags[active_bag]["primary"]
        config["weapon_skin"] = battle_bags[active_bag]["primary_skin"]
        config["weapon_skin_weapon"] = battle_bags[active_bag]["primary"]
    return config


def write_config(path: Path, config: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    with temporary.open("w", encoding="utf-8", newline="\n") as stream:
        json.dump(config, stream, indent=2, ensure_ascii=False)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    # Parse back before replacing the last known-good config.
    with temporary.open("r", encoding="utf-8") as stream:
        checked = json.load(stream)
    if not checked.get("map") or len(checked.get("bags", [])) != 5:
        temporary.unlink(missing_ok=True)
        raise RuntimeError("Generated battle config failed validation")
    os.replace(temporary, path)


def launch(profile_path: Path = PROFILE_PATH, config_path: Path = LAUNCH_CONFIG,
           template_path: Path | None = None, career_override: str | None = None,
           bag_override: int | None = None, start_game: bool = True,
           scene_id: int | None = None, race_type: int | None = None,
           team_override: int | None = None, ally_bots: int | None = None,
           enemy_bots: int | None = None) -> dict:
    config = prepare_config(
        profile_path, config_path, template_path,
        career_override, bag_override, scene_id, race_type,
        team_override, ally_bots, enemy_bots,
    )
    write_config(config_path, config)
    active = config["bags"][config["active_bag"] - 1]
    log("prepared map=%s mode=%s career=%s bag=%s primary=%s secondary=%s melee=%s throwable=%s" % (
        config["map"], config["mode"], config["career"], config["active_bag"],
        active["primary"], active["secondary"], active["melee"], active["throwable"]))
    if not start_game:
        return config
    if not SERVER_LAUNCHER.is_file():
        raise RuntimeError(f"Server-First battle launcher not found: {SERVER_LAUNCHER}")
    flags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
    hid_lobby = False
    proc = None
    try:
        proc = subprocess.Popen(
            [sys.executable, str(SERVER_LAUNCHER), "--config-json", str(config_path), "--kill-existing"],
            cwd=str(ROOT),
            close_fds=os.name != "nt",
            creationflags=flags,
        )
        log(f"started Server-First launcher: {SERVER_LAUNCHER} --config-json {config_path}")
        # Wait up to 45s for SSJJ_BattleClient_Unity.exe to spin up, then hide lobby and monitor until exit.
        deadline = time.time() + 45.0
        seen = False
        while time.time() < deadline:
            if battle_process_running():
                seen = True
                set_lobby_visible(False)
                hid_lobby = True
                break
            if proc.poll() is not None:
                break
            time.sleep(0.5)
        while seen and battle_process_running():
            time.sleep(1.0)
        log("battle client exited; restoring lobby window")
    finally:
        if proc is not None and proc.poll() is None:
            try:
                proc.wait(timeout=2.0)
            except subprocess.TimeoutExpired:
                proc.terminate()
        subprocess.run(["taskkill", "/F", "/IM", "SSJJ-Server.exe"], capture_output=True)
        if hid_lobby:
            set_lobby_visible(True)
    return config


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", type=Path, default=PROFILE_PATH)
    parser.add_argument("--config-path", type=Path, default=LAUNCH_CONFIG)
    parser.add_argument("--config-template", type=Path)
    parser.add_argument("--career")
    parser.add_argument("--bag", type=int, help="zero-based bag index; defaults to profile selection")
    parser.add_argument("--scene-id", type=int)
    parser.add_argument("--race-type", type=int)
    parser.add_argument("--team", type=int)
    parser.add_argument("--ally-bots", type=int)
    parser.add_argument("--enemy-bots", type=int)
    parser.add_argument("--prepare-only", action="store_true", help="write config without launching battle")
    args = parser.parse_args()
    try:
        launch(
            args.profile, args.config_path, args.config_template,
            args.career, args.bag, not args.prepare_only,
            args.scene_id, args.race_type, args.team,
            args.ally_bots, args.enemy_bots,
        )
        return 0
    except Exception as exc:
        log(f"ERROR {exc}")
        if not args.prepare_only:
            show_error_box(str(exc))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
