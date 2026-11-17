# -*- coding: utf-8 -*-
"""只读探查：sjfp 骨骼表、网格绑定、idle/gun_root 轨道真实数值。不修改任何文件。"""
import json

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"


d = json.load(open(FP, encoding="utf-8"))
print("sjfp keys:", list(d.keys()))
bones = d.get("bones") or d.get("skeleton") or []
print("bones:", len(bones))
if bones:
    print("bone[0] keys:", list(bones[0].keys()))
for b in bones:
    print("  %-26s parent=%-24s local=%s rot=%s" % (
        b.get("name"), b.get("parent"), b.get("local"), b.get("rotation")))

for key in ("hand", "gun", "meshes", "mesh"):
    m = d.get(key)
    if m is None:
        continue
    if isinstance(m, list):
        for mm in m:
            print(key, "keys:", list(mm.keys()))
            p = mm.get("pos") or []
            if p:
                xs, ys, zs = p[0::3], p[1::3], p[2::3]
                print("  verts", len(xs), "x", round(min(xs), 4), round(max(xs), 4),
                      "y", round(min(ys), 4), round(max(ys), 4),
                      "z", round(min(zs), 4), round(max(zs), 4))
            print("  skinned", mm.get("skinned"), "rigidBone", mm.get("rigidBone"), "tex", mm.get("tex"))
    else:
        print(key, "keys:", list(m.keys()))
        p = m.get("pos") or []
        if p:
            xs, ys, zs = p[0::3], p[1::3], p[2::3]
            print("  verts", len(xs), "x", round(min(xs), 4), round(max(xs), 4),
                  "y", round(min(ys), 4), round(max(ys), 4),
                  "z", round(min(zs), 4), round(max(zs), 4))
        print("  skinned", m.get("skinned"), "rigidBone", m.get("rigidBone"), "tex", m.get("tex"))

a = json.load(open(ANM, encoding="utf-8"))
for clip in ("idle", "draw", "putaway"):
    c = a["clips"].get(clip)
    if not c:
        print("clip missing:", clip)
        continue
    print("\n--- clip %s len=%s loop=%s ---" % (clip, c.get("length"), c.get("loop")))
    for name, frames in c["bones"].items():
        if len(frames) == 1:
            f = frames[0]
            print("  %-26s single t=%s pos=%s rot=%s" % (name, f.get("t"), f.get("pos"), f.get("rot")))
        else:
            print("  %-26s frames=%d t0=%s tN=%s rot0=%s rotN=%s" % (
                name, len(frames), frames[0].get("t"), frames[-1].get("t"),
                frames[0].get("rot"), frames[-1].get("rot")))
