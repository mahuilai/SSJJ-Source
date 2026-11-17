using System.Collections.Generic;
using SSJJAsset.Asset;
using SSJJAsset.AssetBundle;
using SSJJBase.String;
using UnityEngine;

/// <summary>
/// 离线模式天空盒补丁。
///
/// 背景：原生 LoadSkyboxSystem 依赖 SceneObjectEntity 的 skybox 组件，
/// 而该实体由服务端下发。离线没有服务端，天空盒永远不生成，
/// 结果 BSP 里 skytexture 的封盖面（map1 有 126 个朝上的面）被
/// isNoRenderTexture 排除后，抬头就是大片纯黑。
///
/// map12 提供 skybox_panorama 时，优先用随地图包加载的专用 shader 在球面上显示完整 360° 全景，
/// 避免客户端裁剪 Unity 内置 shader 后退回六块独立方形面。其他地图回退到官方六面预制件。
/// </summary>
[DefaultExecutionOrder(23000)]
public class OfflineSkybox : MonoBehaviour
{
    private bool _done;
    private bool _bundleRequested;
    private float _timer;
    private GameObject _panoramaSphere;
    private Material _panoramaMaterial;

    private static readonly string[] FaceNames =
        { "Right", "Left", "Top", "Bottom", "Front", "Back" };

    private void Update()
    {
        if (_done) return;
        _timer += Time.deltaTime;
        if (_timer < 2f) return;      // 等进图后 bundle 就绪
        _timer = 0f;

        if (!_bundleRequested)
        {
            _bundleRequested = true;
            try
            {
                IgnoreCaseString key = new IgnoreCaseString("skybox");
                if (!AssetBundleManager.IsAssetBundleDownloaded(ref key))
                    AssetBundleManager.LoadAssetBundle(ref key, false);
                Debug.Log("[OFFLINE-SKY] request bundle skybox");
            }
            catch (System.Exception e)
            {
                Debug.Log("[OFFLINE-SKY] request failed: " + e.Message);
            }
            return;
        }

        Build();
    }

    private void LateUpdate()
    {
        if (_panoramaSphere == null) return;
        Camera camera = FindViewCamera();
        if (camera != null) _panoramaSphere.transform.position = camera.transform.position;
    }

    private GameObject _root;

    private void Build()
    {
        // map12 uses one equirectangular panorama, so no cube geometry or face boundaries are visible.
        Texture2D panorama = FindTexture("skybox_panorama");
        if (panorama != null && BuildPanoramic(panorama)) return;

        // Fallback: use the official six-face prefab for maps without a panorama asset.
        GameObject prefab = null;
        foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
        {
            if (b == null) continue;
            GameObject[] gos;
            try { gos = b.LoadAllAssets<GameObject>(); }
            catch { continue; }
            if (gos == null) continue;
            for (int i = 0; i < gos.Length; i++)
            {
                if (gos[i] != null && gos[i].name == "Skybox") { prefab = gos[i]; break; }
            }
            if (prefab != null) break;
        }
        if (prefab == null) return;

        // Find six-face textures in the active map bundle.
        Texture2D[] tex = new Texture2D[6];
        int found = 0;
        foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
        {
            if (b == null) continue;
            Texture2D[] ts;
            try { ts = b.LoadAllAssets<Texture2D>(); }
            catch { continue; }
            if (ts == null) continue;
            for (int k = 0; k < ts.Length; k++)
            {
                Texture2D t = ts[k];
                if (t == null || !t.name.StartsWith("skybox")) continue;
                string tail = t.name.Substring(6);
                int idx;
                if (int.TryParse(tail, out idx) && idx >= 0 && idx < 6 && tex[idx] == null)
                {
                    tex[idx] = t;
                    found++;
                }
            }
        }
        if (found < 6)
        {
            Debug.Log("[OFFLINE-SKY] textures not ready found=" + found);
            return;
        }

        // 3) 实例化并贴图
        _root = Instantiate(prefab);
        _root.name = "OfflineSkybox";
        // 官方预制件里 Skybox 根节点 localScale=30000、localPosition=(0,0,-10)
        _root.transform.position = new Vector3(0f, 0f, -10f);
        _root.transform.localScale = Vector3.one * 30000f;

        for (int i = 0; i < 6; i++)
        {
            Transform f = _root.transform.Find(FaceNames[i]);
            if (f == null) { Debug.Log("[OFFLINE-SKY] face missing " + FaceNames[i]); continue; }
            MeshRenderer mr = f.GetComponent<MeshRenderer>();
            if (mr == null) continue;
            Material m = mr.material;
            if (m == null) continue;
            m.mainTexture = tex[i];
            m.mainTextureScale = Vector2.one;
            m.mainTextureOffset = Vector2.zero;
        }

        RenderSettings.skybox = null;     // 不要 Unity 内置天空盒叠一层
        _done = true;
        Debug.Log("[OFFLINE-SKY] built root=" + _root.name + " tex=" + found);
    }

