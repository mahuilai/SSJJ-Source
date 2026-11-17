# -*- coding: utf-8 -*-
"""从 sjfp.json 导出静态 fp.glb（无蒙皮、无动画）。

三视图实证（notes/debug/proj_all.png）确认 sjfp 顶点轴语义：
  hand（"Unity XYZ"）: x=上下(±0.10)  y=左右(±0.91,双臂分居)  z=前后(0.98..1.50,前伸持枪)
  gun （"SSJJ view XYZ"): x=宽(±0.06) y=枪长(-0.80..0.41)    z=高(-0.22..0.10)

映射到 MC 相机空间（x右、y上、-z前），右手侧：
  hand: MC=(y, x, -z) × 0.01，只取原 y>0（右手）的三角形，z 加 0.60 让手落在 0.4~0.9m
  gun : MC=(x, z, -y) × 0.01，z 加 -0.85 使枪身从 0.45m 伸到 1.65m

bind pose 本身就是游戏第一人称的持枪姿势（Unity 导出即所见），无需动画/蒙皮。
"""
import json
import os
import struct

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json")
TEX_HAND = os.path.join(ROOT, r"ssjj-port\src\main\resources\assets\ssjjport\textures\fp\hand.png")
TEX_GUN = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.png")
OUT = os.path.join(ROOT, r"ssjj-port\src\main\resources\assets\ssjjport\fp\fp.glb")


def main():
    d = json.load(open(SRC, encoding="utf-8"))
    hand = next(m for m in d["meshes"] if m.get("name") == "hand")
    gun = next(m for m in d["meshes"] if m.get("name") == "gun")

    bin_blob = bytearray()
    views, accs = [], []

    def add(arr, comp, typ, count, target=34962, minmax=None):
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(struct.pack("<%d%s" % (len(arr), fmt_char(comp)), *arr))
        views.append({"buffer": 0, "byteOffset": off,
                      "byteLength": len(bin_blob) - off, "target": target})
        a = {"bufferView": len(views) - 1, "componentType": comp,
             "count": count, "type": typ}
        if minmax:
            a["min"], a["max"] = minmax
        accs.append(a)
        return len(accs) - 1

    def fmt_char(comp):
        return {5126: "f", 5123: "H", 5125: "I"}[comp]

    def add_bin(data):
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(data)
        views.append({"buffer": 0, "byteOffset": off, "byteLength": len(data)})
        return len(views) - 1

    images, textures, materials = [], [], []

    def emit_prim(mesh, transform, tex_path, name):
        pos_l = mesh["pos"]
        uv_l = mesh.get("uv") or []
        idx = [int(i) for i in mesh["idx"]]
        n = len(pos_l)

        def tx(p):
            return transform(p[0], p[1], p[2])

        if name == "hand":
            keep = [i for i in range(n) if pos_l[i][1] > 0]
            keepset = set(keep)
            remap = {old: new for new, old in enumerate(keep)}
            idx = [remap[i] for i in idx if i in keepset]
            pos = [c for i in keep for c in tx(pos_l[i])]
            uv = [c for i in keep for c in (uv_l[i] if uv_l else (0.0, 0.0))]
        else:
            pos = [c for p in pos_l for c in tx(p)]
            uv = [c for p in uv_l for c in p]
        if len(uv) != len(pos) // 3 * 2:
            uv = (uv + [0.0, 0.0] * (len(pos) // 3))[: len(pos) // 3 * 2]
        if max(idx) >= len(pos) // 3:
            raise SystemExit("%s 索引越界" % name)
        xs, ys, zs = pos[0::3], pos[1::3], pos[2::3]
        a_pos = add(pos, 5126, "VEC3", len(pos) // 3, 34962,
                    ([min(xs), min(ys), min(zs)], [max(xs), max(ys), max(zs)]))
        a_uv = add(uv, 5126, "VEC2", len(pos) // 3)
        a_i = add(idx, 5125, "SCALAR", len(idx), 34963)
        prim = {"attributes": {"POSITION": a_pos, "TEXCOORD_0": a_uv},
                "indices": a_i, "mode": 4}
        if os.path.isfile(tex_path):
            images.append({"bufferView": add_bin(open(tex_path, "rb").read()),
                           "mimeType": "image/png", "name": name})
            textures.append({"source": len(images) - 1})
            prim["material"] = len(materials)
            materials.append({"name": name, "doubleSided": True,
                              "pbrMetallicRoughness": {
                                  "baseColorTexture": {"index": len(textures) - 1},
                                  "metallicFactor": 0.0, "roughnessFactor": 0.85}})
        else:
            prim["material"] = len(materials)
            materials.append({"name": name, "doubleSided": True,
                              "pbrMetallicRoughness": {"metallicFactor": 0.0,
                                                       "roughnessFactor": 0.85}})
        prims.append(prim)
        zs2 = zs
        print("  %-5s verts=%d tris=%d bbox z[%.2f,%.2f]"
              % (name, len(pos) // 3, len(idx) // 3, min(zs2), max(zs2)))

    prims = []

    def hand_tx(x, y, z):
        # 手臂：z=150 是手掌端 → 拉到近处 -0.45；z=98 肩端留在 0.02（视野外）
        return (y * 0.01 - 0.35, x * 0.01 - 0.15, -z * 0.01 + 1.05)

    def gun_tx(x, y, z):
        # 枪：y=-80 是枪口 → 伸向远处 -1.15；y=+41 枪尾在 0.06
        return (x * 0.01, z * 0.01 - 0.18, y * 0.01 - 0.35)

    emit_prim(hand, hand_tx, TEX_HAND, "hand")
    emit_prim(gun, gun_tx, TEX_GUN, "gun")

    nodes = [{"name": "SSJJ_FP", "mesh": 0}]
    gltf = {
        "asset": {"version": "2.0", "generator": "sjfp2glb-static (hand+gun, right hand only)"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": nodes,
        "meshes": [{"name": "ssjj_fp", "primitives": prims}],
        "images": images,
        "textures": textures,
        "materials": materials,
        "accessors": accs,
        "bufferViews": views,
        "buffers": [{"byteLength": 0}],
    }
    js = json.dumps(gltf, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    while len(js) % 4:
        js += b" "
    while len(bin_blob) % 4:
        bin_blob.append(0)
    gltf["buffers"][0]["byteLength"] = len(bin_blob)
    js = json.dumps(gltf, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    while len(js) % 4:
        js += b" "
    total = 12 + 8 + len(js) + 8 + len(bin_blob)
    out = bytearray()
    out += b"glTF" + struct.pack("<II", 2, total)
    out += struct.pack("<II", len(js), 0x4E4F534A) + js
    out += struct.pack("<II", len(bin_blob), 0x004E4942) + bytes(bin_blob)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "wb").write(out)
    print("glb ->", OUT, len(out), "B  prims=%d images=%d" % (len(prims), len(images)))

    # 同一份数据再输出 .gltf + .bin（自研 ViewmodelPass 的加载器吃这个格式）
    gltf_ext = dict(gltf)
    gltf_ext["buffers"] = [{"uri": "fp.bin", "byteLength": len(bin_blob)}]
    out_gltf = os.path.join(os.path.dirname(OUT), "fp.gltf")
    out_bin = os.path.join(os.path.dirname(OUT), "fp.bin")
    open(out_gltf, "w", encoding="utf-8").write(json.dumps(gltf_ext, ensure_ascii=False, separators=(",", ":")))
    open(out_bin, "wb").write(bin_blob)
    print("gltf ->", out_gltf, os.path.getsize(out_gltf), "B / bin ->", out_bin, os.path.getsize(out_bin), "B")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
