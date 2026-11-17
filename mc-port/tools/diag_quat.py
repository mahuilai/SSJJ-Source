# -*- coding: utf-8 -*-
"""只读诊断：idle 等 clip 的四元数连续性、采样角速度、loop 回绕跳变。不改工程文件。"""
import json
import math

ANM = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"

anm = json.load(open(ANM, encoding="utf-8"))
clips = anm["clips"]


def qnorm(q):
    n = math.sqrt(sum(c * c for c in q)) or 1.0
    return [c / n for c in q]


def qang(a, b):
    a = qnorm(a)
    b = qnorm(b)
    d = abs(sum(x * y for x, y in zip(a, b)))
    d = max(-1.0, min(1.0, d))
    return math.degrees(2.0 * math.acos(d))


def qpart(f):
    return f[4:8] if len(f) >= 8 else f[-4:]


print("total clips:", len(clips))
print()

for name in ("idle", "TORSO_STAND_blend0", "TORSO_WALK_blend0", "TORSO_SHOWGUN_blend0", "TORSO_ATTACK_blend0"):
    c = clips.get(name)
    if not c:
        print("missing:", name)
        continue
    print("=== %s  len=%s loop=%s bones=%d ===" % (name, c["length"], c.get("loop"), len(c["bones"])))
    rows = []
    for b, ks in c["bones"].items():
        if len(ks) < 2:
            rows.append((0.0, b, len(ks), 0.0))
            continue
        mx = 0.0
        for i in range(1, len(ks)):
            mx = max(mx, qang(qpart(ks[i - 1]), qpart(ks[i])))
        wrap = qang(qpart(ks[-1]), qpart(ks[0]))
        rows.append((mx, b, len(ks), wrap))
    rows.sort(reverse=True)
    for mx, b, n, wrap in rows[:10]:
        print("   %-26s keys=%-3d maxStep=%7.2f deg  loopWrap=%7.2f deg" % (b, n, mx, wrap))
    n1 = sum(1 for r in rows if r[2] < 2)
    print("   bones with <2 keys: %d / %d" % (n1, len(rows)))
    print()

# idle 逐骨架的原始关键帧，用于判断是否单帧静止
c = clips.get("idle")
if c:
    print("=== idle raw keys (all bones) ===")
    for b, ks in c["bones"].items():
        print("  %-26s %s" % (b, ks if len(ks) <= 2 else str(ks[:2]) + " ... keys=" + str(len(ks))))
