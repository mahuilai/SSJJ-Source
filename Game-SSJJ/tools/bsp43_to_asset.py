# -*- coding: utf-8 -*-
"""Generate a Unity 2019.4 text-serialized Mesh .asset with N submeshes straight
from the map43 Quake3 BSP.  Bypasses Unity's OBJ importer, which collapses all
`usemtl` groups into a single submesh (root cause of every texture being wrong).

Layout mirrors Game-SSJJ-logs/mesh_ref.txt produced by Unity's own serializer:
  - index buffer is one continuous hex stream, 2 bytes (uint16) per index
  - firstByte is a byte offset into that stream
  - 14 vertex channels; `offset` is in BYTES from the start of a vertex
"""
import os, struct, json, collections

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, "extracted", "maps", "map43")
BSP = os.path.join(SRC, "data", "model.bsp.raw.bytes")
OUTDIR = os.path.join(ROOT, "Game-SSJJ", "Assets", "Bundles", "Map43", "BSP")
OUT = os.path.join(OUTDIR, "map43_bsp.asset")

TEX_SCALE = 1.0 / 128.0
SKIP = ("noshader", "common/clip", "common/weapclip", "sky", "nodraw", "trigger",
        "caulk", "hint", "areaportal", "clusterportal")

d = open(BSP, "rb").read()
assert d[:4] == b"IBSP"
L = [struct.unpack_from("<ii", d, 8 + i * 8) for i in range(17)]
TO, TL = L[1]
VO = L[10][0]
IO = L[11][0]
SO, SL = L[13]

names = []
for i in range(0, TL, 72):
    nm = d[TO + i:TO + i + 64].split(b"\0")[0].decode("latin1")
    if not nm:
        break
    names.append(nm)


def base_of(sh):
    b = sh.replace("\\", "/").rsplit("/", 1)[-1]
    for ext in (".tga", ".jpg", ".png", ".dds"):
        if b.lower().endswith(ext):
            b = b[:-len(ext)]
    return b


texdir = os.path.join(ROOT, "Game-SSJJ", "Assets", "Bundles", "Map43", "Textures")
mats = {}
for si, sh in enumerate(names):
    if any(t in sh.lower() for t in SKIP):
        continue
    b = base_of(sh)
    if os.path.exists(os.path.join(texdir, b + ".png")):
        mats[si] = b

# ---- collect geometry, grouped by material (order = first appearance) ----
groups = collections.OrderedDict()
all_tris = []          # (group, i0, i1, i2) in global vertex space
verts = []
uvs = []
vmap = {}

