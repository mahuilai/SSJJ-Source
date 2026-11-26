using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using NetData;
using SSJJ.Server.Bots;
using SSJJ.Server.Config;
using SSJJ.Server.GameModes;
using SSJJ.Server.NativeEngine;
using SSJJ.Server.Network;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;
using SSJJ.Server.Snapshot;
using SSJJUserCmd;

namespace SSJJ.Server
{
    internal static class Program
    {
        private static int Main(string[] args)
        {
            var cfg = ServerConfig.Load(args, out string? err);
            if (err != null)
            {
                Console.Error.WriteLine($"[SSJJ-Server] Config error: {err}");
                return 2;
            }

            if (cfg.MaxHumanPlayers is < 1 or > 16)
            {
                Console.Error.WriteLine("[SSJJ-Server] max_human_players must be between 1 and 16.");
                return 2;
            }
            bool multiplayer = cfg.MaxHumanPlayers > 1 && !cfg.Headless;
            if (multiplayer && cfg.EffectiveRaceType is not (2 or 3 or 4 or 5 or 6 or 12 or 14 or 15 or 16 or 17 or 19 or 26 or 28 or 31 or 33 or 64 or 65 or 68 or 69 or 74 or 2003 or 2019 or 2041 or 10001))
            {
                Console.Error.WriteLine($"[SSJJ-Server] Unsupported multiplayer race_type={cfg.EffectiveRaceType}.");
                return 2;
            }

            if (ServerConfig.IsBiohazard(cfg.EffectiveRaceType) && cfg.Biohazard?.IsValid != true)
            {
                Console.Error.WriteLine("[SSJJ-Server] biohazard requires round_ms (>15000), respawn_ms, intermission_ms, mother_hp and infected_hp (mother_hp >= infected_hp > 100).");
                return 2;
            }

            if (cfg.PrintLa)
            {
                Console.WriteLine(cfg.BuildBootConfigBase62());
                return 0;
            }

            Console.WriteLine("=================================================================");
            Console.WriteLine($"  SSJJ-Server [Server-First Architecture] map={cfg.MapId} mode={cfg.Mode} (raceType={cfg.EffectiveRaceType})");
            Console.WriteLine($"  Ports: TCP={cfg.TcpPort} UDP={cfg.UdpPort} Bots: ally={cfg.AllyBots} enemy={cfg.EnemyBots}");
            Console.WriteLine("=================================================================");

            var tables = new GameTables();
            tables.Load(cfg.ProjectRoot);

            var bsp = BspMapData.Load(cfg.MapId, cfg.BattleClientDir);
            string clipPath = System.IO.Path.Combine(AppContext.BaseDirectory, "Data", "Maps", $"map{cfg.MapId}_clip.json");
            if (!System.IO.File.Exists(clipPath))
            {
                clipPath = System.IO.Path.Combine(cfg.ProjectRoot, "SSJJ-Server", "Data", "Maps", $"map{cfg.MapId}_clip.json");
            }
            if (System.IO.File.Exists(clipPath))
            {
                Quake3Pmove.CollisionMap = ClipMap.Load(clipPath);
            }

            using var officialPhysics = new OfficialPhysicsWorld();
            bool weReady = officialPhysics.Initialize(cfg.MapId, bsp.RawBspBytes);

            if (cfg.TraceProbe)
            {
                RunTraceProbe(bsp, officialPhysics);
                return 0;
            }

            G_Combat.GodModeEnabled = cfg.GodMode;

            int raceType = cfg.EffectiveRaceType;
            bool freeForAll = ServerConfig.IsFreeForAll(raceType);
            bool meleeOnly = ServerConfig.IsMeleeOnly(raceType);
            bool isPve = ServerConfig.IsPve(raceType);
            bool canChangeBagAtSpawn = !isPve && raceType is not (64 or 74);
            var weaponDrops = !cfg.Headless && raceType is (2 or 3 or 4 or 5 or 12 or 2003) ? new WeaponDropSystem(tables) : null;

            var botDirector = new BotDirector(cfg, tables, bsp, officialPhysics);
            botDirector.SpawnAll();

            var skillSystem = new SkillAndVfxSystem(tables, officialPhysics);
            var allEntities = new List<PlayerBasicInfo>();
            foreach (var b in botDirector.Agents)
            {
                skillSystem.ResetPlayer(b.Snap);
                allEntities.Add(b.Snap);
            }

            var modeCoord = new ModeCoordinator(cfg, tables, bsp, officialPhysics);
            if (modeCoord.Biohazard != null)
            {
                foreach (var agent in botDirector.Agents)
                {
                    agent.Team = agent.Snap.Team = BiohazardRound.HumanTeam;
                    officialPhysics.SetTeam(agent.Id, agent.Team);
                }
            }

            var humans = new Dictionary<int, HumanRuntime>();
            var initialHumans = new List<PlayerBasicInfo>();
            HumanRuntime? offlineHuman = null;
            if (cfg.Headless)
            {
                long offlineCid = cfg.CharId > 0 ? cfg.CharId : 1000200072528L;
                int offlineTeam = modeCoord.Biohazard != null ? BiohazardRound.HumanTeam : cfg.PlayerTeam;
                offlineHuman = CreateHuman(
                    cfg, tables, bsp, officialPhysics, skillSystem, modeCoord,
                    playerId: 1, team: offlineTeam, characterId: offlineCid, session: null,
                    existingHumans: humans.Values, freeForAll: freeForAll, meleeOnly: meleeOnly, canChangeBagAtSpawn: canChangeBagAtSpawn);
                humans[offlineHuman.Player.Id] = offlineHuman;
                allEntities.Add(offlineHuman.Player);
                initialHumans.Add(offlineHuman.Player);
            }
            modeCoord.InitializeMatch(initialHumans, botDirector);

            var sessions = new ClientSessionRegistry(cfg.MaxHumanPlayers);
            var tcp = new TcpBattleGateway(cfg, cfg.TcpPort, null, tables,
                botDirector.Agents.Select(bot => bot.Snap.Career).ToArray(),
                sessions: sessions);
            var udp = new UdpSyncGateway(sessions, cfg.UdpPort);

            var bioDamageScores = new Dictionary<int, (long Damage, int Remainder)>();
            var bioHumanRoles = new Dictionary<PlayerBasicInfo, (string Career, string Skin, string Hand, int Bag, int Slot, string Weapon, string WeaponSkin)>();

            var pendingHits = new ConcurrentQueue<HitEventData>();
            var pendingExplosions = new ConcurrentQueue<GrenadeExplosionEventData>();
            var positionHistory = multiplayer ? new PlayerPositionHistory() : null;
            var missileSys = new G_Missile();
            missileSys.OnGrenadeExploded += exp => pendingExplosions.Enqueue(exp);
            var rosterChanges = new ConcurrentQueue<Action>();
            var removedPlayerIds = new List<int>();

            int seqId = 1;
            bool sentGameOver = false;
            bool sentGameWin = false;
            bool clientHadSpawned = false;
            double gameOverElapsed = 0.0;
            var sw = Stopwatch.StartNew();
            using var cts = new CancellationTokenSource();

            var assists = new AssistTracker();
            var roundDamage = new Dictionary<int, int>();
            var roundKills = new Dictionary<int, int>();
            var bestStreak = new Dictionary<int, int>();
            var streak = new Dictionary<int, int>();

            ObserverInfoData BuildObserverInfo(PlayerBasicInfo target)
            {
                var ranked = allEntities.OrderByDescending(e => e.Kills).ThenBy(e => e.Deaths).ThenBy(e => e.Id).ToList();
                int rank = Math.Max(1, ranked.FindIndex(e => e.Id == target.Id) + 1);
                float kd = target.Deaths > 0 ? (float)target.Kills / target.Deaths : target.Kills;
                return new ObserverInfoData
                {
                    Id = target.Id,
                    KillEfficiency = kd * 100f,
                    AliveEfficiency = target.IsDead ? 0f : 100f,
                    Kd = kd,
                    HeadKillEfficiency = target.Kills > 0 ? 35f : 0f,
                    Lv = 30,
                    RaceRankSect = 1,
                    RaceRankLv = 1,
                    TeamName = target.Team == 1 ? "风暴联盟" : "雷霆战警",
                    Rank = rank,
                    TechScore = target.Score,
                    WinRate = 55f,
                    MvpCount = target.Kills > 0 ? 1 : 0
                };
            }

            void ApplyBioRoleToPhysics(PlayerBasicInfo player)
            {
                if (botDirector.FindBot(player.Id) is { } bot)
                    bot.Team = player.Team;

                officialPhysics.UnregisterEntity(player.Id);
                officialPhysics.RegisterEntity(player.Id, player.Team, player.Career, player.IsBot,
                    player.PosX, player.PosY, player.PosZ);
                officialPhysics.SetPlayerDead(player.Id, player.IsDead);
                positionHistory?.RemovePlayer(player.Id);
                skillSystem.ResetPlayer(player);
            }

            void EquipBioRole(PlayerBasicInfo player)
            {
                var def = tables.GetWeapon(player.Career);
                PlayerLoadout.Equip(player, player.CurrentBagId, 3, CarriedWeapon.FromConfig(player.Career, "", def), def);
                player.BioWeaponEntityId = SV_Snapshot.AllocTempEntityId();
                player.Fov = player.LastFov = 90;
                player.ResumeZoom = false;
                player.TorsoAnim = 13;
                ApplyBioRoleToPhysics(player);
                tcp.BroadcastScoreBoard(allEntities);
            }

            void RecordHumanRole(PlayerBasicInfo p) => bioHumanRoles[p] =
                (p.Career, p.CareerSkin, p.HandName, p.CurrentBagId, p.CurrentWeapon, p.CurrentWeaponName, p.CurrentWeaponSkinName);

            void ResetBioHumanAtSpawn(HumanRuntime human, BspSpawnPoint spawn, bool infected)
            {
                var p = human.Player;
                float z = weReady && officialPhysics.SampleGround(spawn.X, spawn.Y, spawn.Z, out float ground) ? ground + 2f : spawn.Z;
                G_Combat.ResetSpawnAnimation(p);
                p.Hp = p.MaxHp;
                p.Zhuangjia = infected ? 0 : 100;
                p.Hudun = 0;
                p.LifeBarSeq++;
                p.BioRespawnRemainingMs = null;
                p.PosX = spawn.X; p.PosY = spawn.Y; p.PosZ = z;
                p.ViewYaw = p.MoveYaw = spawn.Yaw;
                p.ViewPitch = p.MovePitch = 0f;
                p.OnGround = true; p.DuckState = 3; p.DuckTime = 0; p.ViewHeight = 150f;
                p.VelX = p.VelY = p.VelZ = p.Velocity2D = 0f;
                p.Moving = false;
                var weapon = tables.GetWeapon(p.CurrentWeaponName);
                PlayerLoadout.Equip(p, p.CurrentBagId, p.CurrentWeapon,
                    CarriedWeapon.FromConfig(p.CurrentWeaponName, p.CurrentWeaponSkinName, weapon), weapon, playRaise: false);
                p.Fov = p.LastFov = 90; p.ResumeZoom = false;
                p.CanChangeBag = canChangeBagAtSpawn && !infected;
                human.Physics.Position = new Vector3f(p.PosX, p.PosY, p.PosZ);
                human.Physics.Velocity = new Vector3f();
                human.Physics.ViewYaw = p.ViewYaw; human.Physics.ViewPitch = 0f; human.Physics.IsOnGround = true;
                human.LoadoutBounds = bsp.GetLoadoutBounds(spawn, z, freeForAll);
                officialPhysics.SetPlayerPosition(p.Id, p.PosX, p.PosY, p.PosZ);
                officialPhysics.SetPlayerDead(p.Id, false);
            }

            void ResetBioRound()
            {
                foreach (var player in allEntities)
                {
                    player.Team = BiohazardRound.HumanTeam;
                    player.BioWeaponEntityId = 0;
                    player.BioRespawnRemainingMs = null;
                    if (bioHumanRoles.Remove(player, out var role))
                    {
                        player.Career = role.Career;
                        player.CareerSkin = role.Skin;
                        player.HandName = role.Hand;
                        var def = tables.GetWeapon(role.Weapon);
                        PlayerLoadout.Equip(player, role.Bag, role.Slot, CarriedWeapon.FromConfig(role.Weapon, role.WeaponSkin, def), def);
                    }
                    player.MaxHp = 100;
                    if (botDirector.FindBot(player.Id) is { } bot) bot.Respawn();
                    else if (humans.TryGetValue(player.Id, out var human))
                    {
                        var spawn = bsp.PickSpawn(player.Team, (player.Id - 1) / 2, freeForAll);
                        ResetBioHumanAtSpawn(human, spawn, infected: false);
                    }
                    ApplyBioRoleToPhysics(player);
                }
                tcp.BroadcastScoreBoard(allEntities);
            }

            PlayerBasicInfo? Leader(Dictionary<int, int> counts) =>
                allEntities.Where(p => counts.GetValueOrDefault(p.Id) > 0)
                    .OrderByDescending(p => counts[p.Id]).ThenBy(p => p.Id).FirstOrDefault();

            void SendMvp()
            {
                var mvp = new LastMvpData();
                if (Leader(roundDamage) is { } damage)
                {
                    mvp.DamagePlayerName = damage.PlayerName;
                    mvp.DamageData = roundDamage[damage.Id];
                }
                if (Leader(roundKills) is { } kills)
                {
                    mvp.KillPlayerName = kills.PlayerName;
                    mvp.KillData = roundKills[kills.Id];
                }
                tcp.BroadcastLastMvp(mvp);
                assists.Clear();
                roundDamage.Clear();
                roundKills.Clear();
                streak.Clear();
                foreach (var human in humans.Values) human.LifeDamageDealt.Clear();
            }

            modeCoord.OnRoundEnded += SendMvp;
            modeCoord.OnRoundEnded += missileSys.Clear;

            void RemoveHuman(ClientSession session)
            {
                if (!humans.TryGetValue(session.PlayerId, out var removed) || removed.Session != session) return;
                humans.Remove(session.PlayerId);
                var player = removed.Player;
                allEntities.Remove(player);
                modeCoord.OnHumanRemoved(player, tcp);
                modeCoord.Biohazard?.RemovePlayer(player);
                bioHumanRoles.Remove(player);
                bioDamageScores.Remove(player.Id);
                weaponDrops?.ReleaseOwner(player);
                positionHistory?.RemovePlayer(player.Id);
                officialPhysics.UnregisterEntity(session.PlayerId);
                skillSystem.RemovePlayer(session.PlayerId);
                missileSys.RemovePlayer(player.Id);
                assists.RemovePlayer(player.Id);
                roundDamage.Remove(player.Id);
                roundKills.Remove(player.Id);
                bestStreak.Remove(player.Id);
                streak.Remove(player.Id);
                foreach (var other in humans.Values) other.LifeDamageDealt.Remove(player.Id);
                if (!removedPlayerIds.Contains(session.PlayerId)) removedPlayerIds.Add(session.PlayerId);
                tcp.BroadcastPlayerLogout(player.Id, player.PlayerName, player.Team, isBot: false);
                tcp.BroadcastScoreBoard(allEntities);
                if (!cfg.Headless && cfg.MaxHumanPlayers <= 1 && clientHadSpawned)
                {
                    cts.Cancel();
                }
            }

            tcp.OnTcpUserCmd2Received += (session, content) => UdpSyncGateway.HandleTcpUserCmd2(session, content);
            tcp.OnTacticsSoundRequested += (session, ts) =>
            {
                rosterChanges.Enqueue(() =>
                {
                    if (!humans.TryGetValue(session.PlayerId, out var h) || h.Session != session) return;
                    bool isWoman = string.Equals(h.Player.HandName, "woman", StringComparison.OrdinalIgnoreCase)
                        || h.Player.Career.Contains("woman", StringComparison.OrdinalIgnoreCase)
                        || h.Player.Career.Contains("pandora", StringComparison.OrdinalIgnoreCase);
                    tcp.BroadcastTacticsSound(h.Player.Id, h.Player.PlayerName, ts.SoundId, isWoman);
                });
            };
            tcp.OnObserverTargetRequested += (session, targetId) =>
            {
                rosterChanges.Enqueue(() =>
                {
                    if (!humans.TryGetValue(session.PlayerId, out var viewer)) return;
                    var target = allEntities.Find(e => e.Id == targetId && !e.IsDead && (freeForAll || e.Team == viewer.Player.Team));
                    if (target == null) return;
                    Volatile.Write(ref session.ObserverTargetId, target.Id);
                    if (viewer.LastObserverTargetId != target.Id)
                    {
                        viewer.LastObserverTargetId = target.Id;
                        tcp.SendTo(session, 30, BuildObserverInfo(target));
                    }
                });
            };

            tcp.OnPlayerSpawned += session =>
            {
                rosterChanges.Enqueue(() =>
                {
                    clientHadSpawned = true;
                    removedPlayerIds.Remove(session.PlayerId);
                    if (humans.TryGetValue(session.PlayerId, out var prior))
                    {
                        RemoveHuman(prior.Session!);
                    }

                    var existingHumanSnaps = new List<PlayerBasicInfo>(humans.Count);
                    foreach (var existing in humans.Values) existingHumanSnaps.Add(existing.Player);

                    int humanTeam = modeCoord.Biohazard != null ? BiohazardRound.HumanTeam : session.Team;
                    var joining = CreateHuman(
                        cfg, tables, bsp, officialPhysics, skillSystem, modeCoord,
                        playerId: session.PlayerId, team: humanTeam, characterId: session.CharacterId, session: session,
                        existingHumans: humans.Values, freeForAll: freeForAll, meleeOnly: meleeOnly, canChangeBagAtSpawn: canChangeBagAtSpawn);

                    if (modeCoord.Biohazard is { HasStarted: true } runningBio)
                    {
                        tcp.SendTo(session, 13, new TimeData { Time = runningBio.RemainingMs(G_Combat.CurrentServerTimeMs) });
                        tcp.SendTo(session, 23, new IntData { Data = runningBio.GrowthLevel });
                    }

                    modeCoord.InitializeJoiningHuman(joining.Player, existingHumanSnaps);

                    int reliveMs = modeCoord.IsPve ? 1000
                        : modeCoord.IsExplode ? 0
                        : modeCoord.Biohazard != null ? cfg.Biohazard!.RespawnMs : 3000;
                    foreach (var existing in humans.Values)
                    {
                        if (existing.Session != null)
                        {
                            SendRosterEntry(tcp, existing.Session, joining.Player, joining.Player.CharacterId, isBot: false, reliveMs, modeCoord.IsPve, BuildObserverInfo);
                        }
                        SendRosterEntry(tcp, session, existing.Player, existing.Player.CharacterId, isBot: false, reliveMs, modeCoord.IsPve, BuildObserverInfo);
                    }
                    foreach (var b in botDirector.Agents)
                    {
                        SendRosterEntry(tcp, session, b.Snap, 100000L + b.Id, isBot: true, reliveMs, modeCoord.IsPve, BuildObserverInfo);
                    }
                    tcp.SendTo(session, 30, BuildObserverInfo(joining.Player));

                    humans[session.PlayerId] = joining;
                    allEntities.Add(joining.Player);

                    if (modeCoord.IsPve)
                    {
                        tcp.BroadcastPveScore(modeCoord.PveStageRemaining, modeCoord.WinScore, modeCoord.PveStage);
                    }
                    else
                    {
                        tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                    }
                    tcp.BroadcastScoreBoard(allEntities);
                    Console.WriteLine($"[SSJJ-Server] Human P{joining.Player.Id} ({joining.Player.PlayerName}, T{joining.Player.Team}, cid={joining.Player.CharacterId}, bag={joining.Player.CurrentBagId}, wpn={joining.Player.CurrentWeaponName}) entered arena.");
                });
            };
            tcp.OnPveGameWinReceived += () =>
            {
                if (modeCoord.IsPve)
                {
                    cts.Cancel();
                }
            };
            tcp.OnClientDisconnected += session => rosterChanges.Enqueue(() => RemoveHuman(session));

            G_Combat.InterceptDamage = null;
            if (modeCoord.Biohazard is { } bioMode)
            {
                G_Combat.InterceptDamage = (victim, attacker, weapon) =>
                {
                    if (!bioMode.IsActive) return true;
                    if (attacker == null || attacker.Team == victim.Team) return true;
                    if (!BiohazardRound.IsInfected(attacker))
                    {
                        bioMode.RecordHurt(victim.Id, G_Combat.CurrentServerTimeMs);
                        return false;
                    }
                    RecordHumanRole(victim);
                    if (bioMode.TryInfect(victim, attacker, weapon, out var lvUp))
                    {
                        EquipBioRole(victim);
                        modeCoord.Team1Kills++;
                        tcp.BroadcastBioMessage(BioMessageType.SUCCESSFULINFECTION, attacker.PlayerName, victim.PlayerName);
                        if (lvUp is { } up)
                        {
                            tcp.BroadcastBioLvUp(up.Lv, up.AddHp);
                            tcp.BroadcastBioMessage(BioMessageType.DOUNLV2, attacker.PlayerName);
                        }
                    }
                    return true;
                };
            }

            G_Combat.OnHitConfirmed += evt =>
            {
                if (evt.AttackerId > 0 && evt.AttackerId != evt.VictimId && evt.Damage > 0)
                {
                    assists.RecordHit(evt.AttackerId, evt.VictimId);
                    roundDamage[evt.AttackerId] = roundDamage.GetValueOrDefault(evt.AttackerId) + evt.Damage;
                    if (humans.TryGetValue(evt.AttackerId, out var attacker))
                        attacker.LifeDamageDealt[evt.VictimId] = attacker.LifeDamageDealt.GetValueOrDefault(evt.VictimId) + evt.Damage;
                }
                pendingHits.Enqueue(evt);
                if (humans.TryGetValue(evt.AttackerId, out var shooter) && shooter.Session != null)
                {
                    tcp.SendHitPlayer(shooter.Session);
                    if (modeCoord.Biohazard is { IsActive: true } && cfg.Biohazard!.DamagePerPoint > 0
                        && evt.HealthDamage > 0 && !BiohazardRound.IsInfected(shooter.Player))
                    {
                        var score = bioDamageScores.GetValueOrDefault(shooter.Player.Id);
                        score.Damage += evt.HealthDamage;
                        int points = (int)(score.Damage / cfg.Biohazard.DamagePerPoint);
                        score.Damage %= cfg.Biohazard.DamagePerPoint;
                        while (points > 0)
                        {
                            int packetPoints = Math.Min(points, 10);
                            tcp.SendBioDamage(shooter.Session, BiohazardRound.EncodeDamageScore(ref score.Remainder, packetPoints));
                            points -= packetPoints;
                        }
                        bioDamageScores[shooter.Player.Id] = score;
                    }
                }
            };

            G_Combat.OnKillOccurred += evt =>
            {
                var killer = allEntities.Find(p => p.Id == evt.KillerId);
                var victim = allEntities.Find(p => p.Id == evt.VictimId);
                if (victim != null)
                {
                    if (!modeCoord.MatchOver && humans.ContainsKey(victim.Id)) weaponDrops?.DropOnDeath(victim);
                    positionHistory?.RemovePlayer(victim.Id);
                    victim.Deaths++;
                    officialPhysics.SetPlayerDead(victim.Id, true);
                }
                if (killer != null)
                {
                    killer.Kills++;
                    killer.Score += 100;
                    skillSystem.OnKillScored(killer);
                    if (cfg.Headless || cfg.MaxHumanPlayers > 1)
                    {
                        float dist = victim != null ? (float)Math.Sqrt(
                            Math.Pow(killer.PosX - victim.PosX, 2) +
                            Math.Pow(killer.PosY - victim.PosY, 2) +
                            Math.Pow(killer.PosZ - victim.PosZ, 2)) : 0f;
                        Console.WriteLine($"[SSJJ-Server][KILL] {killer.PlayerName}(T{killer.Team},{killer.CurrentWeaponName}) -> {victim?.PlayerName}(T{victim?.Team}) hs={evt.IsHeadshot} dist={dist:F0}cm");
                    }
                    tcp.BroadcastKillNotice(
                        killer.Id, killer.PlayerName,
                        victim?.Id ?? evt.VictimId, victim?.PlayerName ?? $"Player_{evt.VictimId}",
                        evt.WeaponName, killer.CurrentWeaponSkinName,
                        evt.IsHeadshot, killer.Kills,
                        killer.Team, victim?.Team ?? 2);
                }

                streak.Remove(evt.VictimId);
                assists.AwardForKill(killer?.Id ?? 0, evt.VictimId, allEntities, 0, credited =>
                {
                    if (humans.TryGetValue(credited.Id, out var assistant) && assistant.Session != null)
                    {
                        tcp.NotifyAssist(assistant.Session);
                    }
                });
                if (killer != null && killer.Id != evt.VictimId)
                {
                    roundKills[killer.Id] = roundKills.GetValueOrDefault(killer.Id) + 1;
                    int current = streak[killer.Id] = streak.GetValueOrDefault(killer.Id) + 1;
                    bestStreak[killer.Id] = Math.Max(current, bestStreak.GetValueOrDefault(killer.Id));
                }

                modeCoord.OnEntityKilled(killer, victim, tcp, allEntities, evt.WeaponName);

                if (humans.TryGetValue(evt.VictimId, out var fallen) && fallen.LifeDamageDealt.Count > 0 && fallen.Session != null)
                {
                    var lifeDamageDealt = fallen.LifeDamageDealt;
                    var dmgEntries = new List<DamageData>(lifeDamageDealt.Count);
                    foreach (var kv in lifeDamageDealt)
                    {
                        var damaged = allEntities.Find(e => e.Id == kv.Key);
                        dmgEntries.Add(new DamageData
                        {
                            PlayerName = damaged?.PlayerName ?? $"Player_{kv.Key}",
                            Damage = kv.Value,
                            IsDead = damaged?.IsDead ?? false
                        });
                    }
                    tcp.BroadcastDamageCount(dmgEntries, fallen.Session);
                    lifeDamageDealt.Clear();
                }

                if (!modeCoord.IsPve)
                {
                    tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                }
                tcp.BroadcastScoreBoard(allEntities);

                foreach (var spectator in humans.Values)
                {
                    int observed = spectator.LastObserverTargetId;
                    if (!spectator.Player.IsDead || observed <= 0 || spectator.Session == null || (killer?.Id != observed && victim?.Id != observed)) continue;
                    var target = allEntities.Find(e => e.Id == observed);
                    if (target != null) tcp.SendTo(spectator.Session, 30, BuildObserverInfo(target));
                }
            };

            if (!cfg.Headless)
            {
                tcp.Start();
                udp.Start();
            }

            Console.WriteLine("[SSJJ-Server] Simulation loop started at 30 Hz (Ctrl+C to exit).");
            Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

            sw.Restart();
            double lastTime = 0.0;
            double snapshotAcc = 0.0;
            double scoreboardAcc = 0.0;
            double logAcc = 0.0;
            const double FixedDt = 1.0 / 60.0;

            while (!cts.IsCancellationRequested)
            {
                double now = sw.Elapsed.TotalSeconds;
                if (cfg.DurationSeconds > 0 && now >= cfg.DurationSeconds) break;

                double frameDt = now - lastTime;
                if (frameDt < FixedDt)
                {
                    Thread.Sleep(1);
                    continue;
                }
                lastTime = now;
                float dt = (float)Math.Clamp(frameDt, 0.005, 0.05);
                int curMs = (int)(now * 1000.0);
                G_Combat.CurrentServerTimeMs = curMs;

                while (rosterChanges.TryDequeue(out var change))
                {
                    change();
                }

                if (modeCoord.Biohazard != null && (humans.Count > 0 || cfg.Headless))
                {
                    foreach (var entity in allEntities)
                    {
                        if (!BiohazardRound.IsInfected(entity)) RecordHumanRole(entity);
                    }
                    modeCoord.TickBiohazard(curMs, allEntities, tcp, EquipBioRole, ResetBioRound, dt);
                }

                var humanList = new List<PlayerBasicInfo>(humans.Count);
                foreach (var human in humans.Values)
                {
                    humanList.Add(human.Player);
                    if (human.Session is { IsSpawned: true } session)
                    {
                        while (session.TryDequeueCommand(out var cmd))
                        {
                            if (cmd.Seq <= human.LastCmdSeq) continue;
                            human.LastCmdSeq = cmd.Seq;
                            session.LastCmdSequence = cmd.Seq;
                            if (cmd.LatestSnapSeq > 0 && session.Latency.Acknowledge(cmd.LatestSnapSeq, sw.ElapsedMilliseconds) is int rtt)
                            {
                                human.Player.PingMs = rtt;
                            }

                            int prevButtons = human.PrevButtons;
                            bool dropped = weaponDrops != null && !modeCoord.MatchOver
                                && (cmd.Buttons & (ButtonConstant.ThrowWeapon | ButtonConstant.Attack2)) == ButtonConstant.ThrowWeapon
                                && (prevButtons & ButtonConstant.ThrowWeapon) == 0
                                && weaponDrops.DropEquipped(human.Player);

                            if (!dropped && !modeCoord.IsWeaponMaster && !modeCoord.IsFlyKnife
                                && (modeCoord.Biohazard == null || !BiohazardRound.IsInfected(human.Player)))
                            {
                                ApplyWeaponSlotSwitch(cfg, tables, human, cmd, meleeOnly);
                            }
                            else if (modeCoord.IsExplode && cmd.WeaponSlot == 5 && human.Player.HasC4)
                            {
                                ApplyWeaponSlotSwitch(cfg, tables, human, cmd, meleeOnly);
                            }

                            bool isDefusing = modeCoord.IsPlayerDefusingC4(human.Player, cmd);
                            float cmdDt = Math.Clamp(cmd.FrameInterval, 1, 100) / 1000f;
                            modeCoord.HandlePlayerExplodeCommand(human.Player, cmd, prevButtons, cmdDt, tcp);
                            skillSystem.ProcessCommand(human.Player, cmd, prevButtons, now, freeForAll, isDefusing, allEntities, tcp);

                            if (human.Player.IsDead && !modeCoord.IsPve)
                            {
                                bool nextObs = (cmd.Buttons & ButtonConstant.Attack) != 0 && (prevButtons & ButtonConstant.Attack) == 0;
                                bool prevObs = (cmd.Buttons & ButtonConstant.Attack2) != 0 && (prevButtons & ButtonConstant.Attack2) == 0;
                                if (nextObs || prevObs)
                                {
                                    var candidates = allEntities.Where(e => e.Id != human.Player.Id && !e.IsDead && (freeForAll || e.Team == human.Player.Team)).ToList();
                                    if (candidates.Count > 0)
                                    {
                                        int requested = Volatile.Read(ref session.ObserverTargetId);
                                        int curIdx = candidates.FindIndex(e => e.Id == (requested > 0 ? requested : human.LastObserverTargetId));
                                        int step = nextObs ? 1 : -1;
                                        int nextIdx = curIdx < 0 ? 0 : (curIdx + step + candidates.Count) % candidates.Count;
                                        Volatile.Write(ref session.ObserverTargetId, candidates[nextIdx].Id);
                                    }
                                }
                            }

                            if (!human.Player.IsDead && (cmd.Buttons & ButtonConstant.Spray) != 0 && (prevButtons & ButtonConstant.Spray) == 0 && tcp.IsClientSpawned)
                            {
                                if (now < human.NextSprayAllowedSec)
                                {
                                    tcp.SendTo(session, 38, new SprayMessageData { Type = SprayMessageType.NOTIMETO });
                                }
                                else
                                {
                                    float eyeX = human.Player.PosX;
                                    float eyeY = human.Player.PosY;
                                    float eyeZ = human.Player.PosZ + human.Player.ViewHeight;
                                    float yawRad = cmd.Yaw * (float)Math.PI / 180f;
                                    float pitchRad = cmd.Pitch * (float)Math.PI / 180f;
                                    float cosP = (float)Math.Cos(pitchRad);
                                    float endX = eyeX + (float)Math.Cos(yawRad) * cosP * 220f;
                                    float endY = eyeY + (float)Math.Sin(yawRad) * cosP * 220f;
                                    float endZ = eyeZ - (float)Math.Sin(pitchRad) * 220f;
                                    if (weReady)
                                    {
                                        if (officialPhysics.TraceRayWithNormal(eyeX, eyeY, eyeZ, endX, endY, endZ, out _, out float hx, out float hy, out float hz, out float nx, out float ny, out float nz))
                                        {
                                            human.NextSprayAllowedSec = now + 5.0;
                                            tcp.BroadcastSprayEvent(new SprayEventEntityData
                                            {
                                                Id = SV_Snapshot.AllocTempEntityId(),
                                                ResTypeID = 100,
                                                IsAdd = true,
                                                PlayerName = human.Player.PlayerName,
                                                X = hx,
                                                Y = hy,
                                                Z = hz,
                                                NormalX = nx,
                                                NormalY = ny,
                                                NormalZ = nz,
                                                Yaw = cmd.Yaw
                                            });
                                        }
                                        else
                                        {
                                            tcp.SendTo(session, 38, new SprayMessageData { Type = SprayMessageType.DISTANCENOTENOUGH });
                                        }
                                    }
                                    else
                                    {
                                        human.NextSprayAllowedSec = now + 5.0;
                                        tcp.BroadcastSprayEvent(new SprayEventEntityData
                                        {
                                            Id = SV_Snapshot.AllocTempEntityId(),
                                            ResTypeID = 100,
                                            IsAdd = true,
                                            PlayerName = human.Player.PlayerName,
                                            X = eyeX + (float)Math.Cos(yawRad) * 100f,
                                            Y = eyeY + (float)Math.Sin(yawRad) * 100f,
                                            Z = human.Player.PosZ,
                                            NormalX = 0f,
                                            NormalY = 0f,
                                            NormalZ = 1f,
                                            Yaw = cmd.Yaw
                                        });
                                    }
                                }
                            }

                            int? shotTime = positionHistory == null ? null
                                : session.Latency.ResolveShotTime(cmd.RenderTime, curMs, PlayerPositionHistory.WindowMs);
                            StepLocalPlayer(human.Player, human.Physics, human.Weapon, missileSys, skillSystem, tcp, tables, officialPhysics, modeCoord,
                                weReady, cmd, prevButtons, freeForAll, allEntities, now, positionHistory, shotTime);
                            human.Player.CanChangeBag &= human.LoadoutBounds.Contains(human.Player.PosX, human.Player.PosY, human.Player.PosZ);
                            human.PrevButtons = cmd.Buttons;
                            session.PreviousButtons = cmd.Buttons;
                        }
                    }

                    human.Weapon.Tick(dt);

                    var p = human.Player;
                    if (p.IsDead)
                    {
                        G_Combat.AdvanceDeathClock(p, curMs);
                        officialPhysics.StepCorpse(p, (int)(dt * 1000f));
                        if (modeCoord.Biohazard is { } bio)
                        {
                            p.BioRespawnRemainingMs = bio.RespawnRemainingMs(p, (int)(curMs - p.TorsoAnimStartTime)) ?? 0;
                        }
                        if (modeCoord.Biohazard?.CanRespawn(p, curMs) == true)
                        {
                            var spawn = bsp.PickSpawn(p.Team, (p.Id - 1) / 2, freeForAll);
                            ResetBioHumanAtSpawn(human, spawn, infected: true);
                            tcp.BroadcastBioMessage(BioMessageType.RESURRECTION, p.PlayerName);
                        }
                        else if ((modeCoord.AllowRespawn || modeCoord.IsPve) && p.DeadTimerMs >= G_Combat.RespawnDelayMs)
                        {
                            var sp = bsp.PickSpawn(p.Team, (p.Id - 1) / 2, freeForAll);
                            float rx = sp.X, ry = sp.Y, rz = sp.Z;
                            if (weReady && officialPhysics.SampleGround(rx, ry, rz, out float g)) rz = g + 2f;
                            G_Combat.ResetSpawnAnimation(p);
                            p.Hp = p.MaxHp;
                            p.Zhuangjia = 100;
                            p.Hudun = 0;
                            p.LifeBarSeq++;
                            p.CanChangeBag = canChangeBagAtSpawn;
                            human.LoadoutBounds = bsp.GetLoadoutBounds(sp, rz, freeForAll);
                            p.PosX = rx; p.PosY = ry; p.PosZ = rz;
                            p.VelX = 0f; p.VelY = 0f; p.VelZ = 0f;
                            p.Velocity2D = 0f; p.Moving = false; p.OnGround = true;
                            p.DuckState = 3; p.DuckTime = 0; p.ViewHeight = 150f;
                            p.Stamina = 0f; p.PlayerStateFlag = 0; p.StateFlag = 0; p.GroundEntityNum = -1;
                            p.ViewYaw = p.MoveYaw = sp.Yaw;
                            p.PunchYaw = p.PunchPitch = p.DecayTime = 0;
                            p.RecoilRunUpMax = false;
                            p.Fov = p.LastFov = 90;
                            p.ResumeZoom = false;
                            if (weaponDrops != null)
                            {
                                var respawnBags = cfg.GetHumanBags(p.CharacterId);
                                int activeBag = Math.Clamp(cfg.GetHumanActiveBag(p.CharacterId), 1, respawnBags.Count);
                                var bagCfg = respawnBags[activeBag - 1];
                                int slot = meleeOnly ? 3 : 1;
                                string wName = bagCfg.GetSlotWeapon(slot);
                                if (string.IsNullOrWhiteSpace(wName)) wName = meleeOnly ? "dagger" : "m4a1";
                                string wSkin = bagCfg.GetSlotSkin(slot);
                                var wDef = tables.GetWeapon(wName);
                                var newLoadout = new PlayerLoadout(respawnBags, tables);
                                p.Loadout = newLoadout;
                                human.Loadout = newLoadout;
                                if (!newLoadout.Switch(p, activeBag, slot, slot, slot, tables, playRaise: false))
                                {
                                    PlayerLoadout.Equip(p, activeBag, slot, slot, CarriedWeapon.FromConfig(wName, wSkin, wDef), wDef, tables, playRaise: false);
                                }
                            }
                            human.Physics.Position = new Vector3f(rx, ry, rz);
                            human.Physics.Velocity = new Vector3f(0f, 0f, 0f);
                            officialPhysics.SetPlayerPosition(p.Id, rx, ry, rz);
                            officialPhysics.SetPlayerDead(p.Id, false);
                            human.LifeDamageDealt.Clear();
                        }
                    }
                }

                skillSystem.Tick(dt, now, allEntities, tcp);
                missileSys.Tick(dt, allEntities, officialPhysics);

                // Tick Bots & Game Mode only after client has finished loading and spawned (or in headless test mode)
                if (cfg.Headless || (tcp.IsClientSpawned && humanList.Count > 0))
                {
                    bool isBioMode = modeCoord.Biohazard != null;
                    for (int i = 0; i < botDirector.Agents.Count; i++)
                    {
                        var bot = botDirector.Agents[i];
                        if (modeCoord.Biohazard?.CanRespawn(bot.Snap, curMs) == true)
                        {
                            bot.Respawn();
                            bot.Snap.Zhuangjia = 0;
                            tcp.BroadcastBioMessage(BioMessageType.RESURRECTION, bot.Name);
                        }
                        float[]? obj = modeCoord.GetBotObjectiveFor(bot);
                        bot.Tick(dt, allEntities, modeCoord.AllowRespawn, obj, curMs, isBioMode);
                        officialPhysics.SetPlayerDead(bot.Id, bot.Snap.IsDead);
                    }

                    // Tick Game Mode (Explode C4 / Rounds / Mode state)
                    var modeExps = new List<GrenadeExplosionEventData>();
                    modeCoord.Tick(dt, humanList, botDirector, allEntities, tcp, modeExps);
                    foreach (var exp in modeExps) pendingExplosions.Enqueue(exp);
                    weaponDrops?.PickUp(allEntities, officialPhysics);
                }

                snapshotAcc += dt;
                if (!cfg.Headless && snapshotAcc >= 0.032)
                {
                    snapshotAcc = 0.0;
                    positionHistory?.Record(curMs, allEntities);
                    if (udp.HasClientEndpoint && tcp.IsClientSpawned)
                    {
                        var hits = DrainList(pendingHits, 16);
                        var exps = DrainList(pendingExplosions, 8);
                        var dels = modeCoord.DrainDeletedEntityIds();
                        if (removedPlayerIds.Count > 0)
                        {
                            dels.AddRange(removedPlayerIds);
                            removedPlayerIds.Clear();
                        }

                        IEnumerable<SceneWeaponDrop> sceneWeapons = modeCoord.GetSceneDrops().Concat(missileSys.FlyingWeapons);
                        if (weaponDrops != null) sceneWeapons = sceneWeapons.Concat(weaponDrops.SceneDrops);
                        var sceneDrops = sceneWeapons.ToArray();
                        var smokeClouds = missileSys.SmokeClouds.ToArray();
                        var bioBuffs = modeCoord.GetBioSceneBuffs();
                        var pveTowers = modeCoord.IsPve ? modeCoord.GetPveTowers() : null;

                        int snapSeq = seqId++;
                        long sentAtMs = sw.ElapsedMilliseconds;
                        var activeSessions = tcp.Sessions.Snapshot();
                        for (int sIdx = 0; sIdx < activeSessions.Length; sIdx++)
                        {
                            var tickSession = activeSessions[sIdx];
                            if (!tickSession.IsSpawned || tickSession.UdpEndPoint == null) continue;

                            int observerTargetId = 0;
                            if (humans.TryGetValue(tickSession.PlayerId, out var viewer))
                            {
                                if (viewer.Player.IsDead && !modeCoord.IsPve && viewer.Player.LegsAnimRemainMs == 0)
                                {
                                    var obsTarget = SelectObserverTarget(viewer, allEntities, freeForAll);
                                    if (obsTarget != null)
                                    {
                                        observerTargetId = obsTarget.Id;
                                        Volatile.Write(ref tickSession.ObserverTargetId, obsTarget.Id);
                                        if (viewer.LastObserverTargetId != obsTarget.Id)
                                        {
                                            viewer.LastObserverTargetId = obsTarget.Id;
                                            tcp.SendTo(tickSession, 30, BuildObserverInfo(obsTarget));
                                        }
                                    }
                                    else
                                    {
                                        viewer.LastObserverTargetId = 0;
                                    }
                                }
                                else if (!viewer.Player.IsDead)
                                {
                                    Volatile.Write(ref tickSession.ObserverTargetId, 0);
                                    viewer.LastObserverTargetId = 0;
                                }
                            }

                            byte[] snapBytes = SV_Snapshot.SerializeSnapshot(
                                snapSeq,
                                curMs,
                                tickSession.LastCmdSequence,
                                cfg,
                                tables,
                                allEntities,
                                sceneDrops,
                                exps,
                                hits,
                                dels.Count > 0 ? dels : null,
                                pveTowers: pveTowers,
                                observerTargetId: observerTargetId,
                                selfPlayerId: tickSession.PlayerId,
                                smokeClouds: smokeClouds,
                                sceneBuffs: bioBuffs);
                            if (udp.SendSnapshot(tickSession, snapBytes))
                            {
                                tickSession.Latency.RecordSent(snapSeq, sentAtMs);
                            }
                        }
                    }
                }

                scoreboardAcc += dt;
                if (scoreboardAcc >= 2.0)
                {
                    scoreboardAcc = 0.0;
                    if (tcp.IsClientSpawned)
                    {
                        tcp.BroadcastScoreBoard(allEntities);
                        if (modeCoord.IsPve)
                        {
                            tcp.BroadcastPveScore(modeCoord.PveStageRemaining, modeCoord.WinScore, modeCoord.PveStage);
                        }
                        else
                        {
                            tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                        }
                    }
                }

                if (modeCoord.MatchOver && !sentGameOver)
                {
                    sentGameOver = true;
                    gameOverElapsed = 0.0;
                    int winTeam = modeCoord.IsPve ? 1 : (modeCoord.Team1Score >= modeCoord.Team2Score ? 1 : 2);
                    string winnerName = winTeam == 1 ? "风暴联盟" : "雷霆战警";
                    Console.WriteLine($"[SSJJ-Server] Match win condition reached! Scores: T1={modeCoord.Team1Score} T2={modeCoord.Team2Score}");
                    if (tcp.IsClientSpawned)
                    {
                        tcp.BroadcastScoreBoard(allEntities);
                        if (modeCoord.IsPve)
                        {
                            tcp.BroadcastPveScore(0f, modeCoord.WinScore, modeCoord.PveStage);
                            tcp.BroadcastMissionResult(true, "");
                            tcp.BroadcastWin();
                            sentGameWin = true;
                        }
                        else
                        {
                            tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                            var leaders = allEntities.Where(p => p.Kills > 0).OrderByDescending(p => p.Kills)
                                .ThenBy(p => p.Id).Take(3).ToArray();
                            var best = new GroupBestKillData();
                            if (leaders.Length > 0) { best.Ace1 = leaders[0].PlayerName; best.AceNum1 = leaders[0].Kills; }
                            if (leaders.Length > 1) { best.Ace2 = leaders[1].PlayerName; best.AceNum2 = leaders[1].Kills; }
                            if (leaders.Length > 2) { best.Ace3 = leaders[2].PlayerName; best.AceNum3 = leaders[2].Kills; }
                            if (Leader(bestStreak) is { } bestPlayer) { best.BestKill = bestPlayer.PlayerName; best.BestNum = bestStreak[bestPlayer.Id]; }
                            tcp.BroadcastGroupBest(best);
                            if (!modeCoord.IsExplode && modeCoord.Biohazard == null) SendMvp();
                            foreach (var h in humans.Values)
                            {
                                if (h.Session == null || !h.Session.IsSpawned || modeCoord.Biohazard != null) continue;
                                bool won = freeForAll
                                    ? allEntities.TrueForAll(e => e.Id == h.Player.Id || e.Kills <= h.Player.Kills)
                                    : h.Player.Team == winTeam;
                                tcp.SendMissionResult(h.Session, won, winnerName);
                            }
                            tcp.BroadcastSimpleProto(new SimpleProto { Key = 3 });
                        }
                    }
                }
                else if (sentGameOver && !sentGameWin)
                {
                    gameOverElapsed += dt;
                    if (gameOverElapsed >= 6.0)
                    {
                        sentGameWin = true;
                        if (tcp.IsClientSpawned)
                        {
                            tcp.BroadcastWin();
                        }
                    }
                }

                logAcc += dt;
                if (logAcc >= 5.0)
                {
                    logAcc = 0.0;
                    string botDiag = "";
                    if (cfg.Headless && botDirector.Agents.Count >= 2)
                    {
                        var b0 = botDirector.Agents[0];
                        var b1 = botDirector.Agents[botDirector.Agents.Count - 1];
                        botDiag = $" | b0=({b0.Snap.PosX:F0},{b0.Snap.PosY:F0},{b0.Snap.PosZ:F0},v={b0.Snap.Velocity2D}) bN=({b1.Snap.PosX:F0},{b1.Snap.PosY:F0},{b1.Snap.PosZ:F0},v={b1.Snap.Velocity2D})";
                    }
                    string humanDiag = "humans=0";
                    if (humanList.Count > 0)
                    {
                        var h0 = humanList[0];
                        humanDiag = $"humans={humanList.Count} P{h0.Id}=({h0.PosX:F0},{h0.PosY:F0},{h0.PosZ:F0},wpn={h0.CurrentWeaponName})";
                    }
                    Console.WriteLine($"[SSJJ-Server][TICK t={now:F1}s] seq={seqId} {humanDiag} score={modeCoord.Team1Score}:{modeCoord.Team2Score} bots={botDirector.Agents.Count}{botDiag}");
                }
            }

            tcp.Stop();
            udp.Stop();
            return 0;
        }

