using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// V5：用 Python 直出的 map43_bsp.asset（29 个 submesh，真实 BSP UV）建 map_3043 场景。
/// 不再经过 Unity 的 OBJ 导入器 —— 它会把所有 usemtl 合并成 1 个 submesh。
/// </summary>
public static class BuildMap43V5
{
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string MeshAsset = "Assets/Bundles/Map43/BSP/map43_bsp.asset";
    private const string TextureDir = "Assets/Bundles/Map43/Textures";
    private const string MaterialDir = "Assets/Bundles/Map43/Materials";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";

    // BSP info_player_start_T[0] 原值 ssjj(x,y,z)=(3350.26, 6918.96, 1653.54), yaw=-90
    // VectorCoordConverter.SsjjToUnity(x,y,z) = (-y, z, x)
    private static readonly Vector3 SpawnPos = new Vector3(-6918.96f, 1653.54f, 3350.26f);

    [MenuItem("SSJJ/9. V5 BSP asset 重建 map43")]
    public static void Build()
    {
        AssetDatabase.Refresh();

        var mesh = AssetDatabase.LoadAssetAtPath<Mesh>(MeshAsset);
        if (mesh == null)
        {
            Debug.LogError("[V5] mesh asset not readable (import failed?): " + MeshAsset);
            EditorApplication.Exit(1);
            return;
        }
        Debug.Log("[V5] mesh verts=" + mesh.vertexCount + " subs=" + mesh.subMeshCount +
                  " bounds=" + mesh.bounds + " uv=" + (mesh.uv == null ? 0 : mesh.uv.Length) +
                  " normals=" + (mesh.normals == null ? 0 : mesh.normals.Length));
        if (mesh.subMeshCount != 29)
        {
            Debug.LogError("[V5] expected 29 submeshes, got " + mesh.subMeshCount);
            EditorApplication.Exit(1);
            return;
        }
        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            var t = mesh.GetTriangles(i);
            if (t.Length == 0) Debug.LogError("[V5] submesh " + i + " empty");
            if (i < 3)
                Debug.Log("[V5] sub" + i + " tris=" + (t.Length / 3) +
                          " aabb=" + mesh.GetSubMesh(i).firstVertex + "+" + mesh.GetSubMesh(i).vertexCount);
        }

        var order = SubMeshOrder();
        Debug.Log("[V5] material order (" + order.Length + "): " + string.Join(",", order));

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var go = new GameObject("Map43_Geometry");
        go.transform.position = Vector3.zero;
        var mf = go.AddComponent<MeshFilter>();
        mf.sharedMesh = mesh;

