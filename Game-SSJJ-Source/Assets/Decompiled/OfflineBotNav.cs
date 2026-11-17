using System;
using System.Collections.Generic;
using UnityEngine;

// [OFFLINE-BOT-NAV] 导航层 —— BSP 洪泛建图 + A* 寻路
//
// 参考 Kieeran/FPS-Game 的分层寻路思路（Dijkstra 战略层 + NavMesh 战术层），
// 但 SSJJ 的 BSP 地图没法烘焙 NavMesh，所以改成：
//   建图  从出生点做广度洪泛，用原版 BSP 体积扫描(TryWalk)验证可达性，
//         只在地面真正能站人的地方生成节点 —— 天然贴合地图，不需要包围盒。
//   寻路  节点图上的 A*（欧氏启发），输出路径点序列。
//   补充  邻居补边时做 CanSee 视线检测，避免"穿过墙也算连通"。
//
// 坐标系：对外统一用 Unity 米制（GetUnityPos 坐标系），内部调 BSP 时转 SSJJ 原始厘米。
public static class OfflineBotNav
{
	public class Node
	{
		public Vector3 Pos;                  // 米制
		public List<int> Links = new List<int>(8);
		public float CoverScore;             // 掩体分（附近有遮挡物越高）
		public bool Tactical;                // 战术点（可用于卡点/包抄）
	}

	public static readonly List<Node> Nodes = new List<Node>(1024);
	public static bool Baked { get; private set; }
	private static int _bakeVersion;

	// 洪泛参数
	private const float StepDist = 4.5f;      // 每次洪泛步进（米）
	private const int MaxNodes = 900;         // 节点上限
	private const float LinkRadius = 9.0f;    // 邻居补边半径（米）
	private const float MinNodeSpacing = 2.5f; // 节点最小间距

	// ---------------- 坐标转换 ----------------
	// [OFFLINE-FIX] OfflineBotPhysics.Cast/TryWalk 接受的坐标空间是 (-data.Y, data.Z, data.X) 厘米，
	// 与 OfflineBotPhysics.Position(data) 完全一致；GetUnityPos 返回米制 (-Y/100, Z/100, X/100)。
	// 两者只差一个 *100，不能对 x 取反（旧实现多取反一次，所有落点被镜像到地图另一侧 -> nodes=0）。
	public static Vector3 UnityToRaw(Vector3 u)
	{
		return new Vector3(u.x * 100f, u.y * 100f, u.z * 100f);
	}

	public static Vector3 RawToUnity(Vector3 r)
	{
		return new Vector3(r.x / 100f, r.y / 100f, r.z / 100f);
	}

	// ---------------- 建图 ----------------

