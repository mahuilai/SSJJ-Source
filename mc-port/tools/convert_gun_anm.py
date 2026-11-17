# -*- coding: utf-8 -*-
"""把 gun.anm 的刚体动画（6 骨：Bip01/Dummy01-04/WeaponAnchor）转成 TaCZ animation.json。

- 只取 WeaponAnchor 曲线（枪相对手的变换），映射到 geo 的 gun_pos 骨骼
- 四元数 → 旋转矩阵 → 基变换（SSJJ: -Y 前/+Z 上 → TaCZ: -Z 前/+Y 上）→ 欧拉角（度）
- 位置 cm → TaCZ 单位（6.25 cm/单位），同样做基变换
- 输出 pack/assets/ssjj/animations/awm_legend_t.animation.json
"""
import json
import math
import os

SRC = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\anm\gun_anm.json"
PACK = r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj"
DEST = os.path.join(PACK, "assets", "ssjj", "animations", "awm_legend_t.animation.json")

CM_PER_UNIT = 6.25

# clip → TaCZ 动画名
MAP = {
    "TORSO_STAND_blend0": ("idle", True),
    "TORSO_ATTACK_blend0": ("shoot", False),
    "TORSO_RELOAD_blend0": ("reload_empty", False),
    "TORSO_WALK_blend0": ("walk_forward", True),
}
# 实测：WeaponAnchor 全程静止，真正的枪身运动在 Dummy02（后坐旋转 + 位移），
# Dummy04 是弹匣/枪机的附加位移。这里用 Dummy02 当主驱动。
BONE_SRC = "Dummy02"
BONE_DST = "gun_pos"


def quat_to_euler_deg(q):
    x, y, z, w = q
    n = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / n, y / n, z / n, w / n
    # 旋转矩阵（列主序按行写）
    m = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
         [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
         [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]
    # 基变换 P：SSJJ(x,y,z) → TaCZ(x,z,y)，R' = P R P^T
    p = [[1, 0, 0], [0, 0, 1], [0, 1, 0]]
    r = [[sum(p[i][k] * m[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    r = [[sum(r[i][k] * p[j][k] for k in range(3)) for j in range(3)] for i in range(3)]
    # XYZ 欧拉
    sy = -r[2][0]
    sy = max(-1.0, min(1.0, sy))
    ry = math.asin(sy)
    if abs(math.cos(ry)) > 1e-6:
        rx = math.atan2(r[2][1], r[2][2])
        rz = math.atan2(r[1][0], r[0][0])
    else:
        rx = math.atan2(-r[1][2], r[1][1])
        rz = 0.0
    return [round(math.degrees(a), 3) for a in (rx, ry, rz)]


def qmul(a, b):
    ax, ay, az, aw = a
    bx, by, bz, bw = b
    return [aw * bx + ax * bw + ay * bz - az * by,
            aw * by - ax * bz + ay * bw + az * bx,
            aw * bz + ax * by - ay * bx + az * bw,
            aw * bw - ax * bx - ay * by - az * bz]


def qconj(q):
    return [-q[0], -q[1], -q[2], q[3]]


def pos_to_tacz(p):
    return [round(p[0] / CM_PER_UNIT, 4),
            round(p[2] / CM_PER_UNIT, 4),
            round(p[1] / CM_PER_UNIT, 4)]


def main():
    data = json.load(open(SRC, encoding="utf-8"))
    clips = {}
    for g in data["groups"]:
        for c in g["clips"]:
            clips[c["name"]] = c

    # 以 TORSO_STAND 首帧为基准姿态：WeaponAnchor 的绝对值含手部静止朝向，
    # 直接套到 gun_pos 会把枪整体拧 180 度。这里取相对量（R_rel = R0^-1 * R）。
    base_clip = clips.get("TORSO_STAND_blend0")
    base_rot, base_pos = None, None
    if base_clip:
        for cur in base_clip["curves"]:
            if cur["bone"] == BONE_SRC and cur["frames"]:
                base_rot = cur["frames"][0]["rot"]
                base_pos = cur["frames"][0]["pos"]
                break
    print("base pose:", base_rot, base_pos)

    out = {"format_version": "1.8.0", "animations": {}}
    for src_name, (dst_name, loop) in MAP.items():
        c = clips.get(src_name)
        if not c:
            print("skip (missing):", src_name)
            continue
        track = None
        for cur in c["curves"]:
            if cur["bone"] == BONE_SRC:
                track = cur
                break
        if not track:
            print("skip (no WeaponAnchor):", src_name)
            continue
        rot, pos = {}, {}
        qi = qconj(base_rot) if base_rot else [0, 0, 0, 1]
        for f in track["frames"]:
            t = "%.4f" % f["t"]
            rel = qmul(qi, f["rot"]) if base_rot else f["rot"]
            rot[t] = quat_to_euler_deg(rel)
            dv = [f["pos"][i] - base_pos[i] for i in range(3)] if base_pos else f["pos"]
            pv = pos_to_tacz(dv)
            # 原始位移有几百 cm 的尖峰（引擎侧做平滑/限制），这里夹到 ±3 单位≈0.19格
            pos[t] = [max(-3.0, min(3.0, v)) for v in pv]
        anim = {"loop": loop, "animation_length": round(c.get("length") or 0.0, 4),
                "bones": {BONE_DST: {"rotation": rot, "position": pos}}}
        out["animations"][dst_name] = anim
        print("%-16s <- %-28s frames=%-4d len=%.3f" % (dst_name, src_name, len(rot), c.get("length") or 0))

    os.makedirs(os.path.dirname(DEST), exist_ok=True)
    with open(DEST, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
    print("->", DEST, os.path.getsize(DEST), "B")
    for k, v in out["animations"].items():
        b = v["bones"][BONE_DST]
        t0 = sorted(b["rotation"])[0]
        print("  %-14s t0=%s rot=%s pos=%s" % (k, t0, b["rotation"][t0], b["position"][t0]))


if __name__ == "__main__":
    main()
