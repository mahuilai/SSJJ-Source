using System;
using System.Collections.Generic;
using UnityEngine;

// [OFFLINE-BOT-AI] 决策层 —— FSM + Behavior Tree 混合
//
// 架构参考 Kieeran/FPS-Game（MIT）：高层 FSM 管状态，低层 BT 管行为序列。
//   高层状态  Idle / Patrol / Search / Combat / Reload / Retreat
//   行为任务  LookAround / ScanArea / Seek / AimAt / Attack / TakeCover
//
// 原版客户端的 bot 逻辑在服务端（客户端只有 NewNpc 渲染，无 AI），
// 所以离线端必须自己实现。本层只输出"意图"，移动/伤害由 OfflineGameplay 执行。
//
// [OFFLINE-AI6] 行为层重写（用户反馈"跟屎一样/原地太空步"）：
//   1) 误差从逐帧白噪声改为低频游走（手指微抖 ≠ 每帧随机，后者是最强机械感来源）；
//   2) BotIntent 增加 MoveYaw/SpeedScale，移动方向与瞄准方向分离
//      （旧实现 data.MoveYaw = AimYaw，平移射击就是太空步）；
//   3) 到达减速 + 状态相关速度缩放（巡逻慢走/交战横移/突击全速）；
//   4) 近战冲砍（MeleeRange 内锁定突进 + 挥砍节奏）；
//   5) 队友分离力（不再叠成一坨）；
//   6) 开火分两段：未完全锁定时压制扫射，锁定后点射（真人节奏）。

public enum BotState
{
	Idle = 0,
	Patrol = 1,
	Search = 2,
	Combat = 3,
	Reload = 4,
	Retreat = 5,
	TakeCover = 6,
	Flank = 7,
	Advance = 8
}

// [OFFLINE-TDM-AI] 团队死斗定位：只决定偏好交战距离与冲锋意愿，不改 Personalize 的人格数值。
public enum BotRole
{
	Assault = 0,
	Support = 1,
	Sniper = 2,
	Anchor = 3
}

/// <summary>难度档案：反应/精度/节奏/身法，改数值就能调手感。</summary>
public class BotProfile
{
	public string Name = "normal";

	// 感知
	public float ViewDistance = 55f;
	public float FovDeg = 120f;
	public float HearRadius = 40f;
	public float MemoryTime = 4f;

	// 反应
	public float ReactionTime = 0.45f;
	public float TurnRate = 300f;

	// 精度
	public float AimErrorBase = 2.2f;
	public float AimConverge = 6f;
	public float AimErrorMoveMul = 1.8f;
	public float AimErrorTargetMoveMul = 1.5f;
	public float HeadshotBias = 0.15f;
	// [OFFLINE-AI6] 开火视锥角：误差小于它才视为"对准"（旧值 14° 太宽，等于乱枪也中）
	public float FireConeDeg = 9f;

	// 节奏
	public float BurstMin = 0.18f, BurstMax = 0.42f;
	public float PauseMin = 0.18f, PauseMax = 0.55f;
	public float ReloadTime = 2.2f;
	public int ClipSize = 30;

	// 伤害
	public float DmgMin = 6f, DmgMax = 12f;
	// [OFFLINE-AI6] 近战
	public bool Melee = false;
	public float MeleeRange = 2.6f;
	public float MeleeDmgMin = 45f, MeleeDmgMax = 70f;

	// 移动
	public float MoveSpeed = 3.4f;
	public float PreferredDist = 12f;
	public float StrafeAmount = 4f;
	public bool UseCover = true;
	public float RetreatHpRatio = 0.28f;
	// [OFFLINE-AI6] 状态相关速度缩放（相对 MoveSpeed）
	public float CombatSpeedScale = 0.62f;
	public float PatrolSpeedScale = 0.55f;
	// [OFFLINE-AI2] 掩体阈值 / 包抄意愿 / 压制射击比例
	public float CoverHpRatio = 0.62f;
	public float FlankChance = 0.45f;
	public float SuppressRatio = 0.35f;
	// [OFFLINE-AI3] 个体人格：同一难度下每个 bot 参数也不同，避免"一批同款机器人"
	public float Aggression = 0.60f;
	public float AimSkill = 1.00f;
	public float CoverBias = 0.60f;
	public float JitterScale = 1.00f;
	public float IrrationalChance = 0.08f;

	/// <summary>按 bot Id 派生一套人格。调用方拿到的是一份独立副本，可以放心改。</summary>
	public BotProfile Personalize(int id)
	{
		BotProfile q = (BotProfile)this.MemberwiseClone();
		uint h = Mix((uint)(id * 2654435761u));
		// 通用人格默认不连跳；map12 训练敌人在玩法层单独启用跳跃身法。
		q.Bhop = false;
		q.JumpDuck = false;
		q.Aggression = 0.25f + Rand01(h, 0) * 0.75f;
		q.AimSkill = 0.70f + Rand01(h, 8) * 0.60f;
		q.CoverBias = 0.30f + Rand01(h, 16) * 0.60f;
		q.JitterScale = 0.60f + Rand01(h, 24) * 0.80f;
		q.IrrationalChance = 0.05f + Rand01(h, 4) * 0.10f;
		// 越激进越贴近、瞄得越好
		q.PreferredDist *= (1.30f - q.Aggression * 0.50f);
		q.AimErrorBase /= q.AimSkill;
		q.AimConverge *= q.AimSkill;
		q.CoverHpRatio = 0.45f + q.CoverBias * 0.35f;
		// [OFFLINE-AI6] 瞄得越准开火视锥越窄（不会提前量乱枪）
		q.FireConeDeg = Mathf.Max(2f, q.FireConeDeg / q.AimSkill);
		return q;
	}

	private static uint Mix(uint h)
	{
		h ^= h >> 13; h *= 0x5bd1e995u; h ^= h >> 15;
		return h;
	}

	private static float Rand01(uint h, int shift)
	{
		return ((h >> shift) & 0xFF) / 255f;
	}
	public bool Bhop = false;
	public bool JumpDuck = false;

	// 决策
	public float ThinkMin = 0.3f, ThinkMax = 0.6f;

	public static BotProfile Get(string diff)
	{
		BotProfile p = new BotProfile();
		switch ((diff ?? "normal").Trim().ToLowerInvariant())
		{
		case "easy":
			p.Name = "easy";
			p.ViewDistance = 35f; p.FovDeg = 100f; p.HearRadius = 25f; p.MemoryTime = 2f;
			p.ReactionTime = 0.85f; p.TurnRate = 150f;
			p.AimErrorBase = 5.5f; p.AimConverge = 2.5f; p.HeadshotBias = 0.02f;
			p.FireConeDeg = 15f;
			p.BurstMin = 0.12f; p.BurstMax = 0.22f; p.PauseMin = 0.5f; p.PauseMax = 1.1f;
			p.ReloadTime = 3.2f; p.DmgMin = 4f; p.DmgMax = 8f;
			p.MoveSpeed = 2.6f; p.PreferredDist = 16f; p.StrafeAmount = 2f; p.UseCover = false;
			p.CombatSpeedScale = 0.5f;
			p.ThinkMin = 0.5f; p.ThinkMax = 1.0f;
			break;
		case "hard":
			p.Name = "hard";
			p.ViewDistance = 75f; p.FovDeg = 130f; p.HearRadius = 55f; p.MemoryTime = 6f;
			p.ReactionTime = 0.28f; p.TurnRate = 520f;
			p.AimErrorBase = 1.1f; p.AimConverge = 12f; p.HeadshotBias = 0.35f;
			p.FireConeDeg = 6f;
			p.BurstMin = 0.25f; p.BurstMax = 0.55f; p.PauseMin = 0.1f; p.PauseMax = 0.3f;
			p.ReloadTime = 1.8f; p.DmgMin = 9f; p.DmgMax = 16f;
			p.MoveSpeed = 4.2f; p.PreferredDist = 10f; p.StrafeAmount = 6f;
			p.CombatSpeedScale = 0.68f;
			p.ThinkMin = 0.2f; p.ThinkMax = 0.4f;
			break;
		case "nightmare":
			p.Name = "nightmare";
			p.ViewDistance = 90f; p.FovDeg = 150f; p.HearRadius = 65f; p.MemoryTime = 8f;
			p.ReactionTime = 0.22f; p.TurnRate = 760f;
			p.AimErrorBase = 0.75f; p.AimConverge = 16f; p.HeadshotBias = 0.35f;
			p.FireConeDeg = 5.5f;
			p.BurstMin = 0.35f; p.BurstMax = 0.7f; p.PauseMin = 0.08f; p.PauseMax = 0.24f;
			p.ReloadTime = 1.5f; p.DmgMin = 12f; p.DmgMax = 20f;
			p.MoveSpeed = 5.0f; p.PreferredDist = 8f; p.StrafeAmount = 7f;
            p.Bhop = true; p.JumpDuck = true; p.ThinkMin = 0.12f; p.ThinkMax = 0.25f;
			break;
		case "hell":
			p.Name = "hell";
			p.ViewDistance = 110f; p.FovDeg = 170f; p.HearRadius = 80f; p.MemoryTime = 10f;
			p.ReactionTime = 0.16f; p.TurnRate = 1100f;
			p.AimErrorBase = 0.45f; p.AimConverge = 24f; p.HeadshotBias = 0.50f;
			p.FireConeDeg = 4.5f;
			p.BurstMin = 0.4f; p.BurstMax = 0.85f; p.PauseMin = 0.05f; p.PauseMax = 0.16f;
			p.ReloadTime = 1.2f; p.DmgMin = 15f; p.DmgMax = 26f;
			p.MoveSpeed = 5.6f; p.PreferredDist = 7f; p.StrafeAmount = 8f;
			p.Bhop = true; p.JumpDuck = true; p.ThinkMin = 0.08f; p.ThinkMax = 0.18f;
			break;
		}
		return p;
	}
}