	/// <summary>
	/// 从种子点（Unity 米制）广度洪泛建图。可重复调用，version 变化会重建。
	/// </summary>
	public static void Bake(List<Vector3> seeds, int version)
	{
		if (Baked && version == _bakeVersion) return;
		_bakeVersion = version;
		Baked = false;
		Nodes.Clear();
		// [OFFLINE-NAVGRID] 先尝试全图网格烘焙：T 出生房/楼梯/门洞不会因为洪泛种子
		// 覆盖不到而断图；网格失败才退回旧的种子洪泛。
		if (TryBakeGrid(seeds))
		{
			Baked = Nodes.Count > 20;
			if (Baked) return;
		}
		Nodes.Clear();
		if (seeds == null || seeds.Count == 0)
		{
			return;
		}

		Queue<Vector3> q = new Queue<Vector3>();
		List<Vector3> accepted = new List<Vector3>();
		for (int i = 0; i < seeds.Count; i++)
		{
			q.Enqueue(seeds[i]);
		}

		// 8 方向 + 4 个斜向，覆盖更均匀
		Vector3[] dirs = new Vector3[]
		{
			new Vector3(1,0,0), new Vector3(-1,0,0), new Vector3(0,0,1), new Vector3(0,0,-1),
			new Vector3(1,0,1).normalized, new Vector3(-1,0,1).normalized,
			new Vector3(1,0,-1).normalized, new Vector3(-1,0,-1).normalized
		};

		int guard = 0;
		while (q.Count > 0 && Nodes.Count < MaxNodes && guard++ < MaxNodes * 14)
		{
			Vector3 cur = q.Dequeue();

			// 太近就跳过
			bool near = false;
			for (int i = 0; i < accepted.Count; i++)
			{
				if ((accepted[i] - cur).sqrMagnitude < MinNodeSpacing * MinNodeSpacing) { near = true; break; }
			}
			if (near) continue;

			// 必须能站人：用 TryWalk 从"上方一点"落到该点
			Vector3 landed;
			if (!TryLand(cur, out landed)) continue;

			Node n = new Node();
			n.Pos = landed;
			int idx = Nodes.Count;
			Nodes.Add(n);
			accepted.Add(landed);

			for (int d = 0; d < dirs.Length; d++)
			{
				Vector3 next = landed + dirs[d] * StepDist;
				q.Enqueue(next);
			}
		}

		// 邻居补边（半径内 + 视线可达）
		for (int i = 0; i < Nodes.Count; i++)
		{
			for (int j = i + 1; j < Nodes.Count; j++)
			{
				float d2 = (Nodes[i].Pos - Nodes[j].Pos).sqrMagnitude;
				if (d2 > LinkRadius * LinkRadius) continue;
				if (!Walkable(Nodes[i].Pos, Nodes[j].Pos)) continue;
				Nodes[i].Links.Add(j);
				Nodes[j].Links.Add(i);
			}
		}

		// 掩体分：节点四周 3m 内如果有遮挡，说明旁边有墙/箱子
		for (int i = 0; i < Nodes.Count; i++)
		{
			int blocked = 0;
			Vector3 p = Nodes[i].Pos;
			for (int d = 0; d < 8; d++)
			{
				float ang = d * 45f * Mathf.Deg2Rad;
				Vector3 probe = p + new Vector3(Mathf.Sin(ang), 0f, Mathf.Cos(ang)) * 3.0f;
				if (!Walkable(p, probe)) blocked++;
			}
			Nodes[i].CoverScore = blocked / 8f;
			Nodes[i].Tactical = blocked >= 3 && blocked <= 6;   // 半遮挡最理想
		}

		Baked = Nodes.Count > 8;
		// [OFFLINE-FIX] 建图失败时给出可定位的数字（种子数 / 尝试数 / 落点失败数）
		if (!Baked)
		{
			UnityEngine.Debug.LogWarning("[OFFLINE-BOT-NAV] bake failed seeds=" + seeds.Count
				+ " tried=" + guard + " accepted=" + Nodes.Count
				+ " firstSeed=" + seeds[0].x.ToString("F1") + "," + seeds[0].y.ToString("F1") + "," + seeds[0].z.ToString("F1"));
		}
	}

