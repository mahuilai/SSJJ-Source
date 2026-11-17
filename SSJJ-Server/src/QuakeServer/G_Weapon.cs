using System;
using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 权威武器系统：接入 Weapon.json 数据表 + WeEngine BSP 掩体遮挡校验 + 近战弧面/枪械射线碰撞判定
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
            if ((!primaryDown && !secondaryDown) || _fireCooldown > 0f || shooter.IsDead) return false;

            string wName = string.IsNullOrWhiteSpace(shooter.CurrentWeaponName) ? "m4a1" : shooter.CurrentWeaponName;
            var tblDef = tables?.GetWeapon(wName);

            bool isMelee = shooter.CurrentWeapon == 3 || (tblDef?.IsMelee ?? (wName.Contains("dagger", StringComparison.OrdinalIgnoreCase) || wName.Contains("knife", StringComparison.OrdinalIgnoreCase) || wName.Contains("bat", StringComparison.OrdinalIgnoreCase) || wName.Contains("sword", StringComparison.OrdinalIgnoreCase)));
            bool isThrowable = shooter.CurrentWeapon == 4 || (tblDef?.IsThrowable ?? false);
            if (isThrowable || wName.Equals("c4", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            if (isMelee)
            {
                return TryMeleeAttack(shooter, tblDef, secondaryDown, physicsWorld, freeForAll, targets);
            }

            float fireInterval = tblDef != null ? Math.Max(0.05f, tblDef.AttackIntervalMs / 1000f)
                : (WeaponDefs.TryGetValue(wName, out var wd) ? wd.FireInterval : 0.10f);
            float baseDmg = tblDef != null ? tblDef.BaseDamage
                : (WeaponDefs.TryGetValue(wName, out var wd2) ? wd2.BaseDamage : 33f);
            int maxClip = tblDef != null && tblDef.MaxClip > 0 ? tblDef.MaxClip
                : (WeaponDefs.TryGetValue(wName, out var wd3) ? wd3.MaxClip : 30);
            int pellets = tblDef != null ? Math.Max(1, tblDef.FireBullets) : 1;
            float spread = tblDef?.WeaponType == 5 ? 0.002f : (tblDef?.WeaponType == 6 ? 0.055f : 0.014f);
            float maxRange = tblDef != null ? Math.Min(tblDef.ShotDistance, 20000f) : 12000f;

            if (shooter.MaxClip <= 0) shooter.MaxClip = maxClip;
            if (shooter.CurrentClip <= 0)
            {
                // 自动换弹兜底，直到完整换弹读条介入
                shooter.CurrentClip = shooter.MaxClip;
            }
            shooter.CurrentClip = Math.Max(0, shooter.CurrentClip - 1);
            _fireCooldown = fireInterval;

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

            bool anyHit = false;
            for (int p = 0; p < pellets; p++)
            {
                float fwdX = baseFwdX + (float)(_rng.NextDouble() * 2.0 - 1.0) * spread;
                float fwdY = baseFwdY + (float)(_rng.NextDouble() * 2.0 - 1.0) * spread;
                float fwdZ = baseFwdZ + (float)(_rng.NextDouble() * 2.0 - 1.0) * spread;
                float mag = (float)Math.Sqrt(fwdX * fwdX + fwdY * fwdY + fwdZ * fwdZ);
                if (mag > 0.0001f) { fwdX /= mag; fwdY /= mag; fwdZ /= mag; }

                PlayerBasicInfo? bestHitTarget = null;
                float minHitDistance = maxRange;
                int hitPart = 2;

                foreach (var target in targets)
                {
                    if (target.Id == shooter.Id || target.IsDead) continue;
                    if (!freeForAll && target.Team == shooter.Team) continue;

                    float toTargetX = target.PosX - muzzleX;
                    float toTargetY = target.PosY - muzzleY;
                    float toTargetZ = (target.PosZ + 100f) - muzzleZ;

                    float proj = toTargetX * fwdX + toTargetY * fwdY + toTargetZ * fwdZ;
                    if (proj <= 0f || proj >= minHitDistance) continue;

                    float perpX = muzzleX + fwdX * proj;
                    float perpY = muzzleY + fwdY * proj;
                    float perpZ = muzzleZ + fwdZ * proj;

                    float dx = perpX - target.PosX;
                    float dy = perpY - target.PosY;
                    float dist2D = (float)Math.Sqrt(dx * dx + dy * dy);

                    if (dist2D <= 32f && perpZ >= target.PosZ && perpZ <= target.PosZ + 175f)
                    {
                        // BSP 掩体遮挡校验：穿过墙壁则不算命中
                        if (physicsWorld != null && physicsWorld.IsReady &&
                            !physicsWorld.TraceRayClear(muzzleX, muzzleY, muzzleZ, perpX, perpY, perpZ, out _))
                        {
                            continue;
                        }

                        minHitDistance = proj;
                        bestHitTarget = target;
                        if (perpZ >= target.PosZ + 135f) hitPart = 1;
                        else if (perpZ >= target.PosZ + 95f) hitPart = 2;
                        else if (perpZ >= target.PosZ + 65f) hitPart = 3;
                        else hitPart = 5;
                    }
                }

                if (bestHitTarget != null)
                {
                    G_Combat.ApplyDamage(bestHitTarget, shooter, (int)baseDmg, hitPart, wName, ignoreArmor: false);
                    anyHit = true;
                }
            }

            return anyHit;
        }

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
                // 近战无视护甲削减，确保左键两刀 / 右键一刀手感
                G_Combat.ApplyDamage(best, shooter, rawDmg, 2, shooter.CurrentWeaponName, ignoreArmor: true);
                return true;
            }
            return false;
        }
    }
}
