# -*- coding: utf-8 -*-
"""Export the AWM hand and weapon clips into the Fabric first-person format.

The source contains paired hand/weapon .anm clips. Keep every source clip and
add gameplay aliases. The AWM bolt-action fire clip is split at frame 9 because
the original TORSO_ATTACK animation moves from recoil into the bolt cycle there.
"""
import copy
import json
import math
import os

OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\anm"
DEST = r"D:\逆向\SSJJ双塔惊魂\mc-port\fpmod\src\main\resources\assets\ssjjfp\fp\awm.anm.json"


def load(path):
    d = json.load(open(path, encoding="utf-8"))
    return {c["name"]: c for group in d["groups"] for c in group["clips"]}


def pack_hand_tracks(curves, t0=None, t1=None):
    out = {}
    for cur in curves:
        frames = cur["frames"]
        if t0 is not None:
            frames = [f for f in frames if t0 - 1e-6 <= f["t"] <= t1 + 1e-6]
        if not frames:
            continue
        first = frames[0]
        static = all(
            math.dist(f["pos"], first["pos"]) < 0.5
            and max(abs(a - b) for a, b in zip(f["rot"], first["rot"])) < 0.004
            for f in frames
        )
        if static:
            out[cur["bone"]] = [[0.0] + [round(v, 3) for v in first["pos"]]
                                 + [round(v, 5) for v in first["rot"]]]
            continue
        keys = []
        for frame in frames:
            t = frame["t"] - (t0 or 0.0)
            keys.append([round(max(t, 0.0), 4)]
                        + [round(v, 3) for v in frame["pos"]]
                        + [round(v, 5) for v in frame["rot"]])
        out[cur["bone"]] = keys
    return out


def quat_mul(a, b):
    ax, ay, az, aw = a
    bx, by, bz, bw = b
    return [aw * bx + ax * bw + ay * bz - az * by,
            aw * by - ax * bz + ay * bw + az * bx,
            aw * bz + ax * by - ay * bx + az * bw,
            aw * bw - ax * bx - ay * by - az * bz]


# Exported AWM OBJ has its muzzle along -X. Map weapon coordinates
# (+X right along the stock, +Y up, +Z width) into SSJJ view axes
# (+X right, -Y forward, +Z up): (x, y, z) -> (z, x, y).
VIEW_BASIS = [0.5, 0.5, 0.5, 0.5]
VIEW_BASIS_INV = [-VIEW_BASIS[0], -VIEW_BASIS[1], -VIEW_BASIS[2], VIEW_BASIS[3]]


def weapon_to_view(v):
    return [v[2], v[0], v[1]]


def gun_track(curve, base_pos, base_rot, t0=None, t1=None):
    if not curve:
        return {}
    qi = [-base_rot[0], -base_rot[1], -base_rot[2], base_rot[3]]
    keys = []
    for frame in curve["frames"]:
        if t0 is not None and not (t0 - 1e-6 <= frame["t"] <= t1 + 1e-6):
            continue
        t = frame["t"] - (t0 or 0.0)
        rel_source = quat_mul(qi, frame["rot"])
        rel = quat_mul(quat_mul(VIEW_BASIS, rel_source), VIEW_BASIS_INV)
        dp_source = [frame["pos"][i] - base_pos[i] for i in range(3)]
        dp = weapon_to_view(dp_source)
        # Preserve source translations. Earlier output clamped these to 1.5 cm,
        # which removed most of the AWM's actual recoil and bolt movement.
        keys.append([round(max(t, 0.0), 4)] + [round(v, 3) for v in dp]
                    + [round(v, 5) for v in rel])
    return {"gun_root": keys} if keys else {}


def make_clip(name, hand_clip, gun_clip, hand, gun, base_pos, base_rot,
              loop=False, t0=None, t1=None):
    tracks = pack_hand_tracks(hand[hand_clip]["curves"], t0, t1)
    weapon_curves = {c["bone"]: c for c in gun[gun_clip]["curves"]}
    tracks.update(gun_track(weapon_curves.get("Dummy02"), base_pos, base_rot, t0, t1))
    length = (t1 - t0) if t0 is not None else hand[hand_clip].get("length", 0.0)
    return {"loop": loop, "length": round(length, 4), "bones": tracks}


def reverse_clip(src):
    clip = copy.deepcopy(src)
    for name, keys in clip["bones"].items():
        if len(keys) < 2:
            continue
        clip["bones"][name] = [
            [round(clip["length"] - key[0], 4)] + key[1:]
            for key in reversed(keys)
        ]
    clip["loop"] = False
    return clip


def main():
    hand = load(os.path.join(OUT, "hand_man_anm.json"))
    gun = load(os.path.join(OUT, "gun_anm.json"))
    base_curve = next(c for c in gun["TORSO_STAND_blend0"]["curves"]
                      if c["bone"] == "Dummy02")
    base = base_curve["frames"][0]
    base_pos, base_rot = base["pos"], base["rot"]

    clips = {}
    for source_name, hclip in hand.items():
        if source_name not in gun:
            print("skip unpaired source clip", source_name)
            continue
        loop = source_name.startswith(("TORSO_STAND", "TORSO_WALK", "TORSO_SPECIAL_STAND", "TORSO_SPECIAL_WALK"))
        clips[source_name] = make_clip(source_name, source_name, source_name,
                                       hand, gun, base_pos, base_rot, loop)

    aliases = {
        "idle": "TORSO_STAND_blend0",
        "walk": "TORSO_WALK_blend0",
        "draw": "TORSO_RAISE_blend0",
        "reload": "TORSO_RELOAD_blend0",
        "inspect": "TORSO_SHOWGUN_blend0",
        "melee": "TORSO_SECONDARY_ATTACK_blend0",
    }
    for alias, source in aliases.items():
        clips[alias] = copy.deepcopy(clips[source])
        clips[alias]["loop"] = alias in ("idle", "walk")

    attack = "TORSO_ATTACK_blend0"
    fire_end = 9.0 / 30.0
    full_length = hand[attack]["length"]
    clips["fire"] = make_clip("fire", attack, attack, hand, gun, base_pos, base_rot,
                               t0=0.0, t1=fire_end)
    clips["bolt"] = make_clip("bolt", attack, attack, hand, gun, base_pos, base_rot,
                               t0=fire_end, t1=full_length)
    clips["putaway"] = reverse_clip(clips["draw"])

    out = {"format": "ssjj-anm/2", "fps": 30, "clips": clips}
    os.makedirs(os.path.dirname(DEST), exist_ok=True)
    with open(DEST, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))

    print("clips:", len(clips))
    for name in ("idle", "walk", "draw", "fire", "bolt", "reload", "inspect", "melee", "putaway"):
        c = clips[name]
        print("%-8s length=%6.3f tracks=%d loop=%s" %
              (name, c["length"], len(c["bones"]), c["loop"]))
    print("->", DEST, round(os.path.getsize(DEST) / 1048576, 2), "MB")


if __name__ == "__main__":
    main()
