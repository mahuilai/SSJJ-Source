using SSJJ.Server.Config;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer;

/// <summary>Owns ground weapons and transfers them on the simulation thread.</summary>
public sealed class WeaponDropSystem(GameTables tables)
{
    private sealed class Drop(SceneWeaponDrop scene, CarriedWeapon weapon, int slot, PlayerBasicInfo owner)
    {
        public SceneWeaponDrop Scene { get; } = scene;
        public CarriedWeapon Weapon { get; } = weapon;
        public int Slot { get; } = slot;
        public PlayerBasicInfo? BlockedOwner { get; set; } = owner;
    }

    private readonly List<Drop> _drops = new();

    public IEnumerable<SceneWeaponDrop> SceneDrops => _drops.Select(drop => drop.Scene);

    public void ReleaseOwner(PlayerBasicInfo player)
    {
        foreach (var drop in _drops)
            if (drop.BlockedOwner == player) drop.BlockedOwner = null;
    }

    public bool DropEquipped(PlayerBasicInfo player)
    {
        if (player.IsDead || player.Loadout is not { } loadout || player.CurrentWeapon is not (1 or 2)) return false;

        int bag = player.CurrentBagId;
        int slot = player.CurrentWeapon;
        for (int next = 1; next <= 3; next++)
        {
            if (next == slot || loadout.Get(bag, next) == null) continue;
            if (!DropFromSlot(player, loadout, slot)) return false;
            loadout.Switch(player, bag, next, tables);
            return true;
        }
        return false;
    }

    public void DropOnDeath(PlayerBasicInfo player)
    {
        if (player.Loadout is not { } loadout || !DropFromSlot(player, loadout, 1) || player.CurrentWeapon != 1)
            return;

        // PlayerBagInitSystem removes a dropped weapon entity, even while a dead player
        // still owns the camera. Keep the current slot pointed at a carried weapon.
        int bag = player.CurrentBagId;
        for (int slot = 2; slot <= 3; slot++)
        {
            if (loadout.Get(bag, slot) == null) continue;
            loadout.Switch(player, bag, slot, tables, playRaise: false);
            break;
        }
    }

    private bool DropFromSlot(PlayerBasicInfo player, PlayerLoadout loadout, int slot)
    {
        if (loadout.Remove(player, slot) is not { } weapon) return false;
        var scene = new SceneWeaponDrop
        {
            Id = SV_Snapshot.AllocTempEntityId(),
            WeaponName = weapon.Name,
            WeaponSkin = weapon.Skin,
            WeaponType = tables.GetWeapon(weapon.Name).WeaponType,
            X = player.PosX,
            Y = player.PosY,
            Z = player.PosZ,
            Yaw = player.ViewYaw
        };
        _drops.Add(new Drop(scene, weapon, slot, player));
        return true;
    }

    public void PickUp(IReadOnlyList<PlayerBasicInfo> players, OfficialPhysicsWorld physics)
    {
        for (int i = _drops.Count - 1; i >= 0; i--)
        {
            var drop = _drops[i];
            if (drop.BlockedOwner is { } owner && (owner.IsDead || !IsInReach(owner, drop.Scene, out _)))
                drop.BlockedOwner = null;

            PlayerBasicInfo? winner = null;
            float bestDistance = float.PositiveInfinity;
            foreach (var player in players)
            {
                if (player.IsDead || player == drop.BlockedOwner || player.Loadout is not { } loadout
                    || loadout.Get(player.CurrentBagId, drop.Slot) != null
                    || !IsInReach(player, drop.Scene, out float distance)
                    || distance > bestDistance || (distance == bestDistance && winner != null && player.Id > winner.Id))
                    continue;

                float reachZ = player.ViewHeight * 0.5f;
                if (!physics.TraceRayClear(player.PosX, player.PosY, player.PosZ + reachZ,
                    drop.Scene.X, drop.Scene.Y, drop.Scene.Z + reachZ, out _))
                    continue;

                bestDistance = distance;
                winner = player;
            }
            if (winner != null && winner.Loadout!.TryAdd(winner.CurrentBagId, drop.Slot, drop.Weapon with { EntityId = drop.Scene.Id }))
                _drops.RemoveAt(i);
        }
    }

    private static bool IsInReach(PlayerBasicInfo player, SceneWeaponDrop drop, out float distanceSquared)
    {
        float dx = player.PosX - drop.X;
        float dy = player.PosY - drop.Y;
        distanceSquared = dx * dx + dy * dy;
        return distanceSquared <= SceneWeaponDrop.PickupRadius * SceneWeaponDrop.PickupRadius
            && Math.Abs(player.PosZ - drop.Z) <= SceneWeaponDrop.PickupHeight;
    }
}
