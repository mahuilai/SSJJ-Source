# -*- coding: utf-8 -*-
"""SSJJ viewhand bundle + .anm  ->  glTF 2.0（骨架 / 蒙皮权重 / 动画）

把第一人称手模与 SSJJ 自己的 .anm 逐帧动画导成 glTF，
Blender 3.6+ / 4.x 直接 File > Import > glTF 2.0 就得到
「骨架 + 蒙皮 + 动画」，再 Export > FBX 即可。

为什么必须自己转：
  AssetStudio / AssetRipper 能导带蒙皮的 FBX，但都不认识 SSJJ 私有的 .anm
  （它不是 Unity AnimationClip）。动画只能按下面的格式自己解。

用法：
  # 只导模型
  python ssjj2gltf.py --bundle "viewhand\\man_7054af81..." --out out\\man
  # 模型 + 动画
  python ssjj2gltf.py --bundle ... --anim "Game source\\06_singleplayer\\anim\\anim\\ak47.anm" --out out\\ak47
  # 只导一个 clip
  python ssjj2gltf.py ... --anim ak47.anm --clip crouch_shoot2_ak47_blend0
  # 不翻转 X（默认把 Unity 左手系转成 glTF 右手系）
  python ssjj2gltf.py ... --no-flip

依赖：UnityPy 1.20+（本机 Python314 里是 1.25.2）

三个实测要点（踩过的坑）：
1. 真蒙皮权重在 m_VertexData 通道里，不在 m_Skin / m_Weights：
     ch12  stream2 offset 0   format0 (float4)  = BLENDWEIGHT
     ch13  stream2 offset 16  format10(uint32)  = BLENDINDICES
   Unity 2019 这两项走 m_VariableBoneCountWeights，m_Skin/m_Weights 是空的。
2. 逆绑定矩阵在 **Mesh.m_BindPose**（44 个 Matrix4x4f，行主序 e00..e33）；
   SkinnedMeshRenderer.m_BindPose 为空，别从那里取。
3. .anm 里只有「骨名 + 每帧局部 TRS」，没有层级也没有绑定姿态，
   单独转 .anm 没有意义，必须配着骨架一起导。

.anm 布局（小端；ReadUTF = uint16 长度 + UTF8）：
  int32 version; int32 groupCount
  groupCount × [ UTF groupName; int32 clipCount
    clipCount × [ UTF clipName; int32 curveCount; float length
      curveCount × [ UTF boneName; int32 frameCount
        frameCount × 8×float32 = time, px,py,pz, qx,qy,qz,qw ] ] ]
"""

import argparse
import io
import json
import os
import struct

import UnityPy

FMT_SIZE = {0: 4, 1: 2, 2: 1, 3: 2, 4: 2, 10: 4}
FMT_CODE = {0: "f", 1: "e", 2: "B", 3: "H", 4: "h", 10: "I"}


def align4(n):
    return (n + 3) & ~3


# ------------------------------------------------------------------ 四元数

def qmul(a, b):
    ax, ay, az, aw = a
    bx, by, bz, bw = b
    return (aw * bx + ax * bw + ay * bz - az * by,
            aw * by - ax * bz + ay * bw + az * bx,
            aw * bz + ax * by - ay * bx + az * bw,
            aw * bw - ax * bx - ay * by - az * bz)


def qnorm(q):
    l = (q[0] ** 2 + q[1] ** 2 + q[2] ** 2 + q[3] ** 2) ** 0.5
    return (0.0, 0.0, 0.0, 1.0) if l < 1e-12 else (q[0] / l, q[1] / l, q[2] / l, q[3] / l)


def qrot(q, v):
    x, y, z, w = q
    vx, vy, vz = v
    tx = 2.0 * (y * vz - z * vy)
    ty = 2.0 * (z * vx - x * vz)
    tz = 2.0 * (x * vy - y * vx)
    return (vx + w * tx + (y * tz - z * ty),
            vy + w * ty + (z * tx - x * tz),
            vz + w * tz + (x * ty - y * tx))


# ------------------------------------------------------------------ .anm

def read_utf(r):
    n = struct.unpack("<H", r.read(2))[0]
    return r.read(n).decode("utf-8", "replace")