/// <summary>
/// [OFFLINE-BOT-WEAPON] bot 手里那把枪的真实数据。
/// 射速/弹夹取自原版 Weapon.json（AttackInterval / MaxClip），和玩家用同一份表；
/// 伤害不在客户端表里（服务端结算），这里按武器类别对齐原版 TTK 估算，
/// 不再用"每个 bot 无论拿什么枪都 30 发/0.1 秒一枪"的旧模型。
/// </summary>
public class BotWeaponStats
{
	public string Name = "";
	public bool NativeInfoResolved;
	public bool Melee;
	public bool Sniper;
	public float ShotInterval = 0.1f;   // 两发之间最短间隔（秒）
	public int ClipSize = 30;
	public float Damage = 38f;
	public float MeleeDamage = 55f;
	public float MeleeRange = 2.6f;

	public static BotWeaponStats Resolve(string weaponName, bool melee, BotProfile fallback)
	{
		BotWeaponStats s = new BotWeaponStats();
		s.Name = weaponName ?? "";
		s.Melee = melee;
		if (fallback != null)
		{
			s.ClipSize = fallback.ClipSize;
			s.MeleeRange = fallback.MeleeRange;
			s.MeleeDamage = (fallback.MeleeDmgMin + fallback.MeleeDmgMax) * 0.5f;
			s.Damage = (fallback.DmgMin + fallback.DmgMax) * 0.5f;
		}

		Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo info = null;
		try
		{
			info = Assets.Sources.Info.Weapon.WeaponInfoFactory.Instance.GetWeaponInfo(s.Name)
				as Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo;
		}
		catch (Exception) { }

		if (info != null)
		{
			s.NativeInfoResolved = true;
			if (info.AttackInterval >= 20) s.ShotInterval = info.AttackInterval / 1000f;
			if (info.MaxClip > 0) s.ClipSize = info.MaxClip;
			// WeaponType: 0 手枪 / 1 步枪 / 2 近战 / 5 狙击 / 6 霰弹 / 10 机枪
			if (info.Damage > 1)
			{
				s.Damage = info.Damage;
				if (s.Melee) s.MeleeDamage = info.Damage;
			}
			else switch (info.WeaponType)
			{
			case 0: s.Damage = 30f; break;
			case 2: s.Damage = 55f; break;
			case 5: s.Damage = 110f; s.Sniper = true; break;
			case 6: s.Damage = 90f; break;
			case 10: s.Damage = 34f; break;
			default: s.Damage = 38f; break;
			}
			if (info.WeaponType == 5) s.Sniper = true;
		}
		if (s.Melee) s.Damage = s.MeleeDamage;
		// PVE 转轮机枪在表里是 interval=1000 / clip=0（服务端自己灌弹），实际是连续压制武器。
		if (s.Name == "pvegatling")
		{
			s.ShotInterval = 0.09f;
			s.ClipSize = 200;
			s.Damage = 32f;
		}
		return s;
	}
}

/// <summary>AI 每帧给执行层的意图。</summary>
public class BotIntent
{
	public Vector3 MoveTarget;
	public bool HasMove;
	public bool WantFire;
	public bool WantReload;
	public bool WantCrouch;
	public bool WantJump;
	public bool Bhop;
	public float AimYaw;
	public float AimPitch;
	public float AimErrorDeg;
	// [OFFLINE-AI6] 移动方向与速度缩放：ViewYaw 跟枪，MoveYaw 走路，两者分离才不太空步
	public float MoveYaw;
	public float SpeedScale = 1f;
	public int TargetId = -1;
	public BotState State;
	// [OFFLINE-AI8] 八方向移动输入（-1~1）：MoveYaw 是身体朝向，这两个是摇杆量。
	// 默认 (1,0)=朝 MoveTarget 直冲（寻路状态）；Combat/Retreat 用摇杆
	// 做斜走近位、倒着撤（身体仍锁敌）、探头斜身。
	public float MoveForward = 1f;
	public float MoveRight = 0f;
	// [OFFLINE-VISION] 视线（视觉朝向）：默认=弹道。执行层写 data.ViewYaw 驱动
	// 头部/上身；弹道 AimYaw 保持精准不受晃动影响（命中判定只用 AimYaw）。
	public float ViewYaw;
	public float ViewPitch;

	// [OFFLINE-TDM-AI] 投掷物 / 技能意图：AI 只出意图，是否真的释放由 OfflineGameplay 决定。
	public bool WantGrenade;
	public Vector3 GrenadeTarget;
	public int GrenadeKind;   // 0 破片 / 1 闪光 / 2 烟雾
	public bool WantSkill;
}

/// <summary>感知到的一个威胁。</summary>
public struct BotThreat
{
	public int Id;
	public int Team;
	public Vector3 Pos;
	public Vector3 Velocity;
	public float ViewHeight;
	public float Hp;
	public float Distance;
	public bool Visible;
}

/// <summary>执行层提供的世界接口。</summary>
public class BotWorld
{
	public Func<Vector3, Vector3, bool> CanSee;
	public float Now;
	public bool RoundOver;
	// [OFFLINE-AI2] 队友是否正在与敌人交火（用于包抄判断）
	public bool SquadEngaging;
	// [OFFLINE-AI3] 执行层每帧喂进来的自身状态
	public float SelfSpeed;     // 自己的水平速度 cm/s（急停射击判定）

	// [OFFLINE-AI4] 玩家位置与阵营关系。
	// 缺这三个字段时 AI 没有任何"该往哪去"的依据，只能在出生点附近随机游走。
	public Vector3 PlayerPos;
	public bool PlayerValid;
	// map12 练枪：敌人可从侧后发现玩家，仍须通过实际遮挡检测，目标反应/瞄准误差不变。
	public bool TrainingPlayerAwareness;
	public bool IsAlly;         // 本 bot 与玩家同队（团队模式下）
	public int SelfPlayerId = -1;   // 玩家自己的实体 id，威胁评分要用

	// [OFFLINE-AI6] 同队存活 bot 的位置（分离力用，防止叠成一坨）
	public List<Vector3> NearbyAllies = new List<Vector3>(8);

	// [OFFLINE-TDM-AI] 团队死斗上下文（执行层逐帧填，缺省值保证未接入时不改变旧行为）
	public int SelfTeam = -1;
	public int PlayerTeam = -1;
	public bool MatchActive = true;
	// 可选：玩家存活标记。执行层不填时保持 true，等价于沿用 PlayerValid 的旧语义。
	public bool PlayerAlive = true;
	public Vector3 ObjectivePos;
	public bool HasObjective;
	public Vector3 SharedEnemyPos;
	public bool HasSharedEnemy;
	public float SharedEnemyTime = -999f;
	public int AliveAllies;
	public int AliveEnemies;
}

public class OfflineBotAgent
{
	public int Id;
	public int Team;
	public string Name = "";
	public Vector3 SpawnPos;
	public Vector3 Home;

	public BotState State = BotState.Patrol;
	public float StateEnter;

	public int TargetId = -1;
	public bool AimAtHead;
	public float FirstSeen = -1f;
	public float LastKnownTime = -999f;
	public Vector3 LastKnownPos;
	public Vector3 LastKnownVel;
	public Vector3 EnemyIntelPos;
	public float EnemyIntelTime = -999f;
	public float AimSettle;

	public List<Vector3> Path = new List<Vector3>(16);
	public int PathIdx;
	public float PathTime;
	public float NextPathDiag;
	public bool UseCombatPath;
	public float NextRouteExecDiag;
	public int PmoveDiagCount;
	public Vector3 MoveGoal;
	public float MoveGoalTime;
	public float StrafeSign = 1f;

	public float AimYaw, AimPitch;
	// [OFFLINE-LOOK-SMOOTH] 角色视觉朝向单独平滑，避免目标切换时瞬间转身。
	public float VisualYaw, VisualPitch;
	public bool VisualAnglesInitialized;
	public float ErrYaw, ErrPitch;
	// [OFFLINE-AI6] 误差目标低频游走（替代逐帧白噪声）
	public float ErrTgtYaw, ErrTgtPitch;
	public float ErrNextTgt;
	public bool InBurst;
	public float BurstEnd, PauseEnd, NextShot;
	public float NextShotDiag;
	public int Clip;
	// [OFFLINE-BOT-WEAPON] 手上武器的真实射速/弹夹/伤害（按武器表解析，见 BotWeaponStats）。
	public BotWeaponStats Weapon;
	public float NextWeaponResolve;
	// 执行层的射击节流：旧实现一帧一发，0.18s 的"一个点射"能打出十几发伤害。
	public float ReloadEnd;
	public bool ReloadAnimIssued;

	public bool Alive = true;
	public float RespawnAt;
	public float Hp = 100f;
	public float MaxHp = 100f;

	public float NextThink;
	public Vector3 StuckPos;
	public float StuckTime;
	// [OFFLINE-STUCK] 卡墙自愈：连续卡住计数 + 短时侧移脱困
	public int StuckCount;
	public float StuckEscapeUntil;
	public float StuckEscapeSign;
	public float LastStuckLog;
	// [OFFLINE-SPAWN-NEAR] 出生时玩家还没定位，首帧后补一次"刷到玩家附近"。
	public bool NeedsNearPlacement = true;
	public int NearPlaceTries;
	public float NearPlaceNextTry;
	// [OFFLINE-SPAWN-VISIBLE] 短暂冻结在玩家视野内，避免 AI 在同一帧又把
	// 刚召回的 bot 推回远处出生点。由 OfflineGameplay 的视野锚定逻辑维护。
	public float VisibleHoldUntil = -1f;

	// [OFFLINE-AI4] 与玩家的关系 / 最后一次接触敌人的时间（驱动主动推进）
	public bool Ally;
	public float LastContact = -999f;
	public float LastMoveLog;

	// [OFFLINE-TDM-AI] 团战角色 / 投掷与技能冷却 / 最后攻击者
	public BotRole Role = BotRole.Assault;
	public bool RoleAssigned;
	public float NextGrenade;
	private float _gdNext;   // [OFFLINE-GDIAG]
	public float NextSkill;
	public int LastAttackerId = -1;
	public Vector3 LastAttackerPos;
	public float LastAttackerTime = -999f;
	// 人格原始偏好距离（角色修正前），避免复活重分配时距离被反复叠加
	public float RoleBaseDist = -1f;
	// 已采纳过的队友报点时间戳，防止同一条报点每帧重复采纳
	public float SharedReportTime = -999f;

	// [OFFLINE-KILLCHAIN] 计分板用的个人战绩
	public int Kills;
	public int Deaths;

