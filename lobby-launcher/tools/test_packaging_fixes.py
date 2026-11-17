# -*- coding: utf-8 -*-
"""单测两处修复：ensure_offline_markers 自愈 + verify_stage 拦截坏包。

不触碰真实 20 GiB 目录，全部在临时目录里用假文件验证。
"""
import importlib.util
import os
import shutil
import sys
import tempfile
from pathlib import Path

PROJECT = Path(r"D:\逆向\SSJJ双塔惊魂\lobby-launcher")
FAIL = []


def check(label, cond, detail=""):
    print(("  PASS " if cond else "  FAIL ") + label + (f"  {detail}" if detail else ""))
    if not cond:
        FAIL.append(label)


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


# ---------- 1. ensure_offline_markers ----------
print("\n[1] start_offline.ensure_offline_markers 自愈测试")

tmp = Path(tempfile.mkdtemp(prefix="ssjj_marker_"))
try:
    game = tmp / "battle" / "3_64"
    game.mkdir(parents=True)

    # 用环境变量把 GAME 指到临时目录（模块在 import 时读环境变量）
    os.environ["SSJJ_GAME_DIR"] = str(game)
    os.environ["SSJJ_BUNDLE_ROOT"] = str(tmp)
    mod = load_module("start_offline_test", PROJECT / "portable" / "scripts" / "start_offline.py")

    # 场景 A：三个文件都不存在
    mod.OFFLINE_MARKERS = mod.OFFLINE_MARKERS  # 已就绪
    mod.ensure_offline_markers()
    for name, payload in mod.OFFLINE_MARKERS.items():
        p = game / name
        check(f"空目录应创建 {name}", p.is_file() and p.read_bytes() == payload,
              f"{p.stat().st_size if p.is_file() else 'MISSING'}B")

    # 场景 B：内容被改坏
    (game / "LookSceneDebug.txt").write_bytes(b"garbage content here!!")
    mod.ensure_offline_markers()
    check("内容被改坏应纠正回 offline",
          (game / "LookSceneDebug.txt").read_bytes() == b"offline\r\n",
          repr((game / "LookSceneDebug.txt").read_bytes()))

    # 场景 C：已正确，不应重复写（用 mtime 判断）
    before = (game / "LookSceneDebug.txt").stat().st_mtime_ns
    mod.ensure_offline_markers()
    after = (game / "LookSceneDebug.txt").stat().st_mtime_ns
    check("已正确时不应重写", before == after)

    # 场景 D：unity64Check.json 允许 0 字节
    check("unity64Check.json 应为 0 字节",
          (game / "unity64Check.json").stat().st_size == 0)
finally:
    shutil.rmtree(tmp, ignore_errors=True)
    os.environ.pop("SSJJ_GAME_DIR", None)
    os.environ.pop("SSJJ_BUNDLE_ROOT", None)


# ---------- 2. verify_stage ----------
print("\n[2] package_portable.verify_stage 拦截测试")

os.environ["SSJJ_GAME_ROOT"] = r"D:\SSJJ-4399"
os.environ["SSJJ_RESOURCE_POOL"] = str(PROJECT.parent / "资源全集")
os.environ["SSJJ_RESOURCE_CACHE"] = str(PROJECT.parent / "资源缓存")
os.environ["SSJJ_OFFICIAL_MANIFEST"] = str(PROJECT.parent / "_manifest_cache.xml")
pkg = load_module("package_portable_test", PROJECT / "tools" / "package_portable.py")

tmp = Path(tempfile.mkdtemp(prefix="ssjj_stage_"))
try:
    # 场景 A：空 stage 必须失败
    empty = tmp / "empty"
    empty.mkdir()
    raised = False
    try:
        pkg.verify_stage(empty)
    except SystemExit:
        raised = True
    check("空 stage 必须中止出包", raised)

    # 场景 B：构造齐全的 stage
    stage = tmp / "good"
    for rel in pkg.REQUIRED_FILES:
        p = stage / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        if rel in pkg.REQUIRED_CONTENT:
            p.write_bytes(pkg.REQUIRED_CONTENT[rel])
        else:
            p.write_bytes(b"x")
    # 地图目录
    streaming = stage / "battle" / "3_64" / "SSJJ_BattleClient_Unity_Data" / "StreamingAssets"
    for i in range(pkg.MIN_MAP_DIRS):
        (streaming / f"map{i}").mkdir(parents=True, exist_ok=True)
    for rel in ("resources/pool", "data/previews"):
        d = stage / rel
        d.mkdir(parents=True, exist_ok=True)
        (d / "placeholder.bin").write_bytes(b"x")

    raised = False
    try:
        pkg.verify_stage(stage)
    except SystemExit:
        raised = True
    check("齐全的 stage 应通过", not raised)

    # 场景 C：删掉 LookSceneDebug.txt 必须失败
    (stage / "battle/3_64/LookSceneDebug.txt").unlink()
    raised = False
    try:
        pkg.verify_stage(stage)
    except SystemExit:
        raised = True
    check("缺 LookSceneDebug.txt 必须中止", raised)

    # 场景 D：内容被改成 online 必须失败
    (stage / "battle/3_64/LookSceneDebug.txt").write_bytes(b"online\r\n")
    raised = False
    try:
        pkg.verify_stage(stage)
    except SystemExit:
        raised = True
    check("LookSceneDebug.txt 内容不是 offline 必须中止", raised)

    # 场景 E：地图目录不足必须失败
    (stage / "battle/3_64/LookSceneDebug.txt").write_bytes(b"offline\r\n")
    for i in range(10):
        shutil.rmtree(streaming / f"map{i}", ignore_errors=True)
    raised = False
    try:
        pkg.verify_stage(stage)
    except SystemExit:
        raised = True
    check("地图目录不足必须中止", raised)
finally:
    shutil.rmtree(tmp, ignore_errors=True)
    for k in ("SSJJ_GAME_ROOT", "SSJJ_RESOURCE_POOL", "SSJJ_RESOURCE_CACHE",
              "SSJJ_OFFICIAL_MANIFEST"):
        os.environ.pop(k, None)


print("\n" + ("全部通过" if not FAIL else f"失败 {len(FAIL)} 项: {FAIL}"))
sys.exit(1 if FAIL else 0)
