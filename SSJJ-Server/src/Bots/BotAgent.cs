using System;
using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.Bots
{
    /// <summary>
    /// 服务端权威人机 AI（严格区分近战贴脸挥砍与枪械视线压制，接入 OfficialPhysicsWorld 与 BSP LOS 检查）
    /// </summary>
    public sealed class BotAgent
    {
        public int Id { get; }
        public int Team { get; set; }
        public string Name { get; }
        public PlayerBasicInfo Snap { get; }
        public PlayerPhysicsState Physics { get; }
        public G_Weapon Weapon { get; }

        private readonly GameTables _tables;
        private readonly OfficialPhysicsWorld? _officialPhysics;
        private readonly BspNavGraph? _navGraph;
        private readonly bool _freeForAll;
        private readonly float _spawnX;
        private readonly float _spawnY;
        private readonly float _spawnZ;
        private readonly float _spawnYaw;

        private float _targetLockTime;
        private float _strafeTimer;
        private float _strafeDir = 1f;
        private float _stuckTimer;
        private float _lastCheckX;
        private float _lastCheckY;
        private float _steerYawOffset;
        private float _steerHoldTimer;
        private float _wallFollowSign;
        private List<int> _navPath = new List<int>();
        private int _navPathIdx;
        private float _navRecalcTimer;
        private readonly Random _rng;

        public BotAgent(
            int id,
            int team,
            string name,
            string career,
            string weapon,
            string weaponSkin,
            float x,
            float y,
            float z,
            float yaw,
            GameTables tables,
            OfficialPhysicsWorld? officialPhysics,
            BspNavGraph? navGraph,
            bool freeForAll,
            bool isMeleeOnly,
            int quality = 1)
        {
            Id = id;
            Team = team;
            Name = name;
            _tables = tables;
            _officialPhysics = officialPhysics;
            _navGraph = navGraph;
            _freeForAll = freeForAll;
            _spawnX = x;
            _spawnY = y;
            _spawnZ = z;
            _spawnYaw = yaw;
            _lastCheckX = x;
            _lastCheckY = y;
            _wallFollowSign = (id & 1) == 0 ? 1f : -1f;
            _rng = new Random(id * 997 + 13);

            var wDef = tables.GetWeapon(weapon);
            int slot = (isMeleeOnly || (wDef?.IsMelee ?? false)) ? 3 : 1;
            int maxClip = wDef?.MaxClip ?? (slot == 3 ? 0 : 30);

            Snap = new PlayerBasicInfo
            {
                Id = id,
                Team = team,
                PlayerName = name,
                Career = career,
                Hp = 100,
                MaxHp = 100,
                Zhuangjia = 100,
                Hudun = 0,
                IsBot = true,
                BotQuality = quality,
                CurrentBagId = 1,
                CurrentWeapon = slot,
                CurrentWeaponName = weapon,
                CurrentWeaponSkinName = weaponSkin ?? "",
                CurrentWeaponIndex = slot,
                CurrentClip = maxClip,
                MaxClip = maxClip,
                CurrentCarryClip = maxClip * 4,
                PosX = x,
                PosY = y,
                PosZ = z,
                DuckState = 3,
                ViewHeight = 150f,
                ViewYaw = yaw,
                MoveYaw = yaw,
                ViewPitch = 0f,
                MovePitch = 0f,
                LegsAnim = 7,
                TorsoAnim = 13,
                ViewAnim = 13
            };
            Physics = new PlayerPhysicsState
            {
                Position = new Vector3f(x, y, z),
                Velocity = new Vector3f(0f, 0f, 0f),
                ViewYaw = yaw,
                ViewPitch = 0f,
                IsOnGround = true
            };
            Weapon = new G_Weapon();
        }

        public void Respawn(float? x = null, float? y = null, float? z = null, float? yaw = null)
        {
            float sx = x ?? _spawnX;
            float sy = y ?? _spawnY;
            float sz = z ?? _spawnZ;
            float syaw = yaw ?? _spawnYaw;

            Snap.IsDead = false;
            Snap.Hp = Snap.MaxHp > 0 ? Snap.MaxHp : 100;
            Snap.Zhuangjia = 100;
            Snap.Hudun = 0;
            Snap.DeadTimer = 0f;
            Snap.LifeBarSeq++;

            Physics.Position = new Vector3f(sx, sy, sz);
            Physics.Velocity = new Vector3f(0f, 0f, 0f);
            Physics.ViewYaw = syaw;
            Physics.ViewPitch = 0f;
            Physics.IsOnGround = true;

            _officialPhysics?.SetPlayerPosition(Id, sx, sy, sz);

            Snap.PosX = sx;
            Snap.PosY = sy;
            Snap.PosZ = sz;
            Snap.ViewYaw = syaw;
            Snap.MoveYaw = syaw;
            Snap.ViewPitch = 0f;
            Snap.MovePitch = 0f;
            Snap.LegsAnim = 7;
            Snap.TorsoAnim = 13;
            Snap.FireAnimEndTime = 0f;
            _targetLockTime = 0f;
        }

        public void Tick(float dt, List<PlayerBasicInfo> allEntities, bool allowRespawn, float[]? objectivePoint = null, int serverTimeMs = 0)
        {
            if (Snap.IsDead)
            {
                Snap.DeadTimer += dt;
                if (allowRespawn && Snap.DeadTimer >= G_Combat.RESPAWN_DELAY)
                {
                    Respawn();
                }
                return;
            }

            Weapon.Tick(dt);

            // 1. 寻找最近敌方目标
            PlayerBasicInfo? bestTarget = null;
            float bestDistSq = float.MaxValue;
            for (int i = 0; i < allEntities.Count; i++)
            {
                var e = allEntities[i];
                if (e.Id == Id || e.IsDead) continue;
                if (!_freeForAll && e.Team == Team) continue;

                float dx = e.PosX - Snap.PosX;
                float dy = e.PosY - Snap.PosY;
                float dz = e.PosZ - Snap.PosZ;
                float distSq = dx * dx + dy * dy + dz * dz;
                if (distSq < bestDistSq)
                {
                    bestDistSq = distSq;
                    bestTarget = e;
                }
            }

            var wDef = _tables.GetWeapon(Snap.CurrentWeaponName);
            bool isMelee = Snap.CurrentWeapon == 3 || (wDef?.IsMelee ?? false);
            UserCmd cmd = new UserCmd();

            bool holdObjective = objectivePoint != null && objectivePoint.Length >= 4 && objectivePoint[3] > 0.5f;

            if (holdObjective)
            {
                // 正在包点原地安放或拆除 C4：静止读条并保持警戒
                cmd.ForwardMove = 0f;
                cmd.RightMove = 0f;
            }
            else if (bestTarget != null)
            {
                float dx = bestTarget.PosX - Snap.PosX;
                float dy = bestTarget.PosY - Snap.PosY;
                float targetZ = bestTarget.PosZ + 120f;
                float muzzleZ = Snap.PosZ + (Snap.ViewHeight - 4f);
                float dz = targetZ - muzzleZ;
                float dist2D = (float)Math.Sqrt(dx * dx + dy * dy);

                float desiredYaw = (float)(Math.Atan2(dy, dx) * 180.0 / Math.PI);
                float desiredPitch = -(float)(Math.Atan2(dz, Math.Max(1f, dist2D)) * 180.0 / Math.PI);

                bool hasLos = _officialPhysics == null || !_officialPhysics.IsReady ||
                              _officialPhysics.TraceRayClear(Snap.PosX, Snap.PosY, muzzleZ, bestTarget.PosX, bestTarget.PosY, targetZ, out _);

                _strafeTimer += dt;
                if (_strafeTimer >= 0.75f)
                {
                    _strafeTimer = 0f;
                    _strafeDir = -_strafeDir;
                }

                // 检测位置停滞并用多角度 BSP 射线选路绕障
                if (_steerHoldTimer > 0f) _steerHoldTimer = Math.Max(0f, _steerHoldTimer - dt);

                _stuckTimer += dt;
                if (_stuckTimer >= 0.75f)
                {
                    float moved = Math.Abs(Snap.PosX - _lastCheckX) + Math.Abs(Snap.PosY - _lastCheckY);
                    _lastCheckX = Snap.PosX;
                    _lastCheckY = Snap.PosY;
                    _stuckTimer = 0f;
                    if (moved < 55f && dist2D > 160f)
                    {
                        _wallFollowSign = -_wallFollowSign;
                        _steerYawOffset = FindClearSteerOffset(desiredYaw, forceChange: true);
                        _steerHoldTimer = 2.4f;
                        cmd.Jump = _rng.NextDouble() < 0.45;
                    }
                }

                float goalX = bestTarget.PosX, goalY = bestTarget.PosY, goalZ = bestTarget.PosZ;
                if (objectivePoint != null && objectivePoint.Length >= 3 && !hasLos && dist2D > 600f)
                {
                    goalX = objectivePoint[0];
                    goalY = objectivePoint[1];
                    goalZ = objectivePoint[2];
                }
                float goalYaw = (float)(Math.Atan2(goalY - Snap.PosY, goalX - Snap.PosX) * 180.0 / Math.PI);

                // 若刚检测到卡死(_steerHoldTimer > 0)，先用射线脱困转向避开箱角/门框，再继续沿 A* 路点前进
                float navYaw = goalYaw;
                bool usedNavNode = false;
                if (_steerHoldTimer > 1.2f)
                {
                    navYaw = goalYaw + _steerYawOffset;
                    usedNavNode = true;
                }
                else if (_navGraph != null && _navGraph.NodeCount > 0 && !hasLos)
                {
                    _navRecalcTimer -= dt;
                    if (_navRecalcTimer <= 0f || _navPathIdx >= _navPath.Count)
                    {
                        _navRecalcTimer = 0.85f + (Id % 5) * 0.12f;
                        _navPath = _navGraph.FindPath(Snap.PosX, Snap.PosY, Snap.PosZ, goalX, goalY, goalZ);
                        _navPathIdx = 0;
                    }
                    while (_navPathIdx < _navPath.Count && _navGraph.TryGetNode(_navPath[_navPathIdx], out var wp))
                    {
                        float wdx = wp.X - Snap.PosX, wdy = wp.Y - Snap.PosY;
                        if (wdx * wdx + wdy * wdy < 130f * 130f && Math.Abs(wp.Z - Snap.PosZ) < 160f)
                        {
                            _navPathIdx++;
                            continue;
                        }
                        navYaw = (float)(Math.Atan2(wdy, wdx) * 180.0 / Math.PI);
                        usedNavNode = true;
                        break;
                    }
                }

                if (!usedNavNode && (!hasLos || dist2D > 260f))
                {
                    if (_steerHoldTimer > 0f && !IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 70f, goalYaw, 420f))
                    {
                        float curFollow = goalYaw + _steerYawOffset;
                        if (!IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 70f, curFollow, 140f))
                        {
                            _steerYawOffset = FindClearSteerOffset(goalYaw, forceChange: false);
                        }
                        navYaw = goalYaw + _steerYawOffset;
                    }
                    else if (!IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 70f, goalYaw, 200f))
                    {
                        _steerYawOffset = FindClearSteerOffset(goalYaw, forceChange: false);
                        _steerHoldTimer = 2.2f;
                        navYaw = goalYaw + _steerYawOffset;
                    }
                }

                float aimTargetYaw = hasLos ? desiredYaw : navYaw;
                float deltaAimYaw = NormalizeAngle(aimTargetYaw - Snap.ViewYaw);
                float maxStepYaw = 540f * dt;
                Snap.ViewYaw = Math.Abs(deltaAimYaw) <= maxStepYaw ? aimTargetYaw : Snap.ViewYaw + Math.Sign(deltaAimYaw) * maxStepYaw;

                float aimPitch = hasLos ? desiredPitch : 0f;
                float deltaPitch = aimPitch - Snap.ViewPitch;
                float maxStepPitch = 360f * dt;
                Snap.ViewPitch = Math.Abs(deltaPitch) <= maxStepPitch ? aimPitch : Snap.ViewPitch + Math.Sign(deltaPitch) * maxStepPitch;
                Snap.MoveYaw = Snap.ViewYaw;
                Snap.MovePitch = Snap.ViewPitch;

                float losYawDiff = Math.Abs(NormalizeAngle(desiredYaw - Snap.ViewYaw));

                if (isMelee)
                {
                    // 近战人机：严格禁止远程开火！必须冲到 <= 195cm 且视线无阻挡才挥砍
                    if (dist2D <= 195f && losYawDiff < 38f && hasLos)
                    {
                        bool heavy = _rng.NextDouble() < 0.35;
                        if (heavy) cmd.Attack2 = true; else cmd.Attack = true;
                        Weapon.TryFire(Snap, Physics, !heavy, heavy, _tables, _officialPhysics, _freeForAll, allEntities);
                    }
                    cmd.ForwardMove = (!hasLos || dist2D > 95f) ? 1.0f : 0.2f;
                    cmd.RightMove = hasLos ? (_strafeDir * 0.25f) : (_strafeDir * 0.15f);
                }
                else
                {
                    // 枪械人机：仅在有视线时开火，且限制最大有效交战距离
                    if (hasLos) _targetLockTime += dt;
                    else _targetLockTime = 0f;

                    bool inAim = losYawDiff < 20f;
                    if (hasLos && inAim && _targetLockTime >= 0.12f && dist2D < 6500f)
                    {
                        cmd.Attack = true;
                        Weapon.TryFire(Snap, Physics, true, false, _tables, _officialPhysics, _freeForAll, allEntities);
                    }

                    if (!hasLos || dist2D > 650f)
                    {
                        cmd.ForwardMove = 1.0f;
                        cmd.RightMove = hasLos ? (_strafeDir * 0.35f) : 0f;
                    }
                    else
                    {
                        cmd.ForwardMove = 0.2f;
                        cmd.RightMove = _strafeDir * 0.85f;
                    }
                }
            }
            else if (objectivePoint != null && objectivePoint.Length >= 2)
            {
                float dx = objectivePoint[0] - Snap.PosX;
                float dy = objectivePoint[1] - Snap.PosY;
                float yaw = (float)(Math.Atan2(dy, dx) * 180.0 / Math.PI);
                Snap.ViewYaw = yaw;
                Snap.MoveYaw = yaw;
                Snap.ViewPitch = 0f;
                Snap.MovePitch = 0f;
                cmd.ForwardMove = 1.0f;
            }
            else
            {
                _targetLockTime = 0f;
                float marchYaw = (Team == 1) ? 90f : -90f;
                Snap.ViewYaw = marchYaw;
                Snap.MoveYaw = marchYaw;
                Snap.ViewPitch = 0f;
                Snap.MovePitch = 0f;
                cmd.ForwardMove = 1.0f;
            }

            cmd.Yaw = Snap.ViewYaw;
            cmd.Pitch = Snap.ViewPitch;

            if (_officialPhysics != null && _officialPhysics.IsReady)
            {
                int maxSpd = wDef?.MaxSpeed ?? 600;
                var pyCmd = new ServerPyCmd
                {
                    Sequence = ++Snap.CmdSequence,
                    FrameInterval = Math.Max(8, (int)(dt * 1000f)),
                    MoveForward = 1014f * cmd.ForwardMove,
                    MoveRight = 1014f * cmd.RightMove,
                    IsForward = cmd.ForwardMove > 0.1f,
                    IsBackward = cmd.ForwardMove < -0.1f,
                    IsLeft = cmd.RightMove < -0.1f,
                    IsRight = cmd.RightMove > 0.1f,
                    IsJump = cmd.Jump,
                    CameraYaw = Snap.ViewYaw,
                    CameraPitch = Snap.ViewPitch
                };
                _officialPhysics.StepPlayer(Id, pyCmd, maxSpd);
                if (_officialPhysics.TryGetState(Id, out float px, out float py, out float pz, out double vh, out int ds, out bool og, out int v2d))
                {
                    Snap.PosX = px;
                    Snap.PosY = py;
                    Snap.PosZ = pz;
                    Snap.ViewHeight = (float)vh;
                    Snap.DuckState = ds;
                    Snap.OnGround = og;
                    Snap.Velocity2D = v2d;
                    Snap.Moving = v2d > 10;
                    if (!og)
                    {
                        Snap.LegsAnim = 5;
                    }
                    else if (v2d > 10)
                    {
                        bool backward = cmd.ForwardMove < -0.1f;
                        Snap.LegsAnim = ds == 0 ? (backward ? 10 : 9) : (backward ? 2 : 1);
                        Snap.LegsSpeedAnimTime += dt * 1000f * (v2d / 250f);
                    }
                    else
                    {
                        Snap.LegsAnim = ds == 0 ? 8 : 7;
                    }
                }
            }
            else
            {
                G_Active.ClientThink(Physics, Snap, cmd, dt);
            }

            if (!Snap.IsDead)
            {
                float nowSec = serverTimeMs / 1000f;
                if (cmd.Attack || cmd.Attack2)
                {
                    if (Snap.TorsoAnim != 15)
                    {
                        Snap.TorsoAnim = 15;
                        Snap.TorsoAnimStartTime = serverTimeMs;
                    }
                    Snap.FireAnimEndTime = nowSec + 0.24f;
                }
                else if (nowSec >= Snap.FireAnimEndTime && Snap.TorsoAnim != 13)
                {
                    Snap.TorsoAnim = 13;
                    Snap.TorsoAnimStartTime = serverTimeMs;
                }
            }
        }

        private bool IsRayClear2D(float x, float y, float z, float yawDeg, float dist)
        {
            if (_officialPhysics == null || !_officialPhysics.IsReady) return true;
            float rad = yawDeg * (float)Math.PI / 180f;
            float tx = x + (float)Math.Cos(rad) * dist;
            float ty = y + (float)Math.Sin(rad) * dist;
            return _officialPhysics.TraceRayClear(x, y, z, tx, ty, z, out _);
        }

        private float FindClearSteerOffset(float baseYaw, bool forceChange)
        {
            float sign = _wallFollowSign;
            float[] candidates = forceChange
                ? new[] { 90f * sign, 125f * sign, 55f * sign, -90f * sign, -125f * sign, 180f }
                : new[] { 40f * sign, 75f * sign, 110f * sign, -40f * sign, -75f * sign, -110f * sign, 145f * sign, -145f * sign, 180f };

            float bestOffset = candidates[0];
            float bestScore = -1f;
            foreach (float off in candidates)
            {
                float yaw = baseYaw + off;
                float rad = yaw * (float)Math.PI / 180f;
                float tx = Snap.PosX + (float)Math.Cos(rad) * 380f;
                float ty = Snap.PosY + (float)Math.Sin(rad) * 380f;
                float frac = 1f;
                bool clear = _officialPhysics == null || !_officialPhysics.IsReady ||
                             _officialPhysics.TraceRayClear(Snap.PosX, Snap.PosY, Snap.PosZ + 70f, tx, ty, Snap.PosZ + 70f, out frac);
                if (clear) return off;
                if (frac > bestScore)
                {
                    bestScore = frac;
                    bestOffset = off;
                }
            }
            return bestOffset;
        }

        private static float NormalizeAngle(float angle)
        {
            while (angle > 180f) angle -= 360f;
            while (angle < -180f) angle += 360f;
            return angle;
        }
    }
}
