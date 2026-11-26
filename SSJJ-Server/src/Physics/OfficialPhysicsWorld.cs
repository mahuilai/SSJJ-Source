using System;
using System.Collections.Generic;
using config;
using data;
using math;
using physics;
using physics.data;
using physics.engine;
using physics.engine.business;
using physics.engine.entity;
using physics.engine.entity.indicator;
using physics.entity;
using physics.impl;
using physics.move;
using physics.trace;
using share;
using share.constant;
using SSJJ.Server.NativeEngine;
using SSJJ.Server.Snapshot;
using wizardengine;

namespace SSJJ.Server.Physics
{
    /// <summary>
    /// 与客户端 SSJJPhysics.Pmove 对齐的服务端权威 Pmove：
    /// 落地 CheckFalling 时复位 IsLimitMaxSpeed = true（恢复 1.25x / 825 限速），开启 ThrustArea，同步空停与落地状态。
    /// </summary>
    public sealed class ServerPmove : DefaultPmove
    {
        public ServerPmove(IPyEntityMove entityMove, IPyWorld world, IPyEntityManager entityManager)
            : base(entityMove, world, entityManager)
        {
        }

        protected override void CheckFalling()
        {
            if (GetPlayerMove() is ServerPlayerPhysicsAdapter adapter)
            {
                adapter.LimitMaxSpeed = true;
                if (adapter.GetPlayerStateType(1073741824))
                {
                    adapter.DeletePlayerStateType(33554432, false);
                    adapter.DeletePlayerStateType(268435456, false);
                }
            }
        }

        protected override void OnGroundTraceMissed()
        {
            if (GetPlayerMove() is ServerPlayerPhysicsAdapter adapter)
            {
                adapter.SetGroundEntityNum(-1);
            }
            pml.groundPlane = true;
            pml.walking = false;
        }

        protected override void OnThrustAreaLoop()
        {
            if (pml.walking && _velocity[2] - 2032f * pml.frametime > 0f)
            {
                pml.groundPlane = false;
                pml.walking = false;
                GetPlayerMove()?.SetGroundEntityNum(-1);
            }
        }

        protected override bool IsTaregetCanThrustArea() => true;

        protected override bool IsNotPlayerAirMove()
        {
            if (GetPlayerMove() is ServerPlayerPhysicsAdapter adapter && adapter.GetPlayerStateType(1073741824))
            {
                _velocity[0] = 0f;
                _velocity[1] = 0f;
                _velocity[2] = 0f;
                return true;
            }
            return false;
        }
    }

    public sealed class ServerWeEngineHandler : DefaultWeEngineHandler
    {
        private readonly List<IPyEntity> _players = new List<IPyEntity>();
        private readonly float[]? _obfuscatorSeed;

        public ServerWeEngineHandler(float[]? obfuscatorSeed = null)
        {
            _obfuscatorSeed = obfuscatorSeed;
        }

        public void RegisterPlayer(IPyEntity entity)
        {
            if (!_players.Contains(entity)) _players.Add(entity);
        }

        public void UnregisterPlayer(IPyEntity entity)
        {
            _players.Remove(entity);
        }

        public override bool IsBspAsTriMesh() => false;

        public override float[] GetObfuscatorSeed() => _obfuscatorSeed ?? new float[] { 0f, 0f, 0f };

        public override ISceneMoveData CreateSceneMoveData() => new SceneMoveData();

        public override IPyMove CreatePmove(IPyEntityMove entityMove, IPyWorld world, IPyEntityManager entityManager) =>
            new ServerPmove(entityMove, world, entityManager);

        public override IList<IPyEntity> GetPlayerEntityList() => _players;

        public override void LinkEngineEntityToGameEntity(IPySceneEntityConfig sceneConfig, WeBaseEntity baseEntity)
        {
            // No-op in headless/server simulation; entities live directly in WeScene.
        }

        public override void RemoveEntity(IPyEntity engineEntity)
        {
            _players.Remove(engineEntity);
        }
    }

    public sealed class ServerPyCmd : IPyUserCmd
    {
        public float MoveForward { get; set; }
        public float MoveRight { get; set; }
        public int FrameInterval { get; set; } = 16;
        public bool IsJump { get; set; }
        public double CameraYaw { get; set; }
        public double CameraPitch { get; set; }
        public bool IsForward { get; set; }
        public bool IsBackward { get; set; }
        public bool IsLeft { get; set; }
        public bool IsRight { get; set; }
        public bool IsDuck { get; set; }
        public bool IsWalk { get; set; }
        public bool IsCtrl { get; set; }
        public int Sequence { get; set; }
        public int Seq() => Sequence;
    }

