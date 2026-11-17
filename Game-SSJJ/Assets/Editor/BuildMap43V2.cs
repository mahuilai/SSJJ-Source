using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// V2 完整重建：OBJ(正确mtl贴图) + 6-sided 天空盒 + 暖色平行光 + 线性雾 + 全量 MeshCollider
/// → 保存场景 → AssetBundleBuild 场景包 → 拷贝到客户端 → 更新清单 md5。
/// </summary>
public static class BuildMap43V2
{
    private const string SrcRoot = @"D:\逆向\SSJJ双塔惊魂\extracted\maps\map43";
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string ObjPath = "Assets/Bundles/Map43/Model/map43_full.obj";
    private const string SkyDir = "Assets/Bundles/Map43/Skybox";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";

    private static readonly string[] SkyFaces = { "skybox0", "skybox1", "skybox4", "skybox5", "skybox2", "skybox3" }; // rt lf bk ft up dn → Unity: F B L R U D 见下

    [MenuItem("SSJJ/6. V2 完整重建 map43")]
    public static void Build()
    {
        // 0) 拷贝 skybox 到工程
        Directory.CreateDirectory(SkyDir);
        for (int i = 0; i < 6; i++)
        {
            var src = Path.Combine(SrcRoot, "textures", "skybox" + i + ".png");
            var dst = Path.Combine(SkyDir, "skybox" + i + ".png");
            if (!File.Exists(dst) || new FileInfo(src).LastWriteTime > new FileInfo(dst).LastWriteTime)
                File.Copy(src, dst, true);
        }
        AssetDatabase.Refresh();

        // 1) 重导入 OBJ（新 mtl 生效）
        AssetDatabase.ImportAsset(ObjPath, ImportAssetOptions.ForceUpdate);

        // 2) 新场景
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        // 3) Skybox 材质（Unity 6-sided 顺序: Front Back Left Right Up Down）
        //    BSP 面序 sky0..5 = rt lf bk ft up dn（亮度与内容推断）
        var sb = new Material(Shader.Find("Skybox/6 Sided"));
        var faces = new[]
        {
            ("_FrontTex", "skybox5"), ("_BackTex", "skybox4"),
            ("_LeftTex", "skybox1"), ("_RightTex", "skybox0"),
            ("_UpTex", "skybox2"), ("_DownTex", "skybox3")
        };
        foreach (var f in faces)
        {
            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(SkyDir + "/" + f.Item2 + ".png");
            if (tex != null) sb.SetTexture(f.Item1, tex);
        }
        RenderSettings.skybox = sb;
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
        RenderSettings.defaultReflectionMode = UnityEngine.Rendering.DefaultReflectionMode.Skybox;

        // 4) 平行光（阴天柔光，略暖）+ 雾
        var lightGo = new GameObject("Directional Light");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.color = new Color32(255, 244, 224, 255);
        light.intensity = 1.15f;
        light.shadows = LightShadows.Soft;
        lightGo.transform.rotation = Quaternion.Euler(48f, 320f, 0f);
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.72f, 0.74f, 0.78f);
        RenderSettings.fogStartDistance = 90f;
        RenderSettings.fogEndDistance = 430f;

        // 5) 实例化模型
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(ObjPath);
        if (prefab == null)
        {
            Debug.LogError("[V2] OBJ 加载失败");
            EditorApplication.Exit(1);
            return;
        }
        var model = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        model.name = "Map43_Geometry";

        // 6) 全量 MeshCollider + 统计包围盒
        var renderers = model.GetComponentsInChildren<MeshRenderer>();
        var colliders = model.GetComponentsInChildren<MeshCollider>(true);
        foreach (var mf in model.GetComponentsInChildren<MeshFilter>(true))
        {
            if (mf.GetComponent<MeshCollider>() == null && mf.sharedMesh != null)
                mf.gameObject.AddComponent<MeshCollider>();
        }
        colliders = model.GetComponentsInChildren<MeshCollider>(true);
        var bounds = new Bounds(model.transform.position, Vector3.zero);
        bool first = true;
        foreach (var r in renderers)
        {
            if (first) { bounds = r.bounds; first = false; }
            else bounds.Encapsulate(r.bounds);
        }
        Debug.Log("[V2] renderers=" + renderers.Length + " colliders=" + colliders.Length +
                  " bounds=" + bounds.size + " center=" + bounds.center);

        // 7) spawn：包围盒中心 XZ，y 取地面（向下打盒）+1.6
        var spawn = new GameObject("SpawnPoint");
        Vector3 cxz = new Vector3(bounds.center.x, 0, bounds.center.z);
        float groundY = bounds.min.y;
        spawn.transform.position = new Vector3(cxz.x, groundY + 1.7f, cxz.z);
        Debug.Log("[V2] spawn=" + spawn.transform.position);

        // 8) 保存 + 打包（AssetBundleBuild 场景包）
        EditorSceneManager.SaveScene(scene, ScenePath);

        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);
        // 清掉旧产物避免混淆
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
            Debug.LogError("[V2] 打包失败");
            EditorApplication.Exit(1);
            return;
        }

        // 9) 拷贝到客户端 + 更新清单 md5
        var built = Path.Combine(outDir, "unitymaps", "map_3043");
        if (!File.Exists(built))
        {
            Debug.LogError("[V2] bundle not found: " + built);
            EditorApplication.Exit(1);
            return;
        }
        var md5 = CalcMd5(built);
        var clientDir = Path.Combine(ClientWin, "unitymaps");
        Directory.CreateDirectory(clientDir);
        // 清旧版本
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

        Debug.Log("[V2] DONE md5=" + md5 + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
