using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using SSJJ.Server.Bots;
using SSJJ.Server.Config;
using SSJJ.Server.GameModes;
using SSJJ.Server.Network;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;
using SSJJ.Server.Snapshot;
using SSJJUserCmd;
using WeaponDef = SSJJ.Server.Config.WeaponDef;

namespace SSJJ.Server.Tests
{
    internal static class Program
    {
        private static int _passed;
        private static int _failed;

        private static void Assert(bool cond, string name, string detail = "")
        {
            if (cond)
            {
                _passed++;
                Console.WriteLine($"[PASS] {name}");
            }
            else
            {
                _failed++;
                Console.WriteLine($"[FAIL] {name} {detail}");
            }
        }

        private static int Main()
        {
            Console.WriteLine("=== SSJJ-Server Full Unit, Animation, Combat & Mode Verification ===");

            var tables = new GameTables();
            string repoRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", ".."));
            tables.Load(repoRoot);

            // A. Main-branch death animation, attack animation, animation chains, bot cadence, and airborne corpse tests
            CheckFall(false, 2, 180f, 11, 19, 2033);
            CheckFall(true, 2, 180f, 11, 19, 2033);
            CheckFall(false, 1, 0f, 42, 42, 933);
            CheckFall(true, 1, 90f, 42, 42, 933);
            CheckFall(true, 1, 180f, 43, 43, 933);
            CheckAttackAnimation(tables);
            CheckAnimationChainsAndLoadout(tables);
            CheckBotFireCadence(tables);
            CheckAirborneCorpse();

            // Reset static state before running Module 1-4 tests
            G_Combat.GodModeEnabled = false;
            G_Combat.InterceptDamage = null;

            // B. Module 1-4 tests (prediction, ballistics, lag-comp, hitboxes, skills, biohazard, drops, multi-mode)
            var p = new PlayerBasicInfo { Id = 1, ClientTime = 1000 };
            PlayerPredictionEngine.AdvanceClientTime(p, 16);
            PlayerPredictionEngine.AdvanceClientTime(p, 17);
            Assert(p.ClientTime == 1033, "ClientTimePredication: exact FrameInterval accumulation");

            PlayerPredictionEngine.UpdateMoveYaw(p, 90f, true, false, true, false);
            Assert(Math.Abs(p.MoveYaw - 135f) < 0.11f, "OrientationPredication: W+A MoveYaw=135");
            PlayerPredictionEngine.UpdateMoveYaw(p, 170f, false, true, false, false);
            Assert(Math.Abs(p.MoveYaw - (-10f)) < 0.11f, "OrientationPredication: S MoveYaw wrap(-10)");

            p.DecayTime = 20;
            p.PunchPitch = -4.0f;
            p.PunchYaw = 3.0f;
            PlayerPredictionEngine.StepPunchAndDecay(p, 16);
            Assert(p.DecayTime == 4 && Math.Abs(p.PunchPitch - (-4.0f)) < 0.001f, "DecayPredication: holds punch while DecayTime > 0");
            PlayerPredictionEngine.StepPunchAndDecay(p, 16);
            Assert(p.DecayTime == 0, "DecayPredication: DecayTime reaches 0");
            PlayerPredictionEngine.StepPunchAndDecay(p, 100);
            float lenAfter = (float)Math.Sqrt(p.PunchYaw * p.PunchYaw + p.PunchPitch * p.PunchPitch);
            Assert(Math.Abs(lenAfter - 3.75f) < 0.02f, "PunchOrientationPredication: 1:1 linear+proportional decay", $"got {lenAfter:F3}");

            p.Moving = true;
            p.LegsAnim = 7;
            PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(p, true, 3, 500, false, false, 16);
            Assert(p.LegsAnim == 1 && p.LegsSpeedAnimTime == (int)(16f * (500f * 0.0016f)),
                "LegAnimPredication: state transition resets ScaledEclipsedTime and uses 0.0016*v2d");

            for (int frame = 1; frame < 120; frame++)
                PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(p, true, 3, 500, false, false, 16);
            Assert(p.LegsSpeedAnimTime == 1440f,
                "LegAnimPredication: 120 commands truncate per command (native int clock, no fractional drift)");

            var sniper = new WeaponDef { Name = "awm", WeaponType = 5, AttackIntervalMs = 1300, MaxClip = 10, DefaultAccuracy = 0.05f };
            p.Fov = 90; p.ClientTime = 2000;
            PlayerPredictionEngine.StepSniperZoom(p, sniper, secondaryPressed: true, fired: false);
            Assert(p.Fov == 40, "FovPredication: sniper zoom level 1 (40)");
            PlayerPredictionEngine.StepSniperZoom(p, sniper, secondaryPressed: true, fired: false);
            Assert(p.Fov == 15, "FovPredication: sniper zoom level 2 (15)");
            PlayerPredictionEngine.StepSniperZoom(p, sniper, secondaryPressed: false, fired: true);
            p.NextAttackTimer = 3300;
            Assert(p.Fov == 90 && p.LastFov == 15 && p.ResumeZoom, "FovPredication: fire unzooms & flags ResumeZoom");
            p.ClientTime = 3300;
            PlayerPredictionEngine.StepSniperZoom(p, sniper, secondaryPressed: false, fired: false);
            Assert(p.Fov == 15 && !p.ResumeZoom, "FovPredication: ResumeZoom restores LastFov after NextAttackTimer");

            var shotgun = new WeaponDef { Name = "m3", WeaponType = 6, MaxClip = 8, MaxCarryClip = 32, FireBullets = 8 };
            p.CurrentClip = 2; p.CurrentCarryClip = 16; p.MaxClip = 8; p.IsStartReload = false;
            PlayerPredictionEngine.StepReload(p, shotgun, reloadPressed: true, attackDown: false);
            Assert(p.IsStartReload && p.ViewAnim == 17, "ShotgunReload: starts shell reload");
            p.ClientTime += 450;
            PlayerPredictionEngine.StepReload(p, shotgun, reloadPressed: false, attackDown: false);
            Assert(p.CurrentClip == 3 && p.IsStartReload, "ShotgunReload: loads 1 shell & continues");
            PlayerPredictionEngine.StepReload(p, shotgun, reloadPressed: false, attackDown: true);
            Assert(!p.IsStartReload && p.ViewAnim == 13, "ShotgunReload: fire interrupts reload when Clip > 0");

            var rifle = new WeaponDef { Name = "m4a1", WeaponType = 1, AttackIntervalMs = 90, DefaultAccuracy = 0.2f };
            p.ShotsFired = 12; p.DelayFire = true; p.ClientTime = 5000;
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(p, rifle, isAttackDown: false, fired: false, isSecondary: false);
            Assert(p.ShotsFired == 8 && p.DecreaseShotsFired == 5150, "RifleIdleAction: caps ShotsFired=8 & sets +150ms");
            var pistol = new WeaponDef { Name = "deagle", WeaponType = 0, AttackIntervalMs = 200, DefaultAccuracy = 0.2f };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(p, pistol, isAttackDown: false, fired: false, isSecondary: false);
            Assert(p.ShotsFired == 0, "PistolIdleAction: resets ShotsFired=0 on release");

            var meleeUser = new PlayerBasicInfo { Id = 1, Team = 1, CurrentWeapon = 3, CurrentWeaponName = "dagger", PosX = 0, PosY = 0, PosZ = 0, ViewYaw = 0f, ViewPitch = -15f };
            var victim = new PlayerBasicInfo { Id = 2, Team = 2, PosX = 120, PosY = 0, PosZ = 0, ViewYaw = 0f, Hp = 100 };
            var wpn = new G_Weapon();
            bool hit = wpn.TryFire(meleeUser, null, true, false, null, null, false, new List<PlayerBasicInfo> { meleeUser, victim });
            Assert(hit && victim.IsDead, "MeleeBackstabHeadshot: backstab+headshot kills in 1 hit");

            var missile = new G_Missile();
            var expVictim = new PlayerBasicInfo { Id = 3, Team = 2, PosX = 100, PosY = 0, PosZ = 0, Hp = 100 };
            missile.SpawnGrenade(new PlayerBasicInfo { Id = 1, PosX = 0, PosY = 0, PosZ = 0, ViewYaw = 0, ViewPitch = 0 }, 40f);
            for (int t = 0; t < 160; t++) missile.Tick(0.02f, new List<PlayerBasicInfo> { expVictim }, null);
            Assert(expVictim.Hp < 100, "G_Missile: grenade gravity + fuse splash deals damage", $"hp={expVictim.Hp}");
            TestUtilityGrenades();

            using var phys = new OfficialPhysicsWorld();
            string[] heroWeapons = { "m4a1_legend2", "ak47_legend", "awm_legend", "axe_g", "nunchakus_legend2", "dagger", "taiyi_grenade2", "thunder_submachinegun_legend2", "hero_weapon_base", "sawed_pirate" };
            int resolved = 0;
            foreach (var hw in heroWeapons)
            {
                var def = tables.GetWeapon(hw);
                if (!string.IsNullOrEmpty(def.Name)) resolved++;
            }
            Assert(tables.WeaponCount >= 1400 && resolved == heroWeapons.Length, $"Tables & 10 Hero/Legendary Weapons resolved ({resolved}/{heroWeapons.Length}, total={tables.WeaponCount})");
            TestWeaponDrops(tables);
            TestObserverBag(tables);
            TestLoadoutAndInspect(tables);
            TestTableWeaponBallistics(tables);
            TestBiohazardRound();

            var adapter = new ServerPlayerPhysicsAdapter(1, 1, "police", false, 0f, 0f, 0f);
            Assert(Math.Abs(adapter.GetJumpHeight(681f) - 681f) < 0.01f && adapter.GetFlySpeed() == 0f && adapter.Stamina == 0f && Math.Abs(adapter.GetBeingHitFriction() - 16f) < 0.01f,
                "VanillaJumpHeight: GetJumpHeight(681)=681, GetFlySpeed=0, Stamina=0, BeingHitFriction=16");

            var jmp = new PlayerBasicInfo { Id = 1, LegsAnim = 7, Moving = false };
            PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(jmp, onGround: false, duckState: 3, velocity2D: 200, isWalk: false, isBackward: false, frameIntervalMs: 16);
            bool jmpTakeoff = jmp.LegsAnim == 5 && jmp.LegsSpeedAnimTime == 16f;
            for (int f = 0; f < 32; f++)
                PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(jmp, onGround: false, duckState: 3, velocity2D: 200, isWalk: false, isBackward: false, frameIntervalMs: 16);
            bool jmpLoop = jmp.LegsAnim == 340;
            PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(jmp, onGround: true, duckState: 3, velocity2D: 0, isWalk: false, isBackward: false, frameIntervalMs: 16);
            bool jmpLand = jmp.LegsAnim == 6;
            for (int f = 0; f < 20; f++)
                PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(jmp, onGround: true, duckState: 3, velocity2D: 0, isWalk: false, isBackward: false, frameIntervalMs: 16);
            bool jmpIdle = jmp.LegsAnim == 7;
            Assert(jmpTakeoff && jmpLoop && jmpLand && jmpIdle,
                "VanillaJumpAnimSequence: 5(jump) -> 340(jump_loop) -> 6(land) -> 7(idle)",
                $"takeoff={jmpTakeoff} loop={jmpLoop} land={jmpLand} idle={jmpIdle} last={jmp.LegsAnim}");

            var missShooter = new PlayerBasicInfo { Id = 1, Team = 1, CurrentWeapon = 1, CurrentWeaponName = "m4a1", CurrentClip = 30, MaxClip = 30, ClientTime = 1000 };
            var gunWpn = new G_Weapon();
            gunWpn.TryFireEx(missShooter, null, true, false, tables, null, false, new List<PlayerBasicInfo> { missShooter }, out bool gunDidFire, out bool gunHit);
            Assert(gunDidFire && !gunHit, "TryFireEx: reports didFire=true even when missing");

            var latency = new SnapshotLatencyTracker();
            latency.RecordSent(1, 700);
            latency.RecordSent(2, 1050);
            Assert(latency.Acknowledge(900, 1150) == null && latency.ResolveShotTime(1000, 1150, PlayerPositionHistory.WindowMs) == null,
                "Lag compensation requires a known snapshot acknowledgement");
            Assert(latency.Acknowledge(2, 1150) == 100
                && latency.ResolveShotTime(1000, 1150, PlayerPositionHistory.WindowMs) == 1000
                && latency.ResolveShotTime(1, 1150, PlayerPositionHistory.WindowMs) == 970
                && latency.ResolveShotTime(1200, 1150, PlayerPositionHistory.WindowMs) == 970
                && latency.ResolveShotTime(1000, 1551, PlayerPositionHistory.WindowMs) == null,
                "Lag compensation uses render time and bounds fallback by the snapshot clock and RTT");
            Assert(latency.ResolveShotTime(880, 1150, PlayerPositionHistory.WindowMs) == 880,
                "An original queued command may render over 130ms before its packet's snapshot acknowledgement");

            ServerConfig.Load(["--print-la", "--battle-host", "0.0.0.0"], out string? invalidBattleHost);
            Assert(invalidBattleHost != null, "A listener wildcard cannot be advertised in a client boot config");

            var history = new PlayerPositionHistory();
            var movingTarget = new PlayerBasicInfo { Id = 2, Team = 2, PosX = 200, Hp = 100 };
            history.Record(1000, new[] { movingTarget });
            movingTarget.PosY = 20;
            history.Record(1030, new[] { movingTarget });
            movingTarget.PosY = 150;
            history.Record(1060, new[] { movingTarget });
            Assert(history.TryGetPosition(2, 1015, out var earlier) && Math.Abs(earlier.Y - 10) < 0.001f,
                "Lag compensation interpolates between published positions");

            var rewindShooter = new PlayerBasicInfo { Id = 1, Team = 1, PosY = 10f, CurrentWeapon = 1, CurrentWeaponName = "m4a1", CurrentClip = 3, ViewHeight = 150 };
            var rewindTargets = new[] { movingTarget };
            new G_Weapon().TryFireEx(rewindShooter, null, true, false, null, null, false, rewindTargets, out _, out bool liveHit);
            new G_Weapon().TryFireEx(rewindShooter, null, true, false, null, null, false, rewindTargets,
                out _, out bool oldHit, history, 1015);
            Assert(!liveHit && oldHit && movingTarget.Hp < 100 && movingTarget.PosY == 150,
                "Delayed shot hits the historical target and applies damage without moving the live entity");

            history.RemovePlayer(2);
            history.Record(1090, new[] { new PlayerBasicInfo { Id = 2, PosX = 800 } });
            Assert(!history.TryGetPosition(2, 1030, out _) && history.TryGetPosition(2, 1090, out var replacementPosition)
                && replacementPosition.X == 800, "A reused player slot starts with clean position history");
            var stanceHistory = new PlayerPositionHistory();
            var stanceTarget = new PlayerBasicInfo { Id = 2, Team = 2, Career = "police", PosX = 220, DuckState = 3, Hp = 300, MaxHp = 300 };
            var stanceTargets = new[] { stanceTarget };
            stanceHistory.Record(2000, stanceTargets);
            stanceTarget.DuckState = 0;
            stanceHistory.Record(2030, stanceTargets);
            stanceTarget.DuckState = 2;
            stanceHistory.Record(2060, stanceTargets);

            bool ShotAtHeight(float muzzleZ, int? timestamp)
            {
                var shooter = new PlayerBasicInfo
                {
                    Id = 1, Team = 1, CurrentWeaponName = "m4a1", CurrentWeapon = 1,
                    CurrentClip = 1, ViewHeight = 150, PosZ = muzzleZ - 146
                };
                new G_Weapon().TryFireEx(shooter, null, true, false, null, null, false, stanceTargets,
                    out _, out bool shotHit, stanceHistory, timestamp);
                return shotHit;
            }

            Assert(ShotAtHeight(146, 2029) && !ShotAtHeight(146, 2030) && ShotAtHeight(96, 2030),
                "Historical standing and crouching shots use the discrete rendered stance, not the live stance");
            Assert(ShotAtHeight(40, 2059) && !ShotAtHeight(40, 2060) && !ShotAtHeight(40, null)
                && stanceTarget.DuckState == 2 && stanceTarget.PosZ == 0,
                "A duck jump raises the live and rewound lower hull without moving or reposing the target");
            stanceHistory.Record(2531, stanceTargets);
            Assert(!stanceHistory.TryGetTarget(2, 2030, out _) && stanceHistory.TryGetTarget(2, 2031, out var lastCrouched)
                && lastCrouched.MinZ == 0 && lastCrouched.MaxZ == 110,
                "The 500ms history cutoff keeps the earlier discrete stance for valid interpolation");

            var m4Def = tables.GetWeapon("m4a1");
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(missShooter, m4Def, isAttackDown: true, fired: gunDidFire, isSecondary: false);
            Assert(missShooter.ViewAnim == 15 && missShooter.TorsoAnim == 15 && missShooter.ViewAnimRemainMs == 233,
                "GunAttackAnim: ViewAnim=15, TorsoAnim=15, exact m4a1 ViewAnimRemainMs=233", $"remain={missShooter.ViewAnimRemainMs}");

            var knifeDef = tables.GetWeapon("dagger");
            var knifeUser = new PlayerBasicInfo { Id = 1, Team = 1, CurrentWeapon = 3, CurrentWeaponName = "dagger", ClientTime = 2000 };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(knifeUser, knifeDef, isAttackDown: true, fired: true, isSecondary: false);
            Assert(knifeUser.ViewAnim == 31 && knifeUser.TorsoAnim == 15 && knifeUser.ViewAnimRemainMs == 400,
                "MeleeLeftAnim: native float32 12 frames = 400ms", $"remain={knifeUser.ViewAnimRemainMs}");
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(knifeUser, knifeDef, isAttackDown: false, fired: true, isSecondary: true);
            Assert(knifeUser.ViewAnim == 20 && knifeUser.TorsoAnim == 15 && knifeUser.ViewAnimRemainMs == 1400,
                "MeleeRightAnim: native float32 42 frames = 1400ms", $"torso={knifeUser.TorsoAnim} remain={knifeUser.ViewAnimRemainMs}");

            G_Combat.CurrentServerTimeMs = 15432;
            var deadTarget = new PlayerBasicInfo
            {
                Id = 2, Team = 2, Hp = 20, LegsSpeedAnimTime = 12345f,
                TorsoAnim = 17, IsStartReload = true, ReloadEndTime = 16000,
                Moving = true, VelX = 200, VelY = -30, VelZ = 50, Velocity2D = 202
            };
            G_Combat.ApplyDamage(deadTarget, missShooter, 50, hitPart: 2, "m4a1", ignoreArmor: true);
            Assert(deadTarget.IsDead && deadTarget.LegsAnim == 11 && deadTarget.TorsoAnim == 19
                && deadTarget.LegsSpeedAnimTime == 0 && deadTarget.DeadTimer == 0
                && deadTarget.TorsoAnimStartTime == 15432 && deadTarget.LegsAnimRemainMs == 2033
                && !deadTarget.IsStartReload && deadTarget.ReloadEndTime == 0,
                "Body death resets both animation layers to the matching native fall");
            Assert(!deadTarget.Moving && deadTarget.VelX == 0 && deadTarget.VelY == 0
                && deadTarget.VelZ == 0 && deadTarget.Velocity2D == 0,
                "A moving victim stops driving the corpse orientation with its running state");
            G_Combat.AdvanceDeathClock(deadTarget, 15759);
            Assert(deadTarget.LegsSpeedAnimTime == 327 && Math.Abs(deadTarget.DeadTimer - 0.327f) < 0.0001f
                && deadTarget.LegsAnimRemainMs == 1706 && Math.Abs(deadTarget.TorsoAnimationTimer - 1.706f) < 0.0001f,
                "Death playback and remaining time share the same clock");
            G_Combat.AdvanceDeathClock(deadTarget, 18000);
            Assert(deadTarget.LegsAnim == 11 && deadTarget.TorsoAnim == 19
                && deadTarget.LegsAnimRemainMs == 0 && deadTarget.TorsoAnimationTimer == 0
                && deadTarget.IsDead, "A finished death clip keeps its final pose until respawn");

            foreach (var (yaw, x, y, expected) in new[]
            {
                (0f, 100f, 0f, 42), (0f, -100f, 0f, 43),
                (0f, 0f, 100f, 42), (0f, 0f, -100f, 42),
                (90f, 0f, -100f, 43), (90f, 0f, 100f, 42),
            })
            {
                var headshot = new PlayerBasicInfo { Id = 3, Team = 2, Hp = 20, ViewYaw = yaw };
                var attacker = new PlayerBasicInfo { Id = 1, Team = 1, PosX = x, PosY = y };
                G_Combat.ApplyDamage(headshot, attacker, 50, hitPart: 1, "m4a1", ignoreArmor: true);
                Assert(headshot.IsDead && headshot.LegsAnim == expected && headshot.TorsoAnim == expected
                    && headshot.LegsAnimRemainMs == 933,
                    $"Native headshot fall with victim yaw {yaw} and source ({x},{y}) uses state {expected}");
            }

            var legendM4 = tables.GetWeapon("m4a1_legend2");
            int legendDur = PlayerPredictionEngine.GetDefaultViewAnimDurationMs(legendM4, 15);
            Assert(legendDur == 366 && legendM4.HasMeleeSecondary, $"M4a1Legend2AnimAndBayonet: dur={legendDur}ms, hasMeleeSec={legendM4.HasMeleeSecondary}");
            Assert(PlayerPredictionEngine.GetDefaultViewAnimDurationMs(new WeaponDef
                { Name = "m4a1_missing_test", AnimationWeaponName = "m4a1" }, 15) == 0,
                "Missing first-person asset does not borrow another weapon's timing");
            var legendUser = new PlayerBasicInfo { Id = 1, Team = 1, CurrentWeapon = 1, CurrentWeaponName = "m4a1_legend2", ClientTime = 3000 };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(legendUser, legendM4, isAttackDown: false, fired: true, isSecondary: true);
            Assert(legendUser.ViewAnim == 20 && legendUser.TorsoAnim == 20, $"RifleMeleeRightAnim: ViewAnim={legendUser.ViewAnim}, TorsoAnim={legendUser.TorsoAnim}");

            var djAdapter = new ServerPlayerPhysicsAdapter(99, 1, "police", false, 0f, 0f, 0f);
            djAdapter.DuckState = 2;
            Assert(Math.Abs(djAdapter.GetCurrentMinZ() - 60.0) < 0.01 && djAdapter.IsUsingDuckJumpBrush(),
                $"DuckJumpBrush: minZ={djAdapter.GetCurrentMinZ()}, uses DuckJumpBrush");

            var botCfg = ServerConfig.Load(new[] { "--team", "2", "--ally-bots", "2", "--enemy-bots", "2", "--map", "map12" }, out _);
            botCfg.Career = "pandora_ct";
            botCfg.BotCareer = "ct_knight1_2";
            var botDir = new BotDirector(botCfg, tables, new BspMapData { MapId = 12 }, phys);
            botDir.SpawnAll();
            bool alliesPandoraCt = botDir.Agents.Count(b => b.Snap.Career == "pandora_ct") == 2;
            bool enemiesKnight1 = botDir.Agents.Count(b => b.Snap.Career == "ct_knight1") == 2;
            Assert(botDir.Agents.Count == 4 && alliesPandoraCt && enemiesKnight1,
                "BotDirector: preserves pandora_ct (woman anim) and remaps ct_knight1_2 -> ct_knight1");

            float ground = PlayerPhysicsState.FloorElevation;
            BotAgent CreateBot(string weapon) => new(
                200, 1, "Bot", "police", weapon, "", 2500f, 2500f, ground, 0f,
                tables, null, null, freeForAll: false, isMeleeOnly: false);
            PlayerBasicInfo CreateTarget(float x) => new()
                { Id = 201, Team = 2, PosX = x, PosY = 2500f, PosZ = ground, Hp = 10000 };
            var sniperBot = CreateBot("awp");
            var awpSpeed = tables.GetWeapon("awp");
            Assert(awpSpeed.GetMoveSpeed(90) == 446 && awpSpeed.GetMoveSpeed(40) == 380
                && awpSpeed.GetMoveSpeed(15) == 380, "AWP uses the two speed values in Weapon.json");
            var barrettSpeed = tables.GetWeapon("barrett_m107_g");
            Assert(barrettSpeed.GetMoveSpeed(90) == 480 && barrettSpeed.GetMoveSpeed(40) == 380
                && tables.GetWeapon("m4a1").GetMoveSpeed(90) == 550,
                "Sniper speed selection preserves per-weapon values and scalar rifle speed");
            var sniperTargets = new List<PlayerBasicInfo> { sniperBot.Snap, CreateTarget(4000f) };
            int sniperShots = 0;
            int fovAtShot = 90;
            sniperBot.Weapon.OnWeaponFired += _ => { sniperShots++; fovAtShot = sniperBot.Snap.Fov; };
            for (int i = 0; i < 20 && sniperBot.Snap.Fov == 90; i++)
                sniperBot.Tick(0.05f, sniperTargets, allowRespawn: false);
            Assert(sniperBot.Snap.Fov == 40 && sniperShots == 0 && sniperBot.Snap.PosX == 2500f,
                "Sniper bot holds position and scopes before firing");
            sniperBot.Tick(0.05f, sniperTargets, allowRespawn: false);
            Assert(sniperShots == 1 && fovAtShot == 40 && sniperBot.Snap.ResumeZoom
                && sniperBot.Snap.NextAttackTimer == sniperBot.Snap.ClientTime + tables.GetWeapon("awp").AttackIntervalMs,
                "Sniper bot fires scoped and uses the weapon table cooldown");
            sniperBot.Respawn();
            Assert(sniperBot.Snap.Fov == 90 && !sniperBot.Snap.ResumeZoom, "Sniper respawn clears scope state");

            var shotgunBot = CreateBot("m3");
            var shotgunTargets = new List<PlayerBasicInfo> { shotgunBot.Snap, CreateTarget(4000f) };
            int shotgunShots = 0;
            shotgunBot.Weapon.OnWeaponFired += _ => shotgunShots++;
            for (int i = 0; i < 5; i++) shotgunBot.Tick(0.05f, shotgunTargets, allowRespawn: false);
            Assert(shotgunBot.Snap.PosX > 2500f && shotgunShots == 0, "Shotgun bot closes distance before firing");
            shotgunTargets[1].PosX = shotgunBot.Snap.PosX + 240f;
            for (int i = 0; i < 5 && shotgunShots == 0; i++) shotgunBot.Tick(0.05f, shotgunTargets, allowRespawn: false);
            Assert(shotgunShots == 1, "Shotgun bot fires in close range");

            string[] missingFirstPersonWeapons = { "pveawp", "smaw_rpg", "botweapon", "acg_scar_legend", "zp_local_test" };
            foreach (var wpnName in missingFirstPersonWeapons)
            {
                var def = tables.GetWeapon(wpnName);
                int durRaise = PlayerPredictionEngine.GetDefaultViewAnimDurationMs(def, 16);
                int durFire = PlayerPredictionEngine.GetDefaultViewAnimDurationMs(def, 15);
                var pMissing = new PlayerBasicInfo
                {
                    Id = 1, Team = 1, CurrentWeapon = 1, CurrentWeaponName = wpnName,
                    CurrentClip = Math.Max(1, def.MaxClip), MaxClip = Math.Max(1, def.MaxClip),
                    CurrentCarryClip = def.MaxCarryClip, ClientTime = 1000
                };
                PlayerPredictionEngine.StepReload(pMissing, def, true, false);
                PlayerPredictionEngine.StepWeaponIdleAndAccuracy(pMissing, def, isAttackDown: false, fired: true, isSecondary: false);
                Assert(durRaise == 0 && durFire == 0 && pMissing.ViewAnimRemainMs == 0,
                    $"MissingFirstPersonAssetBoundary({wpnName}): durRaise={durRaise}, durFire={durFire}, remain={pMissing.ViewAnimRemainMs}");
            }

            var expCfg = new ServerConfig { Map = "2", RaceType = 2, PlayerTeam = 1 };
            expCfg.EnsureDefaults();
            var expMap = new BspMapData { MapId = 2 };
            expMap.BombSites.Add(new BspBombSite { X = 300, Y = 400, Z = 500 });
            var expMode = new ModeCoordinator(expCfg, tables, expMap, phys);
            var expGateway = new TcpBattleGateway(expCfg, 0, System.Net.IPAddress.Loopback, tables);
            var expPlanter = new PlayerBasicInfo
            {
                Id = 1, Team = 1, PlayerName = "Planter", PosX = 300, PosY = 400, PosZ = 500,
                HasC4 = true, CurrentWeapon = 5
            };
            var holdAttack = new DecodedUserCmd { Buttons = 64 };
            var releaseAttack = new DecodedUserCmd { Buttons = 0 };
            for (int i = 0; i < 60; i++) expMode.HandlePlayerExplodeCommand(expPlanter, holdAttack, 0, 0.03125f, expGateway);
            Assert(!expMode.C4Planted, "Partial plant < 3.0s does not plant C4");
            expMode.HandlePlayerExplodeCommand(expPlanter, releaseAttack, 64, 0.03125f, expGateway);
            for (int i = 0; i < 60; i++) expMode.HandlePlayerExplodeCommand(expPlanter, holdAttack, 0, 0.03125f, expGateway);
            Assert(!expMode.C4Planted, "Interrupted plant resets progress timer cleanly (1.875s + 1.875s interrupted != 3.0s)");
            for (int i = 0; i < 40 && !expMode.C4Planted; i++) expMode.HandlePlayerExplodeCommand(expPlanter, holdAttack, 0, 0.03125f, expGateway);
            Assert(expMode.C4Planted && expPlanter.CurrentWeapon == 1 && expPlanter.MaxClip == tables.GetWeapon("m4a1").MaxClip && expPlanter.CurrentClip == expPlanter.MaxClip,
                "Completing C4 plant restores primary weapon slot and magazine capacity");

            TestHitboxAndArmorSystem(tables, phys);
            TestSkillAndVfxSystem(tables, phys);
            TestBiohazardDeepAndAi(tables, phys);
            TestAllModeMultiplayer(tables, phys);

            Console.WriteLine($"=== SUMMARY: passed={_passed} failed={_failed} ===");
            return _failed == 0 ? 0 : 1;
        }

