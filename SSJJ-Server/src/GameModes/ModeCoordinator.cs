using System;
using System.Collections.Generic;
using NetData;
using SSJJ.Server.Bots;
using SSJJ.Server.Config;
using SSJJ.Server.Network;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;
using SSJJ.Server.Snapshot;
using SSJJUserCmd;

namespace SSJJ.Server.GameModes
{
    public enum ExplodeRoundPhase
    {
        Playing,
        RoundEndFreeze
    }

    /// <summary>
    /// 全模式玩法协调器：
    /// 统一接管 团队(2003/3)、刀战(15/2041)、爆破(2)、个人/死斗(5/12)、武器大师(64)、飞刀(74)、大头(2019)
    /// </summary>
    public sealed class ModeCoordinator
    {
        private static readonly string[] WeaponMasterLadder =
        {
            "m4a1", "ak47", "scar", "mp5", "p90", "xm1014", "awp", "deagle", "usp", "dagger"
        };

        private readonly ServerConfig _cfg;
        private readonly GameTables _tables;
        private readonly BspMapData _bsp;
        private readonly OfficialPhysicsWorld _officialPhysics;

        public int RaceType { get; }
        public BiohazardRound? Biohazard { get; }
        public bool IsExplode => RaceType == 2;
        public bool IsFreeForAll => ServerConfig.IsFreeForAll(RaceType);
        public bool IsMeleeOnly => ServerConfig.IsMeleeOnly(RaceType);
        public bool IsWeaponMaster => RaceType == 64;
        public bool IsFlyKnife => RaceType == 74;
        public bool IsBigHead => RaceType == 2019;
        public bool IsPve => ServerConfig.IsPve(RaceType);
        public bool AllowRespawn => !IsExplode && !IsPve && Biohazard == null;

        public int PveStage { get; private set; } = 1;
        public int PveStageRemaining { get; private set; } = 4;
        public int PveTaskNow { get; private set; } = 209;
        private BotDirector? _bots;
        private readonly List<PveTowerEntityData> _pveTowers = new List<PveTowerEntityData>();
        private readonly List<int> _pendingDeletedEntityIds = new List<int>();

        public int Team1Score { get; set; }
        public int Team2Score { get; set; }
        public int Team1Kills { get; set; }
        public int Team2Kills { get; set; }
        public int WinScore { get; }
        public bool MatchOver { get; private set; }
        public event Action? OnRoundEnded;

        // 爆破模式 C4 与回合状态
        public bool C4Planted { get; private set; }
        public bool C4Dropped { get; private set; }
        public float C4X { get; private set; }
        public float C4Y { get; private set; }
        public float C4Z { get; private set; }
        public float C4ElapsedSec { get; private set; }
        public const float C4DetonateSec = 40.0f;

        private ExplodeRoundPhase _explodePhase = ExplodeRoundPhase.Playing;
        private float _roundEndTimer;
        private float _roundElapsedSec;
        private float _plantProgressSec;
        private float _defuseProgressSec;
        private float _botPlantProgressSec;
        private float _botDefuseProgressSec;
        private float _c4BroadcastAcc;
        private float _c4DropCooldownSec;
        private int _c4DropperId;
        private int _plantActorId;
        private int _defuseActorId;
        private string _plantActorName = "";
        private string _defuseActorName = "";
        private int _c4PlanterId;
        private bool _plantProgressActive;
        private bool _defuseProgressActive;
        private readonly List<SceneWeaponDrop> _sceneDrops = new List<SceneWeaponDrop>();
        private readonly int _c4DropEntityId = 49999;

        // 武器大师 & 大头进度追踪
        private readonly Dictionary<int, int> _weaponTier = new Dictionary<int, int>();
        private readonly Dictionary<int, int> _bigHeadXp = new Dictionary<int, int>();

        public ModeCoordinator(ServerConfig cfg, GameTables tables, BspMapData bsp, OfficialPhysicsWorld officialPhysics)
        {
            _cfg = cfg;
            _tables = tables;
            _bsp = bsp;
            _officialPhysics = officialPhysics;
            RaceType = cfg.EffectiveRaceType;
            if (ServerConfig.IsBiohazard(RaceType))
            {
                Biohazard = new BiohazardRound(cfg.Biohazard!, cfg.Seed);
            }
            WinScore = cfg.WinScoreOverride > 0 ? cfg.WinScoreOverride : TcpBattleGateway.GetWinScore(RaceType);
        }

        public IReadOnlyList<SceneWeaponDrop> GetSceneDrops() => _sceneDrops;
        public IReadOnlyList<PveTowerEntityData> GetPveTowers() => _pveTowers;

        public List<int> DrainDeletedEntityIds()
        {
            if (_pendingDeletedEntityIds.Count == 0) return new List<int>();
            var copy = new List<int>(_pendingDeletedEntityIds);
            _pendingDeletedEntityIds.Clear();
            return copy;
        }

        public void InitializeMatch(PlayerBasicInfo localPlayer, BotDirector bots)
            => InitializeMatch(new[] { localPlayer }, bots);

