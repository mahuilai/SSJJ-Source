using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 首次运行：用 Unity 序列化器生成 Mesh .asset，再读回文本，作为 Python 侧写 YAML 的权威模板。
/// 先建带 2 个 submesh 的网格，AssetDatabase.CreateAsset 之后强制 text 序列化读原文。
/// 之后 OpenMap43：打开工程 + 刷新资产 + 报告网格是否可读，供批量流程复用。
/// </summary>
public static class Map43Pipeline
{
    private const string AssetPath = "Assets/Bundles/Map43/BSP/_ref_mesh.asset";

    [MenuItem("SSJJ/诊. 用 Unity 序列化器导出 Mesh 模板")]
    public static void DumpRef()
    {
        AssetDatabase.Refresh();
        var dir = Path.Combine(Directory.GetParent(Application.dataPath).FullName, "Game-SSJJ-logs");
        Directory.CreateDirectory(dir);

        var abs = Path.Combine(Directory.GetParent(Application.dataPath).FullName, AssetPath);
        if (File.Exists(abs)) File.Delete(abs);

        var m = new Mesh { name = "ref_mesh" };
        m.SetVertices(new List<Vector3>
        {
            new Vector3(0, 0, 0), new Vector3(1, 0, 0),
            new Vector3(1, 1, 0), new Vector3(0, 1, 0)
        });
        m.SetUVs(0, new List<Vector2>
        {
            new Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1)
        });
        m.subMeshCount = 2;
        m.SetTriangles(new[] { 0, 1, 2 }, 0, false);
        m.SetTriangles(new[] { 0, 2, 3 }, 1, false);
        m.RecalculateNormals();
        m.RecalculateBounds();

        AssetDatabase.CreateAsset(m, AssetPath);
        AssetDatabase.SaveAssets();
        var text = File.ReadAllText(abs);
        File.WriteAllText(Path.Combine(dir, "mesh_ref.txt"), text, new UTF8Encoding(false));
        Debug.Log("[REF] wrote mesh_ref.txt len=" + text.Length);
        EditorApplication.Exit(0);
    }
}
