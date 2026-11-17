# -*- coding: utf-8 -*-
"""P5 第 1 步：把手模 + 枪合成为 TaCZ geo（骨骼来自手模 bindpose）。

坐标换算：
  原版视模型空间 = 厘米、Y 向前(-Y 为前)、Z 向上、相机在原点
  TaCZ/Bedrock 空间 = Y 向上、Z 向前(-Z 为前)、1 单位 = 1/16 格 = 6.25 cm
  映射： TZ_x = x,  TZ_y = z,  TZ_z = -y   （再把 cm ÷ 6.25 换成单位）

产物：mc-port/pack/ssjj/assets/ssjj/geo_models/gun/awm_fp_geo.json
"""
import json
import os

CM_PER_UNIT = 6.25
EYE_Z_CM = 150.0   # 视模型以地面为原点，眼睛约在 150 cm；TaCZ 以眼睛为原点

OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"
PACK = r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj"
GUN_GEO = os.path.join(PACK, "assets", "ssjj", "geo_models", "gun", "awm_legend_t_geo.json")
HAND_OBJ = os.path.join(OUT, "hand_man.obj")
HAND_BONES = os.path.join(OUT, "hand_bindpose.json")
DEST = os.path.join(PACK, "assets", "ssjj", "geo_models", "gun", "awm_fp_geo.json")


def parse_obj(path):
    v, vt, f = [], [], []
    for ln in open(path, encoding="utf-8"):
        if ln.startswith("v "):
            v.append([float(x) for x in ln.split()[1:4]])
        elif ln.startswith("vt "):
            vt.append([float(x) for x in ln.split()[1:3]])
        elif ln.startswith("f "):
            tri = []
            for t in ln.split()[1:4]:
                p = t.split("/")
                tri.append((int(p[0]) - 1, int(p[1]) - 1 if len(p) > 1 and p[1] else 0))
            f.append(tri)
    return v, vt, f


def to_tacz(p):
    # 原版视模型：-Y 为前、+Z 为up；TaCZ：-Z 为前、+Y 为up
    # TML 渲染时 Y 取反（FLIP_MODEL_Y），所以这里预先取负，最终才是「上为正」
    return [p[0] / CM_PER_UNIT, -(p[2] - EYE_Z_CM) / CM_PER_UNIT, p[1] / CM_PER_UNIT]


def main():
    hv, hvt, hf = parse_obj(HAND_OBJ)
    print("hand verts", len(hv), "faces", len(hf))

    hand_bones = json.load(open(HAND_BONES, encoding="utf-8"))
    # 只保留有 pivot 的骨骼，且父级必须存在
    names = {b["name"] for b in hand_bones if b.get("pivot")}
    bones = []
    for b in hand_bones:
        if not b.get("pivot") or not b.get("name"):
            continue
        nb = {"name": b["name"], "pivot": [round(v, 4) for v in to_tacz(b["pivot"])], "cubes": []}
        if b.get("parent") in names and b["parent"] != b["name"]:
            nb["parent"] = b["parent"]
        bones.append(nb)
    print("hand bones kept", len(bones))

    # 手模顶点 → TaCZ 空间
    hpos = [[round(c, 4) for c in to_tacz(p)] for p in hv]
    hu = [[round(u, 5), round(v, 5)] for u, v in hvt] if hvt else [[0.0, 0.0]] * len(hv)
    if len(hu) < len(hpos):
        hu += [[0.0, 0.0]] * (len(hpos) - len(hu))

    hand_mesh = {"normalized_uvs": False,
                 "positions": hpos,
                 "normals": [[0.0, 1.0, 0.0]] * len(hpos),
                 "uvs": hu,
                 "polys": [[[a[0], 0, a[0]], [b[0], 0, b[0]], [c[0], 0, c[0]]] for a, b, c in hf]}

    # 枪：直接复用已生成的枪 geo 顶点（已经在 TaCZ 单位空间），挂到手前方
    gun = json.load(open(GUN_GEO, encoding="utf-8"))
    gun_bones = [b for b in gun["minecraft:geometry"][0]["bones"] if b.get("poly_mesh")]
    gp = gun_bones[0]["poly_mesh"]
    # 枪当前 x -3..3 / y 1..8 / z -29..-2（单位），把它移到右手前方
    off = (1.5, 1.0, -6.0)   # 对到右手：手在 y≈5.3（取负后）/ z≈-12 单位
    gpos = [[round(p[0] + off[0], 4), round(p[1] + off[1], 4), round(p[2] + off[2], 4)]
            for p in gp["positions"]]
    gun_mesh = {"normalized_uvs": False,
                "positions": gpos,
                "normals": [[0.0, 1.0, 0.0]] * len(gpos),
                "uvs": gp["uvs"],
                "polys": gp["polys"]}

    # TaCZ 的第一人称取景依赖结构骨骼（camera/views/positioning/gun_pos）。
    # 缺了它们，第一人称整块不可见（第三人称仍能显示）。
    # camera 放原点 = 眼睛在模型原点，手模正好落在眼前 0.9~1.5 格。
    struct = [
        {"name": "root", "pivot": [0, 0, 0], "cubes": []},
        {"name": "positioning", "parent": "root", "pivot": [0, 0, 0], "cubes": []},
        {"name": "camera", "parent": "positioning", "pivot": [0, 0, 0], "cubes": []},
        {"name": "views", "parent": "positioning", "pivot": [0, 0, 0], "cubes": []},
        {"name": "iron_view", "parent": "views", "pivot": [0, 3.0, -10.0], "cubes": []},
        {"name": "idle_view", "parent": "views", "pivot": [0, 0, 0], "cubes": []},
        {"name": "gun_pos", "parent": "positioning", "pivot": [0, 0, 0], "cubes": []},
    ]
    for b in bones:
        if not b.get("parent"):
            b["parent"] = "gun_pos"
    bones = struct + bones

    bones.append({"name": "hand_mesh", "parent": "gun_pos", "pivot": [0, 0, 0], "cubes": []})
    bones[-1]["poly_mesh"] = hand_mesh
    bones.append({"name": "gun_mesh", "parent": "gun_pos", "pivot": [0, 0, 0]})
    bones[-1]["poly_mesh"] = gun_mesh

    # 双材质：TML 支持 meshy:materials，按骨骼名分配贴图
    geo = {"format_version": "1.12.0",
           "meshy:materials": {
               "hand_mesh": "ssjj:textures/gun/uv/hand_man.png",
               "gun_mesh": "ssjj:textures/gun/uv/awm_legend_t.png",
           },
           "minecraft:geometry": [{
               "description": {"identifier": "geometry.ssjj.awm_fp",
                               "texture_width": 512, "texture_height": 512,
                               "visible_bounds_width": 3, "visible_bounds_height": 2.5,
                               "visible_bounds_offset": [0, 0.25, 0]},
               "bones": bones}]}
    with open(DEST, "w", encoding="utf-8") as f:
        json.dump(geo, f, ensure_ascii=False)
    print("geo ->", DEST, os.path.getsize(DEST), "B")
    print("bones", len(bones), "| hand polys", len(hand_mesh["polys"]), "| gun polys", len(gun_mesh["polys"]))

    xs = [p[0] for p in hpos]; ys = [p[1] for p in hpos]; zs = [p[2] for p in hpos]
    print("hand in TaCZ: x %.1f..%.1f  y %.1f..%.1f  z %.1f..%.1f (单位)"
          % (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))


if __name__ == "__main__":
    main()
