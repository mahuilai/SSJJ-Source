using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using NetData;
using SSJJ.Data;

namespace SSJJ.Server.Config
{
    public sealed class BagSlotConfig
    {
        [JsonPropertyName("primary")] public string Primary { get; set; } = "m4a1";
        [JsonPropertyName("secondary")] public string Secondary { get; set; } = "deagle";
        [JsonPropertyName("melee")] public string Melee { get; set; } = "dagger";
        [JsonPropertyName("throwable")] public string Throwable { get; set; } = "grenade";
        [JsonPropertyName("throwable2")] public string Throwable2 { get; set; } = "";
        [JsonPropertyName("throwable3")] public string Throwable3 { get; set; } = "";
        [JsonPropertyName("primary_id")] public int PrimaryId { get; set; }
        [JsonPropertyName("secondary_id")] public int SecondaryId { get; set; }
        [JsonPropertyName("melee_id")] public int MeleeId { get; set; }
        [JsonPropertyName("throwable_id")] public int ThrowableId { get; set; }
        [JsonPropertyName("throwable2_id")] public int Throwable2Id { get; set; }
        [JsonPropertyName("throwable3_id")] public int Throwable3Id { get; set; }
        [JsonPropertyName("primary_skin")] public string PrimarySkin { get; set; } = "";
        [JsonPropertyName("secondary_skin")] public string SecondarySkin { get; set; } = "";
        [JsonPropertyName("melee_skin")] public string MeleeSkin { get; set; } = "";
        [JsonPropertyName("throwable_skin")] public string ThrowableSkin { get; set; } = "";
        [JsonPropertyName("throwable2_skin")] public string Throwable2Skin { get; set; } = "";
        [JsonPropertyName("throwable3_skin")] public string Throwable3Skin { get; set; } = "";

        public string GetSlotWeapon(int slot) => slot switch
        {
            1 => Primary ?? "",
            2 => Secondary ?? "",
            3 => Melee ?? "",
            4 => Throwable ?? "",
            6 => Throwable2 ?? "",
            7 => Throwable3 ?? "",
            _ => Primary ?? ""
        };

        public string GetSlotSkin(int slot) => slot switch
        {
            1 => PrimarySkin ?? "",
            2 => SecondarySkin ?? "",
            3 => MeleeSkin ?? "",
            4 => ThrowableSkin ?? "",
            6 => Throwable2Skin ?? "",
            7 => Throwable3Skin ?? "",
            _ => ""
        };

        public int GetSlotId(int slot) => slot switch
        {
            1 => PrimaryId,
            2 => SecondaryId,
            3 => MeleeId,
            4 => ThrowableId,
            6 => Throwable2Id,
            7 => Throwable3Id,
            _ => 0
        };
    }

    public sealed class BiohazardSettings
    {
        [JsonPropertyName("round_ms")] public int RoundMs { get; set; }
        [JsonPropertyName("respawn_ms")] public int RespawnMs { get; set; }
        [JsonPropertyName("intermission_ms")] public int IntermissionMs { get; set; }
        [JsonPropertyName("mother_hp")] public int MotherHp { get; set; }
        [JsonPropertyName("infected_hp")] public int InfectedHp { get; set; }
        [JsonPropertyName("damage_per_point")] public int DamagePerPoint { get; set; }

        public bool IsValid => RoundMs > GameModes.BiohazardRound.IncubationMs
            && RespawnMs > 0 && IntermissionMs > 0 && MotherHp >= InfectedHp && InfectedHp > 100 && DamagePerPoint >= 0;
    }

    public sealed class LobbyPlayerConfig
    {
        [JsonPropertyName("name")] public string Name { get; set; } = "";
        [JsonPropertyName("team")] public int Team { get; set; }
        [JsonPropertyName("active_bag")] public int ActiveBag { get; set; }
        [JsonPropertyName("career")] public string Career { get; set; } = "";
        [JsonPropertyName("career_skin")] public string CareerSkin { get; set; } = "";
        [JsonPropertyName("hand")] public string Hand { get; set; } = "";
        [JsonPropertyName("bags")] public List<BagSlotConfig>? Bags { get; set; }
    }

