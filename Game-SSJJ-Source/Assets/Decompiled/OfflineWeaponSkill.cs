using System;
using System.Collections.Generic;
using Assets.Generated.Table;
using Assets.Sources.Components.Interface;
using Assets.Sources.Components.Interface.Info.AnimState;
using Assets.Sources.Components.Time;
using Assets.Sources.Info.SkillProgress;
using Assets.Sources.Info.Weapon.WeaponInfo;
using Assets.Sources.Modules.Player.Anim.FirstPerson;
using Assets.Sources.Utils;
using Assets.Sources.Utils.Sound;
using Assets.Sources.Utils.Weapon;
using NetData;
using SSJJBase.Singleton;
using UnityEngine;

/// <summary>
/// Offline bridge for the original weapon skill, EffectLevel, Power, and VFX pipeline.
/// Skill rows, visibility rules, progress calculators, cooldown rules, KnifeAttackConfig,
/// ViewWeaponEffectLogics, and SharedPredication remain the game's own implementations.
/// This class supplies the server-owned readiness/EffectLevel/Power state and executes
/// melee skill effects (projectiles, sword waves, dashes, AOE slams, SpecialMode) offline.
/// </summary>
public static class OfflineWeaponSkill
{
	private enum MeleeSkillKind
	{
		SpecialCleave,
		Projectile,
		DashSlash,
		AoeSlam
	}

	private sealed class SkillProjectile
	{
		public Vector3 StartUnity;
		public Vector3 EndUnity;
		public float StartAt;
		public float TravelTime;
		public int TargetId;
		public bool Headshot;
		public float Damage;
		public bool IsWave;
		public Color Tint;
		public GameObject Visual;
	}

	private sealed class TransientVfx
	{
		public GameObject Go;
		public float StartAt;
		public float Duration;
		public Vector3 StartScale;
		public Vector3 EndScale;
	}

	private static WeaponEntity _armedWeapon;
	private static float _armedUntil = -1f;
	private static int _specialStartClientTime;
	private static readonly HashSet<int> _initializedWeaponIds = new HashSet<int>();
	private static float _powerAccum;
	private static readonly Dictionary<int, float> _cooldownUntilByWeaponId = new Dictionary<int, float>();
	private static readonly List<SkillProjectile> _projectiles = new List<SkillProjectile>();
	private static readonly List<TransientVfx> _vfxs = new List<TransientVfx>();

	public static bool IsMeleeWeaponEntity(WeaponEntity weapon)
	{
		if (weapon == null || !weapon.hasBasicInfo) return false;
		if (weapon.basicInfo.Info != null && weapon.basicInfo.Info.WeaponType == 2) return true;
		string name = weapon.basicInfo.Data != null ? weapon.basicInfo.Data.WeaponName : null;
		if (string.IsNullOrEmpty(name)) return false;
		string s = name.ToLowerInvariant();
		return s.Contains("botweapon") || s.Contains("dagger") || s.Contains("knife") || s.Contains("bat")
			|| s.Contains("axe") || s.Contains("sword") || s.Contains("hammer")
			|| s.Contains("blade") || s.Contains("claw") || s.Contains("scythe")
			|| s.Contains("fan") || s.Contains("guqin") || s.Contains("whip")
			|| s.Contains("spear") || s.Contains("staff") || s.Contains("club")
			|| s.Contains("stick") || s.Contains("pole") || s.Contains("shield")
			|| s.Contains("sickle") || s.Contains("saw") || s.Contains("pickaxe")
			|| s.Contains("shovel") || s.Contains("fangs") || s.Contains("machete")
			|| s.Contains("katana") || s.Contains("kris") || s.Contains("kukri")
			|| s.Contains("halberd") || s.Contains("gauntlet") || s.Contains("trident")
			|| s.Contains("crowbar") || s.Contains("wrench") || s.Contains("bayonet")
			|| s.Contains("knuckle") || s.Contains("umbrella") || s.Contains("nunchaku")
			|| s.Contains("glaive") || s.Contains("shears") || s.Contains("yoyo")
			|| s.Contains("drum") || s.Contains("mantis") || s.Contains("awakening")
			|| s.Contains("pokong");
	}

	public static bool HasNativeShowGunHandler(WeaponEntity weapon)
	{
		if (weapon == null || !weapon.hasBasicInfo || weapon.basicInfo.Data == null) return false;
		string s = (weapon.basicInfo.Data.WeaponName ?? string.Empty).ToLowerInvariant();
		return s.Contains("mirage_dou_blade")
			|| s.Contains("dragon_stick")
			|| s.Contains("spirits_sword")
			|| s.Contains("sword_whip")
			|| s.Contains("mikaduki_sword");
	}

