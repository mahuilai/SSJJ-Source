using System;
using System.Collections.Generic;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer
{
    /// <summary>
    /// 对标 Quake 3: code/game/g_missile.c
    /// 投掷物权威物理轨迹、反弹与爆炸范围伤害
    /// </summary>
    public class G_Missile
    {
        public const float GRAVITY = 800f;
        public const float BOUNCE_RESTITUTION = 0.45f;
        public const float GROUND_FRICTION = 0.65f;
        public const float SPLASH_RADIUS = 320f; // 约 8 米爆炸半径
        public const int MAX_SPLASH_DAMAGE = 105;

        private readonly List<MissileEntity> _activeMissiles = new List<MissileEntity>();
        private int _nextId = 100;

        public event Action<GrenadeExplosionEventData> OnGrenadeExploded;

        public void SpawnGrenade(PlayerBasicInfo thrower, float speed = 750f)
        {
            if (thrower == null || thrower.IsDead) return;

            float yawRad = thrower.ViewYaw * (float)Math.PI / 180f;
            float pitchRad = thrower.ViewPitch * (float)Math.PI / 180f;

            float cosPitch = (float)Math.Cos(pitchRad);
            float fwdX = (float)Math.Sin(yawRad) * cosPitch;
            float fwdY = -(float)Math.Sin(pitchRad);
            float fwdZ = (float)Math.Cos(yawRad) * cosPitch;

            var missile = new MissileEntity
            {
                Id = _nextId++,
                ThrowerId = thrower.Id,
                WeaponTid = 10,
                PosX = thrower.PosX,
                PosY = thrower.PosY + (thrower.ViewHeight - 8f),
                PosZ = thrower.PosZ,
                VelX = fwdX * speed,
                VelY = fwdY * speed + 150f, // 仰角初速度
                VelZ = fwdZ * speed,
                FuseTimer = 2.5f,
                Exploded = false
            };

            _activeMissiles.Add(missile);
        }

        public void Tick(float dt, List<PlayerBasicInfo> players)
        {
            for (int i = _activeMissiles.Count - 1; i >= 0; i--)
            {
                var m = _activeMissiles[i];

                // 1. 物理位置与重力推进 (对标 BG_EvaluateTrajectory)
                m.PosX += m.VelX * dt;
                m.PosZ += m.VelZ * dt;
                m.VelY -= GRAVITY * dt;
                m.PosY += m.VelY * dt;

                // 2. 地面碰撞与反弹 (对标 G_RunMissile)
                if (m.PosY <= 0f)
                {
                    m.PosY = 0f;
                    m.VelY = -m.VelY * BOUNCE_RESTITUTION;
                    m.VelX *= GROUND_FRICTION;
                    m.VelZ *= GROUND_FRICTION;

                    // 低速贴地静止
                    if (Math.Abs(m.VelY) < 30f) m.VelY = 0f;
                }

                // 3. 运输船边界碰撞反弹
                if (m.PosX < -400f || m.PosX > 400f) m.VelX = -m.VelX * 0.5f;
                if (m.PosZ < -700f || m.PosZ > 700f) m.VelZ = -m.VelZ * 0.5f;

                // 4. 引信倒计时与爆炸结算 (对标 G_ExplodeMissile)
                m.FuseTimer -= dt;
                if (m.FuseTimer <= 0f && !m.Exploded)
                {
                    m.Exploded = true;
                    Explode(m, players);
                    _activeMissiles.RemoveAt(i);
                }
            }
        }

        private void Explode(MissileEntity m, List<PlayerBasicInfo> players)
        {
            // 广播手雷爆炸事件 (驱动客户端爆炸火焰、冲击波与震屏)
            OnGrenadeExploded?.Invoke(new GrenadeExplosionEventData
            {
                ThrowerId = m.ThrowerId,
                WeaponTid = m.WeaponTid,
                PosX = m.PosX,
                PosY = m.PosY,
                PosZ = m.PosZ
            });

            // 范围伤害结算 (对标 G_RadiusDamage)
            PlayerBasicInfo thrower = players.Find(p => p.Id == m.ThrowerId);

            foreach (var p in players)
            {
                if (p.IsDead) continue;

                float dx = p.PosX - m.PosX;
                float dy = (p.PosY + 32f) - m.PosY;
                float dz = p.PosZ - m.PosZ;
                float dist = (float)Math.Sqrt(dx * dx + dy * dy + dz * dz);

                if (dist <= SPLASH_RADIUS)
                {
                    // 距离线性衰减
                    float factor = 1.0f - (dist / SPLASH_RADIUS);
                    int damage = Math.Max(5, (int)(MAX_SPLASH_DAMAGE * factor));
                    G_Combat.ApplyDamage(p, thrower, damage, 2, "grenade");
                }
            }
        }
    }
}
