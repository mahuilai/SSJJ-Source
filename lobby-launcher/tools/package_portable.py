"""Assemble the two-launcher, self-contained Windows distribution."""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[1]
WORKSPACE = PROJECT.parent
DIST = PROJECT / "dist"
STAGE = DIST / "SSJJ离线大厅-双版本"
ARCHIVE = DIST / "SSJJ离线大厅-双版本便携包.zip"
OLD_EXE = DIST / "ssjj-lobby-before-official-lobby-previews.exe"

# [FIX 2026-11-02] 出包前的强制自检清单。
#
# 事故复盘：上一版包把 LookSceneDebug.txt / offline_flags.json / unity64Check.json
# 一起写进了 robocopy 的 exclude_files（当成作者本机的临时状态），但没有任何
# 脚本负责重建。GameController.Awake() 正是用 LookSceneDebug.txt 判断走不走
# 离线分支，缺了就去连官方战服，表现是窗口出来了、进度条永远 0%。
#
# 只靠"记得别排除"不可靠，所以加一道机械校验：任何一项不达标就中止出包，
# 绝不生成一个能发出去但对方跑不起来的 ZIP。
REQUIRED_FILES = {
    # 大厅本体
    "ssjj-lobby.exe": "Rust 大厅主程序",
    "ssjj-lobby-before-official-lobby-previews.exe": "旧版大厅程序",
    "asset_inventory.json": "资源索引",
    "official_lobby_preview_index.json": "大厅预览索引",
    "_manifest_cache.xml": "官方 AssetBundle 清单（17509 条）",
    # 战斗客户端核心
    "battle/3_64/SSJJ_BattleClient_Unity.exe": "战斗客户端主程序",
    "battle/3_64/UnityPlayer.dll": "Unity 运行时",
    "battle/3_64/SSJJ_BattleClient_Unity_Data/Managed/Assembly-CSharp.dll": "客户端逻辑程序集",
    "battle/3_64/SSJJ_BattleClient_Unity_Data/StreamingAssets/AssetBundles/Windows/AssetBundles": "运行期 AssetBundle 清单",
    # 离线开关三件套 —— 缺任意一个都会卡 0% 或丢功能
    "battle/3_64/LookSceneDebug.txt": "离线模式开关（缺失＝走在线分支＝卡 0%）",
    "battle/3_64/offline_flags.json": "离线模块开关",
    "battle/3_64/unity64Check.json": "版本标记",
    # 启动链脚本
    "scripts/start_offline.py": "战斗启动脚本",
    "scripts/prepare_launch_assets.py": "资源装配脚本",
    "scripts/install_bot_assets.py": "机器人资源脚本",
    "scripts/install_map.py": "地图装配脚本",
    "scripts/career_anim_map.json": "职业动画映射",
    # 便携 Python
    "runtime/python/python.exe": "便携 Python 运行时",
}

# 需要逐字节校验内容的文件（不只是存在）
REQUIRED_CONTENT = {
    "battle/3_64/LookSceneDebug.txt": b"offline\r\n",
}

# StreamingAssets 下的地图目录数量下限（官方 84 个，留一点余量）
MIN_MAP_DIRS = 80


def verify_stage(stage: Path) -> None:
    """出包前自检：关键文件齐全 + 开关内容正确 + 地图目录数量达标。

    任何一项不满足都直接 abort，避免产出一个能发出去但对方跑不起来的包。
    """
    problems: list[str] = []

    for rel, why in REQUIRED_FILES.items():
        path = stage / rel
        if not path.is_file():
            problems.append(f"缺失 {rel}（{why}）")
        elif path.stat().st_size == 0 and rel != "battle/3_64/unity64Check.json":
            problems.append(f"空文件 {rel}（{why}）")

    for rel, expect in REQUIRED_CONTENT.items():
        path = stage / rel
        if not path.is_file():
            continue  # 缺失已在上面记录
        actual = path.read_bytes()
        if actual != expect:
            problems.append(
                f"内容不符 {rel}：期望 {expect!r}，实际 {actual[:40]!r}"
            )

    streaming = stage / "battle" / "3_64" / "SSJJ_BattleClient_Unity_Data" / "StreamingAssets"
    if not streaming.is_dir():
        problems.append(f"缺失 StreamingAssets 目录：{streaming}")
    else:
        map_dirs = [p for p in streaming.iterdir() if p.is_dir() and p.name.startswith("map")]
        if len(map_dirs) < MIN_MAP_DIRS:
            problems.append(
                f"地图目录只有 {len(map_dirs)} 个，至少应有 {MIN_MAP_DIRS} 个"
            )

    # 关键目录非空
    for rel, label in (("battle/3_64", "战斗客户端"), ("resources/pool", "资源全集"),
                       ("data/previews", "原版预览图")):
        d = stage / rel
        if not d.is_dir():
            problems.append(f"缺失目录 {rel}（{label}）")
        elif not any(d.iterdir()):
            problems.append(f"空目录 {rel}（{label}）")

    if problems:
        print("\n[自检失败] 以下问题会让接收方跑不起来，已中止出包：", flush=True)
        for p in problems:
            print(f"  ✗ {p}", flush=True)
        raise SystemExit(1)

    print(f"[自检通过] {len(REQUIRED_FILES)} 个关键文件齐全，"
          f"离线开关内容正确，地图目录 >= {MIN_MAP_DIRS} 个。", flush=True)