	public static bool ShouldForwardSkillKey()
	{
		try
		{
			WeaponEntity weapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
			if (weapon == null || !weapon.hasBasicInfo || weapon.basicInfo.Data == null) return false;
			if (IsMeleeWeaponEntity(weapon)) return true;
			return FindSkillInfo(weapon.basicInfo.Data.WeaponName) != null;
		}
		catch (Exception) { return false; }
	}

	private static ISkillProgressInfo FindSkillInfo(string weaponName)
	{
		if (string.IsNullOrEmpty(weaponName)) return null;
		try
		{
			var contexts = Contexts.sharedInstance;
			var factory = SSJJBase.Manager.BattleSingletonInstance<SkillProgressFactory>.Instance;
			if (factory == null || factory.SkillProgressInfos == null) return null;

			BattleRoomEntity room = null;
			try
			{
				var rooms = contexts.battleRoom.GetEntities();
				if (rooms != null && rooms.Count > 0) room = rooms[0] as BattleRoomEntity;
			}
			catch (Exception) { }

			ISkillProgressInfo fallback = null;
			foreach (KeyValuePair<int, ISkillProgressInfo> entry in factory.SkillProgressInfos)
			{
				ISkillProgressInfo info = entry.Value;
				var row = info != null ? info.Config : null;
				if (row == null || !weaponName.Equals(row.Name, StringComparison.OrdinalIgnoreCase)) continue;
				if (fallback == null) fallback = info;
				if (room != null && info.Visiable != null && !info.Visiable.IsModeShow(row, room)) continue;
				return info;
			}
			return fallback;
		}
		catch (Exception ex)
		{
			Debug.LogWarning("[OFFLINE-SKILL] original skill table lookup failed: " + ex.Message);
		}
		return null;
	}

	public static bool HasSkill(string weaponName)
	{
		return FindSkillInfo(weaponName) != null;
	}

	public static int RowCount()
	{
		try
		{
			var factory = SSJJBase.Manager.BattleSingletonInstance<SkillProgressFactory>.Instance;
			return factory != null && factory.SkillProgressInfos != null ? factory.SkillProgressInfos.Count : -1;
		}
		catch (Exception) { return -2; }
	}

	/// <summary>
	/// Ensure melee weapon has its server-granted EffectLevel unlock bits and Power initialized.
	/// Carefully avoids setting active-state bits (like SPECIAL_MODE/GIANT_MODE) on startup.
	/// </summary>
	private static void EnsureMeleeWeaponReady(PlayerEntity player, WeaponEntity weapon)
	{
		if (player == null || weapon == null || !weapon.hasBasicInfo || weapon.basicInfo.Data == null) return;
		if (!IsMeleeWeaponEntity(weapon)) return;

		int wid = weapon.basicInfo.Data.Id;
		string wn = (weapon.basicInfo.Data.WeaponName ?? string.Empty).ToLowerInvariant();

		if (_initializedWeaponIds.Add(wid))
		{
			if (weapon.hasSpecial)
			{
				int unlockMask = ResolveUnlockEffectBits(wn);
				if (unlockMask != 0 && (weapon.special.EffectLevel & unlockMask) != unlockMask)
				{
					weapon.special.EffectLevel |= unlockMask;
				}
				weapon.basicInfo.Data.EffectLevel = weapon.special.EffectLevel;
			}
			if (weapon.hasPower)
			{
				if (weapon.power.MaxPower <= 0) weapon.power.MaxPower = 100;
				if (weapon.power.Power <= 0) weapon.power.Power = weapon.power.MaxPower;
				weapon.basicInfo.Data.MaxPower = weapon.power.MaxPower;
				weapon.basicInfo.Data.Power = weapon.power.Power;
			}
			Debug.Log("[OFFLINE-SKILL] melee ready weapon=" + wn
				+ " effectLevel=0x" + (weapon.hasSpecial ? weapon.special.EffectLevel.ToString("X") : "0")
				+ " power=" + (weapon.hasPower ? weapon.power.Power : 0));
		}

		// Keep EffectLevel synced to Data and Player.CurrentWeaponEffectLevel for native effect systems
		if (weapon.hasSpecial)
		{
			if (weapon.basicInfo.Data.EffectLevel != weapon.special.EffectLevel)
			{
				weapon.basicInfo.Data.EffectLevel = weapon.special.EffectLevel;
			}
			if (player.hasBasicInfo && player.basicInfo.Current != null)
			{
				player.basicInfo.Current.CurrentWeaponEffectLevel = weapon.special.EffectLevel;
			}
		}
	}

