# -*- coding: utf-8 -*-
"""查 SSJJPhysics.Pmove 类：构造/Init/SetEntity 等（含 Game source 全量源码）。"""
import io, os, re

ROOTS = [r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets',
         r'D:\逆向\SSJJ双塔惊魂\Game source\02_managed_src']
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\pmove_class.txt'
buf = []

found = []
for root in ROOTS:
    if not os.path.isdir(root): continue
    for dp, dn, fn in os.walk(root):
        for f in fn:
            if f == 'Pmove.cs':
                found.append(os.path.join(dp, f))

buf.append('Pmove.cs 位置: %s' % found)
for p in found:
    t = io.open(p, encoding='utf-8', errors='surrogatepass').read()
    buf.append('')
    buf.append('===== %s (%d 行) =====' % (p, t.count('\n')))
    # 类声明 + 公开成员
    for m in re.finditer(r'public\s+(static\s+)?[\w<>\[\],\.\s]+?\s+(\w+)\s*[\({]', t):
        ln = t[:m.start()].count('\n') + 1
        buf.append('  L%-5d %s' % (ln, m.group(0).strip()[:90]))
    # 构造函数
    i = t.find('public Pmove(')
    if i > 0:
        buf.append('')
        buf.append('--- 构造函数 ---')
        buf.append(t[i:i+1200])
    # 关键方法 IsOnGround / SetMove / 内部状态
    for kw in ['IsOnGround', 'SetMove', 'GetEntity', 'Init', '_velocity', 'Reset']:
        j = t.find(kw)
        if j > 0:
            ln = t[:j].count('\n') + 1
            buf.append('--- [%s] L%d' % (kw, ln))
            buf.append(t[max(0,j-200):j+700])
            buf.append('')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
