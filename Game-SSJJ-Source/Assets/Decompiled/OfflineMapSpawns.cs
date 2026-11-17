using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;

/// <summary>
/// 从地图 BSP 的 entity lump 读取原版默认出生点（info_player_start_CT / _T）。
/// 离线端原先把 map1 的出生点写死，切换到其它地图就会出生在地图外。
/// </summary>
public static class OfflineMapSpawns
{
    private static readonly Dictionary<int, List<float[]>> s_cache = new Dictionary<int, List<float[]>>();
    private static readonly Dictionary<int, List<float[]>> s_bombCache = new Dictionary<int, List<float[]>>();

    private static string ResolveBspPath(int sceneId)
    {
        string root = Path.Combine(Application.streamingAssetsPath, "map" + sceneId);
        string path = Path.Combine(root, "model.bsp.raw");
        if (!File.Exists(path)) path = Path.Combine(root, Path.Combine("data", "model.bsp.raw.bytes"));
        if (!File.Exists(path))
        {
            int altId = sceneId % 1000;
            string altPath = Path.Combine(Application.streamingAssetsPath, "map" + altId, "model.bsp.raw");
            if (File.Exists(altPath)) path = altPath;
            else
            {
                string map1 = Path.Combine(Application.streamingAssetsPath, "map1", "model.bsp.raw");
                if (File.Exists(map1)) path = map1;
            }
        }
        return path;
    }

    public static List<float[]> LoadBombSites(int sceneId)
    {
        List<float[]> cached;
        if (s_bombCache.TryGetValue(sceneId, out cached)) return cached;
        List<float[]> list = new List<float[]>();
        try
        {
            string path = ResolveBspPath(sceneId);
            if (!File.Exists(path)) { s_bombCache[sceneId] = list; return list; }
            byte[] d = File.ReadAllBytes(path);
            if (d.Length < 16) { s_bombCache[sceneId] = list; return list; }
            int entOff = BitConverter.ToInt32(d, 8);
            int entLen = BitConverter.ToInt32(d, 12);
            if (entOff <= 0 || entLen <= 0 || entOff + entLen > d.Length) { s_bombCache[sceneId] = list; return list; }
            string text = Encoding.GetEncoding("latin1").GetString(d, entOff, entLen);
            foreach (string block in text.Split('}'))
            {
                if (block.IndexOf("Info_Point_Break", StringComparison.OrdinalIgnoreCase) < 0) continue;
                string origin = Extract(block, "origin");
                if (string.IsNullOrEmpty(origin)) continue;
                string[] xyz = origin.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (xyz.Length < 3) continue;
                float x, y, z;
                if (!float.TryParse(xyz[0], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out x)) continue;
                if (!float.TryParse(xyz[1], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out y)) continue;
                if (!float.TryParse(xyz[2], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out z)) continue;
                float radius = 180f;
                string rs = Extract(block, "radius");
                if (!string.IsNullOrEmpty(rs))
                {
                    float tmp;
                    if (float.TryParse(rs, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out tmp) && tmp > 30f)
                        radius = tmp;
                }
                list.Add(new float[] { x, y, z, radius });
            }
            Debug.Log("[OFFLINE-C4] map" + sceneId + " Info_Point_Break sites=" + list.Count);
        }
        catch (Exception ex)
        {
            Debug.LogWarning("[OFFLINE-C4] bomb site load fail map" + sceneId + ": " + ex.Message);
        }
        s_bombCache[sceneId] = list;
        return list;
    }

