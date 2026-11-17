# -*- coding: utf-8 -*-
"""构建 + 回注 + 启动 + 抓 bhop/lookplayer 验证日志。"""
import subprocess, os, io, re, time

BUILD_DIR = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild'
TOOLS = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\tools'
LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'

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
print('inject:', r.stdout.strip()[-140:])

# 3) 启动（nightmare 已在配置里则直接跑，否则提示）
cfg = io.open(r'D:\SSJJ-4399\battle\3_64\launch_config.json', encoding='utf-8')
import json
d = json.load(cfg)
print('当前配置: mode=%s difficulty=%s map=%s' % (d.get('mode'), d.get('bot_difficulty'), d.get('map')))

# 记录日志起点
log_size = os.path.getsize(LOG) if os.path.exists(LOG) else 0
r = subprocess.run(['python', 'run_game.py', '--wait', '55'], capture_output=True, text=True,
                   encoding='utf-8', errors='replace', cwd=TOOLS)
print('game:', r.stdout.strip()[:150])

# 4) 分析本段日志
time.sleep(2)
with open(LOG, 'rb') as f:
    f.seek(log_size)
    seg = f.read().decode('utf-8', errors='replace')

res = []
res.append('===== BHOP-ASSIGN（50% 分配实证）=====')
for m in re.findall(r'\[OFFLINE-BHOP-ASSIGN\][^\n]*', seg):
    res.append('  ' + m.strip()[:130])
res.append('')
res.append('===== BHOP 跳跃 =====')
bh = re.findall(r'\[OFFLINE-BHOP\][^\n]*', seg)
res.append('  次数: %d' % len(bh))
for m in bh[-4:]:
    res.append('  ' + m.strip()[:130])
res.append('')
res.append('===== AIRACCEL 空中加速 =====')
aa = re.findall(r'\[OFFLINE-AIRACCEL\][^\n]*', seg)
res.append('  次数: %d' % len(aa))
for m in aa[-4:]:
    res.append('  ' + m.strip()[:130])
res.append('')
res.append('===== LOOKPLAYER（非身法 bot 盯玩家）=====')
lp = re.findall(r'\[OFFLINE-LOOKPLAYER\][^\n]*', seg)
res.append('  次数: %d' % len(lp))
ids = set(re.search(r'id=(\d+)', m).group(1) for m in lp)
res.append('  出镜 bot: %s' % sorted(ids))
for m in lp[-4:]:
    res.append('  ' + m.strip()[:130])
res.append('')
res.append('===== 异常 =====')
exs = [l for l in seg.splitlines() if 'Exception' in l or 'ERROR' in l.upper()]
res.append('  Exception/ERROR: %d' % len(exs))
for e in exs[:3]:
    res.append('  ' + e.strip()[:160])

io.open(r'D:\逆向\SSJJ双塔惊魂\_work\bhop_verify.txt', 'w', encoding='utf-8').write('\n'.join(res))
print('\n'.join(res))
