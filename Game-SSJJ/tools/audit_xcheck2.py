# -*- coding: utf-8 -*-
"""Final verification batch: dead code, clip sync, grenade impl."""
import io, re

F = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
s = io.open(F, encoding='utf-8', errors='surrogatepass').read()

def show(kw, n=4, w=110):
    idxs = [m.start() for m in re.finditer(re.escape(kw), s)]
    out = ['### %s  (%d hits)' % (kw, len(idxs))]
    for i in idxs[:n]:
        ln = s[:i].count('\n') + 1
        out.append('   L%-6d %s' % (ln, s[max(0, i - w):i + w].replace('\n', ' | ')[:2 * w + 24]))
    return out

for kw in ['PmoveStep', 'ExecuteBotMove', 'ThrowBotGrenade', 'data.clip',
           'b.Clip', 'SpeedScale', 'EnemySideObjective', 'BotObjectiveOffset',
           '_botSkillIgnored', 'RoundOver =', 'GetBotPmove']:
    for line in show(kw):
        print(line)
    print()
