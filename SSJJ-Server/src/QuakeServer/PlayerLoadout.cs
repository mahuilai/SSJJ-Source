using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.Snapshot;
using WeaponDef = SSJJ.Server.Config.WeaponDef;

namespace SSJJ.Server.QuakeServer;

public sealed record CarriedWeapon(string Name, string Skin, int Clip, int Reserve, int StorageId = 0)
{
    public int EntityId { get; init; }
    public bool RecoilDirection { get; init; }

    public static CarriedWeapon FromConfig(string name, string skin, WeaponDef definition, int storageId = 0) =>
        new(name, skin, definition.MaxClip, definition.MaxCarryClip, storageId);
}

public sealed class PlayerLoadout
{
    private static readonly int[] BagStorageSlots = { 1, 2, 3, 4, 6, 7 };
    private readonly Dictionary<(int Bag, int StorageSlot), CarriedWeapon> _weapons = new();

    public PlayerLoadout(ServerConfig config, GameTables tables) : this(config.Bags, tables)
    {
    }

    public PlayerLoadout(IReadOnlyList<BagSlotConfig> bags, GameTables tables)
    {
        for (int bagIdx = 0; bagIdx < bags.Count; bagIdx++)
        {
            var bag = bags[bagIdx];
            foreach (int storageSlot in BagStorageSlots)
            {
                string name = bag.GetSlotWeapon(storageSlot);
                if (!string.IsNullOrWhiteSpace(name))
                {
                    _weapons.Add((bagIdx + 1, storageSlot),
                        CarriedWeapon.FromConfig(name, bag.GetSlotSkin(storageSlot), tables.GetWeapon(name), bag.GetSlotId(storageSlot)));
                }
            }
        }
    }

    public CarriedWeapon? Get(int bag, int storageSlot) => _weapons.GetValueOrDefault((bag, storageSlot));

    public bool TryAdd(int bag, int storageSlot, CarriedWeapon weapon) => _weapons.TryAdd((bag, storageSlot), weapon);

    public CarriedWeapon? Remove(PlayerBasicInfo player, int storageSlot)
    {
        SaveEquipped(player);
        return _weapons.Remove((player.CurrentBagId, storageSlot), out var weapon) ? weapon : null;
    }

    public void SaveEquipped(PlayerBasicInfo player)
    {
        int storageSlot = GetStorageSlot(player.CurrentWeapon, player.CurrentWeaponIndex);
        if (storageSlot <= 0) return;
        var key = (player.CurrentBagId, storageSlot);
        if (_weapons.TryGetValue(key, out var equipped))
        {
            _weapons[key] = equipped with
            {
                Clip = player.CurrentClip,
                Reserve = player.CurrentCarryClip,
                RecoilDirection = player.RecoilDirection
            };
        }
    }

    public bool Switch(PlayerBasicInfo player, int bag, int storageSlot, int protocolSlot, int weaponIndex, GameTables tables, bool playRaise = true)
    {
        if (Get(bag, storageSlot) is not { } weapon) return false;
        SaveEquipped(player);
        Equip(player, bag, protocolSlot, weaponIndex, weapon, tables.GetWeapon(weapon.Name), tables, playRaise);
        return true;
    }

    public bool Switch(PlayerBasicInfo player, int bag, int slot, GameTables tables, bool playRaise = true)
    {
        int weaponIndex = slot == 4 ? 0 : slot;
        return Switch(player, bag, slot, slot, weaponIndex, tables, playRaise);
    }

    public static void Equip(PlayerBasicInfo player, int bag, int slot,
        CarriedWeapon weapon, WeaponDef definition, bool playRaise = true)
    {
        int weaponIndex = slot == 4 ? 0 : slot;
        Equip(player, bag, slot, weaponIndex, weapon, definition, tables: null, playRaise);
    }

    internal static void Equip(PlayerBasicInfo player, int bag, int protocolSlot, int weaponIndex,
        CarriedWeapon weapon, WeaponDef definition, GameTables? tables, bool playRaise = true)
    {
        player.CurrentBagId = bag;
        player.CurrentWeapon = protocolSlot;
        player.CurrentWeaponIndex = weaponIndex;
        player.CurrentWeaponName = weapon.Name;
        player.CurrentWeaponSkinName = weapon.Skin;
        player.MaxClip = definition.MaxClip;
        player.CurrentClip = weapon.Clip;
        player.CurrentCarryClip = weapon.Reserve;
        player.WeaponAccuracy = definition.DefaultAccuracy;
        player.ShotsFired = 0;
        player.DecreaseShotsFired = 0;
        player.DelayFire = false;
        player.RecoilDirection = weapon.RecoilDirection;
        player.RecoilRunUpMax = false;
        player.PunchYaw = 0f;
        player.PunchPitch = 0f;
        player.DecayTime = 0;
        if (playRaise)
        {
            if (tables != null)
            {
                CombatAnimation.Equip(player, tables, definition);
            }
            else
            {
                int raiseMs = Math.Max(350, PlayerPredictionEngine.GetDefaultViewAnimDurationMs(definition, 16));
                player.IsStartReload = false;
                player.ReloadEndTime = 0;
                player.ViewAnim = player.LeftViewAnim = 16;
                player.ViewAnimRemainMs = raiseMs;
                player.ViewAnimSpeed = 1f;
                player.LeftViewAnimSpeed = 1f;
                player.NextAttackTimer = player.NextSecondaryAttackTimer = player.ClientTime + raiseMs;
            }
        }
        else
        {
            player.IsStartReload = false;
            player.ReloadEndTime = 0;
            player.ViewAnim = 13;
            player.LeftViewAnim = 13;
            player.ViewAnimRemainMs = 0;
            player.ViewAnimSpeed = 1f;
            player.LeftViewAnimSpeed = 1f;
            if (!player.IsDead)
            {
                player.TorsoAnim = 13;
                player.TorsoAnimRemainMs = 0;
            }
        }
    }

    public static int GetStorageSlot(int protocolSlot, int weaponIndex) => protocolSlot switch
    {
        4 => weaponIndex switch { 1 => 6, 2 => 7, _ => 4 },
        >= 1 and <= 3 => protocolSlot,
        _ => 0
    };
}
