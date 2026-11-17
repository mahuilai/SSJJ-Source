# -*- coding: utf-8 -*-
"""
按 SSJJ BspReader 语义提取 BSP 的 brush(clip) 碰撞几何 -> Unity 可用网格。

lump 语义（BspReader.cs 实证）：
  lump[2]  planes      16B = normal(3f) + dist(f)     约定: n·p <= dist 为内侧
  lump[8]  brushes     12B = firstSide(i) + numSides(i) + shader(i)
  lump[9]  brushSides   8B = planeIndex(i) + shader(i)
  lump[1]  shaders     72B = name[64] + surfaceFlags(i) + contentFlags(i)

坐标：BSP 用 (X, 水平Z, 高度Y)；Unity = (-水平Z, 高度Y, X)
"""
import struct, json, os, math
from collections import Counter

SRC = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Assets\Bundles\Map1\Data\model.bsp.raw.bytes"
OUT = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Assets\Bundles\Map1\Collision"

d = open(SRC, "rb").read()
L = [struct.unpack_from("<ii", d, 8 + i * 8) for i in range(19)]

so, sl = L[1]
shaders = []
for i in range(sl // 72):
    off = so + i * 72
    nm = d[off:off + 64].split(b"\0")[0].decode("latin1")
    sf, cf = struct.unpack_from("<ii", d, off + 64)
    shaders.append((nm, sf, cf))

po, pl = L[2]
planes = [struct.unpack_from("<4f", d, po + i * 16) for i in range(pl // 16)]
bso, bsl = L[9]
bsides = [struct.unpack_from("<ii", d, bso + i * 8) for i in range(bsl // 8)]
bo, bl = L[8]
brushes = [struct.unpack_from("<iii", d, bo + i * 12) for i in range(bl // 12)]

print("[clip] shaders=%d planes=%d brushSides=%d brushes=%d"
      % (len(shaders), len(planes), len(bsides), len(brushes)))
print("[clip] contentFlags:", Counter(shaders[s][2] for _, _, s in brushes).most_common())

# 内容位
CONT_SOLID   = 0x0001
CONT_WATER   = 0x0020
CONT_LAVA    = 0x0008
CONT_SLIME   = 0x0010
CONT_MIST    = 0x0040
CONT_AREAPORTAL = 0x8000
SKIP = CONT_WATER | CONT_LAVA | CONT_SLIME | CONT_MIST | CONT_AREAPORTAL


def solve3(a, b, c):
    """三平面交点（n·p = d）"""
    (a1, a2, a3, a4) = a; (b1, b2, b3, b4) = b; (c1, c2, c3, c4) = c
    det = (a1 * (b2 * c3 - b3 * c2) - a2 * (b1 * c3 - b3 * c1) + a3 * (b1 * c2 - b2 * c1))
    if abs(det) < 1e-8:
        return None
    x = (a4 * (b2 * c3 - b3 * c2) - a2 * (b4 * c3 - b3 * c4) + a3 * (b4 * c2 - b2 * c4)) / det
    y = (a1 * (b4 * c3 - b3 * c4) - a4 * (b1 * c3 - b3 * c1) + a3 * (b1 * c4 - b4 * c1)) / det
    z = (a1 * (b2 * c4 - b4 * c2) - a2 * (b1 * c4 - b4 * c1) + a4 * (b1 * c2 - b2 * c1)) / det
    return (x, y, z)


def brush_corners(sides):
    n = len(sides)
    pts = []
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                P = solve3(sides[i], sides[j], sides[k])
                if P is None:
                    continue
                if all(px * P[0] + py * P[1] + pz * P[2] - pd <= 1e-2
                       for px, py, pz, pd in sides):
                    dup = False
                    for q in pts:
                        if (abs(q[0] - P[0]) < 1e-2 and abs(q[1] - P[1]) < 1e-2
                                and abs(q[2] - P[2]) < 1e-2):
                            dup = True
                            break
                    if not dup:
                        pts.append(P)
    return pts


def face_poly(sides, ci):
    """该平面上的顶点（已属于凸体），按平面内极角排序"""
    nx, ny, nz, dist = sides[ci]
    if len(pts_all) < 3:
        return []
    # 平面内基
    if abs(nx) < 0.9:
        ux, uy, uz = 0.0, -nz, ny
    else:
        ux, uy, uz = -nz, 0.0, nx
    ul = math.sqrt(ux * ux + uy * uy + uz * uz) or 1.0
    ux, uy, uz = ux / ul, uy / ul, uz / ul
    vx = ny * uz - nz * uy
    vy = nz * ux - nx * uz
    vz = nx * uy - ny * ux
    poly = sorted(pts_all, key=lambda p: math.atan2(
        (p[0]) * vx + (p[1]) * vy + (p[2]) * vz,
        (p[0]) * ux + (p[1]) * uy + (p[2]) * uz))
    # 去掉共线点
    out = []
    for p in poly:
        if not out:
            out.append(p); continue
        q = out[-1]
        if abs(p[0] - q[0]) < 1e-3 and abs(p[1] - q[1]) < 1e-3 and abs(p[2] - q[2]) < 1e-3:
            continue
        out.append(p)
    return out if len(out) >= 3 else []


def ssjj2u(p):
    x, y, z = p
    return (-y, z, x)


verts, tris = [], []
bmin = [1e18] * 3
bmax = [-1e18] * 3
kept = 0
for first, n, sh in brushes:
    nm, sf, cf = shaders[sh]
    if cf == 0 or (cf & SKIP):
        continue
    sides = [planes[bsides[first + k][0]] for k in range(n)]
    global pts_all
    pts_all = brush_corners(sides)
    if len(pts_all) < 4:
        continue
    kept += 1
    for ci in range(n):
        poly = face_poly(sides, ci)
        if len(poly) < 3:
            continue
        st = len(verts)
        for p in poly:
            u = ssjj2u(p)
            verts.append(u)
            for a in range(3):
                bmin[a] = min(bmin[a], u[a]); bmax[a] = max(bmax[a], u[a])
        for k in range(1, len(poly) - 1):
            tris.append((st, st + k, st + k + 1))

print("[clip] kept brushes=%d verts=%d tris=%d" % (kept, len(verts), len(tris)))
print("[clip] unity bounds min=%s max=%s"
      % (tuple(round(x, 1) for x in bmin), tuple(round(x, 1) for x in bmax)))

os.makedirs(OUT, exist_ok=True)
json.dump({"verts": verts, "tris": tris},
          open(os.path.join(OUT, "map1_clip.json"), "w"), separators=(",", ":"))
print("[clip] wrote map1_clip.json")
