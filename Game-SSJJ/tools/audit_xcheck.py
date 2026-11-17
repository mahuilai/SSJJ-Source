# -*- coding: utf-8 -*-
"""Cross-verify OfflineBotAI integration points against OfflineGameplay."""
import io, re, sys

F = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
s = io.open(F, encoding='utf-8', errors='surrogatepass').read()

def show(kw, n=4, w=150):
    idxs = [m.start() for m in re.finditer(re.escape(kw), s)]
    out = ['### %s  (%d hits)' % (kw, len(idxs))]
    for i in idxs[:n]:
        ln = s[:i].count('\n') + 1
        out.append('   L%-6d %s' % (ln, s[max(0, i - w):i + w].replace('\n', ' | ')[:2 * w + 24]))
    return out

KWS = [
    'BotThreat', '.Distance', 'NextFireTime', 'NextShot', 'WantFire',
    '.Clip', 'ResetForMatch', 'RespawnPlayer', 'OfflineTdmMatch.',
    'agent.Tick', 'BotWorld', 'ReportKill', 'OnPlayerDeath', 'OnPlayerRespawn',
    'DirectStep', 'BotIntent', 'MoveTarget', 'SpeedScale',
]
for kw in KWS:
    for line in show(kw):
        print(line)
    print()
