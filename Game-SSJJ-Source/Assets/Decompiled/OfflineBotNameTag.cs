using NetData;
using UnityEngine;

/// <summary>
/// 离线 Bot 的世界空间姓名牌 / 血条。
/// [OFFLINE-FIX] 旧实现两个硬伤：
///   1) 挂点 localPosition.y = 200（Unity 单位=米），名牌飘在 200 米高空，永远看不见；
///   2) TextMesh 用内置 Arial，中文直接渲染成空白。
/// 现在改为每帧跟随父级 Renderer 包围盒顶部（不论父级 scale 是米还是厘米都正确），
/// 并用系统字体动态创建中文字形。
///
/// [OFFLINE-AI6] 按 botQuality 分级显示（对齐原版 HPBarMonter / PlayerDrawMapImageSystem）：
///   quality 0    普通：队友绿名
///   quality 1-2  精英：橙名 + 橙血条
///   quality >=3  首领：红名 + 红血条（更宽）
/// 敌人一律不显示名字（防透视）；大头人机(2019) 按原版 BigHeadGameRule.IsShowEnemyHpBar
/// 只显示血条不显示名字。
/// </summary>
public sealed class OfflineBotNameTag : MonoBehaviour
{
    private TextMesh _text;
    private Camera _camera;
    private bool _ally = true;
    private string _label = "";
    private float _nextResolve;

    private int _botId = -1;
    private int _quality;
    private int _lv;
    private float _hpRatio = 1f;
    private bool _showHp = true;

    private Transform _barBg;
    private Transform _barFg;
    private float _barWidth = 1.3f;

    private static Font s_cjkFont;
    private static bool s_fontTried;
    private static Mesh s_quadMesh;

    private static readonly Color AllyColor = Color.green;     // 原版队友绿字
    private static readonly Color EnemyColor = new Color(0.95f, 0.28f, 0.24f);    // 敌人红
    private static readonly Color EliteColor = new Color(1.00f, 0.55f, 0.10f);    // 精英橙
    private static readonly Color BossColor = new Color(0.95f, 0.18f, 0.18f);     // 首领红
    private static readonly Color BarBgColor = new Color(0.08f, 0.08f, 0.10f);    // 血条底

    public string Label
    {
        get { return _label; }
        set
        {
            value = value ?? string.Empty;
            if (_label == value) return;
            _label = value;
            if (_text != null) _text.text = value;
        }
    }

    public void SetAlly(bool ally)
    {
        if (_ally == ally) return;
        _ally = ally;
        ApplyColor();
    }

    /// <summary>设置 bot 身份（质量/Lv/实体 id），血条据此分级并每帧刷新。</summary>
    public void SetBotInfo(int botId, int quality, int lv, bool showHp)
    {
        _botId = botId;
        _quality = quality;
        _lv = lv;
        _showHp = showHp;
        ApplyColor();
        EnsureBar();
        if (_barBg != null) _barBg.gameObject.SetActive(showHp);
        if (_barFg != null) _barFg.gameObject.SetActive(showHp);
    }

    private Color TagColor()
    {
        if (_quality >= 3) return BossColor;
        if (_quality >= 1) return EliteColor;
        return _ally ? AllyColor : EnemyColor;
    }

    private Color BarColor()
    {
        if (_quality >= 3) return BossColor;
        if (_quality >= 1) return EliteColor;
        return _ally ? Color.green : EnemyColor;
    }

    private void ApplyColor()
    {
        if (_text != null) _text.color = TagColor();
    }

    private static Font GetCjkFont()
    {
        if (s_fontTried) return s_cjkFont;
        s_fontTried = true;
        string[] names = { "Microsoft YaHei", "微软雅黑", "SimHei", "黑体", "SimSun", "宋体", "Arial Unicode MS" };
        for (int i = 0; i < names.Length; i++)
        {
            try
            {
                Font f = Font.CreateDynamicFontFromOSFont(names[i], 48);
                if (f != null) { s_cjkFont = f; return f; }
            }
            catch (System.Exception) { }
        }
        return null;
    }

