using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

namespace SSJJ.Server.Physics
{
    /// <summary>
    /// Server-side triangle collision map built from BSP solid/visual triangles.
    /// Coordinates are SSJJ server space: X/Y horizontal, Z up (centimetres).
    /// JSON is produced by SSJJ-Server/tools/export_bsp_solid.py.
    /// </summary>
    public sealed class ClipMap
    {
        private sealed class ClipData
        {
            public float[][] verts { get; set; } = Array.Empty<float[]>();
            public int[][] tris { get; set; } = Array.Empty<int[]>();
        }

        private struct Tri
        {
            public Vector3f A, B, C;
            public Vector3f Normal;
            public Vector3f Min, Max;
            public Vector3f Centroid;
        }

        private sealed class Node
        {
            public Vector3f Min, Max;
            public int Start, Count;
            public int Left, Right; // -1 = leaf
        }

        private readonly List<Tri> _tris = new List<Tri>();
        private readonly List<int> _order = new List<int>();
        private readonly List<Node> _nodes = new List<Node>();

        public Vector3f Min { get; private set; }
        public Vector3f Max { get; private set; }
        public int TriangleCount => _tris.Count;
        public int NodeCount => _nodes.Count;

        public static ClipMap? Load(string path)
        {
            try
            {
                string json = File.ReadAllText(path);
                var data = JsonSerializer.Deserialize<ClipData>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
                if (data == null || data.verts.Length == 0 || data.tris.Length == 0) return null;
                var map = new ClipMap();
                map.Build(data);
                return map;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("[ClipMap] load failed: " + ex.Message);
                return null;
            }
        }

        private void Build(ClipData data)
        {
            var verts = new Vector3f[data.verts.Length];
            for (int i = 0; i < data.verts.Length; i++)
            {
                var v = data.verts[i];
                verts[i] = new Vector3f(v[0], v[1], v[2]);
            }

            for (int i = 0; i < data.tris.Length; i++)
            {
                var t = data.tris[i];
                if (t.Length < 3) continue;
                Vector3f a = verts[t[0]], b = verts[t[1]], c = verts[t[2]];
                Vector3f n = Vector3f.Cross(b - a, c - a);
                float len = n.Length();
                if (len < 1e-4f) continue;
                n = n / len;
                var tri = new Tri
                {
                    A = a, B = b, C = c,
                    Normal = n,
                    Min = new Vector3f(Math.Min(a.X, Math.Min(b.X, c.X)), Math.Min(a.Y, Math.Min(b.Y, c.Y)), Math.Min(a.Z, Math.Min(b.Z, c.Z))),
                    Max = new Vector3f(Math.Max(a.X, Math.Max(b.X, c.X)), Math.Max(a.Y, Math.Max(b.Y, c.Y)), Math.Max(a.Z, Math.Max(b.Z, c.Z))),
                    Centroid = (a + b + c) / 3f
                };
                _tris.Add(tri);
                _order.Add(_tris.Count - 1);
            }

            if (_tris.Count == 0) return;

            Min = _tris[0].Min;
            Max = _tris[0].Max;
            for (int i = 1; i < _tris.Count; i++)
            {
                Min = Vector3f.Min(Min, _tris[i].Min);
                Max = Vector3f.Max(Max, _tris[i].Max);
            }

            BuildNode(0, _order.Count);
        }

        private int BuildNode(int start, int count)
        {
            var node = new Node { Start = start, Count = count, Left = -1, Right = -1 };
            Vector3f min = _tris[_order[start]].Min;
            Vector3f max = _tris[_order[start]].Max;
            Vector3f cmin = _tris[_order[start]].Centroid;
            Vector3f cmax = cmin;
            for (int i = start + 1; i < start + count; i++)
            {
                var t = _tris[_order[i]];
                min = Vector3f.Min(min, t.Min);
                max = Vector3f.Max(max, t.Max);
                cmin = Vector3f.Min(cmin, t.Centroid);
                cmax = Vector3f.Max(cmax, t.Centroid);
            }
            node.Min = min;
            node.Max = max;
            int index = _nodes.Count;
            _nodes.Add(node);

            if (count <= 8) return index;

            Vector3f extent = cmax - cmin;
            int axis = extent.X > extent.Y
                ? (extent.X > extent.Z ? 0 : 2)
                : (extent.Y > extent.Z ? 1 : 2);

            int mid = start + count / 2;
            _order.Sort(start, count, Comparer<int>.Create((ia, ib) =>
            {
                var a = _tris[ia].Centroid;
                var b = _tris[ib].Centroid;
                float av = axis == 0 ? a.X : axis == 1 ? a.Y : a.Z;
                float bv = axis == 0 ? b.X : axis == 1 ? b.Y : b.Z;
                return av.CompareTo(bv);
            }));

            int left = BuildNode(start, mid - start);
            int right = BuildNode(mid, start + count - mid);
            var n2 = _nodes[index];
            n2.Left = left;
            n2.Right = right;
            _nodes[index] = n2;
            return index;
        }