def require(path: Path, label: str) -> Path:
    if not path.exists():
        raise SystemExit(f"缺少{label}：{path}\n请检查 README.md 中的资源路径说明。")
    return path


def robocopy(source: Path, destination: Path, *, exclude_dirs=(), exclude_files=()) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    command = ["robocopy", str(source), str(destination), "/E", "/MT:16", "/R:1", "/W:1", "/NFL", "/NDL", "/NP"]
    if exclude_dirs:
        command += ["/XD", *map(str, exclude_dirs)]
    if exclude_files:
        command += ["/XF", *exclude_files]
    print(f"复制：{source} -> {destination}", flush=True)
    result = subprocess.run(command, check=False)
    if result.returncode > 7:
        raise SystemExit(f"robocopy 复制失败（退出码 {result.returncode}）：{source}")


def copy_python_runtime(destination: Path) -> None:
    source = Path(os.environ.get("SSJJ_PYTHON_RUNTIME", Path(sys.executable).resolve().parent))
    require(source / "python.exe", "Python 运行时 python.exe")
    py_zip = next(iter(sorted(source.glob("python3*.zip"))), None)
    if py_zip is None:
        raise SystemExit(f"Python 标准库压缩包 python3*.zip 不存在：{source}")

    destination.mkdir(parents=True, exist_ok=True)
    names = {"python.exe", py_zip.name}
    names.update(path.name for pattern in ("python3*.dll", "vcruntime*.dll", "*.pyd", "libcrypto*.dll", "libssl*.dll", "libffi*.dll", "sqlite3.dll") for path in source.glob(pattern))
    for name in sorted(names):
        candidate = source / name
        if candidate.is_file():
            shutil.copy2(candidate, destination / name)
    pth = next(iter(source.glob("python3*._pth")), None)
    if pth is None:
        raise SystemExit(f"Python embedded 路径配置 python3*._pth 不存在：{source}")
    with (destination / pth.name).open("w", encoding="ascii", newline="\n") as stream:
        stream.write(f"{py_zip.name}\n.\n")

    probe = subprocess.run(
        [str(destination / "python.exe"), "-c", "import hashlib,json,pathlib,subprocess,xml.etree.ElementTree"],
        capture_output=True,
        text=True,
        check=False,
    )
    if probe.returncode:
        raise SystemExit(f"便携 Python 运行时自检失败：{probe.stderr}")
    print(f"Python {sys.version.split()[0]} 便携运行时已准备。", flush=True)


