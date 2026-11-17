"""Create a small, GitHub-ready source archive for the Rust offline lobby."""
from __future__ import annotations

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


PROJECT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = PROJECT / "dist" / "SSJJ离线大厅源码.zip"
FILES = (
    "README.md",
    "Cargo.toml",
    "Cargo.lock",
    "build.rs",
    ".gitignore",
    ".cargo/config.toml",
    "assets/icon.png",
    "assets/icon.ico",
    "data/asset_inventory.json",
    "data/official_lobby_preview_index.json",
)
DIRECTORIES = ("src", "tools", "portable")
SKIP_DIRS = {"__pycache__", "target", "dist", "shots", "大厅截图", "previews"}
SKIP_SUFFIXES = {".pyc", ".exe", ".dll", ".pdb", ".zip", ".log"}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    prefix = "ssjj-lobby-source/"
    count = 0
    with ZipFile(output, "w", compression=ZIP_DEFLATED, compresslevel=6, allowZip64=True) as archive:
        for relative in FILES:
            source = PROJECT / relative
            if source.is_file():
                archive.write(source, prefix + relative.replace("\\", "/"))
                count += 1
        for directory in DIRECTORIES:
            source_root = PROJECT / directory
            if not source_root.is_dir():
                continue
            for source in sorted(source_root.rglob("*")):
                if not source.is_file():
                    continue
                relative = source.relative_to(PROJECT)
                if any(part in SKIP_DIRS for part in relative.parts[:-1]):
                    continue
                if source.suffix.lower() in SKIP_SUFFIXES:
                    continue
                archive.write(source, prefix + relative.as_posix())
                count += 1
    print(f"源码 ZIP：{output}")
    print(f"已收录 {count:,} 个源码/配置文件，{output.stat().st_size / (1024 * 1024):.2f} MiB。")


if __name__ == "__main__":
    main()
