using System.Collections.Generic;
using Assets.Sources.Components.Interface;
using Assets.Sources.Snapshots;
using Assets.Sources.Systems.Snapshot;
using NetData;
using UnityEngine;
using Assets.Sources.Components.Interface.Info.AnimData;
using Assets.Sources.Components.Interface.Info.AnimState;
using Assets.Sources.Components.Interface.Info.Weapon;
using physics;
using SSJJPhysicsExtensions;
using Assets.Sources.Info.WeaponAnim;
using SSJJAnim.WeaponAnim;

/// <summary>
/// 单机版玩法层：Bot 巡逻/追击 AI、击杀计分、比分 HUD、胜负判定。
/// 直接读写快照里的 PlayerEntityData，由引擎渲染管线负责实体化。
/// </summary>
public class OfflineGameplay : MonoBehaviour
{
    public static OfflineGameplay Instance;

    // ---- 计分状态 ----
    public int PlayerKills;
    public int PlayerDeaths;
    public int BotKills;
    public int BotDeaths;
    public int RoundSeconds = 300;
    public bool RoundOver;
    public string RoundResult = "";

    /// <summary>剩余秒数（HUD 用）。</summary>
    public float RemainingSeconds { get { return _roundTimer; } }

    private float _roundTimer;
    private float _hudTimer;
    // [OFFLINE-TDM] 初始化重试（setting 可能晚于 Start 就绪）
    private bool _tdmInited;
    private int _tdmInitTries;
    private bool _botSkillIgnored;
    private bool _uiProbeDone;
    private readonly Dictionary<int, OfflineBotAgent> _agents = new Dictionary<int, OfflineBotAgent>();
    private ISnapshot _snap;

