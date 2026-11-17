using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

namespace SSJJ.Server.Config
{
    public sealed class WeaponDef
    {
        public string Name { get; init; } = "";
        public int WeaponType { get; init; } // 0=pistol, 1=rifle, 2=melee, 3=throwable, 5=sniper, 6=shotgun, 10=mg
        public bool IsMelee { get; init; }
        public bool IsThrowable => WeaponType == 3 || Name.Contains("grenade", StringComparison.OrdinalIgnoreCase) || Name.Contains("bomb", StringComparison.OrdinalIgnoreCase) || Name.Equals("c4", StringComparison.OrdinalIgnoreCase);
        public string AttackType { get; init; } = "Default";
        public string SpecialAttackType { get; init; } = "";
        public int AttackIntervalMs { get; init; } = 120;
        public int MaxClip { get; init; } = 30;
        public int MaxCarryClip { get; init; } = 120;
        public int MaxSpeed { get; init; } = 600;
        public int FireBullets { get; init; } = 1;
        public int ClipPerShot { get; init; } = 1;
        public float ShotDistance { get; init; } = 20000f;
        public float DefaultAccuracy { get; init; } = 0.2f;
        public int SlashSlashMs { get; init; } = 400;
        public int StabStabMs { get; init; } = 850;
        public int DelaySlashMs { get; init; } = 180;
        public int DelayStabMs { get; init; } = 250;
        public string ThirdAnimationType { get; init; } = "";

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
    }

    public sealed class WeaponSkillDef
    {
        public int Id { get; init; }
        public string Name { get; init; } = "";
        public string SpecialType { get; init; } = "";
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

        public int WeaponCount => _weapons.Count;
        public int SkillCount => _skills.Count;
        public int SkinCount => _skins.Count;

        public void Load(string projectRoot)
        {
            string tablesDir = Path.Combine(projectRoot, "Game source", "06_singleplayer", "tables_json");
            if (!Directory.Exists(tablesDir))
            {
                Console.WriteLine($"[SSJJ-Server][TABLES] tables_json dir missing: {tablesDir}");
                return;
            }
            LoadWeapons(Path.Combine(tablesDir, "Weapon.json"));
            LoadSkills(Path.Combine(tablesDir, "WeaponSkill.json"));
            LoadSkins(Path.Combine(tablesDir, "WeaponSkinInfo.json"));
            Console.WriteLine($"[SSJJ-Server][TABLES] Loaded {_weapons.Count} weapons, {_skills.Count} skills, {_skins.Count} skins from {tablesDir}");
        }

        private void LoadWeapons(string path)
        {
            if (!File.Exists(path)) return;
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("rows", out var rows) || rows.ValueKind != JsonValueKind.Array) return;
            foreach (var row in rows.EnumerateArray())
            {
                string name = Str(row, "Name");
                if (string.IsNullOrEmpty(name)) continue;
                int wt = Int(row, "WeaponType", 1);
                bool isMelee = wt == 2 || Bool(row, "IsMelee");
                _weapons[name] = new WeaponDef
                {
                    Name = name,
                    WeaponType = wt,
                    IsMelee = isMelee,
                    AttackType = Str(row, "AttackType", "Default"),
                    SpecialAttackType = Str(row, "SpecialAttackType", ""),
                    AttackIntervalMs = Math.Max(40, Int(row, "AttackInterval", 120)),
                    MaxClip = Math.Max(0, Int(row, "MaxClip", isMelee ? 0 : 30)),
                    MaxCarryClip = Math.Max(0, Int(row, "MaxCarryClip", isMelee ? 0 : 120)),
                    MaxSpeed = Math.Clamp(Int(row, "MaxSpeedParam", 600), 350, 900),
                    FireBullets = Math.Max(1, Int(row, "FireBullets", 1)),
                    ClipPerShot = Math.Max(0, Int(row, "ClipPerShot", isMelee ? 0 : 1)),
                    ShotDistance = Math.Max(120f, Float(row, "ShotDistParam", isMelee ? 280f : 20000f)),
                    DefaultAccuracy = Float(row, "DefaultAccuracy", 0.2f),
                    SlashSlashMs = Math.Max(150, Int(row, "SlashSlashTime", 400)),
                    StabStabMs = Math.Max(300, Int(row, "StabStabTime", 850)),
                    DelaySlashMs = Math.Max(50, Int(row, "DelayAttackSlashTime", 180)),
                    DelayStabMs = Math.Max(50, Int(row, "DelayAttackStabTime", 250)),
                    ThirdAnimationType = Str(row, "ThirdAnimationType", "")
                };
            }
        }

        private void LoadSkills(string path)
        {
            if (!File.Exists(path)) return;
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("rows", out var rows) || rows.ValueKind != JsonValueKind.Array) return;
            foreach (var row in rows.EnumerateArray())
            {
                string name = Str(row, "Name");
                if (string.IsNullOrEmpty(name) || _skills.ContainsKey(name)) continue;
                _skills[name] = new WeaponSkillDef
                {
                    Id = Int(row, "Id", 0),
                    Name = name,
                    SpecialType = Str(row, "SpecialType", ""),
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
