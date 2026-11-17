# -*- coding: utf-8 -*-
"""探针 2：确认 m_Skin / m_Weights / mesh.m_BindPose / Transform 层级。"""
import os
import UnityPy

VIEWHAND = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand"
path = os.path.join(VIEWHAND, "man_7054af81a181fa550c92e563decf7cb1")
env = UnityPy.load(path)

for o in env.objects:
    if o.type.name == "Mesh":
        t = o.read_typetree()
        print("MESH typetree keys:", sorted(t.keys()))
        bp = t.get("m_BindPose") or []
        print("m_BindPose len:", len(bp))
        if bp:
            print("  bp[0] keys:", sorted(bp[0].keys())[:12])
            print("  bp[0]:", {k: bp[0][k] for k in ("e00", "e03", "e30", "e31", "e32", "e33") if k in bp[0]})
        sk = t.get("m_Skin") or []
        print("m_Skin len:", len(sk), "first:", sk[:4] if sk else None)
        wts = t.get("m_Weights") or []
        print("m_Weights len:", len(wts))
        if wts:
            print("  w[0]:", wts[0])
        vd = t.get("m_VertexData") or {}
        print("m_VertexData keys:", sorted(vd.keys()))
        print("  m_DataSize len:", len(vd.get("m_DataSize") or []))
        break

print("\n--- Transform 层级 ---")
trs = {}
for o in env.objects:
    if o.type.name == "Transform":
        t = o.read_typetree()
        trs[o.path_id] = {
            "go": (t.get("m_GameObject") or {}).get("m_PathID"),
            "father": (t.get("m_Father") or {}).get("m_PathID"),
            "lp": t.get("m_LocalPosition"),
            "lr": t.get("m_LocalRotation"),
            "ls": t.get("m_LocalScale"),
        }
gos = {}
for o in env.objects:
    if o.type.name == "GameObject":
        gos[o.path_id] = o.read_typetree().get("m_Name")

roots = [pid for pid, v in trs.items() if not v["father"]]
print("transforms:", len(trs), "roots:", len(roots))
def show(pid, d=0):
    v = trs[pid]
    print("  " * d + "%s  lp=%s" % (gos.get(v["go"]), v["lp"]))
    if d < 3:
        for c in [k for k, x in trs.items() if x["father"] == pid][:4]:
            show(c, d + 1)
for r in roots[:2]:
    show(r)