        private static void CheckFall(bool bot, int hitPart, float attackerBearing, int legs, int torso, int durationMs)
        {
            const int start = 45000;
            G_Combat.CurrentServerTimeMs = start;
            var victim = new PlayerBasicInfo
            {
                Id = 2, IsBot = bot, Hp = 1, Moving = true, Velocity2D = 350f, VelX = 350f,
                LegsSpeedAnimTime = 1234f, LegsAnim = 1, TorsoAnim = 15, ViewYaw = 0f
            };
            float bearing = attackerBearing * (MathF.PI / 180f);
            var attacker = new PlayerBasicInfo { PosX = MathF.Cos(bearing), PosY = MathF.Sin(bearing) };

            G_Combat.ApplyDamage(victim, attacker, 1, hitPart, "m4a1", ignoreArmor: true);
            Assert(victim.IsDead && victim.Hp == 0 && !victim.Moving && victim.VelX == 0f && victim.Velocity2D == 0f,
                "CheckFall: lethal damage stops motion");
            Assert(victim.LegsAnim == legs && victim.TorsoAnim == torso && victim.TorsoAnimStartTime == start,
                "CheckFall: both layers use expected death state and start time");
            Assert(victim.DeadTimerMs == 0 && victim.LegsSpeedAnimTime == 0f && victim.LegsAnimRemainMs == durationMs,
                "CheckFall: death starts at frame zero");

            G_Combat.AdvanceDeathClock(victim, start + 327);
            Assert(victim.DeadTimerMs == 327 && victim.LegsSpeedAnimTime == 327f && victim.LegsAnimRemainMs == durationMs - 327,
                "CheckFall: playback progress follows snapshot clock");
            G_Combat.AdvanceDeathClock(victim, start + durationMs + 50);
            Assert(victim.IsDead && victim.LegsAnim == legs && victim.TorsoAnim == torso && victim.LegsAnimRemainMs == 0,
                "CheckFall: retains final pose after clip finishes");

            G_Combat.CurrentServerTimeMs = start + G_Combat.RespawnDelayMs;
            G_Combat.ResetSpawnAnimation(victim);
            Assert(!victim.IsDead && victim.LegsAnim == 7 && victim.TorsoAnim == 13 && victim.DeadTimerMs == 0
                && victim.LegsSpeedAnimTime == 0f && victim.LegsAnimRemainMs == 0 && victim.TorsoAnimStartTime == G_Combat.CurrentServerTimeMs,
                "CheckFall: respawn clears death state on both layers");
        }

