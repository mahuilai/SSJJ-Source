using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

/// <summary>Build and install the KitBash3D Luminara environment as playable map3102.</summary>
public static class BuildLuminaraBundles
{
    private const string FbxPath = "Assets/Luminara/Models/LuminaraCourse.fbx";
    private const string TextureDir = "Assets/Luminara/Textures/";
    private const string MaterialDir = "Assets/Luminara/Materials/";
    private const string ScenePath = "Assets/Bundles/Scenes/map_3102.unity";
    private const string BspPath = "Assets/Luminara/MapData/model.bsp.raw.bytes";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientRoot = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";
    private const string ClientStreaming = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets";
    private const string ServerSolid = @"D:\逆向\SSJJ双塔惊魂\SSJJ-Server\Data\Maps\map3102_solid.json";

    [MenuItem("SSJJ/Luminara/Build + install playable map 3102")]
    public static void BuildAndInstall()
    {
        try
        {
            if (EditorApplication.isPlaying)
                throw new InvalidOperationException("Exit Play Mode before building map3102.");
            if (!File.Exists(FbxPath) || !File.Exists(BspPath) || !File.Exists(ServerSolid))
                throw new FileNotFoundException("Run build_luminara_course.py and build_luminara_bsp.py first.");

            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            CreateScene();
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

            string outDir = Path.GetFullPath(BundleRoot);
            Directory.CreateDirectory(outDir);
            var builds = new[]
            {
                new AssetBundleBuild { assetBundleName = "unitymaps/map_3102", assetNames = new[] { ScenePath } },
                new AssetBundleBuild { assetBundleName = "maps/map3102", assetNames = new[] { BspPath } }
            };
            var manifest = BuildPipeline.BuildAssetBundles(outDir, builds,
                BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.StandaloneWindows64);
            if (manifest == null) throw new InvalidOperationException("Unity returned no AssetBundleManifest.");

            string sceneBundle = Path.Combine(outDir, "unitymaps", "map_3102");
            string bspBundle = Path.Combine(outDir, "maps", "map3102");
            if (!File.Exists(sceneBundle) || !File.Exists(bspBundle))
                throw new FileNotFoundException("Expected map3102 bundles are missing after the Unity build.");
            string manifestPath = Path.Combine(ClientRoot, "AssetBundles");
            if (!Directory.Exists(ClientRoot) || !File.Exists(manifestPath))
                throw new DirectoryNotFoundException("Offline client bundle directory or manifest is missing: " + ClientRoot);

            string sceneMd5 = CopyHashed(sceneBundle, ClientRoot, "unitymaps", "map_3102");
            string bspMd5 = CopyHashed(bspBundle, ClientRoot, "maps", "map3102");
            string manifestText = File.ReadAllText(manifestPath, Encoding.UTF8);
            string updated = UpsertEntry(manifestText, "unitymaps/map_3102", sceneMd5);
            updated = UpsertEntry(updated, "maps/map3102", bspMd5);
            if (updated != manifestText)
            {
                string backup = manifestPath + ".before-map3102";
                if (!File.Exists(backup)) File.Copy(manifestPath, backup);
                File.WriteAllText(manifestPath, updated, new UTF8Encoding(false));
            }

            string rawDir = Path.Combine(ClientStreaming, "map3102");
            Directory.CreateDirectory(rawDir);
            File.Copy(BspPath, Path.Combine(rawDir, "model.bsp.raw"), true);
            Debug.Log("[Luminara] map3102 installed. unitymaps/map_3102 md5=" + sceneMd5 +
                      " maps/map3102 md5=" + bspMd5 + " spawn is sourced from luminara_map_layout.json; " +
                      "all visible mesh renderers have MeshColliders and BSP convex proxies.");
            EditorApplication.Exit(0);
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
            EditorApplication.Exit(1);
        }
    }

