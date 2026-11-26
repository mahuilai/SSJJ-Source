using System;
using System.Collections.Generic;
using System.Globalization;
using NetData;
using SSJJ.Server.Config;
using SSJJ.Server.Network;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;
using SSJJUserCmd;

namespace SSJJ.Server.QuakeServer
{
    public enum SkillMechanismKind
    {
        None = 0,
        DualFormTransform = 1,
        ChargedUltimate = 2,
        AreaWaveOrProjectile = 3,
        SelfAndAllyBuff = 4,
        MeleeHeroHeavyDerived = 5
    }

    public sealed record SkillPlan(
        SkillMechanismKind PrimaryKind,
        bool SupportsTransform,
        bool SupportsChargedActive,
        bool SupportsAreaWave,
        bool SupportsTeamBuff,
        bool SupportsMeleeDerived,
        int CooldownMs,
        int ActiveDurationMs,
        int PowerCost,
        int BonusShield,
        int HealAmount,
        float MoveSpeedScale,
        float FireRateScale,
        float DamageScale,
        float WaveRangeCm,
        float WaveMinCos,
        int WaveDamage,
        bool WavePiercesTargets);

    /// <summary>
    /// 服务端数据驱动武器技能、变形与特效系统：
    /// 全面对接 Weapon.json / WeaponSkill.json，驱动 BaseWeaponData (SpecialMode / WeaponEffectLevel /
    /// WeaponPower / WeaponPower2 / NextSkillTimer)、Method 27 SkillInfoData 与 Method 100 Key 60/61/65 特效生命周期。
    /// </summary>
    public sealed class SkillAndVfxSystem
    {
        private sealed class PlayerSkillRuntime
        {
            public double ActiveUntilSec;
            public double ShieldUntilSec;
            public double BuffUntilSec;
            public int PendingSkillId;
            public float RechargeAcc;
            public float Recharge2Acc;
            public float MoveSpeedScale = 1.0f;
            public float FireRateScale = 1.0f;
            public float DamageScale = 1.0f;
            public string? ActiveEffectKey;
            public double EffectExpireSec;
        }

        private readonly Dictionary<int, PlayerSkillRuntime> _runtime = new();
        private readonly GameTables _tables;
        private readonly OfficialPhysicsWorld _physics;
        private int _effectSeq = 1;

        public SkillAndVfxSystem(GameTables tables, OfficialPhysicsWorld physics)
        {
            _tables = tables;
            _physics = physics;
        }