    // 返回每个出生点：{ X, 水平Z, 高度Y, yaw }（对应 PlayerEntityData 的 X/Y/Z）
    public static List<float[]> Load(int sceneId)
    {
        List<float[]> cached;
        if (s_cache.TryGetValue(sceneId, out cached)) return cached;
        List<float[]> list = new List<float[]>();
        try
        {
            string root = Path.Combine(Application.streamingAssetsPath, "map" + sceneId);
            string path = Path.Combine(root, "model.bsp.raw");
            if (!File.Exists(path)) path = Path.Combine(root, Path.Combine("data", "model.bsp.raw.bytes"));
            if (!File.Exists(path))
            {
                int altId = sceneId % 1000;
                string altPath = Path.Combine(Application.streamingAssetsPath, "map" + altId, "model.bsp.raw");
                if (File.Exists(altPath))
                {
                    path = altPath;
                }
                else
                {
                    string map1 = Path.Combine(Application.streamingAssetsPath, "map1", "model.bsp.raw");
                    if (File.Exists(map1)) path = map1;
                }
            }
            if (!File.Exists(path))
            {
                Debug.LogWarning("[OFFLINE-SPAWN] bsp raw missing for map" + sceneId + ": " + path);
                s_cache[sceneId] = list;
                return list;
            }
            byte[] d = File.ReadAllBytes(path);
            if (d.Length < 16) { s_cache[sceneId] = list; return list; }
            int entOff = BitConverter.ToInt32(d, 8);
            int entLen = BitConverter.ToInt32(d, 12);
            if (entOff <= 0 || entLen <= 0 || entOff + entLen > d.Length)
            {
                Debug.LogWarning("[OFFLINE-SPAWN] bad entity lump map" + sceneId);
                s_cache[sceneId] = list;
                return list;
            }
            string text = Encoding.GetEncoding("latin1").GetString(d, entOff, entLen);
            foreach (string block in text.Split('}'))
            {
                if (block.IndexOf("info_player_start", StringComparison.OrdinalIgnoreCase) < 0) continue;
                string cls = Extract(block, "classname");
                string origin = Extract(block, "origin");
                if (string.IsNullOrEmpty(cls) || string.IsNullOrEmpty(origin)) continue;
                string[] xyz = origin.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (xyz.Length < 3) continue;
                float x, y, z;
                if (!float.TryParse(xyz[0], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out x)) continue;
                if (!float.TryParse(xyz[1], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out y)) continue;
                if (!float.TryParse(xyz[2], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out z)) continue;
                float yaw = 180f;
                string ys = Extract(block, "yaw");
                if (!string.IsNullOrEmpty(ys))
                {
                    float tmp;
                    if (float.TryParse(ys, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out tmp)) yaw = tmp;
                }
                bool isCT = cls.IndexOf("CT", StringComparison.OrdinalIgnoreCase) >= 0;
                // [OFFLINE-SPAWN] 记录 I 点（自由出生点）：map1 的 T 出生房被门/梯子隔开，
                // 离线 nav 进不去，敌人会卡死在 T 房。I 点分布在主战场，作为敌方兜底。
                bool isI = cls.IndexOf("_I", StringComparison.OrdinalIgnoreCase) >= 0;
                float teamFlag = isCT ? 1f : (isI ? 2f : 0f);
                list.Add(new float[] { x, y, z, teamFlag, yaw });
            }
            Debug.Log("[OFFLINE-SPAWN] map" + sceneId + " spawns=" + list.Count);
        }
        catch (Exception ex)
        {
            Debug.LogWarning("[OFFLINE-SPAWN] load fail map" + sceneId + ": " + ex.Message);
        }
        s_cache[sceneId] = list;
        return list;
    }

    /// <summary>取第一个出生点：优先 CT（玩家），没有就取第一个。</summary>
    public static float[] FirstSpawn(int sceneId, bool preferCT)
    {
        List<float[]> list = Load(sceneId);
        if (list.Count == 0) return null;
        // 原版服务端从本阵营出生点里随机挑一个，这里保持一致。
        List<float[]> pool = new List<float[]>();
        for (int i = 0; i < list.Count; i++)
        {
            if ((list[i][3] == 1f) == preferCT) pool.Add(list[i]);
        }
        if (pool.Count == 0) pool = list;
        return pool[UnityEngine.Random.Range(0, pool.Count)];
    }

    private static string Extract(string block, string key)
    {
        try
        {
            Match m = Regex.Match(block, "\"" + Regex.Escape(key) + "\"\\s+\"([^\"]*)\"", RegexOptions.IgnoreCase);
            return m.Success ? m.Groups[1].Value : null;
        }
        catch (Exception)
        {
            return null;
        }
    }
}
