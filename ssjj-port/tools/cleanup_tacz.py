# -*- coding: utf-8 -*-
"""
把 TACZ 遗留**归档（移动，不删除）**到
    D:\\逆向\\SSJJ双塔惊魂\\_archive\\tacz-legacy-20261109\\

设计约束（对应 ENG-01 任务书）：
  1. 先检测游戏进程（tasklist 找 oneclient_app.exe / javaw.exe）。
     只要检测到在跑：打印提示、**拒绝改动运行时 mods 与 .minecraft\\tacz**、
     只归档工程侧文件，并以非零退出码 2 结束（提示关服后重跑）。
  2. 不改正在运行的游戏 mods 目录；不改 mc-port\\fpmod 任何文件；
     保留 mc-port\\tools（ssjj2gltf.py 要复用）。
  3. 幂等：已归档(src 不在 / dst 已在)直接 SKIP；src 与 dst 同时存在报 CONFLICT 不动。
  4. 每一步打印**真实路径**（Path.resolve() 解析 junction/软链）与大小。
  5. 只做 move，不 os.remove / 不 rmtree 源数据。

用法（**默认就是 dry-run**，只打印清单不落盘）：
    PY="C:/Users/Mahuilai/AppData/Local/Programs/Python/Python314/python"
    "$PY" "...\\cleanup_tacz.py"            # 默认 dry-run，只打印清单
    "$PY" "...\\cleanup_tacz.py" --apply    # 真实移动，需输入 YES 确认

退出码：
    0 = 全部目标已归档 / 本来就不存在（且游戏未运行）
    1 = 冲突或出错
    2 = 检测到游戏进程：运行时目标已跳过，仅工程侧处理完毕（关服后重跑）
    3 = --apply 的确认门未通过（输入不是 YES 或 EOF），未移动任何文件
"""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------- 路径常量
PROJECT_ROOT = Path(r"D:\逆向\SSJJ双塔惊魂")
ARCHIVE_ROOT = PROJECT_ROOT / "_archive" / "tacz-legacy-20261109"