    public sealed class ServerConfig
    {
        [JsonPropertyName("map")] public string Map { get; set; } = "map12";
        [JsonPropertyName("mode")] public string Mode { get; set; } = "team_ai";
        [JsonPropertyName("race_type")] public int RaceType { get; set; } = 0;
        [JsonPropertyName("career")] public string Career { get; set; } = "police";
        [JsonPropertyName("career_skin")] public string CareerSkin { get; set; } = "";
        [JsonPropertyName("hand")] public string Hand { get; set; } = "man";
        [JsonPropertyName("player_name")] public string PlayerName { get; set; } = "石井执行官";
        [JsonPropertyName("player_team")] public int PlayerTeam { get; set; } = 1;
        [JsonPropertyName("max_human_players")] public int MaxHumanPlayers { get; set; } = 1;
        [JsonPropertyName("lobby_players")] public Dictionary<long, LobbyPlayerConfig> LobbyPlayers { get; set; } = new();
        [JsonPropertyName("char_id")] public long CharId { get; set; } = 1000200072528;
        [JsonPropertyName("room_id")] public long RoomId { get; set; } = 1001;
        [JsonPropertyName("active_bag")] public int ActiveBag { get; set; } = 1; // 1-based (1..5)
        [JsonPropertyName("ally_bot_count")] public int AllyBots { get; set; } = 3;
        [JsonPropertyName("enemy_bot_count")] public int EnemyBots { get; set; } = 4;
        [JsonPropertyName("bot_count")] public int BotCount { get; set; } = -1;
        [JsonPropertyName("bot_difficulty")] public string BotDifficulty { get; set; } = "normal";
        [JsonPropertyName("bot_career")] public string BotCareer { get; set; } = "pandora_t";
        [JsonPropertyName("god_mode")] public bool GodMode { get; set; } = false;
        [JsonPropertyName("win_score")] public int WinScoreOverride { get; set; } = 0;
        [JsonPropertyName("biohazard")] public BiohazardSettings? Biohazard { get; set; }
        [JsonPropertyName("bags")] public List<BagSlotConfig> Bags { get; set; } = new List<BagSlotConfig>();

        // Runtime / CLI options
        [JsonIgnore] public int TcpPort { get; set; } = 27100;
        [JsonIgnore] public int UdpPort { get; set; } = 27101;
        [JsonIgnore] public int Seed { get; set; } = 12345;
        [JsonIgnore] public bool Headless { get; set; }
        [JsonIgnore] public double DurationSeconds { get; set; }
        [JsonIgnore] public bool PrintLa { get; set; }
        [JsonIgnore] public string BattleServerIp { get; private set; } = IPAddress.Loopback.ToString();
        [JsonIgnore] public bool TraceProbe { get; set; }
        [JsonIgnore] public string ResourceBase { get; set; } = "http://127.0.0.1:8080/s3/";
        [JsonIgnore] public string ProjectRoot { get; set; } = @"D:\逆向\SSJJ双塔惊魂";
        [JsonIgnore] public string BattleClientDir { get; set; } = @"D:\SSJJ-4399\battle\3_64";

        public List<BagSlotConfig> GetHumanBags(long characterId)
        {
            if (characterId > 0 && LobbyPlayers.TryGetValue(characterId, out var lp) && lp.Bags is { Count: > 0 })
            {
                return lp.Bags;
            }
            return Bags;
        }

        public int GetHumanActiveBag(long characterId)
        {
            var bags = GetHumanBags(characterId);
            int raw = characterId > 0 && LobbyPlayers.TryGetValue(characterId, out var lp) && lp.ActiveBag > 0
                ? lp.ActiveBag
                : ActiveBag;
            return Math.Clamp(raw, 1, Math.Max(1, bags.Count));
        }

        public string GetHumanCareer(long characterId)
        {
            string? c = characterId > 0 && LobbyPlayers.TryGetValue(characterId, out var lp) && !string.IsNullOrWhiteSpace(lp.Career)
                ? lp.Career
                : Career;
            return string.IsNullOrWhiteSpace(c) ? "police" : c;
        }

        public string GetHumanCareerSkin(long characterId)
        {
            if (characterId > 0 && LobbyPlayers.TryGetValue(characterId, out var lp) && !string.IsNullOrWhiteSpace(lp.CareerSkin))
            {
                return lp.CareerSkin;
            }
            return CareerSkin ?? "";
        }

        public string GetHumanHand(long characterId)
        {
            string? h = characterId > 0 && LobbyPlayers.TryGetValue(characterId, out var lp) && !string.IsNullOrWhiteSpace(lp.Hand)
                ? lp.Hand
                : Hand;
            return string.IsNullOrWhiteSpace(h) ? "man" : h;
        }

