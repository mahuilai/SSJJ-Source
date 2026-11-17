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
        public bool IsExplode => RaceType == 2;
        public bool IsFreeForAll => ServerConfig.IsFreeForAll(RaceType);
        public bool IsMeleeOnly => ServerConfig.IsMeleeOnly(RaceType);
        public bool IsWeaponMaster => RaceType == 64;
        public bool IsFlyKnife => RaceType == 74;
        public bool IsBigHead => RaceType == 2019;
        public bool AllowRespawn => !IsExplode;

        public int Team1Score { get; set; }
        public int Team2Score { get; set; }
        public int Team1Kills { get; set; }
        public int Team2Kills { get; set; }
        public int WinScore { get; }
        public bool MatchOver { get; private set; }

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
            WinScore = cfg.WinScoreOverride > 0 ? cfg.WinScoreOverride : TcpBattleGateway.GetWinScore(RaceType);
        }

        public IReadOnlyList<SceneWeaponDrop> GetSceneDrops() => _sceneDrops;

        public void InitializeMatch(PlayerBasicInfo localPlayer, BotDirector bots)
        {
            _weaponTier[localPlayer.Id] = 0;
            _bigHeadXp[localPlayer.Id] = 0;
            foreach (var b in bots.Agents)
            {
                _weaponTier[b.Id] = 0;
                _bigHeadXp[b.Id] = 0;
            }

            if (IsExplode)
            {
                SetupExplodeRound(localPlayer, bots, broadcast: false, tcp: null);
            }
            else if (IsWeaponMaster)
            {
                EquipWeaponForEntity(localPlayer, WeaponMasterLadder[0]);
                foreach (var b in bots.Agents) EquipWeaponForEntity(b.Snap, WeaponMasterLadder[0]);
            }
            else if (IsFlyKnife)
            {
                var bag = _cfg.Bags[Math.Clamp(_cfg.ActiveBag - 1, 0, _cfg.Bags.Count - 1)];
                string knife = string.IsNullOrWhiteSpace(bag.Melee) ? "dagger" : bag.Melee;
                EquipWeaponForEntity(localPlayer, knife, bag.MeleeSkin);
                foreach (var b in bots.Agents) EquipWeaponForEntity(b.Snap, knife);
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
            if (!IsExplode || _explodePhase != ExplodeRoundPhase.Playing || p.IsDead) return;

            bool dropPressed = (cmd.Buttons & ButtonConstant.ThrowWeapon) != 0 && (prevButtons & ButtonConstant.ThrowWeapon) == 0;
            if (dropPressed && p.HasC4 && !C4Planted)
            {
                DropC4At(p.PosX, p.PosY, p.PosZ, p);
                return;
            }

            // Team 1 持包者按左键下包
            if (p.Team == 1 && p.HasC4 && !C4Planted && p.CurrentWeapon == 5 && (cmd.Buttons & ButtonConstant.Attack) != 0)
            {
                if (IsInsideAnyBombSite(p.PosX, p.PosY, p.PosZ, out _))
                {
                    _plantProgressSec += dt;
                    if (_plantProgressSec >= 3.0f)
                    {
                        PlantC4At(p, tcp);
                    }
                    return;
                }
            }
            _plantProgressSec = 0f;

            // Team 2 靠近已安放 C4 按 E 拆包
            if (p.Team == 2 && C4Planted && (cmd.Buttons & ButtonConstant.Demolition) != 0 &&
                Dist2D(p.PosX, p.PosY, C4X, C4Y) <= 160f && Math.Abs(p.PosZ - C4Z) <= 140f)
            {
                _defuseProgressSec += dt;
                if (_defuseProgressSec >= 5.0f)
                {
                    DefuseC4(p, tcp);
                }
            }
            else if (p.Team == 2)
            {
                _defuseProgressSec = 0f;
            }
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

        public void OnEntityKilled(PlayerBasicInfo? killer, PlayerBasicInfo? victim, TcpBattleGateway tcp, IReadOnlyList<PlayerBasicInfo> allPlayers)
        {
            if (victim != null && victim.HasC4 && IsExplode && !C4Planted)
            {
                DropC4At(victim.PosX, victim.PosY, victim.PosZ, victim);
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
                        if (killer.Id == 1)
                        {
                            var flags = new List<bool>(WeaponMasterLadder.Length);
                            for (int i = 0; i < WeaponMasterLadder.Length; i++) flags.Add(i <= tier);
                            tcp.BroadcastWeaponMaster(flags);
                        }
                    }
                    else
                    {
                        Team1Score = Math.Max(Team1Score, killer.Team == 1 ? WinScore : Team1Score);
                        if (killer.Id == 1 || IsFreeForAll) MatchOver = true;
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
                    if (killer.Id == 1)
                    {
                        tcp.BroadcastBigHeadProgress(lv, (xp % 2) * 50);
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

        public void Tick(
            float dt,
            PlayerBasicInfo localPlayer,
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
                    SetupExplodeRound(localPlayer, bots, broadcast: true, tcp: tcp);
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
                    if (Dist2D(p.PosX, p.PosY, C4X, C4Y) <= 95f && Math.Abs(p.PosZ - C4Z) <= 120f)
                    {
                        C4Dropped = false;
                        _c4DropperId = 0;
                        _sceneDrops.Clear();
                        p.HasC4 = true;
                        Console.WriteLine($"[SSJJ-Server][EXPLODE] {p.PlayerName} picked up C4!");
                        break;
                    }
                }
            }

            // 人机 AI 爆破目标逻辑（C4 携带者寻路下包 / CT 拆包）
            TickExplodeBotObjectives(dt, bots, tcp);

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
                        ThrowerId = 1,
                        WeaponTid = 10,
                        PosX = C4X,
                        PosY = C4Y,
                        PosZ = C4Z
                    });
                    EndExplodeRound(winnerTeam: 1, reason: "C4 爆炸", tcp: tcp);
                    return;
                }
            }

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
            C4X = planter.PosX;
            C4Y = planter.PosY;
            C4Z = planter.PosZ;
            C4ElapsedSec = 0f;
            _plantProgressSec = 0f;
            _botPlantProgressSec = 0f;

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
                planter.CurrentWeapon = 1;
                planter.CurrentWeaponIndex = 1;
                var bag = _cfg.Bags[Math.Clamp(planter.CurrentBagId - 1, 0, _cfg.Bags.Count - 1)];
                planter.CurrentWeaponName = bag.Primary;
                planter.CurrentWeaponSkinName = bag.PrimarySkin;
            }

            tcp.BroadcastC4State(true, 0);
            var msg = new SimpleProto { Key = 1 };
            msg.Ss.Add($"{planter.PlayerName} 已安放 C4！倒计时 40 秒");
            tcp.BroadcastSimpleProto(msg);
            Console.WriteLine($"[SSJJ-Server][EXPLODE] C4 planted by {planter.PlayerName} at ({C4X:F0},{C4Y:F0},{C4Z:F0})");
        }

        private void DefuseC4(PlayerBasicInfo defuser, TcpBattleGateway tcp)
        {
            C4Planted = false;
            _sceneDrops.Clear();
            tcp.BroadcastC4State(false, 0);
            EndExplodeRound(winnerTeam: 2, reason: $"{defuser.PlayerName} 成功拆除 C4", tcp: tcp);
        }

        private void DropC4At(float x, float y, float z, PlayerBasicInfo? carrier)
        {
            if (carrier != null)
            {
                carrier.HasC4 = false;
                if (carrier.CurrentWeapon == 5)
                {
                    carrier.CurrentWeapon = 1;
                    carrier.CurrentWeaponIndex = 1;
                    var bag = _cfg.Bags[Math.Clamp(carrier.CurrentBagId - 1, 0, _cfg.Bags.Count - 1)];
                    carrier.CurrentWeaponName = bag.Primary;
                    carrier.CurrentWeaponSkinName = bag.PrimarySkin;
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
            _explodePhase = ExplodeRoundPhase.RoundEndFreeze;
            _roundEndTimer = 4.0f;

            if (winnerTeam == 1) Team1Score++;
            else Team2Score++;

            tcp.BroadcastTeamScore(Team1Score, Team2Score, WinScore, Team1Kills, Team2Kills);
            var msg = new SimpleProto { Key = 1 };
            msg.Ss.Add($"第 {Team1Score + Team2Score} 回合结束：Team {winnerTeam} 胜 ({reason})");
            tcp.BroadcastSimpleProto(msg);
            Console.WriteLine($"[SSJJ-Server][EXPLODE] Round End: Winner=Team{winnerTeam} ({reason}) Score={Team1Score}:{Team2Score}");
        }

        private void SetupExplodeRound(PlayerBasicInfo localPlayer, BotDirector bots, bool broadcast, TcpBattleGateway? tcp)
        {
            _explodePhase = ExplodeRoundPhase.Playing;
            _roundElapsedSec = 0f;
            _plantProgressSec = 0f;
            _defuseProgressSec = 0f;
            _botPlantProgressSec = 0f;
            _botDefuseProgressSec = 0f;
            C4Planted = false;
            C4Dropped = false;
            C4ElapsedSec = 0f;
            _sceneDrops.Clear();

            var sp = _bsp.PickSpawn(localPlayer.Team, 0, false);
            float lz = sp.Z;
            if (_officialPhysics.IsReady && _officialPhysics.SampleGround(sp.X, sp.Y, sp.Z, out float gz)) lz = gz + 2f;

            localPlayer.IsDead = false;
            localPlayer.Hp = localPlayer.MaxHp;
            localPlayer.Zhuangjia = 100;
            localPlayer.DeadTimer = 0f;
            localPlayer.LifeBarSeq++;
            localPlayer.PosX = sp.X; localPlayer.PosY = sp.Y; localPlayer.PosZ = lz;
            localPlayer.VelX = 0f; localPlayer.VelY = 0f; localPlayer.VelZ = 0f;
            localPlayer.Velocity2D = 0f; localPlayer.Moving = false; localPlayer.OnGround = true;
            localPlayer.DuckState = 3; localPlayer.DuckTime = 0; localPlayer.ViewHeight = 150f;
            localPlayer.Stamina = 100f; localPlayer.LegsAnim = 7; localPlayer.ViewAnim = 13;
            localPlayer.ViewYaw = sp.Yaw; localPlayer.MoveYaw = sp.Yaw;
            localPlayer.HasC4 = localPlayer.Team == 1;
            _officialPhysics.SetPlayerPosition(localPlayer.Id, sp.X, sp.Y, lz);

            bots.RespawnAll();
            bool c4Assigned = localPlayer.HasC4;
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
                tcp.BroadcastC4State(false, 0);
                tcp.BroadcastClearForNewSection();
                tcp.BroadcastStartNewSection(TcpBattleGateway.GetSectionTimeMs(RaceType));
                tcp.BroadcastTeamScore(Team1Score, Team2Score, WinScore, Team1Kills, Team2Kills);
            }
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
