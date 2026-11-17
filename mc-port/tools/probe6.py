# -*- coding: utf-8 -*-
"""只读探查 v6：
(A) 对比四种 bindPose 取法下的手模蒙皮 bbox（定位“尖角/发红”）；
(B) 判别手模左右的真实轴向（找双峰间隙）；
(C) 枚举源轴 -> MC 相机轴 的映射候选并打分。
不修改任何工程文件。
"""
import json, math, itertools

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
    A = [[m[c * 4 + r] for c in range(4)] + [1.0 if c == r else 0.0 for c in range(4)]
         for r in range(4)]
    for i in range(4):
        p = max(range(i, 4), key=lambda r: abs(A[r][i]))
        if abs(A[p][i]) < 1e-12:
            return None
        A[i], A[p] = A[p], A[i]
        d = A[i][i]
        A[i] = [v / d for v in A[i]]
        for r in range(4):
            if r != i and A[r][i] != 0.0:
                f = A[r][i]
                A[r] = [vr - f * vi for vr, vi in zip(A[r], A[i])]
    out = [0.0] * 16
    for r in range(4):
        for c in range(4):
            out[c * 4 + r] = A[r][4 + c]
    return out


def xf(m, p):
    return [m[0] * p[0] + m[4] * p[1] + m[8] * p[2] + m[12],
            m[1] * p[0] + m[5] * p[1] + m[9] * p[2] + m[13],
            m[2] * p[0] + m[6] * p[1] + m[10] * p[2] + m[14]]


def slerp(a, b, f):
    ax, ay, az, aw = a[4:8]
    bx, by, bz, bw = b[4:8]
    dot = ax * bx + ay * by + az * bz + aw * bw
    if dot < 0:
        bx, by, bz, bw, dot = -bx, -by, -bz, -bw, -dot
    if dot > 0.9995:
        o = [ax + (bx - ax) * f, ay + (by - ay) * f, az + (bz - az) * f, aw + (bw - aw) * f]
    else:
        th0 = math.acos(max(-1.0, min(1.0, dot)))
        th = th0 * f
        s0 = math.sin(th0 - th) / math.sin(th0)
        s1 = math.sin(th) / math.sin(th0)
        o = [ax * s0 + bx * s1, ay * s0 + by * s1, az * s0 + bz * s1, aw * s0 + bw * s1]
    n = math.sqrt(sum(v * v for v in o)) or 1.0
    return [v / n for v in o]


def sample(clip, bone, t):
    ks = clip["bones"].get(bone) if clip else None
    if not ks:
        return None
    if clip["loop"] and clip["length"] > 1e-4:
        t = t % clip["length"]
    elif t > ks[-1][0]:
        t = ks[-1][0]
    if t <= ks[0][0]:
        return list(ks[0][1:4]), list(ks[0][4:8])
    i = 0
    while i + 1 < len(ks) and ks[i + 1][0] <= t:
        i += 1
    if i + 1 >= len(ks):
        return list(ks[-1][1:4]), list(ks[-1][4:8])
    a, b = ks[i], ks[i + 1]
    span = max(1e-5, b[0] - a[0])
    f = min(1.0, max(0.0, (t - a[0]) / span))
    pos = [a[1 + k] + (b[1 + k] - a[1 + k]) * f for k in range(3)]
    return pos, slerp(a, b, f)


d = json.load(open(FP, encoding="utf-8"))
bones = d["skeleton"]["bones"]
N = len(bones)
n2i = {b["name"]: i for i, b in enumerate(bones)}
pidx = [n2i.get(b["parent"], -1) if b.get("parent") else -1 for b in bones]

a = json.load(open(ANM, encoding="utf-8"))
idle = a["clips"]["idle"]


