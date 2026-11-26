using System;
using System.Collections.Generic;

namespace SSJJ.Server.Network;

/// <summary>Server-clock RTT from a sent snapshot to the first command acknowledging it.</summary>
public sealed class SnapshotLatencyTracker
{
    private readonly Dictionary<int, long> _sent = new();
    private readonly Queue<int> _order = new();
    private int _lastAck = -1;
    private long? _firstSnapshotMs;
    private long _acknowledgedSnapshotMs;
    private int _roundTripMs;

    public void RecordSent(int sequence, long timestampMs)
    {
        _firstSnapshotMs ??= timestampMs;
        _sent[sequence] = timestampMs;
        _order.Enqueue(sequence);
        while (_order.Count > 1024) _sent.Remove(_order.Dequeue());
    }

    public int? Acknowledge(int sequence, long timestampMs)
    {
        if (sequence <= _lastAck || !_sent.TryGetValue(sequence, out long sentMs) || timestampMs < sentMs)
            return null;
        _lastAck = sequence;
        _acknowledgedSnapshotMs = sentMs;
        _roundTripMs = (int)Math.Min(int.MaxValue, timestampMs - sentMs);
        while (_order.TryPeek(out int oldest) && oldest <= sequence)
            _sent.Remove(_order.Dequeue());
        return _roundTripMs;
    }

    public int? ResolveShotTime(int renderTimeMs, int nowMs, int windowMs)
    {
        if (_firstSnapshotMs is not long firstSnapshotMs || _lastAck < 0
            || nowMs - _acknowledgedSnapshotMs > windowMs) return null;

        long earliest = Math.Max(firstSnapshotMs, (long)nowMs - windowMs);
        if (renderTimeMs >= earliest && renderTimeMs <= nowMs) return renderTimeMs;

        const int clientRenderDelayMs = 130;
        return (int)Math.Clamp(nowMs - _roundTripMs / 2L - clientRenderDelayMs, earliest, nowMs);
    }
}
