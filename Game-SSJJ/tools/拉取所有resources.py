#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SSJJ 资源批量拉取器
====================
从游戏源码逆向出的官方资源更新链路，直接对接 4399 CDN：

  1) GET  {Base}{Platform}/version.php                  -> "<manifestMd5>_<timestamp>"
  2) GET  {Base}{Platform}/AssetBundles_<ver>2019.manifest -> XML 清单（17509 个 bundle，含 md5/crc/size/依赖）
  3) GET  {Base}{Platform}/<bundleName>_<bundleMd5>       -> UnityFS 包（实测返回 "UnityFS" 头）

Base 来自 Templates/boot_config.xml 的 <ResourceBase>，线上实际值是
http://cdn.4399ssjj.com/s3/ （从原版 debug.log 抓到的真实值，内网 192.168.0.2 那套是开发配置）。

用法：
  python pull_resources.py --list                          # 只统计分类，不下载
  python pull_resources.py --match weapon/ player/ viewhand/   # 按前缀前缀下载
  python pull_resources.py --match all                     # 全量 17GB
  python pull_resources.py --match weapon/ak47 --exact      # 精确名字（含 $2 要转义）
  python pull_resources.py --match all --max-seconds 600   # 只跑 10 分钟，重跑自动续传

环境变量（都可选）：
  SSJJ_ROOT      仓库根目录，默认取脚本上两级
  SSJJ_DEST      下载目标目录，默认 <SSJJ_ROOT>/资源全集
  SSJJ_CDN       资源 CDN，默认 http://cdn.4399ssjj.com/s3/
  SSJJ_PLATFORM  平台目录名，默认 Windows

产物目录结构（与客户端 StreamingAssets 完全一致）：
  <dest>/<bundleName>_<md5>      例：weapon/ak47_86867120f6583c6debecccc30446f348
