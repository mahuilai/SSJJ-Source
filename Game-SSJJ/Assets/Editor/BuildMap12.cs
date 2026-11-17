using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// map12：Q3 BSP 导出的 OBJ（已是 Unity/SSJJ 坐标）+ 官方贴图。
/// PyEngine 碰撞由 StreamingAssets/map12/model.bsp.raw 提供。
/// </summary>
public static class BuildMap12
{
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string ObjPath = "Assets/Bundles/Map12/Model/map12.obj";
    private const string TexDir = "Assets/Bundles/Map12/Textures";
    private const string MatDir = "Assets/Bundles/Map12/Materials";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";
    private static readonly Vector3 Spawn = new Vector3(-1254.76f, 119.38f, 3896.36f);

    [MenuItem("SSJJ/8. map12 场景重建")]
    public static void Build()
    {
        AssetDatabase.Refresh();
        var importer = AssetImporter.GetAtPath(ObjPath) as ModelImporter;
        if (importer != null)
        {
            importer.globalScale = 1f;
            importer.useFileScale = true;
            importer.importMaterials = true;
            importer.materialName = ModelImporterMaterialName.BasedOnMaterialName;
            importer.materialSearch = ModelImporterMaterialSearch.Local;
            importer.importAnimation = false;
            importer.SaveAndReimport();
        }

        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(ObjPath);
        if (prefab == null) { Debug.LogError("[M12] OBJ load failed"); EditorApplication.Exit(1); return; }

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var model = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        model.name = "Map12_Geometry";

        var renderers = model.GetComponentsInChildren<MeshRenderer>(true);
        var filters = model.GetComponentsInChildren<MeshFilter>(true);
        var bounds = new Bounds();
        bool first = true;
        foreach (var r in renderers)
        {
            if (first) { bounds = r.bounds; first = false; } else bounds.Encapsulate(r.bounds);
        }
        Debug.Log("[M12] renderers=" + renderers.Length + " filters=" + filters.Length +
                  " bounds=" + bounds.size + " center=" + bounds.center + " min=" + bounds.min + " max=" + bounds.max);

        Directory.CreateDirectory(MatDir);
        int bound = 0, missing = 0;
        foreach (var r in renderers)
        {
            var mats = r.sharedMaterials;
            for (int i = 0; i < mats.Length; i++)
            {
                if (mats[i] == null) continue;
                var key = mats[i].name;
                if (key.EndsWith("Mat")) key = key.Substring(0, key.Length - 3);
                var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(TexDir + "/" + key + ".png");
                var matPath = MatDir + "/" + key + ".mat";
                var mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
                if (mat == null)
                {
                    mat = new Material(Shader.Find("SSJJ/TextureDouble"));
                    AssetDatabase.CreateAsset(mat, matPath);
                }
                mat.shader = Shader.Find("SSJJ/TextureDouble");
                mat.mainTexture = tex;
                mat.SetColor("_Color", Color.white);
                mat.color = Color.white;
                mat.SetFloat("_Metallic", 0.05f);
                
                mat.SetInt("_Cull", 0);
                mat.doubleSidedGI = true;
                mats[i] = mat;
                if (tex != null) bound++; else { missing++; Debug.LogWarning("[M12] tex missing: " + key); }
            }
            r.sharedMaterials = mats;
        }
        AssetDatabase.SaveAssets();
        Debug.Log("[M12] materials bound=" + bound + " missing=" + missing);

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

        var sb = new Material(Shader.Find("Skybox/Procedural"));
        sb.SetFloat("_SunDisk", 1f);
        sb.SetFloat("_AtmosphereThickness", 1f);
        sb.SetColor("_SkyTint", new Color(0.40f, 0.52f, 0.74f));
        sb.SetColor("_GroundColor", new Color(0.22f, 0.21f, 0.20f));
        sb.SetFloat("_Exposure", 1.2f);
        RenderSettings.skybox = sb;
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
        RenderSettings.ambientIntensity = 1.6f;
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.60f, 0.65f, 0.74f);
        RenderSettings.fogStartDistance = 4000f;
        RenderSettings.fogEndDistance = 12000f;

        var lightGo = new GameObject("Sun");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.color = new Color(1f, 0.93f, 0.82f);
        light.intensity = 1.2f;
        light.shadows = LightShadows.Soft;
        lightGo.transform.rotation = Quaternion.Euler(48f, -35f, 0f);

        var lampGo = new GameObject("SpawnLamp");
        var lamp = lampGo.AddComponent<Light>();
        lamp.type = LightType.Point;
        lamp.color = Color.white;
        lamp.intensity = 2.2f;
        lamp.range = 3000f;
        lampGo.transform.position = Spawn + new Vector3(0f, 300f, 0f);

        var spawnGo = new GameObject("SpawnPoint");
        spawnGo.transform.position = Spawn;
        Debug.Log("[M12] spawn=" + Spawn);

        EditorSceneManager.SaveScene(scene, ScenePath);

        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);
        foreach (var f in Directory.GetFiles(outDir, "map_3043*", SearchOption.AllDirectories))
            File.Delete(f);

        var build = new AssetBundleBuild();
        build.assetBundleName = "unitymaps/map_3043";
        build.assetNames = new[] { ScenePath };
        var manifest = BuildPipeline.BuildAssetBundles(outDir, new[] { build },
            BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.StandaloneWindows64);
        if (manifest == null) { Debug.LogError("[M12] bundle build failed"); EditorApplication.Exit(1); return; }

        var built = Path.Combine(outDir, "unitymaps", "map_3043");
        if (!File.Exists(built)) { Debug.LogError("[M12] bundle missing"); EditorApplication.Exit(1); return; }
        var md5 = CalcMd5(built);
        var clientDir = Path.Combine(ClientWin, "unitymaps");
        Directory.CreateDirectory(clientDir);
        foreach (var f in Directory.GetFiles(clientDir, "map_3043_*")) File.Delete(f);
        var deployed = Path.Combine(clientDir, "map_3043_" + md5);
        File.Copy(built, deployed, true);

        var manifestPath = Path.Combine(ClientWin, "AssetBundles");
        var text = File.ReadAllText(manifestPath);
        text = System.Text.RegularExpressions.Regex.Replace(text,
            @"<AssetBundle name=""unitymaps/map_3043"" md5=""[0-9a-f]+"" crc=""0"" />",
            "<AssetBundle name=\"unitymaps/map_3043\" md5=\"" + md5 + "\" crc=\"0\" />");
        File.WriteAllText(manifestPath, text);
        Debug.Log("[M12] DONE md5=" + md5 + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
