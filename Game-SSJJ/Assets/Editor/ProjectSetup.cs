using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 一键生成启动场景 + 配置 Build Settings。
/// 用法（批处理）：
///   Unity.exe -batchmode -nographics -quit -projectPath <proj>
///             -executeMethod ProjectSetup.CreateBootScene -logFile <log>
/// </summary>
public static class ProjectSetup
{
    private const string ScenePath = "Assets/Scenes/Boot.unity";

    [MenuItem("SSJJ/1. 创建启动场景")]
    public static void CreateBootScene()
    {
        Directory.CreateDirectory("Assets/Scenes");

        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var camGo = new GameObject("Main Camera");
        var cam = camGo.AddComponent<Camera>();
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = new Color(0.05f, 0.06f, 0.08f);
        camGo.tag = "MainCamera";
        camGo.transform.position = new Vector3(0, 1, -5);

        var lightGo = new GameObject("Directional Light");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1f;
        lightGo.transform.rotation = Quaternion.Euler(50, -30, 0);

        var bootGo = new GameObject("Boot");
        bootGo.AddComponent<BootLoader>();

        EditorSceneManager.SaveScene(scene, ScenePath);

        EditorBuildSettings.scenes = new[]
        {
            new EditorBuildSettingsScene(ScenePath, true)
        };

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("[SSJJ-SP] boot scene created: " + ScenePath);
    }
}