def parse_anm(path):
    data = open(path, "rb").read()
    r = io.BytesIO(data)
    version = struct.unpack("<i", r.read(4))[0]
    gc = struct.unpack("<i", r.read(4))[0]
    groups = []
    for _ in range(gc):
        gname = read_utf(r)
        cc = struct.unpack("<i", r.read(4))[0]
        clips = []
        for _ in range(cc):
            cname = read_utf(r)
            curves_n = struct.unpack("<i", r.read(4))[0]
            length = struct.unpack("<f", r.read(4))[0]
            if length <= 0.0:
                length = 1.0 / 30.0
            curves = {}
            for _ in range(curves_n):
                bone = read_utf(r)
                fc = struct.unpack("<i", r.read(4))[0]
                frames = []
                for _ in range(fc):
                    t, px, py, pz, qx, qy, qz, qw = struct.unpack("<8f", r.read(32))
                    frames.append((t, (px, py, pz), (qx, qy, qz, qw)))
                curves[bone] = frames
            clips.append({"name": cname, "length": length, "curves": curves})
        groups.append({"name": gname, "clips": clips})
    left = len(data) - r.tell()
    if left:
        print("WARN: .anm 剩余 %d 字节未消费（共 %d）" % (left, len(data)))
    return version, groups


# ------------------------------------------------------------------ 顶点

def decode_vertex_stream(data, vt, channels):
    active = [c for c in channels if c["dimension"] > 0]
    streams = sorted({c["stream"] for c in active})
    stride = {}
    for s in streams:
        mx = 0
        for c in active:
            if c["stream"] == s:
                mx = max(mx, c["offset"] + c["dimension"] * FMT_SIZE.get(c["format"], 4))
        stride[s] = align4(mx)
    start, pos = {}, 0
    for s in streams:
        start[s] = pos
        pos += vt * stride[s]
    if pos > len(data) or len(data) - pos > 16:
        raise RuntimeError("stream layout mismatch: need %d have %d vt=%d stride=%s"
                           % (pos, len(data), vt, stride))
    out = []
    for i in range(vt):
        rec = {"pos": None, "uv": None, "w": None, "j": None}
        for c in active:
            base = start[c["stream"]] + i * stride[c["stream"]] + c["offset"]
            ci = c["index"]
            # 蒙皮通道：ChannelInfo 的 index/format 标反了（12 标 float 实为索引，
            # 13 标 uint32 实为权重）。按 offset 判：0 = BLENDINDICES(uint32×4)，
            # 16 = BLENDWEIGHT(float4)。顶点 0 的索引区是脏数据，下面会 clamp。
            if ci in (12, 13) or c["stream"] == 2:
                if c["offset"] == 0:
                    rec["j"] = struct.unpack_from("<4I", data, base)
                else:
                    rec["w"] = struct.unpack_from("<4f", data, base)
                continue
            code = FMT_CODE.get(c["format"])
            dim = c["dimension"]
            vals = struct.unpack_from("<" + code * dim, data, base) if code else (0.0,) * dim
            rec[{0: "pos", 4: "uv"}.get(ci, "?")] = vals
        out.append(rec)
    return out, stride


# ------------------------------------------------------------------ glTF

class Gltf:
    def __init__(self):
        self.j = {
            "asset": {"version": "2.0", "generator": "ssjj2gltf"},
            "scene": 0, "scenes": [{"nodes": []}],
            "nodes": [], "meshes": [], "skins": [], "materials": [],
            "textures": [], "images": [], "samplers": [],
            "accessors": [], "bufferViews": [], "buffers": [],
        }
        self.bin = bytearray()

    def view(self, blob, target=None):
        while len(self.bin) % 4:
            self.bin.append(0)
        off = len(self.bin)
        self.bin += blob
        v = {"buffer": 0, "byteOffset": off, "byteLength": len(blob)}
        if target:
            v["target"] = target
        self.j["bufferViews"].append(v)
        return len(self.j["bufferViews"]) - 1

    def acc(self, blob, comp, type_str, count, target=None, minmax=None):
        bv = self.view(blob, target)
        a = {"bufferView": bv, "componentType": comp, "count": count, "type": type_str}
        if minmax:
            a["min"], a["max"] = minmax
        self.j["accessors"].append(a)
        return len(self.j["accessors"]) - 1

    def f32v(self, vals, type_str, count, minmax=None, target=34962):
        return self.acc(struct.pack("<%df" % len(vals), *vals), 5126, type_str, count, target, minmax)

    def f32s(self, vals, minmax=None):
        return self.acc(struct.pack("<%df" % len(vals), *vals), 5126, "SCALAR",
                        len(vals), None, minmax)


