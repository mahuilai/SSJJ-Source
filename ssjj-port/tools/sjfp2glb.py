# -*- coding: utf-8 -*-
"""把 sjfp.json 的 hand + gun 合成一个 GLB（单一骨架、单一 skin），喂给 GemRender。

为什么必须合成一个资源：GemRender 的设计是「一个资产 = 一个 Flywheel Model」，
所有 primitive 共享同一套骨骼调色板，部件之间靠 palette 相对运动，不是分开画。

关键点：inverseBindMatrix 要左乘 bindComp
  sjfp 的 bindPose 与节点 world 之间差一个固定变换 bindComp = inverse(world(j0) × ibm0)，
  这正是自研 SkelotonPose 里手动补偿的那个 -90°X。
  GPU 蒙皮是标准的 world × ibm × v，所以要在导出时把 bindComp 烘进 ibm：
      ibm' = bindComp × ibm
  这样标准 glTF skinning 的结果就等于自研版本，不需要任何运行时补丁。

gun 没有 boneIdx/boneW（纯刚体），这里给它补一组「全指 gun_root(47)、权重 1」，
让它跟着骨架的 gun_root 走，而不是硬编码坐标。
"""
import json
import math
import os
import struct

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json")
TEX_HAND = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\hand.png")
TEX_GUN = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.png")
OUT = os.path.join(ROOT, r"ssjj-port\src\main\resources\assets\ssjjport\fp\fp.glb")

GUN_ROOT_NAME = "WeaponAnchor"


# ---------------------------------------------------------------- 4x4 行主序
def ident():
    return [[1.0 if i == j else 0.0 for j in range(4)] for i in range(4)]


def mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def quat_mat(q):
    x, y, z, w = q
    n = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / n, y / n, z / n, w / n
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), 0.0],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), 0.0],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), 0.0],
            [0.0, 0.0, 0.0, 1.0]]


def local_of(b):
    t = b.get("local") or [0, 0, 0]
    r = b.get("rotation") or [0, 0, 0, 1]
    s = b.get("scale") or [1, 1, 1]
    m = mul(quat_mat(r), [[s[0], 0, 0, 0], [0, s[1], 0, 0], [0, 0, s[2], 0], [0, 0, 0, 1]])
    m[0][3], m[1][3], m[2][3] = t[0], t[1], t[2]
    return m


def inv4(m):
    """通用 4x4 求逆（Gauss-Jordan），只用于 bindComp。"""
    a = [row[:] + [1.0 if i == r else 0.0 for r in range(4)] for i, row in enumerate(m)]
    for c in range(4):
        p = max(range(c, 4), key=lambda r: abs(a[r][c]))
        if abs(a[p][c]) < 1e-12:
            raise ZeroDivisionError("奇异矩阵，无法求逆")
        a[c], a[p] = a[p], a[c]
        d = a[c][c]
        a[c] = [v / d for v in a[c]]
        for r in range(4):
            if r != c and abs(a[r][c]) > 1e-15:
                f = a[r][c]
                a[r] = [a[r][k] - f * a[c][k] for k in range(8)]
    return [row[4:] for row in a]


def col_major(m):
    return [m[r][c] for c in range(4) for r in range(4)]


