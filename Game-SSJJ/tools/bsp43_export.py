# -*- coding: utf-8 -*-
"""SSJJ map43 (Quake3 BSP) -> textured OBJ/MTL for Unity, using each surface's
OWN lightmap/uv basis.  No invented triplanar scales, no per-axis overrides.

Surface layout (104 bytes, verified on map43):
  0 shader(int) 4 fog 8 type
  12 vfirst 16 nverts 20 ifirst 24 nindices
  28 lmnum 32 lmx 36 lmy 40 lmsize 44 lmstart
  48 lightmapOrigin[3f]  60 lightmapVecs[0]  72 lightmapVecs[1]  84 normal[3f]
  96 patchWidth 100 patchHeight

drawVert = 44 bytes: pos[3f] uv[2f] lmUV[2f] normal[3f] color[4b]
"""
import os, struct, json, collections

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, "extracted", "maps", "map43")
BSP = os.path.join(SRC, "data", "model.bsp.raw.bytes")
TEX = os.path.join(SRC, "textures")
OUTDIR = os.path.join(ROOT, "Game-SSJJ", "Assets", "Bundles", "Map43", "BSP")
OUT = os.path.join(OUTDIR, "map43_bsp.obj")
MTL = os.path.join(OUTDIR, "map43_bsp.mtl")

# world units -> Unity units.  SSJJ inches, 1 tile per 128 world units is the
# conventional Q3 default texture scale (32 texels * 4).
UNIT = 1.0
TEX_SCALE = 1.0 / 128.0

SKIP = ("noshader", "common/clip", "common/weapclip", "sky", "nodraw", "trigger",
        "caulk", "hint", "areaportal", "clusterportal", "lava", "slime")

d = open(BSP, "rb").read()
assert d[:4] == b"IBSP"
L = [struct.unpack_from("<ii", d, 8 + i * 8) for i in range(17)]
TO, TL = L[1]
VO, VL = L[10]
IO, IL = L[11]
SO, SL = L[13]

names = []
for i in range(0, TL, 72):
    nm = d[TO + i:TO + i + 64].split(b"\0")[0].decode("latin1")
    if not nm:
        break
    names.append(nm)


def base_of(shader):
    b = shader.replace("\\", "/").rsplit("/", 1)[-1]
    for ext in (".tga", ".jpg", ".png", ".dds"):
        if b.lower().endswith(ext):
            b = b[:-len(ext)]
    return b


# material resolution: shader index -> png base name that actually exists
mats = {}
missing = collections.Counter()
for si, sh in enumerate(names):
    low = sh.lower()
    if any(t in low for t in SKIP):
        continue
    b = base_of(sh)
    if os.path.exists(os.path.join(TEX, b + ".png")):
        mats[si] = b
    else:
        missing[sh] += 1

nfaces = SL // 104
surfaces = []
for i in range(nfaces):
    b = SO + i * 104
    shader, fog, ftype = struct.unpack_from("<3i", d, b)
    vfirst, nv, ifirst, ni = struct.unpack_from("<4i", d, b + 12)
    lmo = struct.unpack_from("<3f", d, b + 48)
    lmv0 = struct.unpack_from("<3f", d, b + 60)
    lmv1 = struct.unpack_from("<3f", d, b + 72)
    norm = struct.unpack_from("<3f", d, b + 84)
    surfaces.append((shader, ftype, vfirst, nv, ifirst, ni, lmo, lmv0, lmv1, norm))

os.makedirs(OUTDIR, exist_ok=True)

# ---- write MTL (relative path back to the extracted texture folder we copy in) --
used = sorted({mats[s[0]] for s in surfaces if s[0] in mats})
with open(MTL, "w", encoding="utf-8", newline="\n") as f:
    for base in used:
        f.write("newmtl %s\n" % base)
        f.write("Ka 1 1 1\nKd 1 1 1\nKs 0.02 0.02 0.02\nNs 8\nillum 2\n")
        f.write("map_Kd ../Textures/%s.png\n\n" % base)

verts_out = []          # list of "x y z"
uv_out = []
groups = collections.OrderedDict()   # base -> list of "f a/a b/b c/c"
stats = collections.Counter()
tris = 0

for (shader, ftype, vfirst, nv, ifirst, ni, lmo, lmv0, lmv1, norm) in surfaces:
    if ftype != 1 or nv < 3 or ni < 3:
        stats["skip_patch" if ftype != 1 else "skip_degenerate"] += 1
        continue
    if shader not in mats:
        stats["skip_matslot"] += 1
        continue
    base = mats[shader]
    bucket = groups.setdefault(base, [])

    # vertex block start index in our global arrays
    vbase = len(verts_out) + 1
    lmoX, lmoY, lmoZ = lmo
    a0, a1, a2 = lmv0
    b0, b1, b2 = lmv1

    for k in range(nv):
        off = VO + (vfirst + k) * 44
        x, y, z, u, v = struct.unpack_from("<5f", d, off)
        # SSJJ world (inches, Z up) -> Unity via VectorCoordConverter: (-y, z, x)
        ux, uy, uz = -y * UNIT, z * UNIT, x * UNIT
        verts_out.append((ux, uy, uz))
        # BSP lightmap basis gives the true texture projection for this face.
        # uv = dot(p - origin, vec) * scale
        dx, dy, dz = x - lmoX, y - lmoY, z - lmoZ
        tu = (dx * a0 + dy * a1 + dz * a2) * TEX_SCALE
        tv = (dx * b0 + dy * b1 + dz * b2) * TEX_SCALE
        # Unity ObjImporter flips V; pre-flip so textures land right side up
        uv_out.append((tu, -tv))

    idx = struct.unpack_from("<%di" % ni, d, IO + ifirst * 4)
    for t in range(0, (ni // 3) * 3, 3):
        i0, i1, i2 = idx[t], idx[t + 1], idx[t + 2]
        # drop any tri that references a vertex outside this surface
        if not (0 <= i0 < nv and 0 <= i1 < nv and 0 <= i2 < nv):
            stats["bad_index"] += 1
            continue
        bucket.append("f %d/%d %d/%d %d/%d" % (
            vbase + i0, vbase + i0, vbase + i1, vbase + i1, vbase + i2, vbase + i2))
        tris += 1

with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    f.write("# map43 (twin towers) BSP export, %d surfaces\n" % nfaces)
    f.write("mtllib %s\n" % os.path.basename(MTL))
    for x, y, z in verts_out:
        f.write("v %.4f %.4f %.4f\n" % (x, y, z))
    for u, v in uv_out:
        f.write("vt %.6f %.6f\n" % (u, v))
    for base, lines in groups.items():
        f.write("g %s\nusemtl %s\n" % (base, base))
        f.write("\n".join(lines))
        f.write("\n")

# bounds
xs = [p[0] for p in verts_out] or [0]
ys = [p[1] for p in verts_out] or [0]
zs = [p[2] for p in verts_out] or [0]
print("[bsp43] faces=%d tris=%d verts=%d groups=%d" % (nfaces, tris, len(verts_out), len(groups)))
print("[bsp43] bounds x[%.1f,%.1f] y[%.1f,%.1f] z[%.1f,%.1f]"
      % (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))
print("[bsp43] groups:", dict((k, len(v)) for k, v in groups.items()))
print("[bsp43] stats:", dict(stats), "unmapped_tex:", dict(missing))
