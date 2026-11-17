using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

/// <summary>
/// 命令行构建 Windows x64。
/// 用法：
///   Unity.exe -batchmode -nographics -quit -projectPath <proj>
///             -executeMethod BuildGame.BuildWin64 -logFile <log>
/// 产物：Build/SSJJ-SP/SSJJ-SP.exe
/// </summary>
public static class BuildGame
{
    [MenuItem("SSJJ/2. 构建 Windows64")]
    public static void BuildWin64()
    {
        var outDir = Path.GetFullPath("Build/SSJJ-SP");
        Directory.CreateDirectory(outDir);
        var exe = Path.Combine(outDir, "SSJJ-SP.exe");

        var scenes = new[] { "Assets/Scenes/Boot.unity" };
        foreach (var s in scenes)
        {
            if (!File.Exists(s))
            {
                Debug.LogError("[SSJJ-SP] missing scene " + s + "，先跑 ProjectSetup.CreateBootScene");
                EditorApplication.Exit(2);
                return;
            }
        }

        var options = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = exe,
            target = BuildTarget.StandaloneWindows64,
            options = BuildOptions.None
        };

        var report = BuildPipeline.BuildPlayer(options);
        var summary = report.summary;
        Debug.Log(string.Format(
            "[SSJJ-SP] BUILD_RESULT={0} size={1} bytes errors={2} warnings={3} time={4}",
            summary.result, summary.totalSize, summary.totalErrors, summary.totalWarnings, summary.totalTime));

        if (summary.result != BuildResult.Succeeded)
            EditorApplication.Exit(1);
    }
}
