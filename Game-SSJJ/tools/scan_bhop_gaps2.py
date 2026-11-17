# -*- coding: utf-8 -*-
"""查：PlayerEntityData.ViewYaw 字段、BlockActors 实现、HasMove 门、selfPos 单位。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\bhop_gaps2.txt'
os.makedirs(os.path.dirname(OUT), exist_ok=True)
buf = []

gp = io.open(os.path.join(ROOT, 'OfflineGameplay.cs'), encoding='utf-8', errors='surrogatepass').read()

# 1) PlayerEntityData 的 View 字段（全 Decompiled 搜）
buf.append('===== ViewYaw/ViewPitch 字段声明（PlayerEntityData）=====')
found = False
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: s = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        for m in re.finditer(r'public\s+float\s+View(Yaw|Pitch)\s*[;=]', s):
            ln = s[:m.start()].count('\n') + 1
            buf.append('%-42s L%-6d %s' % (f, ln, m.group(0)))
            found = True
if not found:
    buf.append('(未找到 ViewYaw/ViewPitch 字段声明)')
buf.append('')

# 2) BlockActors 完整体
phys = io.open(os.path.join(ROOT, 'OfflineBotPhysics.cs'), encoding='utf-8', errors='surrogatepass').read()
def extract(s, sig):
    i = s.find(sig)
    if i < 0: return '(not found)'
    j = s.find('{', i); depth = 0; p = j
    while p < len(s):
        if s[p] == '{': depth += 1
        elif s[p] == '}':
            depth -= 1
            if depth == 0: break
        p += 1
    return s[i:p+1]
buf.append('===== BlockActors =====')
buf.append(extract(phys, 'public static Vector3 BlockActors'))
buf.append('')

# 3) HasMove 门 + Update 主循环（BspStep 调用上下文）
buf.append('===== ExecuteBotMove 调用门（Gameplay L1240-1270）=====')
i = gp.find('BotIntent it = b.Tick(prof, _botWorld, _threats, pos)')
buf.append(gp[max(0,i-200):i+800])
buf.append('')

# 4) selfPos 单位（FillTdmWorld 调用处往上找 selfPos 定义）
buf.append('===== selfPos 定义 =====')
i = gp.find('FillTdmWorld(snap, b, data, haveSelf, selfPos, freeForAll)')
seg = gp[max(0,i-3000):i]
j = seg.rfind('Vector3 selfPos')
if j < 0: j = seg.rfind('selfPos =')
buf.append(seg[max(0,j-100):j+500] if j >= 0 else '(未在窗口内找到，往上扩)')
buf.append('')

# 5) ViewYaw 在 BspStep 的写入 + SyncOfflineAnimStates 的读取
buf.append('===== data.ViewYaw 写入点（Gameplay）=====')
for m in re.finditer(r'ViewYaw', gp):
    ln = gp[:m.start()].count('\n') + 1
    buf.append('L%-6d %s' % (ln, gp[max(0,m.start()-120):m.start()+60].replace('\n',' | ')[:170]))
buf.append('')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
