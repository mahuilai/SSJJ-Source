using SSJJ.Server.Config;
using SSJJ.Server.Snapshot;
using WeaponDef = SSJJ.Server.Config.WeaponDef;
using static share.constant.AnimationConstant;

namespace SSJJ.Server.QuakeServer;

internal static class CombatAnimation
{
    internal static void Advance(PlayerBasicInfo player, int frameMs, GameTables? tables = null)
    {
        int scaledStep = (int)(frameMs * player.ViewAnimSpeed);
        int remainingStep = Math.Max(0, scaledStep);
        while (player.ViewAnimRemainMs > 0 && remainingStep > 0)
        {
            if (remainingStep < player.ViewAnimRemainMs)
            {
                player.ViewAnimRemainMs -= remainingStep;
                remainingStep = 0;
                break;
            }

            remainingStep -= player.ViewAnimRemainMs;
            player.ViewAnimRemainMs = 0;

            int nextState = ResolveNextViewAnimState(player, tables, out int nextDuration);
            player.ViewAnim = nextState;
            player.ViewAnimSpeed = 1f;
            if (!player.SpecialMode)
            {
                player.LeftViewAnim = TORSO_STAND;
                player.LeftViewAnimSpeed = 1f;
            }
            if (nextDuration <= 0 || nextState == TORSO_STAND || nextState == TORSO_SPECIAL_STAND)
            {
                player.ViewAnimRemainMs = 0;
                remainingStep = 0;
                break;
            }
            player.ViewAnimRemainMs = nextDuration;
        }

        if (player.ViewAnimRemainMs == 0 && player.ViewAnim is TORSO_WALK or TORSO_SPECIAL_WALK)
        {
            player.ViewAnim = player.SpecialMode ? TORSO_SPECIAL_STAND : TORSO_STAND;
        }

        // PlayerTorsePredictionSystem only counts RemainTime down and leaves TorsoAnimInfo unchanged on Self;
        // SV_Snapshot maps expired non-dead TorsoAnim back to TORSO_STAND for remote observers.
        player.TorsoAnimRemainMs = Math.Max(0, player.TorsoAnimRemainMs - frameMs);

        if (player.ReloadEndTime > 0 && player.ClientTime > player.ReloadEndTime
            && tables?.GetWeapon(player.CurrentWeaponName)?.WeaponType != 6)
        {
            int rounds = Math.Min(player.MaxClip - player.CurrentClip, player.CurrentCarryClip);
            player.CurrentClip += rounds;
            player.CurrentCarryClip -= rounds;
            player.ReloadEndTime = 0;
            player.IsStartReload = false;
        }
    }

    private static int ResolveNextViewAnimState(PlayerBasicInfo player, GameTables? tables, out int nextDuration)
    {
        int idleState = player.SpecialMode ? TORSO_SPECIAL_STAND : TORSO_STAND;
        nextDuration = 0;
        switch (player.ViewAnim)
        {
            case TORSO_ATTACK:
            case TORSO_ATTACK2:
            case TORSO_RELOAD:
                if (tables != null)
                {
                    int pullDuration = tables.GetViewAnimationDuration(player.CurrentWeaponName, nameof(TORSO_PULL_CHARGER));
                    if (pullDuration > 0)
                    {
                        nextDuration = pullDuration;
                        return TORSO_PULL_CHARGER;
                    }
                }
                return idleState;

            case TORSO_KNIFE_ATTACK:
                if (tables != null)
                {
                    int raiseDuration = tables.GetViewAnimationDuration(player.CurrentWeaponName, nameof(TORSO_ATTACK_RAISE));
                    if (raiseDuration > 0)
                    {
                        nextDuration = raiseDuration;
                        return TORSO_ATTACK_RAISE;
                    }
                }
                return idleState;

            default:
                return idleState;
        }
    }

