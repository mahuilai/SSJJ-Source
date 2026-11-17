# -*- coding: utf-8 -*-
"""只读：打印 awm.sjfp.json 的真实单位、骨架链、每块网格包围盒、gun_root 轨道量级。
不修改任何工程文件。"""
import json

FP = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json"
ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"

d = json.load(open(FP, encoding="utf-8"))
print("top-level keys:", list(d.keys()))
print("format:", d.get("format"), "space:", d.get("space"))

bones = (d.get("skeleton") or {}).get("bones") or []
print("bones:", len(bones))
if bones:
    print("   bone keys:", list(bones[0].keys()))

meshes = d.get("meshes") or []
print("meshes:", len(meshes))
for m in meshes:
    name = m.get("name")
    pos = m.get("pos") or []
    n = len(pos)
    if n:
        xs = [p[0] for p in pos]
        ys = [p[1] for p in pos]
        zs = [p[2] for p in pos]
        print("   %-6s verts=%-5d skinned=%s rigidBone=%s idx=%d" % (
            name, n, m.get("skinned"), m.get("rigidBone"), len(m.get("idx") or [])))
        print("       x[%+.4f,%+.4f] y[%+.4f,%+.4f] z[%+.4f,%+.4f]  size=(%+.4f, %+.4f, %+.4f)" % (
            min(xs), max(xs), min(ys), max(ys), min(zs), max(zs),
            max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs)))
    else:
        print("   %-6s (no pos)" % name)

print()
print("bone local scale (non-1 only):")
for b in bones:
    s = b.get("scale") or [1, 1, 1]
    if any(abs(v - 1.0) > 1e-6 for v in s):
        print("   %-22s parent=%-22s scale=%s" % (b.get("name"), b.get("parent"), s))

print()
print("roots:")
for b in bones:
    if b.get("parent") is None:
        print("   %-10s local=%s rot=%s" % (b.get("name"), b.get("local"), b.get("rotation")))

anm = json.load(open(ANM, encoding="utf-8"))
print()
print("gun_root translation ranges per clip:")
for name, c in anm["clips"].items():
    ks = (c.get("bones") or {}).get("gun_root")
    if not ks:
        continue
    xs = [k[1] for k in ks]
    ys = [k[2] for k in ks]
    zs = [k[3] for k in ks]
    print("   %-28s keys=%-4d x[%+.3f,%+.3f] y[%+.3f,%+.3f] z[%+.3f,%+.3f]" % (
        name, len(ks), min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))
