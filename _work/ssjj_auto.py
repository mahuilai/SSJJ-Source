#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SSJJ 抓包自动定位 + 解析
自动找出战斗服会话（UDP 大流量 + 私有头特征），再解 TCP APC 与 UDP 快照。
用法: python ssjj_auto.py <pcap> [--dump-tcp]
"""
import subprocess, sys, os, collections, json

TSHARK = r"D:\RE_Tools\Wireshark\tshark.exe"
WORK = r"D:\逆向\SSJJ双塔惊魂\_work"


def run(args):
    r = subprocess.run([TSHARK] + args, capture_output=True, text=True, errors="replace")
    return r.stdout


def read_varint(b, i):
    r = 0; s = 0
    while i < len(b):
        c = b[i]; i += 1
        r |= (c & 0x7F) << s
        if not (c & 0x80):
            return r, i
        s += 7
        if s > 63:
            break
    return None, i


def pb(buf, depth=0, maxd=4):
    out = []; i = 0; n = len(buf)
    while i < n:
        key, i = read_varint(buf, i)
        if key is None:
            break
        fn = key >> 3; wt = key & 7
        if fn == 0 or fn > 100000:
            break
        if wt == 0:
            v, i = read_varint(buf, i)
            if v is None:
                break
            out.append((fn, 0, v, 0))
        elif wt == 2:
            ln, i = read_varint(buf, i)
            if ln is None or i + ln > n:
                break
            raw = buf[i:i + ln]; i += ln
            sub = None
            if depth < maxd and ln > 0:
                try:
                    cand = pb(raw, depth + 1, maxd)
                    if cand and cand[-1][3] == ln:
                        sub = cand
                except Exception:
                    pass
            out.append((fn, 2, raw if sub is None else sub, ln))
        elif wt == 5:
            if i + 4 > n: break
            out.append((fn, 5, buf[i:i + 4].hex(), 4)); i += 4
        elif wt == 1:
            if i + 8 > n: break
            out.append((fn, 1, buf[i:i + 8].hex(), 8)); i += 8
        else:
            break
    return out


def pbtext(fields, ind=0, lim=8):
    pad = "  " * ind; L = []
    for it in fields[:lim]:
        fn, wt = it[0], it[1]
        if wt == 0:
            L.append(f"{pad}#{fn}={it[2]}")
        elif wt == 2:
            sub, ln = it[2], it[3]
            if isinstance(sub, list):
                L.append(f"{pad}#{fn}({ln}B):")
                L.extend(pbtext(sub, ind + 1, lim))
            else:
                try:
                    s = sub.decode("utf-8")
                    pr = len(s) > 0 and all(32 <= ord(c) < 127 for c in s)
                except Exception:
                    pr = False
                L.append(f"{pad}#{fn}='{s}'" if pr else f"{pad}#{fn}({ln}B)=hex:{sub[:12].hex()}")
        else:
            L.append(f"{pad}#{fn}=hex:{it[2]}")
    if len(fields) > lim:
        L.append(f"{pad}...(+{len(fields)-lim})")
    return L


def find_battle_server(pcap):
    """从 UDP 会话里找游戏服：字节量最大的非标准端口会话"""
    out = run(["-r", pcap, "-q", "-z", "conv,udp"])
    best = None
    for line in out.splitlines():
        if "<->" not in line:
            continue
        parts = line.split()
        try:
            pair = [p for p in parts if "<->" in p][0]
            a, b = pair.split("<->")
            nums = [p for p in parts if p.isdigit()]
            total = int(nums[-1]) if nums else 0
        except Exception:
            continue
        # 排除广播/组播/局域网
        if any(x in pair for x in ("255.255", "239.255", "ff02", "10.66.", "10.67.255", ":5353", ":2200", ":5684", ":1900")):
            continue
        if best is None or total > best[0]:
            best = (total, pair)
    return best


def dump_tcp(pcap, limit=None):
    rows = run(["-r", pcap, "-Y", "tcp.len>0", "-T", "fields",
                "-e", "frame.number", "-e", "ip.src", "-e", "tcp.srcport",
                "-e", "ip.dst", "-e", "tcp.dstport", "-e", "data.data"]).splitlines()
    msgs = []
    for line in rows:
        c = line.split("\t")
        if len(c) < 6 or not c[5]:
            continue
        try:
            blob = bytes.fromhex(c[5])
        except Exception:
            continue
        i = 0
        while i + 4 <= len(blob):
            ln = int.from_bytes(blob[i:i + 4], "big")
            if ln <= 0 or ln > 200000 or i + 4 + ln > len(blob):
                break
            body = blob[i + 4:i + 4 + ln]
            i += 4 + ln
            f = pb(body)
            mid = None; content = b""
            for x in f:
                if x[0] == 1 and x[1] == 0:
                    mid = x[2]
                elif x[0] == 2 and x[1] == 2 and isinstance(x[2], bytes):
                    content = x[2]
            msgs.append({"frame": c[0], "src": c[1], "sp": c[2], "dst": c[3], "dp": c[4],
                         "len": ln, "method": mid, "content": content.hex(),
                         "pb": pbtext(pb(content)) if content else []})
    return msgs


def dump_udp(pcap, host, port):
    rows = run(["-r", pcap, "-Y", f"udp and (ip.addr=={host} and udp.port=={port})",
                "-T", "fields", "-e", "frame.number", "-e", "ip.src",
                "-e", "udp.srcport", "-e", "data.data"]).splitlines()
    up, down = [], []
    for line in rows:
        c = line.split("\t")
        if len(c) < 4 or not c[3]:
            continue
        try:
            b = bytes.fromhex(c[3])
        except Exception:
            continue
        if len(b) < 12:
            continue
        ln = int.from_bytes(b[0:4], "big")
        is_down = (c[1] == host)
        if is_down:
            d = {"frame": c[0], "len": ln, "type": b[4] if len(b) > 4 else None,
                 "head": b[4:20].hex(), "pb": pbtext(pb(b[12:])) if len(b) > 12 else []}
            down.append(d)
        else:
            conn = int.from_bytes(b[4:8], "big", signed=True)
            d = {"frame": c[0], "len": ln, "conn": conn, "head": b[8:24].hex(),
                 "tail": b[24:].hex()}
            up.append(d)
    return up, down


def main():
    pcap = sys.argv[1]
    if not os.path.exists(pcap):
        print("no pcap:", pcap); return

    print("=" * 66)
    print("pcap:", os.path.basename(pcap), " %.2f MB" % (os.path.getsize(pcap) / 1048576))

    bs = find_battle_server(pcap)
    if bs:
        print("\n[战斗服 UDP 会话] 总字节=%d  %s" % bs)
        host = bs[1].split("<->")[1].strip().split(":")[0]
        port = bs[1].split("<->")[1].strip().split(":")[1]
        up, down = dump_udp(pcap, host, port)
        print("  上行 %d / 下行 %d" % (len(up), len(down)))
        if up:
            conns = collections.Counter(u["conn"] for u in up)
            print("  connectionId:", dict(conns.most_common(4)))
            print("  上行样例:")
            for u in up[:4]:
                print("    [%s] len=%d conn=%d head=%s tail=%s" % (u["frame"], u["len"], u["conn"], u["head"], u["tail"][:40]))
        if down:
            print("  下行样例:")
            for d in down[:3]:
                print("    [%s] len=%d type=%s head=%s" % (d["frame"], d["len"], d["type"], d["head"]))
                for l in d["pb"]:
                    print("       ", l)

    msgs = dump_tcp(pcap)
    print("\n[TCP APC] 共 %d 条" % len(msgs))
    cnt = collections.Counter(m["method"] for m in msgs)
    print("  methodId 分布:", dict(sorted(cnt.items(), key=lambda x: -x[1])))
    for m in msgs[:40]:
        print("  [%s] %s:%s -> %s:%s  method=%s len=%s" % (m["frame"], m["src"], m["sp"], m["dst"], m["dp"], m["method"], m["len"]))
        for l in m["pb"]:
            print("     ", l)

    json.dump({"battle_udp": bs[1] if bs else None, "tcp": msgs},
              open(os.path.join(WORK, "parse_auto.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    print("\njson ->", os.path.join(WORK, "parse_auto.json"))


if __name__ == "__main__":
    main()
