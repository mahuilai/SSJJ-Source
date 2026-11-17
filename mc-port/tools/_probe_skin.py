# -*- coding: utf-8 -*-
"""探针：确认 viewhand bundle 里 SkinnedMeshRenderer / Mesh 的真实字段，
重点是有没有 m_BindPose、m_Skin、m_Weights（真权重）。"""
import os
import UnityPy

VIEWHAND = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand"
name = "man_7054af81a181fa550c92e563decf7cb1"
path = os.path.join(VIEWHAND, name)
env = UnityPy.load(path)

types = {}
for o in env.objects:
    types[o.type.name] = types.get(o.type.name, 0) + 1
print("object types:", types)

# SMR typetree 字段
for o in env.objects:
    if o.type.name == "SkinnedMeshRenderer":
        t = o.read_typetree()
        print("\nSMR keys:", sorted(t.keys()))
        print("  m_Mesh:", t.get("m_Mesh"))
        print("  m_Bones count:", len(t.get("m_Bones") or []))
        bp = t.get("m_BindPose") or []
        print("  m_BindPose count:", len(bp))
        if bp:
            print("  bindPose[0] keys:", sorted(bp[0].keys()) if isinstance(bp[0], dict) else type(bp[0]))
            e = bp[0].get("e00") if isinstance(bp[0], dict) else None
            print("  bindPose[0]:", {k: bp[0].get(k) for k in ("e00","e01","e02","e03","e30","e31","e32","e33")})
        print("  m_Materials:", t.get("m_Materials"))
        print("  m_RootBone:", t.get("m_RootBone"))
        break

for o in env.objects:
    if o.type.name == "Mesh":
        m = o.read()
        print("\nMESH name:", m.m_Name)
        attrs = [a for a in dir(m) if not a.startswith("_")]
        print("  has m_Skin:", hasattr(m, "m_Skin"), " has m_Weights:", hasattr(m, "m_Weights"))
        skin = getattr(m, "m_Skin", None)
        wts = getattr(m, "m_Weights", None)
        print("  m_Skin len:", len(skin) if skin is not None else None,
              "m_Weights len:", len(wts) if wts is not None else None)
        if skin:
            print("  skin[0:4]:", skin[:4])
        if wts:
            w0 = wts[0]
            print("  weight[0]:", w0, type(w0), getattr(w0, "__dict__", None))
        vd = m.m_VertexData
        print("  vertexCount:", vd.m_VertexCount, "channels:", len(vd.m_Channels or []))
        for i, c in enumerate(vd.m_Channels or []):
            print("    ch%d stream=%d off=%d fmt=%d dim=%d" %
                  (i, c.stream, c.offset, c.format, c.dimension))
        print("  m_BindPose on mesh:", hasattr(m, "m_BindPose"))
        break