	private static int ResolveUnlockEffectBits(string wn)
	{
		// Exact unlock/component bits from weaponPredicateNet & Assembly-CSharp (excluding active-state bits!)
		if (wn.Contains("brave_dagger")) return 64 | 256; // THROW_ENABLED | SKILL_CAN_OPEN
		if (wn.Contains("mirage_dou_blade")) return 2 | 4 | 8 | 16 | 64; // HAS_COMPONENT1..4 | CAN_CHANGE_GIANT
		if (wn.Contains("hero_blade")) return 0xFFFF; // all swordType/Protection/Pattern/Heart + weaponeffect21..26
		if (wn.Contains("drill_blade")) return 128 | 256; // POHUN_STATUS | SPECIAL_SEC
		if (wn.Contains("wing_knife")) return 64 | 128 | 256; // LUANLING_STATUS | SJMF_ADD | ASJ_ADD
		if (wn.Contains("mantis_arm")) return 32 | 64; // SPEED_UP | SPECIAL_DAMAGE
		if (wn.Contains("light_with_shadow")) return 256; // SWORD_ON
		if (wn.Contains("type91_dagger")) return 1; // slash-slash mode
		if (wn.Contains("asura_blade")) return 0; // bit 32 suppresses fire events
		if (wn.Contains("baby_ram")) return 0; // bit 1 = RIGHT_ATTACK state
		// Default melee unlock bits: enable visual effect levels 1..5 (bits 0..4) for KnifeAttackConfig & FirstPersonPatricles
		return 0x1F;
	}

	public static void AddPower(WeaponEntity weapon, int amount)
	{
		if (weapon == null || !weapon.hasPower || amount <= 0) return;
		int maxP = weapon.power.MaxPower > 0 ? weapon.power.MaxPower : 100;
		weapon.power.MaxPower = maxP;
		weapon.power.Power = Mathf.Min(maxP, weapon.power.Power + amount);
		if (weapon.hasBasicInfo && weapon.basicInfo.Data != null)
		{
			weapon.basicInfo.Data.MaxPower = maxP;
			weapon.basicInfo.Data.Power = weapon.power.Power;
		}
	}

	/// <returns>true when E belongs to a skill and must not fall through to pickup.</returns>
	public static bool TryUse(OfflineGameplay gameplay)
	{
		if (gameplay == null) return false;
		PlayerEntity player = null;
		WeaponEntity weapon = null;
		try
		{
			player = Contexts.sharedInstance.player.myPlayerEntity;
			weapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
		}
		catch (Exception) { }
		if (player == null || weapon == null || !weapon.hasBasicInfo || weapon.basicInfo.Data == null) return false;

		string weaponName = weapon.basicInfo.Data.WeaponName ?? "";
		bool isMelee = IsMeleeWeaponEntity(weapon);
		ISkillProgressInfo skill = FindSkillInfo(weaponName);
		if (!isMelee && (skill == null || skill.Config == null))
		{
			Debug.Log("[OFFLINE-SKILL] no visible original WeaponSkill row for weapon=" + weaponName
				+ " tableRows=" + RowCount() + "; E will fall through to interact/pickup");
			return false;
		}

		EnsureMeleeWeaponReady(player, weapon);

		// Check cooldown
		int wid = weapon.basicInfo.Data.Id;
		float cdUntil;
		if (_cooldownUntilByWeaponId.TryGetValue(wid, out cdUntil) && Time.time < cdUntil)
		{
			Debug.Log("[OFFLINE-SKILL] cooldown active weapon=" + weaponName
				+ " remaining=" + (cdUntil - Time.time).ToString("F1") + "s");
			return true;
		}

		TimeComponent time = null;
		try { time = Contexts.sharedInstance.time.time; } catch (Exception) { }

		// Determine duration and cooldown
		var row = skill != null ? skill.Config : null;
		int activeMs = (row != null && row.SpecialTime > 0) ? row.SpecialTime : 6000;
		int cooldownMs = ResolveCooldownMs(weapon, row);

		// Check Power cost for melee skills (soft requirement: if Power < 20, still allow if no power component or recharge fast)
		if (isMelee && weapon.hasPower && weapon.power.MaxPower > 0)
		{
			int cost = 35;
			if (weapon.power.Power < cost && row != null && row.CanUse != WeaponSkillTable.CanUseType.AllAwalys)
			{
				// Allow activation if cooldown is ready, just drain remaining power
				weapon.power.Power = 0;
			}
			else
			{
				weapon.power.Power = Mathf.Max(0, weapon.power.Power - cost);
			}
			weapon.basicInfo.Data.Power = weapon.power.Power;
		}

		_cooldownUntilByWeaponId[wid] = Time.time + cooldownMs / 1000f;
		if (player.hasClientTime)
		{
			try { weapon.basicInfo.Data.NextSkillTimer = (uint)(player.clientTime.ClientTime + cooldownMs); } catch (Exception) { }
		}
		try
		{
			var cmd = Contexts.sharedInstance.userCommand.commands.getCurrentCmd();
			if (cmd != null) cmd.Buttons |= 0x1000; // UserCmd.isSkill
		}
		catch (Exception) { }

		// Arm SpecialMode when weapon has SpecialComponent (gives special animations, effects & SpecialAttackType)
		if (weapon.hasSpecial)
		{
			if (time != null) _specialStartClientTime = time.ClientRealTime;
			SetSpecialMode(weapon, true);
			_armedWeapon = weapon;
			_armedUntil = activeMs > 0 ? Time.time + activeMs / 1000f : -1f;
		}

		if (!isMelee)
		{
			Debug.Log("[OFFLINE-SKILL] armed non-melee skill weapon=" + weaponName + " activeMs=" + activeMs);
			return true;
		}

		// Execute melee skill visuals, audio, animation, and combat effect!
		ExecuteMeleeSkill(gameplay, player, weapon, weaponName, cooldownMs, activeMs);
		return true;
	}

