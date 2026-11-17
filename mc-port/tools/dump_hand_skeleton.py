# -*- coding: utf-8 -*-
"""导出 viewhand 手模的骨骼层级（名字/父级/绝对 pivot），并列出 hand_man.anm 的 clip。

用途：P5 合模需要把 TaCZ geo 的 bones[].pivot 填成手模骨骼的真实世界坐标。
"""
import json
import os
import sys

import UnityPy

VIEWHAND = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else \
        [f for f in os.listdir(VIEWHAND) if f.startswith("man_")][0]
    env = UnityPy.load(os.path.join(VIEWHAND, name))

    gos, trs = {}, {}
    for o in env.objects:
        if o.type.name == "GameObject":
            try:
                gos[o.path_id] = o.read_typetree().get("m_Name")
            except Exception:
                pass
        elif o.type.name == "Transform":
            try:
                trs[o.path_id] = o.read_typetree()
            except Exception:
                pass

    # 每个 Transform: m_GameObject, m_Father, m_LocalPosition/Rotation/Scale
    def gname(t):
        return gos.get((t.get("m_GameObject") or {}).get("m_PathID"))

    parent = {}
    for pid, t in trs.items():
        parent[pid] = (t.get("m_Father") or {}).get("m_PathID")

    def abs_pos(pid, depth=0):
        t = trs.get(pid)
        if not t or depth > 64:
            return [0.0, 0.0, 0.0]
        p = t.get("m_LocalPosition") or {"x": 0, "y": 0, "z": 0}
        me = [p.get("x", 0), p.get("y", 0), p.get("z", 0)]
        fa = parent.get(pid)
        if not fa or fa not in trs:
            return me
        base = abs_pos(fa, depth + 1)
        # 只累加平移（忽略旋转对子级位置的贡献，骨骼链多为无旋转或小角度）
        return [base[i] + me[i] for i in range(3)]

    rows = []
    for pid, t in trs.items():
        n = gname(t)
        if not n:
            continue
        fa = parent.get(pid)
        rows.append({"name": n, "parent": gname(trs[fa]) if fa in trs else None,
                     "pivot": [round(v, 3) for v in abs_pos(pid)]})

    # 按层级排序：父在前
    order, seen = [], set()

    def visit(n):
        if n in seen:
            return
        seen.add(n)
        for r in rows:
            if r["name"] == n:
                order.append(r)
                for c in rows:
                    if c["parent"] == n:
                        visit(c["name"])
                break

    roots = [r["name"] for r in rows if not r["parent"]]
    for r in roots:
        visit(r)
    for r in rows:
        if r["name"] not in seen:
            order.append(r)

    dst = os.path.join(OUT, "hand_skeleton.json")
    with open(dst, "w", encoding="utf-8") as f:
        json.dump(order, f, ensure_ascii=False, indent=1)
    print("skeleton bones:", len(order), "->", dst)
    for r in order[:10]:
        print("   %-24s parent=%-22s pivot=%s" % (r["name"], r["parent"], r["pivot"]))


if __name__ == "__main__":
    main()
