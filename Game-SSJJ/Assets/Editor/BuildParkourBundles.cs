using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>Build and install the playable Neon Skyrail map as offline map 3101.</summary>
public static class BuildParkourBundles
{
    private const string SourceScene = "Assets/Parkour/NeonSkyrail.unity";
    private const string ScenePath = "Assets/Bundles/Scenes/map_3101.unity";
    private const string BspPath = "Assets/Parkour/MapData/model.bsp.raw.bytes";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientRoot = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";
    private const string ClientStreaming = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets";
    private const string ServerSolid = @"D:\逆向\SSJJ双塔惊魂\SSJJ-Server\Data\Maps\map3101_solid.json";

    [MenuItem("SSJJ/Parkour/Build + install playable map 3101")]
    public static void BuildAndInstall()
    {
        if (EditorApplication.isPlaying)
        {
            Debug.LogError("[Parkour] Exit Play Mode before building map 3101.");
            return;
        }
        if (!File.Exists(BspPath) || !File.Exists(ServerSolid))
        {
            Debug.LogError("[Parkour] Run Game-SSJJ/tools/build_parkour_bsp.py and build_parkour_course.py first.");
            return;
        }

        AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
        Directory.CreateDirectory(Path.GetDirectoryName(ScenePath));
        var scene = EditorSceneManager.OpenScene(SourceScene, OpenSceneMode.Single);
        foreach (var camera in UnityEngine.Object.FindObjectsOfType<Camera>())
        {
            if (camera.name == "Parkour_Preview_Camera")
                UnityEngine.Object.DestroyImmediate(camera.gameObject);
        }
        EditorSceneManager.SaveScene(scene, ScenePath);
        AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

        string outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);
        var bundles = new[]
        {
            new AssetBundleBuild
            {
                assetBundleName = "unitymaps/map_3101",
                assetNames = new[] { ScenePath }
            },
            new AssetBundleBuild
            {
                assetBundleName = "maps/map3101",
                assetNames = new[] { BspPath }
            }
        };
        var manifest = BuildPipeline.BuildAssetBundles(
            outDir, bundles, BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);
        if (manifest == null)
        {
            Debug.LogError("[Parkour] AssetBundle build failed.");
            return;
        }

        string sceneBundle = Path.Combine(outDir, "unitymaps", "map_3101");
        string bspBundle = Path.Combine(outDir, "maps", "map3101");
        if (!File.Exists(sceneBundle) || !File.Exists(bspBundle))
        {
            Debug.LogError("[Parkour] Expected map bundles are missing after build.");
            return;
        }
        if (!Directory.Exists(ClientRoot) || !File.Exists(Path.Combine(ClientRoot, "AssetBundles")))
        {
            Debug.LogError("[Parkour] Offline client bundle directory or XML manifest not found: " + ClientRoot);
            return;
        }

        string sceneMd5 = CopyHashed(sceneBundle, ClientRoot, "unitymaps", "map_3101");
        string bspMd5 = CopyHashed(bspBundle, ClientRoot, "maps", "map3101");
        string manifestPath = Path.Combine(ClientRoot, "AssetBundles");
        string manifestText = File.ReadAllText(manifestPath, Encoding.UTF8);
        string updated = UpsertEntry(manifestText, "unitymaps/map_3101", sceneMd5);
        updated = UpsertEntry(updated, "maps/map3101", bspMd5);
        if (updated != manifestText)
        {
            string backup = manifestPath + ".before-map3101";
            if (!File.Exists(backup)) File.Copy(manifestPath, backup);
            File.WriteAllText(manifestPath, updated, new UTF8Encoding(false));
        }

        string rawDir = Path.Combine(ClientStreaming, "map3101");
        Directory.CreateDirectory(rawDir);
        File.Copy(BspPath, Path.Combine(rawDir, "model.bsp.raw"), true);
        Debug.Log("[Parkour] map3101 installed. unitymaps/map_3101 md5=" + sceneMd5 +
                  " maps/map3101 md5=" + bspMd5 + " spawn=0,0,250 yaw=1 (SSJJ axes)");
    }

    private static string CopyHashed(string source, string clientRoot, string subdir, string bundleName)
    {
        string md5;
        using (var hash = MD5.Create())
        using (var stream = File.OpenRead(source))
            md5 = BitConverter.ToString(hash.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
        string dir = Path.Combine(clientRoot, subdir);
        Directory.CreateDirectory(dir);
        File.Copy(source, Path.Combine(dir, bundleName + "_" + md5), true);
        return md5;
    }

    private static string UpsertEntry(string xml, string name, string md5)
    {
        string escaped = Regex.Escape(name);
        var match = Regex.Match(xml,
            "<AssetBundle\\b(?=[^>]*\\bname=\"" + escaped + "\")[^>]*/>",
            RegexOptions.IgnoreCase);
        if (match.Success)
        {
            string item = match.Value;
            if (Regex.IsMatch(item, "\\bmd5=\"[0-9a-f]+\"", RegexOptions.IgnoreCase))
                item = Regex.Replace(item, "\\bmd5=\"[0-9a-f]+\"", "md5=\"" + md5 + "\"", RegexOptions.IgnoreCase);
            else
                item = item.Substring(0, item.Length - 2) + " md5=\"" + md5 + "\" />";
            return xml.Substring(0, match.Index) + item + xml.Substring(match.Index + match.Length);
        }
        int end = xml.LastIndexOf("</AssetBundles>", StringComparison.OrdinalIgnoreCase);
        if (end < 0) throw new InvalidDataException("AssetBundles XML closing tag not found.");
        string entry = "  <AssetBundle name=\"" + name + "\" md5=\"" + md5 + "\" crc=\"0\" />\r\n";
        return xml.Substring(0, end) + entry + xml.Substring(end);
    }
}
