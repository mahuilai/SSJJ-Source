# -*- coding: utf-8 -*-
"""把 AIR 大厅客户端上报的日志批次还原成完整时间线。

背景（踩过的坑）：
  客户端通过 `addHallLog` POST 到网关，body 里是 URL 编码的 `log=` 字段。
  该字段是**增量**的：每一批只带几行新日志，不是累积缓冲。
  直接取最后一批（或把批次简单拼接）都会得到残缺甚至重复的时间线，
  据此下的结论会错得很自然 —— 必须按顺序解码、去重、还原成一条时间线。

用法:
    python tools/lobby_client_log.py                      # 写到 Game-SSJJ-logs/client_full.log
    python tools/lobby_client_log.py --tail 40            # 顺便打印末尾 40 行
    python tools/lobby_client_log.py --grep "callBack:|load bytes"   # 只打印匹配行
"""
import argparse
import os
import re
import sys
import urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_SRC = os.path.join(ROOT, 'Game-SSJJ-logs', 'gateway.log')
DEFAULT_OUT = os.path.join(ROOT, 'Game-SSJJ-logs', 'client_full.log')


def decode_blobs(src):
    if not os.path.isfile(src):
        return []
    raw = open(src, 'r', encoding='utf-8', errors='replace').read()
    out = []
    for m in re.finditer(r'log=([^&\r\n]+)', raw):
        try:
            txt = urllib.parse.unquote(m.group(1))
        except Exception:
            continue
        out.append([ln.strip() for ln in txt.splitlines() if ln.strip()])
    return out


def merge(blobs):
    """按顺序合并批次，去掉与上一批重叠的前缀。

    客户端偶尔会重发包含旧行的批次；只做「整批去重」会丢真实重复行，
    所以只合并「本批开头 == 已积累尾部」的已知重叠，其余原样保留。
    """
    merged = []
    for b in blobs:
        if not b:
            continue
        overlap = 0
        maxk = min(len(b), len(merged))
        for k in range(maxk, 0, -1):
            if merged[-k:] == b[:k]:
                overlap = k
                break
        merged.extend(b[overlap:])
    return merged


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--src', default=DEFAULT_SRC)
    ap.add_argument('--out', default=DEFAULT_OUT)
    ap.add_argument('--tail', type=int, default=0)
    ap.add_argument('--grep', default='')
    a = ap.parse_args()

    blobs = decode_blobs(a.src)
    lines = merge(blobs)
    print(f'批次: {len(blobs)}  合并后行数: {len(lines)}')
    if not lines:
        print('（没有可解码的日志；确认网关在跑且客户端已上报）')
        return 2
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    with open(a.out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print(f'已写: {a.out}')

    if a.grep:
        pat = re.compile(a.grep)
        hit = [ln for ln in lines if pat.search(ln)]
        print(f'--grep 命中 {len(hit)} 行')
        for ln in hit[-60:]:
            print('  ' + ln)
    elif a.tail:
        print(f'-- 末尾 {a.tail} 行 --')
        for ln in lines[-a.tail:]:
            print('  ' + ln)
    return 0


if __name__ == '__main__':
    sys.exit(main())
