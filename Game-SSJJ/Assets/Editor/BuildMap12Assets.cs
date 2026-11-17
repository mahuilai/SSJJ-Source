using System.IO;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

/// <summary>
/// Rebuild only the extracted native asset bundle maps/map12.
/// The map_3043 Unity scene is shared with map43 and is intentionally untouched.
/// </summary>
public static class BuildMap12Assets
{
    private const string TextureDir = "Assets/Bundles/Map12/Textures";
    private const string DataDir = "Assets/Bundles/Map12/Data";
    private const string ShaderDir = "Assets/Bundles/Map12/Shaders";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";

    private static readonly string[] Assets =
    {
        TextureDir + "/c_xd_d001_a.png",
        TextureDir + "/c_xd_d002_a.png",
        TextureDir + "/c_xd_q001.png",
        TextureDir + "/c_xd_q002_a.png",
        TextureDir + "/c_xd_q003.png",
        TextureDir + "/c_xd_q005_a.png",
        TextureDir + "/c_xd_q006_a.png",
        TextureDir + "/lightmap0.png",
        TextureDir + "/map.png",
        TextureDir + "/smallmapback.png",
        TextureDir + "/skybox0.png",
        TextureDir + "/skybox1.png",
        TextureDir + "/skybox2.png",
        TextureDir + "/skybox3.png",
        TextureDir + "/skybox4.png",
        TextureDir + "/skybox5.png",
        TextureDir + "/skybox_panorama.png",
        ShaderDir + "/SkyboxPanoramicOffline.shader",
        DataDir + "/model.bsp.raw.bytes",
        DataDir + "/scenemapdataconfig.xml",
    };

    [MenuItem("SSJJ/12. map12 资源包 (maps/map12)")]
    public static void Build()
    {
        AssetDatabase.Refresh();

        var panoramaImporter = AssetImporter.GetAtPath(TextureDir + "/skybox_panorama.png") as TextureImporter;
        if (panoramaImporter == null)
        {
            Debug.LogError("[M12A] panorama texture importer missing");
            EditorApplication.Exit(1);
            return;
        }
        panoramaImporter.textureType = TextureImporterType.Default;
        panoramaImporter.mipmapEnabled = false;
        panoramaImporter.wrapMode = TextureWrapMode.Repeat;
        panoramaImporter.filterMode = FilterMode.Bilinear;
        panoramaImporter.maxTextureSize = 2048;
        panoramaImporter.SaveAndReimport();

        foreach (var path in Assets)
        {
            if (!File.Exists(path))
            {
                Debug.LogError("[M12A] missing asset: " + path);
                EditorApplication.Exit(1);
                return;
            }
        }
        Debug.Log("[M12A] assets=" + Assets.Length + " surfaces=7 skyFaces=6 panorama=1 shaders=1 technical=3 data=2");

        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(Path.Combine(outDir, "maps"));
        var build = new AssetBundleBuild
        {
            assetBundleName = "maps/map12",
            assetNames = Assets
        };
        var manifest = BuildPipeline.BuildAssetBundles(
            outDir,
            new[] { build },
            BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);

        var built = Path.Combine(outDir, "maps", "map12");
        if (manifest == null || !File.Exists(built))
        {
            Debug.LogError("[M12A] bundle build failed: " + built);
            EditorApplication.Exit(1);
            return;
        }

        uint crc;
        if (!BuildPipeline.GetCRCForAssetBundle(built, out crc))
        {
            Debug.LogError("[M12A] CRC calculation failed");
            EditorApplication.Exit(1);
            return;
        }

        string md5;
        using (var hash = MD5.Create())
        using (var stream = File.OpenRead(built))
            md5 = System.BitConverter.ToString(hash.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();

        var fileSize = new FileInfo(built).Length;
        var clientManifest = Path.Combine(ClientWin, "AssetBundles");
        if (!File.Exists(clientManifest))
        {
            Debug.LogError("[M12A] client manifest missing: " + clientManifest);
            EditorApplication.Exit(1);
            return;
        }
        var text = File.ReadAllText(clientManifest);
        const string pattern = @"<AssetBundle crc=""[0-9]+"" md5=""[0-9a-f]+"" name=""maps/map12"" size=""[0-9]+""\s*/>";
        if (!Regex.IsMatch(text, pattern))
        {
            Debug.LogError("[M12A] legacy maps/map12 manifest entry not found; manifest left unchanged");
            EditorApplication.Exit(1);
            return;
        }
        var entry = "<AssetBundle crc=\"" + crc + "\" md5=\"" + md5 +
                    "\" name=\"maps/map12\" size=\"" + fileSize + "\" />";

        var clientMaps = Path.Combine(ClientWin, "maps");
        Directory.CreateDirectory(clientMaps);
        var deployed = Path.Combine(clientMaps, "map12_" + md5);
        File.Copy(built, deployed, true);

        text = Regex.Replace(text, pattern, entry);
        var tempManifest = clientManifest + ".map12.tmp";
        File.WriteAllText(tempManifest, text);
        File.Replace(tempManifest, clientManifest, null);
        foreach (var file in Directory.GetFiles(clientMaps, "map12_*"))
        {
            if (Path.GetFullPath(file).Equals(Path.GetFullPath(deployed), System.StringComparison.OrdinalIgnoreCase)) continue;
            try { File.Delete(file); }
            catch (IOException) { Debug.LogWarning("[M12A] stale bundle retained (in use): " + file); }
        }

        Debug.Log("[M12A] manifest updated: " + entry);
        Debug.Log("[M12A] DONE md5=" + md5 + " crc=" + crc + " bytes=" + fileSize +
                  " assets=" + Assets.Length + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }
}
