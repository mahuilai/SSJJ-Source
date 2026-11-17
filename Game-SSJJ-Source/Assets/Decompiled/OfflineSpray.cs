using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Assets.Sources.Utils;
using NetData;
using share;
using SSJJAsset.Asset;
using SSJJBase.Thread;
using SSJJSceneLoader;
using UnityEngine;

/// <summary>
/// 可选的喷漆配置（启动目录下的 offline_spray.json，与 offline_flags.json 同级）。
/// 单独一个文件而不是改 OfflineGameSetting：那个文件由别人拥有，且喷漆只影响本系统。
/// </summary>
[Serializable]
public class OfflineSprayConfig
{
    public int[] ids;       // 可用喷漆 id（= spray/<id> 的 bundle 名与 prefab 名）
    public float cooldown;  // 冷却秒数
    public float life;      // 存留秒数（原版服务器 30~60s 后下发 IsAdd=false）
    public int max;         // 同时存在上限，超出滚动淘汰最旧的
}

/// <summary>
/// 离线喷漆：尽量走原版渲染链路，只把“服务器下发”换成本地构造。
///
/// 已核实原版链路：
///   APC 37 / AddEventHandler.Handle
///     → SceneObjectFactory.CraeteSpary(SprayEventEntityData)
///       → Marks.CraeteMark(mesh, SceneClipMap, WorldHelp, yaw, origin, normal, 90, "SPRAY_MARKFRAGMENT")
///         用 BSP 把 90cm 方片裁剪成真正贴墙的世界坐标 Mesh（格子被墙角切掉，不悬空不穿透）
///       → sceneObject 实体 AddSpary(data, mesh) + AddLoadSparyResource(ResourceUtility.GetSparyRequest(id))
///     → CommonResourceLoadSystem 载入 spray/&lt;id&gt; 里的 prefab（贴图/材质都在 prefab 上）
///     → SparyResourceInitSystem 把 Mesh 塞进 SparyTextures，SparyTextures.Update 每帧刷 _MainTex
///   实体销毁由 CommonEntityLifeTimeSystem（LifeTime 组件）+ CommonResourceDestroySystem 负责。
///
/// 这里复用：Marks / ResourceUtility.GetSparyRequest / LoadSparyResource 组件 +
/// SparyResourceInitSystem / sceneObject 上下文生命周期。重新实现的只有
/// SceneObjectFactory.CraeteSpary 的 4 行外壳：它的 GetSceneClipMap 是私有方法，
/// 而且它不返回实体引用，拿不到实体就没法做 30 秒生命周期与滚动淘汰。
/// </summary>
public static class OfflineSpray
{
    // 与 tools/install_spray_assets.py 的 DEFAULT_SPRAY_IDS 保持一致
    private static readonly int[] DefaultIds = { 2, 10, 51, 100 };

    private const float DefaultCooldown = 5f;    // 原版喷漆有 CD
    private const float DefaultLife = 30f;
    private const int DefaultMax = 12;
    private const float MaxDistanceMeters = 8f;  // 5~10m 之间
    private const int MarkRadius = 90;           // 原版 CraeteMark 半径（BSP 厘米 = 0.9m）

    private static readonly Marks _marks = new Marks();
    private static readonly List<LiveSpray> _live = new List<LiveSpray>();

    private static int[] _ids = DefaultIds;
    private static int _cursor;
    private static int _nextId = 900000;         // 本地喷漆 id，避开玩家/bot 的 id 段
    private static float _nextAt;
    private static float _cooldown = DefaultCooldown;
    private static float _life = DefaultLife;
    private static int _maxAlive = DefaultMax;
    private static bool _inited;

    private sealed class LiveSpray
    {
        public SceneObjectEntity Entity;
        public int ResId;
    }