        public void InitializeMatch(IReadOnlyList<PlayerBasicInfo> humanPlayers, BotDirector bots)
        {
            _bots = bots;
            for (int i = 0; i < humanPlayers.Count; i++)
            {
                var h = humanPlayers[i];
                _weaponTier[h.Id] = 0;
                _bigHeadXp[h.Id] = 0;
            }
            foreach (var b in bots.Agents)
            {
                _weaponTier[b.Id] = 0;
                _bigHeadXp[b.Id] = 0;
            }

            if (IsPve)
            {
                for (int i = 0; i < humanPlayers.Count; i++)
                {
                    humanPlayers[i].Hp = 1000;
                    humanPlayers[i].MaxHp = 1000;
                }
                PveStage = 1;
                PveStageRemaining = Math.Max(1, bots.Agents.Count);
                PveTaskNow = 209;
                Team1Score = 1;
                Team2Score = PveStageRemaining;
                _pveTowers.Clear();
                _pendingDeletedEntityIds.Clear();
                _pveTowers.Add(new PveTowerEntityData
                {
                    Id = 6327907,
                    EType = 9,
                    Hp = 1f,
                    MaxHp = 1f,
                    X = 5328f,
                    Y = 2412f,
                    Z = 522f,
                    FileName = "genpve_door4_roadBlock"
                });
                _pveTowers.Add(new PveTowerEntityData
                {
                    Id = 6327908,
                    EType = 9,
                    Hp = 1f,
                    MaxHp = 1f,
                    X = 3312f,
                    Y = 7581f,
                    Z = 517f,
                    FileName = "genpve_door4_roadBlock"
                });
                return;
            }

            if (IsExplode)
            {
                SetupExplodeRound(humanPlayers, bots, broadcast: false, tcp: null);
            }
            else if (IsWeaponMaster)
            {
                for (int i = 0; i < humanPlayers.Count; i++) EquipWeaponForEntity(humanPlayers[i], WeaponMasterLadder[0]);
                foreach (var b in bots.Agents) EquipWeaponForEntity(b.Snap, WeaponMasterLadder[0]);
            }
            else if (IsFlyKnife)
            {
                for (int i = 0; i < humanPlayers.Count; i++) EquipHumanFlyKnife(humanPlayers[i]);
                var bag = _cfg.Bags[Math.Clamp(_cfg.ActiveBag - 1, 0, _cfg.Bags.Count - 1)];
                string knife = string.IsNullOrWhiteSpace(bag.Melee) ? "dagger" : bag.Melee;
                foreach (var b in bots.Agents) EquipWeaponForEntity(b.Snap, knife);
            }
        }

        public void InitializeJoiningHuman(PlayerBasicInfo joiningPlayer, IReadOnlyList<PlayerBasicInfo>? existingHumans = null)
        {
            existingHumans ??= Array.Empty<PlayerBasicInfo>();
            _weaponTier[joiningPlayer.Id] = 0;
            _bigHeadXp[joiningPlayer.Id] = 0;

            if (IsPve)
            {
                joiningPlayer.Hp = 1000;
                joiningPlayer.MaxHp = 1000;
                return;
            }

            if (IsExplode)
            {
                if (_explodePhase == ExplodeRoundPhase.Playing && joiningPlayer.Team == 1 && !C4Planted && !C4Dropped)
                {
                    bool humanHasC4 = false;
                    for (int i = 0; i < existingHumans.Count; i++)
                    {
                        if (existingHumans[i].Id != joiningPlayer.Id && existingHumans[i].HasC4)
                        {
                            humanHasC4 = true;
                            break;
                        }
                    }

                    bool botPlanting = false;
                    if (_bots != null)
                    {
                        foreach (var b in _bots.Agents)
                        {
                            if (!b.Snap.IsDead && b.Snap.HasC4 && IsInsideAnyBombSite(b.Snap.PosX, b.Snap.PosY, b.Snap.PosZ, out _))
                            {
                                botPlanting = true;
                                break;
                            }
                        }
                    }

                    if (!humanHasC4 && !botPlanting)
                    {
                        if (_bots != null)
                        {
                            foreach (var b in _bots.Agents) b.Snap.HasC4 = false;
                        }
                        joiningPlayer.HasC4 = true;
                    }
                }
                return;
            }

            if (IsWeaponMaster)
            {
                EquipWeaponForEntity(joiningPlayer, WeaponMasterLadder[0]);
            }
            else if (IsFlyKnife)
            {
                EquipHumanFlyKnife(joiningPlayer);
            }
        }

        public void OnHumanRemoved(PlayerBasicInfo player, TcpBattleGateway tcp)
        {
            if (_plantActorId == player.Id) CancelPlantProgress(tcp);
            if (_defuseActorId == player.Id) CancelDefuseProgress(tcp);
            if (IsExplode && player.HasC4 && !C4Planted)
            {
                DropC4At(player.PosX, player.PosY, player.PosZ, player, tcp);
            }
        }

        public bool IsPlayerDefusingC4(PlayerBasicInfo p, DecodedUserCmd cmd)
        {
            if (!IsExplode || !C4Planted || p.Team != 2 || p.IsDead) return false;
            if ((cmd.Buttons & ButtonConstant.Demolition) == 0) return false;
            return Dist2D(p.PosX, p.PosY, C4X, C4Y) <= 160f && Math.Abs(p.PosZ - C4Z) <= 140f;
        }