    public sealed class ServerPlayerPhysicsAdapter : IPyPlayerMove, IPyPlayerEntity, IPyPlayerMoveAdapter, IPlayerIndicator
    {
        public int Id { get; }
        public int Team { get; set; }
        public string Career { get; set; }
        public bool Bot { get; }
        public bool Dead { get; set; }
        public double X { get; set; }
        public double Y { get; set; }
        public double Z { get; set; }
        public double ViewHeight { get; set; } = 150.0;
        public double NormalViewHeight { get; } = 150.0;
        public double DuckViewHeight { get; } = 93.0;
        public int DuckState { get; set; } = 3;
        public int DuckTime { get; set; }
        public bool OnGround { get; set; } = true;
        public int GroundEntityNum { get; set; } = -1;
        public float Stamina { get; set; } = 0f;
        public int Velocity2D { get; set; }
        public Vector3D Velocity { get; } = new Vector3D();
        public Pml Pml { get; } = new Pml();
        public CBrush NormalBrush { get; }
        public CBrush DuckBrush { get; }
        public CBrush DuckJumpBrush { get; }
        public CBrush DetectorBrush { get; }
        public int LegsAnim { get; set; } = 7;
        public WeEntity? EngineEntity { get; set; }
        public int PlayerStates { get; set; }
        public int FlyWaitTime { get; set; }
        public bool LimitMaxSpeed { get; set; } = true;
        public bool LimitSpeedInJumpRule { get; set; } = true;
        public float GravityEffectRate { get; set; } = 1.0f;
        public int Airaccelerate { get; set; } = PmoveBase.DEFAULT_AIRACCELERATE; // 10
        public float SkillJumpHeight { get; set; } = 0f;
        public float SkillJumpHeightRate { get; set; } = 0f;
        public float FlySpeed { get; set; } = 0f;
        public float BeingHitFriction { get; set; } = 16f;
        public int BeingHitTime { get; set; }
        public int ImpulseTime { get; set; }
        public int ImpulseTime2 { get; set; }
        public bool LastCrash { get; set; }
        public bool LastPerfectjump { get; set; }
        public int ContinuousPerfectjumpCount { get; set; }
        public bool CtrlDuck { get; set; }
        public bool Spurting { get; set; }
        public bool AnimPos { get; set; }
        public int AnimMoveTime { get; set; }
        public float ViewYaw { get; set; }
        public float ViewPitch { get; set; }
        public string WeaponName { get; set; } = "m4a1";
        public Vector3D LadderNormal { get; } = new Vector3D(0, 0, 0);

        private readonly Vector3D _normalMin;
        private readonly Vector3D _normalMax;
        private readonly Vector3D _duckMin;
        private readonly Vector3D _duckMax;
        private readonly Vector3D _duckJumpMin;
        private readonly Vector3D _duckJumpMax;

        public ServerPlayerPhysicsAdapter(int id, int team, string career, bool isBot, float x, float y, float z)
        {
            Id = id;
            Team = team;
            Career = string.IsNullOrEmpty(career) ? "police" : career;
            Bot = isBot;
            X = x;
            Y = y;
            Z = z;

            _normalMin = BoundBoxConfig.GetBoundsMinForPlayer(Career, 3) ?? new Vector3D(-45, -45, 0);
            _normalMax = BoundBoxConfig.GetBoundsMaxForPlayer(Career, 3) ?? new Vector3D(45, 45, 170);
            _duckMin = BoundBoxConfig.GetBoundsMinForPlayer(Career, 0) ?? new Vector3D(-45, -45, 0);
            _duckMax = BoundBoxConfig.GetBoundsMaxForPlayer(Career, 0) ?? new Vector3D(45, 45, 110);
            _duckJumpMin = BoundBoxConfig.GetBoundsMinForPlayer(Career, 2) ?? new Vector3D(-45, -45, 60);
            _duckJumpMax = BoundBoxConfig.GetBoundsMaxForPlayer(Career, 2) ?? new Vector3D(45, 45, 170);
            var detMin = BoundBoxConfig.GetDetectorBoundsMinForNormalPlayer(Career) ?? _normalMin;
            var detMax = BoundBoxConfig.GetDetectorBoundsMaxForNormalPlayer(Career) ?? _normalMax;

            NormalBrush = BrushUtils.CreateBrushInternal(_normalMin, _normalMax);
            DuckBrush = BrushUtils.CreateBrushInternal(_duckMin, _duckMax);
            DuckJumpBrush = BrushUtils.CreateBrushInternal(_duckJumpMin, _duckJumpMax);
            DetectorBrush = BrushUtils.CreateBrushInternal(detMin, detMax);
        }

