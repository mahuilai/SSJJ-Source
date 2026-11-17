using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 把已提取的 map43（双塔惊魂）重建成本机 Unity 场景，并打成 unitymaps/map_3043。
/// 素材来源：D:\逆向\SSJJ双塔惊魂\extracted\maps\map43
/// </summary>
public static class BuildMap43
{
    private const string SrcRoot = @"D:\逆向\SSJJ双塔惊魂\extracted\maps\map43";
    private const string AssetRoot = "Assets/Bundles/Map43";
    private const string ModelDir = AssetRoot + "/Model";
    private const string TexDir = AssetRoot + "/Textures";
    private const string ScenePath = "Assets/Bundles/Scenes/map_3043.unity";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const float UnitScale = 0.0254f;   // Quake/BSP 单位(英寸) → 米

    [MenuItem("SSJJ/4. 构建 map43 单机地图")]
    public static void Build()
    {
        Directory.CreateDirectory(ScenePath.Substring(0, ScenePath.LastIndexOf('/')));

        CopySource();

        var objPath = ModelDir + "/map43_full.obj";
        var importer = AssetImporter.GetAtPath(objPath) as ModelImporter;
        if (importer == null)
        {
            AssetDatabase.ImportAsset(objPath, ImportAssetOptions.ForceUpdate);
            importer = AssetImporter.GetAtPath(objPath) as ModelImporter;
        }
        if (importer == null)
        {
            Debug.LogError("[SSJJ-SP] OBJ 导入失败: " + objPath);
            EditorApplication.Exit(1);
            return;
        }
        importer.globalScale = UnitScale;
        importer.importMaterials = true;
        importer.importNormals = ModelImporterNormals.Import;
        importer.SaveAndReimport();

        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(objPath);
        if (prefab == null)
        {
            Debug.LogError("[SSJJ-SP] 加载模型失败");
            EditorApplication.Exit(1);
            return;
        }

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var lightGo = new GameObject("Directional Light");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1.3f;
        light.shadows = LightShadows.Soft;
        lightGo.transform.rotation = Quaternion.Euler(55, -35, 0);

        var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        instance.name = "MapGeometry";

        // 碰撞
        int colliders = 0;
        foreach (var mf in instance.GetComponentsInChildren<MeshFilter>())
        {
            if (mf.sharedMesh == null) continue;
            var mc = mf.gameObject.GetComponent<MeshCollider>();
            if (mc == null) mc = mf.gameObject.AddComponent<MeshCollider>();
            mc.sharedMesh = mf.sharedMesh;
            mc.convex = false;
            colliders++;
        }

        // 贴图绑定：按 usemtl 顺序（= 子网格顺序）配 材质/贴图
        var mapJson = AssetRoot + "/material_map.json";
        var subMeshes = LoadMaterialMap(mapJson);
        int bound = 0;
        foreach (var mr in instance.GetComponentsInChildren<MeshRenderer>())
        {
            var mesh = mr.GetComponent<MeshFilter>() != null ? mr.GetComponent<MeshFilter>().sharedMesh : null;
            int count = mesh != null ? mesh.subMeshCount : subMeshes.Count;
            var mats = new Material[count];
            for (int i = 0; i < count; i++)
            {
                var tex = i < subMeshes.Count ? subMeshes[i] : null;
                var m = new Material(Shader.Find("Standard"));
                m.name = "map43_" + i;
                if (tex != null) { m.mainTexture = tex; bound++; }
                mats[i] = m;
            }
            mr.sharedMaterials = mats;
        }
        Debug.Log("[SSJJ-SP] colliders=" + colliders + " textures_bound=" + bound);

        // 出生点：包围盒中心上方
        var bounds = new Bounds(instance.transform.position, Vector3.zero);
        foreach (var r in instance.GetComponentsInChildren<Renderer>())
            bounds.Encapsulate(r.bounds);

        var spawn = new GameObject("PlayerSpawn");
        spawn.transform.position = new Vector3(bounds.center.x, bounds.max.y - 5f, bounds.center.z);

        // 兜底地板，防止掉出地图
        var floor = GameObject.CreatePrimitive(PrimitiveType.Plane);
        floor.name = "SafetyFloor";
        floor.transform.position = new Vector3(bounds.center.x, bounds.min.y - 0.5f, bounds.center.z);
        floor.transform.localScale = new Vector3(bounds.size.x / 10f, 1, bounds.size.z / 10f);
        var fr = floor.GetComponent<MeshRenderer>();
        if (fr != null) fr.enabled = false;

        EditorSceneManager.SaveScene(scene, ScenePath);
        var si = AssetImporter.GetAtPath(ScenePath);
        si.assetBundleName = "unitymaps/map_3043";
        si.SaveAndReimport();

        Debug.Log("[SSJJ-SP] scene saved, bounds=" + bounds.size + " spawn=" + spawn.transform.position);

        // 打包（含 tables，见 BuildBundles）
        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);
        var manifest = BuildPipeline.BuildAssetBundles(
            outDir, BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.StandaloneWindows64);
        if (manifest == null)
        {
            Debug.LogError("[SSJJ-SP] 打包失败");
            EditorApplication.Exit(1);
            return;
        }
        foreach (var b in manifest.GetAllAssetBundles())
            Debug.Log("[SSJJ-SP] bundle: " + b);
        Debug.Log("[SSJJ-SP] map43 bundle ready: unitymaps/map_3043 -> " + outDir);
    }

    private static void CopySource()
    {
        Directory.CreateDirectory(ModelDir);
        Directory.CreateDirectory(TexDir);

        var obj = Path.Combine(SrcRoot, @"godot_environment\map43_full.obj");
        var mtl = Path.Combine(SrcRoot, @"godot_environment\map43_full.mtl");
        if (!File.Exists(obj)) { Debug.LogError("[SSJJ-SP] 缺 " + obj); return; }

        File.Copy(obj, Path.Combine(ModelDir, "map43_full.obj"), true);
        if (File.Exists(mtl)) File.Copy(mtl, Path.Combine(ModelDir, "map43_full.mtl"), true);

        var texRoot = Path.Combine(SrcRoot, "textures");
        if (Directory.Exists(texRoot))
            foreach (var f in Directory.GetFiles(texRoot, "*.png"))
                File.Copy(f, Path.Combine(TexDir, Path.GetFileName(f)), true);

        AssetDatabase.Refresh();
    }

    private static List<Texture2D> LoadMaterialMap(string jsonPath)
    {
        var list = new List<Texture2D>();
        if (!File.Exists(Path.GetFullPath(jsonPath)))
        {
            Debug.LogWarning("[SSJJ-SP] 缺 material_map.json: " + jsonPath);
            return list;
        }
        var text = File.ReadAllText(jsonPath);
        var wrapped = "{\"items\":" + text + "}";
        var data = JsonUtility.FromJson<MatMapWrapper>(wrapped);
        if (data == null || data.items == null) return list;

        var guids = AssetDatabase.FindAssets("t:Texture2D", new[] { TexDir });
        var byName = new Dictionary<string, Texture2D>();
        foreach (var g in guids)
        {
            var p = AssetDatabase.GUIDToAssetPath(g);
            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(p);
            if (tex != null) byName[Path.GetFileNameWithoutExtension(p).ToLower()] = tex;
        }
        foreach (var it in data.items)
        {
            Texture2D tex = null;
            if (!string.IsNullOrEmpty(it.texture))
                byName.TryGetValue(Path.GetFileNameWithoutExtension(it.texture).ToLower(), out tex);
            list.Add(tex);
        }
        Debug.Log("[SSJJ-SP] material_map entries=" + list.Count + " textures=" + byName.Count);
        return list;
    }

    [System.Serializable]
    private class MatMapItem { public string material; public string texture; }

    [System.Serializable]
    private class MatMapWrapper { public MatMapItem[] items; }
}
