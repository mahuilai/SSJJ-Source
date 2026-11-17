# -*- coding: utf-8 -*-
"""[OFFLINE-AI8] AI 八方向身法：斜着走 / 倒着走。

现状：AI 只输出 MoveTarget（目标点）+ MoveYaw（身体朝向），执行层永远
"朝目标点直冲"。动画侧其实齐全（leg 1=run 2=runb 3=walk 4=walkb 9/10 蹲
跑 5/340/6 跳，bot 后退动画由 MoveYaw-ViewYaw 夹角 >135° 驱动），缺的是
AI 真的产出倒走/斜走意图。

改动：
  1) BotIntent 加 MoveForward/MoveRight（-1~1 摇杆量），默认 (1,0) 直冲
  2) Combat 斜走近战位（前+横移合成）、Retreat 倒着走（-1 后 + 微横移，
     身体保持锁敌）、TakeCover 探头斜身
  3) ExecuteBotBspStep 摇杆模式：按 (MoveYaw 前后左右) 合成方向，
     寻路状态仍直冲 MoveTarget（行为不变）
  4) Retreat 加退出（2.8s 回 Combat）——否则倒走永远停不下（审计遗留 P2）
  5) GodMode 时 bot 不把玩家当威胁（免伤还挨打没意义）+ 玩家打 bot 秒杀
"""
import io

AI = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'

# ================= 1) BotIntent 加摇杆字段 =================
s = io.open(AI, encoding='utf-8', errors='surrogatepass').read()
old = '''	public int TargetId = -1;
	public BotState State;'''
new = '''	public int TargetId = -1;
	public BotState State;
	// [OFFLINE-AI8] 八方向移动输入（-1~1）：MoveYaw 是身体朝向，这两个是摇杆量。
	// 默认 (1,0)=朝 MoveTarget 直冲（寻路状态）；Combat/Retreat/TakeCover 用摇杆
	// 做斜走近位、倒着撤（身体仍锁敌）、探头斜身。
	public float MoveForward = 1f;
	public float MoveRight = 0f;'''
assert old in s, 'BotIntent anchor missing'
s = s.replace(old, new, 1)

# ================= 2) Tick 按状态填摇杆 + HasMove =================
old = '''		it.MoveTarget = goal;
		it.HasMove = (goal - self).sqrMagnitude > 0.36f;'''
new = '''		// [OFFLINE-AI8] 八方向身法意图：交战斜走近位 / 后撤倒着走 / 探头斜身。
		// MoveTarget 仍然设置（摇杆模式下执行层忽略它，仅作寻路兜底）。
		if (State == BotState.Combat)
		{
			float dTgt = (bestId >= 0) ? Vector3.Distance(self, best.Pos) : Vector3.Distance(self, LastKnownPos);
			float pref2 = p.Melee ? p.MeleeRange * 0.8f : p.PreferredDist;
			it.MoveForward = dTgt > pref2 * 1.15f ? 1f : (dTgt < pref2 * 0.65f ? -0.55f : 0f);
			it.MoveRight = StrafeSign;
		}
		else if (State == BotState.Retreat)
		{
			// 倒着走：身体保持锁敌（ViewYaw 走 AimYaw），摇杆向后 + 微横移
			it.MoveForward = -1f;
			it.MoveRight = (StrafeSign >= 0f) ? 0.35f : -0.35f;
		}
		else if (State == BotState.TakeCover)
		{
			it.MoveForward = (CoverPhase == 0) ? 0f : 0.7f;
			it.MoveRight = (CoverPhase == 1 || CoverPhase == 2) ? ((FlankSide >= 0) ? 0.6f : -0.6f) : 0f;
		}
		it.MoveTarget = goal;
		// 摇杆模式只要有输入就算要移动（goal 可能就在脚下导致旧判定不动）
		it.HasMove = (it.MoveForward != 0f || it.MoveRight != 0f)
			|| (goal - self).sqrMagnitude > 0.36f;'''
assert old in s, 'Tick HasMove anchor missing'
s = s.replace(old, new, 1)

# ================= 3) Retreat 退出（审计 P2-15）=================
old = '''		bool inSpecial = State == BotState.Retreat || State == BotState.TakeCover || State == BotState.Flank;'''
new = '''		bool inSpecial = State == BotState.Retreat || State == BotState.TakeCover || State == BotState.Flank;
		// [OFFLINE-AI8] 后撤限时 2.8s：旧实现 Retreat 无退出条件，残血 bot 一路
		// 倒着逃到脱战（不开枪不换弹）。到点回 Combat（UseCover 时下一步会进掩体）。
		if (State == BotState.Retreat && now - StateEnter > 2.8f)
		{
			State = BotState.Combat; StateEnter = now;
		}'''
