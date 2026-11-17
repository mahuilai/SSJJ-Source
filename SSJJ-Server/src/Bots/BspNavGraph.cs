using System;
using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.Physics;

namespace SSJJ.Server.Bots
{
    /// <summary>
    /// 基于 OfficialPhysicsWorld BSP 射线探针与地图出生点/包点种子泛洪构建的可达导航图 + A* 寻路器
    /// （无需外部 .nav 文件，自动支持多层高度、斜坡、通道与 1:1 BSP 障碍绕行）
    /// </summary>
    public sealed class BspNavGraph
    {
        public sealed class NavNode
        {
            public int Index;
            public float X;
            public float Y;
            public float Z;
            public List<int> Neighbors = new List<int>(8);
        }

        private const float CellSize = 260f;
        private const float ZBand = 150f;
        private const int MaxNodes = 4000;

        private readonly List<NavNode> _nodes = new List<NavNode>();
        private readonly Dictionary<(int gx, int gy, int gz), int> _gridToNode = new Dictionary<(int, int, int), int>();
        private static readonly (int dx, int dy)[] Dirs =
        {
            (1, 0), (-1, 0), (0, 1), (0, -1),
            (1, 1), (1, -1), (-1, 1), (-1, -1)
        };

        public int NodeCount => _nodes.Count;

        public void Build(BspMapData bsp, OfficialPhysicsWorld physics)
        {
            _nodes.Clear();
            _gridToNode.Clear();
            if (!physics.IsReady) return;

            var sw = System.Diagnostics.Stopwatch.StartNew();
            var queue = new Queue<int>();

            void TrySeed(float x, float y, float z)
            {
                if (physics.SampleGround(x, y, z - 20f, out float gz))
                {
                    AddOrGetNode(x, y, gz + 2f, queue);
                }
            }

            foreach (var sp in bsp.Spawns) TrySeed(sp.X, sp.Y, sp.Z);
            foreach (var bs in bsp.BombSites) TrySeed(bs.X, bs.Y, bs.Z);

            while (queue.Count > 0 && _nodes.Count < MaxNodes)
            {
                int curIdx = queue.Dequeue();
                var cur = _nodes[curIdx];

                for (int d = 0; d < Dirs.Length; d++)
                {
                    float nx = cur.X + Dirs[d].dx * CellSize;
                    float ny = cur.Y + Dirs[d].dy * CellSize;

                    if (!physics.SampleGround(nx, ny, cur.Z - 20f, out float ngz)) continue;
                    float dz = ngz - cur.Z;
                    if (dz > 130f || dz < -260f) continue;

                    // 检查腰部与头部（含左右胶囊体肩宽 ±26cm）是否可无障碍通过
                    float segLen = (float)Math.Sqrt((nx - cur.X) * (nx - cur.X) + (ny - cur.Y) * (ny - cur.Y));
                    float px = segLen > 1f ? -(ny - cur.Y) / segLen * 26f : 0f;
                    float py = segLen > 1f ? (nx - cur.X) / segLen * 26f : 0f;
                    if (!physics.TraceRayClear(cur.X + px, cur.Y + py, cur.Z + 76f, nx + px, ny + py, ngz + 76f, out _)) continue;
                    if (!physics.TraceRayClear(cur.X - px, cur.Y - py, cur.Z + 76f, nx - px, ny - py, ngz + 76f, out _)) continue;
                    if (!physics.TraceRayClear(cur.X, cur.Y, cur.Z + 132f, nx, ny, ngz + 132f, out _)) continue;

                    int nextIdx = AddOrGetNode(nx, ny, ngz + 2f, queue);
                    if (nextIdx >= 0 && nextIdx != curIdx)
                    {
                        if (!cur.Neighbors.Contains(nextIdx)) cur.Neighbors.Add(nextIdx);
                        if (Math.Abs(dz) <= 130f && !_nodes[nextIdx].Neighbors.Contains(curIdx))
                        {
                            _nodes[nextIdx].Neighbors.Add(curIdx);
                        }
                    }
                }
            }

            Console.WriteLine($"[SSJJ-Server][NAV] Built BSP nav graph for map{bsp.MapId}: {_nodes.Count} nodes in {sw.ElapsedMilliseconds}ms");
        }

