using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
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

            var pSpawn = bsp.PickSpawn(cfg.PlayerTeam, 0, freeForAll);
            float pX = pSpawn.X, pY = pSpawn.Y, pZ = pSpawn.Z;
            if (weReady && officialPhysics.SampleGround(pX, pY, pZ, out float groundZ))
            {
                pZ = groundZ + 2f;
            }

            int activeBagIdx = Math.Clamp(cfg.ActiveBag - 1, 0, cfg.Bags.Count - 1);
            var activeBag = cfg.Bags[activeBagIdx];
            int startSlot = meleeOnly ? 3 : 1;
            string startWpn = activeBag.GetSlotWeapon(startSlot);
            if (string.IsNullOrWhiteSpace(startWpn)) startWpn = meleeOnly ? "dagger" : "m4a1";
            string startSkin = activeBag.GetSlotSkin(startSlot);
            var startDef = tables.GetWeapon(startWpn);

            var localPlayer = new PlayerBasicInfo
            {
                Id = 1,
                Team = cfg.PlayerTeam,
                PlayerName = cfg.PlayerName,
                Career = string.IsNullOrWhiteSpace(cfg.Career) ? "police" : cfg.Career,
                CareerSkin = cfg.CareerSkin ?? "",
                HandName = string.IsNullOrWhiteSpace(cfg.Hand) ? "man" : cfg.Hand,
                Hp = 100,
                MaxHp = 100,
                Zhuangjia = 100,
                Hudun = 0,
                IsBot = false,
                HasC4 = ServerConfig.IsExplode(raceType) && cfg.PlayerTeam == 1,
                CurrentBagId = cfg.ActiveBag,
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
                LegsAnim = 7,
                ViewAnim = 13,
                ViewAnimSpeed = 1f,
                LeftViewAnim = 13,
                LeftViewAnimSpeed = 1f
            };
            var localPhysics = new PlayerPhysicsState
            {
                Position = new Vector3f(pX, pY, pZ),
                ViewYaw = pSpawn.Yaw,
                IsOnGround = true
            };
            var localWeapon = new G_Weapon();
            officialPhysics.RegisterEntity(localPlayer.Id, localPlayer.Team, localPlayer.Career, false, pX, pY, pZ);

            var botDirector = new BotDirector(cfg, tables, bsp, officialPhysics);
            botDirector.SpawnAll();

            var skillSystem = new SkillAndVfxSystem(tables, officialPhysics);
            skillSystem.ResetPlayer(localPlayer);
            foreach (var b in botDirector.Agents) skillSystem.ResetPlayer(b.Snap);

            var modeCoord = new ModeCoordinator(cfg, tables, bsp, officialPhysics);
            modeCoord.InitializeMatch(localPlayer, botDirector);

            var allEntities = new List<PlayerBasicInfo> { localPlayer };
            foreach (var b in botDirector.Agents) allEntities.Add(b.Snap);

            var tcp = new TcpBattleGateway(cfg, cfg.TcpPort, null, tables);
            var udp = new UdpSyncGateway(cfg.UdpPort);

            var pendingCmds = new ConcurrentQueue<DecodedUserCmd>();
            var pendingHits = new ConcurrentQueue<HitEventData>();
            var pendingExplosions = new ConcurrentQueue<GrenadeExplosionEventData>();

            int seqId = 1;
            int lastCmdSeq = 0;
            int prevButtons = 0;
            bool sentGameOver = false;
            bool sentGameWin = false;
            bool clientHadSpawned = false;
            double gameOverElapsed = 0.0;
            var sw = Stopwatch.StartNew();
            using var cts = new CancellationTokenSource();

            tcp.OnTcpUserCmd2Received += content => udp.HandleTcpUserCmd2(content);
            udp.OnUserCmdBatchReceived += batch =>
            {
                foreach (var c in batch) pendingCmds.Enqueue(c);
            };

            tcp.OnPlayerSpawned += () =>
            {
                clientHadSpawned = true;
                long localCid = cfg.CharId > 0 ? cfg.CharId : 1000200072528;
                tcp.BroadcastPlayerInfo(localCid);
                foreach (var b in botDirector.Agents)
                {
                    long botCid = 100000L + b.Id;
                    tcp.BroadcastPlayerLogin(b.Id, b.Name, b.Team, botCid, isBot: true);
                    tcp.BroadcastPlayerInfo(botCid);
                }
                tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                tcp.BroadcastScoreBoard(allEntities);
            };
            tcp.OnClientDisconnected += () =>
            {
                if (!cfg.Headless && clientHadSpawned)
                {
                    cts.Cancel();
                }
            };

            G_Combat.OnHitConfirmed += evt =>
            {
                pendingHits.Enqueue(evt);
                if (evt.AttackerId == 1)
                {
                    tcp.BroadcastHitPlayer();
                }
            };

            G_Combat.OnKillOccurred += evt =>
            {
                var killer = allEntities.Find(p => p.Id == evt.KillerId);
                var victim = allEntities.Find(p => p.Id == evt.VictimId);
                if (victim != null)
                {
                    victim.Deaths++;
                    victim.TorsoAnimStartTime = (float)sw.Elapsed.TotalMilliseconds;
                    officialPhysics.SetPlayerDead(victim.Id, true);
                }
                if (killer != null)
                {
                    killer.Kills++;
                    killer.Score += 100;
                    if (cfg.Headless)
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

                modeCoord.OnEntityKilled(killer, victim, tcp, allEntities);
                tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                tcp.BroadcastScoreBoard(allEntities);
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

                while (pendingCmds.TryDequeue(out var cmd))
                {
                    if (cmd.Seq <= lastCmdSeq) continue;
                    lastCmdSeq = cmd.Seq;

                    if (!modeCoord.IsWeaponMaster && !modeCoord.IsFlyKnife)
                    {
                        ApplyWeaponSlotSwitch(cfg, tables, localPlayer, cmd, meleeOnly);
                    }
                    else if (modeCoord.IsExplode && cmd.WeaponSlot == 5 && localPlayer.HasC4)
                    {
                        ApplyWeaponSlotSwitch(cfg, tables, localPlayer, cmd, meleeOnly);
                    }

                    bool isDefusing = modeCoord.IsPlayerDefusingC4(localPlayer, cmd);
                    modeCoord.HandlePlayerExplodeCommand(localPlayer, cmd, prevButtons, dt, tcp);
                    skillSystem.ProcessCommand(localPlayer, cmd, prevButtons, now, freeForAll, isDefusing, allEntities, tcp);
                    StepLocalPlayer(localPlayer, localPhysics, localWeapon, tables, officialPhysics, modeCoord, weReady, cmd, prevButtons, freeForAll, allEntities, now);
                    prevButtons = cmd.Buttons;
                }

                localWeapon.Tick(dt);
                skillSystem.Tick(dt, now, allEntities);

                if (localPlayer.IsDead)
                {
                    localPlayer.DeadTimer += dt;
                    if (modeCoord.AllowRespawn && localPlayer.DeadTimer >= G_Combat.RESPAWN_DELAY)
                    {
                        var sp = bsp.PickSpawn(localPlayer.Team, 0, freeForAll);
                        float rx = sp.X, ry = sp.Y, rz = sp.Z;
                        if (weReady && officialPhysics.SampleGround(rx, ry, rz, out float g)) rz = g + 2f;
                        localPlayer.IsDead = false;
                        localPlayer.Hp = localPlayer.MaxHp;
                        localPlayer.Zhuangjia = 100;
                        localPlayer.DeadTimer = 0f;
                        localPlayer.LifeBarSeq++;
                        localPlayer.PosX = rx; localPlayer.PosY = ry; localPlayer.PosZ = rz;
                        localPlayer.VelX = 0f; localPlayer.VelY = 0f; localPlayer.VelZ = 0f;
                        localPlayer.Velocity2D = 0f; localPlayer.Moving = false; localPlayer.OnGround = true;
                        localPlayer.DuckState = 3; localPlayer.DuckTime = 0; localPlayer.ViewHeight = 150f;
                        localPlayer.Stamina = 100f; localPlayer.LegsAnim = 7; localPlayer.TorsoAnim = 13; localPlayer.ViewAnim = 13;
                        localPhysics.Position = new Vector3f(rx, ry, rz);
                        officialPhysics.SetPlayerPosition(1, rx, ry, rz);
                    }
                }

                // Tick Bots (passing Explode objectives when applicable)
                int curMs = (int)(now * 1000.0);
                for (int i = 0; i < botDirector.Agents.Count; i++)
                {
                    var bot = botDirector.Agents[i];
                    float[]? obj = modeCoord.GetBotObjectiveFor(bot);
                    bot.Tick(dt, allEntities, modeCoord.AllowRespawn, obj, curMs);
                    officialPhysics.SetPlayerDead(bot.Id, bot.Snap.IsDead);
                }

                // Tick Game Mode (Explode C4 / Rounds / Mode state)
                var modeExps = new List<GrenadeExplosionEventData>();
                modeCoord.Tick(dt, localPlayer, botDirector, allEntities, tcp, modeExps);
                foreach (var exp in modeExps) pendingExplosions.Enqueue(exp);

                snapshotAcc += dt;
                if (!cfg.Headless && snapshotAcc >= 0.032)
                {
                    snapshotAcc = 0.0;
                    if (udp.HasClientEndpoint && tcp.IsClientSpawned)
                    {
                        var hits = DrainList(pendingHits, 16);
                        var exps = DrainList(pendingExplosions, 8);
                        byte[] snapBytes = SV_Snapshot.SerializeSnapshot(
                            seqId++,
                            (int)(now * 1000.0),
                            lastCmdSeq,
                            cfg,
                            tables,
                            allEntities,
                            modeCoord.GetSceneDrops(),
                            exps,
                            hits);
                        udp.SendSnapshot(snapBytes);
                    }
                }

                scoreboardAcc += dt;
                if (scoreboardAcc >= 2.0)
                {
                    scoreboardAcc = 0.0;
                    if (tcp.IsClientSpawned)
                    {
                        tcp.BroadcastScoreBoard(allEntities);
                        tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                    }
                }

                if (modeCoord.MatchOver && !sentGameOver)
                {
                    sentGameOver = true;
                    gameOverElapsed = 0.0;
                    int winTeam = modeCoord.Team1Score >= modeCoord.Team2Score ? 1 : 2;
                    bool localWon = freeForAll
                        ? allEntities.TrueForAll(e => e.Id == localPlayer.Id || e.Kills <= localPlayer.Kills)
                        : localPlayer.Team == winTeam;
                    string winnerName = winTeam == 1 ? "风暴联盟" : "雷霆战警";
                    Console.WriteLine($"[SSJJ-Server] Match win condition reached! Scores: T1={modeCoord.Team1Score} T2={modeCoord.Team2Score} localWon={localWon}");
                    if (tcp.IsClientSpawned)
                    {
                        tcp.BroadcastScoreBoard(allEntities);
                        tcp.BroadcastTeamScore(modeCoord.Team1Score, modeCoord.Team2Score, modeCoord.WinScore, modeCoord.Team1Kills, modeCoord.Team2Kills);
                        tcp.BroadcastMissionResult(localWon, winnerName);
                        tcp.BroadcastSimpleProto(new SimpleProto { Key = 3 });
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
                    Console.WriteLine($"[SSJJ-Server][TICK t={now:F1}s] seq={seqId} lastCmd={lastCmdSeq} pos=({localPlayer.PosX:F0},{localPlayer.PosY:F0},{localPlayer.PosZ:F0}) wpn={localPlayer.CurrentWeaponName} score={modeCoord.Team1Score}:{modeCoord.Team2Score} bots={botDirector.Agents.Count}{botDiag}");
                }
            }

            tcp.Stop();
            udp.Stop();
            return 0;
        }

        private static void ApplyWeaponSlotSwitch(ServerConfig cfg, GameTables tables, PlayerBasicInfo p, DecodedUserCmd cmd, bool meleeOnly)
        {
            int bagId = cmd.BagId >= 1 && cmd.BagId <= cfg.Bags.Count ? cmd.BagId : p.CurrentBagId;
            int slot = meleeOnly ? 3 : (cmd.WeaponSlot >= 1 && cmd.WeaponSlot <= 5 ? cmd.WeaponSlot : p.CurrentWeapon);

            if (bagId == p.CurrentBagId && slot == p.CurrentWeapon) return;

            if (slot == 5)
            {
                if (p.HasC4)
                {
                    p.CurrentBagId = bagId;
                    p.CurrentWeapon = 5;
                    p.CurrentWeaponIndex = 5;
                    p.CurrentWeaponName = "c4";
                    p.CurrentWeaponSkinName = "";
                    p.CurrentClip = 1;
                    p.MaxClip = 1;
                    p.CurrentCarryClip = 0;
                }
                return;
            }

            var bag = cfg.Bags[Math.Clamp(bagId - 1, 0, cfg.Bags.Count - 1)];
            string wpn = bag.GetSlotWeapon(slot);
            if (string.IsNullOrWhiteSpace(wpn)) return;
            string skin = bag.GetSlotSkin(slot);
            var def = tables.GetWeapon(wpn);

            p.CurrentBagId = bagId;
            p.CurrentWeapon = slot;
            p.CurrentWeaponIndex = slot;
            p.CurrentWeaponName = wpn;
            p.CurrentWeaponSkinName = skin;
            p.MaxClip = def.MaxClip;
            p.CurrentClip = p.MaxClip;
            p.CurrentCarryClip = def.MaxCarryClip;
            p.WeaponAccuracy = def.DefaultAccuracy;
            p.ShotsFired = 0;
            p.DecreaseShotsFired = 0;
            p.DelayFire = false;
        }

        private static float WrapAngle180(float angle)
        {
            while (angle > 180f) angle -= 360f;
            while (angle < -180f) angle += 360f;
            return angle;
        }

        private static void StepLocalPlayer(
            PlayerBasicInfo p,
            PlayerPhysicsState phys,
            G_Weapon wpn,
            GameTables tables,
            OfficialPhysicsWorld officialPhysics,
            ModeCoordinator modeCoord,
            bool weReady,
            DecodedUserCmd cmd,
            int prevButtons,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> allEntities,
            double nowSec)
        {
            p.CmdSequence = cmd.Seq;
            // 客户端 PlayerClientTimePredictionSystem 每帧执行 clientTime.ClientTime += cmd.FrameInterval
            p.ClientTime += Math.Max(0, cmd.FrameInterval);
            p.ViewYaw = cmd.Yaw;
            p.ViewPitch = cmd.Pitch;
            p.MovePitch = 0f;

            if (p.IsDead) return;

            int rawFrameMs = Math.Max(1, cmd.FrameInterval);
            float dt = rawFrameMs / 1000f;
            bool isForward = (cmd.Buttons & ButtonConstant.Forward) != 0;
            bool isBackward = (cmd.Buttons & ButtonConstant.Backward) != 0;
            bool isLeft = (cmd.Buttons & ButtonConstant.Left) != 0;
            bool isRight = (cmd.Buttons & ButtonConstant.Right) != 0;
            bool isJump = (cmd.Buttons & ButtonConstant.Jump) != 0;
            bool isDuck = (cmd.Buttons & ButtonConstant.Duck) != 0;
            bool isWalk = (cmd.Buttons & ButtonConstant.Switchwalk) != 0;
            bool isAttack = (cmd.Buttons & ButtonConstant.Attack) != 0;
            bool isAttack2 = (cmd.Buttons & ButtonConstant.Attack2) != 0;
            bool isReload = (cmd.Buttons & ButtonConstant.Reload) != 0 && (prevButtons & ButtonConstant.Reload) == 0;

            // 与 PlayerOrientationPredicationSystem.CaculateFinalMoveYaw 1:1 对齐
            if (isForward || isBackward || isLeft || isRight)
            {
                float finalMoveYaw = cmd.Yaw;
                if (isForward)
                {
                    if (isLeft) finalMoveYaw = cmd.Yaw + 45f;
                    else if (isRight) finalMoveYaw = cmd.Yaw - 45f;
                }
                else if (isBackward)
                {
                    if (isLeft) finalMoveYaw = cmd.Yaw + 135f;
                    else if (isRight) finalMoveYaw = cmd.Yaw - 135f;
                    else finalMoveYaw = cmd.Yaw + 180f;
                }
                else if (isLeft) finalMoveYaw = cmd.Yaw + 90f;
                else if (isRight) finalMoveYaw = cmd.Yaw - 90f;
                p.MoveYaw = WrapAngle180(finalMoveYaw);
            }

            var wDef = tables.GetWeapon(p.CurrentWeaponName);
            if (isReload && p.MaxClip > 0 && p.CurrentClip < p.MaxClip && p.CurrentCarryClip > 0)
            {
                int need = Math.Min(p.MaxClip - p.CurrentClip, p.CurrentCarryClip);
                p.CurrentClip += need;
                p.CurrentCarryClip -= need;
            }

            if (weReady)
            {
                int maxSpd = wDef.MaxSpeed;
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
                    IsWalk = isWalk,
                    CameraYaw = cmd.Yaw,
                    CameraPitch = cmd.Pitch
                };
                officialPhysics.StepPlayer(p.Id, pyCmd, maxSpd);
                if (officialPhysics.TryGetFullState(
                    p.Id,
                    out float px, out float py, out float pz,
                    out float vx, out float vy, out float vz,
                    out double vh, out int ds, out int dtime,
                    out bool og, out int gNum, out int v2d, out float stamina))
                {
                    p.PosX = px;
                    p.PosY = py;
                    p.PosZ = pz;
                    p.VelX = vx;
                    p.VelY = vy;
                    p.VelZ = vz;
                    p.ViewHeight = (float)vh;
                    p.DuckState = ds;
                    p.DuckTime = dtime;
                    p.OnGround = og;
                    p.GroundEntityNum = gNum;
                    p.Velocity2D = v2d;
                    p.Stamina = stamina;
                    // 与 PlayerMovePredicationSystem.CommonDetermine 对齐
                    double speed3d = Math.Sqrt((double)vx * vx + (double)vy * vy + (double)vz * vz);
                    if (isForward || isBackward || isLeft || isRight) p.Moving = true;
                    if (p.Moving && speed3d < 0.1) p.Moving = false;
                    // 与 LegPredictionUtility 对齐
                    if (p.Moving)
                    {
                        if (ds == 0) p.LegsAnim = isBackward ? 10 : 9;
                        else if (!isWalk && v2d > 305) p.LegsAnim = isBackward ? 2 : 1;
                        else p.LegsAnim = isBackward ? 4 : 3;
                    }
                    else
                    {
                        p.LegsAnim = ds == 0 ? 8 : 7;
                    }
                    if (og && v2d > 10) p.LegsSpeedAnimTime += rawFrameMs * (v2d / 250f);
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

            if (isAttack || isAttack2)
            {
                if (modeCoord.IsFlyKnife)
                {
                    modeCoord.TryFlyKnifeAttack(p, isAttack, isAttack2, allEntities);
                }
                else
                {
                    wpn.TryFire(p, phys, isAttack, isAttack2, tables, officialPhysics, freeForAll, allEntities);
                }
                if (p.TorsoAnim != 15)
                {
                    p.TorsoAnim = 15;
                    p.TorsoAnimStartTime = (float)(nowSec * 1000.0);
                }
                p.FireAnimEndTime = (float)nowSec + 0.22f;
            }
            else if (isReload)
            {
                if (p.TorsoAnim != 17)
                {
                    p.TorsoAnim = 17;
                    p.TorsoAnimStartTime = (float)(nowSec * 1000.0);
                }
                p.ReloadAnimEndTime = (float)nowSec + 1.4f;
            }
            else if (nowSec >= p.FireAnimEndTime && nowSec >= p.ReloadAnimEndTime && p.TorsoAnim != 13)
            {
                p.TorsoAnim = 13;
                p.TorsoAnimStartTime = (float)(nowSec * 1000.0);
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
