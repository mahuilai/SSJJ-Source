using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Xml.Linq;
using SSJJ.Server.QuakeServer;

namespace SSJJ.Server.Config
{
    public sealed class WeaponDef
    {
        public string Name { get; init; } = "";
        public int WeaponType { get; init; } // 0=pistol, 1=rifle, 2=melee, 3=throwable, 5=sniper, 6=shotgun, 10=mg
        public bool IsMelee { get; init; }
        public string InfoType { get; init; } = "";
        public bool IsThrowable => WeaponType == 3 || Name.Contains("grenade", StringComparison.OrdinalIgnoreCase) || Name.Contains("bomb", StringComparison.OrdinalIgnoreCase) || Name.Equals("c4", StringComparison.OrdinalIgnoreCase);
        public string AttackType { get; init; } = "Default";
        public string SpecialAttackType { get; init; } = "";
        public bool HasDoubleAttack { get; init; }
        public bool HasMeleeSecondary => IsMelee || AttackType.StartsWith("RifleMelee", StringComparison.Ordinal) || InfoType.Contains("Melee", StringComparison.OrdinalIgnoreCase);
        public string AnimationWeaponName { get; init; } = "";
        public int AttackIntervalMs { get; init; } = 120;
        public int MaxClip { get; init; } = 30;
        public int MaxCarryClip { get; init; } = 120;
        public string MaxSpeedType { get; init; } = "Default";
        public int MaxSpeed { get; set; } = 609;
        public int MaxSpeedZoom { get; set; } = 0;
        public int? ScopedMaxSpeed => MaxSpeedZoom > 0 ? MaxSpeedZoom : null;
        public int GetMoveSpeed(int fov) => fov != 90 && MaxSpeedZoom > 0 ? MaxSpeedZoom : MaxSpeed;
        public int FireBullets { get; init; } = 1;
        public int ClipPerShot { get; init; } = 1;
        public float ShotDistance { get; init; } = 20000f;
        public float DefaultAccuracy { get; init; } = 0.2f;
        internal WeaponBallistics? Ballistics { get; init; }
        public int SlashSlashMs { get; init; } = 400;
        public int SlashStabMs { get; init; } = 500;
        public int StabStabMs { get; init; } = 850;
        public int StabSlashMs { get; init; } = 850;
        public int DelaySlashMs { get; init; } = 180;
        public int DelayStabMs { get; init; } = 250;
        public string ThirdAnimationType { get; init; } = "";
        public bool IsGold { get; init; }

        public float BaseDamage => WeaponType switch
        {
            0 => 32f,
            2 => 55f,
            5 => 115f,
            6 => 22f, // per pellet (x8 pellets)
            10 => 35f,
            _ => Name.Contains("awm", StringComparison.OrdinalIgnoreCase) || Name.Contains("barrett", StringComparison.OrdinalIgnoreCase) ? 115f
               : Name.Contains("ak", StringComparison.OrdinalIgnoreCase) ? 38f
               : 34f
        };

        public float ArmorPenetration => WeaponType switch
        {
            2 => 1.0f,
            5 => Name.Contains("barrett", StringComparison.OrdinalIgnoreCase) ? 0.95f : 0.85f,
            10 => 0.78f,
            1 => AttackType.Contains("Submachine", StringComparison.OrdinalIgnoreCase) ? 0.52f : 0.72f,
            0 => Name.Contains("deagle", StringComparison.OrdinalIgnoreCase) ? 0.70f : 0.55f,
            6 => 0.42f,
            _ => 0.65f
        };

        public float WallPenetrationPower => WeaponType switch
        {
            5 => Name.Contains("barrett", StringComparison.OrdinalIgnoreCase) ? 0.85f : 0.75f,
            10 => 0.68f,
            1 => AttackType.Contains("Submachine", StringComparison.OrdinalIgnoreCase) ? 0.42f : 0.62f,
            0 => Name.Contains("deagle", StringComparison.OrdinalIgnoreCase) ? 0.58f : 0.40f,
            6 => 0.28f,
            _ => 0.50f
        };

