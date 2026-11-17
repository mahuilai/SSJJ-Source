# -*- coding: utf-8 -*-
"""P2/P3: 把 awm_legend_t 的 130 张贴图导成 PNG、20 个 Mesh 导成 OBJ + manifest。

Unity 2019.4 Mesh VertexData 没有 m_Streams（typetree 实测为 null），流布局要按
m_Channels 推断：
  stride[s] = align4(max(offset + dimension * format_size) for ch with stream==s)
  数据段按 stream 编号顺序连续存放: [vt*stride0][vt*stride1]...
  顶点 i 在 stream s 的基址 = sum(vt*stride[k] for k<s) + i*stride[s]
实测校验: jian_2 12顶点 384B = 12*32; Plane002 4顶点 144B = 4*24+4*8+4*4。

坐标系: Unity 左手 Y-up -> glTF/Blockbench 右手 Y-up，导出时翻转 X。
索引: m_IndexBuffer 为 uint16 little-endian，submesh 按 firstByte/indexCount 切。

用法: python export_assets.py [--textures-only|--mesh-only]
"""
import argparse
import json
import os
import struct
import sys

import UnityPy
from PIL import Image

ROOT = r"D:\逆向\SSJJ双塔惊魂"
WEAPON = os.path.join(ROOT, "资源全集", "weapon")
OUT = os.path.join(ROOT, "mc-port", "out")
TEX_DIR = os.path.join(OUT, "textures")
MESH_DIR = os.path.join(OUT, "mesh")
MANIFEST = os.path.join(OUT, "asset_manifest.json")

# Unity VertexChannelFormat 每分量字节宽（实测本批出现 0/1/2/10）
#   0 kFloat=4, 1 kFloat16=2, 2 kColor/UNorm8=1, 10 kUInt32=4
FMT_SIZE = {0: 4, 1: 2, 2: 1, 3: 1, 4: 1, 5: 2, 6: 2,
            7: 1, 8: 1, 9: 2, 10: 4, 11: 4, 12: 4}
FMT_CODE = {0: "f", 1: "e", 2: "B", 10: "I", 11: "I", 12: "i"}


def find_bundles():
    fs = [f for f in os.listdir(WEAPON) if f.startswith("awm_legend_t")]
    main = [f for f in fs if "$2_" not in f][0]
    sub = [f for f in fs if "$2_" in f][0]
    return os.path.join(WEAPON, main), os.path.join(WEAPON, sub)


def align4(n):
    return (n + 3) & ~3


def align16(n):
    return (n + 15) & ~15


def decode_vertex_stream(data, vt, channels):
    # channels: list of dict {index, stream, offset, format, dimension}
    # ChannelInfo 有 __slots__，不能动态挂字段，所以先转成普通 dict。
    active = [c for c in channels if c["dimension"] > 0]
    streams = sorted(set(c["stream"] for c in active))
    stride = {}
    for s in streams:
        mx = 0
        for c in active:
            if c["stream"] != s:
                continue
            fsz = FMT_SIZE.get(c["format"], 4)
            mx = max(mx, c["offset"] + c["dimension"] * fsz)
        stride[s] = align4(mx)
    start = {}
    segment = {}
    pos = 0
    for s in streams:
        start[s] = pos
        # 流段紧密排列；整个 blob 尾部允许 <=16 字节对齐填充
        segment[s] = vt * stride[s]
        pos += segment[s]
    if pos > len(data) or len(data) - pos > 16:
        raise RuntimeError("stream layout mismatch: need %d, have %d (vt=%d stride=%s seg=%s)"
                           % (pos, len(data), vt, stride, segment))

    out = []
    for i in range(vt):
        rec = {"Position": None, "Normal": None, "UV": [], "Extra": []}
        for c in active:
            s = c["stream"]
            base = start[s] + i * stride[s] + c["offset"]
            dim = c["dimension"]
            fmt = c["format"]
            code = FMT_CODE.get(fmt)
            if code:
                vals = struct.unpack_from("<" + code * dim, data, base)
            else:
                vals = tuple([0.0] * dim)
            ci = c["index"]
            if ci == 0:
                rec["Position"] = vals
            elif ci == 1:
                rec["Normal"] = vals
            elif ci == 4:
                rec["UV"].append(vals)
            else:
                rec["Extra"].append((ci, vals))
        out.append(rec)
    return out, stride