def main():
    d = json.load(open(SRC, encoding="utf-8"))
    bones = d["skeleton"]["bones"]
    names = [b["name"] for b in bones]
    idx_of = {n: i for i, n in enumerate(names)}
    n = len(bones)

    parents = []
    for b in bones:
        p = b.get("parent")
        parents.append(idx_of[p] if p else -1)

    # 拓扑序 + world
    order = sorted(range(n), key=lambda i: _depth(i, parents))
    world = [None] * n
    for i in order:
        m = local_of(bones[i])
        pi = parents[i]
        world[i] = m if pi < 0 else mul(world[pi], m)

    ibm = [b.get("bindPose") for b in bones]
    def to_m(a):  # 16 floats 行主序 -> 4x4
        return [[a[r * 4 + c] for c in range(4)] for r in range(4)]

    ibm_m = [to_m(x) for x in ibm]

    # bindComp = inverse(world(j0) × ibm0)，j0 取第一个带有效 bindPose 的骨
    j0 = 0
    for i in range(n):
        if any(abs(v) > 1e-9 for v in ibm[i]):
            j0 = i
            break
    raw0 = mul(world[j0], ibm_m[j0])
    bind_comp = inv4(raw0)
    print("bindComp 平移", [round(bind_comp[r][3], 3) for r in range(3)])

    ibm_baked = [col_major(mul(bind_comp, ibm_m[i])) for i in range(n)]

    gun_root = idx_of.get(GUN_ROOT_NAME)
    if gun_root is None:
        raise SystemExit("找不到 gun_root 骨")

    hand = next(m for m in d["meshes"] if m.get("name") == "hand")
    gun = next(m for m in d["meshes"] if m.get("name") == "gun")

    bin_blob = bytearray()
    views, accs = [], []

    def add_f32(vals, typ, count, target=34962, minmax=None):
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(struct.pack("<%df" % len(vals), *vals))
        views.append({"buffer": 0, "byteOffset": off, "byteLength": len(bin_blob) - off, "target": target})
        a = {"bufferView": len(views) - 1, "componentType": 5126, "count": count, "type": typ}
        if minmax:
            a["min"], a["max"] = minmax
        accs.append(a)
        return len(accs) - 1

    def add_u16(vals, typ, count, target=34962):
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(struct.pack("<%dH" % len(vals), *vals))
        views.append({"buffer": 0, "byteOffset": off, "byteLength": len(bin_blob) - off, "target": target})
        accs.append({"bufferView": len(views) - 1, "componentType": 5123, "count": count, "type": typ})
        return len(accs) - 1

    def add_u32(vals, typ, count, target=34963):
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(struct.pack("<%dI" % len(vals), *vals))
        views.append({"buffer": 0, "byteOffset": off, "byteLength": len(bin_blob) - off, "target": target})
        accs.append({"bufferView": len(views) - 1, "componentType": 5125, "count": count, "type": typ})
        return len(accs) - 1

    # 手臂骨骼名前缀：只有这些保留可见；其余（躯干/头/腿）进 hidden 节点，
    # 否则相机在身体内部，看到的是一整面躯干内壁。
    ARM_PREFIX = ("Bip01_R_Hand", "Bip01_R_Forearm", "Bip01_R_UpperArm",
                  "Bip01_R_Clavicle", "Bip01_R_Finger",
                  "Bip01_L_Hand", "Bip01_L_Forearm", "Bip01_L_UpperArm",
                  "Bip01_L_Clavicle", "Bip01_L_Finger")

    def split_arm(mesh):
        """按顶点主导骨骼把手/躯干拆成两组三角形索引。"""
        bi = mesh.get("boneIdx") or []
        bw = mesh.get("boneW") or []
        idx = [int(i) for i in mesh["idx"]]
        arm, torso = [], []
        for t in range(0, len(idx), 3):
            tri = idx[t:t + 3]
            def dom(v):
                best, bwv = 0, -1.0
                for k in range(4):
                    w = bw[v][k] if isinstance(bw[v], list) else bw[v * 4 + k]
                    if w > bwv:
                        bwv, best = w, (bi[v][k] if isinstance(bi[v], list) else bi[v * 4 + k])
                return best
            if all(names[dom(v)].startswith(ARM_PREFIX) for v in tri):
                arm.extend(tri)
            else:
                torso.extend(tri)
        return arm, torso

    prims = []
    for mesh, jidx_override in ((hand, None), (gun, gun_root)):
        pos = [c for p in mesh["pos"] for c in p]
        uv = [c for p in (mesh.get("uv") or []) for c in p]
        verts = len(mesh["pos"])
        if len(uv) != verts * 2:
            uv = (uv + [0.0, 0.0] * verts)[: verts * 2]
        if mesh["name"] == "hand":
            arm_i, torso_i = split_arm(mesh)
            idx = arm_i
            print("  hand 拆分: 手臂三角 %d / 躯干三角 %d（躯干进 hidden）" % (len(arm_i)//3, len(torso_i)//3))
        else:
            idx = [int(i) for i in mesh["idx"]]
        if jidx_override is None:
            bi = mesh.get("boneIdx") or []
            bw = mesh.get("boneW") or []
            jf = [int(x) for sub in bi for x in (sub if isinstance(sub, list) else [sub])]
            wf = [float(x) for sub in bw for x in (sub if isinstance(sub, list) else [sub])]
        else:
            jf = [jidx_override, 0, 0, 0] * verts
            wf = [1.0, 0.0, 0.0, 0.0] * verts
        if len(jf) != verts * 4 or len(wf) != verts * 4:
            raise SystemExit("%s 骨骼数据长度不符: %d/%d vs %d" % (mesh["name"], len(jf), len(wf), verts * 4))
        # 权重归一化
        for v in range(verts):
            s = sum(wf[v * 4:v * 4 + 4]) or 1.0
            for k in range(4):
                wf[v * 4 + k] /= s
        xs, ys, zs = pos[0::3], pos[1::3], pos[2::3]
        a_pos = add_f32(pos, "VEC3", verts, 34962, ([min(xs), min(ys), min(zs)], [max(xs), max(ys), max(zs)]))
        a_uv = add_f32(uv, "VEC2", verts)
        a_j = add_u16(jf, "VEC4", verts)
        a_w = add_f32(wf, "VEC4", verts)
        a_i = add_u32(idx, "SCALAR", len(idx), 34963)
        prims.append({"attributes": {"POSITION": a_pos, "TEXCOORD_0": a_uv,
                                     "JOINTS_0": a_j, "WEIGHTS_0": a_w},
                      "indices": a_i, "material": 0, "mode": 4})
        print("  %-5s verts=%d tris=%d" % (mesh["name"], verts, len(idx) // 3))

    a_ibm = add_f32([v for m in ibm_baked for v in m], "MAT4", n)

    # ---- 贴图嵌入（GLB images 走 bufferView）----
    def embed_png(path):
        data = open(path, "rb").read()
        while len(bin_blob) % 4:
            bin_blob.append(0)
        off = len(bin_blob)
        bin_blob.extend(data)
        views.append({"buffer": 0, "byteOffset": off, "byteLength": len(data)})
        return len(views) - 1

    images, textures = [], []
    if os.path.isfile(TEX_HAND):
        images.append({"bufferView": embed_png(TEX_HAND), "mimeType": "image/png", "name": "hand"})
    if os.path.isfile(TEX_GUN):
        images.append({"bufferView": embed_png(TEX_GUN), "mimeType": "image/png", "name": "gun"})
    for i, im in enumerate(images):
        textures.append({"source": i})
    materials = []
    if len(textures) >= 1:
        materials.append({"name": "hand", "doubleSided": True,
                          "pbrMetallicRoughness": {"baseColorTexture": {"index": 0},
                                                   "metallicFactor": 0.0, "roughnessFactor": 0.9}})
    if len(textures) >= 2:
        materials.append({"name": "gun", "doubleSided": True,
                          "pbrMetallicRoughness": {"baseColorTexture": {"index": 1},
                                                   "metallicFactor": 0.0, "roughnessFactor": 0.8}})
    while len(materials) < len(prims):
        materials.append({"name": "ssjj", "doubleSided": True,
                          "pbrMetallicRoughness": {"metallicFactor": 0.0, "roughnessFactor": 0.8}})
    for i, prim in enumerate(prims):
        prim["material"] = i % len(materials)
    print("  贴图: %d 张嵌入, 材质 %d 个" % (len(images), len(materials)))

    # ---- idle 动画（原版握枪姿势）：从 awm.anm.json 抽单帧，转成 glTF animation ----
    ANM = os.path.join(ROOT, r"mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json")
    animations = []
    try:
        anm = json.load(open(ANM, encoding="utf-8"))
        clip = anm["clips"].get("idle") or anm["clips"].get("TORSO_STAND_blend0")
        samplers, channels = [], []
        s_idx = 0
        for bn, frames in clip["bones"].items():
            ni = idx_of.get(bn)
            if ni is None or not frames:
                continue
            f = frames[0]
            t_in = add_f32([0.0], "SCALAR", 1)
            t_out = add_f32([f[1], f[2], f[3]], "VEC3", 1)
            samplers.append({"input": t_in, "output": t_out, "interpolation": "LINEAR"})
            channels.append({"sampler": s_idx, "target": {"node": ni, "path": "translation"}})
            s_idx += 1
            r_in = add_f32([0.0], "SCALAR", 1)
            r_out = add_f32([f[4], f[5], f[6], f[7]], "VEC4", 1)
            samplers.append({"input": r_in, "output": r_out, "interpolation": "LINEAR"})
            channels.append({"sampler": s_idx, "target": {"node": ni, "path": "rotation"}})
            s_idx += 1
        animations = [{"name": "idle", "samplers": samplers, "channels": channels}]
        print("  idle 动画: %d 骨 / %d channels" % (len(clip["bones"]), len(channels)))
    except Exception as e:
        print("  idle 动画导出失败:", e)

    # sjfp 的顶点单位是厘米（z 98..150 是离地高度），而 Minecraft/GemRender 认米。
    # 根节点统一乘 0.01，让整棵树（含蒙皮结果）落回 1 格 ≈ 人的尺度。
    CM_TO_M = 0.01
    nodes = []
    for i, b in enumerate(bones):
        t = b.get("local") or [0, 0, 0]
        r = b.get("rotation") or [0, 0, 0, 1]
        s = list(b.get("scale") or [1, 1, 1])
        if parents[i] < 0:
            # Unity 是左手系（+z 朝前），MC/OpenGL 是右手系（-z 朝前）。
            # 根节点 scale 取 [-0.01, 0.01, -0.01]：完成 cm→m 缩放的同时绕 Y 转 180°，
            # 行列式为正（真旋转），不会把模型镜像。
            s = [-v * CM_TO_M if k in (0, 2) else v * CM_TO_M for k, v in enumerate(s)]
            t = [-v * CM_TO_M if k in (0, 2) else v * CM_TO_M for k, v in enumerate(t)]
        nodes.append({"name": b["name"],
                      "translation": [round(x, 6) for x in t],
                      "rotation": [round(x, 6) for x in r],
                      "scale": [round(x, 6) for x in s]})
    for i in range(n):
        p = parents[i]
        if p >= 0:
            nodes[p].setdefault("children", []).append(i)
    mesh_node = len(nodes)
    nodes.append({"name": "SSJJ_FP", "mesh": 0, "skin": 0})

    gltf = {
        "asset": {"version": "2.0", "generator": "sjfp2glb (hand+gun, one skin)"},
        "scene": 0,
        "scenes": [{"nodes": [i for i in range(n) if parents[i] < 0] + [mesh_node]}],
        "nodes": nodes,
        "meshes": [{"name": "ssjj_fp", "primitives": prims}],
        "images": images,
        "textures": textures,
        "materials": materials,
        "skins": [{"joints": list(range(n)), "inverseBindMatrices": a_ibm,
                   "skeleton": next(i for i in range(n) if parents[i] < 0)}],
        "animations": animations,

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
    print("glb ->", OUT, len(out), "B  bones=%d prims=%d" % (n, len(prims)))
    return 0


def _depth(i, parents):
    d = 0
    while parents[i] >= 0:
        i = parents[i]
        d += 1
        if d > 1000:
            raise RuntimeError("骨骼层级有环")
    return d


if __name__ == "__main__":
    raise SystemExit(main())
