"""批量解码大厅 FairyGUI 布局，靠全局密钥表 + 多文件投票求稳。

swfDecode 的六个密钥字节对所有资源是同一张表（.rodata 里的 L__2E_str324），
所以不必每个文件独立暴力：先解只用 keyTable[5] 的文件（blocks==0），
再依次解 keyTable[4..0]，每一步用已有 key + 候选 key 试 256 次，
所有能解到的文件各自给出候选，取众数。
"""
import zlib, sys, os, json, collections

BLOCK = 1024
OFF = 91


def try_decompress(data, cap=400_000):
    d = zlib.decompressobj()
    out = bytearray()
    for i in range(0, len(data), 512):
        try:
            out += d.decompress(bytes(data[i : i + 512]))
        except Exception:
            return bytes(out), False
        if d.eof or len(out) > cap:
            return bytes(out), d.eof
    try:
        out += d.flush()
    except Exception:
        pass
    return bytes(out), d.eof


def clean_len(out):
    n = 0
    for b in out:
        if b in (9, 10, 13) or 32 <= b <= 126:
            n += 1
        else:
            break
    return n


def positions_of(n):
    blocks = n // BLOCK
    out = [(i * BLOCK + OFF, 5 - (i % 6)) for i in range(blocks)]
    if n - blocks * BLOCK > OFF:
        out.append((blocks * BLOCK + OFF, 5 - (blocks % 6)))
    return out


def score(out, eof):
    return (10_000_000 if eof else 0) + clean_len(out) * 10 + len(out)


def solve_table(files):
    """files: [(name, raw)] -> (table, decode_fn)"""
    table = [None] * 6

    def build(raw, override=None):
        """按当前 table 应用已解出的 key，override 用于试当前候选。"""
        data = bytearray(raw)
        for pos, ki in positions_of(len(data)):
            v = table[ki] if ki != (override or (None, None))[0] else override[1]
            if v is not None:
                data[pos] ^= v
        return data

    for ki_target in [5, 4, 3, 2, 1, 0]:
        votes = collections.Counter()
        for name, raw in files:
            poss = positions_of(len(raw))
            if not any(ki == ki_target for _, ki in poss):
                continue
            # 该文件里 ki_target 之后（更早就用到的）都必须已知，否则跳过
            need = [ki for _, ki in poss if ki > ki_target]
            if any(table[k] is None for k in need):
                continue
            best, best_s = None, -1
            for k in range(256):
                data = build(raw, (ki_target, k))
                out, eof = try_decompress(bytes(data))
                s = score(out, eof)
                if s > best_s:
                    best_s, best = s, k
            votes[best] += 1
        if votes:
            top = votes.most_common(1)[0][0]
            table[ki_target] = top
            print(f"  keyTable[{ki_target}] = {top}  (votes {votes.most_common(3)})")
        else:
            print(f"  keyTable[{ki_target}] = 无可用样本，跳过")
    return table


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\view_all"
    dst = sys.argv[2] if len(sys.argv) > 2 else r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\view_dec"
    os.makedirs(dst, exist_ok=True)
    files = []
    for fn in sorted(os.listdir(src)):
        if fn.endswith(".xml") and not fn.endswith(".dec.xml"):
            files.append((fn, open(os.path.join(src, fn), "rb").read()))
    print(f"files={len(files)}")
    table = solve_table(files)
    print("keyTable:", table)

    ok = bad = 0
    for name, raw in files:
        data = bytearray(raw)
        for pos, ki in positions_of(len(data)):
            if table[ki] is not None:
                data[pos] ^= table[ki]
        out, eof = try_decompress(bytes(data))
        if out.startswith(b"<"):
            open(os.path.join(dst, name.replace(".xml", ".dec.xml")), "wb").write(out)
            ok += 1
        else:
            bad += 1
    print(f"decoded ok={ok} bad={bad} -> {dst}")
    json.dump([table[i] for i in range(6)], open(os.path.join(dst, "keytable.json"), "w"))


if __name__ == "__main__":
    main()