        // IPyEntity & IPyPlayerMoveAdapter
        public IPyPlayerMove GetPlayerMove() => this;
        public IPyEntity GetEntity() => this;
        public WeEntity? GetEngineEntity() => EngineEntity;
        public void SetEngineEntity(WeEntity entity) => EngineEntity = entity;
        public WeEntity CreateEngineEntity(WeScene scene) =>
            new WePlayerEntity(scene, Career, Id, new Vector3D(X, Y, Z), scene.IsSimulationEnabled(), 255);
        public void DisposeEngineEntity() => EngineEntity = null;
        public int GetId() => Id;
        public int GetTeam() => Team;
        public double GetX() => X;
        public double GetY() => Y;
        public double GetZ() => Z;
        public void SetX(double endpo) => X = endpo;
        public void SetY(double endpo) => Y = endpo;
        public void SetZ(double endpo) => Z = endpo;
        public void SetPosition(float x, float y, float z) { X = x; Y = y; Z = z; }
        public CBrush GetBrush() => DuckState switch
        {
            0 => DuckBrush,
            2 => DuckJumpBrush,
            _ => NormalBrush
        };
        public CBrush GetDetectorBrush() => DetectorBrush;
        public bool GetNeedToCheckCollisionWithOtherEntities() => !Dead;
        public bool IsAirPush() => true;
        public void OnCrashLand() { }

        // Velocity & physics (1:1 aligned with BasePyPlayerAdapter)
        public Vector3D GetVelocity() => Velocity;
        public void SetVelocity(Vector3D v) { if (v != null) Velocity.CopyFrom(v); }
        public void SetVelocity(float x, float y, float z) { Velocity.x = x; Velocity.y = y; Velocity.z = z; }
        public void SetVelocity2D(int velocity2D) => Velocity2D = velocity2D;
        public float GetGravityEffectRate() => GravityEffectRate;
        public int GetAiraccelerate() => Airaccelerate;
        public float GetJumpHeight(float currentVel)
        {
            currentVel += SkillJumpHeight;
            currentVel *= (float)Math.Sqrt(1f + SkillJumpHeightRate);
            return currentVel;
        }
        public float GetFlySpeed() => FlySpeed;
        public bool IsOnGround() => OnGround;
        public void SetOnGround(bool onGround) => OnGround = onGround;
        public int GetGroundEntityNum() => GroundEntityNum;
        public void SetGroundEntityNum(int entityNumNone) => GroundEntityNum = entityNumNone;
        public void SetGroundTraceSurfaceFlags(int surfaceFlags) { }
        public void SetSlideMoveSurfaceFlags(int surfaceFlags) { }
        public Pml GetPml() => Pml;
        public Vector3D GetLadderNormal() => LadderNormal;

        // Bounds & Duck (1:1 aligned with BasePyPlayerAdapter & BoundBoxConfig)
        public Vector3D GetCurrentMin() => DuckState switch
        {
            0 => _duckMin,
            2 => _duckJumpMin,
            _ => _normalMin
        };
        public double GetCurrentMinZ() => GetCurrentMin().z;
        public bool IsUsingDuckJumpBrush() => GetBrush() == DuckJumpBrush;
        public Vector3D GetCurrentMax() => DuckState switch
        {
            0 => _duckMax,
            2 => _duckJumpMax,
            _ => _normalMax
        };
        public Vector3D GetNormalMax() => _normalMax;
        public Vector3D GetDuckMax() => _duckMax;
        public double GetViewHeight() => ViewHeight;
        public void SetViewHeight(double duckViewHeight) => ViewHeight = duckViewHeight;
        public double GetNormalViewHeight() => NormalViewHeight;
        public double GetDuckViewHeight() => DuckViewHeight;
        public double GetDuckTime() => DuckTime;
        public void SetDuckTime(int i) => DuckTime = i;
        public int GetDuckState() => DuckState;
        public void SetDuckState(int duckState) => DuckState = duckState;
        public int GetAdditonalCrouchSpeed() => 0;
        public bool IsServerHoldDuck() => false;
        public bool GetCtrlDuck() => CtrlDuck;

