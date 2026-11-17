# -*- coding: utf-8 -*-
"""G 补丁：PmoveStep 每次 SetMove 前更新 brush（对齐 UpdateNormalBrushSystem 的 2 操作）+ ground 诊断"""
import io

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-BRUSH-UPDATE' in g:
    print('already patched')
    raise SystemExit(0)

# 在 SetMove 前插 brush 更新 + 位置同步
old = '''        int nativeSpeed = (int)speed;
        try
        {
            nativeSpeed = PlayerSpeedUtil.GetPlayerSpeed(pe.move.PyPlayerMove, st.Adapter);
        }
        catch (System.Exception)
        {
            nativeSpeed = (int)speed;   // 工具函数在异常环境下退回参考速度
        }
        pmove.SetMove(pe.move.PyPlayerMove, st.Adapter, nativeSpeed);'''
new = '''        int nativeSpeed = (int)speed;
        try
        {
            nativeSpeed = PlayerSpeedUtil.GetPlayerSpeed(pe.move.PyPlayerMove, st.Adapter);
        }
        catch (System.Exception)
        {
            nativeSpeed = (int)speed;   // 工具函数在异常环境下退回参考速度
        }
        // [OFFLINE-BRUSH-UPDATE] 对齐原版 UpdateNormalBrushSystem：物理实体每帧用 2（更新）
        // 刷新 brush 世界位置。旧实现只在创建时传 0（添加）一次，brush 停在出生点，
        // 地面 trace 与实际位置错位 → IsOnGround() 恒 false。
        try
        {
            var em = Contexts.sharedInstance.battleRoom.pyEngine.PyEngine.GetEntityManager();
            if (em != null) em.UpdateEntityNormalBrush(2, pe.move.PyPlayerMove.GetEntity());
        }
        catch (System.Exception) { }
        pmove.SetMove(pe.move.PyPlayerMove, st.Adapter, nativeSpeed);'''
assert old in g, 'G anchor missing'
g = g.replace(old, new, 1)

# 日志补：实体坐标 vs 快照坐标（定位 brush/实体不同步）
old2 = '''                + " jumpEdge=" + jumpEdge
                + " cmdF=" + st.Cmd.MoveForward.ToString("F0") + " btn=" + st.Cmd.Buttons);'''
new2 = '''                + " jumpEdge=" + jumpEdge
                + " ent=" + pe.move.PyPlayerMove.GetX().ToString("F0") + "," + pe.move.PyPlayerMove.GetY().ToString("F0") + "," + pe.move.PyPlayerMove.GetZ().ToString("F0")
                + " data=" + data.X.ToString("F0") + "," + data.Y.ToString("F0") + "," + data.Z.ToString("F0")
                + " cmdF=" + st.Cmd.MoveForward.ToString("F0") + " btn=" + st.Cmd.Buttons);'''
assert old2 in g, 'G2 anchor missing'
g = g.replace(old2, new2, 1)

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
print('G done: brush update(2) + ent/data diag')
