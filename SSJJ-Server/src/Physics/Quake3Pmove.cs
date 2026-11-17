using System;

namespace SSJJ.Server.Physics
{
    public struct Vector3f
    {
        public float X, Y, Z;
        public Vector3f(float x, float y, float z) { X = x; Y = y; Z = z; }

        public static Vector3f operator +(Vector3f a, Vector3f b) => new Vector3f(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
        public static Vector3f operator -(Vector3f a, Vector3f b) => new Vector3f(a.X - b.X, a.Y - b.Y, a.Z - b.Z);
        public static Vector3f operator *(Vector3f a, float d) => new Vector3f(a.X * d, a.Y * d, a.Z * d);
        public static Vector3f operator /(Vector3f a, float d) => new Vector3f(a.X / d, a.Y / d, a.Z / d);

        public static float Dot(Vector3f a, Vector3f b) => a.X * b.X + a.Y * b.Y + a.Z * b.Z;
        public static Vector3f Cross(Vector3f a, Vector3f b) => new Vector3f(
            a.Y * b.Z - a.Z * b.Y,
            a.Z * b.X - a.X * b.Z,
            a.X * b.Y - a.Y * b.X);
        public static Vector3f Min(Vector3f a, Vector3f b) => new Vector3f(
            Math.Min(a.X, b.X), Math.Min(a.Y, b.Y), Math.Min(a.Z, b.Z));
        public static Vector3f Max(Vector3f a, Vector3f b) => new Vector3f(
            Math.Max(a.X, b.X), Math.Max(a.Y, b.Y), Math.Max(a.Z, b.Z));
        public float Length() => (float)Math.Sqrt(X * X + Y * Y + Z * Z);
        public float Length2D() => (float)Math.Sqrt(X * X + Y * Y);

        public Vector3f Normalized()
        {
            float l = Length();
            return l > 1e-5f ? this / l : new Vector3f(0, 0, 0);
        }
    }

    public struct UserCmd
    {
        public float ForwardMove; // W / S (-1 to 1)
        public float RightMove;   // A / D (-1 to 1)
        public float UpMove;      // Jump
        public float Yaw;         // View Yaw (degrees)
        public float Pitch;       // View Pitch (degrees)
        public bool Jump;
        public bool Duck;
        public bool Attack;
        public bool Attack2;
    }

    public class PlayerPhysicsState
    {
        public Vector3f Position;
        public Vector3f Velocity;
        public float ViewYaw;
        public float ViewPitch;
        public bool IsOnGround = true;
        public bool IsDucking = false;
        public float Stamina = 100f;

        // Constants from SSJJ PmoveBase & Quake 3
        public const float FloorElevation = 119.38f;
        public const float Gravity = 800f;
        public const float StopSpeed = 100f;
        public const float Friction = 4.0f;
        public const float Accelerate = 5.0f;
        public const float AirAccelerate = 10.0f;
        public const float WishSpeedAir = 76.2f;
        public const float JumpSpeed = 270f;
        public const float MaxSpeed = 260f;
    }

    /// <summary>
    /// 100% 对齐 Quake 3 Arena (bg_pmove.c) 与生死狙击原版 physics.net PmoveBase 的移动物理实现
    /// </summary>
    public static class Quake3Pmove
    {
        public static ClipMap? CollisionMap;
        public static bool UseClipCollision;
        public const float PlayerRadius = 45f;
        public const float StepHeight = 18f;

