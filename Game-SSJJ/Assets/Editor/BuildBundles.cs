using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 生成单机版所需的本地 bundle 集：
///   unitymaps/map_3001   最小可走场景（地板 + 光照 + 出生点）
///   tables               已导出的表数据
/// 产物：Assets/StreamingAssets/AssetBundles/Windows/
/// </summary>
public static class BuildBundles
{
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string SceneDir = "Assets/Bundles/Scenes";
    private const string TableSrc = @"D:\逆向\SSJJ双塔惊魂\Game source\06_singleplayer\tables";
    private const string TableDst = "Assets/Bundles/Tables";

    [MenuItem("SSJJ/3. 生成单机 bundle")]
    public static void BuildAll()
    {
        Directory.CreateDirectory(SceneDir);

        // ---- 1. 最小地图场景 ----
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var lightGo = new GameObject("Directional Light");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1.2f;
        lightGo.transform.rotation = Quaternion.Euler(50, -30, 0);

        var floor = GameObject.CreatePrimitive(PrimitiveType.Plane);
        floor.name = "Floor";
        floor.transform.localScale = new Vector3(6, 1, 6);

        var spawn = new GameObject("PlayerSpawn");
        spawn.transform.position = new Vector3(0, 1.2f, 0);

        var scenePath = SceneDir + "/map_3001.unity";
        EditorSceneManager.SaveScene(scene, scenePath);

        var imp = AssetImporter.GetAtPath(scenePath);
        imp.assetBundleName = "unitymaps/map_3001";
        imp.SaveAndReimport();

        // ---- 2. tables ----
        Directory.CreateDirectory(TableDst);
        int copied = 0;
        if (Directory.Exists(TableSrc))
        {
            foreach (var f in Directory.GetFiles(TableSrc, "*", SearchOption.AllDirectories))
            {
                var name = Path.GetFileName(f);
                if (name.Contains(".")) continue;              // 只收无扩展名的表文件
                var dst = Path.Combine(TableDst, name + ".bytes");
                File.Copy(f, dst, true);
                AssetDatabase.ImportAsset(dst);
                var ti = AssetImporter.GetAtPath(dst);
                ti.assetBundleName = "tables";
                ti.SaveAndReimport();
                copied++;
            }
        }
        Debug.Log("[SSJJ-SP] tables copied: " + copied);

        // ---- 3. 构建 ----
        Directory.CreateDirectory(BundleRoot);
        var manifest = BuildPipeline.BuildAssetBundles(
            BundleRoot,
            BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);

        if (manifest == null)
        {
            Debug.LogError("[SSJJ-SP] BuildAssetBundles 失败");
            EditorApplication.Exit(1);
            return;
        }

        foreach (var b in manifest.GetAllAssetBundles())
            Debug.Log("[SSJJ-SP] bundle: " + b);

        AssetDatabase.Refresh();
        Debug.Log("[SSJJ-SP] bundles built -> " + BundleRoot);
    }
}
