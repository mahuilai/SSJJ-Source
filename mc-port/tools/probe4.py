# -*- coding: utf-8 -*-
"""只读探查 v4：
(A) 用真 jar 源码/字节码确认 1.21.1 VertexConsumer 的 overlay/light 签名；
(B) 复现 FpRender+FpConfig 全链，输出相机空间真实包围盒、朝向、随时间变化。
不修改任何工程文件。
"""
import json
import math
import os
import re
import zipfile

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"
SRC_ROOTS = [os.path.expanduser("~/.gradle/caches/fabric-loom"),
             r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\.gradle"]
CFG_PATHS = [
    r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\clusters\1.21.1 Fabric\config\ssjjfp.json",
    r"C:\Users\Mahuilai\AppData\Roaming\.minecraft\config\ssjjfp.json",
]

print("===== (A) VertexConsumer API =====")
found = False
for root in SRC_ROOTS:
    if not os.path.isdir(root):
        continue
    for dp, _dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith(".jar"):
                continue
            if "sources" not in f and "named" not in f:
                continue
            p = os.path.join(dp, f)
            try:
                z = zipfile.ZipFile(p)
            except Exception:
                continue
            names = z.namelist()
            vc = "net/minecraft/client/render/VertexConsumer.java"
            if vc in names:
                print("SOURCES JAR:", p)
                s = z.read(vc).decode("utf-8", "replace")
                for i, ln in enumerate(s.splitlines(), 1):
                    if re.search(r"\b(overlay|light|color|texture|normal)\s*\(", ln):
                        print("  %4d %s" % (i, ln.strip()))
                found = True
                break
        if found:
            break
    if found:
        break
if not found:
    print("sources jar not found; scanning class bytes instead")
    for root in SRC_ROOTS:
        if not os.path.isdir(root):
            continue
        for dp, _dn, fn in os.walk(root):
            for f in fn:
                if not f.endswith(".jar") or "named" not in f:
                    continue
                p = os.path.join(dp, f)
                try:
                    z = zipfile.ZipFile(p)
                except Exception:
                    continue
                cn = "net/minecraft/client/render/VertexConsumer.class"
                if cn not in z.namelist():
                    continue
                b = z.read(cn)
                print("CLASS JAR:", p)
                for m in re.finditer(rb"[\x20-\x7e]{2,80}", b):
                    t = m.group().decode("ascii")
                    if "overlay" in t or "light" in t or t.startswith("(II)"):
                        print("   ", t)
                found = True
                break
            if found:
                break
        if found:
            break

print("\n===== config file =====")
for p in CFG_PATHS:
    if os.path.exists(p):
        print("FOUND", p)
        print(open(p, encoding="utf-8").read())
        break
else:
    print("no ssjjfp.json found in candidates")

print("\n===== (B) numeric replay =====")

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


def local_mat(p, q, s):
    m = qmat(q)
    for col in range(3):
        for row in range(3):
            m[col * 4 + row] *= s[col]
    m[12], m[13], m[14] = p[0], p[1], p[2]
    return m


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
order = [i for i in range(N)]

a = json.load(open(ANM, encoding="utf-8"))
clips = a["clips"]

def bbox(pts):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    zs = [p[2] for p in pts]
    return (min(xs), max(xs)), (min(ys), max(ys)), (min(zs), max(zs))

def fmt3(name, bb):
    return "%s x[%.2f,%.2f] y[%.2f,%.2f] z[%.2f,%.2f]" % (
        name, bb[0][0], bb[0][1], bb[1][0], bb[1][1], bb[2][0], bb[2][1])

print("raw mesh bbox (file units):")
for m in d["meshes"]:
    print("  " + fmt3(m["name"], bbox(m["pos"])))


def skinned(clip, t):
    world = [ident() for _ in range(N)]
    for i in order:
        b = bones[i]
        pos = list(b["local"])
        rot = list(b["rotation"])
        s = sample(clip, b["name"], t)
        if s:
            pos, rot = s
        lm = local_mat(pos, rot, b["scale"])
        world[i] = mul(world[pidx[i]], lm) if pidx[i] >= 0 else lm
    skin = [mul(world[i], bones[i]["bindPose"]) for i in range(N)]
    out = {}
    for m in d["meshes"]:
        if m.get("skinned"):
            pts = []
            for v, p in enumerate(m["pos"]):
                x = y = z = 0.0
                for k in range(4):
                    w = m["boneW"][v][k]
                    if w == 0.0:
                        continue
                    bi = m["boneIdx"][v][k]
                    if not (0 <= bi < N):
                        continue
                    tp = xf(skin[bi], p)
                    x += w * tp[0]
                    y += w * tp[1]
                    z += w * tp[2]
                pts.append((x, y, z))
        else:
            bi = n2i.get(m.get("rigidBone"), -1)
            pts = [xf(skin[bi], p) for p in m["pos"]] if bi >= 0 else [tuple(p) for p in m["pos"]]
        out[m["name"]] = pts
    return out, world, skin


SCALE = 0.01 * 0.2
HAND_REL = (12.7540, 22.46553, 13.93207)
GUN_REL = (22.46553, -12.7540, -13.93207)

def to_mc(pts, gun, offz, offx=0.0, offy=0.0):
    s = SCALE
    tx, ty, tz = (GUN_REL if gun else HAND_REL)
    tx *= SCALE
    ty *= SCALE
    tz *= SCALE
    out = []
    for p in pts:
        if gun:
            out.append((s * p[0] + tx + offx, s * p[2] + ty + offy, s * p[1] + tz + offz))
        else:
            out.append((s * p[2] + tx + offx, s * p[1] + ty + offy, s * p[0] + tz + offz))
    return out


for probe, times in (("idle", [0.0, 0.016]), ("walk", [0.0, 0.2, 0.4, 0.6]),
                     ("fire", [0.0, 0.1, 0.2, 0.29]), ("bolt", [0.0, 0.3, 0.6, 0.86]),
                     ("draw", [0.0, 0.2, 0.46])):
    clip = clips.get(probe)
    if not clip:
        continue
    print("\n--- %s (len=%.3f) ---" % (probe, clip["length"]))
    for t in times:
        pts, world, skin = skinned(clip, t)
        gh = pts.get("hand", [])
        gg = pts.get("gun", [])
        line = "  t=%.3f rig: %s | %s" % (t, fmt3("hand", bbox(gh)) if gh else "-",
                                          fmt3("gun", bbox(gg)) if gg else "-")
        print(line)
        for offz in (0.0,):
            mh = to_mc(gh, False, offz)
            mg = to_mc(gg, True, offz)
            if mg:
                cx = sum(p[0] for p in mg) / len(mg)
                cy = sum(p[1] for p in mg) / len(mg)
                cz = sum(p[2] for p in mg) / len(mg)
                print("     MC hand %s" % (fmt3("", bbox(mh)),))
                print("     MC gun  %s  centroid=(%.3f,%.3f,%.3f) front=%.3f" % (
                    fmt3("", bbox(mg)), cx, cy, cz, -cz))
        gi = n2i.get("gun_root", -1)
        if gi >= 0:
            wp = [world[gi][12], world[gi][13], world[gi][14]]
            print("     gun_root world pos=%s" % [round(v, 3) for v in wp])
