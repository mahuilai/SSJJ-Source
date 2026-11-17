# -*- coding: utf-8 -*-
"""只读探查 v2：sjfp 真实结构 + idle 时刻 CPU 蒙皮统计（找“尖角”= 爆点顶点）。不修改任何文件。"""
import json, math, statistics

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"


def qmat(q):
    x, y, z, w = q
    xx, yy, zz = x * x, y * y, z * z
    xy, xz, yz = x * y, x * z, y * z
    wx, wy, wz = w * x, w * y, w * z
    return [1 - 2 * (yy + zz), 2 * (xy + wz), 2 * (xz - wy), 0.0,
            2 * (xy - wz), 1 - 2 * (xx + zz), 2 * (yz + wx), 0.0,
            2 * (xz + wy), 2 * (yz - wx), 1 - 2 * (xx + yy), 0.0,
            0.0, 0.0, 0.0, 1.0]


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


def local_mat(pos, rot, scl):
    m = qmat(rot)
    for col in range(3):
        for row in range(3):
            m[col * 4 + row] *= (scl[col] if col < len(scl) else 1.0)
    m[12], m[13], m[14] = pos[0], pos[1], pos[2]
    return m


d = json.load(open(FP, encoding="utf-8"))
print("format=%s space=%s" % (d.get("format"), d.get("space")))
sk = d["skeleton"]
if isinstance(sk, dict):
    print("skeleton keys:", list(sk.keys()))
    bones = sk.get("bones") or []
    order = sk.get("order")
else:
    bones, order = sk, None
print("bones=%d order=%s" % (len(bones), "yes" if order else "no"))
if bones:
    print("bone[0] keys:", list(bones[0].keys()))
    print("bone[0]:", {k: v for k, v in bones[0].items() if k != "bindPose"})
    print("bindPose[0]:", [round(v, 5) for v in bones[0].get("bindPose", [])])

