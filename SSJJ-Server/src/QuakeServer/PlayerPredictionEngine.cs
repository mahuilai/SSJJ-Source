using System;
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
                p.LegsAnim = 5;
            }
            else if (p.Moving)
            {
                if (duckState == 0) p.LegsAnim = isBackward ? 10 : 9;
                else if (!isWalk && velocity2D > 310) p.LegsAnim = isBackward ? 2 : 1;
                else p.LegsAnim = isBackward ? 4 : 3;
            }
            else
            {
                p.LegsAnim = duckState == 0 ? 8 : 7;
            }

            if (p.LegsAnim != prevLegsAnim)
            {
                p.LegsSpeedAnimTime = 0f;
            }

            float legAnimSpeed = (p.LegsAnim == 1 || p.LegsAnim == 2) ? velocity2D * 0.0016f : 1f;
            p.LegsSpeedAnimTime += frameIntervalMs * legAnimSpeed;
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
                int durMs = isShotgun ? 450 : 1400;
                p.IsStartReload = true;
                p.ReloadEndTime = p.ClientTime + durMs;
                p.NextAttackTimer = p.ClientTime + durMs;
                p.ViewAnim = 17;
                p.ViewAnimRemainMs = durMs;
                p.Fov = 90;
                p.LastFov = 90;
                p.ResumeZoom = false;
            }
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
                p.DelayFire = true;
                p.NextAttackTimer = p.ClientTime + atkMs;
                p.ViewAnim = isSecondary ? 20 : 15;
                p.ViewAnimRemainMs = atkMs;
                p.DecayTime = Math.Max(40, atkMs / 2);
                p.PunchPitch = Math.Max(-8f, p.PunchPitch - (wDef.WeaponType == 5 ? 2.5f : 0.65f));
                float maxAcc = wDef.WeaponType == 5 ? 0.65f : 0.45f;
                p.WeaponAccuracy = Math.Min(maxAcc, wDef.DefaultAccuracy + p.ShotsFired * 0.025f);
                return;
            }

            if (!isAttackDown)
            {
                if (p.DelayFire)
                {
                    p.DelayFire = false;
                    if (p.ShotsFired > 8) p.ShotsFired = 8;
                    p.DecreaseShotsFired = p.ClientTime + 150;
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
