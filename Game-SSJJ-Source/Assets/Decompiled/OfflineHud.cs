using System.Collections.Generic;
using Assets.Sources.Components.Interface;
using Assets.Sources.Snapshots;
using Assets.Sources.Systems.Snapshot;
using NetData;
using UnityEngine;

/// <summary>
/// 单机版 HUD —— 按原游戏布局还原：
///   · 左下：血条（红底 + 绿/黄/红分段填充 + 数值）
///   · 右下：武器信息（名称 / 弹药 / 近战标记）
///   · 中心：动态准星（随移动扩散）
///   · 左上：小地图雷达（原图 map.png 底图 + 自身朝向扇形 + 敌我光点）
///   · 右上：战绩面板（击杀 / 死亡 / 剩余时间）
///
/// 小地图贴图从已加载的 maps/map1 bundle 里按名字取（"map"），取不到就退化
/// 成纯色底板，不会崩。
/// </summary>
[DefaultExecutionOrder(22000)]
public class OfflineHud : MonoBehaviour
{
    public static OfflineHud Instance;

    /// <summary>只作为 F6 训练面板宿主；原版 HUD 继续由 UGUI 自己绘制。</summary>
    public bool TrainingPanelOnly;

    /// <summary>B 键背包开关。由 OfflineGameController 切换。</summary>
    public static bool BackpackOpen;
    /// <summary>F6 map12 训练面板。所有离线输入都把它视作模态面板。</summary>
    public static bool TrainingPanelOpen;
    public static bool IsModalPanelOpen { get { return BackpackOpen || TrainingPanelOpen; } }

    // ---- 布局常量（按 1600x900 设计，运行时按屏幕缩放）----
    private const float RefW = 1600f;
    private const float RefH = 900f;

    private float _scale = 1f;
    private GUIStyle _txtBig, _txtMid, _txtSmall, _txtNum, _slotBtn;
    private Texture2D _white;
    private Texture2D _minimap;
    private Texture2D _minimapBack;
    private Texture2D _trainingBackdrop;
    private bool _texTried;

    // 地图包围盒（SSJJ 原始坐标，用于把世界坐标投到小地图贴图上）
    private float _mapMinX = 0f, _mapMaxX = 11188f;
    private float _mapMinZ = 0f, _mapMaxZ = 11188f;
    // map.png 实际有效内容只占左上 1/4（512/1024），映射要乘这个比例
    private const float MapUvScale = 0.5f;

