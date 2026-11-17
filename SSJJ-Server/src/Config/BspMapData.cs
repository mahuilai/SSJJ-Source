using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace SSJJ.Server.Config
{
    public sealed class BspSpawnPoint
    {
        public float X { get; init; } // SSJJ raw X (cm)
        public float Y { get; init; } // SSJJ raw Y (cm)
        public float Z { get; init; } // SSJJ raw Z height (cm)
        public float Yaw { get; init; }
        public int TeamFlag { get; init; } // 1 = CT, 0 = T, 2 = I (free)
    }

    public sealed class BspBombSite
    {
        public float X { get; init; } // SSJJ raw X (cm)
        public float Y { get; init; } // SSJJ raw Y (cm)
        public float Z { get; init; } // SSJJ raw Z height (cm)
        public float Radius { get; init; } = 180f;
    }

    public sealed class BspMapData
    {
        public int MapId { get; init; }
        public string? BspPath { get; init; }
        public byte[]? RawBspBytes { get; init; }
        public List<BspSpawnPoint> Spawns { get; } = new List<BspSpawnPoint>();
        public List<BspBombSite> BombSites { get; } = new List<BspBombSite>();

        public static BspMapData Load(int sceneId, string battleClientDir)
        {
            var data = new BspMapData { MapId = sceneId };
            string streaming = Path.Combine(battleClientDir, "SSJJ_BattleClient_Unity_Data", "StreamingAssets");
            string[] candidates =
            {
                Path.Combine(streaming, $"map{sceneId}", "model.bsp.raw"),
                Path.Combine(streaming, $"map{sceneId}", "data", "model.bsp.raw.bytes"),
                Path.Combine(streaming, $"map{sceneId % 1000}", "model.bsp.raw"),
            };

            string? path = null;
            foreach (var c in candidates)
            {
                if (File.Exists(c)) { path = c; break; }
            }
            if (path == null)
            {
                Console.WriteLine($"[SSJJ-Server][BSP] Warning: model.bsp.raw missing for map{sceneId}");
                return data;
            }

            byte[] bytes = File.ReadAllBytes(path);
            var loaded = new BspMapData { MapId = sceneId, BspPath = path, RawBspBytes = bytes };
            if (bytes.Length < 16) return loaded;

            int entOff = BitConverter.ToInt32(bytes, 8);
            int entLen = BitConverter.ToInt32(bytes, 12);
            if (entOff <= 0 || entLen <= 0 || entOff + entLen > bytes.Length) return loaded;

            string text = Encoding.Latin1.GetString(bytes, entOff, entLen);
            foreach (string block in text.Split('}'))
            {
                string? cls = Extract(block, "classname");
                string? origin = Extract(block, "origin");
                if (string.IsNullOrEmpty(cls) || string.IsNullOrEmpty(origin)) continue;

                string[] xyz = origin.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                if (xyz.Length < 3) continue;
                if (!float.TryParse(xyz[0], NumberStyles.Float, CultureInfo.InvariantCulture, out float x)) continue;
                if (!float.TryParse(xyz[1], NumberStyles.Float, CultureInfo.InvariantCulture, out float y)) continue;
                if (!float.TryParse(xyz[2], NumberStyles.Float, CultureInfo.InvariantCulture, out float z)) continue;

                if (cls.Contains("info_player_start", StringComparison.OrdinalIgnoreCase))
                {
                    float yaw = 90f;
                    string? ys = Extract(block, "yaw");
                    if (!string.IsNullOrEmpty(ys) && float.TryParse(ys, NumberStyles.Float, CultureInfo.InvariantCulture, out float parsedYaw))
                    {
                        yaw = parsedYaw;
                    }
                    int teamFlag = cls.Contains("CT", StringComparison.OrdinalIgnoreCase) ? 1
                                 : (cls.Contains("_I", StringComparison.OrdinalIgnoreCase) ? 2 : 0);
                    loaded.Spawns.Add(new BspSpawnPoint { X = x, Y = y, Z = z, Yaw = yaw, TeamFlag = teamFlag });
                }
                else if (cls.Equals("Info_Point_Break", StringComparison.OrdinalIgnoreCase))
                {
                    float radius = 180f;
                    string? rs = Extract(block, "radius");
                    if (!string.IsNullOrEmpty(rs) && float.TryParse(rs, NumberStyles.Float, CultureInfo.InvariantCulture, out float parsedR) && parsedR > 30f)
                    {
                        radius = parsedR;
                    }
                    loaded.BombSites.Add(new BspBombSite { X = x, Y = y, Z = z, Radius = radius });
                    Console.WriteLine($"[SSJJ-Server][BSP] map{sceneId} BombSite[{loaded.BombSites.Count - 1}] = ({x:F0},{y:F0},{z:F0}) r={radius:F0}");
                }
            }

            Console.WriteLine($"[SSJJ-Server][BSP] map{sceneId}: loaded {bytes.Length / 1024}KB from {path} | spawns={loaded.Spawns.Count} bombSites={loaded.BombSites.Count}");
            return loaded;
        }

        public BspSpawnPoint PickSpawn(int team, int index, bool freeForAll)
        {
            List<BspSpawnPoint> pool;
            if (freeForAll)
            {
                pool = Spawns.FindAll(s => s.TeamFlag == 2);
                if (pool.Count == 0) pool = Spawns;
            }
            else if (team == 2)
            {
                pool = Spawns.FindAll(s => s.TeamFlag == 1);
                if (pool.Count == 0) pool = Spawns;
            }
            else
            {
                pool = Spawns.FindAll(s => s.TeamFlag == 0);
                if (pool.Count == 0) pool = Spawns;
            }

            if (pool.Count > 0)
            {
                return pool[Math.Abs(index) % pool.Count];
            }

            return team == 2
                ? new BspSpawnPoint { X = 3683.00f, Y = 5491.48f, Z = 119.38f, Yaw = -90f, TeamFlag = 1 }
                : new BspSpawnPoint { X = 3896.36f, Y = 1254.76f, Z = 119.38f, Yaw = 90f, TeamFlag = 0 };
        }

        private static string? Extract(string block, string key)
        {
            var m = Regex.Match(block, "\"" + Regex.Escape(key) + "\"\\s+\"([^\"]*)\"", RegexOptions.IgnoreCase);
            return m.Success ? m.Groups[1].Value : null;
        }
    }
}
