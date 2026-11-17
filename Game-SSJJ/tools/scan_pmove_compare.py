# -*- coding: utf-8 -*-
"""抓 BOT-MOVE 日志 + 读原版玩家移动入口（UserCommandInitSystem/PlayerMovePredicationSystem）。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\pmove_compare.txt'
buf = []

# 1) 日志实况
s = io.open(LOG, encoding='utf-8', errors='replace').read()
sums = [m.start() for m in re.finditer(r'spawn summary', s)]
seg = s[sums[-1]:] if sums else s
mv = re.findall(r'\[OFFLINE-BOT-MOVE\][^\n]*', seg)
buf.append('===== [OFFLINE-BOT-MOVE] 本局 %d 条 =====' % len(mv))
for m in mv[:14]:
    buf.append('  ' + m.strip()[:150])
buf.append('')
# adapter 创建日志
ad = re.findall(r'\[OFFLINE-BOT-MOVE\] id=\d+ (created|adapter)[^\n]*', seg)
buf.append('adapter 创建: %d 条' % len(ad))
buf.append('')

# 2) 原版玩家移动链：谁调 SetMove
buf.append('===== SetMove 调用点（全 Decompiled）=====')
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: t = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        for m in re.finditer(r'\.SetMove\(', t):
            ln = t[:m.start()].count('\n') + 1
            seg2 = t[max(0,m.start()-420):m.start()+120].replace('\n', ' | ')
            buf.append('%s L%d:' % (f, ln))
            buf.append('   ...%s' % seg2[-500:])
            buf.append('')
buf.append('')

# 3) IPyMove 接口定义
buf.append('===== IPyMove / IPyPlayerMove 接口 =====')
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: t = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        if 'interface IPyMove' in t or 'interface IPyPlayerMove' in t:
            buf.append('--- %s' % f)
            i = t.find('interface IPy')
            buf.append(t[i:i+1500])
            buf.append('')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
