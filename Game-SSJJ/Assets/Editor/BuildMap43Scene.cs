using System.IO;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 用 AssetBundleBuild API 重打 map_3043 为「场景 bundle」（含 Scene 数据，
/// SceneManager.LoadSceneAsync("map_3043") 可用）。
/// </summary>
public static class BuildMap43Scene
{
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";

    [MenuItem("SSJJ/5. 重打 map_3043 场景bundle")]
    public static void Build()
    {
        var build = new AssetBundleBuild();
        build.assetBundleName = "unitymaps/map_3043";
        build.assetNames = new[] { ScenePath };

        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);

        var manifest = BuildPipeline.BuildAssetBundles(
            outDir, new[] { build }, BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);

        if (manifest == null)
        {
            Debug.LogError("[SSJJ-SP] scene bundle build failed");
            EditorApplication.Exit(1);
            return;
        }
        foreach (var b in manifest.GetAllAssetBundles())
            Debug.Log("[SSJJ-SP] bundle: " + b);
        Debug.Log("[SSJJ-SP] scene bundle done -> " + outDir);
        EditorApplication.Exit(0);
    }
}