        public void HandlePlayerExplodeCommand(PlayerBasicInfo p, DecodedUserCmd cmd, int prevButtons, float dt, TcpBattleGateway tcp)
        {
            if (!IsExplode || _explodePhase != ExplodeRoundPhase.Playing) return;
            if (p.IsDead)
            {
                if (_plantActorId == p.Id) CancelPlantProgress(tcp);
                if (_defuseActorId == p.Id) CancelDefuseProgress(tcp);
                return;
            }

            bool dropPressed = (cmd.Buttons & ButtonConstant.ThrowWeapon) != 0 && (prevButtons & ButtonConstant.ThrowWeapon) == 0;
            if (dropPressed && p.HasC4 && !C4Planted)
            {
                if (_plantActorId == p.Id) CancelPlantProgress(tcp);
                DropC4At(p.PosX, p.PosY, p.PosZ, p, tcp);
                return;
            }

            // Team 1 持包者按左键下包
            bool canPlant = p.Team == 1 && p.HasC4 && !C4Planted && p.CurrentWeapon == 5 &&
                (cmd.Buttons & ButtonConstant.Attack) != 0 &&
                IsInsideAnyBombSite(p.PosX, p.PosY, p.PosZ, out _);
            if (canPlant && (_plantActorId == 0 || _plantActorId == p.Id))
            {
                if (!_plantProgressActive || _plantActorId != p.Id)
                {
                    _plantProgressActive = true;
                    _plantActorId = p.Id;
                    _plantActorName = p.PlayerName;
                    tcp.BroadcastProgress(ProgressType.ACTIVE, 3000, p.PlayerName, "", 1f, _plantProgressSec * 1000f);
                }
                _plantProgressSec += dt;
                if (_plantProgressSec >= 3.0f)
                {
                    PlantC4At(p, tcp);
                }
                return;
            }
            if (_plantActorId == p.Id)
            {
                CancelPlantProgress(tcp);
            }

            // Team 2 靠近已安放 C4 按 E 拆包
            bool canDefuse = p.Team == 2 && C4Planted && (cmd.Buttons & ButtonConstant.Demolition) != 0 &&
                Dist2D(p.PosX, p.PosY, C4X, C4Y) <= 160f && Math.Abs(p.PosZ - C4Z) <= 140f;
            if (canDefuse && (_defuseActorId == 0 || _defuseActorId == p.Id))
            {
                if (!_defuseProgressActive || _defuseActorId != p.Id)
                {
                    _defuseProgressActive = true;
                    _defuseActorId = p.Id;
                    _defuseActorName = p.PlayerName;
                    tcp.BroadcastProgress(ProgressType.DEMOLITION, 5000, p.PlayerName, "", 1f, _defuseProgressSec * 1000f);
                }
                _defuseProgressSec += dt;
                if (_defuseProgressSec >= 5.0f)
                {
                    DefuseC4(p, tcp);
                }
            }
            else if (_defuseActorId == p.Id)
            {
                CancelDefuseProgress(tcp);
            }
        }

        private void CancelPlantProgress(TcpBattleGateway? tcp)
        {
            _plantActorId = 0;
            _plantProgressSec = 0f;
            if (_plantProgressActive)
            {
                _plantProgressActive = false;
                tcp?.BroadcastProgress(ProgressType.ACTIVE, 0, _plantActorName, "", 0f, 0f);
                _plantActorName = "";
            }
        }

        private void CancelDefuseProgress(TcpBattleGateway? tcp)
        {
            _defuseActorId = 0;
            _defuseProgressSec = 0f;
            if (_defuseProgressActive)
            {
                _defuseProgressActive = false;
                tcp?.BroadcastProgress(ProgressType.DEMOLITION, 0, _defuseActorName, "", 0f, 0f);
                _defuseActorName = "";
            }
        }

        private void CancelActiveProgress(TcpBattleGateway? tcp)
        {
            CancelPlantProgress(tcp);
            CancelDefuseProgress(tcp);
        }

        public bool TryFlyKnifeAttack(PlayerBasicInfo shooter, bool attack1, bool attack2, IReadOnlyList<PlayerBasicInfo> targets)
        {
            if (!IsFlyKnife || (!attack1 && !attack2) || shooter.IsDead) return false;
            // 飞刀模式允许远程投掷飞刀命中（射线 2600cm + BSP 遮挡检验）
            float muzzleX = shooter.PosX;
            float muzzleY = shooter.PosY;
            float muzzleZ = shooter.PosZ + (shooter.ViewHeight - 4f);
            float yawRad = shooter.ViewYaw * (float)Math.PI / 180f;
            float pitchRad = shooter.ViewPitch * (float)Math.PI / 180f;
            float cosP = (float)Math.Cos(pitchRad);
            float fwdX = (float)Math.Cos(yawRad) * cosP;
            float fwdY = (float)Math.Sin(yawRad) * cosP;
            float fwdZ = -(float)Math.Sin(pitchRad);

            PlayerBasicInfo? best = null;
            float bestProj = 2600f;
            int bestPart = 2;
            for (int i = 0; i < targets.Count; i++)
            {
                var t = targets[i];
                if (t.Id == shooter.Id || t.IsDead) continue;
                float tx = t.PosX - muzzleX, ty = t.PosY - muzzleY, tz = (t.PosZ + 100f) - muzzleZ;
                float proj = tx * fwdX + ty * fwdY + tz * fwdZ;
                if (proj <= 0f || proj >= bestProj) continue;
                float px = muzzleX + fwdX * proj, py = muzzleY + fwdY * proj, pz = muzzleZ + fwdZ * proj;
                if (Dist2D(px, py, t.PosX, t.PosY) <= 34f && pz >= t.PosZ && pz <= t.PosZ + 178f)
                {
                    if (_officialPhysics.IsReady && !_officialPhysics.TraceRayClear(muzzleX, muzzleY, muzzleZ, px, py, pz, out _)) continue;
                    bestProj = proj;
                    best = t;
                    bestPart = pz >= t.PosZ + 135f ? 1 : 2;
                }
            }
            if (best != null)
            {
                G_Combat.ApplyDamage(best, shooter, 110, bestPart, shooter.CurrentWeaponName, ignoreArmor: true);
                return true;
            }
            return false;
        }

