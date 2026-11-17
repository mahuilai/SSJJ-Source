# -*- coding: utf-8 -*-
"""只读验证：用 prefab local TRS 的逆作为 bindPose，重算蒙皮 bbox。
同时在原版 anm 里找能给出真实 bindPose 的量（源曲线第一帧 vs prefab）。不修改任何工程文件。
"""
import json, math

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
HAND_ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\hand_man_anm.json"


def ident():
    return [1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0]


def mul(a, b):
    c = [0.0] * 16
    for col in range(4):
        for row in range(4):
            c[col * 4 + row] = sum(a[k * 4 + row] * b[col * 4 + k] for k in range(4))
    return c


def qmat(q):
    x, y, z, w = q
    return [1 - 2 * (y * y + z * z), 2 * (x * y + w * z), 2 * (x * z - w * y), 0.0,
            2 * (x * y - w * z), 1 - 2 * (x * x + z * z), 2 * (y * z + w * x), 0.0,
            2 * (x * z + w * y), 2 * (y * z - w * x), 1 - 2 * (x * x + y * y), 0.0,
            0.0, 0.0, 0.0, 1.0]


def lm(p, q, s):
    m = qmat(q)
    for col in range(3):
        for row in range(3):
            m[col * 4 + row] *= s[col]
    m[12], m[13], m[14] = p[0], p[1], p[2]
    return m


def inv(m):
    # 通用 4x4 求逆（行主序展平存储方式与 mul 一致：列主序）
    a = m
    det = (a[0] * (a[5] * a[10] - a[6] * a[9])
           - a[4] * (a[1] * a[10] - a[2] * a[9])
           + a[8] * (a[1] * a[6] - a[2] * a[5]))
    d = 1.0 / det
    r = [0.0] * 16
    r[0] = (a[5] * a[10] - a[6] * a[9]) * d
    r[4] = -(a[4] * a[10] - a[6] * a[8]) * d
    r[8] = (a[4] * a[9] - a[5] * a[8]) * d
    r[1] = -(a[1] * a[10] - a[2] * a[9]) * d
    r[5] = (a[0] * a[10] - a[2] * a[8]) * d
    r[9] = -(a[0] * a[9] - a[1] * a[8]) * d
    r[2] = (a[1] * a[6] - a[2] * a[5]) * d
    r[6] = -(a[0] * a[6] - a[2] * a[4]) * d
    r[10] = (a[0] * a[5] - a[1] * a[4]) * d
    r[12] = -(r[0] * a[12] + r[4] * a[13] + r[8] * a[14])
    r[13] = -(r[1] * a[12] + r[5] * a[13] + r[9] * a[14])
    r[14] = -(r[2] * a[12] + r[6] * a[13] + r[10] * a[14])
    r[15] = 1.0
    return r


def xf(m, p):
    return [m[0] * p[0] + m[4] * p[1] + m[8] * p[2] + m[12],
            m[1] * p[0] + m[5] * p[1] + m[9] * p[2] + m[13],
            m[2] * p[0] + m[6] * p[1] + m[10] * p[2] + m[14]]


def ainv(m):
    # 只求 3x3 逆 + 平移，够用
    a, b, c = m[0], m[4], m[8]
    d, e, f = m[1], m[5], m[9]
    g, h, i = m[2], m[6], m[10]
    det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
    n = 1.0 / det
    r = [0.0] * 16
    r[0] = (e * i - f * h) * n
    r[4] = -(b * i - c * h) * n
    r[8] = (b * f - c * e) * n
    r[1] = -(d * i - f * g) * n
    r[5] = (a * i - c * g) * n
    r[9] = -(a * f - c * d) * n
    r[2] = (d * h - e * g) * n
    r[6] = -(a * h - b * g) * n
    r[10] = (a * e - b * d) * n
    r[12] = -(r[0] * m[12] + r[4] * m[13] + r[8] * m[14])
    r[13] = -(r[1] * m[12] + r[5] * m[13] + r[9] * m[14])
    r[14] = -(r[2] * m[12] + r[6] * m[13] + r[10] * m[14])
    r[15] = 1.0
    return r


d = json.load(open(FP, encoding="utf-8"))
bones = d["skeleton"]["bones"]
N = len(bones)
n2i = {b["name"]: i for i, b in enumerate(bones)}
pidx = [n2i.get(b["parent"], -1) if b.get("parent") else -1 for b in bones]

world = [ident() for _ in range(N)]
for i in range(N):
    b = bones[i]
    m = lm(b["local"], b["rotation"], b["scale"])
    world[i] = mul(world[pidx[i]], m) if pidx[i] >= 0 else m

hand = [m for m in d["meshes"] if m.get("skinned")][0]
bidx, bw, P = hand["boneIdx"], hand["boneW"], hand["pos"]


def bbox(pts):
    return [(min(p[i] for p in pts), max(p[i] for p in pts)) for i in range(3)]


def skin_pts(bindmode):
    if bindmode == "file":
        skin = [mul(world[i], [float(v) for v in bones[i]["bindPose"]]) for i in range(N)]
    elif bindmode == "prefab_inv":
        skin = [mul(world[i], ainv(world[i])) for i in range(N)]
    elif bindmode == "identity":
        skin = [ident() for _ in range(N)]
    pts = []
    for v, p in enumerate(P):
        x = y = z = 0.0
        for k in range(4):
            w = bw[v][k]
            if w == 0.0:
                continue
            j = bidx[v][k]
            if not (0 <= j < N):
                continue
            t = xf(skin[j], p)
            x += w * t[0]
            y += w * t[1]
            z += w * t[2]
        pts.append((x, y, z))
    return pts


for mode in ("file", "prefab_inv", "identity"):
    pts = skin_pts(mode)
    bb = bbox(pts)
    print("bind=%-12s x[%.2f,%.2f] y[%.2f,%.2f] z[%.2f,%.2f]" % (
        mode, bb[0][0], bb[0][1], bb[1][0], bb[1][1], bb[2][0], bb[2][1]))

print("\n原始模型坐标 bbox:")
bb = bbox([tuple(p) for p in P])
print("  x[%.2f,%.2f] y[%.2f,%.2f] z[%.2f,%.2f]" % (
    bb[0][0], bb[0][1], bb[1][0], bb[1][1], bb[2][0], bb[2][1]))

print("\n--- 骨骼 world 平移 ---")
for nm in ("model", "PlayerMesh", "Bip01", "Bip01_Pelvis", "Bip01_R_Hand", "WeaponAnchor", "gun_root"):
    i = n2i.get(nm)
    if i is None:
        continue
    print("  %-16s worldPos=(%.3f,%.3f,%.3f)" % (nm, world[i][12], world[i][13], world[i][14]))

print("\n--- 检查 hand_man_anm.json 是否存在可用的 bind 信息 ---")
try:
    h = json.load(open(HAND_ANM, encoding="utf-8"))
    print("  groups:", len(h.get("groups", [])))
    first = h["groups"][0]["clips"][0]
    print("  clip:", first.get("name"), "curves:", len(first.get("curves", [])))
    for c in first["curves"][:3]:
        print("   ", c.get("bone"), "frames", len(c.get("frames", [])), "f0", c["frames"][0])
except Exception as e:
    print("  not available:", e)