        public float MaxWallThicknessCm => WeaponType switch
        {
            5 => Name.Contains("barrett", StringComparison.OrdinalIgnoreCase) ? 150f : 110f,
            10 => 80f,
            1 => AttackType.Contains("Submachine", StringComparison.OrdinalIgnoreCase) ? 32f : 65f,
            0 => Name.Contains("deagle", StringComparison.OrdinalIgnoreCase) ? 55f : 28f,
            6 => 18f,
            _ => 0f
        };

        public float RangeFalloffPerMeter => WeaponType switch
        {
            5 => 0.9985f,
            10 => 0.9955f,
            1 => AttackType.Contains("Submachine", StringComparison.OrdinalIgnoreCase) ? 0.986f : 0.9945f,
            0 => 0.988f,
            6 => 0.960f,
            _ => 0.994f
        };
    }

    public sealed class WeaponSkillDef
    {
        public int Id { get; init; }
        public string Name { get; init; } = "";
        public string SpecialType { get; init; } = "";
        public string Mode { get; init; } = "";
        public string SkillType { get; init; } = "";
        public float Total { get; init; } = 1f;
        public int MaxLevel { get; init; } = 1;
        public int SpecialTimeMs { get; init; } = 6000;
        public string CanUse { get; init; } = "";
        public float CanUseValue { get; init; } = 1f;
        public string CdType { get; init; } = "Normal";
        public string ProgressType { get; init; } = "";
        public string EffectType { get; init; } = "";
    }

    public sealed class WeaponSkinDef
    {
        public string Name { get; init; } = "";
        public string WeaponsRaw { get; init; } = "";
        public bool HasEffect { get; init; }
        public bool HasKnifeEffect { get; init; }
    }