    private static void CreateScene()
    {
        if (AssetDatabase.LoadAssetAtPath<GameObject>(FbxPath) == null)
            throw new FileNotFoundException("Unity did not import the Luminara FBX: " + FbxPath);
        Directory.CreateDirectory("Assets/Bundles/Scenes");
        Directory.CreateDirectory(MaterialDir);
        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        GameObject modelAsset = AssetDatabase.LoadAssetAtPath<GameObject>(FbxPath);
        GameObject root = UnityEngine.Object.Instantiate(modelAsset);
        root.name = "LuminaraCourse";
        SceneManager.MoveGameObjectToScene(root, scene);
        // KitBash3D source meshes are authored in Blender metres, while this
        // game's BSP, player and Unity-render scene coordinates use centimetres.
        // Keep the render scene on the exact same scale as the BSP collision.
        root.transform.localScale = Vector3.one * 100f;

        var importedMaterials = new Dictionary<string, Material>(StringComparer.OrdinalIgnoreCase);
        foreach (UnityEngine.Object asset in AssetDatabase.LoadAllAssetsAtPath(FbxPath))
        {
            Material material = asset as Material;
            if (material != null && !importedMaterials.ContainsKey(material.name))
                importedMaterials.Add(material.name, material);
        }
        var convertedMaterials = new Dictionary<string, Material>(StringComparer.OrdinalIgnoreCase);
        int colliderCount = 0;
        int rendererCount = 0;
        foreach (MeshFilter filter in root.GetComponentsInChildren<MeshFilter>(true))
        {
            if (filter.sharedMesh == null) continue;
            MeshRenderer renderer = filter.GetComponent<MeshRenderer>();
            if (renderer == null) continue;
            rendererCount++;
            Material[] sourceMaterials = renderer.sharedMaterials;
            var finalMaterials = new Material[sourceMaterials.Length];
            for (int i = 0; i < sourceMaterials.Length; i++)
            {
                string materialName = sourceMaterials[i] != null ? sourceMaterials[i].name : "Luminara_Stone";
                Material source;
                importedMaterials.TryGetValue(materialName, out source);
                Material converted;
                if (!convertedMaterials.TryGetValue(materialName, out converted))
                {
                    converted = CreateTexturedMaterial(materialName, source);
                    convertedMaterials.Add(materialName, converted);
                }
                finalMaterials[i] = converted;
            }
            renderer.sharedMaterials = finalMaterials;

            MeshCollider collider = filter.GetComponent<MeshCollider>();
            if (collider == null) collider = filter.gameObject.AddComponent<MeshCollider>();
            collider.sharedMesh = filter.sharedMesh;
            collider.convex = false;
            colliderCount++;
        }

        var lightObject = new GameObject("Luminara_WarmSun", typeof(Light));
        SceneManager.MoveGameObjectToScene(lightObject, scene);
        lightObject.transform.rotation = Quaternion.Euler(42f, -28f, 0f);
        Light sun = lightObject.GetComponent<Light>();
        sun.type = LightType.Directional;
        sun.color = new Color(1.0f, 0.86f, 0.68f);
        sun.intensity = 1.15f;
        sun.shadows = LightShadows.Soft;
        sun.shadowStrength = 0.72f;

        RenderSettings.ambientMode = AmbientMode.Trilight;
        RenderSettings.ambientSkyColor = new Color(0.28f, 0.38f, 0.58f);
        RenderSettings.ambientEquatorColor = new Color(0.29f, 0.30f, 0.34f);
        RenderSettings.ambientGroundColor = new Color(0.10f, 0.09f, 0.08f);
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.12f, 0.17f, 0.27f);
        RenderSettings.fogStartDistance = 22000f;
        RenderSettings.fogEndDistance = 52000f;
        const string skyTexturePath = "Assets/Luminara/Textures/Luminara_Skybox.png";
        TextureImporter skyImporter = AssetImporter.GetAtPath(skyTexturePath) as TextureImporter;
        if (skyImporter != null)
        {
            if (skyImporter.textureType != TextureImporterType.Default ||
                skyImporter.wrapMode != TextureWrapMode.Repeat || skyImporter.maxTextureSize != 2048)
            {
                skyImporter.textureType = TextureImporterType.Default;
                skyImporter.wrapMode = TextureWrapMode.Repeat;
                skyImporter.maxTextureSize = 2048;
                skyImporter.SaveAndReimport();
            }
        }
        Texture2D skyTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(skyTexturePath);
        Shader skyShader = Shader.Find("Skybox/Panoramic");
        if (skyTexture != null && skyShader != null)
        {
            string skyPath = MaterialDir + "Luminara_Skybox.mat";
            Material sky = AssetDatabase.LoadAssetAtPath<Material>(skyPath);
            if (sky == null)
            {
                sky = new Material(skyShader);
                AssetDatabase.CreateAsset(sky, skyPath);
            }
            sky.shader = skyShader;
            sky.SetTexture("_MainTex", skyTexture);
            sky.SetFloat("_Exposure", 0.72f);
            if (sky.HasProperty("_Rotation")) sky.SetFloat("_Rotation", 0f);
            if (sky.HasProperty("_Mapping")) sky.SetFloat("_Mapping", 0f);
            RenderSettings.skybox = sky;
        }
        EditorSceneManager.SaveScene(scene, ScenePath);
        Debug.Log("[Luminara] Scene saved with mesh renderers=" + rendererCount +
                  " MeshColliders=" + colliderCount + " rootScale=100 (cm) textured materials=" + convertedMaterials.Count);
    }

    private static Material CreateTexturedMaterial(string name, Material source)
    {
        string safeName = Regex.Replace(name, "[^A-Za-z0-9_ -]", "_");
        string assetPath = MaterialDir + safeName + ".mat";
        Material material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
        if (material == null)
        {
            Shader shader = source != null && source.shader != null && source.shader.isSupported
                ? source.shader : Shader.Find("Standard");
            material = source != null ? new Material(source) : new Material(shader);
            material.name = name;
            AssetDatabase.CreateAsset(material, assetPath);
        }
        Texture2D baseColor = LoadTexture(name + "_basecolor.png", false);
        Texture2D normal = LoadTexture(name + "_normal.png", true);
        Texture2D metallic = LoadTexture(name + "_metallic.png", false);
        if (baseColor != null && material.HasProperty("_MainTex")) material.SetTexture("_MainTex", baseColor);
        if (normal != null && material.HasProperty("_BumpMap"))
        {
            material.SetTexture("_BumpMap", normal);
            material.EnableKeyword("_NORMALMAP");
        }
        if (metallic != null && material.HasProperty("_MetallicGlossMap"))
        {
            material.SetTexture("_MetallicGlossMap", metallic);
            material.EnableKeyword("_METALLICGLOSSMAP");
        }
        if (material.HasProperty("_Glossiness")) material.SetFloat("_Glossiness", 0.22f);
        EditorUtility.SetDirty(material);
        return material;
    }

    private static Texture2D LoadTexture(string filename, bool normalMap)
    {
        string path = TextureDir + filename;
        Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        if (texture == null) return null;
        TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
        if (importer != null)
        {
            TextureImporterType type = normalMap ? TextureImporterType.NormalMap : TextureImporterType.Default;
            if (importer.textureType != type)
            {
                importer.textureType = type;
                importer.SaveAndReimport();
                texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
            }
        }
        return texture;
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
            "<AssetBundle\\b(?=[^>]*\\bname=\"" + escaped + "\")[^>]*/>", RegexOptions.IgnoreCase);
        if (match.Success)
        {
            string item = match.Value;
            if (Regex.IsMatch(item, "\\bmd5=\"[0-9a-f]+\"", RegexOptions.IgnoreCase))
                item = Regex.Replace(item, "\\bmd5=\"[0-9a-f]+\"", "md5=\"" + md5 + "\"", RegexOptions.IgnoreCase);
            else item = item.Substring(0, item.Length - 2) + " md5=\"" + md5 + "\" />";
            return xml.Substring(0, match.Index) + item + xml.Substring(match.Index + match.Length);
        }
        int end = xml.LastIndexOf("</AssetBundles>", StringComparison.OrdinalIgnoreCase);
        if (end < 0) throw new InvalidDataException("AssetBundles closing tag was not found.");
        string entry = "  <AssetBundle name=\"" + name + "\" md5=\"" + md5 + "\" crc=\"0\" />\r\n";
        return xml.Substring(0, end) + entry + xml.Substring(end);
    }
}
