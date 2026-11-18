# -*- coding: utf-8 -*-
"""Module 5: Automated live SSJJ_BattleClient_Unity.exe + SSJJ-Server sweep across all 8 modes."""
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BATTLE_DIR = Path(r"D:\SSJJ-4399\battle\3_64")
BASE_CFG = BATTLE_DIR / "launch_config.json"
LAUNCHER = ROOT / "_work" / "launch_server_client.py"
LOG_DIR = ROOT / "_work" / "mode_sweep_logs"

MODES = [
    ("explode", "map1", 2),
    ("team_ai", "map12", 2003),
    ("blade_ai", "map43", 2041),
    ("personal", "map12", 5),
    ("deathmatch", "map12", 12),
    ("weaponmaster", "map12", 64),
    ("flyknife", "map12", 74),
    ("bighead", "map12", 2019),
]


def main() -> int:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    with BASE_CFG.open("r", encoding="utf-8-sig") as f:
        template = json.load(f)

    passed = 0
    failed = 0
    for mode, map_name, race_type in MODES:
        cfg = dict(template)
        cfg["mode"] = mode
        cfg["map"] = map_name
        cfg["race_type"] = race_type
        cfg_path = LOG_DIR / f"cfg_{mode}.json"
        with cfg_path.open("w", encoding="utf-8") as f:
            json.dump(cfg, f, indent=2, ensure_ascii=False)

        print(f"=== [SWEEP] mode={mode} map={map_name} raceType={race_type} ===", flush=True)
        res = subprocess.run(
            [sys.executable, str(LAUNCHER), "--config-json", str(cfg_path), "--smoke-seconds", "13", "--kill-existing"],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=90,
        )
        out = (res.stdout or "") + "\n" + (res.stderr or "")
        (LOG_DIR / f"sweep_{mode}.log").write_text(out, encoding="utf-8")

        ok = (
            res.returncode == 0
            and "client alive=True, server alive=True" in out
            and "lastCmd=" in out
            and "ApcBodyParser" not in out
        )
        if ok:
            passed += 1
            last_tick = [ln for ln in out.splitlines() if "[SSJJ-Server][TICK" in ln]
            tail = last_tick[-1] if last_tick else "OK"
            print(f"[PASS] {mode} ({map_name}): {tail}", flush=True)
        else:
            failed += 1
            print(f"[FAIL] {mode} ({map_name}) rc={res.returncode}", flush=True)

    print(f"=== 8-MODE LIVE SWEEP SUMMARY: passed={passed}/8 failed={failed} ===", flush=True)
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
