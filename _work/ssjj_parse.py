#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SSJJ 协议解析器 —— 把 pcap 里的 TCP(APC) / UDP(快照) 解成可读结构
用法:
  python ssjj_parse.py <pcap>            # 总览
  python ssjj_parse.py <pcap> --tcp      # TCP APC 明细
  python ssjj_parse.py <pcap> --udp      # UDP 明细
  python ssjj_parse.py <pcap> --json out.json
"""
import sys, subprocess, json, collections, os

TSHARK = r"D:\RE_Tools\Wireshark\tshark.exe"


# ---------- protobuf 极简解码（只解 wire type 0/2/5，够用于结构识别） ----------
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


def pb_decode(buf, depth=0, maxdepth=4):
    """返回 [(field_no, wire_type, value)]；value 对 len 类型尝试递归解 protobuf"""
    out = []
    i = 0
    n = len(buf)
    while i < n:
        key, i = read_varint(buf, i)
        if key is None:
            break
        fn = key >> 3
        wt = key & 7
        if fn == 0 or fn > 100000:
            break
        if wt == 0:
            v, i = read_varint(buf, i)
            if v is None:
                break
            out.append((fn, 0, v))
        elif wt == 2:
            ln, i = read_varint(buf, i)
            if ln is None or i + ln > n:
                break
            raw = buf[i:i + ln]
            i += ln
            sub = None
            if depth < maxdepth and ln > 0:
                try:
                    cand = pb_decode(raw, depth + 1, maxdepth)
                    # 判定"像 protobuf"：至少 1 个字段且能完整消费
                    if cand and cand[-1][3] == len(raw):
                        sub = cand
                except Exception:
                    sub = None
            out.append((fn, 2, raw if sub is None else sub, len(raw)))
        elif wt == 5:
            if i + 4 > n:
                break
            out.append((fn, 5, buf[i:i + 4].hex()))
            i += 4
        elif wt == 1:
            if i + 8 > n:
                break
            out.append((fn, 1, buf[i:i + 8].hex()))
            i += 8
        else:
            break
    return out


def pb_text(fields, indent=0, limit=6):
    pad = "  " * indent
    lines = []
    for it in fields[:limit]:
        fn, wt = it[0], it[1]
        if wt == 0:
            lines.append(f"{pad}#{fn}=v{it[2]}")
        elif wt == 2:
            sub, ln = it[2], it[3]
            if isinstance(sub, list):
                lines.append(f"{pad}#{fn}({ln}B):")
                lines.extend(pb_text(sub, indent + 1, limit))
            else:
                try:
                    s = sub.decode("utf-8")
                    printable = all(32 <= ord(c) < 127 for c in s) and len(s) > 0
                except Exception:
                    printable = False
                if printable:
                    lines.append(f"{pad}#{fn}='{s}'")
                else:
                    lines.append(f"{pad}#{fn}({ln}B)=hex:{sub[:16].hex()}")
        else:
            lines.append(f"{pad}#{fn}=hex:{it[2]}")
    if len(fields) > limit:
        lines.append(f"{pad}... (+{len(fields)-limit} fields)")
    return lines


# ---------- 抓取字段 ----------
def tshark_fields(pcap, display_filter, fields):
    cmd = [TSHARK, "-r", pcap]
    if display_filter:
        cmd += ["-Y", display_filter]
    for f in fields:
        cmd += ["-e", f]
    cmd += ["-T", "fields"]
    p = subprocess.run(cmd, capture_output=True, text=True, errors="replace")
    rows = []
    for line in p.stdout.splitlines():
        if not line.strip():
            continue
        rows.append(line.split("\t"))
    return rows


def parse_tcp(pcap):
    rows = tshark_fields(pcap, "tcp.len>0",
                         ["frame.number", "ip.src", "tcp.srcport", "ip.dst", "tcp.dstport", "data.data"])
    msgs = []
    for r in rows:
        if len(r) < 6 or not r[5]:
            continue
        try:
            blob = bytes.fromhex(r[5])
        except Exception:
            continue
        i = 0
        while i + 4 <= len(blob):
            ln = int.from_bytes(blob[i:i + 4], "big")
            if ln <= 0 or i + 4 + ln > len(blob):
                break
            body = blob[i + 4:i + 4 + ln]
            i += 4 + ln
            # APC {1: id, 2: content}
            fields = pb_decode(body)
            api_id = None
            content = b""
            for f in fields:
                if f[0] == 1 and f[1] == 0:
                    api_id = f[2]
                elif f[0] == 2 and f[1] == 2 and isinstance(f[2], bytes):
                    content = f[2]
            msgs.append({
                "frame": r[0], "from": r[1], "sp": r[2], "to": r[3], "dp": r[4],
                "len": ln, "method": api_id, "content": content.hex(),
                "content_pb": pb_text(pb_decode(content), 0, 8) if content else [],
            })
    return msgs


def parse_udp(pcap):
    rows = tshark_fields(pcap, "udp",
                         ["frame.number", "ip.src", "udp.srcport", "ip.dst", "udp.dstport", "data.data"])
    up, down = [], []
    for r in rows:
        if len(r) < 6 or not r[5]:
            continue
        try:
            b = bytes.fromhex(r[5])
        except Exception:
            continue
        if len(b) < 8:
            continue
        ln = int.from_bytes(b[0:4], "big")
        conn = int.from_bytes(b[4:8], "big", signed=True)
        d = {"frame": r[0], "len": ln, "conn": conn, "total": len(b),
             "src": r[1], "sp": r[2], "dst": r[3], "dp": r[4], "head": b[8:24].hex()}
        if r[2] == "1960":       # 服务端 -> 客户端
            d["app"] = b[8]
            d["pb"] = pb_text(pb_decode(b[16:]), 0, 5)
            down.append(d)
        else:
            up.append(d)
    return up, down


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return
    pcap = sys.argv[1]
    if not os.path.exists(pcap):
        print("no such pcap:", pcap)
        return

    if "--tcp" in sys.argv:
        msgs = parse_tcp(pcap)
        print(f"TCP APC messages: {len(msgs)}")
        cnt = collections.Counter(m["method"] for m in msgs)
        print("method id 分布:", dict(sorted(cnt.items(), key=lambda x: -x[1])))
        for m in msgs:
            print(f"\n[{m['frame']}] {m['from']}:{m['sp']} -> {m['to']}:{m['dp']}  len={m['len']}  method={m['method']}")
            for l in m["content_pb"]:
                print("   ", l)
        return

    if "--udp" in sys.argv:
        up, down = parse_udp(pcap)
        print(f"UDP 上行 {len(up)} / 下行 {len(down)}")
        if up:
            print("\n上行样例（前 5）:")
            for d in up[:5]:
                print(f"  [{d['frame']}] len={d['len']} conn={d['conn']} head={d['head']}")
        if down:
            print("\n下行样例（前 3）:")
            for d in down[:3]:
                print(f"  [{d['frame']}] len={d['len']} conn={d['conn']} app={d['app']} head={d['head']}")
                for l in d["pb"]:
                    print("     ", l)
        return

    # 总览
    print("=" * 60)
    print("pcap:", pcap)
    msgs = parse_tcp(pcap)
    up, down = parse_udp(pcap)
    print(f"TCP APC 消息 {len(msgs)} 条 | UDP 上行 {len(up)} / 下行 {len(down)}")
    if msgs:
        cnt = collections.Counter(m["method"] for m in msgs)
        print("TCP method id:", dict(sorted(cnt.items(), key=lambda x: -x[1])))
    print("\n--- TCP 前 6 条 ---")
    for m in msgs[:6]:
        print(f"[{m['frame']}] method={m['method']} len={m['len']}")
        for l in m["content_pb"]:
            print("   ", l)
    print("\n--- UDP 上行前 3 条 ---")
    for d in up[:3]:
        print(f"  len={d['len']} conn={d['conn']} head={d['head']}")
    print("\n--- UDP 下行前 2 条 ---")
    for d in down[:2]:
        print(f"  len={d['len']} conn={d['conn']} app={d['app']}")
        for l in d["pb"]:
            print("     ", l)

    if "--json" in sys.argv:
        idx = sys.argv.index("--json")
        out = sys.argv[idx + 1] if idx + 1 < len(sys.argv) else "parse.json"
        json.dump({"tcp": msgs, "udp_up": up, "udp_down": down},
                  open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print("\njson ->", out)


if __name__ == "__main__":
    main()
