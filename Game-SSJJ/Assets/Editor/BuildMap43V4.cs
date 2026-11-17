using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// V4：直接用 Quake3 BSP 的 drawVert/drawIndex 重建 map43（双塔惊魂）。
/// 与 V3 的区别：
///   1. 几何已是 SSJJ 世界坐标（英寸，Y 向上），transform 恒等，不再旋转+放大；
///   2. 29 个材质组各是一个 submesh，每个 submesh 单独绑贴图；
///   3. 每个 submesh 单独生成一个 MeshCollider（V3 只有 1 个整体凸包，站不住）；
///   4. 出生点取 BSP 实体表 info_player_start_T[0]，不再硬编码。
/// </summary>
public static class BuildMap43V4
{
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string ObjPath = "Assets/Bundles/Map43/BSP/map43_bsp.obj";
    private const string TextureDir = "Assets/Bundles/Map43/Textures";
    private const string MaterialDir = "Assets/Bundles/Map43/Materials";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";

    // BSP info_player_start_T[0] 原值 (x,y,z)=(3350.26, 6918.96, 1653.54), yaw=-90
    // SSJJ 世界 = (x, z, y) 英寸
    private static readonly Vector3 SpawnPos = new Vector3(3350.26f, 1653.54f, 6918.96f);

    [MenuItem("SSJJ/8. V4 BSP 重建 map43")]
    public static void Build()
    {
        AssetDatabase.Refresh();

        var importer = AssetImporter.GetAtPath(ObjPath) as ModelImporter;
        if (importer == null)
        {
            Debug.LogError("[V4] OBJ importer missing (not imported yet): " + ObjPath);
            EditorApplication.Exit(1);
            return;
        }
        importer.globalScale = 1f;
        importer.useFileScale = true;
        importer.importMaterials = false;      // 材质自己建，别让 Unity 生成一堆空的
        importer.importNormals = ModelImporterNormals.Calculate;
        importer.importAnimation = false;
        importer.weldVertices = false;
        importer.SaveAndReimport();

        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(ObjPath);
        if (prefab == null)
        {
            Debug.LogError("[V4] OBJ load failed");
            EditorApplication.Exit(1);
            return;
        }

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var model = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        model.name = "Map43_Geometry";
        model.transform.position = Vector3.zero;
        model.transform.rotation = Quaternion.identity;
        model.transform.localScale = Vector3.one;

        var mf = model.GetComponentInChildren<MeshFilter>();
        if (mf == null || mf.sharedMesh == null)
        {
            Debug.LogError("[V4] no mesh in OBJ prefab");
            EditorApplication.Exit(1);
            return;
        }
        // 合并所有子物体到单一网格（OBJ 一般只有一个）
        var meshes = model.GetComponentsInChildren<MeshFilter>(true)
                          .Where(f => f.sharedMesh != null).Select(f => f.sharedMesh).ToArray();
        var mesh = meshes.Length == 1 ? meshes[0] : CombineMeshes(meshes);
        mesh.name = "map43_bsp";
        Debug.Log("[V4] subMeshes=" + mesh.subMeshCount + " verts=" + mesh.vertexCount +
                  " tris=" + (mesh.triangles.Length / 3) + " bounds=" + mesh.bounds);

        // ---- 1. 每个 submesh 一个 Material，绑定同名贴图 ----
        Directory.CreateDirectory(MaterialDir);
        var subs = mesh.subMeshCount;
        var mats = new Material[subs];
        var usedKeys = new List<string>();
        for (int i = 0; i < subs; i++)
        {
            var key = SubMeshKey(mesh, i);
            usedKeys.Add(key);
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
            float metal = 0.05f, smooth = 0.18f;
            if (key.StartsWith("gd_metal")) { metal = 0.80f; smooth = 0.62f; }
            else if (key.StartsWith("gd_d") || key == "gd_ggp") { metal = 0.02f; smooth = 0.10f; }
            else if (key == "gd_wood1") { metal = 0.02f; smooth = 0.22f; }
            mat.SetFloat("_Metallic", metal);
            mat.SetFloat("_Glossiness", smooth);
            mats[i] = mat;
            if (tex == null) Debug.LogWarning("[V4] texture missing for submesh " + i + " key=" + key);
        }
        AssetDatabase.SaveAssets();
        Debug.Log("[V4] submesh keys = " + string.Join(",", usedKeys.ToArray()));

        // ---- 2. 渲染器 + 每个 submesh 一个 MeshCollider ----
        var mr = model.GetComponent<MeshRenderer>();
        if (mr == null) mr = model.AddComponent<MeshRenderer>();
        mr.sharedMaterials = mats;
        mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
        mr.receiveShadows = true;

        for (int i = 0; i < subs; i++)
        {
            var go = new GameObject("Collider_" + i + "_" + usedKeys[i]);
            go.transform.SetParent(model.transform, false);
            var subMesh = new Mesh();
            subMesh.name = "collider_" + i;
            subMesh.SetVertices(mesh.vertices.ToList());
            subMesh.SetTriangles(mesh.GetTriangles(i), 0, true);
            subMesh.RecalculateBounds();
            var mc = go.AddComponent<MeshCollider>();
            mc.sharedMesh = subMesh;
            mc.convex = false;
        }
        Debug.Log("[V4] colliders=" + model.GetComponentsInChildren<MeshCollider>(true).Length +
                  " (one per submesh)");

        foreach (var go in model.GetComponentsInChildren<Transform>(true))
            go.gameObject.isStatic = true;

        // ---- 3. 光照：天空用 BSP 自带 skybox 贴图，环境光按 worldspawn ambient 30 ----
        var skyTex = AssetDatabase.LoadAssetAtPath<Texture2D>(TextureDir + "/skybox0.png");
        var sb = new Material(Shader.Find("Skybox/6 Sided"));
        if (skyTex != null)
        {
            for (int f = 0; f < 6; f++) sb.SetTexture(SideProp(f), skyTex);
        }
        sb.SetFloat("_Exposure", 1.0f);
        RenderSettings.skybox = sb;
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Trilight;
        RenderSettings.ambientSkyColor = new Color(0.62f, 0.66f, 0.72f);
        RenderSettings.ambientEquatorColor = new Color(0.52f, 0.50f, 0.48f);
        RenderSettings.ambientGroundColor = new Color(0.30f, 0.28f, 0.26f);
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.60f, 0.64f, 0.70f);
        RenderSettings.fogStartDistance = 5000f;
        RenderSettings.fogEndDistance = 16000f;
        QualitySettings.shadowDistance = 5000f;

