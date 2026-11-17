#!/usr/bin/env python3
"""Build and assemble a portable Rust offline lobby directory."""
from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist"
EXE = ROOT / "target" / "release" / "ssjj-lobby.exe"


def main() -> None:
    subprocess.run(["cargo", "build", "--release"], cwd=ROOT, check=True)
    if not EXE.is_file():
        raise SystemExit(f"release executable was not produced: {EXE}")

    DIST.mkdir(parents=True, exist_ok=True)
    shutil.copy2(EXE, DIST / EXE.name)
    shutil.copy2(ROOT / "data" / "asset_inventory.json", DIST / "asset_inventory.json")

    shutil.copy2(
        ROOT / "data" / "official_lobby_preview_index.json",
        DIST / "official_lobby_preview_index.json",
    )
    source_previews = ROOT / "data" / "previews" / "official_lobby"
    output_previews = DIST / "data" / "previews" / "official_lobby"
    if source_previews.is_dir():
        shutil.copytree(source_previews, output_previews, dirs_exist_ok=True)

    count = sum(1 for path in output_previews.rglob("*.png")) if output_previews.is_dir() else 0
    print(f"portable build: {DIST}")
    print(f"official lobby preview icons copied: {count}")
    print("The inventory and official lobby preview index are embedded; exported SWF icons are in data/previews/official_lobby/.")


if __name__ == "__main__":
    main()
