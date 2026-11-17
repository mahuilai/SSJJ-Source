using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// V3：用 Blender 从 map43_game.glb 转出的 FBX 重建场景。
/// 几何/材质/贴图来自 Godot 已验证资产，不再用错位 OBJ。
/// </summary>
public static class BuildMap43V3
{
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string FbxPath = "Assets/Bundles/Map43/FBX/map43_game.fbx";
    private const string BspPath = "Assets/Bundles/Map43/Data/model.bsp.raw.bytes";
    private const string EffectPath = "Assets/Bundles/Map43/Data/sceneEffectConfig.bytes";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";
    private const string Spawn = "-141,8.6,-122";
    private const string TextureDir = "Assets/Bundles/Map43/Textures";
    private const string MaterialDir = "Assets/Bundles/Map43/Materials";

    [MenuItem("SSJJ/7. V3 FBX 重建 map43")]
    public static void Build()
    {
        AssetDatabase.Refresh();

        var importer = AssetImporter.GetAtPath(FbxPath) as ModelImporter;
        if (importer == null)
        {
            Debug.LogError("[V3] FBX importer missing: " + FbxPath);
            EditorApplication.Exit(1);
            return;
        }
        importer.globalScale = 1f;
        importer.useFileScale = true;
        importer.importMaterials = true;
        importer.materialName = ModelImporterMaterialName.BasedOnMaterialName;
        importer.materialSearch = ModelImporterMaterialSearch.Everywhere;
        importer.importAnimation = false;
        importer.SaveAndReimport();

        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(FbxPath);
        if (prefab == null)
        {
            Debug.LogError("[V3] FBX load failed");
            EditorApplication.Exit(1);
            return;
        }

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var model = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        model.name = "Map43_Geometry";

        var renderers = model.GetComponentsInChildren<MeshRenderer>(true);
        var filters = model.GetComponentsInChildren<MeshFilter>(true);
        var bounds = new Bounds();
        bool first = true;
        int matCount = 0;
        foreach (var r in renderers)
        {
            if (first) { bounds = r.bounds; first = false; } else bounds.Encapsulate(r.bounds);
            matCount += r.sharedMaterials.Length;
        }
        var sm0 = renderers.Length > 0 ? renderers[0].sharedMaterials[0] : null;
        Debug.Log("[V3] scale=" + model.transform.localScale + " renderers=" + renderers.Length +
                  " filters=" + filters.Length + " mats=" + matCount +
                  " bounds=" + bounds.size + " center=" + bounds.center +
                  " min=" + bounds.min + " max=" + bounds.max);
        if (sm0 != null)
            Debug.Log("[V3] mat0=" + sm0.name + " shader=" + (sm0.shader != null ? sm0.shader.name : "null") +
                      " tex=" + (sm0.mainTexture != null ? sm0.mainTexture.name : "null"));

        // FBX 内嵌贴图未被 Unity 提取：按 GLB 材质名重新绑定工程内官方贴图
        Directory.CreateDirectory(MaterialDir);
        int bound = 0, missing = 0;
        foreach (var r in renderers)
        {
            var mats = r.sharedMaterials;
            for (int i = 0; i < mats.Length; i++)
            {
                if (mats[i] == null) continue;
                var key = KeyOf(mats[i].name);
                var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(TextureDir + "/" + key + ".png");
                var matPath = MaterialDir + "/" + key + ".mat";
                var mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
                if (mat == null)
                {
                    mat = new Material(Shader.Find("Standard"));
                    AssetDatabase.CreateAsset(mat, matPath);
                }
                mat.mainTexture = tex;
                mat.color = Color.white;
                float metal = 0.1f, smooth = 0.35f;
                if (key.StartsWith("gd_metal")) { metal = 0.85f; smooth = 0.65f; }
                else if (key.StartsWith("gd_d")) { metal = 0.05f; smooth = 0.15f; }
                mat.SetFloat("_Metallic", metal);
                mat.SetFloat("_Glossiness", smooth);
                mats[i] = mat;
                if (tex != null) bound++; else { missing++; Debug.LogWarning("[V3] texture missing: " + key); }
            }
            r.sharedMaterials = mats;
        }
        AssetDatabase.SaveAssets();
        Debug.Log("[V3] materials bound=" + bound + " missing=" + missing);

        foreach (var mf in filters)
        {
            if (mf.sharedMesh == null) continue;
            var mc = mf.GetComponent<MeshCollider>();
            if (mc == null) mc = mf.gameObject.AddComponent<MeshCollider>();
            mc.sharedMesh = mf.sharedMesh;
            mc.convex = false;
        }
        foreach (var go in model.GetComponentsInChildren<Transform>(true))
            go.gameObject.isStatic = true;
        Debug.Log("[V3] colliders=" + model.GetComponentsInChildren<MeshCollider>(true).Length);

        // 对齐 PyEngine 坐标：SSJJ 世界单位为英寸，视觉网格是米；绕 Y +90° 后放大 39.37
        // Blender 射线校验：出生点处视觉地面 1630.68，与 BSP 地面一致，Y 偏移 0
        model.transform.localRotation = Quaternion.Euler(0f, 270f, 0f);
        model.transform.localScale = model.transform.localScale * 39.3701f;
        model.transform.position = new Vector3(-9611f, 0f, 11102f);
        Physics.SyncTransforms();
        var wb = new Bounds();
        bool wf = true;
        foreach (var rr in model.GetComponentsInChildren<MeshRenderer>(true))
        {
            if (wf) { wb = rr.bounds; wf = false; } else wb.Encapsulate(rr.bounds);
        }
        Debug.Log("[V3] worldBounds min=" + wb.min + " max=" + wb.max + " center=" + wb.center);

        // 黄昏天空 + 暖光 + 轻雾
        var sb = new Material(Shader.Find("Skybox/Procedural"));
        sb.SetFloat("_SunDisk", 1f);
        sb.SetFloat("_AtmosphereThickness", 1.05f);
        sb.SetColor("_SkyTint", new Color(0.38f, 0.50f, 0.72f));
        sb.SetColor("_GroundColor", new Color(0.20f, 0.19f, 0.20f));
        sb.SetFloat("_Exposure", 1.15f);
        RenderSettings.skybox = sb;
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
        RenderSettings.ambientIntensity = 1.05f;
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.58f, 0.63f, 0.72f);
        RenderSettings.fogStartDistance = 4000f;
        RenderSettings.fogEndDistance = 14000f;
        QualitySettings.shadowDistance = 5000f;

