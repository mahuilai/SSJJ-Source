using System;



using System.Collections;



using Assets.Scripts.Input;



using Assets.Sources.Components.Interface;



using Assets.Sources.Components.Interface.Info.GameRule;



using Assets.Sources.Config;



using Assets.Sources.Framework.System;



using Assets.Sources.Info.CareerAnim;



using Assets.Sources.Info.GameRule;



using Assets.Sources.Modules;



using Assets.Sources.Modules.Ui;



using Assets.Sources.Snapshots;



using Assets.Sources.Ui.DynamicLoader;



using Assets.Sources.Ui.Model.Common;



using Assets.Sources.Ui.ViewModel.Common;



using Assets.Sources.Systems.GameRule;



using Assets.Sources.Systems.PacketHandle;



using Assets.Sources.Systems.Snapshot;



using Assets.Sources.Systems.Time;



using Assets.Sources.Systems.UserCommand;



using Assets.Sources.Utils.ComponentInit;



using Assets.Sources.Utils.EventLogger;



using Assets.Sources.Utils.Weapon;



using Assets.Tests.PlayMode.UI;



using DefaultNamespace;



using Entitas;



using NetData;



using SSJJ.BattleLoading;



using SSJJAsset.AssetBundle;



using SSJJBase.Logger;



using SSJJBase.Manager;



using SSJJBase.Singleton;



using SSJJBase.Thread;



using SSJJUserCmd;



using UnityEngine;

using Assets.Scripts.Utility.Sound;

using Assets.Sources.CsvLoader;



using UnityEngine.SceneManagement;



using physics;
using physics.trace;
using share;



using physics.engine;



using physics.entity;



using physics.pool;








public class OfflineGameController : GameController



{
	[System.Runtime.InteropServices.DllImport("user32")]
	public static extern short GetAsyncKeyState(int vKey);




	public static OfflineGameSetting setting;



	public static OfflineGameController Instance;







	public static bool isOffline;







	private static bool isFly;

	private static bool _probeDone;



	// [OFFLINE-PATCH] 左上角调试文字开关，默认关闭（F1 切换）

	private static bool _showDebugHud = false;
	private static float _offlineFpsSmooth = 60f;



	private float _dbgTimer;



	private bool _rigSpawned;



	private float _rigWait;



	// [OFFLINE-PATCH] 出生点取自 map1(Dust2) 的 BSP 实体 info_player_start_CT[0]：

	//     origin = "4251.959961 1234.439941 1767.839966"

	//

	// ★★★ 这里必须用 SSJJ 原始坐标，不能用 Unity 坐标 ★★★

	// 日志实证：eng=min=(-20,-20,-20) max=(11188,11188,2494) —— BspClipMap 的世界

	// 包围盒是 BSP 数学空间 (X, 水平Z, 高度Y)，三个轴的范围分别是 [0,11188]、

	// [0,11188]、[0,2494]。

	// 之前传的是 Unity 坐标 (-1234.44, 1767.84, 4251.96)：

	//    - X=-1234 落在 min.x=-20 之外  -> 每一帧都被判 "out of world"

	//    - 日志里 phys 的第三个分量恒为 -2008 左右，正是被包围盒夹住的痕迹

	// 结果就是每帧 reset 回出生点、位置永远不前进（resets 从 0 涨到 18）。

	//

	// 正确做法：物理体位置用 BSP 原始三元组 (X=4251.96, 水平Z=1234.44, 高度Y=1767.84)。

	// 渲染侧的 SsjjToUnity(x,y,z)=(-水平Z, 高度Y, X) 由引擎自己按需换算，

	// 我们不要在这里预先转换。

	//

	// 地面校验：对 (4251.96, 1234.44) 竖直下探，brush 顶面在 Y=1737.36，

	// 与渲染网格射线结果一致；origin 高出地面 30.5（网格吸附残差），物理可正常落地。

	private const float OFFLINE_SPAWN_X = 4251.96f;

	private const float OFFLINE_SPAWN_Y = 1234.44f;

	private const float OFFLINE_SPAWN_Z = 1767.84f;

	private const float OFFLINE_SPAWN_YAW = 180f;

	private bool _spawnFixed;
	private int _spawnWaitFrames;



	// [OFFLINE-PATCH] 物理体位置同步诊断

	private float _physLastX, _physLastY, _physLastZ;

	private int _physSyncCount;



	// 物理引擎世界包围盒（首次同步时缓存），用于判定"掉出世界"。

	// 初值全 0 + _engBoundsOk 标志，避免用 MaxValue/MinValue 时哨兵判断写错。

	private float _engMinX, _engMinY, _engMinZ;

	private float _engMaxX, _engMaxY, _engMaxZ;

	private bool _engBoundsOk;

	private int _physicsResets;
	// [OFFLINE-SCOPE] 开镜隐藏状态切换日志（只在变化时打一行，便于取证）
	private bool _fpHideLogged;



	private bool _matLogged;



	private bool _visualLoaded;







		private const string LOG_PATH = @"D:\SSJJ-4399\battle\3_64\log\quit_trace.log";



		// [OFFLINE-TRACE] 异常落盘节流：同一条件最多 20 条，且整体受 trace 开关控制。

		// 之前无开关无节流，循环异常能把 quit_trace.log 写到 MB 级。

		private static readonly System.Collections.Generic.Dictionary<string, int> _lifeLogCount = new System.Collections.Generic.Dictionary<string, int>();



private void Awake()



	{



		//IL_0005: Unknown result type (might be due to invalid IL or missing references)



		//IL_000f: Expected Obj, but got Unknown



		EventPool.GetInstance().SetPoolInstance((IEventPool)new SharpEventPool());



		// [OFFLINE-LIFE] 退出/异常溯源：确认静默退出的路径

		try

		{

			System.AppDomain.CurrentDomain.UnhandledException += (object snd, System.UnhandledExceptionEventArgs ev) =>

			{

				UnityEngine.Debug.LogError("[OFFLINE-LIFE] UnhandledException " + ev.ExceptionObject);

			};

			// [OFFLINE-LIFE] 谁请求退出？wantsToQuit 在 Unity 决定退出前触发，
			// 这里把调用栈落盘，能直接看出是 Application.Quit、关窗还是别的路径。
			Application.wantsToQuit += () =>
			{
				try
				{
					System.IO.File.AppendAllText(@"D:\SSJJ-4399\battle\3_64\log\quit_stack.log",
						"wantsToQuit t=" + Time.realtimeSinceStartup + "\n" + System.Environment.StackTrace + "\n");
				}
				catch (System.Exception) { }
				return true;
			};
			Application.quitting += () =>

			{

				string qt = "quitting t=" + Time.realtimeSinceStartup;

				UnityEngine.Debug.LogError("[OFFLINE-LIFE] " + qt);

				System.IO.File.AppendAllText(LOG_PATH, qt);

			};

			// [OFFLINE-TRACE] 受 trace 开关控制 + 同条件最多 20 条，防止循环异常写爆盘。

			Application.logMessageReceived += (string cond, string trace, LogType type) =>

			{

				if (type != LogType.Exception && type != LogType.Assert)

				{

					return;

				}

				if (!Assets.Sources.Framework.System.SystemTrace.Enabled)

				{

					return;

				}

				int seen;

				_lifeLogCount.TryGetValue(cond, out seen);

				seen++;

				_lifeLogCount[cond] = seen;

				if (seen > 20)

				{

					return;

				}

				System.IO.File.AppendAllText(LOG_PATH, type + " " + cond + " " + trace);

			};

		}

		catch (System.Exception ex2)

		{

			UnityEngine.Debug.LogError("[OFFLINE-LIFE] hook fail " + ex2);

		}



						// [OFFLINE-TRACE] 心跳线程：主线程死掉/进程被杀时，心跳停止时间就是死亡时刻。



		try



		{



			System.Threading.Thread hbThread = new System.Threading.Thread(delegate()



			{



				while (true)



				{



					try



					{



						if (Assets.Sources.Framework.System.SystemTrace.Enabled)

						{

							System.IO.File.AppendAllText(@"D:\SSJJ-4399\battle\3_64\log\hb_trace.log",



							DateTime.Now.ToString("HH:mm:ss.fff") + " alive tick=" + System.Environment.TickCount + "\n");



							}

					}



					catch



					{



					}



					// [OFFLINE-TRACE] 关闭追踪时 5 秒一跳，开启时才保持 500ms 精度。

					System.Threading.Thread.Sleep(Assets.Sources.Framework.System.SystemTrace.Enabled ? 500 : 5000);



				}



			});



			hbThread.IsBackground = true;



			hbThread.Name = "OfflineHeartbeat";



			hbThread.Start();



		}



		catch



		{



		}



		WeEngineUtil.InitNativeLibrary();



		GameController.Instance = this;



	}







	private IEnumerator Start()



	{



		yield return SceneManager.LoadSceneAsync("BattleLoading", (LoadSceneMode)1);



		Application.runInBackground = true;



		yield return InitBootConfigFromCommand();



		EventLogger.Instance.StageLogger(TplManager.Instance.GetBootConfig().ResourceBase, StartStageEnum.InitCmd);



		TplManager.Instance.GameBootConfig.IsBootCmd = false;



		AssetBundleManagerUtility.InitResourceUrl();



		EventLogger.Instance.StageLogger(TplManager.Instance.GetBootConfig().ResourceBase, StartStageEnum.InitResUrl);



		((Component)this).gameObject.AddComponent<UnityMainThreadDispatcher>();



		GameController.CreateSingletonEntities(Contexts.sharedInstance);



		_systems = new SSJJSystem();



		yield return InitAssetBundleManager();



		EventLogger.Instance.StageLogger(AssetBundleManager.GetAssetBundleManifestMd5(), StartStageEnum.InitBundleManager);



		yield return LoadTables();



		EventLogger.Instance.StageLogger("StartStageEnum.InitTables", StartStageEnum.InitTables);



		// [OFFLINE-PATCH] 必须先在实体/职业信息创建前加载职业动画配置：
		// CareerInfoFactory 会按 animConfig 解析 animType 并永久缓存，顺序错了会把所有
		// 角色缓存成 manCT 回退（男骨架+动画、女模型错配、第三人称动画缺失）。
		yield return CareerData.LoadConfig();



		AutoStartOffline();



		// [OFFLINE-PATCH] 原版 GameController 的启动协程会加载 UiModelRefrence.xml，

		// 它决定 HUD 动态图标/准星等 sprite 的 bundle 与资源名；离线 Start 没走那条路径，

		// 缺了这一步 UiDynamicLoadManager 的 AssetCache 为空，所有动态图片都会保持空白。

		// 用容错版本，缺包时只记录错误，不能让它中断下面的 CareerData / GameSetting 初始化。

		yield return LoadUiAssetReferenceSafe();

		// [OFFLINE-SOUND] 原版 GameController 在这里加载 SoundSystem / AutoSound 配置；
		// 离线 Start 漏了这一步 → AutoSoundManager.AutoConfigs 为空，
		// PlayKillSound/PlayAutoSoundEvent 全部静默，所以击杀/连杀/爆头没有声音。
		yield return SoundSystemLoader.Instance.Load();
		yield return MonoBehaviourSingleton<AutoSoundLoader>.Instance.Load();
		UnityEngine.Debug.Log("[OFFLINE-SOUND] SoundSystem + AutoSound loaded");



		// [OFFLINE-PATCH] CareerData.LoadConfig 已提前到 AutoStartOffline 之前执行。



		EventLogger.Instance.StageLogger("StartStageEnum.InitAnimConfig", StartStageEnum.InitAnimConfig);



		GameSetting.Apply();
		// [OFFLINE-STEP] 脚步声音量 = Vol * GameSoundManager.Config.StepVolume，
		// 而 GameSetting 用 configConstant.StepVolume / 100f 覆盖；配置缺键时 int 默认 0，
		// 结果就是「系统在跑、clip 在播，但音量 0」。这里兜到 1.0 并打日志。
		if (Assets.Sources.Utils.Sound.GameSoundManager.Config.StepVolume <= 0.01f)
		{
			Assets.Sources.Utils.Sound.GameSoundConfig soundCfg = new Assets.Sources.Utils.Sound.GameSoundConfig(
				Assets.Sources.Utils.Sound.GameSoundManager.Config.WeaponVolume,
				Assets.Sources.Utils.Sound.GameSoundManager.Config.EnvironmentVolume,
				Assets.Sources.Utils.Sound.GameSoundManager.Config.AsideVolume,
				1f,
				Assets.Sources.Utils.Sound.GameSoundManager.Config.VoiceListenVolume,
				Assets.Sources.Utils.Sound.GameSoundManager.Config.VoiceSpeakVolume,
				Assets.Sources.Utils.Sound.GameSoundManager.Config.BgmSpeakVolume);
			Assets.Sources.Utils.Sound.GameSoundManager.InitConfig(ref soundCfg);
		}
		UnityEngine.Debug.Log("[OFFLINE-STEP] StepVolume=" + Assets.Sources.Utils.Sound.GameSoundManager.Config.StepVolume);



		InitOther();



		_initFinish = true;



		isOffline = true;



	}







	// 迭代器里不能把 yield 放进 try/catch，这里手动 MoveNext 保证异常不冒泡到 Start。

	private static IEnumerator LoadUiAssetReferenceSafe()

	{

		IEnumerator it = BattleSingletonInstance<UiAssetReferenceLoader>.Instance.Load();

		while (true)

		{

			bool moved;

			try

			{

				moved = it.MoveNext();

			}

			catch (Exception ex)

			{

				UnityEngine.Debug.LogError("[OFFLINE-UI] UiModelRefrence load failed: " + ex);

				yield break;

			}

			if (!moved)

			{

				UnityEngine.Debug.Log("[OFFLINE-UI] UiModelRefrence loaded, groups=" +

					BattleSingletonInstance<Assets.Sources.Ui.DynamicLoader.UiAssetReferenceLoader>.Instance.AssetCache.Count);

				yield break;

			}

			yield return it.Current;

		}

	}



	public void AutoStartOffline()

	{

		Instance = this;

		isOffline = true;

		if (GetComponent<OfflineFirstPersonRig>() == null)

		{

			gameObject.AddComponent<OfflineFirstPersonRig>();

		}

		if (GetComponent<OfflineGameSetting>() == null)

		{

			gameObject.AddComponent<OfflineGameSetting>();

		}

		if (GetComponent<OfflineGameplay>() == null)

		{

			gameObject.AddComponent<OfflineGameplay>();

		}
		// 仅挂载 F6 训练面板宿主；OnGUI 会主动跳过自绘 HUD，避免覆盖原版 UGUI。
		OfflineHud trainingHud = GetComponent<OfflineHud>();
		if (trainingHud == null) trainingHud = gameObject.AddComponent<OfflineHud>();
		trainingHud.TrainingPanelOnly = true;
		// Bot 的网络可见性/CommandBuffer 状态在离线快照下不完整；
		// 该组件只修复 Bot 的现有第三人称 Renderer，不参与碰撞或 AI。
		if (GetComponent<OfflineBotVisual>() == null)
		{
			gameObject.AddComponent<OfflineBotVisual>();
		}
		// [OFFLINE-GRENADE] 破片/闪光/烟雾的表现层（全屏闪光 + 爆炸脉冲 + 烟雾粒子）。
		if (GetComponent<OfflineGrenadeFx>() == null)
		{
			gameObject.AddComponent<OfflineGrenadeFx>();
		}

		// 原版 HUD 全部由 UiModule 的 MVVM 视图驱动（Menu / Weaponstate / RadarMap / Teamscore ...），

		// UiModule 关闭时（原版 HUD 崩溃问题修复前）挂回自绘 OfflineHud 兜底。

		// [OFFLINE-PATCH] 原版 UGUI 负责主 HUD；OfflineHud 自绘面板保持卸载。
		// [OFFLINE-PATCH] 帧率：原版 targetFrameRate=屏幕刷新率（读旧存档可能=40），

		// 离线端解封到 120 并关闭垂直同步。

		QualitySettings.vSyncCount = 0;

		Application.targetFrameRate = 999;

		// [OFFLINE-PATCH] 天空盒兜底：离线没有服务端下发的 skybox 实体，

		// 抬头会看到 map1 顶部封盖缺失造成的大片纯黑，这里手工补上。

		if (GetComponent<OfflineSkybox>() == null)

		{

			gameObject.AddComponent<OfflineSkybox>();

		}

		OfflineGameSetting offlineGameSetting = GetComponent<OfflineGameSetting>();

		// [OFFLINE-PATCH] 大厅启动器写入 launch_config.json，离线端在这里应用选择；

		// 没有配置或资源缺包时回退到已验证的 police + 黄金尼泊尔。

		if (!offlineGameSetting.ApplyLaunchConfig())

		{

			offlineGameSetting.TurnOn = true;

			offlineGameSetting.SceneId = 1;

			offlineGameSetting.Player = "police";

			offlineGameSetting.Hand = "man";

			offlineGameSetting.Weapon = "nbr_knife_g";

			offlineGameSetting.BotCount = 4;

			offlineGameSetting.BotCareer = "police";

			offlineGameSetting.GodMode = true;

			offlineGameSetting.X = (offlineGameSetting.Y = (offlineGameSetting.Z = 0f));

		}

		// [OFFLINE-TRAINING] map12 练枪强制本局无敌；只覆盖内存设置，不回写启动器配置。
		if (Assets.Sources.Systems.Snapshot.OfflineBotSpawner.IsMap12TrainingProfile(offlineGameSetting))
		{
			offlineGameSetting.GodMode = true;
			UnityEngine.Debug.Log("[OFFLINE-TRAINING] map12 practice god mode=ON (runtime only)");
		}
		OfflineGameplay.GodMode = offlineGameSetting.GodMode;

		GlobalLogger.Info<OfflineGameController, string>(this, "AUTO OFFLINE START: SceneId=" + offlineGameSetting.SceneId + " player=" + offlineGameSetting.Player + " weapon=" + offlineGameSetting.Weapon);

		InitOfflineData();

		// RaceType 必须是真实模式 id（有 modeconfig 的），SceneId 才是地图

		Contexts.sharedInstance.battleRoom.roomData.Data.RaceType = offlineGameSetting.RaceType;

		// [OFFLINE-FIX] InitOfflineData 已写入所选地图 id；这里必须保持一致，
		// 否则房间状态=1 而实际加载的是别的图，读取 roomData 的 UI/场景特例逻辑会拿错图。
		Contexts.sharedInstance.battleRoom.roomData.Data.SceneId = offlineGameSetting.SceneId;

		Contexts.sharedInstance.battleRoom.roomData.IsObserver = false;

		// [OFFLINE-TDM] 在 UI 模式初始化前创建 broadcastScore/sectionTime/gameOver，
		// 否则原版 TeamScore/PlayerReborn/CommonGameOver 的 MakeTempNotify(initinvoke)
		// 可能读到不存在的组件而失效。Initialize 幂等，OfflineGameplay.Start 会再确认一次。
		try
		{
			OfflineTdmMatch.Initialize(OfflineGameplay.Instance);
		}
		catch (System.Exception ex)
		{
			UnityEngine.Debug.LogWarning("[OFFLINE-TDM] controller init failed: " + ex.Message);
		}

	}



