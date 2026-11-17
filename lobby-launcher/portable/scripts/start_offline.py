# -*- coding: utf-8 -*-
"""Portable launcher for the already-patched offline battle client."""
from __future__ import annotations

import os
import subprocess
import sys
import time
from pathlib import Path


_SCRIPT = Path(__file__).resolve()
_DEFAULT_ROOT = _SCRIPT.parents[3] if _SCRIPT.parent.parent.name == "portable" else _SCRIPT.parents[1]
ROOT = Path(os.environ.get("SSJJ_BUNDLE_ROOT", _DEFAULT_ROOT)).resolve()
GAME = Path(os.environ.get("SSJJ_GAME_DIR", ROOT / "battle" / "3_64")).resolve()
GAME_EXE = GAME / "SSJJ_BattleClient_Unity.exe"
SCRIPTS = _SCRIPT.parent if _SCRIPT.parent.parent.name == "portable" else ROOT / "scripts"
LOG_DIR = GAME / "log"
LAUNCHER_LOG = LOG_DIR / "launcher.log"
OFFLINE_LOG = LOG_DIR / "offline.log"
HELPERS = (
    SCRIPTS / "prepare_launch_assets.py",
    SCRIPTS / "install_bot_assets.py",
)

# [FIX 2026-11-02] 离线模式标记文件。
#
# GameController.Awake() 的第一行就是：
#     if (File.Exists("LookSceneDebug.txt")) {
#         GetComponent<GameController>().enabled = false;
#         gameObject.AddComponent<OfflineGameController>();   // 切离线
#         return;
#     }
# 没有这个文件 -> 走在线 GameController.Start() -> 先起 RuntimeCheatGuard、
# 再 LoadSceneAsync("BattleLoading") 去连战服 -> 界面永远停在 0%。
# 日志特征：Unity 起来后在 "Setting up N worker threads for Enlighten" 之后
# 完全静默，且能看到 "RuntimeCheatGuard started"。
#
# 这三个文件原先被 tools/package_portable.py 加进了 exclude_files（本意是
# 避免把作者本机的临时状态带出去），但没有任何脚本负责重建，于是便携包里
# 缺失 -> 好友机器上必然走在线分支。现在改成每次启动前强制补齐。
OFFLINE_MARKERS = {
    "LookSceneDebug.txt": b"offline\r\n",
    "offline_flags.json": b'{"modules": "anim+ui", "trace": false}',
    "unity64Check.json": b"",
}


def log(message: str) -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with LAUNCHER_LOG.open("a", encoding="utf-8") as stream:
        stream.write(f"[{stamp}] {message}\n")


def run_helper(script: Path) -> bool:
    result = subprocess.run(
        [sys.executable, str(script)],
        cwd=str(GAME),
        env={**os.environ, "SSJJ_BUNDLE_ROOT": str(ROOT), "PYTHONUTF8": "1"},
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=600,
        check=False,
    )
    log(f"helper={script.name} exit={result.returncode}\n{result.stdout[-12000:]}")
    return result.returncode == 0


def ensure_offline_markers() -> None:
    """确保离线模式标记文件存在，且内容与作者机器一致。

    LookSceneDebug.txt 是 GameController.Awake() 判定离线分支的唯一依据，
    缺了就会去连战服、卡在 0%。其余两个是资源模块开关和版本标记。
    已存在时只校验大小，不覆盖用户手动改过的内容。
    """
    for name, payload in OFFLINE_MARKERS.items():
        path = GAME / name
        if path.is_file() and path.stat().st_size == len(payload):
            continue
        if path.is_file() and payload:
            # 内容非空但大小不符：作者机器上这类文件只有一种正确内容，直接纠正
            log(f"marker repaired: {name} ({path.stat().st_size} -> {len(payload)} bytes)")
        elif not path.is_file():
            log(f"marker created: {name} ({len(payload)} bytes)")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(payload)


def main() -> int:
    if not GAME_EXE.is_file():
        log(f"ERROR: battle executable missing: {GAME_EXE}")
        return 2

    for script in HELPERS:
        if not script.is_file():
            log(f"ERROR: helper script missing: {script}")
            return 2

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log("==== portable battle launch ====")
    # 必须在启动客户端之前补齐：决定走离线还是在线分支。
    ensure_offline_markers()
    for image in ("SSJJ_BattleClient_Unity.exe", "UnityCrashHandler64.exe"):
        subprocess.run(["taskkill", "/f", "/im", image], capture_output=True, check=False)
    time.sleep(0.5)

    # The package contains the verified, already-injected client DLL. Never run
    # the author's rebuild/injection toolchain on another machine.
    for script in HELPERS:
        if not run_helper(script):
            log(f"ERROR: preparing resources failed: {script.name}")
            return 3

    args = [
        str(GAME_EXE),
        "-screen-fullscreen", "0",
        "-screen-width", "2240",
        "-screen-height", "1260",
        "-logFile", str(OFFLINE_LOG),
    ]
    flags = getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0) | getattr(subprocess, "DETACHED_PROCESS", 0)
    subprocess.Popen(args, cwd=str(GAME), close_fds=True, creationflags=flags)
    log("battle client started")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        try:
            log(f"FATAL: {error!r}")
        finally:
            raise