        public void OnEntityKilled(PlayerBasicInfo? killer, PlayerBasicInfo? victim, TcpBattleGateway tcp, IReadOnlyList<PlayerBasicInfo> allPlayers, string weaponName = "")
        {
            if (IsPve)
            {
                HandlePveEntityKilled(killer, victim, tcp);
                return;
            }

            if (Biohazard is { } bio)
            {
                if (victim != null && bio.RecordKill(killer, victim,
                    !string.IsNullOrEmpty(weaponName) && _tables.GetWeapon(weaponName).IsMelee) is { } message)
                {
                    Team2Kills++;
                    tcp.BroadcastBioGrowth(bio.GrowthLevel);
                    tcp.BroadcastBioMessage(message, killer!.PlayerName, victim.PlayerName);
                }
                return;
            }

            if (victim != null && victim.HasC4 && IsExplode && !C4Planted)
            {
                if (_plantActorId == victim.Id) CancelPlantProgress(tcp);
                DropC4At(victim.PosX, victim.PosY, victim.PosZ, victim, tcp);
            }

            if (killer != null)
            {
                if (!IsExplode)
                {
                    if (killer.Team == 1) { Team1Kills++; Team1Score++; }
                    else if (killer.Team == 2) { Team2Kills++; Team2Score++; }
                }
                else
                {
                    if (killer.Team == 1) Team1Kills++;
                    else Team2Kills++;
                }

                // 武器大师升级
                if (IsWeaponMaster && killer.Id != victim?.Id)
                {
                    int tier = _weaponTier.TryGetValue(killer.Id, out int cur) ? cur + 1 : 1;
                    _weaponTier[killer.Id] = tier;
                    if (tier < WeaponMasterLadder.Length)
                    {
                        EquipWeaponForEntity(killer, WeaponMasterLadder[tier]);
                        if (!killer.IsBot)
                        {
                            var flags = new List<bool>(WeaponMasterLadder.Length);
                            for (int i = 0; i < WeaponMasterLadder.Length; i++) flags.Add(i <= tier);
                            tcp.BroadcastWeaponMaster(flags, targetPlayerId: killer.Id);
                        }
                    }
                    else
                    {
                        Team1Score = Math.Max(Team1Score, killer.Team == 1 ? WinScore : Team1Score);
                        if (!killer.IsBot || IsFreeForAll) MatchOver = true;
                    }
                }

                // 大头英雄模式体型放大
                if (IsBigHead && killer.Id != victim?.Id)
                {
                    int xp = (_bigHeadXp.TryGetValue(killer.Id, out int cur) ? cur : 0) + 1;
                    _bigHeadXp[killer.Id] = xp;
                    int lv = Math.Clamp(xp / 2 + 1, 1, 4);
                    float scale = (lv - 1) * 0.35f;
                    killer.HeadEnlarge = scale;
                    killer.OtherHeadEnlarge = scale;
                    if (!killer.IsBot)
                    {
                        tcp.BroadcastBigHeadProgress(lv, (xp % 2) * 50, targetPlayerId: killer.Id);
                    }
                }
            }

            if (!IsExplode && !IsWeaponMaster && !MatchOver)
            {
                if (Team1Score >= WinScore || Team2Score >= WinScore || (IsFreeForAll && killer != null && killer.Kills >= WinScore))
                {
                    MatchOver = true;
                }
            }
        }

        private void HandlePveEntityKilled(PlayerBasicInfo? killer, PlayerBasicInfo? victim, TcpBattleGateway tcp)
        {
            if (victim == null || victim.Team != 2) return;

            Team1Kills++;
            PveTaskNow++;
            tcp.BroadcastRpgCounterUpdate(PveTaskNow);
            tcp.BroadcastPveExp(5 + Team1Kills * 2);
            tcp.BroadcastPlayerLogout(victim.Id, victim.PlayerName);

            PveStageRemaining = Math.Max(0, PveStageRemaining - 1);
            Team2Score = PveStageRemaining;

            bool isBossKill = string.Equals(victim.Career, "boss1001", StringComparison.OrdinalIgnoreCase);
            if (PveStage >= 4 && (isBossKill || PveStageRemaining == 0))
            {
                if (_bots != null)
                {
                    foreach (var b in _bots.Agents)
                    {
                        if (!b.Snap.IsDead && b.Id != victim.Id)
                        {
                            G_Combat.BeginDeath(b.Snap, null, headshot: false);
                            _officialPhysics.SetPlayerDead(b.Id, true);
                            tcp.BroadcastKillNotice(0, "", b.Id, b.Snap.PlayerName, "accident", "", false, 0, 0, 2);
                            tcp.BroadcastPlayerLogout(b.Id, b.Snap.PlayerName);
                        }
                    }
                }
                PveStageRemaining = 0;
                Team2Score = 0;
                Team1Score = WinScore;
                MatchOver = true;
                tcp.BroadcastPveScore(0f, WinScore, 4);
                tcp.BroadcastRpgTipsHide(-3011);
                return;
            }

            if (PveStageRemaining == 0 && PveStage < 4)
            {
                PveStage++;
                if (PveStage == 2)
                {
                    _pveTowers.RemoveAll(t => t.Id == 6327907);
                    _pendingDeletedEntityIds.Add(6327907);
                    tcp.BroadcastPveMessage(46);
                }
                else if (PveStage == 4)
                {
                    _pveTowers.RemoveAll(t => t.Id == 6327908);
                    _pendingDeletedEntityIds.Add(6327908);
                }
                tcp.BroadcastPveMessage(47);
                tcp.BroadcastPveMessage(48);
                tcp.BroadcastRpgTipsHide(-3011);

                if (_bots != null)
                {
                    _bots.SpawnPveStageWave(PveStage);
                    foreach (var b in _bots.Agents)
                    {
                        long botCid = 100000L + b.Id;
                        tcp.BroadcastPlayerLogin(b.Id, b.Snap.PlayerName, b.Team, botCid, isBot: true);
                        tcp.BroadcastPlayerInfo(botCid);
                    }
                    PveStageRemaining = Math.Max(1, _bots.Agents.Count);
                }
                else
                {
                    PveStageRemaining = 4;
                }

                Team1Score = PveStage;
                Team2Score = PveStageRemaining;
                tcp.BroadcastPveScore(PveStageRemaining, WinScore, PveStage);
                if (PveStage == 4)
                {
                    tcp.BroadcastPveMessage(59);
                }
                return;
            }

            tcp.BroadcastPveScore(PveStageRemaining, WinScore, PveStage);
        }