        // Player state
        public bool IsDead() => Dead;
        public bool IsBot() => Bot;
        public bool IsPlayer() => true;
        public string GetCareer() => Career;
        public string GetCurrentWeaponName() => WeaponName;
        public float GetStamina() => Stamina;
        public void SetStamina(float stamina) => Stamina = stamina;
        public bool BotAiMaskMoveSolid() => true;
        public bool IsBotHumanJump() => true;
        public bool IsBotCmdDrive() => true;
        public bool GetPlayerStateType(int flag) => (PlayerStates & flag) != 0;
        public void AddPlayerStateType(int flag) => PlayerStates |= flag;
        public void AddPlayerStateType(int flag, int duration, bool b) => PlayerStates |= flag;
        public void DeletePlayerStateType(int flag, bool b) => PlayerStates &= ~flag;
        public bool GetStatusByKeyName(int playerInfoStateType) => false;
        public bool GetPlayerInfo(int infoId) => false;
        public bool GetHitImpulseVelocity(float[] impulseVel) => false;
        public bool GetHitImpulseVelocity2(float[] impulseVel) => false;
        public void UpdateHitImpulseSet(int dtime)
        {
            ImpulseTime = ImpulseTime > dtime ? ImpulseTime - dtime : 0;
        }
        public void UpdateHitImpulseSet2(int dtime)
        {
            ImpulseTime2 = ImpulseTime2 > dtime ? ImpulseTime2 - dtime : 0;
        }
        public int GetImpulseTime() => ImpulseTime;
        public int GetImpulseTime2() => ImpulseTime2;
        public void WhenJumpLand() { }
        public bool GetBeingHit() => BeingHitTime > 0;
        public void UpdateBeingHitTime(int frameInterval)
        {
            BeingHitTime = BeingHitTime > frameInterval ? BeingHitTime - frameInterval : 0;
        }
        public float GetBeingHitFriction() => BeingHitFriction;
        public int GetFlyWaitTime() => FlyWaitTime;
        public void SetFlyWaitTime(int flyWaitTime) => FlyWaitTime = flyWaitTime;
        public void OnCheckWalkOnStep(float newZ) { }
        public bool IsHumanHero() => false;
        public bool IsHumanity() => true;
        public void SetIsLimitMaxSpeed(bool value) => LimitMaxSpeed = value;
        public bool GetIsLimitMaxSpeed() => LimitMaxSpeed && !Pml.slideOnN2GrenadeIcd && LimitSpeedInJumpRule;
        public bool ActThirdMove() => false;
        public bool IsActThirdMove() => false;
        public bool GetIsSpurting() => Spurting;
        public void SetIsSpurting(bool isSpurting) => Spurting = isSpurting;
        public bool IsKeepFly() => false;
        public float GetKeepFlySpeed() => 0f;
        public void SetIsLastCrash(bool isLastCrash) => LastCrash = isLastCrash;
        public bool IsLastCrash() => LastCrash;
        public void SetLastPerfectjump(bool isPerfect) => LastPerfectjump = isPerfect;
        public bool IsLastPerfectjump() => LastPerfectjump;
        public void SetContinuousPerfectjumpCount(int count) => ContinuousPerfectjumpCount = count;
        public int GetContinuousPerfectjumpCount() => ContinuousPerfectjumpCount;
        public bool IfControlEntityHide() => false;
        public int GetAnimMoveTime() => AnimMoveTime;
        public void SetAnimMoveTime(int animMoveTime) => AnimMoveTime = animMoveTime;
        public bool IsAnimPosition() => AnimPos;
        public void SetAnimPosition(bool animPosition) => AnimPos = animPosition;

        // Unused interface methods on IPyThirdViewEntity / IPyAttackableEntity / IEntityIndicator
        public int GetEntityType() => 1;
        public int GetAttackEntityType() => 1;
        public int GetTeamId() => Team;
        public bool IsHide() => false;
        public float GetScale() => 1f;
        public bool IsGlide() => false;
        public bool IsEnableCollision() => !Dead;
        public float GetMaxHp() => 100f;
        public float GetHp() => Dead ? 0f : 100f;
        public int GetControlEntityId() => -1;
        public int GetOwnerId() => Id;
        public bool IsSameTeamExclude(int team) => Team == team;
        public double GetMoveYaw() => ViewYaw;
        public double GetViewYaw() => ViewYaw;
        public int GetLegsAnim() => LegsAnim;
        public int GetVelocity2D() => Velocity2D;
    }

