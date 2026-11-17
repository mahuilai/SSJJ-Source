# -*- coding: utf-8 -*-
"""构建 + 回注 + nightmare 实机 + 验证玩家同源四项：ground/速度/跳跃/动画"""
import subprocess, os, io, re, json, time

BUILD_DIR = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild'
TOOLS = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\tools'
LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'
CFG = r'D:\SSJJ-4399\battle\3_64\launch_config.json'

d = json.load(io.open(CFG, encoding='utf-8'))
d['bot_difficulty'] = 'nightmare'
json.dump(d, io.open(CFG, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('difficulty ->', d['bot_difficulty'], '| mode:', d.get('mode'), '| map:', d.get('map'))

r = subprocess.run([r'C:\Program Files\dotnet\dotnet.exe', 'build', 'Assembly-CSharp.csproj',
                    '-t:Rebuild', '-v', 'q', '--nologo'],
                   capture_output=True, text=True, encoding='utf-8', errors='replace', cwd=BUILD_DIR)
out = (r.stdout or '') + (r.stderr or '')
errs = [l for l in out.splitlines() if 'error' in l.lower()]
print('build exit:', r.returncode, '| errors:', len(errs))
for l in errs[:6]:
    print('  ', l[:220])
if errs:
    raise SystemExit(1)

r = subprocess.run(['python', 'inject_rebuild.py'], capture_output=True, text=True,
                   encoding='utf-8', errors='replace', cwd=TOOLS)
print('inject:', r.stdout.strip()[-120:])

r = subprocess.run(['python', 'run_game.py', '--wait', '60'], capture_output=True, text=True,
                   encoding='utf-8', errors='replace', cwd=TOOLS)
print('game:', r.stdout.strip()[:120])

time.sleep(2)
s = io.open(LOG, encoding='utf-8', errors='replace').read()
sums = [m.start() for m in re.finditer(r'spawn summary', s)]
seg = s[sums[-1]:] if sums else s

res = []
mv = re.findall(r'\[OFFLINE-BOT-MOVE\][^\n]*', seg)
res.append('===== BOT-MOVE (%d) =====' % len(mv))
for m in mv[:12]:
    res.append('  ' + m.strip()[:160])

# ground 统计
grounds = re.findall(r'ground=(\w+)', seg)
from collections import Counter
res.append('')
res.append('ground 分布: %s' % dict(Counter(grounds)))
vels = [int(x) for x in re.findall(r'vel=(\d+)', seg)]
res.append('vel 样本: %s' % vels[:12])
res.append('vel 最大: %s' % (max(vels) if vels else '-'))

je = re.findall(r'jumpEdge=(\w+)', seg)
res.append('jumpEdge 分布: %s' % dict(Counter(je)))

for tag, pat in [('BHOP(物理层)', r'\[OFFLINE-BHOP\][^\n]*'),
                 ('AIRACCEL', r'\[OFFLINE-AIRACCEL\][^\n]*'),
                 ('BHOPCHAIN', r'\[OFFLINE-BHOPCHAIN\][^\n]*'),
                 ('VELMOVE', r'\[OFFLINE-VELMOVE\][^\n]*')]:
    ms = re.findall(pat, seg)
    res.append('')
    res.append('===== %s (%d) =====' % (tag, len(ms)))
    for m in ms[:8]:
        res.append('  ' + m.strip()[:140])

# leg 状态分布（跳跃动画 5 是否出现）
legs = re.findall(r'leg=(\d+)', seg)
res.append('')
res.append('leg 分布: %s' % dict(Counter(legs)))

exs = [l for l in seg.splitlines() if 'Exception' in l]
res.append('')
res.append('Exception: %d' % len(exs))
for e in exs[:3]:
    res.append('  ' + e.strip()[:150])

io.open(r'D:\逆向\SSJJ双塔惊魂\_work\native_verify.txt', 'w', encoding='utf-8').write('\n'.join(res))
print('\n'.join(res))
