"""解大厅加密资源（定稿）：FairyGUI 布局 XML 的解密/解压。

swfDecode 算法（FlasCC 字节码反编译，见 wdnative/lobby_decoder/swfDecode.as）：
    每 1024 字节块的偏移 91（0x5B）字节被 XOR 一个密钥字节，其余字节不动，
    然后整体是标准 zlib 流。
    密钥表在 .rodata（符号 L__2E_str324），6 字节，按块序号倒序循环使用。

求解方式：逐块暴力 256 个候选，判据 = 完整解压(eof) > 连续可打印长度。
小文件可完全还原；大文件若尾部信息不足，个别块的密钥可能落在等价类里，
但解出的 XML 主体（所有控件的 name/x/y/width/height/skin）均正确，
只有文件头几个属性字节可能偏差，不影响布局复现。
"""
import zlib, sys, os

BLOCK = 1024
OFF = 91


def try_decompress(data):
    """分片解压，返回 (输出, eof)。分片是为了在出错时保留已解出内容。"""
    d = zlib.decompressobj()
    out = bytearray()
    for i in range(0, len(data), 256):
        try:
            out += d.decompress(bytes(data[i : i + 256]))
        except Exception:
            return bytes(out), False
        if d.eof:
            return bytes(out), True
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


def decode(raw, known=None):
    known = known or {}
    data = bytearray(raw)
    keys = {}
    for pos, ki in positions_of(len(data)):
        if ki in known:
            data[pos] ^= known[ki]
            keys[ki] = known[ki]
            continue
        best, best_s = 0, -1
        orig = data[pos]
        for k in range(256):
            data[pos] = orig ^ k
            out, eof = try_decompress(bytes(data))
            s = (10_000_000 if eof else 0) + clean_len(out) * 10 + len(out)
            if s > best_s:
                best_s, best = s, k
        data[pos] = orig ^ best
        keys[ki] = best
    out, eof = try_decompress(bytes(data))
    return out, keys, eof


def main():
    known = {}
    # 用法: decode_lobby_res.py [--key5=N] file...
    args = []
    for a in sys.argv[1:]:
        if a.startswith("--key"):
            k, v = a[2:].split("=")
            known[int(k[3:])] = int(v)
        else:
            args.append(a)
    for path in args:
        raw = open(path, "rb").read()
        out, keys, eof = decode(raw, known)
        good = out.startswith(b"<")
        print(f"{'OK ' if good else 'BAD'} {os.path.basename(path):32s} {len(raw):>7} -> {len(out):>7} eof={eof} keys={keys}")
        if good and not path.endswith(".dec.xml"):
            dst = path.replace(".xml", ".dec.xml")
            open(dst, "wb").write(out)


if __name__ == "__main__":
    main()
