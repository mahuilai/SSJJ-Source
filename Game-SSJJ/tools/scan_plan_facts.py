# -*- coding: utf-8 -*-
"""计划前事实核查：
1) bot 是不是已经是标准 PlayerEntity（"新建实体"这半句是否已成立）
2) 客户端里 bot 专用代码有多少（OfflineBotAI/Physics/Gameplay 分支）
3) 远端玩家（非本地）在客户端怎么被消费——快照/动画/位置链
"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\plan_facts.txt'
buf = []

def read(f):
    for dp, dn, fn in os.walk(ROOT):
        if f in fn:
            return io.open(os.path.join(dp, f), encoding='utf-8', errors='surrogatepass').read(), os.path.join(dp, f)
    return None, None

# 1) OfflineBotSpawner 怎么建实体
sp, p = read('OfflineBotSpawner.cs')
if sp:
    buf.append('===== OfflineBotSpawner 实体创建段 =====')
    for kw in ['CreateEntity', 'AddBasicInfo', 'AddMove', 'new PyPlayerAdapter', 'PlayerEntityUtility', 'AddEntityId']:
        for m in list(re.finditer(re.escape(kw), sp))[:3]:
            ln = sp[:m.start()].count('\n') + 1
            buf.append('L%-6d [%s] %s' % (ln, kw, sp[max(0,m.start()-200):m.start()+200].replace('\n',' | ')[:380]))
    buf.append('')

# 2) bot 专用代码规模
buf.append('===== bot 专用文件规模 =====')
tot = 0
for f in ['OfflineBotAI.cs', 'OfflineBotNav.cs', 'OfflineBotPhysics.cs', 'OfflineBotSpawner.cs',
          'OfflineTdmMatch.cs', 'OfflineKillChain.cs']:
    t, p2 = read(f)
    if t:
        n = t.count('\n') + 1
        tot += n
        buf.append('  %-28s %5d 行' % (f, n))
buf.append('  合计 %.0f 行' % tot)
buf.append('')

# 3) OfflineGameplay 里 bot 专用方法清单
gp, _ = read('OfflineGameplay.cs')
if gp:
    buf.append('===== OfflineGameplay 方法清单（bot 相关标记）=====')
    for m in re.finditer(r'(private|public)\s+(static\s+)?[\w<>\[\],\s]+?\s+(\w+)\s*\(', gp):
        ln = gp[:m.start()].count('\n') + 1
        name = m.group(3)
        if any(k in name.lower() for k in ('bot', 'pmove', 'bsp', 'death', 'threat')):
            buf.append('  L%-6d %s' % (ln, name))
    buf.append('')

# 4) 远端玩家消费链：快照 -> 实体的系统（在线路径）
buf.append('===== 远端玩家位置/动画消费系统 =====')
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        if not any(k in f for k in ('Playback', 'SnapshotPlayback', 'BasicInfoPlayback', 'PositionPlayback', 'AnimPlayback')):
            continue
        buf.append('  %s' % f)
buf.append('')

# 5) SyncOfflineAnimStates 里 bot 专用分支数量
ctrl, _ = read('OfflineGameController.cs')
if ctrl:
    i = ctrl.find('private void SyncOfflineAnimStates')
    if i > 0:
        j = ctrl.find('\n\tprivate', i + 100)
        body = ctrl[i:j if j > 0 else i+14000]
        buf.append('===== SyncOfflineAnimStates 里 bot 专用标记 =====')
        for kw in ['!p.isMyPlayer', 'isMyPlayer', 'OFFLINE-BOT', 'snapData']:
            buf.append('  %-18s x%d' % (kw, body.count(kw)))
        buf.append('  函数长度: %d 字符' % len(body))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
