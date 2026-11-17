using System;
using System.Collections.Generic;

// [OFFLINE-MODE] 模式档案表
// 数据来源：2026-10-24 对原版战斗服抓包实测（cap_snap1 = 团队 2003，cap_m2_snap = 刀锋 15）
// + 原版 RuleUtilty.IsBotMode / GameRuleFactory / UiModeFactory 源码核对（2003/2019/2041 三套人机模式）。
// 每条档案对应原版 method12(RoomData) + method3(OnGameinitData) 的真实字段值。
public static class OfflineModeTable
{
	public class Profile
	{
		public int RaceType;
		public string Name;
		// method3 的 #2：职业池
		public string[] Careers;
		// method3 的 #3：武器池（服务端按模式裁剪）
		public string[] Weapons;
		// method12 的 #3 / #4 / #6 / #7 / #11 / #16
		public int P3, P4, P6, P7, P11, P16;
		// method12 的 #9
		public int MaxPlayers;
		// 是否只能用近战（服务端武器池全是近战）
		public bool MeleeOnly;
		// 分数上限（method12 #6，150000 在刀战里像是"无上限"）
		public int ScoreLimit;
		// [OFFLINE-BOT] 人机配置（bot 数量/精英/首领/Lv/职业池/武器池/大头）
		public BotCfg Bot;
		// [OFFLINE-BOT] 大头模式（2019）原版 BigHeadGameRule.IsShowEnemyHpBar() => true，
		// 敌人也显示血条；名字仍然不显示（防透视，见 OfflineGameController 挂名牌逻辑）。
		public bool ShowEnemyHpBar;
	}

	/// <summary>
	/// [OFFLINE-BOT] 人机bot配置。
	/// 对应原版服务端下发的 isBot/botRaceType/botLv/botQuality 快照字段：
	///   botQuality 0 = 普通兵；1/2 = 精英（血条+小地图标记）；>=3 = 首领（boss 血条）。
	/// 原版这些值由服务端按模式难度表生成，离线端由本结构本地合成。
	/// </summary>
	public class BotCfg
	{
		public int AllyBots = 2;
		public int EnemyBots = 4;
		public int EliteCount = 1;
		public int BossCount = 1;
		public int LvMin = 3;
		public int LvMax = 25;
		// 普通 / 精英 / 首领职业池（空数组 = 继承上一档）
		public string[] Careers = new string[0];
		public string[] EliteCareers = new string[0];
		public string[] BossCareers = new string[0];
		// 普通 / 首领武器池（空数组 = 继承上一档；首领用 BossWeapons）
		public string[] Weapons = new string[0];
		public string[] BossWeapons = new string[0];
		public float EliteHpMul = 1.6f;
		public float BossHpMul = 3f;
		// 大头模式：HeadEnlarge 快照字段（HeadScalePlaybackSystem: scale = 1 + HeadEnlarge + OtherHeadEnlarge）
		public float HeadEnlarge;
	}

	// ---------- 刀锋战士 (RaceType 15) ----------
	// 实测：method12 #3=3 #4=13 #6=150000 #7=3000 #9=8 #11=13 #16=1
	//       method3 武器池 6 把近战，职业池 27 个
	private static readonly Profile Blade =
		new Profile
		{
			RaceType = 15,
			Name = "刀锋战士",
			P3 = 3, P4 = 13, P6 = 150000, P7 = 3000, P11 = 13, P16 = 1,
			MaxPlayers = 8,
			MeleeOnly = true,
			ScoreLimit = 150000,
			Careers = new string[]
			{
				"chicken", "snowman", "xiya_tlz", "chixia1", "t_xise", "aisha", "pig",
				"rpg_skin_bookofdoom_magic_elf", "lanbainvpu", "ct_mask", "cat",
				"cia_girl1", "feihu", "sanjiaozhou", "type2", "sas", "tongyun",
				"longyin", "rpg_skin_bookofdoom_forest", "diaochan", "police",
				"huiselv", "rpg_bookofdoom2", "guardian_a", "meat", "heihongluoli", "baofeng"
			},
			Weapons = new string[]
			{
				"double_fangs_g", "ice_ax", "axe_g", "shovel_g", "nbr_knife_g", "blood_shadow_sword"
			},
			Bot = new BotCfg
			{
				AllyBots = 0, EnemyBots = 5,
				EliteCount = 1, BossCount = 0,
				LvMin = 1, LvMax = 15,
				Careers = new string[] { "police", "pandora_t", "feihuwoman", "acg_paila" },
				EliteCareers = new string[] { "acg_paila" },
				BossCareers = new string[] { "boss1008" },
				Weapons = new string[] { "nbr_knife_g", "double_fangs_g", "ice_ax", "axe_g", "shovel_g", "blood_shadow_sword", "botweapon" },
				BossWeapons = new string[] { "botweapon", "ice_ax", "blood_shadow_sword" },
			}
		};