class Skeleton:
    def __init__(self, env):
        self.tr, self.toname = {}, {}
        goname = {}
        for o in env.objects:
            if o.type.name == "GameObject":
                goname[o.path_id] = o.read_typetree().get("m_Name")
        for o in env.objects:
            if o.type.name != "Transform":
                continue
            t = o.read_typetree()
            go = (t.get("m_GameObject") or {}).get("m_PathID")
            lp = t.get("m_LocalPosition") or {}
            lr = t.get("m_LocalRotation") or {}
            ls = t.get("m_LocalScale") or {}
            self.tr[o.path_id] = {
                "go": go,
                "father": (t.get("m_Father") or {}).get("m_PathID"),
                "t": [lp.get("x", 0.0), lp.get("y", 0.0), lp.get("z", 0.0)],
                "r": [lr.get("x", 0.0), lr.get("y", 0.0), lr.get("z", 0.0), lr.get("w", 1.0)],
                "s": [ls.get("x", 1.0), ls.get("y", 1.0), ls.get("z", 1.0)],
            }
            self.toname[o.path_id] = goname.get(go) or ("node_%d" % o.path_id)

    def path_of(self, name):
        for pid, n in self.toname.items():
            if n == name:
                return pid
        return None


def export(bundle, anim_path, clip_filter, out_base, flip, uv_flip):
    env = UnityPy.load(bundle)
    sk = Skeleton(env)

    smr = next((o for o in env.objects if o.type.name == "SkinnedMeshRenderer"), None)
    if smr is None:
        raise SystemExit("bundle 里没有 SkinnedMeshRenderer")
    smt = smr.read_typetree()
    bone_pids = [(b or {}).get("m_PathID") for b in (smt.get("m_Bones") or [])]
    mesh_pid = (smt.get("m_Mesh") or {}).get("m_PathID")

    mesh = None
    for o in env.objects:
        if o.type.name == "Mesh" and (mesh_pid is None or o.path_id == mesh_pid):
            mesh = o
            break
    if mesh is None:
        raise SystemExit("bundle 里没有 Mesh")
    mt = mesh.read_typetree()

    vd = mt["m_VertexData"]
    vt = vd["m_VertexCount"]
    def fld(c, name):
        return c.get(name) if isinstance(c, dict) else getattr(c, name)

    chans = [{"index": i, "stream": fld(c, "stream"), "offset": fld(c, "offset"),
              "format": fld(c, "format"), "dimension": fld(c, "dimension")}
             for i, c in enumerate(vd["m_Channels"] or [])]
    recs, stride = decode_vertex_stream(bytes(vd["m_DataSize"]), vt, chans)

    ib = mt.get("m_IndexBuffer") or []
    raw = b"".join(ib) if ib and isinstance(ib[0], (bytes, bytearray)) else bytes(ib)
    idx = list(struct.unpack("<%dH" % (len(raw) // 2), raw[: (len(raw) // 2) * 2]))

    bp = mt.get("m_BindPose") or []
    if not bp:
        raise SystemExit("Mesh.m_BindPose 为空，无法生成 skin")

    def mp(p):
        return [-p[0], p[1], p[2]] if flip else [p[0], p[1], p[2]]

    def mq(q):
        return [q[0], -q[1], -q[2], q[3]] if flip else list(q)

    # 面法线 -> 顶点平均（这批 mesh 没有 NORMAL 通道）
    acc = [[0.0, 0.0, 0.0] for _ in range(vt)]
    for i in range(0, len(idx) - 2, 3):
        a, b, c = idx[i], idx[i + 1], idx[i + 2]
        if max(a, b, c) >= vt:
            continue
        pa, pb, pc = recs[a]["pos"], recs[b]["pos"], recs[c]["pos"]
        u = [pb[k] - pa[k] for k in range(3)]
        v = [pc[k] - pa[k] for k in range(3)]
        n = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]]
        for t in (a, b, c):
            for k in range(3):
                acc[t][k] += n[k]

    g = Gltf()
    node_of = {}
    for pid in sk.tr:
        node_of[pid] = len(g.j["nodes"])
        n = sk.tr[pid]
        g.j["nodes"].append({
            "name": sk.toname.get(pid),
            "translation": mp(n["t"]),
            "rotation": mq(n["r"]),
            "scale": n["s"],
        })
    for pid, n in sk.tr.items():
        f = n["father"]
        if f and f in node_of:
            g.j["nodes"][node_of[f]].setdefault("children", []).append(node_of[pid])
        else:
            g.j["scenes"][0]["nodes"].append(node_of[pid])

    pos, uvs, js, ws = [], [], [], []
    for rec in recs:
        pos.extend(mp(rec["pos"]))
        u = rec["uv"] or (0.0, 0.0)
        uvs.extend((u[0], 1.0 - u[1]) if uv_flip else (u[0], u[1]))
        w = list(rec["w"] or (0.0, 0.0, 0.0, 0.0))
        j = list(rec["j"] or (0, 0, 0, 0))
        tot = sum(max(0.0, x) for x in w)
        if tot <= 1e-6:
            w, tot = [1.0, 0.0, 0.0, 0.0], 1.0
        js.extend(0 if (x < 0 or x >= len(bone_pids)) else int(x) for x in j)
        ws.extend([max(0.0, x) / tot for x in w])
    nrm = []
    for i in range(vt):
        x, y, z = acc[i]
        l = (x * x + y * y + z * z) ** 0.5 or 1.0
        nrm.extend(mp((x / l, y / l, z / l)))

    tri = []
    for i in range(0, len(idx) - 2, 3):
        a, b, c = idx[i], idx[i + 1], idx[i + 2]
        if max(a, b, c) >= vt:
            continue
        tri.extend((a, c, b) if flip else (a, b, c))

    a_pos = g.f32v(pos, "VEC3", vt,
                   ([min(pos[0::3]), min(pos[1::3]), min(pos[2::3])],
                    [max(pos[0::3]), max(pos[1::3]), max(pos[2::3])]))
    a_nrm = g.f32v(nrm, "VEC3", vt)
    a_uv = g.f32v(uvs, "VEC2", vt)
    a_w = g.f32v(ws, "VEC4", vt)
    a_j = g.acc(struct.pack("<%dH" % len(js), *js), 5123, "VEC4", vt, 34962)
    a_i = g.acc(struct.pack("<%dI" % len(tri), *tri), 5125, "SCALAR", len(tri), 34963)

    joints_nodes = [node_of[p] for p in bone_pids if p in node_of]
    ibm = []
    for e in bp:
        def val(r, c):
            v = e["e%d%d" % (r, c)]
            if flip and (r == 0) != (c == 0):
                return -v
            return v
        ibm.extend(val(r, c) for c in range(4) for r in range(4))
    a_ibm = g.acc(struct.pack("<%df" % len(ibm), *ibm), 5126, "MAT4", len(bp))
    g.j["skins"].append({"joints": joints_nodes, "inverseBindMatrices": a_ibm,
                         "skeleton": joints_nodes[0] if joints_nodes else None})

    tex_png = None
    for o in env.objects:
        if o.type.name == "Texture2D":
            d = o.read()
            tex_png = out_base + "_tex.png"
            d.image.convert("RGBA").save(tex_png)
            break
    mat = {"name": "ssjj", "doubleSided": True,
           "pbrMetallicRoughness": {"metallicFactor": 0.0, "roughnessFactor": 0.8}}
    if tex_png:
        g.j["images"].append({"uri": os.path.basename(tex_png)})
        g.j["samplers"].append({"magFilter": 9729, "minFilter": 9987,
                                "wrapS": 10497, "wrapT": 10497})
        g.j["textures"].append({"source": 0, "sampler": 0})
        mat["pbrMetallicRoughness"]["baseColorTexture"] = {"index": 0}
    g.j["materials"].append(mat)

    g.j["meshes"].append({"name": mt.get("m_Name") or "mesh", "primitives": [{
        "attributes": {"POSITION": a_pos, "NORMAL": a_nrm, "TEXCOORD_0": a_uv,
                       "JOINTS_0": a_j, "WEIGHTS_0": a_w},
        "indices": a_i, "material": 0, "mode": 4}]})
    mn = len(g.j["nodes"])
    g.j["nodes"].append({"name": "SSJJ_Mesh", "mesh": 0, "skin": 0})
    g.j["scenes"][0]["nodes"].append(mn)

    # ---------------------------------------------------------- 动画
    n_clip = 0
    missing = set()
    if anim_path:
        _, groups = parse_anm(anim_path)
        g.j["animations"] = []
        for grp in groups:
            for clip in grp["clips"]:
                if clip_filter and clip["name"] != clip_filter:
                    continue
                anim = {"name": clip["name"], "channels": [], "samplers": []}
                for bone, frames in clip["curves"].items():
                    pid = sk.path_of(bone)
                    if pid is None or pid not in node_of:
                        missing.add(bone)
                        continue
                    times, tv, rv = [], [], []
                    for (t, p, q) in frames:
                        times.append(float(t))
                        tv.extend(mp(p))
                        rv.extend(mq(q))
                    a_t = g.f32s(times, ([min(times)], [max(times)]))
                    a_p = g.f32v(tv, "VEC3", len(times), target=None)
                    a_r = g.f32v(rv, "VEC4", len(times), target=None)
                    st = len(anim["samplers"])
                    anim["samplers"].append({"input": a_t, "output": a_p, "interpolation": "LINEAR"})
                    anim["samplers"].append({"input": a_t, "output": a_r, "interpolation": "LINEAR"})
                    anim["channels"].append({"sampler": st, "target": {"node": node_of[pid], "path": "translation"}})
                    anim["channels"].append({"sampler": st + 1, "target": {"node": node_of[pid], "path": "rotation"}})
                if anim["channels"]:
                    g.j["animations"].append(anim)
                    n_clip += 1

    bin_path = out_base + ".bin"
    with open(bin_path, "wb") as f:
        f.write(g.bin)
    g.j["buffers"] = [{"uri": os.path.basename(bin_path), "byteLength": len(g.bin)}]
    gltf_path = out_base + ".gltf"
    with open(gltf_path, "w", encoding="utf-8") as f:
        json.dump(g.j, f, ensure_ascii=False, separators=(",", ":"))

    print("mesh=%s verts=%d tris=%d joints=%d stride=%s idxbytes=%d idxfmt=%s"
          % (mt.get("m_Name"), vt, len(tri) // 3, len(joints_nodes), stride,
             len(raw), mt.get("m_IndexFormat")))
    print("v0.pos=%s  w0=%s  j0=%s  sum(w0)=%.3f"
          % (tuple(round(x, 2) for x in recs[0]["pos"]), recs[0]["w"], recs[0]["j"],
             sum(recs[0]["w"] or [0])))
    print("bbox min=%s max=%s"
          % ([round(min(pos[0::3]), 2), round(min(pos[1::3]), 2), round(min(pos[2::3]), 2)],
             [round(max(pos[0::3]), 2), round(max(pos[1::3]), 2), round(max(pos[2::3]), 2)]))
    print("nodes=%d  accessors=%d  bin=%d B"
          % (len(g.j["nodes"]), len(g.j["accessors"]), len(g.bin)))
    if anim_path:
        print("clips=%d  (骨骼缺失并已跳过: %s)" % (n_clip, ", ".join(sorted(missing)) or "无"))
    print("out  -> %s" % gltf_path)
    return gltf_path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle", required=True, help="viewhand bundle 路径（或目录里的文件名）")
    ap.add_argument("--anim", default=None, help=".anm 文件")
    ap.add_argument("--clip", default=None, help="只导这个 clip")
    ap.add_argument("--out", required=True, help="输出前缀（不含扩展名）")
    ap.add_argument("--no-flip", action="store_true", help="不做 Unity 左手系 -> glTF 右手系转换")
    ap.add_argument("--no-uv-flip", action="store_true", help="不翻转 UV 的 V")
    a = ap.parse_args()

    bundle = a.bundle
    if not os.path.isfile(bundle):
        cand = os.path.join(r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand", bundle)
        if os.path.isfile(cand):
            bundle = cand
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    export(bundle, a.anim, a.clip, a.out, not a.no_flip, not a.no_uv_flip)


if __name__ == "__main__":
    main()
