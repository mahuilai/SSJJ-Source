using System;
using UnityEngine;

/// <summary>
/// [OFFLINE-GRENADE] 破片/闪光/烟雾的表现层。
/// 原版：爆炸粒子在 effectprefab/explosion，闪光在 uiprefabs/common/flashexplosion，
/// 烟雾是服务端 SceneBuff 下发的 scenebuff_smoke_area 粒子。
/// 离线端不依赖这些包（部分未安装），用等价的程序化表现还原：
///   - 破片：橙色膨胀球 + 点光
///   - 闪光：白球 + 全屏白屏（距离/视线/朝向按原版 FlashExplosionModel 公式）
///   - 烟雾：灰色粒子云，15 秒
/// 视觉参数对齐原版手感，资源名与数据来源见 OfflineGameplay.ThrowGrenade / UpdateGrenades。
/// </summary>
public sealed class OfflineGrenadeFx : MonoBehaviour
{
    public static OfflineGrenadeFx Instance;

    private float _flashUntil;
    private float _flashDuration;
    private static Texture2D _white;
    private static Texture2D _soft;

    private void Awake()
    {
        Instance = this;
    }

    private void OnDestroy()
    {
        if (Instance == this) Instance = null;
    }

    private void OnGUI()
    {
        if (Time.time >= _flashUntil) return;
        float remain = Mathf.Max(0f, _flashUntil - Time.time);
        float alpha = Mathf.Clamp01(remain / Mathf.Max(0.05f, _flashDuration));
        if (_white == null)
        {
            _white = new Texture2D(1, 1, TextureFormat.RGBA32, false);
            _white.SetPixel(0, 0, Color.white);
            _white.Apply();
        }
        Color old = GUI.color;
        GUI.color = new Color(1f, 1f, 1f, alpha);
        GUI.DrawTexture(new Rect(0f, 0f, Screen.width, Screen.height), _white);
        GUI.color = old;
    }

    /// <summary>破片/闪光爆炸的可见表现（0=破片 1=闪光 2=烟雾）。</summary>
    public static void Explosion(Vector3 pos, int kind)
    {
        try
        {
            Color color = kind == 1
                ? new Color(1f, 1f, 0.86f)
                : (kind == 2 ? new Color(0.88f, 0.88f, 0.92f) : new Color(1f, 0.55f, 0.15f));
            GameObject go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.name = "OfflineGrenadeFx";
            Collider col = go.GetComponent<Collider>();
            if (col != null) UnityEngine.Object.Destroy(col);
            go.transform.position = pos;
            go.transform.localScale = Vector3.one * 0.2f;
            Renderer r = go.GetComponent<Renderer>();
            if (r != null)
            {
                Shader sh = Shader.Find("Sprites/Default");
                if (sh != null)
                {
                    Material m = new Material(sh);
                    m.color = color;
                    r.material = m;
                }
            }
            Pulse pulse = go.AddComponent<Pulse>();
            pulse.Life = kind == 1 ? 0.3f : 0.45f;
            pulse.From = 0.2f;
            pulse.To = kind == 1 ? 9f : 7f;
            pulse.BaseColor = color;
            Light light = go.AddComponent<Light>();
            light.type = LightType.Point;
            light.range = kind == 1 ? 18f : 12f;
            light.intensity = kind == 1 ? 6f : 4f;
            light.color = color;
            UnityEngine.Object.Destroy(light, 0.25f);
        }
        catch (Exception) { }
    }

