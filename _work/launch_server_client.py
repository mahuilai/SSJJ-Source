# -*- coding: utf-8 -*-
"""
Server-First 独立调试启动器：
1. 校验原版 Assembly-CSharp.dll 零修改 SHA256
2. 拉起本地 :8080 资源网关（若未运行）
3. 拉起原生 SSJJ-Server.exe
4. 通过 -la <base62(ProtoBuf(BootConfigData))> 拉起未修改的原版 SSJJ_BattleClient_Unity.exe
"""
import argparse
import ctypes
from ctypes import wintypes
import hashlib
import os
import socket
import subprocess
import sys
import time

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SERVER_EXE = os.path.join(ROOT_DIR, "SSJJ-Server", "bin", "Debug", "net10.0", "SSJJ-Server.exe")
GATEWAY_PY = os.path.join(ROOT_DIR, "_work", "gateway_8080.py")
BATTLE_DIR = r"D:\SSJJ-4399\battle\3_64"
CLIENT_EXE = os.path.join(BATTLE_DIR, "SSJJ_BattleClient_Unity.exe")
CLIENT_DLL = os.path.join(BATTLE_DIR, "SSJJ_BattleClient_Unity_Data", "Managed", "Assembly-CSharp.dll")
ORIG_SHA256 = "28D8901BCEAEF5ED39000D1603F094532120EDA15D46F2AB0DEBF4C6EE45F089"
LOG_DIR = os.path.join(BATTLE_DIR, "log")
SERVER_LOG = os.path.join(LOG_DIR, "ssjj_server.log")
CLIENT_LOG = os.path.join(LOG_DIR, "server_first_client.log")
GATEWAY_LOG = os.path.join(LOG_DIR, "gateway_8080.log")


def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest().upper()


