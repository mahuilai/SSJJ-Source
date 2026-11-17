# -*- coding: utf-8 -*-
"""查 UpdateEntityNormalBrush 签名 + PyPlayerAdapter 原版创建/初始化链。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\brush_init.txt'
buf = []

for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: t = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        # 1) UpdateEntityNormalBrush 定义与调用
        for m in re.finditer(r'UpdateEntityNormalBrush', t):
            ln = t[:m.start()].count('\n') + 1
            seg = t[max(0,m.start()-350):m.start()+250].replace('\n', ' | ')
            kind = 'DEF?' if ('void UpdateEntityNormalBrush' in t[max(0,m.start()-80):m.start()+80]) else 'CALL'
            buf.append('%-52s L%-6d [%s] %s' % (f, ln, kind, seg[:430]))
        # 2) PyPlayerAdapter 构造
        for m in re.finditer(r'new PyPlayerAdapter\(', t):
            ln = t[:m.start()].count('\n') + 1
            seg = t[max(0,m.start()-450):m.start()+400].replace('\n', ' | ')
            buf.append('')
            buf.append('>>> new PyPlayerAdapter  %s L%d' % (f, ln))
            buf.append('    ' + seg[:700])

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
