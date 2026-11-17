# -*- coding: utf-8 -*-
"""临时探针：打印某个 .anm 文件的 group/clip/骨名/帧率。"""
import sys, os, io, struct

sys.path.insert(0, r"D:\逆向\SSJJ双塔惊魂\mc-port\tools")


def read_utf(r):
    n = struct.unpack("<H", r.read(2))[0]
    return r.read(n).decode("utf-8", "replace")


def parse(path):
    data = open(path, "rb").read()
    r = io.BytesIO(data)
    ver = struct.unpack("<i", r.read(4))[0]
    gc = struct.unpack("<i", r.read(4))[0]
    groups = []
    for _ in range(gc):
        gn = read_utf(r)
        cc = struct.unpack("<i", r.read(4))[0]
        clips = []
        for _ in range(cc):
            cn = read_utf(r)
            curves = struct.unpack("<i", r.read(4))[0]
            length = struct.unpack("<f", r.read(4))[0]
            bones = []
            total_frames = 0
            for _ in range(curves):
                bn = read_utf(r)
                fc = struct.unpack("<i", r.read(4))[0]
                r.read(32 * fc)
                total_frames += fc
                bones.append((bn, fc))
            clips.append((cn, curves, length, total_frames, bones))
        groups.append((gn, clips))
    return ver, len(data), r.tell(), groups


for p in sys.argv[1:]:
    ver, total, used, groups = parse(p)
    print("=" * 70)
    print("FILE", p, "bytes", total, "ver", ver, "consumed", used,
          "OK" if used == total else "MISMATCH")
    for gn, clips in groups:
        print("  GROUP", gn, "clips", len(clips))
        for cn, nc, ln, nf, bones in clips:
            rate = (max(b[1] for b in bones) - 1) / ln if ln > 0 else 0
            print("    clip=%-22s curves=%-4d len=%.4fs keyframes=%-6d rate≈%.1ffps"
                  % (cn, nc, ln, nf, rate))
            print("      bones: " + ", ".join("%s(%d)" % b for b in bones[:10])
                  + (" ..." if len(bones) > 10 else ""))
