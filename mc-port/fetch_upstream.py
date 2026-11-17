#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""拉取 SSJJ -> Minecraft 移植所需的上游源码，并导出 TaCZ 默认枪包结构供参考。

用法：
    python fetch_upstream.py --dry-run     # 只打印将要执行的命令
    python fetch_upstream.py               # 实际执行（浅克隆）
    python fetch_upstream.py --with-fallback   # 同时拉 1.20.1 Forge LTS 分支

说明：
  * 只拉源码与参考结构，不会修改游戏客户端、不会编译、不会生成任何产物。
  * TaCZ 默认枪包资产是 CC BY-NC-ND 4.0（禁演绎/非商业），这里只导出
    "目录结构文本" 作为格式参考，不复制任何模型/贴图/音效到我们的枪包。
"""
import argparse
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
UPSTREAM = os.path.join(HERE, "upstream")

TACZ_REPO = "https://github.com/MCModderAnchor/TACZ.git"
BRANCHES = {
    "1.21.1": ("1.21.1", "1.2.0-neoforge-1.21.1"),
    "1.20.1": ("1.20.1", "1.2.0-forge-mc1.20.1"),
}
OTHER_REPOS = {
    "Figura": "https://github.com/FiguraMC/Figura.git",
    "geckolib": "https://github.com/bernie-g/geckolib.git",
    "AssetRipper": "https://github.com/AssetRipper/AssetRipper.git",
    "blockbench": "https://github.com/JannisX11/blockbench.git",
    "litematica": "https://github.com/maruohon/litematica.git",
}


def run(cmd, dry):
    print("[cmd] " + " ".join(cmd), flush=True)
    if dry:
        return 0
    return subprocess.call(cmd)


def clone(repo, dest, ref, dry):
    if os.path.isdir(os.path.join(dest, ".git")):
        print("[skip] already cloned: " + dest, flush=True)
        return
    cmd = ["git", "clone", "--depth", "1"]
    if ref and ref != "HEAD":
        cmd += ["--branch", ref]
    cmd += [repo, dest]
    if dry:
        print("[cmd] " + " ".join(cmd), flush=True)
        return
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    rc = run(cmd, dry=False)
    if rc != 0:
        print("[warn] clone failed rc=%d (check network / git availability)" % rc, flush=True)


def dump_gunpack_tree(tacz_dir, out_path, dry):
    """把默认枪包的目录结构写成纯文本，供后续建 ssjj 枪包对照。"""
    if dry or not os.path.isdir(tacz_dir):
        print("[dry] would write " + out_path, flush=True)
        return
    roots = []
    for base, dirs, files in os.walk(tacz_dir):
        dirs[:] = [d for d in dirs if d not in (".git", "build", ".gradle", "run")]
        if any(f in files for f in ("pack.json", "tab.json")):
            roots.append(base)
        if len(roots) >= 3:
            break
    lines = ["# TaCZ default gun pack structure (reference only, do NOT copy assets)", ""]
    for root in roots:
        lines.append("## " + os.path.relpath(root, tacz_dir))
        for base, dirs, files in os.walk(root):
            dirs[:] = sorted(d for d in dirs if not d.startswith("."))
            rel = os.path.relpath(base, root)
            depth = 0 if rel == "." else rel.count(os.sep) + 1
            lines.append("  " * depth + (os.path.basename(base) if rel != "." else ".") + "/")
            for f in sorted(files)[:12]:
                lines.append("  " * (depth + 1) + f)
            if len(lines) > 260:
                lines.append("  ... (truncated)")
                break
    with open(out_path, "w", encoding="utf-8") as fp:
        fp.write("\n".join(lines) + "\n")
    print("[ok] " + out_path + "  roots=" + str(len(roots)), flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--with-fallback", action="store_true", help="also clone 1.20.1 Forge LTS")
    ap.add_argument("--all-upstreams", action="store_true", help="also clone Figura/GeckoLib/AssetRipper/etc")
    args = ap.parse_args()

    os.makedirs(UPSTREAM, exist_ok=True)
    print("[info] target = " + UPSTREAM, flush=True)

    wanted = ["1.21.1"] + (["1.20.1"] if args.with_fallback else [])
    for key in wanted:
        branch, tag = BRANCHES[key]
        dest = os.path.join(UPSTREAM, "TACZ-" + key)
        clone(TACZ_REPO, dest, branch, args.dry_run)
        dump_gunpack_tree(dest, os.path.join(UPSTREAM, "gunpack_structure_" + key + ".txt"), args.dry_run)

    if args.all_upstreams:
        for name, repo in OTHER_REPOS.items():
            clone(repo, os.path.join(UPSTREAM, name), "HEAD", args.dry_run)

    print("[done] stack.lock.json is the authority; this script only fetches references.", flush=True)


if __name__ == "__main__":
    main()
