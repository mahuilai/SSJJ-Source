#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""SSJJ .anm 逐帧动画解析器。

规格来源（不是黑盒逆向，是照着反编译源码写的）：
  Game source/02_managed_src/SSJJAnim_Library/SSJJAnim.Parser/SJAnimationPaser.cs
  Game source/02_managed_src/Assembly-CSharp/Assets.Libs.SJAnimation.Parser/SJAnimationLoader.cs

布局（小端，ReadUTF = uint16 长度 + UTF8 字节）:
  int32  version            (源码读后丢弃)
  int32  groupCount
    UTF  groupName
    int32 clipCount
      UTF   clipName
      int32 curveCount
      float length (秒; <=0 时取 1/30)
      [ UTF boneName
        int32 frameCount
        [ float time, float px, float y, float z,
          float qx, float qy, float qz, float qw ] * frameCount
      ] * curveCount
    ] * clipCount
  ] * groupCount

源码里的坐标系变换（务必保留，否则动画镜像）:
  Position = (-px, y, z)
  Rotation = Quaternion(qx, -qy, -qz, qw)
  FrameRate = (frameCount - 1) / length  (frameCount > 1)，否则 30

用法:
  python decode_anm.py                    # 打印两把 .anm 的统计并校验字节是否消费干净
  python decode_anm.py --dump <outdir>   # 额外把解析结果写成 JSON
"""
import argparse
import io
import json
import os
import struct
import sys

import UnityPy

ROOT = r"D:\逆向\SSJJ双塔惊魂"
MAIN_BUNDLE = os.path.join(
    ROOT, "资源全集", "weapon",
    "awm_legend_t_4e41f53852ab64dd135a4278f48fd8fe",
)
ANM_NAMES = ("gun.anm", "hand_man.anm")


def read_utf(reader):
    raw = reader.read(2)
    if len(raw) != 2:
        raise ValueError("truncated UTF length")
    count = struct.unpack("<H", raw)[0]
    data = reader.read(count)
    if len(data) != count:
        raise ValueError("truncated UTF payload: want %d got %d" % (count, len(data)))
    return data.decode("utf-8", "replace")


def parse_anm(data):
    """返回 (groups, consumed, total)。consumed == total 才算格式理解正确。"""
    r = io.BytesIO(data)
    version = struct.unpack("<i", r.read(4))[0]
    group_count = struct.unpack("<i", r.read(4))[0]
    if not (0 < group_count < 10000):
        raise ValueError("implausible groupCount=%d" % group_count)

    groups = []
    for _ in range(group_count):
        gname = read_utf(r)
        clip_count = struct.unpack("<i", r.read(4))[0]
        if not (0 <= clip_count < 100000):
            raise ValueError("implausible clipCount=%d in %r" % (clip_count, gname))
        clips = []
        for _ in range(clip_count):
            cname = read_utf(r)
            curve_count = struct.unpack("<i", r.read(4))[0]
            length = struct.unpack("<f", r.read(4))[0]
            if length <= 0.0:
                length = 1.0 / 30.0
            curves = []
            for _ in range(curve_count):
                bone = read_utf(r)
                frame_count = struct.unpack("<i", r.read(4))[0]
                if not (0 <= frame_count < 1000000):
                    raise ValueError("implausible frameCount=%d on %r" % (frame_count, bone))
                frames = []
                for _ in range(frame_count):
                    blob = r.read(32)
                    if len(blob) != 32:
                        raise ValueError("truncated keyframe on %r" % bone)
                    t, px, py, pz, qx, qy, qz, qw = struct.unpack("<8f", blob)
                    frames.append({
                        "t": t,
                        "pos": [-px, py, pz],
                        "rot": [qx, -qy, -qz, qw],
                    })
                rate = (frame_count - 1) / length if frame_count > 1 else 30.0
                curves.append({"bone": bone, "frameRate": rate, "frames": frames})
            clips.append({"name": cname, "length": length, "curves": curves})
        groups.append({"group": gname, "clips": clips})

    return {"version": version, "groups": groups}, r.tell(), len(data)


def load_text_assets(bundle_path):
    env = UnityPy.load(bundle_path)
    out = {}
    for obj in env.objects:
        if obj.type.name != "TextAsset":
            continue
        d = obj.read()
        if d.m_Name not in ANM_NAMES:
            continue
        raw = d.m_Script
        if isinstance(raw, str):
            raw = raw.encode("utf-8", "surrogateescape")
        out[d.m_Name] = raw
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle", default=MAIN_BUNDLE)
    ap.add_argument("--dump", default=None, help="额外把解析结果写成 JSON 的目录")
    args = ap.parse_args()

    assets = load_text_assets(args.bundle)
    if not assets:
        print("ERROR: no .anm TextAsset found in " + args.bundle)
        return 1
    if args.dump:
        os.makedirs(args.dump, exist_ok=True)

    ok = True
    for name in ANM_NAMES:
        if name not in assets:
            print("MISS " + name)
            ok = False
            continue
        raw = assets[name]
        try:
            parsed, used, total = parse_anm(raw)
        except Exception as exc:
            print("FAIL %-14s %s: %s" % (name, type(exc).__name__, exc))
            ok = False
            continue

        groups = parsed["groups"]
        n_clips = sum(len(g["clips"]) for g in groups)
        n_curves = sum(len(c["curves"]) for g in groups for c in g["clips"])
        n_frames = sum(len(cu["frames"]) for g in groups
                       for c in g["clips"] for cu in c["curves"])
        bones = sorted({cu["bone"] for g in groups
                        for c in g["clips"] for cu in c["curves"]})

        print("=== %s ===" % name)
        print("  bytes=%d version=%d consumed=%d/%d %s"
              % (total, parsed["version"], used, total,
                 "OK" if used == total else "MISMATCH"))
        print("  groups=%d clips=%d curves=%d keyframes=%d distinct_bones=%d"
              % (len(groups), n_clips, n_curves, n_frames, len(bones)))
        print("  group names: " + ", ".join(g["group"] for g in groups[:12])
              + (" ..." if len(groups) > 12 else ""))
        sample = [(g["group"], c["name"], len(c["curves"]),
                   sum(len(cu["frames"]) for cu in c["curves"]))
                  for g in groups for c in g["clips"]][:6]
        for gname, cname, nc, nf in sample:
            print("    %-24s %-28s curves=%-4d frames=%d" % (gname, cname, nc, nf))
        if bones:
            print("  bones sample: " + ", ".join(bones[:8]))
        if used != total:
            ok = False
        if args.dump:
            path = os.path.join(args.dump, name.replace(".", "_") + ".json")
            with open(path, "w", encoding="utf-8") as fp:
                json.dump(parsed, fp, ensure_ascii=False, separators=(",", ":"))
            print("  dumped -> " + path)

    print("RESULT: " + ("ALL OK - .anm spec confirmed" if ok else "FAILED"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
