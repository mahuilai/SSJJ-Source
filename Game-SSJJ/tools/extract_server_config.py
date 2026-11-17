#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 OpenRecord 录制文件里提取服务器下发的配置类 TCP 包（RoomData / SceneMapInfo / SceneXMLFile 等）。"""
import json
import os
import re
import struct
import sys

sys.path.insert(0, r"D:/逆向/SSJJ双塔惊魂/Game-SSJJ/tools")
from parse_record import parse_frames  # noqa: E402

MSG = json.load(open(r"D:/逆向/SSJJ双塔惊魂/Game source/01_metadata/protocol_messages.json", encoding="utf-8"))
FIELDS = {m["type"]: [(f["tag"], f["name"]) for f in m["fields"]] for m in MSG["messages"]}
HANDLERS = json.load(open(r"D:/逆向/SSJJ双塔惊魂/Game source/01_metadata/protocol_method_ids.json", encoding="utf-8"))["handlers"]
MID2MSG = {}
for h in HANDLERS:
    MID2MSG.setdefault(h["method_id"], h["message"])


def read_varint(b, p):
    shift = 0
    val = 0
    n = len(b)
    while True:
        if p >= n:
            raise IndexError("varint out of range")
        c = b[p]
        p += 1
        val |= (c & 0x7F) << shift
        if not (c & 0x80):
            return val, p
        shift += 7


def decode_proto(b):
    """容错 protobuf 解码：越界/非法 wiretype 就地停止，返回已解析字段。"""
    out = {}
    p = 0
    n = len(b)
    while p < n:
        try:
            key, p = read_varint(b, p)
            tag, wt = key >> 3, key & 7
            if tag == 0 or tag > 100000:
                break
            if wt == 0:
                v, p = read_varint(b, p)
                out.setdefault(tag, []).append(v)
            elif wt == 2:
                ln, p = read_varint(b, p)
                if ln < 0 or p + ln > n:
                    out.setdefault(tag, []).append(b[p:n])
                    break
                out.setdefault(tag, []).append(b[p:p + ln])
                p += ln
            elif wt == 5:
                if p + 4 > n:
                    break
                p += 4
            elif wt == 1:
                if p + 8 > n:
                    break
                p += 8
            else:
                break
        except (IndexError, ValueError):
            break
    return out


def iter_tcp(rec_path):
    _, frames = parse_frames(open(rec_path, "rb").read())
    for i, fr in enumerate(frames):
        for tcp, pl in fr["nets"]:
            if not tcp:
                continue
            if len(pl) < 8:
                continue
            total = struct.unpack(">I", pl[:4])[0]
            body = pl[4:4 + total - 4] if 4 < total <= len(pl) else pl[4:]
            try:
                apc = decode_proto(body)
            except Exception:
                continue
            ids = apc.get(1)
            contents = apc.get(2)
            if not ids or not contents:
                continue
            yield i, ids[0], contents[0]


def main():
    files = [
        r"D:/SSJJ/SSJJ-4399/battle/3_64/Records/Record_2026_10_22 13_22_10.txt",
        r"D:/SSJJ/SSJJ-4399/battle/3_64/Records/Record_2026_10_22 13_32_44.txt",
    ]
    for f in files:
        if not os.path.isfile(f):
            print("缺文件:", f)
            continue
        print("=" * 70)
        print("文件:", os.path.basename(f), "%.2f MB" % (os.path.getsize(f) / 1048576))
        stat = {}
        keep = {}
        for idx, mid, content in iter_tcp(f):
            stat[mid] = stat.get(mid, 0) + 1
            if mid in (12, 111, 119, 125, 210, 241, 71, 304, 305):
                keep.setdefault(mid, []).append((idx, content))
        print("TCP 消息种类: %d" % len(stat))
        top = sorted(stat.items(), key=lambda x: -x[1])[:12]
        print("高频: " + ", ".join("%s(%s:%d)" % (MID2MSG.get(k, "?"), k, v) for k, v in top))

        for mid in (12, 111, 119, 125, 210, 241):
            if mid not in keep:
                continue
            name = MID2MSG.get(mid, "?")
            print("\n--- methodId %d = %s  x%d ---" % (mid, name, len(keep[mid])))
            for idx, content in keep[mid][:3]:
                dec = decode_proto(content)
                fl = FIELDS.get(name, [])
                tag2name = {t: n for t, n in fl}
                pairs = []
                for tag, vals in sorted(dec.items()):
                    nm = tag2name.get(tag, "tag%d" % tag)
                    v = vals[0]
                    if isinstance(v, bytes):
                        show = "bytes(%d) %r" % (len(v), v[:24])
                    else:
                        show = v
                    pairs.append("%s=%s" % (nm, show))
                print("  帧%-6d %s" % (idx, "  ".join(pairs)[:300]))


if __name__ == "__main__":
    main()
