using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>Builds the standalone Neon Skyrail parkour scene.</summary>
public static class BuildParkourCourse
{
    private const string CollisionPath = "Assets/Parkour/ParkourCollision.obj";
    private const string ScenePath = "Assets/Parkour/NeonSkyrail.unity";
    private static readonly string[] VisualMaterials =
    {
        "deck_circuit", "deck_grate", "deck_hazard",
        "deep_navy", "steel", "cyan", "amber", "lime", "violet", "white", "hazard"
    };

    [MenuItem("SSJJ/Parkour/Build Neon Skyrail Scene")]
    public static void Build()
    {
        AssetDatabase.Refresh();
        foreach (var materialName in VisualMaterials)
            ConfigureObj("Assets/Parkour/ParkourCourse_" + materialName + ".obj", false);
        ConfigureObj(CollisionPath, false);
        var collisionPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(CollisionPath);
        if (collisionPrefab == null)
        {
            Debug.LogError("[Parkour] Collision OBJ import failed; run Game-SSJJ/tools/build_parkour_course.py first.");
            return;
        }

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var root = new GameObject("NeonSkyrail");
        var visual = new GameObject("Course_Visuals");
        visual.transform.SetParent(root.transform, false);
        foreach (var materialName in VisualMaterials)
        {
            var visualPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(
                "Assets/Parkour/ParkourCourse_" + materialName + ".obj");
            if (visualPrefab == null)
            {
                Debug.LogError("[Parkour] Missing visual OBJ for material " + materialName + ". Run build_parkour_course.py first.");
                return;
            }
            var materialObject = (GameObject)PrefabUtility.InstantiatePrefab(visualPrefab);
            materialObject.name = materialName;
            materialObject.transform.SetParent(visual.transform, false);
            ApplyVisualMaterial(materialObject, materialName);
        }
        var collision = (GameObject)PrefabUtility.InstantiatePrefab(collisionPrefab);
        collision.name = "Course_Collision";
        collision.transform.SetParent(root.transform, false);
        foreach (var renderer in collision.GetComponentsInChildren<Renderer>(true))
            Object.DestroyImmediate(renderer);
        foreach (var filter in collision.GetComponentsInChildren<MeshFilter>(true))
        {
            if (filter.sharedMesh == null) continue;
            var collider = filter.gameObject.GetComponent<MeshCollider>();
            if (collider == null) collider = filter.gameObject.AddComponent<MeshCollider>();
            collider.sharedMesh = filter.sharedMesh;
            collider.convex = false;
        }

        var spawn = new GameObject("SpawnPoint");
        spawn.transform.SetParent(root.transform, false);
        spawn.transform.position = new Vector3(0f, 250f, 0f);
        spawn.transform.rotation = Quaternion.identity;
        var startMarker = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        startMarker.name = "Spawn_Marker";
        startMarker.transform.SetParent(spawn.transform, false);
        startMarker.transform.localPosition = new Vector3(0f, 15f, 0f);
        startMarker.transform.localScale = new Vector3(18f, 2f, 18f);
        Object.DestroyImmediate(startMarker.GetComponent<Collider>());

        var lightObject = new GameObject("Skyrail_Key_Light");
        var light = lightObject.AddComponent<Light>();
        light.type = LightType.Directional;
        light.color = new Color(0.72f, 0.82f, 1f);
        light.intensity = 1.45f;
        lightObject.transform.rotation = Quaternion.Euler(35f, -30f, 0f);
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        RenderSettings.ambientLight = new Color(0.68f, 0.70f, 0.80f);
        var skyTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Parkour/Textures/NeonSkyrail_Skybox.png");
        var panoramicShader = Shader.Find("Skybox/Panoramic");
        if (skyTexture != null && panoramicShader != null)
        {
            var skyMaterial = new Material(panoramicShader);
            skyMaterial.SetTexture("_MainTex", skyTexture);
            skyMaterial.SetFloat("_Exposure", 1.1f);
            RenderSettings.skybox = skyMaterial;
        }
        RenderSettings.fog = true;
        RenderSettings.fogColor = new Color(0.008f, 0.014f, 0.045f);
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogStartDistance = 30000f;
        RenderSettings.fogEndDistance = 50000f;

        var cameraObject = new GameObject("Parkour_Preview_Camera");
        var camera = cameraObject.AddComponent<Camera>();
        camera.tag = "MainCamera";
        camera.fieldOfView = 64f;
        camera.farClipPlane = 50000f;
        cameraObject.transform.position = new Vector3(-8000f, 8500f, -5000f);
        cameraObject.transform.LookAt(new Vector3(0f, 1200f, 19500f));

        EditorSceneManager.SaveScene(scene, ScenePath);
        AssetDatabase.SaveAssets();
        Debug.Log("[Parkour] Neon Skyrail scene saved: " + ScenePath);
    }