        public bool TraceLine(Vector3f start, Vector3f end, out Vector3f hit, out Vector3f normal, out float fraction)
        {
            hit = end;
            normal = new Vector3f(0, 0, 1);
            fraction = 1f;
            if (_nodes.Count == 0) return false;
            Vector3f dir = end - start;
            float best = 1f;
            bool found = false;
            var stack = new Stack<int>();
            stack.Push(0);
            while (stack.Count > 0)
            {
                int ni = stack.Pop();
                var node = _nodes[ni];
                if (!RayAabb(start, dir, node.Min, node.Max, best)) continue;
                if (node.Left >= 0)
                {
                    stack.Push(node.Left);
                    stack.Push(node.Right);
                    continue;
                }
                for (int i = node.Start; i < node.Start + node.Count; i++)
                {
                    var tri = _tris[_order[i]];
                    if (!RayTriangle(start, dir, tri, out float t, out Vector3f n)) continue;
                    if (t < 0f || t > best) continue;
                    best = t;
                    hit = start + dir * t;
                    normal = n;
                    found = true;
                }
            }
            fraction = best;
            return found;
        }

        /// <summary>Approximate player sweep: centre + four horizontal side rays.</summary>
        public bool TracePlayer(Vector3f start, Vector3f end, float radius, out Vector3f hit, out Vector3f normal, out float fraction)
        {
            hit = end;
            normal = new Vector3f(0, 0, 1);
            fraction = 1f;
            bool found = TraceLine(start, end, out hit, out normal, out fraction);
            Vector3f[] offsets =
            {
                new Vector3f(radius, 0, 0), new Vector3f(-radius, 0, 0),
                new Vector3f(0, radius, 0), new Vector3f(0, -radius, 0)
            };
            for (int i = 0; i < offsets.Length; i++)
            {
                var o = offsets[i];
                if (TraceLine(start + o, end + o, out var h2, out var n2, out var f2) && f2 < fraction)
                {
                    fraction = f2;
                    hit = h2 - o;
                    normal = n2;
                    found = true;
                }
            }
            return found;
        }

        public bool SampleGround(Vector3f pos, float up, float down, out Vector3f ground, out Vector3f normal)
        {
            return TraceLine(pos + new Vector3f(0, 0, up), pos - new Vector3f(0, 0, down), out ground, out normal, out _);
        }

        private static bool RayAabb(Vector3f start, Vector3f dir, Vector3f min, Vector3f max, float maxT)
        {
            float tmin = 0f, tmax = maxT;
            for (int axis = 0; axis < 3; axis++)
            {
                float s = axis == 0 ? start.X : axis == 1 ? start.Y : start.Z;
                float d = axis == 0 ? dir.X : axis == 1 ? dir.Y : dir.Z;
                float lo = axis == 0 ? min.X : axis == 1 ? min.Y : min.Z;
                float hi = axis == 0 ? max.X : axis == 1 ? max.Y : max.Z;
                if (Math.Abs(d) < 1e-9f)
                {
                    if (s < lo || s > hi) return false;
                    continue;
                }
                float t1 = (lo - s) / d;
                float t2 = (hi - s) / d;
                if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }
                if (t1 > tmin) tmin = t1;
                if (t2 < tmax) tmax = t2;
                if (tmin > tmax) return false;
            }
            return true;
        }

        private static bool RayTriangle(Vector3f start, Vector3f dir, Tri tri, out float t, out Vector3f normal)
        {
            t = 0f;
            normal = tri.Normal;
            Vector3f e1 = tri.B - tri.A;
            Vector3f e2 = tri.C - tri.A;
            Vector3f p = Vector3f.Cross(dir, e2);
            float det = Vector3f.Dot(e1, p);
            if (Math.Abs(det) < 1e-8f) return false;
            float inv = 1f / det;
            Vector3f tv = start - tri.A;
            float u = Vector3f.Dot(tv, p) * inv;
            if (u < -1e-5f || u > 1.00001f) return false;
            Vector3f q = Vector3f.Cross(tv, e1);
            float v = Vector3f.Dot(dir, q) * inv;
            if (v < -1e-5f || u + v > 1.00001f) return false;
            float tt = Vector3f.Dot(e2, q) * inv;
            if (tt < 0f || tt > 1f) return false;
            t = tt;
            if (Vector3f.Dot(normal, dir) > 0f) normal = normal * -1f;
            return true;
        }
    }
}
