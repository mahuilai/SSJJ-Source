# -*- coding: utf-8 -*-
"""导出第一人称模型（手模 + 枪）为模组直读的 .sjfp.json。

设计要点：
- 手模从 Unity `m_Skin` / `m_BindPose` 读取原始 4 权重和完整 4×4 矩阵。
- 保留 `Bip01` 等非蒙皮祖先，因为原版 `.anm` 会动画根节点。
- 手模保留 Unity XYZ；枪网格单独变换到 SSJJ 视模型轴，避免混用坐标基。
- 枪由 `camera_man` 相机相对矩阵定位；`Dummy02` 动画叠加在独立 gun_root 上。

用法：
  python export_fp_model.py [--gun-yaw 0] [--gun-pitch 0] [--gun-roll 0]
                            [--gun-off X Y Z]
"""
import argparse
import json
import math
import os
import UnityPy

OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"
HAND_OBJ = os.path.join(OUT, "hand_man.obj")
GUN_OBJ = os.path.join(OUT, "mesh", "awm_legend_t.obj")
GUN_PARTS = ("p1_xm",)
DEST = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
VIEWHAND_BUNDLE = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand\man_7054af81a181fa550c92e563decf7cb1"


def parse_obj(path, only=None):
    verts, uvs, faces, cur = [], [], [], None
    for ln in open(path, encoding="utf-8"):
        if ln.startswith("o ") or ln.startswith("g "):
            cur = ln[2:].strip()
        elif ln.startswith("v "):
            verts.append([float(x) for x in ln.split()[1:4]])
        elif ln.startswith("vt "):
            uvs.append([float(x) for x in ln.split()[1:3]])
        elif ln.startswith("f "):
            if only and cur not in only:
                continue
            tri = []
            for tok in ln.split()[1:4]:
                a = tok.split("/")
                tri.append((int(a[0]) - 1, int(a[1]) - 1 if len(a) > 1 and a[1] else 0))
            faces.append(tri)
    return verts, uvs, faces


