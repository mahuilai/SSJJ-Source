using NetData;
using SSJJ.Server.Config;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.GameModes;

public sealed class BioSupplyCrate
{
    public int Id { get; init; }
    public float X { get; init; }
    public float Y { get; init; }
    public float Z { get; init; }
    public string BufName { get; init; } = "shuxing_lan";
}

public sealed class BiohazardRound(BiohazardSettings settings, int seed)
{
    // BiochemicalStartGameModel.GetAfterTime for RaceType 6.
    public const int IncubationMs = 15_000;
    public const int HumanTeam = 2;
    public const int InfectedTeam = 1;
    public const string Mother = "doun_master";
    public const string Infected = "doun";
    public const string HeroCareer = "hero";
    public const string HeroWeapon = "hero_weapon_base";
    public const int HeroHp = 1000;
    public const int RegenIdleDelayMs = 4000;
    public const float SupplySpawnIntervalSec = 18.0f;
    public const float SupplyPickupRadiusCm = 125f;

    private readonly Random _random = new(seed);
    private readonly HashSet<PlayerBasicInfo> _permanentlyDead = [];
    private readonly Dictionary<int, int> _lastHurtMs = new();
    private readonly Dictionary<int, int> _infectedEvolutionPoints = new();
    private readonly Dictionary<int, int> _infectedLevel = new();
    private readonly Dictionary<int, float> _regenAccumulator = new();
    private readonly List<BioSupplyCrate> _supplyCrates = new();
    private int _nextSupplyId = 58000;
    private float _supplySpawnTimer;
    private bool _heroActivated;

    private int? _startedAt;
    private int? _endedAt;
    private int _motherId;

    public bool IsActive => _motherId != 0 && _endedAt == null;
    public int GrowthLevel { get; private set; }
    public IReadOnlyList<BioSupplyCrate> SupplyCrates => _supplyCrates;
    public bool HeroActivated => _heroActivated;
    public static bool IsInfected(PlayerBasicInfo p) => p.Career is Mother or Infected;
    public static bool IsHero(PlayerBasicInfo p) => string.Equals(p.Career, HeroCareer, StringComparison.OrdinalIgnoreCase);
    public static bool IsInfectionWeapon(string weapon) => weapon is Mother or Infected;
    public bool HasStarted => _startedAt.HasValue;
    public bool IntermissionComplete(int now) => _endedAt is int ended && now - ended >= settings.IntermissionMs;

    public float GetHumanDamageMultiplier() => 1.0f + GrowthLevel * 0.20f;
    public int GetInfectedLevel(int playerId) => _infectedLevel.GetValueOrDefault(playerId, 1);

    public void RemovePlayer(PlayerBasicInfo player)
    {
        _permanentlyDead.Remove(player);
        _lastHurtMs.Remove(player.Id);
        _infectedEvolutionPoints.Remove(player.Id);
        _infectedLevel.Remove(player.Id);
        _regenAccumulator.Remove(player.Id);
    }

    public int RemainingMs(int now) =>
        _startedAt is int started ? Math.Max(0, settings.RoundMs - Math.Max(0, now - started)) : settings.RoundMs;

    public void Begin(int now)
    {
        _startedAt = now;
        _endedAt = null;
        _motherId = 0;
        GrowthLevel = 0;
        _heroActivated = false;
        _supplySpawnTimer = 10.0f;
        _permanentlyDead.Clear();
        _lastHurtMs.Clear();
        _infectedEvolutionPoints.Clear();
        _infectedLevel.Clear();
        _regenAccumulator.Clear();
        _supplyCrates.Clear();
    }

    public PlayerBasicInfo? SelectMother(int now, IReadOnlyList<PlayerBasicInfo> players)
    {
        if (_startedAt is not int started || _endedAt.HasValue || _motherId != 0 || now - started < IncubationMs || RemainingMs(now) == 0)
            return null;

        var humans = players.Where(p => !p.IsDead && !IsInfected(p)).OrderBy(p => p.Id).ToArray();
        if (humans.Length < 2) return null;

        var mother = humans[_random.Next(humans.Length)];
        _motherId = mother.Id;
        Convert(mother, isMother: true);
        _infectedLevel[mother.Id] = 1;
        return mother;
    }

