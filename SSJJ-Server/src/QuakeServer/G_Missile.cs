using System.Linq;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer;

public sealed class G_Missile
{
    public const float GRAVITY = 800f;
    public const float BOUNCE_RESTITUTION = 0.45f;
    public const float GROUND_FRICTION = 0.65f;
    public const float SPLASH_RADIUS = 320f;
    public const int MAX_SPLASH_DAMAGE = 105;
    // The smoke_area wrapper points at yanwudan, whose non-looping ParticleSystems run for this duration.
    public const float SmokeDurationSec = 20.046667f;
    private const float SurfaceClearance = 4f;
    private const float RestSpeed = 30f;

    private enum GrenadeEffect { Blast, Flash, Smoke }

    private sealed class Missile(int ownerId, SceneWeaponDrop flight, GrenadeEffect effect, Vector3f position, Vector3f velocity)
    {
        public int OwnerId { get; } = ownerId;
        public SceneWeaponDrop Flight { get; } = flight;
        public GrenadeEffect Effect { get; } = effect;
        public Vector3f Position = position;
        public Vector3f Velocity = velocity;
        public float FuseSec = 2.5f;
    }

    private readonly record struct Impact(Vector3f Position, Vector3f Normal);
    private sealed class SmokeCloud(SceneSmokeData scene)
    {
        public SceneSmokeData Scene { get; } = scene;
        public float RemainingSec = SmokeDurationSec;
    }

    private readonly List<Missile> _activeMissiles = new();
    private readonly List<SmokeCloud> _smokeClouds = new();

    public event Action<GrenadeExplosionEventData>? OnGrenadeExploded;

    public IEnumerable<SceneWeaponDrop> FlyingWeapons => _activeMissiles.Select(missile => missile.Flight);
    public IEnumerable<SceneSmokeData> SmokeClouds => _smokeClouds.Select(cloud => cloud.Scene);

    public void SpawnGrenade(PlayerBasicInfo thrower, float speed = 750f, string weaponName = "grenade", int weaponType = 3)
    {
        if (thrower.IsDead) return;
        float yaw = thrower.ViewYaw * MathF.PI / 180f;
        float pitch = thrower.ViewPitch * MathF.PI / 180f;
        var position = new Vector3f(thrower.PosX, thrower.PosY, thrower.PosZ + thrower.ViewHeight - 8f);
        var velocity = new Vector3f(MathF.Cos(yaw) * MathF.Cos(pitch) * speed,
            MathF.Sin(yaw) * MathF.Cos(pitch) * speed, -MathF.Sin(pitch) * speed + 160f);
        var flight = new SceneWeaponDrop
        {
            Id = SV_Snapshot.AllocTempEntityId(),
            WeaponName = weaponName,
            WeaponSkin = thrower.CurrentWeaponSkinName,
            WeaponType = weaponType
        };
        var effect = weaponName.ToLowerInvariant() switch
        {
            "flashgrenade" or "flashgrenade_ult" => GrenadeEffect.Flash,
            "smoke" or "smoke_ult" or "grenade_smoke" => GrenadeEffect.Smoke,
            _ => GrenadeEffect.Blast
        };
        var missile = new Missile(thrower.Id, flight, effect, position, velocity);
        UpdateFlight(missile);
        _activeMissiles.Add(missile);
    }

    public void RemovePlayer(int id) => _activeMissiles.RemoveAll(missile => missile.OwnerId == id);

    public void Clear()
    {
        _activeMissiles.Clear();
        _smokeClouds.Clear();
    }

    public void Tick(float dt, IReadOnlyList<PlayerBasicInfo> players, OfficialPhysicsWorld? physicsWorld = null)
    {
        for (int i = _smokeClouds.Count - 1; i >= 0; i--)
        {
            if ((_smokeClouds[i].RemainingSec -= dt) <= 0f) _smokeClouds.RemoveAt(i);
        }

        for (int i = _activeMissiles.Count - 1; i >= 0; i--)
        {
            var missile = _activeMissiles[i];
            float step = missile.FuseSec > 0f ? MathF.Min(dt, missile.FuseSec) : dt;
            Impact? impact = Move(missile, step, physicsWorld);
            missile.FuseSec -= dt;
            if (physicsWorld?.IsBelowScene(missile.Position.Z) == true)
            {
                _activeMissiles.RemoveAt(i);
                continue;
            }

            if (missile.FuseSec <= 0f && (missile.Effect != GrenadeEffect.Smoke || impact is { Normal.Z: > 0f }))
            {
                _activeMissiles.RemoveAt(i);
                Detonate(missile, impact, players, physicsWorld);
                continue;
            }

            UpdateFlight(missile);
        }
    }

