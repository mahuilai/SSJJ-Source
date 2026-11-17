# -*- coding: utf-8 -*-
"""P4: 从真实 PPtr 还原 mesh -> material -> texture 绑定。

Unity AssetBundle 跨包引用:
  main 包持有 130 个 Texture2D；$2 包持有 Mesh / Material / SkinnedMeshRenderer。
  Material.m_SavedProperties.m_TexEnvs[i] = [槽名, {m_Texture: {m_FileID, m_PathID}, ...}]
  SkinnedMeshRenderer.m_Materials[i].m_PathID 指向同包 Material。
若 texenv 的 m_PathID 能命中主包 Texture2D 的 path_id，即可精确绑定。

产物: mc-port/out/material_resolution.json
"""
import collections
import json
import os

import UnityPy

ROOT = r"D:\逆向\SSJJ双塔惊魂"
WEAPON = os.path.join(ROOT, "资源全集", "weapon")
OUT = os.path.join(ROOT, "mc-port", "out", "material_resolution.json")


def bundles():
    fs = [f for f in os.listdir(WEAPON) if f.startswith("awm_legend_t")]
    return (os.path.join(WEAPON, [f for f in fs if "$2_" not in f][0]),
            os.path.join(WEAPON, [f for f in fs if "$2_" in f][0]))


def tree(obj):
    try:
        return obj.read_typetree()
    except Exception:
        return {}


def main():
    main_p, sub_p = bundles()
    env_m = UnityPy.load(main_p)
    env_s = UnityPy.load(sub_p)

    tex = {}
    for o in env_m.objects:
        if o.type.name == "Texture2D":
            t = tree(o)
            tex[o.path_id] = {"name": t.get("m_Name"), "w": t.get("m_Width"),
                              "h": t.get("m_Height"), "fmt": t.get("m_TextureFormat")}
    gos = {}
    for o in env_s.objects:
        if o.type.name == "GameObject":
            gos[o.path_id] = tree(o).get("m_Name")
    # m_Bones 指向 Transform，需再追一层 m_GameObject 才是骨骼名
    transforms = {}
    for o in env_s.objects:
        if o.type.name == "Transform":
            t = tree(o)
            gp = (t.get("m_GameObject") or {}).get("m_PathID")
            transforms[o.path_id] = gos.get(gp)
    meshes = {}
    for o in env_s.objects:
        if o.type.name == "Mesh":
            meshes[o.path_id] = tree(o).get("m_Name")
    mats = {}
    for o in env_s.objects:
        if o.type.name != "Material":
            continue
        t = tree(o)
        envs = []
        for e in (t.get("m_SavedProperties") or {}).get("m_TexEnvs", []) or []:
            slot = e[0] if isinstance(e, (list, tuple)) else str(e)
            pptr = {}
            if isinstance(e, (list, tuple)) and len(e) > 1 and isinstance(e[1], dict):
                pptr = e[1].get("m_Texture") or {}
            envs.append({"slot": slot,
                         "file_id": pptr.get("m_FileID"),
                         "path_id": pptr.get("m_PathID")})
        mats[o.path_id] = {"name": t.get("m_Name"), "texenvs": envs}

    smrs = []
    hit = miss = 0
    for o in env_s.objects:
        if o.type.name != "SkinnedMeshRenderer":
            continue
        t = tree(o)
        mesh_pid = (t.get("m_Mesh") or {}).get("m_PathID")
        mat_pids = [(x or {}).get("m_PathID") for x in (t.get("m_Materials") or [])]
        bone_pids = [(x or {}).get("m_PathID") for x in (t.get("m_Bones") or [])]
        md = []
        for pid in mat_pids:
            m = mats.get(pid, {})
            textures = []
            for e in m.get("texenvs", []):
                tx = tex.get(e["path_id"])
                if tx:
                    hit += 1
                    textures.append({"slot": e["slot"], "file_id": e["file_id"],
                                     "path_id": e["path_id"], "texture": tx["name"],
                                     "size": "%dx%d" % (tx["w"], tx["h"]), "resolved": True})
                else:
                    miss += 1
                    textures.append({"slot": e["slot"], "file_id": e["file_id"],
                                     "path_id": e["path_id"], "resolved": False})
            md.append({"path_id": pid, "name": m.get("name"), "textures": textures})
        smrs.append({
            "smr_path_id": o.path_id,
            "mesh_path_id": mesh_pid,
            "mesh": meshes.get(mesh_pid),
            "materials": md,
            "bones": [{"path_id": b, "name": transforms.get(b) or gos.get(b)} for b in bone_pids],
        })

    result = {
        "counts": {"textures_in_main": len(tex), "materials": len(mats),
                   "meshes": len(meshes), "smrs": len(smrs),
                   "texenv_pptr_resolved": hit, "texenv_pptr_unresolved": miss},
        "bindings": smrs,
        "unresolved_pptrs": sorted({e["path_id"] for b in smrs for m in b["materials"]
                                    for e in m["textures"] if not e["resolved"]}, key=str),
        "material_index": {str(k): v["name"] for k, v in mats.items()},
    }
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=1)
    print("textures=%d materials=%d meshes=%d smrs=%d" % (len(tex), len(mats), len(meshes), len(smrs)))
    print("texenv PPtr resolved=%d unresolved=%d" % (hit, miss))
    for b in smrs[:12]:
        names = [(m["name"], [t.get("texture") for t in m["textures"]]) for m in b["materials"]]
        print("  %-18s mat=%s bones=%s" % (b["mesh"], names[:2],
              [x["name"] for x in b["bones"][:3]]))
    print("written:", OUT)


if __name__ == "__main__":
    main()
