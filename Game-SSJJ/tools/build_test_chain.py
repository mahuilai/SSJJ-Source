# -*- coding: utf-8 -*-
"""构建 + 回注 + nightmare 实机 + 抓 BHOPCHAIN/BHOP/AIRACCEL/LOOKPLAYER。"""
import subprocess, os, io, re, json, time

BUILD_DIR = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild'
TOOLS = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\tools'
LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'
CFG = r'D:\SSJJ-4399\battle\3_64\launch_config.json'

# 0) 确保 nightmare 难度（身法 bot 在该档 Bhop+JumpDuck 全开）
d = json.load(io.open(CFG, encoding='utf-8'))
d['bot_difficulty'] = 'nightmare'
json.dump(d, io.open(CFG, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('difficulty ->', d['bot_difficulty'])

# 1) 构建
r = subprocess.run([r'C:\Program Files\dotnet\dotnet.exe', 'build', 'Assembly-CSharp.csproj',
                    '-t:Rebuild', '-v', 'q', '--nologo'],
                   capture_output=True, text=True, encoding='utf-8', errors='replace', cwd=BUILD_DIR)
out = (r.stdout or '') + (r.stderr or '')
errs = [l for l in out.splitlines() if 'error' in l.lower()]
print('build exit:', r.returncode, '| errors:', len(errs))
for l in errs[:5]:
    print('  ', l[:200])
if errs:
    raise SystemExit(1)

# 2) 回注
r = subprocess.run(['python', 'inject_rebuild.py'], capture_output=True, text=True,
                   encoding='utf-8', errors='replace', cwd=TOOLS)
print('inject:', r.stdout.strip()[-120:])

# 3) 启动
r = subprocess.run(['python', 'run_game.py', '--wait', '55'], capture_output=True, text=True,
                   encoding='utf-8', errors='replace', cwd=TOOLS)
print('game:', r.stdout.strip()[:120])

# 4) 分析（全量，按最后 spawn summary 切）
time.sleep(2)
s = io.open(LOG, encoding='utf-8', errors='replace').read()
sums = [m.start() for m in re.finditer(r'spawn summary', s)]
seg = s[sums[-1]:] if sums else s

res = []
for tag, pat in [('BHOPCHAIN', r'\[OFFLINE-BHOPCHAIN\][^\n]*'),
                 ('BHOP', r'\[OFFLINE-BHOP\][^\n]*'),
                 ('AIRACCEL', r'\[OFFLINE-AIRACCEL\][^\n]*'),
                 ('LOOKPLAYER', r'\[OFFLINE-LOOKPLAYER\][^\n]*'),
                 ('ASSIGN', r'\[OFFLINE-BHOP-ASSIGN\][^\n]*'),
                 ('VELMOVE', r'\[OFFLINE-VELMOVE\][^\n]*')]:
    ms = re.findall(pat, seg)
    res.append('===== %s (%d) =====' % (tag, len(ms)))
    for m in ms[:10]:
        res.append('  ' + m.strip()[:135])
    res.append('')

exs = [l for l in seg.splitlines() if 'Exception' in l or 'ERROR' in l.upper()]
res.append('Exception/ERROR: %d' % len(exs))
for e in exs[:3]:
    res.append('  ' + e.strip()[:160])

io.open(r'D:\逆向\SSJJ双塔惊魂\_work\bhop_chain.txt', 'w', encoding='utf-8').write('\n'.join(res))
print('\n'.join(res))