        public static void MoveTick(PlayerPhysicsState ps, UserCmd cmd, float dt)
        {
            if (UseClipCollision && CollisionMap != null)
            {
                MoveTickClip(ps, cmd, dt);
                return;
            }

            ps.ViewYaw = cmd.Yaw;
            ps.ViewPitch = cmd.Pitch;

            // 1. Friction
            if (ps.IsOnGround)
            {
                ApplyFriction(ps, dt);
            }

            // 2. Calculate forward and right vectors from Yaw (SSJJ/Quake: X/Y ground plane, Z vertical)
            float rad = cmd.Yaw * (float)(Math.PI / 180.0);
            Vector3f forward = new Vector3f((float)Math.Cos(rad), (float)Math.Sin(rad), 0);
            Vector3f right = new Vector3f((float)Math.Sin(rad), -(float)Math.Cos(rad), 0);

            Vector3f wishVel = forward * cmd.ForwardMove + right * cmd.RightMove;
            float wishSpeed = wishVel.Length2D() * PlayerPhysicsState.MaxSpeed;
            Vector3f wishDir = wishVel.Normalized();

            if (wishSpeed > PlayerPhysicsState.MaxSpeed)
                wishSpeed = PlayerPhysicsState.MaxSpeed;

            // 3. Jump Check (Z is vertical axis)
            if (cmd.Jump && ps.IsOnGround)
            {
                ps.Velocity.Z = PlayerPhysicsState.JumpSpeed;
                ps.IsOnGround = false;
            }

            // 4. Ground vs Air Move
            if (ps.IsOnGround)
            {
                Accelerate(ps, wishDir, wishSpeed, PlayerPhysicsState.Accelerate, dt);
            }
            else
            {
                // Air Strafe Mechanics (Quake 3 / CS / SSJJ Air Acceleration)
                float airSpeed = Math.Min(wishSpeed, PlayerPhysicsState.WishSpeedAir);
                Accelerate(ps, wishDir, airSpeed, PlayerPhysicsState.AirAccelerate, dt);
                ps.Velocity.Z -= PlayerPhysicsState.Gravity * dt;
            }

            // 5. Integrate Position
            ps.Position += ps.Velocity * dt;

            // Simple floor collision (Map 12 Transport Ship floor elevation = 119.38f)
            if (float.IsNaN(ps.Position.Z) || ps.Position.Z <= PlayerPhysicsState.FloorElevation)
            {
                ps.Position.Z = PlayerPhysicsState.FloorElevation;
                ps.Velocity.Z = 0.0f;
                ps.IsOnGround = true;
            }

            // Map 12 (Ice Transport Ship) Bounding Box Clamp
            if (float.IsNaN(ps.Position.X) || ps.Position.X < 1200f) ps.Position.X = 1200f;
            if (ps.Position.X > 4300f) ps.Position.X = 4300f;
            if (float.IsNaN(ps.Position.Y) || ps.Position.Y < 800f) ps.Position.Y = 800f;
            if (ps.Position.Y > 5800f) ps.Position.Y = 5800f;
        }

