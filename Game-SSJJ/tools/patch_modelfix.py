# -*- coding: utf-8 -*-
"""[OFFLINE-MODEL-FIX] PvP 模式不再刷 PVE 首领模型 + bot 数量回原版默认。

问题现场（1v1 团战）：唯一敌人 = quality=3 首领 boss1008（PVE 巨怪模型 +
巴雷特 + HeadEnlarge 0.40），玩家视角"建模不对"。根因：Team(2003)/Blade(15)/
BotKnife(2041) 三个 PvP 档案都带 BossCount=1 + BossCareers={boss1008}。

修复：
  1) Team / Blade / BotKnife 的 BossCount 1 -> 0（PvP 不出首领；BigHead 2019
     保留 BossCount=1，PVE 感是大头模式特色，上轮已实机验证）
  2) launch_config.json 删掉 bot_count/ally_bot_count/enemy_bot_count，
     BotCountExplicit=false -> 团队模式走原版默认 3v4（MaxPlayers 8）
"""
import io, json, re, os

# ---------- 1) OfflineModeTable：三个 PvP 档案 BossCount -> 0 ----------
P = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineModeTable.cs'
s = io.open(P, encoding='utf-8', errors='surrogatepass').read()

changed = []
for name in ('Blade', 'Team', 'BotKnife'):
    m = re.search(r'Profile\s+' + name + r'\s*=\s*new Profile', s)
    if not m:
        print('WARN: profile %s not found' % name)
        continue
    start = m.start()
    # 段终点：下一个 "Profile Xxx = new Profile" 或文件尾
    nxt = re.search(r'Profile\s+\w+\s*=\s*new Profile', s[m.end():])
    end = m.end() + nxt.start() if nxt else len(s)
    seg = s[start:end]
    if 'BossCount = 1' in seg:
        seg2 = seg.replace('BossCount = 1', 'BossCount = 0', 1)
        s = s[:start] + seg2 + s[end:]
        changed.append(name)
    else:
        print('WARN: %s has no BossCount = 1 (already 0?)' % name)

io.open(P, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('OfflineModeTable BossCount->0 for:', changed)
# 校验 BigHead 保留
m = re.search(r'Profile\s+BigHead\s*=\s*new Profile', s)
seg = s[m.start():m.start() + 2500]
print('BigHead BossCount still =', re.search(r'BossCount\s*=\s*(\d+)', seg).group(1))

# ---------- 2) launch_config：删显式数量键，回原版默认 ----------
CFG = r'D:\SSJJ-4399\battle\3_64\launch_config.json'
d = json.load(io.open(CFG, encoding='utf-8'))
removed = [k for k in ('bot_count', 'ally_bot_count', 'enemy_bot_count') if k in d]
for k in removed:
    del d[k]
json.dump(d, io.open(CFG, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('launch_config removed keys:', removed, '| mode =', d.get('mode'))