        private static void CheckAttackAnimation(GameTables tables)
        {
            var weapon = tables.GetWeapon("m4a1");
            var player = new PlayerBasicInfo { CurrentWeaponName = weapon.Name, ClientTime = 1500, CurrentClip = 4 };
            var gun = new G_Weapon();
            G_Combat.CurrentServerTimeMs = 2000;
            bool hit = gun.TryFire(player, null, true, false, tables, null, false, [], out bool fired);
            Assert(fired && !hit && player.CurrentClip == 3 && player.ViewAnim == 15 && player.ViewAnimRemainMs == 233
                && player.ViewAnimSpeed == 1f && player.TorsoAnim == 15 && player.TorsoAnimStartTime == 2000
                && player.NextAttackTimer == 1500 + weapon.AttackIntervalMs,
                "CheckAttackAnimation: missed shot starts both native animation channels");
            G_Combat.CurrentServerTimeMs += 40;
            player.ClientTime += 40;
            CombatAnimation.Advance(player, 40);
            gun.TryFire(player, null, true, false, tables, null, false, [], out fired);
            Assert(!fired && player.CurrentClip == 3 && player.ViewAnimRemainMs == 193 && player.TorsoAnimStartTime == 2000,
                "CheckAttackAnimation: holding fire advances animation without restarting");

            G_Combat.CurrentServerTimeMs = 2200;
            player.ClientTime = 1700;
            gun.TryFire(player, null, true, false, tables, null, false, [], out fired);
            Assert(fired && player.CurrentClip == 2 && player.ViewAnimRemainMs == 233 && player.TorsoAnimStartTime == 2200,
                "CheckAttackAnimation: second shot restarts clip once");
            player.CurrentClip = 0;
            player.CurrentCarryClip = 2;
            player.ClientTime += 300;
            CombatAnimation.Advance(player, 300);
            gun.TryFire(player, null, true, false, tables, null, false, [], out fired);
            Assert(!fired && player.CurrentClip == 0 && player.ViewAnim == 13, "CheckAttackAnimation: empty trigger cannot fire");
            CombatAnimation.TryStartReload(player, tables, weapon, requested: true);
            Assert(player.ViewAnim == 17 && player.ViewAnimRemainMs == 2500 && player.CurrentClip == 0,
                "CheckAttackAnimation: reload starts native animation");
            player.ClientTime += 2501;
            CombatAnimation.Advance(player, 2501);
            Assert(player.CurrentClip == 2 && player.CurrentCarryClip == 0 && player.ReloadEndTime == 0 && !player.IsStartReload,
                "CheckAttackAnimation: reload spends reserve ammo once");
        }