        private int AddOrGetNode(float x, float y, float z, Queue<int> queue)
        {
            var key = ((int)Math.Round(x / CellSize), (int)Math.Round(y / CellSize), (int)Math.Round(z / ZBand));
            if (_gridToNode.TryGetValue(key, out int existing)) return existing;
            if (_nodes.Count >= MaxNodes) return -1;

            int idx = _nodes.Count;
            _nodes.Add(new NavNode
            {
                Index = idx,
                X = x,
                Y = y,
                Z = z
            });
            _gridToNode[key] = idx;
            queue.Enqueue(idx);
            return idx;
        }

        public int FindNearestNode(float x, float y, float z)
        {
            int bestIdx = -1;
            float bestScore = float.MaxValue;
            for (int i = 0; i < _nodes.Count; i++)
            {
                var n = _nodes[i];
                float dx = n.X - x;
                float dy = n.Y - y;
                float dz = Math.Abs(n.Z - z);
                float score = dx * dx + dy * dy + dz * dz * 4f;
                if (score < bestScore)
                {
                    bestScore = score;
                    bestIdx = i;
                }
            }
            return bestIdx;
        }

        public List<int> FindPath(float fromX, float fromY, float fromZ, float toX, float toY, float toZ)
        {
            var path = new List<int>();
            if (_nodes.Count == 0) return path;

            int start = FindNearestNode(fromX, fromY, fromZ);
            int goal = FindNearestNode(toX, toY, toZ);
            if (start < 0 || goal < 0 || start == goal) return path;

            var gScore = new Dictionary<int, float> { [start] = 0f };
            var cameFrom = new Dictionary<int, int>();
            var pq = new PriorityQueue<int, float>();
            pq.Enqueue(start, Dist(_nodes[start], _nodes[goal]));
            var closed = new HashSet<int>();
            int bestReached = start;
            float bestGoalDist = Dist(_nodes[start], _nodes[goal]);

            int expansions = 0;
            while (pq.Count > 0 && expansions++ < 1800)
            {
                int cur = pq.Dequeue();
                if (!closed.Add(cur)) continue;

                float gd = Dist(_nodes[cur], _nodes[goal]);
                if (gd < bestGoalDist)
                {
                    bestGoalDist = gd;
                    bestReached = cur;
                }
                if (cur == goal) break;

                var cn = _nodes[cur];
                float cg = gScore[cur];
                for (int i = 0; i < cn.Neighbors.Count; i++)
                {
                    int nb = cn.Neighbors[i];
                    if (closed.Contains(nb)) continue;
                    var nn = _nodes[nb];
                    float tentative = cg + Dist(cn, nn);
                    if (!gScore.TryGetValue(nb, out float prevG) || tentative < prevG)
                    {
                        gScore[nb] = tentative;
                        cameFrom[nb] = cur;
                        pq.Enqueue(nb, tentative + Dist(nn, _nodes[goal]));
                    }
                }
            }

            int trace = closed.Contains(goal) ? goal : bestReached;
            while (cameFrom.TryGetValue(trace, out int prev))
            {
                path.Add(trace);
                trace = prev;
            }
            path.Reverse();
            return path;
        }

        public bool TryGetNode(int index, out NavNode node)
        {
            if (index >= 0 && index < _nodes.Count)
            {
                node = _nodes[index];
                return true;
            }
            node = null!;
            return false;
        }

        private static float Dist(NavNode a, NavNode b)
        {
            float dx = a.X - b.X, dy = a.Y - b.Y, dz = a.Z - b.Z;
            return (float)Math.Sqrt(dx * dx + dy * dy + dz * dz);
        }
    }
}