def find_7zip() -> str:
    found = shutil.which("7z") or shutil.which("7z.exe")
    if found:
        return found
    beside_python = Path(sys.executable).resolve().parent / "7z.exe"
    if beside_python.is_file():
        return str(beside_python)
    raise SystemExit("未找到 7z.exe；请安装 7-Zip，或将 7z.exe 放到 Python 运行时目录。")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-zip", action="store_true", help="只组装目录，不创建 ZIP")
    parser.add_argument("--force-zip", action="store_true", help="允许覆盖同名 ZIP")
    parser.add_argument("--keep-stage", action="store_true", help="打包后保留约 20 GiB 的展开目录")
    args = parser.parse_args()

    game_root = Path(os.environ.get("SSJJ_GAME_ROOT", WORKSPACE.parent.parent / "SSJJ-4399"))
    pool = Path(os.environ.get("SSJJ_RESOURCE_POOL", WORKSPACE / "资源全集"))
    cache = Path(os.environ.get("SSJJ_RESOURCE_CACHE", WORKSPACE / "资源缓存"))
    manifest = Path(os.environ.get("SSJJ_OFFICIAL_MANIFEST", WORKSPACE / "_manifest_cache.xml"))

    new_candidate = PROJECT / "target" / "release" / "ssjj-lobby.exe"
    if not new_candidate.is_file():
        new_candidate = DIST / "ssjj-lobby.exe"
    new_exe = require(new_candidate, "当前 Rust 启动器")
    old_exe = require(OLD_EXE, "用户指定的旧版启动器")
    inventory = require(PROJECT / "data" / "asset_inventory.json", "资源索引")
    preview_index = require(PROJECT / "data" / "official_lobby_preview_index.json", "大厅预览索引")
    previews = require(DIST / "data" / "previews" / "official_lobby", "原版大厅预览图片目录")
    battle = require(game_root / "battle" / "3_64", "离线战斗客户端")
    pool = require(pool, "资源全集目录")
    cache = require(cache, "资源缓存目录")
    manifest = require(manifest, "官方资源 manifest")

    STAGE.mkdir(parents=True, exist_ok=True)
    shutil.copy2(new_exe, STAGE / "ssjj-lobby.exe")
    shutil.copy2(old_exe, STAGE / "ssjj-lobby-before-official-lobby-previews.exe")
    shutil.copy2(inventory, STAGE / "asset_inventory.json")
    shutil.copy2(preview_index, STAGE / "official_lobby_preview_index.json")
    data_dir = STAGE / "data"
    data_dir.mkdir(exist_ok=True)
    shutil.copy2(inventory, data_dir / inventory.name)
    shutil.copy2(preview_index, data_dir / preview_index.name)
    robocopy(previews, data_dir / "previews" / "official_lobby")
    shutil.copy2(manifest, STAGE / "_manifest_cache.xml")

    robocopy(
        battle,
        STAGE / "battle" / "3_64",
        exclude_dirs=("log",),
        # [FIX 2026-11-02] 不能再排除 LookSceneDebug.txt / offline_flags.json /
        # unity64Check.json：这三个是客户端切离线分支的开关，不是本机临时状态。
        # GameController.Awake() 只有在 game 目录存在 LookSceneDebug.txt 时才会
        # 挂上 OfflineGameController；缺了就走在线流程去连战服，界面卡在 0%。
        # 之前把它们一起排除，便携包里就没有任何离线标记，好友机器必然黑屏/卡 0%。
        # launch_config.json 仍排除：它由 scripts/prepare_launch_assets.py 按
        # 大厅选择重新生成；fp_auto_*.png 是作者本机的调试截图，也该排除。
        exclude_files=("launch_config.json", "launch_config*.json*", "fp_auto_*.png"),
    )
    robocopy(pool, STAGE / "resources" / "pool", exclude_files=("*.part", "*.tmp"))
    robocopy(cache, STAGE / "resources" / "cache", exclude_files=("*.part", "*.tmp"))

    shutil.copytree(PROJECT / "portable" / "scripts", STAGE / "scripts", dirs_exist_ok=True)
    shutil.copy2(PROJECT / "portable" / "启动器引导.ps1", STAGE / "启动器引导.ps1")
    for name in ("启动新版大厅.bat", "启动原始版大厅.bat"):
        shutil.copy2(PROJECT / "portable" / name, STAGE / name)
    copy_python_runtime(STAGE / "runtime" / "python")
    (STAGE / "README-先看我.txt").write_text(
        "4399 生死狙击离线大厅（双版本）\n\n"
        "双击「启动新版大厅.bat」运行当前 Rust 大厅；双击「启动原始版大厅.bat」运行原始启动器。\n"
        "整个目录解压后可移动，不要只单独复制 exe。首次启动会在 %APPDATA%\\ssjj-lobby 写入便携路径，保留其他配置。\n"
        "战斗客户端、地图/武器/角色资源和 Python 运行时均已随包提供。大厅离线运行，不需要安装 Python 或启动后台服务。\n"
        "说明：此包仅供个人离线研究与本地游玩，内含游戏原版资源，请勿公开上传或用于商业分发。\n",
        encoding="utf-8",
    )

    total_files = sum(1 for path in STAGE.rglob("*") if path.is_file())
    total_bytes = sum(path.stat().st_size for path in STAGE.rglob("*") if path.is_file())
    print(f"便携目录完成：{STAGE}\n文件：{total_files:,}，体积：{total_bytes / (1024 ** 3):.2f} GiB", flush=True)

    # [FIX 2026-11-02] 出包前强制自检。放在 ZIP 之前，坏包根本不生成。
    verify_stage(STAGE)

    if args.no_zip:
        return
    if ARCHIVE.exists() and not args.force_zip:
        raise SystemExit(f"ZIP 已存在，若确认重建请传 --force-zip：{ARCHIVE}")
    if ARCHIVE.exists():
        ARCHIVE.unlink()
    sevenzip = find_7zip()
    print(f"开始创建 ZIP64（仅存储不压缩，减少打包时间）：{ARCHIVE}", flush=True)
    subprocess.run([sevenzip, "a", "-tzip", "-mx=0", "-mmt=on", "-mcu=on", "-bsp1", str(ARCHIVE), "."], cwd=STAGE, check=True)
    print(f"ZIP 已完成：{ARCHIVE} ({ARCHIVE.stat().st_size / (1024 ** 3):.2f} GiB)", flush=True)
    if not args.keep_stage:
        if STAGE.resolve().parent != DIST.resolve():
            raise SystemExit(f"为避免误删，不清理非 dist 子目录：{STAGE}")
        shutil.rmtree(STAGE)
        print("已删除临时展开目录，保留 ZIP 发行包。", flush=True)


if __name__ == "__main__":
    main()
