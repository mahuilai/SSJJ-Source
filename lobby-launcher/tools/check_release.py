# -*- coding: utf-8 -*-
"""发包前自检：检查便携包 ZIP 里该有的东西在不在。

用法：
    python tools/check_release.py                      # 检查 dist 下所有 zip
    python tools/check_release.py 路径\\xxx.zip          # 检查指定包

判定为「能发」的条件：离线三件套齐全且 LookSceneDebug.txt 内容为 offline、
战斗客户端主程序 + Assembly-CSharp.dll + 运行期 AssetBundles 清单都在、
启动链脚本齐全、地图目录 >= 80。

只读 ZIP 中央目录，不解压，20 GiB 的包也就几秒。
"""
from __future__ import annotations

import sys
import zipfile
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
DIST = PROJECT / "dist"

# 归档内路径 -> 说明
REQUIRED = {
    "battle/3_64/SSJJ_BattleClient_Unity.exe": "战斗客户端主程序",
    "battle/3_64/UnityPlayer.dll": "Unity 运行时",
    "battle/3_64/SSJJ_BattleClient_Unity_Data/Managed/Assembly-CSharp.dll": "客户端逻辑程序集",
    "battle/3_64/SSJJ_BattleClient_Unity_Data/StreamingAssets/AssetBundles/Windows/AssetBundles": "运行期 AssetBundle 清单",
    "battle/3_64/LookSceneDebug.txt": "离线模式开关",
    "battle/3_64/offline_flags.json": "离线模块开关",
    "battle/3_64/unity64Check.json": "版本标记",
    "scripts/start_offline.py": "战斗启动脚本",
    "scripts/prepare_launch_assets.py": "资源装配脚本",
    "scripts/install_bot_assets.py": "机器人资源脚本",
    "scripts/career_anim_map.json": "职业动画映射",
    "runtime/python/python.exe": "便携 Python 运行时",
}

EXPECT_CONTENT = {"battle/3_64/LookSceneDebug.txt": b"offline\r\n"}
MIN_MAP_DIRS = 80


def find_prefix(names: list[str]) -> str:
    """ZIP 可能有顶层目录（SSJJ离线大厅-双版本/），自动探测。"""
    for n in names:
        if n.endswith("battle/3_64/LookSceneDebug.txt"):
            return n[: -len("battle/3_64/LookSceneDebug.txt")]
    return ""


def check(path: Path) -> bool:
    print(f"\n检查：{path.name}  ({path.stat().st_size / (1024**3):.2f} GiB)")
    problems: list[str] = []

    try:
        zf = zipfile.ZipFile(path)
    except Exception as exc:
        print(f"  ✗ 打不开：{exc}")
        return False

    names = zf.namelist()
    prefix = find_prefix(names)
    if prefix:
        print(f"  顶层目录：{prefix}")
    print(f"  条目数：{len(names):,}")

    for rel, why in REQUIRED.items():
        full = prefix + rel
        if full not in names:
            problems.append(f"缺失 {rel}（{why}）")
            continue
        if rel in EXPECT_CONTENT:
            data = zf.read(full)
            if data != EXPECT_CONTENT[rel]:
                problems.append(f"内容不符 {rel}：期望 {EXPECT_CONTENT[rel]!r}，实际 {data[:40]!r}")

    maps = {n.split(prefix + "battle/3_64/SSJJ_BattleClient_Unity_Data/StreamingAssets/", 1)[1].split("/")[0]
            for n in names
            if n.startswith(prefix + "battle/3_64/SSJJ_BattleClient_Unity_Data/StreamingAssets/")
            and "/" in n[len(prefix + "battle/3_64/SSJJ_BattleClient_Unity_Data/StreamingAssets/"):]}
    map_dirs = [m for m in maps if m.startswith("map")]
    print(f"  地图目录：{len(map_dirs)} 个")
    if len(map_dirs) < MIN_MAP_DIRS:
        problems.append(f"地图目录只有 {len(map_dirs)} 个，至少应有 {MIN_MAP_DIRS} 个")

    pool = [n for n in names if n.startswith(prefix + "resources/pool/") and not n.endswith("/")]
    print(f"  resources/pool：{len(pool):,} 个文件")
    if len(pool) < 1000:
        problems.append(f"resources/pool 只有 {len(pool)} 个文件，资源没打进去")

    zf.close()

    if problems:
        print("  → 不能发：")
        for p in problems:
            print(f"      ✗ {p}")
        return False

    print("  → 可以发（离线开关齐全，资源完整）")
    return True


def main() -> int:
    args = sys.argv[1:]
    if args:
        targets = [Path(a) for a in args]
    else:
        targets = sorted(DIST.glob("*.zip"))
        if not targets:
            print(f"dist 下没有 zip：{DIST}")
            return 2

    results = [(t, check(t)) for t in targets if t.is_file()]
    print("\n" + "=" * 60)
    ok = sum(1 for _, v in results if v)
    for t, v in results:
        print(f"  {'✓ 可发' if v else '✗ 别发'}  {t.name}")
    print(f"{ok}/{len(results)} 个包通过")
    return 0 if ok == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