def is_port_open(host: str, port: int, timeout: float = 0.5) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def main():
    parser = argparse.ArgumentParser(description="Server-First Standalone Launcher")
    parser.add_argument("--map", default="")
    parser.add_argument("--mode", default="")
    parser.add_argument("--race-type", type=int, default=0)
    parser.add_argument("--bots", type=int, default=-1)
    parser.add_argument("--ally-bots", type=int, default=-1)
    parser.add_argument("--enemy-bots", type=int, default=-1)
    parser.add_argument("--max-human-players", type=int, default=0)
    parser.add_argument("--team", type=int, default=0)
    parser.add_argument("--config-json", default="")
    parser.add_argument("--tcp-port", type=int, default=27100)
    parser.add_argument("--udp-port", type=int, default=27101)
    parser.add_argument("--join-host", help="IPv4 address or DNS name of an existing battle server")
    parser.add_argument("--char-id", type=int, help="Positive character ID, unique in the room (required with --join-host)")
    parser.add_argument("--room-id", type=int, help="Battle room ID (default: 1001)")
    parser.add_argument("--fullscreen", action="store_true")
    parser.add_argument("--smoke-seconds", type=int, default=0, help="If >0, monitor for N seconds then summarize logs and exit")
    parser.add_argument("--kill-existing", action="store_true", help="Kill existing SSJJ-Server / BattleClient before launching")
    args = parser.parse_args()
    joining = args.join_host is not None
    if joining and args.kill_existing:
        parser.error("--kill-existing cannot be used with --join-host")
    if joining and args.char_id is None:
        parser.error("--join-host requires --char-id")
    if args.char_id is not None and args.char_id <= 0:
        parser.error("--char-id must be positive")
    if args.room_id is not None and args.room_id <= 0:
        parser.error("--room-id must be positive")
    if not (1 <= args.tcp_port <= 65535 and 1 <= args.udp_port <= 65535):
        parser.error("--tcp-port and --udp-port must be in 1..65535")

    look_dbg = os.path.join(BATTLE_DIR, "LookSceneDebug.txt")
    if os.path.exists(look_dbg):
        if joining:
            parser.error(f"{look_dbg} forces the original client into offline mode; move it aside before joining")
        os.replace(look_dbg, look_dbg + ".bak")
    os.makedirs(LOG_DIR, exist_ok=True)
    client_log = os.path.join(LOG_DIR, f"server_first_client_{args.char_id}.log") if joining else CLIENT_LOG

    # 1. Verify unmodified client DLL
    actual_sha = sha256_file(CLIENT_DLL)
    if actual_sha != ORIG_SHA256:
        print(f"[FATAL] Assembly-CSharp.dll SHA256 mismatch!\n  Expected: {ORIG_SHA256}\n  Actual:   {actual_sha}", file=sys.stderr)
        sys.exit(2)
    print(f"[OK] Unmodified Assembly-CSharp.dll verified ({actual_sha[:16]}...)")

    if args.kill_existing:
        for img in ("SSJJ_BattleClient_Unity.exe", "SSJJ-Server.exe"):
            subprocess.run(["taskkill", "/F", "/IM", img], capture_output=True)
        time.sleep(0.5)

    # 2. Ensure the configured loopback resource gateway is running.
    resource_port = int(os.environ.get("SSJJ_RESOURCE_PORT", "8080"))
    if not is_port_open("127.0.0.1", resource_port):
        print("[Launch] Starting gateway_8080.py ...")
        gw_log = open(GATEWAY_LOG, "w", encoding="utf-8", errors="replace")
        subprocess.Popen([sys.executable, GATEWAY_PY], cwd=ROOT_DIR, stdout=gw_log, stderr=subprocess.STDOUT)
        for _ in range(25):
            if is_port_open("127.0.0.1", resource_port):
                break
            time.sleep(0.2)
    if not is_port_open("127.0.0.1", resource_port):
        raise RuntimeError(f"Resource gateway failed to start on :{resource_port}")
    print(f"[OK] HTTP :{resource_port} Gateway ready.")

    # 3. Build server arguments
    srv_args = [
        "--tcp-port", str(args.tcp_port),
        "--udp-port", str(args.udp_port),
    ]
    if args.char_id is not None:
        srv_args += ["--char-id", str(args.char_id)]
    if args.room_id is not None or joining:
        srv_args += ["--room-id", str(args.room_id if args.room_id is not None else 1001)]
    if joining:
        srv_args += ["--battle-host", args.join_host]
    else:
        if args.config_json:
            srv_args += ["--config-json", args.config_json]
        if args.map:
            srv_args += ["--map", args.map]
        elif not args.config_json:
            srv_args += ["--map", "map12"]
        if args.mode:
            srv_args += ["--mode", args.mode]
        elif not args.config_json:
            srv_args += ["--mode", "team_ai"]
        if args.team > 0:
            srv_args += ["--team", str(args.team)]
        if args.race_type > 0:
            srv_args += ["--race-type", str(args.race_type)]
        if args.bots >= 0:
            srv_args += ["--bots", str(args.bots)]
        if args.ally_bots >= 0:
            srv_args += ["--ally-bots", str(args.ally_bots)]
        if args.enemy_bots >= 0:
            srv_args += ["--enemy-bots", str(args.enemy_bots)]
        if args.max_human_players > 0:
            srv_args += ["--max-human-players", str(args.max_human_players)]

    # 4. Generate native -la token
    la_proc = subprocess.run([SERVER_EXE] + srv_args + ["--print-la"], capture_output=True, text=True)
    if la_proc.returncode != 0:
        sys.exit(la_proc.stderr.strip() or "Failed to generate native -la token")
    la_token = la_proc.stdout.strip().splitlines()[-1]
    print(f"[OK] Generated native -la token (len={len(la_token)})")

    # 5. Start SSJJ-Server
    srv_proc = None
    if joining:
        print(f"[Launch] Joining {args.join_host} (TCP={args.tcp_port}, UDP={args.udp_port})")
    else:
        srv_log_f = open(SERVER_LOG, "w", encoding="utf-8", errors="replace")
        srv_proc = subprocess.Popen([SERVER_EXE] + srv_args, cwd=os.path.dirname(SERVER_EXE), stdout=srv_log_f, stderr=subprocess.STDOUT)
        for _ in range(30):
            if is_port_open("127.0.0.1", args.tcp_port):
                break
            time.sleep(0.2)
        print(f"[OK] SSJJ-Server started (PID={srv_proc.pid}, log={SERVER_LOG})")

    # 6. Start unmodified BattleClient visibly on WinSta0\Default
    fs_flag = "1" if args.fullscreen else "0"
    cli_cmd = [CLIENT_EXE, "-la", la_token, "-screen-fullscreen", fs_flag, "-logFile", client_log]
    cli_proc, h_cli_proc, cli_pid = launch_battle_client_visible(cli_cmd, BATTLE_DIR)
    print(f"[OK] SSJJ_BattleClient_Unity.exe started (PID={cli_pid}, log={client_log})")

    def is_cli_alive() -> bool:
        if cli_proc is not None:
            return cli_proc.poll() is None
        code = wintypes.DWORD()
        if ctypes.windll.kernel32.GetExitCodeProcess(h_cli_proc, ctypes.byref(code)):
            return code.value == 259
        return False

    def kill_cli():
        if cli_proc is not None:
            cli_proc.terminate()
        elif h_cli_proc:
            ctypes.windll.kernel32.TerminateProcess(h_cli_proc, 0)
            ctypes.windll.kernel32.CloseHandle(h_cli_proc)

    if args.smoke_seconds > 0:
        time.sleep(args.smoke_seconds)
        server_status = f", server alive={srv_proc.poll() is None}" if srv_proc is not None else ""
        print(f"\n--- SMOKE CHECK after {args.smoke_seconds}s (client alive={is_cli_alive()}{server_status}) ---")
        if srv_proc is not None:
            srv_log_f.flush()
            try:
                with open(SERVER_LOG, "r", encoding="utf-8", errors="replace") as f:
                    print("[SERVER LOG TAIL]\n" + "".join(f.readlines()[-35:]))
            except Exception as e:
                print("Read server log failed:", e)
        try:
            with open(client_log, "r", encoding="utf-8", errors="replace") as f:
                lines = f.readlines()
                print(f"[CLIENT LOG] lines={len(lines)}")
                for line in lines[-40:]:
                    print(line.rstrip())
        except Exception as e:
            print("Read client log failed:", e)
        kill_cli()
    else:
        print("Waiting for BattleClient exit...")
        if cli_proc is not None:
            cli_proc.wait()
        elif h_cli_proc:
            ctypes.windll.kernel32.WaitForSingleObject(h_cli_proc, 0xFFFFFFFF)
            ctypes.windll.kernel32.CloseHandle(h_cli_proc)
    if srv_proc is not None:
        srv_proc.terminate()


