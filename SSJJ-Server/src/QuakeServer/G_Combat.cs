using System;
using SSJJ.Server.GameModes;
using SSJJ.Server.Snapshot;
using static share.constant.AnimationConstant;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 对标 Quake 3: code/game/g_combat.c
    /// 权威伤害结算、护甲吸收、击杀播报与复活机制
    /// </summary>
    public static class G_Combat
    {
        public const float ARMOR_PROTECTION_RATIO = 0.35f; // 护甲吸收 35% 伤害
        public const float RESPAWN_DELAY = 3.0f;
        public const int RespawnDelayMs = (int)(RESPAWN_DELAY * 1000f);

        // Inclusive frame ranges in the native manCT/woman model.DAE.action files.
        private const int BodyDeathDurationMs = (int)((260 - 200 + 1) * 33.333332f);
        private const int HeadshotDeathDurationMs = (int)((27 - 0 + 1) * 33.333332f);

        public static int CurrentServerTimeMs { get; set; }

        // Mode-owned interception is installed once by the simulation.
        public static Func<PlayerBasicInfo, PlayerBasicInfo?, string, bool>? InterceptDamage { get; set; }
        public static event Action<HitEventData>? OnHitConfirmed;
        public static event Action<KillNoticeEventData>? OnKillOccurred;

        /// <summary>Debug-only: protect entity id 1. Disabled by default; enable with --godmode.</summary>
        public static bool GodModeEnabled = false;

        /// <summary>
        /// 权威伤害结算函数（对标 g_combat.c::G_Damage）
        /// </summary>
        public static void ApplyDamage(
            PlayerBasicInfo target,
            PlayerBasicInfo? attacker,
            int rawDamage,
            int hitPart,
            string weaponName,
            bool ignoreArmor = false,
            float armorPenetration = 0.65f)
        {
            if (target == null || target.IsDead) return;
            if (GodModeEnabled && target.Id == 1) return;
            if (InterceptDamage?.Invoke(target, attacker, weaponName) == true) return;

            // Project damage multipliers keyed by the original client HitBoxGroupUtilty hit groups.
            float multiplier = hitPart switch
            {
                1 => 2.5f,
                2 => 1.0f,
                3 => 1.1f,
                4 or 5 => 0.8f,
                6 or 7 => 0.7f,
                _ => 1.0f
            };

            int finalDamage = ignoreArmor ? Math.Max(1, rawDamage) : Math.Max(1, (int)(rawDamage * multiplier));

            // 2. 技能护盾 (Hudun) 优先吸收
            int remainingDamage = finalDamage;
            if (!ignoreArmor && target.Hudun > 0)
            {
                int absorbed = Math.Min(target.Hudun, remainingDamage);
                target.Hudun -= absorbed;
                remainingDamage -= absorbed;
            }

            // 3. 防弹衣/头盔护甲吸收计算 (1=Head头盔, 2/3=胸腹防弹衣; 四肢不耗护甲)
            int armorSave = 0;
            bool armoredPart = hitPart is 1 or 2 or 3;
            if (!ignoreArmor && armoredPart && target.Zhuangjia > 0 && remainingDamage > 0)
            {
                float clampedPen = Math.Clamp(armorPenetration, 0.1f, 1.0f);
                float absorbRatio = hitPart == 1
                    ? Math.Clamp((1f - clampedPen) * 0.85f, 0.10f, 0.45f)
                    : Math.Clamp(1f - clampedPen * 0.65f, 0.20f, ARMOR_PROTECTION_RATIO + 0.15f);
                armorSave = (int)Math.Ceiling(remainingDamage * absorbRatio);
                if (armorSave > target.Zhuangjia) armorSave = target.Zhuangjia;
                target.Zhuangjia -= armorSave;
            }
            int hpDeduction = Math.Max(0, remainingDamage - armorSave);

            int healthDamage = Math.Min(target.Hp, hpDeduction);
            target.Hp -= hpDeduction;

            // 3. 产生受击确认事件 (驱动客户端准星红叉与命中音效)
            var hitEvt = new HitEventData
            {
                AttackerId = attacker?.Id ?? 0,
                VictimId = target.Id,
                Damage = finalDamage,
                HealthDamage = healthDamage,
                HitPart = hitPart,
                WeaponName = weaponName,
                AttackerX = attacker?.PosX ?? target.PosX,
                AttackerY = attacker?.PosY ?? target.PosY,
                AttackerZ = attacker?.PosZ ?? target.PosZ
            };
            OnHitConfirmed?.Invoke(hitEvt);

            // 4. 致命伤击杀结算 (对标 player_die)
            if (target.Hp <= 0)
            {
                BeginDeath(target, attacker, hitPart == 1);

                var killEvt = new KillNoticeEventData
                {
                    KillerId = attacker?.Id ?? 0,
                    VictimId = target.Id,
                    WeaponName = weaponName,
                    IsHeadshot = (hitPart == 1)
                };
                OnKillOccurred?.Invoke(killEvt);
            }
        }

        public static void BeginDeath(PlayerBasicInfo player, PlayerBasicInfo? attacker, bool headshot)
        {
            player.Hp = 0;
            player.IsDead = true;
            // The corpse stays in place. Clear the movement flags used by the
            // client's OrientationAnimSystem to choose the model's facing.
            player.Moving = false;
            player.VelX = player.VelY = player.VelZ = player.Velocity2D = 0f;
            player.IsStartReload = false;
            player.ReloadEndTime = 0;
            player.ViewAnim = player.LeftViewAnim = TORSO_STAND;
            player.ViewAnimRemainMs = 0;

            bool useHeadshot = headshot && !BiohazardRound.IsInfected(player);
            if (useHeadshot)
            {
                int anim = IsHitFromBehind(player, attacker) ? HEADSHOT_F : HEADSHOT;
                player.LegsAnim = player.TorsoAnim = anim;
            }
            else
            {
                player.LegsAnim = LEGS_DIE;
                player.TorsoAnim = TORSO_DIE;
            }

            player.TorsoAnimStartTime = CurrentServerTimeMs;
            AdvanceDeathClock(player, CurrentServerTimeMs);
        }

        private static bool IsHitFromBehind(PlayerBasicInfo player, PlayerBasicInfo? attacker)
        {
            if (attacker == null) return false;
            float dx = attacker.PosX - player.PosX;
            float dy = attacker.PosY - player.PosY;
            if (dx == 0f && dy == 0f) return false;
            // Match server movement and shooting: ViewYaw 0 faces +X, 90 faces +Y.
            float bearing = MathF.Atan2(dy, dx) * (180f / MathF.PI);
            return MathF.Abs(MathF.IEEERemainder(bearing - player.ViewYaw, 360f)) > 90f;
        }

        private static int DeathDuration(PlayerBasicInfo player, bool headshot) =>
            BiohazardRound.IsInfected(player) ? (int)(40 * 33.333332f)
                : headshot ? HeadshotDeathDurationMs : BodyDeathDurationMs;

        // Use the snapshot clock for both animation layers and the observer's DeadTimer.
        public static void AdvanceDeathClock(PlayerBasicInfo player, int serverTimeMs)
        {
            if (!player.IsDead) return;
            int elapsed = Math.Max(0, serverTimeMs - (int)player.TorsoAnimStartTime);
            int duration = DeathDuration(player, player.LegsAnim is HEADSHOT or HEADSHOT_F);
            int remaining = Math.Max(duration - elapsed, 0);
            player.DeadTimerMs = elapsed;
            player.LegsSpeedAnimTime = elapsed;
            player.LegsAnimRemainMs = remaining;
            player.TorsoAnimRemainMs = remaining;
        }

        public static void ResetSpawnAnimation(PlayerBasicInfo player)
        {
            player.IsDead = false;
            player.DeadTimerMs = 0;
            player.LegsAnim = LEGS_IDLE;
            player.LegsSpeedAnimTime = 0f;
            player.LegsAnimRemainMs = 0;
            player.TorsoAnim = TORSO_STAND;
            player.TorsoAnimStartTime = CurrentServerTimeMs;
            player.TorsoAnimRemainMs = 0;
            player.ViewAnim = player.LeftViewAnim = TORSO_STAND;
            player.ViewAnimRemainMs = 0;
            player.IsStartReload = false;
            player.ReloadEndTime = 0;
            player.NextAttackTimer = player.NextSecondaryAttackTimer = 0;
            player.ShotsFired = player.DecreaseShotsFired = 0;
            player.DelayFire = false;
        }

        /// <summary>
        /// 复活倒计时推进与出生点重生
        /// </summary>
        public static void CheckRespawn(PlayerBasicInfo player, Physics.PlayerPhysicsState pState, float dt, float spawnX, float spawnY, float spawnZ)
        {
            if (!player.IsDead) return;

            if (player.DeadTimerMs >= RespawnDelayMs)
            {
                // 重生复活
                ResetSpawnAnimation(player);
                player.Hp = 100;
                player.Zhuangjia = 100;
                player.Hudun = 0;
                player.LifeBarSeq++; // 通知客户端刷新血条与实体状态
                player.Stamina = 0f;

                pState.Position.X = spawnX;
                pState.Position.Y = spawnY;
                pState.Position.Z = spawnZ;
                pState.Velocity.X = 0f;
                pState.Velocity.Y = 0f;
                pState.Velocity.Z = 0f;
            }
        }
    }
}
