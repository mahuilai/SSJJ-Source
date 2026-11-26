using config;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer;

/// <summary>Snapshot target position, orientation, and native movement hull height for its current duck state.</summary>
public readonly record struct PlayerTargetState(
    Vector3f Position,
    float MinZ,
    float MaxZ,
    float ViewYaw = 0f,
    float MoveYaw = 0f,
    bool Moving = false,
    float ViewHeight = 150f,
    int DuckState = 3,
    string Career = "police")
{
    public static PlayerTargetState Capture(PlayerBasicInfo player)
    {
        float minZ = (float)BoundBoxConfig.GetBoundsMinForPlayer(player.Career, player.DuckState).z;
        float maxZ = (float)BoundBoxConfig.GetBoundsMaxForPlayer(player.Career, player.DuckState).z;
        return new(
            new Vector3f(player.PosX, player.PosY, player.PosZ),
            minZ,
            maxZ,
            player.ViewYaw,
            player.MoveYaw,
            player.Moving,
            player.ViewHeight,
            player.DuckState,
            string.IsNullOrEmpty(player.Career) ? "police" : player.Career);
    }

    public bool EnclosesHeight(float worldZ) =>
        worldZ >= Position.Z + MinZ && worldZ <= Position.Z + MaxZ;
}

/// <summary>Target states published to clients, indexed by the simulation clock.</summary>
public sealed class PlayerPositionHistory
{
    public const int WindowMs = 500;
    private readonly Frame?[] _frames = new Frame[32];
    private int _next;

    public void Record(int timestampMs, IReadOnlyList<PlayerBasicInfo> players)
    {
        var targets = new Dictionary<int, PlayerTargetState>(players.Count);
        foreach (var player in players)
            if (!player.IsDead) targets.Add(player.Id, PlayerTargetState.Capture(player));

        _frames[_next] = new Frame(timestampMs, targets);
        _next = (_next + 1) % _frames.Length;
    }

    public void RemovePlayer(int playerId)
    {
        foreach (var frame in _frames) frame?.Targets.Remove(playerId);
    }

    public bool TryGetPosition(int playerId, int timestampMs, out Vector3f position)
    {
        bool found = TryGetTarget(playerId, timestampMs, out var target);
        position = target.Position;
        return found;
    }

    public bool TryGetTarget(int playerId, int timestampMs, out PlayerTargetState target)
    {
        target = default;
        var newest = _frames[(_next + _frames.Length - 1) % _frames.Length];
        if (newest == null || (long)newest.TimestampMs - timestampMs > WindowMs) return false;
        Frame? later = null;
        for (int age = 1; age <= _frames.Length; age++)
        {
            var frame = _frames[(_next + _frames.Length - age) % _frames.Length];
            if (frame == null) break;
            if (frame.TimestampMs > timestampMs)
            {
                later = frame;
                continue;
            }
            if (!frame.Targets.TryGetValue(playerId, out var older)) return false;
            if (later == null || frame.TimestampMs == timestampMs)
            {
                target = older;
                return true;
            }
            if (!later.Targets.TryGetValue(playerId, out var next)) return false;
            float fraction = (float)(timestampMs - frame.TimestampMs) / (later.TimestampMs - frame.TimestampMs);
            // The client initializes DuckState from the current snapshot. Hold that
            // frame's discrete hull while interpolating only position.
            target = older with { Position = older.Position + (next.Position - older.Position) * fraction };
            return true;
        }
        return false;
    }

    private sealed record Frame(int TimestampMs, Dictionary<int, PlayerTargetState> Targets);
}
