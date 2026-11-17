# -*- coding: utf-8 -*-
"""PlayerInfo.cs 不在 Decompiled 根——全盘定位。"""
import io, os, re, glob

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\viewpitch_check.txt'
buf = []

hits = glob.glob(os.path.join(ROOT, '**', 'PlayerInfo.cs'), recursive=True)
buf.append('PlayerInfo.cs 位置: %s' % hits)
for p in hits:
    s = io.open(p, encoding='utf-8', errors='surrogatepass').read()
    buf.append('===== %s（前 100 行）=====' % p)
    buf.append('\n'.join(s.split('\n')[:100]))
    buf.append('')

# PlayerEntityData 定义
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: s = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        for m in re.finditer(r'(class|interface|struct)\s+PlayerEntityData', s):
            ln = s[:m.start()].count('\n') + 1
            buf.append('PlayerEntityData 定义: %s L%d' % (os.path.basename(p), ln))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
