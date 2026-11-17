# -*- coding: utf-8 -*-
"""只读：用正确的行主序矩阵布局（平移在 flat[3]/[7]/[11]）复现蒙皮，
输出手/枪在 Unity 世界（cm）中的真实包围盒与关键骨骼位置。
不修改任何工程文件。"""
import json, math

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"


def flat_to_rows(m):
    """flat[16] 行主序 -> rows[4][4]"""
    return [[m[r * 4 + c] for c in range(4)] for r in range(4)]


def rows_to_flat(M):
    return [M[r][c] for r in range(4) for c in range(4)]


def mmul(A, B):
    C = [[0.0] * 4 for _ in range(4)]
    for r in range(4):
        for c in range(4):
            C[r][c] = sum(A[r][k] * B[k][c] for k in range(4))
    return C


def xf(M, p):
    return [M[r][0] * p[0] + M[r][1] * p[1] + M[r][2] * p[2] + M[r][3] for r in range(3)]


def xfdir(M, p):
    return [M[r][0] * p[0] + M[r][1] * p[1] + M[r][2] * p[2] for r in range(3)]


def qmat(q):
    x, y, z, w = q
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y), 0.0],
            [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x), 0.0],
            [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y), 0.0],
            [0.0, 0.0, 0.0, 1.0]]


def trs(p, q, s):
    M = qmat(q)
    for r in range(3):
        for c in range(3):
            M[r][c] *= s[c]
    M[0][3], M[1][3], M[2][3] = p
    return M


def sample(clip, bone, t, pos, rot):
    ks = clip["bones"].get(bone)
    if not ks:
        return
    length = clip["length"]
    tt = t % length if (clip["loop"] and length > 1e-4) else min(t, ks[-1][0])
    if tt <= ks[0][0]:
        pos[:] = ks[0][1:4]
        rot[:] = ks[0][4:8]
        return
    i = 0
    while i + 1 < len(ks) and ks[i + 1][0] <= tt:
        i += 1
    if i + 1 >= len(ks):
        pos[:] = ks[-1][1:4]
        rot[:] = ks[-1][4:8]
        return
    a, b = ks[i], ks[i + 1]
    f = (tt - a[0]) / max(1e-5, b[0] - a[0])
    for k in range(3):
        pos[k] = a[1 + k] + (b[1 + k] - a[1 + k]) * f
    qa, qb = a[4:8], b[4:8]
    dot = sum(qa[k] * qb[k] for k in range(4))
    if dot < 0:
        qb = [-v for v in qb]
        dot = -dot
    if dot > 0.9995:
        q = [qa[k] + (qb[k] - qa[k]) * f for k in range(4)]
    else:
        th0 = math.acos(max(-1.0, min(1.0, dot)))
        th = th0 * f
        s0 = math.sin(th0 - th) / math.sin(th0)
        s1 = math.sin(th) / math.sin(th0)
        q = [qa[k] * s0 + qb[k] * s1 for k in range(4)]
    n = math.sqrt(sum(v * v for v in q)) or 1.0
    rot[:] = [v / n for v in q]


fp = json.load(open(FP, encoding="utf-8"))
anm = json.load(open(ANM, encoding="utf-8"))
bones = fp["skeleton"]["bones"]
name2i = {b["name"]: i for i, b in enumerate(bones)}

# 拓扑序
order, pending = [], set(range(len(bones)))
while pending:
    ready = [i for i in pending
             if bones[i]["parent"] is None or name2i.get(bones[i]["parent"], -1) not in pending]
    if not ready:
        raise RuntimeError("cycle")
    for i in ready:
        order.append(i)
        pending.discard(i)


def evaluate(clip_name, t):
    clip = anm["clips"][clip_name]
    world = [None] * len(bones)
    for i in order:
        b = bones[i]
        pos = list(b["local"])
        rot = list(b["rotation"])
        sample(clip, b["name"], t, pos, rot)
        local = trs(pos, rot, b["scale"])
        p = name2i.get(b["parent"]) if b["parent"] else None
        world[i] = local if p is None else mmul(world[p], local)
    skin = [mmul(world[i], flat_to_rows(bones[i]["bindPose"])) for i in range(len(bones))]
    return world, skin


def skinned(mesh, skin):
    out = []
    for v in range(len(mesh["pos"])):
        p = mesh["pos"][v]
        acc = [0.0, 0.0, 0.0]
        for k in range(4):
            w = mesh["boneW"][v][k]
            if not w:
                continue
            t = xf(skin[mesh["boneIdx"][v][k]], p)
            for j in range(3):
                acc[j] += w * t[j]
        out.append(acc)
    return out


def rigid(mesh, skin):
    sm = skin[name2i[mesh["rigidBone"]]]
    return [xf(sm, p) for p in mesh["pos"]]


def bbox(tag, pts):
    print("  %-22s" % tag)
    for j, ax in enumerate("xyz"):
        vals = [p[j] for p in pts]
        print("       %s %10.3f .. %10.3f" % (ax, min(vals), max(vals)))
    c = [sum(p[j] for p in pts) / len(pts) for j in range(3)]
    print("       centroid (%8.3f, %8.3f, %8.3f)" % tuple(c))


hand_mesh = [m for m in fp["meshes"] if m["name"] == "hand"][0]
gun_mesh = [m for m in fp["meshes"] if m["name"] == "gun"][0]

for clip_name, t in (("idle", 0.0), ("fire", 0.30), ("bolt", 0.20)):
    world, skin = evaluate(clip_name, t)
    print("=== clip=%s t=%.3f（Unity 世界, cm）===" % (clip_name, t))
    cols = []
    for i in range(len(bones)):
        S = skin[i]
        cols.append(max(math.sqrt(sum(S[r][c] ** 2 for r in range(3))) for c in range(3)))
    print("  skin 列长 max=%.5f min=%.5f（应≈1）" % (max(cols), min(cols)))
    bbox("hand 蒙皮后", skinned(hand_mesh, skin))
    bbox("gun 刚性后", rigid(gun_mesh, skin))
    wa = skin[name2i["WeaponAnchor"]]
    print("  WeaponAnchor pos=(%.3f, %.3f, %.3f)" % (wa[0][3], wa[1][3], wa[2][3]))
    gr = skin[name2i["gun_root"]]
    print("  gun_root skin pos=(%.3f, %.3f, %.3f) X=(%.3f,%.3f,%.3f) Y=(%.3f,%.3f,%.3f) Z=(%.3f,%.3f,%.3f)" % (
        gr[0][3], gr[1][3], gr[2][3],
        gr[0][0], gr[1][0], gr[2][0], gr[0][1], gr[1][1], gr[2][1], gr[0][2], gr[1][2], gr[2][2]))
    w, s = world, skin
    print()
