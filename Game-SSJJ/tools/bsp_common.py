# -*- coding: utf-8 -*-
"""通用 Q3 BSP 分析 + mesh asset 生成器（map1 / map43 共用）。

关键点（踩过的坑，勿改）：
  1. surface.type 在 SSJJ 的 BSP 里全为 1，不遵循标准 Q3 "1=skip" 语义
     -> 不能按 ftype 过滤，否则三角形数为 0。
  2. drawIndex 是相对 vfirst 的局部下标，不是全局下标。
     -> vi = vfirst + IDX[ifirst + k]；用全局下标会只有 64 个顶点被引用。
  3. 实体 "origin" 三元组是 (X, 水平Z, 高度Y)，第二字段才是水平轴。

用法：
  python bsp_common.py analyze  <mapDir>
  python bsp_common.py genmesh  <mapDir> <outAssetPath> <meshName>
"""
import os
import struct
import sys
import collections

SKIP_WORDS = ("noshader", "common/clip", "common/weapclip", "sky", "nodraw",
              "trigger", "caulk", "hint", "areaportal", "clusterportal")


def base_of(sh):
    b = sh.replace("\\", "/").rsplit("/", 1)[-1]
    for ext in (".tga", ".jpg", ".png", ".dds"):
        if b.lower().endswith(ext):
            b = b[:-len(ext)]
    return b