    private static Mesh QuadMesh()
    {
        if (s_quadMesh != null) return s_quadMesh;
        Mesh m = new Mesh();
        m.vertices = new Vector3[]
        {
            new Vector3(-0.5f, -0.5f, 0f), new Vector3(0.5f, -0.5f, 0f),
            new Vector3(-0.5f, 0.5f, 0f), new Vector3(0.5f, 0.5f, 0f)
        };
        m.uv = new Vector2[] { new Vector2(0f, 0f), new Vector2(1f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f) };
        m.triangles = new int[] { 0, 1, 2, 1, 3, 2 };
        m.RecalculateNormals();
        m.RecalculateBounds();
        s_quadMesh = m;
        return m;
    }

    private static Material NewSolid(Color c)
    {
        Shader sh = Shader.Find("Sprites/Default");
        if (sh == null) return null;
        Material mat = new Material(sh);
        mat.color = c;
        return mat;
    }

    private void Awake()
    {
        _text = gameObject.GetComponent<TextMesh>();
        if (_text == null) _text = gameObject.AddComponent<TextMesh>();
        _text.anchor = TextAnchor.LowerCenter;
        _text.alignment = TextAlignment.Center;
        _text.fontSize = 48;
        _text.characterSize = 0.10f;
        _text.fontStyle = FontStyle.Bold;
        _text.richText = false;
        _text.color = TagColor();

        Font cjk = GetCjkFont();
        if (cjk != null) _text.font = cjk;

        MeshRenderer mr = _text.GetComponent<MeshRenderer>();
        if (mr != null) mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        _text.text = _label;

        EnsureBar();
    }

    /// <summary>血条：背景条 + 前景条（左锚定，按 HP 比例缩放）。</summary>
    private void EnsureBar()
    {
        if (_barBg != null) return;
        Mesh quad = QuadMesh();

        GameObject bg = new GameObject("HpBg");
        bg.transform.SetParent(transform, false);
        bg.transform.localPosition = new Vector3(0f, 0.44f, 0f);
        bg.transform.localScale = new Vector3(_barWidth, 0.09f, 1f);
        var bgMr = bg.AddComponent<MeshRenderer>();
        var bgMf = bg.AddComponent<MeshFilter>();
        bgMf.sharedMesh = quad;
        Material bgMat = NewSolid(BarBgColor);
        if (bgMat != null) bgMr.sharedMaterial = bgMat;
        bgMr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        _barBg = bg.transform;

        GameObject fg = new GameObject("HpFg");
        fg.transform.SetParent(transform, false);
        fg.transform.localPosition = new Vector3(0f, 0.44f, 0.002f);
        fg.transform.localScale = new Vector3(_barWidth - 0.04f, 0.05f, 1f);
        var fgMr = fg.AddComponent<MeshRenderer>();
        var fgMf = fg.AddComponent<MeshFilter>();
        fgMf.sharedMesh = quad;
        Material fgMat = NewSolid(BarColor());
        if (fgMat != null) fgMr.sharedMaterial = fgMat;
        fgMr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        _barFg = fg.transform;

        if (!_showHp)
        {
            bg.SetActive(false);
            fg.SetActive(false);
        }
    }

    private void ApplyBar()
    {
        if (_barFg == null) return;
        float w = _barWidth - 0.04f;
        float r = Mathf.Clamp01(_hpRatio);
        _barFg.localScale = new Vector3(Mathf.Max(0.0001f, w * r), 0.05f, 1f);
        _barFg.localPosition = new Vector3(-(w * (1f - r)) * 0.5f, 0.44f, 0.002f);
        MeshRenderer mr = _barFg.GetComponent<MeshRenderer>();
        if (mr != null && mr.sharedMaterial != null) mr.sharedMaterial.color = BarColor();
    }

