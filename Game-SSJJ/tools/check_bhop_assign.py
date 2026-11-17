# -*- coding: utf-8 -*-
"""1) 全量日志搜 BHOP-ASSIGN/BHOP/LOOKPLAYER（确认 easy 有没有分配）
   2) 输出 CS 机制对照结论"""
import io, re

LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'
s = io.open(LOG, encoding='utf-8', errors='replace').read()
out = []

# 按 spawn summary 切局
sums = [m.start() for m in re.finditer(r'spawn summary', s)]
out.append('spawn summary 总数: %d' % len(sums))
last_start = sums[-1] if sums else 0
seg = s[last_start:]
out.append('本局日志长度: %d' % len(seg))

for tag in ['OFFLINE-BHOP-ASSIGN', 'OFFLINE-BHOP]', 'OFFLINE-AIRACCEL', 'OFFLINE-LOOKPLAYER',
            'OFFLINE-DUCK]', 'OFFLINE-VELMOVE', 'OFFLINE-VISION']:
    ms = re.findall(r'\[' + tag.replace(']', '') + r'\][^\n]*', seg)
    out.append('%-22s 本局 %d 条' % (tag, len(ms)))
    for m in ms[:6]:
        out.append('    ' + m.strip()[:130])

# spawn 行
sp = re.findall(r'\[OFFLINE-BOT\] spawn id=\d+[^\n]*', seg)
out.append('')
out.append('本局 spawn (%d):' % len(sp))
for l in sp[:8]:
    out.append('  ' + l.strip()[:150])

# 难度
d = re.findall(r'bot_difficulty[^,\n]*', s)
out.append('')
out.append('难度配置痕迹: %s' % (d[-1] if d else '(无)'))

io.open(r'D:\逆向\SSJJ双塔惊魂\_work\bhop_whyzero.txt', 'w', encoding='utf-8').write('\n'.join(out))
print('\n'.join(out))
