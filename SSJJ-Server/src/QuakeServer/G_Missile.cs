using System;
using System.Collections.Generic;
using SSJJ.Server.Physics;
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
            float fwdX = (float)Math.Cos(yawRad) * cosPitch;
            float fwdY = (float)Math.Sin(yawRad) * cosPitch;
            float fwdZ = -(float)Math.Sin(pitchRad);

            var missile = new MissileEntity
            {
                Id = _nextId++,
                ThrowerId = thrower.Id,
                WeaponTid = 10,
                PosX = thrower.PosX,
                PosY = thrower.PosY,
                PosZ = thrower.PosZ + (thrower.ViewHeight - 8f),
                VelX = fwdX * speed,
                VelY = fwdY * speed,
                VelZ = fwdZ * speed + 160f,
                FuseTimer = 2.5f,
                Exploded = false
            };

            _activeMissiles.Add(missile);
        }

        public void Tick(float dt, List<PlayerBasicInfo> players, OfficialPhysicsWorld? physicsWorld = null)
        {
            for (int i = _activeMissiles.Count - 1; i >= 0; i--)
            {
                var m = _activeMissiles[i];

                float nextX = m.PosX + m.VelX * dt;
                float nextY = m.PosY + m.VelY * dt;
                m.VelZ -= GRAVITY * dt;
                float nextZ = m.PosZ + m.VelZ * dt;

                if (physicsWorld != null && physicsWorld.IsReady)
                {
                    if (!physicsWorld.TraceRayClear(m.PosX, m.PosY, m.PosZ, nextX, nextY, m.PosZ, out _))
                    {
                        m.VelX = -m.VelX * BOUNCE_RESTITUTION;
                        m.VelY = -m.VelY * BOUNCE_RESTITUTION;
                        nextX = m.PosX;
                        nextY = m.PosY;
                    }
                    if (physicsWorld.SampleGround(nextX, nextY, m.PosZ + 20f, out float gz) && nextZ <= gz + 4f)
                    {
                        nextZ = gz + 4f;
                        m.VelZ = -m.VelZ * BOUNCE_RESTITUTION;
                        m.VelX *= GROUND_FRICTION;
                        m.VelY *= GROUND_FRICTION;
                        if (Math.Abs(m.VelZ) < 30f) m.VelZ = 0f;
                    }
                }
                else if (nextZ <= 4f)
                {
                    nextZ = 4f;
                    m.VelZ = -m.VelZ * BOUNCE_RESTITUTION;
                    m.VelX *= GROUND_FRICTION;
                    m.VelY *= GROUND_FRICTION;
                    if (Math.Abs(m.VelZ) < 30f) m.VelZ = 0f;
                }

                m.PosX = nextX;
                m.PosY = nextY;
                m.PosZ = nextZ;

                m.FuseTimer -= dt;
                if (m.FuseTimer <= 0f && !m.Exploded)
                {
                    m.Exploded = true;
                    Explode(m, players, physicsWorld);
                    _activeMissiles.RemoveAt(i);
                }
            }
        }

        private void Explode(MissileEntity m, List<PlayerBasicInfo> players, OfficialPhysicsWorld? physicsWorld)
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

            // 范围伤害结算 (对标 G_RadiusDamage + BSP 掩体遮挡)
            PlayerBasicInfo? thrower = players.Find(p => p.Id == m.ThrowerId);

            foreach (var p in players)
            {
                if (p.IsDead) continue;

                float dx = p.PosX - m.PosX;
                float dy = p.PosY - m.PosY;
                float dz = (p.PosZ + 90f) - m.PosZ;
                float dist = (float)Math.Sqrt(dx * dx + dy * dy + dz * dz);

                if (dist <= SPLASH_RADIUS)
                {
                    if (physicsWorld != null && physicsWorld.IsReady &&
                        !physicsWorld.TraceRayClear(m.PosX, m.PosY, m.PosZ + 8f, p.PosX, p.PosY, p.PosZ + 100f, out _))
                    {
                        continue;
                    }
                    float factor = 1.0f - (dist / SPLASH_RADIUS);
                    int damage = Math.Max(5, (int)(MAX_SPLASH_DAMAGE * factor));
                    G_Combat.ApplyDamage(p, thrower, damage, 2, "grenade");
                }
            }
        }
    }
}
