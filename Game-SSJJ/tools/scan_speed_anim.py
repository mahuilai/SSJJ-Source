# -*- coding: utf-8 -*-
"""查：1) 原版玩家 speed 来源（PlayerMovePredicationSystem speed 计算）
   2) 跳跃动画字段（basicInfo.JumpState/MoveState + 动画系统读取点）"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\speed_anim_align.txt'
buf = []

def read(f):
    for dp, dn, fn in os.walk(ROOT):
        if f in fn:
            return io.open(os.path.join(dp, f), encoding='utf-8', errors='surrogatepass').read()
    return None

# 1) speed 计算（PlayerMovePredicationSystem Execute 开头）
pms = read('PlayerMovePredicationSystem.cs')
if pms:
    buf.append('===== PlayerMovePredicationSystem Execute（speed 计算段）=====')
    i = pms.find('protected override void Execute')
    if i < 0: i = pms.find('void Execute')
    buf.append(pms[i:i+2600] if i > 0 else '(not found)')
    buf.append('')
    # FixSpeed 全段（含 SceneSpecialArea 后逻辑）
    i = pms.find('private void FixSpeed')
    if i > 0:
        seg = pms[i:i+3000]
        buf.append('===== FixSpeed 全段 =====')
        buf.append(seg)

buf.append('')
# 2) 跳跃动画字段：basicInfo 的 Jump/Move 状态
buf.append('===== basicInfo.Current 字段里的 Jump/Move 状态 =====')
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if not f.endswith('.cs'): continue
        p = os.path.join(dp, f)
        try: t = io.open(p, encoding='utf-8', errors='ignore').read()
        except Exception: continue
        for kw in ['JumpState', 'MoveState', 'OnGround', 'GroundState']:
            for m in list(re.finditer(r'public\s+\w+\s+' + kw + r'\s*[;=]', t))[:2]:
                ln = t[:m.start()].count('\n') + 1
                buf.append('%-40s L%-6d %s' % (f, ln, m.group(0)))

buf.append('')
# 3) SyncOfflineAnimStates 的 leg 状态合成（跳跃分支）
ctrl = read('OfflineGameController.cs')
if ctrl:
    buf.append('===== SyncOfflineAnimStates 跳跃/leg 分支 =====')
    i = ctrl.find('SyncOfflineAnimStates')
    if i > 0:
        seg = ctrl[i:i+6000]
        # 找 leg = 赋值（跳/蹲相关）
        for m in list(re.finditer(r'leg\s*=\s*\d+', seg))[:20]:
            ln = seg[:m.start()].count('\n') + 1
            buf.append('  L%-5d(rel) %s' % (ln, seg[max(0,m.start()-160):m.start()+60].replace('\n',' | ')[:220]))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
