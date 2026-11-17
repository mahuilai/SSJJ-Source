using System.Text;
using UnityEditor;
using UnityEngine;

public static class ProbeAsset2
{
    public static void Run()
    {
        var m = AssetDatabase.LoadAssetAtPath<Mesh>("Assets/Bundles/Map43/BSP/map43_bsp.asset");
        if (m == null) { Debug.Log("[P2] mesh null"); return; }
        var v = m.vertices;
        var uv = m.uv;
        var nrm = m.normals;
        var sb = new StringBuilder();
        sb.AppendLine("[P2] verts=" + v.Length + " subs=" + m.subMeshCount + " uv=" + uv.Length + " nrm=" + nrm.Length);
        for (int i = 0; i < Mathf.Min(4, v.Length); i++)
            sb.AppendLine("[P2] v" + i + "=" + v[i].ToString("F2") + " uv=" + (i < uv.Length ? uv[i].ToString("F3") : "-") + " n=" + (i < nrm.Length ? nrm[i].ToString("F2") : "-"));
        // 全局：所有三角形边长统计
        int over = 0, tot = 0;
        float maxEdge = 0;
        for (int s = 0; s < m.subMeshCount; s++)
        {
            var tri = m.GetTriangles(s);
            for (int t = 0; t + 2 < tri.Length; t += 3)
            {
                tot++;
                float e1 = Vector3.Distance(v[tri[t]], v[tri[t + 1]]);
                float e2 = Vector3.Distance(v[tri[t + 1]], v[tri[t + 2]]);
                float e3 = Vector3.Distance(v[tri[t + 2]], v[tri[t]]);
                float mx = Mathf.Max(e1, Mathf.Max(e2, e3));
                if (mx > maxEdge) maxEdge = mx;
                if (mx > 1000f) over++;
            }
        }
        sb.AppendLine("[P2] tris=" + tot + " edge>1000 count=" + over + " maxEdge=" + maxEdge.ToString("F1"));
        Debug.Log(sb.ToString());
    }
}
