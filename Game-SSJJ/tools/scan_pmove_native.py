# -*- coding: utf-8 -*-
"""读原版：FixSpeed / GetPmove / UpdateEntityNormalBrush 用法 + GetBotPmove 实现。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\pmove_native.txt'
buf = []

def read(f):
    for dp, dn, fn in os.walk(ROOT):
        if f in fn:
            return io.open(os.path.join(dp, f), encoding='utf-8', errors='surrogatepass').read()
    return None

# 1) FixSpeed
pms = read('PlayerMovePredicationSystem.cs')
if pms:
    i = pms.find('private void FixSpeed')
    if i < 0: i = pms.find('void FixSpeed')
    buf.append('===== FixSpeed =====')
    buf.append(pms[i:i+1200] if i > 0 else '(not found)')
    buf.append('')
    # GetPmove / UpdateEntityNormalBrush 用法
    buf.append('===== UpdateEntityNormalBrush / GetPmove 用法（PlayerMovePredicationSystem）=====')
    for kw in ['UpdateEntityNormalBrush', 'GetPmove', 'new PyPlayerAdapter', 'PyPlayerMove =']:
        for m in list(re.finditer(re.escape(kw), pms))[:3]:
            ln = pms[:m.start()].count('\n') + 1
            buf.append('L%d [%s]: %s' % (ln, kw, pms[max(0,m.start()-300):m.start()+200].replace('\n',' | ')[:480]))
            buf.append('')
    # MoveButtonsNeedToBeClear 相关（按钮门控）
    i = pms.find('MoveButtonsNeedToBe')
    buf.append('===== MoveButtonsNeedToBeClear =====')
    buf.append(pms[i:i+900] if i > 0 else '(not found)')

buf.append('')
buf.append('===== GetBotPmove 实现（OfflineGameplay）=====')
gp = read('OfflineGameplay.cs')
if gp:
    i = gp.find('GetBotPmove')
    if i > 0:
        buf.append(gp[max(0,i-200):i+1500])

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
