# -*- coding: utf-8 -*-
"""只读诊断：打印 .anm.json 的 clip 轨道、.sjfp.json 的骨架与网格包围盒。不修改任何文件。"""
import json

ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"
FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"

anm = json.load(open(ANM, encoding="utf-8"))
clips = anm["clips"]
print("clips:", len(clips))
for name, c in clips.items():
    print("  %-10s loop=%s len=%s tracks=%d" % (name, c.get("loop"), c.get("length"), len(c.get("bones", {}))))

print()
for probe in ("idle", "draw", "fire", "reload", "bolt", "walk", "putaway"):
    c = clips.get(probe)
    if not c:
        continue
    print("--- %s (len=%s loop=%s) ---" % (probe, c["length"], c.get("loop")))
    for b, ks in c["bones"].items():
        if len(ks) <= 3:
            print("   %s: %s" % (b, ks))
        else:
            print("   %s: %d keys first=%s last=%s" % (b, len(ks), ks[0], ks[-1]))

fp = json.load(open(FP, encoding="utf-8"))
print("\nspace:", fp.get("space"))
bones = fp["skeleton"]["bones"]
print("bones:", len(bones))
for b in bones:
    r = [round(x, 4) for x in b["rotation"]]
    print("  %-16s <- %-16s local=%s rot=%s scale=%s" % (
        b["name"], str(b["parent"]), b["local"], r, b["scale"]))

for b in bones:
    if b["name"] in ("gun_root", "Bip01", "WeaponAnchor", "Dummy02"):
        print("\nbindPose %s:" % b["name"])
        m = b["bindPose"]
        for i in range(4):
            print("   ", [round(m[i * 4 + j], 4) for j in range(4)])

for m in fp["meshes"]:
    p = m["pos"]
    print("\nmesh %s verts=%d skinned=%s rigidBone=%s" % (
        m["name"], len(p), m["skinned"], m.get("rigidBone")))
    for k, ax in enumerate("xyz"):
        vals = [v[k] for v in p]
        print("  bbox %s %8.2f .. %8.2f" % (ax, min(vals), max(vals)))
