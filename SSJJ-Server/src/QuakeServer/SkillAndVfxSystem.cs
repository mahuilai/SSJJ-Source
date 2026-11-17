using System;
using System.Collections.Generic;
using NetData;
using SSJJ.Server.Config;
using SSJJ.Server.Network;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;
using SSJJUserCmd;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 服务端数据驱动武器技能、变形与特效系统：
    /// 对接 Weapon.json / WeaponSkill.json，驱动 BaseWeaponData.SpecialMode / EffectLevel / Power / NextSkillTimer
    /// 以及 Method 27 SkillInfoData / Method 100 SimpleProto (EffectCreate/Show/Delete)
    /// </summary>
    public sealed class SkillAndVfxSystem
    {
        private sealed class PlayerSkillRuntime
        {
            public double ActiveUntilSec;
            public double ShieldUntilSec;
            public int PendingSkillId;
            public float RechargeAcc;
        }

        private readonly Dictionary<int, PlayerSkillRuntime> _runtime = new Dictionary<int, PlayerSkillRuntime>();
        private readonly GameTables _tables;
        private readonly OfficialPhysicsWorld _physics;

        public SkillAndVfxSystem(GameTables tables, OfficialPhysicsWorld physics)
        {
            _tables = tables;
            _physics = physics;
        }

        public void ResetPlayer(PlayerBasicInfo p)
        {
            _runtime[p.Id] = new PlayerSkillRuntime();
            p.SpecialMode = false;
            p.WeaponEffectLevel = 0;
            p.WeaponPower = 100;
            p.WeaponMaxPower = 100;
            p.WeaponPower2 = 0;
            p.WeaponMaxPower2 = 100;
            p.NextSkillTimer = 0;
            p.Hudun = 0;
        }

        public void ProcessCommand(
            PlayerBasicInfo p,
            DecodedUserCmd cmd,
            int prevButtons,
            double nowSec,
            bool freeForAll,
            bool isDefusingC4,
            IReadOnlyList<PlayerBasicInfo> allEntities,
            TcpBattleGateway tcp)
        {
            if (p.IsDead) return;
            if (!_runtime.TryGetValue(p.Id, out var rt))
            {
                rt = new PlayerSkillRuntime();
                _runtime[p.Id] = rt;
            }

            var wDef = _tables.GetWeapon(p.CurrentWeaponName);
            _tables.TryGetSkill(p.CurrentWeaponName, out var skillDef);

            bool reloadPressed = (cmd.Buttons & ButtonConstant.Reload) != 0 && (prevButtons & ButtonConstant.Reload) == 0;
            bool skillPressed = (cmd.Buttons & ButtonConstant.Skill) != 0 && (prevButtons & ButtonConstant.Skill) == 0;
            bool demoPressed = !isDefusingC4 && (cmd.Buttons & ButtonConstant.Demolition) != 0 && (prevButtons & ButtonConstant.Demolition) == 0;
            bool showPressed = (cmd.Buttons & ButtonConstant.Showgun) != 0 && (prevButtons & ButtonConstant.Showgun) == 0;

            // 1. 武器变形切换（R 键近战变形如 DoubleScythe/MirageDouBlade，或特殊武器 E 键变形）
            bool hasDistinctSpecial = !string.IsNullOrEmpty(wDef.SpecialAttackType) &&
                                      !wDef.SpecialAttackType.Equals(wDef.AttackType, StringComparison.OrdinalIgnoreCase);
            bool isTransformWeapon = hasDistinctSpecial ||
                                     wDef.AttackType.Contains("Scythe", StringComparison.OrdinalIgnoreCase) ||
                                     wDef.AttackType.Contains("Saw", StringComparison.OrdinalIgnoreCase) ||
                                     wDef.SpecialAttackType.Contains("DoubleScythe", StringComparison.OrdinalIgnoreCase) ||
                                     wDef.SpecialAttackType.Contains("Laser", StringComparison.OrdinalIgnoreCase) ||
                                     wDef.SpecialAttackType.Contains("Opticor", StringComparison.OrdinalIgnoreCase);

            if ((reloadPressed && wDef.IsMelee && isTransformWeapon) || (demoPressed && isTransformWeapon))
            {
                p.SpecialMode = !p.SpecialMode;
                if (p.SpecialMode)
                {
                    p.WeaponEffectLevel |= 0x01;
                }
                else
                {
                    p.WeaponEffectLevel &= ~0x01;
                }
                Console.WriteLine($"[SSJJ-Server][SKILL] Player {p.Id} weapon={p.CurrentWeaponName} transform SpecialMode={p.SpecialMode} EffectLevel={p.WeaponEffectLevel}");
            }

            // 2. 检视武器特效点亮 (V 键)
            if (showPressed)
            {
                p.WeaponEffectLevel ^= 0x100; // 256: AbyssPistol/Showgun 检视光效位
            }

            // 3. 主动技能释放 (F 键 Skill=4096 或 E 键 Demolition=2048，前提有 Skill 配置或特殊近战/英雄武器)
            bool wantsSkill = skillPressed || (demoPressed && !isTransformWeapon);
            bool hasActiveSkill = skillDef != null || wDef.IsMelee || !string.IsNullOrEmpty(wDef.SpecialAttackType);
            if (wantsSkill && hasActiveSkill && cmd.RenderTime >= p.NextSkillTimer)
            {
                int cdMs = skillDef != null && skillDef.SpecialTimeMs > 1000 ? skillDef.SpecialTimeMs : 7000;
                int activeSec = Math.Clamp(cdMs / 2000, 3, 6);

                p.NextSkillTimer = cmd.RenderTime + cdMs;
                p.WeaponPower = 0;
                p.WeaponEffectLevel |= 0x3E; // 激活 1..5 号武器技能粒子位
                rt.ActiveUntilSec = nowSec + activeSec;
                rt.PendingSkillId = skillDef?.Id ?? 1;

                // 下发 Method 27 技能 CD/能量条包
                tcp.BroadcastSkillInfo(new SkillInfoData
                {
                    Id = p.Id,
                    SkillName = rt.PendingSkillId,
                    CdTime = cdMs,
                    CurrentCdTime = cdMs,
                    Energy = 0,
                    Kind = 10,
                    IsSilent = false
                });

                // 下发服务端 SimpleProto 特效提示 / 光环事件
                EmitWeaponSkillEffect(p, wDef, skillDef, tcp);

                // 执行技能实战效果（近战技能旋风斩/剑气波/飞刀突刺 + 护盾增益）
                ApplySkillGameplayEffect(p, wDef, skillDef, nowSec, rt, freeForAll, allEntities);
            }
        }

        public void Tick(float dt, double nowSec, IReadOnlyList<PlayerBasicInfo> players)
        {
            for (int i = 0; i < players.Count; i++)
            {
                var p = players[i];
                if (!_runtime.TryGetValue(p.Id, out var rt)) continue;

                // 能量平滑充能 (约12%/s)
                if (p.WeaponPower < p.WeaponMaxPower)
                {
                    rt.RechargeAcc += dt * 15f;
                    int add = (int)rt.RechargeAcc;
                    if (add > 0)
                    {
                        rt.RechargeAcc -= add;
                        p.WeaponPower = Math.Min(p.WeaponMaxPower, p.WeaponPower + add);
                    }
                }

                // 技能主动特效期满自动清除粒子位（保留 SpecialMode 变形位 bit0）
                if (rt.ActiveUntilSec > 0 && nowSec >= rt.ActiveUntilSec)
                {
                    rt.ActiveUntilSec = 0;
                    p.WeaponEffectLevel = p.SpecialMode ? (p.WeaponEffectLevel & 0x101) : (p.WeaponEffectLevel & 0x100);
                }

                // 护盾过期衰减
                if (rt.ShieldUntilSec > 0 && nowSec >= rt.ShieldUntilSec)
                {
                    rt.ShieldUntilSec = 0;
                    p.Hudun = 0;
                }
            }
        }

        private void ApplySkillGameplayEffect(
            PlayerBasicInfo caster,
            Config.WeaponDef wDef,
            WeaponSkillDef? skillDef,
            double nowSec,
            PlayerSkillRuntime rt,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> allEntities)
        {
            string atk = wDef.AttackType ?? "";
            string satk = wDef.SpecialAttackType ?? "";
            bool isShieldOrStim = (skillDef?.CanUse.Contains("Hormone", StringComparison.OrdinalIgnoreCase) ?? false) ||
                                  atk.Contains("Shield", StringComparison.OrdinalIgnoreCase) ||
                                  satk.Contains("Mirage", StringComparison.OrdinalIgnoreCase);

            if (isShieldOrStim)
            {
                caster.Hudun = Math.Max(caster.Hudun, 35);
                rt.ShieldUntilSec = nowSec + 5.0;
            }

            // 若是近战或特殊剑气/飞镖武器，执行范围斩击 / 远程飞刀判定
            if (wDef.IsMelee || caster.CurrentWeapon == 3)
            {
                bool isRangedWave = atk.Contains("Darts", StringComparison.OrdinalIgnoreCase) ||
                                    atk.Contains("Burster", StringComparison.OrdinalIgnoreCase) ||
                                    atk.Contains("Mikaduki", StringComparison.OrdinalIgnoreCase) ||
                                    atk.Contains("HanSword", StringComparison.OrdinalIgnoreCase) ||
                                    atk.Contains("Shark", StringComparison.OrdinalIgnoreCase) ||
                                    satk.Contains("DoubleScythe", StringComparison.OrdinalIgnoreCase);

                float range = isRangedWave ? 1400f : 420f;
                float minCos = isRangedWave ? 0.92f : 0.25f; // 远程直线飞镖 vs 近战大扇形斩击
                int dmg = isRangedWave ? 90 : 100;

                float muzzleX = caster.PosX;
                float muzzleY = caster.PosY;
                float muzzleZ = caster.PosZ + (caster.ViewHeight - 8f);
                float yawRad = caster.ViewYaw * (float)Math.PI / 180f;
                float fwdX = (float)Math.Cos(yawRad);
                float fwdY = (float)Math.Sin(yawRad);

                int hitCount = 0;
                for (int i = 0; i < allEntities.Count; i++)
                {
                    var target = allEntities[i];
                    if (target.Id == caster.Id || target.IsDead) continue;
                    if (!freeForAll && target.Team == caster.Team) continue;

                    float dx = target.PosX - caster.PosX;
                    float dy = target.PosY - caster.PosY;
                    float dz = Math.Abs(target.PosZ - caster.PosZ);
                    float dist2D = (float)Math.Sqrt(dx * dx + dy * dy);
                    if (dist2D > range || dz > 180f) continue;

                    if (dist2D > 1f)
                    {
                        float cos = (dx * fwdX + dy * fwdY) / dist2D;
                        if (cos < minCos) continue;
                    }

                    if (_physics.IsReady &&
                        !_physics.TraceRayClear(muzzleX, muzzleY, muzzleZ, target.PosX, target.PosY, target.PosZ + 110f, out _))
                    {
                        continue;
                    }

                    G_Combat.ApplyDamage(target, caster, dmg, 2, caster.CurrentWeaponName, ignoreArmor: true);
                    hitCount++;
                    if (isRangedWave) break; // 飞镖类命中首个目标停止
                }

                Console.WriteLine($"[SSJJ-Server][SKILL] {caster.PlayerName} casted {caster.CurrentWeaponName} skill (range={range:F0}, hits={hitCount})");
            }
        }

        private static void EmitWeaponSkillEffect(PlayerBasicInfo caster, Config.WeaponDef wDef, WeaponSkillDef? skillDef, TcpBattleGateway tcp)
        {
            // Key 1 = UI_JUMP_MESSAGE (系统提示通知)
            var tip = new SimpleProto { Key = 1 };
            tip.Ss.Add($"[{caster.CurrentWeaponName}] 技能激活");
            tcp.BroadcastSimpleProto(tip);
        }
    }
}