    private const float EyeHeight = 150f;

private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        _roundTimer = RoundSeconds;
        // [OFFLINE-SPRAY] 读喷漆配置并检查 spray/<id> bundle 是否已安装（缺失只警告，不影响进游戏）
        OfflineSpray.Initialize();
        // [OFFLINE-TDM] 比赛核心初始化（幂等；setting 未就绪时 Update 继续重试）
        TryInitTdm();
    }

    // [OFFLINE-TDM] 幂等初始化：OfflineGameController.setting 可能晚于 Start 就绪，前几秒逐帧重试。
    private void TryInitTdm()
    {
        if (_tdmInited) return;
        try
        {
            _tdmInitTries++;
            bool settingReady = OfflineGameController.setting != null;
            if (!settingReady && _tdmInitTries < 240) return;
            OfflineTdmMatch.Initialize(this);
            _tdmInited = true;
            Debug.Log("[OFFLINE-TDM] gameplay init tries=" + _tdmInitTries
                + " active=" + OfflineTdmMatch.Active + " team=" + OfflineTdmMatch.PlayerTeam);
        }
        catch (System.Exception ex)
        {
            _tdmInited = true;
            Debug.LogWarning("[OFFLINE-TDM] gameplay init failed: " + ex.Message);
        }
    }

    public void Bind(ISnapshot snap)
    {
        _snap = snap;
    }

    /// <summary>应用 F6 训练设置后清除旧难度人格，并同步已有 bot 的阵营/武器统计。</summary>
    public void RefreshTrainingProfiles()
    {
        _botPersona.Clear();
        _botProfileCache = null;
        _botProfileKey = null;
        ISnapshot s = Snap();
        if (s == null || s.PlayerEntityDataDict == null) return;
        if (OfflineBotSpawner.IsMap12TrainingProfile(OfflineGameController.setting))
            SyncTrainingBotRoster(s);
        foreach (var pair in _agents)
        {
            PlayerEntityData data = Get(s, pair.Key);
            OfflineBotAgent agent = pair.Value;
            if (data == null || agent == null) continue;
            agent.Team = data.Team;
            bool melee = OfflineModeTable.IsMelee(data.CurrentWeaponName)
                && !OfflineModeTable.IsThrowable(data.CurrentWeaponName);
            agent.Weapon = BotWeaponStats.Resolve(data.CurrentWeaponName, melee, BotProf);
            agent.Clip = agent.Weapon.ClipSize;
        }
    }

    private OfflineBotAgent CreateBotAgent(int id, PlayerEntityData data)
    {
        Vector3 home = OfflineBotSpawner.GetUnityPos(data);
        var b = new OfflineBotAgent();
        b.Id = id;
        b.Team = data.Team;
        b.Home = home;
        b.SpawnPos = home;
        string weaponName = data.CurrentWeaponName;
        bool melee = OfflineModeTable.IsMelee(weaponName) && !OfflineModeTable.IsThrowable(weaponName);
        b.Weapon = BotWeaponStats.Resolve(weaponName, melee, BotProf);
        b.Clip = b.Weapon.ClipSize;
        b.MaxHp = data.MaxHp > 0f ? data.MaxHp : 100f;
        b.Hp = b.MaxHp;
        b.NextThink = Time.time + Random.Range(0.1f, 0.5f);
        b.StuckPos = home;
        b.StuckTime = Time.time;
        b.AimYaw = data.ViewYaw;
        b.LastKnownTime = -999f;
        return b;
    }

    private void SyncTrainingBotRoster(ISnapshot s)
    {
        int first = OfflineBotSpawner.FirstBotId;
        int end = first + OfflineBotSpawner.TrainingBotTotal;
        var remove = new List<int>();
        foreach (var pair in _agents)
        {
            if (pair.Key >= first && pair.Key < end && !OfflineBotSpawner.IsTrainingBotActive(pair.Key))
                remove.Add(pair.Key);
        }
        for (int i = 0; i < remove.Count; i++)
        {
            int id = remove[i];
            _agents.Remove(id);
            _botPersona.Remove(id);
            _botMove.Remove(id);
            _botPmove.Remove(id);
            _botPmoveRetryAt.Remove(id);
            _botJumpLatch.Remove(id);
            _botSlowFrames.Remove(id);
            _botDirectMode.Remove(id);
            _botAttackAnimUntil.Remove(id);
            _botTorsoAnim.Remove(id);
            OfflineBotPhysics.ResetVertical(id);
        }

        for (int i = 0; i < OfflineBotSpawner.TrainingBotTotal; i++)
        {
            int id = first + i;
            if (!OfflineBotSpawner.IsTrainingBotActive(id) || _agents.ContainsKey(id)) continue;
            PlayerEntityData data = Get(s, id);
            if (data != null) _agents[id] = CreateBotAgent(id, data);
        }
    }

    private static void SyncBotEntityFacing(int botId, float yaw, float pitch)
    {
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null || ctx.player == null) return;
            foreach (PlayerEntity entity in ctx.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (entity == null || entity.entityId.Value != botId) continue;
                if (entity.hasOrientation)
                {
                    entity.orientation.Yaw = yaw;
                    entity.orientation.Pitch = pitch;
                }
                break;
            }
        }
        catch (System.Exception) { }
    }

    private ISnapshot Snap()
    {
        if (_snap != null) return _snap;
        var ctx = Contexts.sharedInstance;
        if (ctx == null) return null;
        _snap = ctx.snapshot.snapshots.LatestSnapshot;
        return _snap;
    }

    // [OFFLINE-ROOTFIX] 动画采样之后重新钉住 bot 模型位置。
    // SJAnimationPlayer 把模型根当骨骼，每帧用片段根曲线覆盖 localPosition（跑步/行走片段
    // 根曲线非零 → 模型被搬离地图 → 移动时看不见；空闲片段根曲线≈0 → 停下闪一下）。
    // Unity 顺序：脚本 Update（DirectStep 写位置）→ 动画求值（片段曲线覆盖）→ LateUpdate（本方法钉回）。
    private void LateUpdate()
    {
        foreach (var kv in _rootFixObj)
        {
            GameObject go = kv.Value;
            if (go == null) continue; // Unity 已销毁对象
            Vector3 p;
            if (_rootFixPos.TryGetValue(kv.Key, out p))
            {
                go.transform.position = p;
            }
        }
        // [OFFLINE-DEATH] 独立于 DirectStep/rootfix 驱动；BSP 移动不再填充 _rootFixObj。
        UpdateBotDeathVisualsFromEntities();
    }

    private void Update()
    {
        // [OFFLINE-SPRAY] 清理已到期的喷漆实体引用（真正销毁由原版 LifeTime 系统负责）
        OfflineSpray.Tick();
        TryInitTdm();

        var s = Snap();
        if (s == null || s.PlayerEntityDataDict == null) return;

        // [OFFLINE-TDM] 快照有效后驱动比赛核心（计时/比分/复活/结算/自动重开）
        if (OfflineTdmMatch.Active) OfflineTdmMatch.Tick();

        // [OFFLINE-UIPROBE] 只打一次：确认 KillMessageModel 真的实例化、通知 22 已注册、
        // AutoSound 配置已加载。击杀图标/音效缺失时先看这一行，能直接分清是 UI 没建、
        // 通知没订阅，还是音效配置为空。
        if (!_uiProbeDone && Time.time > 6f)
        {
            _uiProbeDone = true;
            try
            {
                var uiDel = Assets.Sources.Modules.Ui.UiModeDelegate.Instance;
                var uiMode = (uiDel != null) ? uiDel.UiMode : null;
                var killModel = (uiMode != null)
                    ? uiMode.GetModel<Assets.Sources.Ui.Model.Common.KillMessageModel>() : null;
                bool notify22 = false;
                NotifyEvent.INotify notifyObj;
                notify22 = NotifyEvent.NotifyManager.TryGetNotify(22, out notifyObj);
                bool hitCross = false;
                try { hitCross = Contexts.sharedInstance.cross.hitCross != null; } catch (System.Exception) { }
                int autoCount = 0;
                try { autoCount = SSJJBase.Singleton.MonoBehaviourSingleton<Assets.Scripts.Utility.Sound.AutoSoundManager>.Instance.AutoConfigs.Count; } catch (System.Exception) { }
                Debug.Log("[OFFLINE-UIPROBE] uiMode=" + (uiMode != null)
                    + " killMessage=" + (killModel != null)
                    + " notify22=" + notify22
                    + " hitCross=" + hitCross
                    + " autoSound=" + autoCount);
            }
            catch (System.Exception ex)
            {
                Debug.LogWarning("[OFFLINE-UIPROBE] failed: " + ex.Message);
            }
        }

        if (OfflineTdmMatch.Active)
        {
            // TDM 自己管计时与胜负，本地 _roundTimer 只做 HUD 镜像，不再触发本地 RoundOver。
            _roundTimer = OfflineTdmMatch.RemainingSeconds;
        }
        else if (!RoundOver)
        {
            _roundTimer -= Time.deltaTime;
            if (_roundTimer <= 0f)
            {
                RoundOver = true;
                RoundResult = (PlayerKills > BotKills) ? "胜利" : (PlayerKills == BotKills ? "平局" : "失败");
                Debug.Log("[OFFLINE-ROUND] over result=" + RoundResult +
                          " player=" + PlayerKills + " bot=" + BotKills);
            }
        }
		if (IsExplodeMode()) UpdateExplodeMode(s);

        // [OFFLINE-TDM] 调试热键（仅 TDM）：F10 立即结束，F9 重开一局。
        // F7/F8 已被 OfflineFirstPersonRig 占用，这里避开。
        if (OfflineTdmMatch.Active && !OfflineHud.IsModalPanelOpen)
        {
            if (Input.GetKeyDown(KeyCode.F10))
            {
                Debug.Log("[OFFLINE-TDM] debug F10 forceEnd team=1");
                OfflineTdmMatch.ForceEnd(1, "debug-f10");
            }
            if (Input.GetKeyDown(KeyCode.F9))
            {
                Debug.Log("[OFFLINE-TDM] debug F9 restart");
                OfflineTdmMatch.RestartMatch();
            }
        }

        // [OFFLINE-PATCH] 无敌模式：F2 切换；开启时血量恒满（把已扣的血补回来）。
        if (!OfflineHud.IsModalPanelOpen && Input.GetKeyDown(KeyCode.F2))
        {
            GodMode = !GodMode;
            Debug.Log("[OFFLINE-GOD] god mode " + (GodMode ? "ON" : "OFF"));
        }

        // [OFFLINE-PATCH] F3 切换第一/第三人称：TpsCameraLogic.IsActive() 读 cameraData.IsTps，
        // 置 true 后相机逻辑切 TPS、SwitchPersonViewSystem 打 isThirdPersonView、
        // SwitchThirdPersonSystem 激活第三人称模型根节点，即可看到人物建模。
        if (!OfflineHud.IsModalPanelOpen && Input.GetKeyDown(KeyCode.F3))
        {
            var wc = Contexts.sharedInstance.worldCamera;
            if (wc.hasCameraData)
            {
                wc.cameraData.IsTps = !wc.cameraData.IsTps;
                Debug.Log("[OFFLINE-TP] third person " + (wc.cameraData.IsTps ? "ON" : "OFF"));
            }
            else
            {
                Debug.Log("[OFFLINE-TP] worldCamera has no cameraData component");
            }
        }

        // [OFFLINE-TP] 参考 VapeV4 HookManager.IsActive_Hook：
        // 原版 TpsCameraLogic.IsActive 只在 IsTPS(career) 时才写 Fov/YawAdd/PitchAdd/TransTime，
        // 普通职业下这些字段不更新 → GetCalculateCameraEndPos 用陈旧角度 → 相机卡进人物 → 模糊。
        // 这里在 TP 开启时每帧补上（角度取相机所有者的 orientation，和 VapeV4 同源）。
        if (Contexts.sharedInstance.worldCamera.hasCameraData
            && Contexts.sharedInstance.worldCamera.cameraData.IsTps)
        {
            var wcTp = Contexts.sharedInstance.worldCamera.cameraData;
            var ownerTp = Contexts.sharedInstance.player.cameraOwnerEntity;
            if (ownerTp != null)
            {
                wcTp.Fov = 90;
                wcTp.CameraYawAddValue = ownerTp.orientation.Yaw;
                wcTp.CameraPitchAddValue = ownerTp.orientation.Pitch - 5f;
                wcTp.TransTime = Mathf.Max(230, wcTp.TransTime + Contexts.sharedInstance.time.time.FrameInterval);
            }
        }
        if (GodMode && !OfflineTdmMatch.PlayerDead)
        {
            PlayerEntityData meGod;
            if (s.PlayerEntityDataDict.TryGetValue(s.Self, out meGod))
            {
                // [OFFLINE-TDM] 死亡倒计时期间不回血，避免把 Hp 从 0 补满干扰复活表现
                if (!meGod.IsDead && meGod.Hp > 0f)
                {
                    float maxHp = meGod.MaxHp > 0f ? meGod.MaxHp : 100f;
                    if (meGod.Hp < maxHp) meGod.Hp = maxHp;
                }
            }
        }

        // [OFFLINE-BOT-AI] 初始化 bot 的 AI 状态（感知/决策/战斗三层）
        foreach (var kv in s.PlayerEntityDataDict)
        {
            if (kv.Key < Assets.Sources.Systems.Snapshot.OfflineBotSpawner.FirstBotId) continue;
            if (!OfflineBotSpawner.IsTrainingBotActive(kv.Key)) continue;
            if (_agents.ContainsKey(kv.Key)) continue;
            _agents[kv.Key] = CreateBotAgent(kv.Key, kv.Value);
        }

        Vector3 selfPos = Vector3.zero;
        bool haveSelf = s.PlayerEntityDataDict.TryGetValue(s.Self, out var selfData);
        if (haveSelf && selfData != null)
        {
            selfPos = OfflineBotSpawner.GetUnityPos(selfData);
            FillPlayerContractFields(selfData);
        }
        Vector3 playerVelocity = Vector3.zero;
        if (haveSelf && selfData != null && !selfData.IsDead && _hasSelfVelocitySample)
        {
            playerVelocity = (selfPos - _prevSelfPos) / Mathf.Max(0.001f, Time.deltaTime);
            // 复活、地图切换或瞬移不能被解释成角色的正常移动速度。
            if (playerVelocity.sqrMagnitude > 400f) playerVelocity = Vector3.zero;
        }
        _selfVelocity = playerVelocity;
        // [OFFLINE-TDM] 死亡 / 复活倒计时期间屏蔽玩家的开火/投掷/拾取/技能输入（引擎自身移动/相机保留）
        bool playerInputBlocked = RoundOver || OfflineHud.IsModalPanelOpen
            || (haveSelf && selfData != null
                && (selfData.IsDead || selfData.Hp <= 0f || OfflineTdmMatch.PlayerDead));
        // 保证测试/离线演示中至少有一个活着的 Bot 持续落在玩家 Eye 相机视口内。
        // 原来的“出生时尝试一次”会在相机尚未就绪或 AI 追击后失效，导致所有 Bot
        // 都在屏幕后方/视口外，误判成模型透明。这里按当前相机动态纠正一个 Bot。
        // [OFFLINE-TDM] 团队模式禁用该视觉锚定，否则会把 bot 从阵营战场拖到玩家脸上。
        if (!OfflineTdmMatch.Active) EnsureVisibleBot(s, selfPos, haveSelf);

        // [OFFLINE-PATCH] 换弹：R 键 / 打空自动换，离线没有服务器回包，这里本地结算。
        if (!playerInputBlocked && Input.GetKeyDown(KeyCode.R)) StartReload();
        // [OFFLINE-PATCH] V 键武器检视：原版由 UserCmd.IsShowGun 驱动 SetViewAnimation(44)，离线本地触发。
        // [OFFLINE-GRENADE] G：切到投掷物并投出；丢枪改到 X。
        if (!playerInputBlocked && Input.GetKeyDown(KeyCode.G))
        {
            WeaponEntity gw = Contexts.sharedInstance.weapon.currentWeaponEntity;
            bool gThrow = IsThrowableWeapon(gw);
            if (!gThrow)
            {
                OfflineGameController ctrl = UnityEngine.Object.FindObjectOfType<OfflineGameController>();
                if (ctrl != null) ctrl.TrySwitchWeapon(4);
                gw = Contexts.sharedInstance.weapon.currentWeaponEntity;
                gThrow = IsThrowableWeapon(gw);
                UnityEngine.Debug.Log("[OFFLINE-GRENADE] G switch ok=" + gThrow + " cur=" + ((gw != null && gw.hasBasicInfo && gw.basicInfo.Data != null) ? gw.basicInfo.Data.WeaponName : "-"));
            }
            if (gThrow && Time.time >= _nextThrow) ThrowGrenade();
        }
        if (!playerInputBlocked && Input.GetKeyDown(KeyCode.X)) DropCurrentWeapon();
        if (!playerInputBlocked && Input.GetKeyDown(KeyCode.E))
        {
            // [OFFLINE-SKILL] 原版 E 就是技能键（UserCmd.isSkill 0x1000 / Demolition 0x800）；拾取改到 C。
            if (!OfflineWeaponSkill.TryUse(this))
            {
                if (!IsExplodeMode() || !HandleExplodeInteract()) PickupNearestWeapon();
            }
        }
        if (!playerInputBlocked && Input.GetKeyDown(KeyCode.C))
        {
            if (!IsExplodeMode() || !HandleExplodeInteract()) PickupNearestWeapon();
        }
        // [OFFLINE-PATCH] K 键武器技能（H 是调试信息，F 是飞行）：原版按武器专属技能系统结算，离线做通用近似
        // （播放技能视图动画 + 前方锥形范围伤害）。
        if (!playerInputBlocked && Input.GetKeyDown(KeyCode.K))
        {
            // K 保留为调试别名（技能冷却由执行器内部管理）。
            OfflineWeaponSkill.TryUse(this);
        }
        if (!OfflineHud.IsModalPanelOpen && Input.GetKeyDown(KeyCode.V))
        {
            try
            {
                WeaponEntity vWeapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
                if (!OfflineWeaponSkill.HasNativeShowGunHandler(vWeapon))
                {
                    PlayerEntity meView = Contexts.sharedInstance.player.myPlayerEntity;
                    if (meView != null && meView.hasViewAnim && meView.viewAnim.ViewAnimInfo != null)
                    {
                        int curAnim = ((IAnimStateInfo)meView.viewAnim.ViewAnimInfo).StateId;
                        if (curAnim == 13 || curAnim == 14 || curAnim == 39 || curAnim == 48 || curAnim <= 0)
                        {
                            Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(meView, 44);
                            UnityEngine.Debug.Log("[OFFLINE-INSPECT] V pressed -> state 44");
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                UnityEngine.Debug.LogWarning("[OFFLINE-INSPECT] fail " + ex.Message);
            }
        }
        // [OFFLINE-SPRAY] T 喷漆（Shift+T 轮换图案）：命中/冷却/实体全在 OfflineSpray，
        // 这里只做按键分发，不掺 Bot/武器逻辑。
        if (Input.GetKeyDown(KeyCode.T) && !OfflineHud.IsModalPanelOpen)
        {
            OfflineSpray.TrySpray(Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift));
        }
        // [OFFLINE-MELEE] 当前武器变化时，dump 它的全部视图动画名，便于定位特殊武器。
        try
        {
            WeaponEntity cwDump = Contexts.sharedInstance.weapon.currentWeaponEntity;
            if (cwDump != null && cwDump.hasBasicInfo && cwDump.basicInfo.Info != null && cwDump.basicInfo.Data != null)
            {
                string wnDump = cwDump.basicInfo.Data.WeaponName;
                if (wnDump != _dumpWeapon)
                {
                    _dumpWeapon = wnDump;
                    UnityEngine.Debug.Log("[OFFLINE-MELEE] dump " + wnDump + " : " + Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.DumpAllViewAnimNames(cwDump.basicInfo.Info));
                }
            }
        }
        catch (System.Exception) { }
        // 长按攻击期间持续压掉切刀出场状态，防止 Raise 动画叠加。
        try
        {
            WeaponEntity cwRaise = Contexts.sharedInstance.weapon.currentWeaponEntity;
            if (cwRaise != null && cwRaise.hasSpecial && Input.GetMouseButton(0)) cwRaise.special.IsRaise = false;
        }
        catch (System.Exception) { }
        // [OFFLINE-ANIM] 动画计时完全交给原版 PlayerViewPredictionSystem/PlaybackSystem，
        // 本地不再写 ViewAnimationTimer（之前两边同时写会导致开火动画闪/回跳）。
        // [OFFLINE-VIEWTIMER] 原版动画计时：本地维护 RemainTime 并写回快照，
        // 让 ViewAnimSystem 按完整时长回放（离线没有服务器下发 ViewAnimationTimer）。
        try
        {
            PlayerEntity meV = Contexts.sharedInstance.player.myPlayerEntity;
            if (meV != null && meV.hasViewAnim && meV.hasBasicInfo && meV.basicInfo.Current != null)
            {
                int stV = ((IAnimStateInfo)meV.viewAnim.ViewAnimInfo).StateId;
                // [OFFLINE-MELEE] 同一状态再次出手（如普通刀连续两次 31）时原版会重新
                // SetViewAnimation 并把 RightCurrentTime 归零；只看状态 id 会把第二次连击
                // 当成“已在末帧”直接跳过，这里用时间回退识别重触发并重新计时。
                int rcV = meV.viewAnim.RightCurrentTime;
                bool retrigger = rcV + 2 < _viewTimerRight;
                _viewTimerRight = rcV;
                if (stV != _viewTimerState || retrigger)
                {
                    _viewTimerState = stV;
                    _viewStateSince = Time.time;
                    bool loop = ((IAnimStateInfo)meV.viewAnim.ViewAnimInfo).IsLoop;
                    int dur = 0;
                    if (!loop && meV.hasCurrentWeapon && meV.currentWeapon.WeaponInfo != null)
                    {
                        IWeaponAnimInfo wi = WeaponAnimInfoFactory.Instance.GetWeaponAnimInfo(meV.currentWeapon.WeaponInfo);
                        dur = (wi != null) ? wi.GetViewAnimDuration(stV) : 0;
                        if (dur <= 0 && meV.hasFirstPersonUnityObjects && meV.firstPersonUnityObjects.HandAnimator != null)
                        {
                            dur = (int)(meV.firstPersonUnityObjects.HandAnimator.GetAnimDuration(0, meV.viewAnim.ViewAnimInfo.AnimationName) * 1000f);
                        }
                    }
                    _viewTimerRemain = Mathf.Max(0, dur);
                    if (retrigger && Time.realtimeSinceStartup - s_viewRetrigT > 0.25f)
                    {
                        s_viewRetrigT = Time.realtimeSinceStartup;
                        Debug.Log("[OFFLINE-VIEWTIMER] retrigger state=" + stV + " dur=" + dur);
                    }
                }
                else if (_viewTimerRemain > 0)
                {
                    _viewTimerRemain -= (int)(Time.deltaTime * 1000f);
                    if (_viewTimerRemain < 0) _viewTimerRemain = 0;
                }
                meV.viewAnim.RemainTime = _viewTimerRemain;
                meV.viewAnim.SnapshotRemainTime = _viewTimerRemain;
                meV.basicInfo.Current.ViewAnimationTimer = _viewTimerRemain;
                if (meV.basicInfo.Next != null) meV.basicInfo.Next.ViewAnimationTimer = _viewTimerRemain;
                meV.basicInfo.SnapsotServerTime = Contexts.sharedInstance.time.time.RenderTime;
                ISnapshot snapV = Snap();
                PlayerEntityData selfV;
                if (snapV != null && snapV.PlayerEntityDataDict != null && snapV.PlayerEntityDataDict.TryGetValue(snapV.Self, out selfV))
                {
                    selfV.ViewAnimationTimer = _viewTimerRemain;
                }
            }
        }
        catch (System.Exception) { }
        // [OFFLINE-WEAPON] 切枪出场：等新武器第一人称模型/动画器就绪后立刻播 RAISE，
        // 期间持续压住待机，避免出现“静态 -> 出场 -> 静态”。
        if (PendingRaiseAt > 0f && Time.time >= PendingRaiseAt)
        {
            try
            {
                PlayerEntity meR = Contexts.sharedInstance.player.myPlayerEntity;
                WeaponEntity wR = Contexts.sharedInstance.weapon.currentWeaponEntity;
                bool ready = meR != null && meR.hasFirstPersonUnityObjects && meR.firstPersonUnityObjects.HandAnimator != null;
                if (ready && wR != null && wR.hasBasicInfo && wR.basicInfo.Info != null && meR.hasViewAnim)
                {
                    int rid = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindViewAnimByName(wR.basicInfo.Info, "TORSO_RAISE");
                    if (rid <= 0) rid = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindViewAnimByName(wR.basicInfo.Info, "TORSO_STAND");
                    if (rid > 0)
                    {
                        Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(meR, rid);
                        _viewTimerState = -1;   // 强制重新按 RAISE 的时长起播
                        SuppressIdleUntil = Time.time + 0.6f;
                        PendingRaiseAt = 0f;
                        UnityEngine.Debug.Log("[OFFLINE-WEAPON] raise ready id=" + rid + " weapon=" + wR.basicInfo.Data.WeaponName);
                    }
                }
                else if (Time.time > PendingRaiseAt + 1.5f)
                {
                    PendingRaiseAt = 0f;
                    UnityEngine.Debug.LogWarning("[OFFLINE-WEAPON] raise timeout (model not ready)");
                }
                // 模型已就绪但动画配置还没加载完时不能一直每帧重试，超时后交回待机。
                if (PendingRaiseAt > 0f && Time.time > PendingRaiseAt + 3f)
                {
                    PendingRaiseAt = 0f;
                    UnityEngine.Debug.LogWarning("[OFFLINE-WEAPON] raise timeout (anim config not loaded)");
                }
            }
            catch (System.Exception) { }
        }
        // [OFFLINE-ROUND] 回合计时结束后只停射击/命中/Bot 这些战斗逻辑；
        // 动画计时、PendingRaiseAt 出场、UpdateAttackViewAnim 仍要跑，
        // 否则回合结束再切枪没出场动画、AttackAnimActive 还会卡住。
        // [OFFLINE-MODE] 模式规则：刀锋战士/飞刀强制近战；武器大师击杀进阶；个人战各自为战。
        try
        {
            int modeId = (OfflineGameController.setting != null) ? OfflineGameController.setting.RaceType : 3;
            OfflineModeTable.Profile modeProf = OfflineModeTable.Get(modeId);
            bool meleeOnly = (modeProf != null && modeProf.MeleeOnly) || modeId == 74;
            if (meleeOnly && !_modeLoadoutApplied)
            {
                _modeLoadoutApplied = true;
                OfflineGameController ctrlMode = UnityEngine.Object.FindObjectOfType<OfflineGameController>();
                // 刀锋战士：背包已被 OfflineModeTable 裁成"三槽全近战"，直接拿槽 1
                // 飞刀战：保持原逻辑拿槽 3（近战槽）
                int wantSlot = (modeProf != null && modeProf.MeleeOnly) ? 1 : 3;
                if (ctrlMode != null) ctrlMode.TrySwitchWeapon(wantSlot);
                UnityEngine.Debug.Log("[OFFLINE-MODE] melee-only mode=" + modeId + " slot=" + wantSlot
                    + " profile=" + OfflineModeTable.Describe(modeId));
            }
        }
        catch (System.Exception) { }
        UpdateAttackViewAnim();
        UpdateReload();
        UpdateGrenades();
        // [OFFLINE-TDM] Bot 投掷物推进/爆炸
        UpdateBotGrenades();
        // [OFFLINE-SNAPSHOT-GRENADE] 爆炸事件 3 帧后清出快照（防每帧重复加载特效）
        CleanupExplosionEvents();
        // [OFFLINE-SKILL] 技能执行器：蓄力/投射物/持续区域每帧推进。
        OfflineWeaponSkill.Tick(this);
        if (_returnToPrimaryAt > 0f && Time.time >= _returnToPrimaryAt)
        {
            _returnToPrimaryAt = 0f;
            OfflineGameController ctrlBack = UnityEngine.Object.FindObjectOfType<OfflineGameController>();
            if (ctrlBack != null)
            {
                WeaponEntity cwNow = Contexts.sharedInstance.weapon.currentWeaponEntity;
                if (IsThrowableWeapon(cwNow))
                {
                    ctrlBack.TrySwitchWeapon(1);
                    UnityEngine.Debug.Log("[OFFLINE-GRENADE] return to primary after throw");
                }
            }
        }
        UpdateSkillState();
        RestoreFpIdle();
        EnsureDefaultWeapon();
        UpdateDroppedWeapons();
        UpdateFlyKnifeProjectiles();
        UpdateYaoguangDarts();

        if (RoundOver) return;

        // [OFFLINE-GRENADE] 投掷物使用左键直接投出，不受步枪射速门控影响。
        if (!playerInputBlocked && haveSelf && Input.GetMouseButtonDown(0) && !OfflineHud.IsModalPanelOpen)
        {
            WeaponEntity tw = Contexts.sharedInstance.weapon.currentWeaponEntity;
            if (IsThrowableWeapon(tw) && Time.time >= _nextThrow)
            {
                ThrowGrenade();
            }
        }
        // [OFFLINE-FLYKNIFE] 飞刀模式使用本地投射物，不走近战瞬时射线。
        if (!playerInputBlocked && haveSelf && Input.GetMouseButtonDown(0) && !OfflineHud.IsModalPanelOpen
            && OfflineGameController.setting != null && OfflineGameController.setting.RaceType == 74)
        {
            WeaponEntity fk = Contexts.sharedInstance.weapon.currentWeaponEntity;
            if (fk != null && fk.hasBasicInfo && fk.basicInfo.Data != null && IsMeleeName(fk.basicInfo.Data.WeaponName))
            {
                ThrowFlyKnife();
            }
        }
        // [OFFLINE-SHOOT-DIAG] 观察原版攻击链是否在离线运行（ShotsFired / 后坐力 / 动画态）。
        if (haveSelf && Input.GetMouseButton(0) && Time.time - _lastShootDiag > 1f)
        {
            _lastShootDiag = Time.time;
            try
            {
                PlayerEntity meD = Contexts.sharedInstance.player.myPlayerEntity;
                WeaponEntity wD = Contexts.sharedInstance.weapon.currentWeaponEntity;
                if (meD != null && wD != null && wD.hasAttack && wD.hasBasicInfo && wD.basicInfo.Data != null)
                {
                    UnityEngine.Debug.Log("[OFFLINE-SHOOT-DIAG] weapon=" + wD.basicInfo.Data.WeaponName
                        + " shotsFired=" + wD.attack.ShotsFired
                        + " nextAtk=" + wD.attack.NextAttackTimer
                        + " punch=(" + meD.punchOrientation.PunchPitch.ToString("F2") + "," + meD.punchOrientation.PunchYaw.ToString("F2") + ")"
                        + " view=" + ((IAnimStateInfo)meD.viewAnim.ViewAnimInfo).StateId
                        + " clip=" + (wD.hasClip ? wD.clip.Clip.ToString() : "-"));
                }
            }
            catch (System.Exception ex) { UnityEngine.Debug.LogWarning("[OFFLINE-SHOOT-DIAG] " + ex.Message); }
        }
        // 玩家开火：左键；近战武器同时支持右键重击（一击毙命）及原版 MeleeAttack 多段判定
        WeaponEntity curWeaponForInput = Contexts.sharedInstance.weapon.currentWeaponEntity;
        bool curIsMeleeForInput = IsMeleeWeapon(curWeaponForInput);
        bool nativeMeleeEdge = false;
        if (curIsMeleeForInput && curWeaponForInput != null && curWeaponForInput.hasMeleeAttack)
        {
            bool curMeleeAtk = curWeaponForInput.meleeAttack.MeleeAttack;
            if (curMeleeAtk && !_prevMeleeAttack && Time.time >= _suppressNativeMeleeUntil)
            {
                nativeMeleeEdge = true;
            }
            _prevMeleeAttack = curMeleeAtk;
        }
        else
        {
            _prevMeleeAttack = false;
        }
        bool leftAttack = Input.GetMouseButton(0);
        bool rightAttack = curIsMeleeForInput && Input.GetMouseButton(1);
        bool normalFireReady = (leftAttack || rightAttack) && Time.time >= _nextFire;
        if (!playerInputBlocked && haveSelf && (nativeMeleeEdge || normalFireReady) && !OfflineHud.IsModalPanelOpen)
        {
            WeaponEntity weapon = curWeaponForInput;
            float interval = 0.12f;
            bool canShoot = true;
            bool throwableNow = false;
            bool bloodDemonAwm = false;
            bool heavyMelee = curIsMeleeForInput && ((rightAttack && !leftAttack) || (nativeMeleeEdge && !leftAttack && !rightAttack && _lastMeleeHeavy));
            if (weapon != null && weapon.hasBasicInfo && weapon.basicInfo.Data != null)
            {
                string wn = weapon.basicInfo.Data.WeaponName;
                bloodDemonAwm = string.Equals(wn, "awm_legend_t", System.StringComparison.OrdinalIgnoreCase);
                bool melee = IsMeleeWeapon(weapon);
                bool throwable = IsThrowableWeapon(weapon);
                int modeNow = (OfflineGameController.setting != null) ? OfflineGameController.setting.RaceType : 3;
                if ((modeNow == 15 || modeNow == 74 || modeNow == 2041) && !melee && !throwable)
                {
                    canShoot = false;
                    throwableNow = false;
                }
                 if (modeNow == 74 && melee)
                 {
                     // 飞刀已经在 MouseButtonDown 分支中发射；长按只保留动画，不产生瞬时伤害。
                     canShoot = false;
                 }
                throwableNow = throwable;
                if (weapon.basicInfo.Info != null && weapon.basicInfo.Info.AttackInterval > 0)
                {
                    // 血魔原版是 1200ms 半自动狙击枪；本地门控不能比原版射速更快，
                    // 也不能把它截成 1 秒，否则点击输入和原版 ShotsFired 采样会错位。
                    interval = Mathf.Clamp(weapon.basicInfo.Info.AttackInterval / 1000f,
                        0.05f, bloodDemonAwm ? 2.5f : 1f);
                }
                if (heavyMelee) interval = Mathf.Max(interval, 0.72f);
                // [OFFLINE-ANIM] 弹匣与原版攻击链一致：由原版 action 扣弹/换弹，本地不再重复扣。
            }
            _nextFire = Time.time + interval;
            _lastFireAt = Time.time;
            if (curIsMeleeForInput && normalFireReady)
            {
                _suppressNativeMeleeUntil = Time.time + Mathf.Max(0.25f, interval * 0.95f);
                _lastMeleeHeavy = heavyMelee;
            }
            // [OFFLINE-BOT-AI] 听觉：玩家开枪会被附近的 bot 听到，它们会赶来搜索。
            NotifyBotsHeardNoise();
            // [OFFLINE-ANIM] 开火/攻击动画完全交给原版攻击链（action 写 ViewAnim + 原版 ViewAnimSystem 播放），
            // 本地不再 SetViewAnimation，避免每枪把动画状态重置导致闪烁。
            if (throwableNow)
            {
                // [OFFLINE-PATCH] 手雷：单击投出（不再走即时射线伤害）。
                if (Input.GetMouseButtonDown(0) && Time.time >= _nextThrow)
                {
                    ThrowGrenade();
                }
                canShoot = false;
            }
            if (canShoot)
            {
                WeaponEntity wShot = Contexts.sharedInstance.weapon.currentWeaponEntity;
                bool meleeShot = IsMeleeWeapon(wShot);
                int shots = 0;
                if (wShot != null && wShot.hasAttack)
                {
                    int wid = (wShot.hasBasicInfo && wShot.basicInfo.Data != null) ? wShot.basicInfo.Data.Id : 0;
                    if (_lastShotWeaponId != wid)
                    {
                        _lastShotWeaponId = wid;
                        _lastShotsFired = wShot.attack.ShotsFired;
                    }
                    if (wShot.attack.ShotsFired != _lastShotsFired)
                    {
                        shots = wShot.attack.ShotsFired - _lastShotsFired;
                        if (shots < 0) shots = 1;
                        _lastShotsFired = wShot.attack.ShotsFired;
                    }
                }
                // awm_legend_t 的原版攻击计数在离线模式下可能只存在一个很短的帧窗口。
                // 以真实鼠标按下作为该枪单发的离线兜底；ShotsFired 已捕获时不重复结算。
                if (bloodDemonAwm && shots == 0 && Input.GetMouseButtonDown(0))
                {
                    shots = 1;
                    if (wShot != null && wShot.hasAttack) _lastShotsFired = wShot.attack.ShotsFired;
                    Debug.Log("[OFFLINE-SHOT-FALLBACK] weapon=awm_legend_t source=mouse-down shots=1");
                }
                // 近战没有枪械射击计数，仍按本地节奏结算一刀；枪械严格按原版每枪一次。
                if (meleeShot) shots = 1;
                if (shots > 0)
                {
                    // [OFFLINE-ANIM] 原版攻击链已经改写 ViewAnim 时只交给 ViewAnimSystem 播放，
                    // 不再从头手动重播同一动作；离线攻击链没写状态时才补设一次原版动画状态。
                    try
                    {
                        PlayerEntity meA = Contexts.sharedInstance.player.myPlayerEntity;
                        if (meA != null && meA.hasViewAnim && wShot != null && wShot.hasBasicInfo)
                        {
                            int animId = ((IAnimStateInfo)meA.viewAnim.ViewAnimInfo).StateId;
                            bool originalAttack = animId > 0 && animId != 13 && animId != 14 && animId != 16;
                            if (originalAttack)
                            {
                                AttackAnimActive = false;
                                PendingRaiseAt = 0f;
                                if (wShot.hasSpecial) wShot.special.IsRaise = false;
                            }
                            else
                            {
                                int fallbackAnim = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindAttackViewAnim(
                                    wShot.basicInfo.Info, meleeShot);
                                if (fallbackAnim > 0) PlayAttackViewAnim(wShot, fallbackAnim);
                            }
                        }
                    }
                    catch (System.Exception) { }
                    // [OFFLINE-FIX] 玩家眼位相机是 "Eye"；"Main Camera" 在原点附近，
                    // 用它当射线起点会导致所有子弹从地图原点打出，永远打不中 bot。
                    Camera cam = null;
                    Camera[] cams = Camera.allCameras;
                    for (int i = 0; i < cams.Length; i++)
                    {
                        if (cams[i] != null && cams[i].name == "Eye") { cam = cams[i]; break; }
                    }
                    if (cam == null)
                    {
                        for (int i = 0; i < cams.Length; i++)
                        {
                            if (cams[i] != null && cams[i].name == "Main Camera") { cam = cams[i]; break; }
                        }
                    }
                    if (cam == null && cams.Length > 0) cam = Camera.main != null ? Camera.main : cams[0];
                    if (cam != null)
                    {
                        int n = Mathf.Min(shots, 4);
                        for (int k = 0; k < n; k++)
                        {
                            Vector3 dir = cam.transform.forward;
                            if (!meleeShot)
                            {
                                // 轻微散布：原版散布/后坐由引擎负责，这里只补一点点随机，避免一条直线。
                                float sp = 0.25f;
                                dir = Quaternion.Euler(Random.Range(-sp, sp), Random.Range(-sp, sp), 0f) * dir;
                            }
                            bool rayHeadshot;
                            float maxRangeCm = 20000f;
                            if (meleeShot)
                            {
                                maxRangeCm = 280f;
                                try
                                {
                                    var dwi = wShot.basicInfo.Info as Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo;
                                    if (dwi != null && dwi.ShotDistanceLogic != null)
                                    {
                                        var cmdNow = Contexts.sharedInstance.userCommand.commands.getCurrentCmd();
                                        float sd = dwi.ShotDistanceLogic.GetShotDistance(cmdNow, wShot, heavyMelee);
                                        if (sd > 10f) maxRangeCm = Mathf.Max(280f, sd * 1.5f);
                                    }
                                }
                                catch (System.Exception) { }
                            }
                            bool specialActive = wShot != null && wShot.hasSpecial && wShot.special.SpecialMode;
                            int hit = NearestBotInRange(cam.transform.position, dir, maxRangeCm, out rayHeadshot);
                            // [OFFLINE-FIRE-DIAG] 限频打印开火真值，定位打不中的环节
                            if (UnityEngine.Time.realtimeSinceStartup - s_fireDiag > 0.4f)
                            {
                                s_fireDiag = UnityEngine.Time.realtimeSinceStartup;
                                UnityEngine.Debug.Log("[OFFLINE-FIRE] cam=" + cam.name
                                    + " from=" + cam.transform.position.ToString("F1")
                                    + " dir=" + dir.ToString("F2")
                                    + " shots=" + shots + " melee=" + meleeShot + " heavy=" + heavyMelee
                                    + " rangeCm=" + maxRangeCm.ToString("F0") + " hit=" + hit);
                            }
                            if (meleeShot)
                            {
                                // 近战多目标锥形判定（特殊态全锥形、普通挥砍最多 3 个目标），并回复武器能量
                                List<int> coneHits = GetBotsInCone(cam.transform.position, dir, maxRangeCm, specialActive ? 0.45f : 0.65f, specialActive ? 8 : 3);
                                if (hit >= 0 && !coneHits.Contains(hit)) coneHits.Insert(0, hit);
                                float meleeDmg = specialActive ? 140f : (heavyMelee ? 120f : 55f);
                                string shotWeaponName = wShot != null && wShot.hasBasicInfo && wShot.basicInfo.Data != null
                                    ? wShot.basicInfo.Data.WeaponName : "unknown";
                                for (int ci = 0; ci < coneHits.Count; ci++)
                                {
                                    int cid = coneHits[ci];
                                    try { Contexts.sharedInstance.cross.hitCross.ChangRedTime = 200; }
                                    catch (System.Exception) { }
                                    bool hs = (cid == hit) && rayHeadshot;
                                    Debug.Log("[OFFLINE-WEAPON-HIT] weapon=" + shotWeaponName
                                        + " baseDamage=" + meleeDmg.ToString("F0") + " headshot=" + hs + " target=" + cid);
                                    KillBot(cid, meleeDmg, hs, true);
                                    OfflineWeaponSkill.AddPower(wShot, 20);
                                }
                            }
                            else if (hit >= 0)
                            {
                                // [OFFLINE-HITMARK] 原版 HitPlayerHandler(method 131) 只做这一件事：
                                // cross.hitCross.ChangRedTime=200，HitCrossUpdateSystem 递减、HitCrossModel 显示。
                                // 离线没有服务端 131，这里在玩家射线命中时补上同一个字段。
                                try { Contexts.sharedInstance.cross.hitCross.ChangRedTime = 200; }
                                catch (System.Exception) { }
                                float shotDamage = ResolvePlayerShotDamage(wShot, false);
                                string shotWeaponName = wShot != null && wShot.hasBasicInfo && wShot.basicInfo.Data != null
                                    ? wShot.basicInfo.Data.WeaponName : "unknown";
                                if (string.Equals(shotWeaponName, "awm_legend_t", System.StringComparison.OrdinalIgnoreCase)
                                    && !OfflineTdmMatch.IsProtected(hit))
                                    ApplyAwmKnockback(hit, dir);
                                Debug.Log("[OFFLINE-WEAPON-HIT] weapon=" + shotWeaponName
                                    + " baseDamage=" + shotDamage.ToString("F0") + " headshot=" + rayHeadshot + " target=" + hit);
                                KillBot(hit, shotDamage, rayHeadshot, false);
                            }
                        }
                    }
                }
            }
        }

        foreach (var kv in _agents)
        {
            var data = Get(s, kv.Key);
            if (data == null) continue;
            TickBot(kv.Value, data, haveSelf, selfPos);
        }
        // [OFFLINE-SPAWN-VISIBLE] AI 可能把所有 bot 带到 Eye 视野外；每隔一小段时间
        // 重新把至少一个存活 bot 锚定到相机前方，并冻结一个短窗口，让实体同步/渲染
        // 有机会稳定下来。这里改的是快照位置与 AI 目标，不涉及任何渲染兜底。
        // 禁用强制视野锚定：相机坐标与 AI 坐标制式不同会造成队友叠点/瞬移。
        EnsureNavBaked(s);
        _prevSelfPos = selfPos;
        _hasSelfVelocitySample = haveSelf && selfData != null && !selfData.IsDead;

        // 诊断：每 6 秒报告 bot 位置，确认 AI 在动
        if (Time.time >= _nextBotLog)
        {
            _nextBotLog = Time.time + 6f;
            string line = "";
            foreach (var kv in _agents)
            {
                var d = Get(s, kv.Key);
                if (d == null) { line += kv.Key + ":gone "; continue; }
                Vector3 p = OfflineBotSpawner.GetUnityPos(d);
                // [OFFLINE-SYNC-DIAG] 同时报告实体 basicInfo 的位置：
                // data 在动而 ent 不跟 -> 是位置同步断了（渲染停在原地）
                // data 也不动 -> 是 AI 没给出有效目标
                Vector3 entPos = new Vector3(-9999f, -9999f, -9999f);
                bool entFound = false;
                try
                {
                    foreach (PlayerEntity pe in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
                    {
                        if (pe.entityId.Value != kv.Key) continue;
                        entFound = true;
                        if (pe.hasBasicInfo && pe.basicInfo.Current != null)
                        {
                            entPos = new Vector3(-(float)pe.basicInfo.Current.Y / 100f,
                                (float)pe.basicInfo.Current.Z / 100f,
                                (float)pe.basicInfo.Current.X / 100f);
                        }
                        break;
                    }
                }
                catch (System.Exception) { }
                line += kv.Key + "[" + kv.Value.State + (kv.Value.Ally ? "/ally" : "/foe")
                    + " tgt=" + kv.Value.TargetId + "]"
                    + " data=" + p.ToString("F0")
                    + " ent=" + (entFound ? entPos.ToString("F0") : "none")
                    + " hp=" + d.Hp.ToString("F0") + (d.IsDead ? "D" : "")
                    + " kd=" + kv.Value.Kills + "/" + kv.Value.Deaths + " ";
            }
            Debug.Log("[OFFLINE-AI] threats=" + _threats.Count + " " + line);
        }
    }

    private float _nextBotLog;
    private float _nextVisibleBotCheck;
    private float _lastVisibleBotAnchorLog;

    /// <summary>
    /// [OFFLINE-SPAWN-VISIBLE] 保证至少一个存活 bot 落在 Eye 相机视野内。
    ///
    /// 原来的近玩家出生只在开局/复活时尝试一次；AI 一旦从 BSP 出生点开始移动，
    /// 几秒内就可能把所有 bot 带出屏幕。这里按短周期检查当前投影，若没有可见 bot，
    /// 就把最靠前的存活 bot 放到相机前方可站立点，并暂时锁住它的移动目标。
    /// </summary>
    private void EnsureVisibleBot(ISnapshot snap, bool haveSelf, PlayerEntityData selfData)
    {
        float now = Time.time;
        if (now < _nextVisibleBotCheck) return;
        _nextVisibleBotCheck = now + 0.35f;
        if (snap == null || snap.PlayerEntityDataDict == null || !haveSelf || selfData == null
            || selfData.IsDead || selfData.Hp <= 0f) return;

        Camera cam = null;
        try
        {
            Camera[] cams = Camera.allCameras;
            for (int i = 0; i < cams.Length; i++)
            {
                if (cams[i] != null && cams[i].name == "Eye") { cam = cams[i]; break; }
            }
            if (cam == null)
            {
                var wc = Contexts.sharedInstance.worldCamera;
                if (wc != null && wc.hasUnityObjects) cam = wc.unityObjects.mainCamera;
            }
            if (cam == null) cam = Camera.main;
        }
        catch (System.Exception) { }
        if (cam == null) return;

        // 先确认是否已有 bot 在屏幕内；有的话不要打断正常 AI。
        OfflineBotAgent chosen = null;
        PlayerEntityData chosenData = null;
        foreach (var kv in _agents)
        {
            PlayerEntityData d = Get(snap, kv.Key);
            if (d == null || d.IsDead || d.Hp <= 0f || !kv.Value.Alive) continue;
            Vector3 p = OfflineBotSpawner.GetUnityPos(d) + Vector3.up * 1.0f;
            Vector3 scr = cam.WorldToViewportPoint(p);
            if (scr.z > 0.05f && scr.x >= 0.04f && scr.x <= 0.96f
                && scr.y >= 0.04f && scr.y <= 0.96f)
            {
                return;
            }
            if (chosen == null)
            {
                chosen = kv.Value;
                chosenData = d;
            }
        }
        if (chosen == null || chosenData == null) return;

        Vector3 selfU = OfflineBotSpawner.GetUnityPos(selfData);
        Vector3 fwd = Vector3.ProjectOnPlane(cam.transform.forward, Vector3.up);
        if (fwd.sqrMagnitude < 0.01f)
        {
            float yaw = selfData.ViewYaw * Mathf.Deg2Rad;
            fwd = new Vector3(Mathf.Sin(yaw), 0f, Mathf.Cos(yaw));
        }
        fwd.Normalize();
        Vector3 right = new Vector3(fwd.z, 0f, -fwd.x);
        float[] distances = new float[] { 7f, 9f, 11f };
        float[] laterals = new float[] { 0f, -1.5f, 1.5f, -3f, 3f };
        Vector3 fallback = Vector3.zero;
        bool haveFallback = false;
        Vector3 selected = Vector3.zero;
        bool haveSelected = false;
        Vector3 eyeRaw = OfflineBotNav.UnityToRaw(cam.transform.position);

        for (int di = 0; di < distances.Length && !haveSelected; di++)
        {
            for (int li = 0; li < laterals.Length; li++)
            {
                Vector3 cand = selfU + fwd * distances[di] + right * laterals[li];
                Vector3 probe = cand * 100f + Vector3.up * 300f;
                Vector3 end, normal; float frac;
                if (OfflineBotPhysics.Cast(probe, probe - Vector3.up * 600f, 0f, 0f,
                    out end, out normal, out frac) && frac < 0.999f && normal.y >= 0.65f)
                {
                    cand = end / 100f;
                }
                else
                {
                    // 个别地图 BSP 没有返回地面时，保留玩家当前高度，避免回退到原点。
                    cand.y = selfU.y;
                }
                cand += Vector3.up * 0.02f;
                Vector3 scr = cam.WorldToViewportPoint(cand + Vector3.up * 1.0f);
                if (scr.z <= 0.05f || scr.x < 0.04f || scr.x > 0.96f
                    || scr.y < 0.04f || scr.y > 0.96f) continue;
                bool crowded = false;
                foreach (var kv in snap.PlayerEntityDataDict)
                {
                    if (kv.Value == null || kv.Value.IsDead || kv.Value.Hp <= 0f) continue;
                    if (Vector3.Distance(OfflineBotSpawner.GetUnityPos(kv.Value), cand) < 1.4f)
                    {
                        crowded = true;
                        break;
                    }
                }
                if (crowded) continue;
                if (!haveFallback) { fallback = cand; haveFallback = true; }
                Vector3 chestRaw = OfflineBotNav.UnityToRaw(cand + Vector3.up * 1.0f);
                if (OfflineBotPhysics.CanSee(eyeRaw, chestRaw))
                {
                    selected = cand;
                    haveSelected = true;
                    break;
                }
            }
        }
        if (!haveSelected) selected = fallback;
        if (!haveFallback && !haveSelected)
        {
            // 最后的保底仍然在相机正前方，不会把 bot 留在旧的 BSP 角落。
            selected = selfU + fwd * 7f + Vector3.up * 0.02f;
        }

        OfflineBotSpawner.SetUnityPos(chosenData, selected.x, selected.y, selected.z);
        chosen.SpawnPos = selected;
        chosen.Home = selected;
        chosen.StuckPos = selected;
        chosen.LastPos = selected;
        chosen.LastPosTime = now;
        chosen.SpeedSampleTime = -1f;
        chosen.MoveGoal = selected;
        chosen.MoveGoalTime = now + 0.65f;
        chosen.Path.Clear();
        chosen.PathIdx = 0;
        chosen.NextThink = now + 0.65f;
        chosen.VisibleHoldUntil = now + 0.65f;
        chosen.NeedsNearPlacement = false;
        chosen.AimYaw = Mathf.Atan2(fwd.x, fwd.z) * Mathf.Rad2Deg;
        chosenData.ViewYaw = chosen.AimYaw;
        chosenData.MoveYaw = chosen.AimYaw;
        if (now >= _lastVisibleBotAnchorLog)
        {
            _lastVisibleBotAnchorLog = now + 2f;
            Debug.Log("[OFFLINE-SPAWN-VISIBLE] anchor id=" + chosen.Id
                + " pos=" + selected.ToString("F1")
                + " screen=" + cam.WorldToViewportPoint(selected + Vector3.up).ToString("F2"));
        }
    }
    private float _nextVisibleBotPlacement;

    private void EnsureVisibleBot(ISnapshot snapshot, Vector3 selfPos, bool haveSelf)
    {
        if (!haveSelf || Time.time < _nextVisibleBotPlacement) return;
        Camera cam = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
            if (cams[i] != null && cams[i].name == "Eye" && cams[i].enabled) { cam = cams[i]; break; }
        if (cam == null) return;

        bool anyVisible = false;
        foreach (var kv in _agents)
        {
            PlayerEntityData d = Get(snapshot, kv.Key);
            if (d == null || d.IsDead || d.Hp <= 0f) continue;
            Vector3 p = OfflineBotSpawner.GetUnityPos(d);
            Vector3 sp = cam.WorldToScreenPoint(p + Vector3.up * 1f);
            if (sp.z > 0f && sp.x >= cam.pixelWidth * 0.12f && sp.x <= cam.pixelWidth * 0.88f
                && sp.y >= cam.pixelHeight * 0.12f && sp.y <= cam.pixelHeight * 0.88f)
            {
                anyVisible = true;
                break;
            }
        }
        _nextVisibleBotPlacement = Time.time + (anyVisible ? 1.0f : 0.15f);
        if (anyVisible) return;

        Vector3 fwd = Vector3.ProjectOnPlane(cam.transform.forward, Vector3.up);
        if (fwd.sqrMagnitude < 0.01f) return;
        fwd.Normalize();
        Vector3 right = new Vector3(fwd.z, 0f, -fwd.x);
        int chosen = -1;
        PlayerEntityData chosenData = null;
        foreach (var kv in _agents)
        {
            PlayerEntityData d = Get(snapshot, kv.Key);
            if (d != null && !d.IsDead && d.Hp > 0f) { chosen = kv.Key; chosenData = d; break; }
        }
        if (chosen < 0 || chosenData == null) return;

        float[] distances = { 8f, 10f, 12f, 6f };
        float[] offsets = { 0f, -1.5f, 1.5f, -3f, 3f };
        for (int di = 0; di < distances.Length; di++)
        {
            for (int oi = 0; oi < offsets.Length; oi++)
            {
                Vector3 candidate = selfPos + fwd * distances[di] + right * offsets[oi];
                Vector3 probe = candidate * 100f + Vector3.up * 300f;
                Vector3 end, normal; float fraction;
                if (!OfflineBotPhysics.Cast(probe, probe - Vector3.up * 600f, 0f, 0f,
                    out end, out normal, out fraction) || fraction >= 0.999f || normal.y < 0.65f)
                    continue;
                Vector3 ground = end / 100f;
                Vector3 screen = cam.WorldToScreenPoint(ground + Vector3.up * 1f);
                if (screen.z <= 0f || screen.x < cam.pixelWidth * 0.08f || screen.x > cam.pixelWidth * 0.92f
                    || screen.y < cam.pixelHeight * 0.08f || screen.y > cam.pixelHeight * 0.92f)
                    continue;
                OfflineBotSpawner.SetUnityPos(chosenData, ground.x, ground.y + 0.02f, ground.z);
                if (_agents.TryGetValue(chosen, out var agent))
                {
                    agent.SpawnPos = ground;
                    agent.Home = ground;
                    agent.LastKnownPos = ground;
                    agent.MoveGoal = ground;
                    agent.Path.Clear();
                    agent.PathIdx = 0;
                    agent.NeedsNearPlacement = false;
                }
                Debug.Log("[OFFLINE-BOT-VISIBILITY] force id=" + chosen + " pos=" + ground.ToString("F1")
                    + " screen=" + screen.ToString("F0"));
                return;
            }
        }
    }

    // ================= [OFFLINE-BOT-AI] 执行层状态 =================
    private class BotMoveState
    {
        public SSJJUserCmd.UserCmd Cmd;
        public SSJJUserCmd.PyUserCmdAdapter Adapter;
        public physics.IDuckManager DuckManager;
        public bool AirStrafeActive;
        public float AirStrafeSign = 1f;
        public int AirStrafeStep;
        public float NextAirStrafeTime;
        public bool JumpObservedAirborne;
        public float JumpIssuedAt;
        public float NextJumpDiagTime;
    }
    private const int BotBhopAirStrokeCount = 6;
    private const float BotBhopAirStrokeInterval = 0.085f;
    private readonly Dictionary<int, BotMoveState> _botMove = new Dictionary<int, BotMoveState>();
    private readonly List<BotThreat> _threats = new List<BotThreat>(8);
    // [OFFLINE-AI3] 每个 bot 一份独立人格（同难度下参数也不同）
    private readonly Dictionary<int, BotProfile> _botPersona = new Dictionary<int, BotProfile>();
    private readonly BotWorld _botWorld = new BotWorld();
    private BotProfile _botProfileCache;
    private string _botProfileKey;
    private Vector3 _prevSelfPos;
    private Vector3 _selfVelocity;
    private bool _hasSelfVelocitySample;
    private static bool _navBakedOnce;
    private static bool _syncPosErr;

    private BotProfile BotProf
    {
        get
        {
            string key = (OfflineGameController.setting != null)
                ? (OfflineGameController.setting.BotDifficulty ?? "normal") : "normal";
            if (_botProfileCache == null || _botProfileKey != key)
            {
                _botProfileKey = key;
                _botProfileCache = BotProfile.Get(key);
            }
            return _botProfileCache;
        }
    }

    private bool BotCanSeeRaw(Vector3 a, Vector3 b)
    {
        return OfflineBotPhysics.CanSee(OfflineBotNav.UnityToRaw(a), OfflineBotNav.UnityToRaw(b));
    }

    /// <summary>玩家开枪：将敌方枪声传给可听到的本地人机。</summary>
    private void NotifyBotsHeardNoise()
    {
        if (_agents.Count == 0) return;
        ISnapshot s = Snap();
        if (s == null) return;
        PlayerEntityData me;
        if (!s.PlayerEntityDataDict.TryGetValue(s.Self, out me) || me == null) return;
        NotifyBotsHeardNoise(s, s.Self, me.Team, OfflineBotSpawner.GetUnityPos(me));
    }

    private void NotifyBotsHeardNoise(ISnapshot s, int shooterId, int shooterTeam, Vector3 origin)
    {
        if (s == null) return;
        float now = Time.time;
        bool freeForAll = OfflineGameSetting.IsFreeForAll(
            OfflineGameController.setting != null ? OfflineGameController.setting.RaceType : 3);
        foreach (var kv in _agents)
        {
            if (kv.Key == shooterId || !kv.Value.Alive) continue;
            PlayerEntityData listener = Get(s, kv.Key);
            if (listener == null || listener.IsDead) continue;
            if (!freeForAll && listener.Team == shooterTeam) continue;
            BotProfile listenerProfile;
            if (!_botPersona.TryGetValue(kv.Key, out listenerProfile)) listenerProfile = BotProf;
            kv.Value.HearNoise(OfflineBotSpawner.GetUnityPos(listener), origin, listenerProfile.HearRadius, now);
        }
    }

    /// <summary>进图后第一次 Tick 时用出生点洪泛建导航图。</summary>
    private static float s_navNextTry;
    private void EnsureNavBaked(ISnapshot s)
    {
        if (OfflineBotNav.Baked) return;
        // [OFFLINE-FIX] 建图失败时不要每帧重试刷屏（上一版日志里 13053 行都是同一条）。
        if (UnityEngine.Time.realtimeSinceStartup < s_navNextTry) return;
        s_navNextTry = UnityEngine.Time.realtimeSinceStartup + 3f;
        int sceneId = (OfflineGameController.setting != null) ? OfflineGameController.setting.SceneId : 1;
        List<Vector3> seeds = new List<Vector3>();
        try
        {
            List<float[]> sp = OfflineMapSpawns.Load(sceneId);
            for (int i = 0; i < sp.Count; i++)
            {
                // [OFFLINE-FIX] OfflineMapSpawns 返回 { X, 水平Z, 高度Y, 阵营, yaw }，
                // 而 OfflineBotNav 的厘米空间是 (-水平Z, 高度Y, X)，不能原序塞进去。
                seeds.Add(OfflineBotNav.RawToUnity(new Vector3(-sp[i][1], sp[i][2], sp[i][0])));
            }
        }
        catch (System.Exception) { }
        // 出生点太少时补上 bot 当前位置与玩家位置
        foreach (var kv in _agents)
        {
            PlayerEntityData d = Get(s, kv.Key);
            if (d != null) seeds.Add(OfflineBotSpawner.GetUnityPos(d));
        }
        OfflineBotNav.Bake(seeds, sceneId);
        _navBakedOnce = true;
        Debug.Log("[OFFLINE-BOT-NAV] " + OfflineBotNav.Stat() + " seeds=" + seeds.Count);
    }

    /// <summary>
    /// [OFFLINE-BOT-AI] 单个 bot 的每帧驱动：
    ///   AI 出意图 -> 这里负责 pmove 移动 + 命中结算。
    /// </summary>
    private void TickBot(OfflineBotAgent b, PlayerEntityData data, bool haveSelf, Vector3 selfPos)
    {
        float now = Time.time;
        bool map12Training = OfflineBotSpawner.IsMap12TrainingProfile(OfflineGameController.setting);
        BotProfile prof;
        if (!_botPersona.TryGetValue(b.Id, out prof))
        {
            prof = BotProf.Personalize(b.Id);
            // map12 训练恢复普通对枪 AI：不再自动连跳或空中跳蹲。
            prof.Bhop = false;
            prof.JumpDuck = false;
            // [OFFLINE-AI6] 按 botQuality 强化人格：精英更快更准，首领再上一档；
            // 同时按武器类别决定近战行为（冲砍而不是对射）。
            OfflineBotSpawner.BotMeta meta;
            if (OfflineBotSpawner.Meta.TryGetValue(b.Id, out meta))
            {
                prof.Melee = meta.Melee;
                if (meta.Quality >= 3)
                {
                    prof.AimSkill *= 1.25f;
                    prof.AimErrorBase *= 0.75f;
                    prof.AimConverge *= 1.2f;
                    prof.ReactionTime *= 0.7f;
                    prof.ViewDistance *= 1.2f;
                }
                else if (meta.Quality >= 1)
                {
                    prof.AimSkill *= 1.10f;
                    prof.AimErrorBase *= 0.85f;
                    prof.ReactionTime *= 0.85f;
                }
            }
            else if (data != null)
            {
                prof.Melee = OfflineModeTable.IsMelee(data.CurrentWeaponName)
                    && !OfflineModeTable.IsThrowable(data.CurrentWeaponName);
            }
            _botPersona[b.Id] = prof;
            Debug.Log("[OFFLINE-BHOP-ASSIGN] id=" + b.Id + " enabled=" + prof.Bhop
                + " map12=" + map12Training + " airStrafe=" + prof.Bhop);
        }
        // 角色可能先于武器表初始化，或者在对局中换武器；延迟重试并保持剩余弹量。
        string currentBotWeapon = data != null ? data.CurrentWeaponName : null;
        if (!string.IsNullOrEmpty(currentBotWeapon))
        {
            bool weaponChanged = b.Weapon == null || !string.Equals(b.Weapon.Name, currentBotWeapon, System.StringComparison.OrdinalIgnoreCase);
            if (weaponChanged || (!b.Weapon.NativeInfoResolved && now >= b.NextWeaponResolve))
            {
                bool melee = OfflineModeTable.IsMelee(currentBotWeapon) && !OfflineModeTable.IsThrowable(currentBotWeapon);
                BotWeaponStats resolved = BotWeaponStats.Resolve(currentBotWeapon, melee, prof);
                b.NextWeaponResolve = now + 5f;
                if (weaponChanged || resolved.NativeInfoResolved)
                {
                    bool wasFull = b.Weapon != null && b.Clip >= b.Weapon.ClipSize;
                    b.Clip = weaponChanged || wasFull ? resolved.ClipSize : Mathf.Min(b.Clip, resolved.ClipSize);
                    b.Weapon = resolved;
                    if (weaponChanged)
                    {
                        prof.Melee = resolved.Melee;
                        b.InBurst = false;
                        b.BurstEnd = 0f;
                        b.PauseEnd = 0f;
                        b.NextShot = now;
                        _botAttackAnimUntil.Remove(b.Id);
                        _botTorsoAnim.Remove(b.Id);
                        if (b.State == BotState.Reload)
                        {
                            b.State = BotState.Patrol;
                            b.StateEnter = now;
                            b.ReloadAnimIssued = false;
                        }
                    }
                    Debug.Log("[OFFLINE-BOT-WEAPON] id=" + b.Id + " name=" + resolved.Name
                        + " native=" + resolved.NativeInfoResolved + " interval=" + resolved.ShotInterval.ToString("F3")
                        + " clip=" + resolved.ClipSize + " damage=" + resolved.Damage.ToString("F0"));
                }
            }
        }
        ISnapshot snap = Snap();
        if (snap == null) return;

        // ---- 死亡 / 复活 ----
        if (!b.Alive)
        {
            if (now >= b.RespawnAt)
            {
                // [OFFLINE-AI5] 复活点分散：固定 SpawnPos 会让 bot 反复在同一处刷出来，
                // 一局 30 秒实测复活 5 次，全挤在出生点。改成 70% 用附近 nav 节点、
                // 30% 用战术点，至少分散在地图各处。
                Vector3 sp = b.SpawnPos;
                bool trainingNearPicked = false;
                if (OfflineTdmMatch.Active)
                {
                    // map12 练枪先尝试玩家附近的可见可走点；标准团队模式仍按阵营复活。
                    Vector3? tdmSpawn = null;
                    if (map12Training)
                    {
                        PlayerEntityData meTraining = null;
                        snap.PlayerEntityDataDict.TryGetValue(snap.Self, out meTraining);
                        bool enemyTraining = meTraining == null || meTraining.Team != data.Team;
                        tdmSpawn = OfflineBotSpawner.PickSpawnNearPlayer(snap, meTraining, enemyTraining, b.Id);
                        trainingNearPicked = tdmSpawn.HasValue;
                    }
                    if (!tdmSpawn.HasValue)
                        tdmSpawn = OfflineBotSpawner.PickBotRespawn(
                            snap, b.Id, data.Team, data.Team == 1, selfPos, b.Id);
                    if (tdmSpawn.HasValue) sp = tdmSpawn.Value;
                }
                else
                {
                    // [OFFLINE-SPAWN-NEAR] 复活也刷到玩家附近（敌人必须与玩家通视），
                    // 否则死了以后 30 秒都在几十米外的 BSP 出生点，玩家再也见不到。
                    PlayerEntityData meR = null;
                    snap.PlayerEntityDataDict.TryGetValue(snap.Self, out meR);
                    int myTeamR = (meR != null) ? meR.Team : int.MinValue;
                    bool enemyR = (myTeamR == int.MinValue) || data.Team != myTeamR;
                    Vector3? nearR = OfflineBotSpawner.PickSpawnNearPlayer(snap, meR, enemyR, b.Id);
                    if (nearR.HasValue)
                    {
                        sp = nearR.Value;
                    }
                    else if (OfflineBotNav.Baked)
                    {
                        Vector3 scatter = (UnityEngine.Random.value < 0.7f)
                            ? OfflineBotNav.RandomNodePos(b.Id + (int)(UnityEngine.Time.time * 7f))
                            : OfflineBotNav.RandomTacticalPos(b.Id + (int)(UnityEngine.Time.time * 5f));
                        if (scatter != Vector3.zero && Vector3.Distance(scatter, b.SpawnPos) > 6f)
                            sp = scatter;
                    }
                }
                OfflineBotSpawner.SetUnityPos(data, sp.x, sp.y, sp.z);
                ResetBotMotion(b.Id);
                data.DuckState = 3;
                data.ViewHeight = 150f;
                float maxHpR = data.MaxHp > 0f ? data.MaxHp : 100f;
                data.Hp = maxHpR;
                data.IsDead = false;
                data.DeadTimer = 0;
                b.ResetForRespawn(sp, now, maxHpR);
                _botAttackAnimUntil.Remove(b.Id);
                _botTorsoAnim.Remove(b.Id);
                b.NeedsNearPlacement = map12Training && !trainingNearPicked;
                b.NearPlaceTries = 0;
                b.NearPlaceNextTry = 0f;
                SyncBotSpawnToEntity(b.Id, data);
                if (OfflineTdmMatch.Active) OfflineTdmMatch.MarkSpawnProtected(b.Id);
                Debug.Log("[OFFLINE-BOT] respawn id=" + b.Id + (OfflineTdmMatch.Active ? " tdm" : ""));
            }
            return;
        }

        // 标准团队模式保留阵营出生；map12 练枪需把断开的 BSP 出生区迁到当前可走战场。
        if (OfflineTdmMatch.Active && !map12Training) b.NeedsNearPlacement = false;

        // [OFFLINE-SPAWN-NEAR] 出生时玩家还没定位（SpawnAll 阶段 self=0,0,0），
        // 这里在玩家坐标有效后的第一帧把 bot 迁到玩家附近；敌人必须与玩家通视。
        if (b.NeedsNearPlacement && (!map12Training || now >= b.NearPlaceNextTry))
        {
            PlayerEntityData meP;
            if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out meP) && meP != null && !meP.IsDead
                && (Mathf.Abs(meP.X) > 100f || Mathf.Abs(meP.Y) > 100f))
            {
                b.NearPlaceTries++;
                if (map12Training) b.NearPlaceNextTry = now + 0.20f;
                bool enemyP = meP.Team != data.Team;
                Vector3? np = OfflineBotSpawner.PickSpawnNearPlayer(snap, meP, enemyP, b.Id);
                if (np.HasValue)
                {
                    OfflineBotSpawner.SetUnityPos(data, np.Value.x, np.Value.y, np.Value.z);
                    b.SpawnPos = np.Value;
                    b.Home = np.Value;
                    b.StuckPos = np.Value;
                    b.StuckTime = now;
                    b.StuckCount = 0;
                    b.StuckEscapeUntil = 0f;
                    b.LastPos = np.Value;
                    b.LastPosTime = now;
                    b.SpeedSampleTime = -1f;
                    b.MoveGoal = np.Value;
                    b.MoveGoalTime = now;
                    b.Path.Clear();
                    b.PathIdx = 0;
                    b.NextThink = now + 0.1f;
                    b.NearPlaceTries = 0;
                    b.NearPlaceNextTry = 0f;
                    b.VisibleHoldUntil = now + 0.25f;
                    data.DuckState = 3;
                    data.ViewHeight = 150f;
                    ResetBotMotion(b.Id);
                    SyncBotSpawnToEntity(b.Id, data);
                    b.NeedsNearPlacement = false;
                    UnityEngine.Debug.Log("[OFFLINE-BOT] map12 near-place id=" + b.Id + " enemy=" + enemyP
                        + " pos=" + np.Value.ToString("F1"));
                }
                else if (b.NearPlaceTries > 240 && !map12Training)
                {
                    b.NeedsNearPlacement = false;   // ~4 秒仍找不到点位，保留 BSP 出生点
                }
            }
        }

        Vector3 pos = OfflineBotSpawner.GetUnityPos(data);
        b.Hp = data.Hp;
        if (data.MaxHp > 0f) b.MaxHp = data.MaxHp;
        if (data.Hp <= 0f || data.IsDead)
        {
            if (data.DeadTimer <= 0) data.DeadTimer = 3000;   // [OFFLINE-SYNC-DIAG] 死亡姿态推进目标
            b.Alive = false;
            b.RespawnAt = now + 5f;
            return;
        }

        // [OFFLINE-SPAWN-VISIBLE] 视野锚定后给实体同步和模型刷新一个短窗口；
        // 否则下一帧 AI 会立即沿旧目标移动，玩家仍然只会看到一闪而过的 bot。
        if (now < b.VisibleHoldUntil)
        {
            data.ViewYaw = b.AimYaw;
            data.MoveYaw = b.AimYaw;
            SyncBotEntityFacing(b.Id, b.AimYaw, data.ViewPitch);
            return;
        }

        // ---- 构造威胁列表 ----
        _threats.Clear();
        bool freeForAll = OfflineGameSetting.IsFreeForAll(
            OfflineGameController.setting != null ? OfflineGameController.setting.RaceType : 3);
        // [OFFLINE-TRAINING] 玩家无敌时仍作为练枪目标；DamagePlayer 负责免伤结算。
        if (haveSelf)
        {
            PlayerEntityData me;
            if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me != null && !me.IsDead && me.Hp > 0f)
            {
                if (freeForAll || me.Team != data.Team)
                {
                    BotThreat t = new BotThreat();
                    t.Id = snap.Self;
                    t.Team = me.Team;
                    t.Pos = selfPos;
					t.ViewHeight = (me.ViewHeight > 10f ? me.ViewHeight : EyeHeight) / 100f;
                    t.Hp = me.Hp;
                    t.Velocity = _selfVelocity;
                    t.Distance = Vector3.Distance(pos, selfPos);
                    _threats.Add(t);
                }
            }
        }
        foreach (var kv in _agents)
        {
            if (kv.Key == b.Id || !kv.Value.Alive) continue;
            PlayerEntityData d = Get(snap, kv.Key);
            if (d == null || d.IsDead || d.Hp <= 0f) continue;
            if (!freeForAll && d.Team == data.Team) continue;
            BotThreat t = new BotThreat();
            t.Id = kv.Key;
            t.Team = d.Team;
            t.Pos = OfflineBotSpawner.GetUnityPos(d);
            t.ViewHeight = (d.ViewHeight > 10f ? d.ViewHeight : EyeHeight) / 100f;
            t.Velocity = kv.Value.ObservedVelocity;
            t.Hp = d.Hp;
            t.Distance = Vector3.Distance(pos, t.Pos);
            _threats.Add(t);
        }

        // ---- AI 出意图 ----
        _botWorld.Now = now;
        _botWorld.RoundOver = RoundOver;
        if (_botWorld.CanSee == null) _botWorld.CanSee = BotCanSeeRaw;

        // [OFFLINE-AI3] 自身水平速度（cm/s）：急停射击要用它判断"是否在全速跑"
        float selfSpeed = 0f;
        b.ObservedVelocity = Vector3.zero;
        if (b.SpeedSampleTime >= 0f && now > b.SpeedSampleTime)
        {
            float dtS = Mathf.Max(0.001f, now - b.SpeedSampleTime);
            Vector3 measuredVelocity = (pos - b.SpeedSamplePos) / dtS;
            if (measuredVelocity.sqrMagnitude <= 400f) b.ObservedVelocity = measuredVelocity;
            selfSpeed = new Vector2(b.ObservedVelocity.x, b.ObservedVelocity.z).magnitude * 100f;
        }
        b.SpeedSamplePos = pos;
        b.SpeedSampleTime = now;
        _botWorld.SelfSpeed = selfSpeed;

        // [OFFLINE-AI4] 把玩家位置与阵营关系喂给决策层。
        // 之前 BotWorld 完全没有玩家信息，AI 只会在自己出生点 40m 内随机游走，
        // 表现出来就是"一群傻子在原地晃"。这是决策依据缺失，不是参数问题。
        _botWorld.PlayerValid = haveSelf;
        _botWorld.PlayerPos = selfPos;
        _botWorld.SelfPlayerId = snap.Self;
        {
            int playerTeam = int.MinValue;
            if (haveSelf)
            {
                PlayerEntityData meT;
                if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out meT) && meT != null)
                    playerTeam = meT.Team;
            }
            _botWorld.IsAlly = !freeForAll && playerTeam != int.MinValue && data.Team == playerTeam;
        }
        // [OFFLINE-AI2] 队友正在交火 -> 允许本 bot 走侧翼包抄（haner-ai 的 squad 协同）
        bool squadEngaging = false;
        foreach (var kv2 in _agents)
        {
            if (kv2.Key == b.Id || !kv2.Value.Alive) continue;
            PlayerEntityData d2 = Get(snap, kv2.Key);
            if (d2 == null || d2.Team != data.Team) continue;
            if (kv2.Value.State == BotState.Combat || kv2.Value.State == BotState.Flank)
            {
                squadEngaging = true;
                break;
            }
        }
        _botWorld.SquadEngaging = squadEngaging;
        // [OFFLINE-AI6] 队友分离力数据：6m 内同队存活 bot 的位置（AI 用来防堆叠）
        _botWorld.NearbyAllies.Clear();
        foreach (var kv3 in _agents)
        {
            if (kv3.Key == b.Id || !kv3.Value.Alive) continue;
            PlayerEntityData d3 = Get(snap, kv3.Key);
            if (d3 == null || d3.IsDead || d3.Hp <= 0f) continue;
            if (!freeForAll && d3.Team != data.Team) continue;
            Vector3 ap = OfflineBotSpawner.GetUnityPos(d3);
            if (Vector3.Distance(ap, pos) > 6f) continue;
            _botWorld.NearbyAllies.Add(ap);
        }
        // [OFFLINE-TDM] 团战世界数据：阵营/存活人数/目标点/共享情报（AI 团战化的输入）
        FillTdmWorld(snap, b, data, haveSelf, selfPos, freeForAll);
        _botWorld.TrainingPlayerAwareness = OfflineBotSpawner.IsMap12TrainingProfile(OfflineGameController.setting);
        if (!b.VisualAnglesInitialized)
        {
            b.VisualYaw = data.ViewYaw;
            b.VisualPitch = data.ViewPitch;
            b.VisualAnglesInitialized = true;
        }
        BotIntent it = b.Tick(prof, _botWorld, _threats, pos);

        // DefaultReloadSystem 的原版第三人称换弹动作编号为 17；只在进入换弹时触发一次。
        if (it.WantReload && !b.ReloadAnimIssued)
        {
            SetBotTorsoAnimation(b.Id, 17);
            b.ReloadAnimIssued = true;
            Debug.Log("[OFFLINE-BOT-RELOAD] id=" + b.Id + " duration=" + Mathf.Max(0f, b.ReloadEnd - now).ToString("F2"));
        }
        else if (!it.WantReload) b.ReloadAnimIssued = false;

        // ---- 执行移动（原版 pmove，BSP 碰撞/台阶/重力全由引擎算） ----
        if (it.HasMove)
        {
            ExecuteBotMove(b, data, it, prof, pos);
        }
        else
        {
            // [OFFLINE-LOOKSTILL] 静止 bot 也要刷新视线：
            // 不会身法的 bot 站着盯玩家（[OFFLINE-BHOP50] lookPlayer），
            // 玩家绕圈/跳蹲时头要跟着转；旧逻辑 HasMove=false 整段不跑，
            // ViewYaw 停在最后一次移动的值，表现就是"盯死一个方向"。
            data.ViewYaw = it.ViewYaw;
            data.ViewPitch = it.ViewPitch;
            data.MoveYaw = it.MoveYaw;
            SyncBotEntityFacing(b.Id, it.ViewYaw, it.ViewPitch);
        }

        // [OFFLINE-TRAINING] pmove 路径和 BSP 保底路径都统一写回实体朝向。
        // 仅更新快照的 ViewYaw 会留下 Entitas orientation 旧值，第三人称模型因此仍背向目标。
        data.ViewYaw = it.ViewYaw;
        data.ViewPitch = it.ViewPitch;
        SyncBotEntityFacing(b.Id, it.ViewYaw, it.ViewPitch);

        // 决策层在发出 WantFire 时已按武器射速扣弹并推进 NextShot。
        // 执行层不再使用第二个时钟拒绝同一发射，避免扣弹但没有枪声和伤害。
        if (!RoundOver && it.WantFire && it.TargetId >= 0)
        {
            BotWeaponStats bw = b.Weapon;
            bool meleeShot = (bw != null) ? bw.Melee : prof.Melee;
            // 原版普通刀左键和枪械开火均使用第三人称 TORSO_ATTACK (15)。
            SetBotTorsoAnimation(b.Id, 15);
            PlayBotFireSound(bw != null ? bw.Name : data.CurrentWeaponName, pos);
            NotifyBotsHeardNoise(snap, b.Id, data.Team, pos);

            PlayerEntityData tgt = Get(snap, it.TargetId);
            if (tgt != null && !tgt.IsDead && tgt.Hp > 0f)
            {
                Vector3 tp = OfflineBotSpawner.GetUnityPos(tgt);
                float dist = Vector3.Distance(pos, tp);
                // [OFFLINE-AI6] 近战按砍距判定，枪械按视距
                float range = meleeShot ? ((bw != null) ? bw.MeleeRange : prof.MeleeRange) : prof.ViewDistance;
                Vector3 shotOrigin = pos + Vector3.up * 1.5f;
                Vector3 shotDirection = Quaternion.Euler(it.AimPitch, it.AimYaw, 0f) * Vector3.forward;
                float targetViewHeight = (tgt.ViewHeight > 10f ? tgt.ViewHeight : EyeHeight) / 100f;
                Vector3 impact = tp + Vector3.up * (targetViewHeight * 0.7f);
                bool headshot = false;
                bool intersects = meleeShot || TryBotShotBody(shotOrigin, shotDirection, tp, targetViewHeight, out impact, out headshot);
                bool clearShot = intersects && BotCanSeeRaw(shotOrigin, impact);
                bool hit = dist <= range && clearShot && intersects;
                if (now >= b.NextShotDiag)
                {
                    b.NextShotDiag = now + 2f;
                    Debug.Log("[OFFLINE-BOT-SHOT] id=" + b.Id + " target=" + it.TargetId
                        + " clip=" + b.Clip + " hit=" + hit + " head=" + (hit && headshot)
                        + " clear=" + clearShot + " intersects=" + intersects + " speed=" + selfSpeed.ToString("F0"));
                }
                // [OFFLINE-AI6] 开火反馈：每一发都有枪线（压制射击才看得见），命中才出火花。
                SpawnBotTracer(pos, it.AimYaw, it.AimPitch, impact, meleeShot, hit);
                if (hit)
                {
                    float dmg;
                    if (meleeShot)
                    {
                        dmg = (bw != null && bw.MeleeDamage > 0f) ? bw.MeleeDamage : 55f;
                    }
                    else
                    {
                        float baseDmg = (bw != null && bw.Damage > 0f) ? bw.Damage : Random.Range(prof.DmgMin, prof.DmgMax);
                        dmg = baseDmg * Random.Range(0.92f, 1.08f);
                        // 服务端伤害表未在客户端找到；头部倍率仍按离线近似值处理。
                        if (headshot) dmg *= 2f;
                    }
                    if (it.TargetId == snap.Self)
                    {
                        DamagePlayer(dmg, b.Id, headshot, meleeShot);
                    }
                    else
                    {
                        DamageBot(it.TargetId, dmg, b.Id, headshot, meleeShot);
                    }
                }
            }
        }

        // [OFFLINE-TDM] bot 投掷物：AI 已按 7~24m / 冷却 / 角色概率给出意图，这里只负责执行
        if (it.WantGrenade && !RoundOver && b.Alive && !OfflineTdmMatch.IsProtected(b.Id))
        {
            try
            {
                float gd = Vector3.Distance(pos, it.GrenadeTarget);
                if (gd >= 7f && gd <= 24f)
                    ThrowBotGrenade(b.Id, data.Team, it.GrenadeTarget, it.GrenadeKind);
            }
            catch (System.Exception) { }
        }
        // [OFFLINE-TDM] bot 技能意图暂不实现（只记一次日志，避免半成品行为）
        if (it.WantSkill && !_botSkillIgnored)
        {
            _botSkillIgnored = true;
            Debug.Log("[OFFLINE-TDM] bot skill intent ignored");
        }

        // 朝向写回快照（第三人称模型转身靠它）
        // [OFFLINE-VISION] 视线=ViewYaw（含呼吸/扫视晃动），弹道 AimYaw 保持精准
        data.ViewYaw = it.ViewYaw;
        // [OFFLINE-CONTRACT] Step A：补齐 30 字段，激活 139 个消费系统
        FillContractFields(data, b, b.Alive);
        // [OFFLINE-AI6] MoveYaw 用移动方向：旧实现直接 = AimYaw，
        // 横移射击时模型朝枪口方向平移 —— 就是用户说的"原地太空步"。
        data.MoveYaw = it.MoveYaw;
    }

    /// <summary>
    /// [OFFLINE-TDM] 填充 BotWorld 团战字段：阵营、存活人数、目标点、共享情报。
    /// 常规目标取地图敌方出生区域；敌人位置只通过感知和队友情报提供。
    /// </summary>
    private void FillTdmWorld(ISnapshot snap, OfflineBotAgent b, PlayerEntityData data,
        bool haveSelf, Vector3 selfPos, bool freeForAll)
    {
        try
        {
            if (snap == null || data == null) return;
            float now = Time.time;
            PlayerEntityData me = null;
            if (haveSelf) snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me);
            int playerTeam = (me != null) ? me.Team : int.MinValue;
            bool playerAlive = me != null && !me.IsDead && me.Hp > 0f;

            if (freeForAll)
            {
                // 个人战保留旧行为：不提供目标点/共享情报，人数差失效（=0）
                _botWorld.SelfTeam = data.Team;
                _botWorld.PlayerTeam = playerTeam;
                _botWorld.MatchActive = !RoundOver;
                _botWorld.PlayerAlive = playerAlive;
                _botWorld.HasObjective = false;
                _botWorld.HasSharedEnemy = false;
                _botWorld.SharedEnemyTime = -999f;
                _botWorld.AliveAllies = 0;
                _botWorld.AliveEnemies = 0;
                return;
            }

            _botWorld.SelfTeam = data.Team;
            _botWorld.PlayerTeam = playerTeam;
            _botWorld.MatchActive = !RoundOver && !OfflineTdmMatch.RoundOver;
            _botWorld.PlayerAlive = playerAlive;

            // ---- 存活人数（含玩家）----
            int allies = 0;
            int enemies = 0;
            if (me != null && playerAlive)
            {
                if (!freeForAll && me.Team == data.Team) allies++;
                else enemies++;
            }
            foreach (var kv in _agents)
            {
                if (kv.Key == b.Id || !kv.Value.Alive) continue;
                PlayerEntityData d = Get(snap, kv.Key);
                if (d == null || d.IsDead || d.Hp <= 0f) continue;
                if (!freeForAll && d.Team == data.Team) allies++;
                else enemies++;
            }
            _botWorld.AliveAllies = allies;
            _botWorld.AliveEnemies = enemies;

            // 没有敌情时以固定地图信息推进，不能读取敌人的实时坐标。
            Vector3 objective = EnemySideObjective(data.Team);
            bool hasObjective = objective.sqrMagnitude >= 1f;
            if (hasObjective)
            {
                objective += BotObjectiveOffset(b.Id);
                Vector3 snappedObj;
                if (OfflineBotNav.TrySnapToNode(objective, 12f, out snappedObj))
                    objective = snappedObj;
            }
            _botWorld.ObjectivePos = objective;
            _botWorld.HasObjective = hasObjective;

            // ---- 共享情报：同队存活 bot 最近 6 秒内的位置 ----
            bool shared = false;
            float bestT = -999f;
            Vector3 bestP = Vector3.zero;
            if (!freeForAll) foreach (var kv in _agents)
            {
                if (kv.Key == b.Id || !kv.Value.Alive) continue;
                PlayerEntityData d = Get(snap, kv.Key);
                if (d == null || d.IsDead || d.Hp <= 0f) continue;
                if (!freeForAll && d.Team != data.Team) continue;
                float t = kv.Value.EnemyIntelTime;
                if (t < now - 6f || t <= bestT) continue;
                bestT = t;
                bestP = kv.Value.EnemyIntelPos;
                shared = true;
            }
            _botWorld.HasSharedEnemy = shared;
            _botWorld.SharedEnemyPos = shared ? bestP : Vector3.zero;
            _botWorld.SharedEnemyTime = shared ? bestT : -999f;
        }
        catch (System.Exception) { }
    }

    /// <summary>[OFFLINE-TDM] 每个 bot 固定的 2~4m 横向目标偏移，避免全队挤在一个坐标。</summary>
    private static Vector3 BotObjectiveOffset(int botId)
    {
        float ang = (botId % 8) * 0.7853982f;
        float radius = 2f + (botId % 3);
        return new Vector3(Mathf.Cos(ang) * radius, 0f, Mathf.Sin(ang) * radius);
    }

    /// <summary>[OFFLINE-TDM] 敌方出生侧的一个 BSP 点（Unity 米制）；无数据返回零向量。</summary>
    private static Vector3 EnemySideObjective(int selfTeam)
    {
        try
        {
            int sceneId = (OfflineGameController.setting != null) ? OfflineGameController.setting.SceneId : 1;
            List<float[]> list = OfflineMapSpawns.Load(sceneId);
            if (list == null || list.Count == 0) return Vector3.zero;
            bool wantCT = selfTeam != 1;
            for (int i = 0; i < list.Count; i++)
            {
                float[] raw = list[i];
                if (raw == null || raw.Length < 5) continue;
                if ((raw[3] == 1f) != wantCT) continue;
                // BSP { X, 水平Z, 高度Y, 阵营, yaw } -> Unity 米制 (-Z, Y, X)
                return new Vector3(-raw[1] * 0.01f, raw[2] * 0.01f, raw[0] * 0.01f);
            }
        }
        catch (System.Exception) { }
        return Vector3.zero;
    }

    private bool _botFireSoundWarning;

    // 原版 EventsPlaySystem 的开火事件 1/47 使用同一资源键与三维衰减。
    private void PlayBotFireSound(string weaponName, Vector3 position)
    {
        if (string.IsNullOrEmpty(weaponName)) return;
        try
        {
            var sound = SSJJBase.Singleton.MonoBehaviourSingleton<Assets.Sources.Utils.Sound.GameSoundManager>.Instance;
            if (sound == null) return;
            sound.Play3DSound(Assets.Generated.Table.SoundSystemTable.SoundSubtype.Shoot, false,
                Assets.Sources.Utils.SoundResourceUtility.GetWeaponSoundFireAssetInfo(weaponName),
                position * 100f, Assets.Sources.Utils.Sound.GameSoundManager.Config.WeaponVolume,
                Assets.Sources.Utils.Sound.GameSoundManager.RollOffDistance.Distance94);
        }
        catch (System.Exception ex)
        {
            if (!_botFireSoundWarning)
            {
                _botFireSoundWarning = true;
                Debug.LogWarning("[OFFLINE-BOT-SOUND] fire failed: " + ex.Message);
            }
        }
    }

    // 离线角色近似碰撞体：与玩家打 bot 使用的站/蹲视高和半径保持一致。
    private static bool TryBotShotBody(Vector3 origin, Vector3 direction, Vector3 feet, float viewHeight,
        out Vector3 impact, out bool headshot)
    {
        impact = feet + Vector3.up * (viewHeight * 0.7f);
        headshot = false;
        Vector3 flat = new Vector3(direction.x, 0f, direction.z);
        float flatLengthSq = flat.sqrMagnitude;
        float t;
        if (flatLengthSq > 0.0001f)
        {
            Vector3 toAxis = new Vector3(feet.x - origin.x, 0f, feet.z - origin.z);
            t = Vector3.Dot(toAxis, flat) / flatLengthSq;
        }
        else t = Vector3.Dot(feet + Vector3.up * (viewHeight * 0.5f) - origin, direction);
        if (t <= 0f) return false;

        impact = origin + direction * t;
        const float bodyRadius = 0.34f;
        const float headRadius = 0.18f;
        float bodyHeight = viewHeight + 0.25f;
        float spineTop = Mathf.Max(bodyRadius, bodyHeight - bodyRadius);
        float closestY = feet.y + Mathf.Clamp(impact.y - feet.y, bodyRadius, spineTop);
        Vector3 nearestBody = new Vector3(feet.x, closestY, feet.z);
        if ((impact - nearestBody).sqrMagnitude > bodyRadius * bodyRadius) return false;
        Vector3 head = feet + Vector3.up * viewHeight;
        headshot = (impact - head).sqrMagnitude <= headRadius * headRadius;
        return true;
    }

    /// <summary>[OFFLINE-AI6] bot 开火反馈：枪线轨迹 + 命中火花。</summary>
    private static Material _botTracerMat;

    private void SpawnBotTracer(Vector3 from, float yawDeg, float pitchDeg, Vector3 target, bool melee, bool hit)
    {
        try
        {
            Vector3 dir = Quaternion.Euler(pitchDeg, yawDeg, 0f) * Vector3.forward;
            Vector3 muzzle = from + Vector3.up * 1.5f + dir * 0.5f;
            Vector3 hitPoint = target;
            if (melee)
            {
                if (hit) SpawnSpark(hitPoint, new Color(1f, 0.95f, 0.8f), 0.10f);
                return;
            }
            // 未命中时枪线沿实际瞄准方向飞出（玩家能看出是打偏），命中时才落在目标身上。
            Vector3 end = hit ? hitPoint : muzzle + dir * Mathf.Max(4f, Vector3.Distance(muzzle, hitPoint));
            var go = new GameObject("BotTracer");
            var lr = go.AddComponent<LineRenderer>();
            lr.useWorldSpace = true;
            lr.startWidth = 0.02f;
            lr.endWidth = 0.015f;
            lr.positionCount = 2;
            lr.SetPosition(0, muzzle);
            lr.SetPosition(1, end);
            if (_botTracerMat == null)
            {
                Shader sh = Shader.Find("Sprites/Default");
                if (sh != null)
                {
                    _botTracerMat = new Material(sh);
                    _botTracerMat.color = new Color(1f, 0.85f, 0.35f);
                }
            }
            if (_botTracerMat != null) lr.material = _botTracerMat;
            if (hit) SpawnSpark(hitPoint, new Color(1f, 0.9f, 0.6f), 0.12f);
            UnityEngine.Object.Destroy(go, 0.06f);
        }
        catch (System.Exception) { }
    }

    private void SpawnSpark(Vector3 at, Color c, float life)
    {
        try
        {
            var s = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            s.transform.position = at;
            s.transform.localScale = Vector3.one * 0.09f;
            var col = s.GetComponent<Collider>();
            if (col != null) UnityEngine.Object.Destroy(col);
            var mr = s.GetComponent<MeshRenderer>();
            if (mr != null)
            {
                Shader sh = Shader.Find("Sprites/Default");
                if (sh != null)
                {
                    var mat = new Material(sh);
                    mat.color = c;
                    mr.material = mat;
                }
            }
            UnityEngine.Object.Destroy(s, life);
        }
        catch (System.Exception) { }
    }

    // ---------------- bot 移动 ----------------
    //
    // [OFFLINE-FIX] 让 bot 走和玩家完全相同的原版 pmove 管线，但**每个 bot 一个独立 Pmove 实例**。
    // 原实现里玩家和 4 个 bot 共用 engine.GetPmove() 单例，实测 aF=25350 经 CmdScale 归一化后
    // 只剩 13cm/s（目标 259）。Pmove 的构造是公开的：
    //     SSJJPhysics.Pmove(IPyEntityMove, IPyWorld, IPyEntityManager)
    // 每个 bot 独立持有后，内部 _velocity / pml 状态不再互相覆盖。
    // 万一某个难度/地图下 pmove 仍给不到 35% 目标速度，自动降级到 BSP 直接驱动（有日志）。

    private readonly System.Collections.Generic.Dictionary<int, physics.IPyMove> _botPmove =
        new System.Collections.Generic.Dictionary<int, physics.IPyMove>();
    private readonly System.Collections.Generic.Dictionary<int, float> _botPmoveRetryAt =
        new System.Collections.Generic.Dictionary<int, float>();
    private readonly System.Collections.Generic.HashSet<int> _botJumpLatch =
        new System.Collections.Generic.HashSet<int>();
    private readonly System.Collections.Generic.Dictionary<int, int> _botSlowFrames =
        new System.Collections.Generic.Dictionary<int, int>();
    private readonly System.Collections.Generic.HashSet<int> _botDirectMode =
        new System.Collections.Generic.HashSet<int>();

    private static bool s_botPmoveWarned = false;
    private void ResetBotMotion(int id)
    {
        _botMove.Remove(id);
        _botPmove.Remove(id);
        _botPmoveRetryAt.Remove(id);
        _botJumpLatch.Remove(id);
        _botSlowFrames.Remove(id);
        _botDirectMode.Remove(id);
        OfflineBotPhysics.ResetVertical(id);
    }

    private physics.IPyMove GetBotPmove(int id)
    {
        physics.IPyMove pm;
        if (_botPmove.TryGetValue(id, out pm) && pm != null) return pm;
        float retryAt;
        if (_botPmoveRetryAt.TryGetValue(id, out retryAt) && Time.time < retryAt) return null;
        _botPmoveRetryAt[id] = Time.time + 1f;
        try
        {
            var room = Contexts.sharedInstance.battleRoom;
            if (room == null || !room.hasPyEngine || room.pyEngine == null || room.pyEngine.PyEngine == null)
            {
                return null;
            }
            var eng = room.pyEngine.PyEngine;
            var em = eng.GetEntityMove();
            var w = eng.GetWorld();
            var mgr = eng.GetEntityManager();
            if (em == null || w == null || mgr == null)
            {
                return null;
            }
            pm = new SSJJPhysics.Pmove(em, w, mgr);
            _botPmove[id] = pm;
            _botPmoveRetryAt.Remove(id);
            UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + id + " per-bot Pmove + brush update(2)");
        }
        catch (System.Exception ex)
        {
            if (!s_botPmoveWarned)
            {
                s_botPmoveWarned = true;
                UnityEngine.Debug.LogWarning("[OFFLINE-BOT-MOVE] id=" + id + " 建 Pmove 失败: " + ex.Message);
            }
            pm = null;
        }
        return pm;
    }

    private static void SyncBotSpawnToEntity(int botId, PlayerEntityData data)
    {
        if (data == null) return;
        try
        {
            foreach (PlayerEntity pe in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (pe == null || pe.entityId.Value != botId) continue;
                if (pe.hasBasicInfo && pe.basicInfo.Current != null)
                {
                    pe.basicInfo.Current.X = data.X;
                    pe.basicInfo.Current.Y = data.Y;
                    pe.basicInfo.Current.Z = data.Z;
                    pe.basicInfo.Current.MoveYaw = data.MoveYaw;
                }
                if (pe.hasBasicInfo && pe.basicInfo.Next != null)
                {
                    pe.basicInfo.Next.X = data.X;
                    pe.basicInfo.Next.Y = data.Y;
                    pe.basicInfo.Next.Z = data.Z;
                    pe.basicInfo.Next.MoveYaw = data.MoveYaw;
                }
                if (pe.hasMove)
                {
                    pe.move.DuckState = 3;
                    pe.move.IsLimitMaxSpeed = false;
                    if (pe.move.PyPlayerMove != null)
                    {
                        pe.move.PyPlayerMove.SetPosition((float)data.X, (float)data.Y, (float)data.Z);
                        pe.move.PyPlayerMove.SetVelocity(0f, 0f, 0f);
                        StoreBotVelocity(pe, data, 0f, 0f, 0f);
                        var room = Contexts.sharedInstance.battleRoom;
                        if (room.hasPyEngine && room.pyEngine.PyEngine != null)
                            room.pyEngine.PyEngine.GetEntityManager().UpdateEntityNormalBrush(
                                2, pe.move.PyPlayerMove.GetEntity());
                    }
                }
                break;
            }
        }
        catch (System.Exception) { }
    }

    private static void ApplyBotBhopAirStrafe(BotMoveState state, bool bhop, bool onGround,
        ref float moveForward, ref float moveRight)
    {
        if (!bhop || onGround)
        {
            state.AirStrafeActive = false;
            state.AirStrafeStep = 0;
            state.NextAirStrafeTime = 0f;
            return;
        }

        if (!state.AirStrafeActive)
        {
            state.AirStrafeActive = true;
            state.AirStrafeStep = 0;
            state.AirStrafeSign = 1f;
            state.NextAirStrafeTime = Time.time + BotBhopAirStrokeInterval;
        }
        else if (state.AirStrafeStep < BotBhopAirStrokeCount - 1
            && Time.time >= state.NextAirStrafeTime)
        {
            state.AirStrafeStep++;
            state.AirStrafeSign = -state.AirStrafeSign;
            state.NextAirStrafeTime = Time.time + BotBhopAirStrokeInterval;
        }

        // 每次腾空做 A/D/A/D/A/D 六段侧向空速；留少量前向量保持追击方向。
        moveForward = 0.20f;
        moveRight = state.AirStrafeSign;
    }

    private void ExecuteBotMove(OfflineBotAgent b, PlayerEntityData data, BotIntent it, BotProfile prof, Vector3 pos)
    {
        try
        {
            // [OFFLINE-PMOVE] 先走和本地玩家完全相同的 Pmove；跳跃、重力、蹲伏、
            // 空中转向和碰撞全部由同一 physics 引擎处理。只有实体尚未拿到 Move/PyPlayerMove
            // 时才保留 BSP 路径，并输出明确诊断，避免悄悄使用另一套身法。
            Vector3 dir = it.MoveTarget - pos;
            dir.y = 0f;
            if (it.MoveForward != 1f || it.MoveRight != 0f)
            {
                float yr = it.MoveYaw * Mathf.Deg2Rad;
                Vector3 fwd = new Vector3(Mathf.Sin(yr), 0f, Mathf.Cos(yr));
                Vector3 rgt = new Vector3(Mathf.Cos(yr), 0f, -Mathf.Sin(yr));
                dir = fwd * it.MoveForward + rgt * it.MoveRight;
            }
            if (b.UseCombatPath && Time.time >= b.NextRouteExecDiag)
            {
                b.NextRouteExecDiag = Time.time + 5f;
                Debug.Log("[OFFLINE-BOT-ROUTE] id=" + b.Id + " pos=" + pos.ToString("F1")
                    + " waypoint=" + it.MoveTarget.ToString("F1")
                    + " stick=" + (it.MoveForward != 1f || it.MoveRight != 0f)
                    + " fallback=" + _botDirectMode.Contains(b.Id));
            }
            if (dir.sqrMagnitude > 0.0001f) dir.Normalize();
            // 原版 Pmove 在 map12 个别碰撞面/离地状态下会接受满速命令却只推进很短距离。
            // 水平位移仍切到 BSP 保底路径；map12 跳跃的人机继续逐帧运行原版 Pmove，
            // 只取原版的垂直位置/重力/落地，再用 BSP 计算水平位移，避免自建抛物线与玩家不一致。
            if (_botDirectMode.Contains(b.Id))
            {
                Vector3 directPos = OfflineBotSpawner.GetUnityPos(data);
                bool nativeVertical = false;
                if (prof.Bhop)
                {
                    float ignoredVelocity;
                    nativeVertical = PmoveStep(b, data, it, prof, dir, ReferencePlayerSpeed(),
                        Mathf.Clamp(Time.deltaTime, 0.001f, 0.05f), out ignoredVelocity);
                    if (nativeVertical)
                    {
                        Vector3 nativePos = OfflineBotSpawner.GetUnityPos(data);
                        // Pmove 的水平位移不参与保底路径，只保留它的真实垂直模拟。
                        OfflineBotSpawner.SetUnityPos(data, directPos.x, nativePos.y, directPos.z);
                        SyncBotPmoveEntityPosition(b.Id, data);
                    }
                }
                ExecuteBotBspStep(b, data, it, prof, OfflineBotSpawner.GetUnityPos(data), nativeVertical);
                return;
            }
            float pmVel;
            float targetSpeed = ReferencePlayerSpeed();
            if (PmoveStep(b, data, it, prof, dir, targetSpeed, Mathf.Clamp(Time.deltaTime, 0.001f, 0.05f), out pmVel))
            {
                int slowFrames = 0;
                _botSlowFrames.TryGetValue(b.Id, out slowFrames);
                if (it.HasMove && pmVel < targetSpeed * 0.35f)
                    slowFrames++;
                else
                    slowFrames = 0;
                _botSlowFrames[b.Id] = slowFrames;
                if (slowFrames >= 10)
                {
                    _botDirectMode.Add(b.Id);
                    Vector3 currentPos = OfflineBotSpawner.GetUnityPos(data);
                    UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + b.Id
                        + " switching=map-bsp target=" + targetSpeed.ToString("F0")
                        + " pmove=" + pmVel.ToString("F0") + " slowFrames=" + slowFrames);
                    ExecuteBotBspStep(b, data, it, prof, currentPos, prof.Bhop);
                }
                return;
            }

            // 实体缺少原版物理适配器时才走已有 BSP 保底路径。
            ExecuteBotBspStep(b, data, it, prof, pos);
        }
        catch (System.Exception ex)
        {
            if (!_botMoveErr)
            {
                _botMoveErr = true;
                UnityEngine.Debug.LogError("[OFFLINE-BOT-MOVE] failed: " + ex);
            }
        }
    }
    private static bool _botMoveErr;
    private static float s_botDuckWarnT;

    private bool IsBotNativeAirborne(int id)
    {
        if (!_botJumpLatch.Contains(id)) return false;
        try
        {
            foreach (PlayerEntity pe in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
                if (pe.entityId.Value == id && pe.hasMove && pe.move.PyPlayerMove != null)
                    return !pe.move.PyPlayerMove.IsOnGround();
        }
        catch (System.Exception) { }
        return false;
    }

    private static void SyncBotPmoveEntityPosition(int id, PlayerEntityData data)
    {
        try
        {
            foreach (PlayerEntity pe in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (pe.entityId.Value != id || !pe.hasMove || pe.move.PyPlayerMove == null) continue;
                var ent = pe.move.PyPlayerMove.GetEntity();
                if (ent == null) return;
                ent.SetX(data.X);
                ent.SetY(data.Y);
                ent.SetZ(data.Z);
                return;
            }
        }
        catch (System.Exception) { }
    }

    private void ExecuteBotBspStep(OfflineBotAgent b, PlayerEntityData data, BotIntent it, BotProfile prof,
        Vector3 pos, bool nativeVertical = false)
    {
        // [OFFLINE-AI8] 摇杆模式：AI 给 (MoveForward/MoveRight) 时按 MoveYaw 的
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
        float distance = stickMode ? 999f : delta.magnitude;
        float dt = Mathf.Clamp(Time.deltaTime, 0.001f, 0.05f);
        float playerSpeed = ReferencePlayerSpeed();
        float targetSpeed = Mathf.Max(520f, playerSpeed);
        float desired = targetSpeed;
        b.ActualSpeed = Mathf.MoveTowards(b.ActualSpeed, desired, 1400f * dt);
        float speed = Mathf.Max(0f, b.ActualSpeed) / 100f;
        // [OFFLINE-AI8] 摇杆模式没有'到达'概念（由 AI 状态机管距离），全速走
        float step = stickMode ? speed * dt : Mathf.Min(distance, speed * dt);
        if (step <= 0.001f) step = 0f;
        Vector3 target = pos + delta.normalized * step;

        Vector3 fromRaw = OfflineBotNav.UnityToRaw(pos);
        Vector3 toRaw = OfflineBotNav.UnityToRaw(target);
        Vector3 walkedRaw;
        bool airborne = nativeVertical ? IsBotNativeAirborne(b.Id) : OfflineBotPhysics.IsAirborne(b.Id);
        bool airDuck = prof.Bhop && airborne;
        if (prof.Bhop)
        {
            // [OFFLINE-BHOP50] 保底路径专用：实体拿到 PyPlayerMove 后走 PmoveStep
            // （引擎原生 bhop：落地跳位 + 引擎空中加速），这里只在适配器创建失败时
            // 用自建近似顶上。自建八向空中加速与引擎行为不同，仅止损用。
            Vector3 airVelocity = OfflineBotPhysics.ApplyAirAcceleration(
                b.Id, delta, targetSpeed, dt, airborne);
            if (airborne && airVelocity.sqrMagnitude > 0.01f)
            {
                delta = airVelocity.normalized;
                speed = airVelocity.magnitude / 100f;
                step = speed * dt;
                target = pos + delta * step;
                toRaw = OfflineBotNav.UnityToRaw(target);
            }
        }
        if (step <= 0.001f)
        {
            walkedRaw = fromRaw;
        }
        else if (airborne)
        {
            Vector3 airEnd, airNormal; float airFrac;
            if (!OfflineBotPhysics.Cast(fromRaw + Vector3.up * 2f, toRaw + Vector3.up * 2f,
                OfflineBotPhysics.Radius, OfflineBotPhysics.Height, out airEnd, out airNormal, out airFrac))
                walkedRaw = fromRaw;
            else walkedRaw = airEnd;
        }
        else if (!OfflineBotPhysics.TryWalk(fromRaw, toRaw, out walkedRaw))
        {
            walkedRaw = fromRaw;
        }
        // [OFFLINE-BHOPCHAIN] 链路诊断（限频 20 条）：WantJump 是否到达物理层、Grounded 状态
        if (prof.Bhop && s_chainLogN < 20)
        {
            s_chainLogN++;
            UnityEngine.Debug.Log("[OFFLINE-BHOPCHAIN] id=" + b.Id + " wantJump=" + it.WantJump
                + " grounded=" + (nativeVertical ? !airborne : OfflineBotPhysics.IsGrounded(b.Id))
                + " airborne=" + airborne + " step=" + step.ToString("F4")
                + " hasMove=" + it.HasMove + " crouch=" + it.WantCrouch);
        }
        if (nativeVertical)
        {
            // Pmove 已经更新了原版垂直坐标；BSP 只负责水平扫掠，不能再叠加第二套重力/起跳。
            walkedRaw.y = fromRaw.y;
        }
        else
        {
            Vector3 verticalRaw;
            OfflineBotPhysics.ApplyVertical(b.Id, walkedRaw, it.WantJump, it.WantCrouch || airDuck, dt,
                1f, out verticalRaw);
            walkedRaw = verticalRaw;
        }
        ISnapshot snap = Snap();
        if (snap != null)
            walkedRaw = OfflineBotPhysics.BlockActors(snap, b.Id, fromRaw, walkedRaw, OfflineBotPhysics.Height);
        if (nativeVertical) walkedRaw.y = fromRaw.y;
        Vector3 walked = OfflineBotNav.RawToUnity(walkedRaw);
        float moved = Vector3.Distance(pos, walked);
        if (moved <= 0.001f) return;
        OfflineBotSpawner.SetUnityPos(data, walked.x, walked.y, walked.z);
        if (!nativeVertical)
            data.DuckState = (it.WantCrouch || airDuck) ? 2 : 3;
        data.MoveYaw = it.MoveYaw;
        data.ViewYaw = it.ViewYaw;   // [OFFLINE-VISION] 视线（含晃动）
        if (nativeVertical) SyncBotPmoveEntityPosition(b.Id, data);
        b.LastPos = walked;
        b.LastPosTime = Time.time;
        // 卡住判断使用决策层的累计位移，不能被每帧微小的 BSP 位移清零。
    }

    private float _referencePlayerSpeed = 520f;

    private float ReferencePlayerSpeed()
    {
        try
        {
            PlayerEntity player = Contexts.sharedInstance.player.myPlayerEntity;
            if (player != null && player.hasMove && player.move.PyPlayerMove != null)
            {
                var v = player.move.PyPlayerMove.GetVelocity();
                float s = Mathf.Sqrt((float)(v.x * v.x + v.y * v.y));
                if (s > 40f) _referencePlayerSpeed = Mathf.Clamp(s, 520f, 660f);
            }
        }
        catch (System.Exception) { }
        return _referencePlayerSpeed;
    }

    // Playback restores MoveComponent from Current each frame; preserve the full native
    // velocity in the same snapshots that feed that restore, not just Velocity2D.
    private static void StoreBotVelocity(PlayerEntity pe, PlayerEntityData data, float x, float y, float z)
    {
        PlayerEntityData[] snapshots = { data,
            pe != null && pe.hasBasicInfo ? pe.basicInfo.Current : null,
            pe != null && pe.hasBasicInfo ? pe.basicInfo.Next : null };
        foreach (PlayerEntityData snapshot in snapshots)
        {
            if (snapshot == null) continue;
            if (snapshot.Velocity == null) snapshot.Velocity = new Vector3DData();
            snapshot.Velocity.X = x;
            snapshot.Velocity.Y = y;
            snapshot.Velocity.Z = z;
        }
    }

    /// <summary>原版 pmove 驱动（独立实例）。返回本帧实际水平速度 cm/s。</summary>
    private bool PmoveStep(OfflineBotAgent b, PlayerEntityData data, BotIntent it, BotProfile prof,
        Vector3 dir, float speed, float dt, out float velocity)
    {
        velocity = 0f;
        PlayerEntity pe = null;
        foreach (PlayerEntity e in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
        {
            if (e.entityId.Value == b.Id) { pe = e; break; }
        }
        if (pe == null || !pe.hasMove) return false;
        // map12 练枪人机直接继承本地玩家的跳跃加成参数，让起跳高度与玩家使用同一套 Pmove 配置。
        try
        {
            if (prof.Bhop)
            {
                PlayerEntity local = Contexts.sharedInstance.player.myPlayerEntity;
                if (local != null && local.hasSkill && pe.hasSkill
                    && local.skill.SkillAdditionalData != null && pe.skill.SkillAdditionalData != null)
                {
                    pe.skill.SkillAdditionalData.JumpHeight = local.skill.SkillAdditionalData.JumpHeight;
                    pe.skill.SkillAdditionalData.JumpHeightRate = local.skill.SkillAdditionalData.JumpHeightRate;
                }
            }
            else if (pe.hasSkill && pe.skill.SkillAdditionalData != null)
            {
                pe.skill.SkillAdditionalData.JumpHeight = 0;
                pe.skill.SkillAdditionalData.JumpHeightRate = 0f;
            }
        }
        catch (System.Exception) { }
        // bot 的 CheckFalling 会在引擎仍判定离地时留下限速位；先清理再取玩家跑速，
        // 否则同一套满幅摇杆也会被持续压成慢走。练枪 bot 不执行蹲伏输入。
        pe.move.IsLimitMaxSpeed = false;
        if (pe.move.PyPlayerMove == null)
        {
            try
            {
                pe.move.PyPlayerMove = (physics.IPyPlayerMove)(object)new PyPlayerAdapter(
                    pe, Contexts.sharedInstance.weapon);
                var room = Contexts.sharedInstance.battleRoom;
                if (room.hasPyEngine && room.pyEngine.PyEngine != null)
                    room.pyEngine.PyEngine.GetEntityManager().UpdateEntityNormalBrush(
                        0, pe.move.PyPlayerMove.GetEntity());
                UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + b.Id + " created PyPlayerAdapter");
            }
            catch (System.Exception ex)
            {
                UnityEngine.Debug.LogWarning("[OFFLINE-BOT-MOVE] id=" + b.Id + " adapter failed: " + ex.Message);
                return false;
            }
        }

        physics.IPyMove pmove = GetBotPmove(b.Id);
        if (pmove == null) return false;
        // 如果本 bot 从 BSP 保底路径切回原版 Pmove，丢弃保底路径残留的垂直状态。
        OfflineBotPhysics.ResetVertical(b.Id, !prof.Bhop);

        float moveYaw = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;

        BotMoveState st;
        if (!_botMove.TryGetValue(b.Id, out st))
        {
            st = new BotMoveState();
            st.Cmd = new SSJJUserCmd.UserCmd();
            st.Adapter = new SSJJUserCmd.PyUserCmdAdapter(st.Cmd);
            _botMove[b.Id] = st;
        }
        st.Cmd.Seq = UnityEngine.Time.frameCount;
        st.Cmd.FrameInterval = Mathf.Clamp((int)(dt * 1000f), 10, 50);
        // [OFFLINE-PMOVE-NATIVE] CameraYaw/Pitch = 视线（与玩家一致：输入系统录的就是视角）。
        // AI 摇杆相对 MoveYaw 定义，旋转到视线系后给引擎——位移结果与旧写法等价，
        // 但 cmd 里记录的 CameraYaw 就是真人视角值（引擎若用它做视角相关处理也一致）。
        st.Cmd.CameraYaw = (short)(it.ViewYaw * 100f);
        st.Cmd.CameraPitch = (short)(it.ViewPitch * 100f);
        bool onGroundNow = true;
        try { onGroundNow = pe.move.PyPlayerMove.IsOnGround(); } catch (System.Exception) { }
        float moveForward = it.MoveForward;
        float moveRight = it.MoveRight;
        // 初建 PyPlayerMove 时引擎可能有一帧报告离地；只有本 bot 真正发过跳跃边沿后，
        // 才把该离地状态视为跳跃空中段。否则会在出生帧错误按蹲并卡进地面。
        bool jumpLatched = _botJumpLatch.Contains(b.Id);
        ApplyBotBhopAirStrafe(st, prof.Bhop && jumpLatched, onGroundNow, ref moveForward, ref moveRight);
        bool stickMode = (moveForward != 1f || moveRight != 0f);
        float mf, mr;
        if (stickMode)
        {
            float rel = (it.MoveYaw - it.ViewYaw) * Mathf.Deg2Rad;
            float inF = Mathf.Clamp(moveForward, -1f, 1f) * 100f;
            float inR = Mathf.Clamp(moveRight, -1f, 1f) * 100f;
            float stickLen = Mathf.Sqrt(inF * inF + inR * inR);
            if (stickLen > 0.01f)
            {
                // AI 的 0.4/0.7 方向权重只表达偏向，不代表静步；有移动意图时
                // 将摇杆归一化到玩家满幅，斜向也保持完整跑速。
                float scale = 100f / stickLen;
                inF *= scale;
                inR *= scale;
            }
            mf = inF * Mathf.Cos(rel) - inR * Mathf.Sin(rel);
            mr = inF * Mathf.Sin(rel) + inR * Mathf.Cos(rel);
        }
        else
        {
            // 寻路模式：dir 已由 MoveYaw 合成（上方 ExecuteBotMove），视线系下等效前移
            float rel = (it.MoveYaw - it.ViewYaw) * Mathf.Deg2Rad;
            mf = Mathf.Cos(rel) * 100f;
            mr = Mathf.Sin(rel) * 100f;
        }
        // 与玩家同源：PlayerSpeedUtil.GetPlayerSpeed
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

        // 原版 ComputeUserCommandSystem 写入 ±100；PyUserCmdAdapter 自行转换到物理单位。
        st.Cmd.MoveForward = mf;
        st.Cmd.MoveRight = mr;
        int buttons = 0;
        if (mf > 0.01f) buttons |= 1;
        else if (mf < -0.01f) buttons |= 2;
        if (mr > 0.01f) buttons |= 8;
        else if (mr < -0.01f) buttons |= 4;
        // [OFFLINE-PMOVE-NATIVE] 跳位边沿化：只有落地帧给 0x20（真人 bhop 的输入模式——
        // 落地瞬间按跳；空中不按）。旧实现 WantJump 持续置位 = 外挂式按住不放，
        // 引擎在异常 ground 状态下会把 bot 一直往上推（悬空爬墙截图实况）。
        if (!onGroundNow && jumpLatched)
        {
            st.JumpObservedAirborne = true;
        }
        else if (onGroundNow && jumpLatched
            && (st.JumpObservedAirborne || Time.time - st.JumpIssuedAt >= 0.28f))
        {
            // 必须确实离地再落地才重置；若天花板挡住起跳，短暂延迟后允许重试。
            _botJumpLatch.Remove(b.Id);
            st.JumpObservedAirborne = false;
            jumpLatched = false;
        }
        bool jumpEdge = it.WantJump && onGroundNow && !jumpLatched;
        if (jumpEdge) buttons |= 0x20;
        bool airDuck = prof.Bhop && !onGroundNow && jumpLatched;
        if (it.WantCrouch || airDuck) buttons |= 0x80;
        st.Cmd.Buttons = buttons;
        // 每次起跳只发一个 Pmove 脉冲，空中和落地检测延迟期间都不会叠加跳跃速度。
        if (jumpEdge)
        {
            _botJumpLatch.Add(b.Id);
            st.JumpObservedAirborne = false;
            st.JumpIssuedAt = Time.time;
            if (Time.time >= st.NextJumpDiagTime)
            {
                st.NextJumpDiagTime = Time.time + 1f;
                UnityEngine.Debug.Log("[OFFLINE-BOT-JUMP] id=" + b.Id + " edge=1 grounded=" + onGroundNow
                    + " pos=" + data.X.ToString("F0") + "," + data.Y.ToString("F0") + "," + data.Z.ToString("F0"));
            }
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
        // Pmove.CheckFalling() 可能再次置限速位。即便引擎暂时未判定落地，也要在
        // 本次移动前清除，避免 bot 长期以 17–76 cm/s 爬行；角色保持站立跑动。
        try
        {
            pe.move.IsLimitMaxSpeed = false;
            pe.move.PyPlayerMove.DeletePlayerStateType(4194304, false);
        }
        catch (System.Exception) { }

        var beforeMove = pe.move.PyPlayerMove.GetVelocity();
        float beforeX = (float)beforeMove.x, beforeY = (float)beforeMove.y, beforeZ = (float)beforeMove.z;
        pmove.SetMove(pe.move.PyPlayerMove, st.Adapter, nativeSpeed);

        // 与原版 PlayerMovePredicationSystem 同序：Pmove 后运行 DuckManager，
        // 让空中蹲真正更新 DUCK_JUMP 碰撞盒、视高和 DuckState。
        try
        {
            if (st.DuckManager == null)
            {
                var room = Contexts.sharedInstance.battleRoom;
                var engine = room.pyEngine.PyEngine;
                st.DuckManager = new physics.DuckManager(pmove, engine.GetWorld());
            }
            if (pe.CanDuck())
                st.DuckManager.Duck(pe.move.PyPlayerMove.GetEntity(), pe.move.PyPlayerMove, st.Adapter);
        }
        catch (System.Exception ex)
        {
            if (UnityEngine.Time.realtimeSinceStartup - s_botDuckWarnT > 3f)
            {
                s_botDuckWarnT = UnityEngine.Time.realtimeSinceStartup;
                UnityEngine.Debug.LogWarning("[OFFLINE-BHOP-DUCK] id=" + b.Id + " DuckManager failed: " + ex.Message);
            }
        }

        double ax = pe.move.PyPlayerMove.GetX();
        double ay = pe.move.PyPlayerMove.GetY();
        double az = pe.move.PyPlayerMove.GetZ();
        if (double.IsNaN(ax) || double.IsNaN(ay) || double.IsNaN(az)) return false;
        data.X = (float)ax; data.Y = (float)ay; data.Z = (float)az;
        data.DuckState = pe.move.DuckState;
        data.MoveYaw = it.MoveYaw;
        data.ViewYaw = it.ViewYaw;
        // [SERVER-AUTHORITY] 身体朝向由 Pmove 帧的视线写回实体，快照/Capture 再读它。
        if (pe.hasOrientation)
        {
            pe.orientation.Yaw = it.ViewYaw;
            pe.orientation.Pitch = it.ViewPitch;
        }

        float verticalVelocity = 0f;
        try
        {
            var vv = pe.move.PyPlayerMove.GetVelocity();
            velocity = Mathf.Sqrt((float)(vv.x * vv.x + vv.y * vv.y));
            verticalVelocity = (float)vv.z;
            StoreBotVelocity(pe, data, (float)vv.x, (float)vv.y, (float)vv.z);
        }
        catch (System.Exception) { }
        b.ActualSpeed = velocity;
        if (b.PmoveDiagCount < 12)
        {
            b.PmoveDiagCount++;
            Debug.Log("[OFFLINE-PMOVE-PROBE] id=" + b.Id + " step=" + b.PmoveDiagCount
                + " frameMs=" + st.Cmd.FrameInterval + " speed=" + nativeSpeed
                + " cmd=" + st.Cmd.MoveForward.ToString("F1") + "," + st.Cmd.MoveRight.ToString("F1")
                + " pyCmd=" + st.Adapter.MoveForward.ToString("F1") + "," + st.Adapter.MoveRight.ToString("F1")
                + " pre=" + beforeX.ToString("F1") + "," + beforeY.ToString("F1") + "," + beforeZ.ToString("F1")
                + " ground=" + onGroundNow + " vel=" + velocity.ToString("F1") + " vz=" + verticalVelocity.ToString("F1")
                + " pos=" + data.X.ToString("F1") + "," + data.Y.ToString("F1") + "," + data.Z.ToString("F1"));
        }
        if (pe.hasMove) pe.move.Velocity2D = (int)velocity;
        // [SERVER-AUTHORITY] Pmove 是权威：把腿/上半身/蹲伏/速度写回快照字段，
        // 随后由 PlayerLegAnimInitSystem/PlayerTorseAnimInitSystem 消费。
        if (OfflineServerAuthority.Enabled)
        {
            try
            {
                OfflineServerAuthority.CapturePmoveState(pe, data, Contexts.sharedInstance.time.time.RenderTime, velocity);
            }
            catch (System.Exception) { }
        }
        Vector3 walked = OfflineBotSpawner.GetUnityPos(data);
        b.LastPos = walked;
        b.LastPosTime = Time.time;
        // [OFFLINE-STUCK] 不要在这里重置 StuckPos/StuckTime：
        // 它们归 AI Tick 的卡住检测所有，每帧重置会让"撞墙 vel=0"永远检测不到。

        if (UnityEngine.Time.realtimeSinceStartup - s_botMoveLog > 2.0f)
        {
            s_botMoveLog = UnityEngine.Time.realtimeSinceStartup;
            UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + b.Id + " mode=pmove"
                + " vel=" + velocity.ToString("F0") + " max=" + nativeSpeed.ToString("F0")
                + " ground=" + pe.move.PyPlayerMove.IsOnGround()
                + " vz=" + verticalVelocity.ToString("F0")
                + " jumpEdge=" + jumpEdge
                + " duck=" + pe.move.DuckState + " airAD=" + (st.AirStrafeStep + 1) + "/" + BotBhopAirStrokeCount
                + " ent=" + pe.move.PyPlayerMove.GetX().ToString("F0") + "," + pe.move.PyPlayerMove.GetY().ToString("F0") + "," + pe.move.PyPlayerMove.GetZ().ToString("F0")
                + " data=" + data.X.ToString("F0") + "," + data.Y.ToString("F0") + "," + data.Z.ToString("F0")
                + " cmdF=" + st.Cmd.MoveForward.ToString("F0") + " btn=" + st.Cmd.Buttons);
        }
        return true;
    }

    /// <summary>BSP 直接驱动：自算位移 + 体积扫描 + 撞墙滑行/台阶 + 贴地。</summary>
    private void DirectStep(OfflineBotAgent b, PlayerEntityData data, Vector3 dir, float speed, float dt)
    {
        float step = speed * dt;
        float R = OfflineBotPhysics.Radius;
        float H = OfflineBotPhysics.Height;

        Vector3 cur = new Vector3(-data.Y, data.Z + 2f, data.X);
        Vector3 delta = new Vector3(dir.x * step, 0f, dir.z * step);
        Vector3 want = cur + delta;

        Vector3 hit, normal; float frac;
        bool blocked = OfflineBotPhysics.Cast(cur, want, R, H, out hit, out normal, out frac);
        Vector3 dest = blocked ? hit : want;

        if (blocked && frac < 0.95f)
        {
            Vector3 upFrom = cur + new Vector3(0f, 50f, 0f);
            Vector3 upTo = upFrom + delta;
            Vector3 uhit; float ufrac;
            if (!OfflineBotPhysics.Cast(upFrom, upTo, R, H, out uhit, out normal, out ufrac))
            {
                dest = upTo;
            }
            else
            {
                Vector3 remain = want - hit;
                float vn = Vector3.Dot(remain, normal);
                Vector3 slide = remain - normal * vn;
                if (slide.sqrMagnitude > 0.01f)
                {
                    Vector3 sTo = hit + slide;
                    Vector3 shit; float sfrac;
                    if (!OfflineBotPhysics.Cast(hit, sTo, R, H, out shit, out normal, out sfrac))
                        dest = sTo;
                    else
                        dest = shit;
                }
            }
        }

        Vector3 gFrom = new Vector3(dest.x, dest.y + 20f, dest.z);
        Vector3 gTo = new Vector3(dest.x, dest.y - 220f, dest.z);
        Vector3 ghit; float gfrac;
        if (OfflineBotPhysics.Cast(gFrom, gTo, R, H, out ghit, out normal, out gfrac))
        {
            float drop = dest.y - ghit.y;
            if (drop >= -5f && drop < 120f) dest.y = ghit.y + 1f;
        }

        data.X = dest.z;
        data.Y = -dest.x;
        data.Z = dest.y;

        // [OFFLINE-FIX] 引擎实体必须跟着走：原版弹道/碰撞查的是 mover 的 brush，
        // 只改快照数据会让 bot 在物理世界里停在出生点，子弹全部打空。
        try
        {
            foreach (PlayerEntity pe in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (pe.entityId.Value != b.Id) continue;
                if (pe.hasMove && pe.move.PyPlayerMove != null)
                {
                    var ent = pe.move.PyPlayerMove.GetEntity();
                    if (ent != null)
                    {
                        ent.SetX(data.X);
                        ent.SetY(data.Y);
                        ent.SetZ(data.Z);
                    }
                }
                break;
            }
        }
        catch (System.Exception) { }

        // [OFFLINE-SYNC] 第三人称模型位置兜底。
        // 原版链路是 快照 -> basicInfo -> UnityTransform 系统 -> ThirdTran.RootContainer，
        // 但那套系统在离线环境对非本地玩家不跑（日志实测：data 从 -55 走到 -31，
        // 实体 basicInfo 也跟上了，但模型仍停在出生点）。
        // 这里直接把根节点对齐到 Unity 世界坐标，保证"人在跑"而不只是数据在跑。
        try
        {
            foreach (PlayerEntity pe2 in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.ThirdPersonUnityObjects))
            {
                if (pe2.entityId.Value != b.Id) continue;
                if (!pe2.hasThirdPersonUnityObjects) break;
                var tps = pe2.thirdPersonUnityObjects;
                if (tps == null || tps.ThirdTran == null) break;
                Vector3 upos = new Vector3(-data.Y / 100f, data.Z / 100f, data.X / 100f);
                if (tps.ThirdTran.RootContainer != null)
                {
                    tps.ThirdTran.RootContainer.transform.position = upos;
                    // [OFFLINE-VISFIX] 防"模型被剔除后冻结消失"（实机症状：bot 基本看不见、偶尔闪一下、
                    // 没有移动动画）。根因是 SkinnedMeshRenderer.updateWhenOffscreen=false：
                    // 渲染器一旦被视锥剔除，世界空间 bounds 停止更新，模型跑出陈旧 bounds 后
                    // 永远判屏外；Animator 对已剔除对象也停止采样。强制 bounds 每帧更新 +
                    // 动画永不休眠。模型重建后 RootContainer 实例会变，靠缓存自动重设。
                    EnsureBotRenderVisible(b.Id, tps.ThirdTran.RootContainer);
                    // [OFFLINE-ROOTFIX] 缓存目标位置，LateUpdate 在动画采样后重新钉住
                    // （防 SJAnimationPlayer 用片段根曲线把模型搬走）。
                    _rootFixObj[b.Id] = tps.ThirdTran.RootContainer;
                    _rootFixPos[b.Id] = upos;
                }
                else if (tps.ThirdTran.BodyTransform != null)
                {
                    tps.ThirdTran.BodyTransform.position = upos;
                }
                break;
            }
        }
        catch (System.Exception exSync)
        {
            if (!_syncPosErr) { _syncPosErr = true; UnityEngine.Debug.LogError("[OFFLINE-SYNC] transform sync failed: " + exSync); }
        }
    }

    private float _nextFire;
    private float _lastFireAt;
    private static float s_botMoveLog;
    private static int s_chainLogN;

    // [OFFLINE-VISFIX] 每个 bot 上次设过可见性标志的 RootContainer 实例（模型重建后自动重设）。
    private static readonly System.Collections.Generic.Dictionary<int, GameObject> _visFixRoot =
        new System.Collections.Generic.Dictionary<int, GameObject>();

    // [OFFLINE-ROOTFIX] 每个 bot 最近一次 DirectStep 目标位置（RootContainer 实例 + 世界坐标）。
    // 根因（实机症状：bot 移动时整体消失、停下闪一下）：
    // SSJJAnim.SJAnimationPlayer.GenerateBones(base.transform, _bones) 把模型根 Transform
    // 本身也注册成骨骼；ApplyKeyFrame/MainThreadApplyKeyFrame 每帧执行
    // bone.localPosition = clipCurve.Position。跑步/行走片段的根骨骼位置曲线非零，
    // 会在 DirectStep 写位置之后把整个模型搬到片段曲线指定的位置（远离地图 → 看不见）；
    // 空闲片段根曲线≈0，模型回到 RootContainer 位置 → 停下时"闪一下"。
    // 修复：DirectStep 缓存目标世界坐标，LateUpdate（动画采样之后）重新钉回。
    private static readonly System.Collections.Generic.Dictionary<int, GameObject> _rootFixObj =
        new System.Collections.Generic.Dictionary<int, GameObject>();
    private static readonly System.Collections.Generic.Dictionary<int, Vector3> _rootFixPos =
        new System.Collections.Generic.Dictionary<int, Vector3>();

    private void UpdateBotDeathVisualsFromEntities()
    {
        try
        {
            foreach (PlayerEntity pe in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (pe == null || pe.entityId.Value < 200 || !pe.hasBasicInfo || !pe.hasThirdPersonUnityObjects)
                    continue;
                var tp = pe.thirdPersonUnityObjects.ThirdTran;
                if (tp == null || tp.RootContainer == null)
                    continue;
                UpdateBotDeathVisual(pe.entityId.Value, tp.RootContainer, pe.basicInfo.IsDead);
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-DEATH] entity traversal failed: " + ex.Message);
        }
    }

    private void UpdateBotDeathVisual(int id, GameObject root, bool dead)
    {
        // [OFFLINE-DEATH-NATIVE] 不再旋转、下沉或缩放 RootContainer。
        // bot 的倒地姿势由原版 TorsoAnim=19 (TORSO_DIE) 与角色骨骼动画播放。
    }

    /// <summary>[OFFLINE-VISFIX] 对 bot 第三人称模型强制：
    /// 1) SkinnedMeshRenderer.updateWhenOffscreen=true —— 剔除后 bounds 继续每帧更新，
    ///    模型不会困在陈旧 bounds 里被判为屏外（症状：bot 看不见 / 闪）；
    /// 2) Animator.cullingMode=AlwaysAnimate —— 已剔除对象的动画永不停采样
    ///    （症状：没有移动动画）。
    /// 只在 RootContainer 实例变化（模型重建）时重跑一次，平时零开销。</summary>
    private static void EnsureBotRenderVisible(int botId, GameObject root)
    {
        if (root == null) return;
        GameObject last;
        if (_visFixRoot.TryGetValue(botId, out last) && last == root) return;
        _visFixRoot[botId] = root;
        try
        {
            SkinnedMeshRenderer[] smrs = root.GetComponentsInChildren<SkinnedMeshRenderer>(true);
            for (int i = 0; i < smrs.Length; i++)
            {
                if (smrs[i] == null) continue;
                smrs[i].updateWhenOffscreen = true;
            }
            Animator[] anims = root.GetComponentsInChildren<Animator>(true);
            for (int i = 0; i < anims.Length; i++)
            {
                if (anims[i] == null) continue;
                anims[i].cullingMode = AnimatorCullingMode.AlwaysAnimate;
            }
        }
        catch (System.Exception) { }
    }

    // 松手后把开火姿势还原为举枪待机（TORSO_RAISE），否则会停在最后一帧开火动画。
    private void RestoreFpIdle()
    {
        // [OFFLINE-ANIM] 原版视图预测会从攻击态回到待机；这里不再强行写 STAND，避免与攻击动画互相覆盖造成闪烁。
    }

    // [OFFLINE-PATCH] 离线手雷：原版投掷依赖服务器 UserCmd，离线自行模拟抛掷物与爆炸结算。
    private class GrenadeBall
    {
        public Vector3 Pos;
        public Vector3 Vel;
        public float FuseAt;
        public GameObject Visual;
        // [OFFLINE-GRENADE] 0=破片 / 1=闪光 / 2=烟雾（按 Weapon.json 名字分类，原版按 EventId）。
        public int Kind;
    }

    /// <summary>[OFFLINE-EQUIP] 原版护甲减伤由服务端结算；客户端没有数值表，按经典口径近似：
    /// 防弹衣吸收 50% 伤害；戴头盔时高伤害（爆头/大口径）再乘 0.75。</summary>
    private static float AbsorbArmor(PlayerEntityData d, float dmg)
    {
        if (d == null) return dmg;
        float outDmg = dmg;
        if (d.ArmorBody) outDmg *= 0.5f;
        if (d.ArmorHead && dmg >= 45f) outDmg *= 0.75f;
        return outDmg;
    }

    private static float ResolvePlayerShotDamage(WeaponEntity weapon, bool meleeShot)
    {
        if (meleeShot) return 55f;
        string weaponName = weapon != null && weapon.hasBasicInfo && weapon.basicInfo.Data != null
            ? weapon.basicInfo.Data.WeaponName : "";
        int nativeDamage = 0;
        int weaponType = -1;
        Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo info = null;
        if (weapon != null && weapon.hasBasicInfo)
        {
            try
            {
                info = weapon.basicInfo.Info as Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo;
                if (info == null && !string.IsNullOrEmpty(weaponName))
                    info = Assets.Sources.Info.Weapon.WeaponInfoFactory.Instance.GetWeaponInfo(weaponName)
                        as Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo;
                if (info != null)
                {
                    nativeDamage = info.Damage;
                    weaponType = info.WeaponType;
                }
            }
            catch (System.Exception) { }
        }
        float damage = nativeDamage;
        if (damage <= 1f)
        {
            // 离线客户端没有服务端的逐枪伤害结算字段，按原版武器类型给出保底伤害。
            switch (weaponType)
            {
                case 0: damage = 30f; break;  // 手枪
                case 2: damage = 55f; break;  // 近战
                case 5: damage = 110f; break; // 狙击枪
                case 6: damage = 90f; break;  // 霰弹枪
                case 10: damage = 34f; break; // 机枪
                default:
                    damage = weaponName.IndexOf("awm", System.StringComparison.OrdinalIgnoreCase) >= 0
                        || weaponName.IndexOf("barrett", System.StringComparison.OrdinalIgnoreCase) >= 0
                        ? 110f : 38f;
                    break;
            }
        }
        // 练枪配置：屠魔 AWM 至少 320 点，防弹衣/头盔吸收后仍能一枪击杀。
        if (string.Equals(weaponName, "awm_legend_t", System.StringComparison.OrdinalIgnoreCase))
            damage = Mathf.Max(damage, 320f);
        return damage;
    }

    private static void ApplyAwmKnockback(int targetId, Vector3 shotDirection)
    {
        ApplyKnockback(targetId, shotDirection, 650f, 220f);
    }

    public static void ApplyKnockback(int targetId, Vector3 shotDirection, float horizontalImpulse, float verticalImpulse)
    {
        try
        {
            PlayerEntity target = null;
            foreach (PlayerEntity entity in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (entity != null && entity.entityId.Value == targetId) { target = entity; break; }
            }
            if (target == null || !target.hasMove) return;
            if (target.move.PyPlayerMove == null)
            {
                target.move.PyPlayerMove = new PyPlayerAdapter(target, Contexts.sharedInstance.weapon);
                var room = Contexts.sharedInstance.battleRoom;
                if (room.hasPyEngine && room.pyEngine.PyEngine != null)
                    room.pyEngine.PyEngine.GetEntityManager().UpdateEntityNormalBrush(
                        0, target.move.PyPlayerMove.GetEntity());
            }
            var adapter = target.move.PyPlayerMove;
            if (adapter == null) return;
            Vector3 flat = new Vector3(shotDirection.x, 0f, shotDirection.z);
            if (flat.sqrMagnitude < 0.0001f) return;
            flat.Normalize();
            var velocity = adapter.GetVelocity();
            adapter.SetVelocity(
                (float)velocity.x + flat.z * horizontalImpulse,
                (float)velocity.y - flat.x * horizontalImpulse,
                (float)velocity.z + verticalImpulse);
            var pushed = adapter.GetVelocity();
            var snapshot = Instance != null ? Instance.Snap() : null;
            StoreBotVelocity(target, snapshot != null ? Get(snapshot, targetId) : null,
                (float)pushed.x, (float)pushed.y, (float)pushed.z);
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-KNOCKBACK] target=" + targetId + " failed: " + ex.Message);
        }
    }

    public bool TryGetBotEyeUnityPos(int botId, out Vector3 eyeUnity)
    {
        eyeUnity = Vector3.zero;
        var s = Snap();
        if (s == null) return false;
        var d = Get(s, botId);
        if (d == null) return false;
        float viewHeight = d.ViewHeight > 10f ? d.ViewHeight : EyeHeight;
        eyeUnity = OfflineBotSpawner.GetUnityPos(d) + Vector3.up * (viewHeight / 100f);
        return true;
    }

    public List<int> GetBotsInCone(Vector3 originUnity, Vector3 forward, float maxDistCm, float minCos, int maxCount)
    {
        var result = new List<int>();
        var s = Snap();
        if (s == null) return result;
        Vector3 originCm = originUnity.magnitude < 500f ? originUnity * 100f : originUnity;
        var scored = new List<System.Collections.Generic.KeyValuePair<int, float>>();
        foreach (var kv in _agents)
        {
            if (!kv.Value.Alive) continue;
            var d = Get(s, kv.Key);
            if (d == null || !IsEnemyOfPlayer(d)) continue;
            float viewHeight = d.ViewHeight > 10f ? d.ViewHeight : EyeHeight;
            Vector3 targetCm = (OfflineBotSpawner.GetUnityPos(d) + Vector3.up * (viewHeight * 0.5f / 100f)) * 100f;
            Vector3 delta = targetCm - originCm;
            float dist = delta.magnitude;
            if (dist > maxDistCm) continue;
            if (minCos > -0.99f && dist > 1f)
            {
                float cos = Vector3.Dot(delta / dist, forward);
                if (cos < minCos) continue;
            }
            scored.Add(new System.Collections.Generic.KeyValuePair<int, float>(kv.Key, dist));
        }
        scored.Sort((a, b) => a.Value.CompareTo(b.Value));
        int limit = Mathf.Min(maxCount, scored.Count);
        for (int i = 0; i < limit; i++) result.Add(scored[i].Key);
        return result;
    }

    private static void SetBotNativeDeathAnimation(int botId, PlayerEntityData data)
    {
        try
        {
            int renderTime = Contexts.sharedInstance.time.time.RenderTime;
            int duration = 0;
            int legsDuration = 0;
            data.LegsAnim = 11; // 原版 LEGS_DIE
            data.LegsAnimSpecified = true;
            data.TorsoAnim = 19; // 原版 TORSO_DIE
            data.TorsoAnimSpecified = true;
            data.TorsoAnimStartTime = renderTime;
            data.TorsoAnimStartTimeSpecified = true;
            foreach (PlayerEntity entity in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (entity == null || entity.entityId.Value != botId || !entity.hasBasicInfo) continue;
                if (entity.hasLegAnim)
                {
                    try
                    {
                        Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetLegsAnimation(entity, 11);
                        legsDuration = Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.GetLegAnimDuration(entity, 11);
                    }
                    catch (System.Exception) { }
                }
                if (entity.hasTorseAnim && entity.hasCurrentWeapon)
                {
                    try
                    {
                        Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetTorseAnimation(entity, 19);
                        duration = entity.torseAnim.RemainTime;
                    }
                    catch (System.Exception) { }
                }
                if (duration <= 0 && entity.hasCurrentWeapon)
                {
                    try { duration = Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.GetTorseAnimDuration(entity, 19); }
                    catch (System.Exception) { }
                }
                if (entity.basicInfo.Current != null)
                {
                    entity.basicInfo.Current.LegsAnim = 11;
                    entity.basicInfo.Current.LegsSpeedAnimTime = 0;
                    entity.basicInfo.Current.TorsoAnim = 19;
                    entity.basicInfo.Current.TorsoAnimStartTime = renderTime;
                    entity.basicInfo.Current.TorsoAnimationTimer = duration;
                }
                if (entity.basicInfo.Next != null)
                {
                    entity.basicInfo.Next.LegsAnim = 11;
                    entity.basicInfo.Next.LegsSpeedAnimTime = 0;
                    entity.basicInfo.Next.TorsoAnim = 19;
                    entity.basicInfo.Next.TorsoAnimStartTime = renderTime;
                    entity.basicInfo.Next.TorsoAnimationTimer = duration;
                }
                break;
            }
            data.TorsoAnimationTimer = duration;
            data.TorsoAnimationTimerSpecified = true;
            data.LegsAnimationTimer = legsDuration;
            data.LegsAnimationTimerSpecified = true;
            Debug.Log("[OFFLINE-DEATH-ANIM] id=" + botId + " legs=11/" + legsDuration
                + " torso=19/" + duration);
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-DEATH-ANIM] id=" + botId + " failed: " + ex.Message);
        }
    }

    private readonly List<GrenadeBall> _grenades = new List<GrenadeBall>();

    // [OFFLINE-TDM] Bot 投掷物（自包含，与玩家 _grenades 互不影响）
    private class BotGrenade
    {
        public Vector3 Pos;
        public Vector3 Vel;
        public float FuseAt;
        public int Kind;        // 0 破片 / 1 闪光 / 2 烟雾
        public int OwnerId;
        public int OwnerTeam;
        public GameObject Visual;
    }

    private readonly List<BotGrenade> _botGrenades = new List<BotGrenade>();
    // [OFFLINE-SNAPSHOT-GRENADE] 手雷爆炸事件：写入快照交给原版 Playback 消费
    private int _nextExplosionEventId = 910000;
    private readonly List<int> _liveExplosionEventIds = new List<int>();
    private readonly List<int> _explosionEventFrames = new List<int>();
    private int _explosionFrameCounter;


	private bool _c4SitesReady;
	private Vector3 _c4SiteA;
	private Vector3 _c4SiteB;
	private bool _c4Planted;
	private int _c4SiteIndex;
	private Vector3 _c4Position;
	private float _c4ExplodesAt;
	private GameObject _c4Visual;
	public string BombStatusText { get; private set; } = "";

    private class FlyKnifeProjectile
    {
        public Vector3 Pos;
        public Vector3 Vel;
        public float EndAt;
        public GameObject Visual;
    }

    // [OFFLINE-YAOGUANG] 离线补发耀光 E 技能的原版飞刃：沿准星飞行，命中后走统一击杀链。
    private class YaoguangDartProjectile
    {
        public Vector3 Start;
        public Vector3 End;
        public float StartAt;
        public float TravelTime;
        public int TargetId;
        public bool Headshot;
        public float Damage;
        public GameObject Visual;
    }

    private readonly List<FlyKnifeProjectile> _flyKnives = new List<FlyKnifeProjectile>();
    private readonly List<YaoguangDartProjectile> _yaoguangDarts = new List<YaoguangDartProjectile>();
    private float _nextYaoguangDartAt;
    // [OFFLINE-PATCH] 离线丢枪/捡枪：世界模型 + 背包槽位增删。
    private class DroppedWeapon
    {
        public string Name;
        public int SlotKind; // 1=主 2=副 3=近战 4=投掷
        public GameObject Obj;
        public Vector3 Vel;
        public float FloorY;
        public bool Landed;
    }

    private readonly List<DroppedWeapon> _dropped = new List<DroppedWeapon>();
    private float _nextPickLog;
    private float _nextEquipCheck;
    private float _lastShootDiag;
    private int _lastShotWeaponId = -1;
    private int _lastShotsFired;
    private bool _prevMeleeAttack;
    private float _suppressNativeMeleeUntil;
    private bool _lastMeleeHeavy;
    private static float s_fireDiag;
    private static float s_aimDiag;
    private string _dumpWeapon;
    public static float SuppressIdleUntil;
    public static float PendingRaiseAt;
    private float _secondaryEndAt;
    private float _nextSecondary;
    private float _lastSecondaryLog;
    private int _bayonetStage;
    private bool _bayonetActive;
    private int _bayonetPhase;
    private float _bayonetNextAt;
    private int _viewTimerState = -1;
    private bool _modeLoadoutApplied;
    private int _viewTimerRemain;
    private int _viewTimerRight;
    private float _viewStateSince;
    public static bool AttackAnimActive;
    private static float s_viewRetrigT;

    private float _nextThrow;
    private float _nextKnifeThrow;
    private float _returnToPrimaryAt;
    public static float LastTorsoActionAt;
    private static readonly Dictionary<int, float> _botAttackAnimUntil = new Dictionary<int, float>();
    private static readonly Dictionary<int, int> _botTorsoAnim = new Dictionary<int, int>();

    public static int GetBotTorsoAnimation(int botId)
    {
        float until;
        int anim;
        return _botAttackAnimUntil.TryGetValue(botId, out until) && Time.time < until
            && _botTorsoAnim.TryGetValue(botId, out anim) ? anim : 0;
    }

    private static void SetBotTorsoAnimation(int botId, int animId)
    {
        try
        {
            int renderTime = Contexts.sharedInstance.time.time.RenderTime;
            int duration = 500;
            ISnapshot snap = Contexts.sharedInstance.snapshot.snapshots.LatestSnapshot;
            PlayerEntityData data = null;
            if (snap != null && snap.PlayerEntityDataDict != null)
                snap.PlayerEntityDataDict.TryGetValue(botId, out data);
            if (data != null)
            {
                data.TorsoAnim = animId;
                data.TorsoAnimSpecified = true;
                data.TorsoAnimStartTime = renderTime;
                data.TorsoAnimStartTimeSpecified = true;
            }
            foreach (PlayerEntity entity in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))
            {
                if (entity == null || entity.entityId.Value != botId || !entity.hasBasicInfo) continue;
                if (entity.hasTorseAnim && entity.hasCurrentWeapon)
                {
                    try
                    {
                        Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetTorseAnimation(entity, animId);
                        duration = Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.GetTorseAnimDuration(entity, animId);
                    }
                    catch (System.Exception) { }
                }
                if (entity.basicInfo.Current != null)
                {
                    entity.basicInfo.Current.TorsoAnim = animId;
                    entity.basicInfo.Current.TorsoAnimStartTime = renderTime;
                    if (duration > 0) entity.basicInfo.Current.TorsoAnimationTimer = duration;
                }
                if (entity.basicInfo.Next != null)
                {
                    entity.basicInfo.Next.TorsoAnim = animId;
                    entity.basicInfo.Next.TorsoAnimStartTime = renderTime;
                    if (duration > 0) entity.basicInfo.Next.TorsoAnimationTimer = duration;
                }
                break;
            }
            if (data != null && duration > 0)
            {
                data.TorsoAnimationTimer = duration;
                data.TorsoAnimationTimerSpecified = true;
            }
            _botTorsoAnim[botId] = animId;
            _botAttackAnimUntil[botId] = Time.time + Mathf.Clamp(duration / 1000f, 0.25f, animId == 17 ? 5f : 1.2f);
        }
        catch (System.Exception) { }
    }

    // [OFFLINE-PATCH] 第三人称上半身动作：本地直接写快照字段并记录时间，SyncOfflineAnimStates 据此保留动作。
    public static void SetTorsoAction(int id)
    {
        try
        {
            PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
            if (me == null || !me.hasBasicInfo || me.basicInfo.Current == null) return;
            me.basicInfo.Current.TorsoAnim = id;
            if (me.basicInfo.Next != null) me.basicInfo.Next.TorsoAnim = id;
            me.basicInfo.Current.TorsoAnimStartTime = Contexts.sharedInstance.time.time.RenderTime;
            LastTorsoActionAt = Time.time;
        }
        catch (System.Exception) { }
    }

    private static PlayerEntityData Get(ISnapshot s, int id)
    {
        PlayerEntityData d;
        return s.PlayerEntityDataDict.TryGetValue(id, out d) ? d : null;
    }