	// ---------- 人机团战 (RaceType 2003) ----------
	// 实测：method12 #3=1 #4=150 #6=0 #7=3000 #9=8 #11=150 #16=217
	//       method3 武器池 19 把枪械（服务端下发的是本局全部玩家实际装备）
	private static readonly Profile Team =
		new Profile
		{
			RaceType = 2003,
			Name = "人机团战",
			P3 = 1, P4 = 150, P6 = 0, P7 = 3000, P11 = 150, P16 = 217,
			MaxPlayers = 8,
			MeleeOnly = false,
			ScoreLimit = 0,
			Careers = new string[]
			{
				"lanbainvpu", "police", "type2", "tongyun", "heihongluoli", "aisha"
			},
			Weapons = new string[]
			{
				"blood_machinegun", "aa12_hero1", "double_fangs_g", "m4a1_g1", "ice_ax",
				"deagle_g", "m4", "colt_boa", "shovel_g", "barrett_m107_g",
				"grenade_wukong", "grenade_star_dark", "axe_g", "grenade_pumpkin",
				"viper", "double_infinity_g", "grenade_mooncake", "nbr_knife_g", "viper_rage"
			},
			Bot = new BotCfg
			{
				AllyBots = 2, EnemyBots = 4,
				EliteCount = 1, BossCount = 0,
				LvMin = 3, LvMax = 25,
				Careers = new string[] { "police", "pandora_t", "feihuwoman", "acg_paila" },
				EliteCareers = new string[] { "acg_paila", "pandora_t" },
				BossCareers = new string[] { "boss1008" },
				Weapons = new string[]
				{
					"blood_machinegun", "aa12_hero1", "m4a1_g1", "deagle_g", "m4",
					"colt_boa", "barrett_m107_g", "viper", "double_infinity_g", "viper_rage"
				},
				BossWeapons = new string[] { "pvegatling", "barrett_m107_g", "aa12_hero1" },
				EliteHpMul = 1.6f, BossHpMul = 3f,
			}
		};

	// ---------- 大头人机 (RaceType 2019) ----------
	// 原版：RuleUtilty.IsBotMode(2019)=true；BigHeadGameRule.IsShowEnemyHpBar()=true；
	//       HeadScalePlaybackSystem: headScale.Scale = 1 + HeadEnlarge + OtherHeadEnlarge。
	// 抓包未覆盖 2019（需进大头人机房），队伍/数量按 2003 同构推导，大头倍率取原版 1.6。
	private static readonly Profile BigHead =
		new Profile
		{
			RaceType = 2019,
			Name = "大头人机",
			P3 = 1, P4 = 150, P6 = 0, P7 = 3000, P11 = 150, P16 = 217,
			MaxPlayers = 8,
			MeleeOnly = false,
			ScoreLimit = 0,
			Careers = Team.Careers,
			Weapons = Team.Weapons,
			ShowEnemyHpBar = true,
			Bot = new BotCfg
			{
				AllyBots = 2, EnemyBots = 4,
				EliteCount = 2, BossCount = 1,
				LvMin = 5, LvMax = 30,
				Careers = new string[] { "police", "pandora_t", "feihuwoman", "acg_paila" },
				EliteCareers = new string[] { "acg_paila" },
				BossCareers = new string[] { "boss1008" },
				Weapons = new string[]
				{
					"blood_machinegun", "aa12_hero1", "m4a1_g1", "deagle_g", "m4",
					"colt_boa", "barrett_m107_g", "viper", "double_infinity_g", "viper_rage"
				},
				BossWeapons = new string[] { "pvegatling", "barrett_m107_g", "aa12_hero1" },
				EliteHpMul = 1.6f, BossHpMul = 3f,
				// [OFFLINE-HEAD] 1.6f 会被当成增量算成 2.6 倍头，大头模式已整体关闭。
				HeadEnlarge = 0f,
			}
		};

	// ---------- 刀战人机 (RaceType 2041) ----------
	// 原版：RuleUtilty.IsBotMode(2041)=true，BotKnife 规则；个人竞技类（无队友）。
	// 武器池 = botweapon（近战人机专用）+ 常规近战；投掷 bot_bomb。
	private static readonly Profile BotKnife =
		new Profile
		{
			RaceType = 2041,
			Name = "刀战人机",
			P3 = 3, P4 = 13, P6 = 150000, P7 = 3000, P11 = 13, P16 = 1,
			MaxPlayers = 8,
			MeleeOnly = true,
			ScoreLimit = 150000,
			Careers = Blade.Careers,
			Weapons = new string[]
			{
				"botweapon", "nbr_knife_g", "double_fangs_g", "ice_ax", "axe_g",
				"shovel_g", "blood_shadow_sword", "bot_bomb"
			},
			Bot = new BotCfg
			{
				AllyBots = 0, EnemyBots = 5,
				EliteCount = 1, BossCount = 0,
				LvMin = 1, LvMax = 15,
				Careers = new string[] { "police", "pandora_t", "feihuwoman", "acg_paila" },
				EliteCareers = new string[] { "acg_paila" },
				BossCareers = new string[] { "boss1008" },
				Weapons = new string[] { "botweapon", "nbr_knife_g", "double_fangs_g", "ice_ax", "axe_g", "shovel_g", "blood_shadow_sword" },
				BossWeapons = new string[] { "botweapon", "ice_ax", "blood_shadow_sword" },
				EliteHpMul = 1.6f, BossHpMul = 3f,
			}
		};

