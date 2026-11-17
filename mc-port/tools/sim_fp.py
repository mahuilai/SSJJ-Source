# -*- coding: utf-8 -*-
"""只读：用 Python 复现 FpRender + FpConfig 的完整变换链，输出最终相机空间包围盒、投影范围和朝向。
不修改任何工程文件。"""
import json, math

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"


def ident():
    return [1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0]


def mul(a, b):
    c = [0.0] * 16
    for col in range(4):
        for row in range(4):
            c[col * 4 + row] = sum(a[k * 4 + row] * b[col * 4 + k] for k in range(4))
    return c


def xf(m, p):
    return [m[0] * p[0] + m[4] * p[1] + m[8] * p[2] + m[12],
            m[1] * p[0] + m[5] * p[1] + m[9] * p[2] + m[13],
            m[2] * p[0] + m[6] * p[1] + m[10] * p[2] + m[14]]


def xfdir(m, p):
    return [m[0] * p[0] + m[4] * p[1] + m[8] * p[2],
            m[1] * p[0] + m[5] * p[1] + m[9] * p[2],
            m[2] * p[0] + m[6] * p[1] + m[10] * p[2]]


def qmat(q):
    x, y, z, w = q
    xx, yy, zz = x * x, y * y, z * z
    xy, xz, yz = x * y, x * z, y * z
    wx, wy, wz = w * x, w * y, w * z
    return [1 - 2 * (yy + zz), 2 * (xy + wz), 2 * (xz - wy), 0,
            2 * (xy - wz), 1 - 2 * (xx + zz), 2 * (yz + wx), 0,
            2 * (xz + wy), 2 * (yz - wx), 1 - 2 * (xx + yy), 0,
            0, 0, 0, 1]


def trs(p, q, s):
    m = qmat(q)
    for i in range(3):
        m[0 + i] *= s[0]
        m[4 + i] *= s[1]
        m[8 + i] *= s[2]
    m[12], m[13], m[14] = p
    return m


def sample(clip, bone, t, pos, rot):
    ks = clip["bones"].get(bone)
    if not ks:
        return
    length = clip["length"]
    tt = t % length if (clip["loop"] and length > 1e-4) else min(t, ks[-1][0])
    if tt <= ks[0][0]:
        k = ks[0]
        pos[:] = k[1:4]
        rot[:] = k[4:8]
        return
    i = 0
    while i + 1 < len(ks) and ks[i + 1][0] <= tt:
        i += 1
    if i + 1 >= len(ks):
        k = ks[-1]
        pos[:] = k[1:4]
        rot[:] = k[4:8]
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
        th0 = math.acos(dot)
        th = th0 * f
        s0 = math.sin(th0 - th) / math.sin(th0)
        s1 = math.sin(th) / math.sin(th0)
        q = [qa[k] * s0 + qb[k] * s1 for k in range(4)]
    n = math.sqrt(sum(v * v for v in q)) or 1.0
    rot[:] = [v / n for v in q]


fp = json.load(open(FP, encoding="utf-8"))
anm = json.load(open(ANM, encoding="utf-8"))
bones = fp["skeleton"]["bones"]
idx = {b["name"]: i for i, b in enumerate(bones)}


def evaluate(clip_name, t):
    clip = anm["clips"][clip_name]
    world = [None] * len(bones)
    order = []
    pending = set(range(len(bones)))
    while pending:
        ready = [i for i in pending
                 if bones[i]["parent"] is None or idx.get(bones[i]["parent"], -1) not in pending]
        if not ready:
            raise RuntimeError("cycle")
        for i in ready:
            order.append(i)
            pending.discard(i)
    for i in order:
        b = bones[i]
        pos = list(b["local"])
        rot = list(b["rotation"])
        sample(clip, b["name"], t, pos, rot)
        local = trs(pos, rot, b["scale"])
        p = idx.get(b["parent"]) if b["parent"] else None
        world[i] = local if p is None else mul(world[p], local)
    skin = [mul(world[i], bones[i]["bindPose"]) for i in range(len(bones))]
    return world, skin