        private sealed class HumanRuntime
        {
            public required PlayerBasicInfo Player { get; init; }
            public required PlayerPhysicsState Physics { get; init; }
            public required G_Weapon Weapon { get; init; }
            public required PlayerLoadout Loadout { get; set; }
            public required SpawnBounds LoadoutBounds { get; set; }
            public ClientSession? Session { get; init; }
            public int LastCmdSeq { get; set; }
            public int PrevButtons { get; set; }
            public int LastObserverTargetId { get; set; }
            public double NextSprayAllowedSec { get; set; }
            public Dictionary<int, int> LifeDamageDealt { get; } = new();
        }

        private static HumanRuntime CreateHuman(
            ServerConfig cfg,
            GameTables tables,
            BspMapData bsp,
            OfficialPhysicsWorld officialPhysics,
            SkillAndVfxSystem skillSystem,
            ModeCoordinator modeCoord,
            int playerId,
            int team,
            long characterId,
            ClientSession? session,
            IEnumerable<HumanRuntime> existingHumans,
            bool freeForAll,
            bool meleeOnly,
            bool canChangeBagAtSpawn)
        {
            int teamSpawnIdx = 0;
            foreach (var existing in existingHumans)
            {
                if (freeForAll || existing.Player.Team == team) teamSpawnIdx++;
            }

            var pSpawn = bsp.PickSpawn(team, teamSpawnIdx, freeForAll);
            float pX = pSpawn.X, pY = pSpawn.Y, pZ = pSpawn.Z;
            if (officialPhysics.IsReady && officialPhysics.SampleGround(pX, pY, pZ, out float groundZ))
            {
                pZ = groundZ + 2f;
            }

            var bags = cfg.GetHumanBags(characterId);
            int activeBag = Math.Clamp(cfg.GetHumanActiveBag(characterId), 1, bags.Count);
            var activeBagCfg = bags[activeBag - 1];
            int startSlot = meleeOnly ? 3 : 1;
            string startWpn = activeBagCfg.GetSlotWeapon(startSlot);
            if (string.IsNullOrWhiteSpace(startWpn)) startWpn = meleeOnly ? "dagger" : "m4a1";
            string startSkin = activeBagCfg.GetSlotSkin(startSlot);
            var startDef = tables.GetWeapon(startWpn);
            string career = cfg.GetHumanCareer(characterId);
            string careerSkin = cfg.GetHumanCareerSkin(characterId);
            string handName = cfg.GetHumanHand(characterId);
            var loadout = new PlayerLoadout(bags, tables);

            var player = new PlayerBasicInfo
            {
                Id = playerId,
                CharacterId = characterId,
                Loadout = loadout,
                Team = team,
                PlayerName = cfg.GetHumanName(characterId, playerId),
                Career = string.IsNullOrWhiteSpace(career) ? "police" : career,
                CareerSkin = careerSkin ?? "",
                HandName = string.IsNullOrWhiteSpace(handName) ? "man" : handName,
                Hp = modeCoord.IsPve ? 1000 : 100,
                MaxHp = modeCoord.IsPve ? 1000 : 100,
                Zhuangjia = 100,
                Hudun = 0,
                IsBot = false,
                HasC4 = false,
                CurrentBagId = activeBag,
                CanChangeBag = canChangeBagAtSpawn,
                CurrentWeapon = startSlot,
                CurrentWeaponName = startWpn,
                CurrentWeaponSkinName = startSkin,
                CurrentWeaponIndex = startSlot,
                CurrentClip = startDef.MaxClip,
                MaxClip = startDef.MaxClip,
                CurrentCarryClip = startDef.MaxCarryClip,
                WeaponAccuracy = startDef.DefaultAccuracy,
                PosX = pX,
                PosY = pY,
                PosZ = pZ,
                ViewYaw = pSpawn.Yaw,
                MoveYaw = pSpawn.Yaw,
                ViewPitch = 0f,
                MovePitch = 0f,
                ViewHeight = 150f,
                DuckState = 3,
                OnGround = true,
                Alpha = 1f,
                SelfAlpha = 1f,
                Fov = 90,
                LastFov = 90,
                LegsAnim = 7,
                ViewAnim = 13,
                ViewAnimSpeed = 1f,
                LeftViewAnim = 13,
                LeftViewAnimSpeed = 1f,
                TorsoAnim = 13
            };
            if (!loadout.Switch(player, activeBag, startSlot, startSlot, startSlot, tables, playRaise: false))
            {
                PlayerLoadout.Equip(player, activeBag, startSlot, startSlot,
                    CarriedWeapon.FromConfig(startWpn, startSkin, startDef), startDef, tables, playRaise: false);
            }

            var phys = new PlayerPhysicsState
            {
                Position = new Vector3f(pX, pY, pZ),
                ViewYaw = pSpawn.Yaw,
                IsOnGround = true
            };
            officialPhysics.RegisterEntity(player.Id, player.Team, player.Career, false, pX, pY, pZ);
            skillSystem.ResetPlayer(player);

            return new HumanRuntime
            {
                Player = player,
                Physics = phys,
                Weapon = new G_Weapon(),
                Loadout = loadout,
                LoadoutBounds = bsp.GetLoadoutBounds(pSpawn, pZ, freeForAll),
                Session = session
            };
        }

