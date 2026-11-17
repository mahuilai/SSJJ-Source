using System;
using System.Collections.Generic;
using Entitas;
using UnityEngine;

/// <summary>
/// 离线 Bot 的最后一道渲染兜底。
///
/// LoadThirdPersonSystem 已经成功创建了 Bot 的网格和骨骼，但原版材质链包含
/// 服务端可见性/CommandBuffer 状态；在离线快照下 Renderer.isVisible 为真仍可能没有
/// 颜色像素。这里不重新加载模型，也不替换骨骼，只对 Bot 的现有 Renderer 做最小修复：
/// 开启 Renderer、关闭动态遮挡、恢复根节点，并把原贴图复制到 Unity 内置不透明材质。
/// 一旦原材质能正常绘制，保留原材质；只有连续帧仍无可见结果时才启用 fallback。
/// </summary>
public sealed class OfflineBotVisual : MonoBehaviour
{
    private const int FirstBotId = Assets.Sources.Systems.Snapshot.OfflineBotSpawner.FirstBotId;
    private readonly HashSet<int> _patched = new HashSet<int>();
    private readonly Dictionary<Renderer, Material> _fallbackMaterials = new Dictionary<Renderer, Material>();
    private readonly Dictionary<int, GameObject> _proxyObjects = new Dictionary<int, GameObject>();
    private readonly Dictionary<int, GameObject> _silhouetteObjects = new Dictionary<int, GameObject>();
    private readonly Dictionary<int, GameObject> _staticObjects = new Dictionary<int, GameObject>();
    private readonly HashSet<int> _silhouetteDiag = new HashSet<int>();
    private float _nextScan;

    private void LateUpdate()
    {
        if (Time.unscaledTime < _nextScan) return;
        _nextScan = Time.unscaledTime + 0.1f;
        Contexts ctx = Contexts.sharedInstance;
        if (ctx == null || ctx.player == null) return;

        IGroup<PlayerEntity> group = ctx.player.GetGroup(PlayerMatcher.EntityId);
        var it = group.GetEnumerator();
        try
        {
            while (it.MoveNext())
            {
                PlayerEntity entity = it.Current;
                if (entity == null || !entity.hasEntityId || entity.entityId.Value < FirstBotId
                    || !entity.hasThirdPersonUnityObjects)
                    continue;
                Patch(entity);
            }
        }
        finally
        {
            ((System.IDisposable)it).Dispose();
        }
    }

    private void Patch(PlayerEntity entity)
    {
        var objects = entity.thirdPersonUnityObjects;
        if (objects.ThirdTran != null && objects.ThirdTran.RootContainer != null)
        {
            objects.ThirdTran.RootContainer.SetActive(true);
        }

        Renderer[] renders = objects.MeshRenders;
        if (renders == null) return;
        for (int i = 0; i < renders.Length; i++)
        {
            Renderer r = renders[i];
            if (r == null) continue;
            r.enabled = true;
            r.forceRenderingOff = false;
            r.allowOcclusionWhenDynamic = false;
            if (r.gameObject.layer != 0) r.gameObject.layer = 0;
        }
        // 日志已经证明原 Renderer.isVisible=True 仍没有像素，因此不能把 isVisible
        // 当作颜色相机绘制成功的证据。Bot 直接使用保留原贴图的内置不透明材质，
        // 绕过原版 shader 的 stencil/CommandBuffer 门控；网格、骨骼和动画对象不变。
        // 原版 PlayerDrawVertexColorSystem 可能在后续帧重新写材质，所以这里每次扫描
        // 都校验并恢复绑定，而不是只在第一次出现时处理。
        EnableFallback(renders);
        if (_patched.Add(entity.entityId.Value))
            Debug.Log("[OFFLINE-BOT-VISUAL] fallback material enabled id=" + entity.entityId.Value);
    }