    /// <summary>启动时调用一次：读配置、过滤掉没装 bundle 的 id。</summary>
    public static void Initialize()
    {
        if (_inited) return;
        _inited = true;
        LoadConfig();

        List<int> ok = new List<int>();
        for (int i = 0; i < _ids.Length; i++)
        {
            if (OfflineBundleLocator.IsLocalBundleAvailable("spray/" + _ids[i])) ok.Add(_ids[i]);
            else Debug.LogWarning("[OFFLINE-SPRAY] bundle missing spray/" + _ids[i]
                + " (run Game-SSJJ/tools/install_spray_assets.py)");
        }
        if (ok.Count > 0) _ids = ok.ToArray();

        string list = "";
        for (int i = 0; i < _ids.Length; i++) list += (i > 0 ? "," : "") + _ids[i];
        Debug.Log("[OFFLINE-SPRAY] init ids=" + list + " cooldown=" + _cooldown.ToString("F1")
            + " life=" + _life.ToString("F0") + " max=" + _maxAlive);
    }

    /// <summary>按 T 调用；rotate=Shift+T 轮换图案。</summary>
    public static void TrySpray(bool rotate)
    {
        Initialize();
        float now = Time.time;

        if (rotate && _ids.Length > 1)
        {
            _cursor = (_cursor + 1) % _ids.Length;
            Debug.Log("[OFFLINE-SPRAY] select id=" + _ids[_cursor]);
        }
        if (now < _nextAt)
        {
            Skip("cooldown remain=" + (_nextAt - now).ToString("F1"));
            return;
        }

        Camera cam = Eye();
        if (cam == null) { Skip("no-camera"); return; }

        int id = (_ids.Length > 0) ? _ids[Mathf.Clamp(_cursor, 0, _ids.Length - 1)] : 0;
        if (id <= 0) { Skip("no-resource"); return; }
        if (!OfflineBundleLocator.IsLocalBundleAvailable("spray/" + id)) { Skip("no-bundle id=" + id); return; }
        // 每个喷漆包都依赖 spray/materials（材质 + shader 引用），缺了会白模
        if (!OfflineBundleLocator.IsLocalBundleAvailable("spray/materials")) { Skip("no-bundle spray/materials"); return; }

        // Eye 相机就在 BSP 厘米空间（实测 (-5194,249,1889)），所以射线/结果直接用，不用换算
        Vector3 from = cam.transform.position;
        Vector3 fwd = cam.transform.forward;
        Vector3 end, normal; float frac;
        // 用原版 BSP WorldTrace：场景里没有 MeshCollider（地图是 BSP 渲染网格），
        // 而且这条划线与玩家移动/子弹判定同一套几何，命中面就是真实的墙面/地面。
        bool traced = OfflineBotPhysics.Cast(from, from + fwd * (MaxDistanceMeters * 100f),
            0f, 0f, out end, out normal, out frac);
        if (!traced) { Skip("no-bsp"); return; }
        if (frac >= 0.99f) { Skip("no-hit"); return; }                 // 打天空 / 超出 8m

        float dist = (end - from).magnitude / 100f;
        if (dist < 0.35f) { Skip("too-close dist=" + dist.ToString("F2")); return; }
        if (normal.sqrMagnitude < 0.01f) { Skip("no-normal"); return; }
        if (Vector3.Dot(normal, fwd) > 0f) normal = -normal;           // 法线必须朝向玩家

        _nextAt = now + _cooldown;

        // Unity(厘米) -> SSJJ 原始三元组 (X, 水平, 高度)：X=z, 水平=-x, 高度=y
        SprayEventEntityData data = new SprayEventEntityData();
        data.Id = _nextId++;
        data.ResTypeID = id;
        data.IsAdd = true;
        data.PlayerName = PlayerName();
        data.X = end.z;
        data.Y = -end.x;
        data.Z = end.y;
        data.NormalX = normal.z;
        data.NormalY = -normal.x;
        data.NormalZ = normal.y;
        data.Yaw = cam.transform.eulerAngles.y;

        SceneClipMap mp;
        WorldHelp wh;
        GetSceneClip(out mp, out wh);

        // Marks.CraeteMark 内部用线程池裁剪，必须走协程（原版同样用 StartCoRoutine）
        BaseAsyncManager.Instance.StartCoRoutine(Spawn(data, mp, wh, dist));
    }