        public IReadOnlyList<SceneBufEntityData> GetBioSceneBuffs()
        {
            if (Biohazard is not { } bio || bio.SupplyCrates.Count == 0)
                return Array.Empty<SceneBufEntityData>();
            var list = new List<SceneBufEntityData>(bio.SupplyCrates.Count);
            foreach (var c in bio.SupplyCrates)
            {
                list.Add(new SceneBufEntityData
                {
                    Id = c.Id,
                    EType = 9,
                    X = c.X,
                    Y = c.Y,
                    Z = c.Z,
                    BufName = c.BufName,
                    Show = true,
                    Scale = new Vector3DData { X = 1.5f, Y = 1.5f, Z = 1.5f }
                });
            }
            return list;
        }

        public void TickBiohazard(int now, IReadOnlyList<PlayerBasicInfo> players, TcpBattleGateway tcp,
            Action<PlayerBasicInfo> changeRole, Action resetRound, float dt = 0.033f)
        {
            if (Biohazard is not { } bio || MatchOver) return;
            if (!bio.HasStarted)
            {
                bio.Begin(now);
                return;
            }
            if (bio.IntermissionComplete(now))
            {
                if (Team1Score >= WinScore || Team2Score >= WinScore)
                {
                    MatchOver = true;
                    return;
                }
                resetRound();
                bio.Begin(now);
                tcp.BroadcastClearForNewSection();
                tcp.BroadcastBioGrowth(0);
                tcp.BroadcastStartNewSection(tcp.GetConfiguredSectionTimeMs());
                return;
            }
            if (bio.SelectMother(now, players) is { } mother)
            {
                changeRole(mother);
                tcp.BroadcastBioMessage(BioMessageType.DOUNCHANGED, mother.PlayerName);
            }

            // 变异体脱战自然回血、补给箱随机刷新/拾取、终结者英雄变身
            bio.TickRegen(dt, now, players);
            bio.TickSupplySpawns(dt, _bsp.Spawns);
            foreach (var p in players)
            {
                if (bio.TryPickUpSupply(p, _tables) != null)
                {
                    tcp.BroadcastBioMessage(BioMessageType.GETBIOITEM, p.PlayerName);
                }
            }
            foreach (var hero in bio.TryPromoteHeroes(players))
            {
                var def = _tables.GetWeapon(BiohazardRound.HeroWeapon);
                PlayerLoadout.Equip(hero, hero.CurrentBagId, 3, CarriedWeapon.FromConfig(BiohazardRound.HeroWeapon, "", def), def);
                changeRole(hero);
                tcp.BroadcastBioMessage(BioMessageType.CHANGEHERO, hero.PlayerName);
            }

            if (bio.TryFinish(now, players) is int winner)
            {
                if (winner == BiohazardRound.InfectedTeam) Team1Score++;
                else Team2Score++;
                OnRoundEnded?.Invoke();
                tcp.BroadcastTeamScore(Team1Score, Team2Score, WinScore, Team1Kills, Team2Kills);
                tcp.BroadcastMissionResult(winner == BiohazardRound.HumanTeam, "");
            }
        }

        public void Tick(
            float dt,
            PlayerBasicInfo localPlayer,
            BotDirector bots,
            List<PlayerBasicInfo> allEntities,
            TcpBattleGateway tcp,
            List<GrenadeExplosionEventData> explosionsOut)
            => Tick(dt, new[] { localPlayer }, bots, allEntities, tcp, explosionsOut);

        public void Tick(
            float dt,
            IReadOnlyList<PlayerBasicInfo> humanPlayers,
            BotDirector bots,
            List<PlayerBasicInfo> allEntities,
            TcpBattleGateway tcp,
            List<GrenadeExplosionEventData> explosionsOut)
        {
            if (!IsExplode) return;

            if (_explodePhase == ExplodeRoundPhase.RoundEndFreeze)
            {
                _roundEndTimer -= dt;
                if (_roundEndTimer <= 0f)
                {
                    if (Team1Score >= WinScore || Team2Score >= WinScore)
                    {
                        MatchOver = true;
                        return;
                    }
                    SetupExplodeRound(humanPlayers, bots, broadcast: true, tcp: tcp);
                }
                return;
            }

            _roundElapsedSec += dt;

            // 捡起地上掉落的 C4（丢包者 1.2 秒内不会瞬间原地吸回）
            if (_c4DropCooldownSec > 0f) _c4DropCooldownSec = Math.Max(0f, _c4DropCooldownSec - dt);
            if (C4Dropped && !C4Planted)
            {
                for (int i = 0; i < allEntities.Count; i++)
                {
                    var p = allEntities[i];
                    if (p.IsDead || p.Team != 1) continue;
                    if (p.Id == _c4DropperId && _c4DropCooldownSec > 0f) continue;
                    if (Dist2D(p.PosX, p.PosY, C4X, C4Y) <= SceneWeaponDrop.PickupRadius
                        && Math.Abs(p.PosZ - C4Z) <= SceneWeaponDrop.PickupHeight)
                    {
                        C4Dropped = false;
                        _c4DropperId = 0;
                        _sceneDrops.Clear();
                        p.HasC4 = true;
                        tcp.BroadcastC4Message(C4MessageType.PICKUP, p.PlayerName, p.PosX, p.PosY, p.PosZ);
                        Console.WriteLine($"[SSJJ-Server][EXPLODE] {p.PlayerName} picked up C4!");
                        break;
                    }
                }
            }

            // 人机 AI 爆破目标逻辑（C4 携带者寻路下包 / CT 拆包）
            TickExplodeBotObjectives(dt, bots, tcp);

            // Wait briefly for remaining human seats on first round before evaluating team wipe
            bool waitingForHumans = !_cfg.Headless && Team1Score == 0 && Team2Score == 0 &&
                humanPlayers.Count < _cfg.MaxHumanPlayers && _roundElapsedSec < 15.0f;

            // C4 倒计时推进
            if (C4Planted)
            {
                C4ElapsedSec += dt;
                _c4BroadcastAcc += dt;
                if (_c4BroadcastAcc >= 1.0f)
                {
                    _c4BroadcastAcc = 0f;
                    tcp.BroadcastC4State(true, (int)(C4ElapsedSec * 1000f));
                }
                if (C4ElapsedSec >= C4DetonateSec)
                {
                    explosionsOut.Add(new GrenadeExplosionEventData
                    {
                        ThrowerId = _c4PlanterId > 0 ? _c4PlanterId : (humanPlayers.Count > 0 ? humanPlayers[0].Id : 1),
                        WeaponTid = 10,
                        PosX = C4X,
                        PosY = C4Y,
                        PosZ = C4Z
                    });
                    EndExplodeRound(winnerTeam: 1, reason: "C4 爆炸", tcp: tcp);
                    return;
                }
            }

            if (waitingForHumans) return;

            // 回合胜负判定（歼灭 / 超时）
            int aliveT = 0, aliveCt = 0;
            for (int i = 0; i < allEntities.Count; i++)
            {
                var p = allEntities[i];
                if (p.IsDead) continue;
                if (p.Team == 1) aliveT++;
                else if (p.Team == 2) aliveCt++;
            }

            if (aliveT == 0 && !C4Planted)
            {
                EndExplodeRound(winnerTeam: 2, reason: "CT 全歼 T", tcp: tcp);
            }
            else if (aliveCt == 0)
            {
                EndExplodeRound(winnerTeam: 1, reason: "T 全歼 CT", tcp: tcp);
            }
            else if (!C4Planted && _roundElapsedSec >= 150.0f)
            {
                EndExplodeRound(winnerTeam: 2, reason: "回合时间耗尽", tcp: tcp);
            }
        }

