# -*- coding: utf-8 -*-
"""视模型软件光栅化预览器（不依赖 MC、不依赖 GL）。

用途：在本地就能看到「按某组轴映射 + 缩放 + 平移」渲染出来是什么样，
避免每次改 Java 都让用户重启游戏验证。

用法：
  python preview_viewmodel.py                     # 用默认参数出一张
  python preview_viewmodel.py --map xyz           # 轴映射 (x,y,-z)
  python preview_viewmodel.py --map xzy           # 轴映射 (x,z,y)
  python preview_viewmodel.py --scale 0.2 --tz 0.7 --out a.png
"""
import argparse
import json
import math
import os
import struct

from PIL import Image

W, H = 720, 405
NEAR, FAR = 0.05, 200.0

ROOT = r"D:\逆向\SSJJ双塔惊魂\ssjj-port"
GLTF = os.path.join(ROOT, r"src\main\resources\assets\ssjjport\fp\awm.gltf")
BIN = os.path.join(ROOT, r"src\main\resources\assets\ssjjport\fp\awm.bin")
TEX = os.path.join(ROOT, r"src\main\resources\assets\ssjjport\fp\awm.png")


def load_gltf():
    g = json.load(open(GLTF, encoding="utf-8"))
    data = open(BIN, "rb").read()
    acc, views = g["accessors"], g["bufferViews"]

    def read(ai):
        a = acc[ai]
        v = views[a["bufferView"]]
        off = v.get("byteOffset", 0) + a.get("byteOffset", 0)
        n = a["count"]
        comps = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}[a["type"]]
        fmt = {5126: "f", 5123: "H", 5125: "I", 5121: "B"}[a["componentType"]]
        return struct.unpack_from("<" + fmt * (n * comps), data, off)

    prim = g["meshes"][0]["primitives"][0]
    pos = read(prim["attributes"]["POSITION"])
    uv = read(prim["attributes"]["TEXCOORD_0"]) if "TEXCOORD_0" in prim["attributes"] else None
    idx = read(prim["indices"])
    return pos, uv, idx


def base_matrix(mode, scale, tx, ty, tz):
    """列主序 4x4。mode=xyz 表示 (x, y, -z)；xzy 表示 (x, z, y)。"""
    s = scale
    if mode == "xyz":
        # x'=s*x+tx, y'=s*y+ty, z'=-s*z+tz
        return [[s, 0, 0, tx],
                [0, s, 0, ty],
                [0, 0, -s, tz],
                [0, 0, 0, 1]]
    if mode == "xzy":
        # x'=s*x+tx, y'=s*z+ty, z'=s*y+tz
        return [[s, 0, 0, tx],
                [0, 0, s, ty],
                [0, s, 0, tz],
                [0, 0, 0, 1]]
    raise SystemExit("unknown map mode: " + mode)


def apply(m, p):
    x, y, z = p
    return (m[0][0] * x + m[0][1] * y + m[0][2] * z + m[0][3],
            m[1][0] * x + m[1][1] * y + m[1][2] * z + m[1][3],
            m[2][0] * x + m[2][1] * y + m[2][2] * z + m[2][3])


def render(mode, scale, tx, ty, tz, fov_deg, out_path, tex_on=True):
    pos, uv, idx = load_gltf()
    tex = Image.open(TEX).convert("RGBA") if (tex_on and os.path.isfile(TEX)) else None
    tw, th = (tex.size if tex else (1, 1))

    m = base_matrix(mode, scale, tx, ty, tz)
    n = len(pos) // 3
    cam = [apply(m, (pos[i * 3], pos[i * 3 + 1], pos[i * 3 + 2])) for i in range(n)]

    f = 1.0 / math.tan(math.radians(fov_deg) / 2.0)
    aspect = W / float(H)
    img = Image.new("RGB", (W, H), (24, 32, 24))
    px = img.load()
    zbuf = [[1e9] * W for _ in range(H)]

    def project(p):
        x, y, z = p
        if z > -NEAR:
            return None
        w = -z
        nx = (f / aspect) * x / w
        ny = f * y / w
        return ((nx + 1.0) * 0.5 * W, (1.0 - ny) * 0.5 * H, w)

    drawn = 0
    clipped = 0
    for t in range(0, len(idx), 3):
        a, b, c = idx[t], idx[t + 1], idx[t + 2]
        pa, pb, pc = project(cam[a]), project(cam[b]), project(cam[c])
        if pa is None or pb is None or pc is None:
            clipped += 1
            continue
        drawn += 1
        xs = [pa[0], pb[0], pc[0]]
        ys = [pa[1], pb[1], pc[1]]
        x0, x1 = max(0, int(min(xs))), min(W - 1, int(max(xs)) + 1)
        y0, y1 = max(0, int(min(ys))), min(H - 1, int(max(ys)) + 1)
        if x1 < x0 or y1 < y0:
            continue
        d = (pb[1] - pc[1]) * (pa[0] - pc[0]) + (pc[0] - pb[0]) * (pa[1] - pc[1])
        if abs(d) < 1e-9:
            continue
        ua = (uv[a * 2], uv[a * 2 + 1]) if uv else (0.5, 0.5)
        ub = (uv[b * 2], uv[b * 2 + 1]) if uv else (0.5, 0.5)
        uc = (uv[c * 2], uv[c * 2 + 1]) if uv else (0.5, 0.5)
        for y in range(y0, y1 + 1):
            row = zbuf[y]
            for x in range(x0, x1 + 1):
                w0 = ((pb[1] - pc[1]) * (x - pc[0]) + (pc[0] - pb[0]) * (y - pc[1])) / d
                w1 = ((pc[1] - pa[1]) * (x - pc[0]) + (pa[0] - pc[0]) * (y - pc[1])) / d
                w2 = 1.0 - w0 - w1
                if w0 < -1e-6 or w1 < -1e-6 or w2 < -1e-6:
                    continue
                z = w0 * pa[2] + w1 * pb[2] + w2 * pc[2]
                if z >= row[x]:
                    continue
                row[x] = z
                if tex:
                    u = w0 * ua[0] + w1 * ub[0] + w2 * uc[0]
                    v = w0 * ua[1] + w1 * ub[1] + w2 * uc[1]
                    uu = min(tw - 1, max(0, int(u % 1.0 * tw)))
                    vv = min(th - 1, max(0, int((1.0 - v % 1.0) * th)))
                    r, g_, b_, _ = tex.getpixel((uu, vv))
                else:
                    shade = 0.45 + 0.55 * abs(w1)
                    r = int(200 * shade); g_ = int(210 * shade); b_ = int(230 * shade)
                px[x, y] = (r, g_, b_)

    img.save(out_path)
    print("%-28s map=%-4s scale=%-5s t=(%.2f,%.2f,%.2f) fov=%.0f  tris=%d clipped=%d  -> %s"
          % (os.path.basename(out_path), mode, scale, tx, ty, tz, fov_deg, drawn, clipped, out_path))
    return out_path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="xyz", choices=["xyz", "xzy"])
    ap.add_argument("--scale", type=float, default=0.01)
    ap.add_argument("--tx", type=float, default=0.12)
    ap.add_argument("--ty", type=float, default=-0.20)
    ap.add_argument("--tz", type=float, default=0.0)
    ap.add_argument("--fov", type=float, default=75.0)
    ap.add_argument("--out", default=os.path.join(ROOT, "notes", "debug", "preview.png"))
    ap.add_argument("--notex", action="store_true")
    a = ap.parse_args()
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    render(a.map, a.scale, a.tx, a.ty, a.tz, a.fov, a.out, not a.notex)


if __name__ == "__main__":
    main()
