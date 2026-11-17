# -*- coding: utf-8 -*-
"""F 补丁：速度源与动画阈值对齐玩家
F1) PmoveStep 的 speed 改用 PlayerSpeedUtil.GetPlayerSpeed(bot adapter, bot cmd)
    —— 与 PlayerMovePredicationSystem L221 完全同一函数（蹲速/走速/maxSpeed 规则一致）
F2) 动画 leg 阈值 bot 与玩家统一（310 跑步 / 260 滞回）—— 速度已对齐，不再需要 140 妥协
"""
import io, re

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
CTRL = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs'

g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
if 'OFFLINE-SPEED-NATIVE' in g:
    print('F1 already patched')
else:
    # 定位 SetMove 调用，把 speed 换成原版工具函数
    old = '        pmove.SetMove(pe.move.PyPlayerMove, st.Adapter, (int)speed);'
    new = '''        // [OFFLINE-SPEED-NATIVE] 与玩家同源：PlayerMovePredicationSystem L221
        // int speed = PlayerSpeedUtil.GetPlayerSpeed(pyPlayerMove, _pyCmd);
        // 内部按蹲/走/死亡/第三人称规则返回 CrouchMoveSpeed/WalkSpeed/GetMaxSpeed，
        // 因此 bot 的蹲速、走速、职业基础速与玩家逐值一致。
        int nativeSpeed = (int)speed;
        try
        {
            nativeSpeed = PlayerSpeedUtil.GetPlayerSpeed(pe.move.PyPlayerMove, st.Adapter);
        }
        catch (System.Exception)
        {
            nativeSpeed = (int)speed;   // 工具函数在异常环境下退回参考速度
        }
        pmove.SetMove(pe.move.PyPlayerMove, st.Adapter, nativeSpeed);'''
    assert old in g, 'F1 anchor missing'
    g = g.replace(old, new, 1)

    # 日志里的 max 也改成 nativeSpeed 才有意义
    old2 = '''                + " vel=" + velocity.ToString("F0") + " max=" + speed.ToString("F0")'''
    new2 = '''                + " vel=" + velocity.ToString("F0") + " max=" + nativeSpeed.ToString("F0")'''
    assert old2 in g, 'F1b anchor missing'
    g = g.replace(old2, new2, 1)
    io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
    print('F1 done: native speed source')

# F2 动画阈值
c = io.open(CTRL, encoding='utf-8', errors='surrogatepass').read()
if 'OFFLINE-LEG-NATIVE' in c:
    print('F2 already patched')
else:
    old = '''		// Bot 的 BSP 移动速度通常在 180~280cm/s，原版 310cm/s 阈值会永远选 walk。
		// 玩家仍沿用原版阈值；Bot 达到正常移动速度就进入跑步片段。
		bool runNow = p.isMyPlayer ? horizSpeed > 310f : horizSpeed > 140f;'''
    new = '''		// [OFFLINE-LEG-NATIVE] Bot 改走引擎 pmove 后速度和玩家同量级（300~520cm/s），
		// 阈值统一回原版 310（旧 140 是 BSP 近似速度偏低时的妥协，已不再需要）。
		bool runNow = horizSpeed > 310f;'''
    if old in c:
        c = c.replace(old, new, 1)
    else:
        # 可能是空格缩进
        old2 = 'bool runNow = p.isMyPlayer ? horizSpeed > 310f : horizSpeed > 140f;'
        assert old2 in c, 'F2 anchor missing'
        c = c.replace(old2, 'bool runNow = horizSpeed > 310f;   // [OFFLINE-LEG-NATIVE] 与玩家同阈值', 1)

    old3 = 'runNow = p.isMyPlayer ? horizSpeed > 260f : horizSpeed > 120f;'
    if old3 in c:
        c = c.replace(old3, 'runNow = horizSpeed > 260f;   // [OFFLINE-LEG-NATIVE] 滞回同玩家', 1)
    io.open(CTRL, 'w', encoding='utf-8', errors='surrogatepass').write(c)
    print('F2 done: leg threshold aligned')
