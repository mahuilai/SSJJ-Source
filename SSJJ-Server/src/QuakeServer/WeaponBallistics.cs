using System.Globalization;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer;

// The legacy actions calculate spread before updating accuracy, then apply recoil after the ray.
internal sealed class WeaponBallistics(
    string accuracyType, float[] accuracy, float divisor, float offset, float maxInaccuracy,
    string spreadType, float[] spread, float verticalScale, float[] recoil, bool singleShot)
{
    internal bool SingleShot => singleShot;

    internal static WeaponBallistics? FromTable(
        string attackType, string accuracyType, string accuracyArgs, float divisor, float offset, float maxInaccuracy,
        string spreadType, string spreadArgs, float verticalScale, string recoilType, string recoilArgs)
    {
        if (attackType is not ("Rifle" or "Pistol" or "SniperRifle" or "ShotGun")) return null;
        if (accuracyType is not ("Normal" or "Submachine" or "Pistol" or "None")) return null;
        int spreadLength = spreadType switch { "Rifle" => 2, "Pistol" => 4, "Pistol1" => 1, "Sniper" => 6, _ => 0 };
        int recoilLength = recoilType switch { "Rifle" => 28, "Sniper" => 1, _ => 0 };
        if (spreadLength == 0 || recoilLength == 0) return null;
        if (!TryReadParameters(spreadArgs, spreadLength, out var spread)
            || !TryReadParameters(recoilArgs, recoilLength, out var recoil)) return null;
        float[] accuracy = [];
        if (accuracyType == "Pistol" && (!TryReadParameters(accuracyArgs, 3, out accuracy) || accuracy[2] > accuracy[1]))
            return null;

        return new WeaponBallistics(accuracyType, accuracy, divisor, offset, maxInaccuracy,
            spreadType, spread, verticalScale, recoil, attackType == "Pistol");
    }

    private static bool TryReadParameters(string value, int count, out float[] parameters)
    {
        var parts = value.Split(',');
        parameters = [];
        if (parts.Length != count) return false;
        parameters = new float[count];
        for (int i = 0; i < count; i++)
        {
            if (!float.TryParse(parts[i], NumberStyles.Float, CultureInfo.InvariantCulture, out parameters[i])
                || !float.IsFinite(parameters[i])) return false;
        }
        return true;
    }

    internal float Spread(PlayerBasicInfo player)
    {
        bool crouched = player.DuckState == 0;
        float speed = player.Velocity2D;
        return spreadType switch
        {
            "Rifle" => spread[player.OnGround ? 1 : 0] * player.WeaponAccuracy,
            "Pistol" => spread[!player.OnGround ? 0 : speed > 13f ? 1 : crouched ? 2 : 3] * (1f - player.WeaponAccuracy),
            "Sniper" => spread[!player.OnGround ? 0 : speed > 350f ? 1 : speed > 25f ? 2 : crouched ? 3 : 4]
                + (player.Fov == 90 ? spread[5] : 0f),
            _ => spread[0]
        };
    }

    internal Vector3f ShotDirection(PlayerBasicInfo player, int pellet, float shotSpread)
    {
        // The server stores positive camera pitch downward and positive punch pitch upward.
        var forward = weapon.ShootingDirUtils.CalculateShotingDir(unchecked(player.CmdSequence + pellet),
            player.ViewYaw + 2f * player.PunchYaw, -player.ViewPitch + 2f * player.PunchPitch, shotSpread, verticalScale, 1d);
        return new Vector3f((float)forward.x, (float)forward.y, (float)forward.z).Normalized();
    }

    internal void UpdateAccuracy(PlayerBasicInfo player, int attackIntervalMs)
    {
        float shots = player.ShotsFired;
        if (accuracyType == "Pistol")
        {
            float elapsed = (player.ClientTime - player.NextAttackTimer + attackIntervalMs) / 1000f;
            player.WeaponAccuracy = Math.Clamp(player.WeaponAccuracy - accuracy[0] * (0.3f - elapsed), accuracy[2], accuracy[1]);
        }
        else if (divisor > 0f && accuracyType is "Normal" or "Submachine")
        {
            float power = shots * shots;
            if (accuracyType == "Normal") power *= shots;
            player.WeaponAccuracy = Math.Min(maxInaccuracy, offset + power / divisor);
        }
    }

    internal void ApplyRecoil(PlayerBasicInfo player, int attackIntervalMs)
    {
        if (recoil.Length == 1)
        {
            player.PunchPitch += recoil[0];
            return;
        }

        bool running = player.Velocity2D > 300f;
        int stance = running || player.RecoilRunUpMax ? 0 : !player.OnGround ? 7 : player.DuckState == 0 ? 14 : 21;
        int shotFactor = player.ShotsFired == 1 ? 0 : player.ShotsFired;
        player.PunchPitch += recoil[stance] + shotFactor * recoil[stance + 2];
        if (player.PunchPitch > recoil[stance + 4] + attackIntervalMs * 0.01d)
        {
            player.PunchPitch = recoil[stance + 4];
            player.DecayTime = attackIntervalMs / 2;
            player.RecoilRunUpMax |= running;
        }

        float yawStep = recoil[stance + 1] + shotFactor * recoil[stance + 3];
        float maxYaw = recoil[stance + 5];
        player.PunchYaw = player.RecoilDirection
            ? Math.Min(maxYaw, player.PunchYaw + yawStep) : Math.Max(-maxYaw, player.PunchYaw - yawStep);
        if (math.UniformRandom.RandomInt(player.CmdSequence, 0, (int)recoil[stance + 6]) == 0)
            player.RecoilDirection = !player.RecoilDirection;
    }
}