        private static void MoveTickClip(PlayerPhysicsState ps, UserCmd cmd, float dt)
        {
            ps.ViewYaw = cmd.Yaw;
            ps.ViewPitch = cmd.Pitch;

            if (float.IsNaN(ps.Position.X) || float.IsNaN(ps.Position.Y) || float.IsNaN(ps.Position.Z))
                return;

            if (ps.IsOnGround) ApplyFriction(ps, dt);

            float rad = cmd.Yaw * (float)(Math.PI / 180.0);
            var forward = new Vector3f((float)Math.Cos(rad), (float)Math.Sin(rad), 0);
            var right = new Vector3f((float)Math.Sin(rad), -(float)Math.Cos(rad), 0);
            var wishVel = forward * cmd.ForwardMove + right * cmd.RightMove;
            float wishSpeed = wishVel.Length2D();
            if (wishSpeed > PlayerPhysicsState.MaxSpeed) wishSpeed = PlayerPhysicsState.MaxSpeed;
            var wishDir = wishVel.Normalized();

            if (cmd.Jump && ps.IsOnGround)
            {
                ps.Velocity.Z = PlayerPhysicsState.JumpSpeed;
                ps.IsOnGround = false;
            }

            if (ps.IsOnGround)
            {
                Accelerate(ps, wishDir, wishSpeed, PlayerPhysicsState.Accelerate, dt);
            }
            else
            {
                float airSpeed = Math.Min(wishSpeed, PlayerPhysicsState.WishSpeedAir);
                Accelerate(ps, wishDir, airSpeed, PlayerPhysicsState.AirAccelerate, dt);
                ps.Velocity.Z -= PlayerPhysicsState.Gravity * dt;
            }

            var map = CollisionMap!;
            var start = ps.Position;
            var delta = new Vector3f(ps.Velocity.X * dt, ps.Velocity.Y * dt, 0);
            var end = start + delta;

            if (delta.Length2D() > 1e-5f)
            {
                // Horizontal sweep at knee height; wall normals remove the blocked component.
                var traceStart = start + new Vector3f(0, 0, 2f);
                var traceEnd = end + new Vector3f(0, 0, 2f);
                if (map.TracePlayer(traceStart, traceEnd, PlayerRadius, out var hit, out var normal, out _))
                {
                    // Try a step-up before stopping: stairs/ledges are common on map1.
                    var raisedStart = traceStart + new Vector3f(0, 0, StepHeight);
                    var raisedEnd = traceEnd + new Vector3f(0, 0, StepHeight);
                    if (!map.TracePlayer(raisedStart, raisedEnd, PlayerRadius, out _, out _, out _))
                    {
                        ps.Position = new Vector3f(end.X, end.Y, end.Z + StepHeight);
                    }
                    else
                    {
                        ps.Position = new Vector3f(hit.X, hit.Y, ps.Position.Z);
                        float into = Vector3f.Dot(ps.Velocity, normal);
                        if (into < 0)
                        {
                            ps.Velocity.X -= normal.X * into;
                            ps.Velocity.Y -= normal.Y * into;
                        }
                    }
                }
                else
                {
                    ps.Position = new Vector3f(end.X, end.Y, ps.Position.Z);
                }
            }

            if (ps.IsOnGround)
            {
                if (map.SampleGround(ps.Position + new Vector3f(0, 0, StepHeight), 2f, StepHeight + 4f,
                                     out var ground, out var groundNormal) && groundNormal.Z > 0.5f)
                {
                    ps.Position = new Vector3f(ps.Position.X, ps.Position.Y, ground.Z + 0.1f);
                    ps.Velocity.Z = 0f;
                    ps.IsOnGround = true;
                }
                else
                {
                    ps.IsOnGround = false;
                }
            }
            else
            {
                float dz = ps.Velocity.Z * dt;
                var downStart = ps.Position;
                var downEnd = ps.Position + new Vector3f(0, 0, dz);
                if (map.TraceLine(downStart, downEnd, out var ground, out var n, out _))
                {
                    ps.Position = new Vector3f(ps.Position.X, ps.Position.Y, ground.Z);
                    ps.Velocity.Z = 0f;
                    ps.IsOnGround = n.Z > 0.5f;
                }
                else
                {
                    ps.Position = new Vector3f(ps.Position.X, ps.Position.Y, downEnd.Z);
                }
            }
        }

        private static void ApplyFriction(PlayerPhysicsState ps, float dt)
        {
            float speed = ps.Velocity.Length2D();
            if (speed < 0.0001f)
            {
                ps.Velocity.X = 0;
                ps.Velocity.Y = 0;
                return;
            }

            float control = (speed < PlayerPhysicsState.StopSpeed) ? PlayerPhysicsState.StopSpeed : speed;
            float drop = control * PlayerPhysicsState.Friction * dt;

            float newspeed = speed - drop;
            if (newspeed < 0) newspeed = 0;
            newspeed /= speed;

            ps.Velocity.X *= newspeed;
            ps.Velocity.Y *= newspeed;
        }

        private static void Accelerate(PlayerPhysicsState ps, Vector3f wishdir, float wishspeed, float accel, float dt)
        {
            float currentspeed = Vector3f.Dot(ps.Velocity, wishdir);
            float addspeed = wishspeed - currentspeed;
            if (addspeed <= 0) return;

            float accelspeed = accel * dt * wishspeed;
            if (accelspeed > addspeed) accelspeed = addspeed;

            ps.Velocity.X += accelspeed * wishdir.X;
            ps.Velocity.Y += accelspeed * wishdir.Y;
        }
    }
}