        private static void CheckAnimationChainsAndLoadout(GameTables tables)
        {
            var m4a1 = tables.GetWeapon("m4a1");
            var dagger = tables.GetWeapon("dagger");
            var cfg = new ServerConfig();
            cfg.EnsureDefaults();
            var loadout = new PlayerLoadout(cfg.Bags, tables);

            var mover = new PlayerBasicInfo
            {
                Id = 1, Career = "police", HandName = "man",
                LegsAnim = 1, Moving = true, CurrentBagId = 1,
                CurrentWeapon = 1, CurrentWeaponIndex = 1,
                CurrentWeaponName = "m4a1",
                CurrentClip = 1, MaxClip = m4a1.MaxClip, CurrentCarryClip = 30
            };
            G_Combat.CurrentServerTimeMs = 1000;
            CombatAnimation.StartAttack(mover, tables, m4a1, secondary: false);
            Assert(mover.ViewAnim == 15 && mover.ViewAnimRemainMs == 233 && mover.TorsoAnim == 15,
                "CheckAnimationChains: rifle fire starts ViewAnim=15 and TorsoAnim=15");
            CombatAnimation.Advance(mover, 233, tables);
            Assert(mover.ViewAnim == 18 && mover.ViewAnimRemainMs == 33,
                "CheckAnimationChains: rifle attack chains into TORSO_PULL_CHARGER (18)");
            CombatAnimation.Advance(mover, 33, tables);
            Assert(mover.ViewAnim == 13 && mover.ViewAnimRemainMs == 0,
                "CheckAnimationChains: finishes into TORSO_STAND (13)");
            Assert(mover.TorsoAnim == 15,
                "CheckAnimationChains: Self TorsoAnim retained without spurious reset");

            mover.CurrentClip = 0;
            CombatAnimation.StartAttack(mover, tables, m4a1, secondary: false);
            CombatAnimation.TryStartReload(mover, tables, m4a1, requested: false);
            Assert(mover.ViewAnim == 17 && mover.ReloadEndTime > 0 && mover.IsStartReload,
                "CheckAnimationChains: auto-reload on empty clip triggers during TORSO_ATTACK");

            loadout.Switch(mover, 1, 1, 1, 1, tables, playRaise: false);
            mover.CurrentClip = 12;
            mover.CurrentCarryClip = 45;
            Assert(loadout.Switch(mover, 1, 2, 2, 2, tables, playRaise: true), "CheckAnimationChains: switch to secondary");
            Assert(mover.ViewAnim == 16 && mover.TorsoAnim == 16,
                "CheckAnimationChains: weapon raise sets ViewAnim=16 and TorsoAnim=16");
            Assert(loadout.Switch(mover, 1, 1, 1, 1, tables, playRaise: true), "CheckAnimationChains: switch back to primary");
            Assert(mover.CurrentClip == 12 && mover.CurrentCarryClip == 45,
                "CheckAnimationChains: PlayerLoadout persists per-slot clip and reserve");

            Assert(loadout.Switch(mover, 1, 3, 3, 3, tables, playRaise: false), "CheckAnimationChains: switch to melee");
            CombatAnimation.StartAttack(mover, tables, dagger, secondary: false);
            Assert(mover.ViewAnim == 31 && mover.ViewAnimRemainMs == 400 && mover.TorsoAnim == 15,
                "CheckAnimationChains: dagger primary starts ViewAnim=31");
            CombatAnimation.Advance(mover, 400, tables);
            Assert(mover.ViewAnim == 30 && mover.ViewAnimRemainMs == 333,
                "CheckAnimationChains: dagger chains into TORSO_ATTACK_RAISE (30)");
            CombatAnimation.Advance(mover, 333, tables);
            Assert(mover.ViewAnim == 13 && mover.ViewAnimRemainMs == 0,
                "CheckAnimationChains: dagger recovery finishes at TORSO_STAND (13)");
        }

        private static void CheckBotFireCadence(GameTables tables)
        {
            var bot = new BotAgent(200, 1, "test", "police", "m4a1", "", 0f, 0f, 0f, 0f, tables, null, null, false, false);
            var target = new PlayerBasicInfo { Id = 1, Team = 2, PosX = 400f, Hp = 100000 };
            var fireAt = new List<int>();
            bot.Weapon.OnWeaponFired += _ => fireAt.Add(G_Combat.CurrentServerTimeMs);
            for (int time = 20; time <= 4000; time += 20)
            {
                G_Combat.CurrentServerTimeMs = time;
                bot.Tick(0.02f, [bot.Snap, target], false, serverTimeMs: time);
            }
            Assert(fireAt.Count >= 4 && fireAt[0] >= 280, $"CheckBotFireCadence: saw target >= 280ms before firing (first={fireAt.FirstOrDefault()}ms, count={fireAt.Count})");
            Assert(fireAt.Zip(fireAt.Skip(1)).Any(pair => pair.Second - pair.First >= 350), "CheckBotFireCadence: pauses >= 350ms between bursts");
        }

        private static void CheckAirborneCorpse()
        {
            const string client = @"D:\SSJJ-4399\battle\3_64";
            var bsp = BspMapData.Load(12, client);
            using var physics = new OfficialPhysicsWorld();
            Assert(physics.Initialize(12, bsp.RawBspBytes), "CheckAirborneCorpse: load native BSP collision world");
            var spawn = bsp.PickSpawn(1, 0, false);
            Assert(physics.SampleGround(spawn.X, spawn.Y, spawn.Z, out float ground), "CheckAirborneCorpse: sample floor");
            var bot = new PlayerBasicInfo { Id = 202, IsBot = true, Team = 1, Career = "police", Hp = 1 };
            physics.RegisterEntity(bot.Id, bot.Team, bot.Career, true, spawn.X, spawn.Y, ground + 155f);
            physics.StepPlayer(bot.Id, new ServerPyCmd { FrameInterval = 16, CameraYaw = spawn.Yaw }, 660);
            Assert(physics.CopyPlayerState(bot) && !bot.OnGround, "CheckAirborneCorpse: bot starts airborne");
            float deathZ = bot.PosZ;
            G_Combat.CurrentServerTimeMs = 2000;
            G_Combat.ApplyDamage(bot, new PlayerBasicInfo(), 1, 2, "m4a1", ignoreArmor: true);
            physics.SetPlayerDead(bot.Id, true);
            for (int elapsed = 16; elapsed <= 800; elapsed += 16)
            {
                G_Combat.AdvanceDeathClock(bot, G_Combat.CurrentServerTimeMs + elapsed);
                physics.StepCorpse(bot, 16);
            }
            Assert(bot.IsDead && bot.OnGround && bot.PosZ < deathZ - 100f && Math.Abs(bot.PosZ - ground) < 10f
                && bot.LegsAnim == 11 && bot.TorsoAnim == 19 && bot.DeadTimerMs == 800,
                "CheckAirborneCorpse: native Pmove brings airborne corpse to floor");
        }

