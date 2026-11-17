# -*- coding: utf-8 -*-
"""读 bhop 核心实现完整体：ApplyAirAcceleration / ApplyVertical / BspStep 跳跃段 / lookPlayer 逻辑。"""
import io, os

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\bhop_impl_full.txt'
os.makedirs(os.path.dirname(OUT), exist_ok=True)

phys = io.open(os.path.join(ROOT, 'OfflineBotPhysics.cs'), encoding='utf-8', errors='surrogatepass').read()
gp = io.open(os.path.join(ROOT, 'OfflineGameplay.cs'), encoding='utf-8', errors='surrogatepass').read()
ai = io.open(os.path.join(ROOT, 'OfflineBotAI.cs'), encoding='utf-8', errors='surrogatepass').read()

buf = []

# 1) ApplyAirAcceleration 完整体（方法级花括号配对）
def extract_method(s, sig):
    i = s.find(sig)
    if i < 0: return '(not found: %s)' % sig
    # 回退到方法注释起点
    start = i
    depth = 0
    j = s.find('{', i)
    p = j
    while p < len(s):
        if s[p] == '{': depth += 1
        elif s[p] == '}':
            depth -= 1
            if depth == 0: break
        p += 1
    return s[start:p+1]

buf.append('################ OfflineBotPhysics.ApplyAirAcceleration ################')
buf.append(extract_method(phys, 'public static Vector3 ApplyAirAcceleration'))
buf.append('')
buf.append('################ OfflineBotPhysics.ApplyVertical ################')
buf.append(extract_method(phys, 'public static bool ApplyVertical'))
buf.append('')
buf.append('################ OfflineBotPhysics.IsAirborne ################')
buf.append(extract_method(phys, 'public static bool IsAirborne'))
buf.append('')

# 2) BspStep 的 bhop 段（L1690-1760 区域）
buf.append('################ ExecuteBotBspStep bhop 段 ################')
i = gp.find('private void ExecuteBotBspStep')
seg = gp[i:i+4200]
buf.append(seg)
buf.append('')

# 3) lookPlayer 在 AI/Gameplay 的现状
buf.append('################ lookPlayer 现状 ################')
for name, s in [('Gameplay', gp), ('AI', ai)]:
    idx = s.find('lookPlayer')
    while idx >= 0:
        ln = s[:idx].count('\n') + 1
        buf.append('%s L%d: %s' % (name, ln, s[max(0,idx-150):idx+150].replace('\n',' | ')[:300]))
        idx = s.find('lookPlayer', idx+1)
buf.append('')

# 4) BotIntent 结构（看盯玩家需要的字段在不在）
buf.append('################ BotIntent 定义 ################')
i = ai.find('struct BotIntent')
if i < 0: i = ai.find('class BotIntent')
buf.append(ai[i:i+1200] if i > 0 else '(not found)')
buf.append('')

# 5) ViewYaw/AimYaw 在非交战/无目标时怎么走
buf.append('################ AI Tick 无目标/巡逻朝向 ################')
for kw in ['SearchState', 'Patrol', 'LookAt', 'FaceTo', 'ViewYaw =']:
    j = ai.find(kw)
    if j > 0:
        ln = ai[:j].count('\n') + 1
        buf.append('--- [%s] L%d' % (kw, ln))
        buf.append(ai[max(0,j-250):j+400])
        buf.append('')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
