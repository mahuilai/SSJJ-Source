using System;
using System.Collections.Generic;
using System.Linq;
using SSJJ.Server.Config;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 权威武器系统：接入 Weapon.json 数据表 + WeEngine BSP 掩体遮挡校验 + 弹道/HitBox/穿墙/距离衰减判定
    /// </summary>
    public class G_Weapon
    {
        private static readonly Random _rng = new Random();

        public static readonly Dictionary<string, Snapshot.WeaponDef> WeaponDefs = new Dictionary<string, Snapshot.WeaponDef>(StringComparer.OrdinalIgnoreCase)
        {
            ["m4a1"] = new Snapshot.WeaponDef { Name = "m4a1", BaseDamage = 31, FireInterval = 0.09f, Spread = 0.012f, MaxClip = 35 },
            ["ak47"] = new Snapshot.WeaponDef { Name = "ak47", BaseDamage = 36, FireInterval = 0.10f, Spread = 0.018f, MaxClip = 35 },
            ["awp"] = new Snapshot.WeaponDef { Name = "awp", BaseDamage = 115, FireInterval = 1.30f, Spread = 0.001f, MaxClip = 10 },
            ["deagle"] = new Snapshot.WeaponDef { Name = "deagle", BaseDamage = 45, FireInterval = 0.22f, Spread = 0.020f, MaxClip = 7 },
            ["dagger"] = new Snapshot.WeaponDef { Name = "dagger", BaseDamage = 55, FireInterval = 0.45f, Spread = 0.0f, MaxClip = 0 },
            ["bat"] = new Snapshot.WeaponDef { Name = "bat", BaseDamage = 65, FireInterval = 0.60f, Spread = 0.0f, MaxClip = 0 }
        };

        private float _fireCooldown = 0f;
        public int CurrentAmmo { get; private set; } = 35;
        public event Action<WeaponFireEventData>? OnWeaponFired;

        public void Tick(float dt)
        {
            if (_fireCooldown > 0f)
            {
                _fireCooldown -= dt;
                if (_fireCooldown < 0f) _fireCooldown = 0f;
            }
        }

        public bool TryFire(PlayerBasicInfo shooter, PlayerPhysicsState? shooterPhysics, bool isTriggerDown, List<PlayerBasicInfo> targets)
        {
            return TryFire(shooter, shooterPhysics, isTriggerDown, false, null, null, false, targets);
        }

        public bool TryFire(
            PlayerBasicInfo shooter,
            PlayerPhysicsState? shooterPhysics,
            bool primaryDown,
            bool secondaryDown,
            GameTables? tables,
            OfficialPhysicsWorld? physicsWorld,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> targets)
        {
            TryFireEx(shooter, shooterPhysics, primaryDown, secondaryDown, tables, physicsWorld, freeForAll, targets, out _, out bool anyHit);
            return anyHit;
        }

        internal bool TryFire(
            PlayerBasicInfo shooter,
            PlayerPhysicsState? shooterPhysics,
            bool primaryDown,
            bool secondaryDown,
            GameTables? tables,
            OfficialPhysicsWorld? physicsWorld,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> targets,
            out bool fired)
        {
            bool ok = TryFireEx(shooter, shooterPhysics, primaryDown, secondaryDown, tables, physicsWorld, freeForAll, targets, out fired, out bool anyHit);
            if (!ok || !fired) return false;

            string wName = string.IsNullOrWhiteSpace(shooter.CurrentWeaponName) ? "m4a1" : shooter.CurrentWeaponName;
            var tblDef = tables?.GetWeapon(wName);
            bool isMelee = shooter.CurrentWeapon == 3 || IsMeleeName(wName, tblDef);
            bool secondary = secondaryDown && (isMelee || tblDef?.HasMeleeSecondary == true);
            ApplyPostFireState(shooter, tables, tblDef, wName, isMelee || secondary, secondary);
            return anyHit;
        }

        internal static void ApplyPostFireState(
            PlayerBasicInfo shooter,
            GameTables? tables,
            Config.WeaponDef? tblDef,
            string wName,
            bool isMeleeOrSecondary,
            bool secondary,
            int? overrideIntervalMs = null)
        {
            if (isMeleeOrSecondary)
            {
                int primaryDelay = secondary ? tblDef?.StabSlashMs ?? 850 : tblDef?.SlashSlashMs ?? 400;
                int secondaryDelay = secondary ? tblDef?.StabStabMs ?? 850 : tblDef?.SlashStabMs ?? 500;
                shooter.NextAttackTimer = shooter.ClientTime + primaryDelay;
                shooter.NextSecondaryAttackTimer = shooter.ClientTime + secondaryDelay;
                if (tables != null && tblDef != null) CombatAnimation.StartAttack(shooter, tables, tblDef, secondary);
                return;
            }

            int intervalMs = overrideIntervalMs
                ?? tblDef?.AttackIntervalMs
                ?? (WeaponDefs.TryGetValue(wName, out var wd) ? (int)(wd.FireInterval * 1000f) : 100);
            shooter.NextAttackTimer = shooter.ClientTime + intervalMs;
            shooter.ShotsFired++;
            shooter.DelayFire = tblDef?.AttackType != "Pistol";
            if (tables != null && tblDef != null) CombatAnimation.StartAttack(shooter, tables, tblDef, secondary: false);
        }

        public bool TryFireEx(
            PlayerBasicInfo shooter,
            PlayerPhysicsState? shooterPhysics,
            bool primaryDown,
            bool secondaryDown,
            GameTables? tables,
            OfficialPhysicsWorld? physicsWorld,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> targets,
            out bool didFire,
            out bool anyHit,
            PlayerPositionHistory? positionHistory = null,
            int? shotTimeMs = null,
            float damageMultiplier = 1f,
            float attackIntervalScale = 1f)
        {
            didFire = false;
            anyHit = false;
            bool hasNativeCooldownTimer = shooter.ClientTime > 0
                && (shooter.NextAttackTimer > 0 || shooter.NextSecondaryAttackTimer > 0);
            if ((!primaryDown && !secondaryDown) || (!hasNativeCooldownTimer && _fireCooldown > 0f)
                || shooter.IsDead || shooter.IsStartReload || shooter.ReloadEndTime > 0)
                return false;

            string wName = string.IsNullOrWhiteSpace(shooter.CurrentWeaponName) ? "m4a1" : shooter.CurrentWeaponName;
            var tblDef = tables?.GetWeapon(wName);

            bool isMelee = shooter.CurrentWeapon == 3 || IsMeleeName(wName, tblDef);
            bool isRifleMeleeSecondary = !isMelee && secondaryDown && (tblDef?.HasMeleeSecondary ?? false);
            bool isThrowable = shooter.CurrentWeapon == 4 || (tblDef?.IsThrowable ?? false);
            if (isThrowable || wName.Equals("c4", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            if (shooter.ClientTime > 0)
            {
                if ((isMelee || isRifleMeleeSecondary) && secondaryDown)
                {
                    if (shooter.ClientTime < shooter.NextSecondaryAttackTimer) return false;
                }
                else if (shooter.ClientTime < shooter.NextAttackTimer)
                {
                    return false;
                }
            }

            if (isMelee || isRifleMeleeSecondary)
            {
                didFire = true;
                anyHit = TryMeleeAttack(shooter, tblDef, secondaryDown, physicsWorld, freeForAll, targets);
                return true;
            }

            var ballistics = tblDef?.Ballistics;
            if ((ballistics?.SingleShot == true || tblDef?.AttackType == "Pistol") && shooter.ShotsFired > 0) return false;

            float fireInterval = (tblDef != null ? Math.Max(0.04f, tblDef.AttackIntervalMs / 1000f)
                : (WeaponDefs.TryGetValue(wName, out var wd) ? wd.FireInterval : 0.10f)) * Math.Clamp(attackIntervalScale, 0.35f, 2.0f);
            float baseDmg = tblDef != null ? tblDef.BaseDamage
                : (WeaponDefs.TryGetValue(wName, out var wd2) ? wd2.BaseDamage : 33f);
            int maxClip = tblDef != null && tblDef.MaxClip > 0 ? tblDef.MaxClip
                : (WeaponDefs.TryGetValue(wName, out var wd3) ? wd3.MaxClip : 30);
            int pellets = tblDef != null ? Math.Max(1, tblDef.FireBullets) : 1;
            float spread = ballistics?.Spread(shooter) ?? (tblDef?.WeaponType == 5
                ? ((shooter.Velocity2D > 10 || !shooter.OnGround) ? 0.085f : (shooter.Fov < 90 ? 0.0005f : 0.025f))
                : (tblDef?.WeaponType == 6 ? 0.055f : Math.Clamp(shooter.WeaponAccuracy * 0.08f, 0.004f, 0.07f)));
            float maxRange = tblDef != null ? Math.Min(tblDef.ShotDistance, 20000f) : 12000f;

            if (shooter.MaxClip <= 0) shooter.MaxClip = maxClip;
            if (shooter.CurrentClip <= 0)
            {
                if (shooter.IsBot && shooter.CurrentCarryClip > 0 && tblDef != null)
                {
                    PlayerPredictionEngine.StepReload(shooter, tblDef, reloadPressed: true, attackDown: false);
                }
                return false;
            }
            int clipCost = Math.Max(1, tblDef?.ClipPerShot ?? 1);
            shooter.CurrentClip = Math.Max(0, shooter.CurrentClip - clipCost);
            _fireCooldown = fireInterval;
            didFire = true;

            float muzzleX = shooter.PosX;
            float muzzleY = shooter.PosY;
            float muzzleZ = shooter.PosZ + (shooter.ViewHeight - 4f);

            float yawRad = shooter.ViewYaw * (float)Math.PI / 180f;
            float pitchRad = shooter.ViewPitch * (float)Math.PI / 180f;
            float cosPitch = (float)Math.Cos(pitchRad);
            float baseFwdX = (float)Math.Cos(yawRad) * cosPitch;
            float baseFwdY = (float)Math.Sin(yawRad) * cosPitch;
            float baseFwdZ = -(float)Math.Sin(pitchRad);

            OnWeaponFired?.Invoke(new WeaponFireEventData
            {
                ShooterId = shooter.Id,
                WeaponName = wName,
                MuzzleX = muzzleX,
                MuzzleY = muzzleY,
                MuzzleZ = muzzleZ,
                DirYaw = shooter.ViewYaw,
                DirPitch = shooter.ViewPitch
            });

            for (int p = 0; p < pellets; p++)
            {
                Vector3f forward = ballistics?.ShotDirection(shooter, p, spread) ?? new Vector3f(
                    baseFwdX + (float)(_rng.NextDouble() * 2.0 - 1.0) * spread,
                    baseFwdY + (float)(_rng.NextDouble() * 2.0 - 1.0) * spread,
                    baseFwdZ + (float)(_rng.NextDouble() * 2.0 - 1.0) * spread).Normalized();

                PlayerBasicInfo? bestHitTarget = null;
                float minHitDistance = maxRange;
                float bestDamageScale = 1f;
                int hitPart = 2;
                var rayOrigin = new Vector3f(muzzleX, muzzleY, muzzleZ);

                foreach (var target in targets)
                {
                    if (target.Id == shooter.Id || target.IsDead) continue;
                    if (!freeForAll && target.Team == shooter.Team) continue;

                    PlayerTargetState targetState;
                    if (positionHistory != null && shotTimeMs is int timestamp)
                    {
                        if (!positionHistory.TryGetTarget(target.Id, timestamp, out targetState)) continue;
                    }
                    else
                    {
                        targetState = PlayerTargetState.Capture(target);
                    }

                    if (!PlayerHitboxSystem.RaycastTarget(rayOrigin, forward, minHitDistance, targetState,
                        out float hitDist, out Vector3f hitPt, out _, out int candidatePart))
                    {
                        continue;
                    }

                    float wallScale = 1f;
                    if (physicsWorld != null && physicsWorld.IsReady)
                    {
                        float maxWall = tblDef?.MaxWallThicknessCm ?? 60f;
                        float penPow = tblDef?.WallPenetrationPower ?? 0.65f;
                        if (!physicsWorld.TraceWallbang(muzzleX, muzzleY, muzzleZ, hitPt.X, hitPt.Y, hitPt.Z,
                            maxWall, penPow, out wallScale))
                        {
                            continue;
                        }
                    }

                    minHitDistance = hitDist;
                    bestHitTarget = target;
                    hitPart = candidatePart;
                    bestDamageScale = wallScale;
                }

                if (bestHitTarget != null)
                {
                    float rangeMeters = minHitDistance / 100f;
                    float falloffPerMeter = tblDef?.RangeFalloffPerMeter ?? 0.996f;
                    float distScale = Math.Clamp(MathF.Pow(falloffPerMeter, Math.Max(0f, rangeMeters - 5f)), 0.35f, 1.0f);
                    int scaledDmg = Math.Max(1, (int)MathF.Round(baseDmg * bestDamageScale * distScale * Math.Max(0.1f, damageMultiplier)));
                    float armorPen = tblDef?.ArmorPenetration ?? 0.65f;
                    G_Combat.ApplyDamage(bestHitTarget, shooter, scaledDmg, hitPart, wName, ignoreArmor: false, armorPenetration: armorPen);
                    anyHit = true;
                }
            }

            return true;
        }

        private static bool IsMeleeName(string wName, Config.WeaponDef? tblDef) =>
            tblDef?.IsMelee ?? (wName.Contains("dagger", StringComparison.OrdinalIgnoreCase)
                || wName.Contains("knife", StringComparison.OrdinalIgnoreCase)
                || wName.Contains("bat", StringComparison.OrdinalIgnoreCase)
                || wName.Contains("sword", StringComparison.OrdinalIgnoreCase));

        private bool TryMeleeAttack(
            PlayerBasicInfo shooter,
            Config.WeaponDef? tblDef,
            bool isSecondaryHeavy,
            OfficialPhysicsWorld? physicsWorld,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> targets)
        {
            float slashSec = tblDef != null ? Math.Max(0.25f, tblDef.SlashSlashMs / 1000f) : 0.40f;
            float stabSec = tblDef != null ? Math.Max(0.55f, tblDef.StabStabMs / 1000f) : 0.85f;
            _fireCooldown = isSecondaryHeavy ? stabSec : slashSec;

            // 近战严格近身判定：上限 220cm (约2.2m)
            float meleeRange = tblDef != null ? Math.Clamp(tblDef.ShotDistance, 160f, 240f) : 210f;
            int rawDmg = isSecondaryHeavy ? 120 : 55; // 刀战契约：左键两刀死(55*2=110)，右键一击毙命(120)

            float muzzleX = shooter.PosX;
            float muzzleY = shooter.PosY;
            float muzzleZ = shooter.PosZ + (shooter.ViewHeight - 10f);

            float yawRad = shooter.ViewYaw * (float)Math.PI / 180f;
            float fwdX = (float)Math.Cos(yawRad);
            float fwdY = (float)Math.Sin(yawRad);

            OnWeaponFired?.Invoke(new WeaponFireEventData
            {
                ShooterId = shooter.Id,
                WeaponName = shooter.CurrentWeaponName,
                MuzzleX = muzzleX,
                MuzzleY = muzzleY,
                MuzzleZ = muzzleZ,
                DirYaw = shooter.ViewYaw,
                DirPitch = shooter.ViewPitch
            });

            PlayerBasicInfo? best = null;
            float bestDist = meleeRange;
            foreach (var target in targets)
            {
                if (target.Id == shooter.Id || target.IsDead) continue;
                if (!freeForAll && target.Team == shooter.Team) continue;

                float dx = target.PosX - shooter.PosX;
                float dy = target.PosY - shooter.PosY;
                float dz = Math.Abs((target.PosZ + 90f) - (shooter.PosZ + 90f));
                float dist2D = (float)Math.Sqrt(dx * dx + dy * dy);
                if (dist2D > bestDist || dz > 160f) continue;

                if (dist2D > 1f)
                {
                    float cosAng = (dx * fwdX + dy * fwdY) / dist2D;
                    if (cosAng < 0.45f) continue; // 前方约 126 度扇形
                }

                if (physicsWorld != null && physicsWorld.IsReady &&
                    !physicsWorld.TraceRayClear(muzzleX, muzzleY, muzzleZ, target.PosX, target.PosY, target.PosZ + 110f, out _))
                {
                    continue;
                }

                bestDist = dist2D;
                best = target;
            }

            if (best != null)
            {
                // 近战背部攻击 (1.5x) 与视平线爆头 (2.0x)
                float targetYawRad = best.ViewYaw * (float)Math.PI / 180f;
                float tFwdX = (float)Math.Cos(targetYawRad);
                float tFwdY = (float)Math.Sin(targetYawRad);
                float atkDot = fwdX * tFwdX + fwdY * tFwdY;
                int part = shooter.ViewPitch < -10f ? 1 : 2;
                int finalMeleeDmg = rawDmg;
                if (atkDot > 0.5f) finalMeleeDmg = (int)(finalMeleeDmg * 1.5f);
                if (part == 1) finalMeleeDmg = (int)(finalMeleeDmg * 2.0f);

                // 近战无视护甲削减，确保左键两刀 / 右键一刀手感
                G_Combat.ApplyDamage(best, shooter, finalMeleeDmg, part, shooter.CurrentWeaponName, ignoreArmor: true);
                return true;
            }
            return false;
        }
    }
}
