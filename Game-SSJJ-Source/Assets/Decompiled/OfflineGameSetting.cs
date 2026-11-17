using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class OfflineGameSetting : MonoBehaviour
{
	[SerializeField]
	public bool TurnOn;

	public int SceneId = 12;

	public string Player = "police";

	public string Hand = "man";

	public string Weapon = "hand_of_zeuss";

	public float X;

	public float Y;

	public float Z;

	public int BotCount = 4;
	public int AllyBotCount = 2;
	public int EnemyBotCount = 2;
	// [OFFLINE-BOT] launch_config.json 是否显式给了 bot 数量（写 0 也是显式，必须尊重）。
	// JsonUtility 无法区分"键缺失"和"值为 0"，由 LoadLaunchConfig 读原文判定。
	[NonSerialized]
	public bool BotCountExplicit;
	public string BotDifficulty = "normal";

	public string BotCareer = "police";

	public bool GodMode = true;

	// [OFFLINE-MODULES] 第二批总开关：true 时注册原版被 TurnOn 门禁挡掉的 15 个玩家子模块
	// 与 6 个一级模块（共 97 个系统）。launch_config.json 写 "full_modules": false 可整块回退。
	public bool FullModules = true;

	// [OFFLINE-MODULES] 灰度排除列表，逗号分隔，简称见 PlayerModule 里的判断：
	// effect,accessory,skill,sound,killinfo,baseshow,particleloop,smallmap,entitydestroy,
	// vip,observer,beinghit,gamerule,message,action
	public string SkipModules = "";

	// [SERVER-AUTHORITY] 新管线开关：bot 的腿/上半身动画改为“Pmove → 快照字段 → 原版 Playback”，
	// 不再由 SyncOfflineAnimStates 手写合成。默认关，保住当前可玩版本；验证通过后再默认开。
	public bool ServerAuthority = true;

	// [OFFLINE-PARKOUR] 运行时跑酷关卡
	public bool Parkour = false;

	// [OFFLINE-EQUIP] 原版护甲是二值（ArmorHead/ArmorBody），HUD 读这两个字段；
	// 弹夹包客户端没有独立系统，这里按“备弹翻倍”还原（MaxCarryClip ×2）。
	public bool ArmorDefault = true;
	public bool AmmoPouch = true;

	// 原版 RaceType 就是模式 id，GameRuleFactory 按它选真实规则类（3 = 团队/GroupGameRule）。
	public int RaceType = 3;

	// [OFFLINE-SKIN] 武器皮肤 / 角色皮肤名（空=默认皮肤）。
	// 皮肤包名 = weaponskin/<WeaponSkin>、playerskin/<CareerSkin>，由 prepare_launch_assets.py 安装。
	public string WeaponSkin = "";
	public string CareerSkin = "";
	public string WeaponSkinWeapon = "";

	/// <summary>一个背包的 4 个武器槽（与原版 PlayerBagData 的槽位一一对应）。</summary>
	[Serializable]
	public class BagConfig
	{
		public string primary;
		public string secondary;
		public string melee;
		public string throwable;
		// [OFFLINE-SKIN] 每槽独立皮肤（weaponskin/<名>，空 = 默认外观）。
		// 原版皮肤属于"那把武器"，切枪/换背包时皮肤跟着武器走。
		public string primary_skin;
		public string secondary_skin;
		public string melee_skin;
		public string throwable_skin;

		public BagConfig Clone()
		{
			BagConfig c = new BagConfig();
			c.primary = primary;
			c.secondary = secondary;
			c.melee = melee;
			c.throwable = throwable;
			c.primary_skin = primary_skin;
			c.secondary_skin = secondary_skin;
			c.melee_skin = melee_skin;
			c.throwable_skin = throwable_skin;
			return c;
		}

		/// <summary>槽位 1~4 的武器名（越界返回空串）。</summary>
		public string WeaponAt(int slot)
		{
			switch (slot)
			{
			case 1: return primary ?? "";
			case 2: return secondary ?? "";
			case 3: return melee ?? "";
			case 4: return throwable ?? "";
			default: return "";
			}
		}

		/// <summary>槽位 1~4 的皮肤名（越界返回空串）。</summary>
		public string SkinAt(int slot)
		{
			switch (slot)
			{
			case 1: return primary_skin ?? "";
			case 2: return secondary_skin ?? "";
			case 3: return melee_skin ?? "";
			case 4: return throwable_skin ?? "";
			default: return "";
			}
		}
	}

	[Serializable]
	public class LaunchConfigData
	{
		public string map;
		public string mode;
		public string career;
		public string hand;
		public string weapon;
		public string weapon_skin;
		public string weapon_skin_weapon;
		public string career_skin;
		public int bot_count;
		public int ally_bot_count;
		public int enemy_bot_count;
		public string bot_difficulty;
		public string bot_career;
		public bool god_mode;
		public bool server_authority;
		public bool full_modules;
		public bool parkour;
		public string skip_modules;
		public bool armor;
		public bool ammo_pouch;
		public float[] spawn;
		public int active_bag;
		public BagConfig[] bags;
	}

	public const int BagCount = 5;

	// LoadLaunchConfig 解析时记录的键存在性，供 ApplyLaunchConfig 区分"未配置"与"显式 0"。
	private static bool s_lastHadSplitBotCounts;
	private static bool s_hadFullModulesKey;
	private static bool s_hadServerAuthorityKey;
	private static bool s_hadArmorKey;
	private static bool s_hadAmmoPouchKey;
	private int _modePoolAppliedRaceType = -1;

	// 原版 5 个背包、每个 4 槽；Bags 运行时构造，不参与序列化。
	[NonSerialized]
	public List<BagConfig> Bags = new List<BagConfig>();

	[NonSerialized]
	public int ActiveBag = 1;

	public static string ConfigPath()
	{
		string[] candidates = new string[3];
		try
		{
			candidates[0] = Path.Combine(Directory.GetParent(Application.dataPath).FullName, "launch_config.json");
		}
		catch (Exception)
		{
			candidates[0] = null;
		}
		candidates[1] = Path.Combine(Application.dataPath, "launch_config.json");
		candidates[2] = Path.Combine(Directory.GetCurrentDirectory(), "launch_config.json");
		for (int i = 0; i < candidates.Length; i++)
		{
			if (!string.IsNullOrEmpty(candidates[i]) && File.Exists(candidates[i]))
			{
				return candidates[i];
			}
		}
		return null;
	}

	public static LaunchConfigData LoadLaunchConfig()
	{
		string path = ConfigPath();
		if (path == null)
		{
			Debug.Log("[OFFLINE-CONFIG] launch_config.json not found");
			return null;
		}
		try
		{
			string text = File.ReadAllText(path);
			s_lastHadSplitBotCounts = text.Contains("\"ally_bot_count\"") || text.Contains("\"enemy_bot_count\"");
			s_hadArmorKey = text.Contains("\"armor\"");
			s_hadAmmoPouchKey = text.Contains("\"ammo_pouch\"");
			s_hadFullModulesKey = text.Contains("\"full_modules\"");
			s_hadServerAuthorityKey = text.Contains("\"server_authority\"");
			LaunchConfigData data = JsonUtility.FromJson<LaunchConfigData>(text);
			Debug.Log("[OFFLINE-CONFIG] loaded " + path + " map=" + ((data == null || data.map == null) ? "null" : data.map));
			return data;
		}
		catch (Exception ex)
		{
			Debug.LogError("[OFFLINE-CONFIG] parse failed: " + ex.Message);
			return null;
		}
	}

	public bool ApplyLaunchConfig()
	{
		LaunchConfigData data = LoadLaunchConfig();
		if (data == null)
		{
			return false;
		}
		TurnOn = true;
		// [OFFLINE-MODULES] 缺键默认开；显式 false 才回退到旧的 15 模块关闭状态。
		FullModules = (s_hadFullModulesKey ? data.full_modules : true);
		SkipModules = (data.skip_modules ?? string.Empty);
		UnityEngine.Debug.Log("[OFFLINE-MODULE] full=" + FullModules + " skip=[" + SkipModules + "]");
		string career = (data.career ?? string.Empty).Trim();
		if (!string.IsNullOrEmpty(career) && !career.Equals("terrorist", StringComparison.OrdinalIgnoreCase))
		{
			Player = career;
		}
		string weapon = (data.weapon ?? string.Empty).Trim();
		if (!string.IsNullOrEmpty(weapon))
		{
			Weapon = weapon;

			// [OFFLINE-SKIN] 皮肤名：只在对应皮肤包已在 manifest 时才采用，否则回落默认皮肤。
			string wSkin = (data.weapon_skin ?? string.Empty).Trim();
			string wSkinWeapon = (data.weapon_skin_weapon ?? string.Empty).Trim();
			if (!string.IsNullOrEmpty(wSkinWeapon)) WeaponSkinWeapon = wSkinWeapon;
			if (!string.IsNullOrEmpty(wSkin) && BundleAvailable("weaponskin/" + wSkin))
			{
				WeaponSkin = wSkin;
			}
			else if (!string.IsNullOrEmpty(wSkin))
			{
				Debug.LogWarning("[OFFLINE-CONFIG] weaponskin bundle missing, use default skin: " + wSkin);
			}
			string cSkin = (data.career_skin ?? string.Empty).Trim();
			if (!string.IsNullOrEmpty(cSkin) && BundleAvailable("playerskin/" + cSkin))
			{
				CareerSkin = cSkin;
			}
			else if (!string.IsNullOrEmpty(cSkin))
			{
				Debug.LogWarning("[OFFLINE-CONFIG] playerskin bundle missing, use default skin: " + cSkin);
			}
		}
		string requestedHand = ((data.hand ?? string.Empty).Trim().Equals("woman", StringComparison.OrdinalIgnoreCase) ? "woman" : "man");
		BotCount = Mathf.Clamp(data.bot_count, 0, 12);
		AllyBotCount = Mathf.Clamp(data.ally_bot_count, 0, 6);
		EnemyBotCount = Mathf.Clamp(data.enemy_bot_count, 0, 8);
		BotCountExplicit = s_lastHadSplitBotCounts;
		if (!s_lastHadSplitBotCounts && AllyBotCount + EnemyBotCount <= 0 && BotCount > 0)
		{
			AllyBotCount = BotCount / 2;
			EnemyBotCount = BotCount - AllyBotCount;
		}
		BotDifficulty = string.IsNullOrEmpty(data.bot_difficulty) ? "normal" : data.bot_difficulty.Trim().ToLowerInvariant();
		string botCareer = (data.bot_career ?? string.Empty).Trim();
		if (botCareer.Equals("terrorist", StringComparison.OrdinalIgnoreCase))
		{
			BotCareer = "pandora_t";
		}
		else if (!string.IsNullOrEmpty(botCareer))
		{
			BotCareer = botCareer;
		}
		GodMode = data.god_mode;
		// [OFFLINE-ANIM] 缺键默认开：第三人称腿/上身动画走 Pmove -> 快照 -> 原版 Playback，
		// 这是与原版一致的链路；显式 false 才回退到 SyncOfflineAnimStates 手写合成。
		ServerAuthority = (s_hadServerAuthorityKey ? data.server_authority : true);
		Parkour = data.parkour;
		// 缺省时默认装备护甲/弹夹包；配置里显式写了才覆盖（JsonUtility 无法区分缺省与 false）。
		if (s_hadArmorKey) ArmorDefault = data.armor;
		if (s_hadAmmoPouchKey) AmmoPouch = data.ammo_pouch;
		int modeId = ModeIdFromName(data.mode);
		if (modeId > 0)
		{
			RaceType = modeId;
		}
		if (data.spawn != null && data.spawn.Length >= 3)
		{
			X = data.spawn[0];
			Y = data.spawn[1];
			Z = data.spawn[2];
		}
		// [OFFLINE-MAP] 资源全集已全量落地 + install_map.py 会把 maps/map<id> 装进 manifest，
		// 这里只要求主包在清单里就放行；缺包才回退 map1 并提示跑安装脚本。
		int sceneId = SceneIdFromMap(data.map);
		if (sceneId > 0 && (BundleAvailable("maps/map" + sceneId) || BundleAvailable("maps/map" + (sceneId % 1000)) || BundleAvailable("unitymaps/map_" + sceneId)))
		{
			SceneId = sceneId;
		}
		else
		{
			if (sceneId > 1)
			{
				Debug.LogWarning("[OFFLINE-CONFIG] maps/map" + sceneId + " not in manifest, fallback to map1 (run install_map.py --scene-id " + sceneId + ")");
			}
			SceneId = 1;
		}
		if (!BundleAvailable("player/" + Player))
		{
			Debug.LogWarning("[OFFLINE-CONFIG] player bundle missing, fallback to police: " + Player);
			Player = "police";
		}
		if (!BundleAvailable("weapon/" + Weapon))
		{
			Debug.LogWarning("[OFFLINE-CONFIG] weapon bundle missing, fallback to nbr_knife_g: " + Weapon);
			Weapon = "nbr_knife_g";
		}
		// [OFFLINE-PATCH] 原版 5 背包 × 4 槽：优先按配置构造，缺包/缺字段回落到默认槽位。
		BuildBags(data);
		// 手模必须跟角色一致：优先用角色专属 viewhand/<career>，没有才回退 man/woman。
		Hand = ResolveHand(Player, requestedHand);
		// [OFFLINE-SKIN] 皮肤反查出的女性职业若没有专属手模包，回退 woman，避免女角套男手。
		try
		{
			Assets.Sources.Components.Interface.Info.Career.ICareerInfo careerInfo = Assets.Sources.Info.Career.CareerInfoFactory.Instance.GetCareerInfo(Player);
			if (careerInfo != null && careerInfo.IsFemale && Hand == "man" && BundleAvailable("viewhand/woman"))
			{
				Hand = "woman";
			}
		}
		catch (Exception)
		{
		}
		if (BotCount > 0 && !BundleAvailable("player/" + BotCareer))
		{
			Debug.LogWarning("[OFFLINE-CONFIG] bot career bundle missing, fallback to police: " + BotCareer);
			BotCareer = "police";
		}
		Debug.Log("[OFFLINE-CONFIG] applied player=" + Player + " weapon=" + Weapon + " hand=" + Hand +
			" weaponSkin=" + (string.IsNullOrEmpty(WeaponSkin) ? "-" : WeaponSkin) +
			" careerSkin=" + (string.IsNullOrEmpty(CareerSkin) ? "-" : CareerSkin) +
			" scene=" + SceneId + " bots=" + BotCount + "/" + BotCareer + " god=" + GodMode +
			" serverAuthority=" + ServerAuthority +
			" bag=" + ActiveBag + " bags=" + Bags.Count);
		return true;
	}

	private void BuildBags(LaunchConfigData data)
	{
		Bags = new List<BagConfig>(BagCount);
		string fbPrimary = Weapon;
		string fbSecondary = SanitizeWeapon(fbPrimary == "deagle" ? "92fs" : "deagle", "nbr_knife_g");
		string fbMelee = SanitizeWeapon("nbr_knife_g", "nbr_knife_g");
		string fbThrowable = SanitizeWeapon("grenade", "nbr_knife_g");
		for (int i = 0; i < BagCount; i++)
		{
			BagConfig src = (data.bags != null && i < data.bags.Length) ? data.bags[i] : null;
			BagConfig bag = new BagConfig();
			bag.primary = SanitizeWeapon(src != null ? src.primary : null, fbPrimary);
			bag.secondary = SanitizeWeapon(src != null ? src.secondary : null, fbSecondary);
			bag.melee = SanitizeWeapon(src != null ? src.melee : null, fbMelee);
			bag.throwable = SanitizeWeapon(src != null ? src.throwable : null, fbThrowable);
			// [OFFLINE-SKIN] 槽位皮肤：包不在 manifest 就当默认皮肤（警告一次），不影响进图。
			bag.primary_skin = SanitizeSkin(src != null ? src.primary_skin : null);
			bag.secondary_skin = SanitizeSkin(src != null ? src.secondary_skin : null);
			bag.melee_skin = SanitizeSkin(src != null ? src.melee_skin : null);
			bag.throwable_skin = SanitizeSkin(src != null ? src.throwable_skin : null);
			Bags.Add(bag);
		}
		ActiveBag = (data.active_bag >= 1 && data.active_bag <= BagCount) ? data.active_bag : 1;
		Weapon = Bags[ActiveBag - 1].primary;
		// [OFFLINE-MODE] 背包按模式武器池校正（刀锋模式：服务端只下发近战，不能带枪）
		_modePoolAppliedRaceType = -1;
		ApplyModeWeaponPool();
	}

	// [OFFLINE-MODE] 用抓包实测的 method3 武器池裁剪本地背包。
	// 刀锋战士(15)：服务端武器池 = 6 把近战，所有槽位必须是刀，否则和原版不一致。
	// 人机团战(2003)：保留启动器配置（原版是每个玩家自己的装备，服务端只是汇总下发）。
	private void ApplyModeWeaponPool()
	{
		OfflineModeTable.Profile profile = OfflineModeTable.Get(RaceType);
		if (profile == null || !profile.MeleeOnly) return;
		List<string> pool = OfflineModeTable.PoolMelee(profile);
		if (pool.Count == 0) return;
		// 过滤掉本地没装包的武器，避免加载失败
		List<string> usable = new List<string>();
		for (int i = 0; i < pool.Count; i++)
		{
			if (BundleAvailable("weapon/" + pool[i])) usable.Add(pool[i]);
		}
		if (usable.Count == 0) usable = pool;
		if (Bags == null) return;
		for (int i = 0; i < Bags.Count; i++)
		{
			BagConfig bag = Bags[i];
			if (bag == null) continue;
			// 优先保留玩家仓库当前背包里装备的近战武器；仅当缺失或包不存在时才回退默认近战池。
			bool hasEquippedMelee = !string.IsNullOrEmpty(bag.melee) && BundleAvailable("weapon/" + bag.melee);
			string equippedMelee = hasEquippedMelee
				? bag.melee
				: PickFromPool(usable, i * 4 + 2, bag.melee);
			string meleeSkin = hasEquippedMelee ? (bag.melee_skin ?? "") : "";
			bag.primary = equippedMelee;
			bag.secondary = equippedMelee;
			bag.melee = equippedMelee;
			bag.throwable = equippedMelee;
			bag.primary_skin = meleeSkin;
			bag.secondary_skin = meleeSkin;
			bag.melee_skin = meleeSkin;
			bag.throwable_skin = meleeSkin;
		}
		if (ActiveBag >= 1 && ActiveBag <= Bags.Count) Weapon = Bags[ActiveBag - 1].melee;
		if (_modePoolAppliedRaceType != RaceType)
		{
			_modePoolAppliedRaceType = RaceType;
			Debug.Log("[OFFLINE-MODE] " + OfflineModeTable.Describe(RaceType)
				+ " -> bags kept warehouse melee (" + Weapon + ")");
		}
	}

	private static string PickFromPool(List<string> pool, int idx, string current)
	{
		if (!string.IsNullOrEmpty(current))
		{
			for (int i = 0; i < pool.Count; i++)
			{
				if (string.Equals(pool[i], current, StringComparison.OrdinalIgnoreCase)) return current;
			}
		}
		return pool[Mathf.Abs(idx) % pool.Count];
	}

	/// <summary>没有启动配置时的兜底：用当前 Weapon 填满 5 个背包。</summary>
	public void EnsureBags()
	{
		bool created = false;
		if (Bags == null) { Bags = new List<BagConfig>(); created = true; }
		while (Bags.Count < BagCount) { Bags.Add(null); created = true; }
		string fbSecondary = SanitizeWeapon(Weapon == "deagle" ? "92fs" : "deagle", "nbr_knife_g");
		string fbMelee = SanitizeWeapon("nbr_knife_g", "nbr_knife_g");
		string fbThrowable = SanitizeWeapon("grenade", "nbr_knife_g");
		for (int i = 0; i < BagCount; i++)
		{
			if (Bags[i] == null)
			{
				BagConfig bag = new BagConfig();
				bag.primary = SanitizeWeapon(Weapon, "nbr_knife_g");
				bag.secondary = fbSecondary;
				bag.melee = fbMelee;
				bag.throwable = fbThrowable;
				Bags[i] = bag;
				created = true;
			}
		}
		if (ActiveBag < 1 || ActiveBag > BagCount) ActiveBag = 1;
		// [OFFLINE-MODE] 兜底路径同样按模式裁剪（刀锋模式不能带枪）
		if (created || _modePoolAppliedRaceType != RaceType)
		{
			ApplyModeWeaponPool();
		}
	}

	public BagConfig GetBag(int bagId)
	{
		EnsureBags();
		int idx = Mathf.Clamp(bagId - 1, 0, BagCount - 1);
		return Bags[idx];
	}

	private static string SanitizeWeapon(string name, string fallback)
	{
		string w = (name ?? string.Empty).Trim();
		if (string.IsNullOrEmpty(w)) w = fallback;
		if (!BundleAvailable("weapon/" + w))
		{
			Debug.LogWarning("[OFFLINE-CONFIG] bag weapon bundle missing, fallback to " + fallback + ": " + w);
			w = fallback;
		}
		return w;
	}

	// [OFFLINE-SKIN] 缺包只警告一次，避免 5 背包 × 4 槽刷屏。
	private static HashSet<string> s_missingSkinWarned;

	/// <summary>[OFFLINE-SKIN] 皮肤包不在 manifest 时回落默认皮肤（空串），并打一条警告。</summary>
	private static string SanitizeSkin(string name)
	{
		string skin = (name ?? string.Empty).Trim();
		if (string.IsNullOrEmpty(skin)) return "";
		if (BundleAvailable("weaponskin/" + skin)) return skin;
		if (s_missingSkinWarned == null)
		{
			s_missingSkinWarned = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
		}
		if (s_missingSkinWarned.Add(skin))
		{
			Debug.LogWarning("[OFFLINE-SKIN] weaponskin bundle missing, fallback to default: " + skin);
		}
		return "";
	}

	/// <summary>[OFFLINE-SKIN] 取"某背包某槽位"的皮肤（1 主武器 / 2 副武器 / 3 近战 / 4 投掷）。
	/// 只有 weaponName 与槽位武器一致时才生效（换枪后皮肤不跟到别的枪上）；
	/// 槽位皮肤为空时回落旧版全局字段（weapon_skin + weapon_skin_weapon）。</summary>
	public string SkinForBagSlot(int bagId, int slot, string weaponName)
	{
		string weapon = (weaponName ?? string.Empty).Trim();
		if (string.IsNullOrEmpty(weapon)) return "";
		BagConfig bag = GetBag(bagId);
		if (bag != null)
		{
			string skin = bag.SkinAt(slot);
			if (!string.IsNullOrEmpty(skin))
			{
				// 槽位武器已被替换（B 面板换枪）-> 皮肤不能留在别的枪上。
				if (!string.Equals(bag.WeaponAt(slot), weapon, StringComparison.OrdinalIgnoreCase)) return "";
				return SanitizeSkin(skin);
			}
		}
		// 兼容旧配置：旧版只有"一把武器 + 一个皮肤"。
		if (string.IsNullOrEmpty(WeaponSkin)) return "";
		string legacyWeapon = string.IsNullOrEmpty(WeaponSkinWeapon) ? Weapon : WeaponSkinWeapon;
		if (!string.Equals(legacyWeapon, weapon, StringComparison.OrdinalIgnoreCase)) return "";
		return SanitizeSkin(WeaponSkin);
	}

	/// <summary>[OFFLINE-SKIN] 全部背包槽位用到的皮肤（进图前预加载 weaponSkinList 用）。</summary>
	public List<string> AllBagSkins()
	{
		List<string> list = new List<string>();
		if (Bags == null) return list;
		for (int i = 0; i < Bags.Count; i++)
		{
			BagConfig bag = Bags[i];
			if (bag == null) continue;
			for (int slot = 1; slot <= 4; slot++)
			{
				string skin = SanitizeSkin(bag.SkinAt(slot));
				if (!string.IsNullOrEmpty(skin) && !list.Contains(skin)) list.Add(skin);
			}
		}
		return list;
	}

	/// <summary>把启动器里的模式名映射成原版 RaceType（GameRuleFactory 的 switch 分支）。</summary>
	public static int ModeIdFromName(string mode)
	{
		switch ((mode ?? string.Empty).Trim().ToLowerInvariant())
		{
		case "team":
		case "group":
			return 3;
		// [OFFLINE-MODE] 人机团战：抓包实测原版下发的是 2003（GameRuleFactory 与 3 同走 _groupRule）
		case "team_ai":
		case "bot_team":
		case "botteam":
		case "team2003":
			return 2003;
		// [OFFLINE-MODE] 刀锋战士：抓包实测 RaceType=15，武器池 6 把近战
		case "blade":
		case "blade_fight":
		case "bladefight":
		case "blade_warrior":
		case "blade15":
			return 15;
		// [OFFLINE-MODE] 大头人机：抓包实测原版 RaceType=2019（RuleUtilty.IsBotMode 判定为 bot 模式）
		case "bighead":
		case "big_head":
		case "bot_bighead":
		case "bighead_ai":
		case "bighead2019":
		case "mode2019":
		case "2019":
			return 2019;
		// [OFFLINE-MODE] 刀战人机：抓包实测原版 RaceType=2041（bot 模式，FFA + 近战）
		case "blade_ai":
		case "bot_knife":
		case "bot_knifefight":
		case "knife_ai":
		case "knife2041":
		case "blade2041":
		case "mode2041":
		case "2041":
			return 2041;
		case "personal":
			return 5;
		case "explode":
			return 2;
		case "deathmatch":
		case "death_match":
			return 12;
		case "flyknife":
			return 74;
		case "weaponmaster":
			return 64;
		default:
			return 0;
		}
	}

	/// <summary>原版个人竞技/死亡类规则没有队友；其余当前大厅模式沿用红蓝阵营。</summary>
	public static bool IsFreeForAll(int raceType)
	{
		return raceType == 5 || raceType == 12 || raceType == 15 || raceType == 64 || raceType == 74 || raceType == 2041;
	}

	/// <summary>角色专属手模优先（viewhand/pandora_t 等），否则按配置回退 man/woman。</summary>
	public static string ResolveHand(string career, string requestedHand)
	{
		string c = (career ?? string.Empty).Trim();
		if (!string.IsNullOrEmpty(c) && BundleAvailable("viewhand/" + c))
		{
			return c;
		}
		return requestedHand.Equals("woman", StringComparison.OrdinalIgnoreCase) ? "woman" : "man";
	}

	public static int SceneIdFromMap(string map)
	{
		if (string.IsNullOrEmpty(map))
		{
			return 0;
		}
		string digits = string.Empty;
		for (int i = 0; i < map.Length; i++)
		{
			if (char.IsDigit(map[i]))
			{
				digits += map[i];
			}
		}
		int id;
		return int.TryParse(digits, out id) ? id : 0;
	}

	private static HashSet<string> _bundleNames;

	public static bool BundleAvailable(string bundleName)
	{
		if (_bundleNames == null)
		{
			_bundleNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
			try
			{
				string manifest = Path.Combine(Application.dataPath, "StreamingAssets/AssetBundles/Windows/AssetBundles");
				if (File.Exists(manifest))
				{
					string text = File.ReadAllText(manifest);
					string token = "name=\"";
					int index = 0;
					while ((index = text.IndexOf(token, index, StringComparison.Ordinal)) >= 0)
					{
						int start = index + token.Length;
						int end = text.IndexOf('"', start);
						if (end > start)
						{
							_bundleNames.Add(text.Substring(start, end - start));
						}
						index = end + 1;
					}
				}
			}
			catch (Exception)
			{
				return true;
			}
		}
		if (_bundleNames.Count == 0)
		{
			return true;
		}
		return _bundleNames.Contains(bundleName);
	}
}
