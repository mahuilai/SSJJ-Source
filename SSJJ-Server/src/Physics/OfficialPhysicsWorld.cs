using System;
using System.Collections.Generic;
using config;
using math;
using physics;
using physics.data;
using physics.engine;
using physics.engine.business;
using physics.engine.entity;
using physics.engine.entity.indicator;
using physics.entity;
using physics.impl;
using physics.trace;
using share;
using SSJJ.Server.NativeEngine;
using SSJJ.Server.Snapshot;
using wizardengine;

namespace SSJJ.Server.Physics
{
    public sealed class ServerWeEngineHandler : DefaultWeEngineHandler
    {
        private readonly List<IPyEntity> _players = new List<IPyEntity>();

        public void RegisterPlayer(IPyEntity entity)
        {
            if (!_players.Contains(entity)) _players.Add(entity);
        }

        public void UnregisterPlayer(IPyEntity entity)
        {
            _players.Remove(entity);
        }

        public override bool IsBspAsTriMesh() => false;

        public override float[] GetObfuscatorSeed() => new float[] { 0f, 0f, 0f };

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
        public float Stamina { get; set; } = 100f;
        public int Velocity2D { get; set; }
        public Vector3D Velocity { get; } = new Vector3D();
        public Pml Pml { get; } = new Pml();
        public CBrush NormalBrush { get; }
        public CBrush DuckBrush { get; }
        public CBrush DetectorBrush { get; }
        public WeEntity? EngineEntity { get; set; }
        public int PlayerStates { get; set; }
        public int FlyWaitTime { get; set; }
        public bool LimitMaxSpeed { get; set; }
        public bool Spurting { get; set; }
        public bool AnimPos { get; set; }
        public int AnimMoveTime { get; set; }
        public float ViewYaw { get; set; }
        public float ViewPitch { get; set; }
        public string WeaponName { get; set; } = "m4a1";

        private readonly Vector3D _normalMin;
        private readonly Vector3D _normalMax;
        private readonly Vector3D _duckMax;