	private static int ResolveCooldownMs(WeaponEntity weapon, WeaponSkillTable.Row row)
	{
		try
		{
			int raceType = OfflineGameController.setting != null ? OfflineGameController.setting.RaceType : 3;
			var info = weapon.basicInfo.Info as DefaultWeaponInfo;
			if (info != null && info.CdTimeLogic != null)
			{
				string wn = weapon.basicInfo.Data.WeaponName ?? "";
				int configured = info.CdTimeLogic.GetCdTime(wn, raceType, 0);
				if (configured >= 1000) return configured;
			}
		}
		catch (Exception) { }

		if (row != null && row.Cd != WeaponSkillTable.CdType.None && row.MaxLevel >= 1000)
		{
			return row.MaxLevel;
		}
		return 7000;
	}

	private static MeleeSkillKind ClassifyMeleeSkill(string weaponName)
	{
		string s = (weaponName ?? string.Empty).ToLowerInvariant();
		if (s.Contains("brave_dagger") || s.Contains("light_with_shadow") || s.Contains("feather_fan")
			|| s.Contains("fan_legend") || s.Contains("wing_knife") || s.Contains("darts_")
			|| s.Contains("abyss_blade") || s.Contains("brokenlight") || s.Contains("photon_sword")
			|| s.Contains("k28sword") || s.Contains("m9_devil") || s.Contains("moon_blade")
			|| s.Contains("xianhu") || s.Contains("nunchaku") || s.Contains("crystal_spear")
			|| s.Contains("yoyo_ball") || s.Contains("salute_gun") || s.Contains("guqin"))
		{
			return MeleeSkillKind.Projectile;
		}
		if (s.Contains("shadowless") || s.Contains("blink_shadow") || s.Contains("dash_shield")
			|| s.Contains("actsword") || s.Contains("asura_blade") || s.Contains("wind_axe")
			|| s.Contains("sword_whip") || s.Contains("snake_chain") || s.Contains("mantis_arm")
			|| s.Contains("gemini_blade") || s.Contains("lightning_sword") || s.Contains("lightening_sword"))
		{
			return MeleeSkillKind.DashSlash;
		}
		if (s.Contains("berserker_axe") || s.Contains("hammer") || s.Contains("dragon_stick")
			|| s.Contains("goldhoop") || s.Contains("monk_pole") || s.Contains("knife_wheel")
			|| s.Contains("drum_") || s.Contains("hero_blade") || s.Contains("bladeshield")
			|| s.Contains("honor_shield") || s.Contains("pickaxe") || s.Contains("saw")
			|| s.Contains("drill_blade") || s.Contains("earl_shield") || s.Contains("baby_ram"))
		{
			return MeleeSkillKind.AoeSlam;
		}
		return MeleeSkillKind.SpecialCleave;
	}