	// [OFFLINE-AI2] 感知累加 / 掩体 / 包抄 / 压制
	public float Awareness;
	public Vector3 CoverPos;
	public float CoverUntil;
	public int FlankSide = 1;
	public float FlankUntil;
	public float NextSuppress;
	public float LastFlankEnd = -999f;
	public float LastRetreatEnd = -999f;
	public float NextCoverSearch;

	// [OFFLINE-AI3] 拟人化：弹簧瞄准速度 / 急停窗口 / 反应延迟 / 掩体 peek 阶段 / 非理性
	public float AimVelYaw;
	public float AimVelPitch;
	public float StopUntil;
	public float ReactDelay = -1f;
	public int CoverPhase;
	public float CoverPhaseEnd;
	public bool CoverArrived;
	public float NextIrrational = -1f;
	public float IrrationalUntil;
	public Vector3 LastPos;
	public float LastPosTime;
	public Vector3 SpeedSamplePos;
	public float SpeedSampleTime = -1f;
	public Vector3 ObservedVelocity;
	public float ActualSpeed;
	public uint DriftSeed;
	private float _visDiagNext;
	// [OFFLINE-VISION] 随机扫视：到点快速扫出再回正（人眼珠不时飘一下）
	public float NextScan;
	public float ScanEnd;
	public float ScanDur;
	public float ScanMag;
	public float LookPlayerDiagNext;

