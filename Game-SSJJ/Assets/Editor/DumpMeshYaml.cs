using System.Globalization;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 手工构造 UnityEngine.Mesh 的 YAML 文本（Unity 2019.4 格式），
/// 供 Python 侧批量生成带多个 submesh 的地图网格 .asset。
/// 同时导出一份带 2 个 submesh 的样例用于校验读取链路。
/// </summary>
public static class DumpMeshYaml
{
    [MenuItem("SSJJ/诊. 导出 Mesh YAML 模板")]
    public static void Dump()
    {
        AssetDatabase.Refresh();
        var dir = Path.Combine(Directory.GetParent(Application.dataPath).FullName, "Game-SSJJ-logs");
        Directory.CreateDirectory(dir);

        // 样例：一个正方形，2 个 submesh（各 1 个三角形），带 UV
        var m = new Mesh { name = "yaml_sample" };
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

        var text = Marshal(m);
        File.WriteAllText(Path.Combine(dir, "mesh_template.txt"), text, new UTF8Encoding(false));
        Debug.Log("[DUMP] verts=" + m.vertexCount + " subs=" + m.subMeshCount +
                  " len=" + text.Length + " -> " + Path.Combine(dir, "mesh_template.txt"));

        // 回读校验：把文本写成真 .asset 再让 Unity 导入，确认能解析
        var assetPath = "Assets/Bundles/Map43/BSP/_yaml_sample.asset";
        File.WriteAllText(Path.Combine(Directory.GetParent(Application.dataPath).FullName, assetPath),
                          text, new UTF8Encoding(false));
        AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceUpdate);
        var back = AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);
        if (back == null)
        {
            Debug.LogError("[DUMP] roundtrip FAILED: Unity could not import generated YAML");
            EditorApplication.Exit(1);
            return;
        }
        Debug.Log("[DUMP] roundtrip OK verts=" + back.vertexCount + " subs=" + back.subMeshCount +
                  " bounds=" + back.bounds + " uv0=" + (back.uv == null ? 0 : back.uv.Length) +
                  " normals=" + (back.normals == null ? 0 : back.normals.Length) +
                  " tris0=" + back.GetTriangles(0).Length + " tris1=" + back.GetTriangles(1).Length);
        AssetDatabase.DeleteAsset(assetPath);
        EditorApplication.Exit(0);
    }

    /// <summary>按 Unity 2019.4 的 UnityEngine.Mesh YAML 结构序列化。</summary>
    public static string Marshal(Mesh m)
    {
        var sb = new StringBuilder();
        var inv = CultureInfo.InvariantCulture;
        sb.AppendLine("%YAML 1.1");
        sb.AppendLine("%TAG !u! tag:unity3d.com,2011:");
        sb.AppendLine("--- !u!43 &4300000");
        sb.AppendLine("Mesh:");
        sb.AppendLine("  m_ObjectHideFlags: 0");
        sb.AppendLine("  m_CorrespondingSourceObject: {fileID: 0}");
        sb.AppendLine("  m_PrefabInstance: {fileID: 0}");
        sb.AppendLine("  m_PrefabAsset: {fileID: 0}");
        sb.AppendLine("  m_Name: " + m.name);
        sb.AppendLine("  serializedVersion: 9");
        sb.AppendLine("  m_SubMeshes:");

        for (int i = 0; i < m.subMeshCount; i++)
        {
            var tris = m.GetTriangles(i);
            sb.AppendLine("  - serializedVersion: 2");
            sb.AppendLine("    firstByte: " + (i * 16));
            sb.AppendLine("    indexCount: " + tris.Length);
            sb.AppendLine("    topology: 0");
            sb.AppendLine("    baseVertex: 0");
            sb.AppendLine("    firstVertex: 0");
            sb.AppendLine("    vertexCount: " + m.vertexCount);
            sb.AppendLine("    localAABB:");
            sb.AppendLine("      m_Center: {x: 0, y: 0, z: 0}");
            sb.AppendLine("      m_Extent: {x: 0, y: 0, z: 0}");
        }

        sb.AppendLine("  m_Shapes:");
        sb.AppendLine("    vertices: []");
        sb.AppendLine("    shapes: []");
        sb.AppendLine("    channels: []");
        sb.AppendLine("    fullWeights: []");
        sb.AppendLine("  m_BindPose: []");
        sb.AppendLine("  m_BoneNameHashes: ");
        sb.AppendLine("  m_RootBoneNameHash: 0");
        sb.AppendLine("  m_MeshCompression: 0");
        sb.AppendLine("  m_IsReadable: 1");
        sb.AppendLine("  m_KeepVertices: 1");
        sb.AppendLine("  m_KeepIndices: 1");
        sb.AppendLine("  m_IndexFormat: 0");
        sb.AppendLine("  m_IndexBuffer: " + Hex(m.GetIndices(0) == null ? BuildAllIndices(m) : BuildAllIndices(m)));
        sb.AppendLine("  m_VertexData:");
        sb.AppendLine("    serializedVersion: 3");
        sb.AppendLine("    m_VertexCount: " + m.vertexCount);
        sb.AppendLine("    m_Channels:");
        // 全部通道同一条 stream(0)，offset 为"第几个 float"
        sb.AppendLine(Chan(0, 3, 0));
        sb.AppendLine(Chan(3, 3, 0));
        sb.AppendLine(Chan(6, 4, 0));
        sb.AppendLine(Chan(10, 4, 0));
        sb.AppendLine(Chan(14, 2, 0));
        sb.AppendLine(Chan(16, 2, 0));
        sb.AppendLine(Chan(18, 2, 0));
        sb.AppendLine(Chan(20, 2, 0));
        sb.AppendLine("    m_DataSize: " + (m.vertexCount * 22 * 4));

        // 顶点数据：pos3 + normal3 + tangent4 + color4 + uv0..3 各2 = 22 float
        var pos = m.vertices;
        var nrm = m.normals;
        var uv = m.uv;
        var uv2 = m.uv2;
        var col = m.colors32;
        var bytes = new byte[m.vertexCount * 22 * 4];
        int o = 0;
        for (int i = 0; i < m.vertexCount; i++)
        {
            o = Put(bytes, o, pos[i].x); o = Put(bytes, o, pos[i].y); o = Put(bytes, o, pos[i].z);
            Vector3 n = (nrm != null && i < nrm.Length) ? nrm[i] : Vector3.up;
            o = Put(bytes, o, n.x); o = Put(bytes, o, n.y); o = Put(bytes, o, n.z);
            o = Put(bytes, o, 0f); o = Put(bytes, o, 0f); o = Put(bytes, o, 0f); o = Put(bytes, o, 1f);
            Color32 c = (col != null && i < col.Length) ? col[i] : new Color32(255, 255, 255, 255);
            o = PutB(bytes, o, c.r); o = PutB(bytes, o, c.g); o = PutB(bytes, o, c.b); o = PutB(bytes, o, c.a);
            Vector2 t0 = (uv != null && i < uv.Length) ? uv[i] : Vector2.zero;
            o = Put(bytes, o, t0.x); o = Put(bytes, o, t0.y);
            Vector2 t1 = (uv2 != null && i < uv2.Length) ? uv2[i] : Vector2.zero;
            o = Put(bytes, o, t1.x); o = Put(bytes, o, t1.y);
            o = Put(bytes, o, 0f); o = Put(bytes, o, 0f);
            o = Put(bytes, o, 0f); o = Put(bytes, o, 0f);
        }
        sb.AppendLine("    _typelessdata: " + Hex(bytes));
        sb.AppendLine("  m_CompressedMesh:");
        sb.AppendLine("    m_Vertices:");
        sb.AppendLine("      m_NumItems: 0");
        sb.AppendLine("      m_Data: " + Empties(22));
        sb.AppendLine("  m_LocalAABB:");
        var b = m.bounds;
        sb.AppendLine("    m_Center: {x: " + F(b.center.x) + ", y: " + F(b.center.y) + ", z: " + F(b.center.z) + "}");
        sb.AppendLine("    m_Extent: {x: " + F(b.extents.x) + ", y: " + F(b.extents.y) + ", z: " + F(b.extents.z) + "}");
        sb.AppendLine("  m_MeshUsageFlags: 0");
        sb.AppendLine("  m_BakedConvexCollisionMesh: ");
        sb.AppendLine("  m_BakedTriangleCollisionMesh: ");
        sb.AppendLine("  m_MeshMetrics[0]: 1");
        sb.AppendLine("  m_MeshMetrics[1]: 1");
        sb.AppendLine("  m_StreamData:");
        sb.AppendLine("    offset: 0");
        sb.AppendLine("    size: 0");
        sb.AppendLine("    path: ");
        return sb.ToString();
    }

    private static int[] BuildAllIndices(Mesh m)
    {
        var all = new System.Collections.Generic.List<int>();
        for (int i = 0; i < m.subMeshCount; i++)
            all.AddRange(m.GetTriangles(i));
        return all.ToArray();
    }

    private static string Chan(int offset, int dim, int format)
    {
        return "    - stream: 0\n"
             + "      offset: " + offset + "\n"
             + "      format: " + format + "\n"
             + "      dimension: " + dim;
    }

    private static string F(float v) { return v.ToString("R", CultureInfo.InvariantCulture); }

    private static int Put(byte[] b, int o, float v)
    {
        var raw = System.BitConverter.GetBytes(v);
        b[o] = raw[0]; b[o + 1] = raw[1]; b[o + 2] = raw[2]; b[o + 3] = raw[3];
        return o + 4;
    }

    private static int PutB(byte[] b, int o, byte v) { b[o] = v; return o + 1; }

    private static string Empties(int n)
    {
        var parts = new string[n];
        for (int i = 0; i < n; i++) parts[i] = "00";
        return string.Join(" ", parts);
    }

    private static string Hex(int[] ints)
    {
        // m_IndexBuffer：每个索引 2 字节（小端 uint16）+ 1 字节填充，firstByte 以 16 为步进
        var sb = new StringBuilder(ints.Length * 6);
        for (int i = 0; i < ints.Length; i++)
        {
            var v = (ushort)ints[i];
            if (i > 0) sb.Append(' ');
            sb.Append((v & 0xff).ToString("x2"));
            sb.Append(' ');
            sb.Append(((v >> 8) & 0xff).ToString("x2"));
            sb.Append(" 00");
        }
        return sb.ToString();
    }

    private static string Hex(byte[] bytes)
    {
        var sb = new StringBuilder(bytes.Length * 3);
        for (int i = 0; i < bytes.Length; i++)
        {
            if (i > 0) sb.Append(' ');
            sb.Append(bytes[i].ToString("x2"));
        }
        return sb.ToString();
    }
}
