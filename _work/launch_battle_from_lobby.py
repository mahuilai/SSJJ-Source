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

sys.path.insert(0, str(Path(__file__).resolve().parent))
from launch_server_client import CLIENT_DLL, CLIENT_EXE, ORIG_SHA256, is_port_open, launch_battle_client_visible, sha256_file


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
    6: "biohazard",
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
    10001: "pve",
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


def weapon_storage_id(item: dict | None) -> int:
    if not isinstance(item, dict):
        return 0
    raw = item.get("storageId") or item.get("id") or 0
    try:
        return int(float(raw))
    except (TypeError, ValueError, OverflowError):
        return 0


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
    # Older profiles omit the two grenade slots. Explicit null retains an unequipped slot.
    bag = {"bom2": {"storageId": 10000020, "tid": 20, "codeName": "flashgrenade"},
           "bom3": {"storageId": 10012020, "tid": 12020, "codeName": "smoke"}, **bag}
    primary = bag.get("master")
    secondary = bag.get("secondary")
    melee = bag.get("closed")
    if not isinstance(primary, dict) or not isinstance(secondary, dict) or not isinstance(melee, dict):
        raise RuntimeError("Every battle bag must contain primary, secondary and melee weapons")
    return {
        "primary": weapon_code(bag, "master", required=True),
        "secondary": weapon_code(bag, "secondary", required=True),
        "melee": weapon_code(bag, "closed", required=True),
        "throwable": weapon_code(bag, "bom1"),
        "throwable2": weapon_code(bag, "bom2"),
        "throwable3": weapon_code(bag, "bom3"),
        "primary_id": weapon_storage_id(primary),
        "secondary_id": weapon_storage_id(secondary),
        "melee_id": weapon_storage_id(melee),
        "throwable_id": weapon_storage_id(bag.get("bom1")),
        "throwable2_id": weapon_storage_id(bag.get("bom2")),
        "throwable3_id": weapon_storage_id(bag.get("bom3")),
        "primary_skin": weapon_skin(profile, primary),
        "secondary_skin": weapon_skin(profile, secondary),
        "melee_skin": weapon_skin(profile, melee),
        "throwable_skin": weapon_skin(profile, bag.get("bom1")),
        "throwable2_skin": weapon_skin(profile, bag.get("bom2")),
        "throwable3_skin": weapon_skin(profile, bag.get("bom3")),
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


def set_lobby_visible(visible: bool, both_lobbies: bool = False) -> None:
    if os.name != "nt": return
    user32 = ctypes.windll.user32
    handles = [find_lobby_hwnd()]
    if both_lobbies:
        handles.append(user32.FindWindowW(None, "SSJJ_FlashAir_Battle16398"))
    for hwnd in dict.fromkeys(filter(None, handles)):
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
                   enemy_bots: int | None = None, max_human_players: int | None = None,
                   tcp_port: int | None = None, udp_port: int | None = None) -> dict:
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
    config["god_mode"] = False
    if profile.get("playerName"):
        config["player_name"] = str(profile["playerName"])
    if ally_bots is not None:
        config["ally_bot_count"] = max(0, int(ally_bots))
    if enemy_bots is not None:
        config["enemy_bot_count"] = max(0, int(enemy_bots))
    if ally_bots is not None or enemy_bots is not None:
        config["bot_count"] = int(config.get("ally_bot_count", 0)) + int(config.get("enemy_bot_count", 0))
    if max_human_players is not None:
        config["max_human_players"] = max(1, min(16, int(max_human_players)))
    if tcp_port is not None:
        config["tcp_port"] = int(tcp_port)
    if udp_port is not None:
        config["udp_port"] = int(udp_port)
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