        public string GetHumanName(long characterId, int playerId)
        {
            if (characterId > 0 && LobbyPlayers.TryGetValue(characterId, out var lp) && !string.IsNullOrWhiteSpace(lp.Name))
            {
                return lp.Name;
            }
            string fallback = string.IsNullOrWhiteSpace(PlayerName) ? "石井执行官" : PlayerName;
            return playerId <= 1 ? fallback : $"{fallback} #{playerId}";
        }

        public int MapId => ParseMapId(Map);

        public int EffectiveRaceType
        {
            get
            {
                if (RaceType > 0) return RaceType;
                return ModeToRaceType(Mode);
            }
        }

        public static int ParseMapId(string? map)
        {
            if (string.IsNullOrWhiteSpace(map)) return 12;
            var digits = new StringBuilder();
            foreach (char c in map)
            {
                if (char.IsDigit(c)) digits.Append(c);
            }
            return int.TryParse(digits.ToString(), out int id) && id > 0 ? id : 12;
        }

        public static int ModeToRaceType(string? mode)
        {
            return (mode ?? "team_ai").Trim().ToLowerInvariant() switch
            {
                "explode" or "bomb" or "c4" or "2" => 2,
                "team" or "group" or "3" => 3,
                "personal" or "ffa" or "5" => 5,
                "biohazard" or "biochemical" or "6" => 6,
                "deathmatch" or "death_match" or "12" => 12,
                "blade" or "knife" or "15" => 15,
                "weaponmaster" or "64" => 64,
                "flyknife" or "74" => 74,
                "team_ai" or "bot_team" or "2003" => 2003,
                "bighead" or "bighead_ai" or "2019" => 2019,
                "blade_ai" or "bot_knife" or "2041" => 2041,
                "pve" or "rpg" or "adventure" or "industrial_01" or "10001" => 10001,
                _ => 2003
            };
        }

        public static bool IsFreeForAll(int raceType) =>
            raceType == 5 || raceType == 12 || raceType == 64 || raceType == 74;

        public static bool IsMeleeOnly(int raceType) =>
            raceType == 15 || raceType == 2041;

        public static bool IsBiohazard(int raceType) =>
            raceType == 6;

        public static bool IsExplode(int raceType) =>
            raceType == 2;

        public static bool IsPve(int raceType) =>
            raceType == 10001;

        public void EnsureDefaults()
        {
            if (Bags == null) Bags = new List<BagSlotConfig>();
            while (Bags.Count < 5)
            {
                Bags.Add(new BagSlotConfig());
            }
            if (LobbyPlayers == null) LobbyPlayers = new Dictionary<long, LobbyPlayerConfig>();
            foreach (var lp in LobbyPlayers.Values)
            {
                if (lp.Bags is { Count: > 0 })
                {
                    while (lp.Bags.Count < 5) lp.Bags.Add(new BagSlotConfig());
                }
            }
            if (ActiveBag < 1 || ActiveBag > Bags.Count) ActiveBag = 1;
            if (PlayerTeam != 1 && PlayerTeam != 2) PlayerTeam = 1;
            if (IsBiohazard(EffectiveRaceType) && Biohazard == null)
            {
                Biohazard = new BiohazardSettings
                {
                    RoundMs = 180_000,
                    RespawnMs = 5_000,
                    IntermissionMs = 4_000,
                    MotherHp = 4000,
                    InfectedHp = 1500,
                    DamagePerPoint = 200
                };
            }
            if (IsPve(EffectiveRaceType))
            {
                if (string.IsNullOrWhiteSpace(Map) || string.Equals(Map, "map12", StringComparison.OrdinalIgnoreCase))
                {
                    Map = "map100001";
                }
                PlayerTeam = 1;
                AllyBots = 0;
                if (EnemyBots <= 0) EnemyBots = 4;
                return;
            }
            if (BotCount >= 0 && AllyBots == 0 && EnemyBots == 0)
            {
                if (IsFreeForAll(EffectiveRaceType))
                {
                    AllyBots = 0;
                    EnemyBots = BotCount;
                }
                else
                {
                    AllyBots = BotCount / 2;
                    EnemyBots = BotCount - AllyBots;
                }
            }
        }