meshes = d["meshes"]
for m in meshes:
    print("\nmesh", m.get("name"), "keys:", list(m.keys()))
    print("  skinned=%s rigidBone=%s" % (m.get("skinned"), m.get("rigidBone")))
    p = m.get("pos") or []
    if p:
        for ax, nm in enumerate("xyz"):
            vals = p[ax::3]
            sv = sorted(vals)
            def pc(q):
                return sv[min(len(sv) - 1, int(q * (len(sv) - 1)))]
            print("  %s  min=%.3f p01=%.3f p50=%.3f p99=%.3f max=%.3f" % (nm, sv[0], pc(.01), pc(.5), pc(.99), sv[-1]))
        print("  verts=%d idx=%d" % (len(p) // 3, len(m.get("idx") or [])))

# ---- idle 蒙皮统计 ----
a = json.load(open(ANM, encoding="utf-8"))
clips = a["clips"]
print("\nclips:", len(clips))
idle = clips.get("idle") or clips.get("TORSO_STAND_blend0")
print("idle clip:", idle.get("length") if idle else None, "tracks:", len(idle.get("bones", {})) if idle else 0)
name2i = {b.get("name"): i for i, b in enumerate(bones)}
pidx = []
for b in bones:
    pn = b.get("parent")
    pidx.append(name2i.get(pn, -1) if pn else -1)

def world_at(clip, t):
    world = [ident() for _ in bones]
    seq = order if order else list(range(len(bones)))
    for i in seq:
        b = bones[i]
        pos = list(b.get("local") or b.get("position") or [0, 0, 0])
        rot = list(b.get("rotation") or [0, 0, 0, 1])
        scl = list(b.get("scale") or [1, 1, 1])
        ks = clip["bones"].get(b.get("name")) if clip else None
        if ks:
            c = min(ks, key=lambda k: abs(k[0] - t))
            pos = [c[1], c[2], c[3]]
            rot = [c[4], c[5], c[6], c[7]]
        world[i] = mul(world[pidx[i]], local_mat(pos, rot, scl)) if pidx[i] >= 0 else local_mat(pos, rot, scl)
    return world


world = world_at(idle, 0.0)
skin = [mul(world[i], [float(v) for v in bones[i].get("bindPose")] if bones[i].get("bindPose") else ident()) for i in range(len(bones))]

for m in meshes:
    if not m.get("skinned"):
        continue
    bidx = m.get("boneIdx") or m.get("bidx")
    bw = m.get("boneW") or m.get("bw")
    p = m["pos"]
    n = len(p) // 3
    bkey = list(m.keys())
    print("\nmesh %s weight keys: boneIdx=%s boneW=%s" % (m.get("name"), "boneIdx" in bkey, "boneW" in bkey))
    mass = {}
    bad_w = 0
    pts = []
    for v in range(n):
        x = y = z = 0.0
        s = 0.0
        for k in range(4):
            w = bw[v * 4 + k]
            if w == 0.0:
                continue
            s += w
            bi = bidx[v * 4 + k]
            if bi < 0 or bi >= len(skin):
                continue
            mass[bi] = mass.get(bi, 0.0) + w
            tp = xf(skin[bi], [p[v * 3], p[v * 3 + 1], p[v * 3 + 2]])
            x += w * tp[0]; y += w * tp[1]; z += w * tp[2]
        if abs(s - 1.0) > 0.05:
            bad_w += 1
        pts.append((x, y, z, s))
    print("  verts=%d weight-sum!=1: %d" % (n, bad_w))
    for ax, nm in enumerate("xyz"):
        vals = sorted(q[ax] for q in pts)
        def pc(q):
            return vals[min(len(vals) - 1, int(q * (len(vals) - 1)))]
        print("  %s p00=%.1f p01=%.1f p50=%.1f p99=%.1f p100=%.1f" % (nm, vals[0], pc(.01), pc(.5), pc(.99), vals[-1]))
    cx = statistics.median(q[0] for q in pts)
    cy = statistics.median(q[1] for q in pts)
    cz = statistics.median(q[2] for q in pts)
    out = [i for i, q in enumerate(pts) if math.dist(q[:3], (cx, cy, cz)) > 400]
    print("  median=(%.1f,%.1f,%.1f) verts>400 from median: %d" % (cx, cy, cz, len(out)))
    if out:
        top = {}
        for v in out[:4000]:
            best, bi = -1, -1
            for k in range(4):
                if bw[v * 4 + k] > best:
                    best, bi = bw[v * 4 + k], bidx[v * 4 + k]
            top[bi] = top.get(bi, 0) + 1
        for bi, c in sorted(top.items(), key=lambda kv: -kv[1])[:6]:
            print("    outlier bone %s idx=%d verts=%d" % (bones[bi].get("name"), bi, c))
        for v in out[:4]:
            print("    sample v=%d p=(%.1f,%.1f,%.1f) wsum=%.3f" % (v, pts[v][0], pts[v][1], pts[v][2], pts[v][3]))
    tot = sum(mass.values()) or 1.0
    print("  top bones by weight:")
    for bi, wsum in sorted(mass.items(), key=lambda kv: -kv[1])[:8]:
        print("    %-24s %.1f%%" % (bones[bi].get("name"), 100.0 * wsum / tot))

for m in meshes:
    if m.get("skinned"):
        continue
    rb = m.get("rigidBone")
    bi = name2i.get(rb)
    print("\nmesh %s rigidBone=%s idx=%s" % (m.get("name"), rb, bi))
    if bi is not None:
        print("  rigid skin matrix:", [round(v, 4) for v in skin[bi]])
        print("  rigid local:", {k: v for k, v in bones[bi].items() if k != "bindPose"})
    p = m["pos"]
    n = len(p) // 3
    pts = [xf(skin[bi], [p[v * 3], p[v * 3 + 1], p[v * 3 + 2]]) for v in range(n)] if bi is not None else []
    if pts:
        for ax, nm in enumerate("xyz"):
            vals = sorted(q[ax] for q in pts)
            print("  skinned %s %.4f .. %.4f" % (nm, vals[0], vals[-1]))