        public float[]? GetBotObjectiveFor(BotAgent bot)
        {
            if (Biohazard is { IsActive: true } bio && !BiohazardRound.IsInfected(bot.Snap) && bio.SupplyCrates.Count > 0)
            {
                bool lowAmmo = bot.Snap.MaxClip > 0 && bot.Snap.CurrentCarryClip <= bot.Snap.MaxClip;
                if (lowAmmo || bot.Snap.Hp < bot.Snap.MaxHp * 0.6f)
                {
                    var crate = bio.SupplyCrates[0];
                    return new[] { crate.X, crate.Y, crate.Z, 0f };
                }
            }
            if (!IsExplode) return null;
            if (bot.Team == 1)
            {
                if (C4Dropped && !C4Planted) return new[] { C4X, C4Y, C4Z, 0f };
                if (bot.Snap.HasC4 && !C4Planted)
                {
                    var site = PickNearestBombSite(bot.Snap.PosX, bot.Snap.PosY);
                    float hold = IsInsideAnyBombSite(bot.Snap.PosX, bot.Snap.PosY, bot.Snap.PosZ, out _) ? 1f : 0f;
                    return new[] { site.X, site.Y, site.Z, hold };
                }
                if (C4Planted) return new[] { C4X, C4Y, C4Z, 0f };
            }
            else if (bot.Team == 2)
            {
                if (C4Planted)
                {
                    float hold = Dist2D(bot.Snap.PosX, bot.Snap.PosY, C4X, C4Y) <= 130f ? 1f : 0f;
                    return new[] { C4X, C4Y, C4Z, hold };
                }
                var site = PickSiteByIndex(bot.Id);
                return new[] { site.X, site.Y, site.Z, 0f };
            }
            return null;
        }

        private void TickExplodeBotObjectives(float dt, BotDirector bots, TcpBattleGateway tcp)
        {
            bool anyBotPlanting = false;
            bool anyBotDefusing = false;
            for (int i = 0; i < bots.Agents.Count; i++)
            {
                var b = bots.Agents[i];
                if (b.Snap.IsDead) continue;

                if (b.Team == 1 && b.Snap.HasC4 && !C4Planted)
                {
                    if (IsInsideAnyBombSite(b.Snap.PosX, b.Snap.PosY, b.Snap.PosZ, out _))
                    {
                        anyBotPlanting = true;
                        _botPlantProgressSec += dt;
                        if (_botPlantProgressSec >= 3.0f)
                        {
                            PlantC4At(b.Snap, tcp);
                        }
                    }
                }
                else if (b.Team == 2 && C4Planted && Dist2D(b.Snap.PosX, b.Snap.PosY, C4X, C4Y) <= 140f)
                {
                    anyBotDefusing = true;
                    _botDefuseProgressSec += dt;
                    if (_botDefuseProgressSec >= 5.0f)
                    {
                        DefuseC4(b.Snap, tcp);
                    }
                }
            }
            if (!anyBotPlanting) _botPlantProgressSec = 0f;
            if (!anyBotDefusing) _botDefuseProgressSec = 0f;
        }

        private void PlantC4At(PlayerBasicInfo planter, TcpBattleGateway tcp)
        {
            C4Planted = true;
            C4Dropped = false;
            planter.HasC4 = false;
            _c4PlanterId = planter.Id;
            CancelPlantProgress(tcp);
            _botPlantProgressSec = 0f;
            C4X = planter.PosX;
            C4Y = planter.PosY;
            C4Z = planter.PosZ;
            C4ElapsedSec = 0f;

            _sceneDrops.Clear();
            _sceneDrops.Add(new SceneWeaponDrop
            {
                Id = _c4DropEntityId,
                WeaponName = "c4",
                WeaponType = 3,
                X = C4X,
                Y = C4Y,
                Z = C4Z
            });

            if (planter.CurrentWeapon == 5)
            {
                RestorePrimaryAfterC4(planter);
            }

            tcp.BroadcastC4State(true, 0);
            tcp.BroadcastC4Message(C4MessageType.ACTIVE, planter.PlayerName, C4X, C4Y, C4Z);
            var msg = new SimpleProto { Key = 1 };
            msg.Ss.Add($"{planter.PlayerName} 已安放 C4！倒计时 40 秒");
            tcp.BroadcastSimpleProto(msg);
            Console.WriteLine($"[SSJJ-Server][EXPLODE] C4 planted by {planter.PlayerName} at ({C4X:F0},{C4Y:F0},{C4Z:F0})");
        }

