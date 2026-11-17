using System;
using System.Collections.Generic;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 对标 Quake 3: code/game/g_combat.c
    /// 权威伤害结算、护甲吸收、击杀播报与复活机制
    /// </summary>
    public static class G_Combat
    {
        public const float ARMOR_PROTECTION_RATIO = 0.35f; // 护甲吸收 35% 伤害
        public const float RESPAWN_DELAY = 3.0f;           // 3 秒死亡复活倒计时

        public static event Action<HitEventData> OnHitConfirmed;
        public static event Action<KillNoticeEventData> OnKillOccurred;

        /// <summary>Debug-only: protect entity id 1. Disabled by default; enable with --godmode.</summary>
        public static bool GodModeEnabled = false;

        /// <summary>
        /// 权威伤害结算函数（对标 g_combat.c::G_Damage）
        /// </summary>
        public static void ApplyDamage(PlayerBasicInfo target, PlayerBasicInfo? attacker, int rawDamage, int hitPart, string weaponName, bool ignoreArmor = false)
        {
            if (target == null || target.IsDead) return;
            if (GodModeEnabled && target.Id == 1) return;

            // 1. 部位伤害乘率：1=Head(2.5x), 2=Chest(1.0x), 3=Stomach(1.1x), 4=Arm(0.8x), 5=Leg(0.7x)
            float multiplier = hitPart switch
            {
                1 => 2.5f,
                2 => 1.0f,
                3 => 1.1f,
                4 => 0.8f,
                5 => 0.7f,
                _ => 1.0f
            };

            int finalDamage = ignoreArmor ? Math.Max(1, rawDamage) : Math.Max(1, (int)(rawDamage * multiplier));

            // 2. 护甲吸收计算 (对标 CheckArmor)
            int armorSave = ignoreArmor ? 0 : (int)Math.Ceiling(finalDamage * ARMOR_PROTECTION_RATIO);
            if (armorSave > target.Zhuangjia)
            {
                armorSave = target.Zhuangjia;
            }
            int hpDeduction = finalDamage - armorSave;

            target.Zhuangjia -= armorSave;
            target.Hp -= hpDeduction;

            // 3. 产生受击确认事件 (驱动客户端准星红叉与命中音效)
            var hitEvt = new HitEventData
            {
                AttackerId = attacker?.Id ?? 0,
                VictimId = target.Id,
                Damage = finalDamage,
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
                target.Hp = 0;
                target.IsDead = true;
                target.DeadTimer = 0f;
                target.LegsAnim = hitPart == 1 ? 42 : 59;
                target.TorsoAnim = hitPart == 1 ? 42 : 19;
                target.TorsoAnimStartTime = 0f;

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

        /// <summary>
        /// 复活倒计时推进与出生点重生
        /// </summary>
        public static void CheckRespawn(PlayerBasicInfo player, Physics.PlayerPhysicsState pState, float dt, float spawnX, float spawnY, float spawnZ)
        {
            if (!player.IsDead) return;

            if (player.DeadTimer >= RESPAWN_DELAY)
            {
                // 重生复活
                player.IsDead = false;
                player.Hp = 100;
                player.Zhuangjia = 100;
                player.Hudun = 0;
                player.DeadTimer = 0f;
                player.LifeBarSeq++; // 通知客户端刷新血条与实体状态

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