        public static SkillPlan BuildPlan(Config.WeaponDef wDef, WeaponSkillDef? skillDef)
        {
            string name = wDef.Name ?? "";
            string atk = wDef.AttackType ?? "";
            string satk = wDef.SpecialAttackType ?? "";
            string sType = skillDef?.SpecialType ?? "";
            string sMode = skillDef?.Mode ?? "";
            string sProg = skillDef?.SkillType ?? "";
            string canUse = skillDef?.CanUse ?? "";

            bool hasDistinctSpecial = (!string.IsNullOrEmpty(satk) && !satk.Equals(atk, StringComparison.OrdinalIgnoreCase))
                || sMode.Contains("Deformation", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Legend", StringComparison.OrdinalIgnoreCase)
                || satk.Contains("DoubleScythe", StringComparison.OrdinalIgnoreCase)
                || satk.Contains("Laser", StringComparison.OrdinalIgnoreCase)
                || satk.Contains("Opticor", StringComparison.OrdinalIgnoreCase)
                || sType.Contains("Mirage", StringComparison.OrdinalIgnoreCase)
                || sType.Contains("Opticor", StringComparison.OrdinalIgnoreCase)
                || name.Contains("legend", StringComparison.OrdinalIgnoreCase);

            bool isBuff = canUse.Contains("Hormone", StringComparison.OrdinalIgnoreCase)
                || sProg.Contains("Hormone", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Shield", StringComparison.OrdinalIgnoreCase)
                || satk.Contains("Shield", StringComparison.OrdinalIgnoreCase)
                || sMode.Contains("Kriss", StringComparison.OrdinalIgnoreCase)
                || sMode.Contains("M4A1Hero", StringComparison.OrdinalIgnoreCase)
                || name.Contains("hero", StringComparison.OrdinalIgnoreCase)
                || name.Contains("shield", StringComparison.OrdinalIgnoreCase);

            bool isAreaWave = wDef.IsMelee
                || atk.Contains("Darts", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Burster", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Mikaduki", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("HanSword", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Shark", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Dragon", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Legend", StringComparison.OrdinalIgnoreCase)
                || satk.Contains("DoubleScythe", StringComparison.OrdinalIgnoreCase)
                || name.Contains("dragon", StringComparison.OrdinalIgnoreCase)
                || name.Contains("scythe", StringComparison.OrdinalIgnoreCase)
                || name.Contains("blade", StringComparison.OrdinalIgnoreCase)
                || name.Contains("thunder", StringComparison.OrdinalIgnoreCase)
                || name.Contains("pulse", StringComparison.OrdinalIgnoreCase)
                || name.Contains("crossbow", StringComparison.OrdinalIgnoreCase);

            bool isMeleeDerived = wDef.IsMelee
                && (skillDef != null || hasDistinctSpecial || wDef.IsGold
                    || name.Contains("legend", StringComparison.OrdinalIgnoreCase)
                    || name.Contains("hero", StringComparison.OrdinalIgnoreCase)
                    || name.Contains("gold", StringComparison.OrdinalIgnoreCase)
                    || name.Contains("blade", StringComparison.OrdinalIgnoreCase)
                    || name.Contains("scythe", StringComparison.OrdinalIgnoreCase)
                    || name.Contains("nunchakus", StringComparison.OrdinalIgnoreCase)
                    || name.Contains("axe", StringComparison.OrdinalIgnoreCase));

            bool isCharged = skillDef != null
                || isBuff
                || isAreaWave
                || hasDistinctSpecial
                || wDef.IsGold
                || wDef.IsMelee;

            SkillMechanismKind primary = SkillMechanismKind.None;
            if (isMeleeDerived) primary = SkillMechanismKind.MeleeHeroHeavyDerived;
            else if (hasDistinctSpecial && isAreaWave) primary = SkillMechanismKind.DualFormTransform;
            else if (isBuff) primary = SkillMechanismKind.SelfAndAllyBuff;
            else if (isAreaWave) primary = SkillMechanismKind.AreaWaveOrProjectile;
            else if (hasDistinctSpecial) primary = SkillMechanismKind.DualFormTransform;
            else if (isCharged) primary = SkillMechanismKind.ChargedUltimate;

            int cdMs = skillDef != null && skillDef.SpecialTimeMs > 1000
                ? skillDef.SpecialTimeMs
                : (wDef.IsMelee ? 5500 : wDef.WeaponType == 5 ? 8000 : 7000);
            int activeMs = Math.Clamp(cdMs / 2, 3000, 6000);
            int cost = sProg.Contains("Kill", StringComparison.OrdinalIgnoreCase) ? 50
                : (sProg.Contains("Mp", StringComparison.OrdinalIgnoreCase) ? 60 : 80);

            int shield = isBuff ? (wDef.IsMelee || atk.Contains("Shield", StringComparison.OrdinalIgnoreCase) ? 45 : 35) : 0;
            int heal = (isBuff || name.Contains("legend", StringComparison.OrdinalIgnoreCase) || name.Contains("hero", StringComparison.OrdinalIgnoreCase)) ? 20 : 0;
            float speedScale = isBuff ? 1.18f : 1.0f;
            float rateScale = (isBuff || sMode.Contains("Kriss", StringComparison.OrdinalIgnoreCase) || name.Contains("dragon", StringComparison.OrdinalIgnoreCase)) ? 0.78f : 1.0f;
            float dmgScale = (hasDistinctSpecial || name.Contains("legend", StringComparison.OrdinalIgnoreCase) || wDef.IsGold) ? 1.20f : 1.10f;

            bool isRangedWave = !wDef.IsMelee
                || atk.Contains("Darts", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Burster", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Mikaduki", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("HanSword", StringComparison.OrdinalIgnoreCase)
                || atk.Contains("Shark", StringComparison.OrdinalIgnoreCase)
                || satk.Contains("DoubleScythe", StringComparison.OrdinalIgnoreCase)
                || name.Contains("blade", StringComparison.OrdinalIgnoreCase)
                || name.Contains("saber", StringComparison.OrdinalIgnoreCase);

            float waveRange = isRangedWave ? 1400f : 420f;
            float waveCos = isRangedWave ? 0.88f : 0.25f;
            int waveDmg = isRangedWave ? 88 : 100;
            bool pierces = !isRangedWave || name.Contains("scythe", StringComparison.OrdinalIgnoreCase)
                || name.Contains("dragon", StringComparison.OrdinalIgnoreCase)
                || name.Contains("thunder", StringComparison.OrdinalIgnoreCase);

            return new SkillPlan(
                primary,
                hasDistinctSpecial,
                isCharged,
                isAreaWave,
                isBuff,
                isMeleeDerived,
                cdMs,
                activeMs,
                cost,
                shield,
                heal,
                speedScale,
                rateScale,
                dmgScale,
                waveRange,
                waveCos,
                waveDmg,
                pierces);
        }

        public void ResetPlayer(PlayerBasicInfo p)
        {
            _runtime[p.Id] = new PlayerSkillRuntime();
            p.SpecialMode = false;
            p.WeaponEffectLevel = 0;
            p.WeaponPower = 100;
            p.WeaponMaxPower = 100;
            p.WeaponPower2 = 100;
            p.WeaponMaxPower2 = 100;
            p.NextSkillTimer = 0;
            p.Hudun = 0;
        }

        public void RemovePlayer(int id) => _runtime.Remove(id);

        public float GetEffectiveMoveSpeed(PlayerBasicInfo p, Config.WeaponDef wDef)
        {
            float baseSpeed = wDef.GetMoveSpeed(p.Fov);
            if (_runtime.TryGetValue(p.Id, out var rt))
            {
                if (rt.BuffUntilSec > 0) baseSpeed *= rt.MoveSpeedScale;
                if (p.SpecialMode) baseSpeed *= 1.06f;
            }
            return baseSpeed;
        }

        public int GetEffectiveAttackIntervalMs(PlayerBasicInfo p, Config.WeaponDef wDef)
        {
            int interval = wDef.AttackIntervalMs;
            if (_runtime.TryGetValue(p.Id, out var rt) && rt.BuffUntilSec > 0)
            {
                interval = Math.Max(40, (int)MathF.Round(interval * rt.FireRateScale));
            }
            return interval;
        }

        public float GetEffectiveDamageMultiplier(PlayerBasicInfo p)
        {
            float mult = 1.0f;
            if (_runtime.TryGetValue(p.Id, out var rt) && rt.ActiveUntilSec > 0)
            {
                mult = Math.Max(mult, rt.DamageScale);
            }
            if (p.SpecialMode) mult = Math.Max(mult, 1.12f);
            return mult;
        }

        public void OnKillScored(PlayerBasicInfo? killer)
        {
            if (killer == null || killer.IsDead) return;
            killer.WeaponPower = Math.Min(killer.WeaponMaxPower, killer.WeaponPower + 25);
            killer.WeaponPower2 = Math.Min(killer.WeaponMaxPower2, killer.WeaponPower2 + 25);
        }

        public SkillPlan? ProcessCommand(
            PlayerBasicInfo p,
            DecodedUserCmd cmd,
            int prevButtons,
            double nowSec,
            bool freeForAll,
            bool isDefusingC4,
            IReadOnlyList<PlayerBasicInfo> allEntities,
            TcpBattleGateway tcp)
        {
            if (p.IsDead) return null;
            if (!_runtime.TryGetValue(p.Id, out var rt))
            {
                rt = new PlayerSkillRuntime();
                _runtime[p.Id] = rt;
            }

            var wDef = _tables.GetWeapon(p.CurrentWeaponName);
            _tables.TryGetSkill(p.CurrentWeaponName, out var skillDef);
            var plan = BuildPlan(wDef, skillDef);

            bool reloadPressed = (cmd.Buttons & ButtonConstant.Reload) != 0 && (prevButtons & ButtonConstant.Reload) == 0;
            bool skillPressed = (cmd.Buttons & ButtonConstant.Skill) != 0 && (prevButtons & ButtonConstant.Skill) == 0;
            bool demoPressed = !isDefusingC4 && (cmd.Buttons & ButtonConstant.Demolition) != 0 && (prevButtons & ButtonConstant.Demolition) == 0;
            bool inspectPressed = (cmd.Buttons & ButtonConstant.Showgun) != 0 && (prevButtons & ButtonConstant.Showgun) == 0;

            // 1. 双形态/变形切换（近战 R/E 或枪械特殊形态 E / 特殊 V 切换）
            bool wantsTransform = plan.SupportsTransform
                && ((reloadPressed && wDef.IsMelee) || demoPressed || (inspectPressed && !wDef.IsMelee && skillDef?.Mode.Contains("Deformation", StringComparison.OrdinalIgnoreCase) == true));
            if (wantsTransform)
            {
                p.SpecialMode = !p.SpecialMode;
                if (p.SpecialMode) p.WeaponEffectLevel |= 0x01;
                else p.WeaponEffectLevel &= ~0x01;
                rt.PendingSkillId = skillDef?.Id ?? 1;
                EmitWeaponSkillEffect(p, plan, rt, nowSec, tcp, effectTag: "transform");
            }

            // 2. 主动充能技能释放（F 键 Skill=4096 或非变形武器 E 键）
            bool wantsSkill = skillPressed || (demoPressed && !plan.SupportsTransform);
            if (wantsSkill && plan.SupportsChargedActive && cmd.RenderTime >= p.NextSkillTimer && p.WeaponPower >= plan.PowerCost)
            {
                p.NextSkillTimer = cmd.RenderTime + plan.CooldownMs;
                p.WeaponPower = Math.Max(0, p.WeaponPower - plan.PowerCost);
                p.WeaponPower2 = Math.Max(0, p.WeaponPower2 - plan.PowerCost / 2);
                p.WeaponEffectLevel |= 0x3E; // 激活 1..5 号武器技能粒子位
                rt.ActiveUntilSec = nowSec + plan.ActiveDurationMs / 1000.0;
                rt.PendingSkillId = skillDef?.Id ?? Math.Max(1, Math.Abs(p.CurrentWeaponName.GetHashCode()) % 400 + 1);

                tcp.BroadcastSkillInfo(new SkillInfoData
                {
                    Id = p.Id,
                    SkillName = rt.PendingSkillId,
                    CdTime = plan.CooldownMs,
                    CurrentCdTime = plan.CooldownMs,
                    Energy = p.WeaponPower,
                    Kind = 10,
                    IsSilent = false
                });

                EmitWeaponSkillEffect(p, plan, rt, nowSec, tcp, effectTag: "active");
                ApplySkillGameplayEffect(p, wDef, skillDef, plan, nowSec, rt, freeForAll, allEntities);
            }

            return plan;
        }

        public int TriggerMeleeHeavyDerived(
            PlayerBasicInfo caster,
            Config.WeaponDef wDef,
            double nowSec,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> allEntities,
            TcpBattleGateway? tcp)
        {
            _tables.TryGetSkill(wDef.Name, out var skillDef);
            var plan = BuildPlan(wDef, skillDef);
            if (!plan.SupportsMeleeDerived) return 0;

            if (!_runtime.TryGetValue(caster.Id, out var rt))
            {
                rt = new PlayerSkillRuntime();
                _runtime[caster.Id] = rt;
            }
            caster.WeaponEffectLevel |= 0x06;
            rt.ActiveUntilSec = Math.Max(rt.ActiveUntilSec, nowSec + 1.2);
            if (tcp != null)
            {
                EmitWeaponSkillEffect(caster, plan, rt, nowSec, tcp, effectTag: "heavy");
            }
            return CastWaveAttack(caster, wDef, plan with { WaveRangeCm = Math.Max(plan.WaveRangeCm, 380f), WaveDamage = 75 }, freeForAll, allEntities);
        }

        public void Tick(float dt, double nowSec, IReadOnlyList<PlayerBasicInfo> players, TcpBattleGateway? tcp = null)
        {
            for (int i = 0; i < players.Count; i++)
            {
                var p = players[i];
                if (!_runtime.TryGetValue(p.Id, out var rt)) continue;

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
                if (p.WeaponPower2 < p.WeaponMaxPower2)
                {
                    rt.Recharge2Acc += dt * 10f;
                    int add2 = (int)rt.Recharge2Acc;
                    if (add2 > 0)
                    {
                        rt.Recharge2Acc -= add2;
                        p.WeaponPower2 = Math.Min(p.WeaponMaxPower2, p.WeaponPower2 + add2);
                    }
                }

                if (rt.ActiveUntilSec > 0 && nowSec >= rt.ActiveUntilSec)
                {
                    rt.ActiveUntilSec = 0;
                    rt.DamageScale = 1.0f;
                    p.WeaponEffectLevel = p.SpecialMode ? (p.WeaponEffectLevel & 0x101) : (p.WeaponEffectLevel & 0x100);
                }

                if (rt.BuffUntilSec > 0 && nowSec >= rt.BuffUntilSec)
                {
                    rt.BuffUntilSec = 0;
                    rt.MoveSpeedScale = 1.0f;
                    rt.FireRateScale = 1.0f;
                }

                if (rt.ShieldUntilSec > 0 && nowSec >= rt.ShieldUntilSec)
                {
                    rt.ShieldUntilSec = 0;
                    p.Hudun = 0;
                }

                if (rt.ActiveEffectKey != null && nowSec >= rt.EffectExpireSec)
                {
                    if (tcp != null)
                    {
                        var del = new SimpleProto { Key = 65 };
                        del.Ss.Add(rt.ActiveEffectKey);
                        tcp.BroadcastSimpleProto(del);
                    }
                    rt.ActiveEffectKey = null;
                }
            }
        }

        private void ApplySkillGameplayEffect(
            PlayerBasicInfo caster,
            Config.WeaponDef wDef,
            WeaponSkillDef? skillDef,
            SkillPlan plan,
            double nowSec,
            PlayerSkillRuntime rt,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> allEntities)
        {
            rt.DamageScale = plan.DamageScale;

            if (plan.HealAmount > 0 && !caster.IsDead)
            {
                caster.Hp = Math.Min(caster.MaxHp, caster.Hp + plan.HealAmount);
            }

            if (plan.SupportsTeamBuff)
            {
                rt.BuffUntilSec = nowSec + plan.ActiveDurationMs / 1000.0;
                rt.MoveSpeedScale = plan.MoveSpeedScale;
                rt.FireRateScale = plan.FireRateScale;

                if (plan.BonusShield > 0)
                {
                    caster.Hudun = Math.Max(caster.Hudun, plan.BonusShield);
                    rt.ShieldUntilSec = nowSec + 5.0;
                }

                // 队友光环增益（450cm 内存活队友享有一半护盾/回血与加速持续时间）
                if (!freeForAll)
                {
                    for (int i = 0; i < allEntities.Count; i++)
                    {
                        var ally = allEntities[i];
                        if (ally.Id == caster.Id || ally.IsDead || ally.Team != caster.Team) continue;
                        float dx = ally.PosX - caster.PosX;
                        float dy = ally.PosY - caster.PosY;
                        float dz = ally.PosZ - caster.PosZ;
                        if (dx * dx + dy * dy + dz * dz > 450f * 450f) continue;

                        if (plan.BonusShield > 0)
                        {
                            ally.Hudun = Math.Max(ally.Hudun, Math.Max(15, plan.BonusShield / 2));
                            if (!_runtime.TryGetValue(ally.Id, out var allyRt))
                            {
                                allyRt = new PlayerSkillRuntime();
                                _runtime[ally.Id] = allyRt;
                            }
                            allyRt.ShieldUntilSec = Math.Max(allyRt.ShieldUntilSec, nowSec + 4.0);
                            allyRt.BuffUntilSec = Math.Max(allyRt.BuffUntilSec, nowSec + 4.0);
                            allyRt.MoveSpeedScale = Math.Max(allyRt.MoveSpeedScale, 1.10f);
                        }
                        if (plan.HealAmount > 0)
                        {
                            ally.Hp = Math.Min(ally.MaxHp, ally.Hp + Math.Max(10, plan.HealAmount / 2));
                        }
                    }
                }
            }

            if (plan.SupportsAreaWave)
            {
                int hitCount = CastWaveAttack(caster, wDef, plan, freeForAll, allEntities);
                Console.WriteLine($"[SSJJ-Server][SKILL] {caster.PlayerName} casted {caster.CurrentWeaponName} (tpl={plan.PrimaryKind}, range={plan.WaveRangeCm:F0}, hits={hitCount})");
            }
        }

        private int CastWaveAttack(
            PlayerBasicInfo caster,
            Config.WeaponDef wDef,
            SkillPlan plan,
            bool freeForAll,
            IReadOnlyList<PlayerBasicInfo> allEntities)
        {
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
                if (dist2D > plan.WaveRangeCm || dz > 180f) continue;

                if (dist2D > 1f)
                {
                    float cos = (dx * fwdX + dy * fwdY) / dist2D;
                    if (cos < plan.WaveMinCos) continue;
                }

                if (_physics.IsReady &&
                    !_physics.TraceRayClear(muzzleX, muzzleY, muzzleZ, target.PosX, target.PosY, target.PosZ + 110f, out _))
                {
                    continue;
                }

                G_Combat.ApplyDamage(target, caster, plan.WaveDamage, 2, wDef.Name, ignoreArmor: false, armorPenetration: 0.85f);
                hitCount++;
                if (!plan.WavePiercesTargets) break;
            }
            return hitCount;
        }

        private void EmitWeaponSkillEffect(
            PlayerBasicInfo caster,
            SkillPlan plan,
            PlayerSkillRuntime rt,
            double nowSec,
            TcpBattleGateway tcp,
            string effectTag)
        {
            if (rt.ActiveEffectKey != null)
            {
                var cleanup = new SimpleProto { Key = 65 };
                cleanup.Ss.Add(rt.ActiveEffectKey);
                tcp.BroadcastSimpleProto(cleanup);
            }

            string key = $"skill_vfx_{caster.Id}_{_effectSeq++}";
            rt.ActiveEffectKey = key;
            rt.EffectExpireSec = nowSec + Math.Clamp(plan.ActiveDurationMs / 1000.0, 1.5, 4.0);

            // Key 60 = EffectCreateHandler (需 Ss>=4, Bs>=2, Ks>=1, Fs>=9)
            var create = new SimpleProto { Key = 60 };
            create.Ss.Add(key);
            create.Ss.Add("");
            create.Ss.Add("");
            create.Ss.Add(string.Create(CultureInfo.InvariantCulture, $"{caster.PosX:F1},{caster.PosY:F1},{caster.PosZ:F1}"));
            create.Bs.Add(true);
            create.Bs.Add(false);
            create.Bs.Add(true);
            create.Ks.Add(0);
            float yawRad = caster.ViewYaw * MathF.PI / 180f;
            create.Fs.Add(caster.PosX + MathF.Cos(yawRad) * 65f);
            create.Fs.Add(caster.PosY + MathF.Sin(yawRad) * 65f);
            create.Fs.Add(caster.PosZ + caster.ViewHeight - 15f);
            create.Fs.Add(0f);
            create.Fs.Add(caster.ViewYaw);
            create.Fs.Add(0f);
            create.Fs.Add(1f);
            create.Fs.Add(1f);
            create.Fs.Add(1f);
            tcp.BroadcastSimpleProto(create);

            // Key 61 = EffectShowHandler
            var show = new SimpleProto { Key = 61 };
            show.Ks.Add(Math.Max(800, plan.ActiveDurationMs / 2));
            show.Ss.Add(key);
            tcp.BroadcastSimpleProto(show);

            // Key 1 = UI_JUMP_MESSAGE 提示
            var tip = new SimpleProto { Key = 1 };
            tip.Ss.Add(effectTag == "transform"
                ? $"[{caster.CurrentWeaponName}] 形态切换 ({(caster.SpecialMode ? "特殊" : "常规")})"
                : $"[{caster.CurrentWeaponName}] 技能激活");
            tcp.BroadcastSimpleProto(tip);
        }
    }
}