	private static Color ResolveSkillTint(string weaponName)
	{
		string s = (weaponName ?? string.Empty).ToLowerInvariant();
		if (s.Contains("ice") || s.Contains("crystal") || s.Contains("frozen") || s.Contains("shark"))
			return new Color(0.32f, 0.82f, 1f, 1f);
		if (s.Contains("fire") || s.Contains("hell") || s.Contains("asura") || s.Contains("berserker") || s.Contains("devil") || s.Contains("blood"))
			return new Color(1f, 0.34f, 0.16f, 1f);
		if (s.Contains("thunder") || s.Contains("lightning") || s.Contains("lightening") || s.Contains("thor") || s.Contains("photon") || s.Contains("cyber"))
			return new Color(0.38f, 0.68f, 1f, 1f);
		if (s.Contains("abyss") || s.Contains("shadow") || s.Contains("void") || s.Contains("mirage"))
			return new Color(0.72f, 0.34f, 1f, 1f);
		if (s.Contains("rose") || s.Contains("cupid") || s.Contains("rabbit"))
			return new Color(1f, 0.42f, 0.72f, 1f);
		return new Color(1f, 0.80f, 0.28f, 1f); // Gold/Imperial default
	}

	private static void ExecuteMeleeSkill(OfflineGameplay gameplay, PlayerEntity player, WeaponEntity weapon, string weaponName, int cooldownMs, int activeMs)
	{
		MeleeSkillKind kind = ClassifyMeleeSkill(weaponName);
		Color tint = ResolveSkillTint(weaponName);

		// Play native skill animation if not already triggered by PredicationSystem (e.g. BraveKnifeFrameAction sets 28)
		PlaySkillAnimation(player, weapon);
		PlaySkillSound(player, weapon);

		Camera cam = FindEyeCamera();
		if (cam == null) return;

		Vector3 camPosUnity = cam.transform.position;
		Vector3 dir = cam.transform.forward.normalized;

		if (kind == MeleeSkillKind.Projectile)
		{
			LaunchSkillProjectile(gameplay, camPosUnity, dir, weaponName, tint);
		}
		else if (kind == MeleeSkillKind.DashSlash)
		{
			ExecuteDashSlash(gameplay, player, camPosUnity, dir, tint);
		}
		else if (kind == MeleeSkillKind.AoeSlam)
		{
			ExecuteAoeSlam(gameplay, camPosUnity, dir, tint);
		}
		else
		{
			ExecuteSpecialCleave(gameplay, camPosUnity, dir, tint);
		}

		Debug.Log("[OFFLINE-SKILL] melee skill executed weapon=" + weaponName
			+ " kind=" + kind + " activeMs=" + activeMs + " cdMs=" + cooldownMs);
	}

	private static void PlaySkillAnimation(PlayerEntity player, WeaponEntity weapon)
	{
		try
		{
			int currentAnim = 0;
			if (player.hasViewAnim && player.viewAnim.ViewAnimInfo != null)
			{
				currentAnim = ((IAnimStateInfo)player.viewAnim.ViewAnimInfo).StateId;
			}
			// If native PredicationSystem already set skill anim (28/36/199/200/201), keep it!
			if (currentAnim == 28 || currentAnim == 36 || currentAnim == 199 || currentAnim == 200 || currentAnim == 201)
			{
				return;
			}
			int animId = ViewAnimSystem.FindViewAnimByName(weapon.basicInfo.Info, "TORSO_SKILL");
			if (animId <= 0) animId = ViewAnimSystem.FindViewAnimByName(weapon.basicInfo.Info, "TORSO_ATTACK2");
			if (animId <= 0) animId = ViewAnimSystem.FindAttackViewAnim(weapon.basicInfo.Info, true);
			if (animId > 0)
			{
				Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(player, animId);
			}
			Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetTorseAnimation(player, 28);
		}
		catch (Exception) { }
	}

	private static void PlaySkillSound(PlayerEntity player, WeaponEntity weapon)
	{
		try
		{
			if (player != null && player.hasFirstPersonUnityObjects && weapon != null && weapon.hasBasicInfo && weapon.basicInfo.Data != null)
			{
				string wn = weapon.basicInfo.Data.WeaponName;
				var info = SoundResourceUtility.GetWeaponSoundFire4AssetInfo(wn);
				if (info == null) info = SoundResourceUtility.GetWeaponSoundSecFireAssetInfo(wn);
				if (info != null)
				{
					MonoBehaviourSingleton<GameSoundManager>.Instance.Play2DSound(
						SoundSystemTable.SoundSubtype.Shoot, player.isMyPlayer, info, GameSoundManager.Config.WeaponVolume);
				}
			}
		}
		catch (Exception) { }
	}