	/// <summary>
	/// [OFFLINE-NAVGRID] 全图 2.5m 网格烘焙：从 BspEngine 包围盒采样地面，8 邻接建边。
	/// 不依赖出生点洪泛，T 房/楼梯/门洞只要几何上能站人就会进图。
	/// </summary>
	private static bool TryBakeGrid(List<Vector3> seeds)
	{
		try
		{
			Contexts ctx = Contexts.sharedInstance;
			if (ctx == null || !ctx.battleRoom.hasPyEngine || seeds == null || seeds.Count == 0) return false;
			Vector3 mn = ctx.battleRoom.pyEngine.Min;
			Vector3 mx = ctx.battleRoom.pyEngine.Max;
			if (mx.x <= mn.x + 1f || mx.y <= mn.y + 1f || mx.z <= mn.z + 1f) return false;

			// BSP 原始 (X, Y 水平, Z 高度) -> nav Unity (-Y, Z, X)
			float uMinX = -mx.y * 0.01f;
			float uMaxX = -mn.y * 0.01f;
			float uMinZ = mn.x * 0.01f;
			float uMaxZ = mx.x * 0.01f;
			// [OFFLINE-NAVGRID] 从地图顶部扫会命中屋顶（map1 24.8m），bot 在地面 14m
			// 永远走不到。用出生/玩家种子的最高点 +6m 作为扫描顶，屋顶被排除。
			float maxSeedY = -9999f, minSeedY = 9999f;
			for (int i = 0; i < seeds.Count; i++)
			{
				if (seeds[i].y > maxSeedY) maxSeedY = seeds[i].y;
				if (seeds[i].y < minSeedY) minSeedY = seeds[i].y;
			}
			float top = Mathf.Min(mx.z * 0.01f + 5f, maxSeedY + 6f);
			float bottom = Mathf.Min(mn.z * 0.01f - 5f, minSeedY - 12f);
			float spanX = uMaxX - uMinX;
			float spanZ = uMaxZ - uMinZ;
			if (spanX <= 1f || spanZ <= 1f || top <= bottom) return false;

			float step = 2.5f;
			int nx = Mathf.CeilToInt(spanX / step) + 1;
			int nz = Mathf.CeilToInt(spanZ / step) + 1;
			if (nx * nz > 3600)
			{
				step = Mathf.Sqrt(spanX * spanZ / 3000f);
				if (step < 2f) step = 2f;
				nx = Mathf.CeilToInt(spanX / step) + 1;
				nz = Mathf.CeilToInt(spanZ / step) + 1;
			}

			int[,] idx = new int[nx, nz];
			for (int ix = 0; ix < nx; ix++)
				for (int iz = 0; iz < nz; iz++) idx[ix, iz] = -1;

			for (int ix = 0; ix < nx; ix++)
			{
				float x = uMinX + ix * step;
				for (int iz = 0; iz < nz; iz++)
				{
					float z = uMinZ + iz * step;
					Vector3 from = UnityToRaw(new Vector3(x, top, z));
					Vector3 to = UnityToRaw(new Vector3(x, bottom, z));
					Vector3 end, nrm; float frac;
					if (!OfflineBotPhysics.Cast(from, to, 0f, 0f, out end, out nrm, out frac)) continue;
					if (frac >= 0.999f || frac <= 0.0001f || nrm.y < 0.65f) continue;
					Vector3 g = RawToUnity(end) + Vector3.up * 0.02f;
					if (g.y < bottom || g.y > top) continue;
					// 地图底部/虚空平面（map1 z=0）不是可玩地面；用种子最低点过滤。
					if (g.y < minSeedY - 4f || g.y > maxSeedY + 6f) continue;
					// 头顶净空：从脚上方 10cm 向上 1.8m 做圆柱扫。
					Vector3 upEnd, upNrm; float upFrac;
					if (!OfflineBotPhysics.Cast(UnityToRaw(g + Vector3.up * 0.1f),
						UnityToRaw(g + Vector3.up * 1.9f), 28f, 0f, out upEnd, out upNrm, out upFrac))
						continue;
					if (upFrac < 0.92f) continue;

					Node n = new Node();
					n.Pos = g;
					idx[ix, iz] = Nodes.Count;
					Nodes.Add(n);
				}
			}

			int[] dxs = { 1, -1, 0, 0, 1, 1, -1, -1 };
			int[] dzs = { 0, 0, 1, -1, 1, -1, 1, -1 };
			int edges = 0;
			for (int ix = 0; ix < nx; ix++)
			{
				for (int iz = 0; iz < nz; iz++)
				{
					int i = idx[ix, iz];
					if (i < 0) continue;
					for (int d = 0; d < 8; d++)
					{
						int jx = ix + dxs[d], jz = iz + dzs[d];
						if (jx < 0 || jz < 0 || jx >= nx || jz >= nz) continue;
						int j = idx[jx, jz];
						if (j < 0 || j <= i) continue;
						Vector3 a = Nodes[i].Pos, b = Nodes[j].Pos;
						// 相邻格高度差 >55cm 视为台阶/悬崖；pmove 能迈 45cm，留一点余量。
						if (Mathf.Abs(a.y - b.y) > 0.55f) continue;
						bool ok = Walkable(a, b);
						if (!ok)
						{
							Vector3 landed;
							ok = OfflineBotPhysics.TryWalk(UnityToRaw(a), UnityToRaw(b), out landed);
						}
						if (!ok) continue;
						Nodes[i].Links.Add(j);
						Nodes[j].Links.Add(i);
						edges++;
					}
				}
			}

			for (int i = 0; i < Nodes.Count; i++)
			{
				int blocked = 0;
				Vector3 p = Nodes[i].Pos;
				for (int d = 0; d < 8; d++)
				{
					float ang = d * 45f * Mathf.Deg2Rad;
					Vector3 probe = p + new Vector3(Mathf.Sin(ang), 0f, Mathf.Cos(ang)) * 3.0f;
					if (!Walkable(p, probe)) blocked++;
				}
				Nodes[i].CoverScore = blocked / 8f;
				Nodes[i].Tactical = blocked >= 3 && blocked <= 6;
			}

			UnityEngine.Debug.Log("[OFFLINE-BOT-NAV] grid step=" + step.ToString("F1")
				+ " cells=" + (nx * nz) + " nodes=" + Nodes.Count + " edges=" + edges
				+ " boundsU=" + uMinX.ToString("F1") + "," + uMinZ.ToString("F1")
				+ " -> " + uMaxX.ToString("F1") + "," + uMaxZ.ToString("F1"));
			return Nodes.Count > 20 && edges > 0;
		}
		catch (System.Exception ex)
		{
			UnityEngine.Debug.LogWarning("[OFFLINE-BOT-NAV] grid bake failed: " + ex.Message);
			return false;
		}
	}