    public bool TryInfect(PlayerBasicInfo victim, PlayerBasicInfo? attacker, string weapon, out (int Lv, int AddHp)? levelUp)
    {
        levelUp = null;
        if (!IsActive || attacker == null || attacker.IsDead || victim.IsDead
            || !IsInfected(attacker) || IsInfected(victim) || !IsInfectionWeapon(weapon)
            || attacker.CurrentWeapon != 3 || attacker.CurrentWeaponName != weapon)
            return false;

        Convert(victim, isMother: false);
        _infectedLevel[victim.Id] = 1;
        levelUp = AddInfectionEvolution(attacker, 2);
        return true;
    }

    public bool TryInfect(PlayerBasicInfo victim, PlayerBasicInfo? attacker, string weapon) =>
        TryInfect(victim, attacker, weapon, out _);

    public (int Lv, int AddHp)? AddInfectionEvolution(PlayerBasicInfo infected, int points)
    {
        if (!IsInfected(infected) || points <= 0) return null;
        int curLv = GetInfectedLevel(infected.Id);
        if (curLv >= 3) return null;

        int nextPts = _infectedEvolutionPoints.GetValueOrDefault(infected.Id) + points;
        _infectedEvolutionPoints[infected.Id] = nextPts;
        int targetLv = nextPts >= 5 ? 3 : (nextPts >= 2 ? 2 : 1);
        if (targetLv <= curLv) return null;

        _infectedLevel[infected.Id] = targetLv;
        int addHp = targetLv == 2 ? 400 : 600;
        infected.MaxHp += addHp;
        infected.Hp = Math.Min(infected.MaxHp, infected.Hp + addHp);
        infected.LifeBarSeq++;
        return (targetLv, addHp);
    }

    public void RecordHurt(int victimId, int nowMs)
    {
        _lastHurtMs[victimId] = nowMs;
        _regenAccumulator[victimId] = 0f;
    }

    public void TickRegen(float dt, int nowMs, IReadOnlyList<PlayerBasicInfo> players)
    {
        if (!IsActive || dt <= 0f) return;
        for (int i = 0; i < players.Count; i++)
        {
            var p = players[i];
            if (p.IsDead || !IsInfected(p) || p.Hp >= p.MaxHp) continue;
            int lastHurt = _lastHurtMs.GetValueOrDefault(p.Id, _startedAt ?? nowMs);
            if (nowMs - lastHurt < RegenIdleDelayMs) continue;

            float rate = string.Equals(p.Career, Mother, StringComparison.OrdinalIgnoreCase) ? 60f : 40f;
            float acc = _regenAccumulator.GetValueOrDefault(p.Id) + dt * rate;
            int gain = (int)acc;
            _regenAccumulator[p.Id] = acc - gain;
            if (gain > 0)
            {
                p.Hp = Math.Min(p.MaxHp, p.Hp + gain);
            }
        }
    }

    public List<PlayerBasicInfo> TryPromoteHeroes(IReadOnlyList<PlayerBasicInfo> players)
    {
        var promoted = new List<PlayerBasicInfo>();
        if (!IsActive || _heroActivated) return promoted;

        var aliveHumans = players.Where(p => !p.IsDead && !IsInfected(p) && !IsHero(p)).OrderBy(p => p.Id).ToArray();
        int totalParticipants = players.Count(p => !p.IsDead || IsInfected(p));
        int heroThreshold = totalParticipants >= 6 ? 2 : (totalParticipants >= 3 ? 1 : 0);
        if (heroThreshold == 0 || aliveHumans.Length == 0 || aliveHumans.Length > heroThreshold) return promoted;

        _heroActivated = true;
        foreach (var h in aliveHumans)
        {
            PromoteToHero(h);
            promoted.Add(h);
        }
        return promoted;
    }

    public void PromoteToHero(PlayerBasicInfo human)
    {
        human.Career = HeroCareer;
        human.CareerSkin = "";
        human.HandName = "man";
        human.MaxHp = HeroHp;
        human.Hp = HeroHp;
        human.Zhuangjia = 200;
        human.Hudun = 0;
        human.CanChangeBag = false;
        human.LifeBarSeq++;
    }

