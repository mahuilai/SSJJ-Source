# -*- coding: utf-8 -*-
"""
一次修五个问题：
 1. Nav.Walkable 逻辑反了（Cast=true 表示没卡住，原代码当"撞到"用）-> bot 寻路全挂
 2. AI WantCrouch 常蹲 -> bot 全程蹲走（老板要跑）
 3. 玩家 ThrowGrenade 单位混用（40m / 1800m/s / 12m 球 / 重力980）-> 手雷飞出视野
 4. 玩家投掷没动画 -> 补原版 SetViewAnimation(player, 28)
 5. 玩家爆炸没特效 -> 改走快照 GrenadeExplosionEventEntityDataDict
"""
import io, sys

NAV = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotNav.cs'
AI = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
NL = chr(10)

# ---------- 1) Walkable ----------
s = io.open(NAV, encoding='utf-8', errors='surrogatepass').read()
old = '''		Vector3 hit, normal; float frac;
		// Cast 返回 true 表示撞到东西
		if (OfflineBotPhysics.Cast(from, to, OfflineBotPhysics.Radius, OfflineBotPhysics.Height,
			out hit, out normal, out frac))
		{
			return frac > 0.95f;   // 几乎走到终点才算通
		}
		return true;'''
new = '''		Vector3 hit, normal; float frac;
		// [OFFLINE-NAVFIX] Cast 返回 true = trace 有效（没 startsolid），fraction 才是"走了多远"。
		// 旧实现把 true 当"撞到"直接 return false，导致所有相邻节点都判不可走 -> 寻路全空。
		if (!OfflineBotPhysics.Cast(from, to, OfflineBotPhysics.Radius, OfflineBotPhysics.Height,
			out hit, out normal, out frac))
		{
			return false;          // trace 无效/起点卡在实体里，不能走
		}
		return frac > 0.95f;       // 几乎走到终点才算通'''
if 'OFFLINE-NAVFIX' not in s:
    assert old in s, 'Walkable anchor missing'
    s = s.replace(old, new, 1)
    io.open(NAV, 'w', encoding='utf-8', errors='surrogatepass').write(s)
    print('[1] Walkable fixed')
else:
    print('[1] already')

# ---------- 2) WantCrouch ----------
s = io.open(AI, encoding='utf-8', errors='surrogatepass').read()
n = 0
old2a = '''		it.WantCrouch = p.JumpDuck && it.HasMove;'''
new2a = '''		// [OFFLINE-RUNFIX] 旧写法 = "会跳蹲就全程蹲着走"，bot 移动速度被蹲速压死、
		// 且蹲走动画与原版 walk 不一致。老板要求 bot 跑着走：常态不蹲。
		it.WantCrouch = false;'''
if old2a in s:
    s = s.replace(old2a, new2a, 1); n += 1
old2b = '''		it.WantCrouch = p.JumpDuck && it.HasMove
			&& Mathf.Sin(now * 1.7f + Id * 0.41f) > 0.55f;'''
new2b = '''		// [OFFLINE-RUNFIX] 同上：不常蹲（保留 WantJump 的 bhop）
		it.WantCrouch = false;'''
if old2b in s:
    s = s.replace(old2b, new2b, 1); n += 1
if n:
    io.open(AI, 'w', encoding='utf-8', errors='surrogatepass').write(s)
    print('[2] WantCrouch neutralized (%d site)' % n)
else:
    print('[2] already/not found')

# ---------- 3+4+5) 玩家 ThrowGrenade ----------
s = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
if 'OFFLINE-PGRENADE' in s:
    print('[3-5] already')