	// [OFFLINE-SKIN] 把配置的皮肤名写进本地玩家实体。

	// 角色皮肤 -> basicInfo.SkinName（LoadFirstHandSystem / LoadThirdPersonSystem 读它去

	// PlayerSkinInfoFactory 查表，包名 playerskin/<名>）；

	// 武器皮肤 -> currentWeapon.SkinName（WeaponSkinInfoFactory 查 weaponskin/<名>）。

	private void ApplyOfflineSkin()

	{

		if (setting == null) return;

		Contexts ctx = Contexts.sharedInstance;

		if (ctx == null || ctx.player == null) return;

		PlayerEntity me = ctx.player.myPlayerEntity;

		if (me == null || !me.hasBasicInfo) return;



		bool changed = false;

		if (!string.IsNullOrEmpty(setting.CareerSkin) && me.basicInfo.SkinName != setting.CareerSkin)

		{

			me.basicInfo.SkinName = setting.CareerSkin;

			changed = true;

		}

		if (me.hasCurrentWeapon)
		{
			// [OFFLINE-SKIN] 皮肤按"当前武器所在背包槽位"取：换枪/换背包时皮肤跟着武器走，
			// 不会像旧逻辑那样只有主武器有皮肤、或者换枪后皮肤还留在别的枪上。
			string weaponName = (me.currentWeapon.WeaponInfo != null) ? me.currentWeapon.WeaponInfo.Name : "";
			int bagId = (me.basicInfo.Current != null) ? me.basicInfo.Current.CurrentBagId : setting.ActiveBag;
			int slot = (me.currentWeapon.Weapon >= 1 && me.currentWeapon.Weapon <= 4) ? me.currentWeapon.Weapon : 1;
			string wantSkin = setting.SkinForBagSlot(bagId, slot, weaponName);
			if (me.currentWeapon.SkinName != wantSkin)
			{
				me.currentWeapon.SkinName = wantSkin;
				changed = true;
			}
		}

		if (!_skinLogged)
		{
			_skinLogged = true;
			UnityEngine.Debug.Log("[OFFLINE-SKIN] probe meNull=" + (me == null) + " hasBasic=" + me.hasBasicInfo + " cur=[" + me.basicInfo.SkinName + "]" + " want=[" + setting.CareerSkin + "]" + " hasCW=" + me.hasCurrentWeapon + " cwSkin=[" + (me.hasCurrentWeapon ? me.currentWeapon.SkinName : "-") + "]" + " wantW=[" + setting.WeaponSkin + "]");
		}
		if (changed && !_skinApplied)
		{
			_skinApplied = true;
			UnityEngine.Debug.Log("[OFFLINE-SKIN] applied weaponSkin=" + (string.IsNullOrEmpty(setting.WeaponSkin) ? "-" : setting.WeaponSkin) + " careerSkin=" + (string.IsNullOrEmpty(setting.CareerSkin) ? "-" : setting.CareerSkin));
		}

	}



	public void InitOfflineData()



	{



		//IL_0005: Unknown result type (might be due to invalid IL or missing references)



		//IL_000b: Expected Obj, but got Unknown



		//IL_0016: Unknown result type (might be due to invalid IL or missing references)



		//IL_0020: Expected Obj, but got Unknown



		Contexts sharedInstance = Contexts.sharedInstance;



		OnGameinitData val = new OnGameinitData();



		sharedInstance.battleRoom.roomData.Data = new RoomData();



		setting = ((Component)this).GetComponent<OfflineGameSetting>();



		val.SceneId = setting.SceneId;



		// [OFFLINE-PATCH] 把所选角色/武器/手模加入预加载清单，

		// 否则 BattleLoadingManager 只会加载默认包，所选模型进图后找不到。

		if (!val.PlayerList.Contains(setting.Player)) val.PlayerList.Add(setting.Player);

		if (setting.BotCount > 0 && !val.PlayerList.Contains(setting.BotCareer)) val.PlayerList.Add(setting.BotCareer);

		// [OFFLINE-PATCH] 5 个背包 × 4 槽全部预加载，切背包时资源必须已在内存里。

		setting.EnsureBags();

		for (int bi = 0; bi < setting.Bags.Count; bi++)

		{

			OfflineGameSetting.BagConfig bag = setting.Bags[bi];

			string[] bagWeapons = new string[]

			{

				bag.primary,

				bag.secondary,

				bag.melee,

				bag.throwable

			};

			for (int i = 0; i < bagWeapons.Length; i++)

			{

				string w = bagWeapons[i];

				if (string.IsNullOrEmpty(w)) continue;

				if (!val.WeaponList.Contains(w)) val.WeaponList.Add(w);

				if (!val.ViewWeaponList.Contains(w)) val.ViewWeaponList.Add(w);

			}

		}
		if (setting.RaceType == 2 && !val.WeaponList.Contains("c4"))
		{
			val.WeaponList.Add("c4");
			if (!val.ViewWeaponList.Contains("c4")) val.ViewWeaponList.Add("c4");
		}

		if (!val.HandName.Contains(setting.Hand)) val.HandName.Add(setting.Hand);



		// [OFFLINE-SKIN] 皮肤预加载：OnGameinitData 的 weaponSkinList / careerSkinList。

		if (!string.IsNullOrEmpty(setting.WeaponSkin) && !val.WeaponSkinList.Contains(setting.WeaponSkin))

		{

			val.WeaponSkinList.Add(setting.WeaponSkin);

		}

		// [OFFLINE-SKIN] 背包槽位皮肤：全部加进 weaponSkinList，否则进图后换枪找不到皮肤包。
		System.Collections.Generic.List<string> bagSkins = setting.AllBagSkins();
		for (int si = 0; si < bagSkins.Count; si++)
		{
			if (!val.WeaponSkinList.Contains(bagSkins[si])) val.WeaponSkinList.Add(bagSkins[si]);
		}

		if (!string.IsNullOrEmpty(setting.CareerSkin) && !val.CareerSkinList.Contains(setting.CareerSkin))

		{

			val.CareerSkinList.Add(setting.CareerSkin);

		}

		UnityEngine.Debug.Log("[OFFLINE-SKIN] preload weaponSkin=" + (string.IsNullOrEmpty(setting.WeaponSkin) ? "-" : setting.WeaponSkin) + " careerSkin=" + (string.IsNullOrEmpty(setting.CareerSkin) ? "-" : setting.CareerSkin) + " bagSkins=" + bagSkins.Count);



		sharedInstance.battleRoom.roomData.Data.SceneId = setting.SceneId;



		// [OFFLINE-PATCH] RaceType 是"模式 id"，SceneId 是"地图 id"，不能混用。

		// 离线由 launch_config.mode 映射到原版模式 id（默认 3=团队）。

		int raceType = (setting.RaceType > 0) ? setting.RaceType : 3;

		sharedInstance.battleRoom.roomData.Data.RaceType = raceType;



		sharedInstance.battleRoom.roomData.Data.SubRaceType = 0;



		// [OFFLINE-PATCH] EngineId=1 才走 BSP 物理分支（BspEngine + BspClipMap）。

		// 离线没有服务器下发 OnGameinitData.EngineID，默认是 0，会走 WeEngine + mapData 分支；

		// 而我们的自建 bundle 里根本没有 physics 的 mapData，结果物理世界是空的 ——

		// 玩家没有任何可站立面，一路直坠（日志 cam.y 从 1720 掉到 -158211）。

		// 强制 EngineId=1 后，物理几何直接取自 map1 的 model.bsp.raw，与场景一致。

		val.EngineID = 1;

		sharedInstance.battleRoom.roomData.EngineId = 1;

		UnityEngine.Debug.Log("[OFFLINE-ENGINE] EngineId forced to 1 (BSP physics branch)");



		sharedInstance.battleRoom.roomData.Data.FreeType = "";



		// [OFFLINE-PATCH] 用原版 GameRuleFactory 选真实规则类，而不是测试桩：

		// 3=GroupGameRule（团队）、5=Personal、12=DeathMatch、2=Explode、15=Blade 等。

		// 规则的 49 个钩子直接决定换武器/低血提示/雷达/C4 等行为。

		IGameRule gameRule = GameRuleFactory.Instance.GetGameRule(raceType);

		sharedInstance.gameRule.SetCurrentRule(gameRule);

		UnityEngine.Debug.Log("[OFFLINE-RULE] raceType=" + raceType + " rule=" + gameRule.GetType().Name);



		MonoBehaviourSingleton<BattleLoadingManager>.Instance.LoadOfflineResources(val);



	}







	// [OFFLINE-SKIN] 皮肤只打一次日志，避免每帧刷屏。

	private bool _skinLogged;
	private static float s_velDiagT;
	private static float s_velMoveT;
	private static float s_legChangeT;
	private static float s_jumpLogT;
	// [OFFLINE-LEG] 本地玩家当前合成的腿部状态（供 PlayerLegAnimInitSystem 离线分支使用）。
	public static int OfflineLocalLegState;
	private static float s_viewLocoT;
	// [OFFLINE-VISDIAG2] 每个 bot 只打一次完整渲染器清单（定位"有碰撞没模型"）。
	private static readonly System.Collections.Generic.HashSet<int> s_visDiagIds = new System.Collections.Generic.HashSet<int>();
	private static readonly MaterialPropertyBlock s_visDiagMpb = new MaterialPropertyBlock();

	// 渲染器的逐实例属性块会覆盖材质自身的 _Color.a（隐身/顶点色系统都走这条路）。
	private static readonly UnityEngine.Mesh s_visDiagBake = new UnityEngine.Mesh();

	// 把当前蒙皮结果烘到 CPU，量真实包围盒：≈0 表示骨骼把网格压成一个点（看起来就是"没有模型"）。
	private static string VisDiagBakeSkinned(SkinnedMeshRenderer sr)
	{
		if (sr == null || sr.sharedMesh == null) return "-";
		try
		{
			sr.BakeMesh(s_visDiagBake);
			Vector3[] vs = s_visDiagBake.vertices;
			if (vs == null || vs.Length == 0) return "nov";
			Vector3 min = vs[0], max = vs[0];
			for (int i = 1; i < vs.Length; i++)
			{
				min = Vector3.Min(min, vs[i]);
				max = Vector3.Max(max, vs[i]);
			}
			Vector3 size = max - min;
			return "v" + vs.Length + "/" + size.ToString("F0") + "/c" + ((min + max) * 0.5f).ToString("F0");
		}
		catch (System.Exception ex) { return "e" + ex.GetType().Name; }
	}

	private static string VisDiagMpbAlpha(Renderer rr)
	{
		try
		{
			rr.GetPropertyBlock(s_visDiagMpb);
			if (s_visDiagMpb.isEmpty) return "-";
			return s_visDiagMpb.GetColor("_Color").a.ToString("F2");
		}
		catch (System.Exception) { return "?"; }
	}
		private bool _skinApplied;



	private int _previousWeaponSlot = 1;



	// [OFFLINE-PATCH] 离线帧率上限：默认 150，launch_config.json 的 "fps" 字段可覆盖。

	private static int _offlineFrameLimit = -1;



	private static int OfflineFrameLimit

	{

		get

		{

			if (_offlineFrameLimit < 0)

			{

				_offlineFrameLimit = 999;

				try

				{

					string cfgPath = System.IO.Path.Combine(System.IO.Directory.GetParent(UnityEngine.Application.dataPath).FullName, "launch_config.json");

					if (System.IO.File.Exists(cfgPath))

					{

						string text = System.IO.File.ReadAllText(cfgPath);

						int keyIdx = text.IndexOf("\"fps\"");

						if (keyIdx >= 0)

						{

							int colon = text.IndexOf(':', keyIdx);

							int end = colon;

							while (end < text.Length && (char.IsDigit(text[end]) || text[end] == '-' || text[end] == '.' || char.IsWhiteSpace(text[end]) || text[end] == ':'))

							{

								end++;

							}

							string num = text.Substring(colon + 1, end - colon - 1).Trim();

							int parsed;

							if (int.TryParse(num, out parsed) && parsed > 0)

							{

								_offlineFrameLimit = parsed;

							}

						}

					}

				}

				catch

				{

				}

				UnityEngine.Debug.Log("[OFFLINE-PATCH] frame limit = " + _offlineFrameLimit);

			}

			return _offlineFrameLimit;

		}

	}





	private static bool IsBagPanelOpen()

	{
		if (OfflineHud.TrainingPanelOpen || OfflineHud.BackpackOpen) return true;

		// [OFFLINE-PATCH] UiModule 关闭时原版 PlayerBagModel 不存在，

		// 用自绘 OfflineHud 的背包面板状态兜底。

		if (PlayerBagModel.ViewModelInstance != null)

		{

			return PlayerBagModel.ViewModelInstance.BagOpenedPanelShow;

		}

		return false;

	}



	private void HandleOfflineHotkeys()

	{

		// [OFFLINE-TRAINING] F6 map12 训练设置；打开时屏蔽背包、换枪和游戏输入。
		if (Input.GetKeyDown(KeyCode.F6))
		{
			if (OfflineHud.TrainingPanelOpen) OfflineHud.CloseTrainingPanel();
			else if (!IsBagPanelOpen()) OfflineHud.ToggleTrainingPanel();
		}
		if (OfflineHud.TrainingPanelOpen)
		{
			if (Input.GetKeyDown(KeyCode.Escape)) OfflineHud.CloseTrainingPanel();
			return;
		}

		// [OFFLINE-PATCH] B 键：UiModule 关闭时由这里开合自绘背包面板。

		if (Input.GetKeyDown(KeyCode.B) && PlayerBagModel.ViewModelInstance == null)

		{

			OfflineHud.BackpackOpen = !OfflineHud.BackpackOpen;

			if (OfflineHud.BackpackOpen)

			{

				Cursor.visible = true;

				Cursor.lockState = CursorLockMode.None;

			}

			else

			{

				Cursor.visible = false;

				Cursor.lockState = CursorLockMode.Locked;

			}

		}

		// B 背包 / Esc 设置菜单已由原版 PlayerBagModel / MenuModel 通过 KeyboardEventSystem 处理。

		// 数字键：背包打开时 1~5 选背包（原版只发 UserCmd，离线没有服务端，需要手动落地）；

		// 背包关闭时 1~4 切换当前背包的武器槽。

		if (IsBagPanelOpen())

		{

			if (Input.GetKeyDown(KeyCode.Alpha1)) TrySwitchBag(1);

			else if (Input.GetKeyDown(KeyCode.Alpha2)) TrySwitchBag(2);

			else if (Input.GetKeyDown(KeyCode.Alpha3)) TrySwitchBag(3);

			else if (Input.GetKeyDown(KeyCode.Alpha4)) TrySwitchBag(4);

			else if (Input.GetKeyDown(KeyCode.Alpha5)) TrySwitchBag(5);

			return;

		}

		if (Input.GetKeyDown(KeyCode.Alpha1)) TrySwitchWeapon(1);

		else if (Input.GetKeyDown(KeyCode.Alpha2)) TrySwitchWeapon(2);

		else if (Input.GetKeyDown(KeyCode.Alpha3)) TrySwitchWeapon(3);

		else if (Input.GetKeyDown(KeyCode.Alpha4)) CycleBombSlot();

		else if (Input.GetKeyDown(KeyCode.Q)) TrySwitchWeapon(_previousWeaponSlot);

	}



	/// <summary>切换背包（1~5），沿用原版 CurrentBagId + isCurrentBag 语义。</summary>

	public bool TrySwitchBag(int bagId)

	{

		if (bagId < 1 || bagId > OfflineGameSetting.BagCount) return false;

		Contexts ctx = Contexts.sharedInstance;

		PlayerEntity player = ctx.player.myPlayerEntity;

		if (player == null || !player.hasBasicInfo || player.basicInfo.Current == null) return false;

		if (player.basicInfo.Current.CurrentBagId == bagId) return false;



		player.basicInfo.Current.CurrentBagId = bagId;

		if (player.basicInfo.Next != null) player.basicInfo.Next.CurrentBagId = bagId;



		for (int i = 1; i <= OfflineGameSetting.BagCount; i++)

		{

			PlayerBagEntity bagEntity = ContextsExtensions.GetEntityWithBagId(ctx.playerBag, i);

			if (bagEntity != null)

			{

				bagEntity.isCurrentBag = (i == bagId);

			}

		}



		ISnapshot snap = ctx.snapshot.snapshots.LatestSnapshot;

		PlayerEntityData me;

		if (snap != null && snap.PlayerEntityDataDict != null && snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me))

		{

			me.CurrentBagId = bagId;

		}



		// 换背包后自动拿起该背包主武器；主武器缺失退到近战。

		if (!TrySwitchWeapon(1))

		{

			TrySwitchWeapon(3);

		}

		Debug.Log("[OFFLINE-BAG] switched bag=" + bagId);