class Bsp(object):
    def __init__(self, path):
        self.data = d = open(path, "rb").read()
        assert d[:4] == b"IBSP", "not a Q3 BSP: %r" % d[:4]
        self.L = L = [struct.unpack_from("<ii", d, 8 + i * 8) for i in range(17)]
        TO, TL = L[1]
        self.tex_off = TO
        self.names = []
        for i in range(0, TL, 72):
            nm = d[TO + i:TO + i + 64].split(b"\0")[0].decode("latin1")
            if not nm:
                break
            self.names.append(nm)
        self.verts_off = L[10][0]
        self.n_verts = L[10][1] // 44
        self.idx_off = L[11][0]
        self.surf_off, surf_len = L[13][0], L[13][1]
        self.n_surf = surf_len // 104
        # lump 0 = entities（文本）
        eo, el = L[0]
        self.entities = d[eo:eo + el].decode("latin1", "replace")
        # lump 2 = planes
        self.plane_off, plane_len = L[2][0], L[2][1]
        self.n_planes = plane_len // 16
        self._vert_bbox()

    def _vert_bbox(self):
        d = self.data
        xs = []
        ys = []
        zs = []
        for i in range(self.n_verts):
            x, y, z = struct.unpack_from("<3f", d, self.verts_off + i * 44)
            xs.append(x)
            ys.append(y)
            zs.append(z)
        self.vmin = (min(xs), min(ys), min(zs))
        self.vmax = (max(xs), max(ys), max(zs))

    def surfaces(self):
        """yield (surf_index, shader_idx, vfirst, nv, ifirst, ni)"""
        d = self.data
        for i in range(self.n_surf):
            b = self.surf_off + i * 104
            shader = struct.unpack_from("<i", d, b)[0]
            vfirst, nv, ifirst, ni = struct.unpack_from("<4i", d, b + 12)
            yield i, shader, vfirst, nv, ifirst, ni

    def triangles(self):
        """yield (mat_key, (p0,p1,p2)) —— 已套用 SsjjToUnity 坐标 (-y, z, x)"""
        d = self.data
        out = []
        for si, shader, vfirst, nv, ifirst, ni in self.surfaces():
            if nv < 3 or ni < 3:
                continue
            sh = self.names[shader] if 0 <= shader < len(self.names) else ""
            if any(t in sh.lower() for t in SKIP_WORDS):
                continue
            key = base_of(sh)
            pts = []
            for k in range(nv):
                off = self.verts_off + (vfirst + k) * 44
                x, y, z = struct.unpack_from("<3f", d, off)
                tu, tv = struct.unpack_from("<2f", d, off + 12)
                pts.append((x, y, z, tu, tv))
            idx = struct.unpack_from("<%di" % ni, d, self.idx_off + ifirst * 4)
            for t in range(0, (ni // 3) * 3, 3):
                a, bb, c = idx[t], idx[t + 1], idx[t + 2]
                if max(a, bb, c) >= nv or min(a, bb, c) < 0:
                    continue
                out.append((key, (pts[a], pts[bb], pts[c]), si))
        return out


def cmd_analyze(mapdir):
    bsp_path = os.path.join(mapdir, "data", "model.bsp.raw.bytes")
    b = Bsp(bsp_path)
    print("[bsp] file=%s size=%d" % (bsp_path, os.path.getsize(bsp_path)))
    print("[bsp] verts=%d surfaces=%d planes=%d textures=%d"
          % (b.n_verts, b.n_surf, b.n_planes, len(b.names)))
    print("[bsp] bbox(min)=%.1f %.1f %.1f  bbox(max)=%.1f %.1f %.1f" % (b.vmin + b.vmax))
    print("[bsp] shaders:")
    for i, n in enumerate(b.names):
        print("   %2d  %s" % (i, n))

    # ---- 实体 ----
    ents = []
    cur = {}
    for line in b.entities.split("\n"):
        line = line.strip()
        if line == "{":
            cur = {}
        elif line == "}":
            if cur:
                ents.append(cur)
            cur = {}
        elif '"' in line:
            parts = line.split('"')
            if len(parts) >= 4:
                cur[parts[1]] = parts[3]
    print("[bsp] entities=%d" % len(ents))
    classes = collections.Counter(e.get("classname", "?") for e in ents)
    for k, v in classes.most_common():
        print("   %-32s x%d" % (k, v))
    print("[bsp] player spawns:")
    for e in ents:
        if "player_start" in e.get("classname", "") or "info_player" in e.get("classname", ""):
            print("   %-30s origin=(%s) angle=%s"
                  % (e.get("classname"), e.get("origin"), e.get("angle", e.get("yaw", ""))))

    # ---- 面统计 ----
    tris = b.triangles()
    print("[bsp] triangles=%d" % len(tris))
    per = collections.Counter(t[0] for t in tris)
    for k, v in per.most_common():
        print("   %-24s %6d tris" % (k, v))


def cmd_genmesh(mapdir, outpath, meshname):
    b = Bsp(os.path.join(mapdir, "data", "model.bsp.raw.bytes"))
    tris = b.triangles()

    # 按材质分组，顺序 = 首次出现顺序
    groups = collections.OrderedDict()
    for key, tri, si in tris:
        groups.setdefault(key, []).append(tri)

    verts = []
    uvs = []
    vmap = {}
    tris_by_mat = collections.OrderedDict()
    for gname, tl in groups.items():
        tl_out = []
        for tri in tl:
            li = []
            for (x, y, z, tu, tv) in tri:
                k = (x, y, z, round(tu, 5), round(tv, 5))
                slot = vmap.get(k)
                if slot is None:
                    slot = len(verts)
                    vmap[k] = slot
                    verts.append((-y, z, x))       # SsjjToUnity
                    uvs.append((tu, 1.0 - tv))
                li.append(slot)
            tl_out.append(tuple(li))
        tris_by_mat[gname] = tl_out

    if len(verts) > 65534:
        raise SystemExit("vertex count %d exceeds uint16 range" % len(verts))

    index_stream = []
    submeshes = []
    for gname, tl in tris_by_mat.items():
        first = len(index_stream)
        for (a, bb, c) in tl:
            index_stream.extend((a, bb, c))
        n = len(index_stream) - first
        if n == 0:
            continue
        xs = [verts[index_stream[i]][0] for i in range(first, first + n)]
        ys = [verts[index_stream[i]][1] for i in range(first, first + n)]
        zs = [verts[index_stream[i]][2] for i in range(first, first + n)]
        submeshes.append(dict(name=gname, firstByte=first * 2, indexCount=n,
                              center=((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2,
                                      (min(zs) + max(zs)) / 2),
                              extent=((max(xs) - min(xs)) / 2, (max(ys) - min(ys)) / 2,
                                      (max(zs) - min(zs)) / 2)))

    # ---- 顶点缓冲：pos(12) + normal(12) + uv0(8) = 32B ----
    STRIDE = 32
    acc = [[0.0, 0.0, 0.0] for _ in verts]
    for (a, bb, c) in index_stream_tris(index_stream):
        p0, p1, p2 = verts[a], verts[bb], verts[c]
        e1 = [p1[k] - p0[k] for k in range(3)]
        e2 = [p2[k] - p0[k] for k in range(3)]
        n = (e1[1] * e2[2] - e1[2] * e2[1],
             e1[2] * e2[0] - e1[0] * e2[2],
             e1[0] * e2[1] - e1[1] * e2[0])
        for vi in (a, bb, c):
            for k in range(3):
                acc[vi][k] += n[k]
    vb = bytearray()
    for i, p in enumerate(verts):
        nx, ny, nz = acc[i]
        ln = (nx * nx + ny * ny + nz * nz) ** 0.5 or 1.0
        vb += struct.pack("<3f", p[0], p[1], p[2])
        vb += struct.pack("<3f", nx / ln, ny / ln, nz / ln)
        vb += struct.pack("<2f", uvs[i][0], uvs[i][1])
    assert len(vb) == len(verts) * STRIDE

    xs = [p[0] for p in verts]
    ys = [p[1] for p in verts]
    zs = [p[2] for p in verts]
    bmin = (min(xs), min(ys), min(zs))
    bmax = (max(xs), max(ys), max(zs))

    CH = [(0, 3), (12, 3), (0, 0), (0, 0), (24, 2)] + [(0, 0)] * 9

    L_ = []
    A = L_.append
    A("%YAML 1.1")
    A("%TAG !u! tag:unity3d.com,2011:")
    A("--- !u!43 &4300000")
    A("Mesh:")
    A("  m_ObjectHideFlags: 0")
    A("  m_CorrespondingSourceObject: {fileID: 0}")
    A("  m_PrefabInstance: {fileID: 0}")
    A("  m_PrefabAsset: {fileID: 0}")
    A("  m_Name: " + meshname)
    A("  serializedVersion: 10")
    A("  m_SubMeshes:")
    for s in submeshes:
        A("  - serializedVersion: 2")
        A("    firstByte: %d" % s["firstByte"])
        A("    indexCount: %d" % s["indexCount"])
        A("    topology: 0")
        A("    baseVertex: 0")
        A("    firstVertex: 0")
        A("    vertexCount: %d" % len(verts))
        A("    localAABB:")
        A("      m_Center: {x: %.5f, y: %.5f, z: %.5f}" % s["center"])
        A("      m_Extent: {x: %.5f, y: %.5f, z: %.5f}" % s["extent"])
    A("  m_Shapes:")
    A("    vertices: []")
    A("    shapes: []")
    A("    channels: []")
    A("    fullWeights: []")
    A("  m_BindPose: []")
    A("  m_BoneNameHashes: ")
    A("  m_RootBoneNameHash: 0")
    A("  m_BonesAABB: []")
    A("  m_VariableBoneCountWeights:")
    A("    m_Data: ")
    A("  m_MeshCompression: 0")
    A("  m_IsReadable: 1")
    A("  m_KeepVertices: 1")
    A("  m_KeepIndices: 1")
    A("  m_IndexFormat: 0")
    A("  m_IndexBuffer: " + "".join("%02x%02x" % (i & 0xFF, (i >> 8) & 0xFF)
                                   for i in index_stream))
    A("  m_VertexData:")
    A("    serializedVersion: 3")
    A("    m_VertexCount: %d" % len(verts))
    A("    m_Channels:")
    for off, dim in CH:
        A("    - stream: 0")
        A("      offset: %d" % off)
        A("      format: 0")
        A("      dimension: %d" % dim)
    A("    m_DataSize: %d" % len(vb))
    A("    _typelessdata: " + vb.hex())
    A("  m_CompressedMesh:")
    for key in ("m_Vertices", "m_UV", "m_Normals", "m_Tangents"):
        A("    %s:" % key)
        A("      m_NumItems: 0")
        A("      m_Range: 0")
        A("      m_Start: 0")
        A("      m_Data: ")
        A("      m_BitSize: 0")
    for key in ("m_Weights", "m_NormalSigns", "m_TangentSigns"):
        A("    %s:" % key)
        A("      m_NumItems: 0")
        A("      m_Data: ")
        A("      m_BitSize: 0")
    A("    m_FloatColors:")
    A("      m_NumItems: 0")
    A("      m_Range: 0")
    A("      m_Start: 0")
    A("      m_Data: ")
    A("      m_BitSize: 0")
    A("    m_BoneIndices:")
    A("      m_NumItems: 0")
    A("      m_Data: ")
    A("      m_BitSize: 0")
    A("    m_Triangles:")
    A("      m_NumItems: 0")
    A("      m_Data: ")
    A("      m_BitSize: 0")
    A("    m_UVInfo: 0")
    A("  m_LocalAABB:")
    A("    m_Center: {x: %.5f, y: %.5f, z: %.5f}" % (
        (bmin[0] + bmax[0]) / 2, (bmin[1] + bmax[1]) / 2, (bmin[2] + bmax[2]) / 2))
    A("    m_Extent: {x: %.5f, y: %.5f, z: %.5f}" % (
        (bmax[0] - bmin[0]) / 2, (bmax[1] - bmin[1]) / 2, (bmax[2] - bmin[2]) / 2))
    A("  m_MeshUsageFlags: 0")
    A("  m_BakedConvexCollisionMesh: ")
    A("  m_BakedTriangleCollisionMesh: ")
    A("  m_MeshMetrics[0]: 1")
    A("  m_MeshMetrics[1]: 1")
    A("  m_MeshOptimizationFlags: 1")
    A("  m_StreamData:")
    A("    offset: 0")
    A("    size: 0")
    A("    path: ")

    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(L_) + "\n")

    order = [s["name"] for s in submeshes]
    print("[gen] submeshes=%d verts=%d tris=%d" % (len(submeshes), len(verts), len(index_stream) // 3))
    print("[gen] order=%s" % ",".join(order))
    print("[gen] bounds min=(%.1f,%.1f,%.1f) max=(%.1f,%.1f,%.1f)" % (bmin + bmax))
    print("[gen] fileMB=%.2f" % (os.path.getsize(outpath) / 1048576.0))
    # 供 BuildMap*.cs 使用的顺序常量
    print("[gen] ORDER_CS=%s" % ", ".join('"%s"' % o for o in order))
    return order


def index_stream_tris(flat):
    for i in range(0, len(flat), 3):
        yield flat[i], flat[i + 1], flat[i + 2]


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "analyze":
        cmd_analyze(sys.argv[2])
    elif cmd == "genmesh":
        cmd_genmesh(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        raise SystemExit("unknown cmd")
