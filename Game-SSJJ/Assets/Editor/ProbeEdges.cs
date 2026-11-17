using System.Text;
using UnityEditor;
using UnityEngine;

public static class ProbeEdges
{
    public static void Run()
    {
        var m = AssetDatabase.LoadAssetAtPath<Mesh>("Assets/Bundles/Map43/BSP/map43_bsp.asset");
        var v = m.vertices;
        var sb = new StringBuilder();
        for (int s = 0; s < m.subMeshCount; s++)
        {
            var tri = m.GetTriangles(s);
            int over = 0; float mx = 0;
            for (int t = 0; t + 2 < tri.Length; t += 3)
            {
                float e1 = Vector3.Distance(v[tri[t]], v[tri[t + 1]]);
                float e2 = Vector3.Distance(v[tri[t + 1]], v[tri[t + 2]]);
                float e3 = Vector3.Distance(v[tri[t + 2]], v[tri[t]]);
                float e = Mathf.Max(e1, Mathf.Max(e2, e3));
                if (e > mx) mx = e;
                if (e > 1000f) over++;
            }
            if (over > 0 || mx > 500f)
                sb.AppendLine("[E] sub" + s + " tris=" + (tri.Length / 3) + " over1000=" + over + " max=" + mx.ToString("F0"));
        }
        Debug.Log(sb.ToString());
    }
}