        private void DefuseC4(PlayerBasicInfo defuser, TcpBattleGateway tcp)
        {
            C4Planted = false;
            CancelDefuseProgress(tcp);
            _botDefuseProgressSec = 0f;
            _sceneDrops.Clear();
            tcp.BroadcastC4State(false, 0);
            tcp.BroadcastC4Message(C4MessageType.DEMOLITIONSUCCESS, defuser.PlayerName, C4X, C4Y, C4Z);
            EndExplodeRound(winnerTeam: 2, reason: $"{defuser.PlayerName} 成功拆除 C4", tcp: tcp);
        }

        private void DropC4At(float x, float y, float z, PlayerBasicInfo? carrier, TcpBattleGateway? tcp = null)
        {
            if (carrier != null)
            {
                tcp?.BroadcastC4Message(C4MessageType.FALLING, carrier.PlayerName, x, y, z);
                carrier.HasC4 = false;
                if (carrier.CurrentWeapon == 5)
                {
                    RestorePrimaryAfterC4(carrier);
                }
            }
            _c4DropperId = carrier?.Id ?? 0;
            _c4DropCooldownSec = 1.2f;
            C4Dropped = true;
            C4X = x;
            C4Y = y;
            C4Z = z;
            _sceneDrops.Clear();
            _sceneDrops.Add(new SceneWeaponDrop
            {
                Id = _c4DropEntityId,
                WeaponName = "c4",
                WeaponType = 3,
                X = x,
                Y = y,
                Z = z
            });
            Console.WriteLine($"[SSJJ-Server][EXPLODE] C4 dropped at ({x:F0},{y:F0},{z:F0})");
        }

        private void EndExplodeRound(int winnerTeam, string reason, TcpBattleGateway tcp)
        {
            if (_explodePhase == ExplodeRoundPhase.RoundEndFreeze) return;
            CancelActiveProgress(tcp);
            _explodePhase = ExplodeRoundPhase.RoundEndFreeze;
            _roundEndTimer = 4.0f;

            if (winnerTeam == 1) Team1Score++;
            else Team2Score++;
            OnRoundEnded?.Invoke();

            tcp.BroadcastTeamScore(Team1Score, Team2Score, WinScore, Team1Kills, Team2Kills);
            var msg = new SimpleProto { Key = 1 };
            msg.Ss.Add($"第 {Team1Score + Team2Score} 回合结束：Team {winnerTeam} 胜 ({reason})");
            tcp.BroadcastSimpleProto(msg);
            Console.WriteLine($"[SSJJ-Server][EXPLODE] Round End: Winner=Team{winnerTeam} ({reason}) Score={Team1Score}:{Team2Score}");
        }

        private void SetupExplodeRound(IReadOnlyList<PlayerBasicInfo> humanPlayers, BotDirector bots, bool broadcast, TcpBattleGateway? tcp)
        {
            _explodePhase = ExplodeRoundPhase.Playing;
            _roundElapsedSec = 0f;
            _plantProgressSec = 0f;
            _defuseProgressSec = 0f;
            _botPlantProgressSec = 0f;
            _botDefuseProgressSec = 0f;
            _plantActorId = 0;
            _defuseActorId = 0;
            _plantActorName = "";
            _defuseActorName = "";
            _c4PlanterId = 0;
            _plantProgressActive = false;
            _defuseProgressActive = false;
            C4Planted = false;
            C4Dropped = false;
            C4ElapsedSec = 0f;
            _sceneDrops.Clear();

            bool c4Assigned = false;
            int team1Index = 0;
            int team2Index = 0;
            for (int i = 0; i < humanPlayers.Count; i++)
            {
                var hp = humanPlayers[i];
                int spawnIdx = hp.Team == 1 ? team1Index++ : team2Index++;
                var sp = _bsp.PickSpawn(hp.Team, spawnIdx, false);
                float lz = sp.Z;
                if (_officialPhysics.IsReady && _officialPhysics.SampleGround(sp.X, sp.Y, sp.Z, out float gz)) lz = gz + 2f;

                G_Combat.ResetSpawnAnimation(hp);
                hp.Hp = hp.MaxHp;
                hp.Zhuangjia = 100;
                hp.Hudun = 0;
                hp.LifeBarSeq++;
                hp.CanChangeBag = true;
                hp.PunchYaw = hp.PunchPitch = hp.DecayTime = 0;
                hp.PosX = sp.X; hp.PosY = sp.Y; hp.PosZ = lz;
                hp.VelX = 0f; hp.VelY = 0f; hp.VelZ = 0f;
                hp.Velocity2D = 0f; hp.Moving = false; hp.OnGround = true;
                hp.DuckState = 3; hp.DuckTime = 0; hp.ViewHeight = 150f;
                hp.Stamina = 0f; hp.PlayerStateFlag = 0; hp.GroundEntityNum = -1;
                hp.ViewYaw = sp.Yaw; hp.MoveYaw = sp.Yaw;

                if (!hp.IsBot)
                {
                    var bags = _cfg.GetHumanBags(hp.CharacterId);
                    hp.Loadout = new PlayerLoadout(bags, _tables);
                    int bagId = Math.Clamp(hp.CurrentBagId, 1, bags.Count);
                    if (!hp.Loadout.Switch(hp, bagId, 1, 1, 1, _tables, playRaise: false) &&
                        !hp.Loadout.Switch(hp, bagId, 2, 2, 2, _tables, playRaise: false))
                    {
                        hp.Loadout.Switch(hp, bagId, 3, 3, 3, _tables, playRaise: false);
                    }
                }

                hp.HasC4 = false;
                if (!c4Assigned && hp.Team == 1)
                {
                    hp.HasC4 = true;
                    c4Assigned = true;
                }
                _officialPhysics.SetPlayerPosition(hp.Id, sp.X, sp.Y, lz);
            }

            bots.RespawnAll();
            foreach (var b in bots.Agents)
            {
                b.Snap.HasC4 = false;
                if (!c4Assigned && b.Team == 1)
                {
                    b.Snap.HasC4 = true;
                    c4Assigned = true;
                }
            }

            if (broadcast && tcp != null)
            {
                tcp.BroadcastProgress(ProgressType.ACTIVE, 0, "", "", 0f, 0f);
                tcp.BroadcastC4State(false, 0);
                tcp.BroadcastClearForNewSection();
                tcp.BroadcastStartNewSection(TcpBattleGateway.GetSectionTimeMs(RaceType));
                tcp.BroadcastTeamScore(Team1Score, Team2Score, WinScore, Team1Kills, Team2Kills);
            }
        }