	public BotIntent Tick(BotProfile p, BotWorld w, List<BotThreat> threats, Vector3 self)
	{
		BotIntent it = new BotIntent();
		it.State = State;
		it.SpeedScale = 1f;
		float now = w.Now;
		float dt = Mathf.Max(0.001f, Time.deltaTime);

		if (!Alive || w.RoundOver)
		{
			it.MoveTarget = self;
			it.MoveYaw = AimYaw;
			it.AimYaw = AimYaw;
			it.AimPitch = AimPitch;
			return it;
		}

		// [OFFLINE-TDM-AI] 角色分配：首次 Tick（以及每次复活后）按武器 + 人格定型一次
		if (!RoleAssigned) AssignRole(p, now);

		// ============ BT 任务：ScanArea（感知） ============
		int bestId = -1;
		float bestScore = float.MaxValue;
		BotThreat best = default(BotThreat);
		bool anyVisible = false;
		// [OFFLINE-TDM-AI] 玩家权重只在敌对阵营生效（执行层未填 Team 时保持旧行为）
		bool playerIsEnemy = (w.SelfTeam < 0 || w.PlayerTeam < 0) || (w.SelfTeam != w.PlayerTeam);

		for (int i = 0; i < threats.Count; i++)
		{
			BotThreat t = threats[i];
			Vector3 to = t.Pos - self; to.y = 0f;
			float dist = to.magnitude;
			if (dist > p.ViewDistance) continue;

			// 视锥：近距离全向感知（真人 12m 内有脚步声/余光一定察觉得到），远距离必须面向。
			// 原值 5m 太小：玩家贴到 6m 侧后 bot 依然完全无感，观感就是"瞎子"。
			bool trainingPlayer = w.TrainingPlayerAwareness && t.Id == w.SelfPlayerId;
			if (dist > 12f && !trainingPlayer)
			{
				Vector3 fwd = new Vector3(Mathf.Sin(AimYaw * Mathf.Deg2Rad), 0f, Mathf.Cos(AimYaw * Mathf.Deg2Rad));
				float cosHalf = Mathf.Cos(p.FovDeg * 0.5f * Mathf.Deg2Rad);
				if (Vector3.Dot(fwd, to.normalized) < cosHalf) continue;
			}

			t.Visible = w.CanSee(self + Vector3.up * 1.55f, t.Pos + Vector3.up * 1.55f);
			if (!t.Visible) continue;
			anyVisible = true;
			LastContact = now;

			float score = dist;
			if (t.Id == TargetId) score -= 10f;      // 目标黏性
			// [OFFLINE-TDM-AI] 玩家权重 25 -> 6：TDM 里 bot 要互相打，不能全员围着玩家转。
			if (playerIsEnemy && w.SelfPlayerId >= 0 && t.Id == w.SelfPlayerId) score -= 6f;
			// [OFFLINE-TDM-AI] 残血优先加强（原 -5），残到 20% 以下再补一刀
			if (t.Hp < 40f) score -= 9f;
			if (t.Hp < 20f) score -= 7f;
			// [OFFLINE-TDM-AI] 角色射程偏好：狙击手压远目标，突击手压近目标
			if (Role == BotRole.Sniper)
				score -= Mathf.Clamp((dist - 18f) * 0.45f, -4f, 10f);
			else if (Role == BotRole.Assault)
				score += Mathf.Clamp((dist - 10f) * 0.50f, -3f, 12f);
			// [OFFLINE-TDM-AI] 刚被谁打过：小额复仇权重，不至于完全无视开火来源
			if (LastAttackerId >= 0 && t.Id == LastAttackerId && now - LastAttackerTime < 3f) score -= 3f;
			if (score < bestScore) { bestScore = score; bestId = t.Id; best = t; }
		}

		// [OFFLINE-AI3] 非理性行为注入：真人会犯错（残血不撤、换弹不进掩体）。
		// 永远做最优决策的 AI 反而"太假"，按人格概率制造少量次优动作。
		if (NextIrrational < 0f) NextIrrational = now + UnityEngine.Random.Range(6f, 14f);
		if (now >= NextIrrational)
		{
			NextIrrational = now + UnityEngine.Random.Range(9f, 18f);
			if (UnityEngine.Random.value < p.IrrationalChance)
				IrrationalUntil = now + UnityEngine.Random.Range(1.5f, 3.0f);
		}
		bool irrational = now < IrrationalUntil;

		// ============ 感知累加器（haner-ai 的 Awareness） ============
		// 看见不等于立刻锁死：连续可见累积到 1 才进入交战，丢失后缓慢衰减。
		if (bestId >= 0) Awareness = Mathf.Min(1f, Awareness + dt / Mathf.Max(0.05f, p.ReactionTime));
		else Awareness = Mathf.Max(0f, Awareness - dt / Mathf.Max(0.4f, p.MemoryTime * 0.5f));
		bool engaged = bestId >= 0 && Awareness >= 0.999f;

		// ============ FSM 状态转移 ============
		float hpRatio = Mathf.Clamp01(Hp / Mathf.Max(1f, MaxHp));
		// 站到掩体后视线通常会暂时被遮住，阶段计时不能依赖当前可见目标。
		if (State == BotState.TakeCover)
		{
			if (!CoverArrived && (self - CoverPos).sqrMagnitude <= 1.3f * 1.3f)
			{
				CoverArrived = true;
				CoverUntil = now + UnityEngine.Random.Range(2.6f, 4.2f);
				CoverPhaseEnd = now + 0.35f;
				NextThink = 0f;
			}
			if (CoverArrived && now >= CoverPhaseEnd)
			{
				CoverPhase = (CoverPhase + 1) & 3;
				CoverPhaseEnd = now + (CoverPhase == 0 ? 0.35f : CoverPhase == 1 ? 0.42f
					: CoverPhase == 2 ? 0.90f : 1.10f);
				NextThink = 0f;
				if (CoverPhase == 0 && now >= CoverUntil - 0.9f) CoverUntil = now;
			}
			if (now >= CoverUntil)
			{
				State = bestId >= 0 ? BotState.Combat
					: ((now - LastKnownTime) < p.MemoryTime ? BotState.Advance : BotState.Patrol);
				StateEnter = now; CoverPhase = 0; CoverPhaseEnd = 0f; NextThink = 0f;
			}
		}
		if (State == BotState.Reload)
		{
			if (now >= ReloadEnd)
			{
				Clip = (Weapon != null && Weapon.ClipSize > 0) ? Weapon.ClipSize : p.ClipSize;
				State = anyVisible ? BotState.Combat : BotState.Patrol;
				StateEnter = now;
			}
		}
		else if (bestId >= 0)
		{
			if (TargetId != bestId)
			{
				TargetId = bestId; FirstSeen = now; AimSettle = 0f;
				InBurst = false; BurstEnd = 0f; PauseEnd = 0f;
				AimAtHead = UnityEngine.Random.value < p.HeadshotBias;
				// [OFFLINE-AI3] 反应时间不是常数：每次都重抽（真人 80~250ms 波动很大）
				ReactDelay = p.ReactionTime * UnityEngine.Random.Range(0.7f, 1.5f);
			}
			else if (FirstSeen < 0f) FirstSeen = now;
			LastKnownPos = best.Pos; LastKnownVel = best.Velocity; LastKnownTime = now;
			EnemyIntelPos = best.Pos; EnemyIntelTime = now;

			if (State == BotState.Flank && now >= FlankUntil) { StateEnter = now; State = BotState.Combat; }

		// [OFFLINE-AI8] 后撤限时 2.8s：旧实现 Retreat 无退出条件，残血 bot 一路
		// 倒着逃到脱战（不开枪不换弹）。到点回 Combat（UseCover 时下一步会进掩体）。
		if (State == BotState.Retreat && now - StateEnter > 2.8f)
		{
			State = BotState.Combat; StateEnter = now; LastRetreatEnd = now;
		}
			bool inSpecial = State == BotState.Retreat || State == BotState.TakeCover || State == BotState.Flank;

			if (!irrational && p.UseCover && hpRatio < p.RetreatHpRatio && State != BotState.Retreat
				&& now - LastRetreatEnd >= 5f)
			{
				State = BotState.Retreat; StateEnter = now;
			}
			else if (Clip <= 0 && State != BotState.TakeCover && !p.Melee)
			{
				// 换弹时优先钻掩体，而不是站着换
				if (!irrational && p.UseCover && hpRatio < 0.9f && now - StateEnter > 0.3f
					&& now >= NextCoverSearch && EnterCover(p, self, best.Pos, now))
				{
					// 已开始前往掩体。
				}
				else
				{
					State = BotState.Reload; StateEnter = now; ReloadEnd = now + p.ReloadTime;
				}
			}
			else if (!inSpecial)
			{
				// [OFFLINE-TDM-AI] 角色掩体倾向：狙击/架点更愿意进掩体，突击手更倾向继续压
				float coverLine = p.CoverHpRatio + RoleCoverBonus();
				bool wantCover = p.UseCover && hpRatio < coverLine && now - StateEnter > 1.0f && now >= NextCoverSearch;
				// [OFFLINE-TDM-AI] 包抄按角色冲锋意愿缩放（狙击手基本不绕侧）
				float flankChance = p.FlankChance * (0.70f + 0.60f * ChargeWillingness(w));
				if (Role == BotRole.Sniper) flankChance *= 0.35f;
				bool wantFlank = w.SquadEngaging
					&& best.Distance > p.PreferredDist * 1.2f
					&& now - LastFlankEnd > 6f
					&& ((Id + (int)(now * 0.13f)) % 100) < (int)(Mathf.Clamp01(flankChance) * 100f);
				// 人数被碾压时不硬绕（执行层未填 AliveAllies/Enemies 时为 0，不生效）
				if (w.AliveEnemies > 0 && w.AliveAllies > 0 && w.AliveEnemies > w.AliveAllies * 2)
					wantFlank = false;
				if (wantCover && EnterCover(p, self, best.Pos, now)) { }
				else if (wantFlank) EnterFlank(self, best.Pos, now);
				else if (State != BotState.Combat)
				{
					State = BotState.Combat;
					StateEnter = now;
				}
			}
		}
		else
		{
			TargetId = -1; FirstSeen = -1f; AimSettle = 0f;
			bool memory = (now - LastKnownTime) < p.MemoryTime;

			// [OFFLINE-TDM-AI] 队友报点：6 秒内的共享敌人位置当作新的 LastKnownPos（模拟队友喊点）。
			if (w.HasSharedEnemy && (now - w.SharedEnemyTime) < 6f
				&& w.SharedEnemyTime > LastKnownTime && w.SharedEnemyTime > SharedReportTime + 0.5f)
			{
				SharedReportTime = w.SharedEnemyTime;
				LastKnownPos = w.SharedEnemyPos;
				LastKnownTime = w.SharedEnemyTime;
				EnemyIntelPos = w.SharedEnemyPos; EnemyIntelTime = w.SharedEnemyTime;
				memory = true;
				if (State == BotState.Patrol || State == BotState.Idle || State == BotState.Search)
				{
					State = ChargeWillingness(w) >= 0.6f ? BotState.Advance : BotState.Search;
					StateEnter = now;
					NextThink = 0f;
				}
			}

			// [OFFLINE-AI3] 记忆漂移：人丢了目标只会记得"大概那个方向"，越久越模糊
			if (memory && now - LastKnownTime > 0.4f)
			{
				float drift = Mathf.Min(1.4f, (now - LastKnownTime) * 0.30f) * dt;
				LastKnownPos += new Vector3(
					Mathf.Sin(now * 1.7f + Id * 0.9f) * drift, 0f,
					Mathf.Cos(now * 1.3f + Id * 0.6f) * drift);
			}
			if (State == BotState.Combat || State == BotState.Retreat
				|| (State == BotState.TakeCover && !memory) || State == BotState.Flank || State == BotState.Reload)
			{
				// 目标刚消失：全速压到最后已知位置，而不是原地绕圈找
				State = memory ? BotState.Advance : BotState.Patrol;
				StateEnter = now;
				CoverUntil = 0f; FlankUntil = 0f;
			}
			else if ((State == BotState.Search || State == BotState.Advance) && !memory)
			{
				State = BotState.Patrol; StateEnter = now;
			}

			// [OFFLINE-TDM-AI] 队友：只在离玩家过远时归队，其余时间必须和队伍一起推目标点。
			// 旧逻辑在玩家 22m 内就什么都不做，导致队友全程在玩家身边巡逻、敌人却在抱团推进。
			Ally = w.IsAlly;
			if (w.IsAlly)
			{
				bool playerUp = w.PlayerValid && w.PlayerAlive;
				float distToPlayer = playerUp ? Vector3.Distance(self, w.PlayerPos) : float.MaxValue;
				bool headingToPlayer = playerUp && (LastKnownPos - w.PlayerPos).sqrMagnitude < 100f;
				if (playerUp && distToPlayer > 32f
					&& State != BotState.Reload && State != BotState.TakeCover)
				{
					State = BotState.Advance;
					LastKnownPos = w.PlayerPos;
					LastKnownTime = now;
					StateEnter = now;
				}
				else if (playerUp && distToPlayer < 8f
					&& State == BotState.Advance && headingToPlayer)
				{
					State = BotState.Patrol; StateEnter = now;
				}
				else
				{
					PushObjective(w, self, now);
				}
			}
			else
			{
				PushObjective(w, self, now);
			}
		}

		// 脱离视线后也要完成换弹，避免空弹夹的人机一直追着最后位置跑。
		if (bestId < 0 && !p.Melee && Clip <= 0 && State != BotState.Reload)
		{
			State = BotState.Reload;
			StateEnter = now;
			ReloadEnd = now + p.ReloadTime;
		}

		// ============ BT 任务：AimAt ============
		Vector3 eye = self + Vector3.up * 1.55f;
		Vector3 aimAt;
		if ((State == BotState.Combat || State == BotState.TakeCover) && bestId >= 0)
		{
			// 预判提前量：难度越高越会打提前量
			float lead = Mathf.Clamp(best.Distance / 500f, 0f, 0.22f) * (p.TurnRate / 300f);
			aimAt = best.Pos + best.Velocity * lead;
			float targetViewHeight = best.ViewHeight > 0.1f ? best.ViewHeight : 1.5f;
			aimAt.y += AimAtHead ? targetViewHeight : targetViewHeight * 0.70f;
		}
		else if (State == BotState.Search || State == BotState.Advance)
		{
			// [OFFLINE-AI3] 预瞄：不盯最后位置正中心（人不会精确知道），
			// 而是朝"自己这一侧可能冒头的位置"偏一点，模拟高手的预瞄习惯。
			Vector3 toMe = self - LastKnownPos; toMe.y = 0f;
			if (toMe.sqrMagnitude < 0.01f) toMe = Vector3.forward;
			toMe.Normalize();
			Vector3 sideP = Vector3.Cross(Vector3.up, toMe) * (FlankSide >= 0 ? 1f : -1f);
			aimAt = LastKnownPos + toMe * 0.8f + sideP * 0.9f + Vector3.up * 1.45f;
		}
		else if (State == BotState.TakeCover || State == BotState.Flank)
		{
			aimAt = LastKnownPos + Vector3.up * 1.55f;
		}
		else
		{
			// 无目标时不要把头锁在身体正前方：加入低频左右扫视和轻微回正，
			// 让 Bot 像人在观察环境，而不是固定朝向的木偶。
			float lookYaw = Mathf.Sin(now * 0.73f + Id * 1.17f) * 9f
				+ Mathf.Sin(now * 1.31f + Id * 0.41f) * 3f;
			float lookPitch = Mathf.Sin(now * 0.61f + Id * 0.83f) * 1.8f;
			float lookRad = (AimYaw + lookYaw) * Mathf.Deg2Rad;
			aimAt = eye + new Vector3(Mathf.Sin(lookRad), 0f, Mathf.Cos(lookRad)) * 12f
				+ Vector3.up * lookPitch * 0.03f;
		}

		Vector3 dv = aimAt - eye;
		float horiz = new Vector2(dv.x, dv.z).magnitude;
		float wantYaw = horiz > 0.05f ? Mathf.Atan2(dv.x, dv.z) * Mathf.Rad2Deg : AimYaw;
		float wantPitch = -Mathf.Atan2(dv.y, Mathf.Max(0.05f, horiz)) * Mathf.Rad2Deg;

		// [OFFLINE-AI3] 二阶临界阻尼瞄准（替代恒速插值）。
		// 人手臂是"目标-阻尼"系统：起步加速 → 中段最快 → 接近减速 → 轻微过冲回修。
		// 恒速 MoveTowards 永远匀速直线，是最明显的机械感来源。
		// ω 按角度差缩放（Fitts 定律：转得越多耗时越长），再叠加手抖。
		SpringAim(wantYaw, wantPitch, p, dt);

		// 误差：连续对准越久越准，双方移动放大
		float errGoal;
		if (State == BotState.Combat && bestId >= 0)
		{
			AimSettle += dt;
			float conv = Mathf.Clamp01(AimSettle / 1.1f);
			errGoal = Mathf.Lerp(p.AimErrorBase, 0.12f, conv);
			if (best.Velocity.sqrMagnitude > 6f) errGoal *= p.AimErrorTargetMoveMul;
		}
		else
		{
			errGoal = p.AimErrorBase;
		}
		// [OFFLINE-AI6] 误差目标低频游走：每 0.35~0.8s 重抽一次目标再缓慢逼近。
		// 旧实现每帧都 Random.Range 换目标 —— 那是高频白噪声，看起来就是"机器在抖"。
		if (now >= ErrNextTgt)
		{
			ErrNextTgt = now + UnityEngine.Random.Range(0.35f, 0.8f);
			float g = errGoal * p.JitterScale;
			ErrTgtYaw = UnityEngine.Random.Range(-g, g);
			ErrTgtPitch = UnityEngine.Random.Range(-g * 0.6f, g * 0.6f);
		}
		float errConv = Mathf.Max(2.5f, p.AimConverge * 0.55f);
		ErrYaw = Mathf.MoveTowards(ErrYaw, ErrTgtYaw, errConv * dt);
		ErrPitch = Mathf.MoveTowards(ErrPitch, ErrTgtPitch, errConv * 0.8f * dt);

		it.AimYaw = AimYaw + ErrYaw;
		it.AimPitch = AimPitch + ErrPitch;

		// [OFFLINE-VISION] 视线拟人化：呼吸微晃 + 随机扫视（只动 ViewYaw，不动弹道）
		// 呼吸：双频正弦，越准的 bot 晃得越少（easy ~1.1° / hell ~0.4°）
		// 呼吸晃幅按难度直给：easy 3° / normal 1.6° / hard 1° / nightmare 0.7° / hell 0.5°
		// （旧公式被 AimSkill 压低到 0.3°，肉眼不可见）
		float breathAmp = p.Name == "easy" ? 3.0f : p.Name == "hard" ? 1.0f
			: p.Name == "nightmare" ? 0.7f : p.Name == "hell" ? 0.5f : 1.6f;
		float breath = Mathf.Sin(now * 1.9f + Id * 1.3f) * breathAmp
			+ Mathf.Sin(now * 6.3f + Id * 2.1f) * breathAmp * 0.32f;
		// 扫视：非交战/非掩体状态每 3~7s 一次；sin(πk) 扫出再回正
		if (NextScan <= 0f) NextScan = now + UnityEngine.Random.Range(2f, 6f);
		if (now >= NextScan && State != BotState.Combat && State != BotState.TakeCover
			&& State != BotState.Reload && bestId < 0)
		{
			NextScan = now + UnityEngine.Random.Range(3f, 7f);
			ScanDur = UnityEngine.Random.Range(0.14f, 0.24f);
			ScanEnd = now + ScanDur;
			ScanMag = (UnityEngine.Random.value < 0.5f ? -1f : 1f) * UnityEngine.Random.Range(20f, 38f);
			UnityEngine.Debug.Log("[OFFLINE-SCAN] id=" + Id + " mag=" + ScanMag.ToString("F0") + " dur=" + ScanDur.ToString("F2"));
		}
		float scanOff = 0f;
		if (now < ScanEnd && ScanDur > 0f)
		{
			float k = 1f - (ScanEnd - now) / ScanDur;
			scanOff = Mathf.Sin(k * Mathf.PI) * ScanMag;
		}
		float desiredViewYaw = it.AimYaw + breath + scanOff;
		float desiredViewPitch = Mathf.Clamp(it.AimPitch + breath * 0.35f, -80f, 80f);
		// [OFFLINE-BHOP50] 不会身法的 bot 保留战斗 AimYaw 用于射击，
		// 但第三人称视觉追踪玩家，避免出现 bot 朝敌人开火却背对玩家。
		// [OFFLINE-LOOKDEAD] 玩家死亡后仍可盯最后已知位置；
		// [OFFLINE-HUMANLOOK] 但必须先通视：旧实现让全图 bot 隔墙盯玩家（vOff 1000°+），
		// 观感就是"人机开透视"，这条比"一直看着玩家"更假。
		if (w.PlayerValid)
		{
			Vector3 playerEye = w.PlayerPos + Vector3.up * 1.55f;
			bool playerVisible = w.CanSee != null && w.CanSee(eye, playerEye);
			bool playerIsTarget = bestId >= 0 && bestId == w.SelfPlayerId;
			bool recentlyKnown = (now - LastKnownTime) < 2.5f;
			bool close = Vector3.Distance(self, w.PlayerPos) < 20f;
			if (playerVisible && (playerIsTarget || recentlyKnown || close))
			{
				Vector3 playerDelta = playerEye - eye;
				float playerHoriz = new Vector2(playerDelta.x, playerDelta.z).magnitude;
				if (playerHoriz > 0.05f)
				{
					desiredViewYaw = Mathf.Atan2(playerDelta.x, playerDelta.z) * Mathf.Rad2Deg;
					desiredViewPitch = Mathf.Clamp(-Mathf.Atan2(playerDelta.y, playerHoriz) * Mathf.Rad2Deg, -80f, 80f);
					if (now >= LookPlayerDiagNext)
					{
						LookPlayerDiagNext = now + 2f;
						UnityEngine.Debug.Log("[OFFLINE-LOOKPLAYER] id=" + Id + " yaw="
							+ desiredViewYaw.ToString("F1") + " pitch=" + desiredViewPitch.ToString("F1"));
					}
				}
			}
		}
		if (!VisualAnglesInitialized)
		{
			VisualYaw = AimYaw;
			VisualPitch = AimPitch;
			VisualAnglesInitialized = true;
		}
		float visualTurnRate = Mathf.Clamp(p.TurnRate * 0.4f, 100f, 210f);
		VisualYaw = Mathf.MoveTowardsAngle(VisualYaw, desiredViewYaw, visualTurnRate * dt);
		VisualYaw = Mathf.Repeat(VisualYaw + 180f, 360f) - 180f;
		VisualPitch = Mathf.MoveTowards(VisualPitch, desiredViewPitch, visualTurnRate * 0.65f * dt);
		it.ViewYaw = VisualYaw;
		it.ViewPitch = Mathf.Clamp(VisualPitch, -80f, 80f);
		// [OFFLINE-VISION] 限频诊断：视线与弹道的偏差（呼吸+扫视）实证
		if (now >= _visDiagNext)
		{
			_visDiagNext = now + 2.5f;
			UnityEngine.Debug.Log("[OFFLINE-VISION] id=" + Id + " vwOff=" + Mathf.DeltaAngle(it.AimYaw, it.ViewYaw).ToString("F2")
				+ " breath=" + breath.ToString("F2") + " scan=" + scanOff.ToString("F1")
				+ " state=" + State);
		}
		// [OFFLINE-BHOPCOMMON] 公共汇总：身法 bot 只要有移动意图就持续给跳意图。
		// ApplyVertical 只在落地帧真正起跳 → 落地自动再跳 = 连跳（CS bhop 机制）。
		// 放在这里保证 Combat/Patrol/Advance/Retreat/TakeCover 全状态生效。
		it.WantJump = p.Bhop && it.HasMove && !(StopUntil > 0f && now < StopUntil);
		// [OFFLINE-RUNFIX] 旧写法 = "会跳蹲就全程蹲着走"，bot 移动速度被蹲速压死、
		// 且蹲走动画与原版 walk 不一致。老板要求 bot 跑着走：常态不蹲。
		it.WantCrouch = false;
		it.AimErrorDeg = Mathf.Abs(ErrYaw) + Mathf.Abs(ErrPitch);
		it.TargetId = TargetId;

		// ============ BT 任务：Attack ============
		bool isMelee = p.Melee || (Weapon != null && Weapon.Melee);
		float meleeRange = (Weapon != null && Weapon.MeleeRange > 0f) ? Weapon.MeleeRange : p.MeleeRange;
		if ((State == BotState.Combat || State == BotState.TakeCover)
			&& bestId >= 0 && now >= NextShot && !isMelee && Clip > 0)
		{
			bool reacted = (now - FirstSeen) >= (ReactDelay > 0f ? ReactDelay : p.ReactionTime);
			float angErr = Mathf.Abs(Mathf.DeltaAngle(AimYaw, wantYaw));
			bool onTarget = angErr < p.FireConeDeg;

			// [OFFLINE-AI3] 急停射击：移动中先花 80~180ms 减速稳定，再扣扳机。
			// 真人没有"边全速跑边精准点射"这回事，这是最容易被看出来的假动作之一。
			if (reacted && w.SelfSpeed > 250f && StopUntil <= 0f)
				StopUntil = now + UnityEngine.Random.Range(0.08f, 0.18f);
			bool stopped = (StopUntil <= 0f) || (now >= StopUntil);
			if (stopped) StopUntil = 0f;

			// [OFFLINE-AI3] 掩体里只有"射击段"才露头开火，缩回段强制哑火
			bool coverCanFire = (State != BotState.TakeCover) || (CoverPhase == 2);
			// [OFFLINE-AI6] 两段式开火：感知还没累满（刚照面）时先压制扫射制造压迫感；
			// 完全锁定后才走点射节奏。旧实现两段混在一起，观感就是"一直乱扫"。
			// [OFFLINE-BOT-WEAPON] 射速门控：WantFire 只是"想开火"，真正扣扳机受武器 AttackInterval 限制。
			// 旧实现 burst 期间每帧 WantFire=true，执行层每帧结算一次伤害 —— 0.2s 能打十几发。
			bool shotReady = now >= NextShot;
			if (reacted && shotReady && coverCanFire && !engaged && !onTarget && angErr < 40f && now >= NextSuppress
				&& UnityEngine.Random.value < p.SuppressRatio * dt * 4f)
			{
				// [OFFLINE-AI2] 压制射击：还没完全对准也扣扳机，制造被压制的压迫感
				NextSuppress = now + UnityEngine.Random.Range(0.3f, 0.7f);
				it.WantFire = true;
			}
			if (reacted && shotReady && engaged && onTarget && stopped && coverCanFire)
			{
				if (InBurst)
				{
					if (now >= BurstEnd) { InBurst = false; PauseEnd = now + UnityEngine.Random.Range(p.PauseMin, p.PauseMax); }
					else { it.WantFire = true; }
				}
				else if (now >= PauseEnd)
				{
					InBurst = true;
					BurstEnd = now + UnityEngine.Random.Range(p.BurstMin, p.BurstMax);
					it.WantFire = true;
				}
			}
		}
		// [OFFLINE-AI6] 近战冲砍：进入砍距就突进，到位后按挥砍节奏出手
		if (isMelee && bestId >= 0 && State == BotState.Combat && now >= NextShot)
		{
			bool reacted = (now - FirstSeen) >= (ReactDelay > 0f ? ReactDelay : p.ReactionTime);
			if (reacted && best.Distance <= meleeRange + 0.6f)
			{
				it.WantFire = best.Distance <= meleeRange;
			}
		}
		if (it.WantFire)
		{
			int clipSize = (Weapon != null && Weapon.ClipSize > 0) ? Weapon.ClipSize : p.ClipSize;
			if (isMelee)
			{
				float swing = (Weapon != null) ? Mathf.Clamp(Weapon.ShotInterval, 0.45f, 1.0f) : 0f;
				NextShot = now + (swing > 0f ? swing : UnityEngine.Random.Range(0.5f, 0.85f));
			}
			else
			{
				NextShot = now + ((Weapon != null && Weapon.ShotInterval > 0f) ? Weapon.ShotInterval : 0.1f);
			}
			if (!isMelee) Clip--;
			else Clip = clipSize;
		}
		else if (State != BotState.Combat) InBurst = false;

		it.WantReload = (State == BotState.Reload);
		it.Bhop = p.Bhop;

		// [OFFLINE-TDM-AI] 投掷物 / 技能只输出意图，执行层可以忽略，AI 不做任何状态假设
		PlanGrenade(p, w, best, bestId, engaged, hpRatio, self, now, it);
		PlanSkill(p, w, best, bestId, engaged, now, it);

		// ============ BT 任务：Seek / TakeCover（移动） ============
		if (State != BotState.Combat) UseCombatPath = false;
		if (now >= NextThink)
		{
			NextThink = now + UnityEngine.Random.Range(p.ThinkMin, p.ThinkMax);
			PlanMovement(p, self, bestId >= 0 ? best.Pos : LastKnownPos, now);
		}

		// 沿路径推进
		Vector3 goal = AdvancePath(self, now);
		// [OFFLINE-AI6] 队友分离力：2.2m 内互相推开，不再叠成一坨
		if (w.NearbyAllies != null)
		{
			for (int i = 0; i < w.NearbyAllies.Count; i++)
			{
				Vector3 d = self - w.NearbyAllies[i]; d.y = 0f;
				float dm = d.magnitude;
				if (dm > 0.05f && dm < 2.2f) goal += d.normalized * (2.2f - dm) * 0.9f;
			}
		}
		// [OFFLINE-AI6] 近战锁定目标时直接朝人冲（覆盖路径目标）
		if (isMelee && bestId >= 0 && State == BotState.Combat && !UseCombatPath && best.Distance > meleeRange)
		{
			goal = best.Pos;
		}
		// [OFFLINE-AI4] Advance 到达后回到 Patrol，避免队友贴到玩家身上来回抖
		if (State == BotState.Advance && (self - LastKnownPos).sqrMagnitude < 4f)
		{
			State = BotState.Patrol; StateEnter = now; MoveGoalTime = 0f; MoveGoal = Vector3.zero;
		}
		// [OFFLINE-AI3] 急停窗口内站住，这才是"停下来开枪"的样子
		if (StopUntil > 0f && now < StopUntil) goal = self;
		else if (StopUntil > 0f && now >= StopUntil) StopUntil = 0f;
		// [OFFLINE-AI8] 八方向身法意图：交战斜走近位 / 后撤倒着走 / 探头斜身。
		// MoveTarget 仍然设置（摇杆模式下执行层忽略它，仅作寻路兜底）。
		if (State == BotState.Combat && !UseCombatPath)
		{
			float dTgt = (bestId >= 0) ? Vector3.Distance(self, best.Pos) : Vector3.Distance(self, LastKnownPos);
			float pref2 = isMelee ? meleeRange * 0.8f : p.PreferredDist;
			it.MoveForward = dTgt > pref2 * 1.15f ? 1f : (dTgt < pref2 * 0.65f ? -0.55f : 0f);
			it.MoveRight = StrafeSign;
		}
		else if (State == BotState.Retreat)
		{
			// 倒着走：身体保持锁敌（ViewYaw 走 AimYaw），摇杆向后 + 微横移
			it.MoveForward = -1f;
			it.MoveRight = (StrafeSign >= 0f) ? 0.35f : -0.35f;
		}
		// TakeCover 保持默认寻路输入，沿 MoveTarget 到达掩体或探头点。
		// [OFFLINE-STUCK] 连续撞墙时强制斜向侧移，先脱离墙面再重新寻路。
		if (now < StuckEscapeUntil)
		{
			it.MoveForward = 0.75f;
			it.MoveRight = StuckEscapeSign;
		}
		if (StopUntil > 0f && now < StopUntil)
		{
			it.MoveForward = 0f;
			it.MoveRight = 0f;
		}
		it.MoveTarget = goal;
		bool stickMode = it.MoveForward != 1f || it.MoveRight != 0f;
		it.HasMove = stickMode
			? (it.MoveForward != 0f || it.MoveRight != 0f)
			: (goal - self).sqrMagnitude > 0.36f;
		// [OFFLINE-BHOP50] 持续给出跳跃意图；ApplyVertical 只在落地帧真正起跳，
		// 因此这是连跳而不是空中重复触发。
		it.WantJump = p.Bhop && it.HasMove && !(StopUntil > 0f && now < StopUntil);
		// [OFFLINE-RUNFIX] 同上：不常蹲（保留 WantJump 的 bhop）
		it.WantCrouch = false;

		// [OFFLINE-AI6] 移动方向与瞄准方向分离：MoveYaw 走向目标，ViewYaw 继续锁敌。
		// 旧实现 data.MoveYaw = AimYaw → 横移时模型"太空步"。
		Vector3 mdir = goal - self; mdir.y = 0f;
		it.MoveYaw = (mdir.sqrMagnitude > 0.01f) ? Mathf.Atan2(mdir.x, mdir.z) * Mathf.Rad2Deg : AimYaw;
		// [OFFLINE-AI8] Retreat 倒走：身体必须锁敌（AimYaw），摇杆 MoveForward=-1
		// 才是"倒退着拉开距离"；若身体朝逃跑点，向后移反而变成朝敌人冲。
		if (State == BotState.Retreat) it.MoveYaw = AimYaw;

		// [OFFLINE-AI6] 状态相关速度缩放 + 到达减速（旧实现全程一个速度直冲）
		float scale = 1f;
		switch (State)
		{
		case BotState.Combat: scale = p.CombatSpeedScale; break;
		case BotState.TakeCover: scale = p.CombatSpeedScale * 0.8f; break;
		case BotState.Flank: scale = 0.85f; break;
		case BotState.Retreat: scale = 1f; break;
		case BotState.Advance:
		case BotState.Search: scale = 0.95f; break;
		default: scale = p.PatrolSpeedScale; break;
		}
		// [OFFLINE-TDM-AI] 角色移动倾向：突击转移略快，狙击换位更慢（减少跑动暴露）
		if (State == BotState.Advance || State == BotState.Search)
		{
			if (Role == BotRole.Assault) scale *= 1.04f;
			else if (Role == BotRole.Sniper) scale *= 0.88f;
		}
		if (p.Melee && (State == BotState.Combat || State == BotState.Advance)) scale = Mathf.Max(scale, 0.95f);
		float remain = mdir.magnitude;
		float arrive = Mathf.Clamp01(remain / 1.6f);
		scale *= Mathf.Lerp(0.22f, 1f, arrive);
		it.SpeedScale = Mathf.Clamp(scale, 0.15f, 1.05f);

		// 卡住自愈：1.2 秒没动就重规划；连续卡住时强制侧移并换一个连通导航点。
		if (!it.HasMove)
		{
			// 主动停枪、等待或到达目标不计入尝试移动但受阻的时间。
			StuckTime += dt;
		}
		else if ((self - StuckPos).sqrMagnitude > 0.25f)
		{
			StuckPos = self;
			StuckTime = now;
			if (now > StuckEscapeUntil + 1.0f) StuckCount = 0;
		}
		else if (now - StuckTime > 1.2f)
		{
			StuckTime = now;
			StuckCount++;
			Path.Clear(); PathIdx = 0; PathTime = 0f;
			UseCombatPath = false;
			NextThink = 0f;
			if (now - LastStuckLog > 2.5f)
			{
				LastStuckLog = now;
				UnityEngine.Debug.Log("[OFFLINE-STUCK] id=" + Id + " n=" + StuckCount
					+ " state=" + State + " pos=" + self.ToString("F1")
					+ " goal=" + MoveGoal.ToString("F1") + " path=" + Path.Count
					+ " walkable=" + OfflineBotNav.Walkable(self, MoveGoal)
					+ " navNodes=" + OfflineBotNav.Nodes.Count);
			}
			if (StuckCount >= 2)
			{
				StuckEscapeUntil = now + UnityEngine.Random.Range(0.9f, 1.6f);
				StuckEscapeSign = (StuckCount % 2 == 0) ? 1f : -1f;
				Vector3 node = OfflineBotNav.RandomNodePos(Id * 131 + StuckCount * 17 + (int)(now * 7f));
				if ((State == BotState.Patrol || State == BotState.Idle
					|| State == BotState.Search || State == BotState.Advance)
					&& node != Vector3.zero && (node - self).sqrMagnitude > 4f)
				{
					LastKnownPos = node;
					LastKnownTime = now;
					State = BotState.Advance;
					StateEnter = now;
				}
			}
		}

		return it;
	}

