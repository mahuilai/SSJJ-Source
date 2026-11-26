using System.Net;
using System.Net.Sockets;
using System.Threading.Channels;

namespace SSJJ.Server.Network;

public sealed class ClientSession
{
    private readonly TcpClient _client;
    private readonly Channel<byte[]> _outbound = Channel.CreateBounded<byte[]>(256);
    private readonly Channel<DecodedUserCmd> _commands = Channel.CreateBounded<DecodedUserCmd>(512);
    private IPEndPoint? _udpEndPoint;
    private volatile bool _isSpawned;
    private volatile bool _closed;

    internal ClientSession(TcpClient client, int playerId, int connectionId, int team, long characterId)
    {
        _client = client;
        Stream = client.GetStream();
        RemoteAddress = ((IPEndPoint)client.Client.RemoteEndPoint!).Address;
        PlayerId = playerId;
        ConnectionId = connectionId;
        Team = team;
        CharacterId = characterId;
    }

    public int PlayerId { get; }
    public int ConnectionId { get; }
    public int Team { get; }
    public long CharacterId { get; }
    public bool IsSpawned => _isSpawned && !_closed;
    public IPEndPoint? UdpEndPoint => Volatile.Read(ref _udpEndPoint);
    public SnapshotLatencyTracker Latency { get; } = new();
    public int LastCmdSequence { get; set; }
    public int PreviousButtons { get; set; }
    public int ObserverTargetId;
    internal NetworkStream Stream { get; }
    internal IPAddress RemoteAddress { get; }

    internal void BindUdp(IPEndPoint endpoint) => Volatile.Write(ref _udpEndPoint, endpoint);
    internal void MarkSpawned() => _isSpawned = true;

    internal void EnqueueCommands(IEnumerable<DecodedUserCmd> commands)
    {
        if (!IsSpawned) return;
        foreach (var cmd in commands)
            if (!_commands.Writer.TryWrite(cmd)) break;
    }

    public bool TryDequeueCommand(out DecodedUserCmd command) =>
        _commands.Reader.TryRead(out command!);

    internal void Send(byte[] frame)
    {
        // A stalled client cannot block the simulation thread or grow the queue.
        if (!_closed && !_outbound.Writer.TryWrite(frame)) Close();
    }

    internal async Task WriteFramesAsync()
    {
        try
        {
            await foreach (var frame in _outbound.Reader.ReadAllAsync())
                await Stream.WriteAsync(frame);
        }
        catch (Exception ex) when (ex is IOException or ObjectDisposedException or SocketException)
        {
            Close();
        }
    }

    internal void Close()
    {
        _closed = true;
        _commands.Writer.TryComplete();
        _outbound.Writer.TryComplete();
        _client.Dispose();
    }
}
