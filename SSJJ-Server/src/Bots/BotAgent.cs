using System;
using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.GameModes;
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
        // Distances used by bot decisions only. Damage and ballistics use WeaponDef.
        private const float CloseEngagementDistance = 650f;
        private const float MaxEngagementDistance = 6500f;
        // Keep the normal torso aim point; use the lower native eye height
        // when the opponent crouches so the sight ray stays inside the hull.
        private static float BodyAimZ(PlayerBasicInfo player) => player.PosZ + Math.Min(120f, player.ViewHeight);

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
        private readonly string _difficulty;
        private readonly float _spawnX;
        private readonly float _spawnY;
        private readonly float _spawnZ;
        private readonly float _spawnYaw;

        private float _targetLockTime;
        private int _visibleTargetId;
        private float _strafeTimer;
        private float _strafeDuration = 0.65f;
        private float _strafeDir = 1f;
        private float _burstTimer;
        private float _burstCooldown;
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
            int quality = 1,
            string difficulty = "normal")
        {
            Id = id;
            Team = team;
            Name = name;
            _tables = tables;
            _officialPhysics = officialPhysics;
            _navGraph = navGraph;
            _freeForAll = freeForAll;
            _difficulty = string.IsNullOrWhiteSpace(difficulty) ? "normal" : difficulty.Trim().ToLowerInvariant();
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
                WeaponAccuracy = wDef?.DefaultAccuracy ?? 0.2f,
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

            G_Combat.ResetSpawnAnimation(Snap);
            Snap.Hp = Snap.MaxHp > 0 ? Snap.MaxHp : 100;
            Snap.Zhuangjia = 100;
            Snap.Hudun = 0;
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
            Snap.Stamina = 0f;
            Snap.TorsoAnimStartTime = 0f;
            Snap.WeaponAccuracy = _tables.GetWeapon(Snap.CurrentWeaponName).DefaultAccuracy;
            Snap.RecoilDirection = Snap.RecoilRunUpMax = false;
            Snap.PunchYaw = Snap.PunchPitch = Snap.DecayTime = 0;
            Snap.Fov = Snap.LastFov = 90;
            Snap.ResumeZoom = false;
            if (Snap.MaxClip > 0)
            {
                Snap.CurrentClip = Snap.MaxClip;
                Snap.CurrentCarryClip = Math.Max(Snap.CurrentCarryClip, Snap.MaxClip * 4);
            }
            Snap.FireAnimEndTime = 0f;
            _targetLockTime = 0f;
            _visibleTargetId = 0;
            _burstTimer = 0f;
            _burstCooldown = 0f;
        }

        public void Tick(float dt, List<PlayerBasicInfo> allEntities, bool allowRespawn, float[]? objectivePoint = null, int serverTimeMs = 0, bool isBiohazardMode = false)
        {
            int frameMs = Math.Max(1, (int)(dt * 1000f));
            Snap.ClientTime += frameMs;

            if (Snap.IsDead)
            {
                if (serverTimeMs > 0) G_Combat.AdvanceDeathClock(Snap, serverTimeMs);
                else Snap.DeadTimerMs += frameMs;
                _officialPhysics?.StepCorpse(Snap, frameMs);
                if (allowRespawn && Snap.DeadTimer >= G_Combat.RESPAWN_DELAY)
                {
                    Respawn();
                }
                return;
            }

            Weapon.Tick(dt);
            PlayerPredictionEngine.StepPunchAndDecay(Snap, frameMs);

            // 1. 寻找最近敌方目标（优先有视线 LOS 的目标，避免隔墙锁死）
            PlayerBasicInfo? bestVisibleTarget = null;
            float bestVisibleDistSq = float.MaxValue;
            PlayerBasicInfo? bestAnyTarget = null;
            float bestAnyDistSq = float.MaxValue;
            float muzzleZ = Snap.PosZ + (Snap.ViewHeight - 4f);

            for (int i = 0; i < allEntities.Count; i++)
            {
                var e = allEntities[i];
                if (e.Id == Id || e.IsDead) continue;
                if (!_freeForAll && e.Team == Team) continue;

                float dx = e.PosX - Snap.PosX;
                float dy = e.PosY - Snap.PosY;
                float dz = e.PosZ - Snap.PosZ;
                float distSq = dx * dx + dy * dy + dz * dz;

                if (distSq < bestAnyDistSq)
                {
                    bestAnyDistSq = distSq;
                    bestAnyTarget = e;
                }

                if (distSq < bestVisibleDistSq)
                {
                    bool vis = _officialPhysics == null || !_officialPhysics.IsReady ||
                               _officialPhysics.TraceRayClear(Snap.PosX, Snap.PosY, muzzleZ, e.PosX, e.PosY, BodyAimZ(e), out _);
                    if (vis)
                    {
                        bestVisibleDistSq = distSq;
                        bestVisibleTarget = e;
                    }
                }
            }

            PlayerBasicInfo? bestTarget = bestVisibleTarget ?? bestAnyTarget;

            var wDef = _tables.GetWeapon(Snap.CurrentWeaponName);
            if (!wDef.IsMelee && Snap.CurrentCarryClip <= 0)
            {
                Snap.CurrentCarryClip = Math.Max(30, Snap.MaxClip * 4);
            }
            PlayerPredictionEngine.StepReload(Snap, wDef, reloadPressed: false, attackDown: false);

            bool isBioInfected = isBiohazardMode && BiohazardRound.IsInfected(Snap);
            bool isBioHuman = isBiohazardMode && !isBioInfected;
            bool isMelee = isBioInfected || Snap.CurrentWeapon == 3 || wDef.IsMelee;
            bool isSniper = !isMelee && wDef.WeaponType == 5;
            bool isShotgun = !isMelee && wDef.WeaponType == 6;
            PlayerPredictionEngine.StepSniperZoom(Snap, wDef, secondaryPressed: false, fired: false);
            UserCmd cmd = new UserCmd();
            bool botFired = false;
            bool botHeavyMelee = false;

            bool holdObjective = objectivePoint != null && objectivePoint.Length >= 4 && objectivePoint[3] > 0.5f;

            if (holdObjective)
            {
                _visibleTargetId = 0;
                _targetLockTime = 0f;
                // 正在包点原地安放或拆除 C4：静止读条并保持警戒
                cmd.ForwardMove = 0f;
                cmd.RightMove = 0f;
            }
            else if (bestTarget != null)
            {
                float dx = bestTarget.PosX - Snap.PosX;
                float dy = bestTarget.PosY - Snap.PosY;
                float targetZ = BodyAimZ(bestTarget);
                float dz = targetZ - muzzleZ;
                float dist2D = (float)Math.Sqrt(dx * dx + dy * dy);

                float desiredYaw = (float)(Math.Atan2(dy, dx) * 180.0 / Math.PI);
                float desiredPitch = -(float)(Math.Atan2(dz, Math.Max(1f, dist2D)) * 180.0 / Math.PI);

                bool hasLos = _officialPhysics == null || !_officialPhysics.IsReady ||
                              _officialPhysics.TraceRayClear(Snap.PosX, Snap.PosY, muzzleZ, bestTarget.PosX, bestTarget.PosY, targetZ, out _);
                if (!hasLos || bestTarget.Id != _visibleTargetId)
                {
                    _visibleTargetId = hasLos ? bestTarget.Id : 0;
                    _targetLockTime = 0f;
                }
                float engagementRange = Math.Min(wDef.ShotDistance,
                    isShotgun ? CloseEngagementDistance : MaxEngagementDistance);
                bool holdSniperPosition = isSniper && hasLos && dist2D < engagementRange && objectivePoint == null;

                _strafeTimer += dt;
                if (_strafeTimer >= _strafeDuration)
                {
                    _strafeTimer = 0f;
                    _strafeDir = -_strafeDir;
                    _strafeDuration = 0.45f + (float)_rng.NextDouble() * 0.50f;
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
                    if (!holdSniperPosition && moved < 55f && dist2D > 160f)
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
                bool steeringAroundObstacle = false;
                if (_steerHoldTimer > 1.2f)
                {
                    navYaw = goalYaw + _steerYawOffset;
                    usedNavNode = true;
                    steeringAroundObstacle = true;
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
                        steeringAroundObstacle = true;
                    }
                    else if (!IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 70f, goalYaw, 200f))
                    {
                        _steerYawOffset = FindClearSteerOffset(goalYaw, forceChange: false);
                        _steerHoldTimer = 2.2f;
                        navYaw = goalYaw + _steerYawOffset;
                        steeringAroundObstacle = true;
                    }
                }

                float aimTargetYaw = hasLos ? desiredYaw : navYaw;
                float deltaAimYaw = NormalizeAngle(aimTargetYaw - Snap.ViewYaw);
                float turnSpeed = _difficulty == "hard" ? 720f : (_difficulty == "easy" ? 240f : 460f);
                float maxStepYaw = turnSpeed * dt;
                Snap.ViewYaw = Math.Abs(deltaAimYaw) <= maxStepYaw ? aimTargetYaw : Snap.ViewYaw + Math.Sign(deltaAimYaw) * maxStepYaw;

                float aimPitch = hasLos ? desiredPitch : 0f;
                float deltaPitch = aimPitch - Snap.ViewPitch;
                float maxStepPitch = (turnSpeed * 0.7f) * dt;
                Snap.ViewPitch = Math.Abs(deltaPitch) <= maxStepPitch ? aimPitch : Snap.ViewPitch + Math.Sign(deltaPitch) * maxStepPitch;
                Snap.MoveYaw = Snap.ViewYaw;
                Snap.MovePitch = Snap.ViewPitch;

                float losYawDiff = Math.Abs(NormalizeAngle(desiredYaw - Snap.ViewYaw));

                if (isMelee)
                {
                    // 近战人机：严格禁止远程开火！必须冲到 <= 195cm 且视线无阻挡才挥砍
                    if (dist2D <= 195f && losYawDiff < 38f && hasLos)
                    {
                        bool heavy = _rng.NextDouble() < (_difficulty == "hard" ? 0.50 : 0.35);
                        if (heavy) cmd.Attack2 = true; else cmd.Attack = true;
                        Weapon.TryFireEx(Snap, Physics, !heavy, heavy, _tables, _officialPhysics, _freeForAll, allEntities, out botFired, out _);
                        botHeavyMelee = heavy && botFired;
                    }
                    cmd.ForwardMove = (!hasLos || dist2D > 95f) ? 1.0f : 0.2f;
                    cmd.RightMove = hasLos ? (_strafeDir * 0.25f) : (_strafeDir * 0.15f);
                }
                else
                {
                    // 枪械人机：仅在有视线时开火，按难度区分反应延迟、点射节奏与瞄准精度
                    if (hasLos) _targetLockTime += dt;

                    if (_burstCooldown > 0f)
                    {
                        _burstCooldown = Math.Max(0f, _burstCooldown - dt);
                    }

                    bool lowAmmo = Snap.MaxClip > 0 && Snap.CurrentClip <= Math.Max(3, Snap.MaxClip / 6) && Snap.CurrentCarryClip > 0;
                    if (lowAmmo && !hasLos && !Snap.IsStartReload)
                    {
                        PlayerPredictionEngine.StepReload(Snap, wDef, reloadPressed: true, attackDown: false);
                    }

                    float reqLock = _difficulty == "hard" ? 0.06f : (_difficulty == "easy" ? 0.40f : 0.28f);
                    float aimCone = _difficulty == "hard" ? 12f : (_difficulty == "easy" ? 28f : 18f);
                    bool inAim = losYawDiff < aimCone;
                    bool canEngage = hasLos && inAim && _targetLockTime >= reqLock
                        && dist2D < engagementRange && !Snap.IsStartReload;
                    if (isSniper)
                    {
                        float speed = _officialPhysics?.IsReady == true ? Snap.Velocity2D : Physics.Velocity.Length2D();
                        bool grounded = _officialPhysics?.IsReady == true ? Snap.OnGround : Physics.IsOnGround;
                        if (holdSniperPosition && canEngage && grounded && speed <= 10f)
                        {
                            if (Snap.CurrentClip == 0 || Snap.Fov < 90)
                            {
                                cmd.Attack = true;
                                Weapon.TryFireEx(Snap, Physics, true, false, _tables, _officialPhysics,
                                    _freeForAll, allEntities, out botFired, out _);
                                if (botFired && Snap.CurrentWeaponName == wDef.Name)
                                {
                                    PlayerPredictionEngine.StepSniperZoom(Snap, wDef, secondaryPressed: false, fired: true);
                                    if (wDef.Ballistics == null)
                                        PlayerPredictionEngine.StepWeaponIdleAndAccuracy(Snap, wDef,
                                            isAttackDown: true, fired: true, isSecondary: false);
                                }
                            }
                            else if (!Snap.ResumeZoom)
                            {
                                PlayerPredictionEngine.StepSniperZoom(Snap, wDef, secondaryPressed: true, fired: false);
                            }
                        }
                    }
                    else if (canEngage && _burstCooldown <= 0f && !(wDef.Ballistics?.SingleShot == true && Snap.ShotsFired > 0))
                    {
                        cmd.Attack = true;
                        Weapon.TryFireEx(Snap, Physics, true, false, _tables, _officialPhysics, _freeForAll, allEntities, out botFired, out _);
                        _burstTimer += dt;
                        float maxBurst = _difficulty == "hard" ? 0.70f : (_difficulty == "easy" ? 0.35f : 0.50f);
                        if (_burstTimer >= maxBurst)
                        {
                            _burstTimer = 0f;
                            _burstCooldown = _difficulty == "hard" ? 0.12f : (_difficulty == "easy" ? 0.40f : 0.35f);
                        }
                    }
                    else
                    {
                        _burstTimer = 0f;
                    }

                    if (holdSniperPosition)
                    {
                        cmd.ForwardMove = 0f;
                        cmd.RightMove = 0f;
                        steeringAroundObstacle = false;
                    }
                    else if (isBioHuman && hasLos && dist2D < 380f)
                    {
                        // 生化模式人类 AI：变异体贴近 380cm 时边退边扫射风筝并跳跃拉开身位
                        cmd.ForwardMove = -0.80f;
                        cmd.RightMove = _strafeDir * 0.65f;
                        if (_strafeTimer < 0.05f && _rng.NextDouble() < 0.35) cmd.Jump = true;
                    }
                    else if (!hasLos || dist2D > CloseEngagementDistance)
                    {
                        cmd.ForwardMove = 1.0f;
                        cmd.RightMove = hasLos ? (_strafeDir * 0.35f) : 0f;
                    }
                    else
                    {
                        cmd.ForwardMove = dist2D > 350f ? 0.25f : -0.15f;
                        cmd.RightMove = _strafeDir * 0.85f;
                        if (hasLos && _strafeTimer < 0.05f && _rng.NextDouble() < 0.25)
                        {
                            cmd.Jump = true;
                        }
                        else if (hasLos && _strafeDir < 0f && dist2D > 250f && _difficulty != "easy")
                        {
                            cmd.Duck = _rng.NextDouble() < 0.35;
                        }
                    }
                }
                if (isBioInfected && dist2D > 160f && dist2D < 500f && _strafeTimer < 0.04f && _rng.NextDouble() < 0.30)
                {
                    cmd.Jump = true;
                }
                if (steeringAroundObstacle)
                {
                    float relativeYaw = NormalizeAngle(navYaw - Snap.ViewYaw) * (MathF.PI / 180f);
                    cmd.ForwardMove = MathF.Cos(relativeYaw);
                    cmd.RightMove = -MathF.Sin(relativeYaw);
                }
            }
            else if (objectivePoint != null && objectivePoint.Length >= 2)
            {
                _visibleTargetId = 0;
                _targetLockTime = 0f;
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
                _visibleTargetId = 0;
                _targetLockTime = 0f;
                float baseYaw = Snap.ViewYaw;
                if (!IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 70f, baseYaw, 200f))
                {
                    baseYaw += FindClearSteerOffset(baseYaw, forceChange: false);
                }
                Snap.ViewYaw = baseYaw;
                Snap.MoveYaw = baseYaw;
                Snap.ViewPitch = 0f;
                Snap.MovePitch = 0f;
                cmd.ForwardMove = 1.0f;
            }

            cmd.Yaw = Snap.ViewYaw;
            cmd.Pitch = Snap.ViewPitch;
            bool isFwd = cmd.ForwardMove > 0.1f;
            bool isBwd = cmd.ForwardMove < -0.1f;
            bool isLeft = cmd.RightMove < -0.1f;
            bool isRight = cmd.RightMove > 0.1f;
            PlayerPredictionEngine.UpdateMoveYaw(Snap, Snap.ViewYaw, isFwd, isBwd, isLeft, isRight);

            float travelYaw = cmd.Yaw + MathF.Atan2(-cmd.RightMove, cmd.ForwardMove) * (180f / MathF.PI);
            if (cmd.ForwardMove * cmd.ForwardMove + cmd.RightMove * cmd.RightMove > 0.25f &&
                Snap.OnGround && !cmd.Jump &&
                !IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 52f, travelYaw, 75f) &&
                IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 125f, travelYaw, 120f) &&
                IsRayClear2D(Snap.PosX, Snap.PosY, Snap.PosZ + 170f, travelYaw, 100f))
            {
                cmd.Jump = true;
            }

            if (_officialPhysics != null && _officialPhysics.IsReady)
            {
                int maxSpd = wDef.GetMoveSpeed(Snap.Fov);
                var pyCmd = new ServerPyCmd
                {
                    Sequence = ++Snap.CmdSequence,
                    FrameInterval = frameMs,
                    MoveForward = 1014f * cmd.ForwardMove,
                    MoveRight = 1014f * cmd.RightMove,
                    IsForward = isFwd,
                    IsBackward = isBwd,
                    IsLeft = isLeft,
                    IsRight = isRight,
                    IsJump = cmd.Jump,
                    IsDuck = cmd.Duck,
                    CameraYaw = Snap.ViewYaw,
                    CameraPitch = Snap.ViewPitch
                };
                _officialPhysics.StepPlayer(Id, pyCmd, maxSpd);
                if (_officialPhysics.TryGetFullState(
                    Id,
                    out float px, out float py, out float pz,
                    out float vx, out float vy, out float vz,
                    out double vh, out int ds, out int dtime,
                    out bool og, out int gNum, out int v2d, out float stamina))
                {
                    Snap.PosX = px;
                    Snap.PosY = py;
                    Snap.PosZ = pz;
                    Snap.VelX = vx;
                    Snap.VelY = vy;
                    Snap.VelZ = vz;
                    Snap.ViewHeight = (float)vh;
                    Snap.DuckState = ds;
                    Snap.DuckTime = dtime;
                    Snap.OnGround = og;
                    Snap.GroundEntityNum = gNum;
                    Snap.Velocity2D = v2d;
                    Snap.Stamina = stamina;
                    Snap.Moving = v2d > 10;
                    PlayerPredictionEngine.UpdateLegsAnimAndSpeedTime(Snap, og, ds, v2d, false, isBwd, frameMs);
                }
            }
            else
            {
                G_Active.ClientThink(Physics, Snap, cmd, dt);
            }

            if (!Snap.IsDead)
            {
                if (wDef.Ballistics != null && Snap.CurrentWeaponName == wDef.Name)
                    PlayerPredictionEngine.StepWeaponIdleAndAccuracy(Snap, wDef, cmd.Attack, botFired, false);
                int animClockMs = serverTimeMs > 0 ? serverTimeMs : Snap.ClientTime;
                float nowSec = animClockMs / 1000f;
                if (botFired)
                {
                    Snap.TorsoAnim = (botHeavyMelee && !isMelee) ? 20 : 15;
                    Snap.TorsoAnimStartTime = animClockMs;
                    float minDur = botHeavyMelee ? 0.85f : (isMelee ? 0.40f : 0.24f);
                    float animDur = PlayerPredictionEngine.GetDefaultViewAnimDurationMs(wDef,
                        botHeavyMelee ? 20 : (isMelee ? 31 : 15)) / 1000f;
                    Snap.FireAnimEndTime = nowSec + Math.Max(minDur, animDur);
                }
                else if (Snap.IsStartReload)
                {
                    if (Snap.TorsoAnim != 17)
                    {
                        Snap.TorsoAnim = 17;
                        Snap.TorsoAnimStartTime = animClockMs;
                    }
                    Snap.FireAnimEndTime = nowSec + 0.2f;
                }
                else if (nowSec >= Snap.FireAnimEndTime && Snap.TorsoAnim != 13)
                {
                    Snap.TorsoAnim = 13;
                    Snap.TorsoAnimStartTime = animClockMs;
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