def read_hand_rig():
    """Read Unity's actual m_Skin weights, bind poses, and local transform rig."""
    env = UnityPy.load(VIEWHAND_BUNDLE)
    objects = {o.path_id: o for o in env.objects}
    game_objects = {}
    transforms = {}
    for obj in env.objects:
        if obj.type.name == "GameObject":
            game_objects[obj.path_id] = obj.read_typetree().get("m_Name")
        elif obj.type.name == "Transform":
            transforms[obj.path_id] = obj.read_typetree()

    renderer = None
    for obj in env.objects:
        if obj.type.name == "SkinnedMeshRenderer":
            tree = obj.read_typetree()
            bones = [(x or {}).get("m_PathID") for x in (tree.get("m_Bones") or [])]
            if len(bones) == 44:
                renderer = (tree, bones)
                break
    if renderer is None:
        raise RuntimeError("viewhand SkinnedMeshRenderer with 44 bones was not found")

    smr, bone_pids = renderer
    mesh_pid = (smr.get("m_Mesh") or {}).get("m_PathID")
    mesh_obj = objects.get(mesh_pid)
    if mesh_obj is None:
        raise RuntimeError("viewhand renderer mesh reference is missing")
    mesh = mesh_obj.read()
    if len(mesh.m_Skin or []) != mesh.m_VertexData.m_VertexCount:
        raise RuntimeError("viewhand m_Skin vertex count does not match mesh")

    def transform_name(pid):
        t = transforms[pid]
        go = (t.get("m_GameObject") or {}).get("m_PathID")
        return game_objects.get(go)

    bone_names = [transform_name(pid) for pid in bone_pids]
    if any(name is None for name in bone_names):
        raise RuntimeError("viewhand renderer contains an unnamed bone")

    # Preserve non-renderer ancestors such as Bip01 so the root animation track
    # is evaluated. Their bind pose is identity because no vertex references them.
    include = []
    included = set()
    for pid in bone_pids:
        cur = pid
        while cur in transforms and cur not in included:
            included.add(cur)
            include.append(cur)
            cur = (transforms[cur].get("m_Father") or {}).get("m_PathID")
    ordered_pids = []
    pending = set(included)
    while pending:
        ready = [pid for pid in include if pid in pending and
                 ((transforms[pid].get("m_Father") or {}).get("m_PathID") not in pending)]
        if not ready:
            raise RuntimeError("cycle in viewhand transform hierarchy")
        for pid in ready:
            ordered_pids.append(pid)
            pending.remove(pid)

    index_by_name = {transform_name(pid): i for i, pid in enumerate(ordered_pids)}
    bone_index_by_name = {name: index_by_name[name] for name in bone_names}
    nodes = []
    bone_source_index = {pid: i for i, pid in enumerate(bone_pids)}
    for pid in ordered_pids:
        t = transforms[pid]
        go = (t.get("m_GameObject") or {}).get("m_PathID")
        name = game_objects.get(go)
        parent_pid = (t.get("m_Father") or {}).get("m_PathID")
        parent_name = transform_name(parent_pid) if parent_pid in transforms else None
        p = t.get("m_LocalPosition") or {"x": 0.0, "y": 0.0, "z": 0.0}
        q = t.get("m_LocalRotation") or {"x": 0.0, "y": 0.0, "z": 0.0, "w": 1.0}
        s = t.get("m_LocalScale") or {"x": 1.0, "y": 1.0, "z": 1.0}
        src_i = bone_source_index.get(pid)
        bind_pose = list(mesh.m_BindPose[src_i].M) if src_i is not None else [
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0,
        ]
        nodes.append({
            "name": name,
            "parent": parent_name,
            "local": [p.get("x", 0.0), p.get("y", 0.0), p.get("z", 0.0)],
            "rotation": [q.get("x", 0.0), q.get("y", 0.0), q.get("z", 0.0), q.get("w", 1.0)],
            "scale": [s.get("x", 1.0), s.get("y", 1.0), s.get("z", 1.0)],
            "bindPose": bind_pose,
        })

    bidx, bwt = [], []
    for skin in mesh.m_Skin:
        ids, weights = [], []
        for original_index, weight in zip(skin.boneIndex, skin.weight):
            source_name = bone_names[original_index] if 0 <= original_index < len(bone_names) else None
            ids.append(bone_index_by_name.get(source_name, 0))
            weights.append(float(weight))
        bidx.append(ids)
        bwt.append(weights)
    return nodes, bidx, bwt


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gun-yaw", type=float, default=0.0)
    ap.add_argument("--gun-pitch", type=float, default=0.0)
    ap.add_argument("--gun-roll", type=float, default=0.0)
    ap.add_argument("--gun-off", nargs=3, type=float, default=[0.0, 0.0, 0.0])
    args = ap.parse_args()

    hv, huv, hf = parse_obj(HAND_OBJ)
    print("hand verts", len(hv), "faces", len(hf))

    rig_nodes, bidx, bwt = read_hand_rig()
    print("bones:", len(rig_nodes), "actual Unity skin weights:", len(bidx))

    # The weapon uses camera_man placement and its own Dummy02 action track.
    # Keep it at the view-model root; parenting it to the hand's WeaponAnchor
    # mixes two different source coordinate spaces.
    gv, guv, gf = parse_obj(GUN_OBJ, only=set(GUN_PARTS))
    used = sorted({i for f in gf for i, _ in f})
    remap = {g: k for k, g in enumerate(used)}
    gpos = [gv[g] for g in used]
    print("gun verts", len(gpos), "faces", len(gf))

    ry, rp, rr = (math.radians(a) for a in (args.gun_yaw, args.gun_pitch, args.gun_roll))

    def gun_xform(p):
        # Exported OBJ stores muzzle direction along -X. Map it to SSJJ view -Y,
        # with +Y up -> +Z and width +Z -> screen-right +X.
        # In the exported OBJ the AWM barrel runs along -X, so map +view Y to
        # source +X; negative view Y is the muzzle/forward direction.
        x, y, z = p[2], p[0], p[1]
        cy, sy = math.cos(rr), math.sin(rr)
        x, y = x * cy - y * sy, x * sy + y * cy
        cp, sp = math.cos(rp), math.sin(rp)
        y, z = y * cp - z * sp, y * sp + z * cp
        cy2, sy2 = math.cos(ry), math.sin(ry)
        x, z = x * cy2 + z * sy2, -x * sy2 + z * cy2
        return [x + args.gun_off[0], y + args.gun_off[1], z + args.gun_off[2]]

    gpos_t = [gun_xform(p) for p in gpos]
    gf_local = [[remap[i] for i, _ in tri] for tri in gf]
    # 枪 UV 按顶点索引取（导出的 OBJ 里 vt 与 v 一一对应）
    gun_uv = [[round(guv[i][0], 5), round(guv[i][1], 5)] if i < len(guv) else [0.0, 0.0]
              for i in used]

    skel = [{
        "name": b["name"], "parent": b["parent"],
        "local": [round(v, 6) for v in b["local"]],
        "rotation": [round(v, 7) for v in b["rotation"]],
        "scale": [round(v, 6) for v in b["scale"]],
        "bindPose": [round(v, 7) for v in b["bindPose"]],
    } for b in rig_nodes]
    skel.append({"name": "gun_root", "parent": None,
                 "local": [0.0, 0.0, 0.0], "rotation": [0.0, 0.0, 0.0, 1.0],
                 "scale": [1.0, 1.0, 1.0], "bindPose": [
                     1.0, 0.0, 0.0, 0.0,
                     0.0, 1.0, 0.0, 0.0,
                     0.0, 0.0, 1.0, 0.0,
                     0.0, 0.0, 0.0, 1.0,
                 ]})

    data = {
        "format": "ssjj-fp/1",
        "space": {"unit": "cm", "hand": "Unity XYZ", "gun": "SSJJ view XYZ"},
        "skeleton": {"bones": skel},
        "meshes": [
            {"name": "hand", "tex": "hand", "skinned": True,
             "pos": [[round(c, 3) for c in p] for p in hv],
             "uv": [[round(u, 5), round(v, 5)] for u, v in huv][:len(hv)],
             "boneIdx": bidx, "boneW": bwt,
             "idx": [i for tri in hf for i, _ in tri]},
            {"name": "gun", "tex": "awm", "skinned": False, "rigidBone": "gun_root",
             "pos": [[round(c, 3) for c in p] for p in gpos_t],
             "uv": gun_uv,
             "idx": [i for tri in gf_local for i in tri]},
        ],
    }
    os.makedirs(os.path.dirname(DEST), exist_ok=True)
    with open(DEST, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    print("->", DEST, round(os.path.getsize(DEST) / 1048576, 2), "MB")
    print("gun bbox", [round(min(p[i] for p in gpos_t), 1) for i in range(3)],
          [round(max(p[i] for p in gpos_t), 1) for i in range(3)])


if __name__ == "__main__":
    main()
