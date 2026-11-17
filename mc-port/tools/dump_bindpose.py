# -*- coding: utf-8 -*-
"""从 Mesh 的 m_BindPose 反算骨骼在「网格空间」的绝对位置（与顶点同一坐标系）。

Unity 的 bindpose 是骨骼世界变换的逆，因此 inverse(bindpose) 的平移列就是骨骼位置。
输出 out/hand_bindpose.json：{name, parent, pivot}
"""
import json
import os
import sys

import UnityPy

VIEWHAND = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"


def inv_translation(m):
    """m: 16 floats column-major 4x4（Unity Matrix4x4 序列化顺序）。返回 inverse 的平移部分。"""
    # Unity 序列化为 row-major 的 4x4（e00,e01,e02,e03, e10,...），最后一列是平移
    e = m
    r = [[e[0], e[1], e[2]], [e[4], e[5], e[6]], [e[8], e[9], e[10]]]
    t = [e[3], e[7], e[11]]
    # 判定行列式，避免奇异
    det = (r[0][0] * (r[1][1] * r[2][2] - r[1][2] * r[2][1])
           - r[0][1] * (r[1][0] * r[2][2] - r[1][2] * r[2][0])
           + r[0][2] * (r[1][0] * r[2][1] - r[1][1] * r[2][0]))
    if abs(det) < 1e-9:
        return None, det
    # inverse(r) * (-t)
    inv = [[0.0] * 3 for _ in range(3)]
    inv[0][0] = (r[1][1] * r[2][2] - r[1][2] * r[2][1]) / det
    inv[0][1] = (r[0][2] * r[2][1] - r[0][1] * r[2][2]) / det
    inv[0][2] = (r[0][1] * r[1][2] - r[0][2] * r[1][1]) / det
    inv[1][0] = (r[1][2] * r[2][0] - r[1][0] * r[2][2]) / det
    inv[1][1] = (r[0][0] * r[2][2] - r[0][2] * r[2][0]) / det
    inv[1][2] = (r[0][2] * r[1][0] - r[0][0] * r[1][2]) / det
    inv[2][0] = (r[1][0] * r[2][1] - r[1][1] * r[2][0]) / det
    inv[2][1] = (r[0][1] * r[2][0] - r[0][0] * r[2][1]) / det
    inv[2][2] = (r[0][0] * r[1][1] - r[0][1] * r[1][0]) / det
    nt = [-t[0], -t[1], -t[2]]
    return [sum(inv[i][j] * nt[j] for j in range(3)) for i in range(3)], det


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

    def gname(t):
        return gos.get((t.get("m_GameObject") or {}).get("m_PathID"))

    parent_of = lambda pid: gname(trs[(trs[pid].get("m_Father") or {}).get("m_PathID")]) \
        if (trs[pid].get("m_Father") or {}).get("m_PathID") in trs else None

    mesh = None
    smr = None
    for o in env.objects:
        if o.type.name == "Mesh" and mesh is None:
            mesh = o.read()
        elif o.type.name == "SkinnedMeshRenderer" and smr is None:
            smr = o.read_typetree()
    if mesh is None or smr is None:
        print("missing mesh/smr")
        return

    bone_pids = [(x or {}).get("m_PathID") for x in (smr.get("m_Bones") or [])]
    binds = mesh.m_BindPose or []
    print("bones=%d bindpose=%d" % (len(bone_pids), len(binds)))

    rows = []
    for i, pid in enumerate(bone_pids):
        nm = gname(trs[pid]) if pid in trs else None
        if i < len(binds):
            m = binds[i]
            flat = [m.e00, m.e01, m.e02, m.e03, m.e10, m.e11, m.e12, m.e13,
                    m.e20, m.e21, m.e22, m.e23, m.e30, m.e31, m.e32, m.e33]
            pos, det = inv_translation(flat)
        else:
            pos, det = None, 0
        rows.append({"name": nm, "parent": parent_of(pid) if pid in trs else None,
                     "pivot": [round(v, 3) for v in pos] if pos else None})
    dst = os.path.join(OUT, "hand_bindpose.json")
    with open(dst, "w", encoding="utf-8") as f:
        json.dump(rows, f, ensure_ascii=False, indent=1)
    print("->", dst)
    for r in rows[:8]:
        print("   %-24s parent=%-22s pivot=%s" % (r["name"], r["parent"], r["pivot"]))


if __name__ == "__main__":
    main()
