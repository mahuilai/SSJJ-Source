# -*- coding: utf-8 -*-
"""fp.glb 本地验证器：标准 glTF 蒙皮 + idle 动画采样 + 贴图，软件光栅化。

目的：不启动游戏就能看到「GemRender 将会渲染的样子」。
GemRender 用标准 glTF skinning（GPU），这里用纯 python 复刻同一套数学：
    skinMatrix[j] = world(joints[j]) × inverseBindMatrices[j]
    v' = Σ w_k × skinMatrix[joint_k] × v
inverseBindMatrices 里已烘入 bindComp（导出脚本做的），所以这里不再补偿。

用法：python preview_fp_glb.py [--time 0] [--yaw 0] [--pitch 0] [--dist 2.2] [--out x.png]
"""
import json
import math
import os
import struct
import sys

from PIL import Image

W, H = 720, 405
ROOT = r"D:\逆向\SSJJ双塔惊魂\ssjj-port"
GLB = os.path.join(ROOT, r"src\main\resources\assets\ssjjport\fp\fp.glb")


def parse_glb(path):
    blob = open(path, "rb").read()
    magic, ver, length = struct.unpack_from("<4sII", blob, 0)
    assert magic == b"glTF" and ver == 2, "not glb"
    off = 12
    js = None
    binb = b""
    while off < length:
        clen, ctype = struct.unpack_from("<II", blob, off)
        chunk = blob[off + 8: off + 8 + clen]
        if ctype == 0x4E4F534A:
            js = json.loads(chunk.decode("utf-8"))
        elif ctype == 0x004E4942:
            binb = chunk
        off += 8 + clen
        if off % 4:
            off += 4 - off % 4
    return js, binb


class G:
    pass


def load():
    g, binb = parse_glb(GLB)
    G.g = g
    G.bin = binb
    acc, views = g["accessors"], g["bufferViews"]

    def read(ai):
        a = acc[ai]
        v = views[a["bufferView"]]
        off = v.get("byteOffset", 0) + a.get("byteOffset", 0)
        n = a["count"]
        comps = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}[a["type"]]
        fmt = {5126: "f", 5123: "H", 5125: "I", 5121: "B"}[a["componentType"]]
        return list(struct.unpack_from("<" + fmt * (n * comps), binb, off))

    G.read = read
    G.acc = acc
    # images -> PIL
    G.images = []
    import io as _io
    for im in g.get("images", []):
        bv = im["bufferView"]
        data = bytes(binb[views[bv]["byteOffset"]: views[bv]["byteOffset"] + views[bv]["byteLength"]])
        G.images.append(Image.open(_io.BytesIO(data)).convert("RGB"))


def node_world(nodes, t_override):
    """标准 glTF：局部 TRS → 世界（含根 0.01 缩放，因为根节点 scale 已写进 glb）。"""
    n = len(nodes)
    parent = [-1] * n
    for i, nd in enumerate(nodes):
        for c in nd.get("children", []):
            parent[c] = i
    order = sorted(range(n), key=lambda i: _depth(i, parent))
    world = [None] * n
    for i in order:
        nd = nodes[i]
        t = t_override.get(i, {}).get("t", nd.get("translation", [0, 0, 0]))
        r = t_override.get(i, {}).get("r", nd.get("rotation", [0, 0, 0, 1]))
        s = nd.get("scale", [1, 1, 1])
        m = mul(quat_mat(r), diag(s))
        m = mat_translate(m, t)
        p = parent[i]
        world[i] = m if p < 0 else mul(world[p], m)
    return world, parent


def _depth(i, parent):
    d = 0
    while parent[i] >= 0:
        i = parent[i]
        d += 1
        if d > 500:
            raise RuntimeError("环")
    return d


def quat_mat(q):
    x, y, z, w = q
    nn = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / nn, y / nn, z / nn, w / nn
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), 0],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), 0],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), 0],
            [0, 0, 0, 1]]


def diag(s):
    return [[s[0], 0, 0, 0], [0, s[1], 0, 0], [0, 0, s[2], 0], [0, 0, 0, 1]]


def mat_translate(m, t):
    out = [r[:] for r in m]
    out[0][3] += t[0]
    out[1][3] += t[1]
    out[2][3] += t[2]
    return out


def mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def apply(m, p):
    x, y, z = p[0], p[1], p[2]
    return (m[0][0] * x + m[0][1] * y + m[0][2] * z + m[0][3],
            m[1][0] * x + m[1][1] * y + m[1][2] * z + m[1][3],
            m[2][0] * x + m[2][1] * y + m[2][2] * z + m[2][3])


def anim_override(g, binb, name, t=0.0):
    """采样 glTF animation 到「节点覆盖表」。t=0 即 idle 首帧。"""
    nodes = g["nodes"]
    for a in g.get("animations", []):
        if a.get("name") != name:
            continue
        ov = {}
        for ch in a["channels"]:
            sm = a["samplers"][ch["sampler"]]
            node = ch["target"]["node"]
            path = ch["target"]["path"]
            times = G.read(sm["input"])
            vals = G.read(sm["output"])
            comps = {"translation": 3, "rotation": 4}[path]
            # t=0 取最近帧
            i = 0
            for k, tt in enumerate(times):
                if tt <= t:
                    i = k
            v = vals[i * comps: i * comps + comps]
            d = ov.setdefault(node, {})
            d["t" if path == "translation" else "r"] = v
        return ov
    return {}


def render(time_s, yaw_deg, pitch_deg, dist, out):
    g, binb = parse_glb(GLB)
    G.g, G.bin = g, binb
    acc, views = g["accessors"], g["bufferViews"]

    def read(ai):
        a = acc[ai]
        v = views[a["bufferView"]]
        off = v.get("byteOffset", 0) + a.get("byteOffset", 0)
        n = a["count"]
        comps = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}[a["type"]]
        fmt = {5126: "f", 5123: "H", 5125: "I", 5121: "B"}[a["componentType"]]
        return list(struct.unpack_from("<" + fmt * (n * comps), binb, off))

    # idle 动画覆盖
    ov = {}
    if os.environ.get("FP_ANIM"):
      for a in g.get("animations", []):
        if a.get("name") != "idle":
            continue
        for ch in a["channels"]:
            sm = a["samplers"][ch["sampler"]]
            node = ch["target"]["node"]
            path = ch["target"]["path"]
            times = read(sm["input"])
            vals = read(sm["output"])
            comps = {"translation": 3, "rotation": 4}[path]
            i = 0
            for k, tt in enumerate(times):
                if tt <= time_s:
                    i = k
            v = vals[i * comps: i * comps + comps]
            ov.setdefault(node, {})["t" if path == "translation" else "r"] = v

    nodes = g["nodes"]
    world, parent = node_world(nodes, ov)

    skin = g["skins"][0]
    joints = skin["joints"]
    ibm_raw = read(skin["inverseBindMatrices"])
    ibm = []
    for j in range(len(joints)):
        a = ibm_raw[j * 16: j * 16 + 16]
        ibm.append([[a[c * 4 + r] for c in range(4)] for r in range(4)])

    mesh = g["meshes"][0]
    img = Image.new("RGB", (W, H), (26, 34, 26))
    px = img.load()
    zbuf = [[1e9] * W for _ in range(H)]

    f = 1.0 / math.tan(math.radians(75) / 2)
    aspect = W / float(H)

    import io as _io
    teximgs = []
    for im in g.get("images", []):
        bv = im["bufferView"]
        d = binb[views[bv]["byteOffset"]: views[bv]["byteOffset"] + views[bv]["byteLength"]]
        teximgs.append(Image.open(_io.BytesIO(bytes(d))).convert("RGB"))

    drawn = 0
    for prim in mesh["primitives"]:
        mat_i = prim.get("material", 0)
        bct = (g.get("materials") or [{}])[mat_i].get("pbrMetallicRoughness", {}).get("baseColorTexture")
        tex = teximgs[bct["index"]] if bct and teximgs else None
        tw, th = tex.size if tex else (1, 1)
        P = read(prim["attributes"]["POSITION"])
        UV = read(prim["attributes"]["TEXCOORD_0"]) if "TEXCOORD_0" in prim["attributes"] else None
        J = read(prim["attributes"]["JOINTS_0"]) if "JOINTS_0" in prim["attributes"] else None
        Wt = read(prim["attributes"]["WEIGHTS_0"]) if "WEIGHTS_0" in prim["attributes"] else None
        I = read(prim["indices"])
        nv = len(P) // 3
        skin_mats = []
        for v in range(nv):
            acc_m = [[0.0] * 4 for _ in range(4)]
            for k in range(4):
                j = J[v * 4 + k]
                w = Wt[v * 4 + k]
                if w == 0 or j >= len(joints):
                    continue
                sm = mul(world[joints[j]], ibm[j])
                for r in range(4):
                    for c in range(4):
                        acc_m[r][c] += w * sm[r][c]
            skin_mats.append(acc_m)
        cam = []
        # GemRender transform 钩子：模型根在脚底，需要移到「相机=眼睛」的相对位置。
        # 眼高约 1.62m（人高 1.8 的眼睛），手前伸 y≈1.36 → 应落在视野中下。
        SHIFT = (0.0, -1.62, 0.0)
        for v in range(nv):
            p = skin_mats[v]
            x = p[0][0] * P[v * 3] + p[0][1] * P[v * 3 + 1] + p[0][2] * P[v * 3 + 2] + p[0][3]
            y = p[1][0] * P[v * 3] + p[1][1] * P[v * 3 + 1] + p[1][2] * P[v * 3 + 2] + p[1][3]
            z = p[2][0] * P[v * 3] + p[2][1] * P[v * 3 + 1] + p[2][2] * P[v * 3 + 2] + p[2][3]
            cam.append((x + SHIFT[0], y + SHIFT[1], z + SHIFT[2]))
        # 简单相机：后移 dist，绕 Y 偏航，绕 X 俯仰
        cy, sy = math.cos(math.radians(yaw_deg)), math.sin(math.radians(yaw_deg))
        cp, sp = math.cos(math.radians(pitch_deg)), math.sin(math.radians(pitch_deg))
        view = []
        for (x, y, z) in cam:
            x, z = x * cy + z * sy, -x * sy + z * cy
            y, z = y * cp - z * sp, y * sp + z * cp
            z -= dist
            view.append((x, y, z))
        for t in range(0, len(I), 3):
            tri = []
            ok = True
            for i in (I[t], I[t + 1], I[t + 2]):
                x, y, z = view[i]
                if z > -NEAR:
                    ok = False
                    break
                w = -z
                nx = (f / aspect) * x / w
                ny = f * y / w
                sx = int((nx + 1) * 0.5 * W)
                sy = int((1 - ny) * 0.5 * H)
                tri.append((sx, sy, w))
            if not ok:
                continue
            (x0, y0, w0), (x1, y1, w1), (x2, y2, w2) = tri
            det = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
            if abs(det) < 1e-9:
                continue
            xs = [x0, x1, x2]; ys = [y0, y1, y2]
            for yy in range(max(0, min(ys)), min(H - 1, max(ys)) + 1):
                for xx in range(max(0, min(xs)), min(W - 1, max(xs)) + 1):
                    w0n = ((y1 - y2) * (xx - x2) + (x2 - x1) * (yy - y2)) / det
                    w1n = ((y2 - y0) * (xx - x2) + (x0 - x2) * (yy - y2)) / det
                    w2n = 1 - w0n - w1n
                    if w0n < -1e-6 or w1n < -1e-6 or w2n < -1e-6:
                        continue
                    z = w0n * w0 + w1n * w1 + w2n * w2
                    if z >= zbuf[yy][xx]:
                        continue
                    zbuf[yy][xx] = z
                    if UV and tex:
                        u = w0n * UV[I[t] * 2] + w1n * UV[I[t + 1] * 2] + w2n * UV[I[t + 2] * 2]
                        vv = w0n * UV[I[t] * 2 + 1] + w1n * UV[I[t + 1] * 2 + 1] + w2n * UV[I[t + 2] * 2 + 1]
                        uu = min(tw - 1, max(0, int(u * tw)))
                        vvv = min(th - 1, max(0, int((1 - vv) * th)))
                        px[xx, yy] = tex.getpixel((uu, vvv))
                    else:
                        px[xx, yy] = (160, 165, 175)
            drawn += 1
    img.save(out)
    print("%s  tris=%d  -> %s" % (os.path.basename(out), drawn, out))
    return out


NEAR = 0.05

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--time", type=float, default=0.0)
    ap.add_argument("--yaw", type=float, default=0.0)
    ap.add_argument("--pitch", type=float, default=0.0)
    ap.add_argument("--dist", type=float, default=2.2)
    ap.add_argument("--out", default=os.path.join(ROOT, "notes", "debug", "fp_preview.png"))
    a = ap.parse_args()
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    render(a.time, a.yaw, a.pitch, a.dist, a.out)