	/// <summary>把点落到地面：从 +3m 处向下 TryWalk。</summary>
	private static bool TryLand(Vector3 p, out Vector3 landed)
	{
		landed = p;
		// [OFFLINE-FIX] OfflineBotPhysics.TryWalk 内部只向下探 180cm；从 3m 高处起扫永远
		// 探不到地面（fraction>=0.999 直接被判失败），导致整张图一个节点都建不出来。
		Vector3 from = p + Vector3.up * 0.5f;
		Vector3 res;
		if (!OfflineBotPhysics.TryWalk(UnityToRaw(from), UnityToRaw(p), out res)) return false;
		Vector3 u = RawToUnity(res);
		// 落差过大说明是悬崖/屋顶，不用
		if (Mathf.Abs(u.y - p.y) > 4f) return false;
		landed = u;
		return true;
	}

	/// <summary>两点之间是否能直线走过去（水平体积扫描）。</summary>
	public static bool Walkable(Vector3 a, Vector3 b)
	{
		Vector3 from = UnityToRaw(a + Vector3.up * 0.20f);
		Vector3 to = UnityToRaw(b + Vector3.up * 0.20f);
		Vector3 hit, normal; float frac;
		// Cast 返回 true = trace 有效（没 startsolid），fraction 才是"走了多远"。
		if (!OfflineBotPhysics.Cast(from, to, OfflineBotPhysics.Radius, OfflineBotPhysics.Height,
			out hit, out normal, out frac))
		{
			return false;          // trace 无效/起点卡在实体里，不能走
		}
		return frac > 0.95f;       // 几乎走到终点才算通
	}

	// ---------------- 查询 ----------------

	public static int NearestNode(Vector3 p)
	{
		int best = -1; float bd = float.MaxValue;
		for (int i = 0; i < Nodes.Count; i++)
		{
			float d = (Nodes[i].Pos - p).sqrMagnitude;
			if (d < bd) { bd = d; best = i; }
		}
		return best;
	}

	private static int NearestReachableNode(Vector3 p, float maxDistance)
	{
		int best = -1;
		float bestDistance = maxDistance * maxDistance;
		for (int i = 0; i < Nodes.Count; i++)
		{
			float d = (Nodes[i].Pos - p).sqrMagnitude;
			if (d >= bestDistance) continue;
			if (d > 0.36f && !Walkable(p, Nodes[i].Pos)) continue;
			best = i; bestDistance = d;
		}
		return best;
	}

	/// <summary>把目标点吸附到最近的导航节点（目标在墙里/屋顶时用）。</summary>
	public static bool TrySnapToNode(Vector3 p, float maxDist, out Vector3 snapped)
	{
		snapped = p;
		int i = NearestNode(p);
		if (i < 0) return false;
		float d = Vector3.Distance(Nodes[i].Pos, p);
		if (d > maxDist) return false;
		snapped = Nodes[i].Pos;
		return true;
	}