		return true;

	}



	private static bool s_bagAnimWarmup;

	// [OFFLINE-WEAPON] 武器视图动画配置是异步加载的（WeaponAnimInfoFactory），原版在
	// BattleLoading 阶段就把各背包武器的 AnimConfig 预载好。离线背包是在加载后才构造的，
	// 首次切到没预载的武器会查不到 TORSO_RAISE（切枪没出场动画）。这里开局主动请求一次。
	private void WarmupBagWeaponAnims()
	{
		if (s_bagAnimWarmup) return;
		Contexts ctx = Contexts.sharedInstance;
		PlayerEntity player = (ctx != null) ? ctx.player.myPlayerEntity : null;
		if (player == null || !player.hasBasicInfo || player.basicInfo.Current == null) return;
		s_bagAnimWarmup = true;
		int requested = 0;
		for (int bag = 1; bag <= OfflineGameSetting.BagCount; bag++)
		{
			for (int slot = 1; slot <= 4; slot++)
			{
				try
				{
					WeaponEntity w = WeaponUtility.GetWeaponAtSlot(player, bag, slot, 0);
					if (w != null && w.hasBasicInfo && w.basicInfo.Info != null)
					{
						Assets.Sources.Info.WeaponAnim.WeaponAnimInfoFactory.Instance.GetWeaponAnimInfo(w.basicInfo.Info);
						requested++;
					}
				}
				catch (System.Exception) { }
			}
		}
		UnityEngine.Debug.Log("[OFFLINE-WEAPON] anim config warmup requested=" + requested);
	}

	/// <summary>切到指定武器槽（1 主武器 / 2 副武器 / 3 近战 / 4 投掷），离线没有 UserCmd 直接走原版切换链。</summary>

	public bool TrySwitchWeapon(int slot)	{

		return TrySwitchWeapon(slot, 0);

	}

	/// <summary>[OFFLINE-EQUIP] 手雷包：原版每个背包 3 个投掷槽（BombWeapons0/1/2）。
	/// 按 4 在这三个槽之间轮换；槽位不存在就跳过。</summary>
	public void CycleBombSlot()
	{
		Contexts ctx = Contexts.sharedInstance;
		PlayerEntity player = ctx.player.myPlayerEntity;
		if (player == null || !player.hasBasicInfo || player.basicInfo.Current == null) return;
		int bagId = player.basicInfo.Current.CurrentBagId;
		int curIdx = -1;
		try
		{
			var cur = ctx.weapon.currentWeaponEntity;
			if (cur != null && cur.hasSlot && cur.slot.Slot == 4) curIdx = cur.slot.Index;
		}
		catch (System.Exception) { }
		for (int step = 1; step <= 3; step++)
		{
			int idx = ((curIdx + step) % 3 + 3) % 3;
			var cand = WeaponUtility.GetWeaponAtSlot(player, bagId, 4, idx);
			if (cand == null || !cand.hasBasicInfo || cand.basicInfo.Data == null) continue;
			if (TrySwitchWeapon(4, idx))
			{
				UnityEngine.Debug.Log("[OFFLINE-EQUIP] bomb slot -> " + idx + " " + cand.basicInfo.Data.WeaponName);
			}
			return;
		}
	}

	public bool TrySwitchWeapon(int slot, int index)	{

		if (slot < 1 || slot > 4) return false;

		Contexts ctx = Contexts.sharedInstance;

		PlayerEntity player = ctx.player.myPlayerEntity;

		if (player == null || !player.hasBasicInfo || player.basicInfo.Current == null) return false;

		if (!player.hasCurrentWeapon) return false;

		var current = ctx.weapon.currentWeaponEntity;

		var target = WeaponUtility.GetWeaponAtSlot(player, player.basicInfo.Current.CurrentBagId, slot, index);

		if (target == null || target == current || !target.hasBasicInfo || target.basicInfo.Data == null)

		{

			return false;

		}

		_previousWeaponSlot = Mathf.Max(1, player.currentWeapon.Weapon);

		// [OFFLINE-GRENADE] 原版槽 4 在 Clip==0 时静默拒绝切换；离线给投掷物补 1 发。
		if (slot == 4 && target.hasClip && target.clip.Clip <= 0)
		{
			target.clip.Clip = 1;
			UnityEngine.Debug.Log("[OFFLINE-WEAPON] force throwable clip=1 slot4");
		}
		WeaponUtility.ChangeCurrentWeapon(player, current, target, slot);

		WeaponUtility.CopyToWeaponComponent(player.currentWeapon, target);

		PlayerEntityUtility.CleanupFirstPersonUnityObjects(player);
		OfflineGameplay.AttackAnimActive = false;

		player.fov.Fov = 90;

		target.special.IsRaise = true;



		ISnapshot snap = ctx.snapshot.snapshots.LatestSnapshot;

		PlayerEntityData me;

		if (snap != null && snap.PlayerEntityDataDict != null && snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me))

		{

			me.CurrentWeapon = target.slot.Slot;

			me.CurrentWeaponIndex = target.slot.Index;

			me.CurrentWeaponName = target.basicInfo.Data.WeaponName;

			me.CurrentWeaponSkinName = target.basicInfo.Data.WeaponSkinName;
			// [OFFLINE-SKIN] 皮肤按"当前背包 + 槽位"取：换枪/换背包时皮肤跟着武器走，
			// 不再只有主武器能套皮肤，也不会把旧皮肤留在别的枪上。
			string skinForSlot = (OfflineGameController.setting != null)
				? OfflineGameController.setting.SkinForBagSlot(player.basicInfo.Current.CurrentBagId, slot, target.basicInfo.Data.WeaponName)
				: "";
			target.basicInfo.Data.WeaponSkinName = skinForSlot;
			me.CurrentWeaponSkinName = skinForSlot;

			me.CurrentWeaponLevel = target.basicInfo.Data.Level;

			me.CurrentWeaponWorn = target.basicInfo.Data.WeaponWorn;

			me.CurrentWeaponQuenchId = target.basicInfo.Data.QuenchId;

		}

		// [OFFLINE-WEAPON] 新手模异步就绪后只提交一次 TORSO_RAISE。
		try
		{
			int raiseId = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindViewAnimByName(player.currentWeapon.WeaponInfo, "TORSO_RAISE");
			if (raiseId <= 0) raiseId = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindViewAnimByName(player.currentWeapon.WeaponInfo, "TORSO_STAND");
			OfflineGameplay.SuppressIdleUntil = Time.time + 0.6f;
			OfflineGameplay.PendingRaiseAt = Time.time + 0.02f;
			UnityEngine.Debug.Log("[OFFLINE-WEAPON] raise queued id=" + raiseId);
		}
		catch (System.Exception) { }
		Debug.Log("[OFFLINE-WEAPON] switched slot=" + slot + " weapon=" + target.basicInfo.Data.WeaponName);

		return true;

	}



		private static bool KeyDown(KeyCode kc, int vk)
	{
		if (Input.GetKey(kc)) return true;
		return (GetAsyncKeyState(vk) & 0x8000) != 0;
	}

private void FlyTick()
{
	if (!isFly) return;
	try
	{
		PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
		if (me == null || !me.hasMove || me.move.PyPlayerMove == null) return;
		IPyPlayerMove ad = me.move.PyPlayerMove;
		float mf = 0f, mr = 0f, up = 0f;
		// [OFFLINE-FLY3] 双通道：Input.GetKey 轮询在容器外壳下恒 false，补 GetAsyncKeyState
if (KeyDown(KeyCode.W, 0x57)) mf += 100f;
			if (KeyDown(KeyCode.S, 0x53)) mf -= 100f;
			if (KeyDown(KeyCode.D, 0x44)) mr += 100f;
			if (KeyDown(KeyCode.A, 0x41)) mr -= 100f;
			if (KeyDown(KeyCode.Space, 0x20)) up += 100f;
			if (KeyDown(KeyCode.C, 0x43) || KeyDown(KeyCode.LeftControl, 0xA2)) up -= 100f;
		float yawDeg = 0f, pitDeg = 0f;
		if (me.hasOrientation) { yawDeg = me.orientation.Yaw; pitDeg = me.orientation.Pitch; }
		float num = yawDeg * 0.01745f;
		float num2 = (float)(90 - pitDeg) * 0.01745f;
		float num3 = (yawDeg - 90f) * 0.01745f;
		float num4 = Mathf.Sin(num2) * (Mathf.Cos(num) * mf + Mathf.Cos(num3) * mr) * 0.001f;
		float num5 = Mathf.Sin(num2) * (Mathf.Sin(num) * mf + Mathf.Sin(num3) * mr) * 0.001f;
		float num6 = (Mathf.Cos(num2) * (mf + mr) + up) * 0.001f;
		float k = Mathf.Clamp(Time.deltaTime, 0.001f, 0.05f) * 60f;
		float nx = (float)ad.GetX() + num4 * 300f * k;
		float ny = (float)ad.GetY() + num5 * 300f * k;
		float nz = (float)ad.GetZ() + num6 * 300f * k;
		ad.SetPosition(nx, ny, nz);
		if (me.hasBasicInfo && me.basicInfo.Current != null)
		{
			me.basicInfo.Current.X = nx; me.basicInfo.Current.Y = ny; me.basicInfo.Current.Z = nz;
			if (me.basicInfo.Next != null) { me.basicInfo.Next.X = nx; me.basicInfo.Next.Y = ny; me.basicInfo.Next.Z = nz; }
		}
		if (s_flyLogN < 10 || Time.realtimeSinceStartup - s_flyLogT > 2f)
		{
			s_flyLogN++;
			s_flyLogT = Time.realtimeSinceStartup;
			UnityEngine.Debug.Log("[OFFLINE-FLY] pos=" + nx.ToString("F0") + "," + ny.ToString("F0") + "," + nz.ToString("F0")
				+ " in=" + mf.ToString("F0") + "/" + mr.ToString("F0") + "/" + up.ToString("F0"));
		}
	}
	catch (System.Exception) { }
}