	// 兼容：原版团队模式还有 id=3，规则类与 2003 相同（GameRuleFactory 都走 _groupRule）
	private static readonly Profile TeamLegacy = CloneWithRaceType(Team, 3, "团队");
	private static readonly Profile Explode = new Profile
	{
		RaceType = 2,
		Name = "爆破",
		P3 = Team.P3, P4 = Team.P4, P6 = 5, P7 = Team.P7, P11 = Team.P11, P16 = Team.P16,
		MaxPlayers = 10,
		MeleeOnly = false,
		ScoreLimit = 5,
		Careers = Team.Careers,
		Weapons = Team.Weapons,
		Bot = new BotCfg
		{
			AllyBots = 4, EnemyBots = 5,
			EliteCount = 0, BossCount = 0,
			LvMin = 3, LvMax = 25,
			Careers = new string[] { "police", "pandora_t", "feihuwoman", "sas" },
			EliteCareers = new string[0],
			BossCareers = new string[0],
			Weapons = new string[] { "m4a1_g1", "m4", "deagle_g", "aa12_hero1", "blood_machinegun" },
			BossWeapons = new string[0],
		}
	};

	private static Profile CloneWithRaceType(Profile src, int rt, string name)
	{
		Profile p = new Profile
		{
			RaceType = rt,
			Name = name,
			Careers = src.Careers,
			Weapons = src.Weapons,
			P3 = src.P3, P4 = src.P4, P6 = src.P6, P7 = src.P7,
			P11 = src.P11, P16 = src.P16,
			MaxPlayers = src.MaxPlayers,
			MeleeOnly = src.MeleeOnly,
			ScoreLimit = src.ScoreLimit,
			Bot = src.Bot,
			ShowEnemyHpBar = src.ShowEnemyHpBar
		};
		return p;
	}

	public static Profile Get(int raceType)
	{
		switch (raceType)
		{
		case 2: return Explode;
		case 15: return Blade;
		case 2003: return Team;
		case 2019: return BigHead;
		case 2041: return BotKnife;
		case 3: return TeamLegacy;
		default: return null;
		}
	}

	public static bool IsImplemented(int raceType)
	{
		return Get(raceType) != null;
	}

	// ---------- 武器池工具 ----------

	private static readonly string[] MeleeKeywords = new string[]
	{
		"botweapon", "dagger", "knife", "bat", "axe", "sword", "hammer", "blade", "claw",
		"scythe", "fan", "guqin", "whip", "spear", "staff", "club", "sickle",
		"shovel", "pickaxe", "fangs", "machete", "katana", "kris", "kukri",
		"halberd", "gauntlet", "nunchaku", "trident", "glaive", "crowbar", "wrench", "bayonet", "knuckle"
	};

	private static readonly string[] ThrowKeywords = new string[] { "grenade", "bomb", "c4" };

	public static bool IsMelee(string name)
	{
		if (string.IsNullOrEmpty(name)) return false;
		string n = name.ToLowerInvariant();
		for (int i = 0; i < MeleeKeywords.Length; i++)
		{
			if (n.Contains(MeleeKeywords[i])) return true;
		}
		return false;
	}

	public static bool IsThrowable(string name)
	{
		if (string.IsNullOrEmpty(name)) return false;
		string n = name.ToLowerInvariant();
		for (int i = 0; i < ThrowKeywords.Length; i++)
		{
			if (n.Contains(ThrowKeywords[i])) return true;
		}
		return false;
	}

	// 把模式武器池按类型拆开，供背包裁剪使用
	public static List<string> PoolMelee(Profile p)
	{
		List<string> r = new List<string>();
		if (p == null) return r;
		for (int i = 0; i < p.Weapons.Length; i++)
		{
			if (IsMelee(p.Weapons[i]) && !IsThrowable(p.Weapons[i])) r.Add(p.Weapons[i]);
		}
		return r;
	}

	public static List<string> PoolFirearm(Profile p)
	{
		List<string> r = new List<string>();
		if (p == null) return r;
		for (int i = 0; i < p.Weapons.Length; i++)
		{
			if (!IsMelee(p.Weapons[i]) && !IsThrowable(p.Weapons[i])) r.Add(p.Weapons[i]);
		}
		return r;
	}

	// 模式说明（写日志用）
	public static string Describe(int raceType)
	{
		Profile p = Get(raceType);
		if (p == null) return "raceType=" + raceType + " (no profile)";
		return p.Name + "(rt=" + p.RaceType + ") meleeOnly=" + p.MeleeOnly
			+ " careers=" + p.Careers.Length + " weapons=" + p.Weapons.Length
			+ " maxPlayers=" + p.MaxPlayers;
	}
}
