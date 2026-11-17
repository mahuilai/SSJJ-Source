using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 用 Unity 自己的序列化器生成 Mesh .asset，再读回文本，作为 Python 侧写 YAML 的权威模板。
/// 先建带 2 个 submesh 的网格，AssetDatabase.CreateAsset 之后强制 text 序列化读原文。
/// </summary>
public static class DumpMeshYaml2
{
    [MenuItem("SSJJ/诊. 用 Unity 序列化器导出 Mesh 模板")]
    public static void Dump()
    {
        AssetDatabase.Refresh();
        var dir = Path.Combine(Directory.GetParent(Application.dataPath).FullName, "Game-SSJJ-logs");
        Directory.CreateDirectory(dir);

        var assetPath = "Assets/Bundles/Map43/BSP/_ref_mesh.asset";
        var abs = Path.Combine(Directory.GetParent(Application.dataPath).FullName, assetPath);
        if (File.Exists(abs)) File.Delete(abs);

        var m = new Mesh { name = "ref_mesh" };
        m.SetVertices(new System.Collections.Generic.List<Vector3>
        {
            new Vector3(0, 0, 0), new Vector3(1, 0, 0),
            new Vector3(1, 1, 0), new Vector3(0, 1, 0)
        });
        m.SetUVs(0, new System.Collections.Generic.List<Vector2>
        {
            new Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1)
        });
        m.subMeshCount = 2;
        m.SetTriangles(new[] { 0, 1, 2 }, 0, false);
        m.SetTriangles(new[] { 0, 2, 3 }, 1, false);
        m.RecalculateNormals();
        m.RecalculateBounds();

        AssetDatabase.CreateAsset(m, assetPath);
        AssetDatabase.SaveAssets();
        Debug.Log("[REF] created " + assetPath);

        var text = File.ReadAllText(abs);
        File.WriteAllText(Path.Combine(dir, "mesh_ref.txt"), text, new UTF8Encoding(false));
        var lines = text.Split('\n');
        Debug.Log("[REF] file lines=" + lines.Length + " bytes=" + text.Length +
                  " firstLine=" + lines[0].Trim() +
                  " hasVertexData=" + text.Contains("m_VertexData") +
                  " hasTypeless=" + text.Contains("_typelessdata"));

        // 打印关键区块，便于比对我的手写版本哪里不同
        var sb = new StringBuilder();
        bool grab = false;
        foreach (var raw in lines)
        {
            var l = raw.TrimEnd('\r');
            if (l.Contains("m_SubMeshes") || l.Contains("m_VertexData") || l.Contains("m_IndexBuffer"))
                grab = true;
            if (grab)
            {
                if (l.Length > 160) sb.AppendLine(l.Substring(0, 160) + " ...(" + l.Length + ")");
                else sb.AppendLine(l);
            }
            if (l.Contains("m_LocalAABB")) grab = false;
        }
        File.WriteAllText(Path.Combine(dir, "mesh_ref_excerpt.txt"), sb.ToString(), new UTF8Encoding(false));
        Debug.Log("[REF] excerpt written, len=" + sb.Length);

        var back = AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);
        Debug.Log("[REF] reload verts=" + (back == null ? -1 : back.vertexCount) +
                  " uv=" + (back == null || back.uv == null ? -1 : back.uv.Length) +
                  " subs=" + (back == null ? -1 : back.subMeshCount));
        EditorApplication.Exit(0);
    }
}