def gun_base(ads=0.0):
    s = 0.01 * 0.2 * 1.0
    tx, ty, tz = 22.46553 * 0.01 * 0.2, -12.7540 * 0.01 * 0.2, -13.93207 * 0.01 * 0.2
    return [s, 0, 0, 0, 0, 0, s, 0, 0, s, 0, 0, tx, ty, tz, 1.0]


def hand_base(ads=0.0):
    s = 0.01 * 0.2 * 1.0
    tx, ty, tz = 12.7540 * 0.01 * 0.2, 22.46553 * 0.01 * 0.2, 13.93207 * 0.01 * 0.2
    return [0, 0, s, 0, 0, s, 0, 0, s, 0, 0, 0, tx, ty, tz, 1.0]


def mesh_world(mesh, skin, base):
    out = []
    if mesh["skinned"]:
        for v, (bi, bw) in enumerate(zip(mesh["boneIdx"], mesh["boneW"])):
            p = mesh["pos"][v]
            acc = [0.0, 0.0, 0.0]
            for k in range(4):
                w = bw[k]
                if w == 0.0:
                    continue
                t = xf(skin[bi[k]], p)
                for j in range(3):
                    acc[j] += w * t[j]
            out.append(xf(base, acc))
    else:
        sm = skin[idx[mesh["rigidBone"]]]
        for p in mesh["pos"]:
            out.append(xf(base, xf(sm, p)))
    return out


def report(name, pts, fov=70.0, aspect=16 / 9):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    zs = [p[2] for p in pts]
    depth = [-z for z in zs]
    t = math.tan(math.radians(fov / 2))
    ndc = []
    front = 0
    for p in pts:
        d = -p[2]
        if d > 1e-3:
            front += 1
            ndc.append((p[0] / (d * t * aspect), p[1] / (d * t)))
    print("  %s  model-space bbox x[%+.2f,%+.2f] y[%+.2f,%+.2f] z[%+.2f,%+.2f]" % (
        name, min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))
    print("       depth(-z) %.3f..%.3f   verts in front: %d/%d" % (min(depth), max(depth), front, len(pts)))
    if ndc:
        print("       NDC x[%+.2f,%+.2f] y[%+.2f,%+.2f]  (>1 或 <-1 即被屏幕裁切)" % (
            min(n[0] for n in ndc), max(n[0] for n in ndc),
            min(n[1] for n in ndc), max(n[1] for n in ndc)))


for clip_name, t in (("idle", 0.0), ("idle", 0.02), ("walk", 0.4)):
    world, skin = evaluate(clip_name, t)
    print("=== clip=%s t=%.3f ===" % (clip_name, t))
    for mesh in fp["meshes"]:
        base = hand_base() if mesh["name"] == "hand" else gun_base()
        pts = mesh_world(mesh, skin, base)
        report(mesh["name"], pts)
    pr = [xf(world[idx[b]], b["local"]) for b in bones if b["name"] in idx]
    print()

world, skin = evaluate("idle", 0.0)
print("根骨链 world 平移：")
for b in bones:
    if b["parent"] is None:
        i = idx[b["name"]]
        m = world[i]
        print("  root %-14s pos=(%.3f, %.3f, %.3f) rotX_basis=(%.3f,%.3f,%.3f)" % (
            b["name"], m[12], m[13], m[14], m[4], m[5], m[6]))

for mesh in fp["meshes"]:
    zs = [p[2] for p in mesh["pos"]]
    xs = [p[0] for p in mesh["pos"]]
    print("\n原始 %s 顶点范围 x[%.2f,%.2f] z[%.2f,%.2f] verts=%d" % (
        mesh["name"], min(xs), max(xs), min(zs), max(zs), len(mesh["pos"])))
