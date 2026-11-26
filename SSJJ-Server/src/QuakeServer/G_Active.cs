using System;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 对标 Quake 3: code/game/g_active.c 与原版 SSJJ 物理规范
    /// 权威物理输入推进：将客户端输入的 UserCmd 经过权威 Pmove 计算，驱动物理位移、姿态与跳跃/下蹲状态
    /// </summary>
    public static class G_Active
    {
        // 原生 SSJJ 厘米制标准视高：站立 150cm，下蹲 93cm
        public const float DUCK_VIEW_HEIGHT = 93f;
        public const float STAND_VIEW_HEIGHT = 150f;

        /// <summary>
        /// 权威帧推进一个玩家实体（对标 g_active.c::ClientThink_real）
        /// </summary>
        public static void ClientThink(PlayerPhysicsState pState, PlayerBasicInfo snap, UserCmd cmd, float dt)
        {
            if (snap.IsDead)
            {
                G_Combat.AdvanceDeathClock(snap, G_Combat.CurrentServerTimeMs);
                pState.Velocity.X *= 0.9f;
                pState.Velocity.Y *= 0.9f;
                pState.Velocity.Z -= 800f * dt; // 重力下落
                pState.Position.Z += pState.Velocity.Z * dt;
                if (pState.Position.Z < 119.38f) pState.Position.Z = 119.38f;
                return;
            }

            // 1. Quake 3 物理内核推进速度与位移
            Quake3Pmove.MoveTick(pState, cmd, dt);

            // 2. 视角角与朝向更新
            if (cmd.Yaw != 0f || cmd.Pitch != 0f)
            {
                pState.ViewYaw = cmd.Yaw;
                pState.ViewPitch = cmd.Pitch;
            }

            // 3. 下蹲姿态高度插值 (厘米制 150cm / 93cm)
            bool isDucking = cmd.Duck || cmd.UpMove < -10f;
            float targetHeight = isDucking ? DUCK_VIEW_HEIGHT : STAND_VIEW_HEIGHT;
            snap.ViewHeight += (targetHeight - snap.ViewHeight) * Math.Min(1f, dt * 10f);

            // 4. 同步到位移与朝向快照字段
            snap.PosX = pState.Position.X;
            snap.PosY = pState.Position.Y;
            snap.PosZ = pState.Position.Z;
            snap.ViewYaw = pState.ViewYaw;
            snap.ViewPitch = pState.ViewPitch;
            snap.MoveYaw = pState.ViewYaw;
            snap.MovePitch = pState.ViewPitch;

            // 5. 动画速率与时间戳推进 (原版客户端脚步声与跑动回放依赖 LegsSpeedAnimTime)
            float speed2D = (float)Math.Sqrt(pState.Velocity.X * pState.Velocity.X + pState.Velocity.Y * pState.Velocity.Y);
            if (pState.IsOnGround && speed2D > 10f)
            {
                snap.LegsSpeedAnimTime += dt * (speed2D / 250f);
            }
        }
    }
}