	private static void LaunchSkillProjectile(OfflineGameplay gameplay, Vector3 camPosUnity, Vector3 dir, string weaponName, Color tint)
	{
		bool isDart = weaponName.IndexOf("brave_dagger", StringComparison.OrdinalIgnoreCase) >= 0
			|| weaponName.IndexOf("darts", StringComparison.OrdinalIgnoreCase) >= 0;
		Vector3 originUnity = camPosUnity + dir * 0.65f;
		Vector3 originCm = originUnity * 100f;
		const float maxRangeCm = 20000f;
		float worldRangeCm = maxRangeCm;
		try
		{
			Vector3 worldEnd, worldNormal;
			float fraction;
			if (OfflineBotPhysics.Cast(originCm, originCm + dir * maxRangeCm, 1.5f, 0f,
				out worldEnd, out worldNormal, out fraction) && fraction < 0.999f)
			{
				worldRangeCm = Mathf.Clamp((worldEnd - originCm).magnitude - 6f, 0f, maxRangeCm);
			}
		}
		catch (Exception) { }

		bool headshot;
		int targetId = gameplay.NearestBotInRange(originUnity, dir, worldRangeCm, out headshot);
		float travelCm = worldRangeCm;
		if (targetId >= 0)
		{
			Vector3 targetUnity;
			if (gameplay.TryGetBotEyeUnityPos(targetId, out targetUnity))
			{
				float projCm = Vector3.Dot((targetUnity - originUnity) * 100f, dir);
				if (projCm > 0f) travelCm = Mathf.Min(worldRangeCm, projCm);
			}
		}

		float travelM = travelCm / 100f;
		SkillProjectile proj = new SkillProjectile();
		proj.StartUnity = originUnity;
		proj.EndUnity = originUnity + dir * travelM;
		proj.StartAt = Time.time;
		proj.TravelTime = Mathf.Max(0.035f, travelM / (isDart ? 110f : 65f));
		proj.TargetId = targetId;
		proj.Headshot = headshot;
		proj.Damage = headshot ? 260f : 95f;
		proj.IsWave = !isDart;
		proj.Tint = tint;
		proj.Visual = CreateProjectileVisual(originUnity, dir, proj.IsWave, tint);
		_projectiles.Add(proj);
	}

	private static void ExecuteDashSlash(OfflineGameplay gameplay, PlayerEntity player, Vector3 camPosUnity, Vector3 dir, Color tint)
	{
		// Safe forward dash along horizontal look direction using BSP physics trace
		Vector3 flatDir = new Vector3(dir.x, 0f, dir.z);
		if (flatDir.sqrMagnitude > 0.001f) flatDir.Normalize();
		else flatDir = dir;

		if (player.hasMove && player.move.PyPlayerMove != null)
		{
			try
			{
				// Unity (x,z) -> SSJJ pmove (Y,-X), cm/s
				var v = player.move.PyPlayerMove.GetVelocity();
				player.move.PyPlayerMove.SetVelocity(
					(float)v.x + flatDir.z * 1150f,
					(float)v.y - flatDir.x * 1150f,
					Mathf.Max((float)v.z, 180f));
			}
			catch (Exception) { }
		}

		// Wide forward slash cleave
		SpawnTransientVfx(PrimitiveType.Cube, camPosUnity + dir * 1.4f, Quaternion.LookRotation(dir, Vector3.up),
			new Vector3(1.8f, 0.08f, 0.6f), new Vector3(3.2f, 0.04f, 1.4f), 0.22f, tint);

		List<int> hits = gameplay.GetBotsInCone(camPosUnity, dir, 550f, 0.35f, 8);
		for (int i = 0; i < hits.Count; i++)
		{
			MarkHitCross();
			gameplay.KillBot(hits[i], 130f, false, true);
			OfflineGameplay.ApplyKnockback(hits[i], flatDir, 420f, 160f);
		}
	}

