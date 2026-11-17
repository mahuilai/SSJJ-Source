# -*- coding: utf-8 -*-
"""从 mc-port 的 awm.sjfp.json 提取枪模，导出为独立 glTF（rigid，无蒙皮）。

为什么单独导：hand（PlayerSkin，z 98..150）和 gun（z -22..10）在 sjfp.json 里
标记为两套空间（"hand": "Unity XYZ" / "gun": "SSJJ view XYZ"），枪的顶点已经
烘焙到相机相对空间。所以枪不能和手共用同一个变换，必须给一套自己的。

输出：
  src/main/resources/assets/ssjjport/fp/gun.gltf
  src/main/resources/assets/ssjjport/fp/gun.bin
  src/main/resources/assets/ssjjport/textures/fp/gun.png
"""
import json
import os
import struct
import shutil

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json")
SRC_TEX = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.png")
OUT_DIR = os.path.join(ROOT, r"ssjj-port\src\main\resources\assets\ssjjport\fp")
TEX_DIR = os.path.join(ROOT, r"ssjj-port\src\main\resources\assets\ssjjport\textures\fp")

OUT_GLTF = os.path.join(OUT_DIR, "gun.gltf")
OUT_BIN = os.path.join(OUT_DIR, "gun.bin")
OUT_TEX = os.path.join(TEX_DIR, "gun.png")


def main():
    d = json.load(open(SRC, encoding="utf-8"))
    gun = next(m for m in d["meshes"] if m.get("name") == "gun")
    pos_lists = gun["pos"]
    uv_lists = gun.get("uv") or []
    idx = gun["idx"]
    n = len(pos_lists)

    pos = [c for p in pos_lists for c in p]
    uv = [c for p in uv_lists for c in p] if uv_lists else [0.0, 0.0] * n
    if len(uv) != n * 2:
        uv = (uv + [0.0, 0.0] * n)[: n * 2]
    idx = [int(i) for i in idx]
    if max(idx) >= n:
        raise SystemExit("索引越界: max=%d n=%d" % (max(idx), n))

    xs = pos[0::3]
    ys = pos[1::3]
    zs = pos[2::3]
    print("gun verts=%d tris=%d  bbox x[%.1f,%.1f] y[%.1f,%.1f] z[%.1f,%.1f]"
          % (n, len(idx) // 3, min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))

    bin_blob = bytearray()

    def add(arr, comp, typ, count, target, fmt, minmax=None):
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(struct.pack("<" + fmt * len(arr), *arr))
        views.append({"buffer": 0, "byteOffset": off,
                      "byteLength": len(bin_blob) - off, "target": target})
        acc = {"bufferView": len(views) - 1, "componentType": comp,
               "count": count, "type": typ}
        if minmax:
            acc["min"], acc["max"] = minmax
        accessors.append(acc)
        return len(accessors) - 1

    views, accessors = [], []
    a_pos = add(pos, 5126, "VEC3", n, 34962, "f",
                ([min(xs), min(ys), min(zs)], [max(xs), max(ys), max(zs)]))
    a_uv = add(uv, 5126, "VEC2", n, 34962, "f")
    a_idx = add(idx, 5125, "SCALAR", len(idx), 34963, "I")

    gltf = {
        "asset": {"version": "2.0", "generator": "sjfp2gltf (gun only)"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": [{"name": "SSJJ_Gun", "mesh": 0}],
        "meshes": [{"name": "gun", "primitives": [{
            "attributes": {"POSITION": a_pos, "TEXCOORD_0": a_uv},
            "indices": a_idx, "material": 0, "mode": 4}]}],
        "materials": [{"name": "gun", "doubleSided": True,
                       "pbrMetallicRoughness": {"metallicFactor": 0.0, "roughnessFactor": 0.8}}],
        "accessors": accessors,
        "bufferViews": views,
        "buffers": [{"uri": "gun.bin", "byteLength": len(bin_blob)}],
    }

    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(TEX_DIR, exist_ok=True)
    open(OUT_BIN, "wb").write(bin_blob)
    json.dump(gltf, open(OUT_GLTF, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    if os.path.isfile(SRC_TEX):
        shutil.copy2(SRC_TEX, OUT_TEX)
        print("tex ->", OUT_TEX, os.path.getsize(OUT_TEX), "B")
    else:
        print("WARN: 找不到枪贴图", SRC_TEX)
    print("gltf ->", OUT_GLTF, os.path.getsize(OUT_GLTF), "B")
    print("bin  ->", OUT_BIN, os.path.getsize(OUT_BIN), "B")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