def export_mesh(path):
    env = UnityPy.load(path)
    os.makedirs(MESH_DIR, exist_ok=True)
    obj_path = os.path.join(MESH_DIR, "awm_legend_t.obj")
    records = []
    total_v = total_t = 0
    with open(obj_path, "w", encoding="utf-8") as f:
        f.write("# awm_legend_t - exported by mc-port/tools/export_assets.py\n")
        f.write("# X flipped (Unity LH -> RH Y-up). 1 unit = 1 Unity unit.\n")
        vbase = 1
        for o in env.objects:
            if o.type.name != "Mesh":
                continue
            d = o.read()
            vd = d.m_VertexData
            data = vd.m_DataSize
            if not isinstance(data, (bytes, bytearray)):
                raise RuntimeError("m_DataSize is not bytes: %s" % type(data))
            vt = vd.m_VertexCount
            channels = [{"index": i,
                         "stream": getattr(c, "stream", 0),
                         "offset": getattr(c, "offset", 0),
                         "format": getattr(c, "format", 0),
                         "dimension": getattr(c, "dimension", 0)}
                        for i, c in enumerate(vd.m_Channels or [])]
            verts, stride = decode_vertex_stream(data, vt, channels)
            ib = d.m_IndexBuffer or []
            # UnityPy 1.25.4 把 m_IndexBuffer 暴露成 list[int]（逐字节），不是 bytes
            if isinstance(ib, (bytes, bytearray)):
                idx_bytes = bytes(ib)
            else:
                idx_bytes = bytes(int(x) & 0xFF for x in ib)
            indices = list(struct.unpack_from("<%dH" % (len(idx_bytes) // 2), idx_bytes, 0))
            f.write("\no %s\n" % (d.m_Name or ("mesh_%d" % o.path_id)))
            for v in verts:
                p = v["Position"] or (0, 0, 0)
                f.write("v %.6f %.6f %.6f\n" % (-p[0], p[1], p[2]))
            for v in verts:
                uv = v["UV"][0] if v["UV"] else (0.0, 0.0)
                f.write("vt %.6f %.6f\n" % (uv[0], uv[1]))
            for v in verts:
                n = v["Normal"] or (0, 1, 0)
                f.write("vn %.6f %.6f %.6f\n" % (-n[0], n[1], n[2]))
            subs = d.m_SubMeshes or []
            ranges = []
            for s in subs:
                fb = s.firstByte
                ic = s.indexCount
                for j in range(fb // 2, fb // 2 + ic, 3):
                    if j + 2 >= len(indices):
                        break
                    a, b, c = indices[j] + vbase, indices[j + 1] + vbase, indices[j + 2] + vbase
                    # 翻转一个轴后绕序反转
                    f.write("f %d/%d/%d %d/%d/%d %d/%d/%d\n" %
                            (a, a, a, c, c, c, b, b, b))
                ranges.append({"firstByte": fb, "indexCount": ic,
                               "topology": getattr(s, "topology", 0)})
            tris = sum(r["indexCount"] for r in ranges) // 3
            records.append({
                "name": d.m_Name, "path_id": o.path_id,
                "vertices": vt, "triangles": tris,
                "stride": stride, "data_bytes": len(data),
                "submeshes": ranges,
                "bindpose_count": len(d.m_BindPose or []),
                "uv_range": [
                    min((v["UV"][0][0] for v in verts if v["UV"]), default=0),
                    max((v["UV"][0][0] for v in verts if v["UV"]), default=0),
                    min((v["UV"][0][1] for v in verts if v["UV"]), default=0),
                    max((v["UV"][0][1] for v in verts if v["UV"]), default=0),
                ],
            })
            total_v += vt
            total_t += tris
            vbase += vt
    return obj_path, records, total_v, total_t


def export_textures(path):
    env = UnityPy.load(path)
    os.makedirs(TEX_DIR, exist_ok=True)
    out = []
    seen = {}
    for o in env.objects:
        if o.type.name != "Texture2D":
            continue
        try:
            d = o.read()
            img = d.image
            if img is None:
                continue
            if not isinstance(img, Image.Image):
                img = Image.fromarray(img)
            name = (d.m_Name or ("tex_%d" % o.path_id)).replace("/", "_").replace("\\", "_")
            if name in seen:
                name = "%s_%d" % (name, o.path_id)
            seen[name] = 1
            img = img.convert("RGBA")
            fp = os.path.join(TEX_DIR, name + ".png")
            img.save(fp)
            out.append({"name": name, "file": name + ".png",
                        "width": d.m_Width, "height": d.m_Height,
                        "format": d.m_TextureFormat, "mip": d.m_MipCount,
                        "bytes": os.path.getsize(fp)})
        except Exception as e:
            out.append({"name": getattr(d, "m_Name", "?"), "error": "%s: %s" % (type(e).__name__, str(e)[:80])})
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--textures-only", action="store_true")
    ap.add_argument("--mesh-only", action="store_true")
    args = ap.parse_args()
    main_p, sub_p = find_bundles()
    result = {"coordinate_system": "X flipped (Unity LH -> RH Y-up)",
              "source": {"main": os.path.basename(main_p), "mesh": os.path.basename(sub_p)}}
    if not args.mesh_only:
        tex = export_textures(main_p)
        ok = [t for t in tex if "file" in t]
        print("textures: %d exported / %d errors" % (len(ok), len(tex) - len(ok)))
        result["textures"] = tex
    if not args.textures_only:
        obj, meshes, tv, tt = export_mesh(sub_p)
        print("mesh: %d objects, %d verts, %d tris -> %s" % (len(meshes), tv, tt, obj))
        result["meshes"] = meshes
        result["mesh_totals"] = {"vertices": tv, "triangles": tt}
    with open(MANIFEST, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=1)
    print("manifest:", MANIFEST)


if __name__ == "__main__":
    main()
