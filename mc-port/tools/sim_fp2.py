# -*- coding: utf-8 -*-
"""只读：定位手模蒙皮输出的真实尺度/位置，并搜索能把手/枪放进相机前方的基矩阵。
不修改工程文件。"""
import json, math

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"


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


def qmat(q):
    x, y, z, w = q
    return [1 - 2 * (y * y + z * z), 2 * (x * y + w * z), 2 * (x * z - w * y), 0,
            2 * (x * y - w * z), 1 - 2 * (x * x + z * z), 2 * (y * z + w * x), 0,
            2 * (x * z + w * y), 2 * (y * z - w * x), 1 - 2 * (x * x + y * y), 0,
            0, 0, 0, 1]


def trs(p, q, s):
    m = qmat(q)
    for i in range(3):
        m[0 + i] *= s[0]
        m[4 + i] *= s[1]
        m[8 + i] *= s[2]
    m[12], m[13], m[14] = p
    return m


fp = json.load(open(FP, encoding="utf-8"))
anm = json.load(open(ANM, encoding="utf-8"))
bones = fp["skeleton"]["bones"]
idx = {b["name"]: i for i, b in enumerate(bones)}

depth_of = {}
for i, b in enumerate(bones):
    parent = b["parent"]
    depth_of[b["name"]] = 0 if parent is None else depth_of.get(parent, 0) + 1
order = sorted(range(len(bones)), key=lambda i: depth_of.get(bones[i]["name"], 0))

clip = anm["clips"]["idle"]
world = [None] * len(bones)
for i in order:
    b = bones[i]
    local = trs(b["local"], b["rotation"], b["scale"])
    p = idx.get(b["parent"]) if b["parent"] else None
    world[i] = local if p is None else mul(world[p], local)
skin = [mul(world[i], bones[i]["bindPose"]) for i in range(len(bones))]

print("=== 每根骨骼 skin 矩阵的平移与列长（列长=缩放）===")
for b in bones:
    i = idx[b["name"]]
    m = skin[i]
    cols = [math.sqrt(m[k * 4] ** 2 + m[k * 4 + 1] ** 2 + m[k * 4 + 2] ** 2) for k in range(3)]
    if b["name"] in ("model", "PlayerMesh", "Bip01", "Bip01_Pelvis", "Bip01_Spine",
                     "Bip01_R_Hand", "WeaponAnchor", "Bip01_R_UpperArm", "gun_root"):
        print("  %-16s trans=(%9.2f,%9.2f,%9.2f) colLen=(%.4f,%.4f,%.4f)" % (
            b["name"], m[12], m[13], m[14], cols[0], cols[1], cols[2]))

mesh = [m for m in fp["meshes"] if m["name"] == "hand"][0]
skinned = []
for v in range(len(mesh["pos"])):
    p = mesh["pos"][v]
    acc = [0.0, 0.0, 0.0]
    tot = 0.0
    for k in range(4):
        w = mesh["boneW"][v][k]
        if not w:
            continue
        tot += w
        t = xf(skin[mesh["boneIdx"][v][k]], p)
        for j in range(3):
            acc[j] += w * t[j]
    skinned.append((acc, tot))

for j, ax in enumerate("xyz"):
    vals = [a[0][j] for a in skinned]
    print("skinned hand (PlayerSkin 空间) %s %.2f .. %.2f" % (ax, min(vals), max(vals)))
tots = sorted({round(a[1], 4) for a in skinned})
print("权重和取值集合:", tots[:6], "..." if len(tots) > 6 else "")

c = [sum(a[0][j] for a in skinned) / len(skinned) for j in range(3)]
print("skinned hand 质心: (%.2f, %.2f, %.2f)" % tuple(c))

m = skin[idx["Bip01_R_Hand"]]
print("R_Hand 世界位置: (%.2f, %.2f, %.2f)" % (m[12], m[13], m[14]))
m = skin[idx["WeaponAnchor"]]
print("WeaponAnchor 世界位置: (%.2f, %.2f, %.2f)" % (m[12], m[13], m[14]))
print("WeaponAnchor 基向量: X=(%.3f,%.3f,%.3f) Y=(%.3f,%.3f,%.3f) Z=(%.3f,%.3f,%.3f)" % (
    m[0], m[1], m[2], m[4], m[5], m[6], m[8], m[9], m[10]))

mesh = [mm for mm in fp["meshes"] if mm["name"] == "gun"][0]
print("\n枪（已导出 SSJJ view 轴）bbox: x %.2f..%.2f y %.2f..%.2f z %.2f..%.2f" % (
    min(p[0] for p in mesh["pos"]), max(p[0] for p in mesh["pos"]),
    min(p[1] for p in mesh["pos"]), max(p[1] for p in mesh["pos"]),
    min(p[2] for p in mesh["pos"]), max(p[2] for p in mesh["pos"])))
