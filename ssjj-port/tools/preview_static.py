# -*- coding: utf-8 -*-
"""静态 fp.glb 预览：顶点已在相机空间，直接投影光栅化。"""
import json, math, os, struct, sys
from PIL import Image
W, H = 720, 405
NEAR = 0.05
GLB = os.path.join(os.path.dirname(__file__), "..", "src", "main", "resources", "assets", "ssjjport", "fp", "fp.glb")

blob = open(os.path.abspath(GLB), "rb").read()
ln = struct.unpack_from("<I", blob, 12)[0]
g = json.loads(blob[20:20+ln].decode("utf-8"))
hdr = 20 + ln
clen, _ = struct.unpack_from("<II", blob, hdr)
binb = blob[hdr+8: hdr+8+clen]
acc, views = g["accessors"], g["bufferViews"]
def read(ai):
    a = acc[ai]; v = views[a["bufferView"]]
    off = v.get("byteOffset", 0) + a.get("byteOffset", 0)
    n = a["count"]; comps = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}[a["type"]]
    fmt = {5126: "f", 5123: "H", 5125: "I"}[a["componentType"]]
    return list(struct.unpack_from("<%d%s" % (n * comps, fmt), binb, off))
import io as _io
texs = []
for im in g.get("images", []):
    bv = im["bufferView"]
    d = binb[views[bv]["byteOffset"]: views[bv]["byteOffset"] + views[bv]["byteLength"]]
    texs.append(Image.open(_io.BytesIO(bytes(d))).convert("RGB"))

img = Image.new("RGB", (W, H), (26, 34, 26))
px = img.load()
zbuf = [[1e9] * W for _ in range(H)]
f = 1.0 / math.tan(math.radians(75) / 2)
aspect = W / float(H)
drawn = 0
for prim in g["meshes"][0]["primitives"]:
    mat_i = prim.get("material", 0)
    bct = (g.get("materials") or [{}])[mat_i].get("pbrMetallicRoughness", {}).get("baseColorTexture")
    tex = texs[bct["index"]] if bct and texs else None
    tw, th = tex.size if tex else (1, 1)
    P = read(prim["attributes"]["POSITION"])
    UV = read(prim["attributes"]["TEXCOORD_0"]) if "TEXCOORD_0" in prim["attributes"] else None
    I = read(prim["indices"])
    for t in range(0, len(I), 3):
        tri = []
        ok = True
        for i in (I[t], I[t+1], I[t+2]):
            x, y, z = P[i*3], P[i*3+1], P[i*3+2]
            if z > -NEAR:
                ok = False; break
            w = -z
            nx = (f / aspect) * x / w; ny = f * y / w
            tri.append((int((nx+1)*0.5*W), int((1-ny)*0.5*H), w))
        if not ok:
            continue
        (x0,y0,w0),(x1,y1,w1),(x2,y2,w2) = tri
        det = (y1-y2)*(x0-x2)+(x2-x1)*(y0-y2)
        if abs(det) < 1e-9: continue
        xs=[x0,x1,x2]; ys=[y0,y1,y2]
        for yy in range(max(0,min(ys)), min(H-1,max(ys))+1):
            for xx in range(max(0,min(xs)), min(W-1,max(xs))+1):
                w0n=((y1-y2)*(xx-x2)+(x2-x1)*(yy-y2))/det
                w1n=((y2-y0)*(xx-x2)+(x0-x2)*(yy-y2))/det
                w2n=1-w0n-w1n
                if w0n<-1e-6 or w1n<-1e-6 or w2n<-1e-6: continue
                z=w0n*w0+w1n*w1+w2n*w2
                if z>=zbuf[yy][xx]: continue
                zbuf[yy][xx]=z
                if UV and tex:
                    u=w0n*UV[I[t]*2]+w1n*UV[I[t+1]*2]+w2n*UV[I[t+2]*2]
                    v=w0n*UV[I[t]*2+1]+w1n*UV[I[t+1]*2+1]+w2n*UV[I[t+2]*2+1]
                    uu=min(tw-1,max(0,int(u*tw))); vv=min(th-1,max(0,int((1-v)*th)))
                    px[xx,yy]=tex.getpixel((uu,vvv if False else vv))
                else:
                    px[xx,yy]=(160,165,175)
        drawn += 1
out = os.path.abspath("notes/debug/static_fp.png")
img.save(out)
print("tris=%d -> %s" % (drawn, out))
