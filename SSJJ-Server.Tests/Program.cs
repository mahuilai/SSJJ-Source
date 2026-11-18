using System;
using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;
using SSJJ.Server.Snapshot;
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
            Console.WriteLine("=== SSJJ-Server Module 1-4 Unit & Formula Verification ===");

            // 1. ClientTimeComponent: ClientTime += FrameInterval
            var p = new PlayerBasicInfo { Id = 1, ClientTime = 1000 };
            PlayerPredictionEngine.AdvanceClientTime(p, 16);
            PlayerPredictionEngine.AdvanceClientTime(p, 17);
            Assert(p.ClientTime == 1033, "ClientTimePredication: exact FrameInterval accumulation");

            // 2. OrientationComponent: 8-way MoveYaw
            PlayerPredictionEngine.UpdateMoveYaw(p, 90f, true, false, true, false); // W+A => +45
            Assert(Math.Abs(p.MoveYaw - 135f) < 0.11f, "OrientationPredication: W+A MoveYaw=135");
            PlayerPredictionEngine.UpdateMoveYaw(p, 170f, false, true, false, false); // S => +180 => wrap(-10)
            Assert(Math.Abs(p.MoveYaw - (-10f)) < 0.11f, "OrientationPredication: S MoveYaw wrap(-10)");

            // 3. PunchOrientation & DecayTime
            p.DecayTime = 20;
            p.PunchPitch = -4.0f;
            p.PunchYaw = 3.0f;
            PlayerPredictionEngine.StepPunchAndDecay(p, 16);
            Assert(p.DecayTime == 4 && Math.Abs(p.PunchPitch - (-4.0f)) < 0.001f, "DecayPredication: holds punch while DecayTime > 0");
            PlayerPredictionEngine.StepPunchAndDecay(p, 16);
            Assert(p.DecayTime == 0, "DecayPredication: DecayTime reaches 0");
            PlayerPredictionEngine.StepPunchAndDecay(p, 100); // len=5 -> len - (10+2.5)*0.1 = 3.75
            float lenAfter = (float)Math.Sqrt(p.PunchYaw * p.PunchYaw + p.PunchPitch * p.PunchPitch);
            Assert(Math.Abs(lenAfter - 3.75f) < 0.02f, "PunchOrientationPredication: 1:1 linear+proportional decay", $"got {lenAfter:F3}");

            // 4. LegAnim & ScaledEclipsedTime (0.0016f * v2d for Run, reset on state change)
            p.Moving = true;
            p.LegsAnim = 7;
            PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(p, true, 3, 500, false, false, 16);
            Assert(p.LegsAnim == 1 && Math.Abs(p.LegsSpeedAnimTime - 16f * (500f * 0.0016f)) < 0.01f,
                "LegAnimPredication: state transition resets ScaledEclipsedTime and uses 0.0016*v2d");

            // 5. Sniper Zoom & ResumeZoom (PlayerFovInitSystem)
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

            // 6. Shotgun single-shell reload & fire-interrupt
            var shotgun = new WeaponDef { Name = "m3", WeaponType = 6, MaxClip = 8, MaxCarryClip = 32, FireBullets = 8 };
            p.CurrentClip = 2; p.CurrentCarryClip = 16; p.MaxClip = 8; p.IsStartReload = false;
            PlayerPredictionEngine.StepReload(p, shotgun, reloadPressed: true, attackDown: false);
            Assert(p.IsStartReload && p.ViewAnim == 17, "ShotgunReload: starts shell reload");
            p.ClientTime += 450;
            PlayerPredictionEngine.StepReload(p, shotgun, reloadPressed: false, attackDown: false);
            Assert(p.CurrentClip == 3 && p.IsStartReload, "ShotgunReload: loads 1 shell & continues");
            PlayerPredictionEngine.StepReload(p, shotgun, reloadPressed: false, attackDown: true);
            Assert(!p.IsStartReload && p.ViewAnim == 13, "ShotgunReload: fire interrupts reload when Clip > 0");

            // 7. Rifle Accuracy, ShotsFired Cap & Pistol reset
            var rifle = new WeaponDef { Name = "m4a1", WeaponType = 1, AttackIntervalMs = 90, DefaultAccuracy = 0.2f };
            p.ShotsFired = 12; p.DelayFire = true; p.ClientTime = 5000;
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(p, rifle, isAttackDown: false, fired: false, isSecondary: false);
            Assert(p.ShotsFired == 8 && p.DecreaseShotsFired == 5150, "RifleIdleAction: caps ShotsFired=8 & sets +150ms");
            var pistol = new WeaponDef { Name = "deagle", WeaponType = 0, AttackIntervalMs = 200, DefaultAccuracy = 0.2f };
            PlayerPredictionEngine.StepWeaponIdleAndAccuracy(p, pistol, isAttackDown: false, fired: false, isSecondary: false);
            Assert(p.ShotsFired == 0, "PistolIdleAction: resets ShotsFired=0 on release");

            // 8. Melee backstab + headshot & G_Missile splash physics
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

            // 9. SkillAndVfxSystem: 10+ legendary/hero weapons
            var tables = new GameTables();
            tables.Load(System.IO.Path.GetFullPath(System.IO.Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..")));
            var phys = new OfficialPhysicsWorld();
            var skillSys = new SkillAndVfxSystem(tables, phys);
            string[] heroWeapons = { "m4a1_legend2", "ak47_legend", "awm_legend", "axe_g", "nunchakus_legend2", "dagger", "taiyi_grenade2", "thunder_submachinegun_legend2", "hero_weapon_base", "sawed_pirate" };
            int resolved = 0;
            foreach (var hw in heroWeapons)
            {
                var def = tables.GetWeapon(hw);
                if (!string.IsNullOrEmpty(def.Name)) resolved++;
            }
            Assert(tables.WeaponCount >= 1400 && resolved == heroWeapons.Length, $"Tables & 10 Hero/Legendary Weapons resolved ({resolved}/{heroWeapons.Length}, total={tables.WeaponCount})");

            Console.WriteLine($"=== SUMMARY: passed={_passed} failed={_failed} ===");
            return _failed == 0 ? 0 : 1;
        }
    }
}
