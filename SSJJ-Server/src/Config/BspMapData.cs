using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;

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

    public readonly record struct SpawnBounds(Vector3f Min, Vector3f Max)
    {
        public bool Contains(float x, float y, float z) =>
            x >= Min.X && x <= Max.X && y >= Min.Y && y <= Max.Y && z >= Min.Z && z <= Max.Z;
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
            string[] candidates = sceneId >= 100000
                ? new[]
                {
                    Path.Combine(streaming, $"map{sceneId}", "model.bsp.raw"),
                    Path.Combine(streaming, $"map{sceneId}", "data", "model.bsp.raw.bytes"),
                }
                : new[]
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
                if (sceneId == 100001) PopulateIndustrial01Spawns(data);
                return data;
            }

            byte[] bytes = File.ReadAllBytes(path);
            var loaded = new BspMapData { MapId = sceneId, BspPath = path, RawBspBytes = bytes };
            if (sceneId == 100001)
            {
                PopulateIndustrial01Spawns(loaded);
                Console.WriteLine($"[SSJJ-Server][BSP] map{sceneId}: loaded {bytes.Length / 1024}KB WeSce mesh from {path} | spawns={loaded.Spawns.Count}");
                return loaded;
            }
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

        public SpawnBounds GetLoadoutBounds(BspSpawnPoint spawn, float groundZ, bool freeForAll)
        {
            var min = new Vector3f(spawn.X, spawn.Y, Math.Min(spawn.Z, groundZ));
            var max = new Vector3f(spawn.X, spawn.Y, Math.Max(spawn.Z, groundZ));
            if (!freeForAll)
            {
                foreach (var point in Spawns)
                {
                    if (point.TeamFlag != spawn.TeamFlag) continue;
                    var origin = new Vector3f(point.X, point.Y, point.Z);
                    min = Vector3f.Min(min, origin);
                    max = Vector3f.Max(max, origin);
                }
            }
            var padding = new Vector3f(Quake3Pmove.PlayerRadius, Quake3Pmove.PlayerRadius, G_Active.STAND_VIEW_HEIGHT);
            return new SpawnBounds(min - padding, max + padding);
        }

        private static void PopulateIndustrial01Spawns(BspMapData target)
        {
            // Authentic player spawn from industrial_01.pcapng (Seq 1, Id=1, floor Z=519.8)
            target.Spawns.Add(new BspSpawnPoint { X = 7509.20f, Y = 1409.09f, Z = 522.0f, Yaw = 180.0f, TeamFlag = 0 });

            // Stage 1..4 monster wave spawns on main floor (Z=522.0) connected via Zone 1 -> Door 1 -> Zone 2
            // Stage 1 (indices 0..3) - Courtyard Zone 1
            target.Spawns.Add(new BspSpawnPoint { X = 6252.18f, Y = 1329.36f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 6108.95f, Y = 1239.36f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 6252.18f, Y = 1608.45f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 6453.64f, Y = 1510.99f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });

            // Stage 2 (indices 4..7) - Mid Courtyard approaching Door 1
            target.Spawns.Add(new BspSpawnPoint { X = 5850.00f, Y = 1750.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 5720.00f, Y = 1890.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 5980.00f, Y = 1960.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 6108.95f, Y = 2068.74f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });

            // Stage 3 (indices 8..11) - Door 1 / Zone 2 Entrance
            target.Spawns.Add(new BspSpawnPoint { X = 5581.98f, Y = 1893.61f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 5420.00f, Y = 2150.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 5328.00f, Y = 2412.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 5150.00f, Y = 2550.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });

            // Stage 4 Boss 雷霆加特林 + guards (indices 12..15)
            target.Spawns.Add(new BspSpawnPoint { X = 5581.98f, Y = 1893.61f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 5328.00f, Y = 2412.00f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 4722.27f, Y = 2700.38f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
            target.Spawns.Add(new BspSpawnPoint { X = 4722.27f, Y = 3158.36f, Z = 522.0f, Yaw = 0.0f, TeamFlag = 1 });
        }

        private static string? Extract(string block, string key)
        {
            var m = Regex.Match(block, "\"" + Regex.Escape(key) + "\"\\s+\"([^\"]*)\"", RegexOptions.IgnoreCase);
            return m.Success ? m.Groups[1].Value : null;
        }
    }
}
