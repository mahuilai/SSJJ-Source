# -*- coding: utf-8 -*-
"""找「快照 LegsAnim -> 实体 legAnim 组件」的写入系统 + SnapsotServerTime/Next 的维护者。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\leg_write.txt'
buf = []

pats = [
    r'legAnim\.LegsAnimInfo\s*=', r'\.LegsAnimInfo\s*=\s*',
    r'SetLegsAnimation', r'LegsAnim\s*=\s*',
    r'SnapsotServerTime\s*=', r'basicInfo\.Next\s*=', r'\.Next\.X\s*=',
    r'LegsSpeedAnimTime\s*=',
]
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: t = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        for pat in pats:
            for m in re.finditer(pat, t):
                ln = t[:m.start()].count('\n') + 1
                # 跳过 200 行以上的大文件噪音，只保留关键段
                seg = t[max(0, m.start()-220):m.start()+180].replace('\n', ' | ')
                buf.append('%-46s L%-6d [%s]' % (f, ln, pat.strip('\\')))
                buf.append('    %s' % seg[:340])

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT, '|', len(buf), 'lines')
