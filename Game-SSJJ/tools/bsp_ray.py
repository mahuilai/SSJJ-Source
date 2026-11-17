# -*- coding: utf-8 -*-
"""在 BSP 里对给定 XZ 做竖直射线，找脚下与头顶的实体面，用于定位出生点。

坐标：BSP 原始三元组 (X, 水平Z, 高度Y)，本脚本内部统一用 ssjj 语义：
  x = 第0分量, y = 高度 (第2分量), z = 水平 (第1分量)
输出同时给出 Unity 坐标 (-z, y, x)。
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bsp_raw import RawBsp


def tri_hit_xz(p0, p1, p2, x, z):
    """返回 (hit, y) —— 点在三角形 XZ 投影内时给出该平面的高度 y"""
    (x0, z0), (x1, z1), (x2, z2) = (p0[0], p0[1]), (p1[0], p1[1]), (p2[0], p2[1])
    d = (z1 - z2) * (x0 - x2) + (x2 - x1) * (z0 - z2)
    if abs(d) < 1e-9:
        return False, 0.0
    l1 = ((z1 - z2) * (x - x2) + (x2 - x1) * (z - z2)) / d
    l2 = ((z2 - z0) * (x - x2) + (x0 - x2) * (z - z2)) / d
    l3 = 1.0 - l1 - l2
    if l1 < -1e-6 or l2 < -1e-6 or l3 < -1e-6:
        return False, 0.0
    y = l1 * p0[2] + l2 * p1[2] + l3 * p2[2]
    return True, y


def ray(b, x, z):
    """返回 (下方所有面 [按 y 降序], 上方所有面 [按 y 升序])"""
    hits = []
    for key, tri, si in b.triangles():
        p = [v["p"] for v in tri]
        ok, y = tri_hit_xz(p[0], p[1], p[2], x, z)
        if ok:
            hits.append((y, key, si))
    hits.sort(reverse=True)
    return hits


def main(mapdir, points):
    b = RawBsp(os.path.join(mapdir, "data", "model.bsp.raw.bytes"))
    for (x, z) in points:
        hits = ray(b, x, z)
        print("\n=== ssjj X=%.1f  Z(水平)=%.1f   -> unity X=%.1f Z=%.1f"
              % (x, z, -z, x))
        for (y, key, si) in hits:
            print("    y=%10.2f  %-22s surf=%d" % (y, key, si))
        if not hits:
            print("    (该点无任何面)")


if __name__ == "__main__":
    m = sys.argv[1]
    pts = []
    for a in sys.argv[2:]:
        a, bb = a.split(",")
        pts.append((float(a), float(bb)))
    main(m, pts)