    /// <summary>烟雾弹：灰色粒子云，约 15 秒（原版服务端 SceneBuff 的 smoke_area 等效表现）。</summary>
    public static void Smoke(Vector3 pos)
    {
        try
        {
            GameObject go = new GameObject("OfflineSmoke");
            go.transform.position = pos + Vector3.up * 0.6f;
            ParticleSystem ps = go.AddComponent<ParticleSystem>();
            ParticleSystem.MainModule main = ps.main;
            main.duration = 1f;
            main.loop = false;
            main.startLifetime = 13f;
            main.startSpeed = 1.6f;
            main.startSize = 8f;
            main.startColor = new Color(0.78f, 0.78f, 0.8f, 0.55f);
            main.maxParticles = 200;
            main.simulationSpace = ParticleSystemSimulationSpace.World;
            ParticleSystem.EmissionModule em = ps.emission;
            em.rateOverTime = 0f;
            em.SetBursts(new ParticleSystem.Burst[]
            {
                new ParticleSystem.Burst(0f, 90),
                new ParticleSystem.Burst(0.4f, 60)
            });
            ParticleSystem.ShapeModule shape = ps.shape;
            shape.shapeType = ParticleSystemShapeType.Sphere;
            shape.radius = 3.2f;
            ParticleSystem.ColorOverLifetimeModule col = ps.colorOverLifetime;
            col.enabled = true;
            Gradient grad = new Gradient();
            grad.SetKeys(
                new GradientColorKey[] { new GradientColorKey(Color.white, 0f), new GradientColorKey(Color.white, 1f) },
                new GradientAlphaKey[] { new GradientAlphaKey(0f, 0f), new GradientAlphaKey(0.65f, 0.15f), new GradientAlphaKey(0.5f, 0.7f), new GradientAlphaKey(0f, 1f) });
            col.color = new ParticleSystem.MinMaxGradient(grad);
            ParticleSystemRenderer rend = go.GetComponent<ParticleSystemRenderer>();
            Shader sh = Shader.Find("Sprites/Default");
            if (sh != null)
            {
                Material m = new Material(sh);
                m.mainTexture = SoftCircle();
                rend.material = m;
            }
            rend.renderMode = ParticleSystemRenderMode.Billboard;
            ps.Play();
            UnityEngine.Object.Destroy(go, 15f);
        }
        catch (Exception) { }
    }

    /// <summary>闪光弹致盲：距离/朝向/视线判定 + 衰减，对齐原版 FlashExplosionModel 的公式。</summary>
    public static void TriggerFlash(Vector3 pos)
    {
        if (Instance == null) return;
        try
        {
            Camera eye = FindEye();
            if (eye == null) return;
            Vector3 eyeU = eye.transform.position;
            Vector3 eyeRaw = eyeU * 100f;
            Vector3 posRaw = pos * 100f;
            float d = Vector3.Distance(eyeRaw, posRaw);
            if (d > 4000f) return;
            Vector3 dir = pos - eyeU;
            if (dir.sqrMagnitude < 0.01f) dir = eye.transform.forward;
            if (Vector3.Dot(eye.transform.forward, dir.normalized) <= 0f) return;
            if (!OfflineBotPhysics.CanSee(eyeRaw, posRaw)) return;
            float durMs = (d <= 2000f)
                ? 3000f * Mathf.Pow(0.5f, d / 2000f)
                : 500f * Mathf.Pow(0.5f, d / 2000f);
            durMs = Mathf.Clamp(durMs, 150f, 3000f);
            Instance._flashDuration = durMs / 1000f;
            Instance._flashUntil = Time.time + Instance._flashDuration;
            UnityEngine.Debug.Log("[OFFLINE-GRENADE] flash d=" + d.ToString("F0") + " dur=" + durMs.ToString("F0"));
        }
        catch (Exception) { }
    }

    private static Camera FindEye()
    {
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") return cams[i];
        }
        return Camera.main;
    }

    private static Texture2D SoftCircle()
    {
        if (_soft != null) return _soft;
        const int n = 64;
        _soft = new Texture2D(n, n, TextureFormat.RGBA32, false);
        float c = (n - 1) * 0.5f;
        for (int y = 0; y < n; y++)
        {
            for (int x = 0; x < n; x++)
            {
                float dx = (x - c) / c;
                float dy = (y - c) / c;
                float a = Mathf.Clamp01(1f - Mathf.Sqrt(dx * dx + dy * dy));
                _soft.SetPixel(x, y, new Color(1f, 1f, 1f, a * a));
            }
        }
        _soft.Apply();
        return _soft;
    }

    private sealed class Pulse : MonoBehaviour
    {
        public float Life = 0.45f;
        public float From = 0.2f;
        public float To = 7f;
        public Color BaseColor = Color.white;
        private float _t;
        private Material _m;

        private void Start()
        {
            Renderer r = GetComponent<Renderer>();
            if (r != null) _m = r.material;
        }

        private void Update()
        {
            _t += Time.deltaTime;
            float k = Mathf.Clamp01(_t / Mathf.Max(0.05f, Life));
            transform.localScale = Vector3.one * Mathf.Lerp(From, To, k);
            if (_m != null)
            {
                Color c = BaseColor;
                c.a = 1f - k;
                _m.color = c;
            }
            if (k >= 1f) UnityEngine.Object.Destroy(gameObject);
        }
    }
}