MINECRAFT = Path(r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft")
MODS_DIR = MINECRAFT / "mods" / "1.21.1 Fabric"   # junction -> clusters\1.21.1 Fabric\mods
TACZ_DIR = MINECRAFT / "tacz"

MC_PORT = PROJECT_ROOT / "mc-port"
PACK_SSJJ = MC_PORT / "pack" / "ssjj"
OUT_JARS = MC_PORT / "out" / "jars"

# 运行时 mods 里的 4 个 TACZ 遗留 jar（精确文件名，不做模糊匹配）
RUNTIME_MOD_JARS = [
    "tacz-refabricated-1.0.0-neo1.2.0+mc1.21.1.jar",
    "tacz-mesh-loader-fabric-1.21.1-0.2.0.jar",
    "ForgeConfigAPIPort-v21.1.6-1.21.1-Fabric.jar",
    "ssjj-fp-0.1.0.jar",
]

# 工程侧死包：只归档 0.5.0 / 0.7.1 两个版本，其他 jar 一律不动
DEAD_JARS = [
    "TACZ-Refabricated-1.21.1-0.5.0-forge1.1.7-hotfix2.jar",
    "TACZ-Refabricated-1.21.1-0.7.1-forge1.1.8-hotfix2.jar",
]

# 明确保留、绝不触碰
KEEP_PATHS = [
    MC_PORT / "tools",
    MC_PORT / "fpmod",
]

GAME_PROCESSES = ("oneclient_app.exe", "javaw.exe")


# ---------------------------------------------------------------- 工具函数
def human(n: int) -> str:
    return f"{n:,} B ({n / 1024 / 1024:.2f} MiB)"


def size_of(p: Path) -> int:
    """文件返回字节数；目录返回递归总字节数。"""
    if p.is_file():
        return p.stat().st_size
    if p.is_dir():
        total = 0
        for root, _dirs, files in os.walk(p):
            for f in files:
                try:
                    total += (Path(root) / f).stat().st_size
                except OSError:
                    pass
        return total
    return 0


def real(p: Path) -> Path:
    """解析 junction / 软链，拿到真实路径用于打印。"""
    try:
        return p.resolve()
    except OSError:
        return p


def detect_game_process() -> tuple[bool, list[str], str]:
    """
    用 tasklist 检测游戏进程。
    返回 (是否检测到, 命中的进程名列表, 诊断说明)。
    tasklist 不可用 / 调用失败时保守地返回 True（视为在运行），避免误改运行时目录。
    """
    try:
        proc = subprocess.run(
            ["tasklist", "/FO", "CSV", "/NH"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30,
        )
    except (OSError, subprocess.SubprocessError) as e:
        return True, [], f"tasklist 调用失败({e})，保守判定为「运行中」"

    # D1：tasklist 非零退出或输出为空同样视为「检测不可用」→ 保守按运行中处理。
    # 绝不能把「探测失败」当成「没在运行」而放行运行时目录。
    if proc.returncode != 0 or not (proc.stdout or b"").strip():
        err = (proc.stderr or b"").decode("utf-8", errors="replace").strip()
        return True, [], (f"tasklist returncode={proc.returncode}，stdout 为空"
                          + (f"，stderr={err}" if err else "")
                          + "，保守判定为「运行中」")

    text = proc.stdout.decode("utf-8", errors="replace")
    if not text.strip():
        text = proc.stdout.decode(locale_encoding(), errors="replace")

    hits: list[str] = []
    for line in text.splitlines():
        low = line.lower()
        for name in GAME_PROCESSES:
            if name in low and name not in hits:
                hits.append(name)
    diag = f"tasklist 返回 {len(text.splitlines())} 行，命中 {hits or '无'}"
    return (len(hits) > 0), hits, diag


def locale_encoding() -> str:
    import locale
    return locale.getpreferredencoding(False) or "mbcs"


def guard_keep(target: Path) -> None:
    """硬保护：任何归档动作都不允许落到保留目录内。"""
    t = str(real(target)).lower()
    for keep in KEEP_PATHS:
        k = str(real(keep)).lower()
        if t == k or t.startswith(k + os.sep):
            raise RuntimeError(f"拒绝操作保留目录: {target} (KEEP {keep})")


def archive_one(src: Path, dst: Path, label: str, dry_run: bool) -> str:
    """
    归档单个文件/目录（move）。返回状态：
        moved / skipped_archived / skipped_missing / conflict / dry_run
    """
    src_r, dst_r = real(src), real(dst)
    guard_keep(src)
    guard_keep(dst)

    if not src_r.exists():
        if dst_r.exists():
            print(f"  [SKIP ] {label}: 源已不存在，归档已存在 -> {dst_r}")
            return "skipped_archived"
        print(f"  [SKIP ] {label}: 源不存在 -> {src_r}")
        return "skipped_missing"

    if dst_r.exists():
        print(f"  [CONFLICT] {label}: 源和归档同时存在，人工确认前不动")
        print(f"              src={src_r} ({human(size_of(src_r))})")
        print(f"              dst={dst_r} ({human(size_of(dst_r))})")
        return "conflict"

    sz = human(size_of(src_r))
    print(f"  [{'DRY-RUN' if dry_run else 'MOVE  '}] {label}")
    print(f"              from : {src_r}")
    print(f"              to   : {dst_r}")
    print(f"              size : {sz}")
    if dry_run:
        return "dry_run"

    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(src_r), str(dst_r))  # 移动，不删除
    print(f"              done : {dst_r} ({human(size_of(dst_r))})")
    return "moved"


# ---------------------------------------------------------------- 主流程
def main() -> int:
    ap = argparse.ArgumentParser(description="归档 TACZ 遗留（移动不删除）")
    ap.add_argument("--apply", action="store_true",
                    help="真实执行归档；不带此参数时只做 dry-run（默认，不落盘）")
    ap.add_argument("--dry-run", action="store_true",
                    help="兼容旧用法；dry-run 已是默认行为")
    args = ap.parse_args()
    # F1：--dry-run 优先。只要命令行写了 --dry-run 就一定不落盘，
    # 避免「以为在看清单、结果真移动」。真实执行必须只给 --apply。
    if args.apply and args.dry_run:
        args.apply = False
        print("[i] 同时给了 --apply 与 --dry-run：以 --dry-run 为准，本次不落盘。")
    dry_run = not args.apply

    print("=" * 78)
    print("TACZ 遗留归档（移动，不删除）")
    print("=" * 78)
    print(f"工程根     : {real(PROJECT_ROOT)}")
    print(f"归档根     : {real(ARCHIVE_ROOT)}")
    print(f"模式       : {'DRY-RUN（默认，不落盘）' if dry_run else 'APPLY（真实移动）'}")
    print()

    # ---- 0) 保留目录显式声明（只读，不改动）
    print("[0] 明确保留（本脚本绝不触碰）")
    for keep in KEEP_PATHS:
        k = real(keep)
        print(f"  [KEEP ] {k}  ({human(size_of(k)) if k.exists() else '不存在'})")
    print()

    # ---- 1) 先检测游戏进程（必须第一步）
    running, hits, diag = detect_game_process()
    print("[1] 游戏进程检测")
    print(f"  tasklist: {diag}")
    if running:
        print(f"  !! 检测到游戏进程 {hits or '(检测不可用，按运行处理)'}")
        print("  !! 拒绝改动运行时 mods 与 .minecraft\\tacz。")
        print("  !! 本次只归档工程侧文件；关闭游戏后请原样重跑本脚本。")
    else:
        print("  OK 未检测到 oneclient_app.exe / javaw.exe，运行时目标允许归档。")
    print()

    # ---- 1.5) --apply 确认门（D3：默认 dry-run，真实执行必须显式确认）
    if args.apply:
        print("[!] APPLY 模式：将真实移动以下目标（移动，不删除）。")
        print("    输入 YES 确认，其他任意输入取消：")
        try:
            answer = input("> ")
        except EOFError:
            answer = ""
        if answer.strip() != "YES":
            print("已取消，未移动任何文件。")
            return 3
        print("  已确认。")
        print()

    # ---- 2) 运行时目标
    print("[2] 运行时目标（OneClient 1.21.1 Fabric 集群 + .minecraft\\tacz）")
    mods_r = real(MODS_DIR)
    print(f"  mods 真实路径: {mods_r}")
    if running:
        for name in RUNTIME_MOD_JARS:
            src = mods_r / name
            print(f"  [BLOCK] {name}  (真实路径 {real(src)})")
        tacz_r = real(TACZ_DIR)
        print(f"  [BLOCK] .minecraft\\tacz  (真实路径 {tacz_r}, "
              f"{human(size_of(tacz_r)) if tacz_r.exists() else '不存在'})")
        runtime_states: list[str] = []
    else:
        runtime_states = []
        for name in RUNTIME_MOD_JARS:
            runtime_states.append(archive_one(
                mods_r / name,
                ARCHIVE_ROOT / "mods-1.21.1-fabric" / name,
                f"mods/{name}", dry_run))
        runtime_states.append(archive_one(
            real(TACZ_DIR),
            ARCHIVE_ROOT / "minecraft-tacz" / "tacz",
            ".minecraft/tacz (整个目录)", dry_run))
    print()

    # ---- 3) 工程侧目标（无论游戏是否运行都处理）
    print("[3] 工程侧目标（mc-port/pack/ssjj + out/jars 的 0.5.0/0.7.1 死包）")
    project_states = []
    project_states.append(archive_one(
        PACK_SSJJ,
        ARCHIVE_ROOT / "mc-port" / "pack" / "ssjj",
        "mc-port/pack/ssjj (旧枪包草稿)", dry_run))
    for name in DEAD_JARS:
        project_states.append(archive_one(
            OUT_JARS / name,
            ARCHIVE_ROOT / "mc-port" / "out" / "jars" / name,
            f"mc-port/out/jars/{name} (死包)", dry_run))
    print()

    # ---- 4) 汇总
    all_states = runtime_states + project_states
    conflicts = [s for s in all_states if s == "conflict"]
    ok = ("moved", "dry_run", "skipped_archived", "skipped_missing")
    anomalies = [s for s in all_states if s not in ok]
    print("[4] 汇总")
    print(f"  运行时目标 : {len(runtime_states)} 项，状态 {runtime_states or '本次全部跳过（游戏运行中）'}")
    print(f"  工程侧目标 : {len(project_states)} 项，状态 {project_states}")
    print(f"  异常/冲突  : {len(anomalies)} 项 {anomalies}")
    if not dry_run and ARCHIVE_ROOT.exists():
        print(f"  归档根     : {real(ARCHIVE_ROOT)}  总大小 {human(size_of(ARCHIVE_ROOT))}")
    print()

    if running:
        print("游戏仍在运行：运行时 mods / tacz 已跳过。关闭游戏后重跑本脚本完成归档。")
        return 2
    if conflicts:
        print("存在 CONFLICT，需人工确认后重跑。")
        return 1
    print("完成：所有目标已归档或本来已归档（幂等）。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
