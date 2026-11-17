# -*- coding: utf-8 -*-
"""确认 PlayerSpeedUtil.GetPlayerSpeed 签名/可访问性 + bot 的 ReferencePlayerSpeed 现状。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\psu_check.txt'
buf = []

for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if 'PlayerSpeedUtil' not in f: continue
        p = os.path.join(dp, f)
        t = io.open(p, encoding='utf-8', errors='ignore').read()
        buf.append('===== %s =====' % p)
        i = t.find('class PlayerSpeedUtil')
        buf.append(t[i:i+2500] if i > 0 else t[:1500])
        buf.append('')

# ReferencePlayerSpeed 现状
gp = None
for dp, dn, fn in os.walk(ROOT):
    if 'OfflineGameplay.cs' in fn:
        gp = os.path.join(dp, 'OfflineGameplay.cs')
if gp:
    t = io.open(gp, encoding='utf-8', errors='surrogatepass').read()
    i = t.find('private float ReferencePlayerSpeed')
    if i > 0:
        buf.append('===== ReferencePlayerSpeed（当前）=====')
        buf.append(t[i:i+900])

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