    private static Impact? Move(Missile missile, float dt, OfficialPhysicsWorld? physicsWorld)
    {
        var start = missile.Position;
        missile.Velocity.Z -= GRAVITY * dt;
        var end = start + missile.Velocity * dt;
        missile.Position = end;

        if (physicsWorld?.IsReady == true)
        {
            if (physicsWorld.TraceRayWithNormal(start.X, start.Y, start.Z, end.X, end.Y, end.Z,
                out _, out float x, out float y, out float z, out float normalX, out float normalY, out float normalZ))
            {
                return Bounce(missile, new Vector3f(x, y, z), new Vector3f(normalX, normalY, normalZ).Normalized());
            }
        }
        else if (end.Z <= PlayerPhysicsState.FloorElevation && missile.Velocity.Z < 0f)
        {
            float ratio = Math.Clamp((start.Z - PlayerPhysicsState.FloorElevation) / (start.Z - end.Z), 0f, 1f);
            var contact = start + (end - start) * ratio;
            contact.Z = PlayerPhysicsState.FloorElevation;
            return Bounce(missile, contact, new Vector3f(0, 0, 1));
        }

        return null;
    }

    private static Impact Bounce(Missile missile, Vector3f contact, Vector3f normal)
    {
        float normalSpeed = MathF.Min(Vector3f.Dot(missile.Velocity, normal), 0f);
        var tangent = missile.Velocity - normal * normalSpeed;
        float reboundSpeed = -normalSpeed * BOUNCE_RESTITUTION;
        if (normal.Z > 0f)
        {
            tangent *= GROUND_FRICTION;
            if (reboundSpeed < RestSpeed) reboundSpeed = 0f;
        }
        missile.Position = contact + normal * SurfaceClearance;
        missile.Velocity = tangent + normal * reboundSpeed;
        return new Impact(contact, normal);
    }

    private static void UpdateFlight(Missile missile)
    {
        var flight = missile.Flight;
        flight.X = missile.Position.X;
        flight.Y = missile.Position.Y;
        flight.Z = missile.Position.Z;
        flight.Yaw = MathF.Atan2(missile.Velocity.Y, missile.Velocity.X) * 180f / MathF.PI;
        flight.Pitch = -MathF.Atan2(missile.Velocity.Z, missile.Velocity.Length2D()) * 180f / MathF.PI;
    }

    private void Detonate(Missile missile, Impact? impact, IReadOnlyList<PlayerBasicInfo> players, OfficialPhysicsWorld? physicsWorld)
    {
        var position = missile.Position;
        var owner = players.FirstOrDefault(player => player.Id == missile.OwnerId);
        int effectId = missile.Effect switch
        {
            GrenadeEffect.Flash => 8,
            GrenadeEffect.Smoke => 1278,
            _ => 4
        };
        OnGrenadeExploded?.Invoke(new GrenadeExplosionEventData
        {
            ThrowerId = missile.OwnerId,
            EffectId = effectId,
            WeaponName = missile.Flight.WeaponName,
            PosX = position.X,
            PosY = position.Y,
            PosZ = position.Z,
            CollisionNormal = impact?.Normal,
            CollisionPoint = missile.Effect == GrenadeEffect.Blast ? impact?.Position : null
        });

        if (missile.Effect == GrenadeEffect.Smoke)
        {
            var surface = impact!.Value.Position;
            _smokeClouds.Add(new SmokeCloud(new SceneSmokeData(SV_Snapshot.AllocTempEntityId(), surface)));
        }
        else if (missile.Effect == GrenadeEffect.Blast)
        {
            ApplySplashDamage(missile, owner, players, physicsWorld);
        }
    }

    private static void ApplySplashDamage(Missile missile, PlayerBasicInfo? owner, IReadOnlyList<PlayerBasicInfo> players,
        OfficialPhysicsWorld? physicsWorld)
    {
        var position = missile.Position;
        foreach (var player in players)
        {
            if (player.IsDead) continue;
            var delta = new Vector3f(player.PosX, player.PosY, player.PosZ + 90f) - position;
            float distance = delta.Length();
            if (distance > SPLASH_RADIUS) continue;

            if (physicsWorld != null
                && !physicsWorld.TraceRayClear(position.X, position.Y, position.Z + 8f,
                    player.PosX, player.PosY, player.PosZ + 100f, out _)) continue;

            int damage = Math.Max(5, (int)(MAX_SPLASH_DAMAGE * (1f - distance / SPLASH_RADIUS)));
            G_Combat.ApplyDamage(player, owner, damage, 2, missile.Flight.WeaponName);
        }
    }
}
