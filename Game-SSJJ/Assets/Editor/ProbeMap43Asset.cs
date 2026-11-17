using System.IO;
using UnityEditor;
using UnityEngine;

/// <summary>只检查 map43_bsp.asset 被 Unity 解析成什么样，不建场景。</summary>
public static class ProbeMap43Asset
{
    [MenuItem("SSJJ/诊. 检查 map43_bsp.asset")]
    public static void Probe()
    {
        AssetDatabase.Refresh();
        const string p = "Assets/Bundles/Map43/BSP/map43_bsp.asset";
        AssetDatabase.ImportAsset(p, ImportAssetOptions.ForceUpdate);
        var m = AssetDatabase.LoadAssetAtPath<Mesh>(p);
        if (m == null)
        {
            Debug.LogError("[PROBE] not loaded as Mesh");
            EditorApplication.Exit(1);
            return;
        }
        Debug.Log("[PROBE] verts=" + m.vertexCount + " subs=" + m.subMeshCount +
                  " uv=" + (m.uv == null ? 0 : m.uv.Length) +
                  " normals=" + (m.normals == null ? 0 : m.normals.Length) +
                  " bounds=" + m.bounds);
        for (int i = 0; i < m.subMeshCount && i < 35; i++)
        {
            var sm = m.GetSubMesh(i);
            Debug.Log("[PROBE] sub" + i + " indexCount=" + sm.indexCount +
                      " tris=" + (m.GetTriangles(i).Length / 3));
        }
        EditorApplication.Exit(0);
    }
}