"""
import argparse
import hashlib
import os
import re
import sys
import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

# 项目根 = 本脚本上两级（Game-SSJJ/tools -> Game-SSJJ -> 仓库根）
_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.environ.get("SSJJ_ROOT") or os.path.abspath(os.path.join(_HERE, "..", ".."))

BASE = os.environ.get("SSJJ_CDN", "http://cdn.4399ssjj.com/s3/")
PLATFORM = os.environ.get("SSJJ_PLATFORM", "Windows")
# 默认下到 <仓库根>/资源全集，目录结构与客户端 StreamingAssets 一致
DEFAULT_DEST = os.environ.get("SSJJ_DEST") or os.path.join(_ROOT, "资源全集")
UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
CACHE_MANIFEST = os.path.join(_ROOT, "_manifest_cache.xml")


def http_get(url, timeout=30, retries=3):
    last = None
    for i in range(retries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.read()
        except urllib.error.HTTPError as ex:
            if ex.code == 404:
                raise
            last = ex
        except Exception as ex:
            last = ex
        time.sleep(1.0 + i)
    raise last


def fetch_version(base, plat):
    url = "%s%s/version.php" % (base, plat)
    raw = http_get(url, timeout=20).decode("utf-8", "replace").strip()
    if not raw:
        raise RuntimeError("version.php 返回空")
    return raw


def fetch_manifest(base, plat, ver, cache=CACHE_MANIFEST):
    """清单 2.9MB，本地缓存避免反复拉。"""
    if cache and os.path.isfile(cache) and os.path.getsize(cache) > 1024 * 1024:
        txt = open(cache, "rb").read().decode("utf-8", "replace")
        if "AssetBundles" in txt[:200]:
            print("[*] 使用本地清单缓存: %s (%.1f MB)" % (cache, os.path.getsize(cache) / 1048576))
            return txt
    url = "%s%s/AssetBundles_%s2019.manifest" % (base, plat, ver)
    print("[*] 下载清单: %s" % url)
    raw = http_get(url, timeout=120)
    if cache:
        try:
            open(cache, "wb").write(raw)
        except Exception:
            pass
    return raw.decode("utf-8", "replace")


def parse_manifest(txt):
    """解析清单。两种形式都要吃：<AssetBundle .../> 和 <AssetBundle ...>...</AssetBundle>"""
    out = []
    for m in re.finditer(r"<AssetBundle\s+([^>]*?)(?:/>|>(.*?)</AssetBundle>)", txt, re.S):
        attrs, body = m.group(1), m.group(2) or ""
        d = dict(re.findall(r'(\w+)="([^"]*)"', attrs))
        name = d.get("name")
        md5 = d.get("md5")
        if not name or not md5:
            continue
        out.append({
            "name": name,
            "md5": md5,
            "crc": int(d.get("crc", 0)),
            "size": int(d.get("size", 0)),
            "deps": re.findall(r'<Dependency name="([^"]+)"', body),
        })
    return out


def group_stats(items):
    groups = {}
    for it in items:
        top = it["name"].split("/")[0] if "/" in it["name"] else "(root)"
        g = groups.setdefault(top, [0, 0])
        g[0] += 1
        g[1] += it["size"]
    return groups


def md5_file(path, chunk=1 << 20):
    h = hashlib.md5()
    with open(path, "rb") as f:
        while True:
            b = f.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()


def download_one(item, dest_root, base, plat, verify=True, skip_existing=True, fast_skip=False):
    fname = "%s_%s" % (item["name"], item["md5"])
    path = os.path.join(dest_root, fname.replace("/", os.sep))
    os.makedirs(os.path.dirname(path), exist_ok=True)

    if skip_existing and os.path.isfile(path):
        sz = os.path.getsize(path)
        if sz == item["size"]:
            if fast_skip or not verify or md5_file(path) == item["md5"]:
                return ("skip", item, sz)
    url = "%s%s/%s" % (base, plat, fname.replace("\\", "/"))
    # 超时按体积自适应：socket 超时是"无数据间隔"，大包给足时间但别让死连接卡 3 分钟
    tmo = max(45, min(150, int(item["size"] / 1048576 * 10)))
    try:
        data = http_get(url, timeout=tmo, retries=2)
    except Exception as ex:
        return ("fail", item, repr(ex))
    if len(data) != item["size"]:
        return ("size-mismatch", item, "%d != %d" % (len(data), item["size"]))
    if verify:
        got = hashlib.md5(data).hexdigest()
        if got != item["md5"]:
            return ("md5-mismatch", item, "%s != %s" % (got, item["md5"]))
    tmp = path + ".part"
    with open(tmp, "wb") as f:
        f.write(data)
    os.replace(tmp, path)
    return ("ok", item, len(data))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--match", nargs="*", default=None,
                    help="按名字前缀匹配，如 weapon/ player/ maps/ ；all=全部")
    ap.add_argument("--exact", action="store_true", help="匹配项视为完整名字")
    ap.add_argument("--dest", default=DEFAULT_DEST)
    ap.add_argument("--jobs", type=int, default=8)
    ap.add_argument("--list", action="store_true", help="只列分类统计")
    ap.add_argument("--no-verify", action="store_true", help="跳过 md5 校验（快3倍）")
    ap.add_argument("--base", default=BASE)
    ap.add_argument("--platform", default=PLATFORM)
    ap.add_argument("--fast-skip", action="store_true", help="已存在且体积一致就跳过（不重算 md5）")
    ap.add_argument("--max-seconds", type=int, default=0, help="跑满 N 秒就收工（配合分批续传）")
    ap.add_argument("--shard", default=None,
                    help="分片 i/n（0 起始），配合多进程并行；例：--shard 0/2")
    args = ap.parse_args()

    plat = args.platform

    ver = fetch_version(args.base, plat)
    print("[*] version.php -> %s" % ver)
    txt = fetch_manifest(args.base, plat, ver)
    items = parse_manifest(txt)
    print("[*] 清单解析: %d 个 bundle，总计 %.1f MB" % (len(items), sum(i["size"] for i in items) / 1048576))

    if args.list or not args.match:
        print("\n%-16s %8s %12s" % ("分类", "包数", "大小(MB)"))
        print("-" * 40)
        for k, (n, sz) in sorted(group_stats(items).items(), key=lambda x: -x[1][1]):
            print("%-16s %8d %12.1f" % (k, n, sz / 1048576))
        print("-" * 40)
        print("%-16s %8d %12.1f" % ("合计", len(items), sum(i["size"] for i in items) / 1048576))
        if not args.match:
            print("\n提示：加 --match weapon/ 只统计武器；加 --match all 全量下载 17GB")
            return

    pats = args.match
    if pats == ["all"]:
        selected = items
    elif args.exact:
        wanted = set(pats)
        selected = [i for i in items if i["name"] in wanted]
    else:
        selected = [i for i in items if any(i["name"].startswith(p) for p in pats)]

    if args.shard:
        si, sn = [int(x) for x in args.shard.split("/")]
        selected = selected[si::sn]
        print("[*] 分片 %d/%d -> %d 个 bundle" % (si, sn, len(selected)))

    if not selected:
        print("[!] 没有匹配项")
        return
    # 先小后大：小包多、覆盖面广，断网也不至于卡在几个大文件上
    selected.sort(key=lambda x: x["size"])
    total = sum(i["size"] for i in selected)
    print("\n[*] 选中 %d 个 bundle，共 %.1f MB -> %s" % (len(selected), total / 1048576, args.dest))
    print("[*] 并发 %d，md5 校验 %s" % (args.jobs, "关" if args.no_verify else "开"))

    stats = {}
    done_bytes = 0
    t0 = time.time()
    with ThreadPoolExecutor(max_workers=args.jobs) as ex:
        futs = {ex.submit(download_one, it, args.dest, args.base, plat, not args.no_verify, True, args.fast_skip): it for it in selected}
        for idx, fut in enumerate(as_completed(futs), 1):
            status, item, info = fut.result()
            stats[status] = stats.get(status, 0) + 1
            if status in ("ok", "skip"):
                done_bytes += item["size"]
            else:
                print("  [!] %-14s %-45s %s" % (status, item["name"][:45], info))
            if args.max_seconds and (time.time() - t0) > args.max_seconds:
                print("  到点收工：本轮完成 %d 个，剩余可重跑续传" % idx, flush=True)
                sys.stdout.flush()
                os._exit(0)
            if idx % 20 == 0 or idx == len(selected):
                el = max(time.time() - t0, 0.001)
                print("  进度 %d/%d  已下 %.1f/%.1f MB  %.1f MB/s" % (
                    idx, len(selected), done_bytes / 1048576, total / 1048576,
                    done_bytes / 1048576 / el), flush=True)

    print("\n[*] 完成 %s，耗时 %.1fs" % (stats, time.time() - t0))
    bad = sum(v for k, v in stats.items() if k not in ("ok", "skip"))
    if bad:
        print("[!] 失败 %d 个，可重跑（已完成的会跳过）" % bad)
        sys.exit(1)


if __name__ == "__main__":
    main()