def world_of(clip=None, t=0.0):
    world = [ident() for _ in range(N)]
    for i in range(N):
        b = bones[i]
        pos = list(b["local"])
        rot = list(b["rotation"])
        s = sample(clip, b["name"], t) if clip else None
        if s:
            pos, rot = s
        m = lm(pos, rot, b["scale"])
        world[i] = mul(world[pidx[i]], m) if pidx[i] >= 0 else m
    return world


w_rest = world_of(None)
w_idle = world_of(idle, 0.0)


def bbox(pts):
    return [(min(p[i] for p in pts), max(p[i] for p in pts)) for i in range(3)]


def fmt(bb):
    return "x[%.2f,%.2f] y[%.2f,%.2f] z[%.2f,%.2f]  span=(%.1f,%.1f,%.1f)" % (
        bb[0][0], bb[0][1], bb[1][0], bb[1][1], bb[2][0], bb[2][1],
        bb[0][1] - bb[0][0], bb[1][1] - bb[1][0], bb[2][1] - bb[2][0])


hand = [m for m in d["meshes"] if m.get("skinned")][0]
P = hand["pos"]
bidx, bw = hand["boneIdx"], hand["boneW"]


def skin_pts(bind):
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
            t = xf(bind[j], p)
            x += w * t[0]
            y += w * t[1]
            z += w * t[2]
        pts.append((x, y, z))
    return pts


print("===== (A) bindPose 取法对比 =====")
print("raw mesh          ", fmt(bbox([tuple(p) for p in P])))
for name, bind in (
        ("file bindPose", [mul(w_idle[i], [float(v) for v in bones[i]["bindPose"]]) for i in range(N)]),
        ("inv(rest)*idle", [mul(w_idle[i], inv(w_rest[i])) for i in range(N)]),
        ("inv(idle0)*idle", [mul(w_idle[i], inv(w_idle[i])) for i in range(N)]),
        ("identity", [ident() for _ in range(N)])):
    print("%-18s" % name, fmt(bbox(skin_pts(bind))))

print("\n===== (B) 手模轴向双峰分析（找左右轴）=====")
for ax, nm in enumerate("xyz"):
    vals = sorted(p[ax] for p in P)
    gap, gi = -1.0, 0
    for i in range(1, len(vals)):
        g = vals[i] - vals[i - 1]
        if g > gap:
            gap, gi = g, i
    lo = vals[:gi] if gi else []
    hi = vals[gi:]
    print("  %s  min=%.2f max=%.2f span=%.2f  maxGap=%.2f at %.2f|%.2f  clusterSizes=%d/%d" % (
        nm, vals[0], vals[-1], vals[-1] - vals[0], gap,
        vals[gi - 1] if gi else vals[0], vals[gi], len(lo), len(hi)))

print("\n===== (C) 轴向映射候选打分 =====")
bb = bbox([tuple(p) for p in P])
spans = [bb[i][1] - bb[i][0] for i in range(3)]
src_order = sorted(range(3), key=lambda i: -spans[i])
print("源 span 排序(大到小):", ["xyz"[i] for i in src_order], [round(spans[i], 2) for i in src_order])

pts = skin_pts([mul(w_idle[i], inv(w_idle[i])) for i in range(N)])  # = raw, idle 姿态
for perm in itertools.permutations(range(3)):
    for signs in itertools.product((1, -1), repeat=3):
        mc = [(signs[0] * q[perm[0]], signs[1] * q[perm[1]], signs[2] * q[perm[2]]) for q in pts]
        b2 = bbox(mc)
        sp = [b2[i][1] - b2[i][0] for i in range(3)]
        # 打分：左-右(x) 最窄；前-后(z) 最长（视模型向前延伸）；上-下(y) 居中
        score = abs(sp[0] - min(sp)) + abs(sp[2] - max(sp))
        if sp[1] > max(sp[0], sp[2]) or sp[1] < min(sp[0], sp[2]):
            score += 50
        if score < 30:
            print("  perm=%s signs=%s -> %s  score=%.1f" % (perm, signs, fmt(b2), score))
