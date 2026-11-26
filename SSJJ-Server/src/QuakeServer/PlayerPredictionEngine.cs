using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using SSJJ.Server.Snapshot;
using WeaponDef = SSJJ.Server.Config.WeaponDef;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 1:1 对齐客户端 20 个 IPredicationInitSystem 的权威预测状态机：
    /// 覆盖 ClientTime、MoveYaw、PunchOrientation/DecayTime、Fov/Zoom、
    /// LegAnim/ScaledEclipsedTime、ViewAnim、Reload(含霰弹单发装填) 与 Accuracy/ShotsFired。
    /// </summary>
    public static class PlayerPredictionEngine
    {
        public static void AdvanceClientTime(PlayerBasicInfo p, int frameIntervalMs)
        {
            p.ClientTime += Math.Max(0, frameIntervalMs);
        }

        public static float WrapAngle180(float angle)
        {
            while (angle > 180f) angle -= 360f;
            while (angle < -180f) angle += 360f;
            return angle;
        }

        public static void UpdateMoveYaw(PlayerBasicInfo p, float cameraYaw, bool isForward, bool isBackward, bool isLeft, bool isRight)
        {
            if (!isForward && !isBackward && !isLeft && !isRight) return;

            float finalMoveYaw = cameraYaw;
            if (isForward)
            {
                if (isLeft) finalMoveYaw = cameraYaw + 45f;
                else if (isRight) finalMoveYaw = cameraYaw - 45f;
            }
            else if (isBackward)
            {
                if (isLeft) finalMoveYaw = cameraYaw + 135f;
                else if (isRight) finalMoveYaw = cameraYaw - 135f;
                else finalMoveYaw = cameraYaw + 180f;
            }
            else if (isLeft) finalMoveYaw = cameraYaw + 90f;
            else if (isRight) finalMoveYaw = cameraYaw - 90f;

            p.MoveYaw = WrapAngle180(finalMoveYaw);
        }

        /// <summary>
        /// 1:1 对齐 PlayerPunchOrientationPredictionSystem.OnPredicate
        /// </summary>
        public static void StepPunchAndDecay(PlayerBasicInfo p, int frameIntervalMs)
        {
            if (p.IsDead) return;
            if (p.DecayTime > 0)
            {
                p.DecayTime -= frameIntervalMs;
                if (p.DecayTime < 0) p.DecayTime = 0;
                return;
            }

            float py = p.PunchYaw;
            float pp = p.PunchPitch;
            float dt = frameIntervalMs / 1000f;
            float len = (float)Math.Sqrt(py * py + pp * pp);
            if (len > 0f)
            {
                py /= len;
                pp /= len;
                len -= (10f + len * 0.5f) * dt;
                if (len < 0f) len = 0f;
                p.PunchYaw = py * len;
                p.PunchPitch = pp * len;
            }
        }

        /// <summary>
        /// 1:1 对齐 LegPredictionUtility + PlayerLegPredictionSystem + LegAnimStateInfo.GetAnimSpeed
        /// </summary>
        public static void UpdateLegsAnimAndSpeedTime(
            PlayerBasicInfo p,
            bool onGround,
            int duckState,
            int velocity2D,
            bool isWalk,
            bool isBackward,
            int frameIntervalMs)
        {
            int prevLegsAnim = p.LegsAnim;
            if (!onGround)
            {
                if (prevLegsAnim != 5 && prevLegsAnim != 340)
                {
                    p.LegsAnim = 5;
                    p.LegsAnimRemainMs = 499;
                }
                else if (prevLegsAnim == 5)
                {
                    p.LegsAnimRemainMs = Math.Max(0, p.LegsAnimRemainMs - frameIntervalMs);
                    if (p.LegsAnimRemainMs == 0)
                    {
                        p.LegsAnim = 340;
                    }
                }
            }
            else if (prevLegsAnim == 5 || prevLegsAnim == 340)
            {
                p.LegsAnim = 6;
                p.LegsAnimRemainMs = 280;
            }
            else if (prevLegsAnim == 6 && p.LegsAnimRemainMs > frameIntervalMs)
            {
                p.LegsAnimRemainMs -= frameIntervalMs;
                p.LegsAnim = 6;
            }
            else if (p.Moving)
            {
                p.LegsAnimRemainMs = 0;
                if (duckState == 0) p.LegsAnim = isBackward ? 10 : 9;
                else if (!isWalk && velocity2D > 310) p.LegsAnim = isBackward ? 2 : 1;
                else p.LegsAnim = isBackward ? 4 : 3;
            }
            else
            {
                p.LegsAnimRemainMs = 0;
                p.LegsAnim = duckState == 0 ? 8 : 7;
            }

            if (p.LegsAnim != prevLegsAnim)
            {
                p.LegsSpeedAnimTime = 0f;
            }

            float legAnimSpeed = (p.LegsAnim == 1 || p.LegsAnim == 2) ? velocity2D * 0.0016f : 1f;
            // PlayerLegPredictionSystem truncates EACH command's scaled interval to int.
            // Accumulating fractions until snapshot serialization causes a growing drift.
            p.LegsSpeedAnimTime += (int)(frameIntervalMs * legAnimSpeed);
        }

        /// <summary>
        /// 狙击枪开镜 FOV 切换 (90 -> 40 -> 15 -> 90) 与开火后 ResumeZoom 自动恢复
        /// </summary>
        public static void StepSniperZoom(PlayerBasicInfo p, WeaponDef wDef, bool secondaryPressed, bool fired)
        {
            if (wDef.WeaponType != 5)
            {
                if (p.Fov != 90) { p.Fov = 90; p.LastFov = 90; p.ResumeZoom = false; }
                return;
            }

            if (p.ResumeZoom && p.ClientTime >= p.NextAttackTimer)
            {
                p.Fov = p.LastFov;
                p.ResumeZoom = false;
            }

            if (fired && p.Fov != 90)
            {
                p.LastFov = p.Fov;
                p.Fov = 90;
                p.ResumeZoom = true;
            }
            else if (secondaryPressed)
            {
                p.LastFov = p.Fov;
                p.Fov = p.Fov switch
                {
                    90 => 40,
                    40 => 15,
                    _ => 90
                };
                p.ResumeZoom = false;
            }
        }

        /// <summary>
        /// 换弹状态机（区分霰弹枪单发循环装填与步枪/手枪整匣装填，开火打断霰弹装填）
        /// </summary>
        public static void StepReload(PlayerBasicInfo p, WeaponDef wDef, bool reloadPressed, bool attackDown)
        {
            bool isShotgun = wDef.WeaponType == 6;

            if (isShotgun && p.IsStartReload && attackDown && p.CurrentClip > 0)
            {
                // ShotGunReloadPredicationSystem: 有子弹时开火立即打断装填
                p.IsStartReload = false;
                p.ReloadEndTime = 0;
                p.ViewAnim = 13;
                p.ViewAnimRemainMs = 0;
                return;
            }

            if (p.IsStartReload && p.ClientTime >= p.ReloadEndTime)
            {
                if (isShotgun)
                {
                    if (p.CurrentClip < p.MaxClip && p.CurrentCarryClip > 0)
                    {
                        p.CurrentClip++;
                        p.CurrentCarryClip--;
                    }
                    if (p.CurrentClip < p.MaxClip && p.CurrentCarryClip > 0)
                    {
                        // 继续装填下一发
                        p.ReloadEndTime = p.ClientTime + 450;
                        p.NextAttackTimer = p.ClientTime + 450;
                        p.ViewAnim = 17;
                        p.ViewAnimRemainMs = 450;
                    }
                    else
                    {
                        p.IsStartReload = false;
                        p.ReloadEndTime = 0;
                        p.ViewAnim = 13;
                        p.ViewAnimRemainMs = 0;
                    }
                }
                else
                {
                    p.IsStartReload = false;
                    if (p.MaxClip > 0 && p.CurrentClip < p.MaxClip && p.CurrentCarryClip > 0)
                    {
                        int need = Math.Min(p.MaxClip - p.CurrentClip, p.CurrentCarryClip);
                        p.CurrentClip += need;
                        p.CurrentCarryClip -= need;
                    }
                }
            }
            else if (reloadPressed && !p.IsStartReload && p.MaxClip > 0 && p.CurrentClip < p.MaxClip && p.CurrentCarryClip > 0)
            {
                int durMs = isShotgun ? 450 : GetDefaultViewAnimDurationMs(wDef, 17);
                p.IsStartReload = true;
                p.ReloadEndTime = p.ClientTime + durMs;
                p.NextAttackTimer = p.ClientTime + durMs;
                p.ViewAnim = 17;
                p.LeftViewAnim = 17;
                p.ViewAnimRemainMs = durMs;
                p.Fov = 90;
                p.LastFov = 90;
                p.ResumeZoom = false;
            }
        }

        private static readonly Lazy<Dictionary<string, Dictionary<string, int>>> _weaponAnimDurations = new(() => LoadWeaponAnimDurations());

        private static Dictionary<string, Dictionary<string, int>> LoadWeaponAnimDurations()
        {
            var result = new Dictionary<string, Dictionary<string, int>>(StringComparer.OrdinalIgnoreCase);
            try
            {
                string[] candidates =
                {
                    Path.Combine(AppContext.BaseDirectory, "Data", "weapon_anim_durations.json"),
                    Path.Combine(AppContext.BaseDirectory, "weapon_anim_durations.json"),
                    Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "Data", "weapon_anim_durations.json")),
                    Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "SSJJ-Server", "Data", "weapon_anim_durations.json"))
                };
                foreach (var path in candidates)
                {
                    if (!File.Exists(path)) continue;
                    var parsed = JsonSerializer.Deserialize<Dictionary<string, Dictionary<string, int>>>(File.ReadAllText(path));
                    if (parsed != null)
                    {
                        foreach (var kv in parsed) result[kv.Key] = kv.Value;
                        break;
                    }
                }
            }
            catch { }
            return result;
        }

        private static readonly Dictionary<string, int> ActionIds = LoadActionIds();

        private static Dictionary<string, int> LoadActionIds()
        {
            var ids = new Dictionary<string, int>(StringComparer.Ordinal);
            foreach (var field in typeof(share.constant.AnimationConstant).GetFields(
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static))
            {
                if (field.GetValue(null) is int id) ids.Add(field.Name, id);
            }
            return ids;
        }

        public static int GetDefaultViewAnimDurationMs(WeaponDef wDef, int viewAnimId)
        {
            if (!_weaponAnimDurations.Value.TryGetValue(wDef.Name, out var actions)) return 0;
            foreach (var (name, duration) in actions)
                if (ActionIds.GetValueOrDefault(name) == viewAnimId && viewAnimId > 0) return duration;
            return 0;
        }

        public static bool IsInspectAnimation(int animation) =>
            animation is share.constant.AnimationConstant.TORSO_SHOWGUN or share.constant.AnimationConstant.TORSO_SPECIAL_SHOWGUN;

        public static bool TryInspectWeapon(PlayerBasicInfo player, WeaponDef weapon)
        {
            if (player.IsDead || player.IsStartReload || player.Fov < 90
                || player.ViewAnim is not (13 or 14 or 39 or 48))
                return false;

            int animation = player.SpecialMode
                ? share.constant.AnimationConstant.TORSO_SPECIAL_SHOWGUN
                : share.constant.AnimationConstant.TORSO_SHOWGUN;
            int duration = GetDefaultViewAnimDurationMs(weapon, animation);
            if (duration <= 0) return false;

            player.ViewAnim = animation;
            player.ViewAnimRemainMs = duration;
            player.ViewAnimSpeed = 1f;
            return true;
        }

        /// <summary>
        /// 1:1 对齐 RifleIdleAction / AbstractFrameAction 射速/散布/后坐力计数回落
        /// </summary>
        public static void StepWeaponIdleAndAccuracy(PlayerBasicInfo p, WeaponDef wDef, bool isAttackDown, bool fired, bool isSecondary)
        {
            if (fired)
            {
                int atkMs = Math.Max(40, wDef.AttackIntervalMs);
                p.ShotsFired++;
                p.DelayFire = wDef.Ballistics?.SingleShot != true;
                var ballistics = isSecondary ? null : wDef.Ballistics;
                ballistics?.UpdateAccuracy(p, atkMs);
                if (wDef.IsMelee)
                {
                    int meleeCd = isSecondary ? Math.Max(300, wDef.StabStabMs) : Math.Max(150, wDef.SlashSlashMs);
                    p.NextAttackTimer = p.ClientTime + meleeCd;
                    p.NextSecondaryAttackTimer = p.ClientTime + meleeCd;
                    p.ViewAnim = isSecondary ? 20 : 31;
                    p.TorsoAnim = 15;
                }
                else if (isSecondary)
                {
                    int meleeCd = Math.Max(300, wDef.StabStabMs);
                    p.NextAttackTimer = p.ClientTime + meleeCd;
                    p.NextSecondaryAttackTimer = p.ClientTime + meleeCd;
                    p.ViewAnim = 20;
                    p.TorsoAnim = 20;
                }
                else
                {
                    p.NextAttackTimer = p.ClientTime + atkMs;
                    p.ViewAnim = 15;
                    p.TorsoAnim = 15;
                }
                p.ViewAnimSpeed = 1.0f;
                p.LeftViewAnim = p.ViewAnim;
                p.LeftViewAnimSpeed = 1.0f;
                p.ViewAnimRemainMs = GetDefaultViewAnimDurationMs(wDef, p.ViewAnim);
                if (ballistics != null)
                {
                    ballistics.ApplyRecoil(p, atkMs);
                }
                else
                {
                    p.DecayTime = Math.Max(40, atkMs / 2);
                    p.PunchPitch = Math.Max(-8f, p.PunchPitch - (wDef.WeaponType == 5 ? 2.5f : 0.65f));
                    float maxAcc = wDef.WeaponType == 5 ? 0.65f : 0.45f;
                    p.WeaponAccuracy = Math.Min(maxAcc, wDef.DefaultAccuracy + p.ShotsFired * 0.025f);
                }
                return;
            }

            if (!isAttackDown)
            {
                if (wDef.Ballistics?.SingleShot == true)
                {
                    p.ShotsFired = 0;
                    return;
                }
                if (p.DelayFire)
                {
                    p.DelayFire = false;
                    p.RecoilRunUpMax = false;
                    if (p.ShotsFired > 8) p.ShotsFired = 8;
                    p.DecreaseShotsFired = p.ClientTime + 150;
                    return;
                }
                if (wDef.WeaponType == 0) // Pistol: 单点松手归零
                {
                    p.ShotsFired = 0;
                    p.WeaponAccuracy = wDef.DefaultAccuracy;
                }
                else if (p.ShotsFired > 0 && p.DecreaseShotsFired < p.ClientTime)
                {
                    p.DecreaseShotsFired = p.ClientTime + 16;
                    p.ShotsFired--;
                }
                else if (p.ShotsFired == 0)
                {
                    p.WeaponAccuracy = wDef.DefaultAccuracy;
                }
            }
        }
    }
}
