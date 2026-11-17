# -*- coding: utf-8 -*-
"""P4: OBJ -> TML poly_mesh geometry JSON + 最小 TaCZ 枪包骨架（v2）。

v2 修正（21:33 实机反馈）:
  1. 枪的长轴是 Unity **X**（枪身 x -80..+67），枪口在 -X，不是 Z。
     Bedrock 枪口朝 -Z，所以映射 (x,y,z)_unity -> (z, -y, x)：
       x_b = (z_u - cz) * S     侧向
       y_b = -(y_u - cy) * S    上（TML 渲染还会取负，故预取负）
       z_b = (x_u - cx) * S     前（-X 枪口 -> -Z 枪口）
  2. 手模 PlayerSkin 在 z 98..149，与枪身不在同一坐标系（相机空间的手网格），
     默认剔除；TaCZ 自带手模。
  3. 面法线可能朝内导致全黑：按「面法线 · 面中心方向」自动判定，多数朝内则翻转绕序。
  4. 补 TaCZ 标准骨架 positioning / thirdperson_hand / ground / fixed / gun_pos / muzzle_flash。

TML 渲染约定（源码实证）: x=(px-pivot)/16, y=-(py-pivot)/16, z=(pz-pivot)/16
"""
import argparse
import collections
import json
import math
import os
import shutil

ROOT = r"D:\逆向\SSJJ双塔惊魂"
OUT = os.path.join(ROOT, "mc-port", "out")
PACK = os.path.join(ROOT, "mc-port", "pack", "ssjj")
OBJ = os.path.join(OUT, "mesh", "awm_legend_t.obj")
NAMESPACE = "ssjj"
GUN = "awm_legend_t"

# [OFFLINE] 该 bundle 里塞了 3 套变体网格：p1_xm(2640面, 龙纹矛形主体) /
# p3_xm(1636) / d_xm(980)。全合进来会得到「三把枪重叠」。只保留 p1_xm。
BODY_PARTS = ("p1_xm",)
# PlayerSkin=相机空间手模；p3_xm/d_xm=另外两套变体，合进来会重叠成三把枪
# PlayerSkin=相机空间手模；p3_xm/d_xm=另两套变体（会重叠成三把枪）；
# Plane*/glow*/liuti*/saoguang*/jian*/liuguang* = 枪口火焰/扫光/流体等特效面片，
# 它们靠原版 shader 做透明混合，TaCZ 不认，塞进来就是「一张平面展开贴图」。
EXCLUDE_DEFAULT = ("PlayerSkin", "p3_xm", "d_xm",
                   "Plane001", "Plane001_1", "Plane002", "Plane002_1", "Plane002_2",
                   "Plane003", "Plane003_1", "Plane003_2",
                   "glow_3", "glow_7", "liuti_3", "liuti01_4",
                   "saoguang_6", "liuguang01_5", "jian_2", "jianyu_1")


def find_main_texture():
    man = json.load(open(os.path.join(OUT, "asset_manifest.json"), encoding="utf-8"))
    cands = [t for t in man.get("textures", [])
             if t.get("name", "").startswith(GUN)
             and t.get("width") == 512 and t.get("height") == 512]
    if not cands:
        raise RuntimeError("512x512 main texture not found")
    return os.path.join(OUT, "textures", cands[0]["file"]), cands[0]["file"]


def parse_obj(path):
    groups = []
    cur = None
    for ln in open(path, "r", encoding="utf-8"):
        if ln.startswith("o "):
            cur = {"name": ln[2:].strip(), "v": [], "vt": [], "vn": [], "f": []}
            groups.append(cur)
        elif ln.startswith("v ") and cur is not None:
            cur["v"].append([float(x) for x in ln.split()[1:4]])
        elif ln.startswith("vt ") and cur is not None:
            cur["vt"].append([float(x) for x in ln.split()[1:3]])
        elif ln.startswith("vn ") and cur is not None:
            cur["vn"].append([float(x) for x in ln.split()[1:4]])
        elif ln.startswith("f ") and cur is not None:
            tri = []
            for tok in ln.split()[1:4]:
                p = tok.split("/")
                tri.append([int(p[0]), int(p[2]) if len(p) > 2 else int(p[0]),
                            int(p[1]) if len(p) > 1 else int(p[0])])
            cur["f"].append(tri)
    return groups