	private static void ExecuteAoeSlam(OfflineGameplay gameplay, Vector3 camPosUnity, Vector3 dir, Color tint)
	{
		Vector3 ringPos = camPosUnity - Vector3.up * 0.9f + dir * 0.8f;
		SpawnTransientVfx(PrimitiveType.Cylinder, ringPos, Quaternion.identity,
			new Vector3(0.8f, 0.05f, 0.8f), new Vector3(8.5f, 0.02f, 8.5f), 0.32f, tint);

		List<int> hits = gameplay.GetBotsInCone(camPosUnity, dir, 480f, -1f, 12);
		for (int i = 0; i < hits.Count; i++)
		{
			MarkHitCross();
			gameplay.KillBot(hits[i], 135f, false, true);
			Vector3 botPos;
			Vector3 kbDir = dir;
			if (gameplay.TryGetBotEyeUnityPos(hits[i], out botPos))
			{
				Vector3 delta = botPos - camPosUnity;
				delta.y = 0f;
				if (delta.sqrMagnitude > 0.01f) kbDir = delta.normalized;
			}
			OfflineGameplay.ApplyKnockback(hits[i], kbDir, 560f, 240f);
		}
	}

	private static void ExecuteSpecialCleave(OfflineGameplay gameplay, Vector3 camPosUnity, Vector3 dir, Color tint)
	{
		SpawnTransientVfx(PrimitiveType.Cube, camPosUnity + dir * 1.2f, Quaternion.LookRotation(dir, Vector3.up) * Quaternion.Euler(0f, 0f, 25f),
			new Vector3(1.4f, 0.07f, 0.45f), new Vector3(2.8f, 0.03f, 1.1f), 0.20f, tint);

		List<int> hits = gameplay.GetBotsInCone(camPosUnity, dir, 400f, 0.45f, 6);
		for (int i = 0; i < hits.Count; i++)
		{
			MarkHitCross();
			gameplay.KillBot(hits[i], 110f, false, true);
		}
	}

	public static void Tick(OfflineGameplay gameplay)
	{
		if (gameplay == null) return;

		PlayerEntity player = null;
		WeaponEntity currentWeapon = null;
		try
		{
			player = Contexts.sharedInstance.player.myPlayerEntity;
			currentWeapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
		}
		catch (Exception) { }

		// 1. Keep melee EffectLevel & Power initialized and passively recharging
		if (player != null && currentWeapon != null)
		{
			EnsureMeleeWeaponReady(player, currentWeapon);
			if (IsMeleeWeaponEntity(currentWeapon) && currentWeapon.hasPower)
			{
				int maxP = currentWeapon.power.MaxPower > 0 ? currentWeapon.power.MaxPower : 100;
				if (currentWeapon.power.Power < maxP)
				{
					_powerAccum += 16f * Time.deltaTime;
					if (_powerAccum >= 1f)
					{
						int add = Mathf.FloorToInt(_powerAccum);
						_powerAccum -= add;
						AddPower(currentWeapon, add);
					}
				}
				else
				{
					_powerAccum = 0f;
				}
			}
		}

		// 2. Update active skill projectiles
		for (int i = _projectiles.Count - 1; i >= 0; i--)
		{
			SkillProjectile proj = _projectiles[i];
			float t = proj.TravelTime > 0f ? Mathf.Clamp01((Time.time - proj.StartAt) / proj.TravelTime) : 1f;
			if (proj.Visual != null)
			{
				proj.Visual.transform.position = Vector3.Lerp(proj.StartUnity, proj.EndUnity, t);
			}
			if (t < 1f) continue;

			if (proj.TargetId >= 0)
			{
				MarkHitCross();
				gameplay.KillBot(proj.TargetId, proj.Damage, proj.Headshot, true);
			}
			// Impact flash
			SpawnTransientVfx(PrimitiveType.Sphere, proj.EndUnity, Quaternion.identity,
				new Vector3(0.25f, 0.25f, 0.25f), new Vector3(0.95f, 0.95f, 0.95f), 0.16f, proj.Tint);
			if (proj.Visual != null) UnityEngine.Object.Destroy(proj.Visual);
			_projectiles.RemoveAt(i);
		}

		// 3. Update transient VFXs
		for (int i = _vfxs.Count - 1; i >= 0; i--)
		{
			TransientVfx v = _vfxs[i];
			float t = v.Duration > 0f ? Mathf.Clamp01((Time.time - v.StartAt) / v.Duration) : 1f;
			if (v.Go != null)
			{
				v.Go.transform.localScale = Vector3.Lerp(v.StartScale, v.EndScale, t);
				Renderer r = v.Go.GetComponent<Renderer>();
				if (r != null && r.material != null)
				{
					Color c = r.material.color;
					c.a = 1f - t;
					r.material.color = c;
				}
			}
			if (t >= 1f)
			{
				if (v.Go != null) UnityEngine.Object.Destroy(v.Go);
				_vfxs.RemoveAt(i);
			}
		}

		// 4. SpecialMode expiration
		if (_armedWeapon == null) return;
		if (currentWeapon != _armedWeapon)
		{
			SetSpecialMode(_armedWeapon, false);
			_armedWeapon = null;
			_armedUntil = -1f;
			_specialStartClientTime = 0;
			return;
		}
		if (_armedUntil < 0f || Time.time < _armedUntil) return;
		SetSpecialMode(_armedWeapon, false);
		Debug.Log("[OFFLINE-SKILL] native skill window ended by WeaponSkill.SpecialTime");
		_armedWeapon = null;
		_armedUntil = -1f;
		_specialStartClientTime = 0;
	}

