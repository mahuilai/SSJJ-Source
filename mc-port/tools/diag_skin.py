# -*- coding: utf-8 -*-
"""只读：验证蒙皮矩阵复合方式。静止姿态下 skin 应≈单位阵，包围盒应≈原始网格包围盒。
不改任何工程文件。"""
import json

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"

d = json.load(open(FP, encoding="utf-8"))
bones = d["skeleton"]["bones"]
meshes = d["meshes"]


def qmat(q):
    x, y, z, w = q
    xx, yy, zz = x * x, y * y, z * z
    xy, xz, yz = x * y, x * z, y * z
    wx, wy, wz = w * x, w * y, w * z
    return [
        [1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy), 0.0],
        [2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx), 0.0],
        [2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy), 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


def mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def col_major(arr):
    return [[arr[c * 4 + r] for c in range(4)] for r in range(4)]


def transpose(m):
    return [[m[j][i] for j in range(4)] for i in range(4)]


def ident():
    return [[1.0 if i == j else 0.0 for j in range(4)] for i in range(4)]


def trs(loc, rot, scl):
    m = qmat(rot)
    for r in range(3):
        for c in range(3):
            m[r][c] *= scl[c]
    for r in range(3):
        m[r][3] = loc[r]
    return m


idx = {b["name"]: i for i, b in enumerate(bones)}
order = []
pend = set(range(len(bones)))
while pend:
    ready = [i for i in pend if bones[i].get("parent") not in idx or idx[bones[i]["parent"]] not in pend]
    if not ready:
        raise SystemExit("cycle in skeleton")
    for i in ready:
        order.append(i)
        pend.discard(i)

world = [ident() for _ in bones]
for i in order:
    b = bones[i]
    local = trs(b["local"], b["rotation"], b["scale"])
    p = b.get("parent")
    world[i] = mul(world[idx[p]], local) if p in idx else local

bind = [col_major(b["bindPose"]) for b in bones]

print("--- rest-pose skin deviation from identity ---")
for variant, fn in (("world*bind", lambda i: mul(world[i], bind[i])),
                    ("world*bindT", lambda i: mul(world[i], transpose(bind[i]))),
                    ("bindT*world", lambda i: mul(transpose(bind[i]), world[i])),
                    ("bind*world", lambda i: mul(bind[i], world[i]))):
    mx = 0.0
    worst = None
    for i, b in enumerate(bones):
        if b["name"] not in idx:
            continue
        m = fn(i)
        dev = max(abs(m[r][c] - (1.0 if r == c else 0.0)) for r in range(4) for c in range(4))
        if dev > mx:
            mx, worst = dev, b["name"]
    print("   %-12s max|M-I| = %12.4f   worst=%s" % (variant, mx, worst))

hand = None
gun = None
for m in meshes:
    if m["name"] == "hand":
        hand = m
    elif m["name"] == "gun":
        gun = m


def bbox(pts):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    zs = [p[2] for p in pts]
    return (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs))


print()
print("raw hand bbox  x[%+.2f,%+.2f] y[%+.2f,%+.2f] z[%+.2f,%+.2f]" % bbox(hand["pos"]))
print("raw gun  bbox  x[%+.2f,%+.2f] y[%+.2f,%+.2f] z[%+.2f,%+.2f]" % bbox(gun["pos"]))


for variant, fn in (("world*bind", lambda i: mul(world[i], bind[i])),
                    ("world*bindT", lambda i: mul(world[i], transpose(bind[i]))),
                    ("bindT*world", lambda i: mul(transpose(bind[i]), world[i])),
                    ("bind*world", lambda i: mul(bind[i], world[i]))):
    skin = [fn(i) for i in range(len(bones))]
    out = []
    for v in range(len(hand["pos"])):
        px, py, pz = hand["pos"][v]
        ax = ay = az = 0.0
        for k in range(4):
            w = hand["boneW"][v][k]
            if w == 0.0:
                continue
            sm = skin[hand["boneIdx"][v][k]]
            ax += w * (sm[0][0] * px + sm[0][1] * py + sm[0][2] * pz + sm[0][3])
            ay += w * (sm[1][0] * px + sm[1][1] * py + sm[1][2] * pz + sm[1][3])
            az += w * (sm[2][0] * px + sm[2][1] * py + sm[2][2] * pz + sm[2][3])
        out.append((ax, ay, az))
    print()
    print("skinned hand bbox via %-12s x[%+.2f,%+.2f] y[%+.2f,%+.2f] z[%+.2f,%+.2f]" % ((variant,) + bbox(out)))

print()
print("skeleton root chain of sample bones:")
for nm in ("model", "Bip01", "Bip01_Pelvis", "Bip01_Spine", "Bip01_R_Hand"):
    if nm in idx:
        b = bones[idx[nm]]
        print("   %-14s parent=%-16s local=%s" % (nm, b.get("parent"), b["local"]))