	// ---------------- [OFFLINE-TDM-AI] 角色 / 团战辅助 ----------------

	/// <summary>首次 Tick（含复活）按武器与人格定型角色，并把角色距离写进 PreferredDist。</summary>
	private void AssignRole(BotProfile p, float now)
	{
		string n = (Weapon != null && Weapon.Name != null) ? Weapon.Name.ToLowerInvariant() : "";

		bool isSniper = (Weapon != null && Weapon.Sniper)
			|| n.Contains("awm") || n.Contains("barrett") || n.Contains("judge") || n.Contains("sniper");
		bool isAnchor = n.Contains("machinegun") || n.Contains("gatling") || n.Contains("lmg");
		bool isClose = p.Melee || (Weapon != null && Weapon.Melee)
			|| n.Contains("shotgun") || n.Contains("smg")
			|| n.Contains("uzi") || n.Contains("viper") || n.Contains("deagle");

		if (isSniper) Role = BotRole.Sniper;
		else if (isAnchor) Role = BotRole.Anchor;
		else if (isClose) Role = BotRole.Assault;
		else Role = BotRole.Support;

		float lo, hi;
		switch (Role)
		{
		case BotRole.Sniper: lo = 24f; hi = 34f; break;
		case BotRole.Support: lo = 16f; hi = 24f; break;
		case BotRole.Anchor: lo = 20f; hi = 28f; break;
		default: lo = 8f; hi = 14f; break;   // Assault
		}
		// 人格原始距离只抓一次：复活重分配时不会把角色修正反复叠乘
		if (RoleBaseDist <= 0f) RoleBaseDist = Mathf.Max(4f, p.PreferredDist);
		// 越激进越贴近（保留 Personalize 的个体差异，只约束到角色区间）
		float roleDist = Mathf.Lerp(hi, lo, Mathf.Clamp01(p.Aggression));
		p.PreferredDist = Mathf.Clamp((RoleBaseDist + roleDist) * 0.5f, lo, hi);

		RoleAssigned = true;
		NextGrenade = now + UnityEngine.Random.Range(5f, 12f);
		NextSkill = now + UnityEngine.Random.Range(9f, 18f);
	}