    public sealed class OfficialPhysicsWorld : System.IDisposable
    {
        private WeEngine? _weEngine;
        private ServerWeEngineHandler? _handler;
        private readonly Dictionary<int, ServerPlayerPhysicsAdapter> _adapters = new Dictionary<int, ServerPlayerPhysicsAdapter>();
        private float[] _minBound = new float[3];
        private float[] _maxBound = new float[3];

        public bool IsReady { get; private set; }
        internal bool IsBelowScene(float z) => IsReady && z < _minBound[2];

        public bool Initialize(int mapId, byte[]? bspBytes)
        {
            try
            {
                if (!NativeWizzardHost.Initialize())
                {
                    Console.WriteLine("[SSJJ-Server][WE-ENGINE] NativeWizzardHost.Initialize returned false.");
                    return false;
                }
                if (!WeEngineUtil.InitNativeLibrary())
                {
                    Console.WriteLine("[SSJJ-Server][WE-ENGINE] WeEngineUtil.InitNativeLibrary returned false.");
                    return false;
                }
                if (bspBytes == null || bspBytes.Length < 64)
                {
                    Console.WriteLine($"[SSJJ-Server][WE-ENGINE] No raw BSP bytes for map{mapId}; falling back to software physics.");
                    return false;
                }

                float[]? seed = mapId == 100001
                    ? new float[] { -4392f, -4944f, -3319f }
                    : null;
                _handler = new ServerWeEngineHandler(seed);
                _weEngine = new WeEngine(_handler);
                var clipMap = new DefaultPyClipMap();
                _weEngine.Init(clipMap, bspBytes);
                _weEngine.GetSceneBound(_minBound, _maxBound);
                IsReady = true;
                Console.WriteLine($"[SSJJ-Server][WE-ENGINE] map{mapId} initialized! Bounds=({_minBound[0]:F0},{_minBound[1]:F0},{_minBound[2]:F0})..({_maxBound[0]:F0},{_maxBound[1]:F0},{_maxBound[2]:F0})");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SSJJ-Server][WE-ENGINE] Init failed: {ex.GetType().Name}: {ex.Message}");
                IsReady = false;
                return false;
            }
        }

        public ServerPlayerPhysicsAdapter RegisterEntity(int id, int team, string career, bool isBot, float x, float y, float z)
        {
            var adapter = new ServerPlayerPhysicsAdapter(id, team, career, isBot, x, y, z);
            _adapters[id] = adapter;
            if (IsReady && _weEngine != null && _handler != null)
            {
                _handler.RegisterPlayer(adapter);
                _weEngine.GetEntityManager().UpdateEntityNormalBrush(0, adapter);
            }
            return adapter;
        }

        public void UnregisterEntity(int id)
        {
            if (!_adapters.Remove(id, out var adapter)) return;
            _handler?.UnregisterPlayer(adapter);
            if (adapter.EngineEntity is { } entity)
            {
                try
                {
                    entity.GetScene().RemoveEntity(entity);
                    adapter.DisposeEngineEntity();
                }
                catch { }
            }
        }

        public void SetTeam(int id, int team)
        {
            if (_adapters.TryGetValue(id, out var adapter))
            {
                adapter.Team = team;
            }
        }

        public void SetPlayerPosition(int id, float x, float y, float z)
        {
            if (!_adapters.TryGetValue(id, out var adapter)) return;
            adapter.SetPosition(x, y, z);
            adapter.SetVelocity(0f, 0f, 0f);
            adapter.Dead = false;
            adapter.DuckState = 3;
            adapter.DuckTime = 0;
            adapter.Stamina = 0f;
            adapter.OnGround = true;
            adapter.GroundEntityNum = -1;
            adapter.Velocity2D = 0;
            adapter.ViewHeight = adapter.NormalViewHeight;
            adapter.PlayerStates = 0;
            adapter.LimitMaxSpeed = true;
            adapter.LimitSpeedInJumpRule = true;
            adapter.FlyWaitTime = 0;
            adapter.BeingHitTime = 0;
            adapter.BeingHitFriction = 16f;
            adapter.ImpulseTime = 0;
            adapter.ImpulseTime2 = 0;
            adapter.LastCrash = false;
            adapter.LastPerfectjump = false;
            adapter.ContinuousPerfectjumpCount = 0;
            adapter.Spurting = false;
            adapter.LadderNormal.SetTo(0.0, 0.0, 0.0);
            adapter.Pml.walking = true;
            adapter.Pml.groundPlane = true;
            adapter.Pml.secondJump = false;
            adapter.Pml.laddersWalking = false;
            adapter.Pml.slideOnN2GrenadeIcd = false;
            adapter.Pml.duckState = 3;
            adapter.Pml.isDead = false;
            if (IsReady && _weEngine != null)
            {
                try { _weEngine.GetEntityManager()?.UpdateEntityNormalBrush(0, adapter); } catch { }
            }
        }