        private static void TestWeaponDrops(GameTables tables)
        {
            using var softwarePhysics = new OfficialPhysicsWorld();
            var config = new ServerConfig();
            config.Bags.Add(new BagSlotConfig { PrimarySkin = "skin_m4_legend_poison" });
            config.EnsureDefaults();
            var drops = new WeaponDropSystem(tables);
            var owner = new PlayerBasicInfo { Id = 3, Loadout = new PlayerLoadout(config, tables), CurrentClip = 7, CurrentCarryClip = 19 };
            owner.Loadout.Switch(owner, 1, 2, tables);
            owner.Loadout.Switch(owner, 1, 1, tables);
            Assert(owner.CurrentClip == 7 && owner.CurrentCarryClip == 19, "Switching slots preserves the magazine and reserve");

            Assert(drops.DropEquipped(owner) && owner.CurrentWeapon == 2 && owner.Loadout.Get(1, 1) == null
                && drops.SceneDrops.Single().WeaponSkin == "skin_m4_legend_poison", "Dropping a rifle clears its slot and keeps its skin on the ground");
            drops.PickUp(new[] { owner }, softwarePhysics);
            Assert(drops.SceneDrops.Count() == 1 && owner.Loadout.Get(1, 1) == null,
                "Dropper must leave the pickup radius before reclaiming the weapon");

            var first = new PlayerBasicInfo { Id = 1, Loadout = new PlayerLoadout(config, tables) };
            var second = new PlayerBasicInfo { Id = 2, Loadout = new PlayerLoadout(config, tables) };
            first.Loadout.Switch(first, 1, 2, tables);
            second.Loadout.Switch(second, 1, 2, tables);
            first.Loadout.Remove(first, 1);
            second.Loadout.Remove(second, 1);
            drops.PickUp(new[] { second, owner, first }, softwarePhysics);
            Assert(first.Loadout.Get(1, 1) is { Clip: 7, Reserve: 19 } && second.Loadout.Get(1, 1) == null
                && !drops.SceneDrops.Any(), "Two simultaneous pickups award exactly one copy and preserve both ammo values");

            first.Loadout.Switch(first, 1, 1, tables);
            G_Combat.ApplyDamage(first, second, first.Hp, hitPart: 2, "m4a1", ignoreArmor: true);
            drops.DropOnDeath(first);
            drops.DropOnDeath(first);
            Assert(first.CurrentWeapon == 2 && first.Loadout.Get(first.CurrentBagId, first.CurrentWeapon) != null
                && first.ViewAnim == 13 && first.ViewAnimRemainMs == 0 && first.LegsAnim == 11 && first.TorsoAnim == 19,
                "Death drop leaves a valid current weapon for the camera without a raise animation");
            drops.PickUp(new[] { first, second }, softwarePhysics);
            Assert(first.Loadout.Get(1, 1) == null && second.Loadout.Get(1, 1) is { Clip: 7, Reserve: 19 }
                && !drops.SceneDrops.Any(), "Death drops the primary once and a living player can recover it");

            second.CurrentClip = 3;
            second.CurrentCarryClip = 14;
            Assert(drops.DropEquipped(second) && second.CurrentWeapon == 1 && second.Loadout.Get(1, 2) == null
                && drops.SceneDrops.Single().WeaponName == config.Bags[0].Secondary, "Dropping a sidearm switches to the carried primary");
            second.PosX = SceneWeaponDrop.PickupRadius + 1f;
            drops.PickUp(new[] { second }, softwarePhysics);
            second.PosX = 0;
            drops.PickUp(new[] { second }, softwarePhysics);
            Assert(second.Loadout.Get(1, 2) is { Clip: 3, Reserve: 14 } && !drops.SceneDrops.Any(),
                "The dropper can reclaim a sidearm with its original ammo after leaving the pickup radius");
        }

        private static void TestObserverBag(GameTables tables)
        {
            var config = new ServerConfig();
            config.EnsureDefaults();
            var self = new PlayerBasicInfo
            {
                Id = 1, IsDead = true, CurrentWeapon = 2, CurrentWeaponName = "deagle", CurrentClip = 2,
                Loadout = new PlayerLoadout(config, tables), HasC4 = true
            };
            self.Loadout.Remove(self, 1);
            var target = new PlayerBasicInfo
            {
                Id = 200, IsBot = true, CurrentBagId = 2, CurrentWeapon = 1,
                CurrentWeaponName = "ak47", CurrentClip = 9, CurrentCarryClip = 37
            };
            PlayerBasicInfo[] roster = [self, target];

            NetData.SnapshotData ReadHeader(int observer)
            {
                byte[] snapshot = SV_Snapshot.SerializeSnapshot(17, 200, 44, config, tables, roster, observerTargetId: observer);
                int length = System.Buffers.Binary.BinaryPrimitives.ReadInt32BigEndian(snapshot);
                return TcpBattleGateway.DeserializeProto<NetData.SnapshotData>(snapshot.AsSpan(4, length).ToArray())!;
            }

            var deathCamera = ReadHeader(0);
            var view = ReadHeader(target.Id);
            var active = view.BagList.Bags[1].FirstWeapon;
            Assert(view.Self == 1 && view.LastCmd == 44 && view.Observer == target.Id
                && view.BagList.C4Weapon == null && active is { WeaponName: "ak47", Clip: 9, CarryClip: 37 },
                "Observer snapshots carry the camera owner's active weapon and preserve the receiver's input acknowledgement");
            target.CurrentClip = 8;
            var reloaded = ReadHeader(target.Id).BagList.Bags[1].FirstWeapon;
            Assert(reloaded.Id == active.Id && reloaded.Clip == 8,
                "An observer weapon entity ID stays stable while only the camera owner's ammo changes");

            target.CurrentWeaponName = "m4a1";
            target.CurrentClip = 6;
            var switched = ReadHeader(target.Id).BagList.Bags[1].FirstWeapon;
            Assert(switched is { WeaponName: "m4a1", Clip: 6 } && switched.Id != active.Id,
                "An observed weapon change gets a new entity ID so the client refreshes WeaponInfo");

            var returned = ReadHeader(0);
            Assert(deathCamera.BagList.Bags[0].FirstWeapon == null
                && returned.BagList.Bags[0].SecondaryWeapon is { WeaponName: "deagle", Clip: 2 }
                && returned.BagList.C4Weapon != null
                && returned.BagList.Bags[0].SecondaryWeapon.Id == deathCamera.BagList.Bags[0].SecondaryWeapon.Id,
                "Returning to the receiver restores the same personal weapon IDs and C4");
        }

        private static void TestUtilityGrenades()
        {
            var missiles = new G_Missile();
            var detonations = new List<GrenadeExplosionEventData>();
            missiles.OnGrenadeExploded += detonations.Add;
            var thrower = new PlayerBasicInfo { Id = 1, PosZ = PlayerPhysicsState.FloorElevation };
            var nearby = new PlayerBasicInfo { Id = 2, PosX = 40f, PosZ = thrower.PosZ };
            var players = new[] { thrower, nearby };
            missiles.SpawnGrenade(thrower, speed: 40f, weaponName: "flashgrenade");
            var flight = missiles.FlyingWeapons.Single();
            int flightId = flight.Id;
            float spawnHeight = flight.Z;
            missiles.Tick(0.02f, players);
            Assert(flight.Id == flightId && flight.X > 0 && flight.Z > spawnHeight && flight.WeaponName == "flashgrenade",
                "Flying flash publishes the same entity with its weapon name and updated position");
            for (int tick = 0; tick < 140; tick++) missiles.Tick(0.02f, players);
            Assert(!missiles.FlyingWeapons.Any() && detonations.Single().EffectId == 8
                && nearby.Hp == nearby.MaxHp && !missiles.SmokeClouds.Any(),
                "Flash expires once and leaves HP and scene smoke unchanged");

            detonations.Clear();
            thrower.PosZ = PlayerPhysicsState.FloorElevation + 6000f;
            missiles.SpawnGrenade(thrower, speed: 40f, weaponName: "smoke");
            for (int tick = 0; tick < 130; tick++) missiles.Tick(0.02f, players);
            Assert(missiles.FlyingWeapons.Any() && !missiles.SmokeClouds.Any() && detonations.Count == 0,
                "Smoke waits for ground contact when its fuse expires in the air");
            for (int tick = 0; tick < 100; tick++) missiles.Tick(0.02f, players);
            Assert(!missiles.FlyingWeapons.Any() && missiles.SmokeClouds.Single().Position.Z == PlayerPhysicsState.FloorElevation
                && detonations.Single().EffectId == 1278 && nearby.Hp == nearby.MaxHp,
                "Smoke creates one grounded scene effect and does not deal blast damage");
            for (int tick = 0; tick <= G_Missile.SmokeDurationSec / 0.02f; tick++) missiles.Tick(0.02f, players);
            Assert(!missiles.SmokeClouds.Any(), "Smoke disappears from snapshots when the observed asset lifetime ends");
        }

        private static void TestTableWeaponBallistics(GameTables tables)
        {
            var m4 = tables.GetWeapon("m4a1");
            var standing = new PlayerBasicInfo { WeaponAccuracy = m4.DefaultAccuracy, OnGround = true, CmdSequence = 29 };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(standing, m4, true, true, false);
            Assert(Math.Abs(standing.WeaponAccuracy - 0.305f) < 0.0001f && Math.Abs(standing.PunchPitch - 0.65f) < 0.0001f
                && Math.Abs(standing.PunchYaw + 0.35f) < 0.0001f && standing.DecayTime == 0,
                "M4A1: first shot uses Weapon.json cubic accuracy and standing kickback");
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(standing, m4, true, true, false);
            Assert(Math.Abs(standing.WeaponAccuracy - 0.34f) < 0.0001f && Math.Abs(standing.PunchPitch - 1.8f) < 0.0001f,
                "M4A1: follow-up uses shot count for kickback and accuracy");

            var ak = tables.GetWeapon("ak47");
            var running = new PlayerBasicInfo { WeaponAccuracy = ak.DefaultAccuracy, OnGround = true, Velocity2D = 330f };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(running, ak, true, true, false);
            Assert(Math.Abs(running.PunchPitch - 1.5f) < 0.0001f && Math.Abs(running.WeaponAccuracy - 0.355f) < 0.0001f,
                "AK47: running kickback and cubic accuracy use its own row");

            var mp5 = tables.GetWeapon("mp5");
            var airborne = new PlayerBasicInfo { WeaponAccuracy = mp5.DefaultAccuracy, OnGround = false, ShotsFired = 3 };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(airborne, mp5, true, true, false);
            Assert(Math.Abs(airborne.WeaponAccuracy - (0.45f + 16f / 180f)) < 0.0001f
                && Math.Abs(airborne.PunchPitch - 2.12f) < 0.0001f,
                "MP5: airborne kickback and squared accuracy use its own row");

            var awp = tables.GetWeapon("awp");
            var scoped = new PlayerBasicInfo { WeaponAccuracy = awp.DefaultAccuracy, OnGround = true, Fov = 40 };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(scoped, awp, true, true, false);
            Assert(scoped.PunchPitch == 2f && scoped.WeaponAccuracy == awp.DefaultAccuracy && scoped.DecayTime == 0,
                "AWP: configured kickback and disabled accuracy progression");

            var deagle = tables.GetWeapon("deagle");
            var pistol = new PlayerBasicInfo { CurrentWeaponName = deagle.Name, CurrentWeapon = 2, CurrentClip = 7,
                MaxClip = 7, WeaponAccuracy = deagle.DefaultAccuracy, ClientTime = 1000 };
            var gun = new G_Weapon();
            gun.TryFireEx(pistol, null, true, false, tables, null, false, [], out bool first, out _);
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(pistol, deagle, true, first, false);
            gun.Tick(1f);
            pistol.ClientTime = (int)pistol.NextAttackTimer;
            gun.TryFireEx(pistol, null, true, false, tables, null, false, [], out bool held, out _);
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(pistol, deagle, false, false, false);
            bool retainedAccuracy = pistol.WeaponAccuracy == 0.92f;
            gun.TryFireEx(pistol, null, true, false, tables, null, false, [], out bool second, out _);
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(pistol, deagle, true, second, false);
            Assert(first && !held && retainedAccuracy && second && pistol.CurrentClip == 5 && pistol.PunchPitch == 6f
                && Math.Abs(pistol.WeaponAccuracy - 0.90125f) < 0.0001f,
                "Desert Eagle: click cadence, persistent accuracy, timed accuracy change and kickback");
        }