else:
    old3 = '''        g.Pos = cam.transform.position + cam.transform.forward * 40f - cam.transform.up * 8f;
        g.Vel = cam.transform.forward * 1800f + cam.transform.up * 320f;
        g.FuseAt = Time.time + (g.Kind == 0 ? 2.2f : (g.Kind == 1 ? 1.8f : 1.5f));'''
    new3 = '''        // [OFFLINE-PGRENADE] 单位统一成米制（旧实现 Pos 用了 40 米、Vel 1800 m/s、
        // 球 scale 12 米、重力 980 —— 米和厘米混用，手雷出膛就飞出视野）。
        g.Pos = cam.transform.position + cam.transform.forward * 0.5f - cam.transform.up * 0.15f;
        g.Vel = cam.transform.forward * 18f + cam.transform.up * 3.2f;
        g.FuseAt = Time.time + (g.Kind == 0 ? 2.2f : (g.Kind == 1 ? 1.8f : 1.5f));'''
    assert old3 in s, 'grenade pos/vel anchor missing'
    s = s.replace(old3, new3, 1)

    old4 = '''        ball.transform.localScale = Vector3.one * 12f;'''
    new4 = '''        ball.transform.localScale = Vector3.one * 0.12f;   // [OFFLINE-PGRENADE] 12 -> 0.12 米'''
    assert old4 in s, 'ball scale anchor missing'
    s = s.replace(old4, new4, 1)

    old5 = '''                g.Vel.y -= 980f * dt;'''
    new5 = '''                g.Vel.y -= 9.8f * dt;   // [OFFLINE-PGRENADE] 980 -> 9.8（米制重力）'''
    assert old5 in s, 'gravity anchor missing'
    s = s.replace(old5, new5, 1)

    # 4) 投掷动画：原版 GrenadePredicationSystem 播 state 28
    old6 = '''        _nextThrow = Time.time + 1f;
        _returnToPrimaryAt = Time.time + 0.7f;'''
    new6 = '''        // [OFFLINE-PGRENADE] 补原版投掷动作：GrenadePredicationSystem 在攻击预测时
        // PlayerAnimationUtility.SetViewAnimation(player, 28)。我们绕过 UserCmd，手动补播。
        try
        {
            PlayerEntity meT = Contexts.sharedInstance.player.myPlayerEntity;
            if (meT != null) PlayerAnimationUtility.SetViewAnimation(meT, 28);
        }
        catch (System.Exception) { }

        _nextThrow = Time.time + 1f;
        _returnToPrimaryAt = Time.time + 0.7f;'''
    assert old6 in s, 'throw tail anchor missing'
    s = s.replace(old6, new6, 1)

    # 5) 爆炸走快照（替换 UpdateGrenades 玩家分支）
    old7 = '''            // 烟雾：原版是服务端 SceneBuff 下发的 smoke_area 粒子，纯视觉、无伤害。
            if (g.Kind == 2)
            {
                OfflineGrenadeFx.Smoke(g.Pos);
                Debug.Log("[OFFLINE-GRENADE] smoke at " + g.Pos.ToString("F0"));
                continue;
            }
            OfflineGrenadeF'''
    new7 = '''            // [OFFLINE-PGRENADE] 走原版快照链路（与 bot 同一条）：
            // GrenadeExplosionEntityCreateSystem -> SceneObjectFactory.CreateExplosion
            //  -> Explosion 表 eventId (4=破片 / 8=闪光) -> effectprefab/explosion
            if (g.Kind == 2)
            {
                OfflineGrenadeFx.Smoke(g.Pos);   // 烟雾仍走自建（原版是 SceneBuff 下发）
                Debug.Log("[OFFLINE-GRENADE] smoke at " + g.Pos.ToString("F0"));
                continue;
            }
            EmitGrenadeExplosionEvent(g.Pos, Snap() != null ? Snap().Self : 0, -1,
                g.Kind == 1 ? 8 : 4, 0, g.Kind == 1 ? "flashbang" : "grenade");
            OfflineGrenadeF'''
    assert old7 in s, 'player explode anchor missing'
    s = s.replace(old7, new7, 1)

    io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(s)
    print('[3-5] player grenade fixed (units + anim + snapshot)')