        public void SetPlayerDead(int id, bool dead)
        {
            if (_adapters.TryGetValue(id, out var adapter))
            {
                adapter.Dead = dead;
            }
        }

        public bool TryGetState(int id, out float x, out float y, out float z, out double viewHeight, out int duckState, out bool onGround, out int velocity2D)
        {
            if (_adapters.TryGetValue(id, out var a))
            {
                x = (float)a.X;
                y = (float)a.Y;
                z = (float)a.Z;
                viewHeight = a.ViewHeight;
                duckState = a.DuckState;
                onGround = a.OnGround;
                velocity2D = a.Velocity2D;
                return true;
            }
            x = y = z = 0f;
            viewHeight = 150.0;
            duckState = 3;
            onGround = true;
            velocity2D = 0;
            return false;
        }

        public bool TryGetFullState(
            int id,
            out float x, out float y, out float z,
            out float vx, out float vy, out float vz,
            out double viewHeight, out int duckState, out int duckTime,
            out bool onGround, out int groundEntityNum,
            out int velocity2D, out float stamina) =>
            TryGetFullState(id, out x, out y, out z, out vx, out vy, out vz, out viewHeight,
                out duckState, out duckTime, out onGround, out groundEntityNum, out velocity2D, out stamina,
                out _, out _, out _);

        public bool TryGetFullState(
            int id,
            out float x, out float y, out float z,
            out float vx, out float vy, out float vz,
            out double viewHeight, out int duckState, out int duckTime,
            out bool onGround, out int groundEntityNum,
            out int velocity2D, out float stamina,
            out int playerStateFlag, out float airaccelerate, out bool limitSpeedInJumpRule)
        {
            if (_adapters.TryGetValue(id, out var a))
            {
                x = (float)a.X;
                y = (float)a.Y;
                z = (float)a.Z;
                vx = (float)a.Velocity.x;
                vy = (float)a.Velocity.y;
                vz = (float)a.Velocity.z;
                viewHeight = a.ViewHeight;
                duckState = a.DuckState;
                duckTime = a.DuckTime;
                onGround = a.OnGround;
                groundEntityNum = a.GroundEntityNum;
                velocity2D = a.Velocity2D;
                stamina = a.Stamina;
                playerStateFlag = a.PlayerStates;
                airaccelerate = a.Airaccelerate;
                limitSpeedInJumpRule = a.LimitSpeedInJumpRule;
                return true;
            }
            x = y = z = vx = vy = vz = 0f;
            viewHeight = 150.0;
            duckState = 3;
            duckTime = 0;
            onGround = true;
            groundEntityNum = -1;
            velocity2D = 0;
            stamina = 0f;
            playerStateFlag = 0;
            airaccelerate = PmoveBase.DEFAULT_AIRACCELERATE;
            limitSpeedInJumpRule = true;
            return false;
        }

        public bool CopyPlayerState(PlayerBasicInfo player)
        {
            if (!TryGetFullState(player.Id, out float x, out float y, out float z,
                out float vx, out float vy, out float vz, out double viewHeight, out int duckState, out int duckTime,
                out bool onGround, out int groundEntityNum, out int velocity2D, out float stamina,
                out int flags, out float airAccelerate, out bool limitSpeed)) return false;

            player.PosX = x; player.PosY = y; player.PosZ = z;
            player.VelX = vx; player.VelY = vy; player.VelZ = vz;
            player.ViewHeight = (float)viewHeight;
            player.DuckState = duckState;
            player.DuckTime = duckTime;
            player.OnGround = onGround;
            player.GroundEntityNum = groundEntityNum;
            player.Velocity2D = velocity2D;
            player.Stamina = stamina;
            player.PlayerStateFlag = flags;
            player.Airaccelerate = airAccelerate;
            player.LimitSpeedInJumpRule = limitSpeed;
            return true;
        }