        private static void TestLoadoutAndInspect(GameTables tables)
        {
            var arena = new BspMapData();
            var origin = new BspSpawnPoint { X = 0f, Z = 120f, TeamFlag = 0 };
            arena.Spawns.Add(origin);
            arena.Spawns.Add(new BspSpawnPoint { X = 200f, Z = 120f, TeamFlag = 0 });
            arena.Spawns.Add(new BspSpawnPoint { X = 2000f, Z = 120f, TeamFlag = 1 });
            var zone = arena.GetLoadoutBounds(origin, 100f, freeForAll: false);
            Assert(zone.Contains(0, 0, 100) && zone.Contains(200, 0, 120)
                && !zone.Contains(2000, 0, 120) && !zone.Contains(0, 0, 500),
                "Opening loadout bounds include the team's spawn points and exclude other levels and teams");
            Assert(!arena.GetLoadoutBounds(origin, 100f, freeForAll: true).Contains(200, 0, 120),
                "Free-for-all loadout bounds use the player's own spawn");

            var weapon = tables.GetWeapon("m4a1_pro");
            var player = new PlayerBasicInfo { ViewAnim = 13, LeftViewAnim = 13, WeaponEffectLevel = 16, CurrentClip = 7 };
            Assert(PlayerPredictionEngine.TryInspectWeapon(player, weapon) && player.ViewAnim == 44
                && player.ViewAnimRemainMs == 4166 && player.LeftViewAnim == 13
                && player.CurrentClip == 7 && player.WeaponEffectLevel == 16,
                "Inspect animates the right hand with the measured clip duration and leaves ammo and effects alone");
            Assert(!PlayerPredictionEngine.TryInspectWeapon(player, weapon) && player.ViewAnimRemainMs == 4166,
                "An active inspection cannot restart itself");
            player.ViewAnim = 39;
            player.SpecialMode = true;
            Assert(PlayerPredictionEngine.TryInspectWeapon(player, weapon) && player.ViewAnim == 117,
                "A supported special-mode weapon uses its special inspection clip");
            player.ViewAnim = 13;
            player.SpecialMode = false;
            Assert(!PlayerPredictionEngine.TryInspectWeapon(player, tables.GetWeapon("m4a1")),
                "A weapon without an inspection clip stays idle");
            player.IsStartReload = true;
            Assert(!PlayerPredictionEngine.TryInspectWeapon(player, weapon) && player.ViewAnim == 13,
                "Inspect does not displace reload");
        }

        private static void TestBiohazardRound()
        {
            var settings = new BiohazardSettings { RoundMs = 25000, MotherHp = 240, InfectedHp = 180, RespawnMs = 1000, IntermissionMs = 2000 };
            var round = new BiohazardRound(settings, seed: 1);
            var players = new[] { new PlayerBasicInfo { Id = 1, Career = "police", Team = 2 },
                new PlayerBasicInfo { Id = 2, Career = "police", Team = 2 } };
            round.Begin(2000);
            Assert(round.SelectMother(16999, players) == null && !round.IsActive, "Biohazard waits for the native 15-second countdown");
            var mother = round.SelectMother(17000, players)!;
            var human = players.Single(p => p != mother);
            mother.CurrentWeapon = 3; mother.CurrentWeaponName = "doun_master";
            Assert(mother.Career == "doun_master" && mother.MaxHp == 240 && mother.Hp == 240 && mother.Team != human.Team
                && !round.TryInfect(human, mother, "grenade"), "Biohazard seeds one configured mother and rejects non-claw infection");
            mother.IsDead = true;
            mother.TorsoAnimStartTime = 18000;
            Assert(round.RecordKill(human, mother, melee: false) == NetData.BioMessageType.KILLBIO
                && round.GrowthLevel == 1 && !round.CanRespawn(mother, 18999)
                && round.CanRespawn(mother, 19000) && round.TryFinish(19000, players) == null,
                "A gun kill raises humanity growth and allows the infected to resurrect");
            mother.IsDead = false;
            Assert(round.TryInfect(human, mother, "doun_master") && human.Career == "doun" && human.Hp == 180
                && round.TryFinish(20000, players) == 1 && !round.IntermissionComplete(21999) && round.IntermissionComplete(22000),
                "Claw hit converts a living human and all infected end the round");
            foreach (var player in players) { player.Career = "police"; player.Team = 2; }
            round.Begin(22000);
            mother = round.SelectMother(37000, players)!;
            human = players.Single(p => p != mother);
            mother.IsDead = true;
            Assert(round.RecordKill(human, mother, melee: true) == NetData.BioMessageType.KNIFEKILL
                && !round.CanRespawn(mother, 38000) && round.TryFinish(38000, players) == 2,
                "A melee kill prevents resurrection, giving humanity the round when no infected remain");
            foreach (var player in players) { player.Career = "police"; player.IsDead = false; }
            round.Begin(42000);
            round.SelectMother(57000, players);
            Assert(round.TryFinish(66999, players) == null && round.TryFinish(67000, players) == 2
                && round.TryFinish(67001, players) == null, "A surviving human wins at the room deadline, exactly once");
            int remainder = 0;
            Assert(BiohazardRound.EncodeDamageScore(ref remainder, 9) == 9
                && BiohazardRound.EncodeDamageScore(ref remainder, 3) == 12
                && remainder == 2, "Method 26 uses the client's rollover score encoding");
        }

