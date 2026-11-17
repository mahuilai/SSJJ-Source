# -*- coding: utf-8 -*-
"""Export solid BSP triangles in server coordinates (BSP raw X, horizontal Y, height Z).

This is the server-side collision source for ClipMap. It uses the same RawBsp
parser as Game-SSJJ/tools/bsp_ray.py so the geometry matches the client BSP.
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "Game-SSJJ", "tools"))
from bsp_raw import RawBsp  # noqa: E402

MAP_DIR = os.path.join(ROOT, "Game-SSJJ", "Assets", "Bundles", "Map1")
OUT = os.path.join(ROOT, "SSJJ-Server", "Data", "Maps", "map1_solid.json")
SKIP = 0x0004 | 0x0008 | 0x0010 | 0x0020 | 0x8000  # sky/lava/slime/water/areaportal


def main():
    b = RawBsp(os.path.join(MAP_DIR, "data", "model.bsp.raw.bytes"))
    verts = []
    tris = []
    kept = 0
    for key, tri, si in b.triangles():
        # Keep all BSP triangles used by bsp_ray/RawBsp; content flags are
        # per-shader and do not index the triangle stream consistently.
        base = len(verts)
        for v in tri:
            p = v["p"]
            verts.append([round(p[0], 4), round(p[1], 4), round(p[2], 4)])
        tris.append([base, base + 1, base + 2])
        kept += 1
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        json.dump({"verts": verts, "tris": tris}, f, separators=(",", ":"))
    print(f"[solid] verts={len(verts)} tris={len(tris)} kept={kept} -> {OUT}")

    # quick vertical sanity at map1 spawn
    x, y = 3896.36, 1254.76
    hits = []
    for t in tris:
        p0, p1, p2 = verts[t[0]], verts[t[1]], verts[t[2]]
        d = (p1[1] - p2[1]) * (p0[0] - p2[0]) + (p2[0] - p1[0]) * (p0[1] - p2[1])
        if abs(d) < 1e-9:
            continue
        l1 = ((p1[1] - p2[1]) * (x - p2[0]) + (p2[0] - p1[0]) * (y - p2[1])) / d
        l2 = ((p2[1] - p0[1]) * (x - p2[0]) + (p0[0] - p2[0]) * (y - p2[1])) / d
        l3 = 1.0 - l1 - l2
        if l1 < -1e-4 or l2 < -1e-4 or l3 < -1e-4:
            continue
        hits.append(l1 * p0[2] + l2 * p1[2] + l3 * p2[2])
    hits.sort(reverse=True)
    print("[solid] spawn hits:", [round(v, 1) for v in hits[:8]])


if __name__ == "__main__":
    main()