    private void EnsureStaticMesh(int id, Renderer[] renders)
    {
        if (_staticObjects.ContainsKey(id)) return;
        for (int i = 0; i < renders.Length; i++)
        {
            SkinnedMeshRenderer skin = renders[i] as SkinnedMeshRenderer;
            if (skin == null || skin.sharedMesh == null) continue;
            Mesh baked = new Mesh();
            try { skin.BakeMesh(baked); }
            catch (Exception ex) { Debug.LogWarning("[OFFLINE-BOT-VISUAL] BakeMesh failed id=" + id + " " + ex.Message); continue; }
            if (baked.vertexCount == 0) { Destroy(baked); continue; }
            GameObject go = new GameObject("OfflineBotStaticMesh_" + id);
            go.transform.SetParent(transform, true);
            go.layer = 0;
            go.transform.SetPositionAndRotation(skin.transform.position, skin.transform.rotation);
            go.transform.localScale = skin.transform.lossyScale;
            MeshFilter filter = go.AddComponent<MeshFilter>();
            filter.sharedMesh = baked;
            MeshRenderer renderer = go.AddComponent<MeshRenderer>();
            renderer.shadowCastingMode = skin.shadowCastingMode;
            renderer.receiveShadows = skin.receiveShadows;
            Material source = skin.sharedMaterial;
            if (source != null)
            {
                Material m = MakeFallbackMaterial(source);
                renderer.material = m;
                _fallbackMaterials[renderer] = m;
            }
            _staticObjects[id] = go;
            Debug.Log("[OFFLINE-BOT-VISUAL] static mesh created id=" + id + " vertices=" + baked.vertexCount);
            return;
        }
    }

    private void EnsureProxy(int id, GameObject source)
    {
        GameObject proxy;
        if (!_proxyObjects.TryGetValue(id, out proxy) || proxy == null)
        {
            proxy = Instantiate(source);
            proxy.name = "OfflineBotVisualProxy_" + id;
            proxy.transform.SetParent(transform, true);
            // The proxy is render-only. Disable copied gameplay/animation scripts so it
            // cannot feed back into the original Entitas entity or move independently.
            Behaviour[] behaviours = proxy.GetComponentsInChildren<Behaviour>(true);
            for (int i = 0; i < behaviours.Length; i++)
                if (behaviours[i] != null) behaviours[i].enabled = false;
            Renderer[] proxyRenders = proxy.GetComponentsInChildren<Renderer>(true);
            EnableFallback(proxyRenders);
            _proxyObjects[id] = proxy;
            Debug.Log("[OFFLINE-BOT-VISUAL] proxy clone created id=" + id + " renderers=" + proxyRenders.Length);
        }
        proxy.transform.position = source.transform.position;
        proxy.transform.rotation = source.transform.rotation;
        proxy.transform.localScale = source.transform.lossyScale;
        if (!proxy.activeSelf) proxy.SetActive(true);

        // 永久保留一个纯几何轮廓作为最后兜底。它不依赖角色 shader、贴图、骨骼或
        // CommandBuffer；如果该轮廓可见而模型不可见，问题就确定在原模型渲染链。
        GameObject silhouette;
        if (!_silhouetteObjects.TryGetValue(id, out silhouette) || silhouette == null)
        {
            silhouette = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            silhouette.name = "OfflineBotSilhouette_" + id;
            silhouette.transform.SetParent(transform, true);
            Collider c = silhouette.GetComponent<Collider>();
            if (c != null) Destroy(c);
            Renderer silhouetteRenderer = silhouette.GetComponent<Renderer>();
            Material template = null;
            foreach (Material candidate in _fallbackMaterials.Values)
            {
                if (candidate != null) { template = candidate; break; }
            }
            if (template != null)
            {
                Material mat = new Material(template);
                if (mat.HasProperty("_Color")) mat.color = Color.white;
                mat.renderQueue = 2000;
                silhouetteRenderer.material = mat;
            }
            _silhouetteObjects[id] = silhouette;
            Debug.Log("[OFFLINE-BOT-VISUAL] silhouette created id=" + id);
        }
        silhouette.transform.position = source.transform.position + Vector3.up * 0.9f;
        silhouette.transform.rotation = source.transform.rotation;
        silhouette.transform.localScale = new Vector3(0.45f, 0.9f, 0.45f);
        if (!silhouette.activeSelf) silhouette.SetActive(true);
        if (!_silhouetteDiag.Contains(id))
        {
            _silhouetteDiag.Add(id);
            Renderer sr = silhouette.GetComponent<Renderer>();
            Camera cam = Camera.main;
            Vector3 screen = cam != null ? cam.WorldToScreenPoint(silhouette.transform.position) : Vector3.zero;
            Debug.Log("[OFFLINE-BOT-VISUAL] silhouette diag id=" + id
                + " active=" + silhouette.activeInHierarchy
                + " layer=" + silhouette.layer
                + " renderer=" + (sr != null && sr.enabled)
                + " visible=" + (sr != null && sr.isVisible)
                + " shader=" + (sr != null && sr.sharedMaterial != null && sr.sharedMaterial.shader != null ? sr.sharedMaterial.shader.name : "-")
                + " color=" + (sr != null && sr.sharedMaterial != null && sr.sharedMaterial.HasProperty("_Color") ? sr.sharedMaterial.color.ToString() : "-")
                + " pos=" + silhouette.transform.position
                + " screen=" + screen
                + " cam=" + (cam == null ? "-" : cam.name));
        }
    }

