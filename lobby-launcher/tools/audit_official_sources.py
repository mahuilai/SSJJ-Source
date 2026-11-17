#!/usr/bin/env python3
"""Audit local original-lobby inputs without scanning the battle resource cache.

This is the first reproducible gate for the AIR/SWF rebuild. It only reads files;
the optional report is written only when --output is supplied.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


def describe_file(path: Path) -> dict[str, Any]:
    if not path.is_file():
        return {"path": str(path), "exists": False}
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    with path.open("rb") as stream:
        header = stream.read(8)
    return {
        "path": str(path),
        "exists": True,
        "size": path.stat().st_size,
        "sha256": digest.hexdigest(),
        "swf": swf_header(header) if path.suffix.lower() == ".swf" else None,
    }


def swf_header(header: bytes) -> dict[str, Any] | None:
    if len(header) < 8 or header[:3] not in (b"FWS", b"CWS", b"ZWS"):
        return None
    return {"signature": header[:3].decode("ascii"), "version": header[3]}


def count_files(path: Path, suffix: str) -> int:
    return sum(1 for item in path.rglob(f"*{suffix}") if item.is_file()) if path.is_dir() else 0


def make_report(root: Path, air_root: Path | None) -> dict[str, Any]:
    lobby = root / "_work" / "lobby_air"
    scripts = lobby / "ffdec_out" / "scripts"
    ui = root / "_work" / "lobby_ui" / "view_dec"
    ssjj_main = root / "资源下载" / "大厅资源" / "SSJJ-main"
    target = lobby / "Lobby_efb5f870bf39d086296ba8864ca94496.swf"
    candidates = sorted(lobby.glob("Lobby_*.swf"))
    return {
        "schema": "ssjj.original-lobby-audit.v1",
        "workspace": str(root),
        "requested_swf": describe_file(target),
        "lobby_swf_candidates": [describe_file(path) for path in candidates],
        "decompiled_as3": {
            "root": str(scripts),
            "files": count_files(scripts, ".as"),
            "new_storage_subview": (scripts / "lobby" / "view" / "storage" / "newui" / "NewStorageSubView.as").is_file(),
            "new_role_view": (scripts / "lobby" / "view" / "newRole" / "NewRoleView.as").is_file(),
        },
        "decoded_ui_xml": {"root": str(ui), "files": count_files(ui, ".xml")},
        "ssjj_main_exports": {
            "root": str(ssjj_main / "export"),
            "exists": (ssjj_main / "export").is_dir(),
            "directories": sorted(path.name for path in (ssjj_main / "export").iterdir()) if (ssjj_main / "export").is_dir() else [],
            "swf_files": count_files(ssjj_main / "export", ".swf"),
            "as_files": count_files(ssjj_main / "export", ".as"),
        },
        "air_runtime": {
            "root": str(air_root) if air_root else None,
            "preloader_exe": describe_file(air_root / "AirLobbyPreloader.exe") if air_root else None,
            "preloader_swf": describe_file(air_root / "AirLobbyPreloader.swf") if air_root else None,
        },
        "scope_note": "No battle-client cache paths are scanned or used as lobby inventory sources.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2], help="workspace root")
    parser.add_argument("--air-root", type=Path, default=Path(r"D:\SSJJ-4399\Lobby"), help="installed AIR Lobby directory")
    parser.add_argument("--output", type=Path, help="optional JSON report destination")
    args = parser.parse_args()

    report = make_report(args.root.resolve(), args.air_root.resolve() if args.air_root else None)
    rendered = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    return 0 if report["requested_swf"]["exists"] and report["decompiled_as3"]["new_storage_subview"] and report["decompiled_as3"]["new_role_view"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
