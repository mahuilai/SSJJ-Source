# -*- coding: utf-8 -*-
"""
[OFFLINE-CONTRACT] Step A：把玩家快照的 30 个字段填全。

引擎侧 139 个 Playback 系统全部靠这些字段工作，之前只填了 8~10 个，
所以喷漆/护甲条/小地图标记/大头/隐身/死亡计时/动画进度全是空的。

本补丁只做「填字段」，不动任何消费端系统。
"""
import io, sys

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
s = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
NL = chr(10)
T = chr(9)

if 'OFFLINE-CONTRACT' in s:
    print('already patched')
    sys.exit(0)

# ---------- 1) 新增填充方法（挂在 EmitGrenadeExplosionEvent 之前） ----------
method = (
'    /// <summary>[OFFLINE-CONTRACT] Step A：补齐玩家快照字段。' + NL +
'    /// 客户端 139 个 Playback 系统全部读这些字段，之前只填了 8~10 个，' + NL +
'    /// 导致护甲条/小地图 bot 标记/大头/隐身/死亡计时/动画进度/挂件全是空的。' + NL +
'    private void FillContractFields(PlayerEntityData d, OfflineBotAgent b, bool alive)' + NL +
'    {' + NL +
T + 'if (d == null) return;' + NL +
T + 'try' + NL +
T + '{' + NL +
T*2 + '// --- 身份 / 阵营 ---' + NL +
T*2 + 'd.IsBot = true;' + NL +
T*2 + 'd.HasC4 = false;' + NL +
T*2 + '// --- 血量 / 护甲 / 护盾（护甲条、HUD 数字）---' + NL +
T*2 + 'if (d.MaxHp <= 0f) d.MaxHp = Mathf.Max(1f, d.Hp);' + NL +
T*2 + 'd.Zhuangjia = 0f;' + NL +
T*2 + 'd.MaxZhuangjia = 0f;' + NL +
T*2 + 'd.Hudun = 0f;' + NL +
T*2 + 'd.MaxHudun = 0f;' + NL +
T*2 + '// --- 死亡计时（SmoothDeadTimerSystem -> UI 复活倒计时）---' + NL +
T*2 + 'd.DeadTimer = alive ? 0 : 3000;' + NL +
T*2 + '// --- 视高（蹲下/站立视角、第三人称头部位置）---' + NL +
T*2 + 'd.ViewHeight = (d.DuckState == 3) ? 28f : 64f;' + NL +
T*2 + '// --- 大头模式（HeadScalePlaybackSystem）---' + NL +
T*2 + 'd.HeadEnlarge = 1f;' + NL +
T*2 + 'd.OtherHeadEnlarge = 1f;' + NL +
T*2 + '// --- 隐身透明度（PlayerSetStealthAlphaSystem），255 = 不透明 ---' + NL +
T*2 + 'd.Alpha = 255;' + NL +
T*2 + 'd.SelfAlpha = 255;' + NL +
T*2 + '// --- 控制者 / 身体俯仰翻滚（倒地、斜坡）---' + NL +
T*2 + 'd.ControlEntityId = -1;' + NL +
T*2 + 'd.MovePitch = 0f;' + NL +
T*2 + 'd.MoveRoll = 0f;' + NL +
T*2 + '// --- 动画时间戳：Playback 系统按 serverTime 推进进度，' + NL +
T*2 + '//     不填会让腿/上身动画卡在第 0 帧（和"动画不全"是同一件事）---' + NL +
T*2 + 'int nowMs = (int)(UnityEngine.Time.realtimeSinceStartup * 1000f);' + NL +
T*2 + 'd.LegsSpeedAnimTime = nowMs;' + NL +
T*2 + 'd.TorsoAnimStartTime = 0;' + NL +
T*2 + '// --- 挂件（ViewAccessoryPlaybackSystem）---' + NL +
T*2 + 'if (d.AccessoryList != null) d.AccessoryList.Clear();' + NL +
T*2 + 'd.BackAccessory = "";' + NL +
T*2 + '// --- 血条段（LifeBarSeq：多段血条 / 护盾分段显示）---' + NL +
T*2 + 'if (d.LifeBarSeq != null) d.LifeBarSeq.Clear();' + NL +
T*2 + 'd.CurrentLifeBarSeq = 0;' + NL +
T + '}' + NL +
T + 'catch (System.Exception) { }' + NL +
'}' + NL + NL)

anchor = '    /// <summary>[OFFLINE-SNAPSHOT-GRENADE] 往快照写一条手雷爆炸事件。'
assert anchor in s, 'emit method anchor missing'
s = s.replace(anchor, method + anchor, 1)

# ---------- 2) 每帧调用（跟在 ViewYaw/MoveYaw 写回之后） ----------
old_call = '''        // 朝向写回快照（第三人称模型转身靠它）
        // [OFFLINE-VISION] 视线=ViewYaw（含呼吸/扫视晃动），弹道 AimYaw 保持精准
        data.ViewYaw = it.ViewYaw;'''
new_call = '''        // 朝向写回快照（第三人称模型转身靠它）
        // [OFFLINE-VISION] 视线=ViewYaw（含呼吸/扫视晃动），弹道 AimYaw 保持精准
        data.ViewYaw = it.ViewYaw;
        // [OFFLINE-CONTRACT] Step A：补齐 30 字段，激活 139 个消费系统
        FillContractFields(data, b, b.Alive);'''
assert old_call in s, 'yaw write anchor missing'
s = s.replace(old_call, new_call, 1)

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('CONTRACT fields patched')
