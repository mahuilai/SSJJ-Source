# -*- coding: utf-8 -*-
"""补丁：
A) OfflineGameplay.cs：静止 bot 也每帧写 ViewYaw/ViewPitch（否则站着盯人的 bot 头不转）
B) OfflineBotAI.cs：lookPlayer 去掉 PlayerAlive 门（玩家死亡后仍盯最后位置）
"""
import io

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
AI = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
T = '\t'

# ============ A) OfflineGameplay：静止视线刷新 ============
g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
if 'OFFLINE-LOOKSTILL' in g:
    print('A already patched')
else:
    old = ('        // ---- 执行移动（原版 pmove，BSP 碰撞/台阶/重力全由引擎算） ----' + '\n'
           + '        if (it.HasMove)' + '\n'
           + '        {' + '\n'
           + '            ExecuteBotMove(b, data, it, prof, pos);' + '\n'
           + '        }' + '\n')
    new = old + ('        else' + '\n'
                 + '        {' + '\n'
                 + '            // [OFFLINE-LOOKSTILL] 静止 bot 也要刷新视线：' + '\n'
                 + '            // 不会身法的 bot 站着盯玩家（[OFFLINE-BHOP50] lookPlayer），' + '\n'
                 + '            // 玩家绕圈/跳蹲时头要跟着转；旧逻辑 HasMove=false 整段不跑，' + '\n'
                 + '            // ViewYaw 停在最后一次移动的值，表现就是"盯死一个方向"。' + '\n'
                 + '            data.ViewYaw = it.ViewYaw;' + '\n'
                 + '            data.ViewPitch = it.ViewPitch;' + '\n'
                 + '        }' + '\n')
    assert old in g, 'A anchor missing'
    g = g.replace(old, new, 1)
    io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
    print('A patched: still-bot view refresh')

# ============ B) OfflineBotAI：lookPlayer 放宽 ============
s = io.open(AI, encoding='utf-8', errors='surrogatepass').read()
if 'OFFLINE-LOOKDEAD' in s:
    print('B already patched')
else:
    old = ('\t\tif (!p.Bhop && w.PlayerValid && w.PlayerAlive)' + '\n')
    new = ('\t\t// [OFFLINE-LOOKDEAD] 去掉 PlayerAlive 门：玩家死亡后仍盯最后已知位置' + '\n'
           + '\t\t// （盯着倒下的位置/等复活点），符合"盯着我看"的要求；' + '\n'
           + '\t\t// 玩家无效（ PlayerValid=false ）时才回落到战斗朝向。' + '\n'
           + '\t\tif (!p.Bhop && w.PlayerValid)' + '\n')
    assert old in s, 'B anchor missing'
    s = s.replace(old, new, 1)
    io.open(AI, 'w', encoding='utf-8', errors='surrogatepass').write(s)
    print('B patched: lookPlayer ignores dead gate')