        Directory.CreateDirectory(MaterialDir);
        var mats = new Material[mesh.subMeshCount];
        int matMissing = 0;
        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            var key = i < order.Length ? order[i] : ("sub" + i);
            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(TextureDir + "/" + key + ".png");
            if (tex == null) { matMissing++; Debug.LogWarning("[V5] texture missing: " + key); }
            var matPath = MaterialDir + "/BSP_" + key + ".mat";
            var mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
            if (mat == null)
            {
                mat = new Material(Shader.Find("Standard"));
                AssetDatabase.CreateAsset(mat, matPath);
            }
            mat.mainTexture = tex;
            mat.color = Color.white;
            float metal = 0.05f, smooth = 0.20f;
            if (key.StartsWith("gd_metal")) { metal = 0.75f; smooth = 0.60f; }
            else if (key.StartsWith("gd_d") || key == "gd_ggp") { metal = 0.02f; smooth = 0.12f; }
            else if (key == "gd_wood1" || key == "gd_sn") { metal = 0.02f; smooth = 0.25f; }
            mat.SetFloat("_Metallic", metal);
            mat.SetFloat("_Glossiness", smooth);
            // BSP 几何三角形绕序不保证与 Unity 一致，双面渲染避免整面被背面剔除
            mat.SetFloat("_Cull", 0f); // 0 = Off (CullMode.Off)
            if (mat.HasProperty("_CullMode")) mat.SetFloat("_CullMode", 0f);
            mat.doubleSidedGI = true;
            mats[i] = mat;
        }
        AssetDatabase.SaveAssets();

        var mr = go.AddComponent<MeshRenderer>();
        mr.sharedMaterials = mats;
        mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
        mr.receiveShadows = true;

        // 每个 submesh 一个独立的 MeshCollider —— V3 只有一个整体凸包，角色会卡住/滑落
        // 注意：必须把该 submesh 实际引用的顶点重映射成紧凑数组；直接复用全局 17210 个
        // 顶点而只引用其中几十个，PhysX cooking 会报 TriangleMesh::loadFromDesc isValid() failed。
        var allVerts = mesh.vertices;
        Debug.Log("[V5] allVerts=" + allVerts.Length + " expected=" + mesh.vertexCount);
        if (allVerts.Length != mesh.vertexCount)
        {
            Debug.LogWarning("[V5] vertices truncated, re-reading via MeshFilter mesh");
            allVerts = mf.sharedMesh.vertices;
        }
        int colCount = 0;
        int dropped = 0;
        int oobSkipped = 0;
        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            var tris = mesh.GetTriangles(i);
            if (tris.Length < 3) continue;
            var remap = new Dictionary<int, int>();
            var localVerts = new List<Vector3>();
            var localTris = new List<int>(tris.Length);
            for (int t = 0; t + 2 < tris.Length; t += 3)
            {
                int a = tris[t], b = tris[t + 1], c = tris[t + 2];
                // 跳过重复索引 / 退化三角形，PhysX 拒绝 cooking 这类面
                if (a < 0 || b < 0 || c < 0 ||
                    a >= allVerts.Length || b >= allVerts.Length || c >= allVerts.Length)
                { oobSkipped++; continue; }
                if (a == b || b == c || a == c) { dropped++; continue; }
                var pa = allVerts[a]; var pb = allVerts[b]; var pc = allVerts[c];
                var cross = Vector3.Cross(pb - pa, pc - pa);
                if (cross.sqrMagnitude < 1e-6f) { dropped++; continue; }
                localTris.Add(Map(remap, localVerts, allVerts, a));
                localTris.Add(Map(remap, localVerts, allVerts, b));
                localTris.Add(Map(remap, localVerts, allVerts, c));
            }
            if (localTris.Count < 3) continue;
            var sub = new Mesh { name = "collider_" + i };
            sub.SetVertices(localVerts);
            sub.SetTriangles(localTris, 0, true);
            sub.RecalculateBounds();
            var cgo = new GameObject("Col_" + i + "_" + (i < order.Length ? order[i] : ("sub" + i)));
            cgo.transform.SetParent(go.transform, false);
            var mc = cgo.AddComponent<MeshCollider>();
            mc.sharedMesh = sub;
            mc.convex = false;
            colCount++;
            if (i < 3)
                Debug.Log("[V5] col" + i + " verts=" + localVerts.Count + " tris=" + (localTris.Count / 3));
        }
        Debug.Log("[V5] degenerate tris dropped=" + dropped + " outOfRange=" + oobSkipped);
        Debug.Log("[V5] colliders=" + colCount + " materials=" + mats.Length + " missingTex=" + matMissing);

        go.isStatic = true;

        // 天空：BSP 自带的 skybox0..5 六面
        var sb = new Material(Shader.Find("Skybox/6 Sided"));
        var sides = new[] { "_FrontTex", "_BackTex", "_LeftTex", "_RightTex", "_UpTex", "_DownTex" };
        var skyNames = new[] { "skybox0", "skybox1", "skybox2", "skybox3", "skybox4", "skybox5" };
        int skyBound = 0;
        for (int i = 0; i < 6; i++)
        {
            var t = AssetDatabase.LoadAssetAtPath<Texture2D>(TextureDir + "/" + skyNames[i] + ".png");
            if (t != null) { sb.SetTexture(sides[i], t); skyBound++; }
        }
        sb.SetFloat("_Exposure", 1.0f);
        RenderSettings.skybox = sb;
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Trilight;
        RenderSettings.ambientSkyColor = new Color(0.60f, 0.64f, 0.70f);
        RenderSettings.ambientEquatorColor = new Color(0.50f, 0.48f, 0.46f);
        RenderSettings.ambientGroundColor = new Color(0.28f, 0.26f, 0.24f);
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.60f, 0.64f, 0.70f);
        RenderSettings.fogStartDistance = 6000f;
        RenderSettings.fogEndDistance = 18000f;
        QualitySettings.shadowDistance = 5000f;
        Debug.Log("[V5] skybox sides bound=" + skyBound + "/6");

        var lightGo = new GameObject("Sun");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.color = new Color(1f, 0.95f, 0.86f);
        light.intensity = 1.1f;
        light.shadows = LightShadows.Soft;
        light.shadowStrength = 0.8f;
        lightGo.transform.rotation = Quaternion.Euler(48f, -35f, 0f);

        var spawnGo = new GameObject("SpawnPoint");
        spawnGo.transform.position = SpawnPos;
        spawnGo.transform.rotation = Quaternion.Euler(0f, -90f, 0f);

        EditorSceneManager.SaveScene(scene, ScenePath);
        Debug.Log("[V5] scene saved spawn=" + SpawnPos);

        // ---- 打包 + 部署 ----
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
        if (manifest == null) { Debug.LogError("[V5] bundle build failed"); EditorApplication.Exit(1); return; }

        var built = Path.Combine(outDir, "unitymaps", "map_3043");
        if (!File.Exists(built)) { Debug.LogError("[V5] bundle missing: " + built); EditorApplication.Exit(1); return; }

        var md5 = CalcMd5(built);
        var clientDir = Path.Combine(ClientWin, "unitymaps");
        Directory.CreateDirectory(clientDir);
        foreach (var f in Directory.GetFiles(clientDir, "map_3043_*")) File.Delete(f);
        var deployed = Path.Combine(clientDir, "map_3043_" + md5);
        File.Copy(built, deployed, true);

        var manifestPath = Path.Combine(ClientWin, "AssetBundles");
        if (File.Exists(manifestPath))
        {
            var mfText = File.ReadAllText(manifestPath);
            mfText = System.Text.RegularExpressions.Regex.Replace(
                mfText, @"<AssetBundle name=""unitymaps/map_3043"" md5=""[0-9a-f]+"" crc=""0"" />",
                "<AssetBundle name=\"unitymaps/map_3043\" md5=\"" + md5 + "\" crc=\"0\" />");
            File.WriteAllText(manifestPath, mfText);
        }

        Debug.Log("[V5] DONE md5=" + md5 + " bundleBytes=" + new FileInfo(built).Length + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    private static int Map(Dictionary<int, int> remap, List<Vector3> localVerts,
                           Vector3[] allVerts, int src)
    {
        int dst;
        if (!remap.TryGetValue(src, out dst))
        {
            dst = localVerts.Count;
            remap[src] = dst;
            localVerts.Add(allVerts[src]);
        }
        return dst;
    }

    private static string[] SubMeshOrder()
    {
        // 与 bsp43_to_asset.py 写入 submesh 的顺序严格一致
        return new[]
        {
            "gd_d7","gd_d3","gd_d1","gd_d4","gd_d6","gd_q6","gd_ggp","gd_q10","gd_sn",
            "gd_q11","gd_p1","gd_q17","gd_q3","gd_q20","gd_d2","gd_q1","gd_q7","gd_q2",
            "gd_d5","gd_metal9","gd_metal8","gd_metal7","gd_metal6","gd_metal5","gd_metal4",
            "gd_metal3","gd_metal2","gd_metal1","gd_wood1"
        };
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