    private static Texture2D FindTexture(string name)
    {
        foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
        {
            if (b == null) continue;
            Texture2D[] textures;
            try { textures = b.LoadAllAssets<Texture2D>(); }
            catch { continue; }
            if (textures == null) continue;
            for (int i = 0; i < textures.Length; i++)
                if (textures[i] != null && textures[i].name == name) return textures[i];
        }
        return null;
    }

    private bool BuildPanoramic(Texture2D panorama)
    {
        Shader shader = FindBundledShader("SSJJ/SkyboxPanoramicOffline");
        if (shader == null) shader = Shader.Find("Skybox/Panoramic");
        if (shader == null)
        {
            Debug.LogWarning("[OFFLINE-SKY] panoramic shaders unavailable; using six-face fallback");
            return false;
        }

        _panoramaMaterial = new Material(shader);
        _panoramaMaterial.name = "OfflineSkybox360";
        _panoramaMaterial.SetTexture("_MainTex", panorama);
        if (_panoramaMaterial.HasProperty("_Mapping")) _panoramaMaterial.SetFloat("_Mapping", 0f); // LatLong/equirectangular
        if (_panoramaMaterial.HasProperty("_Rotation")) _panoramaMaterial.SetFloat("_Rotation", 0f);
        if (_panoramaMaterial.HasProperty("_Exposure")) _panoramaMaterial.SetFloat("_Exposure", 1f);
        if (_panoramaMaterial.HasProperty("_Tint")) _panoramaMaterial.SetColor("_Tint", Color.white);

        // The client build strips Unity's built-in panoramic shader, so render the lat-long texture
        // on the inside of a camera-following sphere. Background queue keeps world geometry in front.
        _panoramaSphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        _panoramaSphere.name = "OfflineSkybox360Sphere";
        Collider collider = _panoramaSphere.GetComponent<Collider>();
        if (collider != null) Destroy(collider);
        Camera viewCamera = FindViewCamera();
        _panoramaSphere.transform.position = viewCamera != null ? viewCamera.transform.position : Vector3.zero;
        float radius = viewCamera != null ? Mathf.Min(viewCamera.farClipPlane * 0.75f, 100000f) : 50000f;
        radius = Mathf.Max(radius, 12000f);
        _panoramaSphere.transform.localScale = Vector3.one * (radius * 2f);
        MeshRenderer renderer = _panoramaSphere.GetComponent<MeshRenderer>();
        renderer.sharedMaterial = _panoramaMaterial;
        renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        renderer.receiveShadows = false;
        renderer.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
        RenderSettings.skybox = null;
        _done = true;
        Debug.Log("[OFFLINE-SKY] built panorama sphere=" + radius + " shader=" + shader.name +
                  " texture=" + panorama.width + "x" + panorama.height);
        return true;
    }

    private static Shader FindBundledShader(string shaderName)
    {
        foreach (AssetBundle bundle in AssetBundle.GetAllLoadedAssetBundles())
        {
            if (bundle == null) continue;
            Shader[] shaders;
            try { shaders = bundle.LoadAllAssets<Shader>(); }
            catch { continue; }
            if (shaders == null) continue;
            for (int i = 0; i < shaders.Length; i++)
                if (shaders[i] != null && shaders[i].name == shaderName) return shaders[i];
        }
        return null;
    }

    private static Camera FindViewCamera()
    {
        Camera selected = null;
        Camera[] cameras = Camera.allCameras;
        for (int i = 0; i < cameras.Length; i++)
        {
            Camera camera = cameras[i];
            if (camera == null || !camera.enabled || camera.orthographic) continue;
            if (selected == null || camera.farClipPlane > selected.farClipPlane) selected = camera;
        }
        return selected != null ? selected : Camera.main;
    }
}
