# -*- coding: utf-8 -*-
"""SWF 结构/Tag 检查器（M2 大厅资源取证用）

用途：判定某个 SWF 里到底有哪些 Tag、SymbolClass 关联了哪些类、DoABC 叫什么，
用于回答「DoABC 被剥离后，类定义是否也一起丢了」这类问题。

正确解析要点（之前踩过坑）：
  - 8 字节头之后先是一个 RECT（位压缩，长度 = ceil((5 + 4*nbits)/8)），
    漏掉它会让后面所有 tag 解析错位。
  - tag 头 2 字节：code = h >> 6，len = h & 0x3F；len == 0x3F 时后续 4 字节才是真长度。

用法:
    python tools/swf_tags.py A.swf
    python tools/swf_tags.py A.swf B.swf --diff
    python tools/swf_tags.py A.swf --json
"""
import argparse
import json
import struct
import sys
import zlib

TAG_NAMES = {
    0: 'End', 1: 'ShowFrame', 9: 'SetBackgroundColor', 12: 'DoAction',
    39: 'DefineSprite', 43: 'FrameLabel', 59: 'DoInitAction',
    65: 'ScriptLimits', 69: 'FileAttributes', 70: 'PlaceObject2',
    72: 'DoABC1', 76: 'SymbolClass', 82: 'DoABC', 77: 'Metadata',
    86: 'DefineSceneAndFrameLabelData', 88: 'DefineFontName',
}


def parse(path):
    b = open(path, 'rb').read()
    sig = b[:3]
    ver = b[3]
    flen = struct.unpack('<I', b[4:8])[0]
    out = {'path': path, 'sig': sig.decode('latin1'), 'version': ver,
           'header_len': flen, 'file_bytes': len(b), 'truncated': False,
           'tags': {}, 'symbols': [], 'abcs': []}
    if sig == b'CWS':
        try:
            body = zlib.decompress(b[8:])
        except Exception as e:
            out['error'] = f'zlib: {e}'
            return out
    elif sig == b'FWS':
        body = b[8:]
    else:
        out['error'] = f'bad sig {sig!r}'
        return out
    out['decoded_bytes'] = len(body) + 8
    out['truncated'] = out['decoded_bytes'] < flen

    if len(body) < 5:
        out['error'] = 'body too short'
        return out
    # RECT
    nbits = body[0] >> 3
    rect_bytes = (5 + 4 * nbits + 7) // 8
    i = rect_bytes + 4          # RECT + frameRate(2) + frameCount(2)
    while i + 2 <= len(body):
        h = struct.unpack('<H', body[i:i + 2])[0]
        code = h >> 6
        ln = h & 0x3F
        i += 2
        if ln == 0x3F:
            if i + 4 > len(body):
                break
            ln = struct.unpack('<I', body[i:i + 4])[0]
            i += 4
        payload = body[i:i + ln]
        name = TAG_NAMES.get(code, str(code))
        out['tags'][name] = out['tags'].get(name, 0) + 1

        if code == 76 and len(payload) >= 2:          # SymbolClass
            n = struct.unpack('<H', payload[:2])[0]
            p = 2
            for _ in range(n):
                if p + 2 > len(payload):
                    break
                sid = struct.unpack('<H', payload[p:p + 2])[0]
                p += 2
                e = payload.find(b'\x00', p)
                if e < 0:
                    break
                cls = payload[p:e].decode('utf-8', 'replace')
                p = e + 1
                out['symbols'].append({'id': sid, 'class': cls})
        elif code in (72, 82) and len(payload) >= 4:  # DoABC / DoABC1
            nm = payload[4:].split(b'\x00', 1)[0].decode('utf-8', 'replace')
            out['abcs'].append(nm)
        i += ln
        if code == 0:
            break
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('files', nargs='+')
    ap.add_argument('--json', action='store_true')
    ap.add_argument('--diff', action='store_true')
    ap.add_argument('--show-symbols', action='store_true')
    a = ap.parse_args()

    res = [parse(f) for f in a.files]
    if a.json:
        print(json.dumps(res, ensure_ascii=False, indent=1))
    else:
        for r in res:
            print(f"== {r['path']}")
            print(f"   sig={r['sig']} v{r['version']} file={r['file_bytes']} "
                  f"header_len={r['header_len']} decoded={r.get('decoded_bytes')} "
                  f"truncated={r['truncated']}")
            if 'error' in r:
                print('   ERROR:', r['error']); continue
            print('   tags:', ', '.join(f'{k}x{v}' for k, v in sorted(r['tags'].items())))
            print(f"   DoABC: {r['abcs'] or '(无)'}")
            print(f"   SymbolClass 条目: {len(r['symbols'])}")
            if a.show_symbols:
                for s in r['symbols'][:15]:
                    print(f"      {s['id']:>5}  {s['class']}")

    if a.diff and len(res) >= 2:
        print('\n== SymbolClass 类清单 diff')
        base = {s['class'] for s in res[0]['symbols']}
        for r in res[1:]:
            other = {s['class'] for s in r['symbols']}
            only_base = sorted(base - other)
            only_other = sorted(other - base)
            print(f"   {res[0]['path']} vs {r['path']}: "
                  f"前者独有 {len(only_base)}，后者独有 {len(only_other)}")
            for c in only_base[:15]:
                print('      仅前者有:', c)
            for c in only_other[:15]:
                print('      仅后者有:', c)
    return 0


if __name__ == '__main__':
    sys.exit(main())
