# -*- coding: utf-8 -*-
"""按 SSJJ 官方 BspReader 语义，从 Q3 BSP 提取"原始"场景几何 + 顶点色。

与 bsp_common.py 的区别（这一版才是对的，勿混用）：
  1. 严格按 BaseSceneParse.isNoRenderTexture 剔除 noRender 面：
       * skytexture   -> 不渲染（天空盒由 SSJJ/Skybox2 单独出）
       * unitylighttexture -> 不渲染（这是光照代理面，不是贴图面）
       * noshader     -> 不渲染
     之前把 unitylighttexture 当普通贴图输出，占了 63% 的三角形 —— 这才是
     "贴图贴错 / 亮度不对" 的真正根因。
  2. drawVert = 44B：pos(12) uv(8) lightmapUv(8) normal(12) colorRGBA(4)
     color = b/255，是 BSP 里烘好的"原始亮度"，直接写进 Unity 顶点色。
  3. 索引相对 vfirst：vi = vfirst + IDX[ifirst + k]。
  4. 坐标 SsjjToUnity(x,y,z) = (-y, z, x)。
  5. 绕序：BspReader 是 setIndexAndSurfaceFaceIndex((numIdx-i-1)*2, ...) 反序，
     这里直接按 (i, i+1, i+2) 顺序输出，与官方反序等价于同向。
"""
import os
import struct
import sys
import collections

NO_RENDER_SUBSTR = ("skytexture", "unitylighttexture", "noshader")
# 天空盒专用贴图：BSP 里的天空面由 SSJJ/Skybox 的 6 面 quad 负责，这里一律不输出
NO_RENDER_EXACT = ("textures/skies/skybox", "textures/sky/skybox")
# Q3 内容/表面标记里明确"不参与渲染"的：clip / hint / trigger / caulk 等
Q3_NO_RENDER = ("common/clip", "common/weapclip", "common/hint", "common/trigger",
                "common/caulk", "common/areaportal", "common/clusterportal",
                "common/nodraw", "common/skip", "common/lightgrid")

COLORUNIT = 1.0 / 255.0


def base_of(sh):
    b = sh.replace("\\", "/").rsplit("/", 1)[-1]
    for ext in (".tga", ".jpg", ".png", ".dds"):
        if b.lower().endswith(ext):
            b = b[:-len(ext)]
    return b


