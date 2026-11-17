# -*- coding: utf-8 -*-
"""只读探查 v3：骨骼拓扑顺序、idle/gun_root 轨道、别名映射。不修改任何文件。"""
import json

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"

d = json.load(open(FP, encoding="utf-8"))
bones = d["skeleton"]["bones"]
name2i = {b["name"]: i for i, b in enumerate(bones)}
print("bones=%d" % len(bones))

bad = []
for i, b in enumerate(bones):
    p = b.get("parent")
    pi = name2i.get(p) if p else -1
    if p and pi is None:
        bad.append((b["name"], p))
    print("  [%2d] %-26s parent=%-24s pIdx=%s" % (i, b["name"], p, pi))
print("missing parents:", bad)

# parent-before-child?
viol = [(i, b["name"], b.get("parent")) for i, b in enumerate(bones)
        if b.get("parent") and name2i.get(b.get("parent"), -1) >= i]
print("parent-after-child violations:", len(viol))
for v in viol[:20]:
    print("   ", v)

a = json.load(open(ANM, encoding="utf-8"))
clips = a["clips"]
print("\nclip names:")
for n in clips:
    print("   ", n)

for probe in ("idle", "draw", "walk", "putaway", "fire", "reload", "bolt"):
    c = clips.get(probe)
    if not c:
        print("\n[missing alias] %s" % probe)
        continue
    print("\n--- alias %s : len=%s loop=%s tracks=%d ---" % (probe, c.get("length"), c.get("loop"), len(c.get("bones", {}))))
    moving = []
    for bn, ks in c["bones"].items():
        if len(ks) > 1:
            r0 = ks[0][4:8]
            rN = ks[-1][4:8]
            dmax = max(abs(x - y) for x, y in zip(r0, rN))
            moving.append((bn, len(ks), round(dmax, 4)))
    moving.sort(key=lambda t: -t[2])
    print("   multi-key tracks=%d, top rotation delta:" % len(moving))
    for bn, nk, dm in moving[:8]:
        print("     %-26s keys=%-4d rotDelta=%s" % (bn, nk, dm))
    for bn in ("gun_root", "model", "Bip01"):
        ks = c["bones"].get(bn)
        if ks:
            print("   %s keys=%d first=%s" % (bn, len(ks), ks[0]))