	public static Vector3 RandomNodePos(int seed)
	{
		if (Nodes.Count == 0) return Vector3.zero;
		// 用确定性伪随机，避免每次调用都换点导致抖动
		int i = Mathf.Abs((seed * 1103515245 + 12345) % Nodes.Count);
		return Nodes[i].Pos;
	}

	public static Vector3 RandomTacticalPos(int seed)
	{
		if (Nodes.Count == 0) return Vector3.zero;
		List<int> t = new List<int>();
		for (int i = 0; i < Nodes.Count; i++) if (Nodes[i].Tactical) t.Add(i);
		if (t.Count == 0) return RandomNodePos(seed);
		int k = Mathf.Abs((seed * 2654435761u.GetHashCode() + 97) % t.Count);
		return Nodes[t[k]].Pos;
	}

	// ---------------- A* 寻路 ----------------

	private static readonly Dictionary<int, float> _gScore = new Dictionary<int, float>(256);
	private static readonly Dictionary<int, int> _cameFrom = new Dictionary<int, int>(256);
	private static readonly List<int> _open = new List<int>(256);
	private static readonly HashSet<int> _closed = new HashSet<int>();

	/// <summary>返回从 from 到 to 的路径点（不含起点，含终点）。失败返回空列表。</summary>
	public static List<Vector3> FindPath(Vector3 from, Vector3 to)
	{
		string ignored;
		return FindPath(from, to, out ignored);
	}

	public static List<Vector3> FindPath(Vector3 from, Vector3 to, out string status)
	{
		status = "unknown";
		List<Vector3> path = new List<Vector3>(16);
		// 直线可达就不用寻路
		if (Walkable(from, to)) { status = "direct"; path.Add(to); return path; }
		if (Nodes.Count < 2) { status = "no_graph"; return path; }
		int s = NearestReachableNode(from, 6f);
		// 目标两侧可能隔着薄墙，优先选择能与目标相连的节点。
		int g = NearestReachableNode(to, 6f);
		if (g < 0) g = NearestNode(to);
		if (s < 0 || g < 0) { status = s < 0 ? "no_start_node" : "no_goal_node"; return path; }
		if (s == g)
		{
			if ((Nodes[s].Pos - from).sqrMagnitude > 0.36f) path.Add(Nodes[s].Pos);
			if (Walkable(Nodes[s].Pos, to)) path.Add(to);
			status = path.Count == 0 ? "same_node_no_progress" : "same_node";
			return path;
		}

		_gScore.Clear(); _cameFrom.Clear(); _open.Clear(); _closed.Clear();
		_gScore[s] = 0f;
		_open.Add(s);
		int closest = s;
		float closestDistance = (Nodes[s].Pos - to).sqrMagnitude;
		bool reachedGoal = false;

		int guard = 0;
		while (_open.Count > 0 && guard++ < 4096)
		{
			// 取 f 最小的
			int bi = 0; float bf = float.MaxValue;
			for (int i = 0; i < _open.Count; i++)
			{
				int n = _open[i];
				float f = _gScore[n] + Vector3.Distance(Nodes[n].Pos, Nodes[g].Pos);
				if (f < bf) { bf = f; bi = i; }
			}
			int cur = _open[bi];
			_open.RemoveAt(bi);
			float remaining = (Nodes[cur].Pos - to).sqrMagnitude;
			if (remaining < closestDistance) { closest = cur; closestDistance = remaining; }
			if (cur == g) { reachedGoal = true; break; }
			if (_closed.Contains(cur)) continue;
			_closed.Add(cur);

			List<int> links = Nodes[cur].Links;
			for (int i = 0; i < links.Count; i++)
			{
				int nb = links[i];
				if (_closed.Contains(nb)) continue;
				float tentative = _gScore[cur] + Vector3.Distance(Nodes[cur].Pos, Nodes[nb].Pos);
				float old;
				if (_gScore.TryGetValue(nb, out old) && tentative >= old) continue;
				_gScore[nb] = tentative;
				_cameFrom[nb] = cur;
				if (!_open.Contains(nb)) _open.Add(nb);
			}
		}

		// 回溯
		List<int> rev = new List<int>(16);
		int c = reachedGoal ? g : closest;
		int g2 = 0;
		while (c != s && _cameFrom.ContainsKey(c) && g2++ < 512)
		{
			rev.Add(c);
			c = _cameFrom[c];
		}
		if (c != s) { status = "backtrack_limit"; return path; }
		if ((Nodes[s].Pos - from).sqrMagnitude > 0.36f) path.Add(Nodes[s].Pos);
		for (int i = rev.Count - 1; i >= 0; i--) path.Add(Nodes[rev[i]].Pos);
		if (reachedGoal && path.Count > 0)
		{
			Vector3 last = path[path.Count - 1];
			if ((last - to).sqrMagnitude > 1f && Walkable(last, to)) path.Add(to);
		}
		status = reachedGoal ? "graph" : (path.Count > 0 ? "partial" : "disconnected_no_progress");
		return path;
	}