private bool IsEnemyOfPlayer(PlayerEntityData other)
    {
        ISnapshot snap = Snap();
        if (other == null || snap == null) return false;
        PlayerEntityData self;
        if (!snap.PlayerEntityDataDict.TryGetValue(snap.Self, out self)) return false;
        int raceType = OfflineGameController.setting != null ? OfflineGameController.setting.RaceType : 3;
        return OfflineGameSetting.IsFreeForAll(raceType) || self.Team != other.Team;
    }

private void DamageBot(int targetId, float damage, int fromBot, bool headshot = false, bool ignoreArmor = false)
	{
		ISnapshot snap = Snap();
		if (snap == null) return;
		PlayerEntityData target = Get(snap, targetId);
		OfflineBotAgent brain;
		if (target == null || !_agents.TryGetValue(targetId, out brain) || !brain.Alive) return;
		// [OFFLINE-TDM] 出生保护（2 秒）内不吃任何伤害
		if (OfflineTdmMatch.IsProtected(targetId)) return;
		if (!ignoreArmor) damage = AbsorbArmor(target, damage);
		// [OFFLINE-GOD] 无敌模式一键清 bot：伤害直接灌死
		if (GodMode) damage = target.Hp + 999f;
		target.Hp -= damage;
		if (target.Hp > 0f)
		{
			PlayerEntityData attacker = Get(snap, fromBot);
			if (attacker != null) brain.OnDamaged(OfflineBotSpawner.GetUnityPos(attacker), fromBot, Time.time);
			return;
		}
		brain.Alive = false;
		// 复活间隔 5 秒（TDM/非 TDM 一致）
		brain.RespawnAt = Time.time + 5f;
		target.IsDead = true;
		target.DeadTimer = 3000;
		SetBotNativeDeathAnimation(targetId, target);
		brain.Deaths++;
		// 击杀者是队友 bot 时给击杀者记一分
		OfflineBotAgent killer;
		if (_agents.TryGetValue(fromBot, out killer)) killer.Kills++;
		// [OFFLINE-KILLCHAIN] bot 互杀也走原版 method 6 播报（击杀图标/音效/连杀）
		bool firstBlood = OfflineTdmMatch.Active
			? (OfflineTdmMatch.Team1Score + OfflineTdmMatch.Team2Score == 0)
			: (PlayerKills + BotKills == 0);
		OfflineKillChain.PushBotKill(fromBot, targetId, killer != null ? killer.Kills : 1, headshot, firstBlood);
		// 标签按真实阵营算（旧实现写死 "teammate/enemy"，敌方 bot 杀友方 bot 时显示反了）
		PlayerEntityData self0 = null;
		ISnapshot snap0 = Snap();
		if (snap0 != null) snap0.PlayerEntityDataDict.TryGetValue(snap0.Self, out self0);
		int myTeam = (self0 != null) ? self0.Team : 1;
		PlayerEntityData kd0 = Get(snap0, fromBot);
		PlayerEntityData vd0 = Get(snap0, targetId);
		string kRel = (kd0 != null && kd0.Team == myTeam) ? "teammate" : "enemy";
		string vRel = (vd0 != null && vd0.Team == myTeam) ? "teammate" : "enemy";
		Debug.Log("[OFFLINE-AI] " + kRel + " bot=" + fromBot + " downed " + vRel + "=" + targetId);
		// [OFFLINE-TDM] 只计分（播报已由 PushBotKill 发出）；ReportKill 内部会刷新计分板
		int killerTeam = (kd0 != null) ? kd0.Team : 0;
		OfflineTdmMatch.ReportKill(fromBot, killerTeam, targetId, target.Team, headshot);
		if (!OfflineTdmMatch.Active) OfflineKillChain.RebuildBoard();
	}

    /// <summary>玩家被 bot 命中。</summary>
    // [OFFLINE-PATCH] 无敌模式：默认开启（F2 切换）。离线单机不想被 bot 持续掉血骚扰。
    public static bool GodMode = true;

    public void DamagePlayer(float dmg, int fromBot, bool headshot = false, bool ignoreArmor = false)
    {
        if (GodMode) return;
        var s = Snap();
        if (s == null) return;
        PlayerEntityData me;
        if (!s.PlayerEntityDataDict.TryGetValue(s.Self, out me)) return;
        if (me == null) return;
        if (RoundOver) return;
        // [OFFLINE-TDM] 已经死亡（等待复活）时不重复结算伤害/击杀
        if (me.IsDead || OfflineTdmMatch.PlayerDead) return;
        // [OFFLINE-TDM] 出生保护（复活后 2 秒无敌）
        if (OfflineTdmMatch.IsProtected(s.Self)) return;
        // [OFFLINE-TDM] 单机公平性：bot 枪械打玩家伤害减半并封顶 40；近战保持两刀死口径。
        if (!ignoreArmor && OfflineTdmMatch.Active)
        {
            dmg *= 0.5f;
            if (dmg > 40f) dmg = 40f;
        }
        if (!ignoreArmor) dmg = AbsorbArmor(me, dmg);
        me.Hp -= dmg;
        if (me.Hp > 0f) return;

        if (OfflineTdmMatch.Active)
        {
            // [OFFLINE-TDM] 延迟复活：不立刻回血/传送，交给 OfflineTdmMatch.Tick 倒计时后调用 RespawnPlayer。
            int killerTeam = 0;
            PlayerEntityData kd = Get(s, fromBot);
            if (kd != null) killerTeam = kd.Team;
            bool firstBlood = OfflineTdmMatch.Team1Score + OfflineTdmMatch.Team2Score == 0;
            me.Hp = 0f;
            me.IsDead = true;
            me.DeadTimer = OfflineTdmMatch.RespawnDelayMs;
            PlayerDeaths++;
            if (fromBot >= 0) BotKills++;
            OfflineBotAgent killerBot;
            if (_agents.TryGetValue(fromBot, out killerBot)) killerBot.Kills++;
            Debug.Log("[OFFLINE-KILL] bot " + fromBot + " killed player (tdm). deaths=" + PlayerDeaths
                + " team=" + killerTeam);
            if (fromBot >= 0)
            {
				OfflineKillChain.PushBotKill(fromBot, s.Self,
					killerBot != null ? killerBot.Kills : 1, headshot, firstBlood);
                OfflineTdmMatch.ReportKill(fromBot, killerTeam, s.Self, me.Team, headshot);
			}
            OfflineTdmMatch.OnPlayerDeath(fromBot, killerTeam);
            return;
        }

        // 非 TDM：保持原有立即复活
        bool nonTdmFirstBlood = PlayerKills + BotKills == 0;
        me.Hp = me.MaxHp > 0f ? me.MaxHp : 100f;
        PlayerDeaths++;
        BotKills++;
		OfflineBotAgent nonTdmKiller = null;
        if (fromBot >= 0 && _agents.TryGetValue(fromBot, out nonTdmKiller))
            nonTdmKiller.Kills++;
        if (fromBot >= 0)
        {
			OfflineKillChain.PushBotKill(fromBot, s.Self,
				nonTdmKiller != null ? nonTdmKiller.Kills : 1, headshot, nonTdmFirstBlood);
			OfflineKillChain.RebuildBoard();
		}
        Debug.Log("[OFFLINE-KILL] bot " + fromBot + " killed player. deaths=" + PlayerDeaths);
        RespawnPlayer();
    }

    /// <summary>玩家击杀一个 bot（准星命中由控制器调用）。</summary>
    private int _weaponMasterLevel;
    private void AwardWeaponMaster()
    {
        try
        {
            if (OfflineGameController.setting == null || OfflineGameController.setting.RaceType != 64) return;
            _weaponMasterLevel++;
            // _weaponMasterLevel 已在本次击杀后递增；首杀必须切到槽 1，之后按 1→2→3 循环。
            int slot = 1 + ((_weaponMasterLevel - 1) % 3);
            OfflineGameController ctrl = UnityEngine.Object.FindObjectOfType<OfflineGameController>();
            if (ctrl != null) ctrl.TrySwitchWeapon(slot);
            UnityEngine.Debug.Log("[OFFLINE-MODE] weaponmaster kill=" + _weaponMasterLevel + " -> slot " + slot);
        }
        catch (System.Exception) { }
    }

    public bool KillBot(int botId, float dmg, bool headshot = false, bool ignoreArmor = false)
    {
        var s = Snap();
        if (s == null) return false;
        PlayerEntityData d;
        if (!s.PlayerEntityDataDict.TryGetValue(botId, out d)) return false;
        OfflineBotAgent b;
        if (!_agents.TryGetValue(botId, out b) || !b.Alive) return false;
        // [OFFLINE-TDM] 出生保护内不结算击杀
        if (OfflineTdmMatch.IsProtected(botId)) return false;
        bool firstBlood = OfflineTdmMatch.Active
			? (OfflineTdmMatch.Team1Score + OfflineTdmMatch.Team2Score == 0)
			: (PlayerKills + BotKills == 0);
        d.Hp -= ignoreArmor ? dmg : AbsorbArmor(d, dmg);
        if (d.Hp > 0f)
        {
            PlayerEntityData attacker = Get(s, s.Self);
            if (attacker != null) b.OnDamaged(OfflineBotSpawner.GetUnityPos(attacker), s.Self, Time.time);
            return false;
        }
        b.Alive = false;
        // [OFFLINE-FIX] 原来只把 brain 标死，没设 data.IsDead：渲染层看不到死亡状态，
        // 5 秒后又原地满血复活，观感就是"打不死"。
        d.IsDead = true;
        d.Hp = 0f;
        // [OFFLINE-KILLCHAIN] SmoothDeadTimerSystem 需要 basicInfo.Current.DeadTimer 作为推进目标，
        // 之前一直是 0，死亡平滑计时器没有终点，尸体表现会卡住/直接消失。给 3 秒。
        d.DeadTimer = 3000;
        SetBotNativeDeathAnimation(botId, d);
        // [OFFLINE-TDM] 团队模式统一 5 秒复活；非 TDM 保持 8 秒
        b.RespawnAt = Time.time + (OfflineTdmMatch.Active ? 5f : 8f);
        PlayerKills++;
        AwardWeaponMaster();
        BotDeaths++;
        Debug.Log("[OFFLINE-KILL] player killed bot " + botId + " kills=" + PlayerKills);
        b.Deaths++;
        // [OFFLINE-KILLCHAIN] 走原版 method 6 + method 8：
        // 击杀播报队列 / ForceInvoke(22) / PlayKillSound / 连杀语音 / Tab 计分板全部由原版 handler 处理。
        PlayerEntityData selfK = Get(s, s.Self);
        string killWeapon = "";
        try
        {
            WeaponEntity currentWeapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
            if (currentWeapon != null && currentWeapon.hasBasicInfo && currentWeapon.basicInfo.Data != null)
                killWeapon = currentWeapon.basicInfo.Data.WeaponName;
        }
        catch (System.Exception) { }
        if (string.IsNullOrEmpty(killWeapon) && selfK != null) killWeapon = selfK.CurrentWeaponName;
        OfflineKillChain.PushPlayerKill(botId, d.Team, PlayerKills, headshot, firstBlood, killWeapon);
        // [OFFLINE-TDM] 只计分（播报已由 PushPlayerKill 发出）
        int selfTeam = 0;
        if (selfK != null) selfTeam = selfK.Team;
        OfflineTdmMatch.ReportKill(s.Self, selfTeam, botId, d.Team, headshot);
        return true;
    }

    /// <summary>
    /// [OFFLINE-KILLCHAIN] 把全部 bot 的战绩行交给计分板。
    /// 名字取 OfflineBotSpawner.GetBotName（五字诗句），和头顶名牌保持一致。
    /// </summary>
    public void AppendBotScoreRows(List<OneKillInfoData> list)
    {
        if (list == null) return;
        var s = Snap();
        if (s == null) return;
        foreach (var kv in _agents)
        {
            var d = Get(s, kv.Key);
            if (d == null) continue;
            list.Add(OfflineKillChain.MakeRow(
                kv.Key, d.Team, OfflineBotSpawner.GetBotName(kv.Key),
                kv.Value.Kills, kv.Value.Deaths, ""));
        }
    }

    /// <summary>
    /// [OFFLINE-TDM] 玩家复活（TDM Tick 倒计时结束后、ResetForMatch 都会调用）。
    /// 只负责把玩家放回出生点并清死亡状态，OnPlayerRespawn 由 OfflineTdmMatch.Tick 调用，避免递归。
    /// </summary>
    public void RespawnPlayer()
    {
        var s = Snap();
        if (s == null) return;
        PlayerEntityData me;
        if (!s.PlayerEntityDataDict.TryGetValue(s.Self, out me) || me == null) return;

        float maxHp = me.MaxHp > 0f ? me.MaxHp : 100f;
        me.Hp = maxHp;
        me.IsDead = false;
        me.DeadTimer = 0;

        float sx = 4251.96f, sy = 1234.44f, sz = 1767.84f, yaw = 180f;
        bool picked = false;
        if (OfflineTdmMatch.Active)
        {
            // [OFFLINE-TDM] 团队模式优先阵营出生点（Unity 米制，需用 SetUnityPos 写回快照）
            try
            {
                Vector3? teamSpawn = OfflineBotSpawner.PickTeamSpawn(s, 1, true, 0);
                if (teamSpawn.HasValue)
                {
                    OfflineBotSpawner.SetUnityPos(me, teamSpawn.Value.x, teamSpawn.Value.y, teamSpawn.Value.z);
                    sx = me.X;
                    sy = me.Y;
                    sz = me.Z;
                    yaw = OfflineBotSpawner.LastSpawnYaw;
                    picked = true;
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogWarning("[OFFLINE-TDM] team spawn failed: " + ex.Message);
            }
        }
        if (!picked)
        {
            try
            {
                int sceneId = (OfflineGameController.setting != null) ? OfflineGameController.setting.SceneId : 1;
                float[] spawn = OfflineMapSpawns.FirstSpawn(sceneId, true);
                if (spawn != null)
                {
                    // BSP 返回 {X, 水平Z, 高度Y, 阵营, yaw}，直接写入快照/物理体坐标。
                    sx = spawn[0];
                    sy = spawn[1];
                    sz = spawn[2];
                    if (spawn.Length > 4) yaw = spawn[4];
                    // [OFFLINE-SPAWN] 复活兜底也必须探地，不能把 BSP origin 直接当落点。
                    Vector3 cand = new Vector3(0f - sy * 0.01f, sz * 0.01f, sx * 0.01f);
                    Vector3 grounded;
                    if (OfflineBotSpawner.TryGroundSnap(cand, out grounded))
                    {
                        sx = grounded.z * 100f;
                        sy = (0f - grounded.x) * 100f;
                        sz = grounded.y * 100f;
                    }
                }
            }
            catch (System.Exception) { }
            me.X = sx;
            me.Y = sy;
            me.Z = sz;
        }

        var pm = Contexts.sharedInstance.player.myPlayerEntity;
        if (pm != null && pm.hasMove && pm.move != null && pm.move.PyPlayerMove != null)
        {
            pm.move.PyPlayerMove.SetPosition(sx, sy, sz);
        }
        me.ViewYaw = yaw;
        me.MoveYaw = yaw;
        // 复活保护（OnPlayerRespawn 也会调用，重复无副作用）
        OfflineTdmMatch.MarkSpawnProtected(me.Id > 0 ? me.Id : s.Self);
        Debug.Log("[OFFLINE-SPAWN] respawn player tdm=" + OfflineTdmMatch.Active);
    }

    /// <summary>
    /// [OFFLINE-TDM] 比赛重开：清空本局计数/投射物，重置全部 bot 与玩家到出生点。
    /// 由 OfflineTdmMatch.RestartMatch 调用（不要动玩家背包/武器配置）。
    /// </summary>
    public void ResetForMatch()
    {
        try
        {
            PlayerKills = 0;
            PlayerDeaths = 0;
            BotKills = 0;
            BotDeaths = 0;
            RoundOver = false;
            RoundResult = "";
            _roundTimer = RoundSeconds;

            // 清投射物与地面掉落（只销毁视觉，不动玩家背包）
            for (int i = 0; i < _botGrenades.Count; i++)
                if (_botGrenades[i] != null && _botGrenades[i].Visual != null)
                    UnityEngine.Object.Destroy(_botGrenades[i].Visual);
            _botGrenades.Clear();
            for (int i = 0; i < _grenades.Count; i++)
                if (_grenades[i] != null && _grenades[i].Visual != null)
                    UnityEngine.Object.Destroy(_grenades[i].Visual);
            _grenades.Clear();
            for (int i = 0; i < _flyKnives.Count; i++)
                if (_flyKnives[i] != null && _flyKnives[i].Visual != null)
                    UnityEngine.Object.Destroy(_flyKnives[i].Visual);
            _flyKnives.Clear();
            for (int i = 0; i < _dropped.Count; i++)
                if (_dropped[i] != null && _dropped[i].Obj != null)
                    UnityEngine.Object.Destroy(_dropped[i].Obj);
            _dropped.Clear();

            var s = Snap();
            PlayerEntityData me = null;
            if (s != null && s.PlayerEntityDataDict != null) s.PlayerEntityDataDict.TryGetValue(s.Self, out me);
            Vector3 playerPos = (me != null) ? OfflineBotSpawner.GetUnityPos(me) : Vector3.zero;

            foreach (var kv in _agents)
            {
                OfflineBotAgent b = kv.Value;
                if (b == null) continue;
                PlayerEntityData data = (s != null && s.PlayerEntityDataDict != null) ? Get(s, kv.Key) : null;
                if (data == null) continue;

                // [OFFLINE-TRAINING] F6 可以在同一组已创建的人形实体间重新分配阵营。
                b.Team = data.Team;

                float maxHp = data.MaxHp > 0f ? data.MaxHp : 100f;
                b.Kills = 0;
                b.Deaths = 0;
                b.Alive = true;
                b.Hp = maxHp;
                ResetBotMotion(b.Id);
                data.Hp = maxHp;
                data.IsDead = false;
                data.DeadTimer = 0;

                Vector3 sp = b.SpawnPos;
                if (OfflineTdmMatch.Active)
                {
                    // [OFFLINE-TDM] 按阵营选安全复活点，失败回退记录出生点
                    Vector3? tdmSpawn = OfflineBotSpawner.PickBotRespawn(
                        s, b.Id, data.Team, data.Team == 1, playerPos, b.Id);
                    if (tdmSpawn.HasValue) sp = tdmSpawn.Value;
                }
                OfflineBotSpawner.SetUnityPos(data, sp.x, sp.y, sp.z);
                b.ResetForRespawn(sp, Time.time, maxHp);
                _botAttackAnimUntil.Remove(b.Id);
                _botTorsoAnim.Remove(b.Id);
                SyncBotSpawnToEntity(b.Id, data);
                b.NeedsNearPlacement = false;
                if (OfflineTdmMatch.Active) OfflineTdmMatch.MarkSpawnProtected(b.Id);
            }

            if (me != null)
            {
                me.Hp = me.MaxHp > 0f ? me.MaxHp : 100f;
                me.IsDead = false;
                me.DeadTimer = 0;
            }
            RespawnPlayer();
            OfflineKillChain.RebuildBoard();
            Debug.Log("[OFFLINE-TDM] reset for match bots=" + _agents.Count + " tdm=" + OfflineTdmMatch.Active);
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-TDM] ResetForMatch failed: " + ex);
        }
    }

    /// <summary>找最近的可击杀 bot（给射线命中用）。</summary>
    public int NearestBotInRange(Vector3 from, Vector3 fwd, float maxDist)
    {
        bool ignored;
        return NearestBotInRange(from, fwd, maxDist, out ignored);
    }

    public int NearestBotInRange(Vector3 from, Vector3 fwd, float maxDist, out bool headshot)
    {
        headshot = false;
        var s = Snap();
        if (s == null) return -1;
        int best = -1;
        float bestT = maxDist;
        bool bestHeadshot = false;
        const float BotBodyRadius = 34f; // raw centimeters; approximate original player capsule width
        const float BotHeadRadius = 18f; // only a head-sized sphere can produce a headshot

        // [OFFLINE-KILLCHAIN] 友军火力关闭：原版团队模式下打不到队友。
        PlayerEntityData selfForTeam;
        bool hasSelfTeam = s.PlayerEntityDataDict.TryGetValue(s.Self, out selfForTeam) && selfForTeam != null;
        bool ffa = OfflineGameSetting.IsFreeForAll(
            OfflineGameController.setting != null ? OfflineGameController.setting.RaceType : 3);

        foreach (var kv in _agents)
        {
            if (!kv.Value.Alive) continue;
            var d = Get(s, kv.Key);
            if (d == null) continue;
            if (hasSelfTeam && !ffa && d.Team == selfForTeam.Team) continue;

            Vector3 botPos = OfflineBotSpawner.GetUnityPos(d);
            float viewHeight = d.ViewHeight > 10f ? d.ViewHeight : EyeHeight;
            Vector3 baseRaw = botPos * 100f;
            // Eye 相机通常以米制传入，BSP 与 bot 快照位置使用厘米制。
            Vector3 fromRaw = from;
            if (fromRaw.magnitude < 500f) fromRaw = fromRaw * 100f;

            // 沿射线水平投影到 bot 身体轴线，再测量实际射线点到人体胶囊的距离。
            // 旧版以眼位为中心并容许至少 90cm 偏差，胸口附近也会进入 45cm 爆头带。
            Vector3 flatForward = new Vector3(fwd.x, 0f, fwd.z);
            float flatLengthSq = flatForward.sqrMagnitude;
            float t;
            if (flatLengthSq > 0.0001f)
            {
                Vector3 flatToBot = new Vector3(baseRaw.x - fromRaw.x, 0f, baseRaw.z - fromRaw.z);
                t = Vector3.Dot(flatToBot, flatForward) / flatLengthSq;
            }
            else
            {
                Vector3 centerRaw = baseRaw + Vector3.up * (viewHeight * 0.5f);
                t = Vector3.Dot(centerRaw - fromRaw, fwd);
            }
            if (t <= 0f || t > bestT) continue;

            Vector3 hitPoint = fromRaw + fwd * t;
            float bodyHeight = viewHeight + 25f;
            float spineBottom = BotBodyRadius;
            float spineTop = Mathf.Max(spineBottom, bodyHeight - BotBodyRadius);
            float closestY = baseRaw.y + Mathf.Clamp(hitPoint.y - baseRaw.y, spineBottom, spineTop);
            float dx = hitPoint.x - baseRaw.x;
            float dy = hitPoint.y - closestY;
            float dz = hitPoint.z - baseRaw.z;
            float bodyDistanceSq = dx * dx + dy * dy + dz * dz;
            if (bodyDistanceSq > BotBodyRadius * BotBodyRadius) continue;

            bool seen = OfflineBotPhysics.CanSee(fromRaw, hitPoint);
            // [OFFLINE-FIRE-DIAG] 记录射线命中人体胶囊的数据，便于核对爆头区域。
            if (UnityEngine.Time.realtimeSinceStartup - s_aimDiag > 1.0f)
            {
                s_aimDiag = UnityEngine.Time.realtimeSinceStartup;
                UnityEngine.Debug.Log("[OFFLINE-AIM] bot=" + kv.Key
                    + " t=" + t.ToString("F1") + " bodyDist=" + Mathf.Sqrt(bodyDistanceSq).ToString("F1")
                    + " bodyRadius=" + BotBodyRadius.ToString("F0") + " seen=" + seen
                    + " hitY=" + hitPoint.y.ToString("F1") + " botBaseY=" + baseRaw.y.ToString("F1")
                    + " botPos=" + botPos.ToString("F1") + " from=" + from.ToString("F1"));
            }
            if (!seen) continue;

            best = kv.Key;
            bestT = t;
            float headDx = hitPoint.x - baseRaw.x;
            float headDy = hitPoint.y - (baseRaw.y + viewHeight);
            float headDz = hitPoint.z - baseRaw.z;
            bestHeadshot = headDx * headDx + headDy * headDy + headDz * headDz <= BotHeadRadius * BotHeadRadius;
        }
        headshot = best >= 0 && bestHeadshot;
        return best;
    }

    // ---- 离线手雷投掷 ----
    private void ThrowGrenade()
    {
        // [OFFLINE-PATCH] Main Camera 的 transform 在 (0,0,0) 附近，投掷必须用玩家眼位的 Eye 相机。
        Camera cam = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") { cam = cams[i]; break; }
        }
        if (cam == null) cam = Camera.main;
        if (cam == null) return;

        GrenadeBall g = new GrenadeBall();
        // [OFFLINE-GRENADE] 按武器名分类：原版按爆炸 EventId 区分（8=闪光），客户端名字里带 flash/smoke。
        string gwn = "";
        try
        {
            WeaponEntity cwG = Contexts.sharedInstance.weapon.currentWeaponEntity;
            if (cwG != null && cwG.hasBasicInfo && cwG.basicInfo.Data != null)
                gwn = cwG.basicInfo.Data.WeaponName ?? "";
        }
        catch (System.Exception) { }
        g.Kind = gwn.IndexOf("flash", System.StringComparison.OrdinalIgnoreCase) >= 0 ? 1
               : (gwn.IndexOf("smoke", System.StringComparison.OrdinalIgnoreCase) >= 0 ? 2 : 0);
        // [OFFLINE-PGRENADE] 注意：SSJJ 的 Eye 相机 transform 位于 **厘米** 空间
        // （实测 thrown from (-1041,1887,4630)），这里沿用厘米：40cm 出手 / 1800cm/s。
        g.Pos = cam.transform.position + cam.transform.forward * 40f - cam.transform.up * 8f;
        g.Vel = cam.transform.forward * 1800f + cam.transform.up * 320f;
        g.FuseAt = Time.time + (g.Kind == 0 ? 2.2f : (g.Kind == 1 ? 1.8f : 1.5f));
        GameObject ball = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        ball.name = "OfflineGrenade";
        Collider col = ball.GetComponent<Collider>();
        if (col != null) UnityEngine.Object.Destroy(col);
        ball.transform.localScale = Vector3.one * 12f;   // [OFFLINE-PGRENADE] 厘米空间：12cm 球
        Renderer br = ball.GetComponent<Renderer>();
        if (br != null) br.material.color = g.Kind == 1
            ? new Color(0.95f, 0.95f, 0.75f)
            : (g.Kind == 2 ? new Color(0.62f, 0.62f, 0.66f) : new Color(0.15f, 0.45f, 0.2f));
        g.Visual = ball;
        _grenades.Add(g);
        // [OFFLINE-PGRENADE] 补原版投掷动作：GrenadePredicationSystem 在攻击预测时
        // PlayerAnimationUtility.SetViewAnimation(player, 28)。我们绕过 UserCmd，手动补播。
        try
        {
            PlayerEntity meT = Contexts.sharedInstance.player.myPlayerEntity;
            // [OFFLINE-GRENADE] 28 是空手待机姿，会把投掷动作盖掉；原版出手动作是 23。
            if (meT != null) Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(meT, 23);
        }
        catch (System.Exception) { }

        // [OFFLINE-GRENADE] 原版 AttackInterval = 1500ms，不是 1s。
        _nextThrow = Time.time + 1.5f;
        _returnToPrimaryAt = Time.time + 0.7f;
        Debug.Log("[OFFLINE-GRENADE] thrown from " + g.Pos.ToString("F0") + " vel=" + g.Vel.ToString("F0"));
    }

    private void ThrowFlyKnife()
    {
        if (Time.time < _nextKnifeThrow) return;
        Camera cam = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") { cam = cams[i]; break; }
        }
        if (cam == null) cam = Camera.main;
        if (cam == null) return;

        Vector3 dir = cam.transform.forward.normalized;
        FlyKnifeProjectile knife = new FlyKnifeProjectile();
        knife.Pos = cam.transform.position + dir * 55f;
        knife.Vel = dir * 2600f;
        knife.EndAt = Time.time + 2.0f;
        GameObject visual = GameObject.CreatePrimitive(PrimitiveType.Cube);
        visual.name = "OfflineFlyKnife";
        Collider col = visual.GetComponent<Collider>();
        if (col != null) UnityEngine.Object.Destroy(col);
        visual.transform.localScale = new Vector3(10f, 10f, 90f);
        visual.transform.position = knife.Pos;
        visual.transform.rotation = Quaternion.LookRotation(dir, Vector3.up);
        Renderer renderer = visual.GetComponent<Renderer>();
        if (renderer != null) renderer.material.color = new Color(0.72f, 0.78f, 0.86f, 1f);
        knife.Visual = visual;
        _flyKnives.Add(knife);
        _nextKnifeThrow = Time.time + 0.42f;
        _lastFireAt = Time.time;
        Debug.Log("[OFFLINE-FLYKNIFE] thrown pos=" + knife.Pos.ToString("F0") + " vel=" + knife.Vel.ToString("F0"));
    }

    /// <summary>
    /// 耀光没有 WeaponSkill 表记录：原版 E 直接发射可爆头飞刃。
    /// 返回 true 表示此 E 已属于耀光，即使冷却中也不能退化成拾取。
    /// </summary>
    private bool TryUseYaoguangDart()
    {
        WeaponEntity weapon = null;
        try { weapon = Contexts.sharedInstance.weapon.currentWeaponEntity; } catch (System.Exception) { }
        if (weapon == null || !weapon.hasBasicInfo || weapon.basicInfo.Data == null
            || !string.Equals(weapon.basicInfo.Data.WeaponName, "brave_dagger", System.StringComparison.OrdinalIgnoreCase))
            return false;

        PlayerEntity player = null;
        try { player = Contexts.sharedInstance.player.myPlayerEntity; } catch (System.Exception) { }
        if (player == null) return true;

        int raceType = OfflineGameController.setting != null ? OfflineGameController.setting.RaceType : 3;
        int cooldownMs = 10000; // brave_dagger 的 Weapon.json CdTimePara
        try
        {
            var info = weapon.basicInfo.Info as Assets.Sources.Info.Weapon.WeaponInfo.DefaultWeaponInfo;
            if (info != null && info.CdTimeLogic != null)
            {
                int configured = info.CdTimeLogic.GetCdTime("brave_dagger", raceType, 0);
                if (configured > 0) cooldownMs = configured;
            }
        }
        catch (System.Exception) { }

        long clientNow = 0;
        try { if (player.hasClientTime) clientNow = player.clientTime.ClientTime; } catch (System.Exception) { }
        long nextSkill = 0;
        try { nextSkill = weapon.basicInfo.Data.NextSkillTimer; } catch (System.Exception) { }
        if (Time.time < _nextYaoguangDartAt || (clientNow > 0 && nextSkill > clientNow))
        {
            Debug.Log("[OFFLINE-YAOGUANG] dart blocked by cooldown remaining="
                + Mathf.Max(0f, _nextYaoguangDartAt - Time.time).ToString("F1") + "s");
            return true;
        }

        Camera cam = null;
        Camera[] cameras = Camera.allCameras;
        for (int i = 0; i < cameras.Length; i++)
        {
            if (cameras[i] != null && cameras[i].name == "Eye" && cameras[i].enabled)
            {
                cam = cameras[i];
                break;
            }
        }
        if (cam == null) cam = Camera.main;
        if (cam == null)
        {
            Debug.LogWarning("[OFFLINE-YAOGUANG] cannot fire dart: Eye camera unavailable");
            return true;
        }

        _nextYaoguangDartAt = Time.time + cooldownMs / 1000f;
        try { weapon.basicInfo.Data.NextSkillTimer = (uint)(clientNow + cooldownMs); } catch (System.Exception) { }

        // 优先用耀光自己的技能动画；动作表没有该项时退到它的普通刀刃出手动画。
        try
        {
            int skillAnim = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindViewAnimByName(
                weapon.basicInfo.Info, "TORSO_SKILL");
            if (skillAnim <= 0)
                skillAnim = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindAttackViewAnim(
                    weapon.basicInfo.Info, true);
            if (skillAnim > 0) PlayAttackViewAnim(weapon, skillAnim);
            SetTorsoAction(28);
        }
        catch (System.Exception) { }

        Vector3 direction = cam.transform.forward.normalized;
        Vector3 origin = cam.transform.position + direction * 70f;
        const float skillRange = 20000f; // 200 m; camera and BSP coordinates are in centimetres
        float worldRange = skillRange;
        try
        {
            Vector3 worldEnd, worldNormal;
            float fraction;
            if (OfflineBotPhysics.Cast(origin, origin + direction * skillRange, 1.5f, 0f,
                out worldEnd, out worldNormal, out fraction) && fraction < 0.999f)
                worldRange = Mathf.Clamp((worldEnd - origin).magnitude - 6f, 0f, skillRange);
        }
        catch (System.Exception) { }

        bool headshot;
        int targetId = NearestBotInRange(origin, direction, worldRange, out headshot);
        float travelDistance = worldRange;
        if (targetId >= 0)
        {
            ISnapshot snapshot = Snap();
            PlayerEntityData target = snapshot != null ? Get(snapshot, targetId) : null;
            if (target != null)
            {
                float viewHeight = target.ViewHeight > 10f ? target.ViewHeight : EyeHeight;
                Vector3 targetRaw = (OfflineBotSpawner.GetUnityPos(target) + Vector3.up * (viewHeight / 100f)) * 100f;
                float projectedDistance = Vector3.Dot(targetRaw - origin, direction);
                if (projectedDistance > 0f) travelDistance = Mathf.Min(worldRange, projectedDistance);
            }
        }

        YaoguangDartProjectile dart = new YaoguangDartProjectile();
        dart.Start = origin;
        dart.End = origin + direction * travelDistance;
        dart.StartAt = Time.time;
        dart.TravelTime = Mathf.Max(0.035f, travelDistance / 12000f);
        dart.TargetId = targetId;
        dart.Headshot = headshot;
        dart.Damage = headshot ? 260f : 65f;
        dart.Visual = CreateYaoguangDartVisual(origin, direction);
        _yaoguangDarts.Add(dart);
        NotifyBotsHeardNoise();
        Debug.Log("[OFFLINE-YAOGUANG] dart fired target=" + targetId + " headshot=" + headshot
            + " damage=" + dart.Damage.ToString("F0") + " range=" + travelDistance.ToString("F0")
            + " cooldownMs=" + cooldownMs);
        return true;
    }

    private static GameObject CreateYaoguangDartVisual(Vector3 position, Vector3 direction)
    {
        GameObject visual = GameObject.CreatePrimitive(PrimitiveType.Capsule);
        visual.name = "OfflineYaoguangDart";
        Collider collider = visual.GetComponent<Collider>();
        if (collider != null) UnityEngine.Object.Destroy(collider);
        visual.transform.position = position;
        visual.transform.rotation = Quaternion.FromToRotation(Vector3.up, direction);
        visual.transform.localScale = new Vector3(2.5f, 6.5f, 2.5f);
        Renderer renderer = visual.GetComponent<Renderer>();
        if (renderer != null)
        {
            renderer.material.color = new Color(1f, 0.82f, 0.32f, 1f);
            try
            {
                renderer.material.EnableKeyword("_EMISSION");
                renderer.material.SetColor("_EmissionColor", new Color(1f, 0.58f, 0.12f, 1f));
            }
            catch (System.Exception) { }
            TrailRenderer trail = visual.AddComponent<TrailRenderer>();
            trail.time = 0.09f;
            trail.startWidth = 2.2f;
            trail.endWidth = 0.1f;
            trail.material = renderer.material;
            trail.startColor = new Color(1f, 0.8f, 0.28f, 0.8f);
            trail.endColor = new Color(1f, 0.42f, 0.05f, 0f);
        }
        return visual;
    }

    private void UpdateYaoguangDarts()
    {
        if (_yaoguangDarts.Count == 0) return;
        for (int i = _yaoguangDarts.Count - 1; i >= 0; i--)
        {
            YaoguangDartProjectile dart = _yaoguangDarts[i];
            float t = dart.TravelTime > 0f ? (Time.time - dart.StartAt) / dart.TravelTime : 1f;
            t = Mathf.Clamp01(t);
            if (dart.Visual != null)
            {
                dart.Visual.transform.position = Vector3.Lerp(dart.Start, dart.End, t);
                Vector3 direction = dart.End - dart.Start;
                if (direction.sqrMagnitude > 0.001f)
                    dart.Visual.transform.rotation = Quaternion.FromToRotation(Vector3.up, direction.normalized);
            }
            if (t < 1f) continue;

            if (dart.TargetId >= 0)
            {
                bool killed = KillBot(dart.TargetId, dart.Damage, dart.Headshot);
                Debug.Log("[OFFLINE-YAOGUANG] impact target=" + dart.TargetId
                    + " headshot=" + dart.Headshot + " killed=" + killed);
            }
            if (dart.Visual != null) UnityEngine.Object.Destroy(dart.Visual);
            _yaoguangDarts.RemoveAt(i);
        }
    }

    private void UpdateFlyKnifeProjectiles()
    {
        if (_flyKnives.Count == 0) return;
        ISnapshot snap = Snap();
        float dt = Time.deltaTime;
        for (int i = _flyKnives.Count - 1; i >= 0; i--)
        {
            FlyKnifeProjectile knife = _flyKnives[i];
            Vector3 previous = knife.Pos;
            knife.Pos += knife.Vel * dt;
            if (knife.Visual != null)
            {
                knife.Visual.transform.position = knife.Pos;
                knife.Visual.transform.rotation = Quaternion.LookRotation(knife.Vel.normalized, Vector3.up);
            }

            bool hit = false;
            if (snap != null && snap.PlayerEntityDataDict != null)
            {
                foreach (var kv in _agents)
                {
                    if (!kv.Value.Alive) continue;
                    PlayerEntityData data = Get(snap, kv.Key);
                    if (data == null) continue;
                    if (!IsEnemyOfPlayer(data)) continue;
                    Vector3 target = OfflineBotSpawner.GetUnityPos(data) + Vector3.up * (EyeHeight / 100f);
                    if (DistanceToSegment(target, previous, knife.Pos) <= 120f)
                    {
                        hit = true;
                        KillBot(kv.Key, 100f);
                        Debug.Log("[OFFLINE-FLYKNIFE] hit bot=" + kv.Key);
                        break;
                    }
                }
            }

            if (hit || Time.time >= knife.EndAt)
            {
                if (knife.Visual != null) UnityEngine.Object.Destroy(knife.Visual);
                _flyKnives.RemoveAt(i);
            }
        }
    }

    private static float DistanceToSegment(Vector3 point, Vector3 start, Vector3 end)
    {
        Vector3 delta = end - start;
        float lenSq = delta.sqrMagnitude;
        if (lenSq <= 0.0001f) return Vector3.Distance(point, start);
        float t = Mathf.Clamp01(Vector3.Dot(point - start, delta) / lenSq);
        return Vector3.Distance(point, start + delta * t);
    }

    private void UpdateGrenades()
    {
        if (_grenades.Count == 0) return;
        float dt = Time.deltaTime;
        var snap = Snap();
        for (int i = _grenades.Count - 1; i >= 0; i--)
        {
            GrenadeBall g = _grenades[i];
            bool explode = Time.time >= g.FuseAt;
            if (!explode)
            {
                g.Vel.y -= 980f * dt;   // [OFFLINE-PGRENADE] 厘米空间重力 980 cm/s^2
                Vector3 next = g.Pos + g.Vel * dt;
                // [OFFLINE-GRENADE] BSP 反弹：原来直接穿墙。用世界 brush 做一次扫掠，碰墙按法线反弹。
                Vector3 hitEnd, hitNrm;
                float hitFrac;
                // [OFFLINE-GRENADE] Cast 吃的是世界厘米坐标（bot 走路也是直接传 cm，
                // 例如 probe - up*600f）。这里原来 *100 会把扫掠扔到 100 倍远处，
                // 手雷检测不到地面，直接穿地板掉到 y=-200。改为原样传。
                if (OfflineBotPhysics.Cast(g.Pos, next, 4f, 8f, out hitEnd, out hitNrm, out hitFrac)
                    && hitFrac < 0.999f)
                {
                    g.Pos = hitEnd;
                    g.Vel = Vector3.Reflect(g.Vel, hitNrm) * 0.45f;
                }
                else
                {
                    g.Pos = next;
                }
                if (g.Visual != null) g.Visual.transform.position = g.Pos;
            }
            if (!explode) continue;
            _grenades.RemoveAt(i);
            if (g.Visual != null) UnityEngine.Object.Destroy(g.Visual);

            // [OFFLINE-PGRENADE] 走原版快照链路（与 bot 同一条）：
            // GrenadeExplosionEntityCreateSystem -> SceneObjectFactory.CreateExplosion
            //  -> Explosion 表 eventId (4=破片 / 8=闪光) -> effectprefab/explosion
            if (g.Kind == 2)
            {
                OfflineGrenadeFx.Smoke(g.Pos);   // 烟雾仍走自建（原版是 SceneBuff 下发）
                Debug.Log("[OFFLINE-GRENADE] smoke at " + g.Pos.ToString("F0"));
                continue;
            }
            // g.Pos 是相机厘米空间 -> 除 100 转米，EmitGrenadeExplosionEvent 只收米
            EmitGrenadeExplosionEvent(g.Pos / 100f, Snap() != null ? Snap().Self : 0, -1,
                g.Kind == 1 ? 8 : 4, 0, g.Kind == 1 ? "flashbang" : "grenade");
            OfflineGrenadeFx.Explosion(g.Pos, g.Kind);
            // 闪光：移植原版 FlashExplosionModel 的距离/朝向/视线衰减，只做屏幕致盲，无伤害。
            if (g.Kind == 1)
            {
                OfflineGrenadeFx.TriggerFlash(g.Pos);
                Debug.Log("[OFFLINE-GRENADE] flash explode at " + g.Pos.ToString("F0"));
                continue;
            }

            int hits = 0;
            const float radius = 900f;
            if (snap != null)
            {
                foreach (var kv in _agents)
                {
                    if (!kv.Value.Alive) continue;
                    var d = Get(snap, kv.Key);
                    if (d == null) continue;
                    if (!IsEnemyOfPlayer(d)) continue;
                    Vector3 bp = OfflineBotSpawner.GetUnityPos(d);
                    float dist = Vector3.Distance(bp, g.Pos);
                    if (dist > radius) continue;
                    float dmg = 150f * (1f - dist / radius);
                    hits++;
                    KillBot(kv.Key, dmg);
                }
                // 自伤：原版手雷会炸自己；护甲/无敌在 DamagePlayer 内处理。
                PlayerEntityData meG;
                if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out meG) && meG != null && !meG.IsDead)
                {
                    float sd = Vector3.Distance(OfflineBotSpawner.GetUnityPos(meG), g.Pos);
                    if (sd <= radius) DamagePlayer(150f * (1f - sd / radius) * 0.8f, -1);
                }
            }
            Debug.Log("[OFFLINE-GRENADE] explode at " + g.Pos.ToString("F0") + " hits=" + hits);
        }
    }

    // ================= [OFFLINE-TDM] Bot 投掷物 =================

    /// <summary>[OFFLINE-CONTRACT] Step A：补齐玩家快照字段。
    /// 客户端 139 个 Playback 系统全部读这些字段，之前只填了 8~10 个，
    /// 导致护甲条/小地图 bot 标记/大头/隐身/死亡计时/动画进度/挂件全是空的。
    private void FillContractFields(PlayerEntityData d, OfflineBotAgent b, bool alive)
    {
	if (d == null) return;
	try
	{
		// --- 身份 / 阵营 ---
		d.IsBot = true;
		// BotQuality 与 HasC4 来自出生配置及对局状态，不能每帧覆盖。
		// --- 血量 / 护甲 / 护盾（护甲条、HUD 数字）---
		if (d.MaxHp <= 0f) d.MaxHp = Mathf.Max(1f, d.Hp);
		if (!d.MaxZhuangjiaSpecified) d.MaxZhuangjia = d.ArmorBody ? 100f : 0f;
		if (!d.ZhuangjiaSpecified) d.Zhuangjia = d.MaxZhuangjia;
		if (!d.HudunSpecified) d.Hudun = 0f;
		if (!d.MaxHudunSpecified) d.MaxHudun = 0f;
		// --- 死亡计时（SmoothDeadTimerSystem -> UI 复活倒计时）---
		d.DeadTimer = alive ? 0 : 3000;
		// 原版第三人称死亡动画状态；Alive 时由移动/射击动画链接管。
		if (!alive && d.TorsoAnim != 19)
		{
			d.TorsoAnim = 19;
			d.TorsoAnimSpecified = true;
			d.TorsoAnimStartTime = Contexts.sharedInstance.time.time.RenderTime;
			d.TorsoAnimStartTimeSpecified = true;
		}
		// --- 视高（原版厘米制：站姿 150f / 蹲姿 93f）---
		d.ViewHeight = (d.DuckState == 3) ? 150f : 93f;   // [OFFLINE-DUCK] 3=站立（原版 QuickMultiPlayerModel:147）
		// --- 大头模式（HeadScalePlaybackSystem）---
		// [OFFLINE-HEAD] 原版 Scale = 1 + HeadEnlarge + OtherHeadEnlarge，写 1f 等于 3 倍大头，
		// 而且 FireUtility 用同一个 Scale 做爆头判定 -> 爆头球也放大 3 倍。全部归零。
		d.HeadEnlarge = 0f;
		d.OtherHeadEnlarge = 0f;
		// --- 隐身透明度（PlayerSetStealthAlphaSystem），255 = 不透明 ---
		d.Alpha = 255;
		d.SelfAlpha = 255;
		// --- 控制者 / 身体俯仰翻滚（倒地、斜坡）---
		d.ControlEntityId = -1;
		d.MovePitch = 0f;
		d.MoveRoll = 0f;
		// --- 动画时间戳：Playback 系统按 serverTime 推进进度 ---
		int nowMs = (int)(UnityEngine.Time.realtimeSinceStartup * 1000f);
		d.LegsSpeedAnimTime = nowMs;
		// 上半身动作起点由开火、换弹和死亡事件写入，不能每帧清零。
		// --- 挂件（ViewAccessoryPlaybackSystem）---
		if (d.AccessoryList != null) d.AccessoryList.Clear();
		d.BackAccessory = "";
		// --- 血条段（LifeBarSeq：多段血条 / 护盾分段显示）---
		if (d.LifeBarSeq != null) d.LifeBarSeq.Clear();
		d.CurrentLifeBarSeq = 0;
	}
	catch (System.Exception) { }
}

    private void FillPlayerContractFields(PlayerEntityData d)
    {
	if (d == null) return;
	try
	{
		d.IsBot = false;
		d.BotQuality = 0;
		d.HasC4 = false;
		if (d.MaxHp <= 0f) d.MaxHp = 100f;
		if (d.Hp <= 0f && !d.IsDead) d.Hp = d.MaxHp;
		// 护甲条（HUD 左下角 AC 显示 100）
		d.Zhuangjia = 100f;
		d.MaxZhuangjia = 100f;
		d.Hudun = 0f;
		d.MaxHudun = 0f;
		d.DeadTimer = d.IsDead ? 3000 : 0;
		d.ViewHeight = (d.DuckState == 3) ? 150f : 93f;   // [OFFLINE-DUCK] 3=站立（原版 QuickMultiPlayerModel:147）
		// [OFFLINE-HEAD] 同上，玩家自己也不放大头。
		d.HeadEnlarge = 0f;
		d.OtherHeadEnlarge = 0f;
		// [OFFLINE-FOV] 回写挪到 SyncFirstPersonVisibility（每帧最后），
		// 这里写的是开镜动作执行前的旧值，会把开镜结果打回 90 造成抖动。
		d.Alpha = 255;
		d.SelfAlpha = 255;
		d.ControlEntityId = -1;
		d.MovePitch = 0f;
		d.MoveRoll = 0f;
		int nowMs = (int)(UnityEngine.Time.realtimeSinceStartup * 1000f);
		d.LegsSpeedAnimTime = nowMs;
		d.TorsoAnimStartTime = 0;
		if (d.AccessoryList != null) d.AccessoryList.Clear();
		d.BackAccessory = "";
		if (d.LifeBarSeq != null) d.LifeBarSeq.Clear();
		d.CurrentLifeBarSeq = 0;
	}
	catch (System.Exception) { }
}

    /// <summary>[OFFLINE-SNAPSHOT-GRENADE] 往快照写一条手雷爆炸事件。
    /// 原版 GrenadeExplosionEntityCreateSystem 每帧遍历该字典 -> SceneObjectFactory.CreateExplosion。
    /// 事件保留 3 帧后移除，避免每帧重复 ReplaceLoadUnityObjects 重播。
    private void EmitGrenadeExplosionEvent(Vector3 unityPos, int ownerId, int ownerTeam, int eventId, int resTypeId, string weaponName)
    {
	try
	{
		ISnapshot snap = Snap();
		if (snap == null || snap.GrenadeExplosionEventEntityDataDict == null) return;
		int eid = _nextExplosionEventId++;
		GrenadeExplosionEventEntityData ev = new GrenadeExplosionEventEntityData();
		BaseEventEntityData be = new BaseEventEntityData();
		be.Id = eid;
		be.EType = 5;                       // AbstractSnapshotParser case 5 = GrenadeExplosion
		// Unity 米 -> SSJJ 原生 cm：net.X = z, net.Y = -x, net.Z = y
		be.X = unityPos.z * 100f;
		be.Y = -unityPos.x * 100f;
		be.Z = unityPos.y * 100f;
		be.EventId = eventId;
		be.EventIdSpecified = true;
		be.OwnerId = ownerId;
		be.OwnerIdSpecified = true;
		be.Team = ownerTeam;
		be.TeamSpecified = true;
		be.Scale = new Vector3DData { X = 1f, Y = 1f, Z = 1f };
		ev.BaseEventEntity = be;
		ev.ResTypeID = resTypeId;
		ev.ResTypeIDSpecified = true;
		// [OFFLINE-SNAPSHOT-GRENADE] 必须填 CollisionPoint/CollisionNormal：
		// CreateExplosion 里直接 VectorTypeConverter.Net2Unity(data.CollisionPoint)，
		// 为 null 时抛 NullReferenceException，整条特效加载链中断（实测特效不出的真因）。
		ev.CollisionPoint = new Vector3DData { X = be.X, Y = be.Y, Z = be.Z };
		ev.CollisionNormal = new Vector3DData { X = 0f, Y = 0f, Z = 1f };
		ev.WeaponName = weaponName;
		// [OFFLINE-GRENADE] 原版 FlashExplosionModel 直接乘 TimeRate：缺省 0 会让
		// KeepTime=0，闪光完全不生效；HaveBulletHole 缺省则没有弹孔贴花。
		ev.TimeRate = 1f;
		ev.TimeRateSpecified = true;
		ev.Color = 0;
		ev.ColorSpecified = true;
		ev.HaveBulletHole = true;
		ev.HaveBulletHoleSpecified = true;
		snap.GrenadeExplosionEventEntityDataDict[eid] = ev;
		_liveExplosionEventIds.Add(eid);
		_explosionEventFrames.Add(_explosionFrameCounter);
		Debug.Log("[OFFLINE-SNAPSHOT-GRENADE] emit id=" + eid + " eventId=" + eventId
			+ " resType=" + resTypeId + " pos=" + unityPos.ToString("F1") + " owner=" + ownerId);
	}
	catch (System.Exception ex)
	{
		Debug.LogWarning("[OFFLINE-SNAPSHOT-GRENADE] emit failed: " + ex.Message);
	}
}

    /// <summary>[OFFLINE-SNAPSHOT-GRENADE] 每帧推进事件年龄，下一帧即从快照移除。
    /// 原版 GrenadeExplosionEntityCreateSystem 走 PlaybackInit；同一事件活多帧会
    /// 对同一个 SceneObjectEntity 反复 ReplaceLoadUnityObjects，ResourceInit 再加一次
    /// LifeTime -> EntityAlreadyHasComponentException / 缺 UnityObjects。事件必须 one-shot。
    private void CleanupExplosionEvents()
    {
	_explosionFrameCounter++;
	if (_liveExplosionEventIds.Count == 0) return;
	ISnapshot snap = Snap();
	if (snap == null || snap.GrenadeExplosionEventEntityDataDict == null) return;
	for (int i = _liveExplosionEventIds.Count - 1; i >= 0; i--)
	{
		if (_explosionFrameCounter - _explosionEventFrames[i] < 1) continue;
		int eid = _liveExplosionEventIds[i];
		try { snap.GrenadeExplosionEventEntityDataDict.Remove(eid); } catch (System.Exception) { }
		_liveExplosionEventIds.RemoveAt(i);
		_explosionEventFrames.RemoveAt(i);
	}
}

    /// <summary>[OFFLINE-TDM] Bot 投出投掷物：Unity 米制抛物线，1.4s 命中 + 0.2s 引信。</summary>
    private void ThrowBotGrenade(int ownerId, int ownerTeam, Vector3 target, int kind)
    {
        try
        {
            ISnapshot snap = Snap();
            if (snap == null) return;
            PlayerEntityData owner = Get(snap, ownerId);
            if (owner == null) return;
            Vector3 from = OfflineBotSpawner.GetUnityPos(owner) + Vector3.up * 1.4f;
            float t = 1.4f;
            Vector3 aim = new Vector3(target.x, target.y + 0.6f, target.z);
            Vector3 vel = (aim - from) / t;
            // 重力 9.8 m/s²，垂直初速按抛物线补高差（水平投掷时即 0.5*g*t）
            vel.y = (aim.y - from.y) / t + 0.5f * 9.8f * t;

            BotGrenade g = new BotGrenade();
            g.Pos = from;
            g.Vel = vel;
            g.FuseAt = Time.time + t + 0.2f;
            g.Kind = kind;
            g.OwnerId = ownerId;
            g.OwnerTeam = ownerTeam;

            GameObject ball = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            ball.name = "OfflineBotGrenade";
            Collider col = ball.GetComponent<Collider>();
            if (col != null) UnityEngine.Object.Destroy(col);
            ball.transform.position = from;
            ball.transform.localScale = Vector3.one * 0.12f;
            Renderer r = ball.GetComponent<Renderer>();
            if (r != null)
                r.material.color = kind == 1 ? new Color(0.95f, 0.9f, 0.35f)
                    : (kind == 2 ? new Color(0.62f, 0.62f, 0.66f) : new Color(0.2f, 0.6f, 0.25f));
            g.Visual = ball;
            _botGrenades.Add(g);
            Debug.Log("[OFFLINE-BOT-GRENADE] throw bot=" + ownerId + " team=" + ownerTeam
                + " kind=" + kind + " target=" + target.ToString("F1"));
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-BOT-GRENADE] throw failed: " + ex.Message);
        }
    }

    /// <summary>[OFFLINE-TDM] 每帧推进 Bot 投掷物：BSP 反弹 / 爆炸特效 / 范围伤害。</summary>
    private void UpdateBotGrenades()
    {
        if (_botGrenades.Count == 0) return;
        float dt = Time.deltaTime;
        if (dt <= 0f) return;
        for (int i = _botGrenades.Count - 1; i >= 0; i--)
        {
            BotGrenade g = _botGrenades[i];
            if (g == null)
            {
                _botGrenades.RemoveAt(i);
                continue;
            }
            try
            {
                bool explode = Time.time >= g.FuseAt;
                if (!explode)
                {
                    g.Vel.y -= 9.8f * dt;
                    Vector3 next = g.Pos + g.Vel * dt;
                    Vector3 hitEnd, hitNrm;
                    float hitFrac;
                    // 与玩家手雷同样的坐标约定：Unity 米 * 100 进 BSP
                    if (OfflineBotPhysics.Cast(g.Pos * 100f, next * 100f, 4f, 8f,
                        out hitEnd, out hitNrm, out hitFrac) && hitFrac < 0.999f)
                    {
                        g.Pos = hitEnd / 100f;
                        g.Vel = Vector3.Reflect(g.Vel, hitNrm) * 0.45f;
                    }
                    else
                    {
                        g.Pos = next;
                    }
                    if (g.Visual != null) g.Visual.transform.position = g.Pos;
                    continue;
                }

                _botGrenades.RemoveAt(i);
                if (g.Visual != null) UnityEngine.Object.Destroy(g.Visual);
                g.Visual = null;

                // [OFFLINE-SNAPSHOT-GRENADE] 不再自建特效：写快照事件，交给原版
                // GrenadeExplosionEntityCreateSystem -> SceneObjectFactory.CreateExplosion。
                // EventId: 4=破片手雷（Explosion 表 ResTypeId 0 -> grenade.prefab）；8=闪光（CreateExplosion 内专用分支）
                if (g.Kind == 2)
                {
                    // 烟雾：原版走 LocalEntityEffect/EventId 体系，暂沿用自建（无伤害）
                    OfflineGrenadeFx.Smoke(g.Pos);
                    Debug.Log("[OFFLINE-BOT-GRENADE] explode smoke at " + g.Pos.ToString("F1") + " bot=" + g.OwnerId);
                    continue;
                }
                if (g.Kind == 1)
                {
                    EmitGrenadeExplosionEvent(g.Pos, g.OwnerId, g.OwnerTeam, 8, 0, "grenade");
                    OfflineGrenadeFx.TriggerFlash(g.Pos);   // 屏幕致盲仍是客户端逻辑
                    Debug.Log("[OFFLINE-BOT-GRENADE] explode flash at " + g.Pos.ToString("F1") + " bot=" + g.OwnerId);
                    continue;
                }
                EmitGrenadeExplosionEvent(g.Pos, g.OwnerId, g.OwnerTeam, 4, 0, "grenade");

                int hits = ApplyBotGrenadeDamage(g);
                Debug.Log("[OFFLINE-BOT-GRENADE] explode frag at " + g.Pos.ToString("F1")
                    + " bot=" + g.OwnerId + " hits=" + hits);
            }
            catch (System.Exception ex)
            {
                try { if (g.Visual != null) UnityEngine.Object.Destroy(g.Visual); } catch (System.Exception) { }
                try { _botGrenades.RemoveAt(i); } catch (System.Exception) { }
                Debug.LogWarning("[OFFLINE-BOT-GRENADE] tick failed: " + ex.Message);
            }
        }
    }

    /// <summary>[OFFLINE-TDM] 破片伤害：半径 6m，中心 120 / 边缘 25 线性衰减，只伤 OwnerTeam 的敌人。</summary>
    private int ApplyBotGrenadeDamage(BotGrenade g)
    {
        int hits = 0;
        try
        {
            ISnapshot snap = Snap();
            if (snap == null || snap.PlayerEntityDataDict == null) return 0;
            const float radius = 6f;
            foreach (var kv in _agents)
            {
                if (!kv.Value.Alive) continue;
                PlayerEntityData d = Get(snap, kv.Key);
                if (d == null || d.IsDead || d.Hp <= 0f) continue;
                if (d.Team == g.OwnerTeam) continue;          // 不伤同队
                if (OfflineTdmMatch.IsProtected(kv.Key)) continue;
                float dist = Vector3.Distance(OfflineBotSpawner.GetUnityPos(d), g.Pos);
                if (dist > radius) continue;
                float dmg = Mathf.Lerp(120f, 25f, dist / radius);
                hits++;
                DamageBot(kv.Key, dmg, g.OwnerId);
            }
            PlayerEntityData me;
            if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me != null
                && !me.IsDead && me.Hp > 0f && me.Team != g.OwnerTeam
                && !OfflineTdmMatch.IsProtected(snap.Self))
            {
                float pd = Vector3.Distance(OfflineBotSpawner.GetUnityPos(me), g.Pos);
                if (pd <= radius)
                {
                    hits++;
                    DamagePlayer(Mathf.Lerp(120f, 25f, pd / radius), g.OwnerId);
                }
            }
        }
        catch (System.Exception) { }
        return hits;
    }

	private bool IsExplodeMode()
	{
		return OfflineGameController.setting != null && OfflineGameController.setting.RaceType == 2;
	}

	private static Vector3 SpawnToPhysics(float[] spawn)
	{
		return new Vector3(-spawn[1], spawn[2], spawn[0]);
	}

	private void EnsureBombSites()
	{
		if (_c4SitesReady) return;
		int sceneId = OfflineGameController.setting != null ? OfflineGameController.setting.SceneId : 1;
		float[] ct = OfflineMapSpawns.FirstSpawn(sceneId, true);
		float[] ts = OfflineMapSpawns.FirstSpawn(sceneId, false);
		if (ct != null && ts != null)
		{
			Vector3 ctPos = SpawnToPhysics(ct);
			Vector3 tPos = SpawnToPhysics(ts);
			Vector3 axis = (tPos - ctPos);
			axis.y = 0f;
			if (axis.sqrMagnitude < 1f) axis = Vector3.forward;
			axis.Normalize();
			Vector3 side = Vector3.Cross(Vector3.up, axis);
			_c4SiteA = Vector3.Lerp(ctPos, tPos, 0.45f) + side * 260f;
			_c4SiteB = Vector3.Lerp(ctPos, tPos, 0.72f) - side * 260f;
		}
		else
		{
			ISnapshot snap = Snap();
			PlayerEntityData me;
			if (snap != null && snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me))
			{
				Vector3 p = OfflineBotPhysics.Position(me);
				_c4SiteA = p + Vector3.forward * 500f;
				_c4SiteB = p - Vector3.forward * 500f;
			}
			else
			{
				_c4SiteA = Vector3.zero;
				_c4SiteB = Vector3.forward * 500f;
			}
		}
		_c4SitesReady = true;
		Debug.Log("[OFFLINE-C4] sites A=" + _c4SiteA.ToString("F0") + " B=" + _c4SiteB.ToString("F0"));
	}

	private Vector3 PlayerPhysicsPosition(PlayerEntityData me)
	{
		return OfflineBotPhysics.Position(me);
	}

	private bool NearBombSite(Vector3 position, out int siteIndex, out Vector3 site)
	{
		EnsureBombSites();
		float da = Vector3.Distance(position, _c4SiteA);
		float db = Vector3.Distance(position, _c4SiteB);
		if (da <= 300f || db <= 300f)
		{
			if (da <= db) { siteIndex = 0; site = _c4SiteA; }
			else { siteIndex = 1; site = _c4SiteB; }
			return true;
		}
		siteIndex = -1;
		site = Vector3.zero;
		return false;
	}

	private void SetC4State(bool active, int elapsed)
	{
		try
		{
			if (Contexts.sharedInstance.gameRule.hasC4State)
			{
				Contexts.sharedInstance.gameRule.c4State.Active = active;
				Contexts.sharedInstance.gameRule.c4State.Time = elapsed;
			}
		}
		catch (System.Exception) { }
	}

	private void UpdateExplodeMode(ISnapshot snap)
	{
		EnsureBombSites();
		if (!_c4Planted)
		{
			PlayerEntityData me;
			if (snap != null && snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me.HasC4)
				BombStatusText = "持有 C4 · E 在包点安装";
			else
				BombStatusText = "爆破模式 · E 安装 / 拆除";
			SetC4State(false, 0);
			return;
		}
		int remaining = Mathf.Max(0, Mathf.CeilToInt(_c4ExplodesAt - Time.time));
		BombStatusText = "C4 已安装 " + remaining + " 秒";
		SetC4State(true, Mathf.Max(0, 35000 - remaining * 1000));
		if (Time.time < _c4ExplodesAt || RoundOver) return;
		_c4Planted = false;
		DestroyC4Visual();
		SetC4State(false, 35000);
		RoundOver = true;
		RoundResult = "爆破成功";
		BombStatusText = "C4 爆炸";
		Debug.Log("[OFFLINE-C4] exploded site=" + _c4SiteIndex);
	}

	private bool HandleExplodeInteract()
	{
		ISnapshot snap = Snap();
		if (snap == null || snap.PlayerEntityDataDict == null) return false;
		PlayerEntityData me;
		if (!snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me)) return false;
		Vector3 playerPos = PlayerPhysicsPosition(me);
		if (_c4Planted)
		{
			if (Vector3.Distance(playerPos, _c4Position) > 300f) return false;
			_c4Planted = false;
			DestroyC4Visual();
			SetC4State(false, 0);
			RoundOver = true;
			RoundResult = "拆弹成功";
			BombStatusText = "C4 已拆除";
			Debug.Log("[OFFLINE-C4] defused");
			return true;
		}
		if (!me.HasC4) return false;
		int siteIndex;
		Vector3 site;
		if (!NearBombSite(playerPos, out siteIndex, out site)) return false;
		_c4Planted = true;
		_c4SiteIndex = siteIndex;
		_c4Position = site;
		_c4ExplodesAt = Time.time + 35f;
		me.HasC4 = false;
		if (me != null)
		{
			PlayerEntity player = Contexts.sharedInstance.player.myPlayerEntity;
			if (player != null && player.hasBasicInfo && player.basicInfo.Next != null) player.basicInfo.Next.HasC4 = false;
		}
		CreateC4Visual();
		Debug.Log("[OFFLINE-C4] planted site=" + siteIndex + " pos=" + site.ToString("F0"));
		return true;
	}

	private void CreateC4Visual()
	{
		DestroyC4Visual();
		_c4Visual = GameObject.CreatePrimitive(PrimitiveType.Cube);
		_c4Visual.name = "OfflineC4";
		_c4Visual.transform.position = new Vector3(_c4Position.x / 100f, _c4Position.y / 100f, _c4Position.z / 100f);
		_c4Visual.transform.localScale = Vector3.one * 40f;
		Renderer renderer = _c4Visual.GetComponent<Renderer>();
		if (renderer != null) renderer.material.color = new Color(0.9f, 0.08f, 0.03f, 1f);
		Collider collider = _c4Visual.GetComponent<Collider>();
		if (collider != null) UnityEngine.Object.Destroy(collider);
	}

	private void DestroyC4Visual()
	{
		if (_c4Visual != null) UnityEngine.Object.Destroy(_c4Visual);
		_c4Visual = null;
	}

    // ---- 离线武器技能：以原版 WeaponSkill 表为准（技能/持续时间/冷却） ----
    private float _nextSkill;
    private WeaponEntity _skillSpecialWeapon;
    private float _skillSpecialUntil;

    private static Assets.Generated.Table.WeaponSkillTable.Row LookupWeaponSkill(string weaponName)
    {
        if (string.IsNullOrEmpty(weaponName)) return null;
        try
        {
            var factory = SSJJBase.Manager.BattleSingletonInstance<Assets.Sources.Info.SkillProgress.SkillProgressFactory>.Instance;
            if (factory == null || factory.SkillProgressInfos == null) return null;
            foreach (var kv in factory.SkillProgressInfos)
            {
                var info = kv.Value;
                var row = info != null ? info.Config : null;
                if (row != null && weaponName.Equals(row.Name, System.StringComparison.OrdinalIgnoreCase)) return row;
            }
        }
        catch (System.Exception ex)
        {
            UnityEngine.Debug.LogWarning("[OFFLINE-SKILL] table lookup fail " + ex.Message);
        }
        return null;
    }

    private void UseWeaponSkill()
    {
        PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
        WeaponEntity w = Contexts.sharedInstance.weapon.currentWeaponEntity;
        if (me == null || w == null || !w.hasBasicInfo || w.basicInfo.Data == null) return;
        string weaponName = w.basicInfo.Data.WeaponName;
        var skill = LookupWeaponSkill(weaponName);
        // 原版数据：SpecialTime=技能持续(ms)，MaxLevel=普通冷却(ms)。
        int durationMs = (skill != null && skill.SpecialTime > 0) ? skill.SpecialTime : 5000;
        int cdMs = (skill != null && skill.Cd != Assets.Generated.Table.WeaponSkillTable.CdType.None && skill.MaxLevel > 0)
            ? skill.MaxLevel : 3000;
        // 表内部分技能 MaxLevel 不是毫秒（如 m4a1_legend2=1），低于 1s 一律按 3s 冷却。
        if (cdMs < 1000) cdMs = 3000;
        _nextSkill = Time.time + Mathf.Max(1f, cdMs / 1000f);
        // SpecialMode 是原版“武器技能态”：开枪/挥刀会走 SpecialLeftAction 等专属逻辑。
        bool specialSet = false;
        if (w.hasSpecial && w.special.EffectLevel > 0)
        {
            w.special.SpecialMode = true;
            _skillSpecialWeapon = w;
            _skillSpecialUntil = Time.time + durationMs / 1000f;
            specialSet = true;
        }
        UnityEngine.Debug.Log("[OFFLINE-SKILL] weapon=" + weaponName + " skill=" + (skill != null ? skill.Id.ToString() : "none")
            + " specialType=" + (skill != null ? skill.SpecialType.ToString() : "-")
            + " durationMs=" + durationMs + " cdMs=" + cdMs + " specialMode=" + (specialSet ? "1" : "0"));
        // HUD 技能环读取 NextSkillTimer（客户端时间，ms）。
        try
        {
            if (me.hasClientTime)
            {
                w.basicInfo.Data.NextSkillTimer = (uint)(me.clientTime.ClientTime + cdMs);
            }
        }
        catch (System.Exception)
        {
        }
        try
        {
            if (me.hasViewAnim)
            {
                Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(me, 46);
            }
        }
        catch (System.Exception)
        {
        }
        Camera cam = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") { cam = cams[i]; break; }
        }
        if (cam == null) return;
        Vector3 origin = cam.transform.position;
        Vector3 fwd = cam.transform.forward;
        int hits = 0;
        var snap = Snap();
        if (snap == null) return;
        foreach (var kv in _agents)
        {
            if (!kv.Value.Alive) continue;
            var d = Get(snap, kv.Key);
            if (d == null) continue;
            if (!IsEnemyOfPlayer(d)) continue;
            Vector3 bp = OfflineBotSpawner.GetUnityPos(d) + Vector3.up * (EyeHeight / 100f);
            Vector3 v = bp - origin;
            float dist = v.magnitude;
            if (dist > 900f) continue;
            float cos = Vector3.Dot(v.normalized, fwd);
            if (cos < 0.6f) continue;
            hits++;
            KillBot(kv.Key, 80f);
        }
        Debug.Log("[OFFLINE-SKILL] weapon=" + w.basicInfo.Data.WeaponName + " hits=" + hits);
    }

    // 技能态到期检查：只回收自己设置的 SpecialMode，避免干扰原版帧动作。
    private void UpdateSkillState()
    {
        if (_skillSpecialWeapon == null) return;
        if (Time.time < _skillSpecialUntil) return;
        try
        {
            if (_skillSpecialWeapon.hasSpecial && _skillSpecialWeapon.special.SpecialMode)
            {
                _skillSpecialWeapon.special.SpecialMode = false;
            }
        }
        catch (System.Exception)
        {
        }
        UnityEngine.Debug.Log("[OFFLINE-SKILL] special mode end");
        _skillSpecialWeapon = null;
    }

    private void UpdateDroppedWeapons()
    {
        if (_dropped.Count == 0) return;
        float dt = Time.deltaTime;
        for (int i = 0; i < _dropped.Count; i++)
        {
            DroppedWeapon d = _dropped[i];
            if (d.Obj == null || d.Landed) continue;
            d.Vel.y -= 980f * dt;
            Vector3 p2 = d.Obj.transform.position + d.Vel * dt;
            if (p2.y <= d.FloorY + 8f)
            {
                p2.y = d.FloorY + 8f;
                d.Landed = true;
                d.Vel = Vector3.zero;
                d.Obj.transform.rotation = Quaternion.Euler(0f, d.Obj.transform.eulerAngles.y, 0f);
            }
            d.Obj.transform.position = p2;
        }
        // 走近自动拾取（原版世界武器贴近即拾取）。
        var me = Contexts.sharedInstance.player.myPlayerEntity;
        if (me == null || !me.hasBasicInfo || me.basicInfo.Current == null) return;
        Vector3 mePos = new Vector3((float)me.basicInfo.Current.X, (float)me.basicInfo.Current.Z, (float)me.basicInfo.Current.Y);
        for (int i = _dropped.Count - 1; i >= 0; i--)
        {
            DroppedWeapon d = _dropped[i];
            if (d.Obj == null) continue;
            float dist = Vector3.Distance(d.Obj.transform.position, mePos);
            if (dist > 130f) continue;
            OfflineGameSetting st = OfflineGameController.setting;
            if (st == null) continue;
            var bag = st.GetBag(st.ActiveBag);
            int slot = d.SlotKind == 2 ? 2 : d.SlotKind == 3 ? 3 : d.SlotKind == 4 ? 4 : (string.IsNullOrEmpty(SlotName(bag, 1)) ? 1 : 2);
            if (slot == 0 || !string.IsNullOrEmpty(SlotName(bag, slot))) continue;
            SetSlotName(bag, slot, d.Name);
            SyncSnapshotBagSlot(st.ActiveBag, slot, d.Name);
            UnityEngine.Object.Destroy(d.Obj);
            _dropped.RemoveAt(i);
            Debug.Log("[OFFLINE-PICK] auto-picked " + d.Name + " -> slot " + slot);
        }
    }

    // ---- 离线丢枪 / 捡枪 / 默认武器 ----
    private static string SlotName(OfflineGameSetting.BagConfig bag, int slot)
    {
        if (bag == null) return null;
        switch (slot)
        {
            case 1: return bag.primary;
            case 2: return bag.secondary;
            case 3: return bag.melee;
            case 4: return bag.throwable;
            default: return null;
        }
    }

    private static void SetSlotName(OfflineGameSetting.BagConfig bag, int slot, string name)
    {
        if (bag == null) return;
        switch (slot)
        {
            case 1: bag.primary = name; break;
            case 2: bag.secondary = name; break;
            case 3: bag.melee = name; break;
            case 4: bag.throwable = name; break;
        }
    }

    private static void SyncSnapshotBagSlot(int bagId, int slot, string name)
    {
        var snap = Contexts.sharedInstance.snapshot.snapshots.LatestSnapshot;
        if (snap == null || snap.BagList == null) return;
        for (int i = 0; i < snap.BagList.Bags.Count; i++)
        {
            var b = snap.BagList.Bags[i];
            if (b == null || b.BagId != bagId) continue;
            var slotData = slot == 1 ? b.FirstWeapon : slot == 2 ? b.SecondaryWeapon : slot == 3 ? b.MeleeWeapon : b.BombWeapons0;
            if (slotData != null) slotData.WeaponName = name;
            break;
        }
    }

    private static int SlotKindOf(string weaponName)
    {
        if (string.IsNullOrEmpty(weaponName)) return 0;
        if (IsThrowableName(weaponName)) return 4;
        if (IsMeleeName(weaponName)) return 3;
        return 1;
    }

    private void DropCurrentWeapon()
    {
        WeaponEntity w = Contexts.sharedInstance.weapon.currentWeaponEntity;
        if (w == null || !w.hasBasicInfo || w.basicInfo.Data == null) return;
        string name = w.basicInfo.Data.WeaponName;
        PlayerEntity meDrop = Contexts.sharedInstance.player.myPlayerEntity;
        int slot = meDrop != null && meDrop.hasCurrentWeapon ? meDrop.currentWeapon.Weapon : 1;
        OfflineGameSetting st = OfflineGameController.setting;
        if (st == null) return;
        var bag = st.GetBag(st.ActiveBag);
        if (bag == null || string.IsNullOrEmpty(SlotName(bag, slot))) return;
        int kind = slot == 2 ? 2 : SlotKindOf(name);
        // 生成世界模型（复用已加载的武器 bundle）。
        GameObject obj = null;
        try
        {
            string bundleName = w.basicInfo.Info != null ? w.basicInfo.Info.AssetBundleName : "weapon/" + name;
            AssetBundle bundle = null;
            foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
            {
                if (b != null && b.name == bundleName) { bundle = b; break; }
            }
            if (bundle != null)
            {
                GameObject prefab = bundle.LoadAsset<GameObject>("gun");
                if (prefab == null)
                {
                    string[] names = bundle.GetAllAssetNames();
                    for (int i = 0; i < names.Length; i++)
                    {
                        GameObject c = bundle.LoadAsset<GameObject>(names[i]);
                        if (c != null) { prefab = c; break; }
                    }
                }
                if (prefab != null) obj = UnityEngine.Object.Instantiate(prefab);
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-DROP] spawn fail " + ex.Message);
        }
        if (obj != null)
        {
            obj.name = "DroppedWeapon_" + name;
            var me = Contexts.sharedInstance.player.myPlayerEntity;
            Vector3 pos = Vector3.zero;
            if (me != null && me.hasBasicInfo && me.basicInfo.Current != null)
            {
                pos = new Vector3((float)me.basicInfo.Current.X, (float)me.basicInfo.Current.Z, (float)me.basicInfo.Current.Y);
            }
            Camera cam = null;
            Camera[] cams = Camera.allCameras;
            for (int i = 0; i < cams.Length; i++)
            {
                if (cams[i] != null && cams[i].name == "Eye") { cam = cams[i]; break; }
            }
            Vector3 fwd = cam != null ? cam.transform.forward : Vector3.forward;
            obj.transform.position = pos + new Vector3(fwd.x, 0f, fwd.z).normalized * 110f + Vector3.up * 30f;
            obj.transform.rotation = Quaternion.Euler(0f, cam != null ? cam.transform.eulerAngles.y : 0f, 0f);
            obj.transform.localScale = Vector3.one;
        }
        // 清空槽位 + 同步快照
        SetSlotName(bag, slot, "");
        SyncSnapshotBagSlot(st.ActiveBag, slot, "");
        DroppedWeapon dw = new DroppedWeapon { Name = name, SlotKind = kind, Obj = obj };
        if (obj != null)
        {
            // [OFFLINE-PATCH] 离线地图为 BSP 物理、没有 Unity 碰撞体：丢弃枪自行积分重力落地。
            Camera camD = null;
            Camera[] camsD = Camera.allCameras;
            for (int ciD = 0; ciD < camsD.Length; ciD++)
            {
                if (camsD[ciD] != null && camsD[ciD].name == "Eye") { camD = camsD[ciD]; break; }
            }
            Vector3 fwdD = camD != null ? camD.transform.forward : Vector3.forward;
            dw.Vel = new Vector3(fwdD.x, 0.6f, fwdD.z).normalized * 260f + Vector3.up * 160f;
            dw.FloorY = obj.transform.position.y - 60f;
        }
        _dropped.Add(dw);
        Debug.Log("[OFFLINE-DROP] dropped weapon=" + name + " slot=" + slot + " count=" + _dropped.Count);
        // 自动切到其它可用槽
        for (int s2 = 1; s2 <= 4; s2++)
        {
            if (s2 == slot) continue;
            if (!string.IsNullOrEmpty(SlotName(bag, s2)))
            {
                if (OfflineGameController.Instance != null) OfflineGameController.Instance.TrySwitchWeapon(s2);
                break;
            }
        }
    }

    private void PickupNearestWeapon()
    {
        if (_dropped.Count == 0) return;
        var me = Contexts.sharedInstance.player.myPlayerEntity;
        if (me == null || !me.hasBasicInfo || me.basicInfo.Current == null) return;
        Vector3 pos = new Vector3((float)me.basicInfo.Current.X, (float)me.basicInfo.Current.Z, (float)me.basicInfo.Current.Y);
        DroppedWeapon best = null;
        float bestDist = 260f;
        for (int i = 0; i < _dropped.Count; i++)
        {
            var d = _dropped[i];
            if (d.Obj == null) { best = d; bestDist = 0f; break; }
            float dist = Vector3.Distance(d.Obj.transform.position, pos);
            if (dist < bestDist) { best = d; bestDist = dist; }
        }
        if (best == null)
        {
            if (Time.time >= _nextPickLog) { _nextPickLog = Time.time + 2f; Debug.Log("[OFFLINE-PICK] no weapon in range"); }
            return;
        }
        OfflineGameSetting st = OfflineGameController.setting;
        if (st == null) return;
        var bag = st.GetBag(st.ActiveBag);
        int slot = 0;
        if (best.SlotKind == 2) slot = 2;
        else if (best.SlotKind == 3) slot = 3;
        else if (best.SlotKind == 4) slot = 4;
        else slot = string.IsNullOrEmpty(SlotName(bag, 1)) ? 1 : 2;
        if (slot == 0 || !string.IsNullOrEmpty(SlotName(bag, slot)))
        {
            Debug.Log("[OFFLINE-PICK] no free slot for " + best.Name);
            return;
        }
        SetSlotName(bag, slot, best.Name);
        SyncSnapshotBagSlot(st.ActiveBag, slot, best.Name);
        if (best.Obj != null) UnityEngine.Object.Destroy(best.Obj);
        _dropped.Remove(best);
        Debug.Log("[OFFLINE-PICK] picked " + best.Name + " -> slot " + slot);
        if (OfflineGameController.Instance != null) OfflineGameController.Instance.TrySwitchWeapon(slot);
    }

    private void EnsureDefaultWeapon()
    {
        if (Time.time < _nextEquipCheck) return;
        _nextEquipCheck = Time.time + 2f;
        WeaponEntity w = Contexts.sharedInstance.weapon.currentWeaponEntity;
        if (w != null && w.hasBasicInfo && w.basicInfo.Info != null) return;
        OfflineGameSetting st = OfflineGameController.setting;
        if (st == null) return;
        var bag = st.GetBag(st.ActiveBag);
        for (int s2 = 1; s2 <= 4; s2++)
        {
            if (!string.IsNullOrEmpty(SlotName(bag, s2)))
            {
                Debug.Log("[OFFLINE-EQUIP] default weapon fallback -> slot " + s2);
                if (OfflineGameController.Instance != null) OfflineGameController.Instance.TrySwitchWeapon(s2);
                return;
            }
        }
    }

    // ---- 离线换弹 ----
    private float _reloadEnd;
    private int _reloadWeaponId;

    private void StartReload()
    {
        if (Time.time < _reloadEnd) return;
        WeaponEntity weapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
        if (weapon == null || !weapon.hasClip || !weapon.hasBasicInfo || weapon.basicInfo.Data == null) return;
        string wn = weapon.basicInfo.Data.WeaponName;
        if (IsMeleeName(wn) || IsThrowableWeapon(weapon)) return;
        if (weapon.clip.Clip >= weapon.clip.MaxClip) return;
        if (weapon.clip.CarryClip <= 0) return;
        _reloadWeaponId = weapon.basicInfo.Data.Id;
        _reloadEnd = Time.time + 1.2f;
        SetTorsoAction(17);
        try
        {
            PlayerEntity meReload = Contexts.sharedInstance.player.myPlayerEntity;
            if (meReload != null && meReload.hasViewAnim && weapon.hasBasicInfo && weapon.basicInfo.Info != null)
            {
                int reloadAnim = Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.FindViewAnimByName(weapon.basicInfo.Info, "TORSO_RELOAD");
                if (reloadAnim > 0) Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(meReload, reloadAnim);
            }
        }
        catch (System.Exception) { }
        Debug.Log("[OFFLINE-RELOAD] start " + wn + " clip=" + weapon.clip.Clip + "/" + weapon.clip.MaxClip);
    }

    // [OFFLINE-ANIM] 只提交原版视图动画状态；Animator 由 ViewAnimSystem 唯一驱动。
    private void PlayAttackViewAnim(WeaponEntity weapon, int animId)
    {
        try
        {
            if (weapon != null && weapon.hasSpecial) weapon.special.IsRaise = false;
            PendingRaiseAt = 0f;
            PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
            if (me == null || !me.hasViewAnim) return;
            Assets.Sources.Utils.PlayerAnim.PlayerAnimationUtility.SetViewAnimation(me, animId);
            AttackAnimActive = false;
            Debug.Log("[OFFLINE-ANIM] fallback state=" + animId
                + " weapon=" + (weapon != null && weapon.hasBasicInfo && weapon.basicInfo.Data != null
                    ? weapon.basicInfo.Data.WeaponName : "-"));
        }
        catch (System.Exception ex)
        {
            UnityEngine.Debug.LogWarning("[OFFLINE-ANIM] fallback state failed: " + ex.Message);
        }
    }

    private void UpdateAttackViewAnim()
    {
        // 近战连段和持枪动画由原版 Action 按真实出手时机切换，不按鼠标长按自动循环。
        AttackAnimActive = false;
    }

    private void UpdateReload()
    {
        if (_reloadEnd <= 0f || Time.time < _reloadEnd) return;
        _reloadEnd = 0f;
        WeaponEntity weapon = Contexts.sharedInstance.weapon.currentWeaponEntity;
        if (weapon == null || !weapon.hasClip) return;
        if (weapon.hasBasicInfo && weapon.basicInfo.Data != null && weapon.basicInfo.Data.Id != _reloadWeaponId) return;
        int need = weapon.clip.MaxClip - weapon.clip.Clip;
        if (need <= 0) return;
        int take = Mathf.Min(need, weapon.clip.CarryClip);
        if (take <= 0) return;
        weapon.clip.Clip += take;
        weapon.clip.CarryClip -= take;
        SyncClipToSnapshot(weapon);
        Debug.Log("[OFFLINE-RELOAD] done clip=" + weapon.clip.Clip + " carry=" + weapon.clip.CarryClip);
    }

    /// <summary>把武器实体的弹药写回快照背包数据（HUD 与背包面板都读快照）。</summary>
    private static void SyncClipToSnapshot(WeaponEntity weapon)
    {
        if (weapon == null || !weapon.hasClip || !weapon.hasBasicInfo || weapon.basicInfo.Data == null) return;
        BaseWeaponData data = weapon.basicInfo.Data;
        data.Clip = weapon.clip.Clip;
        data.CarryClip = weapon.clip.CarryClip;
        data.Clip2 = weapon.clip.Clip2;
        data.CarryClip2 = weapon.clip.CarryClip2;

        ISnapshot s = (Instance != null) ? Instance.Snap() : null;
        if (s == null || s.BagList == null || s.BagList.Bags == null) return;
        for (int i = 0; i < s.BagList.Bags.Count; i++)
        {
            PlayerBagData bag = s.BagList.Bags[i];
            if (bag == null) continue;
            SyncBagSlot(bag.FirstWeapon, data);
            SyncBagSlot(bag.SecondaryWeapon, data);
            SyncBagSlot(bag.MeleeWeapon, data);
            SyncBagSlot(bag.BombWeapons0, data);
            SyncBagSlot(bag.BombWeapons1, data);
            SyncBagSlot(bag.BombWeapons2, data);
        }
    }

    private static void SyncBagSlot(BaseWeaponData slot, BaseWeaponData src)
    {
        if (slot == null || src == null || slot.Id != src.Id) return;
        slot.Clip = src.Clip;
        slot.CarryClip = src.CarryClip;
        slot.Clip2 = src.Clip2;
        slot.CarryClip2 = src.CarryClip2;
    }

    private static bool IsMeleeWeapon(WeaponEntity weapon)
    {
        if (weapon == null || !weapon.hasBasicInfo) return false;
        if (weapon.basicInfo.Info != null && weapon.basicInfo.Info.WeaponType == 2) return true;
        return weapon.basicInfo.Data != null && IsMeleeName(weapon.basicInfo.Data.WeaponName);
    }

    private static bool IsMeleeName(string n)
    {
        if (string.IsNullOrEmpty(n)) return false;
        string s = n.ToLowerInvariant();
        return s.Contains("botweapon") || s.Contains("dagger") || s.Contains("knife") || s.Contains("bat")
            || s.Contains("axe") || s.Contains("sword") || s.Contains("hammer")
            || s.Contains("blade") || s.Contains("claw") || s.Contains("scythe")
            || s.Contains("fan") || s.Contains("guqin") || s.Contains("whip")
            || s.Contains("spear") || s.Contains("staff") || s.Contains("club")
            || s.Contains("sickle") || s.Contains("shovel") || s.Contains("pickaxe")
            || s.Contains("fangs") || s.Contains("machete") || s.Contains("katana")
            || s.Contains("kris") || s.Contains("kukri") || s.Contains("halberd")
            || s.Contains("gauntlet") || s.Contains("nunchaku") || s.Contains("trident")
            || s.Contains("glaive") || s.Contains("crowbar") || s.Contains("wrench")
            || s.Contains("bayonet") || s.Contains("knuckle")
            || s.Contains("stick") || s.Contains("pole") || s.Contains("shield")
            || s.Contains("umbrella") || s.Contains("yoyo") || s.Contains("drum")
            || s.Contains("mantis") || s.Contains("awakening") || s.Contains("pokong")
            || s.Contains("saw") || s.Contains("shears");
    }

    private static bool IsThrowableWeapon(WeaponEntity weapon)
    {
        if (weapon == null || !weapon.hasBasicInfo) return false;
        if (weapon.basicInfo.Info != null) return weapon.basicInfo.Info.WeaponType == 3;
        return weapon.basicInfo.Data != null && IsThrowableName(weapon.basicInfo.Data.WeaponName);
    }

    private static bool IsThrowableName(string n)
    {
        if (string.IsNullOrEmpty(n)) return false;
        return n.Contains("grenade") || n.Contains("bomb") || n == "c4";
    }

    // [OFFLINE-PATCH] 旧 HUD 已移除，改由 OfflineHud 统一绘制（原游戏风格布局）。
    // 保留空实现只是为了防止其它地方反射调用 OnGUI 时报错。
    private void OnGUI()
    {
    }
}