        private static void SendRosterEntry(
            TcpBattleGateway tcp,
            ClientSession recipient,
            PlayerBasicInfo entity,
            long cid,
            bool isBot,
            int reliveMs,
            bool isPve,
            Func<PlayerBasicInfo, ObserverInfoData> buildObserverInfo)
        {
            tcp.SendTo(recipient, 9, new PlayerLoginData
            {
                Id = entity.Id,
                PlayerName = entity.PlayerName,
                Team = entity.Team,
                CharacterId = cid,
                IsObserver = false,
                IsBot = isBot,
                CurKillNum = entity.Kills,
                VipLv = isBot ? 0 : 5,
                Show = isPve ? isBot : !isBot
            });
            tcp.SendTo(recipient, 61, new PlayerInfoData
            {
                Cid = cid,
                MaxReliveTime = reliveMs,
                CanReliveTime = reliveMs,
                ThirdModeNoViewChange = false,
                BagGoldWeaponNum = (!isBot && isPve) ? 3 : 0,
                NewPlayer = !isBot && isPve,
                CanUsingNewbieHelp = !isBot && isPve
            });
            tcp.SendTo(recipient, 30, buildObserverInfo(entity));
        }

        private static PlayerBasicInfo? SelectObserverTarget(HumanRuntime viewer, IReadOnlyList<PlayerBasicInfo> allEntities, bool freeForAll)
        {
            int requestedId = viewer.Session != null ? Volatile.Read(ref viewer.Session.ObserverTargetId) : 0;
            if (requestedId > 0 && requestedId != viewer.Player.Id)
            {
                for (int i = 0; i < allEntities.Count; i++)
                {
                    var c = allEntities[i];
                    if (c.Id == requestedId && !c.IsDead && (freeForAll || c.Team == viewer.Player.Team))
                        return c;
                }
            }
            for (int i = 0; i < allEntities.Count; i++)
            {
                var c = allEntities[i];
                if (c.Id != viewer.Player.Id && !c.IsDead && (freeForAll || c.Team == viewer.Player.Team))
                    return c;
            }
            if (freeForAll)
            {
                for (int i = 0; i < allEntities.Count; i++)
                {
                    var c = allEntities[i];
                    if (c.Id != viewer.Player.Id && !c.IsDead) return c;
                }
            }
            return null;
        }