	/// <summary>角色冲锋意愿 0~1：突击最高、狙击最低；人数劣势时整体收敛。</summary>
	private float ChargeWillingness(BotWorld w)
	{
		float c;
		switch (Role)
		{
		case BotRole.Assault: c = 1.00f; break;
		case BotRole.Anchor: c = 0.78f; break;
		case BotRole.Support: c = 0.55f; break;
		default: c = 0.30f; break;   // Sniper
		}
		if (w != null && w.AliveAllies > 0 && w.AliveEnemies > 0)
			c *= Mathf.Clamp(0.72f + 0.28f * (w.AliveAllies / (float)w.AliveEnemies), 0.55f, 1.20f);
		return Mathf.Clamp01(c);
	}

	private float RoleCoverBonus()
	{
		switch (Role)
		{
		case BotRole.Sniper: return 0.16f;
		case BotRole.Anchor: return 0.10f;
		case BotRole.Assault: return -0.08f;
		default: return 0f;
		}
	}

	/// <summary>无可见目标时朝目标点推进；刚丢失目标的 2 秒内仍先搜人。</summary>
	private void PushObjective(BotWorld w, Vector3 self, float now)
	{
		if (w == null || !w.HasObjective || !w.MatchActive) return;
		if (State == BotState.Reload || State == BotState.TakeCover || State == BotState.Flank) return;
		if (now - LastKnownTime < 2f) return;
		// 已在推进同一个点，或已经到点附近：交给原有 Advance/Patrol 逻辑
		if ((LastKnownPos - w.ObjectivePos).sqrMagnitude < 36f && State == BotState.Advance) return;
		if ((self - w.ObjectivePos).sqrMagnitude < 36f) return;
		State = BotState.Advance;
		LastKnownPos = w.ObjectivePos;
		LastKnownTime = now;
		StateEnter = now;
		NextThink = 0f;
	}