def launch_multiplayer(config: dict, control: Path, room_id: int, seats: list[list[str]], server_only: bool) -> None:
    roster = {}
    for cid, team, name, *profile_file in seats:
        member = {"team": int(team), "name": name}
        if profile_file:
            seat_profile = Path(profile_file[0])
            seat_config = prepare_config(seat_profile, LAUNCH_CONFIG, team_override=int(team))
            member.update({key: seat_config[key] for key in ("active_bag", "bags", "career", "hand")})
        roster[int(cid)] = member
    if len(roster) != len(seats) or not (1 if server_only else 2) <= len(roster) <= 16:
        raise RuntimeError("联机房的大厅角色 ID 重复或席位数量超出范围")
    if not server_only:
        if (BATTLE_DIR / "LookSceneDebug.txt").exists():
            raise RuntimeError("LookSceneDebug.txt 会强制离线模式，请先移开该文件")
        if sha256_file(CLIENT_DLL) != ORIG_SHA256:
            raise RuntimeError("原版战斗客户端 DLL SHA256 校验失败")
        if not is_port_open("127.0.0.1", 8080):
            raise RuntimeError("大厅资源网关 127.0.0.1:8080 未启动")

    configured_project = os.environ.get("SSJJ_LOBBY_MULTIPLAYER_PROJECT")
    project = Path(configured_project).resolve() if configured_project else ROOT
    server_path = project / "SSJJ-Server" / "bin" / "Release" / "net10.0" / "SSJJ-Server.exe"
    if not server_path.is_file():
        raise RuntimeError(f"未找到已构建的多人战斗服 {server_path}")
    config.update(room_id=room_id, max_human_players=max(2, len(roster)), lobby_players=roster, god_mode=False)
    config_file = control / "launch_config.json"
    write_config(config_file, config)
    tcp_port, udp_port = config["tcp_port"], config["udp_port"]
    if is_port_open("127.0.0.1", tcp_port):
        raise RuntimeError(f"联机房 TCP 端口已被占用 {tcp_port}")
    launch_args = [str(server_path), "--config-json", str(config_file), "--room-id", str(room_id),
                   "--tcp-port", str(tcp_port), "--udp-port", str(udp_port)]
    environment = dict(os.environ, SSJJ_BIND_ADDR="127.0.0.1", SSJJ_RESOURCE_PORT="8080")
    clients = []
    server = None
    kernel = ctypes.windll.kernel32 if os.name == "nt" else None
    if kernel:
        kernel.GetExitCodeProcess.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_ulong)]
        kernel.TerminateProcess.argtypes = [ctypes.c_void_p, ctypes.c_uint]
        kernel.CloseHandle.argtypes = [ctypes.c_void_p]
    try:
        server_log = control / "server.log"
        with server_log.open("w", encoding="utf-8") as output:
            server = subprocess.Popen(launch_args, cwd=project, env=environment, stdout=output,
                                      stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW if kernel else 0)
        deadline = time.monotonic() + 12
        while server.poll() is None and time.monotonic() < deadline:
            if "Simulation loop started" in server_log.read_text(encoding="utf-8", errors="replace"):
                break
            time.sleep(0.10)
        else:
            raise RuntimeError(f"联机战斗服未就绪，见 {server_log}")

        if not server_only:
            cids = list(roster.keys())
            for seat_idx, cid in enumerate(cids, start=1):
                token = subprocess.check_output([*launch_args, "--battle-host", "127.0.0.1", "--char-id", str(cid), "--print-la"],
                                                cwd=project, env=environment, text=True, timeout=10).strip().splitlines()[-1]
                client_log = str(control / f"client-{cid}.log")
                client = launch_battle_client_visible([CLIENT_EXE, "-la", token, "-screen-fullscreen", "0", "-logFile", client_log], str(BATTLE_DIR))
                clients.append(client)
                log(f"room {room_id} role {cid} launched native client PID {client[2]}")
                if seat_idx < len(cids):
                    # Stagger next Unity client until current seat enters arena so concurrent clients do not race on Preload/*/data.tmp.
                    preload_deadline = time.monotonic() + 20
                    while server.poll() is None and time.monotonic() < preload_deadline:
                        srv_txt = server_log.read_text(encoding="utf-8", errors="replace")
                        if (any(f"cid={cid}" in ln and "entered arena" in ln for ln in srv_txt.splitlines())
                                or sum(1 for ln in srv_txt.splitlines() if "entered arena" in ln) >= seat_idx):
                            break
                        time.sleep(0.25)
            set_lobby_visible(False, both_lobbies=True)

        (control / "ready").touch()
        log(f"room {room_id} ready on 127.0.0.1:{tcp_port}/{udp_port}, seats={len(roster)}, logs={control}")

        def alive(client):
            process, handle, _ = client
            if process is not None:
                return process.poll() is None
            code = ctypes.c_ulong()
            return bool(kernel.GetExitCodeProcess(handle, ctypes.byref(code))) and code.value == 259

        while server.poll() is None and not (control / "stop").exists() and (server_only or any(map(alive, clients))):
            time.sleep(0.4)
    finally:
        for process, handle, _ in clients:
            if process is not None:
                if process.poll() is None:
                    process.terminate()
            elif handle:
                kernel.TerminateProcess(handle, 0)
                kernel.CloseHandle(handle)
        if server is not None and server.poll() is None:
            server.terminate()
            server.wait(timeout=5)
        if clients:
            set_lobby_visible(True, both_lobbies=True)