        private static void ApplyWeaponSlotSwitch(ServerConfig cfg, GameTables tables, HumanRuntime human, DecodedUserCmd cmd, bool meleeOnly)
        {
            var p = human.Player;
            if (p.IsDead) return;
            var bags = cfg.GetHumanBags(p.CharacterId);
            int bagId = p.CanChangeBag && !p.IsDead && cmd.BagId >= 1 && cmd.BagId <= bags.Count
                ? cmd.BagId
                : p.CurrentBagId;
            int requestedSlot = cmd.WeaponSlot;
            int sourceSlot = requestedSlot;
            int slot;
            int weaponIndex;
            if (meleeOnly)
            {
                slot = 3;
                weaponIndex = 3;
                sourceSlot = 3;
            }
            else if (requestedSlot == 5)
            {
                var grenadeBag = bags[Math.Clamp(bagId - 1, 0, bags.Count - 1)];
                sourceSlot = FindNextThrowableSlot(grenadeBag, p.CurrentWeapon == 4 ? p.CurrentWeaponIndex : -1);
                if (sourceSlot == 0) return;
                slot = 4;
                weaponIndex = sourceSlot switch { 6 => 1, 7 => 2, _ => 0 };
            }
            else if (requestedSlot == 6)
            {
                if (!p.HasC4) return;
                slot = 5;
                weaponIndex = 5;
            }
            else if (requestedSlot == 0)
            {
                if (bagId == p.CurrentBagId) return;
                slot = 1;
                weaponIndex = 1;
                sourceSlot = 1;
            }
            else
            {
                if (requestedSlot is not ((>= 1 and <= 4) or 7)) return;
                slot = requestedSlot == 7 ? 4 : requestedSlot;
                weaponIndex = slot == 4 ? (requestedSlot == 7 ? 2 : 0) : slot;
                sourceSlot = requestedSlot;
            }

            if (bagId == p.CurrentBagId && slot == p.CurrentWeapon && weaponIndex == p.CurrentWeaponIndex) return;

            if (slot == 5)
            {
                if (p.HasC4)
                {
                    human.Loadout.SaveEquipped(p);
                    p.CurrentBagId = bagId;
                    p.CurrentWeapon = 5;
                    p.CurrentWeaponIndex = 5;
                    p.CurrentWeaponName = "c4";
                    p.CurrentWeaponSkinName = "";
                    p.CurrentClip = 1;
                    p.MaxClip = 1;
                    p.CurrentCarryClip = 0;
                    CombatAnimation.Equip(p, tables, tables.GetWeapon("c4"));
                }
                return;
            }

            human.Loadout.Switch(p, bagId, sourceSlot, slot, weaponIndex, tables);
        }