assert old in s, 'inSpecial anchor missing'
s = s.replace(old, new, 1)
io.open(AI, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('OfflineBotAI.cs patched')

# ================= 4) ExecuteBotBspStep 摇杆合成 =================
g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
old = '''        Vector3 delta = it.MoveTarget - pos;
        delta.y = 0f;
        float distance = delta.magnitude;'''
new = '''        // [OFFLINE-AI8] 摇杆模式：AI 给 (MoveForward/MoveRight) 时按 MoveYaw 的
        // 前后左右合成方向（斜走/倒走）；寻路状态仍朝 MoveTarget 直冲。
        bool stickMode = (it.MoveForward != 1f || it.MoveRight != 0f);
        Vector3 delta;
        if (stickMode)
        {
            float yr = it.MoveYaw * Mathf.Deg2Rad;
            Vector3 fwd = new Vector3(Mathf.Sin(yr), 0f, Mathf.Cos(yr));
            Vector3 rgt = new Vector3(Mathf.Cos(yr), 0f, -Mathf.Sin(yr));
            delta = fwd * it.MoveForward + rgt * it.MoveRight;
            if (delta.sqrMagnitude < 0.01f) delta = fwd;
            delta.Normalize();
        }
        else
        {
            delta = it.MoveTarget - pos;
            delta.y = 0f;
        }
        float distance = stickMode ? 999f : delta.magnitude;'''
assert old in g, 'BspStep delta anchor missing'
g = g.replace(old, new, 1)

# step 计算处：摇杆模式不受到达距离限制
old = '''        float desired = distance > 1.2f ? targetSpeed : targetSpeed * Mathf.Clamp01(distance / 1.2f);
        b.ActualSpeed = Mathf.MoveTowards(b.ActualSpeed, desired, 1400f * dt);
        float speed = Mathf.Max(0f, b.ActualSpeed) / 100f;
        float step = Mathf.Min(distance, speed * dt);'''
new = '''        float desired = distance > 1.2f ? targetSpeed : targetSpeed * Mathf.Clamp01(distance / 1.2f);
        b.ActualSpeed = Mathf.MoveTowards(b.ActualSpeed, desired, 1400f * dt);
        float speed = Mathf.Max(0f, b.ActualSpeed) / 100f;
        // [OFFLINE-AI8] 摇杆模式没有"到达"概念（由 AI 状态机管距离），全速走
        float step = stickMode ? speed * dt : Mathf.Min(distance, speed * dt);'''
assert old in g, 'BspStep step anchor missing'
g = g.replace(old, new, 1)

# ================= 5) GodMode：bot 不瞄玩家 + 打 bot 秒杀 =================
# 5a) 威胁构建跳过玩家
old = '''        if (haveSelf)
        {
            PlayerEntityData me;
            if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me != null && !me.IsDead && me.Hp > 0f)
            {
                if (freeForAll || me.Team != data.Team)
                {
                    BotThreat t = new BotThreat();
                    t.Id = snap.Self;'''
new = '''        // [OFFLINE-GOD] 无敌模式下 bot 不把玩家当威胁（免伤还挨打没意义）
        if (haveSelf && !GodMode)
        {
            PlayerEntityData me;
            if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me != null && !me.IsDead && me.Hp > 0f)
            {
                if (freeForAll || me.Team != data.Team)
                {
                    BotThreat t = new BotThreat();
                    t.Id = snap.Self;'''
assert old in g, 'threat player anchor missing'
g = g.replace(old, new, 1)

# 5b) GodMode 打 bot 秒杀
old = '''        if (OfflineTdmMatch.IsProtected(targetId)) return;
        damage = AbsorbArmor(target, damage);
        target.Hp -= damage;
        if (target.Hp > 0f) return;
        brain.Alive = false;'''
new = '''        if (OfflineTdmMatch.IsProtected(targetId)) return;
        damage = AbsorbArmor(target, damage);
        // [OFFLINE-GOD] 无敌模式一键清 bot：伤害直接灌死（保留护甲吸收动画感）
        if (GodMode) damage = target.Hp + 999f;
        target.Hp -= damage;
        if (target.Hp > 0f) return;
        brain.Alive = false;'''
assert old in g, 'DamageBot god anchor missing'
g = g.replace(old, new, 1)

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
print('OfflineGameplay.cs patched')