    public BioSupplyCrate? TickSupplySpawns(float dt, IReadOnlyList<BspSpawnPoint> spawns)
    {
        if (!IsActive || _supplyCrates.Count >= 3 || spawns.Count == 0) return null;
        _supplySpawnTimer -= dt;
        if (_supplySpawnTimer > 0f) return null;

        _supplySpawnTimer = SupplySpawnIntervalSec;
        var sp = spawns[_random.Next(spawns.Count)];
        var crate = new BioSupplyCrate
        {
            Id = _nextSupplyId++,
            X = sp.X,
            Y = sp.Y,
            Z = sp.Z,
            BufName = "shuxing_lan"
        };
        _supplyCrates.Add(crate);
        return crate;
    }

    public BioSupplyCrate? TryPickUpSupply(PlayerBasicInfo player, GameTables tables)
    {
        if (!IsActive || player.IsDead || IsInfected(player) || _supplyCrates.Count == 0) return null;
        for (int i = _supplyCrates.Count - 1; i >= 0; i--)
        {
            var c = _supplyCrates[i];
            float dx = player.PosX - c.X;
            float dy = player.PosY - c.Y;
            if (dx * dx + dy * dy <= SupplyPickupRadiusCm * SupplyPickupRadiusCm && Math.Abs(player.PosZ - c.Z) <= 100f)
            {
                _supplyCrates.RemoveAt(i);
                var def = tables.GetWeapon(player.CurrentWeaponName);
                if (!def.IsMelee && def.MaxClip > 0)
                {
                    player.CurrentClip = def.MaxClip;
                    player.CurrentCarryClip = Math.Max(player.CurrentCarryClip, def.MaxCarryClip * 2);
                }
                player.Hp = Math.Min(player.MaxHp, player.Hp + 50);
                return c;
            }
        }
        return null;
    }

    public BioMessageType? RecordKill(PlayerBasicInfo? attacker, PlayerBasicInfo victim, bool melee)
    {
        if (!IsActive || !IsInfected(victim) || attacker == null || IsInfected(attacker))
            return null;

        GrowthLevel = Math.Min(GrowthLevel + 1, 10);
        bool permanent = melee || IsHero(attacker);
        if (!permanent) return BioMessageType.KILLBIO;
        _permanentlyDead.Add(victim);
        return IsHero(attacker) ? BioMessageType.HEROKILL : BioMessageType.KNIFEKILL;
    }

    public int? RespawnRemainingMs(PlayerBasicInfo p, int elapsedMs) =>
        IsInfected(p) && IsActive && !_permanentlyDead.Contains(p)
            ? Math.Max(0, settings.RespawnMs - elapsedMs)
            : null;

    public bool CanRespawn(PlayerBasicInfo p, int now) =>
        IsActive && p.IsDead && IsInfected(p) && !_permanentlyDead.Contains(p)
        && now - (int)p.TorsoAnimStartTime >= settings.RespawnMs;

    public int? TryFinish(int now, IReadOnlyList<PlayerBasicInfo> players)
    {
        if (_startedAt == null || _endedAt.HasValue) return null;

        bool anyHumans = players.Any(p => !IsInfected(p) && !p.IsDead);
        bool anyInfected = players.Any(p => IsInfected(p) && (!p.IsDead || !_permanentlyDead.Contains(p)));
        int? winner = null;
        if (IsActive && !anyHumans) winner = InfectedTeam;
        else if ((IsActive && !anyInfected) || (RemainingMs(now) == 0 && anyHumans)) winner = HumanTeam;
        if (winner.HasValue) _endedAt = now;
        return winner;
    }

    // BioDamageHandler subtracts the previous remainder, then subtracts ten
    // from the received value after a completed score bar. Never use its hero branch.
    public static int EncodeDamageScore(ref int remainder, int points)
    {
        if (points < 1 || points > 10) throw new ArgumentOutOfRangeException(nameof(points));
        int wire = remainder + points;
        remainder = wire % 10;
        return wire;
    }

    private void Convert(PlayerBasicInfo p, bool isMother)
    {
        p.Career = isMother ? Mother : Infected;
        p.CareerSkin = "";
        p.HandName = "man";
        p.Team = InfectedTeam;
        p.Hp = p.MaxHp = isMother ? settings.MotherHp : settings.InfectedHp;
        p.Zhuangjia = 0;
        p.Hudun = 0;
        p.LifeBarSeq++;
        p.CanChangeBag = false;
    }
}