        public static ServerConfig Load(string[] args, out string? error)
        {
            error = null;
            var cfg = new ServerConfig();
            string? configJsonPath = null;
            for (int i = 0; i < args.Length - 1; i++)
            {
                if (args[i] == "--config-json") configJsonPath = args[i + 1];
            }
            if (!string.IsNullOrEmpty(configJsonPath) && File.Exists(configJsonPath))
            {
                try
                {
                    var loaded = JsonSerializer.Deserialize<ServerConfig>(File.ReadAllText(configJsonPath, Encoding.UTF8));
                    if (loaded != null) cfg = loaded;
                }
                catch (Exception ex)
                {
                    error = $"Failed to parse --config-json: {ex.Message}";
                    return cfg;
                }
            }

            string? battleHost = null;
            for (int i = 0; i < args.Length; i++)
            {
                switch (args[i])
                {
                    case "--config-json":
                        i++;
                        break;
                    case "--max-human-players":
                        if (++i >= args.Length || !int.TryParse(args[i], out int humans) || humans is < 1 or > 16)
                        {
                            error = "--max-human-players requires 1..16";
                            return cfg;
                        }
                        cfg.MaxHumanPlayers = humans;
                        break;
                    case "--battle-host":
                        if (++i >= args.Length || Uri.CheckHostName(args[i]) is not (UriHostNameType.IPv4 or UriHostNameType.Dns))
                        {
                            error = "--battle-host requires an IPv4 address or DNS name";
                            return cfg;
                        }
                        battleHost = args[i];
                        break;
                    case "--char-id":
                        if (++i >= args.Length || !long.TryParse(args[i], out long charIdVal) || charIdVal <= 0)
                        {
                            error = "--char-id requires > 0";
                            return cfg;
                        }
                        cfg.CharId = charIdVal;
                        break;
                    case "--room-id":
                        if (++i >= args.Length || !long.TryParse(args[i], out long roomIdVal) || roomIdVal <= 0)
                        {
                            error = "--room-id requires > 0";
                            return cfg;
                        }
                        cfg.RoomId = roomIdVal;
                        break;
                    case "--map":
                        if (++i >= args.Length) { error = "--map requires value"; return cfg; }
                        cfg.Map = args[i];
                        break;
                    case "--mode":
                        if (++i >= args.Length) { error = "--mode requires value"; return cfg; }
                        cfg.Mode = args[i];
                        break;
                    case "--race-type":
                        if (++i >= args.Length || !int.TryParse(args[i], out int rt)) { error = "--race-type requires int"; return cfg; }
                        cfg.RaceType = rt;
                        break;
                    case "--bots":
                        if (++i >= args.Length || !int.TryParse(args[i], out int bots) || bots < 0) { error = "--bots requires >= 0"; return cfg; }
                        cfg.BotCount = bots;
                        cfg.AllyBots = 0;
                        cfg.EnemyBots = 0;
                        break;
                    case "--ally-bots":
                        if (++i >= args.Length || !int.TryParse(args[i], out int ab) || ab < 0) { error = "--ally-bots requires >= 0"; return cfg; }
                        cfg.AllyBots = ab;
                        break;
                    case "--enemy-bots":
                        if (++i >= args.Length || !int.TryParse(args[i], out int eb) || eb < 0) { error = "--enemy-bots requires >= 0"; return cfg; }
                        cfg.EnemyBots = eb;
                        break;
                    case "--team":
                        if (++i >= args.Length || !int.TryParse(args[i], out int tm)) { error = "--team requires 1 or 2"; return cfg; }
                        cfg.PlayerTeam = tm == 2 ? 2 : 1;
                        break;
                    case "--tcp-port":
                        if (++i >= args.Length || !int.TryParse(args[i], out int tp)) { error = "--tcp-port requires int"; return cfg; }
                        cfg.TcpPort = tp;
                        break;
                    case "--udp-port":
                        if (++i >= args.Length || !int.TryParse(args[i], out int up)) { error = "--udp-port requires int"; return cfg; }
                        cfg.UdpPort = up;
                        break;
                    case "--seed":
                        if (++i >= args.Length || !int.TryParse(args[i], out int seed)) { error = "--seed requires int"; return cfg; }
                        cfg.Seed = seed;
                        break;
                    case "--godmode":
                        cfg.GodMode = true;
                        break;
                    case "--headless":
                        cfg.Headless = true;
                        break;
                    case "--duration":
                        if (++i >= args.Length || !double.TryParse(args[i], out double dur)) { error = "--duration requires number"; return cfg; }
                        cfg.DurationSeconds = dur;
                        break;
                    case "--trace-probe":
                        cfg.TraceProbe = true;
                        break;
                    case "--print-la":
                        cfg.PrintLa = true;
                        break;
                }
            }

            if (cfg.PrintLa && (cfg.TcpPort is < 1 or > 65535 || cfg.UdpPort is < 1 or > 65535))
            {
                error = "--print-la requires TCP and UDP ports in 1..65535";
                return cfg;
            }

            if (cfg.PrintLa && battleHost != null)
            {
                try
                {
                    IPAddress[] candidates = IPAddress.TryParse(battleHost, out var literal)
                        ? new[] { literal }
                        : Dns.GetHostAddresses(battleHost, AddressFamily.InterNetwork);
                    var address = candidates.FirstOrDefault(ip => !ip.Equals(IPAddress.Any) && !ip.Equals(IPAddress.Broadcast));
                    if (address == null)
                    {
                        error = $"--battle-host has no usable IPv4 address: {battleHost}";
                        return cfg;
                    }
                    cfg.BattleServerIp = address.ToString();
                }
                catch (SocketException ex)
                {
                    error = $"Could not resolve --battle-host {battleHost}: {ex.Message}";
                    return cfg;
                }
            }

            if (!Directory.Exists(cfg.ProjectRoot) && Directory.Exists(Directory.GetCurrentDirectory()))
            {
                cfg.ProjectRoot = Directory.GetCurrentDirectory();
            }

            cfg.EnsureDefaults();
            return cfg;
        }

