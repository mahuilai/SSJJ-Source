using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer;

/// <summary>Tracks distinct damage contributors for the victim's current life.</summary>
public sealed class AssistTracker
{
    private readonly Dictionary<int, HashSet<int>> _contributors = new();

    public void RecordHit(int attackerId, int victimId)
    {
        if (attackerId <= 0 || attackerId == victimId) return;
        if (!_contributors.TryGetValue(victimId, out var attackers))
            _contributors[victimId] = attackers = new HashSet<int>();
        attackers.Add(attackerId);
    }

    public bool AwardForKill(int killerId, int victimId, IEnumerable<PlayerBasicInfo> players, int localPlayerId,
        Action<PlayerBasicInfo>? onAward = null)
    {
        if (!_contributors.Remove(victimId, out var attackers) || killerId <= 0 || killerId == victimId)
            return false;

        bool notifyLocal = false;
        foreach (var player in players)
        {
            if (player.Id == killerId || !attackers.Contains(player.Id)) continue;
            player.Assists++;
            onAward?.Invoke(player);
            notifyLocal |= player.Id == localPlayerId;
        }
        return notifyLocal;
    }

    public void Clear() => _contributors.Clear();

    public void RemovePlayer(int id)
    {
        _contributors.Remove(id);
        foreach (var attackers in _contributors.Values) attackers.Remove(id);
    }
}