class RawBsp(object):
    def __init__(self, path):
        self.path = path
        d = self.d = open(path, "rb").read()
        assert d[:4] == b"IBSP", "not Q3 BSP"
        self.ident = struct.unpack_from("<i", d, 0)[0]
        self.version = struct.unpack_from("<i", d, 4)[0]
        self.L = L = [struct.unpack_from("<ii", d, 8 + i * 8) for i in range(19)]

        # ---- shaders (lump1, 72B) ----
        to, tl = L[1]
        self.names = []
        self.surf_flags = []
        self.content_flags = []
        for i in range(0, tl, 72):
            nm = d[to + i:to + i + 64].split(b"\0")[0].decode("latin1")
            sf, cf = struct.unpack_from("<ii", d, to + i + 64)
            self.names.append(nm)
            self.surf_flags.append(sf)
            self.content_flags.append(cf)
        self.no_render = [self._is_no_render(i) for i in range(len(self.names))]

        self.vo = L[10][0]
        self.nv = L[10][1] // 44
        self.io = L[11][0]
        self.so, sl = L[13]
        self.ns = sl // 104
        # entities
        eo, el = L[0]
        self.entities = d[eo:eo + el].decode("latin1", "replace")

    def _is_no_render(self, si):
        nm = self.names[si]
        low = nm.lower().replace("\\", "/")
        if low in NO_RENDER_EXACT:
            return True
        # 任何以 "skies/skybox" 结尾的天空 shader 都不参与 BSP 几何渲染
        if low.endswith("/skybox") or low.endswith("/skybox1"):
            return True
        for k in NO_RENDER_SUBSTR:
            if k in low:
                return True
        for k in Q3_NO_RENDER:
            if k in low:
                return True
        return False

    # ---- 顶点 ----
    def vert(self, i):
        off = self.vo + i * 44
        x, y, z = struct.unpack_from("<3f", self.d, off)
        tu, tv = struct.unpack_from("<2f", self.d, off + 12)
        lu, lv = struct.unpack_from("<2f", self.d, off + 20)
        nx, ny, nz = struct.unpack_from("<3f", self.d, off + 32)
        r, g, b, a = struct.unpack_from("<4B", self.d, off + 40)
        return dict(p=(x, y, z), uv=(tu, tv), luv=(lu, lv), n=(nx, ny, nz),
                    color=(r, g, b, a))

    def surfaces(self):
        """yield dict(si, shader, vfirst, nv, ifirst, ni)"""
        for i in range(self.ns):
            b = self.so + i * 104
            shader, fog, stype = struct.unpack_from("<3i", self.d, b)
            vfirst, nv, ifirst, ni = struct.unpack_from("<4i", self.d, b + 12)
            yield dict(si=i, shader=shader, stype=stype, vfirst=vfirst,
                       nv=nv, ifirst=ifirst, ni=ni)

    def triangles(self, include_norender=False):
        """yield (mat_key, [v0,v1,v2], surf_index)；vN 为 dict（已套 SsjjToUnity）"""
        out = []
        for s in self.surfaces():
            if s["nv"] < 3 or s["ni"] < 3:
                continue
            sh = s["shader"]
            if not (0 <= sh < len(self.names)):
                continue
            if self.no_render[sh] and not include_norender:
                continue
            key = "skybox" if "skytexture" in self.names[sh].lower() else base_of(self.names[sh])
            pts = []
            for k in range(s["nv"]):
                v = self.vert(s["vfirst"] + k)
                x, y, z = v["p"]
                v["u"] = (-y, z, x)                    # SsjjToUnity
                pts.append(v)
            idx = struct.unpack_from("<%di" % s["ni"], self.d, self.io + s["ifirst"] * 4)
            for t in range(0, (s["ni"] // 3) * 3, 3):
                a, b2, c = idx[t], idx[t + 1], idx[t + 2]
                if max(a, b2, c) >= s["nv"] or min(a, b2, c) < 0:
                    continue
                out.append((key, (pts[a], pts[b2], pts[c]), s["si"]))
        return out

    def bbox(self):
        d = self.d
        xs, ys, zs = [], [], []
        for i in range(self.nv):
            x, y, z = struct.unpack_from("<3f", d, self.vo + i * 44)
            xs.append(x); ys.append(y); zs.append(z)
        return (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs))


def cmd_analyze(mapdir):
    b = RawBsp(os.path.join(mapdir, "data", "model.bsp.raw.bytes"))
    print("[raw] version=%d verts=%d surfaces=%d shaders=%d"
          % (b.version, b.nv, b.ns, len(b.names)))
    print("[raw] bbox=%s %s" % b.bbox())
    print("\n[raw] shader 分类（noRender 的按官方语义不输出几何）:")
    tris_all = b.triangles(include_norender=True)
    cnt = collections.Counter(t[0] for t in tris_all)
    nr_keys = set()
    for i, nm in enumerate(b.names):
        k = "skybox" if "skytexture" in nm.lower() else base_of(nm)
        if b.no_render[i]:
            nr_keys.add(k)
    for k, v in cnt.most_common():
        print("   %-24s %6d tris   %s" % (k, v, "NO-RENDER" if k in nr_keys else "render"))
    kept = b.triangles()
    print("\n[raw] 渲染三角形=%d / 总=%d" % (len(kept), len(tris_all)))
    vc = collections.defaultdict(set)
    for key, tri, si in kept:
        for p in tri:
            vc[key].add(p["color"])
    print("\n[raw] 各材质顶点色（原始亮度 0..255）:")
    for k, s in vc.items():
        vals = sorted(s)
        print("   %-24s colors=%d  sample=%s" % (k, len(s), vals[:4]))


def cmd_genmesh(mapdir, outpath, meshname):
    b = RawBsp(os.path.join(mapdir, "data", "model.bsp.raw.bytes"))
    tris = b.triangles()

    groups = collections.OrderedDict()
    for key, tri, si in tris:
        groups.setdefault(key, []).append(tri)

    verts, uvs, cols, norms = [], [], [], []
    luvs = []
    vmap = {}
    tris_by_mat = collections.OrderedDict()
    for gname, tl in groups.items():
        out = []
        for tri in tl:
            li = []
            for v in tri:
                # 顶点 key 必须含 lightmapUV，否则不同 lightmap 坐标的点会被错误合并
                k = (v["u"], round(v["uv"][0], 5), round(v["uv"][1], 5),
                     round(v["luv"][0], 5), round(v["luv"][1], 5), v["color"])
                slot = vmap.get(k)
                if slot is None:
                    slot = len(verts)
                    vmap[k] = slot
                    verts.append(v["u"])
                    uvs.append((v["uv"][0], 1.0 - v["uv"][1]))
                    # lightmap UV：BSP 里 V 轴习惯是自上而下，Unity 贴图是自下而上，
                    # 与漫反射 UV 一致地做 1-v 翻转
                    luvs.append((v["luv"][0], 1.0 - v["luv"][1]))
                    r, g, bb, _a = v["color"]
                    cols.append((r * COLORUNIT, g * COLORUNIT, bb * COLORUNIT, 1.0))
                    norms.append(None)
                li.append(slot)
            out.append(tuple(li))
        tris_by_mat[gname] = out

    if len(verts) > 65534:
        raise SystemExit("verts %d > 65534" % len(verts))

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

    # 法线：按三角形累加
    acc = [[0.0, 0.0, 0.0] for _ in verts]
    for (a, bb, c) in zip(index_stream[0::3], index_stream[1::3], index_stream[2::3]):
        p0, p1, p2 = verts[a], verts[bb], verts[c]
        e1 = [p1[k] - p0[k] for k in range(3)]
        e2 = [p2[k] - p0[k] for k in range(3)]
        n = (e1[1] * e2[2] - e1[2] * e2[1],
             e1[2] * e2[0] - e1[0] * e2[2],
             e1[0] * e2[1] - e1[1] * e2[0])
        for vi in (a, bb, c):
            for k in range(3):
                acc[vi][k] += n[k]

    # 顶点缓冲：pos(12) normal(12) color(16 float? 不)
    # Unity Color32 通道 dimension=4 format=0 -> 4 字节/分量？
    # 参考 _ref_mesh.asset：color 通道 offset 24 dimension 4 时 stride 增加 4 字节（Color32）。
    # 这里为稳妥保留 float4 颜色（stride 44）：pos12 + normal12 + color16 + uv8 = 48
    # 但 Unity 的 m_Channels 紧凑解释规则要求 offset 与 dimension 匹配，
    # 直接用 Color32(4B) 更贴近官方：pos12 + normal12 + color4 + uv8 = 36
    STRIDE = 44
    vb = bytearray()
    for i, p in enumerate(verts):
        nx, ny, nz = acc[i]
        ln = (nx * nx + ny * ny + nz * nz) ** 0.5 or 1.0
        vb += struct.pack("<3f", p[0], p[1], p[2])
        vb += struct.pack("<3f", nx / ln, ny / ln, nz / ln)
        r, g, bb, a = cols[i]
        vb += struct.pack("<4B",
                          max(0, min(255, int(r * 255 + 0.5))),
                          max(0, min(255, int(g * 255 + 0.5))),
                          max(0, min(255, int(bb * 255 + 0.5))),
                          255)
        vb += struct.pack("<2f", uvs[i][0], uvs[i][1])
        vb += struct.pack("<2f", luvs[i][0], luvs[i][1])
    assert len(vb) == len(verts) * STRIDE

    xs = [p[0] for p in verts]
    ys = [p[1] for p in verts]
    zs = [p[2] for p in verts]
    bmin = (min(xs), min(ys), min(zs))
    bmax = (max(xs), max(ys), max(zs))

    # 通道：0=vertex(3) 1=normal(3) 2=tangent 3=color(4,Color32) 4=uv0(2) 5=uv1(2)
    CH = [(0, 3), (12, 3), (0, 0), (24, 4), (28, 2), (36, 2)] + [(0, 0)] * 8

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
    print("[gen] submeshes=%d verts=%d tris=%d"
          % (len(submeshes), len(verts), len(index_stream) // 3))
    print("[gen] ORDER=%s" % ",".join(order))
    print("[gen] bounds min=(%.1f,%.1f,%.1f) max=(%.1f,%.1f,%.1f)" % (bmin + bmax))
    print("[gen] fileMB=%.2f" % (os.path.getsize(outpath) / 1048576.0))
    return order


if __name__ == "__main__":
    if sys.argv[1] == "analyze":
        cmd_analyze(sys.argv[2])
    elif sys.argv[1] == "genmesh":
        cmd_genmesh(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        raise SystemExit("unknown cmd")
