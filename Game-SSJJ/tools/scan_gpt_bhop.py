# -*- coding: utf-8 -*-
"""读 GPT 在 OfflineBotPhysics 的 airAccel/bhop 实现 + 找调用点，输出到文件。"""
import io, re, os

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\gpt_bhop_state.txt'
os.makedirs(os.path.dirname(OUT), exist_ok=True)

buf = []
phys = io.open(os.path.join(ROOT, 'OfflineBotPhysics.cs'), encoding='utf-8', errors='surrogatepass').read()
ai = io.open(os.path.join(ROOT, 'OfflineBotAI.cs'), encoding='utf-8', errors='surrogatepass').read()
gp = io.open(os.path.join(ROOT, 'OfflineGameplay.cs'), encoding='utf-8', errors='surrogatepass').read()

def dump(s, kw, name, n=4, w=200):
    idxs = [m.start() for m in re.finditer(re.escape(kw), s)]
    buf.append('### %s [%s] (%d 处)' % (name, kw, len(idxs)))
    for i in idxs[:n]:
        ln = s[:i].count('\n') + 1
        buf.append('   L%-6d %s' % (ln, s[max(0,i-w):i+w].replace('\n',' | ')[:2*w+30]))
    buf.append('')

buf.append('===== OfflineBotPhysics.cs (%d 行) =====' % phys.count('\n'))
# 方法清单
for m in re.finditer(r'(public|private|internal)\s+(static\s+)?[\w<>\[\],\s]+?\s+(\w+)\s*\(', phys):
    ln = phys[:m.start()].count('\n') + 1
    buf.append('   L%-5d %s' % (ln, m.group(0).strip()[:80]))
buf.append('')
dump(phys, 'ApplyAirAcceleration', 'phys')
dump(phys, 'airSpeed', 'phys')
dump(phys, 'AirStrafing', 'phys')
dump(phys, 'wishDir', 'phys')

# AI 侧 bhop 字段
buf.append('')
buf.append('===== OfflineBotAI.cs bhop 相关 (%d 行) =====' % ai.count('\n'))
dump(ai, 'Bhop', 'ai')
dump(ai, 'BhopUntil', 'ai')
dump(ai, 'BhopBias', 'ai')
dump(ai, 'UseBhop', 'ai')
dump(ai, 'AirBoost', 'ai')

# BotProfile 定义
i = ai.find('class BotProfile')
if i < 0: i = ai.find('BotProfile {')
if i > 0:
    buf.append('')
    buf.append('===== BotProfile 定义（前 3000 字符）=====')
    buf.append(ai[i:i+3000])

# Gameplay 侧消费
buf.append('')
buf.append('===== OfflineGameplay.cs 消费点 =====' % ())
dump(gp, 'ApplyAirAcceleration', 'gp')
dump(gp, 'Bhop', 'gp', n=6)
dump(gp, 'it.AirBoost', 'gp', n=4)
dump(gp, 'JumpDuck', 'gp', n=4)

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT, len(buf), 'lines')