        public void StepCorpse(PlayerBasicInfo player, int frameIntervalMs)
        {
            if (!_adapters.TryGetValue(player.Id, out var adapter) || !adapter.Dead) return;
            if (adapter.OnGround && adapter.Pml.isDead && adapter.Velocity.GetLength() == 0) return;
            StepPlayer(player.Id, new ServerPyCmd
            {
                FrameInterval = frameIntervalMs,
                CameraYaw = player.ViewYaw,
                CameraPitch = player.ViewPitch
            }, weaponMaxSpeed: 0);
            CopyPlayerState(player);
        }

        public void StepPlayer(int id, ServerPyCmd cmd, int weaponMaxSpeed)
        {
            if (!IsReady || _weEngine == null || !_adapters.TryGetValue(id, out var adapter)) return;
            if (cmd.FrameInterval <= 0) return;
            try
            {
                adapter.ViewYaw = (float)cmd.CameraYaw;
                adapter.ViewPitch = (float)cmd.CameraPitch;

                // 1. 与客户端 BasePyPlayerAdapter.GetMaxSpeed (L497) + PlayerSpeedUtil.GetPlayerSpeed 1:1 对齐
                int maxSpeed = weaponMaxSpeed;
                if (!PlayerCareerUtil.IsTPS(adapter.Career))
                {
                    // 原版非 TPS 角色基础移速封顶 660 -> PmoveBase.LimitVelocityMaxSpeed 1.25x 限速上限 825
                    maxSpeed = Math.Min(660, maxSpeed);
                }

                int speed;
                if (adapter.DuckState == 0 || adapter.DuckState == 1)
                {
                    speed = PlayerConf.CrouchMoveSpeed() + adapter.GetAdditonalCrouchSpeed(); // 203
                }
                else if (cmd.IsWalk)
                {
                    speed = PlayerConf.WalkSpeed(); // 305
                }
                else
                {
                    speed = maxSpeed;
                }

                // 场景特殊变速区（与 PlayerMovePredicationSystem.FixSpeed 对齐）
                if (_weEngine.GetWorld() is WorldBase worldBase)
                {
                    var spArea = worldBase.GetSceneSpecialArea((float)adapter.X, (float)adapter.Y, (float)adapter.Z, (SpecialAreaEnum)2);
                    if (spArea != null) speed = (int)(speed * spArea.GetSpeedScale());
                    var irrArea = worldBase.GetSceneIrregularitySpecialArea((float)adapter.X, (float)adapter.Y, (float)adapter.Z, (SpecialAreaEnum)2);
                    if (irrArea != null) speed = (int)(speed * irrArea.GetSpeedScale());
                }

                // 2. 与客户端 PlayerMovePredicationSystem.MovePredication (L250-258) 顺序 1:1 对齐：先 SetMove，再 Duck！
                _weEngine.GetPmove()?.SetMove(adapter, cmd, speed);
                _weEngine.GetDuckManager()?.Duck(adapter, adapter, cmd);
                _weEngine.GetEntityManager()?.UpdateEntityNormalBrush(2, adapter);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SSJJ-Server][WE-ENGINE] StepPlayer({id}) warn: {ex.Message}");
            }
        }

        public bool TraceRayClear(float x1, float y1, float z1, float x2, float y2, float z2, out float fraction)
        {
            fraction = 1f;
            if (!IsReady || _weEngine == null) return true;
            try
            {
                var world = _weEngine.GetWorld();
                if (world == null) return true;
                var result = new physics.trace.Trace();
                var s = new float[] { x1, y1, z1 };
                var e = new float[] { x2, y2, z2 };
                var zero = new float[] { 0f, 0f, 0f };
                world.WorldTrace(result, s, e, zero, zero, 33619977);
                fraction = result.fraction;
                return result.fraction >= 0.99f;
            }
            catch
            {
                return true;
            }
        }

        public bool TraceRayWithNormal(
            float x1, float y1, float z1,
            float x2, float y2, float z2,
            out float fraction,
            out float hitX, out float hitY, out float hitZ,
            out float normalX, out float normalY, out float normalZ)
        {
            fraction = 1f;
            hitX = x2; hitY = y2; hitZ = z2;
            normalX = 0f; normalY = 0f; normalZ = 1f;
            if (!IsReady || _weEngine == null) return false;
            try
            {
                var world = _weEngine.GetWorld();
                if (world == null) return false;
                var result = new physics.trace.Trace();
                var s = new float[] { x1, y1, z1 };
                var e = new float[] { x2, y2, z2 };
                var zero = new float[] { 0f, 0f, 0f };
                world.WorldTrace(result, s, e, zero, zero, 33619977);
                fraction = result.fraction;
                if (result.fraction < 0.999f)
                {
                    if (result.endPos != null && result.endPos.Length >= 3)
                    {
                        hitX = result.endPos[0];
                        hitY = result.endPos[1];
                        hitZ = result.endPos[2];
                    }
                    else
                    {
                        hitX = x1 + (x2 - x1) * result.fraction;
                        hitY = y1 + (y2 - y1) * result.fraction;
                        hitZ = z1 + (z2 - z1) * result.fraction;
                    }
                    if (result.plane?.normal != null && result.plane.normal.Length >= 3)
                    {
                        normalX = result.plane.normal[0];
                        normalY = result.plane.normal[1];
                        normalZ = result.plane.normal[2];
                    }
                    return true;
                }
            }
            catch { }
            return false;
        }

        public bool TraceWallbang(
            float x1, float y1, float z1,
            float x2, float y2, float z2,
            float maxThicknessCm,
            float penPower,
            out float damageScale)
        {
            damageScale = 1f;
            if (!IsReady || _weEngine == null) return true;
            if (!TraceRayWithNormal(x1, y1, z1, x2, y2, z2, out _, out float hx1, out float hy1, out float hz1, out _, out _, out _))
            {
                return true;
            }
            if (maxThicknessCm <= 0f || penPower <= 0f)
            {
                damageScale = 0f;
                return false;
            }
            if (!TraceRayWithNormal(x2, y2, z2, hx1, hy1, hz1, out _, out float hx2, out float hy2, out float hz2, out _, out _, out _))
            {
                damageScale = Math.Clamp(penPower * 0.75f, 0.15f, 0.85f);
                return true;
            }

            float dx = x2 - x1;
            float dy = y2 - y1;
            float dz = z2 - z1;
            float rayLen = MathF.Sqrt(dx * dx + dy * dy + dz * dz);
            if (rayLen <= 1e-4f)
            {
                damageScale = 0f;
                return false;
            }
            float ux = dx / rayLen, uy = dy / rayLen, uz = dz / rayLen;
            float tEnter = (hx1 - x1) * ux + (hy1 - y1) * uy + (hz1 - z1) * uz;
            float tExit = (hx2 - x1) * ux + (hy2 - y1) * uy + (hz2 - z1) * uz;
            float thickness = Math.Max(0f, tExit - tEnter);
            if (thickness > maxThicknessCm)
            {
                damageScale = 0f;
                return false;
            }
            damageScale = ComputeWallbangScale(thickness, maxThicknessCm, penPower);
            return true;
        }

        public static float ComputeWallbangScale(float thicknessCm, float maxThicknessCm, float penPower)
        {
            if (thicknessCm <= 0f) return 1f;
            if (maxThicknessCm <= 0f || thicknessCm > maxThicknessCm) return 0f;
            return Math.Clamp(penPower * (1f - thicknessCm / (maxThicknessCm * 1.25f)), 0.15f, 0.85f);
        }

        public bool SampleGround(float x, float y, float z, out float groundZ)
        {
            groundZ = z;
            if (!IsReady || _weEngine == null) return false;
            try
            {
                var world = _weEngine.GetWorld();
                if (world == null) return false;
                var result = new physics.trace.Trace();
                float startZ = z + 150f;
                float endZ = z - 4000f;
                var s = new float[] { x, y, startZ };
                var e = new float[] { x, y, endZ };
                var mins = new float[] { -24f, -24f, 0f };
                var maxs = new float[] { 24f, 24f, 10f };
                world.WorldTrace(result, s, e, mins, maxs, 33619977);
                if (result.fraction < 0.999f)
                {
                    groundZ = startZ + (endZ - startZ) * result.fraction;
                    return true;
                }
            }
            catch { }
            return false;
        }

        public void Dispose()
        {
            try { _weEngine?.Dispose(); } catch { }
            IsReady = false;
        }
    }
}