    /// <summary>每帧调用：清掉已被生命周期系统销毁的引用（Time 到点由原版 LifeTime 负责）。</summary>
    public static void Tick()
    {
        for (int i = _live.Count - 1; i >= 0; i--)
        {
            bool gone = false;
            try { gone = _live[i].Entity == null || !_live[i].Entity.hasSpary; }
            catch (Exception) { gone = true; }
            if (gone) _live.RemoveAt(i);
        }
    }

    private static IEnumerator Spawn(SprayEventEntityData data, SceneClipMap mp, WorldHelp wh, float dist)
    {
        Mesh mesh = new Mesh();
        bool clipped = false;

        // 原版路径：BSP 裁剪（结果为空说明命中面不是可画表面，下面退回方片）。
        // 只对 BSP 地图走裁剪：Marks 内部是线程池回调，非 BSP 地图抛异常会直接崩进程，
        // 这种情况退自绘方片更安全。
        if (mp is BspClipMap && wh != null)
        {
            yield return _marks.CraeteMark(mesh, mp, wh, data.Yaw,
                new Vector3D(data.X, data.Y, data.Z),
                new Vector3D(data.NormalX, data.NormalY, data.NormalZ),
                MarkRadius, "SPRAY_MARKFRAGMENT");
            clipped = mesh.vertexCount >= 3 && mesh.triangles != null && mesh.triangles.Length >= 3;
        }
        if (!clipped) BuildQuad(mesh, data);
        if (mesh.vertexCount < 3) { Skip("clip-empty id=" + data.ResTypeID); yield break; }

        try
        {
            SceneObjectEntity ent = CreateEntity(data, mesh);
            _live.Add(new LiveSpray { Entity = ent, ResId = data.ResTypeID });
            while (_live.Count > _maxAlive)
            {
                Kill(_live[0].Entity);   // 滚动淘汰最旧的
                _live.RemoveAt(0);
            }
            Debug.Log("[OFFLINE-SPRAY] enabled id=" + data.ResTypeID
                + " pos=(" + data.X.ToString("F1") + "," + data.Y.ToString("F1") + "," + data.Z.ToString("F1") + ")"
                + " normal=(" + data.NormalX.ToString("F2") + "," + data.NormalY.ToString("F2") + "," + data.NormalZ.ToString("F2") + ")"
                + " dist=" + dist.ToString("F2"));
        }
        catch (Exception ex)
        {
            Skip("entity " + ex.Message);
        }
    }

    /// <summary>照抄 SceneObjectFactory.CraeteSpary 的实体部分，资源加载/绑定/销毁全部交回原版系统。</summary>
    private static SceneObjectEntity CreateEntity(SprayEventEntityData data, Mesh mesh)
    {
        SceneObjectContext ctx = Contexts.sharedInstance.sceneObject;
        SceneObjectEntity ent = ctx.CreateEntity();
        ent.AddEntityId(data.Id);
        ent.AddSpary(data, mesh);
        // 原版资源声明：bundle spray/<id> 里的 <id>.prefab（贴图、材质都在里面）
        ent.AddLoadSparyResource(new LoadRequests(ResourceUtility.GetSparyRequest(data.ResTypeID)), data.Id);
        // 原版生命周期组件：CommonEntityLifeTimeSystem 到点自动置 isDestroy，不用自己计时
        ent.AddLifeTime(DateTime.Now, Mathf.RoundToInt(_life * 1000f));
        return ent;
    }

    /// <summary>拿地图 BSP 裁剪数据。和 SceneObjectFactory.GetSceneClipMap 同源（mapUnityObjects → ISceneRender）。</summary>
    private static void GetSceneClip(out SceneClipMap mp, out WorldHelp wh)
    {
        mp = null;
        wh = null;
        try
        {
            SceneObjectEntity map = Contexts.sharedInstance.sceneObject.sceneMapEntity;
            if (map == null || !map.hasMapUnityObjects || map.mapUnityObjects.MapObject == null) return;
            ISceneRender sr = map.mapUnityObjects.MapObject.GetComponentInChildren<ISceneRender>(true);
            if (sr == null) sr = map.mapUnityObjects.MapObject.GetComponent<ISceneRender>();
            if (sr == null) return;
            mp = sr.GetSceneClipMap();
            wh = sr.GetWorldHelp();
        }
        catch (Exception ex)
        {
            Debug.LogWarning("[OFFLINE-SPRAY] scene clip unavailable " + ex.Message);
        }
    }