    private void EnableFallback(Renderer[] renders)
    {
        for (int i = 0; i < renders.Length; i++)
        {
            Renderer r = renders[i];
            if (r == null) continue;
            Material m;
            if (!_fallbackMaterials.TryGetValue(r, out m) || m == null)
            {
                Material source = r.sharedMaterial;
                // 该客户端裁掉了 Unlit/Color，Shader.Find 返回 null。复制现有已加载
                // shader 才能保证材质在 2019 Mono 构建中有有效 shader 对象。
                if (source == null) continue;
                m = MakeFallbackMaterial(source);
                _fallbackMaterials[r] = m;
            }
            if (r.sharedMaterial != m) r.material = m;
            r.SetPropertyBlock(null);
            r.enabled = true;
        }
    }

    private static void NormalizeMaterial(Material m)
    {
        if (m == null) return;
        if (m.HasProperty("_Color")) m.color = Color.white;
        if (m.HasProperty("_Alpha")) m.SetFloat("_Alpha", 1f);
        if (m.HasProperty("_SelfAlpha")) m.SetFloat("_SelfAlpha", 1f);
        if (m.HasProperty("_CullAlpha")) m.SetFloat("_CullAlpha", 0f);
        if (m.HasProperty("_CullAlphaEnable")) m.SetFloat("_CullAlphaEnable", 0f);
        if (m.HasProperty("_AlphaKillValue")) m.SetFloat("_AlphaKillValue", 1f);
        if (m.HasProperty("_WeaponCullAlpha")) m.SetFloat("_WeaponCullAlpha", 0f);
        if (m.HasProperty("_Cutoff")) m.SetFloat("_Cutoff", 0f);
        if (m.HasProperty("_ZWrite")) m.SetFloat("_ZWrite", 1f);
        if (m.HasProperty("_CullMode")) m.SetFloat("_CullMode", 0f);
        if (m.HasProperty("_Cull")) m.SetFloat("_Cull", 2f);
        if (m.HasProperty("_OutlineShow")) m.SetFloat("_OutlineShow", 1f);
        if (m.HasProperty("_Stencil")) m.SetFloat("_Stencil", 0f);
        if (m.HasProperty("_StencilRef")) m.SetFloat("_StencilRef", 0f);
        if (m.HasProperty("_StencilComp")) m.SetFloat("_StencilComp", 8f);
        m.renderQueue = 2000;
    }

    /// <summary>
    /// UvHuxi and other third-person shaders may require a server command
    /// buffer that does not exist in offline mode. Keep the source texture but
    /// render the fallback copy with the loaded opaque Diffuse shader.
    /// </summary>
    private static Material MakeFallbackMaterial(Material source)
    {
        if (source == null) return null;
        Material m = new Material(source);
        Texture main = source.mainTexture;
        Color color = source.HasProperty("_Color") ? source.color : Color.white;
        Shader opaque = Shader.Find("SSJJ/Diffuse");
        if (opaque != null && m.shader != opaque)
        {
            m.shader = opaque;
            if (main != null && m.HasProperty("_MainTex")) m.mainTexture = main;
            if (m.HasProperty("_Color")) m.color = color;
        }
        NormalizeMaterial(m);
        return m;
    }

    private void OnDestroy()
    {
        foreach (Material m in _fallbackMaterials.Values)
        {
            if (m != null) Destroy(m);
        }
        _fallbackMaterials.Clear();
        foreach (GameObject proxy in _proxyObjects.Values)
        {
            if (proxy != null) Destroy(proxy);
        }
        _proxyObjects.Clear();
        foreach (GameObject silhouette in _silhouetteObjects.Values)
        {
            if (silhouette != null) Destroy(silhouette);
        }
        _silhouetteObjects.Clear();
        foreach (GameObject staticObject in _staticObjects.Values)
        {
            if (staticObject != null) Destroy(staticObject);
        }
        _staticObjects.Clear();
    }
}