        private static int FindNextThrowableSlot(BagSlotConfig bag, int currentIndex)
        {
            for (int step = 1; step <= 3; step++)
            {
                int index = (currentIndex + step + 3) % 3;
                int slot = index switch { 1 => 6, 2 => 7, _ => 4 };
                if (!string.IsNullOrWhiteSpace(bag.GetSlotWeapon(slot))) return slot;
            }
            return 0;
        }

        private static void StepLocalPlayer(
            PlayerBasicInfo p,
            PlayerPhysicsState phys,
            G_Weapon wpn,
            G_Missile missileSys,
            SkillAndVfxSystem skillSystem,
            TcpBattleGateway tcp,
            GameTables tables,
            OfficialPhysicsWorld officialPhysics,
            ModeCoordinator modeCoord,
            bool weReady,
            DecodedUserCmd cmd,
            int prevButtons,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> allEntities,
            double nowSec,
            PlayerPositionHistory? positionHistory,
            int? shotTimeMs)
        {
            p.CmdSequence = cmd.Seq;
            // 客户端 PlayerClientTimePredictionSystem 每帧执行 clientTime.ClientTime += cmd.FrameInterval
            p.ClientTime += Math.Max(0, cmd.FrameInterval);

            // PlayerOrientationPredicationSystem ignores camera input while dead.
            if (p.IsDead) return;

            p.ViewYaw = cmd.Yaw;
            p.ViewPitch = cmd.Pitch;
            p.MovePitch = 0f;

            int rawFrameMs = Math.Clamp(cmd.FrameInterval, 0, 255);
            float dt = Math.Max(1, rawFrameMs) / 1000f;
            bool isForward = (cmd.Buttons & ButtonConstant.Forward) != 0;
            bool isBackward = (cmd.Buttons & ButtonConstant.Backward) != 0;
            bool isLeft = (cmd.Buttons & ButtonConstant.Left) != 0;
            bool isRight = (cmd.Buttons & ButtonConstant.Right) != 0;
            bool isJump = (cmd.Buttons & ButtonConstant.Jump) != 0;
            bool isDuck = (cmd.Buttons & ButtonConstant.Duck) != 0;
            bool isCtrl = (cmd.Buttons >> 31) == -1;
            bool isWalk = (cmd.Buttons & ButtonConstant.Switchwalk) != 0;
            bool isAttack = (cmd.Buttons & ButtonConstant.Attack) != 0;
            bool isAttack2 = (cmd.Buttons & ButtonConstant.Attack2) != 0;
            bool isAttack2Edge = isAttack2 && (prevButtons & ButtonConstant.Attack2) == 0;
            bool isReload = (cmd.Buttons & ButtonConstant.Reload) != 0 && (prevButtons & ButtonConstant.Reload) == 0;

            PlayerPredictionEngine.UpdateMoveYaw(p, cmd.Yaw, isForward, isBackward, isLeft, isRight);
            PlayerPredictionEngine.StepPunchAndDecay(p, Math.Max(1, rawFrameMs));

            var wDef = tables.GetWeapon(p.CurrentWeaponName);

            if (weReady)
            {
                // 与 PlayerMovePredicationSystem.DefaultDetermine -> CommonDetermine 顺序 1:1 对齐
                int stateFlag = p.StateFlag != 0 ? p.StateFlag : p.PlayerStateFlag;
                if ((stateFlag & 1073741824) != 0)
                {
                    p.Moving = false;
                }
                else
                {
                    if (isForward || isBackward || isLeft || isRight) p.Moving = true;
                    double preSpeed3d = Math.Sqrt((double)p.VelX * p.VelX + (double)p.VelY * p.VelY + (double)p.VelZ * p.VelZ);
                    if (p.Moving && preSpeed3d < 0.1) p.Moving = false;
                }

                int maxSpd = (int)MathF.Round(skillSystem.GetEffectiveMoveSpeed(p, wDef));
                var pyCmd = new ServerPyCmd
                {
                    Sequence = cmd.Seq,
                    FrameInterval = rawFrameMs,
                    MoveForward = 1014f * cmd.MoveForward * 0.25f,
                    MoveRight = 1014f * cmd.MoveRight * 0.25f,
                    IsForward = isForward,
                    IsBackward = isBackward,
                    IsLeft = isLeft,
                    IsRight = isRight,
                    IsJump = isJump,
                    IsDuck = isDuck,
                    IsCtrl = isCtrl,
                    IsWalk = isWalk,
                    CameraYaw = cmd.Yaw,
                    CameraPitch = cmd.Pitch
                };
                if (rawFrameMs > 0)
                {
                    officialPhysics.StepPlayer(p.Id, pyCmd, maxSpd);
                }
                if (officialPhysics.CopyPlayerState(p))
                {
                    PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(p, p.OnGround, p.DuckState, (int)p.Velocity2D, isWalk, isBackward, rawFrameMs);
                }
            }
            else
            {
                var qCmd = new UserCmd
                {
                    ForwardMove = cmd.MoveForward,
                    RightMove = cmd.MoveRight,
                    Jump = isJump,
                    Duck = isDuck,
                    Attack = isAttack,
                    Attack2 = isAttack2,
                    Yaw = cmd.Yaw,
                    Pitch = cmd.Pitch
                };
                G_Active.ClientThink(phys, p, qCmd, dt);
            }

            // Advance 1P ViewAnim chains (15/29/17->18, 31->30) and tick down TorsoAnimRemainMs
            // without resetting TorsoAnim=13 on Self (SV_Snapshot maps expired remote observers only).
            CombatAnimation.Advance(p, rawFrameMs, tables);

            // Shotgun uses interruptible shell-by-shell reload; other weapons use table-driven magazine reload.
            if (wDef.WeaponType == 6)
            {
                PlayerPredictionEngine.StepReload(p, wDef, isReload || (p.CurrentClip <= 0 && !p.IsStartReload), isAttack);
            }

            bool didFire = false;
            bool isMelee = p.CurrentWeapon == 3 || wDef.IsMelee;
            bool isMeleeSecondary = isAttack2 && (isMelee || wDef.HasMeleeSecondary);
            if (isAttack && wDef.IsThrowable && !wDef.Name.Equals("c4", StringComparison.OrdinalIgnoreCase)
                && p.CurrentClip > 0 && p.ClientTime >= p.NextAttackTimer)
            {
                p.CurrentClip = Math.Max(0, p.CurrentClip - Math.Max(1, wDef.ClipPerShot));
                p.NextAttackTimer = p.ClientTime + wDef.AttackIntervalMs;
                missileSys.SpawnGrenade(p, weaponName: wDef.Name, weaponType: wDef.WeaponType);
                p.ViewAnim = 23;
                p.LeftViewAnim = p.SpecialMode ? 23 : 13;
                p.ViewAnimSpeed = 1f;
                p.ViewAnimRemainMs = tables.GetViewAnimationDuration(wDef.Name, "TORSO_THROW");
                p.TorsoAnim = 23;
                p.TorsoAnimStartTime = G_Combat.CurrentServerTimeMs;
                p.TorsoAnimRemainMs = tables.GetTorsoAnimationDuration(p.Career, wDef, "TORSO_THROW");
                didFire = true;
            }
            else if ((isAttack || isMeleeSecondary) && !p.IsStartReload && p.ReloadEndTime == 0)
            {
                if (modeCoord.IsFlyKnife)
                {
                    if (p.ClientTime >= p.NextAttackTimer)
                    {
                        didFire = true;
                        p.NextAttackTimer = p.ClientTime + wDef.AttackIntervalMs;
                        CombatAnimation.StartAttack(p, tables, wDef, isMeleeSecondary);
                        modeCoord.TryFlyKnifeAttack(p, isAttack, isAttack2, allEntities);
                    }
                }
                else
                {
                    float dmgMul = skillSystem.GetEffectiveDamageMultiplier(p);
                    if (modeCoord.Biohazard is { } bioMode && !BiohazardRound.IsInfected(p))
                        dmgMul *= bioMode.GetHumanDamageMultiplier();
                    int effIntervalMs = skillSystem.GetEffectiveAttackIntervalMs(p, wDef);
                    float intervalScale = wDef.AttackIntervalMs > 0
                        ? (float)effIntervalMs / wDef.AttackIntervalMs
                        : 1f;
                    wpn.TryFireEx(p, phys, isAttack, isAttack2, tables, officialPhysics, freeForAll, allEntities,
                        out didFire, out _, positionHistory, shotTimeMs, dmgMul, intervalScale);
                    if (didFire)
                    {
                        if (isAttack2 && wDef.IsMelee)
                        {
                            skillSystem.TriggerMeleeHeavyDerived(p, wDef, nowSec, freeForAll, allEntities, tcp);
                        }
                        G_Weapon.ApplyPostFireState(p, tables, wDef, wDef.Name, isMelee || isMeleeSecondary, isMeleeSecondary,
                            (!isMelee && !isMeleeSecondary && effIntervalMs > 0) ? effIntervalMs : null);
                    }
                }
            }

            // Update ballistics spread, recoil punch, ShotsFired, and sniper zoom, while keeping
            // CombatAnimation's verified 1P/3P ViewAnim/LeftViewAnim/TorsoAnim states intact.
            PlayerPredictionEngine.StepSniperZoom(p, wDef, isAttack2Edge, didFire);
            if (didFire)
            {
                int savedView = p.ViewAnim;
                int savedViewRem = p.ViewAnimRemainMs;
                float savedViewSpd = p.ViewAnimSpeed;
                int savedLeftView = p.LeftViewAnim;
                float savedLeftSpd = p.LeftViewAnimSpeed;
                int savedTorso = p.TorsoAnim;
                float savedTorsoStart = p.TorsoAnimStartTime;
                int savedTorsoRem = p.TorsoAnimRemainMs;
                float savedNextAtk = p.NextAttackTimer;
                float savedNextSecAtk = p.NextSecondaryAttackTimer;
                int savedShots = p.ShotsFired;
                bool savedDelayFire = p.DelayFire;

                p.ShotsFired = Math.Max(0, savedShots - 1);
                PlayerPredictionEngine.StepWeaponIdleAndAccuracy(p, wDef, isAttack, fired: true, isSecondary: isMeleeSecondary);

                p.ShotsFired = savedShots;
                p.DelayFire = savedDelayFire;
                p.ViewAnim = savedView;
                p.ViewAnimRemainMs = savedViewRem;
                p.ViewAnimSpeed = savedViewSpd;
                p.LeftViewAnim = savedLeftView;
                p.LeftViewAnimSpeed = savedLeftSpd;
                p.TorsoAnim = savedTorso;
                p.TorsoAnimStartTime = savedTorsoStart;
                p.TorsoAnimRemainMs = savedTorsoRem;
                p.NextAttackTimer = savedNextAtk;
                p.NextSecondaryAttackTimer = savedNextSecAtk;
            }
            else if (!isAttack && !isAttack2)
            {
                PlayerPredictionEngine.StepWeaponIdleAndAccuracy(p, wDef, isAttackDown: false, fired: false, isSecondary: false);
            }

            if (wDef.WeaponType != 6)
            {
                CombatAnimation.TryStartReload(p, tables, wDef, isReload);
            }

            if (!isAttack && !isAttack2 && !isReload && (cmd.Buttons & ButtonConstant.Showgun) != 0
                && (prevButtons & ButtonConstant.Showgun) == 0)
            {
                PlayerPredictionEngine.TryInspectWeapon(p, wDef);
            }
        }

        private static List<T> DrainList<T>(ConcurrentQueue<T> q, int max)
        {
            var list = new List<T>();
            while (list.Count < max && q.TryDequeue(out var item)) list.Add(item);
            return list;
        }

        private static void RunTraceProbe(BspMapData bsp, OfficialPhysicsWorld phys)
        {
            Console.WriteLine($"[TRACE-PROBE] map={bsp.MapId} weReady={phys.IsReady} spawns={bsp.Spawns.Count} bombSites={bsp.BombSites.Count}");
            var sp0 = bsp.PickSpawn(1, 0, false);
            bool gOk = phys.SampleGround(sp0.X, sp0.Y, sp0.Z, out float gz);
            Console.WriteLine($"[TRACE-PROBE] Spawn0=({sp0.X:F1},{sp0.Y:F1},{sp0.Z:F1}) groundOk={gOk} groundZ={gz:F1}");
            bool clear = phys.TraceRayClear(sp0.X, sp0.Y, sp0.Z + 120f, sp0.X + 200f, sp0.Y, sp0.Z + 120f, out float frac);
            Console.WriteLine($"[TRACE-PROBE] Short forward ray clear={clear} fraction={frac:F3}");
        }
    }
}