for i in range(SL // 104):
    b = SO + i * 104
    shader = struct.unpack_from("<i", d, b)[0]
    ftype = struct.unpack_from("<i", d, b + 8)[0]
    vfirst, nv, ifirst, ni = struct.unpack_from("<4i", d, b + 12)
    if ftype != 1 or nv < 3 or ni < 3 or shader not in mats:
        continue
    g = groups.setdefault(mats[shader], [])
    # drawVert 自带正确的 diffuse UV（值域约 ±130，单位已是"贴图重复次数"），
    # 直接使用，不要用 lightmapVecs 重新投影。
    # BSP 索引是"面内相对"，全局顶点号 = vfirst + idx。
    gidx = []
    for k in range(nv):
        off = VO + (vfirst + k) * 44
        x, y, z = struct.unpack_from("<3f", d, off)
        tu, tv = struct.unpack_from("<2f", d, off + 12)
        key = (vfirst + k, round(tu, 5), round(tv, 5))
        slot = vmap.get(key)
        if slot is None:
            slot = len(verts)
            vmap[key] = slot
            # VectorCoordConverter.SsjjToUnity(v) = (-v.y, v.z, v.x)
            verts.append((-y, z, x))
            uvs.append((tu, 1.0 - tv))
        gidx.append(slot)
    idx = struct.unpack_from("<%dI" % ni, d, IO + ifirst * 4)
    for t in range(0, (ni // 3) * 3, 3):
        a, bb, c = idx[t], idx[t + 1], idx[t + 2]
        if max(a, bb, c) >= nv:
            continue
        all_tris.append((mats[shader], gidx[a], gidx[bb], gidx[c]))

if len(verts) > 65534:
    raise SystemExit("vertex count %d exceeds uint16 index range" % len(verts))

# ---- build per-group triangle lists + one flat index stream ----
index_stream = []
submeshes = []
for gname, _ in groups.items():
    first = len(index_stream)
    n = 0
    for (gn, a, b, c) in all_tris:
        if gn != gname:
            continue
        index_stream.extend((a, b, c))
        n += 3
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

# ---- vertex buffer ----
# Unity 的 m_Channels 不按 offset 重排，而是按通道索引紧凑解释。
# 官方参考(_ref_mesh.asset)里 4 顶点 stride=32：pos(12) + normal(12) + uv0(8)。
# 所以只写 vertex / normal / uv0 三个通道，其余全部 dimension:0。
STRIDE = 32
vb = bytearray()
acc = [[0.0, 0.0, 0.0] for _ in verts]
for (gn, a, b, c) in all_tris:
    p0, p1, p2 = verts[a], verts[b], verts[c]
    e1 = [p1[k] - p0[k] for k in range(3)]
    e2 = [p2[k] - p0[k] for k in range(3)]
    n = (e1[1] * e2[2] - e1[2] * e2[1],
         e1[2] * e2[0] - e1[0] * e2[2],
         e1[0] * e2[1] - e1[1] * e2[0])
    for vi in (a, b, c):
        for k in range(3):
            acc[vi][k] += n[k]
for i, p in enumerate(verts):
    nx, ny, nz = acc[i]
    ln = (nx * nx + ny * ny + nz * nz) ** 0.5 or 1.0
    vb += struct.pack("<3f", p[0], p[1], p[2])
    vb += struct.pack("<3f", nx / ln, ny / ln, nz / ln)
    vb += struct.pack("<2f", uvs[i][0], uvs[i][1])
assert len(vb) == len(verts) * STRIDE, (len(vb), len(verts) * STRIDE)

xs = [p[0] for p in verts]
ys = [p[1] for p in verts]
zs = [p[2] for p in verts]
bmin = (min(xs), min(ys), min(zs))
bmax = (max(xs), max(ys), max(zs))

CH = []
CH.append((0, 3))    # 0 vertex   offset 0
CH.append((12, 3))   # 1 normal   offset 12
CH.append((0, 0))    # 2 tangent  (none)
CH.append((0, 0))    # 3 color    (none)
CH.append((24, 2))   # 4 uv0      offset 24
for _ in range(9):
    CH.append((0, 0))    # uv1..7 / blend

L_ = []
L_.append("%YAML 1.1")
L_.append("%TAG !u! tag:unity3d.com,2011:")
L_.append("--- !u!43 &4300000")
L_.append("Mesh:")
L_.append("  m_ObjectHideFlags: 0")
L_.append("  m_CorrespondingSourceObject: {fileID: 0}")
L_.append("  m_PrefabInstance: {fileID: 0}")
L_.append("  m_PrefabAsset: {fileID: 0}")
L_.append("  m_Name: map43_bsp")
L_.append("  serializedVersion: 10")
L_.append("  m_SubMeshes:")
for s in submeshes:
    L_.append("  - serializedVersion: 2")
    L_.append("    firstByte: %d" % s["firstByte"])
    L_.append("    indexCount: %d" % s["indexCount"])
    L_.append("    topology: 0")
    L_.append("    baseVertex: 0")
    L_.append("    firstVertex: 0")
    L_.append("    vertexCount: %d" % len(verts))
    L_.append("    localAABB:")
    L_.append("      m_Center: {x: %.5f, y: %.5f, z: %.5f}" % s["center"])
    L_.append("      m_Extent: {x: %.5f, y: %.5f, z: %.5f}" % s["extent"])
L_.append("  m_Shapes:")
L_.append("    vertices: []")
L_.append("    shapes: []")
L_.append("    channels: []")
L_.append("    fullWeights: []")
L_.append("  m_BindPose: []")
L_.append("  m_BoneNameHashes: ")
L_.append("  m_RootBoneNameHash: 0")
L_.append("  m_BonesAABB: []")
L_.append("  m_VariableBoneCountWeights:")
L_.append("    m_Data: ")
L_.append("  m_MeshCompression: 0")
L_.append("  m_IsReadable: 1")
L_.append("  m_KeepVertices: 1")
L_.append("  m_KeepIndices: 1")
L_.append("  m_IndexFormat: 0")
# 索引流：每个索引 2 字节小端，紧凑连续，无分隔
ib_hex = "".join("%02x%02x" % (i & 0xFF, (i >> 8) & 0xFF) for i in index_stream)
L_.append("  m_IndexBuffer: " + ib_hex)
L_.append("  m_VertexData:")
L_.append("    serializedVersion: 3")
L_.append("    m_VertexCount: %d" % len(verts))
L_.append("    m_Channels:")
for off, dim in CH:
    L_.append("    - stream: 0")
    L_.append("      offset: %d" % off)
    L_.append("      format: 0")
    L_.append("      dimension: %d" % dim)
L_.append("    m_DataSize: %d" % len(vb))
L_.append("    _typelessdata: " + vb.hex())
L_.append("  m_CompressedMesh:")
for key in ("m_Vertices", "m_UV", "m_Normals", "m_Tangents"):
    L_.append("    %s:" % key)
    L_.append("      m_NumItems: 0")
    L_.append("      m_Range: 0")
    L_.append("      m_Start: 0")
    L_.append("      m_Data: ")
    L_.append("      m_BitSize: 0")
for key in ("m_Weights", "m_NormalSigns", "m_TangentSigns"):
    L_.append("    %s:" % key)
    L_.append("      m_NumItems: 0")
    L_.append("      m_Data: ")
    L_.append("      m_BitSize: 0")
L_.append("    m_FloatColors:")
L_.append("      m_NumItems: 0")
L_.append("      m_Range: 0")
L_.append("      m_Start: 0")
L_.append("      m_Data: ")
L_.append("      m_BitSize: 0")
L_.append("    m_BoneIndices:")
L_.append("      m_NumItems: 0")
L_.append("      m_Data: ")
L_.append("      m_BitSize: 0")
L_.append("    m_Triangles:")
L_.append("      m_NumItems: 0")
L_.append("      m_Data: ")
L_.append("      m_BitSize: 0")
L_.append("    m_UVInfo: 0")
L_.append("  m_LocalAABB:")
L_.append("    m_Center: {x: %.5f, y: %.5f, z: %.5f}" % (
    (bmin[0] + bmax[0]) / 2, (bmin[1] + bmax[1]) / 2, (bmin[2] + bmax[2]) / 2))
L_.append("    m_Extent: {x: %.5f, y: %.5f, z: %.5f}" % (
    (bmax[0] - bmin[0]) / 2, (bmax[1] - bmin[1]) / 2, (bmax[2] - bmin[2]) / 2))
L_.append("  m_MeshUsageFlags: 0")
L_.append("  m_BakedConvexCollisionMesh: ")
L_.append("  m_BakedTriangleCollisionMesh: ")
L_.append("  m_MeshMetrics[0]: 1")
L_.append("  m_MeshMetrics[1]: 1")
L_.append("  m_MeshOptimizationFlags: 1")
L_.append("  m_StreamData:")
L_.append("    offset: 0")
L_.append("    size: 0")
L_.append("    path: ")

os.makedirs(OUTDIR, exist_ok=True)
with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(L_) + "\n")

meta = os.path.join(OUTDIR, "map43_bsp.asset.meta")
if not os.path.exists(meta):
    with open(meta, "w", encoding="utf-8", newline="\n") as f:
        f.write("fileFormatVersion: 2\nguid: 43a5c9d1e0b74a8c9f3d2b6e1a7c4d50\n")

print("[gen] submeshes=%d verts=%d tris=%d" % (len(submeshes), len(verts), len(index_stream) // 3))
print("[gen] order:", [s["name"] for s in submeshes])
print("[gen] indexbytes=%d vbytes=%d fileMB=%.2f"
      % (len(index_stream) * 2, len(vb), os.path.getsize(OUT) / 1048576))
print("[gen] bounds min=(%.1f,%.1f,%.1f) max=(%.1f,%.1f,%.1f)" % (bmin + bmax))