	/// <summary>投掷物意图：只在已交战、7~24m、冷却到期时按角色概率给出。</summary>
	private void PlanGrenade(BotProfile p, BotWorld w, BotThreat best, int bestId, bool engaged,
		float hpRatio, Vector3 self, float now, BotIntent it)
	{
		// [OFFLINE-GDIAG] 逐门诊断（每 5s 一条/bot）
		bool diag = now >= _gdNext;
		if (diag) _gdNext = now + 5f;
		string gate = "";
		if (!engaged || bestId < 0 || p.Melee) gate = "A_eng=" + engaged + ",bid=" + bestId + ",melee=" + p.Melee;
		else if (w == null || !w.MatchActive) gate = "B_world";
		else if (State == BotState.Reload) gate = "C_reload";
		else if (now < NextGrenade) gate = "D_cd=" + (NextGrenade - now).ToString("F1");
		else
		{
			float dd = Vector3.Distance(self, best.Pos);
			if (dd < 7f || dd > 24f) gate = "E_dist=" + dd.ToString("F1");
		}
		if (diag && gate.Length > 0)
			UnityEngine.Debug.Log("[OFFLINE-GDIAG] id=" + Id + " gate=" + gate + " state=" + State);

		if (!engaged || bestId < 0 || p.Melee) return;
		if (w == null || !w.MatchActive) return;
		if (State == BotState.Reload) return;
		if (now < NextGrenade) return;

		float d = Vector3.Distance(self, best.Pos);
		if (d < 7f || d > 24f) return;   // 太近自伤、太远扔不到

		float chance = 0.20f + p.Aggression * 0.50f;
		if (Role == BotRole.Assault) chance += 0.12f;
		else if (Role == BotRole.Sniper) chance -= 0.18f;
		else if (Role == BotRole.Anchor) chance -= 0.06f;
		chance *= 0.70f + 0.50f * ChargeWillingness(w);
		if (UnityEngine.Random.value > Mathf.Clamp01(chance))
		{
			// 条件满足但这次不扔：给短冷却，避免逐帧重抽（帧率越高越爱扔）
			NextGrenade = now + UnityEngine.Random.Range(3f, 6f);
			return;
		}

		// 目标身边有队友 -> 不扔破片（4.5m 内视为会吃到爆炸）
		bool allyNearTarget = false;
		if (w.NearbyAllies != null)
		{
			for (int i = 0; i < w.NearbyAllies.Count; i++)
			{
				if ((w.NearbyAllies[i] - best.Pos).sqrMagnitude < 20.25f) { allyNearTarget = true; break; }
			}
		}
		bool targetHurt = best.Hp < 45f;
		// 目标位置长时间几乎不动 = 大概率蹲掩体/卡点（Velocity 缺失时按静止处理）
		bool targetHolding = best.Velocity.sqrMagnitude < 1f && (now - FirstSeen) > 2.2f;
		bool selfPressed = State == BotState.Retreat || hpRatio < p.RetreatHpRatio * 1.7f;
		bool justEngaged = (now - FirstSeen) < 1.6f;
		// 简化朝向判断：没有可靠朝向数据，按 id/时间做 75% 概率估算
		bool facingMe = ((best.Id * 17 + (int)(now * 0.73f)) & 3) != 0;

		int kind;
		if ((targetHurt || targetHolding) && !allyNearTarget) kind = 0;   // 破片
		else if (selfPressed) kind = 2;                                   // 烟雾掩护后撤
		else if (justEngaged && facingMe) kind = 1;                       // 闪光起手
		else if (!allyNearTarget && UnityEngine.Random.value < 0.5f) kind = 0;
		else kind = 1;

		it.WantGrenade = true;
		it.GrenadeTarget = best.Pos;
		it.GrenadeKind = kind;
		NextGrenade = now + UnityEngine.Random.Range(10f, 18f);
	}

	/// <summary>技能意图：非狙击角色在 4~22m 交战时小概率请求，执行层可忽略。</summary>
	private void PlanSkill(BotProfile p, BotWorld w, BotThreat best, int bestId, bool engaged,
		float now, BotIntent it)
	{
		if (!engaged || bestId < 0 || p.Melee) return;
		if (Role == BotRole.Sniper) return;
		if (w == null || !w.MatchActive) return;
		if (State == BotState.Reload) return;
		if (now < NextSkill) return;

		float d = best.Distance;
		if (d < 4f || d > 22f) return;

		float chance = 0.06f + p.Aggression * 0.10f;
		if (Role == BotRole.Assault) chance += 0.05f;
		if (UnityEngine.Random.value < chance)
		{
			it.WantSkill = true;
			NextSkill = now + UnityEngine.Random.Range(18f, 30f);
		}
		else
		{
			NextSkill = now + UnityEngine.Random.Range(4f, 8f);
		}
	}

	// ---------------- 瞄准 ----------------

	/// <summary>
	/// 二阶临界阻尼逼近：a = ω²Δθ − 2ωv，衰减比 ζ=1（临界，不过冲太多）。
	/// ω 由"需要多大角度"决定，模拟 Fitts 定律；再加手抖。
	/// </summary>
	private void SpringAim(float wantYaw, float wantPitch, BotProfile p, float dt)
	{
		float dYaw = Mathf.DeltaAngle(AimYaw, wantYaw);
		float dPitch = wantPitch - AimPitch;

		// 目标角度 5° → 0.10s；45° → 0.19s；180° → 0.28s（角度越大越慢）
		float mag = Mathf.Max(Mathf.Abs(dYaw), Mathf.Abs(dPitch));
		float settle = Mathf.Lerp(0.10f, 0.30f, Mathf.Clamp01(mag / 140f)) / Mathf.Max(0.4f, p.AimSkill);
		float w = 2.6f / Mathf.Max(0.06f, settle);

		// [OFFLINE-VISION] ζ≈0.85（原临界阻尼 ζ=1 无过冲）：人抬手瞄准会过冲
		// 再回修，这是"活人"与"伺服电机"最直观的差别。
		float accY = w * w * dYaw - 1.7f * w * AimVelYaw;
		float accP = w * w * dPitch - 1.7f * w * AimVelPitch;
		AimVelYaw += accY * dt;
		AimVelPitch += accP * dt;

		// 手抖：幅度随难度与人格变化，方向每帧随机
		float jitter = p.AimErrorBase * 0.06f * p.JitterScale;
		float jy = UnityEngine.Random.Range(-jitter, jitter);
		float jp = UnityEngine.Random.Range(-jitter, jitter);

		AimYaw += AimVelYaw * dt + jy;
		AimYaw = Mathf.Repeat(AimYaw + 180f, 360f) - 180f;
		AimPitch += AimVelPitch * dt + jp;

		// 角度保护
		AimPitch = Mathf.Clamp(AimPitch, -89f, 89f);
	}

	// ---------------- 状态进入 ----------------

	private bool EnterCover(BotProfile p, Vector3 self, Vector3 enemyPos, float now)
	{
		NextCoverSearch = now + 2f;
		CoverPos = OfflineBotNav.NearestTactical(self, enemyPos, 6f, 12f);
		if (CoverPos == Vector3.zero) return false;
		State = BotState.TakeCover;
		StateEnter = now;
		// 行进超时和到位后的掩护时间分别计时。
		CoverArrived = false;
		CoverUntil = now + 4f;
		CoverPhase = 0;
		CoverPhaseEnd = now + 0.35f;
		Path.Clear(); PathIdx = 0; MoveGoalTime = 0f; NextThink = 0f;
		return true;
	}

	private void EnterFlank(Vector3 self, Vector3 enemyPos, float now)
	{
		FlankSide = ((Id & 1) == 0) ? 1 : -1;
		State = BotState.Flank;
		StateEnter = now;
		FlankUntil = now + UnityEngine.Random.Range(2.2f, 4.0f);
		LastFlankEnd = FlankUntil;
		Path.Clear(); PathIdx = 0; MoveGoalTime = 0f; NextThink = 0f;
	}

	// ---------------- 移动规划 ----------------

