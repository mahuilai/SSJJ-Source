using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 打包 map1 的"原生资源 bundle" —— maps/map1。
///
/// 为什么需要这个：
///   BattleLoadingManager 第 559 行：
///       IgnoreCaseString mapkey = new IgnoreCaseString("maps/map" + mapInfo.Id);
///       AssetBundleManager.LoadAllAssetsAsync(ref mapkey);
///       Contexts...mapInfo.AssetLoader = new MapAssetLoader(allAssets, mapkey);
///
///   map1 的 id=1 -> bundle 名 "maps/map1"。
///   BspRender.CreateMaterial() 会调 _mapAssetLoader.GetTexture("c_dust2_qiang04")，
///   而 MapAssetLoader.GetTexture 只在 allAssets 里按 name 精确匹配。
///
///   客户端本来就没有 map1 的官方 bundle（地图已经下架），所以日志里刷的是：
///       ERROR SSJJSceneLoader.BspRender - NoMatchTexture, TextureName c_dust2_d13
///   —— 结果就是所有墙壁地面都变成无贴图的纯色，也就是用户说的"贴图贴错/亮度不对"。
///
/// 这个脚本把导出的 30 张原图 + model.bsp.raw 打进 maps/map1，
/// 让官方 BspRender 能按原名取到贴图，从而：
///   - 贴图是原始贴图（直接从客户端缓存里导出的 PNG，未做任何调色）
///   - 亮度是原始亮度（走官方 SSJJ/UnityMap + 官方 lightmap + 官方顶点色流程）
/// </summary>
public static class BuildMap1Assets
{
    private const string TexDir = "Assets/Bundles/Map1/Textures";
    private const string DataDir = "Assets/Bundles/Map1/Data";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin =
        @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";

    // BspRender 会按这个顺序去要贴图（shader 名字去掉目录）
    private static readonly string[] Texs =
    {
        "c_dust2_damen2", "c_dust2_qiang06", "c_dust2_damen", "c_dust2_di02",
        "c_dust2_di01", "c_dust2_qiang05", "c_dust2_d13", "c_dust2_tianhuaban",
        "c_dust_d11", "c_dust2_qiang03", "c_dust2_qiang07", "c_dust2_neiqiang01",
        "c_dust2_qiang09", "c_dust2_di03", "c_dust2_qiang04", "c_dust2_qiang01",
        "c_dust2_metal1", "c_dust2_wood4", "c_dust2_wood3", "c_dust2_wood2",
        "c_dust2_wood1",
        "lightmap0", "map", "smallmapback",
        "skybox0", "skybox1", "skybox2", "skybox3", "skybox4", "skybox5",
    };

    [MenuItem("SSJJ/11. map1 原生资源 bundle (maps/map1)")]
    public static void Build()
    {
        AssetDatabase.Refresh();

        var assets = new List<string>();

        // ---- 贴图 ----
        int missing = 0;
        foreach (var n in Texs)
        {
            string p = TexDir + "/" + n + ".png";
            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(p);
            if (tex == null) { missing++; Debug.LogError("[MA] 贴图缺失: " + p); continue; }
            if (tex.name != n)
            {
                Debug.LogWarning("[MA] 贴图 asset name 与文件名不一致: " + tex.name + " != " + n);
            }
            assets.Add(p);
        }
        Debug.Log("[MA] textures=" + (Texs.Length - missing) + "/" + Texs.Length);

        // ---- model.bsp.raw（BspRender 走 GetMapData 时优先从 bundle 里取这个 TextAsset）----
        string bspPath = DataDir + "/model_bsp_raw.bytes";
        if (File.Exists(bspPath))
        {
            assets.Add(bspPath);
            Debug.Log("[MA] bsp included (from bundle)");
        }
        else
        {
            // streamingAssets 兜底（MapAssetLoader.GetMapData 的 candidates 里也有 map1/model.bsp.raw）
            Debug.Log("[MA] bsp 未打进 bundle（会走 StreamingAssets/map1/model.bsp.raw 兜底）");
        }

        if (missing > 0)
        {
            Debug.LogError("[MA] 有贴图缺失，终止打包");
            EditorApplication.Exit(1);
            return;
        }

        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(Path.Combine(outDir, "maps"));
        foreach (var f in Directory.GetFiles(Path.Combine(outDir, "maps"), "map1*"))
            File.Delete(f);

        var build = new AssetBundleBuild();
        build.assetBundleName = "maps/map1";
        build.assetNames = assets.ToArray();

        var manifest = BuildPipeline.BuildAssetBundles(
            outDir, new[] { build }, BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);
        if (manifest == null) { Debug.LogError("[MA] bundle build failed"); EditorApplication.Exit(1); return; }

        var built = Path.Combine(outDir, "maps", "map1");
        if (!File.Exists(built)) { Debug.LogError("[MA] bundle missing: " + built); EditorApplication.Exit(1); return; }

        var md5 = CalcMd5(built);
        var clientDir = Path.Combine(ClientWin, "maps");
        Directory.CreateDirectory(clientDir);
        foreach (var f in Directory.GetFiles(clientDir, "map1_*")) File.Delete(f);
        var deployed = Path.Combine(clientDir, "map1_" + md5);
        File.Copy(built, deployed, true);

        // 更新客户端 AssetBundles manifest
        var mfPath = Path.Combine(ClientWin, "AssetBundles");
        if (File.Exists(mfPath))
        {
            var txt = File.ReadAllText(mfPath);
            string entry = "<AssetBundle name=\"maps/map1\" md5=\"" + md5 + "\" crc=\"0\" />";
            var rx = @"<AssetBundle name=""maps/map1"" md5=""[0-9a-f]+"" crc=""0"" />";
            if (System.Text.RegularExpressions.Regex.IsMatch(txt, rx))
                txt = System.Text.RegularExpressions.Regex.Replace(txt, rx, entry);
            else
                txt = txt.Replace("</AssetBundles>", "  " + entry + "\n</AssetBundles>");
            File.WriteAllText(mfPath, txt);
            Debug.Log("[MA] manifest updated: " + entry);
        }

        Debug.Log("[MA] DONE md5=" + md5 + " bytes=" + new FileInfo(built).Length +
                  " assets=" + assets.Count + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
