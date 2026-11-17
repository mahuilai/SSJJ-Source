# -*- coding: utf-8 -*-
"""导出第一人称手模（viewhand/<career>）为 OBJ，并打印骨骼清单。

原版第一人称 = 手模 + 枪模 + hand_man.anm（Bip01_* 骨骼）。
本脚本是 P5 的第一步：确认手模能被解码、骨骼名与 .anm 对齐。

用法：
  python export_viewhand.py                 # 默认 man_*
  python export_viewhand.py <bundle文件名>   # 指定 viewhand 下的包名
"""
import collections
import os
import sys

import UnityPy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from export_assets import decode_vertex_stream  # noqa: E402

VIEWHAND = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand"
OUT = r"D:\逆向\SSJJ双塔竞魂"  # 占位，下面会被覆盖
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"


def bone_names(env):
    gos, tr = {}, {}
    for o in env.objects:
        if o.type.name == "GameObject":
            try:
                gos[o.path_id] = o.read_typetree().get("m_Name")
            except Exception:
                pass
    for o in env.objects:
        if o.type.name == "Transform":
            try:
                t = o.read_typetree()
                tr[o.path_id] = (t.get("m_GameObject") or {}).get("m_PathID")
            except Exception:
                pass
    return gos, tr


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else None
    if not name:
        cands = [f for f in os.listdir(VIEWHAND) if f.startswith("man_")]
        name = cands[0] if cands else os.listdir(VIEWHAND)[0]
    path = os.path.join(VIEWHAND, name)
    print("bundle:", name, os.path.getsize(path), "B")

    env = UnityPy.load(path)
    gos, tr = bone_names(env)

    bones = []
    for o in env.objects:
        if o.type.name != "SkinnedMeshRenderer":
            continue
        t = o.read_typetree()
        pids = [(x or {}).get("m_PathID") for x in (t.get("m_Bones") or [])]
        bones = [gos.get(tr.get(b)) for b in pids]
        break

    mesh = None
    for o in env.objects:
        if o.type.name == "Mesh":
            mesh = o.read()
            break
    if mesh is None:
        print("no mesh")
        return

    vd = mesh.m_VertexData
    vt = vd.m_VertexCount
    chans = [{"index": i, "stream": c.stream, "offset": c.offset,
              "format": c.format, "dimension": c.dimension}
             for i, c in enumerate(vd.m_Channels or [])]
    verts, stride = decode_vertex_stream(vd.m_DataSize, vt, chans)
    idx = list(mesh.m_IndexBuffer or [])
    if isinstance(idx[0], bytes):
        import struct
        idx = list(struct.unpack("<%dH" % (len(idx) // 2), b"".join(idx), 0)) \
            if len(idx) == 1 else idx
    idx = [int(x) for x in idx]

    xs = [v["Position"][0] for v in verts]
    ys = [v["Position"][1] for v in verts]
    zs = [v["Position"][2] for v in verts]
    print("mesh=%s verts=%d tris=%d stride=%s" % (mesh.m_Name, vt, len(idx) // 3, stride))
    print("bbox x %.2f..%.2f  y %.2f..%.2f  z %.2f..%.2f (cm)"
          % (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))
    print("bones=%d  %s" % (len(bones), bones[:10]))

    obj = os.path.join(OUT, "hand_man.obj")
    with open(obj, "w", encoding="utf-8") as f:
        f.write("o %s\n" % mesh.m_Name)
        for v in verts:
            p = v["Position"]
            f.write("v %.5f %.5f %.5f\n" % (p[0], p[1], p[2]))
        for v in verts:
            uv = v["UV"][0] if v["UV"] else (0.0, 0.0)
            f.write("vt %.5f %.5f\n" % (uv[0], uv[1]))
        for i in range(0, len(idx) - 2, 3):
            a, b, c = idx[i], idx[i + 1], idx[i + 2]
            if max(a, b, c) >= vt:
                continue
            f.write("f %d/%d %d/%d %d/%d\n" % (a + 1, a + 1, b + 1, b + 1, c + 1, c + 1))
    print("obj ->", obj, os.path.getsize(obj), "B")

    # 贴图
    texs = []
    for o in env.objects:
        if o.type.name == "Texture2D":
            try:
                d = o.read()
                texs.append((d.m_Name, d.m_Width, d.m_Height))
            except Exception:
                pass
    print("textures:", texs[:4])
    for o in env.objects:
        if o.type.name == "Texture2D":
            try:
                d = o.read()
                png = os.path.join(OUT, "hand_%s.png" % d.m_Name)
                d.image.convert("RGBA").save(png)
                print("png ->", png)
            except Exception as e:
                print("png fail", type(e).__name__)
            break


if __name__ == "__main__":
    main()
