using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;

namespace SSJJ.Server.Network;

public sealed class ClientSessionRegistry(int capacity = 1)
{
    private readonly object _gate = new();
    private readonly Dictionary<int, ClientSession> _connections = new();
    private readonly Dictionary<IPEndPoint, ClientSession> _endpoints = new();
    public int Capacity { get; } = Math.Clamp(capacity, 1, 16);

    internal ClientSession? TryAdd(TcpClient client, int initialTeam, long defaultCharacterId, long requestedCharacterId,
        bool oneTeam = false, int? assignedTeam = null)
    {
        lock (_gate)
        {
            if (_connections.Count >= Capacity) return null;
            int playerId = 1;
            while (_connections.Values.Any(s => s.PlayerId == playerId)) playerId++;
            long characterId = requestedCharacterId > 0 && Capacity > 1
                ? requestedCharacterId : defaultCharacterId + playerId - 1;
            if (_connections.Values.Any(s => s.CharacterId == characterId)) return null;
            int connectionId = 1;
            if (Capacity > 1)
            {
                do { connectionId = RandomNumberGenerator.GetInt32(2, int.MaxValue); }
                while (_connections.ContainsKey(connectionId));
            }
            int team = oneTeam ? initialTeam : assignedTeam ?? (playerId % 2 == 1 ? initialTeam : 3 - initialTeam);
            var session = new ClientSession(client, playerId, connectionId, team, characterId);
            _connections.Add(connectionId, session);
            return session;
        }
    }

    public ClientSession[] Snapshot()
    {
        lock (_gate) return _connections.Values.ToArray();
    }

    internal ClientSession? ResolveUdp(int connectionId, IPEndPoint sender, bool probe)
    {
        lock (_gate)
        {
            if (!_connections.TryGetValue(connectionId, out var session)
                || !session.RemoteAddress.MapToIPv6().Equals(sender.Address.MapToIPv6()))
                return null;
            if (_endpoints.TryGetValue(sender, out var owner))
                return ReferenceEquals(owner, session) ? session : null;
            if (!probe || session.UdpEndPoint != null) return null;
            _endpoints.Add(sender, session);
            session.BindUdp(sender);
            return session;
        }
    }

    internal void Remove(ClientSession session)
    {
        lock (_gate)
        {
            if (_connections.Remove(session.ConnectionId) && session.UdpEndPoint is { } endpoint)
                _endpoints.Remove(endpoint);
        }
        session.Close();
    }
}