        private void RestorePrimaryAfterC4(PlayerBasicInfo player)
        {
            var bags = player.IsBot ? _cfg.Bags : _cfg.GetHumanBags(player.CharacterId);
            int bagIdx = Math.Clamp(player.CurrentBagId - 1, 0, bags.Count - 1);
            var bag = bags[bagIdx];
            string weaponName = string.IsNullOrWhiteSpace(bag.Primary) ? "m4a1" : bag.Primary;
            if (player.Loadout != null && player.Loadout.Switch(player, bagIdx + 1, 1, 1, 1, _tables, playRaise: false))
            {
                var def = _tables.GetWeapon(player.CurrentWeaponName);
                int raiseMs = Math.Max(350, PlayerPredictionEngine.GetDefaultViewAnimDurationMs(def, 16));
                player.ViewAnim = player.LeftViewAnim = 16;
                player.ViewAnimRemainMs = raiseMs;
                player.NextAttackTimer = player.NextSecondaryAttackTimer = player.ClientTime + raiseMs;
                player.PunchYaw = player.PunchPitch = player.DecayTime = 0;
                return;
            }
            EquipWeaponForEntity(player, weaponName, bag.PrimarySkin);
        }

        private void EquipHumanFlyKnife(PlayerBasicInfo human)
        {
            var bags = _cfg.GetHumanBags(human.CharacterId);
            int bagIdx = Math.Clamp(human.CurrentBagId - 1, 0, bags.Count - 1);
            var bag = bags[bagIdx];
            string knife = string.IsNullOrWhiteSpace(bag.Melee) ? "dagger" : bag.Melee;
            if (human.Loadout != null && human.Loadout.Switch(human, bagIdx + 1, 3, 3, 3, _tables, playRaise: false))
            {
                return;
            }
            EquipWeaponForEntity(human, knife, bag.MeleeSkin);
        }

        private void EquipWeaponForEntity(PlayerBasicInfo p, string weaponName, string skin = "")
        {
            var def = _tables.GetWeapon(weaponName);
            int slot = def.IsMelee ? 3 : (def.WeaponType == 0 ? 2 : 1);
            p.CurrentWeapon = slot;
            p.CurrentWeaponIndex = slot;
            p.CurrentWeaponName = weaponName;
            p.CurrentWeaponSkinName = skin;
            p.MaxClip = def.MaxClip;
            p.CurrentClip = def.MaxClip;
            p.CurrentCarryClip = def.MaxCarryClip;
        }

        private bool IsInsideAnyBombSite(float x, float y, float z, out BspBombSite site)
        {
            if (_bsp.BombSites.Count > 0)
            {
                for (int i = 0; i < _bsp.BombSites.Count; i++)
                {
                    var s = _bsp.BombSites[i];
                    if (Dist2D(x, y, s.X, s.Y) <= Math.Max(s.Radius, 180f) && Math.Abs(z - s.Z) <= 180f)
                    {
                        site = s;
                        return true;
                    }
                }
            }
            site = new BspBombSite { X = 3700f, Y = 3300f, Z = z, Radius = 240f };
            return _bsp.BombSites.Count == 0 && Dist2D(x, y, site.X, site.Y) <= site.Radius;
        }

        private BspBombSite PickNearestBombSite(float x, float y)
        {
            if (_bsp.BombSites.Count == 0) return new BspBombSite { X = 3700f, Y = 3300f, Z = 120f };
            var best = _bsp.BombSites[0];
            float bestD = Dist2D(x, y, best.X, best.Y);
            for (int i = 1; i < _bsp.BombSites.Count; i++)
            {
                float d = Dist2D(x, y, _bsp.BombSites[i].X, _bsp.BombSites[i].Y);
                if (d < bestD) { bestD = d; best = _bsp.BombSites[i]; }
            }
            return best;
        }

        private BspBombSite PickSiteByIndex(int idx)
        {
            if (_bsp.BombSites.Count == 0) return new BspBombSite { X = 3700f, Y = 3300f, Z = 120f };
            return _bsp.BombSites[Math.Abs(idx) % _bsp.BombSites.Count];
        }

        private static float Dist2D(float x1, float y1, float x2, float y2)
        {
            float dx = x1 - x2, dy = y1 - y2;
            return (float)Math.Sqrt(dx * dx + dy * dy);
        }
    }
}
