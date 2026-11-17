# -*- coding: utf-8 -*-
"""
[OFFLINE-WISHSPEED] 修 bot 速度只有 24~76 的根因。

PmoveBase.PM_WalkMove:
    array[i] = pml.forward[i]*_fmove + pml.right[i]*_smove;
    num2 = VectorNormalize(array2);   // = sqrt(_fmove^2 + _smove^2)
    num2 *= CmdScale();               // 只有 > speed 时才按 speed/num 缩放
    AccelerateSpeed(array2, num2, 5f);   // <-- wishspeed = num2

也就是说 _fmove/_smove 的量级**就是**目标速度（cm/s）。
原版玩家 cmd.MoveForward 是 speed 量级（几百），我们传的是摇杆量 ±100，
于是 wishspeed 恒为 ~100（实测 vel 24~76），永远到不了 max=615。

修法：MoveForward/MoveRight = 摇杆(-1..1) * nativeSpeed，并把它提到赋值之前算。
"""
import io, sys

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
s = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
NL = chr(10)

if 'OFFLINE-WISHSPEED' in s:
    print('already patched')
    sys.exit(0)

# 1) 摘除原 nativeSpeed 计算块（在后面），挪到前面
old_speed = '''        // [OFFLINE-SPEED-NATIVE] 与玩家同源：PlayerMovePredicationSystem L221
        // int speed = PlayerSpeedUtil.GetPlayerSpeed(pyPlayerMove, _pyCmd);
        // 内部按蹲/走/死亡/第三人称规则返回 CrouchMoveSpeed/WalkSpeed/GetMaxSpeed，
        // 因此 bot 的蹲速、走速、职业基础速与玩家逐值一致。
        int nativeSpeed = (int)speed;
        try
        {
            nativeSpeed = config.PlayerSpeedUtil.GetPlayerSpeed(pe.move.PyPlayerMove, st.Adapter);
        }
        catch (System.Exception)
        {
            nativeSpeed = (int)speed;   // 工具函数在异常环境下退回参考速度
        }
'''
assert old_speed in s, 'nativeSpeed block missing'
s = s.replace(old_speed, '', 1)

# 2) 在 MoveForward 赋值前插入计算 + 按速度缩放
old_assign = '''        st.Cmd.MoveForward = mf;
        st.Cmd.MoveRight = mr;'''
new_assign = '''        // [OFFLINE-WISHSPEED] 必须在写 MoveForward 之前拿到 nativeSpeed：
        // 引擎的 wishspeed 直接等于 _fmove/_smove 的模长（见 PmoveBase.PM_WalkMove），
        // 传摇杆量 ±100 会让 bot 只能以 100cm/s 爬行（实测 vel 24~76 / max 615）。
        // [OFFLINE-SPEED-NATIVE] 与玩家同源：PlayerSpeedUtil.GetPlayerSpeed
        // 按蹲/走/死亡/第三人称规则返回 CrouchMoveSpeed/WalkSpeed/GetMaxSpeed。
        int nativeSpeed = (int)speed;
        try
        {
            nativeSpeed = config.PlayerSpeedUtil.GetPlayerSpeed(pe.move.PyPlayerMove, st.Adapter);
        }
        catch (System.Exception)
        {
            nativeSpeed = (int)speed;
        }
        if (nativeSpeed <= 0) nativeSpeed = 300;

        // 摇杆量 (-100..100) -> 速度量纲 (cm/s)
        st.Cmd.MoveForward = mf * nativeSpeed / 100f;
        st.Cmd.MoveRight = mr * nativeSpeed / 100f;'''
assert old_assign in s, 'MoveForward assign missing'
s = s.replace(old_assign, new_assign, 1)

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('WISHSPEED patched')