        public ServerPlayerPhysicsAdapter(int id, int team, string career, bool isBot, float x, float y, float z)
        {
            Id = id;
            Team = team;
            Career = string.IsNullOrEmpty(career) ? "police" : career;
            Bot = isBot;
            X = x;
            Y = y;
            Z = z;

            _normalMin = BoundBoxConfig.GetBoundsMinForPlayer(Career, 3) ?? new Vector3D(-32, -32, 0);
            _normalMax = BoundBoxConfig.GetBoundsMaxForPlayer(Career, 3) ?? new Vector3D(32, 32, 180);
            _duckMax = BoundBoxConfig.GetBoundsMaxForPlayer(Career, 0) ?? new Vector3D(32, 32, 115);

            NormalBrush = BrushUtils.CreateBrushInternal(_normalMin, _normalMax);
            DuckBrush = BrushUtils.CreateBrushInternal(_normalMin, _duckMax);
            var detMin = new Vector3D(_normalMin.x - 4, _normalMin.y - 4, _normalMin.z);
            var detMax = new Vector3D(_normalMax.x + 4, _normalMax.y + 4, _normalMax.z);
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
        public CBrush GetBrush() => DuckState == 0 ? DuckBrush : NormalBrush;
        public CBrush GetDetectorBrush() => DetectorBrush;
        public bool GetNeedToCheckCollisionWithOtherEntities() => !Dead;
        public bool IsAirPush() => true;
        public void OnCrashLand() { }

        // Velocity & physics
        public Vector3D GetVelocity() => Velocity;
        public void SetVelocity(Vector3D v) { if (v != null) Velocity.CopyFrom(v); }
        public void SetVelocity(float x, float y, float z) { Velocity.x = x; Velocity.y = y; Velocity.z = z; }
        public void SetVelocity2D(int velocity2D) => Velocity2D = velocity2D;
        public float GetGravityEffectRate() => 1.0f;
        public int GetAiraccelerate() => 10;
        public float GetJumpHeight(float currentVel) => 330f;
        public float GetFlySpeed() => 300f;
        public bool IsOnGround() => OnGround;
        public void SetOnGround(bool onGround) => OnGround = onGround;
        public int GetGroundEntityNum() => GroundEntityNum;
        public void SetGroundEntityNum(int entityNumNone) => GroundEntityNum = entityNumNone;
        public void SetGroundTraceSurfaceFlags(int surfaceFlags) { }
        public void SetSlideMoveSurfaceFlags(int surfaceFlags) { }
        public Pml GetPml() => Pml;
        public Vector3D GetLadderNormal() => new Vector3D(0, 0, 1);

        // Bounds & Duck
        public Vector3D GetCurrentMin() => _normalMin;
        public Vector3D GetCurrentMax() => DuckState == 0 ? _duckMax : _normalMax;
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
        public bool GetCtrlDuck() => false;

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
        public void UpdateHitImpulseSet(int dtime) { }
        public void UpdateHitImpulseSet2(int dtime) { }
        public int GetImpulseTime() => 0;
        public int GetImpulseTime2() => 0;
        public void WhenJumpLand() { }
        public bool GetBeingHit() => false;
        public void UpdateBeingHitTime(int frameInterval) { }
        public float GetBeingHitFriction() => 1.0f;
        public int GetFlyWaitTime() => FlyWaitTime;
        public void SetFlyWaitTime(int flyWaitTime) => FlyWaitTime = flyWaitTime;
        public void OnCheckWalkOnStep(float newZ) { }
        public bool IsHumanHero() => false;
        public bool IsHumanity() => true;
        public void SetIsLimitMaxSpeed(bool value) => LimitMaxSpeed = value;
        public bool GetIsLimitMaxSpeed() => LimitMaxSpeed;
        public bool ActThirdMove() => false;
        public bool IsActThirdMove() => false;
        public bool GetIsSpurting() => Spurting;
        public void SetIsSpurting(bool isSpurting) => Spurting = isSpurting;
        public bool IsKeepFly() => false;
        public float GetKeepFlySpeed() => 0f;
        public void SetIsLastCrash(bool isLastCrash) { }
        public bool IsLastCrash() => false;
        public void SetLastPerfectjump(bool isPerfect) { }
        public bool IsLastPerfectjump() => false;
        public void SetContinuousPerfectjumpCount(int count) { }
        public int GetContinuousPerfectjumpCount() => 0;
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
        public int GetLegsAnim() => 7;
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

                _handler = new ServerWeEngineHandler();
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

        public void SetPlayerPosition(int id, float x, float y, float z)
        {
            if (!_adapters.TryGetValue(id, out var adapter)) return;
            adapter.SetPosition(x, y, z);
            adapter.SetVelocity(0f, 0f, 0f);
            adapter.Dead = false;
            adapter.DuckState = 3;
            adapter.DuckTime = 0;
            adapter.Stamina = 100f;
            adapter.OnGround = true;
            adapter.GroundEntityNum = -1;
            adapter.Velocity2D = 0;
            adapter.ViewHeight = adapter.NormalViewHeight;
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
            out int velocity2D, out float stamina)
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
                return true;
            }
            x = y = z = vx = vy = vz = 0f;
            viewHeight = 150.0;
            duckState = 3;
            duckTime = 0;
            onGround = true;
            groundEntityNum = -1;
            velocity2D = 0;
            stamina = 100f;
            return false;
        }

        public void StepPlayer(int id, ServerPyCmd cmd, int weaponMaxSpeed)
        {
            if (!IsReady || _weEngine == null || !_adapters.TryGetValue(id, out var adapter) || adapter.Dead) return;
            try
            {
                // 与客户端 PlayerMovePredicationSystem + PlayerSpeedUtil.GetPlayerSpeed 1:1 对齐
                // 客户端先以当前 DuckState 计算速度并执行 pmove.SetMove，再在 MovePredication 末尾调用 DuckManager.Duck
                int speed = weaponMaxSpeed;
                if (adapter.DuckState == 0 || adapter.DuckState == 1)
                    speed = share.constant.PlayerConf.CrouchMoveSpeed(); // 203
                else if (cmd.IsWalk)
                    speed = share.constant.PlayerConf.WalkSpeed();       // 305

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
