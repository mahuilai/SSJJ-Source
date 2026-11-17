# -*- coding: utf-8 -*-
"""读 ExecuteBotMove 完整体：确认走 BspStep 还是 DirectStep。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
gp = io.open(os.path.join(ROOT, 'OfflineGameplay.cs'), encoding='utf-8', errors='surrogatepass').read()

OUT = r'D:\逆向\SSJJ双塔惊魂\_work\move_branch.txt'
buf = []

def extract(s, sig, span=3500):
    i = s.find(sig)
    if i < 0: return '(not found: %s)' % sig
    return s[i:i+span]

buf.append('===== ExecuteBotMove 完整体 =====')
buf.append(extract(gp, 'private void ExecuteBotMove', 4500))
buf.append('')
buf.append('===== ExecuteBotBspStep 调用点 =====')
for m in re.finditer(r'ExecuteBotBspStep\(', gp):
    ln = gp[:m.start()].count('\n') + 1
    buf.append('L%d' % ln)
buf.append('')
buf.append('===== DirectStep 调用点 =====')
for m in re.finditer(r'DirectStep\(', gp):
    ln = gp[:m.start()].count('\n') + 1
    buf.append('L%d  %s' % (ln, gp[max(0,m.start()-200):m.start()+80].replace('\n',' | ')[:260]))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