    /// <summary>
    /// 兜底：BSP 裁剪不可用时按法线自己贴一个 90cm 方片。
    /// 顶点同样是 BSP 厘米空间，因为喷漆 prefab 的变换是单位阵。
    /// </summary>
    private static void BuildQuad(Mesh mesh, SprayEventEntityData data)
    {
        Vector3 center = new Vector3(-data.Y, data.Z, data.X);
        Vector3 n = new Vector3(-data.NormalY, data.NormalZ, data.NormalX);
        if (n.sqrMagnitude < 0.5f) return;
        n = n.normalized;
        center += n * 2f;   // 抬离墙面 2cm，避免和墙抢深度

        Vector3 helper = (Mathf.Abs(n.y) > 0.95f) ? Vector3.forward : Vector3.up;
        Vector3 right = Vector3.Cross(helper, n).normalized;
        Vector3 up = Vector3.Cross(n, right).normalized;
        float r = MarkRadius;

        mesh.Clear();
        mesh.vertices = new Vector3[]
        {
            center - right * r - up * r,
            center + right * r - up * r,
            center + right * r + up * r,
            center - right * r + up * r,
        };
        mesh.uv = new Vector2[]
        {
            new Vector2(0f, 0f), new Vector2(1f, 0f), new Vector2(1f, 1f), new Vector2(0f, 1f),
        };
        // 三角形朝向必须和法线一致，否则背面剔除后看不见
        Vector3 face = Vector3.Cross(mesh.vertices[1] - mesh.vertices[0], mesh.vertices[2] - mesh.vertices[0]);
        mesh.triangles = (Vector3.Dot(face, n) >= 0f)
            ? new int[] { 0, 1, 2, 0, 2, 3 }
            : new int[] { 0, 2, 1, 0, 3, 2 };
        mesh.RecalculateBounds();
    }

    /// <summary>销毁走原版 isDestroy，资源系统会把 prefab 还回对象池（等于隐藏）。</summary>
    private static void Kill(SceneObjectEntity ent)
    {
        if (ent == null) return;
        try
        {
            if (ent.hasSpary) ent.isDestroy = true;
        }
        catch (Exception)
        {
        }
    }

    private static Camera Eye()
    {
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") return cams[i];
        }
        try
        {
            var wc = Contexts.sharedInstance.worldCamera;
            if (wc != null && wc.hasUnityObjects && wc.unityObjects.mainCamera != null) return wc.unityObjects.mainCamera;
        }
        catch (Exception)
        {
        }
        return Camera.main;
    }

    private static string PlayerName()
    {
        try
        {
            PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
            if (me != null && me.hasBasicInfo && !string.IsNullOrEmpty(me.basicInfo.PlayerName)) return me.basicInfo.PlayerName;
        }
        catch (Exception)
        {
        }
        return "OFFLINE";
    }

    private static void LoadConfig()
    {
        try
        {
            string dir = Directory.GetParent(Application.dataPath).FullName;
            string path = Path.Combine(dir, "offline_spray.json");
            if (!File.Exists(path)) return;
            OfflineSprayConfig cfg = JsonUtility.FromJson<OfflineSprayConfig>(File.ReadAllText(path));
            if (cfg == null) return;
            if (cfg.ids != null && cfg.ids.Length > 0) _ids = cfg.ids;
            if (cfg.cooldown > 0f) _cooldown = cfg.cooldown;
            if (cfg.life > 0f) _life = Mathf.Clamp(cfg.life, 10f, 120f);
            if (cfg.max > 0) _maxAlive = cfg.max;
        }
        catch (Exception ex)
        {
            Debug.LogWarning("[OFFLINE-SPRAY] config read fail " + ex.Message);
        }
    }

    private static void Skip(string reason)
    {
        Debug.Log("[OFFLINE-SPRAY] skip reason=" + reason);
    }
}