    public sealed class GameTables
    {
        private readonly Dictionary<string, WeaponDef> _weapons = new Dictionary<string, WeaponDef>(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, WeaponSkillDef> _skills = new Dictionary<string, WeaponSkillDef>(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, WeaponSkinDef> _skins = new Dictionary<string, WeaponSkinDef>(StringComparer.OrdinalIgnoreCase);
        private Dictionary<string, Dictionary<string, int>> _viewAnimations = new();
        private Dictionary<string, Dictionary<string, Dictionary<string, int>>> _torsoAnimations = new();
        private Dictionary<string, string> _careerAnimationModels = new();

        public int WeaponCount => _weapons.Count;
        public int SkillCount => _skills.Count;
        public int SkinCount => _skins.Count;

        public void Load(string projectRoot)
        {
            string dataDir = Path.Combine(projectRoot, "SSJJ-Server", "Data");
            _viewAnimations = LoadAnimationDurations<Dictionary<string, Dictionary<string, int>>>(dataDir, "weapon_anim_durations.json");
            _torsoAnimations = LoadAnimationDurations<Dictionary<string, Dictionary<string, Dictionary<string, int>>>>(dataDir, "torso_anim_durations.json");
            _careerAnimationModels = LoadAnimationDurations<Dictionary<string, string>>(dataDir, "career_anim_models.json");
            string tablesDir = Path.Combine(projectRoot, "Game source", "06_singleplayer", "tables_json");
            if (!Directory.Exists(tablesDir))
            {
                Console.WriteLine($"[SSJJ-Server][TABLES] tables_json dir missing: {tablesDir}");
                return;
            }
            LoadWeapons(Path.Combine(tablesDir, "Weapon.json"));
            LoadPredicableConfig(Path.Combine(tablesDir, "predicableConfig.xml"));
            LoadSkills(Path.Combine(tablesDir, "WeaponSkill.json"));
            LoadSkins(Path.Combine(tablesDir, "WeaponSkinInfo.json"));
            Console.WriteLine($"[SSJJ-Server][TABLES] Loaded {_weapons.Count} weapons, {_skills.Count} skills, {_skins.Count} skins from {tablesDir}");
        }

        private static T LoadAnimationDurations<T>(string dataDir, string filename) where T : class, new()
        {
            string path = Path.Combine(dataDir, filename);
            if (!File.Exists(path)) path = Path.Combine(AppContext.BaseDirectory, "Data", filename);
            return File.Exists(path) ? JsonSerializer.Deserialize<T>(File.ReadAllText(path)) ?? new T() : new T();
        }

        public int GetViewAnimationDuration(string weapon, string action) =>
            _viewAnimations.TryGetValue(weapon, out var actions) ? actions.GetValueOrDefault(action) : 0;

        public int GetTorsoAnimationDuration(string career, WeaponDef weapon, string action)
        {
            if (!_careerAnimationModels.TryGetValue(career, out string? model) || !_torsoAnimations.TryGetValue(model, out var weapons)) return 0;
            if (weapons.TryGetValue("", out var common) && common.TryGetValue(action, out int duration)) return duration;
            string name = string.IsNullOrEmpty(weapon.AnimationWeaponName) ? weapon.Name : weapon.AnimationWeaponName;
            if (name == "pvegatling") name = "botweapon";
            return weapons.TryGetValue(name, out var actions) ? actions.GetValueOrDefault(action) : 0;
        }

        private void LoadWeapons(string path)
        {
            if (!File.Exists(path)) return;
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("rows", out var rows) || rows.ValueKind != JsonValueKind.Array) return;
            string sharedConfigPath = Path.Combine(Path.GetDirectoryName(path)!, "predicableConfig.xml");
            var sharedWeapons = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (File.Exists(sharedConfigPath))
            {
                foreach (var key in XDocument.Load(sharedConfigPath).Descendants("weaponKey"))
                    sharedWeapons.Add(key.Value.Trim());
            }
            foreach (var row in rows.EnumerateArray())
            {
                string name = Str(row, "Name");
                if (string.IsNullOrEmpty(name)) continue;
                int wt = Int(row, "WeaponType", 1);
                bool isMelee = wt == 2 || Bool(row, "IsMelee");
                string attackType = Str(row, "AttackType", "Default");
                string maxSpeedType = Str(row, "MaxSpeedType", "Default");
                string maxSpeedParam = Str(row, "MaxSpeedParam", "");
                (int maxSpeed, int maxSpeedZoom) = ParseWeaponMaxSpeed(wt, maxSpeedType, maxSpeedParam);
                _weapons[name] = new WeaponDef
                {
                    Name = name,
                    WeaponType = wt,
                    IsMelee = isMelee,
                    InfoType = Str(row, "InfoType", ""),
                    AttackType = attackType,
                    SpecialAttackType = Str(row, "SpecialAttackType", ""),
                    HasDoubleAttack = Bool(row, "HasDoubleAttack"),
                    AnimationWeaponName = Str(row, "AnimationWeaponName", ""),
                    AttackIntervalMs = Math.Max(40, Int(row, "AttackInterval", 120)),
                    MaxClip = Math.Max(0, Int(row, "MaxClip", isMelee ? 0 : 30)),
                    MaxCarryClip = Math.Max(0, Int(row, "MaxCarryClip", isMelee ? 0 : 120)),
                    MaxSpeedType = maxSpeedType,
                    MaxSpeed = maxSpeed,
                    MaxSpeedZoom = maxSpeedZoom,
                    FireBullets = Math.Max(1, Int(row, "FireBullets", 1)),
                    ClipPerShot = Math.Max(0, Int(row, "ClipPerShot", isMelee ? 0 : 1)),
                    ShotDistance = Math.Max(120f, Float(row, "ShotDistParam", isMelee ? 280f : 20000f)),
                    DefaultAccuracy = Float(row, "DefaultAccuracy", 0.2f),
                    Ballistics = sharedWeapons.Contains(name) ? null : WeaponBallistics.FromTable(
                        attackType, Str(row, "AccuracyType"), Str(row, "AccuracyParam"),
                        Float(row, "AccuracyDivisor", -1f), Float(row, "AccuracyOffset", 0f), Float(row, "MaxInaccuracy", 0f),
                        Str(row, "SpreadType"), Str(row, "SpreadParam"), Float(row, "SpreadScaleY", 1f),
                        Str(row, "KickbackType"), Str(row, "KickbackParam")),
                    SlashSlashMs = Math.Max(150, Int(row, "SlashSlashTime", 400)),
                    SlashStabMs = Int(row, "SlashStabTime", 500),
                    StabStabMs = Math.Max(300, Int(row, "StabStabTime", 850)),
                    StabSlashMs = Int(row, "StabSlashTime", 850),
                    DelaySlashMs = Math.Max(50, Int(row, "DelayAttackSlashTime", 180)),
                    DelayStabMs = Math.Max(50, Int(row, "DelayAttackStabTime", 250)),
                    ThirdAnimationType = Str(row, "ThirdAnimationType", ""),
                    IsGold = Bool(row, "IsGold")
                };
            }
        }

        private void LoadPredicableConfig(string path)
        {
            if (!File.Exists(path)) return;
            try
            {
                var doc = XDocument.Load(path);
                if (doc.Root == null) return;
                foreach (var el in doc.Root.Elements("weapon"))
                {
                    string key = el.Element("weaponKey")?.Value?.Trim() ?? "";
                    if (string.IsNullOrEmpty(key) || !_weapons.TryGetValue(key, out var def)) continue;
                    string msType = el.Element("maxSpeedType")?.Value?.Trim() ?? "";
                    string msArgs = el.Element("maxSpeedArgs")?.Value?.Trim() ?? "";
                    if (!string.IsNullOrEmpty(msArgs))
                    {
                        var parts = ParseIntList(msArgs);
                        if (msType.Equals("Fixed", StringComparison.OrdinalIgnoreCase) && parts.Count >= 1)
                        {
                            def.MaxSpeed = parts[0];
                        }
                        else if (parts.Count >= 2)
                        {
                            def.MaxSpeedZoom = parts[0];
                            def.MaxSpeed = parts[1];
                        }
                        else if (parts.Count == 1)
                        {
                            def.MaxSpeed = parts[0];
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SSJJ-Server][TABLES] predicableConfig.xml warn: {ex.Message}");
            }
        }

        /// <summary>
        /// 1:1 对齐客户端 WeaponInfoCache + Assets.Sources.Info.Weapon.Logic.MaxSpeedLogic.* 的移速解析
        /// </summary>
        private static (int normalSpeed, int zoomSpeed) ParseWeaponMaxSpeed(int weaponType, string maxSpeedType, string maxSpeedParam)
        {
            // DefaultMaxSpeedLogic: 0=pistol(635), 2/3=melee/throwable(615), others(609)
            int defaultSpeed = weaponType == 0 ? 635 : (weaponType == 2 || weaponType == 3 ? 615 : 609);
            if (string.IsNullOrWhiteSpace(maxSpeedType) || maxSpeedType.Equals("Default", StringComparison.OrdinalIgnoreCase))
            {
                return (defaultSpeed, 0);
            }

            var parts = ParseIntList(maxSpeedParam);
            if (parts.Count == 0)
            {
                return (defaultSpeed, 0);
            }

            return maxSpeedType switch
            {
                // 单参数: Speed = parts[0]
                "Rifle" or "DaggerBulletBurster" or "PhaseWalker" => (parts[0], 0),
                // 双参数: parts[0] = FovSpeed/SpecialSpeed, parts[1] = normal Speed
                "Sniper" or "Ready" or "Special" or "Qbz951st" when parts.Count >= 2 => (parts[1], parts[0]),
                // 三/四参数: GhostTwins(fov,normal,special), G36cTactic(fov,normal,specFov,specNormal)
                "GhostTwins" or "G36cTactic" when parts.Count >= 2 => (parts[1], parts[0]),
                // TwinsInfinite(special, specialTwo, normal)
                "TwinsInfinite" when parts.Count >= 3 => (parts[2], parts[0]),
                _ => parts.Count >= 2 ? (parts[1], parts[0]) : (parts[0], 0)
            };
        }

        private static List<int> ParseIntList(string raw)
        {
            var list = new List<int>();
            if (string.IsNullOrWhiteSpace(raw)) return list;
            foreach (var tok in raw.Split(','))
            {
                if (int.TryParse(tok.Trim(), out int v) && v > 0)
                {
                    list.Add(v);
                }
            }
            return list;
        }

        private void LoadSkills(string path)
        {
            if (!File.Exists(path)) return;
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("rows", out var rows) || rows.ValueKind != JsonValueKind.Array) return;
            foreach (var row in rows.EnumerateArray())
            {
                string name = Str(row, "Name");
                if (string.IsNullOrEmpty(name) || string.Equals(name, "string", StringComparison.OrdinalIgnoreCase) || _skills.ContainsKey(name)) continue;
                _skills[name] = new WeaponSkillDef
                {
                    Id = Int(row, "Id", 0),
                    Name = name,
                    SpecialType = Str(row, "SpecialType", ""),
                    Mode = Str(row, "Mode", ""),
                    SkillType = Str(row, "Type", ""),
                    Total = Float(row, "Total", 1f),
                    MaxLevel = Math.Max(1, Int(row, "MaxLevel", 1)),
                    SpecialTimeMs = Math.Max(500, Int(row, "SpecialTime", 6000)),
                    CanUse = Str(row, "CanUse", ""),
                    CanUseValue = Float(row, "CanUseValue", 1f),
                    CdType = Str(row, "Cd", "Normal"),
                    ProgressType = Str(row, "Progress", ""),
                    EffectType = Str(row, "Effect", "")
                };
            }
        }

        private void LoadSkins(string path)
        {
            if (!File.Exists(path)) return;
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("rows", out var rows) || rows.ValueKind != JsonValueKind.Array) return;
            foreach (var row in rows.EnumerateArray())
            {
                string name = Str(row, "Name");
                if (string.IsNullOrEmpty(name) || name == "string" || _skins.ContainsKey(name)) continue;
                _skins[name] = new WeaponSkinDef
                {
                    Name = name,
                    WeaponsRaw = Str(row, "Weapon", ""),
                    HasEffect = Bool(row, "HasEffect"),
                    HasKnifeEffect = Bool(row, "HasKnifeEffect")
                };
            }
        }

        public WeaponSkinDef? GetSkin(string? name) =>
            !string.IsNullOrEmpty(name) && _skins.TryGetValue(name, out var s) ? s : null;

        public WeaponDef GetWeapon(string? name)
        {
            if (!string.IsNullOrEmpty(name) && _weapons.TryGetValue(name, out var def)) return def;
            return new WeaponDef { Name = name ?? "m4a1" };
        }

        public bool TryGetSkill(string? name, out WeaponSkillDef? skill)
        {
            skill = null;
            return !string.IsNullOrEmpty(name) && _skills.TryGetValue(name, out skill);
        }

        private static string Str(JsonElement row, string key, string fb = "") =>
            row.TryGetProperty(key, out var p) && p.ValueKind == JsonValueKind.String ? (p.GetString() ?? fb) : fb;

        private static int Int(JsonElement row, string key, int fb)
        {
            string s = Str(row, key);
            return int.TryParse(s, out int v) ? v : fb;
        }

        private static float Float(JsonElement row, string key, float fb)
        {
            string s = Str(row, key);
            return float.TryParse(s, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out float v) ? v : fb;
        }

        private static bool Bool(JsonElement row, string key) =>
            Str(row, key).Equals("true", StringComparison.OrdinalIgnoreCase);
    }
}