        private static void TestHitboxAndArmorSystem(GameTables tables, OfficialPhysicsWorld phys)
        {
            Assert(PlayerHitboxSystem.LoadedRigCount >= 7,
                $"Hitbox rigs loaded for extracted careers ({PlayerHitboxSystem.LoadedRigCount} >= 7)");

            string[] careerAliases = { "police", "pandora_ct", "pandora_t", "ct_knight1", "ct_knight1_2", "feihuwoman", "woman", "doun", "doun_master" };
            bool allRigsOk = true;
            foreach (var c in careerAliases)
            {
                var r = PlayerHitboxSystem.GetRig(c);
                if (r == null || r.Bones.Count < 15) allRigsOk = false;
            }
            Assert(allRigsOk, "PlayerHitboxSystem resolves all 7 native careers and fallback aliases");

            Assert(Math.Abs(PlayerHitboxSystem.ResolveBodyYaw(0f, 0f, true, 3) - 0f) < 0.01f
                && Math.Abs(Math.Abs(PlayerHitboxSystem.ResolveBodyYaw(0f, 180f, true, 3)) - 0f) < 0.01f
                && Math.Abs(PlayerHitboxSystem.ResolveBodyYaw(45f, 180f, true, 3) - 0f) < 0.01f
                && Math.Abs(PlayerHitboxSystem.ResolveBodyYaw(90f, 0f, false, 3) - 90f) < 0.01f
                && Math.Abs(PlayerHitboxSystem.ResolveBodyYaw(75f, 0f, true, 2) - 75f) < 0.01f,
                "ResolveBodyYaw follows OrientationAnimSystem forward/back/crouch rules");

            var standTarget = PlayerTargetState.Capture(new PlayerBasicInfo
            {
                Id = 901, Team = 2, Career = "police", PosX = 200f, PosY = 0f, PosZ = 0f, DuckState = 3, ViewHeight = 150f, Hp = 500
            });
            var fwd = new Vector3f(1f, 0f, 0f);
            bool hHead = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 0f, 146f), fwd, 1000f, standTarget, out _, out _, out _, out int pHead);
            bool hChest = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 0f, 134f), fwd, 1000f, standTarget, out _, out _, out _, out int pChest);
            bool hStomach = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 0f, 100f), fwd, 1000f, standTarget, out _, out _, out _, out int pStomach);
            bool hLeg = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 10f, 40f), fwd, 1000f, standTarget, out _, out _, out _, out int pLeg);
            bool hOtherLeg = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, -10f, 40f), fwd, 1000f, standTarget, out _, out _, out _, out int pOtherLeg);
            bool hMiss = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 0f, 185f), fwd, 1000f, standTarget, out _, out _, out _, out _);
            Assert(hHead && pHead == 1 && hChest && pChest == 2 && hStomach && pStomach == 3
                && hLeg && hOtherLeg && Math.Min(pLeg, pOtherLeg) == 6 && Math.Max(pLeg, pOtherLeg) == 7 && !hMiss,
                $"17-bone raycast reports separate leg groups (head={pHead}, chest={pChest}, stomach={pStomach}, legs={pLeg}/{pOtherLeg}, miss={!hMiss})");
            Assert(PlayerHitboxSystem.GetHitPartForBone("Bip01_L_Forearm") == 4
                && PlayerHitboxSystem.GetHitPartForBone("Bip01_R_Hand") == 5
                && PlayerHitboxSystem.GetHitPartForBone("Bip01_R_Calf") == 6
                && PlayerHitboxSystem.GetHitPartForBone("Bip01_L_Foot") == 7
                && PlayerHitboxSystem.GetHitPartForBone("Bip01_L_Finger0") == 8
                && PlayerHitboxSystem.GetHitPartForBone("dunpai") == 9,
                "Hit parts match the native named-bone groups and shield group");

            var shielded = new PlayerBasicInfo { Id = 902, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 100, Hudun = 35 };
            G_Combat.ApplyDamage(shielded, null, 25, 2, "m4a1", ignoreArmor: false, armorPenetration: 0.65f);
            Assert(shielded.Hudun == 10 && shielded.Hp == 100 && shielded.Zhuangjia == 100,
                $"Hudun shield absorbs damage before HP/Zhuangjia (hudun={shielded.Hudun}, hp={shielded.Hp}, armor={shielded.Zhuangjia})");

            var highPenVictim = new PlayerBasicInfo { Id = 903, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 100 };
            var lowPenVictim = new PlayerBasicInfo { Id = 904, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 100 };
            G_Combat.ApplyDamage(highPenVictim, null, 50, 2, "ak47", ignoreArmor: false, armorPenetration: 0.90f);
            G_Combat.ApplyDamage(lowPenVictim, null, 50, 2, "mp5", ignoreArmor: false, armorPenetration: 0.45f);
            Assert(highPenVictim.Hp < lowPenVictim.Hp && highPenVictim.Zhuangjia < 100 && lowPenVictim.Zhuangjia < highPenVictim.Zhuangjia,
                $"Armor penetration differentiates vest mitigation (highPenHp={highPenVictim.Hp}, lowPenHp={lowPenVictim.Hp})");

            var legVictim = new PlayerBasicInfo { Id = 905, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 100 };
            G_Combat.ApplyDamage(legVictim, null, 50, 6, "ak47", ignoreArmor: false, armorPenetration: 0.90f);
            var armVictim = new PlayerBasicInfo { Id = 909, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 100 };
            G_Combat.ApplyDamage(armVictim, null, 50, 5, "ak47", ignoreArmor: false, armorPenetration: 0.90f);
            Assert(legVictim.Zhuangjia == 100 && legVictim.Hp == 65 && armVictim.Zhuangjia == 100 && armVictim.Hp == 60,
                "Right arm and right leg retain their respective damage multipliers without consuming vest armor");

            var highHelmet = new PlayerBasicInfo { Id = 906, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 100 };
            var unarmoredHead = new PlayerBasicInfo { Id = 907, Team = 2, Hp = 100, MaxHp = 100, Zhuangjia = 0 };
            G_Combat.ApplyDamage(highHelmet, null, 33, 1, "m4a1", ignoreArmor: false, armorPenetration: 0.70f);
            G_Combat.ApplyDamage(unarmoredHead, null, 33, 1, "m4a1", ignoreArmor: false, armorPenetration: 0.70f);
            Assert(highHelmet.Hp > unarmoredHead.Hp && highHelmet.Zhuangjia < 100,
                $"Helmet mitigates headshot damage and loses durability (helmetHp={highHelmet.Hp}, bareHp={unarmoredHead.Hp})");

            var crouchTarget = PlayerTargetState.Capture(new PlayerBasicInfo
            {
                Id = 908, Team = 2, Career = "police", PosX = 200f, DuckState = 0, ViewHeight = 93f, Hp = 100
            });
            bool crouchMissHigh = !PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 0f, 148f), fwd, 1000f, crouchTarget, out _, out _, out _, out _);
            bool crouchHitHead = PlayerHitboxSystem.RaycastTarget(new Vector3f(0f, 0f, 95f), fwd, 1000f, crouchTarget, out _, out _, out _, out int crouchPart);
            Assert(crouchMissHigh && crouchHitHead && crouchPart == 1,
                $"Crouched 17-bone rig misses high ray and maps 95cm ray to head (part={crouchPart})");

            float thinScale = OfficialPhysicsWorld.ComputeWallbangScale(12f, 60f, 0.70f);
            float thickScale = OfficialPhysicsWorld.ComputeWallbangScale(48f, 60f, 0.70f);
            float blockedScale = OfficialPhysicsWorld.ComputeWallbangScale(75f, 60f, 0.70f);
            Assert(thinScale > thickScale && thinScale < 1f && thickScale > 0.1f && blockedScale == 0f,
                $"ComputeWallbangScale scales wall penetration smoothly (thin={thinScale:F2}, thick={thickScale:F2}, blocked={blockedScale:F2})");
        }

        private static void TestSkillAndVfxSystem(GameTables tables, OfficialPhysicsWorld phys)
        {
            string[] weapons21 =
            {
                "m4a1_legend2", "ak47_legend_ct", "ak47_legend_t", "awm_legend_ct", "awm_hero",
                "barrett_m107_dragon", "aa12_hell_dragon", "aa12_hero", "deagle_pulse", "block_dragon_pistol",
                "double_scythe", "double_scythe_hell", "abyss_blade", "bladeshield_hero", "nunchakus_legend2",
                "thunder_submachinegun_legend2", "ak47_hero", "m4a1_hero", "rpk_hero", "p90_s", "gold_saber"
            };
            var seenKinds = new HashSet<SkillMechanismKind>();
            int activePlans = 0;
            foreach (var wn in weapons21)
            {
                var wDef = tables.GetWeapon(wn);
                tables.TryGetSkill(wn, out var skillDef);
                var plan = SkillAndVfxSystem.BuildPlan(wDef, skillDef);
                if (plan.PrimaryKind != SkillMechanismKind.None) activePlans++;
                seenKinds.Add(plan.PrimaryKind);
            }
            Assert(activePlans == weapons21.Length && seenKinds.Count >= 4,
                $"All 21 representative Hero/Legendary/Gold weapons resolve active skill plans ({activePlans}/21, templates={seenKinds.Count})");

            var skillSys = new SkillAndVfxSystem(tables, phys);
            var skillCfg = new ServerConfig { Map = "12", RaceType = 2003 };
            skillCfg.EnsureDefaults();
            var skillTcp = new TcpBattleGateway(skillCfg, 0, System.Net.IPAddress.Loopback, tables);

            foreach (var sample in new[] { "m4a1_legend2", "awm_hero", "deagle_pulse", "double_scythe_hell", "thunder_submachinegun_legend2", "ak47_hero" })
            {
                var wDef = tables.GetWeapon(sample);
                tables.TryGetSkill(sample, out var sDef);
                var sp = SkillAndVfxSystem.BuildPlan(wDef, sDef);
                Assert(sp.SupportsChargedActive && sp.CooldownMs > 0, $"Skill template resolved for {sample}: kind={sp.PrimaryKind}, cd={sp.CooldownMs}ms");
            }

            var caster = new PlayerBasicInfo
            {
                Id = 801, Team = 1, Career = "police", CurrentWeapon = 1, CurrentWeaponName = "m4a1_legend2",
                Hp = 80, MaxHp = 100, PosX = 0f, PosY = 0f, PosZ = 0f, ViewYaw = 0f, WeaponPower = 100, WeaponMaxPower = 100,
                WeaponPower2 = 100, WeaponMaxPower2 = 100
            };
            var ally = new PlayerBasicInfo { Id = 802, Team = 1, Hp = 75, MaxHp = 100, PosX = 180f, PosY = 0f, PosZ = 0f };
            var enemy = new PlayerBasicInfo { Id = 803, Team = 2, Hp = 120, MaxHp = 120, Zhuangjia = 100, PosX = 250f, PosY = 0f, PosZ = 0f };
            var entities = new List<PlayerBasicInfo> { caster, ally, enemy };
            skillSys.ResetPlayer(caster);

            skillSys.ProcessCommand(caster, new DecodedUserCmd { Buttons = ButtonConstant.Demolition, RenderTime = 1000 },
                0, 1.0, false, false, entities, skillTcp);
            Assert(caster.SpecialMode && (caster.WeaponEffectLevel & 0x01) != 0 && skillSys.GetEffectiveDamageMultiplier(caster) > 1.0f,
                "Dual-form transform toggles SpecialMode, bit 0 VFX, and boosted damage multiplier");

            skillSys.ProcessCommand(caster, new DecodedUserCmd { Buttons = ButtonConstant.Skill, RenderTime = 2000 },
                0, 2.0, false, false, entities, skillTcp);
            Assert(caster.WeaponPower < 100 && caster.NextSkillTimer > 2000 && enemy.Hp < 120 && caster.Hp > 80,
                $"Charged skill consumes power({caster.WeaponPower}), sets CD({caster.NextSkillTimer}), damages enemy(hp={enemy.Hp}), heals caster(hp={caster.Hp})");

            int powerBeforeKill = caster.WeaponPower;
            skillSys.OnKillScored(caster);
            Assert(caster.WeaponPower >= Math.Min(100, powerBeforeKill + 25),
                "OnKillScored awards +25 WeaponPower skill energy");

            var buffer = new PlayerBasicInfo
            {
                Id = 804, Team = 1, Career = "police", CurrentWeapon = 1, CurrentWeaponName = "m4a1_hero",
                Hp = 70, MaxHp = 100, PosX = 0f, PosY = 0f, PosZ = 0f, WeaponPower = 100, WeaponMaxPower = 100
            };
            entities.Add(buffer);
            skillSys.ResetPlayer(buffer);
            var m4HeroDef = tables.GetWeapon("m4a1_hero");
            float baseSpd = m4HeroDef.GetMoveSpeed(90);
            skillSys.ProcessCommand(buffer, new DecodedUserCmd { Buttons = ButtonConstant.Skill, RenderTime = 3000 },
                0, 3.0, false, false, entities, skillTcp);
            float buffSpd = skillSys.GetEffectiveMoveSpeed(buffer, m4HeroDef);
            int buffInt = skillSys.GetEffectiveAttackIntervalMs(buffer, m4HeroDef);
            Assert(buffer.Hudun > 0 && ally.Hudun > 0 && ally.Hp > 75 && buffSpd > baseSpd && buffInt < m4HeroDef.AttackIntervalMs,
                $"Buff template grants self/ally Hudun({buffer.Hudun}/{ally.Hudun}), ally heal({ally.Hp}), speed({buffSpd:F0}>{baseSpd:F0}), fireRate({buffInt}<{m4HeroDef.AttackIntervalMs})");

            skillSys.Tick(1.0f, 12.0, entities, skillTcp);
            Assert(buffer.Hudun == 0 && Math.Abs(skillSys.GetEffectiveAttackIntervalMs(buffer, m4HeroDef) - m4HeroDef.AttackIntervalMs) <= 1,
                "Skill Tick expires temporary buff/shield and cleans active VFX keys");

            var saberman = new PlayerBasicInfo
            {
                Id = 805, Team = 1, CurrentWeapon = 3, CurrentWeaponName = "gold_saber",
                PosX = 0f, PosY = 0f, PosZ = 0f, ViewYaw = 0f
            };
            var meleeTarget = new PlayerBasicInfo { Id = 806, Team = 2, PosX = 280f, PosY = 0f, PosZ = 0f, Hp = 100, MaxHp = 100, Zhuangjia = 0 };
            int derivedHits = skillSys.TriggerMeleeHeavyDerived(saberman, tables.GetWeapon("gold_saber"), 4.0, false, new[] { saberman, meleeTarget }, skillTcp);
            Assert(derivedHits == 1 && meleeTarget.Hp < 100 && (saberman.WeaponEffectLevel & 0x06) == 0x06,
                $"MeleeHeroHeavyDerived hits forward wave target (hits={derivedHits}, targetHp={meleeTarget.Hp})");
        }

        private static void TestBiohazardDeepAndAi(GameTables tables, OfficialPhysicsWorld phys)
        {
            var cfg = new ServerConfig { RaceType = 6, AllyBots = 2, EnemyBots = 2 };
            cfg.EnsureDefaults();
            var round = new BiohazardRound(cfg.Biohazard!, seed: 42);
            round.Begin(0);

            var h1 = new PlayerBasicInfo { Id = 1, Team = 2, Career = "police", PosX = 0f, PosY = 0f, PosZ = 0f, Hp = 100, MaxHp = 100, CurrentWeapon = 1, CurrentWeaponName = "m4a1", CurrentClip = 10, MaxClip = 30, CurrentCarryClip = 30 };
            var h2 = new PlayerBasicInfo { Id = 2, Team = 2, Career = "police", PosX = 500f, PosY = 0f, PosZ = 0f, Hp = 100, MaxHp = 100 };
            var h3 = new PlayerBasicInfo { Id = 3, Team = 2, Career = "police", PosX = 1000f, PosY = 0f, PosZ = 0f, Hp = 100, MaxHp = 100 };
            var roster = new[] { h1, h2, h3 };
            var mother = round.SelectMother(BiohazardRound.IncubationMs, roster);
            Assert(mother != null && BiohazardRound.IsInfected(mother), "Biohazard 3-player roster selects 1 mother after 15s incubation");
            if (mother == null) return;
            mother.CurrentWeapon = 3;
            mother.CurrentWeaponName = BiohazardRound.Mother;

            int startMax = mother.MaxHp;
            mother.Hp = startMax - 200;
            round.RecordHurt(mother.Id, BiohazardRound.IncubationMs + 1000);
            round.TickRegen(1.0f, BiohazardRound.IncubationMs + 3000, roster);
            int hpBeforeDelay = mother.Hp;
            round.TickRegen(1.0f, BiohazardRound.IncubationMs + 6000, roster);
            Assert(hpBeforeDelay == startMax - 200 && mother.Hp > hpBeforeDelay && mother.Hp <= mother.MaxHp,
                $"Biohazard infected regen waits 4s hurt delay then heals (before={hpBeforeDelay}, after={mother.Hp})");

            var lv2 = round.AddInfectionEvolution(mother, 2);
            var lv3 = round.AddInfectionEvolution(mother, 3);
            Assert(lv2?.Lv == 2 && lv2?.AddHp == 400 && lv3?.Lv == 3 && lv3?.AddHp == 600 && round.GetInfectedLevel(mother.Id) == 3,
                $"Biohazard infection evolution reaches Lv3 (+400/+600 MaxHp={mother.MaxHp})");

            var gunKillMsg = round.RecordKill(h1.Id != mother.Id ? h1 : h2, mother, melee: false);
            Assert(gunKillMsg == NetData.BioMessageType.KILLBIO && round.GetHumanDamageMultiplier() > 1.0f,
                $"Biohazard gun kill raises growth multiplier ({round.GetHumanDamageMultiplier():F2}x)");

            var nonMothers = Array.FindAll(roster, p => p.Id != mother.Id);
            round.TryInfect(nonMothers[0], mother, mother.CurrentWeaponName, out _);
            var heroes = round.TryPromoteHeroes(roster);
            Assert(heroes.Count == 1 && heroes[0].Career == BiohazardRound.HeroCareer && heroes[0].MaxHp == BiohazardRound.HeroHp,
                "Last surviving human promotes to 1000HP Hero");
            if (heroes.Count == 0) return;

            var msgHero = round.RecordKill(heroes[0], nonMothers[0], melee: true);
            Assert(msgHero == NetData.BioMessageType.HEROKILL && !round.CanRespawn(nonMothers[0], 999999),
                "Hero melee kill emits BioMessageType.HEROKILL and blocks resurrection");

            var spawns = new List<BspSpawnPoint> { new() { X = h1.PosX, Y = h1.PosY, Z = h1.PosZ, TeamFlag = 1 } };
            var crate = round.TickSupplySpawns(20.0f, spawns);
            Assert(crate != null && round.SupplyCrates.Count == 1 && crate!.BufName == "shuxing_lan",
                "Biohazard spawns shuxing_lan supply crate");

            var humanCollector = new PlayerBasicInfo
            {
                Id = 99, Team = 2, Career = "police", PosX = crate!.X, PosY = crate.Y, PosZ = crate.Z,
                Hp = 50, MaxHp = 100, CurrentWeapon = 1, CurrentWeaponName = "m4a1", CurrentClip = 5, MaxClip = 30, CurrentCarryClip = 10
            };
            Assert(round.TryPickUpSupply(mother, tables) == null && round.TryPickUpSupply(humanCollector, tables) != null
                && humanCollector.Hp == 100 && humanCollector.CurrentClip == 30 && round.SupplyCrates.Count == 0,
                $"Supply crate ignores infected and refills human HP({humanCollector.Hp})/clip({humanCollector.CurrentClip})");

            var infectedBot = new BotAgent(301, 1, "ZombieBot", BiohazardRound.Infected, BiohazardRound.Infected, "", 0f, 0f, PlayerPhysicsState.FloorElevation, 0f, tables, null, null, false, true);
            var humanBot = new BotAgent(302, 2, "HumanBot", "police", "m4a1", "", 220f, 0f, PlayerPhysicsState.FloorElevation, 180f, tables, null, null, false, false);
            var aiEntities = new List<PlayerBasicInfo> { infectedBot.Snap, humanBot.Snap };
            float initialXInf = infectedBot.Snap.PosX;
            float initialXHum = humanBot.Snap.PosX;
            for (int t = 0; t < 10; t++)
            {
                infectedBot.Tick(0.05f, aiEntities, false, null, t * 50, isBiohazardMode: true);
                humanBot.Tick(0.05f, aiEntities, false, null, t * 50, isBiohazardMode: true);
            }
            Assert(infectedBot.Snap.PosX > initialXInf && humanBot.Snap.PosX > initialXHum,
                $"Biohazard AI: infected advances({initialXInf:F0}->{infectedBot.Snap.PosX:F0}) and human kites back({initialXHum:F0}->{humanBot.Snap.PosX:F0})");

            Assert(G_Missile.GRAVITY == 800f && G_Missile.BOUNCE_RESTITUTION == 0.45f && G_Missile.SPLASH_RADIUS == 320f && G_Missile.MAX_SPLASH_DAMAGE == 105,
                "G_Missile throwable physics constants match server authoritative contract");
        }

        private static void TestAllModeMultiplayer(GameTables tables, OfficialPhysicsWorld phys)
        {
            var expCfg = new ServerConfig { Map = "2", RaceType = 2, MaxHumanPlayers = 4 };
            expCfg.EnsureDefaults();
            var expBsp = new BspMapData { MapId = 2 };
            expBsp.BombSites.Add(new BspBombSite { X = 300, Y = 400, Z = 500 });
            var expMode = new ModeCoordinator(expCfg, tables, expBsp, phys);
            var expTcp = new TcpBattleGateway(expCfg, 0, System.Net.IPAddress.Loopback, tables);

            var t1 = new PlayerBasicInfo { Id = 1, Team = 1, PlayerName = "PlanterA", PosX = 300, PosY = 400, PosZ = 500, HasC4 = true, CurrentWeapon = 5 };
            var t2 = new PlayerBasicInfo { Id = 2, Team = 1, PlayerName = "EscortB", PosX = 320, PosY = 400, PosZ = 500, HasC4 = false, CurrentWeapon = 1 };
            var holdAttack = new DecodedUserCmd { Buttons = 64 };
            var noAttack = new DecodedUserCmd { Buttons = 0 };
            for (int i = 0; i < 60; i++)
            {
                expMode.HandlePlayerExplodeCommand(t1, holdAttack, 0, 0.03125f, expTcp);
                expMode.HandlePlayerExplodeCommand(t2, noAttack, 0, 0.03125f, expTcp);
            }
            for (int i = 0; i < 40 && !expMode.C4Planted; i++) expMode.HandlePlayerExplodeCommand(t1, holdAttack, 0, 0.03125f, expTcp);
            Assert(expMode.C4Planted, "Multi-human Explode isolates active plant actor from teammate commands");

            var wmCfg = new ServerConfig { Map = "12", RaceType = 64, MaxHumanPlayers = 2 };
            wmCfg.EnsureDefaults();
            var wmMode = new ModeCoordinator(wmCfg, tables, new BspMapData { MapId = 12 }, phys);
            var wmTcp = new TcpBattleGateway(wmCfg, 0, System.Net.IPAddress.Loopback, tables);
            var pA = new PlayerBasicInfo { Id = 1, Team = 1, PlayerName = "WM_A", CurrentWeaponName = "m4a1" };
            var pB = new PlayerBasicInfo { Id = 2, Team = 1, PlayerName = "WM_B", CurrentWeaponName = "m4a1" };
            var victim = new PlayerBasicInfo { Id = 200, Team = 2, PlayerName = "Bot" };
            wmMode.InitializeJoiningHuman(pA);
            wmMode.InitializeJoiningHuman(pB);
            wmMode.OnEntityKilled(pA, victim, wmTcp, new[] { pA, pB, victim }, pA.CurrentWeaponName);
            Assert(pA.CurrentWeaponName != pB.CurrentWeaponName,
                $"WeaponMaster advances killer tier independently (A={pA.CurrentWeaponName}, B={pB.CurrentWeaponName})");

            var fkCfg = new ServerConfig { Map = "12", RaceType = 74, MaxHumanPlayers = 2 };
            fkCfg.EnsureDefaults();
            var fkMode = new ModeCoordinator(fkCfg, tables, new BspMapData { MapId = 12 }, phys);
            var fkShooter = new PlayerBasicInfo { Id = 1, Team = 1, CurrentWeapon = 3, CurrentWeaponName = "dagger", ViewHeight = 150, ViewYaw = 0 };
            var fkTarget = new PlayerBasicInfo { Id = 2, Team = 2, PosX = 800, PosY = 0, PosZ = 0, Hp = 100 };
            bool fkHit = fkMode.TryFlyKnifeAttack(fkShooter, true, false, new[] { fkShooter, fkTarget });
            Assert(fkHit && fkTarget.Hp == 0, $"FlyKnife ranged throw deals 110 lethal damage across distance (hp={fkTarget.Hp})");

            var bhCfg = new ServerConfig { Map = "12", RaceType = 2019, MaxHumanPlayers = 2 };
            bhCfg.EnsureDefaults();
            var bhMode = new ModeCoordinator(bhCfg, tables, new BspMapData { MapId = 12 }, phys);
            var bhTcp = new TcpBattleGateway(bhCfg, 0, System.Net.IPAddress.Loopback, tables);
            var bhA = new PlayerBasicInfo { Id = 1, Team = 1, PlayerName = "BH_A" };
            var bhB = new PlayerBasicInfo { Id = 2, Team = 1, PlayerName = "BH_B" };
            var bhVictim = new PlayerBasicInfo { Id = 200, Team = 2, PlayerName = "Bot" };
            bhMode.InitializeJoiningHuman(bhA);
            bhMode.InitializeJoiningHuman(bhB);
            bhMode.OnEntityKilled(bhA, bhVictim, bhTcp, new[] { bhA, bhB, bhVictim }, "m4a1");
            Assert(bhMode.Team1Kills == 1 && bhMode.Team1Score == 1,
                $"BigHead records kill and score across multiplayer roster (kills={bhMode.Team1Kills}, score={bhMode.Team1Score})");
        }
    }
}