    /// <summary>从快照读实时血量（每帧一次字典查询，成本可忽略）。</summary>
    private void RefreshHp()
    {
        if (_botId < 0 || !_showHp) return;
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null || !ctx.snapshot.hasSnapshots) return;
            var snap = ctx.snapshot.snapshots.LatestSnapshot;
            if (snap == null || snap.PlayerEntityDataDict == null) return;
            PlayerEntityData d;
            if (!snap.PlayerEntityDataDict.TryGetValue(_botId, out d) || d == null) return;
            float mx = d.MaxHp > 0f ? d.MaxHp : 100f;
            float r = Mathf.Clamp01(d.Hp / mx);
            if (Mathf.Abs(r - _hpRatio) > 0.002f)
            {
                _hpRatio = r;
                ApplyBar();
            }
        }
        catch (System.Exception) { }
    }

    private void LateUpdate()
    {
        if (_text == null) return;
        if (_camera == null || !_camera.isActiveAndEnabled) _camera = Camera.main;
        if (_camera == null) return;

        RefreshHp();

        // 跟随父级渲染体顶部：父级无论是米制还是厘米制都正确。
        if (Time.realtimeSinceStartup >= _nextResolve)
        {
            _nextResolve = Time.realtimeSinceStartup + 0.5f;
            Transform parent = transform.parent;
            if (parent != null)
            {
                Renderer[] rs = parent.GetComponentsInChildren<Renderer>(true);
                Renderer body = null;
                float best = float.MaxValue;
                for (int i = 0; i < rs.Length; i++)
                {
                    if (rs[i] == null || rs[i] is MeshRenderer == false) continue;
                    if (rs[i].transform == transform) continue;
                    float h = rs[i].bounds.size.y;
                    if (h < 50f || h > 3000f) continue;
                    float d = (rs[i].bounds.center - parent.position).sqrMagnitude;
                    if (d < best) { best = d; body = rs[i]; }
                }
                if (body != null)
                {
                    Transform head = FindChild(parent, "Bip01_Head");
                    if (head == null) head = FindChild(parent, "Head");
                    if (head != null)
                    {
                        // 游戏世界使用原始厘米坐标；头顶偏移约 12cm，避免名字漂在身体上方。
                        transform.position = head.position + Vector3.up * 12f;
                    }
                    else
                    {
                        Bounds b = body.bounds;
                        transform.position = new Vector3(b.center.x, b.max.y + Mathf.Max(8f, b.size.y * 0.045f), b.center.z);
                    }
                }
            }
        }

        transform.rotation = Quaternion.LookRotation(transform.position - _camera.transform.position, Vector3.up);

        // 队友 35m 内可见；敌人 22m 内可见（原版敌人名牌显示距离更近）。
        // 注意：可见性必须切 MeshRenderer.enabled，不能 SetActive 自身 —— 自身一旦失活，
        // LateUpdate 就不再执行，名牌会永久消失。
        float dist = Vector3.Distance(transform.position, _camera.transform.position);
        bool visible = dist <= (_ally ? 35f : 22f);
        MeshRenderer mr = _text.GetComponent<MeshRenderer>();
        if (mr != null && mr.enabled != visible) mr.enabled = visible;
        if (_barBg != null)
        {
            MeshRenderer bmr = _barBg.GetComponent<MeshRenderer>();
            if (bmr != null && bmr.enabled != (visible && _showHp)) bmr.enabled = visible && _showHp;
        }
        if (_barFg != null)
        {
            MeshRenderer fmr = _barFg.GetComponent<MeshRenderer>();
            if (fmr != null && fmr.enabled != (visible && _showHp)) fmr.enabled = visible && _showHp;
        }
    }

    private static Transform FindChild(Transform root, string name)
    {
        if (root == null) return null;
        if (root.name == name) return root;
        for (int i = 0; i < root.childCount; i++)
        {
            Transform found = FindChild(root.GetChild(i), name);
            if (found != null) return found;
        }
        return null;
    }
}