private void LateUpdate()
	{
		FlyTick();   // [OFFLINE-FLY2] 自管飞行
		// [OFFLINE-HUD] H / F1 开关红字调试信息，并平滑采样 FPS。
		if (Input.GetKeyDown(KeyCode.H) || Input.GetKeyDown(KeyCode.F1)) _showDebugHud = !_showDebugHud;
		float dtDbg = Time.unscaledDeltaTime;
		if (dtDbg > 0.0001f) _offlineFpsSmooth = Mathf.Lerp(_offlineFpsSmooth, 1f / dtDbg, 0.08f);

	// [OFFLINE-TRACE] 帧阶段面包屑：定位系统循环之外的崩溃点。
	if (Assets.Sources.Framework.System.SystemTrace.Enabled)
	{
		try { System.IO.File.AppendAllText(@"D:\SSJJ-4399\battle\3_64\log\sys_trace.log", "PHASE late-end t=" + Time.realtimeSinceStartup + "\n"); } catch { }
	}
	if (isOffline) CleanOfflineDebugUi();
	}

	private int _uiCleanAttempts;
	private float _nextUiClean;
	// 隐藏原版调试残留：FpsDisplay 常驻的“全屏窗口化”红字、加载页遗留的“查看场景”按钮。
	private void CleanOfflineDebugUi()
	{
		if (_uiCleanAttempts >= 8 || Time.time < _nextUiClean) return;
		_nextUiClean = Time.time + 2f;
		_uiCleanAttempts++;
		try
		{
			FpsDisplay fps = FpsDisplay.GetInstance();
			if (fps != null)
			{
				if (fps._text != null) fps._text.enabled = false;
				if (fps._text2 != null) fps._text2.enabled = false;
			}
		}
		catch (System.Exception)
		{
		}
		try
		{
			UnityEngine.UI.Text[] texts = UnityEngine.Resources.FindObjectsOfTypeAll<UnityEngine.UI.Text>();
			for (int i = 0; i < texts.Length; i++)
			{
				UnityEngine.UI.Text t = texts[i];
				if (t == null || t.transform == null || t.transform.parent == null) continue;
				if (t.text != null && t.text.Trim() == "查看场景")
				{
					t.transform.parent.gameObject.SetActive(false);
					UnityEngine.Debug.Log("[OFFLINE-UI] hide 查看场景 button");
				}
			}
		}
		catch (System.Exception)
		{
		}
	}


	// [OFFLINE-DBGCAM] 渲染探针相机：每 2.5 秒从游戏主相机视角渲染两张 PNG 到

	// Game-SSJJ-logs\dbgcam\：

	//   dbg_main_N.png = 主相机原样渲染（= 用户屏幕上应该看到的内容）

	//   dbg_all_N.png  = 同视角全 layer 渲染（cullingMask=-1）

	// 对比两张图即可定位"日志说 isVisible=true 但用户看不见"的断层：

	//   main 有 / all 有 → 模型正常渲染（截图工具问题，非游戏 bug）

	//   main 无 / all 有 → 主相机 cullingMask/layer 把 bot 层剔掉了

	//   main 无 / all 无 → 模型根本没渲染出来（材质/深度/缩放问题）

	private Camera _dbgCam;

	// [OFFLINE-CAMDIAG] 渲染前瞬间的 bot 可见性快照（由 Camera.onPreRender 写入）。
	private static string _preSnap = "-";
	private static bool _preHooked;




	private float _dbgCamT;



	private int _dbgCamN;



		// [OFFLINE-BOTCAM] 每个 bot 的"熟准特写"：相机留在玩家眼位、转向 bot 胸部，
		// FOV 按 bounds 身高/距离自适应（单位无关），等价于用户盯着该 bot 看的画面。
		private void RenderBotCloseups(Camera main, string dir)
		{
			try
			{
				int n = 0;
				foreach (PlayerEntity bp in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
				{
					if (n >= 6) break;
					if (!bp.hasThirdPersonUnityObjects) continue;
					var tpx = bp.thirdPersonUnityObjects.ThirdTran;
					if (tpx == null || tpx.RootContainer == null) continue;
					if (bp.hasBasicInfo && (bp.basicInfo.Current.IsDead || bp.basicInfo.Current.Hp <= 0f)) continue;
					Renderer[] rs = tpx.RootContainer.GetComponentsInChildren<Renderer>(true);
					// [OFFLINE-BODYFIX] 选体：bounds 中心离 bot 根最近 + 尺寸合理（50~3000），
					// 防幻影网格（size.y=10361、中心偏移 2600+）被误选导致特写拍空。
					Renderer body = null;
					float bestD = float.MaxValue;
					Vector3 rootPos = tpx.RootContainer.transform.position;
					for (int i = 0; i < rs.Length; i++)
					{
						if (rs[i] == null || !rs[i].enabled || !rs[i].gameObject.activeInHierarchy) continue;
						float sy = rs[i].bounds.size.y;
						if (sy <= 50f || sy >= 3000f) continue;
						float d = (rs[i].bounds.center - rootPos).sqrMagnitude;
						if (d < bestD) { bestD = d; body = rs[i]; }
					}
					if (body == null) continue;
					Vector3 chest = body.bounds.center;
					float bodyH = body.bounds.size.y;
					float bdist = (chest - main.transform.position).magnitude;
					if (bdist < 0.01f || bodyH <= 0.01f) continue;
					float bfov = 2f * Mathf.Atan(bodyH * 0.325f / bdist) * Mathf.Rad2Deg;
					if (bfov < 6f) bfov = 6f;
					if (bfov > 60f) bfov = 60f;
					if (_dbgCam == null)
					{
						var goc = new GameObject("OfflineDbgCam");
						_dbgCam = goc.AddComponent<Camera>();
					}
					_dbgCam.transform.position = main.transform.position;
					_dbgCam.transform.rotation = Quaternion.LookRotation(chest - main.transform.position, Vector3.up);
					_dbgCam.clearFlags = CameraClearFlags.SolidColor;
					_dbgCam.backgroundColor = new Color(0.1f, 0.1f, 0.2f);
					RenderCamToFile(_dbgCam, -1,
						System.IO.Path.Combine(dir, "dbg_bot" + bp.entityId.Value + "_" + _dbgCamN + ".png"),
						400, 300, bfov, Mathf.Max(0.05f, bodyH * 0.05f), bdist + bodyH * 10f);
					n++;
				}
			}
			catch (System.Exception) { }
		}

	// [OFFLINE-CAMDIAG] 渲染前瞬间采样：此时 HidePlayerSystem(IPreRenderSystem) 已执行完，
	// 记录 bot RootContainer 的真实 active 状态 + 首个身体 Renderer 的 enabled/isVisible。
	private static void OnCamPreSample(Camera c)
	{
		try
		{
			if (c == null || c.name != "Eye") return;
			string s = "";
			foreach (PlayerEntity bp2 in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
			{
				if (!bp2.hasThirdPersonUnityObjects) continue;
				var tp2 = bp2.thirdPersonUnityObjects.ThirdTran;
				if (tp2 == null || tp2.RootContainer == null) continue;
				GameObject rc2 = tp2.RootContainer;
				Renderer body2 = null;
				Renderer[] rs2 = rc2.GetComponentsInChildren<Renderer>(true);
				for (int i2 = 0; i2 < rs2.Length; i2++)
				{
					if (rs2[i2] == null || !rs2[i2].enabled || !rs2[i2].gameObject.activeInHierarchy) continue;
					float sy2 = rs2[i2].bounds.size.y;
					if (sy2 <= 50f || sy2 >= 3000f) continue;
					body2 = rs2[i2];
					break;
				}
				float d2 = (rc2.transform.position - c.transform.position).magnitude;
				// [OFFLINE-SCREENDIAG] layer 是否被主相机剔除 + 屏幕位置 + 像素高度。
				int blayer = rc2.layer;
				bool maskIn = (c.cullingMask & (1 << blayer)) != 0;
				Vector3 chest3 = (body2 != null) ? body2.bounds.center : (rc2.transform.position + new Vector3(0f, 100f, 0f));
				Vector3 sp3 = c.WorldToScreenPoint(chest3);
				bool onScr = sp3.z > 0f && sp3.x >= 0f && sp3.x <= c.pixelWidth && sp3.y >= 0f && sp3.y <= c.pixelHeight;
				float pxH = 0f;
				if (d2 > 1f)
				{
					float bodyH3 = (body2 != null) ? body2.bounds.size.y : 200f;
					pxH = 1080f * bodyH3 / (2f * d2 * Mathf.Tan(c.fieldOfView * 0.5f * Mathf.Deg2Rad));
				}
				s += " #" + bp2.entityId.Value + "(act=" + rc2.activeInHierarchy
					+ " d=" + d2.ToString("F0")
					+ " far=" + c.farClipPlane.ToString("F0")
					+ " inFar=" + (d2 <= c.farClipPlane)
					+ " body=" + ((body2 == null) ? "none" : (body2.enabled + "/" + body2.isVisible))
					+ " layer=" + blayer + "/" + (maskIn ? "Y" : "N")
					+ " scr=" + (onScr ? "Y" : "N") + "@" + sp3.x.ToString("F0") + "," + sp3.y.ToString("F0")
					+ " px=" + pxH.ToString("F0")
					+ ")";
			}
			_preSnap = s;
		}
		catch (System.Exception) { }
	}

	private void UpdateDbgCam()

	{

		if (UnityEngine.Time.realtimeSinceStartup - _dbgCamT < 2.5f) return;

		_dbgCamT = UnityEngine.Time.realtimeSinceStartup;

		try

		{

			Camera main = null;

			var wc = Contexts.sharedInstance.worldCamera;

			if (wc.hasUnityObjects && wc.unityObjects.mainCamera != null)

				main = wc.unityObjects.mainCamera;

			if (main == null) main = Camera.main;

			if (main == null) return;



			string dir = @"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-logs\dbgcam";

			System.IO.Directory.CreateDirectory(dir);

			int w = 640, h = 400;



			RenderCamToFile(main, main.cullingMask, System.IO.Path.Combine(dir, "dbg_main_" + _dbgCamN + ".png"), w, h, main.fieldOfView, main.nearClipPlane, main.farClipPlane);



			if (_dbgCam == null)

			{

				var go = new GameObject("OfflineDbgCam");

				_dbgCam = go.AddComponent<Camera>();

			}

			_dbgCam.transform.position = main.transform.position;

			_dbgCam.transform.rotation = main.transform.rotation;

			_dbgCam.clearFlags = CameraClearFlags.SolidColor;

			_dbgCam.backgroundColor = new Color(0.1f, 0.1f, 0.2f);

			RenderCamToFile(_dbgCam, -1, System.IO.Path.Combine(dir, "dbg_all_" + _dbgCamN + ".png"), w, h, main.fieldOfView, main.nearClipPlane, main.farClipPlane);

			// [OFFLINE-BOTCAM] 每个 bot 的熟准特写
			RenderBotCloseups(main, dir);



			_dbgCamN++;

		}

		catch (System.Exception ex)

		{

			if (_dbgCamN < 3) UnityEngine.Debug.Log("[OFFLINE-DBGCAM] fail " + ex.Message);

		}

	}



	private static void RenderCamToFile(Camera cam, int mask, string path, int w, int h, float fov, float nearC, float farC)

	{

		RenderTexture rt = RenderTexture.GetTemporary(w, h, 24);

		int oldMask = cam.cullingMask;

		float oldFov = cam.fieldOfView;

		float oldNear = cam.nearClipPlane;

		float oldFar = cam.farClipPlane;

		RenderTexture oldRt = cam.targetTexture;

		cam.cullingMask = mask;

		cam.fieldOfView = fov;

		cam.nearClipPlane = nearC;

		cam.farClipPlane = farC;

		cam.targetTexture = rt;

		cam.Render();

		RenderTexture.active = rt;

		Texture2D tex = new Texture2D(w, h, TextureFormat.RGB24, false);

		tex.ReadPixels(new Rect(0f, 0f, w, h), 0, 0);

		tex.Apply();

		System.IO.File.WriteAllBytes(path, tex.EncodeToPNG());

		UnityEngine.Object.Destroy(tex);

		RenderTexture.active = null;

		cam.targetTexture = oldRt;

		cam.cullingMask = oldMask;

		cam.fieldOfView = oldFov;

		cam.nearClipPlane = oldNear;

		cam.farClipPlane = oldFar;

		RenderTexture.ReleaseTemporary(rt);

	}



	private void Update()



	{



		InputCollector.Instance.Collect(Time.deltaTime);

		// [OFFLINE-QUIET] onPreRender 每帧 5 个 bot GetComponentsInChildren，吃 GC；数据已采完，停用。
		// if (!_preHooked) { _preHooked = true; Camera.onPreRender += OnCamPreSample; }
		// [OFFLINE-PERF] debug 相机每 2.5s 渲染 8 张 PNG（RenderTexture+ReadPixels 强制
		// GPU 同步）会造成周期性卡顿，默认关闭；需要取证时把下面一行改回 UpdateDbgCam();
		// UpdateDbgCam();



		if (isOffline)

		{

			WarmupBagWeaponAnims();

			HandleOfflineHotkeys();

			// [OFFLINE-PATCH] 帧率解锁必须在 GameSetting.Apply 之后持续生效。

			// launch_config.json 可加 "fps": N 覆盖（默认 150，同原版 NetRecordManager）。

			if (Application.targetFrameRate != OfflineFrameLimit)

			{

				Application.targetFrameRate = OfflineFrameLimit;

				QualitySettings.vSyncCount = 0;

			}



			// 背包面板是模态 UI：清空本帧输入，避免点面板时武器开火/角色移动。

			if (IsBagPanelOpen()) InputCollector.Instance.Reset();

		}



		if (_systems != null)



		{



			try



			{



				((Systems)_systems).Execute();



				InputCollector.Instance.Reset();



			}



			catch (Exception ex)



			{



				GlobalLogger.LogErrorFormat<OfflineGameController, Exception>(this, "Error: {0}", ex);



			}



		}



		if (isOffline && Contexts.sharedInstance.player.myPlayerEntity != null)

		{

			Contexts.sharedInstance.battleRoom.roomData.IsObserver = false;

			PlayerEntity localPlayer = Contexts.sharedInstance.player.myPlayerEntity;

			if (localPlayer.isDontLoadThirdPerson) localPlayer.isDontLoadThirdPerson = false;

			foreach (PlayerEntity ownerCandidate in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))

			{

				bool wantOwner = (ownerCandidate == localPlayer);

				if (ownerCandidate.isCameraOwner != wantOwner)

				{

					ownerCandidate.isCameraOwner = wantOwner;

				}

			}

		}



		// [OFFLINE-PATCH] 关键：把物理体(PyPlayerMove)的真实位置同步回 basicInfo。

		//

		// 原问题：出生点只写了一次 basicInfo + SetPosition，之后没有任何东西把

		// PyPlayerMove 的结果写回 basicInfo（在线模式靠服务器快照下发，离线没有）。

		// 结果 basicInfo 永远冻结在出生点，而物理体在自由落体，相机读 fpos.Change

		// 于是一路下坠 —— 日志里 cam.y 从 1720 掉到 -158211，画面全灰。

		//

		// 另外，离线没有服务器纠正，物理体一旦掉出世界包围盒就再也回不来，

		// 所以加一个"掉出包围盒就拉回出生点"的兜底。

		if (isOffline && Contexts.sharedInstance.player.myPlayerEntity != null && Contexts.sharedInstance.battleRoom.hasPyEngine)

		{

			SyncOfflinePhysicsPosition();

		}



		// [OFFLINE-PATCH] 腿部动画状态合成（第三人称动画）

		if (isOffline)

		{

			SyncOfflineAnimStates();

			SyncOfflineViewLocomotion();

			SyncFirstPersonVisibility();

		}

		_dbgTimer += Time.deltaTime;



		ApplyOfflineSkin();
		if (_dbgTimer >= 5.0f)  // [OFFLINE-QUIET] 0.35s→5s：高频诊断本身造成卡顿  // [OFFLINE-DIAG] 临时高频，验证动画

		// [OFFLINE-SKIN] 皮肤落地：本地玩家实体创建后再写入。




		{



			_dbgTimer = 0f;



			Camera cam = UnityEngine.Object.FindObjectOfType<Camera>();



			PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;



			string camText = (cam != null) ? (cam.transform.position.ToString("F2") + " rot=" + cam.transform.eulerAngles.ToString("F1") + " far=" + cam.farClipPlane) : "null";
			// [OFFLINE-CAMDIAG] 相机清单：验证 mainCamera 指向哪个相机、真实渲染相机的裁剪面。
			try
			{
				Camera[] allCams = Camera.allCameras;
				string cl = "";
				for (int ci2 = 0; ci2 < allCams.Length && ci2 < 8; ci2++)
				{
					Camera c2 = allCams[ci2];
					if (c2 == null) continue;
					cl += " [" + c2.name + " far=" + c2.farClipPlane.ToString("F0")
						+ " near=" + c2.nearClipPlane.ToString("F2")
						+ " fov=" + c2.fieldOfView.ToString("F0")
						+ " mask=" + c2.cullingMask
						+ " d=" + c2.depth.ToString("F0")
						+ " en=" + c2.enabled + "]";
				}
				camText += " camlist=" + cl;
				var wcu = Contexts.sharedInstance.worldCamera;
				if (wcu.hasUnityObjects && wcu.unityObjects.mainCamera != null)
					camText += " wcMain=" + wcu.unityObjects.mainCamera.name;
				Camera eyeCam = null;
				for (int ci3 = 0; ci3 < allCams.Length; ci3++)
				{
					if (allCams[ci3] != null && allCams[ci3].name == "Eye") { eyeCam = allCams[ci3]; break; }
				}
				if (eyeCam != null)
					camText += " eye=" + eyeCam.farClipPlane.ToString("F0") + "/" + eyeCam.nearClipPlane.ToString("F2") + " fov" + eyeCam.fieldOfView.ToString("F0");
				else
					camText += " eye=none";
			}
			catch (System.Exception cex) { camText += " camlistEX=" + cex.GetType().Name; }
			camText += " pre=" + _preSnap;
			// [OFFLINE-MATDIAG] 全局光照实况：SSJJ/Diffuse 无光照属性，
			// 若环境光/太阳光为黑且 shader 走顶点光照，角色模型会整体发黑而地形（lightmap）正常。
			camText += " amb=" + UnityEngine.RenderSettings.ambientLight.ToString("F2")
				+ " ambMode=" + ((int)UnityEngine.RenderSettings.ambientMode).ToString()
				+ " sun=" + ((UnityEngine.RenderSettings.sun == null) ? "null" : (UnityEngine.RenderSettings.sun.color.ToString("F2") + "@" + UnityEngine.RenderSettings.sun.intensity.ToString("F2")));



			string meText = "null";



			if (me != null && me.hasBasicInfo)



			{



				meText = "X=" + me.basicInfo.Current.X + " Y=" + me.basicInfo.Current.Y + " Z=" + me.basicInfo.Current.Z;



			}



			string engText = "none";



			string tpText = "tp=none";



			if (me != null && me.hasThirdPersonUnityObjects)



			{



				var tpo = me.thirdPersonUnityObjects;



				int skins = (tpo.CareerSkins != null) ? tpo.CareerSkins.Count : -1;



				string first = "null";



				if (skins > 0 && tpo.CareerSkins[0] != null)



				{



					first = "active=" + tpo.CareerSkins[0].gameObject.activeInHierarchy + " size=" + tpo.CareerSkins[0].bounds.size;



				}



				tpText = "tp skins=" + skins + " anim=" + (tpo.Animator != null) + " " + first;

				// [OFFLINE-DIAG] animator 里实际加载的动画名（排查第三人称无动画）

				try

				{

					var anims = tpo.Animator.GetAnimations();

					int ac = (anims == null) ? -1 : anims.Count;

					string names = "";

					if (anims != null)

					{

						int n = 0;

						foreach (string an in anims)

						{

							if (n++ >= 10) break;

							names += an + ",";

						}

					}

					tpText += " animCount=" + ac + " [" + names + "]";



				// [OFFLINE-DIAG] bot 逐实体状态（定位"队友建模闪一下消失"）

				try

				{

					string botText = " bots:";

					foreach (PlayerEntity bp in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))

					{

						if (bp.entityId.Value < 200)
						{
							if (s_visDiagIds.Add(bp.entityId.Value) && s_visDiagIds.Count <= 12)
							{
								string selfTp = " tp=" + bp.hasThirdPersonUnityObjects;
								try
								{
									if (bp.hasThirdPersonUnityObjects && bp.thirdPersonUnityObjects.ThirdTran != null
										&& bp.thirdPersonUnityObjects.ThirdTran.RootContainer != null)
									{
										Transform src = bp.thirdPersonUnityObjects.ThirdTran.RootContainer.transform;
										Renderer[] srs = src.GetComponentsInChildren<Renderer>(true);
										int sbody = 0, smeshNull = 0, svis = 0;
										string sdetail = "";
										for (int si = 0; si < srs.Length; si++)
										{
											Renderer rr = srs[si];
											if (rr == null) continue;
											if (rr.isVisible) svis++;
											if (rr.bounds.size.y > 50f) sbody++;
											UnityEngine.Mesh m = null;
											SkinnedMeshRenderer sr = rr as SkinnedMeshRenderer;
											if (sr != null) m = sr.sharedMesh;
											else { MeshFilter mf = rr.GetComponent<MeshFilter>(); if (mf != null) m = mf.sharedMesh; }
											if (m == null) smeshNull++;
											if (sdetail == "" && rr.bounds.size.y > 50f)
												sdetail = " bodyRev=" + rr.GetType().Name + " en=" + rr.enabled
													+ " vis=" + rr.isVisible + " L=" + rr.gameObject.layer
													+ " mesh=" + (m == null ? "NULL" : (m.name + "/v" + m.vertexCount))
													+ " mat=" + ((rr.sharedMaterial == null || rr.sharedMaterial.shader == null) ? "NULL" : rr.sharedMaterial.shader.name)
													+ " colA=" + ((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_Color")) ? "-" : rr.sharedMaterial.GetColor("_Color").a.ToString("F2"))
													+ " aProp=" + ((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_Alpha")) ? "-" : rr.sharedMaterial.GetFloat("_Alpha").ToString("F2"))
													+ " zw=" + ((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_ZWrite")) ? "-" : rr.sharedMaterial.GetFloat("_ZWrite").ToString("F0"))
													+ " rq=" + (rr.sharedMaterial == null ? -1 : rr.sharedMaterial.renderQueue)
													+ " bc=" + rr.bounds.center.ToString("F0") + " sz=" + rr.bounds.size.ToString("F0")
													+ ((sr != null) ? (" bones=" + (sr.bones == null ? -1 : sr.bones.Length) + " root=" + (sr.rootBone == null ? "null" : sr.rootBone.name)) : "");
										}
										selfTp = " tp=True rootAct=" + src.gameObject.activeSelf + " total=" + srs.Length
											+ " body=" + sbody + " meshNull=" + smeshNull + " vis=" + svis + sdetail;
									}
								}
								catch (System.Exception exs) { selfTp += " selfDiagEx=" + exs.GetType().Name; }
								UnityEngine.Debug.Log("[OFFLINE-VISDIAG2] SELF id=" + bp.entityId.Value
									+ " alpha=" + bp.basicInfo.Current.Alpha
									+ " selfA=" + bp.basicInfo.Current.SelfAlpha
									+ " hasSkill=" + bp.hasSkill
									+ " stealth=" + (bp.hasSkill ? bp.skill.getStealthAlpha().ToString("F2") : "-")
									+ selfTp);
							}
							continue;
						}

						bool hasTp = bp.hasThirdPersonUnityObjects;

						// [OFFLINE-BOT] 只给队友挂小名牌（敌队不显示名字），样式按原版蓝字、近距可见。
						// [OFFLINE-AI6] 大头人机(2019) 按原版 BigHeadGameRule.IsShowEnemyHpBar 对敌人显示血条（不显示名字）。
						try
						{
							if (hasTp && bp.hasBasicInfo && bp.basicInfo.Current != null
								&& bp.thirdPersonUnityObjects.ThirdTran != null
								&& bp.thirdPersonUnityObjects.ThirdTran.RootContainer != null)
							{
								PlayerEntityData meHud = Contexts.sharedInstance.player.myPlayerEntity != null
									&& Contexts.sharedInstance.player.myPlayerEntity.hasBasicInfo
									? Contexts.sharedInstance.player.myPlayerEntity.basicInfo.Current : null;
								bool ally = meHud != null && bp.basicInfo.Current.Team == meHud.Team
									&& !bp.basicInfo.Current.IsDead && bp.basicInfo.Current.Hp > 0f;
								int rtHud = (setting != null) ? setting.RaceType : 3;
								OfflineModeTable.Profile profHud = OfflineModeTable.Get(rtHud);
								bool enemyHpBar = profHud != null && profHud.ShowEnemyHpBar
									&& !bp.basicInfo.Current.IsDead && bp.basicInfo.Current.Hp > 0f;
								GameObject broot = bp.thirdPersonUnityObjects.ThirdTran.RootContainer;
								// [OFFLINE-FIX] 只有队友挂名牌；敌人一律不挂（否则等于自带透视）。
								// 旧实现 localPosition.y = 200（Unity 单位=米）挂在 200 米高空，所以从来没见过名字。
								// 位置交给 OfflineBotNameTag 每帧按父级 Renderer 包围盒顶部自适应，不再写死。
								OfflineBotNameTag tag = broot.GetComponentInChildren<OfflineBotNameTag>(true);
								if (!ally && !enemyHpBar)
								{
									if (tag != null) tag.gameObject.SetActive(false);
								}
								else
								{
									bool botAlive = !bp.basicInfo.Current.IsDead && bp.basicInfo.Current.Hp > 0f;
									if (tag == null)
									{
										GameObject tagObject = new GameObject("OfflineBotNameTag");
										tagObject.transform.SetParent(broot.transform, false);
										tag = tagObject.AddComponent<OfflineBotNameTag>();
									}
									tag.gameObject.SetActive(true);
									tag.SetAlly(ally);
									// [OFFLINE-AI6] botQuality/Lv：精英橙、首领红；敌人只挂血条不挂名
									int qHud = 0, lvHud = 1;
									Assets.Sources.Systems.Snapshot.OfflineBotSpawner.BotMeta metaHud;
									if (Assets.Sources.Systems.Snapshot.OfflineBotSpawner.Meta.TryGetValue(bp.entityId.Value, out metaHud))
									{
										qHud = metaHud.Quality;
										lvHud = metaHud.Lv;
									}
									tag.SetBotInfo(bp.entityId.Value, qHud, lvHud, true);
									if (!ally)
									{
										tag.Label = "";   // 敌人不显示名字（防透视）
									}
									else if (!botAlive)
									{
										tag.Label = "";
									}
									else
									{
										string qPrefix = qHud >= 3 ? "[首领]" : (qHud >= 1 ? "[精英]" : "");
										tag.Label = qPrefix + Assets.Sources.Systems.Snapshot.OfflineBotSpawner.GetBotName(bp.entityId.Value);
									}
								}
							}
						}
						catch (System.Exception) { }

						bool rootAct = false;

						int rend = -1;

						if (hasTp && bp.thirdPersonUnityObjects.ThirdTran != null && bp.thirdPersonUnityObjects.ThirdTran.RootContainer != null)

						{

							rootAct = SSJJObjectExtensions.IsActiveSelf(bp.thirdPersonUnityObjects.ThirdTran.RootContainer);

							rend = bp.thirdPersonUnityObjects.ThirdTran.RootContainer.GetComponentsInChildren<Renderer>(true).Length;

						}

						botText += " #" + bp.entityId.Value

							+ "(flag=" + (bp.hasState ? bp.state.StateFlag : -1)

							+ ",hide=" + (bp.hasState ? bp.state.GetPlayerStateType(131072) : false)

							+ ",isHide=" + bp.isHide

							+ ",dead=" + bp.basicInfo.IsDead

							+ ",tp=" + hasTp

							+ ",act=" + rootAct

							+ ",r=" + rend

							+ ",leg=" + bp.basicInfo.Current.LegsAnim

							+ ",t=" + (bp.hasLegAnim ? bp.legAnim.ScaledEclipsedTime : -1);

						if (hasTp && rootAct)

						{

							Transform rc = bp.thirdPersonUnityObjects.ThirdTran.RootContainer.transform;

							botText += ",pos=" + rc.position.ToString("F1")

								+ ",scl=" + rc.lossyScale.ToString("F2")

								+ ",dist=" + (rc.position - cam.transform.position).magnitude.ToString("F0");

							Renderer[] brs = rc.GetComponentsInChildren<Renderer>(true);

							// [OFFLINE-VISDIAG] 模型"看不见"三连查：isVisible=任何相机本帧是否真的渲染它
							// （false = 被剔除：错误 bounds / 层剔除 / 相机裁剪）；bc=bounds 世界中心
							// （与 rc.position 不一致 = 网格挂在错误位置）；uwo=updateWhenOffscreen。
							int visCount = 0; string firstBody = "";
							for (int bi = 0; bi < brs.Length; bi++)
							{
								if (brs[bi] == null) continue;
								if (brs[bi].isVisible) visCount++;
								if (firstBody == "" && brs[bi].enabled && brs[bi].gameObject.activeInHierarchy
									&& brs[bi].bounds.size.y > 50f)
									firstBody = " body=" + brs[bi].name
										+ " vis=" + brs[bi].isVisible
										+ " bc=" + brs[bi].bounds.center.ToString("F0")
										+ " uwo=" + ((brs[bi] is SkinnedMeshRenderer) ? ((SkinnedMeshRenderer)brs[bi]).updateWhenOffscreen.ToString() : "-")
										+ " shader=" + ((brs[bi].sharedMaterial == null || brs[bi].sharedMaterial.shader == null) ? "NULL" : brs[bi].sharedMaterial.shader.name);
							}
							botText += " vis=" + visCount + "/" + brs.Length + firstBody;

							// [OFFLINE-VISDIAG2] 一次性完整清单：模型是否真的可渲染
							// （active / layer 是否被相机 mask 剔除 / sharedMesh 是否为空 / 材质 shader 是否为空）
							if (s_visDiagIds.Add(bp.entityId.Value) && s_visDiagIds.Count <= 12)
							{
								try
								{
									System.Text.StringBuilder sb = new System.Text.StringBuilder();
									sb.Append("[OFFLINE-VISDIAG2] id=").Append(bp.entityId.Value)
										.Append(" rootActive=").Append(rc.gameObject.activeSelf)
										.Append(" rootLayer=").Append(rc.gameObject.layer)
										.Append(" rootPos=").Append(rc.position.ToString("F1"))
										.Append(" camName=").Append(cam.name)
										.Append(" camMask=").Append(cam.cullingMask)
										.Append(" camPos=").Append(cam.transform.position.ToString("F1"))
										.Append(" cams=");
									Camera[] camsAll = Camera.allCameras;
									Camera eyeCam = null;
									for (int ci = 0; ci < camsAll.Length && ci < 6; ci++)
									{
										Camera cc = camsAll[ci];
										if (cc == null) continue;
										if (eyeCam == null && cc.name == "Eye") eyeCam = cc;
										sb.Append('[').Append(cc.name).Append(" d=").Append(cc.depth)
											.Append(" m=").Append(cc.cullingMask)
											.Append(" hasL0=").Append((cc.cullingMask & 1) != 0).Append("] ");
									}
									// [OFFLINE-VISDIAG3] 投影到玩家真正的视图相机：判断"不在画面"还是"在画面但不渲染"
									if (eyeCam != null)
									{
										Vector3 wp = rc.position + Vector3.up * 100f;
										Vector3 scr = eyeCam.WorldToScreenPoint(wp);
										bool on = scr.z > 0f && scr.x >= 0f && scr.x <= eyeCam.pixelWidth && scr.y >= 0f && scr.y <= eyeCam.pixelHeight;
										sb.Append(" eyeScr=").Append(scr.ToString("F0")).Append(" onScreen=").Append(on)
											.Append(" eyeFwdDot=").Append(Vector3.Dot(eyeCam.transform.forward, (wp - eyeCam.transform.position).normalized).ToString("F2"));
									}
									int bodyN = 0, bodyEn = 0, meshNullN = 0, shown = 0;
									Renderer[] all3 = rc.GetComponentsInChildren<Renderer>(true);
									for (int ri = 0; ri < all3.Length; ri++)
									{
										Renderer rr = all3[ri];
										if (rr == null) continue;
										bool big = rr.bounds.size.y > 50f;
										if (big) bodyN++;
										if (big && rr.enabled && rr.gameObject.activeInHierarchy) bodyEn++;
										UnityEngine.Mesh mesh = null;
										SkinnedMeshRenderer sr = rr as SkinnedMeshRenderer;
										if (sr != null) mesh = sr.sharedMesh;
										else { MeshFilter mf = rr.GetComponent<MeshFilter>(); if (mf != null) mesh = mf.sharedMesh; }
										if (mesh == null) meshNullN++;
										if (shown < 6 && big)
										{
											shown++;
											sb.Append(" | ").Append(rr.name)
												.Append(" en=").Append(rr.enabled)
												.Append(" act=").Append(rr.gameObject.activeInHierarchy)
												.Append(" L=").Append(rr.gameObject.layer)
												.Append(" maskHit=").Append((cam.cullingMask & (1 << rr.gameObject.layer)) != 0)
												.Append(" vis=").Append(rr.isVisible)
												.Append(" bc=").Append(rr.bounds.center.ToString("F0"))
												.Append(" sz=").Append(rr.bounds.size.ToString("F0"))
												.Append(" mesh=").Append(mesh == null ? "NULL" : (mesh.name + "/v" + mesh.vertexCount))
												.Append(" mat=").Append((rr.sharedMaterial == null || rr.sharedMaterial.shader == null) ? "NULL" : rr.sharedMaterial.shader.name)
												.Append(" bones=").Append(sr == null ? "-" : ((sr.bones == null) ? "-1" : sr.bones.Length.ToString()))
												.Append(" root=").Append(sr == null ? "-" : (sr.rootBone == null ? "null" : sr.rootBone.name))
												.Append(" colA=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_Color")) ? "-" : rr.sharedMaterial.GetColor("_Color").a.ToString("F2"))
												.Append(" aProp=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_Alpha")) ? "-" : rr.sharedMaterial.GetFloat("_Alpha").ToString("F2"))
												.Append(" cull=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_Cull")) ? "-" : rr.sharedMaterial.GetFloat("_Cull").ToString("F0"))
												.Append(" cullA=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_CullAlpha")) ? "-" : (rr.sharedMaterial.GetFloat("_CullAlphaEnable").ToString("F0") + "/" + rr.sharedMaterial.GetFloat("_CullAlpha").ToString("F2")))
												.Append(" zw=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_ZWrite")) ? "-" : rr.sharedMaterial.GetFloat("_ZWrite").ToString("F0"))
												.Append(" rq=").Append(rr.sharedMaterial == null ? -1 : rr.sharedMaterial.renderQueue)
												.Append(" sb=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_SrcBlend")) ? "-" : rr.sharedMaterial.GetFloat("_SrcBlend").ToString("F0"))
												.Append(" db=").Append((rr.sharedMaterial == null || !rr.sharedMaterial.HasProperty("_DstBlend")) ? "-" : rr.sharedMaterial.GetFloat("_DstBlend").ToString("F0"))
												.Append(" tex=").Append((rr.sharedMaterial == null || rr.sharedMaterial.mainTexture == null) ? "NULL" : rr.sharedMaterial.mainTexture.name)
												.Append(" vcolA=").Append((mesh == null || mesh.colors32 == null || mesh.colors32.Length == 0) ? "-" : mesh.colors32[0].a.ToString())
												.Append(" mpbA=").Append(VisDiagMpbAlpha(rr))
												.Append(" bp=").Append((mesh == null) ? "-" : mesh.bindposes.Length.ToString())
												.Append(" lb=").Append(sr == null ? "-" : sr.localBounds.center.ToString("F0") + "/" + sr.localBounds.size.ToString("F0"))
												.Append(" boneRoot=").Append((sr == null || sr.rootBone == null) ? "-" : sr.rootBone.position.ToString("F0"))
												.Append(" bake=").Append(VisDiagBakeSkinned(sr));
										}
									}
									sb.Append(" total=").Append(all3.Length).Append(" body=").Append(bodyN)
										.Append(" bodyEnabled=").Append(bodyEn).Append(" meshNull=").Append(meshNullN)
										.Append(" alpha=").Append(bp.basicInfo.Current.Alpha)
										.Append(" selfA=").Append(bp.basicInfo.Current.SelfAlpha)
										.Append(" hasSkill=").Append(bp.hasSkill)
										.Append(" hasState=").Append(bp.hasState)
										.Append(" stealth=").Append(bp.hasSkill ? bp.skill.getStealthAlpha().ToString("F2") : "-");
									UnityEngine.Debug.Log(sb.ToString());
								}
								catch (System.Exception ex) { UnityEngine.Debug.LogWarning("[OFFLINE-VISDIAG2] failed: " + ex.Message); }
							}

						// [OFFLINE-ROOTDIAG] SJAnimator 根骨骼位移诊断：
						// SJAnimationPlayer.GenerateBones 把模型根 Transform 也注册成骨骼，
						// ApplyKeyFrame 每帧写 bone.localPosition=片段曲线值。若跑步/行走片段
						// 的根曲线非零，会在 DirectStep 之后把整个模型搬走（移动时消失的根因）。
						// sjlp=SJAnimator 自身 transform.localPosition（应为 0,0,0 附近）；
						// skel=直接子骨骼（骨架根，如 Bip01）的局部位置——非零且随移动变化 =
						// 该骨骼被片段曲线写歪。disp=所有 |localPosition|>5 的骨骼抽样。
						try
						{
							var sja = rc.GetComponentInChildren<SSJJAnim.Animator.SJAnimator>(true);
							if (sja != null)
							{
								botText += " sjlp=" + sja.transform.localPosition.ToString("F1");
								string skel = "";
								for (int ci = 0; ci < sja.transform.childCount && ci < 3; ci++)
								{
									Transform ch = sja.transform.GetChild(ci);
									if (ch == null) continue;
									skel += " " + ch.name + "@" + ch.localPosition.ToString("F0");
								}
								botText += " skel=" + skel;
								string disp = "";
								int dispN = 0;
								var bones = sja.GetBones();
								if (bones != null)
								{
									foreach (var kv2 in bones)
									{
										if (kv2.Value == null || kv2.Value == sja.transform) continue;
										if (kv2.Value.localPosition.sqrMagnitude > 25f && dispN < 3)
										{
											disp += " " + kv2.Value.name + "@" + kv2.Value.localPosition.ToString("F0");
											dispN++;
										}
									}
								}
								botText += (dispN > 0) ? (" disp=" + disp) : " disp=none";
							}
							else
							{
								botText += " sja=none";
							}
						}
						catch (System.Exception) { }

					// [OFFLINE-MATDIAG] "模型很黑"诊断：运行时材质实况。
					// 静态 bundle 侧已核实 _MainTex=REF、_Color=白；运行时 mt=NULL 即
					// 外部引用解析失败（tex2D(null)→黑）；col 非白即 tint 被改黑。
					try
					{
						// [OFFLINE-BODYFIX] 同 RenderBotCloseups：防幻影网格误选
						Renderer bodyR = null;
						float bestDR = float.MaxValue;
						for (int rri = 0; rri < brs.Length; rri++)
						{
							if (brs[rri] == null || !brs[rri].enabled || !brs[rri].gameObject.activeInHierarchy) continue;
							float sy = brs[rri].bounds.size.y;
							if (sy <= 50f || sy >= 3000f) continue;
							float d = (brs[rri].bounds.center - rc.position).sqrMagnitude;
							if (d < bestDR) { bestDR = d; bodyR = brs[rri]; }
						}
						if (bodyR == null)
						{
							botText += " matdiag=nobody";
						}
						else
						{
							Material bm = bodyR.sharedMaterial;
							if (bm == null)
							{
								botText += " matdiag=matnull";
							}
							else
							{
								string mt = "NULL";
								try
								{
									Texture mtt = bm.mainTexture;
									if (mtt != null) mt = mtt.name;
								}
								catch (System.Exception) { }
								string bcol = "-";
								try { bcol = bm.color.ToString("F2"); }
								catch (System.Exception) { }
								string bwcol = "-";
								try
								{
									if (bm.HasProperty("_WeaponColor")) bwcol = bm.GetColor("_WeaponColor").ToString("F2");
								}
								catch (System.Exception) { }
								int bkw = -1;
								try { bkw = bm.shaderKeywords.Length; }
								catch (System.Exception) { }
								int bpass = -1;
								try { bpass = bm.passCount; }
								catch (System.Exception) { }
								botText += " matdiag=" + bm.name
									+ " mt=" + mt
									+ " col=" + bcol
									+ " wcol=" + bwcol
									+ " kw=" + bkw
									+ " pass=" + bpass
									+ " lmi=" + bodyR.lightmapIndex
									+ " lpu=" + ((int)bodyR.lightProbeUsage).ToString();
							}
						}
					}
					catch (System.Exception) { }

														for (int bi = 0; bi < brs.Length && bi < 4; bi++)

							{

								SkinnedMeshRenderer bsm = brs[bi] as SkinnedMeshRenderer;

								botText += " [" + brs[bi].name

									+ " en=" + brs[bi].enabled

									+ " act=" + brs[bi].gameObject.activeInHierarchy

									+ " mesh=" + ((bsm != null) ? ((bsm.sharedMesh == null) ? "NULL" : bsm.sharedMesh.name) : ((brs[bi] as MeshRenderer) != null ? "mr" : "?"))

									+ " sz=" + brs[bi].bounds.size.ToString("F1")

									+ " mat=" + ((brs[bi].sharedMaterial == null) ? "null" : brs[bi].sharedMaterial.name)

									+ "]";

							}

						}

						botText += ")";

					}

					tpText += botText;

				}

				catch (System.Exception bex)

				{

					tpText += " bots EX " + bex.GetType().Name;

				}

				// [OFFLINE-DIAG] 动画时间链（PlayAtFixedTime 的采样时间）

				try

				{

					var tctx = Contexts.sharedInstance.time.time;

					// [OFFLINE-DIAG] 玩家 TP 骨骼局部偏移（相对模型根，排除移动干扰）

					try

					{

						Transform broot = (me.thirdPersonUnityObjects.ThirdTran != null)

							? me.thirdPersonUnityObjects.ThirdTran.RootContainer.transform : null;

						Transform thigh = me.thirdPersonUnityObjects.Animator.GetBone("Bip01_L_Thigh");

						Transform hand = me.thirdPersonUnityObjects.Animator.GetBone("Bip01_R_Hand");

						if (broot != null && thigh != null && hand != null)

						{

							Vector3 tLocal = broot.InverseTransformPoint(thigh.position);

							Vector3 hLocal = broot.InverseTransformPoint(hand.position);

							tpText += " boneL[thigh=" + tLocal.ToString("F2") + " hand=" + hLocal.ToString("F2") + "]";

						}

						else

						{

							tpText += " boneL[null root=" + (broot == null) + " thigh=" + (thigh == null) + " hand=" + (hand == null) + "]";

						}

					}

					catch (System.Exception bxe)

					{

						tpText += " boneL EX " + bxe.GetType().Name;

					}

					tpText += " animT legScaled=" + me.legAnim.ScaledEclipsedTime

						+ " legSpeedT=" + me.basicInfo.Current.LegsSpeedAnimTime

						+ " snapSrvT=" + me.basicInfo.SnapsotServerTime

						+ " renderT=" + tctx.RenderTime

						+ " legState=" + me.basicInfo.Current.LegsAnim

						+ " vel=" + (me.hasMove ? me.move.Velocity2D.ToString("F0") : "-");

				}

				catch (System.Exception tex2)

				{

					tpText += " animT EX " + tex2.GetType().Name;

				}

				}

				catch (System.Exception aex)

				{

					tpText += " animList EX " + aex.GetType().Name;

				}

				try

				{

					var wc = Contexts.sharedInstance.worldCamera;

					int mode = wc.hasCameraMode ? (int)wc.cameraMode.Mode : -99;

					bool rootActive = (tpo.ThirdTran != null && tpo.ThirdTran.RootContainer != null)

						? SSJJObjectExtensions.IsActiveSelf(tpo.ThirdTran.RootContainer) : false;

					string clName = "null";

					try { var cl = wc.cameraLogic.CameraLogic; clName = (cl != null) ? cl.GetType().Name : "null"; } catch { }

					tpText += " cl=" + clName + " thirdMode=" + me.GetPlayerInfo().ThirdMode + " cur3=" + (me.basicInfo.Current != null && me.basicInfo.Current.IsThirdMode);

					try

					{

						var uo = wc.unityObjects;

						var ct = wc.cameraTransform;

						tpText += " ctPos=" + ct.position + " hasNodeEye=" + (uo.nodeEye != null)

							+ " nodeEyePos=" + ((uo.nodeEye != null) ? uo.nodeEye.transform.position.ToString("F0") : "-")

							+ " mainCam=" + ((uo.mainCamera != null) ? uo.mainCamera.transform.position.ToString("F0") : "-");

					}

					catch (System.Exception ux) { tpText += " ux=" + ux.GetType().Name; }

					tpText += " mode=" + mode + " 3pv=" + me.isThirdPersonView + " 1pv=" + me.isFirstPersonView

						+ " camOwner=" + me.isCameraOwner + " rootActive=" + rootActive

						+ " roleHidden=" + me.state.GetPlayerStateType(131072);

				}

				catch (System.Exception tpx) { tpText += " tpEX=" + tpx.GetType().Name; }



			}



			string flagsText = "flags none";

			if (me != null)

			{

				string cw = (me.hasCurrentWeapon) ? me.currentWeapon.Name : "noWeapon";

				string cr = (me.hasBasicInfo && me.basicInfo.CareerInfo != null) ? me.basicInfo.CareerInfo.Name : "noCareer";

				string wi = (me.hasCurrentWeapon && me.currentWeapon.WeaponInfo != null) ? me.currentWeapon.WeaponInfo.Name : "null";

				string pbn = (me.hasBasicInfo && me.basicInfo.CareerInfo != null) ? me.basicInfo.CareerInfo.PrefabBundleName : "null";

				flagsText = "dont=" + me.isDontLoadThirdPerson + " part=" + me.hasPartBasicInfo + " cw=" + cw + " wi=" + wi + " career=" + cr + " pbn=" + pbn;

				flagsText += " lres=" + me.hasLoadThirdPersonResource + " tres=" + me.hasThirdPersonResource;

				try

				{

					var pg = Contexts.sharedInstance.player.GetGroup(PlayerMatcher.AllOf(PlayerMatcher.BasicInfo));

					var g1 = Contexts.sharedInstance.player.GetGroup(

						PlayerMatcher.AllOf(new Entitas.IMatcher<PlayerEntity>[] { PlayerMatcher.BasicInfo })

						.NoneOf(new Entitas.IMatcher<PlayerEntity>[] {

							PlayerMatcher.DontLoadThirdPerson,

							PlayerMatcher.PartBasicInfo,

							PlayerMatcher.LoadThirdPersonResource,

							PlayerMatcher.ThirdPersonResource }));

					flagsText += " gAll=" + pg.count + " gLoad=" + g1.count;

				}

				catch (System.Exception gex) { flagsText += " gEX=" + gex.GetType().Name; }

			}

			string sysText = "";

			try

			{

				var feat = Assets.Sources.Framework.System.GameModuleFeature.Instance;

				if (feat == null) { sysText = " feat=null"; }

				else

				{

					var fi = feat.GetType().GetField("_playbackResourceLoadSystem", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

					object prls = (fi != null) ? fi.GetValue(feat) : null;

					if (prls == null) { sysText = " prls=null"; }

					else

					{

						var lst = prls.GetType().GetProperty("Systems").GetValue(prls, null) as System.Collections.Generic.List<Assets.Sources.Framework.IResourceLoadSystem>;

						sysText = " prlsCount=" + ((lst != null) ? lst.Count : -1);

						if (lst != null)

						{

							for (int si = 0; si < lst.Count; si++)

							{

								if (lst[si] == null) { sysText += " nullSys;"; continue; }

								sysText += " " + lst[si].GetType().Name + ";";

							}

						}

					}

				}

			}

			catch (System.Exception sex) { sysText = " sysEX=" + sex.GetType().Name + ":" + sex.Message; }

			sysText += " ||init||";

			try

			{

				var feat2 = Assets.Sources.Framework.System.GameModuleFeature.Instance;

				var t2 = feat2.GetType();

				foreach (string fn in new string[] { "_playbackResourceInitSystem", "_resourceLoadSystem", "_resourceInitSystem" })

				{

					var f2 = t2.GetField(fn, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

					object o2 = (f2 != null) ? f2.GetValue(feat2) : null;

					if (o2 == null) { sysText += fn + "=null;"; continue; }

					var l2 = o2.GetType().GetProperty("Systems").GetValue(o2, null) as System.Collections.IList;

					sysText += fn + "[" + ((l2 != null) ? l2.Count : -1) + "]:";

					if (l2 != null)

					{

						for (int si2 = 0; si2 < l2.Count; si2++)

						{

							if (l2[si2] == null) { sysText += "null,"; continue; }

							string n2 = l2[si2].GetType().Name;

							if (n2.Contains("Load")) sysText += n2 + ",";

						}

					}

					sysText += ";";

				}

			}

			catch (System.Exception e2) { sysText += " ex2=" + e2.GetType().Name; }

			flagsText += sysText;

			if (Contexts.sharedInstance.battleRoom.hasPyEngine)



			{



				engText = "min=" + Contexts.sharedInstance.battleRoom.pyEngine.Min + " max=" + Contexts.sharedInstance.battleRoom.pyEngine.Max;



			}



			string ownText = "owner=none";

			if (Contexts.sharedInstance.player.isCameraOwner)

			{

				PlayerEntity ce = Contexts.sharedInstance.player.cameraOwnerEntity;

				ownText = "ownerMe=" + (ce == me) + " obs=" + Contexts.sharedInstance.battleRoom.roomData.IsObserver + " ceId=" + ce.entityId.Value;

			}

			string physText = "phys=(" + _physLastX.ToString("F1") + "," + _physLastY.ToString("F1") + "," + _physLastZ.ToString("F1") + ") syncs=" + _physSyncCount + " resets=" + _physicsResets;

			UnityEngine.Debug.Log("[OFFLINE-DBG] cam=" + camText + " player=" + meText + " " + physText + " eng=" + engText + " " + ownText + " " + tpText + " " + flagsText);



		}



		if (isOffline && !_matLogged && Contexts.sharedInstance.battleRoom.hasPyEngine)

		{

			MeshRenderer[] mrs = UnityEngine.Object.FindObjectsOfType<MeshRenderer>();

			if (mrs.Length > 0)

			{

				_matLogged = true;

				string ms = "mrs=" + mrs.Length;

				for (int i = 0; i < mrs.Length && i < 8; i++)

				{

					Material mm = mrs[i].sharedMaterial;

					ms += " [" + mrs[i].name + ":" + (mm != null ? mm.name : "null") + " tex=" + (mm != null && mm.mainTexture != null ? mm.mainTexture.name : "null") + "]";

				}

				UnityEngine.Debug.Log("[OFFLINE-MAT] " + ms);

			}

		}

		// [OFFLINE-SPAWN] 不再强制等 hasPyEngine：部分地图引擎初始化晚于第一帧，
		// 旧条件会让出生块永远不执行，玩家停在 (0,0,0)（地图下面）。
		if (isOffline && !_spawnFixed)



		{
			// [OFFLINE-THRUST] 注入本图推进区（喷泉/跳台），原版由服务端 ThrustList 下发。
			try
			{
				OfflineThrustAreas.Apply(Contexts.sharedInstance.battleRoom.pyEngine.PyEngine, (setting != null) ? setting.SceneId : 1);
			}
			catch (System.Exception) { }




			PlayerEntity me2 = Contexts.sharedInstance.player.myPlayerEntity;



			if (me2 != null && me2.hasBasicInfo && me2.basicInfo.Current != null)



			{



				float spX = OFFLINE_SPAWN_X, spY = OFFLINE_SPAWN_Y, spZ = OFFLINE_SPAWN_Z, spYaw = OFFLINE_SPAWN_YAW;
				bool haveSpawn = TryPickValidatedSpawn(out spX, out spY, out spZ, out spYaw);
				if (!haveSpawn) haveSpawn = TryGetBoundsSpawn(out spX, out spY, out spZ, out spYaw);
				me2.basicInfo.Current.X = spX;



				me2.basicInfo.Current.Y = spY;



				me2.basicInfo.Current.Z = spZ;



				me2.basicInfo.Current.MoveYaw = spYaw;



				if (me2.basicInfo.Next != null)



				{



					me2.basicInfo.Next.X = spX;



					me2.basicInfo.Next.Y = spY;



					me2.basicInfo.Next.Z = spZ;



					me2.basicInfo.Next.MoveYaw = spYaw;



				}



				if (me2.hasOrientation)

				{

					// [OFFLINE-PATCH] 出生朝向必须朝开阔处。

					// 实测 map1 CT 出生点 (4251.96,1234.44) 的水平净空：

					//   0°=3038  45°=254  90°=180(贴墙)  135°=233

					//   180°=3515  225°=1074  270°=759  315°=1074

					// 原来写死 -90°（=270°）虽不至于贴墙，但与引擎的 90° 不一致会来回跳；

					// 使用 BSP 出生点自带朝向；缺少数据时回退到 map1 的默认朝向。

					me2.orientation.Yaw = PickOpenSpawnYaw(spX, spY, spZ, spYaw);

					me2.orientation.Pitch = -5f;

					me2.orientation.MoveYaw = spYaw;

				}

				_spawnFixed = true;

				// [OFFLINE-TDM] 开局也吃出生保护，避免刚落地就被对面预瞄秒掉。
				try
				{
					if (OfflineTdmMatch.Active)
					{
						int selfId = Contexts.sharedInstance.snapshot.snapshots.LatestSnapshot.Self;
						OfflineTdmMatch.MarkSpawnProtected(selfId);
					}
				}
				catch (System.Exception) { }

				if (me2.hasMove && me2.move.PyPlayerMove != null)



				{



					me2.move.PyPlayerMove.SetPosition(spX, spY, spZ);



					UnityEngine.Debug.Log("[OFFLINE-SPAWN] pybody moved to map1 CT spawn");



				}



				UnityEngine.Debug.Log("[OFFLINE-SPAWN] spawn " + spX + "," + spY + "," + spZ + " yaw=" + spYaw);



			}



		}



		// 角色模型与手模现在由引擎的 ThirdPersonModule / FirstPersonModule 负责加载，



		// 这里不再手动 LoadFromFile，避免与引擎重复加载同一个包触发 "already loaded"。



		if (Contexts.sharedInstance.player.myPlayerEntity != null)



		{



			if (Input.GetKeyUp((KeyCode)102))



			{



				isFly = !isFly;
				UnityEngine.Debug.Log("[OFFLINE-FLY] " + (isFly ? "on（WASD 水平/俯仰飞行，掉出世界不再拉回）" : "off"));



			}



			// V 键不再拦截：原版 UserCommandInitSystem 已把 V 绑定为 Showgun(0x10000)，

			// NormalFrameAction 收到 IsShowGun 会播放 SetViewAnimation(44) 枪械检视动画。



		}



		// 一次性场景探针：报告实际渲染的 Renderer 与网格包围盒，确认 map1 是否真的在场

		if (!_probeDone && Time.frameCount > 120)

		{



			_probeDone = true;



			try

			{



				MeshRenderer[] mrs = (MeshRenderer[])UnityEngine.Object.FindObjectsOfType(typeof(MeshRenderer));



				int meshes = 0;



				string biggest = "none";



				float bestVol = -1f;



				foreach (MeshRenderer mr in mrs)

				{



					MeshFilter mf = mr.GetComponent<MeshFilter>();



					if (mf == null || mf.sharedMesh == null)

					{



						continue;



					}



					meshes++;



					Bounds b = mr.bounds;



					float vol = b.size.x * b.size.y * b.size.z;



					if (vol > bestVol)

					{



						bestVol = vol;



						biggest = mr.name + " c=" + b.center.ToString() + " s=" + b.size.ToString() + " mats=" + mr.sharedMaterials.Length;



					}



				}



				// 角色是 SkinnedMeshRenderer，不属于 MeshRenderer，必须单独统计



				Renderer[] allR = (Renderer[])UnityEngine.Object.FindObjectsOfType(typeof(Renderer));



				SkinnedMeshRenderer[] smrs = (SkinnedMeshRenderer[])UnityEngine.Object.FindObjectsOfType(typeof(SkinnedMeshRenderer));



				string skinInfo = "";



				for (int si = 0; si < smrs.Length && si < 12; si++)



				{



					skinInfo += " [" + smrs[si].name + " root=" + (smrs[si].rootBone != null ? smrs[si].rootBone.name : "null")



						+ " enabled=" + smrs[si].enabled + " active=" + smrs[si].gameObject.activeInHierarchy



						+ " c=" + smrs[si].bounds.center.ToString("F0") + " s=" + smrs[si].bounds.size.ToString("F0") + "]";



				}



				UnityEngine.Debug.Log("[OFFLINE-PROBE] renderers=" + mrs.Length + " allRenderers=" + allR.Length + " skinned=" + smrs.Length + " meshes=" + meshes + " biggest=" + biggest + skinInfo);



				Camera cam0 = (Camera)UnityEngine.Object.FindObjectOfType(typeof(Camera));



				if (cam0 != null)

				{



					UnityEngine.Debug.Log("[OFFLINE-PROBE] cam=" + cam0.transform.position.ToString() + " rot=" + cam0.transform.eulerAngles.ToString() + " fov=" + cam0.fieldOfView + " far=" + cam0.farClipPlane);



				}



			}



			catch (Exception ex2)

			{



				UnityEngine.Debug.LogError("[OFFLINE-PROBE] " + ex2);



			}



		}



	}







	// [OFFLINE-PATCH] 物理体位置 -> basicInfo 的持续同步 + 掉出世界兜底。

	//

	// 在线模式下 basicInfo 是服务器快照下发的，客户端只做预测；

	// 离线模式没有快照，如果不主动写回，basicInfo 就永远停在出生点，

	// 而相机/瞄准/HUD 全读 basicInfo，表现就是"人不见了、画面跟着物理体下沉"。

	private void SyncOfflinePhysicsPosition()

	{

		PlayerEntity p = Contexts.sharedInstance.player.myPlayerEntity;

		if (p == null || !p.hasMove || p.move.PyPlayerMove == null) { return; }

		if (p.basicInfo.Current == null) { return; }



		float px, py, pz;

		try

		{

			IPyEntity pe = p.move.PyPlayerMove.GetEntity();

			if (pe == null) { return; }

			px = (float)pe.GetX();

			py = (float)pe.GetY();

			pz = (float)pe.GetZ();

		}

		catch { return; }



		_physLastX = px; _physLastY = py; _physLastZ = pz;

		_physSyncCount++;



		// 首次同步时把物理引擎的世界包围盒缓存下来（后续判出界用）

		if (!_engBoundsOk)

		{

			try

			{

				var pe2 = Contexts.sharedInstance.battleRoom.pyEngine;

				Vector3 mn = pe2.Min;

				Vector3 mx = pe2.Max;

				if (mx.x > mn.x && mx.y > mn.y && mx.z > mn.z)

				{

					_engMinX = mn.x; _engMinY = mn.y; _engMinZ = mn.z;

					_engMaxX = mx.x; _engMaxY = mx.y; _engMaxZ = mx.z;

					_engBoundsOk = true;

					UnityEngine.Debug.Log("[OFFLINE-PHYS] engine bounds min=" + mn + " max=" + mx);

				}

			}

			catch { }

		}



		// 掉出世界兜底。

		// ★ 轴序：pe.GetX/Y/Z 返回的是 SSJJ 原始坐标 (X, 水平Z, 高度Y)，

		//   高度是第三个分量 pz，不是 py。之前写 py < -200 判高度、pz > 12000 判水平，

		//   两个轴都错位，才会出现 "pz 掉到 -2008 却按 py 判定不成立" 的矛盾日志。

		// ★ 范围：改用物理引擎自己报的世界包围盒（日志实测 min=(-20,-20,-20)

		//   max=(11188,11188,2494)），比硬编码的 ±2000 更贴合地图。

		bool outOfWorld;

		if (_engBoundsOk)

		{

			// 留 300 单位容差：贴边出生点、门框边缘都不该被判出界

			const float M = 300f;

			outOfWorld = px < _engMinX - M || px > _engMaxX + M

				|| py < _engMinY - M || py > _engMaxY + M

				|| pz < _engMinZ - M || pz > _engMaxZ + M;

		}

		else

		{

			// 拿不到引擎包围盒时的保守兜底（SSJJ 坐标：X/Z 水平、Y 高度）

			outOfWorld = pz < -500f || pz > 6000f

				|| px < -3000f || px > 13000f

				|| py < -3000f || py > 13000f;

		}

		if (outOfWorld && !isFly)

		{

			ResetOfflinePhysicsToSpawn(p);

			return;

		}



		// 写回 basicInfo（Current + Next），让相机、瞄准、HUD 全部跟着物理体走

		// [OFFLINE-AI] 复用 BSP 体积扫描，机器人使用原版 45×45×170 碰撞体。
		// 物理坐标为 (X,水平Z,高度Y)，OfflineBotPhysics 采用 (-水平Z,高度Y,X)。
		if (p.basicInfo.Current != null)
		{
			Vector3 rawFrom = new Vector3(-(float)p.basicInfo.Current.Y, (float)p.basicInfo.Current.Z, (float)p.basicInfo.Current.X);
			Vector3 rawTo = new Vector3(-py, pz, px);
			Vector3 blocked = OfflineBotPhysics.BlockActors(
				Contexts.sharedInstance.snapshot.snapshots.LatestSnapshot,
				p.entityId.Value, rawFrom, rawTo, OfflineBotPhysics.Height);
			px = blocked.z;
			py = -blocked.x;
			pz = blocked.y;
		}



		p.basicInfo.Current.X = px;

		p.basicInfo.Current.Y = py;

		p.basicInfo.Current.Z = pz;

		if (p.basicInfo.Next != null)

		{

			p.basicInfo.Next.X = px;

			p.basicInfo.Next.Y = py;

			p.basicInfo.Next.Z = pz;

			p.basicInfo.Next.MoveYaw = p.basicInfo.Current.MoveYaw;

		}

	}



	private sealed class AnimTrack

	{

		public Vector3 LastPos;

		public float LastTime;

		public bool Inited;

		public bool Air;

		public bool AirInit;

		public float JumpEndTime;

		public float JumpStartTime;

	}



	private static readonly System.Collections.Generic.Dictionary<int, AnimTrack> _animTracks =

		new System.Collections.Generic.Dictionary<int, AnimTrack>();



	private void SyncOfflineAnimStates()

	{

		// [OFFLINE-PATCH] 离线动画状态 + 进度合成（在线由服务器快照下发 LegsAnim / LegsSpeedAnimTime）

		int renderT = Contexts.sharedInstance.time.time.RenderTime;

		foreach (PlayerEntity p in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.BasicInfo))

		{

			if (p.basicInfo.Current == null) { continue; }

			// [SERVER-AUTHORITY] Pmove 只提供位置/速度，离线并没有服务器为 bot 生成
			// LegsAnim/TorsoAnim。继续走下方原版状态映射，把 locomotion 状态交给原版 Animator。
			if (OfflineServerAuthority.Enabled && !p.isMyPlayer)
			{
				p.basicInfo.SnapsotServerTime = renderT;
			}

			int id = p.entityId.Value;

			PlayerEntityData snapData;
			AnimTrack tr;

			if (!_animTracks.TryGetValue(id, out tr))

			{

				tr = new AnimTrack();

				_animTracks[id] = tr;

			}

			// 世界位置（SSJJ 原始单位，Z 为高度）

			Vector3 cur = new Vector3((float)p.basicInfo.Current.X, (float)p.basicInfo.Current.Y, (float)p.basicInfo.Current.Z);
			// [OFFLINE-PATCH] 机器人（含队友）由 OfflineGameplay 直接改快照数据，实体 basicInfo
			// 不会更新；这里以快照数据为准计算速度，并把位置/腿部状态回写实体。
			snapData = null;
			var snapCur = Contexts.sharedInstance.snapshot.snapshots.LatestSnapshot;
			if (snapCur != null && snapCur.PlayerEntityDataDict != null)
			{
				// [OFFLINE-ANIM] 本地玩家 Cid 可能为 0，退回实体 id / 快照 Self，保证能取到位移数据。
				int keyId = (int)p.basicInfo.Cid;
				if (keyId <= 0) keyId = p.entityId.Value;
				if (!snapCur.PlayerEntityDataDict.TryGetValue(keyId, out snapData)
					&& snapCur.PlayerEntityDataDict.ContainsKey(snapCur.Self))
				{
					snapCur.PlayerEntityDataDict.TryGetValue(snapCur.Self, out snapData);
				}
			}
			if (snapData != null)
			{
				cur = new Vector3((float)snapData.X, (float)snapData.Y, (float)snapData.Z);
				// Bot 的视角由本地 AI 生成；原版 OrientationPlayback 只对在线预测实体
				// 写入 orientation，离线 Bot 若不回写这里，身体永远保持初始朝向，头部也不会晃动。
				if (!p.isMyPlayer && p.hasOrientation)
				{
					p.orientation.Yaw = snapData.ViewYaw;
					p.orientation.Pitch = snapData.ViewPitch;
				}
				// [OFFLINE-FIX] bot（非 prediction 实体）的 basicInfo 没有别处同步，
				// 快照位置必须直接写进实体，否则渲染永远停在出生点（腿在跑人不动的太空步）。
				if (!p.isMyPlayer && p.basicInfo.Current != null)
				{
					if (p.basicInfo.Current.X != snapData.X || p.basicInfo.Current.Y != snapData.Y || p.basicInfo.Current.Z != snapData.Z)
					{
						p.basicInfo.Current.X = snapData.X;
						p.basicInfo.Current.Y = snapData.Y;
						p.basicInfo.Current.Z = snapData.Z;
						if (p.basicInfo.Next != null)
						{
							p.basicInfo.Next.X = snapData.X;
							p.basicInfo.Next.Y = snapData.Y;
							p.basicInfo.Next.Z = snapData.Z;
						}
					}
				}
			}

			float horizSpeed = 0f;
			// [OFFLINE-LEG] 本地玩家的 basicInfo 位置不跟物理体走（传送/出生时位置差会出现
			// 上万单位的假速度），本地一律用原版 pmove 物理体的真实速度；其余实体继续用位置差。
			bool localHasMove = p.isMyPlayer && p.hasMove && p.move.PyPlayerMove != null;
			if (localHasMove)
			{
				try
				{
					var pv = p.move.PyPlayerMove.GetVelocity();
					horizSpeed = (float)Math.Sqrt(pv.x * pv.x + pv.y * pv.y);
				}
				catch (System.Exception) { }
				p.move.Velocity2D = (int)horizSpeed;
			}
			else if (tr.Inited)
			{
				float dt = Mathf.Max(0.001f, Time.deltaTime);
				Vector2 d = new Vector2(cur.x - tr.LastPos.x, cur.y - tr.LastPos.y);
				horizSpeed = d.magnitude / dt;   // SSJJ 单位/秒（100 = 1 m/s）
				// [OFFLINE-TRACE] 高频移动诊断：只要在动就记录（每 0.25 秒最多一条）。
				if (horizSpeed > 5f && UnityEngine.Time.realtimeSinceStartup - s_velMoveT > 0.25f)
				{
					s_velMoveT = UnityEngine.Time.realtimeSinceStartup;
					UnityEngine.Debug.Log("[OFFLINE-VELMOVE] id=" + p.basicInfo.Cid + " horiz=" + horizSpeed.ToString("F0")
						+ " leg=" + p.basicInfo.Current.LegsAnim + " duckMove=" + (p.hasMove ? p.move.DuckState.ToString() : "-")
						+ " duckData=" + (snapData != null ? snapData.DuckState.ToString() : "-"));
				}
				// [OFFLINE-PATCH] 原版 move.Velocity2D 来自服务器快照；离线没人写导致
				// 腿部动画 GetAnimSpeed(velocity)=0，跑步片段被冻结成静止姿势。
				if (UnityEngine.Time.realtimeSinceStartup - s_velDiagT > 2f)
				{
					s_velDiagT = UnityEngine.Time.realtimeSinceStartup;
					UnityEngine.Debug.Log("[OFFLINE-VEL] hasMove=" + p.hasMove + " horiz=" + horizSpeed.ToString("F0")
						+ " field=" + (p.hasMove ? p.move.Velocity2D.ToString() : "-")
						+ " leg=" + p.basicInfo.Current.LegsAnim);
				}
				if (p.hasMove)
				{
					p.move.Velocity2D = (int)horizSpeed;
				}
			}

			tr.LastPos = cur;

			tr.Inited = true;



			// [OFFLINE-LEG] 原版服务器按移动/下蹲下发腿部状态：
			// 7 idle / 8 蹲idle / 1 run / 2 runb / 3 walk / 4 walkb / 9 蹲跑 / 10 蹲跑b。
			// 离线没有服务器：本地玩家按原版 CommonLegPredication 的规则选状态并直接写 legAnim 组件
			// （PlayerLegAnimInitSystem/PlaybackSystem 都会跳过 isPrediction 实体）。
			bool botDead = !p.isMyPlayer && snapData != null && (snapData.IsDead || snapData.Hp <= 0f);
			bool movingNow = !botDead && horizSpeed > 20f;
			if (p.isMyPlayer && p.hasMove && p.move.Moving) movingNow = true;
			bool duckedNow = snapData != null ? snapData.DuckState != 3 : (p.hasMove && p.move.DuckState != 3);
		// [OFFLINE-LEG-NATIVE] Bot 改走引擎 pmove 后速度和玩家同量级（300~520cm/s），
		// 阈值统一回原版 310（旧 140 是 BSP 近似速度偏低时的妥协，已不再需要）。
		bool runNow = horizSpeed > 310f;
		bool backNow = false;
		if (p.isMyPlayer && movingNow && p.hasOrientation && p.hasMove && p.move.PyPlayerMove != null)
		{
			try
			{
				var lv = p.move.PyPlayerMove.GetVelocity();
				double hlen = Math.Sqrt(lv.x * lv.x + lv.y * lv.y);
				if (hlen > 30.0)
				{
					float velYaw = (float)(Math.Atan2(lv.y, lv.x) * 57.29577951308232);
					float rel = SSJJMath.YawPitchUtility.MakeAngleInRange(velYaw - p.orientation.Yaw);
					backNow = Mathf.Abs(rel) > 135f;
				}
			}
			catch (System.Exception) { }
		}
		// [OFFLINE-AI6] bot 后退动画：移动方向与视线夹角 >135° 播后退腿。
		// 旧实现只给本地玩家算 backNow，bot 永远只有前进/左右四套腿，包抄时像在"倒着跑正步"。
		else if (!p.isMyPlayer && movingNow && snapData != null)
		{
			float relBot = SSJJMath.YawPitchUtility.MakeAngleInRange(snapData.MoveYaw - snapData.ViewYaw);
			backNow = Mathf.Abs(relBot) > 135f;
		}
			// 滞回：已经在跑就低于 260 才回走，避免 310 阈值附近来回切状态。
			if (p.hasLegAnim && p.legAnim.LegsAnimInfo != null)
			{
				int curLegId0 = ((Assets.Sources.Components.Interface.Info.AnimState.IAnimStateInfo)p.legAnim.LegsAnimInfo).StateId;
				if (curLegId0 == 1 || curLegId0 == 2)
					runNow = horizSpeed > 260f;   // [OFFLINE-LEG-NATIVE] 滞回同玩家
			}
			int leg = 7;
			bool jumpState = false;

			// [OFFLINE-JUMPLEG] 原版腿部跳跃状态由服务器下发：5=LEGS_JUMP 起跳、
			// 340=LEGS_JUMP_LOOP 空中循环、6=LEGS_LAND 落地。当前职业动画器没有
			// jump_loop/land 片段，强行播放会停在怪异姿势（扭身/趴下），所以只播
			// 确实存在的起跳片段；空中/落地保持正常移动/待机腿。
			bool airNow = false;
			double vzNow = 0.0;
			bool hasAdapter = p.hasMove && p.move.PyPlayerMove != null;
			bool hasCustomBotVertical = !p.isMyPlayer
				&& OfflineBotPhysics.HasVerticalState(p.entityId.Value);
			if (hasCustomBotVertical)
			{
				airNow = OfflineBotPhysics.IsAirborne(p.entityId.Value);
				vzNow = OfflineBotPhysics.VerticalVelocity(p.entityId.Value);
			}
			else if (hasAdapter && !isFly)
			{
				try
				{
					airNow = !p.move.PyPlayerMove.IsOnGround();
					vzNow = p.move.PyPlayerMove.GetVelocity().z;
				}
				catch (System.Exception) { }
			}
			if (hasAdapter || hasCustomBotVertical)
			{
				float tnow = UnityEngine.Time.time;
				if (!tr.AirInit)
				{
					tr.AirInit = true;
					tr.Air = airNow;
				}
				else
				{
					if (airNow && !tr.Air)
					{
						int jumpMs = 0;
						try { jumpMs = Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.GetLegAnimDuration(p, 5); }
						catch (System.Exception) { }
						float jumpSec = (jumpMs > 30) ? jumpMs * 0.001f : 0.55f;
						// 走下台阶/斜坡（没有向上速度）不播起跳。
						if (vzNow <= 50.0) jumpSec = 0f;
						tr.JumpStartTime = tnow;
						tr.JumpEndTime = tnow + jumpSec;
						if (UnityEngine.Time.realtimeSinceStartup - s_jumpLogT > 0.5f)
						{
							s_jumpLogT = UnityEngine.Time.realtimeSinceStartup;
							UnityEngine.Debug.Log("[OFFLINE-JUMPLEG] takeoff id=" + p.entityId.Value + " jumpMs=" + jumpMs + " vz=" + vzNow.ToString("F0"));
						}
					}
					tr.Air = airNow;
				}
				if (airNow && tr.JumpEndTime > 0f && tnow < tr.JumpEndTime)
				{
					leg = 5;
					jumpState = true;
				}
				if (!airNow)
				{
					tr.JumpEndTime = 0f;
					tr.JumpStartTime = 0f;
				}
			}
			if (botDead)
			{
				// 原版死亡姿势由腿部 LEGS_DIE(11) + 上身 TORSO_DIE(19) 共同完成；
				// 仅播 torso 会让下肢保持站立，角色看起来像僵在原地。
				leg = 11;
				jumpState = true;
			}
			if (!jumpState)
			{
				if (!movingNow) leg = duckedNow ? 8 : 7;
				else if (duckedNow) leg = backNow ? 10 : 9;
				else leg = backNow ? (runNow ? 2 : 4) : (runNow ? 1 : 3);
			}

			if (p.isMyPlayer)
			{
				OfflineLocalLegState = leg;
			}
			if (p.hasLegAnim)
			{
				var curInfo = p.legAnim.LegsAnimInfo;
				int curLegId = (curInfo == null) ? 0 : ((Assets.Sources.Components.Interface.Info.AnimState.IAnimStateInfo)curInfo).StateId;
				if (curLegId != leg)
				{
					Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetLegsAnimation(p, leg);
					p.basicInfo.Current.LegsSpeedAnimTime = 0;
					if (p.isMyPlayer && UnityEngine.Time.realtimeSinceStartup - s_legChangeT > 0.5f)
					{
						s_legChangeT = UnityEngine.Time.realtimeSinceStartup;
						UnityEngine.Debug.Log("[OFFLINE-LEG] local " + curLegId + " -> " + leg + " speed=" + horizSpeed.ToString("F0") + " moving=" + movingNow + " duck=" + (p.hasMove ? p.move.DuckState : -1));
					}
				}
			}
			if (snapData != null && snapData.LegsAnim != leg)
			{
				snapData.LegsAnim = leg;
				snapData.LegsAnimSpecified = true;
			}
			if (p.basicInfo.Current.LegsAnim != leg)
			{
				p.basicInfo.Current.LegsAnim = leg;
				if (p.basicInfo.Next != null) { p.basicInfo.Next.LegsAnim = leg; }
			}



			// 上半身：301 = 原版持枪待机，19 = 原版 TORSO_DIE。bot 死亡时保留骨骼死亡动画，
			// 不再让共享的玩家 LastTorsoActionAt 把 bot 动作带偏。
			int botTorso = !p.isMyPlayer && !botDead ? OfflineGameplay.GetBotTorsoAnimation(p.entityId.Value) : 0;
			int torso = botDead ? 19 : (botTorso != 0 ? botTorso : (p.isMyPlayer && UnityEngine.Time.time - OfflineGameplay.LastTorsoActionAt < 0.6f
				? p.basicInfo.Current.TorsoAnim : 301));

			if (p.basicInfo.Current.TorsoAnim != torso)

			{

				p.basicInfo.Current.TorsoAnim = torso;

				if (p.basicInfo.Next != null) { p.basicInfo.Next.TorsoAnim = torso; }
				if (p.hasTorseAnim)
				{
					try { Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetTorseAnimation(p, torso); }
					catch (System.Exception) { }
				}

			}

			if (torso == 301) p.basicInfo.Current.TorsoAnimStartTime = renderT - (p.basicInfo.Current.LegsSpeedAnimTime % 4000);
			else if ((torso == 19 || torso == 15 || torso == 17) && snapData != null && snapData.TorsoAnim != torso)
				p.basicInfo.Current.TorsoAnimStartTime = renderT;
			if (p.basicInfo.Next != null)
			{
				p.basicInfo.Next.TorsoAnimStartTime = p.basicInfo.Current.TorsoAnimStartTime;
				p.basicInfo.Next.TorsoAnimationTimer = p.basicInfo.Current.TorsoAnimationTimer;
			}
			if (snapData != null)
			{
				snapData.TorsoAnim = torso;
				snapData.TorsoAnimSpecified = true;
				if (torso == 301 || torso == 15 || torso == 17) snapData.TorsoAnimStartTime = p.basicInfo.Current.TorsoAnimStartTime;
				else if (torso == 19 && snapData.TorsoAnimStartTime <= 0) snapData.TorsoAnimStartTime = renderT;
				snapData.TorsoAnimStartTimeSpecified = true;
				if (p.hasTorseAnim)
				{
					snapData.TorsoAnimationTimer = p.torseAnim.RemainTime;
					snapData.TorsoAnimationTimerSpecified = true;
				}
			}



			// [OFFLINE-PATCH] 强制单线程骨骼采样（多线程分支在 TP 根 inactive 期间会卡住）

			if (p.hasThirdPersonUnityObjects && p.thirdPersonUnityObjects.Animator != null)

			{

				SSJJAnim.Animator.SJAnimator sj = p.thirdPersonUnityObjects.Animator as SSJJAnim.Animator.SJAnimator;

				if (sj != null) { sj.SetMultiThreadSupport(false); }

			}



			// [OFFLINE-PATCH] 关掉 TPS 动画分支：

			// F3 让 cameraData.IsTps=true，PlayerAnimationUtility.IsTpsAnim(player) 随之变 true，

			// SJAnimationPlayer._isTps 走 TpsStateCaculate（TPS 专用曲线）。police 不是 TPS 职业、

			// 动画里没有 TPS 变体 → 曲线为空 → 骨骼永不写入（队友非 TPS 所以能动）。

			if (p.hasThirdPersonUnityObjects && p.thirdPersonUnityObjects.Animator != null)

			{

				SSJJAnim.Player.SJAnimationPlayer sjp = p.thirdPersonUnityObjects.ThirdTran.RootContainer.GetComponentInChildren<SSJJAnim.Player.SJAnimationPlayer>();

				if (sjp != null) { sjp.SetIsTpsAnim(false); }

			}



			// 进度推进：LegsSpeedAnimTime 自增（毫秒），并让快照时间紧跟渲染时间

			// （否则 Playback 算出 (RenderTime - 0) 巨大值 / 或恒 0，骨骼都不动）

		// [OFFLINE-LEG] 按原版 GetAnimSpeed(velocity) 缩放片段进度（跑步更快）。
		// [OFFLINE-AI6] 本地与 bot 都缩放：bot 的 Velocity2D 上面已经写好，
		// 旧实现只本地缩放，bot 腿频率不随速度变 —— 慢走和冲刺同一频率，非常假。
		float legMul = 1f;
		if (p.hasLegAnim && p.legAnim.LegsAnimInfo != null)
		{
			try { legMul = p.legAnim.LegsAnimInfo.GetAnimSpeed(horizSpeed); }
			catch (System.Exception) { }
			if (legMul < 0.05f) legMul = 1f;
		}
			int adv = Mathf.Max(1, (int)(Time.deltaTime * 1000f * legMul));

			p.basicInfo.Current.LegsSpeedAnimTime = (p.basicInfo.Current.LegsSpeedAnimTime + adv) % 60000;
			if (snapData != null)
			{
				snapData.LegsSpeedAnimTime = p.basicInfo.Current.LegsSpeedAnimTime;
				snapData.LegsSpeedAnimTimeSpecified = true;
				if (p.hasLegAnim)
				{
					snapData.LegsAnimationTimer = p.legAnim.RemainTime;
					snapData.LegsAnimationTimerSpecified = true;
				}
			}

			p.basicInfo.SnapsotServerTime = renderT;

			if (p.hasLegAnim)

			{

				p.legAnim.ScaledEclipsedTime = p.basicInfo.Current.LegsSpeedAnimTime;

			}

		}

	}



	// [OFFLINE-VIEWLOCO] 原版第一人称移动晃动来自视图动画本身：服务器按腿部状态把 ViewAnim
	// 切到 TORSO_STAND(13)/TORSO_WALK(14)（特殊模式 39/48，见原版 PredictWalkAnim）。
	// 离线没有服务器，这里按同一规则补切；只在循环态之间切换，攻击/换弹/切枪交给原版播放链。
	private void SyncOfflineViewLocomotion()
	{
		try
		{
			PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
			if (me == null || !me.hasViewAnim || !me.hasCurrentWeapon || !me.hasFirstPersonUnityObjects) return;
			if (me.hasBasicInfo && me.basicInfo.IsDead) return;
			if (OfflineGameplay.AttackAnimActive) return;
			if (UnityEngine.Time.time < OfflineGameplay.PendingRaiseAt || UnityEngine.Time.time < OfflineGameplay.SuppressIdleUntil) return;
			var wInfo = me.currentWeapon.WeaponInfo;
			if (wInfo == null) return;
			var vInfo = me.viewAnim.ViewAnimInfo;
			if (vInfo == null) return;
			int cur = ((Assets.Sources.Components.Interface.Info.AnimState.IAnimStateInfo)vInfo).StateId;
			bool special = (cur == 39 || cur == 48);
			if (!special && cur != 13 && cur != 14) return;
			bool moving = false;
			if (me.hasMove) moving = me.move.Moving || me.move.Velocity2D > 20;
			int target = special ? (moving ? 48 : 39) : (moving ? 14 : 13);
			if (cur == target) return;
			if (!Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.IsViewAnimExist(wInfo, target)) return;
			Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimationKeepLoopPhase(me, target);
			if (UnityEngine.Time.realtimeSinceStartup - s_viewLocoT > 1f)
			{
				s_viewLocoT = UnityEngine.Time.realtimeSinceStartup;
				UnityEngine.Debug.Log("[OFFLINE-VIEWLOCO] viewAnim " + cur + " -> " + target + " moving=" + moving + " vel=" + (me.hasMove ? me.move.Velocity2D : 0));
			}
		}
		catch (System.Exception) { }
	}

		private static float PickOpenSpawnYaw(float spX, float spY, float spZ, float fallbackYaw)
	{
		// [OFFLINE-SPAWN] BSP 出生点朝向可能正对墙角（map12 就是这样），
		// 按 16 个方向探 12m，选净空最大的方向，保证出生就能看到战场。
		try
		{
			Vector3 origin = new Vector3(0f - spY, spZ + 60f, spX);
			float bestYaw = fallbackYaw;
			float bestDist = -1f;
			for (int i = 0; i < 16; i++)
			{
				float yaw = i * 22.5f;
				float r = yaw * Mathf.Deg2Rad;
				Vector3 dir = new Vector3(Mathf.Sin(r), 0f, Mathf.Cos(r));
				Vector3 end, nrm; float frac;
				if (!OfflineBotPhysics.Cast(origin, origin + dir * 1200f, 0f, 0f, out end, out nrm, out frac)) continue;
				float d = Vector3.Distance(origin, end);
				if (d > bestDist) { bestDist = d; bestYaw = yaw; }
			}
			UnityEngine.Debug.Log("[OFFLINE-SPAWN] open yaw=" + bestYaw.ToString("F0")
				+ " clear=" + bestDist.ToString("F0") + " (bsp=" + fallbackYaw.ToString("F0") + ")");
			return bestYaw;
		}
		catch (System.Exception) { return fallbackYaw; }
	}

	/// <summary>
	/// [OFFLINE-SPAWN] 团队模式优先走阵营出生点（和 bot/复活同一条路径），
	/// 非团队模式走 BSP CT 点但必须探地成功；失败才交给 TryGetBoundsSpawn。
	/// 旧实现无条件相信 BSP origin，换图后会直接落在界外。
	/// </summary>
	private bool TryPickValidatedSpawn(out float x, out float y, out float z, out float yaw)
	{
		x = OFFLINE_SPAWN_X;
		y = OFFLINE_SPAWN_Y;
		z = OFFLINE_SPAWN_Z;
		yaw = OFFLINE_SPAWN_YAW;
		ISnapshot snap = null;
		try
		{
			if (Contexts.sharedInstance.snapshot.hasSnapshots)
				snap = Contexts.sharedInstance.snapshot.snapshots.LatestSnapshot;
		}
		catch (System.Exception) { }

		if (IsTdmTeamMode())
		{
			try
			{
				Vector3? teamSpawn = Assets.Sources.Systems.Snapshot.OfflineBotSpawner.PickTeamSpawn(snap, 1, true, 0);
				if (teamSpawn.HasValue)
				{
					RawFromUnity(teamSpawn.Value, out x, out y, out z);
					yaw = Assets.Sources.Systems.Snapshot.OfflineBotSpawner.LastSpawnYaw;
					UnityEngine.Debug.Log("[OFFLINE-SPAWN] team-bsp validated src="
						+ Assets.Sources.Systems.Snapshot.OfflineBotSpawner.LastSpawnSource
						+ " raw=" + x.ToString("F1") + "," + y.ToString("F1") + "," + z.ToString("F1") + " yaw=" + yaw.ToString("F0"));
					return true;
				}
			}
			catch (System.Exception ex)
			{
				UnityEngine.Debug.LogWarning("[OFFLINE-SPAWN] team spawn failed: " + ex.Message);
			}
		}

		try
		{
			int sceneId = (setting != null) ? setting.SceneId : 1;
			float[] mapSpawn = OfflineMapSpawns.FirstSpawn(sceneId, true);
			if (mapSpawn != null)
			{
				float rx = mapSpawn[0], ry = mapSpawn[1], rz = mapSpawn[2];
				Vector3 candidate = new Vector3(0f - ry * 0.01f, rz * 0.01f, rx * 0.01f);
				Vector3 grounded;
				if (Assets.Sources.Systems.Snapshot.OfflineBotSpawner.TryGroundSnap(candidate, out grounded))
				{
					RawFromUnity(grounded, out x, out y, out z);
					if (mapSpawn.Length > 4 && Math.Abs(mapSpawn[4]) > 0.01f) yaw = mapSpawn[4];
					UnityEngine.Debug.Log("[OFFLINE-SPAWN] bsp validated scene=" + sceneId
						+ " raw=" + x.ToString("F1") + "," + y.ToString("F1") + "," + z.ToString("F1"));
					return true;
				}
				UnityEngine.Debug.LogWarning("[OFFLINE-SPAWN] bsp spawn not grounded scene=" + sceneId
					+ " raw=" + rx.ToString("F1") + "," + ry.ToString("F1") + "," + rz.ToString("F1"));
			}
		}
		catch (System.Exception) { }
		return false;
	}

	private bool IsTdmTeamMode()
	{
		if (setting == null) return false;
		int rt = setting.RaceType;
		if (OfflineGameSetting.IsFreeForAll(rt)) return false;
		return rt == 3 || rt == 2003 || rt == 2019;
	}

	private static void RawFromUnity(Vector3 u, out float x, out float y, out float z)
	{
		x = u.z * 100f;
		y = (0f - u.x) * 100f;
		z = u.y * 100f;
	}

	/// <summary>
	/// [OFFLINE-SPAWN] 没有 BSP 出生点时，用引擎世界包围盒中心 + 向下探地找可站立点。
	/// 旧实现回退到 map1 坐标，换图后就在界外，且每帧被"掉出世界"兜底拉回原地 —— 连 F 飞行都出不去。
	/// </summary>
	private bool TryGetBoundsSpawn(out float x, out float y, out float z, out float yaw)
	{
		// [OFFLINE-SPAWN] map1 常量只在 map1 有意义；换图后绝不能拿它兜底（会直接落在界外）。
		bool sceneOne = (setting == null || setting.SceneId == 1);
		x = sceneOne ? OFFLINE_SPAWN_X : 0f;
		y = sceneOne ? OFFLINE_SPAWN_Y : 0f;
		z = sceneOne ? OFFLINE_SPAWN_Z : 0f;
		yaw = sceneOne ? OFFLINE_SPAWN_YAW : 0f;
		if (!_engBoundsOk)
		{
			try
			{
				var pe = Contexts.sharedInstance.battleRoom.pyEngine;
				Vector3 mn = pe.Min;
				Vector3 mx = pe.Max;
				if (mx.x > mn.x && mx.y > mn.y && mx.z > mn.z)
				{
					_engMinX = mn.x; _engMinY = mn.y; _engMinZ = mn.z;
					_engMaxX = mx.x; _engMaxY = mx.y; _engMaxZ = mx.z;
					_engBoundsOk = true;
				}
			}
			catch (System.Exception) { }
		}
		if (!_engBoundsOk) return false;
		float cx = (_engMinX + _engMaxX) * 0.5f;
		float cy = (_engMinY + _engMaxY) * 0.5f;
		float halfX = (_engMaxX - _engMinX) * 0.5f;
		float halfY = (_engMaxY - _engMinY) * 0.5f;
		float top = _engMaxZ + 300f;
		// 中心优先，再按 25%/50% 偏移做 5x5 网格向下探地；
		// 原来只探中心一次、失败就把高度设成 maxZ-200 —— 没有 BSP 的图会刷在半空。
		float[] offs = new float[] { 0f, 0.25f, -0.25f, 0.5f, -0.5f };
		for (int i = 0; i < offs.Length; i++)
		{
			for (int j = 0; j < offs.Length; j++)
			{
				float px = cx + offs[i] * halfX;
				float py = cy + offs[j] * halfY;
				Vector3 from = new Vector3(0f - py, top, px);
				Vector3 end, nrm;
				float frac;
				if (!OfflineBotPhysics.Cast(from, from - Vector3.up * 8000f, 0f, 0f, out end, out nrm, out frac)) continue;
				if (frac >= 0.999f || nrm.y < 0.65f) continue;
				if (end.y < _engMinZ - 100f) continue;
				x = px;
				y = py;
				z = end.y + 20f;
				yaw = 0f;
				UnityEngine.Debug.Log("[OFFLINE-SPAWN] no BSP spawn -> ground (" + x.ToString("F0") + "," + y.ToString("F0") + "," + z.ToString("F0") + ")");
				return true;
			}
		}
		yaw = 0f;
		UnityEngine.Debug.LogWarning("[OFFLINE-SPAWN] no BSP spawn and no ground found, keep (" + x.ToString("F0") + "," + y.ToString("F0") + "," + z.ToString("F0") + ")");
		return false;
	}

	/// <summary>
	/// [OFFLINE-SCOPE] 复刻原版 HideFirstPersonViewSystem：
	/// fov.IsHideFristView / IsZoom（开镜）/ 武器组合 / 视图动画 662 / 踢击，
	/// 直接开关原版 firstPersonUnityObjects 的 HandCameraObject 与 WeaponGameObject。
	/// 离线没有注册原版该 PreRenderSystem，所以这里每帧兜一层。
	/// </summary>
	private void SyncFirstPersonVisibility()
	{
		try
		{
			PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
			if (me == null || !me.hasFirstPersonUnityObjects) return;
			bool hide = false;
			// [OFFLINE-SCOPE] 原版只有 RifleScopeFovRightAction（狙击 90->55）才置
			// IsHideFristView；步枪/手枪开镜（90->40->10）不隐藏手模。
			// 之前写成 || IsZoom()，所有开镜都会把枪藏掉，偏离原版手感。
			if (me.hasFov) hide = me.fov.IsHideFristView;
			if (!hide && me.hasViewAnim && me.viewAnim.ViewAnimInfo != null
				&& ((Assets.Sources.Components.Interface.Info.AnimState.IAnimStateInfo)me.viewAnim.ViewAnimInfo).StateId == 662) hide = true;
			if (!hide)
			{
				try
				{
					var gr = Contexts.sharedInstance.gameRule;
					if (gr != null && gr.hasWeaponCombination && gr.weaponCombination.HideFirstPersonView) hide = true;
				}
				catch (System.Exception) { }
			}
			if (!hide && me.HasStatus(share.constant.PlayerInfoStatusConstant.PLAYER_KICKING_P1.ID)) hide = true;
			// [OFFLINE-FOV] 在帧末把 FovComponent 的结果回写进快照字段，作为"服务器回传"。
			// 必须晚于开镜动作，否则下一 cmd 的 PlayerFovInitSystem 会读到旧值把开镜打回去。
			if (me.hasFov && me.hasBasicInfo && me.basicInfo.Current != null)
			{
				me.basicInfo.Current.Fov = me.fov.Fov;
				me.basicInfo.Current.LastFov = me.fov.LastFov;
				me.basicInfo.Current.ResumeZoom = me.fov.ResumeZoom;
			}
			var fp = me.firstPersonUnityObjects;
			if (fp == null) return;
			if (fp.WeaponGameObject != null && fp.WeaponGameObject.activeSelf == hide) fp.WeaponGameObject.SetActive(!hide);
			if (fp.HandCameraObject != null && fp.HandCameraObject.activeSelf == hide) fp.HandCameraObject.SetActive(!hide);
			// [OFFLINE-SCOPE] 手模根节点（FirstHand 树里挂手/枪的那个）也要一起关：
			// Eye 相机一旦渲染过 FPSArmWeapon 层，光关 HandCamera 仍会把手糊在镜片上。
			if (fp.HandGameObject != null && fp.HandGameObject.activeSelf == hide) fp.HandGameObject.SetActive(!hide);
			if (_fpHideLogged != hide)
			{
				_fpHideLogged = hide;
				UnityEngine.Debug.Log("[OFFLINE-SCOPE] hide=" + hide + " fov=" + (me.hasFov ? me.fov.Fov.ToString("F0") : "-") + " isHideFp=" + (me.hasFov ? me.fov.IsHideFristView.ToString() : "-"));
			}
		}
		catch (System.Exception) { }
	}

	private void ResetOfflinePhysicsToSpawn(PlayerEntity p)

	{

		_physicsResets++;
		float spX, spY, spZ, spYaw;
		if (!TryPickValidatedSpawn(out spX, out spY, out spZ, out spYaw)
			&& !TryGetBoundsSpawn(out spX, out spY, out spZ, out spYaw))
		{
			UnityEngine.Debug.LogWarning("[OFFLINE-PHYS] no valid spawn, keep current position (reset skipped)");
			return;
		}

		try

		{

			if (p.hasMove && p.move.PyPlayerMove != null)

			{

				p.move.PyPlayerMove.SetPosition(spX, spY, spZ);

			}

			if (p.hasBasicInfo && p.basicInfo.Current != null)

			{

				p.basicInfo.Current.X = spX;

				p.basicInfo.Current.Y = spY;

				p.basicInfo.Current.Z = spZ;

			}

			if (p.hasOrientation) { p.orientation.Pitch = 0f; p.orientation.Yaw = spYaw; }

			UnityEngine.Debug.Log("[OFFLINE-PHYS] out of world -> reset to spawn (#" + _physicsResets + ") last=(" + _physLastX.ToString("F1") + "," + _physLastY.ToString("F1") + "," + _physLastZ.ToString("F1") + ")");

		}

		catch (Exception e) { UnityEngine.Debug.Log("[OFFLINE-PHYS] reset failed " + e.Message); }

	}





	public override void CreateFpsSystems(Contexts contexts)

	{


		Feature val = new Feature("EntitasSystems");


		((Systems)val).Add((ISystem)(object)new PacketHandleFeature(contexts));


		((Systems)val).Add((ISystem)(object)new TimeFeature(contexts));


		((Systems)val).Add((ISystem)(object)new UserCommandFeature(contexts));


		((Systems)val).Add((ISystem)(object)new SnapshotFeature(contexts));


		((Systems)val).Add((ISystem)(object)new GameRuleFeature(contexts));


		((Systems)val).Add((ISystem)(object)new GameModuleFeature(contexts, new OfflineGameModule(contexts)));


		((Systems)val).Initialize();


		((Systems)_systems).Add((ISystem)(object)val);


		// [OFFLINE-PATCH] 原版 GameController.CreateFpsSystems 末尾会调 UiEditorDataInit()，
		// 它负责 DataProviderManager.Init(contexts) 与 TextStyleManager.Init()。
		// 离线覆写漏了这一步 -> PlayerDataProvider._weaponContext 为 null ->
		// RuleUiPlaybackSystem 每帧 NullReferenceException。
		if (Assets.Sources.Modules.OfflineGameModule.ModulesFlag.Contains("ui"))
		{
			// UiEditorDataInit 是 private，这里内联等价实现：
			// DataProviderManager.Init 建立 player/weapon/context 三个 provider 的上下文引用，
			// TextStyleManager.Init 加载文字样式（字体描边/颜色）。
			try
			{
				UnityEngine.Debug.Log("[OFFLINE-UI-INIT] begin");
				BattleSingletonInstance<Assets.Libs.UiEditor.RunTime.RunTimeLogic.RunTimeNode.DataProviderManager>.Instance.Init(contexts);
				UnityEngine.Debug.Log("[OFFLINE-UI-INIT] provider manager ok");
				SSJJUIEditor.UI.TextStyleManager.Instance.ApplyInit();
				UnityEngine.Debug.Log("[OFFLINE-UI-INIT] text style ok");
			}
			catch (System.Exception uiInitEx)
			{
				UnityEngine.Debug.LogError("[OFFLINE-UI-INIT] FAILED: " + uiInitEx);
			}
		}

	}








	private static int s_moveLog;
	 private static int s_flyLogN;
	 private static float s_flyLogT;

	public static void GetPlayerOffes(IUserCmd cmd, int speed, IPyPlayerMove adapter, IPyMove pmove, IPyUserCmd _pyCmd)



	{



		if (isFly) { return; }   // [OFFLINE-FLY2] 位移由 FlyTick 自管



		else



		{



			pmove.SetMove(adapter, _pyCmd, speed);
			// [OFFLINE-MOVE] 原版式 825：照 PmoveBase.LimitVelocityMaxSpeed 的 speed*1.25 上限，
			// 只在空中结算；不切换 IsLimitMaxSpeed，空中加速仍走原版 100 系数（不改变身法手感）。
			try
			{
				if (!adapter.IsOnGround()
					&& adapter.GetImpulseTime() <= 0 && adapter.GetImpulseTime2() <= 0
					&& adapter.GetDuckState() != 0 && adapter.GetDuckState() != 1)
				{
					double maxSpeed = speed * 1.25;
					Vector3D vel = adapter.GetVelocity();
					double hs = Math.Sqrt(vel.x * vel.x + vel.y * vel.y);
					if (hs > maxSpeed)
					{
						double k = maxSpeed / hs;
						adapter.SetVelocity((float)(vel.x * k), (float)(vel.y * k), (float)vel.z);
					}
					if (s_moveLog < 3)
					{
						s_moveLog++;
						UnityEngine.Debug.Log("[OFFLINE-MOVE] air speed=" + hs.ToString("F0") + " max=" + maxSpeed.ToString("F0") + " base=" + speed);
					}
				}
			}
			catch (System.Exception) { }




		}



	}







	public void OnGUI()
	{
		// [OFFLINE-HUD] 开关与 FPS 采样放在 LateUpdate（OnGUI 每帧多次调用会把开关切来切去）。
		if (!_showDebugHud) return;
		float dt = Time.unscaledDeltaTime;
		GUIStyle st = new GUIStyle();
		st.fontSize = 16;
		st.normal.textColor = Color.red;
		GUILayout.BeginArea(new Rect(8f, 8f, 820f, 240f));
		GUILayout.Label("FPS " + Mathf.RoundToInt(_offlineFpsSmooth) + "   帧耗时 " + (dt * 1000f).ToString("F1") + " ms   上限 " + Application.targetFrameRate, st);
		PlayerEntity meDbg = Contexts.sharedInstance.player.myPlayerEntity;
		if (meDbg != null && meDbg.hasBasicInfo && meDbg.basicInfo.Current != null)
		{
			PlayerEntityData c = meDbg.basicInfo.Current;
			GUILayout.Label("坐标 " + c.X.ToString("F0") + " , " + c.Y.ToString("F0") + " , " + c.Z.ToString("F0") + "   下蹲 " + c.DuckState + "   HP " + c.Hp.ToString("F0"), st);
		}
		Camera camDbg = Camera.main;
		if (camDbg != null)
		{
			GUILayout.Label("相机 " + camDbg.name + " " + camDbg.transform.position.ToString("F0") + "   FOV " + camDbg.fieldOfView.ToString("F1"), st);
		}
		GUILayout.Label("瞄准键 H 关闭 | F=" + isFly, st);
		GUILayout.EndArea();
	}



}



