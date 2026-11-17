# -*- coding: utf-8 -*-
"""P0.5-D: 从 Modrinth v2 下载 TaCZ 生态 jar，校验 sha512，并读 fabric.mod.json。

用法:
  python fetch_mod_jars.py --list          只列候选，不下载
  python fetch_mod_jars.py --fetch         下载到 mc-port/out/jars/ 并校验
  python fetch_mod_jars.py --install      把选定组合装进 1.21.1 Fabric 集群

数据源: https://api.modrinth.com/v2/project/{id}/version (免 token)
集群:  C:/Users/Mahuilai/AppData/Roaming/Polyfrost/OneClient/.minecraft/mods/1.21.1 Fabric
       (符号链接 -> clusters/1.21.1 Fabric/mods)，只写这一个集群。
"""
import argparse
import hashlib
import io
import json
import os
import shutil
import sys
import urllib.request
import zipfile

ROOT = r"D:\逆向\SSJJ双塔惊魂"
CACHE = os.path.join(ROOT, "mc-port", "out", "jars")
CLUSTER = (r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient"
           r"\.minecraft\mods\1.21.1 Fabric")
HDR = {"User-Agent": "ssjj-mcport/1.0"}


def api(url):
    for i in range(3):
        try:
            req = urllib.request.Request(url, headers=HDR)
            with urllib.request.urlopen(req, timeout=25) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception as e:
            if i == 2:
                raise
    raise RuntimeError("unreachable")


def versions(project):
    return api("https://api.modrinth.com/v2/project/" + project + "/version")


def pick(project, predicate):
    for v in versions(project):
        if predicate(v):
            prim = [f for f in v.get("files", []) if f.get("primary")]
            f = prim[0] if prim else v["files"][0]
            return {
                "version": v.get("version_number"),
                "id": v.get("id"),
                "filename": f["filename"],
                "url": f["url"],
                "sha512": f.get("hashes", {}).get("sha512"),
                "size": f.get("size"),
            }
    return None


def candidates():
    # TML 0.2.0 的 fabric.mod.json 写死 depends: {"tacz": ">=1.0.0-"}，
    # 因此 0.5.0 / 0.7.1 都不兼容，必须用 1.0.0-neo1.2.0+mc1.21.1。
    # Refabricated 还强制依赖 forgeconfigapiport（集群原本缺），一并装。
    out = {}
    for key, project, pred in [
        ("tml", "SnuAzTh0", lambda v: v.get("version_number") == "0.2.0"
         and "1.21.1" in v.get("game_versions", [])
         and "fabric" in v.get("loaders", [])),
        ("refab_120", "tacz-refabricated", lambda v: v.get("version_number", "").startswith("1.0.0-neo1.2.0")
         and "1.21.1" in v.get("game_versions", [])),
        ("refab_050", "tacz-refabricated", lambda v: v.get("version_number", "").startswith("1.21.1-0.5.0")
         and "1.21.1" in v.get("game_versions", [])),
        ("refab_071", "tacz-refabricated", lambda v: v.get("version_number", "").startswith("1.21.1-0.7.1")
         and "1.21.1" in v.get("game_versions", [])),
        ("fgaport", "ohNO6lps", lambda v: "1.21.1-Fabric" in v.get("version_number", "")
         and "fabric" in v.get("loaders", [])),
    ]:
        out[key] = pick(project, pred)
    return out


def download(item):
    os.makedirs(CACHE, exist_ok=True)
    dst = os.path.join(CACHE, item["filename"])
    if os.path.isfile(dst):
        d = open(dst, "rb").read()
        if not item["sha512"] or hashlib.sha512(d).hexdigest() == item["sha512"]:
            print("  [cached] %s (%d B, sha512 OK)" % (item["filename"], len(d)))
            return dst
    data = api_bytes(item["url"])
    digest = hashlib.sha512(data).hexdigest()
    if item["sha512"] and digest != item["sha512"]:
        raise RuntimeError("sha512 mismatch: %s" % item["filename"])
    with open(dst, "wb") as f:
        f.write(data)
    print("  [download] %s (%d B, sha512 %s)" % (item["filename"], len(data), digest[:16]))
    return dst


def api_bytes(url):
    req = urllib.request.Request(url, headers=HDR)
    with urllib.request.urlopen(req, timeout=90) as r:
        return r.read()


def mod_meta(path):
    try:
        with zipfile.ZipFile(path) as z:
            for name in ("fabric.mod.json", "META-INF/mods.toml"):
                if name in z.namelist():
                    d = json.loads(z.read(name).decode("utf-8-sig"))
                    return {
                        "id": d.get("id"),
                        "version": d.get("version"),
                        "depends": d.get("depends"),
                        "breaks": d.get("breaks"),
                        "entrypoints": sorted((d.get("entrypoints") or {}).keys()),
                    }
    except Exception as e:
        return {"error": "%s: %s" % (type(e).__name__, str(e)[:80])}
    return {"error": "no mod metadata"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--fetch", action="store_true")
    ap.add_argument("--install", action="store_true")
    ap.add_argument("--combo", default="", help="逗号分隔的候选 key，如 refab_120,tml")
    args = ap.parse_args()

    c = candidates()
    print("=== 候选 ===")
    for k, v in c.items():
        print("  %-12s %s" % (k, ("%s | %s" % (v["version"], v["filename"])) if v else "NOT FOUND"))
    if args.list:
        return

    if args.fetch:
        print("=== 下载 + 校验 ===")
        for k, v in c.items():
            if v:
                download(v)
        print("=== fabric.mod.json ===")
        for k, v in c.items():
            if not v:
                continue
            p = os.path.join(CACHE, v["filename"])
            if os.path.isfile(p):
                print("  %-12s %s" % (k, json.dumps(mod_meta(p), ensure_ascii=False)[:600]))

    if args.install:
        keys = [x.strip() for x in args.combo.split(",") if x.strip()]
        if not keys:
            print("--install 需要 --combo，例如 --combo refab_120,tml", file=sys.stderr)
            sys.exit(2)
        os.makedirs(CLUSTER, exist_ok=True)
        print("=== 安装到", CLUSTER, "===")
        for k in keys:
            v = c.get(k)
            if not v:
                raise RuntimeError("unknown candidate " + k)
            src = download(v)
            dst = os.path.join(CLUSTER, v["filename"])
            shutil.copy2(src, dst)
            print("  [install] %s" % dst)
        print("=== 集群里 TaCZ/TML jar ===")
        for f in sorted(os.listdir(CLUSTER)):
            if any(x in f.lower() for x in ("tacz", "mesh-loader", "tml")):
                print("  ", f, os.path.getsize(os.path.join(CLUSTER, f)))


if __name__ == "__main__":
    main()