	private void PlanMovement(BotProfile p, Vector3 self, Vector3 enemyPos, float now)
	{
		Vector3 goal;
		switch (State)
		{
		case BotState.Combat:
			{
				// 交火走位：保持偏好距离 + 横移 + 优先战术点
				Vector3 away = self - enemyPos; away.y = 0f;
				if (away.sqrMagnitude < 0.01f) away = new Vector3(0f, 0f, 1f);
				away.Normalize();
				Vector3 side = Vector3.Cross(Vector3.up, away);
				// [OFFLINE-AI5] 0.6s 换一次方向、幅度 ×1.6、绕侧概率 0.35：
				// 旧值 0.9s / ×1.0 / 0.25 会让 bot 站成一排对射（截图实况）。
				if (now - MoveGoalTime > 0.6f)
				{
					MoveGoalTime = now;
					StrafeSign = UnityEngine.Random.value < 0.5f ? -1f : 1f;
					// 偶尔绕侧翼
					if (UnityEngine.Random.value < 0.35f) StrafeSign *= 1.6f;
				}
				float dist = Vector3.Distance(self, enemyPos);
				// [OFFLINE-AI6] 近战偏好距离 = 砍距；枪战保持原偏好距离
				float pref = p.Melee ? p.MeleeRange * 0.8f : p.PreferredDist;
				// [OFFLINE-AI2] 距离超过偏好值 1.2 倍就主动压上去，不再永远吊在射程边缘
				float keep = (dist > pref * 1.2f) ? pref * 0.8f : pref;
				goal = enemyPos + away * keep + side * (p.StrafeAmount * StrafeSign * 1.6f);
				break;
			}
		case BotState.TakeCover:
			{
				if (CoverPos == Vector3.zero || Vector3.Distance(CoverPos, enemyPos) < 4f)
					CoverPos = OfflineBotNav.NearestTactical(self, enemyPos, 6f, 45f);
				if (CoverPos == Vector3.zero) { goal = self; break; }
				if (CoverPhase == 3)
				{
					goal = CoverPos;   // 缩回掩体
				}
				else
				{
					// 探头：从掩体朝敌人方向偏出去一点，阶段越靠后露得越多
					Vector3 toEnemy = enemyPos - CoverPos; toEnemy.y = 0f;
					if (toEnemy.sqrMagnitude < 0.01f) toEnemy = Vector3.forward;
					toEnemy.Normalize();
					float lean = CoverPhase == 0 ? 0f : (CoverPhase == 1 ? 1.2f : 0.5f);
					goal = CoverPos + toEnemy * lean;
				}
				break;
			}
		case BotState.Flank:
			{
				Vector3 fp = OfflineBotNav.FlankPoint(self, enemyPos, FlankSide, Mathf.Max(8f, p.PreferredDist));
				goal = (fp != Vector3.zero) ? fp : enemyPos;
				break;
			}
		case BotState.Advance:
			{
				goal = LastKnownPos;
				break;
			}
		case BotState.Retreat:
			{
				// 后撤：跑向离敌人最远的战术点
				Vector3 t = OfflineBotNav.RandomTacticalPos(Id + (int)(now * 0.7f));
				if (t != Vector3.zero && Vector3.Distance(t, enemyPos) > Vector3.Distance(self, enemyPos))
					goal = t;
				else
				{
					Vector3 back = self - enemyPos; back.y = 0f;
					goal = self + back.normalized * 9f;
				}
				break;
			}
		case BotState.Search:
			{
				float d = Vector3.Distance(self, LastKnownPos);
				goal = d > 4f ? LastKnownPos : OfflineBotNav.RandomNodePos(Id + (int)(now));
				break;
			}
		case BotState.Reload:
			{
				Vector3 side = Vector3.Cross(Vector3.up, (enemyPos - self).normalized);
				goal = self + side * 4f * (StrafeSign >= 0 ? 1f : -1f);
				break;
			}
		default:
			{
				// Patrol / Idle：在 Home 附近随机点游走
				if (now - MoveGoalTime < 2.2f && MoveGoal != Vector3.zero)
				{
					goal = MoveGoal;
				}
				else
				{
					MoveGoalTime = now;
					Vector3 r = OfflineBotNav.RandomNodePos(Id * 131 + (int)(now * 3f));
					goal = (r != Vector3.zero && Vector3.Distance(r, Home) < 40f) ? r : Home +
						new Vector3(UnityEngine.Random.Range(-14f, 14f), 0f, UnityEngine.Random.Range(-14f, 14f));
					MoveGoal = goal;
				}
				break;
			}
		}

		MoveGoal = goal;
		// 用 A* 把目标变成路径（只有跨区时才多段）
		string pathStatus;
		Path = OfflineBotNav.FindPath(self, goal, out pathStatus);
		UseCombatPath = State == BotState.Combat && Path.Count > 0
			&& (pathStatus == "graph" || pathStatus == "partial" || pathStatus == "same_node");
		PathIdx = 0;
		PathTime = now;
		if ((pathStatus == "partial" || Path.Count == 0) && (goal - self).sqrMagnitude > 1.44f && now >= NextPathDiag)
		{
			NextPathDiag = now + 5f;
			UnityEngine.Debug.Log("[OFFLINE-NAV-PATH] id=" + Id + " state=" + State + " result=" + pathStatus
				+ " from=" + self.ToString("F1") + " goal=" + goal.ToString("F1") + " points=" + Path.Count);
		}
		if (Path.Count == 0 && (goal - self).sqrMagnitude > 1.44f)
		{
			MoveGoal = self;
		}
	}

	private Vector3 AdvancePath(Vector3 self, float now)
	{
		if (Path == null || Path.Count == 0) return MoveGoal;
		if (PathIdx >= Path.Count) return Path[Path.Count - 1];
		Vector3 wp = Path[PathIdx];
		float waypointDistanceSq = (wp - self).sqrMagnitude;
		bool nextVisible = PathIdx + 1 < Path.Count && waypointDistanceSq < 1.2f * 1.2f
			&& OfflineBotNav.Walkable(self, Path[PathIdx + 1]);
		if (waypointDistanceSq < 0.6f * 0.6f || nextVisible)
		{
			PathIdx++;
			if (PathIdx >= Path.Count) return Path[Path.Count - 1];
			wp = Path[PathIdx];
		}
		return wp;
	}

	// ---------------- 外部事件 ----------------

	/// <summary>听觉：别人开枪。</summary>
	public void HearNoise(Vector3 self, Vector3 noise, float radius, float now)
	{
		if (!Alive) return;
		if (Vector3.Distance(self, noise) > radius) return;
		if (now - LastKnownTime < 0.6f) return;
		LastKnownPos = noise;
		LastKnownTime = now;
		EnemyIntelPos = noise; EnemyIntelTime = now;
		if (State == BotState.Patrol || State == BotState.Idle)
		{
			State = BotState.Search;
			StateEnter = now;
			NextThink = 0f;
		}
	}

	/// <summary>被打了但没看见人：转头找人。</summary>
	public void OnDamaged(Vector3 fromPos, int fromId, float now)
	{
		if (!Alive) return;
		// [OFFLINE-TDM-AI] 记录攻击者：目标评分给小额复仇权重，也供执行层做受击反馈
		LastAttackerId = fromId;
		LastAttackerPos = fromPos;
		LastAttackerTime = now;
		if (now - LastKnownTime < 0.3f) return;
		LastKnownPos = fromPos;
		LastKnownTime = now;
		EnemyIntelPos = fromPos; EnemyIntelTime = now;
		if (State == BotState.Patrol || State == BotState.Idle)
		{
			State = BotState.Search;
			StateEnter = now;
			NextThink = 0f;
		}
	}

	public void ResetForRespawn(Vector3 pos, float now, float maxHp)
	{
		Alive = true;
		Hp = maxHp;
		MaxHp = maxHp;
		State = BotState.Patrol;
		StateEnter = now;
		TargetId = -1;
		AimAtHead = false;
		FirstSeen = -1f;
		LastKnownTime = -999f;
		LastKnownPos = pos; LastKnownVel = Vector3.zero; AimSettle = 0f;
		EnemyIntelPos = pos; EnemyIntelTime = -999f;
		Path.Clear(); PathIdx = 0;
		NextPathDiag = 0f;
		UseCombatPath = false;
		NextRouteExecDiag = 0f;
		PmoveDiagCount = 0;
		MoveGoal = pos; MoveGoalTime = 0f;
		Clip = (Weapon != null && Weapon.ClipSize > 0) ? Weapon.ClipSize : 30;
		ReloadAnimIssued = false;
		ReloadEnd = 0f;
		InBurst = false;
		BurstEnd = 0f; PauseEnd = 0f; NextShot = 0f;
		Awareness = 0f;
		CoverPos = Vector3.zero;
		CoverUntil = 0f;
		FlankUntil = 0f;
		LastFlankEnd = -999f;
		LastRetreatEnd = -999f;
		NextCoverSearch = 0f;
		NextSuppress = 0f;
		NextShotDiag = 0f;
		AimVelYaw = 0f; AimVelPitch = 0f;
		VisualYaw = AimYaw; VisualPitch = AimPitch; VisualAnglesInitialized = false;
		StopUntil = 0f;
		ReactDelay = -1f;
		CoverPhase = 0; CoverPhaseEnd = 0f; CoverArrived = false;
		NextIrrational = -1f; IrrationalUntil = 0f;
		ErrYaw = 0f; ErrPitch = 0f; ErrTgtYaw = 0f; ErrTgtPitch = 0f; ErrNextTgt = 0f;
		NextScan = 0f; ScanEnd = 0f; ScanDur = 0f; ScanMag = 0f;
		LastPos = pos; LastPosTime = now;
		SpeedSamplePos = pos; SpeedSampleTime = -1f; ObservedVelocity = Vector3.zero;
		ActualSpeed = 0f; LastContact = -999f; NextWeaponResolve = 0f;
		RespawnAt = 0f;
		SpawnPos = pos;
		StuckPos = pos;
		StuckTime = now;
		StuckCount = 0;
		StuckEscapeUntil = 0f;
		StuckEscapeSign = 1f;
		LastStuckLog = 0f;
		NextThink = 0f;
		// [OFFLINE-TDM-AI] 新字段复位；RoleBaseDist 保留，避免角色距离重复叠加
		RoleAssigned = false;
		NextGrenade = now + UnityEngine.Random.Range(6f, 12f);
		NextSkill = now + UnityEngine.Random.Range(9f, 18f);
		LastAttackerId = -1;
		LastAttackerPos = Vector3.zero;
		LastAttackerTime = -999f;
		SharedReportTime = -999f;
	}
}
