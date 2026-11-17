using UnityEngine;
using UnityEditor;

/// <summary>逐个子网格核对 GetTriangles 的索引是否落在 vertexCount 内。</summary>
public static class ProbeTris
{
    [MenuItem("SSJJ/诊. 校验子网格索引")]
    public static void Probe()
    {
        AssetDatabase.Refresh();
        var p = "Assets/Bundles/Map43/BSP/map43_bsp.asset";
        AssetDatabase.ImportAsset(p, ImportAssetOptions.ForceUpdate);
        var m = AssetDatabase.LoadAssetAtPath<Mesh>(p);
        if (m == null) { Debug.LogError("[TRI] load failed"); EditorApplication.Exit(1); return; }
        var vs = m.vertices;
        Debug.Log("[TRI] verts=" + m.vertexCount + " verticesArray=" + vs.Length + " subs=" + m.subMeshCount);
        int bad = 0, total = 0;
        for (int i = 0; i < m.subMeshCount; i++)
        {
            var t = m.GetTriangles(i);
            total += t.Length;
            int mx = 0, mn = int.MaxValue, oob = 0;
            foreach (var v in t) { if (v > mx) mx = v; if (v < mn) mn = v; if (v < 0 || v >= vs.Length) oob++; }
            if (oob > 0)
            {
                bad++;
                Debug.LogError("[TRI] sub" + i + " tris=" + (t.Length / 3) + " idx[" + mn + ".." + mx +
                               "] oob=" + oob + " (vertices=" + vs.Length + ")");
            }
            else if (i < 5)
                Debug.Log("[TRI] sub" + i + " ok tris=" + (t.Length / 3) + " idx[" + mn + ".." + mx + "]");
        }
        Debug.Log("[TRI] total indices=" + total + " badSubMeshes=" + bad);
        EditorApplication.Exit(0);
    }
}