    private float _crossSpread = 6f;
    private int _trainingDraftTotal = 5;
    private int _trainingDraftAllies;
    private string _trainingDraftDifficulty = "hard";
    private string _trainingPanelMessage = "";
    private static readonly string[] TrainingDifficulties = { "easy", "normal", "hard", "nightmare", "hell" };
    private static readonly string[] TrainingDifficultyNames = { "简单", "普通", "困难", "噩梦", "地狱" };

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        _white = new Texture2D(1, 1, TextureFormat.RGBA32, false);
        _white.SetPixel(0, 0, Color.white);
        _white.Apply();
        LoadTrainingBackdrop();
        // 注意：这里不能立即 TryLoadMinimap —— 地图 bundle 是异步加载的，
        // 进图前 GetAllLoadedAssetBundles 里还没有 maps/map1。改成每帧重试。
    }

    private void LoadTrainingBackdrop()
    {
        try
        {
            using (var stream = typeof(OfflineHud).Assembly.GetManifestResourceStream("OfflineTrainingPanelBackground.jpg"))
            {
                if (stream == null)
                {
                    Debug.LogWarning("[OFFLINE-TRAINING] embedded background image not found");
                    return;
                }
                byte[] bytes = new byte[stream.Length];
                int offset = 0;
                while (offset < bytes.Length)
                {
                    int read = stream.Read(bytes, offset, bytes.Length - offset);
                    if (read <= 0) break;
                    offset += read;
                }
                _trainingBackdrop = new Texture2D(2, 2, TextureFormat.RGB24, false);
                if (!_trainingBackdrop.LoadImage(bytes))
                {
                    Destroy(_trainingBackdrop);
                    _trainingBackdrop = null;
                    Debug.LogWarning("[OFFLINE-TRAINING] background image decode failed");
                }
                else
                {
                    _trainingBackdrop.name = "OfflineTrainingPanelBackground";
                    _trainingBackdrop.wrapMode = TextureWrapMode.Clamp;
                    _trainingBackdrop.filterMode = FilterMode.Bilinear;
                    Debug.Log("[OFFLINE-TRAINING] blurred background loaded " + _trainingBackdrop.width + "x" + _trainingBackdrop.height);
                }
            }
        }
        catch (System.Exception e)
        {
            Debug.LogWarning("[OFFLINE-TRAINING] background image load failed: " + e.Message);
        }
    }

    private void Update()
    {
        if (TrainingPanelOnly) return;
        if (_minimap == null) TryLoadMinimap();
    }

    public static void ToggleTrainingPanel()
    {
        if (TrainingPanelOpen)
        {
            CloseTrainingPanel();
            return;
        }
        if (!OfflineBotSpawner.IsMap12TrainingProfile(OfflineGameController.setting))
        {
            Debug.Log("[OFFLINE-TRAINING] F6 panel is available in map12 team training only");
            return;
        }
        if (BackpackOpen) return;
        TrainingPanelOpen = true;
        Debug.Log("[OFFLINE-TRAINING] F6 panel opened");
        if (Instance != null) Instance.BeginTrainingDraft();
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
    }

    public static void CloseTrainingPanel()
    {
        TrainingPanelOpen = false;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void BeginTrainingDraft()
    {
		_trainingDraftTotal = OfflineBotSpawner.TrainingActiveCount;
        _trainingDraftAllies = OfflineBotSpawner.TrainingAllyCount;
        _trainingDraftDifficulty = OfflineBotSpawner.NormalizeDifficulty(OfflineBotSpawner.TrainingDifficulty);
        _trainingPanelMessage = "";
    }

    /// <summary>
    /// 从已加载的 AssetBundle 里找名为 "map" 的贴图当小地图底图。
    /// maps/map1 由 BuildMap1Assets 打包，里面包含 map / smallmapback 两张原图。
    /// </summary>
    private void TryLoadMinimap()
    {
        if (_minimap != null) return;
        try
        {
            // 不靠 bundle 名匹配：扫描所有已加载 bundle 里叫 "map" 的贴图。
            // maps/map1 由 BuildMap1Assets 打包，内含原图 map / smallmapback。
            int scanned = 0;
            foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
            {
                if (b == null) continue;
                scanned++;
                Texture2D[] texs = null;
                try { texs = b.LoadAllAssets<Texture2D>(); }
                catch { continue; }
                if (texs == null) continue;
                for (int k = 0; k < texs.Length; k++)
                {
                    if (texs[k] == null) continue;
                    if (texs[k].name == "map") _minimap = texs[k];
                    else if (texs[k].name == "smallmapback") _minimapBack = texs[k];
                }
                if (_minimap != null && _minimapBack != null)
                {
                    Debug.Log("[OFFLINE-HUD] minimap ok from bundle=" + b.name
                        + " scanned=" + scanned + " size=" + _minimap.width + "x" + _minimap.height);
                    return;
                }
            }
        }
        catch (System.Exception e)
        {
            Debug.Log("[OFFLINE-HUD] minimap load failed: " + e.Message);
        }
    }

    private void EnsureStyles()
    {
        _scale = Mathf.Min(Screen.width / RefW, Screen.height / RefH);
        if (_txtBig == null)
        {
            _txtBig = new GUIStyle(GUI.skin.label) { fontSize = Mathf.RoundToInt(20 * _scale) };
            _txtBig.normal.textColor = Color.white;
            _txtBig.fontStyle = FontStyle.Bold;
            _txtMid = new GUIStyle(_txtBig) { fontSize = Mathf.RoundToInt(16 * _scale) };
            _txtSmall = new GUIStyle(_txtBig) { fontSize = Mathf.RoundToInt(12 * _scale) };
            _txtSmall.normal.textColor = new Color(0.85f, 0.85f, 0.85f);
            _txtNum = new GUIStyle(_txtBig) { fontSize = Mathf.RoundToInt(26 * _scale) };
            _txtNum.alignment = TextAnchor.MiddleRight;
            _slotBtn = new GUIStyle(GUI.skin.button);
            _slotBtn.normal.background = null;
            _slotBtn.hover.background = null;
            _slotBtn.active.background = null;
            _slotBtn.normal.textColor = Color.clear;
            _slotBtn.hover.textColor = Color.clear;
            _slotBtn.active.textColor = Color.clear;
        }
    }

    // 每次需要半透明色块时用白色贴图 + GUI.color 染色
    private void Rect_(Rect r, Color c)
    {
        Color old = GUI.color;
        GUI.color = c;
        GUI.DrawTexture(r, _white);
        GUI.color = old;
    }

    private void Tex_(Rect r, Texture2D t, Color c)
    {
        if (t == null) return;
        Color old = GUI.color;
        GUI.color = c;
        GUI.DrawTexture(r, t, ScaleMode.StretchToFill, true);
        GUI.color = old;
    }

    private void OnGUI()
    {
        EnsureStyles();
        if (TrainingPanelOnly)
        {
            if (TrainingPanelOpen) DrawTrainingPanel();
            return;
        }
        var gp = OfflineGameplay.Instance;
        var snap = SnapData();
        PlayerEntityData me = null;
        if (snap != null && snap.PlayerEntityDataDict != null)
            snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me);

        DrawHealthBar(me);
        DrawWeaponPanel(snap, me);
        DrawSlotStrip(snap, me);
        // [OFFLINE-SCOPE] 开镜（IsHideFristView）时盖镜内遮罩，并停掉普通准星。
        DrawScope();
        if (_scopeAlpha < 0.5f) DrawCrosshair();
        DrawMinimap(snap, me);
        DrawScoreboard(gp);

        if (BackpackOpen) DrawBackpack(snap, me);
        if (gp != null && gp.RoundOver) DrawRoundOver(gp);
        if (TrainingPanelOpen) DrawTrainingPanel();
    }

    private void DrawTrainingPanel()
    {
        Rect screen = new Rect(0f, 0f, Screen.width, Screen.height);
        if (_trainingBackdrop != null)
        {
            Color old = GUI.color;
            GUI.color = new Color(0.78f, 0.84f, 1f, 0.92f);
            GUI.DrawTexture(screen, _trainingBackdrop, ScaleMode.ScaleAndCrop, true);
            GUI.color = old;
        }
        Rect_(screen, new Color(0.025f, 0.035f, 0.075f, _trainingBackdrop != null ? 0.30f : 0.82f));

        float w = Mathf.Min(680f * _scale, Screen.width - 36f * _scale);
        float h = Mathf.Min(500f * _scale, Screen.height - 36f * _scale);
        float x = (Screen.width - w) * 0.5f, y = (Screen.height - h) * 0.5f;
        // 叠加半透明浅色玻璃层、细描边和高光，保留背后的模糊樱花图。
        Rect_(new Rect(x - 2f * _scale, y - 2f * _scale, w + 4f * _scale, h + 4f * _scale), new Color(0.78f, 0.87f, 1f, 0.72f));
        Rect_(new Rect(x, y, w, h), new Color(0.24f, 0.30f, 0.42f, 0.58f));
        Rect_(new Rect(x + 1f * _scale, y + 1f * _scale, w - 2f * _scale, 1f * _scale), new Color(1f, 1f, 1f, 0.45f));
        Rect_(new Rect(x + 18f * _scale, y + 91f * _scale, w - 36f * _scale, 1f * _scale), new Color(1f, 1f, 1f, 0.20f));

        GUI.Label(new Rect(x + 30f * _scale, y + 20f * _scale, w - 60f * _scale, 34f * _scale), "训练设置", _txtBig);
        GUI.Label(new Rect(x + 31f * _scale, y + 55f * _scale, w - 62f * _scale, 28f * _scale),
            "MAP 12  ·  离线练枪  ·  默认 0 队友 / 1 敌人  ·  本局生效", _txtSmall);
        GUI.Label(new Rect(x + w - 145f * _scale, y + 23f * _scale, 110f * _scale, 28f * _scale), "F6 关闭", _txtSmall);

        float rowY = y + 112f * _scale;
        float labelX = x + 36f * _scale;
        float valueX = x + 400f * _scale;
        float rowH = 52f * _scale;
        GUI.Label(new Rect(labelX, rowY, 250f * _scale, rowH), "人机总数", _txtMid);
        if (GUI.Button(new Rect(valueX, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "−"))
        {
            _trainingDraftTotal = Mathf.Max(1, _trainingDraftTotal - 1);
            _trainingDraftAllies = Mathf.Min(_trainingDraftAllies, _trainingDraftTotal - 1);
        }
        GUI.Label(new Rect(valueX + 50f * _scale, rowY, 65f * _scale, rowH), _trainingDraftTotal.ToString(), _txtMid);
        if (GUI.Button(new Rect(valueX + 120f * _scale, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "+"))
            _trainingDraftTotal = Mathf.Min(OfflineBotSpawner.TrainingBotTotal, _trainingDraftTotal + 1);

        rowY += rowH;
        GUI.Label(new Rect(labelX, rowY, 250f * _scale, rowH), "队友", _txtMid);
        if (GUI.Button(new Rect(valueX, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "−"))
            _trainingDraftAllies = Mathf.Max(0, _trainingDraftAllies - 1);
        GUI.Label(new Rect(valueX + 50f * _scale, rowY, 65f * _scale, rowH), _trainingDraftAllies.ToString(), _txtMid);
        if (GUI.Button(new Rect(valueX + 120f * _scale, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "+"))
            _trainingDraftAllies = Mathf.Min(_trainingDraftTotal - 1, _trainingDraftAllies + 1);

        rowY += rowH;
        int enemyDraft = _trainingDraftTotal - _trainingDraftAllies;
        GUI.Label(new Rect(labelX, rowY, 250f * _scale, rowH), "敌人", _txtMid);
        if (GUI.Button(new Rect(valueX, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "−"))
            _trainingDraftAllies = Mathf.Min(_trainingDraftTotal - 1, _trainingDraftAllies + 1);
        GUI.Label(new Rect(valueX + 50f * _scale, rowY, 65f * _scale, rowH), enemyDraft.ToString(), _txtMid);
        if (GUI.Button(new Rect(valueX + 120f * _scale, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "+"))
            _trainingDraftAllies = Mathf.Max(0, _trainingDraftAllies - 1);

        rowY += rowH;
        GUI.Label(new Rect(labelX, rowY, 250f * _scale, rowH), "变异体", _txtMid);
        GUI.Label(new Rect(valueX, rowY, w - (valueX - x) - 28f * _scale, rowH),
            "不可用：本地缺原版模型、动画及攻击资源", _txtSmall);

        rowY += rowH;
        GUI.Label(new Rect(labelX, rowY, 250f * _scale, rowH), "难度", _txtMid);
        int diffIndex = System.Array.IndexOf(TrainingDifficulties, _trainingDraftDifficulty);
        if (diffIndex < 0) diffIndex = 2;
        if (GUI.Button(new Rect(valueX, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "◀"))
            diffIndex = (diffIndex + TrainingDifficulties.Length - 1) % TrainingDifficulties.Length;
        if (GUI.Button(new Rect(valueX + 120f * _scale, rowY + 3f * _scale, 42f * _scale, 34f * _scale), "▶"))
            diffIndex = (diffIndex + 1) % TrainingDifficulties.Length;
        _trainingDraftDifficulty = TrainingDifficulties[diffIndex];
        GUI.Label(new Rect(valueX + 50f * _scale, rowY, 65f * _scale, rowH), TrainingDifficultyNames[diffIndex], _txtMid);

        if (!string.IsNullOrEmpty(_trainingPanelMessage))
            GUI.Label(new Rect(labelX, y + h - 116f * _scale, w - 72f * _scale, 26f * _scale), _trainingPanelMessage, _txtSmall);
        GUI.Label(new Rect(labelX, y + h - 84f * _scale, w - 72f * _scale, 22f * _scale),
            "配置只在本次运行中生效；launch_config.json 不会被修改。", _txtSmall);

        float btnY = y + h - 52f * _scale;
        if (GUI.Button(new Rect(x + 36f * _scale, btnY, 250f * _scale, 36f * _scale), "应用并重开"))
        {
            if (OfflineBotSpawner.ConfigureMap12Training(_trainingDraftTotal, _trainingDraftAllies, _trainingDraftDifficulty))
                CloseTrainingPanel();
            else
                _trainingPanelMessage = "阵容未能重建：当前快照里没有完整的 7 个原版人机槽位。";
        }
        if (GUI.Button(new Rect(x + w - 166f * _scale, btnY, 130f * _scale, 36f * _scale), "取消"))
            CloseTrainingPanel();
    }

    private ISnapshot SnapData()
    {
        var ctx = Contexts.sharedInstance;
        if (ctx == null) return null;
        return ctx.snapshot.snapshots.LatestSnapshot;
    }

    // ---------------- 血条 ----------------
    private void DrawHealthBar(PlayerEntityData me)
    {
        float hp = 100f, maxHp = 100f;
        if (me != null)
        {
            hp = me.Hp;
            maxHp = (me.MaxHp > 0f) ? me.MaxHp : 100f;
        }
        float frac = Mathf.Clamp01(hp / maxHp);

        float w = 300f * _scale, h = 24f * _scale;
        float x = 40f * _scale, y = Screen.height - 60f * _scale - h;

        // 外框 + 底色
        Rect_(new Rect(x - 2, y - 2, w + 4, h + 4), new Color(0f, 0f, 0f, 0.75f));
        Rect_(new Rect(x, y, w, h), new Color(0.12f, 0.05f, 0.05f, 0.9f));

        // 填充色：>50% 绿，>25% 黄，否则红
        Color fill = frac > 0.5f ? new Color(0.28f, 0.86f, 0.33f)
                   : frac > 0.25f ? new Color(0.95f, 0.78f, 0.22f)
                   : new Color(0.92f, 0.22f, 0.22f);
        Rect_(new Rect(x, y, w * frac, h), fill);

        // 高光
        Rect_(new Rect(x, y, w * frac, h * 0.35f), new Color(1f, 1f, 1f, 0.18f));

        GUI.Label(new Rect(x + 8 * _scale, y + 1 * _scale, w, h),
            "HP  " + Mathf.CeilToInt(hp), _txtBig);
    }

    // ---------------- 武器信息 ----------------
    private void DrawWeaponPanel(ISnapshot snap, PlayerEntityData me)
    {
        string wname = "black_dagger";
        if (me != null && !string.IsNullOrEmpty(me.CurrentWeaponName)) wname = me.CurrentWeaponName;
        BaseWeaponData data = CurrentWeaponData(snap, me);

        float w = 250f * _scale, h = 64f * _scale;
        float x = Screen.width - w - 40f * _scale;
        float y = Screen.height - 60f * _scale - h;

        Rect_(new Rect(x - 2, y - 2, w + 4, h + 4), new Color(0f, 0f, 0f, 0.7f));
        Rect_(new Rect(x, y, w, h), new Color(0.08f, 0.09f, 0.11f, 0.82f));

        bool melee = IsMelee(wname);
        string label = IsThrowable(wname) ? "投掷武器" : (melee ? "近战武器" : "主武器");

        GUI.Label(new Rect(x + 10 * _scale, y + 4 * _scale, w, 22 * _scale),
            PrettyName(wname), _txtMid);
        GUI.Label(new Rect(x + 10 * _scale, y + 30 * _scale, w, 20 * _scale),
            label, _txtSmall);

        string ammo;
        if (melee) ammo = "∞";
        else if (data != null) ammo = data.Clip + " / " + data.CarryClip;
        else ammo = "—";
        GUI.Label(new Rect(x, y + 22 * _scale, w - 12 * _scale, 28 * _scale), ammo, _txtNum);
    }

    // ---------------- 右下角 1~4 武器槽 ----------------
    private void DrawSlotStrip(ISnapshot snap, PlayerEntityData me)
    {
        if (me == null) return;
        PlayerBagData bag = GetBag(snap, me);
        if (bag == null) return;
        BaseWeaponData[] slots = SlotWeapons(bag);
        float w = 108f * _scale, h = 42f * _scale, gap = 6f * _scale;
        float x = Screen.width - 40f * _scale - (w * 4f + gap * 3f);
        float y = Screen.height - 60f * _scale - 64f * _scale - 12f * _scale - h;

        for (int i = 0; i < 4; i++)
        {
            bool current = me.CurrentWeapon == i + 1;
            float bx = x + i * (w + gap);
            Rect_(new Rect(bx, y, w, h), current
                ? new Color(0.16f, 0.42f, 0.24f, 0.92f)
                : new Color(0.08f, 0.09f, 0.11f, 0.78f));
            if (current) Rect_(new Rect(bx, y + h - 3f * _scale, w, 3f * _scale),
                new Color(0.45f, 1f, 0.55f, 1f));
            GUI.Label(new Rect(bx + 6f * _scale, y + 2f * _scale, 18f * _scale, 18f * _scale),
                (i + 1).ToString(), _txtSmall);
            string name = (slots[i] != null) ? PrettyName(slots[i].WeaponName) : "空";
            GUI.Label(new Rect(bx + 6f * _scale, y + 18f * _scale, w - 8f * _scale, 20f * _scale),
                name, _txtSmall);
        }
    }

    // ---------------- B 键背包 ----------------
    private void DrawBackpack(ISnapshot snap, PlayerEntityData me)
    {
        Rect_(new Rect(0f, 0f, Screen.width, Screen.height), new Color(0f, 0f, 0f, 0.55f));
        float w = 660f * _scale, h = 470f * _scale;
        float x = (Screen.width - w) * 0.5f, y = (Screen.height - h) * 0.5f;
        Rect_(new Rect(x - 2f, y - 2f, w + 4f, h + 4f), new Color(0.25f, 0.55f, 0.32f, 0.9f));
        Rect_(new Rect(x, y, w, h), new Color(0.06f, 0.08f, 0.09f, 0.96f));
        int activeBag = (me != null) ? me.CurrentBagId : 1;
        GUI.Label(new Rect(x + 20f * _scale, y + 12f * _scale, w, 32f * _scale), "背 包", _txtBig);
        GUI.Label(new Rect(x + 20f * _scale, y + 44f * _scale, w, 20f * _scale),
            "按 1~5 切换背包 · 点击槽位切换武器 · B 关闭", _txtSmall);

        // 原版 5 个背包页签
        int bagCount = OfflineGameSetting.BagCount;
        float tabGap = 8f * _scale;
        float tabW = (w - 40f * _scale - tabGap * (bagCount - 1)) / bagCount;
        float tabH = 36f * _scale;
        float tabY = y + 72f * _scale;
        for (int b = 0; b < bagCount; b++)
        {
            int bagId = b + 1;
            Rect tab = new Rect(x + 20f * _scale + b * (tabW + tabGap), tabY, tabW, tabH);
            bool active = (bagId == activeBag);
            Rect_(tab, active ? new Color(0.18f, 0.46f, 0.26f, 0.95f)
                              : new Color(0.11f, 0.13f, 0.15f, 0.9f));
            if (active) Rect_(new Rect(tab.x, tab.y + tab.height - 3f * _scale, tab.width, 3f * _scale),
                new Color(0.45f, 1f, 0.55f, 1f));
            GUIStyle tabStyle = new GUIStyle(_txtMid) { alignment = TextAnchor.MiddleCenter };
            GUI.Label(tab, "背包 " + bagId, tabStyle);
            if (GUI.Button(tab, "", _slotBtn))
            {
                OfflineGameController ctrl = OfflineGameController.Instance;
                if (ctrl != null) ctrl.TrySwitchBag(bagId);
            }
        }

        PlayerBagData bag = GetBag(snap, me);
        BaseWeaponData[] slots = (bag != null) ? SlotWeapons(bag) : new BaseWeaponData[4];
        string[] labels = { "主武器", "副武器", "近战", "投掷" };
        float rowH = 64f * _scale, rowGap = 10f * _scale;
        float ry = tabY + tabH + 18f * _scale;
        for (int i = 0; i < 4; i++)
        {
            Rect row = new Rect(x + 20f * _scale, ry + i * (rowH + rowGap), w - 40f * _scale, rowH);
            bool current = me != null && me.CurrentWeapon == i + 1;
            Rect_(row, current ? new Color(0.14f, 0.36f, 0.22f, 0.95f)
                               : new Color(0.12f, 0.14f, 0.16f, 0.9f));
            if (current) Rect_(new Rect(row.x, row.y, 4f * _scale, row.height),
                new Color(0.45f, 1f, 0.55f, 1f));

            string name = (slots[i] != null) ? PrettyName(slots[i].WeaponName) : "空槽位";
            GUI.Label(new Rect(row.x + 16f * _scale, row.y + 8f * _scale, 420f * _scale, 24f * _scale),
                (i + 1) + "   " + name, _txtMid);
            GUI.Label(new Rect(row.x + 16f * _scale, row.y + 36f * _scale, 420f * _scale, 20f * _scale),
                labels[i] + (slots[i] != null && !IsMelee(slots[i].WeaponName) && !IsThrowable(slots[i].WeaponName)
                    ? ("   " + slots[i].Clip + " / " + slots[i].CarryClip) : ""), _txtSmall);
            GUIStyle bagTag = new GUIStyle(_txtSmall) { alignment = TextAnchor.MiddleRight };
            GUI.Label(new Rect(row.x, row.y + 20f * _scale, row.width - 16f * _scale, 22f * _scale),
                "背包 " + activeBag + " · 槽 " + (i + 1), bagTag);

            if (GUI.Button(row, "", _slotBtn))
            {
                OfflineGameController ctrl = OfflineGameController.Instance;
                if (ctrl != null) ctrl.TrySwitchWeapon(i + 1);
                BackpackOpen = false;
                // 点选后关闭面板时必须恢复鼠标锁定，否则相机视角再也转不动。
                Cursor.visible = false;
                Cursor.lockState = CursorLockMode.Locked;
            }
        }
    }

    private static PlayerBagData GetBag(ISnapshot snap, PlayerEntityData me)
    {
        if (snap == null || snap.BagList == null || snap.BagList.Bags == null || me == null) return null;
        for (int i = 0; i < snap.BagList.Bags.Count; i++)
        {
            if (snap.BagList.Bags[i] != null && snap.BagList.Bags[i].BagId == me.CurrentBagId)
                return snap.BagList.Bags[i];
        }
        return null;
    }

    private static BaseWeaponData[] SlotWeapons(PlayerBagData bag)
    {
        return new BaseWeaponData[]
        {
            bag.FirstWeapon, bag.SecondaryWeapon, bag.MeleeWeapon, bag.BombWeapons0
        };
    }

    private static BaseWeaponData CurrentWeaponData(ISnapshot snap, PlayerEntityData me)
    {
        PlayerBagData bag = GetBag(snap, me);
        if (bag == null || me == null) return null;
        switch (me.CurrentWeapon)
        {
            case 1: return bag.FirstWeapon;
            case 2: return bag.SecondaryWeapon;
            case 3: return bag.MeleeWeapon;
            case 4:
                if (me.CurrentWeaponIndex == 1) return bag.BombWeapons1;
                if (me.CurrentWeaponIndex == 2) return bag.BombWeapons2;
                return bag.BombWeapons0;
            default: return null;
        }
    }

    private static bool IsMelee(string n)
    {
        if (string.IsNullOrEmpty(n)) return false;
        return n.Contains("dagger") || n.Contains("knife") || n.Contains("bat")
            || n.Contains("axe") || n.Contains("sword") || n.Contains("hammer")
            || n.Contains("blade") || n.Contains("claw") || n.Contains("scythe");
    }

    private static bool IsThrowable(string n)
    {
        if (string.IsNullOrEmpty(n)) return false;
        return n.Contains("grenade") || n.Contains("bomb") || n == "c4";
    }

    private static string PrettyName(string n)
    {
        if (string.IsNullOrEmpty(n)) return "-";
        switch (n)
        {
            case "black_dagger": return "黑刃匕首";
            case "nbr_knife_g": return "尼泊尔军刀-金";
            case "deagle": return "沙漠之鹰";
            case "92fs": return "92FS";
            case "grenade": return "高爆手雷";
            case "ak47": return "AK47";
            case "awp": return "AWP";
        }
        string u = n.ToUpperInvariant();
        u = u.Replace("_", " ");
        return u;
    }

    // ---------------- 准星 ----------------
    private Texture2D _scopeMask;
    private float _scopeAlpha;
    private bool _scopeLogged;

    /// <summary>[OFFLINE-SCOPE] 程序生成的圆形镜筒遮罩：圆心透明、边缘羽化、外部不透明。</summary>
    private Texture2D ScopeMask()
    {
        if (_scopeMask != null) return _scopeMask;
        const int n = 256;
        _scopeMask = new Texture2D(n, n, TextureFormat.RGBA32, false);
        _scopeMask.wrapMode = TextureWrapMode.Clamp;
        float cx = n * 0.5f, cy = n * 0.5f;
        float rOuter = n * 0.5f, rInner = n * 0.42f;
        Color32[] px = new Color32[n * n];
        for (int y = 0; y < n; y++)
        {
            for (int x = 0; x < n; x++)
            {
                float dx = x + 0.5f - cx, dy = y + 0.5f - cy;
                float d = Mathf.Sqrt(dx * dx + dy * dy);
                float a = Mathf.Clamp01((d - rInner) / Mathf.Max(1f, rOuter - rInner));
                px[y * n + x] = new Color32(0, 0, 0, (byte)(a * 255f));
            }
        }
        _scopeMask.SetPixels32(px);
        _scopeMask.Apply();
        return _scopeMask;
    }

    private void DrawScope()
    {
        PlayerEntity pe = (Contexts.sharedInstance.player != null) ? Contexts.sharedInstance.player.myPlayerEntity : null;
        bool scoped = pe != null && pe.hasFov && pe.fov.IsHideFristView;
        _scopeAlpha = Mathf.MoveTowards(_scopeAlpha, scoped ? 1f : 0f, Time.unscaledDeltaTime * 8f);
        if (_scopeAlpha <= 0.01f) return;

        // [OFFLINE-SCOPE] 原版 HUD（Screen Space Overlay Canvas）在本脚本之后的
        // 绘制顺序里，GUI.depth 不提前会被它盖住，镜筒就看不见。
        int oldDepth = GUI.depth;
        GUI.depth = -1000;

        float w = Screen.width, h = Screen.height;
        float side = Mathf.Min(w, h);
        float ox = (w - side) * 0.5f, oy = (h - side) * 0.5f;
        Color black = new Color(0f, 0f, 0f, _scopeAlpha);

        // 宽屏两侧补黑，保证镜筒是正圆不是椭圆
        if (w > side + 1f)
        {
            Rect_(new Rect(0f, 0f, ox, h), black);
            Rect_(new Rect(w - ox, 0f, ox, h), black);
        }
        if (h > side + 1f)
        {
            Rect_(new Rect(0f, 0f, w, oy), black);
            Rect_(new Rect(0f, h - oy, w, oy), black);
        }
        Color old = GUI.color;
        GUI.color = new Color(1f, 1f, 1f, _scopeAlpha);
        GUI.DrawTexture(new Rect(ox, oy, side, side), ScopeMask(), ScaleMode.StretchToFill, true);
        GUI.color = old;

        // 镜内细十字
        float cx = w * 0.5f, cy = h * 0.5f;
        float len = side * 0.30f;
        Color line = new Color(0f, 0f, 0f, 0.85f * _scopeAlpha);
        Rect_(new Rect(cx - len, cy - 0.5f, len * 2f, 1f), line);
        Rect_(new Rect(cx - 0.5f, cy - len, 1f, len * 2f), line);
        GUI.depth = oldDepth;
        if (!_scopeLogged && _scopeAlpha > 0.9f)
        {
            _scopeLogged = true;
            Debug.Log("[OFFLINE-SCOPE] mask drawn side=" + side.ToString("F0") + " screen=" + w.ToString("F0") + "x" + h.ToString("F0"));
        }
    }

    private void DrawCrosshair()
    {
        // 随移动速度扩散：从玩家实体的移动量估算
        float sp = 0f;
        var me = Contexts.sharedInstance.player != null ? Contexts.sharedInstance.player.myPlayerEntity : null;
        if (me != null && me.hasBasicInfo && me.basicInfo.Current != null)
        {
            sp = Mathf.Abs(me.basicInfo.Current.MoveYaw) > 0.01f ? 1f : 0f;
        }
        float target = 6f + sp * 8f;
        _crossSpread = Mathf.Lerp(_crossSpread, target, Time.deltaTime * 8f);

        float cx = Screen.width * 0.5f, cy = Screen.height * 0.5f;
        float len = 8f * _scale, thick = 2f * _scale, gap = _crossSpread * _scale;
        Color c = new Color(0.35f, 1f, 0.45f, 0.95f);

        Rect_(new Rect(cx - gap - len, cy - thick * 0.5f, len, thick), c);   // 左
        Rect_(new Rect(cx + gap, cy - thick * 0.5f, len, thick), c);         // 右
        Rect_(new Rect(cx - thick * 0.5f, cy - gap - len, thick, len), c);   // 上
        Rect_(new Rect(cx - thick * 0.5f, cy + gap, thick, len), c);         // 下
        Rect_(new Rect(cx - 1.5f * _scale, cy - 1.5f * _scale, 3 * _scale, 3 * _scale), c); // 中心点
    }

    // ---------------- 小地图雷达 ----------------
    private void DrawMinimap(ISnapshot snap, PlayerEntityData me)
    {
        float size = 190f * _scale;
        float x = 30f * _scale, y = 30f * _scale;

        // 底板
        Rect_(new Rect(x - 3, y - 3, size + 6, size + 6), new Color(0f, 0f, 0f, 0.8f));
        Rect_(new Rect(x, y, size, size), new Color(0.1f, 0.12f, 0.1f, 0.75f));

        if (_minimap != null)
        {
            // 原图有效内容在左上 1/4，用 uvRect 裁出那部分铺满
            GUI.color = new Color(1f, 1f, 1f, 0.95f);
            GUI.DrawTextureWithTexCoords(new Rect(x, y, size, size), _minimap,
                new Rect(0f, 0.5f, MapUvScale, MapUvScale));
            GUI.color = Color.white;
        }

        if (me == null)
        {
            GUI.Label(new Rect(x, y + size * 0.5f - 10, size, 20), "NO MAP", _txtSmall);
            return;
        }

        // 世界坐标 -> 小地图像素
        Vector2 SelfUV = WorldToMap(me.X, me.Y);   // PlayerEntityData: (X, 水平Z, 高度)

        // 自身朝向扇形
        float yaw = me.ViewYaw;   // 度，SSJJ 约定 0=+X，逆时针
        DrawFovCone(x + SelfUV.x * size, y + (1f - SelfUV.y) * size, yaw, 26f * _scale);

        // 自身点
        DrawDot(x + SelfUV.x * size, y + (1f - SelfUV.y) * size, 4f * _scale,
            new Color(0.4f, 1f, 0.5f, 1f));

        // 其他玩家
        if (snap.PlayerEntityDataDict != null)
        {
            foreach (var kv in snap.PlayerEntityDataDict)
            {
                if (kv.Key == snap.Self) continue;
                var d = kv.Value;
                if (d == null || d.Hp <= 0f) continue;
                Vector2 uv = WorldToMap(d.X, d.Y);
                bool sameTeam = (d.Team == me.Team);
                DrawDot(x + uv.x * size, y + (1f - uv.y) * size, 3.5f * _scale,
                    sameTeam ? new Color(0.4f, 0.75f, 1f, 1f) : new Color(1f, 0.35f, 0.35f, 1f));
            }
        }

        GUI.Label(new Rect(x + 4 * _scale, y + size - 20 * _scale, size, 18 * _scale),
            "MAP" + (OfflineGameController.setting != null ? OfflineGameController.setting.SceneId : 1), _txtSmall);
    }

    /// <summary>
    /// SSJJ (X, 水平Z) -> 小地图归一化 uv（0~1，左下原点）。
    ///
    /// 方位换算：渲染侧 SsjjToUnity(x, z, y) = (-z, y, x)，
    /// 所以俯视图里 Unity 横轴 = -水平Z，纵轴 = X。
    /// 截图（map.png 左上象限）里 u 向右、v 向上，与 Unity 横纵轴一一对应，
    /// 因此 u 取 -水平Z、v 取 X，这样雷达上的朝向扇形才能和第一人称视角一致。
    /// </summary>
    private Vector2 WorldToMap(float x, float z)
    {
        float u = Mathf.InverseLerp(-_mapMaxZ, -_mapMinZ, -z);
        float v = Mathf.InverseLerp(_mapMinX, _mapMaxX, x);
        return new Vector2(Mathf.Clamp01(u), Mathf.Clamp01(v));
    }

    private void DrawDot(float cx, float cy, float r, Color c)
    {
        Rect_(new Rect(cx - r, cy - r, r * 2, r * 2), c);
    }

    /// <summary>朝向扇形：用短线段拼出 60° 视野锥。</summary>
    private void DrawFovCone(float cx, float cy, float yawDeg, float len)
    {
        Color c = new Color(1f, 1f, 1f, 0.22f);
        const int steps = 10;
        float half = 30f;
        Vector2 prev = Vector2.zero;
        for (int i = 0; i <= steps; i++)
        {
            float a = (yawDeg - half) + (2f * half) * i / steps;
            float rad = a * Mathf.Deg2Rad;
            // 小地图 y 轴向下，而世界水平 Z 向上 -> 取负
            Vector2 p = new Vector2(Mathf.Cos(rad) * len, -Mathf.Sin(rad) * len);
            if (i > 0)
            {
                float dx = p.x - prev.x, dy = p.y - prev.y;
                float l = Mathf.Sqrt(dx * dx + dy * dy);
                if (l > 0.01f)
                {
                    float ang = Mathf.Atan2(dy, dx) * Mathf.Rad2Deg;
                    Matrix4x4 m = GUI.matrix;
                    GUIUtility.RotateAroundPivot(ang, new Vector2(cx + prev.x, cy + prev.y));
                    Rect_(new Rect(cx + prev.x, cy + prev.y - 1f, l, 2f), c);
                    GUI.matrix = m;
                }
            }
            prev = p;
        }
    }

    // ---------------- 战绩面板 ----------------
    private void DrawScoreboard(OfflineGameplay gp)
    {
        if (gp == null) return;
        bool hasBombStatus = !string.IsNullOrEmpty(gp.BombStatusText);
        float w = 220f * _scale, h = (hasBombStatus ? 124f : 96f) * _scale;
        float x = Screen.width - w - 30f * _scale, y = 30f * _scale;

        Rect_(new Rect(x - 2, y - 2, w + 4, h + 4), new Color(0f, 0f, 0f, 0.75f));
        Rect_(new Rect(x, y, w, h), new Color(0.08f, 0.09f, 0.11f, 0.8f));

        GUI.Label(new Rect(x + 10 * _scale, y + 6 * _scale, w, 24 * _scale), "战绩", _txtMid);
        GUI.Label(new Rect(x + 10 * _scale, y + 34 * _scale, w * 0.6f, 22 * _scale),
            "击杀", _txtSmall);
        GUI.Label(new Rect(x + 10 * _scale, y + 54 * _scale, w * 0.6f, 22 * _scale),
            "死亡", _txtSmall);
        GUI.Label(new Rect(x + 10 * _scale, y + 72 * _scale, w * 0.6f, 22 * _scale),
            "时间", _txtSmall);

        GUIStyle right = new GUIStyle(_txtMid) { alignment = TextAnchor.MiddleRight };
        GUI.Label(new Rect(x, y + 32 * _scale, w - 12 * _scale, 22 * _scale),
            gp.PlayerKills.ToString(), right);
        GUI.Label(new Rect(x, y + 52 * _scale, w - 12 * _scale, 22 * _scale),
            gp.PlayerDeaths.ToString(), right);

        int sec = Mathf.Max(0, Mathf.CeilToInt(gp.RoundSeconds - 0));
        float remain = Mathf.Max(0f, gp.RemainingSeconds);
        int r = Mathf.CeilToInt(remain);
        GUI.Label(new Rect(x, y + 70 * _scale, w - 12 * _scale, 22 * _scale),
            (r / 60) + ":" + (r % 60).ToString("00"), right);
        if (hasBombStatus)
        {
            GUI.Label(new Rect(x + 10 * _scale, y + 96 * _scale, w - 18 * _scale, 22 * _scale),
                gp.BombStatusText, _txtSmall);
        }
    }

    private void DrawRoundOver(OfflineGameplay gp)
    {
        GUIStyle big = new GUIStyle(_txtBig);
        big.fontSize = Mathf.RoundToInt(56 * _scale);
        big.alignment = TextAnchor.MiddleCenter;
        Rect_(new Rect(0, Screen.height * 0.5f - 70 * _scale, Screen.width, 140 * _scale),
            new Color(0f, 0f, 0f, 0.55f));
        GUI.Label(new Rect(0, Screen.height * 0.5f - 50 * _scale, Screen.width, 100 * _scale),
            gp.RoundResult + "   " + gp.PlayerKills + " : " + gp.BotKills, big);
    }
}