	private static GameObject CreateProjectileVisual(Vector3 posUnity, Vector3 dir, bool isWave, Color tint)
	{
		GameObject visual = GameObject.CreatePrimitive(isWave ? PrimitiveType.Cube : PrimitiveType.Capsule);
		visual.name = isWave ? "OfflineMeleeWave" : "OfflineMeleeDart";
		Collider col = visual.GetComponent<Collider>();
		if (col != null) UnityEngine.Object.Destroy(col);
		visual.transform.position = posUnity;
		if (isWave)
		{
			visual.transform.rotation = Quaternion.LookRotation(dir, Vector3.up);
			visual.transform.localScale = new Vector3(0.95f, 0.10f, 0.35f);
		}
		else
		{
			visual.transform.rotation = Quaternion.FromToRotation(Vector3.up, dir);
			visual.transform.localScale = new Vector3(0.05f, 0.18f, 0.05f);
		}
		Renderer renderer = visual.GetComponent<Renderer>();
		if (renderer != null)
		{
			renderer.material.color = tint;
			try
			{
				renderer.material.EnableKeyword("_EMISSION");
				renderer.material.SetColor("_EmissionColor", tint * 1.4f);
			}
			catch (Exception) { }
			TrailRenderer trail = visual.AddComponent<TrailRenderer>();
			trail.time = 0.12f;
			trail.startWidth = isWave ? 0.45f : 0.06f;
			trail.endWidth = 0.01f;
			trail.material = renderer.material;
			trail.startColor = tint;
			trail.endColor = new Color(tint.r, tint.g, tint.b, 0f);
		}
		return visual;
	}

	private static void SpawnTransientVfx(PrimitiveType shape, Vector3 posUnity, Quaternion rot, Vector3 startScale, Vector3 endScale, float duration, Color tint)
	{
		try
		{
			GameObject go = GameObject.CreatePrimitive(shape);
			go.name = "OfflineSkillVfx";
			Collider col = go.GetComponent<Collider>();
			if (col != null) UnityEngine.Object.Destroy(col);
			go.transform.position = posUnity;
			go.transform.rotation = rot;
			go.transform.localScale = startScale;
			Renderer r = go.GetComponent<Renderer>();
			if (r != null)
			{
				Shader additive = Shader.Find("Particles/Additive");
				if (additive == null) additive = Shader.Find("Sprites/Default");
				if (additive != null)
				{
					r.material = new Material(additive);
					r.material.color = tint;
				}
				else
				{
					r.material.color = tint;
					try
					{
						r.material.EnableKeyword("_EMISSION");
						r.material.SetColor("_EmissionColor", tint * 1.3f);
					}
					catch (Exception) { }
				}
			}
			_vfxs.Add(new TransientVfx
			{
				Go = go,
				StartAt = Time.time,
				Duration = duration,
				StartScale = startScale,
				EndScale = endScale
			});
		}
		catch (Exception) { }
	}

	private static void MarkHitCross()
	{
		try { Contexts.sharedInstance.cross.hitCross.ChangRedTime = 200; } catch (Exception) { }
	}

	private static Camera FindEyeCamera()
	{
		Camera[] cams = Camera.allCameras;
		for (int i = 0; i < cams.Length; i++)
		{
			if (cams[i] != null && cams[i].name == "Eye" && cams[i].enabled) return cams[i];
		}
		for (int i = 0; i < cams.Length; i++)
		{
			if (cams[i] != null && cams[i].name == "Eye") return cams[i];
		}
		return Camera.main;
	}

	private static void SetSpecialMode(WeaponEntity weapon, bool value)
	{
		if (weapon == null) return;
		try { if (weapon.hasSpecial) weapon.special.SpecialMode = value; } catch (Exception) { }
		try { if (weapon.hasBasicInfo && weapon.basicInfo.Data != null) weapon.basicInfo.Data.SpecialMode = value; } catch (Exception) { }
	}
}
