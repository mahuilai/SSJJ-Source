# -*- coding: utf-8 -*-
"""查 WantJump 产生点 + PlayerPos/eye 单位 + VapeV4 bhop 参数。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\bhop_gaps.txt'
os.makedirs(os.path.dirname(OUT), exist_ok=True)

ai = io.open(os.path.join(ROOT, 'OfflineBotAI.cs'), encoding='utf-8', errors='surrogatepass').read()
gp = io.open(os.path.join(ROOT, 'OfflineGameplay.cs'), encoding='utf-8', errors='surrogatepass').read()

buf = []

# 1) WantJump 赋值点
buf.append('===== WantJump 赋值点（AI）=====')
for m in re.finditer(r'WantJump\s*=', ai):
    ln = ai[:m.start()].count('\n') + 1
    buf.append('L%-6d %s' % (ln, ai[max(0,m.start()-350):m.start()+120].replace('\n',' | ')[:440]))
buf.append('')

# 2) PlayerPos / eye 单位（FillTdmWorld 或感知填充处）
buf.append('===== w.PlayerPos 填充（Gameplay FillTdmWorld）=====')
for m in re.finditer(r'PlayerPos\s*=', gp):
    ln = gp[:m.start()].count('\n') + 1
    buf.append('L%-6d %s' % (ln, gp[max(0,m.start()-300):m.start()+200].replace('\n',' | ')[:460]))
buf.append('')

# 3) eye 定义（AI 层）
buf.append('===== AI eye 定义/赋值 =====')
for m in list(re.finditer(r'\beye\b', ai))[:14]:
    ln = ai[:m.start()].count('\n') + 1
    seg = ai[max(0,m.start()-120):m.start()+100].replace('\n',' | ')
    if '=' in seg or 'eye' in seg:
        buf.append('L%-6d %s' % (ln, seg[:220]))
buf.append('')

# 4) FillTdmWorld 里 PlayerPos/PlayerValid/PlayerAlive 段
i = gp.find('FillTdmWorld')
if i > 0:
    buf.append('===== FillTdmWorld 玩家字段段 =====')
    seg = gp[i:i+5200]
    j = seg.find('PlayerValid')
    buf.append(seg[max(0,j-800):j+900] if j > 0 else seg[:1200])
buf.append('')

# 5) BotWorld 字段
buf.append('===== BotWorld 字段定义 =====')
i = ai.find('class BotWorld')
if i < 0: i = ai.find('struct BotWorld')
if i > 0:
    seg = ai[i:i+1000]
    buf.append(seg)
buf.append('')

# 6) VapeV4 bhop 参数
buf.append('===== VapeV4 bhop 相关文件 =====')
vape = r'D:\逆向\SSJJ双塔惊魂\SSJJ-VapeV4-main'
hits = []
for dp, dn, fn in os.walk(vape):
    for f in fn:
        if f.lower().endswith(('.cs', '.json', '.txt')):
            p = os.path.join(dp, f)
            try:
                s = io.open(p, encoding='utf-8', errors='ignore').read()
            except Exception:
                continue
            low = s.lower()
            if 'bhop' in low or ('jump' in low and 'air' in low):
                hits.append((p, len(s)))
buf.append('文件命中 (%d):' % len(hits))
for p, n in hits[:12]:
    buf.append('   %-90s %d bytes' % (p.replace(vape, ''), n))
buf.append('')

# 7) VapeV4 bhop 代码体（前 2 个命中文件）
for p, n in hits[:2]:
    s = io.open(p, encoding='utf-8', errors='ignore').read()
    buf.append('')
    buf.append('######## %s ########' % os.path.basename(p))
    for m in list(re.finditer(r'(?i)bhop|jump|air', s))[:30]:
        ln = s[:m.start()].count('\n') + 1
        seg = s[max(0,m.start()-80):m.start()+120].replace('\n', ' | ')
        if any(c.isdigit() for c in seg) and ('=' in seg or '(' in seg):
            buf.append('   L%-5d %s' % (ln, seg[:180]))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
