# -*- coding: utf-8 -*-
"""1) PlayerMovePredicationSystem 的 speed 初始值来源
   2) SyncOfflineAnimStates 完整体（leg/跳/蹲分支）"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\speed_anim2.txt'
buf = []

def read(f):
    for dp, dn, fn in os.walk(ROOT):
        if f in fn:
            return io.open(os.path.join(dp, f), encoding='utf-8', errors='surrogatepass').read()
    return None

pms = read('PlayerMovePredicationSystem.cs')
if pms:
    buf.append('===== speed 赋值点 =====')
    for m in re.finditer(r'\bspeed\s*=', pms):
        ln = pms[:m.start()].count('\n') + 1
        buf.append('L%-6d %s' % (ln, pms[max(0,m.start()-260):m.start()+120].replace('\n',' | ')[:360]))
    buf.append('')
    buf.append('===== GetSpeed / MaxSpeed 相关 =====')
    for kw in ['GetSpeed', 'MaxSpeed', 'MoveSpeed', 'GetMoveSpeed']:
        for m in list(re.finditer(re.escape(kw), pms))[:4]:
            ln = pms[:m.start()].count('\n') + 1
            buf.append('L%-6d [%s] %s' % (ln, kw, pms[max(0,m.start()-180):m.start()+140].replace('\n',' | ')[:300]))

buf.append('')
ctrl = read('OfflineGameController.cs')
if ctrl:
    i = ctrl.find('private void SyncOfflineAnimStates')
    if i < 0: i = ctrl.find('void SyncOfflineAnimStates')
    if i > 0:
        # 花括号配对取完整体
        j = ctrl.find('{', i); depth = 0; p = j
        while p < len(ctrl):
            if ctrl[p] == '{': depth += 1
            elif ctrl[p] == '}':
                depth -= 1
                if depth == 0: break
            p += 1
        buf.append('===== SyncOfflineAnimStates 完整体 =====')
        buf.append(ctrl[i:p+1])
    else:
        buf.append('SyncOfflineAnimStates not found; 搜 LegsAnim 合成:')
        for m in list(re.finditer(r'LegsAnim\s*=', ctrl))[:10]:
            ln = ctrl[:m.start()].count('\n') + 1
            buf.append('L%-6d %s' % (ln, ctrl[max(0,m.start()-200):m.start()+80].replace('\n',' | ')[:280]))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