    private static void ConfigureObj(string path, bool materials)
    {
        var importer = AssetImporter.GetAtPath(path) as ModelImporter;
        if (importer == null) return;
        importer.globalScale = 1f;
        importer.useFileScale = false;
        importer.materialImportMode = materials
            ? ModelImporterMaterialImportMode.ImportStandard
            : ModelImporterMaterialImportMode.None;
        importer.materialName = ModelImporterMaterialName.BasedOnMaterialName;
        importer.materialSearch = ModelImporterMaterialSearch.Local;
        importer.importAnimation = false;
        importer.meshCompression = ModelImporterMeshCompression.Medium;
        importer.SaveAndReimport();
    }

    private static void ApplyVisualMaterial(GameObject visual, string materialName)
    {
        Directory.CreateDirectory("Assets/Parkour/Materials");
        string assetPath = "Assets/Parkour/Materials/Skyrail_" + materialName + ".mat";
        var material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
        if (material == null)
        {
            var shader = Shader.Find("Standard");
            if (shader == null) return;
            material = new Material(shader);
            AssetDatabase.CreateAsset(material, assetPath);
        }

        Color tint = Color.white;
        Color glow = Color.black;
        string textureName = null;
        switch (materialName)
        {
            case "deck_circuit": textureName = "Skyrail_CircuitDeck.png"; break;
            case "deck_grate": textureName = "Skyrail_HexGrate.png"; break;
            case "deck_hazard": textureName = "Skyrail_HazardDeck.png"; break;
            case "deep_navy": textureName = "Map101_S_city_06.png"; break;
            case "steel": textureName = "Map101_S_city_01.png"; break;
            case "cyan": glow = new Color(0.025f, 0.055f, 0.07f); textureName = "Map101_S_city_02.png"; break;
            case "amber": glow = new Color(0.035f, 0.02f, 0.004f); textureName = "Map101_S_city_04.png"; break;
            case "lime": glow = new Color(0.02f, 0.035f, 0.01f); textureName = "Map101_S_city_12.png"; break;
            case "violet": glow = new Color(0.025f, 0.01f, 0.04f); textureName = "Map101_S_city_08.png"; break;
            case "white": glow = new Color(0.03f, 0.05f, 0.06f); textureName = "Map101_S_city_13.png"; break;
            case "hazard": glow = new Color(0.035f, 0.015f, 0.003f); textureName = "Map101_S_city_04.png"; break;
        }
        material.color = tint;
        material.SetFloat("_Metallic", 0.10f);
        material.SetFloat("_Glossiness", 0.36f);
        if (textureName != null)
        {
            var texture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Parkour/Textures/" + textureName);
            if (texture != null) material.mainTexture = texture;
        }
        if (material.HasProperty("_EmissionColor"))
        {
            material.EnableKeyword("_EMISSION");
            material.SetColor("_EmissionColor", glow);
        }
        EditorUtility.SetDirty(material);
        foreach (var renderer in visual.GetComponentsInChildren<Renderer>(true))
            renderer.sharedMaterial = material;
        AssetDatabase.SaveAssets();
    }
}