class _STARTUPINFOW(ctypes.Structure):
    _fields_ = [
        ("cb", wintypes.DWORD),
        ("lpReserved", wintypes.LPWSTR),
        ("lpDesktop", wintypes.LPWSTR),
        ("lpTitle", wintypes.LPWSTR),
        ("dwX", wintypes.DWORD),
        ("dwY", wintypes.DWORD),
        ("dwXSize", wintypes.DWORD),
        ("dwYSize", wintypes.DWORD),
        ("dwXCountChars", wintypes.DWORD),
        ("dwYCountChars", wintypes.DWORD),
        ("dwFillAttribute", wintypes.DWORD),
        ("dwFlags", wintypes.DWORD),
        ("wShowWindow", wintypes.WORD),
        ("cbReserved2", wintypes.WORD),
        ("lpReserved2", ctypes.c_void_p),
        ("hStdInput", wintypes.HANDLE),
        ("hStdOutput", wintypes.HANDLE),
        ("hStdError", wintypes.HANDLE),
    ]


class _PROCESS_INFORMATION(ctypes.Structure):
    _fields_ = [
        ("hProcess", wintypes.HANDLE),
        ("hThread", wintypes.HANDLE),
        ("dwProcessId", wintypes.DWORD),
        ("dwThreadId", wintypes.DWORD),
    ]


def launch_battle_client_visible(cmd_list, cwd: str):
    if os.name != "nt":
        p = subprocess.Popen(cmd_list, cwd=cwd)
        return p, None, p.pid

    k32 = ctypes.windll.kernel32
    k32.GetExitCodeProcess.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
    k32.GetExitCodeProcess.restype = wintypes.BOOL
    k32.WaitForSingleObject.argtypes = [wintypes.HANDLE, wintypes.DWORD]
    k32.WaitForSingleObject.restype = wintypes.DWORD
    k32.TerminateProcess.argtypes = [wintypes.HANDLE, wintypes.UINT]
    k32.TerminateProcess.restype = wintypes.BOOL
    k32.CloseHandle.argtypes = [wintypes.HANDLE]
    k32.CloseHandle.restype = wintypes.BOOL
    k32.CreateProcessW.argtypes = [
        wintypes.LPCWSTR, wintypes.LPWSTR, ctypes.c_void_p, ctypes.c_void_p,
        wintypes.BOOL, wintypes.DWORD, ctypes.c_void_p, wintypes.LPCWSTR,
        ctypes.POINTER(_STARTUPINFOW), ctypes.POINTER(_PROCESS_INFORMATION),
    ]
    k32.CreateProcessW.restype = wintypes.BOOL

    cmd_line = subprocess.list2cmdline(cmd_list)
    si = _STARTUPINFOW()
    si.cb = ctypes.sizeof(_STARTUPINFOW)
    si.lpDesktop = "WinSta0\\Default"
    si.dwFlags = 0x00000001  # STARTF_USESHOWWINDOW
    si.wShowWindow = 1       # SW_SHOWNORMAL
    pi = _PROCESS_INFORMATION()
    ok = k32.CreateProcessW(
        None, cmd_line, None, None, False, 0, None, cwd,
        ctypes.byref(si), ctypes.byref(pi)
    )
    if not ok:
        p = subprocess.Popen(cmd_list, cwd=cwd)
        return p, None, p.pid
    k32.CloseHandle(pi.hThread)
    return None, pi.hProcess, pi.dwProcessId


if __name__ == "__main__":
    main()