def launch(profile_path: Path = PROFILE_PATH, config_path: Path = LAUNCH_CONFIG,
           template_path: Path | None = None, career_override: str | None = None,
           bag_override: int | None = None, start_game: bool = True,
           scene_id: int | None = None, race_type: int | None = None,
           team_override: int | None = None, ally_bots: int | None = None,
           enemy_bots: int | None = None, max_human_players: int | None = None,
           tcp_port: int | None = None, udp_port: int | None = None,
           room_id: int | None = None, seats: list[list[str]] | None = None,
           control: Path | None = None, server_only: bool = False) -> dict:
    config = prepare_config(
        profile_path, config_path, template_path,
        career_override, bag_override, scene_id, race_type,
        team_override, ally_bots, enemy_bots, max_human_players, tcp_port, udp_port,
    )
    if seats and start_game:
        if room_id is None or control is None:
            raise RuntimeError("联机席位需要大厅房间号及控制目录")
        launch_multiplayer(config, control, room_id, seats, server_only)
        return config
    write_config(config_path, config)
    active = config["bags"][config["active_bag"] - 1]
    log("prepared map=%s mode=%s career=%s bag=%s primary=%s secondary=%s melee=%s throwable=%s" % (
        config["map"], config["mode"], config["career"], config["active_bag"],
        active["primary"], active["secondary"], active["melee"], active["throwable"]))
    if not start_game:
        return config
    if not SERVER_LAUNCHER.is_file():
        raise RuntimeError(f"Server-First battle launcher not found: {SERVER_LAUNCHER}")
    port_args = []
    if tcp_port is not None:
        port_args += ["--tcp-port", str(tcp_port)]
    if udp_port is not None:
        port_args += ["--udp-port", str(udp_port)]
    flags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
    hid_lobby = False
    proc = None
    try:
        proc = subprocess.Popen(
            [sys.executable, str(SERVER_LAUNCHER), "--config-json", str(config_path), *port_args],
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
    parser.add_argument("--max-human-players", type=int)
    parser.add_argument("--tcp-port", type=int)
    parser.add_argument("--udp-port", type=int)
    parser.add_argument("--room-id", type=int)
    parser.add_argument("--seat", action="append", nargs="+", metavar="SEAT")
    parser.add_argument("--room-control", type=Path)
    parser.add_argument("--server-only", action="store_true")
    parser.add_argument("--prepare-only", action="store_true", help="write config without launching battle")
    args = parser.parse_args()
    try:
        launch(
            args.profile, args.config_path, args.config_template,
            args.career, args.bag, not args.prepare_only,
            args.scene_id, args.race_type, args.team,
            args.ally_bots, args.enemy_bots, args.max_human_players,
            args.tcp_port, args.udp_port, args.room_id, args.seat, args.room_control, args.server_only,
        )
        return 0
    except Exception as exc:
        log(f"ERROR {exc}")
        if not args.prepare_only:
            show_error_box(str(exc))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