        public string BuildBootConfigBase62()
        {
            int resourcePort = 8080;
            if (int.TryParse(Environment.GetEnvironmentVariable("SSJJ_RESOURCE_PORT"), out int configuredPort) &&
                configuredPort is > 0 and <= 65535)
                resourcePort = configuredPort;
            string resourceOrigin = $"http://127.0.0.1:{resourcePort}";
            var data = new BootConfigData
            {
                ResourceBase = resourcePort == 8080 ? ResourceBase : resourceOrigin + "/s3/",
                BattleServerIp = BattleServerIp,
                BattleServerTcpPort = TcpPort,
                BattleServerUdpPort = UdpPort,
                RoomId = RoomId > 0 ? RoomId : 1001,
                UserId = CharId,
                CharId = CharId,
                Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString(),
                Sign = "offline_local_sign",
                ServerId = 1,
                ExternalUrl = resourceOrigin + "/",
                Platform = "4399",
                GameStartCount = 1,
                IsDirectProxy = false,
                ClientDebug = true,
                StatUrl = resourceOrigin + "/stat",
                LoginId = 1,
                GenerateId = 1,
                IsGlobalServer = false,
                SceneTcpProxy = "",
                IsPluginReportEnable = false,
                SignFileName = "",
                WindowMode = "window",
                GameEngine = "unity",
                IsNewPlayer = "false",
                SpeechControlClose = true,
                HallModeRuleId = 1,
                SelfKillNormal = "defaultkill",
                SelfKillHeadshot = "headshot",
                SelfKillKnife = "defaultkill",
                SelfKillSpecial = "defaultkill",
                GameStartJsonAttribute = "{}"
            };
            var ser = new ProtobufSerializer();
            using var ms = new MemoryStream();
            ser.Serialize(ms, data);
            return Base62Encode(ms.ToArray());
        }

        private static string Base62Encode(byte[] inBytes)
        {
            const string Codes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var sb = new StringBuilder(inBytes.Length * 2);
            void AppendBits(int val)
            {
                if (val < 61) sb.Append(Codes[val]);
                else { sb.Append('9'); sb.Append(Codes[val - 61]); }
            }
            for (int i = 0; i < inBytes.Length; i += 3)
            {
                AppendBits((inBytes[i] & 0xFC) >> 2);
                int b = (inBytes[i] & 3) << 4;
                if (i + 1 < inBytes.Length)
                {
                    b |= (inBytes[i + 1] & 0xF0) >> 4;
                    AppendBits(b);
                    b = (inBytes[i + 1] & 0xF) << 2;
                    if (i + 2 < inBytes.Length)
                    {
                        b |= (inBytes[i + 2] & 0xC0) >> 6;
                        AppendBits(b);
                        AppendBits(inBytes[i + 2] & 0x3F);
                    }
                    else AppendBits(b);
                }
                else AppendBits(b);
            }
            return sb.ToString();
        }
    }
}
