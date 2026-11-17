using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace SSJJ.Server.NativeEngine
{
    /// <summary>
    /// 对标 OfflineMapSpawns.cs：从地图 BSP 的 Entity Lump 中读取官方 info_player_start 原始三元组
    /// 并提供地图 BSP 文件加载与空间坐标校验
    /// </summary>
    public static class NativeBspPhysicsHost
    {
        private static readonly Dictionary<int, List<float[]>> s_cache = new Dictionary<int, List<float[]>>();

        /// <summary>
        /// 从 map{sceneId} 的 model.bsp.raw 中解析出生点
        /// 返回格式：{ X, 水平Z, 高度Y, 阵营(1=CT, 0=T, 2=I), yaw }
        /// </summary>
        public static List<float[]> LoadMapSpawns(int sceneId, string streamingAssetsDir = @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets")
        {
            if (s_cache.TryGetValue(sceneId, out var cached)) return cached;
            var list = new List<float[]>();

            try
            {
                string root = Path.Combine(streamingAssetsDir, "map" + sceneId);
                string path = Path.Combine(root, "model.bsp.raw");
                if (!File.Exists(path)) path = Path.Combine(root, "data", "model.bsp.raw.bytes");

                if (!File.Exists(path))
                {
                    int altId = sceneId % 1000;
                    string altPath = Path.Combine(streamingAssetsDir, "map" + altId, "model.bsp.raw");
                    if (File.Exists(altPath))
                    {
                        path = altPath;
                    }
                    else
                    {
                        string map1 = Path.Combine(streamingAssetsDir, "map1", "model.bsp.raw");
                        if (File.Exists(map1)) path = map1;
                    }
                }

                if (!File.Exists(path))
                {
                    Console.WriteLine($"[SSJJ-Server] Warning: BSP raw missing for map{sceneId}: {path}");
                    s_cache[sceneId] = list;
                    return list;
                }

                byte[] d = File.ReadAllBytes(path);
                if (d.Length >= 16)
                {
                    int entOff = BitConverter.ToInt32(d, 8);
                    int entLen = BitConverter.ToInt32(d, 12);
                    if (entOff > 0 && entLen > 0 && entOff + entLen <= d.Length)
                    {
                        string text = Encoding.GetEncoding("latin1").GetString(d, entOff, entLen);
                        foreach (string block in text.Split('}'))
                        {
                            if (block.IndexOf("info_player_start", StringComparison.OrdinalIgnoreCase) < 0) continue;
                            string cls = Extract(block, "classname");
                            string origin = Extract(block, "origin");
                            if (string.IsNullOrEmpty(cls) || string.IsNullOrEmpty(origin)) continue;

                            string[] xyz = origin.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                            if (xyz.Length < 3) continue;

                            if (!float.TryParse(xyz[0], NumberStyles.Float, CultureInfo.InvariantCulture, out float x)) continue;
                            if (!float.TryParse(xyz[1], NumberStyles.Float, CultureInfo.InvariantCulture, out float y)) continue;
                            if (!float.TryParse(xyz[2], NumberStyles.Float, CultureInfo.InvariantCulture, out float z)) continue;

                            float yaw = 180f;
                            string ys = Extract(block, "yaw");
                            if (!string.IsNullOrEmpty(ys) && float.TryParse(ys, NumberStyles.Float, CultureInfo.InvariantCulture, out float tmpYaw))
                            {
                                yaw = tmpYaw;
                            }

                            bool isCT = cls.IndexOf("CT", StringComparison.OrdinalIgnoreCase) >= 0;
                            bool isI = cls.IndexOf("_I", StringComparison.OrdinalIgnoreCase) >= 0;
                            float teamFlag = isCT ? 1f : (isI ? 2f : 0f);

                            list.Add(new float[] { x, y, z, teamFlag, yaw });
                        }
                    }
                }

                Console.WriteLine($"[SSJJ-Server] Loaded {list.Count} native spawn points for map{sceneId} from BSP Entity Lump!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SSJJ-Server] Error reading BSP spawns for map{sceneId}: {ex.Message}");
            }

            s_cache[sceneId] = list;
            return list;
        }

        private static string Extract(string block, string key)
        {
            try
            {
                Match m = Regex.Match(block, "\"" + Regex.Escape(key) + "\"\\s+\"([^\"]*)\"", RegexOptions.IgnoreCase);
                return m.Success ? m.Groups[1].Value : "";
            }
            catch
            {
                return "";
            }
        }
    }
}