        var lightGo = new GameObject("Sun");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.color = new Color(1f, 0.95f, 0.86f);
        light.intensity = 1.15f;
        light.shadows = LightShadows.Soft;
        light.shadowStrength = 0.8f;
        lightGo.transform.rotation = Quaternion.Euler(48f, -35f, 0f);

        // ---- 4. 出生点：BSP info_player_start_T[0] ----
        var spawnGo = new GameObject("SpawnPoint");
        spawnGo.transform.position = SpawnPos;
        spawnGo.transform.rotation = Quaternion.Euler(0f, -90f, 0f);
        var lamp = new GameObject("SpawnLamp");
        lamp.transform.position = SpawnPos + Vector3.up * 300f;
        var pl = lamp.AddComponent<Light>();
        pl.type = LightType.Point;
        pl.range = 1200f;
        pl.intensity = 1.2f;
        pl.color = new Color(1f, 0.93f, 0.82f);

        EditorSceneManager.SaveScene(scene, ScenePath);
        Debug.Log("[V4] scene saved " + ScenePath + " spawn=" + SpawnPos);

        // ---- 5. 打包 + 部署 ----
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
        if (manifest == null) { Debug.LogError("[V4] bundle build failed"); EditorApplication.Exit(1); return; }

        var built = Path.Combine(outDir, "unitymaps", "map_3043");
        if (!File.Exists(built)) { Debug.LogError("[V4] bundle missing: " + built); EditorApplication.Exit(1); return; }

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

        Debug.Log("[V4] DONE md5=" + md5 + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    private static string SideProp(int i)
    {
        switch (i)
        {
            case 0: return "_FrontTex";
            case 1: return "_BackTex";
            case 2: return "_LeftTex";
            case 3: return "_RightTex";
            case 4: return "_UpTex";
            default: return "_DownTex";
        }
    }

    private static string[] _subMeshNames;

    private static string SubMeshKey(Mesh mesh, int i)
    {
        if (_subMeshNames == null)
            _subMeshNames = ReadUsemtlOrder(ObjPath);
        if (i < _subMeshNames.Length) return _subMeshNames[i];
        Debug.LogWarning("[V4] submesh " + i + " has no usemtl entry, fallback gd_d1");
        return "gd_d1";
    }

    /// <summary>OBJ 里 usemtl 的出现顺序 = Unity 导入后的 submesh 顺序。</summary>
    private static string[] ReadUsemtlOrder(string objAssetPath)
    {
        var list = new List<string>();
        var abs = Path.Combine(Directory.GetParent(Application.dataPath).FullName, objAssetPath);
        string cur = null;
        foreach (var raw in File.ReadLines(abs))
        {
            if (!raw.StartsWith("usemtl")) continue;
            var parts = raw.Split(new[] { ' ', '\t' }, System.StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 2) continue;
            if (parts[1] == cur) continue;
            cur = parts[1];
            list.Add(cur);
        }
        Debug.Log("[V4] usemtl order (" + list.Count + "): " + string.Join(",", list.ToArray()));
        return list.ToArray();
    }

    private static Mesh CombineMeshes(Mesh[] meshes)
    {
        var combine = new CombineInstance[meshes.Length];
        for (int i = 0; i < meshes.Length; i++)
            combine[i].mesh = meshes[i];
        var m = new Mesh();
        m.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
        m.CombineMeshes(combine, true, false);
        return m;
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