def bbox(vs):
    mn = [min(v[i] for v in vs) for i in range(3)]
    mx = [max(v[i] for v in vs) for i in range(3)]
    return mn, mx


def face_normal(a, b, c):
    u = [b[i] - a[i] for i in range(3)]
    v = [c[i] - a[i] for i in range(3)]
    n = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]]
    ln = math.sqrt(sum(x * x for x in n)) or 1.0
    return [x / ln for x in n]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--target-blocks", type=float, default=1.25)
    ap.add_argument("--exclude", default=",".join(EXCLUDE_DEFAULT))
    ap.add_argument("--keep-hands", action="store_true")
    ap.add_argument("--no-auto-winding", action="store_true")
    ap.add_argument("--span", type=float, default=42.0,
                    help="枪身在模型空间的长度（Bedrock 单位，16=1格）。默认 42≈2.6格")
    ap.add_argument("--z-offset", type=float, default=0.0,
                    help="枪口在模型空间的 z（越负越靠前）。默认 -38，与默认 AWP 的 -37 对齐")
    ap.add_argument("--fit-awp", action="store_true", default=True,
                    help="把枪身贴合默认狙击枪 AWP 的包围盒（默认开启）")
    ap.add_argument("--no-fit-awp", dest="fit_awp", action="store_false")
    ap.add_argument("--yaw", type=float, default=0.0, help="持枪偏航角（度，正=枪口向左）")
    ap.add_argument("--pitch", type=float, default=0.0, help="俯仰角（度，正=枪口上抬）")
    ap.add_argument("--roll", type=float, default=0.0, help="横滚角（度）")
    ap.add_argument("--scale", type=float, default=0.28,
                    help="fit 之后再做一次整体缩放（第一人称视模型约 1 格长，世界模型 63 单位≈4 格）")
    ap.add_argument("--x-offset", type=float, default=0.0,
                    help="左手/右手偏移（模型空间单位，16=1格）。正值=往右")
    ap.add_argument("--y-offset", type=float, default=0.0,
                    help="高度偏移（模型空间单位）。负值=往下")
    args = ap.parse_args()

    excl = set() if args.keep_hands else {x.strip() for x in args.exclude.split(",") if x.strip()}
    # 注意：OBJ 的 f 索引是按「全部原始组」的顶点顺序编号的。
    # 即使某组被排除，vbase 也必须照样累加，否则后续组索引全部错位。
    all_groups = parse_obj(OBJ)
    body = [g for g in all_groups if g["name"] in BODY_PARTS]
    body_v = [v for g in body for v in g["v"]]
    mn, mx = bbox(body_v)
    cx, cy, cz = [(mn[i] + mx[i]) / 2 for i in range(3)]
    body_len = max(mx[0] - mn[0], mx[1] - mn[1], mx[2] - mn[2])
    # 对齐 TaCZ 默认狙击枪（ai_awp_geo）的模型空间：
    #   枪口 z=-35.225、枪托约 +20、枪身中心 y≈7.68651
    # 这样第一人称相机在原点时枪在前方而不是穿过相机；第三人称手部骨骼也能对上。
    # [FIT-AWP] 把枪身等比贴合到默认狙击枪 ai_awp_geo 的包围盒：
    #   AWP cubes bbox x -10.2..10.3 / y 0.6..20.0 / z -37.2..26.2
    # 同一套骨架 + 同一套动画下，位置/大小应当与原版 AWP 一致，
    # 比手工猜 z-offset 可靠（之前 -48 把枪顶到相机脸上就是这个原因）。
    AWP_BBOX = {"x": (-10.2, 10.3), "y": (0.6, 20.0), "z": (-37.2, 26.2)}

    def fit_awp():
        span_awp = AWP_BBOX["z"][1] - AWP_BBOX["z"][0]      # 63.4
        k = span_awp / body_len                              # 长轴等比
        ax = sum(AWP_BBOX["x"]) / 2
        ay = sum(AWP_BBOX["y"]) / 2
        az = sum(AWP_BBOX["z"]) / 2
        return k, ax, ay, az, span_awp

    if args.fit_awp:
        S, AX, AY, AZ, SPAN_Z = fit_awp()
        MUZZLE_Z = AZ - SPAN_Z / 2
        MUZZLE_Y = AY
        print("fit-awp: scale=%.4f center=(%.2f,%.2f,%.2f) span=%.1f" % (S, AX, AY, AZ, SPAN_Z))
    else:
        MUZZLE_Z = args.z_offset
        MUZZLE_Y = 7.68651
        SPAN_Z = args.span
        AX, AY = 0.0, 0.0
        S = SPAN_Z / body_len

    # TML 的 PolyMesh 已固定 FLIP_MODEL_Y=true（bakedY = -(pos[1]-pivotY)/16），
    # 这里**不能**再预取负，否则 Y 翻两次 -> 枪自身上下颠倒（21:49 实机确认）。
    if args.fit_awp:
        K2 = args.scale          # 视模型缩放（世界模型 63 单位太长，第一人称要缩）
        CX0, CY0, CZ0 = AX, AY, AZ
        # [POSE] 第一人称持枪姿态：绕枪托附近的支点做 yaw/pitch/roll，
        # 否则枪的长度轴正好沿视线，屏幕上只剩一条竖条（只能看到枪托端面）。
        import math as _m
        _yaw, _pitch, _roll = _m.radians(args.yaw), _m.radians(args.pitch), _m.radians(args.roll)

        def _rot(p, piv):
            x, y, z = p[0] - piv[0], p[1] - piv[1], p[2] - piv[2]
            # roll (Z), pitch (X), yaw (Y)
            cy_, sy_ = _m.cos(_roll), _m.sin(_roll)
            x, y = x * cy_ - y * sy_, x * sy_ + y * cy_
            cp, sp = _m.cos(_pitch), _m.sin(_pitch)
            y, z = y * cp - z * sp, y * sp + z * cp
            cy2, sy2 = _m.cos(_yaw), _m.sin(_yaw)
            x, z = x * cy2 + z * sy2, -x * sy2 + z * cy2
            return [x + piv[0], y + piv[1], z + piv[2]]

        PIVOT = [args.x_offset + 1.0, 4.0, -4.0]

        def remap(v):
            x = ((v[2] - cz) * S + AX - CX0) * K2 + CX0 + args.x_offset
            y = ((v[1] - cy) * S + AY - CY0) * K2 + CY0 + args.y_offset
            z = ((v[0] - cx) * S + AZ - CZ0) * K2 + CZ0 + args.z_offset
            return app(_rot([x, y, z], PIVOT))
    else:
        def remap(v):
            return app([(v[2] - cz) * S + args.x_offset,
                        (v[1] - cy) * S + MUZZLE_Y + args.y_offset,
                        (v[0] - mn[0]) * S + MUZZLE_Z])

    bones, mmap = [], []
    name_count = collections.Counter()
    stats = {"bones": 0, "positions": 0, "polys": 0, "flipped_groups": 0,
             "skipped_groups": sorted(excl)}
    muzzle_z = 999.0
    vbase = 1
    for g in all_groups:
        nv, nn = len(g["v"]), len(g["vn"])
        if nv == 0:
            continue
        if g["name"] in excl:
            vbase += nv
            continue
        n = name_count[g["name"]]
        name_count[g["name"]] += 1
        bname = g["name"] if n == 0 else "%s_%d" % (g["name"], n)
        pos = [remap(v) for v in g["v"]]
        uvs = [[round(u, 6), round(v, 6)] for u, v in g["vt"]] or [[0.0, 0.0]] * nv
        nor = [[0.0, 1.0, 0.0]] * nv
        polys, bad = [], 0
        for tri in g["f"]:
            t = [[a - vbase, b - vbase, c - vbase] for a, b, c in tri]
            if any(not (0 <= x[0] < nv and 0 <= x[2] < len(uvs)) for x in t):
                bad += 1
                continue
            polys.append(t)
        # 自动外法线：面法线 · 面中心 若多数为负，翻转所有面的绕序
        if polys and not args.no_auto_winding:
            # 参考点必须用「该网格自身的中心」，不能用世界原点（模型中心在 z≈-7.6/y≈9.4）
            gc = [sum(p[i] for p in pos) / nv for i in range(3)]
            score = 0
            for t in polys:
                p0, p1, p2 = pos[t[0][0]], pos[t[1][0]], pos[t[2][0]]
                fn = face_normal(p0, p1, p2)
                ctr = [(p0[i] + p1[i] + p2[i]) / 3.0 for i in range(3)]
                vec = [ctr[i] - gc[i] for i in range(3)]
                score += 1 if sum(fn[i] * vec[i] for i in range(3)) > 0 else -1
            if score < 0:
                polys = [[t[0], t[2], t[1]] for t in polys]
                stats["flipped_groups"] += 1
        face = {"uv": [0, 0], "uv_size": [0.5, 0.5]}
        placeholder = {"origin": [0, 0, 0], "size": [0.5, 0.5, 0.5],
                       "uv": {k: dict(face) for k in ("north", "east", "south", "west", "up", "down")}}
        bones.append({"name": bname, "parent": "gun_pos", "pivot": [0, 0, 0],
                      "cubes": [placeholder],
                      "poly_mesh": {"normalized_uvs": True, "positions": pos,
                                    "normals": nor, "uvs": uvs, "polys": polys}})
        if g["name"] in BODY_PARTS:
            muzzle_z = min(muzzle_z, min(p[2] for p in pos))
        mmap.append({"bone": bname, "mesh": g["name"],
                     "class": "body" if g["name"] in BODY_PARTS else "fx",
                     "vertices": nv, "triangles": len(polys), "skipped_faces": bad})
        stats["bones"] += 1
        stats["positions"] += nv
        stats["polys"] += len(polys)
        vbase += nv

    if muzzle_z > 900:
        muzzle_z = min(p[2] for b in bones for p in b["poly_mesh"]["positions"])
    # 骨架照抄 ai_awp_geo 的定位链（TacZ 的第一/第三人称变换按这套 pivot 设计）
    # TaCZ 的第一人称取景不是靠 display 里的 transform，而是靠 geo 里的结构骨骼：
    #   camera / views(iron_view,idle_view) 决定相机与开镜锚点，
    #   positioning/ground/fixed/thirdperson_hand 决定各显示场景的落点，
    #   root/AWP/gun_and_righthand/AWP_body/gun_pos 是动画驱动的骨架链。
    # 我们原先只造了 root..gun_pos，缺 camera/views → 相机落在原点、陷进枪身，
    # 且默认 rifle 动画没有骨骼可驱动 → 第一人称看不到正常持枪位与动作。
    # 这里直接沿用默认狙击枪 ai_awp_geo 的结构骨骼（只有 pivot/rotation，无几何）。
    DEFAULT_GEO = os.path.join(
        os.environ.get("APPDATA", r"C:\Users\Mahuilai\AppData\Roaming"),
        "Polyfrost", "OneClient", ".minecraft", "tacz", "tacz_default_gun",
        "assets", "tacz", "geo_models", "gun", "ai_awp_geo.json")

    def load_skeleton():
        try:
            with open(DEFAULT_GEO, "r", encoding="utf-8") as fp:
                src = json.load(fp)["minecraft:geometry"][0]["bones"]
        except Exception as e:
            print("warn: 读默认骨架失败(%s)，使用内置最小骨架" % str(e)[:60])
            return None
        out, seen = [], set()
        for b in src:
            if b.get("cubes"):
                continue
            name = b.get("name")
            if not name or name in seen:
                continue
            seen.add(name)
            nb = {"name": name, "pivot": list(b.get("pivot") or [0, 0, 0])}
            if b.get("parent"):
                nb["parent"] = b["parent"]
            if b.get("rotation"):
                nb["rotation"] = list(b["rotation"])
            out.append(nb)
        return out

    skeleton = load_skeleton() or [
        {"name": "root", "pivot": [0, 4, 9], "cubes": []},
        {"name": "AWP", "parent": "root", "pivot": [0, 4, 9], "cubes": []},
        {"name": "gun_and_righthand", "parent": "AWP", "pivot": [0, 5, 8], "cubes": []},
        {"name": "AWP_body", "parent": "gun_and_righthand", "pivot": [0, 0, 0], "cubes": []},
        {"name": "gun_pos", "parent": "AWP_body", "pivot": [0, 0, 0], "cubes": []},
    ]
    # 保证枪口/抛壳锚点存在（默认骨架若自带 cube 会被上面过滤掉）
    have = {b["name"] for b in skeleton}
    if "gun_pos" not in have:
        skeleton.append({"name": "gun_pos", "parent": "AWP_body", "pivot": [0, 0, 0], "cubes": []})
        have.add("gun_pos")
    if "muzzle_flash" not in have:
        skeleton.append({"name": "muzzle_flash", "parent": "gun_pos",
                         "pivot": [0, MUZZLE_Y, MUZZLE_Z]})
        have.add("muzzle_flash")
    if "shell" not in have:
        skeleton.append({"name": "shell", "parent": "gun_pos",
                         "pivot": [-0.1875, 7.9375, 1.9375]})
        have.add("shell")
    print("skeleton bones: %d (camera/views: %s)" %
          (len(skeleton), "yes" if {"camera", "views"} <= have else "NO"))
    geo = {"format_version": "1.12.0",
           "minecraft:geometry": [{
               "description": {"identifier": "geometry.%s.%s" % (NAMESPACE, GUN),
                               "texture_width": 512, "texture_height": 512,
                               "visible_bounds_width": 3, "visible_bounds_height": 2.5,
                               "visible_bounds_offset": [0, 0.25, 0]},
               "bones": skeleton + bones}]}

    dirs = [os.path.join(PACK, "assets", NAMESPACE, "geo_models", "gun"),
            os.path.join(PACK, "assets", NAMESPACE, "textures", "gun", "uv"),
            os.path.join(PACK, "assets", NAMESPACE, "display", "guns")]
    for d in dirs:
        os.makedirs(d, exist_ok=True)
    geo_path = os.path.join(dirs[0], GUN + "_geo.json")
    with open(geo_path, "w", encoding="utf-8") as f:
        json.dump(geo, f, ensure_ascii=False, separators=(",", ":"))
    src_tex, src_name = find_main_texture()
    shutil.copy2(src_tex, os.path.join(dirs[1], GUN + ".png"))

    errs = []
    for b in bones:
        pm = b["poly_mesh"]
        if any(len(p) != 3 for p in pm["positions"]):
            errs.append(b["name"] + ": pos")
        if any(len(u) != 2 for u in pm["uvs"]):
            errs.append(b["name"] + ": uv")
        for t in pm["polys"]:
            if len(t) != 3 or any(len(x) != 3 for x in t):
                errs.append(b["name"] + ": poly")
                break
    json.load(open(geo_path, encoding="utf-8"))
    with open(os.path.join(OUT, "material_map.json"), "w", encoding="utf-8") as f:
        json.dump({"texture": "textures/gun/uv/%s.png" % GUN, "bones": mmap},
                  f, ensure_ascii=False, indent=1)
    print("body bbox=%s center=%s len=%.2f S=%.5f target=%.2f blocks" %
          ([round(x, 1) for x in (mx[0] - mn[0], mx[1] - mn[1], mx[2] - mn[2])],
           [round(x, 1) for x in (cx, cy, cz)], body_len, S, args.target_blocks))
    print("stats", json.dumps(stats, ensure_ascii=False))
    print("muzzle_z(units)=%.3f  geo=%d bytes" % (muzzle_z, os.path.getsize(geo_path)))
    print("texture", src_name, "selfcheck", "PASS" if not errs else errs[:5])


def app(v):
    return [round(x, 5) for x in v]


if __name__ == "__main__":
    main()