	/// <summary>最近的战术点（掩体）：要求离威胁至少 minThreatDist，避免钻进敌人怀里。</summary>
	public static Vector3 NearestTactical(Vector3 pos, Vector3 threat, float minThreatDist, float maxSearch)
	{
		// 先找能从当前位置走到的起点，再只搜索与其连通的节点。
		int start = NearestReachableNode(pos, 6f);
		if (start < 0) return Vector3.zero;
		var reachable = new HashSet<int>();
		var queue = new Queue<int>();
		reachable.Add(start); queue.Enqueue(start);
		while (queue.Count > 0)
		{
			int current = queue.Dequeue();
			foreach (int link in Nodes[current].Links)
				if (link >= 0 && link < Nodes.Count && reachable.Add(link)) queue.Enqueue(link);
		}
		int best = -1;
		float bd = maxSearch * maxSearch;
		foreach (int i in reachable)
		{
			if (!Nodes[i].Tactical) continue;
			if (Vector3.Distance(Nodes[i].Pos, threat) < minThreatDist) continue;
			float d = (Nodes[i].Pos - pos).sqrMagnitude;
			if (d >= bd) continue;
			// 必须实际挡住当前威胁；起点无效的 trace 不能当作遮挡。
			Vector3 from = UnityToRaw(Nodes[i].Pos + Vector3.up * 1.5f);
			Vector3 to = UnityToRaw(threat + Vector3.up * 1.5f);
			Vector3 dir = to - from;
			if (dir.sqrMagnitude < 3600f) continue;
			from += dir.normalized * 60f;
			Vector3 hit, normal; float fraction;
			if (!OfflineBotPhysics.Cast(from, to, 0f, 0f, out hit, out normal, out fraction)) continue;
			if (fraction >= 0.999f) continue;
			bd = d; best = i;
		}
		if (best < 0) return Vector3.zero;
		return Nodes[best].Pos;
	}

	/// <summary>侧翼点：绕到威胁侧面（side=±1 决定左右），保持半径 radius。</summary>
	public static Vector3 FlankPoint(Vector3 self, Vector3 threat, int side, float radius)
	{
		Vector3 away = self - threat; away.y = 0f;
		if (away.sqrMagnitude < 0.01f) away = Vector3.forward;
		away.Normalize();
		Vector3 sideDir = Vector3.Cross(Vector3.up, away) * (side >= 0 ? 1f : -1f);
		Vector3 desired = threat + (away * 0.3f + sideDir * 1.0f).normalized * Mathf.Max(5f, radius);
		int n = NearestNode(desired);
		if (n < 0) return Vector3.zero;
		return Nodes[n].Pos;
	}

	public static string Stat()
	{
		int edges = 0;
		for (int i = 0; i < Nodes.Count; i++) edges += Nodes[i].Links.Count;
		int tactical = 0;
		for (int i = 0; i < Nodes.Count; i++) if (Nodes[i].Tactical) tactical++;
		return "nodes=" + Nodes.Count + " edges=" + (edges / 2) + " tactical=" + tactical + " baked=" + Baked;
	}
}