    internal static void StartAttack(PlayerBasicInfo player, GameTables tables, WeaponDef weapon, bool secondary)
    {
        int state;
        string action;
        if (secondary)
        {
            state = TORSO_SECONDARY_ATTACK;
            action = nameof(TORSO_SECONDARY_ATTACK);
        }
        else if (weapon.IsMelee)
        {
            state = player.SpecialMode ? TORSO_ATTACK2 : TORSO_KNIFE_ATTACK;
            action = player.SpecialMode ? nameof(TORSO_ATTACK2) : nameof(TORSO_KNIFE_ATTACK);
        }
        else if (weapon.HasDoubleAttack && player.ShotsFired > 3)
        {
            state = TORSO_DOUBLE_ATTACK;
            action = nameof(TORSO_DOUBLE_ATTACK);
        }
        else
        {
            state = TORSO_ATTACK;
            action = nameof(TORSO_ATTACK);
        }

        SetAction(player, tables, weapon, state, action, secondary ? TORSO_SECONDARY_ATTACK : TORSO_ATTACK,
            secondary ? nameof(TORSO_SECONDARY_ATTACK) : nameof(TORSO_ATTACK));
    }

    internal static void TryStartReload(PlayerBasicInfo player, GameTables tables, WeaponDef weapon, bool requested)
    {
        if (weapon.WeaponType == 6)
        {
            PlayerPredictionEngine.StepReload(player, weapon, requested || player.CurrentClip <= 0, attackDown: false);
            return;
        }

        bool blockedViewAnim = player.ViewAnim is TORSO_SECONDARY_ATTACK or TORSO_KNIFE_ATTACK or TORSO_ATTACK_RAISE;
        if ((!requested && player.CurrentClip > 0) || weapon.IsMelee || weapon.IsThrowable
            || player.CurrentCarryClip == 0 || player.CurrentClip >= player.MaxClip || player.IsStartReload || player.ReloadEndTime > 0
            || blockedViewAnim || (player.ViewAnim == TORSO_RAISE && player.ViewAnimRemainMs > 0)) return;
        int duration = tables.GetViewAnimationDuration(weapon.Name, nameof(TORSO_RELOAD));
        if (duration <= 0) return;
        player.Fov = 90;
        player.IsStartReload = true;
        player.ReloadEndTime = player.ClientTime + duration;
        player.NextAttackTimer = player.NextSecondaryAttackTimer = player.ReloadEndTime;
        SetAction(player, tables, weapon, TORSO_RELOAD, nameof(TORSO_RELOAD), TORSO_RELOAD, nameof(TORSO_RELOAD));
    }

    internal static void Equip(PlayerBasicInfo player, GameTables tables, WeaponDef weapon)
    {
        player.IsStartReload = false;
        player.ReloadEndTime = 0;
        player.TorsoAnim = TORSO_RAISE;
        player.TorsoAnimStartTime = G_Combat.CurrentServerTimeMs;
        player.TorsoAnimRemainMs = tables.GetTorsoAnimationDuration(player.Career, weapon, nameof(TORSO_RAISE));
        player.ViewAnim = TORSO_RAISE;
        player.ViewAnimSpeed = 1f;
        player.ViewAnimRemainMs = tables.GetViewAnimationDuration(weapon.Name, nameof(TORSO_RAISE));
        if (!player.SpecialMode)
        {
            player.LeftViewAnim = TORSO_STAND;
            player.LeftViewAnimSpeed = 1f;
        }
        player.NextAttackTimer = player.NextSecondaryAttackTimer = player.ClientTime + player.ViewAnimRemainMs;
    }

    internal static void ReleaseTrigger(PlayerBasicInfo player, WeaponDef weapon)
    {
        if (weapon.AttackType == "Pistol")
        {
            player.ShotsFired = 0;
        }
        else if (player.DelayFire)
        {
            player.DelayFire = false;
            player.ShotsFired = Math.Min(8, player.ShotsFired);
            player.DecreaseShotsFired = player.ClientTime + 150;
        }
        else if (player.ShotsFired > 0 && player.DecreaseShotsFired < player.ClientTime)
        {
            player.DecreaseShotsFired = player.ClientTime + 16;
            player.ShotsFired--;
        }
        else if (player.ShotsFired == 0)
        {
            player.WeaponAccuracy = weapon.DefaultAccuracy;
        }
    }

    private static void SetAction(PlayerBasicInfo player, GameTables tables, WeaponDef weapon,
        int viewState, string viewAction, int torsoState, string torsoAction)
    {
        player.ViewAnim = viewState;
        player.ViewAnimSpeed = 1f;
        player.ViewAnimRemainMs = tables.GetViewAnimationDuration(weapon.Name, viewAction);
        player.TorsoAnim = torsoState;
        player.TorsoAnimStartTime = G_Combat.CurrentServerTimeMs;
        player.TorsoAnimRemainMs = tables.GetTorsoAnimationDuration(player.Career, weapon, torsoAction);
    }
}