        var lightGo = new GameObject("Sun");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.color = new Color(1f, 0.92f, 0.80f);
        light.intensity = 1.25f;
        light.shadows = LightShadows.Soft;
        light.shadowStrength = 0.85f;
        lightGo.transform.rotation = Quaternion.Euler(46f, -38f, 0f);

        var spawnGo = new GameObject("SpawnPoint");
        spawnGo.transform.position = ParseVec(Spawn);

        EditorSceneManager.SaveScene(scene, ScenePath);

        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);
        foreach (var f in Directory.GetFiles(outDir, "map_3043*", SearchOption.AllDirectories))
            File.Delete(f);

        var build = new AssetBundleBuild();
        build.assetBundleName = "unitymaps/map_3043";
        build.assetNames = new[] { ScenePath };
        var manifest = BuildPipeline.BuildAssetBundles(
            outDir, new[] { build }, BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);
        if (manifest == null)
        {
            Debug.LogError("[V3] bundle build failed");
            EditorApplication.Exit(1);
            return;
        }

        var built = Path.Combine(outDir, "unitymaps", "map_3043");
        if (!File.Exists(built))
        {
            Debug.LogError("[V3] bundle missing: " + built);
            EditorApplication.Exit(1);
            return;
        }
        var md5 = CalcMd5(built);
        var clientDir = Path.Combine(ClientWin, "unitymaps");
        Directory.CreateDirectory(clientDir);
        foreach (var f in Directory.GetFiles(clientDir, "map_3043_*"))
            File.Delete(f);
        var deployed = Path.Combine(clientDir, "map_3043_" + md5);
        File.Copy(built, deployed, true);

        var manifestPath = Path.Combine(ClientWin, "AssetBundles");
        var mfText = File.ReadAllText(manifestPath);
        mfText = System.Text.RegularExpressions.Regex.Replace(
            mfText, @"<AssetBundle name=""unitymaps/map_3043"" md5=""[0-9a-f]+"" crc=""0"" />",
            "<AssetBundle name=\"unitymaps/map_3043\" md5=\"" + md5 + "\" crc=\"0\" />");
        File.WriteAllText(manifestPath, mfText);

        Debug.Log("[V3] DONE md5=" + md5 + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    private static string KeyOf(string matName)
    {
        var n = matName.ToLowerInvariant();
        foreach (var p in new[] { "textures_gongdi_", "textures_material_", "textures_" })
            if (n.StartsWith(p)) { n = n.Substring(p.Length); break; }
        return n;
    }

    private static Vector3 ParseVec(string s)
    {
        var p = s.Split(',').Select(float.Parse).ToArray();
        return new Vector3(p[0], p[1], p[2]);
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
