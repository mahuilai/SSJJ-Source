using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text.Json;
using System.Threading;
using NetData;
using SSJJ.Data;

namespace VerifyE2E;

internal sealed class DecodedSnapshot
{
    public SnapshotData Header { get; init; } = new();
    public List<PlayerEntityData> Players { get; } = new();
    public List<SceneWeaponEntityData> SceneWeapons { get; } = new();
    public List<PveTowerEntityData> PveTowers { get; } = new();
    public List<SceneBufEntityData> SceneBuffs { get; } = new();
    public List<GrenadeExplosionEventEntityData> GrenadeExplosions { get; } = new();
}

internal static class Btn
{
    public const int Forward = 1;
    public const int Backward = 2;
    public const int Left = 4;
    public const int Right = 8;
    public const int Switchwalk = 16;
    public const int Jump = 32;
    public const int Attack = 64;
    public const int Duck = 128;
    public const int Reload = 256;
    public const int Attack2 = 512;
    public const int ThrowWeapon = 1024;
    public const int Demolition = 2048;
    public const int Skill = 4096;
    public const int Spray = 8192;
    public const int Inspect = 65536;
    public const int Showgun = 65536;
}

internal sealed class BattleWireClient : IDisposable
{
    private static readonly ProtobufSerializer Proto = new();
    private readonly TcpClient _tcp = new();
    private readonly UdpClient _udp = new();
    private NetworkStream? _stream;
    private volatile bool _running = true;

    public CallBackLoginData? CallBackLogin { get; private set; }
    public TcpConnectionIDData? TcpConnId { get; private set; }
    public RoomData? Room { get; private set; }
    public OnGameinitData? Init3 { get; private set; }
    public OnGameinitData? Init232 { get; private set; }
    public readonly List<PlayerLoginData> PlayerLogins = new();
    public readonly List<KillPlayerInfoData> Kills = new();
    public readonly List<BroadcastScoreData> TeamScores = new();
    public readonly List<SkillInfoData> SkillInfos = new();
    public readonly List<SimpleProto> SimpleProtos = new();
    public readonly List<C4ActiveData> C4Actives = new();
    public readonly ConcurrentQueue<C4MessageData> C4Messages = new();
    public readonly ConcurrentQueue<AllKillInfoData> Scoreboards = new();
    public readonly ConcurrentQueue<int> AssistBodyLengths = new();
    public readonly ConcurrentQueue<GameMessageData> GameMessages = new();
    public readonly ConcurrentQueue<PlayerLogoutData> PlayerLogouts = new();
    public readonly ConcurrentQueue<ProgressData> ProgressEvents = new();
    public readonly ConcurrentQueue<DamageCountData> DamageCounts = new();
    public readonly ConcurrentQueue<TacticsSoundData> TacticsSounds = new();
    public readonly ConcurrentQueue<ObserverInfoData> ObserverInfos = new();
    public readonly ConcurrentQueue<SprayEventEntityData> SprayEvents = new();
    public readonly ConcurrentQueue<SprayMessageData> SprayMessages = new();
    public readonly ConcurrentQueue<GrenadeExplosionEventEntityData> GrenadeExplosions = new();
    public PingListData? LatestPings { get; private set; }
    public GroupBestKillData? GroupBest { get; private set; }
    public LastMvpData? LastMvp { get; private set; }
    public readonly List<MessageListData> WeaponMasterMsgs = new();
    public readonly List<BigHeadProgressData> BigHeadMsgs = new();
    public readonly List<PveMessageData> PveMsgs = new();
    public readonly List<RpgCounterData> RpgCounterUpdates = new();
    public readonly List<ExpData> ExpMsgs = new();
    public PeekabooItemListTmpData? RoadBlocks { get; private set; }
    public SceneMapInfoData? SceneMapInfo { get; private set; }
    public RpgCounterListData? RpgCounterList { get; private set; }
    public readonly ConcurrentQueue<int> BioGrowth = new();
    public readonly ConcurrentQueue<int> BioDamage = new();
    public readonly ConcurrentQueue<BioMessageData> BioMessages = new();
    public readonly ConcurrentQueue<BioLvUpData> BioLvUps = new();
    public int HitPlayerCount;
    public int AllKillInfoCount;
    public int ClearSectionCount;
    public int MissionResultCount;
    public int GameWinCount;
    public bool P2PAckReceived { get; private set; }
    public DecodedSnapshot? LatestSnapshot { get; private set; }
    public readonly ConcurrentBag<int> SeenDeletedIds = new();
    public event Action<DecodedSnapshot>? OnSnapshotReceived;
    public int SnapshotCount;

    private int _cmdSeq = 1;
    private int _renderTime = 1000;

    public BattleWireClient(string host, int tcpPort, int udpPort)
    {
        _tcp.Connect(host, tcpPort);
        _stream = _tcp.GetStream();
        _udp.Connect(new IPEndPoint(IPAddress.Parse(host), udpPort));
        new Thread(TcpReadLoop) { IsBackground = true }.Start();
        new Thread(UdpReadLoop) { IsBackground = true }.Start();
    }

    public void SendTcp(int methodId, object? msg = null)
    {
        byte[] content = msg == null ? Array.Empty<byte>() : Serialize(msg);
        byte[] apc = Serialize(new APC { Id = methodId, Content = content });
        byte[] len = BitConverter.GetBytes(apc.Length);
        if (BitConverter.IsLittleEndian) Array.Reverse(len);
        _stream!.Write(len, 0, 4);
        _stream!.Write(apc, 0, apc.Length);
        _stream!.Flush();
    }

    public void SendP2PProbe()
    {
        // Native probe: length, negotiated connection ID, method, splice/compress flags.
        byte[] pkt = { 0, 0, 0, 7, 0, 0, 0, 0, 0, 1, 0 };
        System.Buffers.Binary.BinaryPrimitives.WriteInt32BigEndian(pkt.AsSpan(4), TcpConnId!.Id);
        _udp.Send(pkt, pkt.Length);
    }

    public int SendUserCmd(sbyte moveFwd, sbyte moveRight, int buttons, byte bagId, byte slot, float yaw, float pitch, byte intervalMs = 33)
    {
        int seq = _cmdSeq++;
        _renderTime += intervalMs;
        int snapSeq = LatestSnapshot?.Header.SeqId ?? 0;

        using var ms = new MemoryStream();
        // Leave 4 bytes for length prefix
        ms.Write(new byte[4], 0, 4);
        WriteIntBE(ms, TcpConnId!.Id);
        ms.WriteByte(2);   // Method = 2 (UserCmd2)

        // Header: [1B latency][4B seq][4B renderTime][4B latestSnapSeq]
        ms.WriteByte(1);
        WriteIntBE(ms, seq);
        WriteIntBE(ms, _renderTime);
        WriteIntBE(ms, snapSeq);

        // Single command mask with all fields:
        // MaskFrameInterval(1) | MaskMove(2) | MaskButton(4) | MaskBagWeapon(8) | MaskYaw(16) | MaskPitch(32) | MaskRender(128) = 191
        ms.WriteByte(1 | 2 | 4 | 8 | 16 | 32 | 128);
        ms.WriteByte(intervalMs);
        ms.WriteByte((byte)moveFwd);
        ms.WriteByte((byte)moveRight);
        WriteIntBE(ms, buttons);
        byte bw = (byte)(((bagId & 0x07) << 5) | (slot & 0x1F));
        ms.WriteByte(bw);
        WriteShortBE(ms, (short)Math.Clamp(Math.Round(yaw * 100f), short.MinValue, short.MaxValue));
        WriteShortBE(ms, (short)Math.Clamp(Math.Round(pitch * 100f), short.MinValue, short.MaxValue));

        byte[] raw = ms.ToArray();
        int payloadLen = raw.Length - 4;
        raw[0] = (byte)((payloadLen >> 24) & 0xFF);
        raw[1] = (byte)((payloadLen >> 16) & 0xFF);
        raw[2] = (byte)((payloadLen >> 8) & 0xFF);
        raw[3] = (byte)(payloadLen & 0xFF);

        _udp.Send(raw, raw.Length);
        return seq;
    }

    private void TcpReadLoop()
    {
        byte[] lenBuf = new byte[4];
        try
        {
            while (_running && _stream != null)
            {
                if (!ReadExact(_stream, lenBuf, 4)) break;
                if (BitConverter.IsLittleEndian) Array.Reverse(lenBuf);
                int len = BitConverter.ToInt32(lenBuf, 0);
                if (len <= 0 || len > 4 * 1024 * 1024) break;
                byte[] buf = new byte[len];
                if (!ReadExact(_stream, buf, len)) break;
                var apc = Deserialize<APC>(buf);
                if (apc == null) continue;
                byte[] body = apc.Content ?? Array.Empty<byte>();
                switch (apc.Id)
                {
                    case 1: CallBackLogin = Deserialize<CallBackLoginData>(body); break;
                    case 1000: TcpConnId = Deserialize<TcpConnectionIDData>(body); break;
                    case 12: Room = Deserialize<RoomData>(body); break;
                    case 3: Init3 = Deserialize<OnGameinitData>(body); break;
                    case 232: Init232 = Deserialize<OnGameinitData>(body); break;
                    case 5: Interlocked.Increment(ref GameWinCount); break;
                    case 18:
                    case 19:
                        Interlocked.Increment(ref MissionResultCount);
                        break;
                    case 62: Interlocked.Increment(ref ClearSectionCount); break;
                    case 9:
                        var pl = Deserialize<PlayerLoginData>(body);
                        if (pl != null) lock (PlayerLogins) PlayerLogins.Add(pl);
                        break;
                    case 10:
                        if (Deserialize<PlayerLogoutData>(body) is { } logout) PlayerLogouts.Enqueue(logout);
                        break;
                    case 4:
                        var bs = Deserialize<BroadcastScoreData>(body);
                        if (bs != null) lock (TeamScores) TeamScores.Add(bs);
                        break;
                    case 6:
                        var kp = Deserialize<KillPlayerInfoData>(body);
                        if (kp != null) lock (Kills) Kills.Add(kp);
                        break;
                    case 8:
                        if (Deserialize<AllKillInfoData>(body) is { } scoreboard) Scoreboards.Enqueue(scoreboard);
                        Interlocked.Increment(ref AllKillInfoCount);
                        break;
                    case 14:
                        var c4 = Deserialize<C4ActiveData>(body);
                        if (c4 != null) lock (C4Actives) C4Actives.Add(c4);
                        break;
                    case 15:
                        if (Deserialize<ProgressData>(body) is { } prog) ProgressEvents.Enqueue(prog);
                        break;
                    case 16:
                        if (Deserialize<C4MessageData>(body) is { } c4Message) C4Messages.Enqueue(c4Message);
                        break;
                    case 17: LastMvp = Deserialize<LastMvpData>(body); break;
                    case 20:
                        if (Deserialize<DamageCountData>(body) is { } dmgCount) DamageCounts.Enqueue(dmgCount);
                        break;
                    case 22:
                        if (Deserialize<TacticsSoundData>(body) is { } ts) TacticsSounds.Enqueue(ts);
                        break;
                    case 24: LatestPings = Deserialize<PingListData>(body); break;
                    case 28: AssistBodyLengths.Enqueue(body.Length); break;
                    case 29: GroupBest = Deserialize<GroupBestKillData>(body); break;
                    case 30:
                        if (Deserialize<ObserverInfoData>(body) is { } obs) ObserverInfos.Enqueue(obs);
                        break;
                    case 35:
                        if (Deserialize<GameMessageData>(body) is { } gameMessage) GameMessages.Enqueue(gameMessage);
                        break;
                    case 37:
                        var innerApc = Deserialize<APC>(body);
                        if (innerApc?.Id == 17 && innerApc.Content != null &&
                            Deserialize<SprayEventEntityData>(innerApc.Content) is { } spray)
                        {
                            SprayEvents.Enqueue(spray);
                        }
                        break;
                    case 38:
                        if (Deserialize<SprayMessageData>(body) is { } sprayMsg) SprayMessages.Enqueue(sprayMsg);
                        break;
                    case 23:
                        if (Deserialize<IntData>(body) is { } growth) BioGrowth.Enqueue(growth.Data);
                        break;
                    case 25:
                        if (Deserialize<BioMessageData>(body) is { } bio) BioMessages.Enqueue(bio);
                        break;
                    case 26:
                        if (Deserialize<IntData>(body) is { } damage) BioDamage.Enqueue(damage.Data);
                        break;
                    case 27:
                        var sk = Deserialize<SkillInfoData>(body);
                        if (sk != null) lock (SkillInfos) SkillInfos.Add(sk);
                        break;
                    case 64:
                        var bh = Deserialize<BigHeadProgressData>(body);
                        if (bh != null) lock (BigHeadMsgs) BigHeadMsgs.Add(bh);
                        break;
                    case 66:
                        var ex = Deserialize<ExpData>(body);
                        if (ex != null) lock (ExpMsgs) ExpMsgs.Add(ex);
                        break;
                    case 71:
                        var pm = Deserialize<PveMessageData>(body);
                        if (pm != null) lock (PveMsgs) PveMsgs.Add(pm);
                        break;
                    case 74:
                        RoadBlocks = Deserialize<PeekabooItemListTmpData>(body);
                        break;
                    case 83:
                        if (Deserialize<BioLvUpData>(body) is { } lvup) BioLvUps.Enqueue(lvup);
                        break;
                    case 111:
                        SceneMapInfo = Deserialize<SceneMapInfoData>(body);
                        break;
                    case 114:
                        var rc = Deserialize<RpgCounterData>(body);
                        if (rc != null) lock (RpgCounterUpdates) RpgCounterUpdates.Add(rc);
                        break;
                    case 126:
                        RpgCounterList = Deserialize<RpgCounterListData>(body);
                        break;
                    case 100:
                        var sp = Deserialize<SimpleProto>(body);
                        if (sp != null) lock (SimpleProtos) SimpleProtos.Add(sp);
                        break;
                    case 120:
                        var wm = Deserialize<MessageListData>(body);
                        if (wm != null) lock (WeaponMasterMsgs) WeaponMasterMsgs.Add(wm);
                        break;
                    case 131:
                        Interlocked.Increment(ref HitPlayerCount);
                        break;
                }
            }
        }
        catch { }
    }

    private void UdpReadLoop()
    {
        try
        {
            while (_running)
            {
                IPEndPoint? remote = null;
                byte[] pkt = _udp.Receive(ref remote);
                if (pkt.Length >= 11 && pkt[4] == 0)
                {
                    P2PAckReceived = true;
                    continue;
                }
                if (pkt.Length >= 10 && pkt[4] == 1)
                {
                    using var compMs = new MemoryStream(pkt, 10, pkt.Length - 10);
                    using var z = new ZLibStream(compMs, CompressionMode.Decompress);
                    using var rawMs = new MemoryStream();
                    z.CopyTo(rawMs);
                    var snapshot = ParseSnapshot(rawMs.ToArray());
                    foreach (int del in snapshot.Header.DeleteIdList) SeenDeletedIds.Add(del);
                    foreach (var explosion in snapshot.GrenadeExplosions) GrenadeExplosions.Enqueue(explosion);
                    LatestSnapshot = snapshot;
                    Interlocked.Increment(ref SnapshotCount);
                    OnSnapshotReceived?.Invoke(snapshot);
                }
            }
        }
        catch { }
    }

    private static DecodedSnapshot ParseSnapshot(byte[] raw)
    {
        int pos = 0;
        int hdrLen = ReadIntBE(raw, ref pos);
        byte[] hdrBytes = new byte[hdrLen];
        Buffer.BlockCopy(raw, pos, hdrBytes, 0, hdrLen);
        pos += hdrLen;
        var header = Deserialize<SnapshotData>(hdrBytes) ?? new SnapshotData();
        var snap = new DecodedSnapshot { Header = header };

        while (pos + 5 <= raw.Length)
        {
            byte etype = raw[pos++];
            int elen = ReadIntBE(raw, ref pos);
            if (elen < 0 || pos + elen > raw.Length) break;
            byte[] eb = new byte[elen];
            Buffer.BlockCopy(raw, pos, eb, 0, elen);
            pos += elen;

            if (etype == 1)
            {
                var pe = Deserialize<PlayerEntityData>(eb);
                if (pe != null) snap.Players.Add(pe);
            }
            else if (etype == 6)
            {
                var swe = Deserialize<SceneWeaponEntityData>(eb);
                if (swe != null) snap.SceneWeapons.Add(swe);
            }
            else if (etype == 5 && Deserialize<GrenadeExplosionEventEntityData>(eb) is { } explosion)
                snap.GrenadeExplosions.Add(explosion);
            else if (etype == 9 && Deserialize<SceneBufEntityData>(eb) is { } sceneBuff)
                snap.SceneBuffs.Add(sceneBuff);
            else if (etype == 14 && Deserialize<PveTowerEntityData>(eb) is { } pte)
                snap.PveTowers.Add(pte);
        }
        return snap;
    }

    private static bool ReadExact(NetworkStream s, byte[] buf, int count)
    {
        int total = 0;
        while (total < count)
        {
            int r = s.Read(buf, total, count - total);
            if (r <= 0) return false;
            total += r;
        }
        return true;
    }

    private static void WriteIntBE(MemoryStream ms, int v)
    {
        ms.WriteByte((byte)((v >> 24) & 0xFF));
        ms.WriteByte((byte)((v >> 16) & 0xFF));
        ms.WriteByte((byte)((v >> 8) & 0xFF));
        ms.WriteByte((byte)(v & 0xFF));
    }

    private static void WriteShortBE(MemoryStream ms, short v)
    {
        ms.WriteByte((byte)((v >> 8) & 0xFF));
        ms.WriteByte((byte)(v & 0xFF));
    }

    private static int ReadIntBE(byte[] b, ref int pos)
    {
        int v = (b[pos] << 24) | (b[pos + 1] << 16) | (b[pos + 2] << 8) | b[pos + 3];
        pos += 4;
        return v;
    }

    private static byte[] Serialize(object obj)
    {
        using var ms = new MemoryStream();
        Proto.Serialize(ms, obj);
        return ms.ToArray();
    }

    private static T? Deserialize<T>(byte[] bytes) where T : class
    {
        if (bytes.Length == 0) return null;
        using var ms = new MemoryStream(bytes);
        return Proto.Deserialize(ms, null, typeof(T)) as T;
    }

    public void Dispose()
    {
        _running = false;
        try { _tcp.Close(); } catch { }
        try { _udp.Close(); } catch { }
    }
}


internal static class Program
{
    private const int TcpPort = 27150;
    private const int UdpPort = 27151;
    private static readonly string Root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
    private static readonly string ServerExe = File.Exists(Path.Combine(Root, "SSJJ-Server", "bin", "Release", "net10.0", "SSJJ-Server.exe"))
        ? Path.Combine(Root, "SSJJ-Server", "bin", "Release", "net10.0", "SSJJ-Server.exe")
        : Path.Combine(Root, "SSJJ-Server", "bin", "Debug", "net10.0", "SSJJ-Server.exe");
    private static SSJJ.Server.Physics.OfficialPhysicsWorld? _map12Physics;
    private static SSJJ.Server.Bots.BspNavGraph? _map12Nav;

    private static (SSJJ.Server.Physics.OfficialPhysicsWorld Physics, SSJJ.Server.Bots.BspNavGraph Nav) EnsureMap12Nav()
    {
        if (_map12Physics != null && _map12Nav != null)
        {
            return (_map12Physics, _map12Nav);
        }

        var bsp = SSJJ.Server.Config.BspMapData.Load(12, @"D:\SSJJ-4399\battle\3_64");
        var physics = new SSJJ.Server.Physics.OfficialPhysicsWorld();
        Assert(physics.Initialize(12, bsp.RawBspBytes), "VerifyE2E initialized Map 12 OfficialPhysicsWorld");
        var nav = new SSJJ.Server.Bots.BspNavGraph();
        nav.Build(bsp, physics);
        Assert(nav.NodeCount > 0, $"VerifyE2E built Map 12 BspNavGraph ({nav.NodeCount} nodes)");
        _map12Physics = physics;
        _map12Nav = nav;
        return (physics, nav);
    }

    private static void DisposeMap12Nav()
    {
        _map12Nav = null;
        _map12Physics?.Dispose();
        _map12Physics = null;
    }

    private static int Main(string[] args)
    {
        Console.WriteLine($"[VerifyE2E] Root = {Root}");
        Console.WriteLine($"[VerifyE2E] Exe  = {ServerExe}");
        if (!File.Exists(ServerExe))
        {
            Console.Error.WriteLine("[ERR] SSJJ-Server.exe not found! Build SSJJ-Server first.");
            return 1;
        }

        try
        {
            if (args.Contains("--dual"))
            {
                TestDualClientMultiplayer();
                return 0;
            }
            if (args.Contains("--biohazard-only"))
            {
                TestBiohazard();
                return 0;
            }
            if (args.Contains("--multiplayer-only"))
            {
                TestMultiplayerRoom();
                TestMultiplayerDamageReport();
                return 0;
            }
            if (args.Contains("--lobby-only"))
            {
                TestDualLobbyAndBattleBridge();
                return 0;
            }
            if (args.Contains("--direct-join-only"))
            {
                TestDirectJoin();
                return 0;
            }
            TestCompetitiveMovementAndBhopParity();
            TestDualTransport();
            TestDirectJoin();
            TestMultiplayerRoom();
            TestMultiplayerDamageReport();
            TestBiohazard();
            TestWeaponDropAndPickup();
            TestGrenadeFlight();
            TestLoadoutAndInspect();
            TestCombatAnnouncements();
            TestScopedMovement();
            TestTeamAiHitmarkerAndSettlement();
            TestCombatFeedbackAndSpectate();
            TestBladeAiSkillsTransformAndMelee();
            TestExplodeC4DropPickupAndRoundReset();
            TestWeaponMasterFlyKnifeBigHead();
            TestPveIndustrial01WaveAndBossSettlement();
            TestDualClientMultiplayer();
            TestAllModeMultiplayerE2E();
            TestHeroWeaponsSkillAndVfxE2E();
            TestDualLobbyAndBattleBridge();
            Console.WriteLine("[VERIFY-E2E] ALL E2E WIRE PROTOCOL + GAMEPLAY CHECKS PASSED!");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"[VERIFY-E2E FAIL] {ex}");
            return 1;
        }
        finally
        {
            DisposeMap12Nav();
        }
    }

    private static Process StartServer(object configObj, string tag, IPAddress? bindAddress = null)
    {
        string cfgPath = Path.Combine(Path.GetTempPath(), $"ssjj_e2e_{tag}_{Environment.ProcessId}.json");
        File.WriteAllText(cfgPath, JsonSerializer.Serialize(configObj));

        var psi = new ProcessStartInfo
        {
            FileName = ServerExe,
            Arguments = $"--tcp-port {TcpPort} --udp-port {UdpPort} --config-json \"{cfgPath}\"",
            WorkingDirectory = Root,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        if (bindAddress != null)
            psi.Environment[SSJJ.Server.Network.BindPolicy.EnvVar] = bindAddress.ToString();
        var proc = Process.Start(psi)!;
        var readyEvt = new ManualResetEventSlim(false);
        var seen = new List<string>();
        proc.OutputDataReceived += (_, e) =>
        {
            if (e.Data == null) return;
            lock (seen) seen.Add(e.Data);
            if (e.Data.Contains("Simulation loop started")) readyEvt.Set();
        };
        proc.ErrorDataReceived += (_, e) =>
        {
            if (e.Data == null) return;
            lock (seen) seen.Add("[ERR] " + e.Data);
        };
        proc.BeginOutputReadLine();
        proc.BeginErrorReadLine();
        if (!readyEvt.Wait(12000))
        {
            KillSafe(proc);
            string dump;
            lock (seen) dump = string.Join("\n", seen);
            throw new Exception($"Server [{tag}] failed to start. Out:\n{dump}");
        }
        return proc;
    }

    private static BattleWireClient HandshakeAndSpawn(int tcpPort, int udpPort, long userId = 0, int playerId = 1,
        long roomId = 1001, string host = "127.0.0.1")
    {
        var c = new BattleWireClient(host, tcpPort, udpPort);
        if (userId == 0) c.SendTcp(2);
        else c.SendTcp(2, new LoginData { RoomId = roomId, UserId = userId, Sign = "test", Timestamp = "1" });
        WaitUntil(() => c.CallBackLogin != null && c.Room != null && c.Init3 != null, 5000, "Stage1 Handshake");
        Assert(c.CallBackLogin!.Res, "CallBackLogin.Res is true");

        c.SendTcp(3); // LoadingSuccess
        WaitUntil(() => c.Init232 != null && c.TeamScores.Count > 0 && c.AllKillInfoCount > 0, 5000, "Stage2 Spawn");

        for (int i = 0; i < 5 && !c.P2PAckReceived; i++)
        {
            c.SendP2PProbe();
            Thread.Sleep(50);
        }
        Assert(c.P2PAckReceived, "UDP P2P Probe ack received");
        WaitUntil(() => c.LatestSnapshot != null, 5000, "First UDP ZLib Snapshot");
        Assert(c.LatestSnapshot!.Header.Base == -1, $"Snapshot.Base == -1 (got {c.LatestSnapshot.Header.Base})");
        Assert(c.LatestSnapshot.Header.Self == playerId, $"Snapshot.Self == {playerId} (got {c.LatestSnapshot.Header.Self})");
        return c;
    }

    private static void SteerAndShootAtClosestEnemy(
        BattleWireClient cli,
        byte slot,
        int extraButtons,
        ref float steerOffsetDeg,
        ref double steerUntilSec,
        ref float lastCheckX,
        ref float lastCheckY,
        ref double lastCheckSec,
        Stopwatch sw,
        bool allowAttack = true,
        int? targetPlayerId = null,
        bool useMap12Nav = true)
    {
        var snap = cli.LatestSnapshot!;
        int self = snap.Header.Self;
        var me = snap.Players.First(p => p.Id == self);
        if (me.IsDead)
        {
            cli.SendUserCmd(0, 0, extraButtons, 1, slot, me.ViewYaw, 0f);
            return;
        }

        if (!useMap12Nav)
        {
            var directEnemy = snap.Players
                .Where(p => p.Id != self && (p.Team != me.Team || p.Team >= 10) && !p.IsDead
                    && (targetPlayerId == null || p.Id == targetPlayerId))
                .OrderBy(p => Dist2(me, p))
                .FirstOrDefault();

            double secNow = sw.Elapsed.TotalSeconds;
            if (secNow - lastCheckSec >= 0.45)
            {
                float movedStep = Dist2(me.X, me.Y, lastCheckX, lastCheckY);
                lastCheckX = me.X;
                lastCheckY = me.Y;
                lastCheckSec = secNow;
                if (movedStep < 30f)
                {
                    steerOffsetDeg = steerOffsetDeg == 0f ? 75f : -steerOffsetDeg;
                    steerUntilSec = secNow + 0.9;
                }
            }

            if (directEnemy != null)
            {
                float directDist2d = Math.Max(1f, Dist2(me, directEnemy));
                float directAimYaw = (float)(Math.Atan2(directEnemy.Y - me.Y, directEnemy.X - me.X) * 180.0 / Math.PI);
                float directAimPitch = -(float)(Math.Atan2((directEnemy.Z + 115f) - (me.Z + 146f), directDist2d) * 180.0 / Math.PI);
                float directMoveYaw = secNow < steerUntilSec ? directAimYaw + steerOffsetDeg : directAimYaw;
                int directBtns = Btn.Forward | extraButtons;
                if (allowAttack && directDist2d < 3500f) directBtns |= Btn.Attack;
                cli.SendUserCmd(4, 0, directBtns, 1, slot, directMoveYaw, directAimPitch);
            }
            else
            {
                cli.SendUserCmd(4, 0, Btn.Forward | extraButtons, 1, slot, me.ViewYaw, 0f);
            }
            return;
        }

        var (physics, nav) = EnsureMap12Nav();
        var enemies = snap.Players
            .Where(p => p.Id != self && (p.Team != me.Team || p.Team >= 10) && !p.IsDead
                && (targetPlayerId == null || p.Id == targetPlayerId))
            .OrderBy(p => Dist2(me, p))
            .ToList();

        double nowSec = sw.Elapsed.TotalSeconds;
        if (nowSec - lastCheckSec >= 0.45)
        {
            float movedStep = Dist2(me.X, me.Y, lastCheckX, lastCheckY);
            lastCheckX = me.X;
            lastCheckY = me.Y;
            lastCheckSec = nowSec;
            if (movedStep < 25f)
            {
                steerOffsetDeg = steerOffsetDeg == 0f ? 65f : -steerOffsetDeg;
                steerUntilSec = nowSec + 0.8;
            }
        }

        if (enemies.Count == 0)
        {
            cli.SendUserCmd(4, 0, Btn.Forward | extraButtons, 1, slot, me.ViewYaw, 0f);
            return;
        }

        PlayerEntityData? visibleEnemy = allowAttack
            ? enemies.FirstOrDefault(e => physics.TraceRayClear(me.X, me.Y, me.Z + 146f, e.X, e.Y, e.Z + 120f, out _))
            : null;

        if (visibleEnemy != null)
        {
            float dist2d = Math.Max(1f, Dist2(me, visibleEnemy));
            float aimYaw = (float)(Math.Atan2(visibleEnemy.Y - me.Y, visibleEnemy.X - me.X) * 180.0 / Math.PI);
            float aimPitch = -(float)(Math.Atan2((visibleEnemy.Z + 120f) - (me.Z + 146f), dist2d) * 180.0 / Math.PI);
            // Correct the aim for the punch that the server will retain after this command's decay.
            const float commandSeconds = 0.033f;
            float punchLength = MathF.Sqrt(me.PunchYaw * me.PunchYaw + me.PunchPitch * me.PunchPitch);
            if (punchLength > 0f)
            {
                float scale = me.DecayTime > 0 ? 1f
                    : Math.Max(0f, punchLength - (10f + 0.5f * punchLength) * commandSeconds) / punchLength;
                aimYaw -= 2f * scale * me.PunchYaw;
                aimPitch += 2f * scale * me.PunchPitch;
            }
            int btns = extraButtons;
            sbyte fwd = 0;
            sbyte right = 0;
            // Guns hold steady when already in close/mid LOS; melee advances into swing range.
            if (slot == 3 || dist2d > 850f)
            {
                btns |= Btn.Forward;
                fwd = 4;
            }
            if (nowSec < steerUntilSec && fwd != 0)
            {
                btns |= Btn.Jump | (steerOffsetDeg > 0f ? Btn.Right : Btn.Left);
                right = (sbyte)(steerOffsetDeg > 0f ? 4 : -4);
            }
            if (dist2d < 3500f) btns |= Btn.Attack;
            cli.SendUserCmd(fwd, right, btns, 1, slot, aimYaw, aimPitch);
            return;
        }

        var target = enemies[0];
        float wx = target.X;
        float wy = target.Y;
        var path = nav.FindPath(me.X, me.Y, me.Z + 4f, target.X, target.Y, target.Z + 4f);
        for (int i = 0; i < path.Count; i++)
        {
            if (nav.TryGetNode(path[i], out var node) && Dist2(me.X, me.Y, node.X, node.Y) > 90f)
            {
                wx = node.X;
                wy = node.Y;
                break;
            }
        }

        float navYaw = (float)(Math.Atan2(wy - me.Y, wx - me.X) * 180.0 / Math.PI);
        float moveYaw = nowSec < steerUntilSec ? navYaw + steerOffsetDeg : navYaw;
        int navBtns = Btn.Forward | extraButtons;
        if (nowSec < steerUntilSec) navBtns |= Btn.Jump;
        cli.SendUserCmd(4, 0, navBtns, 1, slot, moveYaw, 0f);
    }

    private static void TestCompetitiveMovementAndBhopParity()
    {
        Console.WriteLine("=== [0] Testing Competitive Movement & Bhop Parity (team_ai map12: 681 jump, AirAccel=10, 1.25x / 825 cap, crouch-jump, AWP speed) ===");
        var cfg = new
        {
            map = "12",
            mode = "team_ai",
            race_type = 2003,
            tcp_port = TcpPort,
            udp_port = UdpPort,
            ally_bot_count = 0,
            enemy_bot_count = 0,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" },
                new { primary = "awp", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger_1", melee_skin = "", throwable = "grenade", throwable_skin = "" }
            }
        };
        using var srv = StartServer(cfg, "move_parity");
        try
        {
            using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
            var history = new List<PlayerEntityData>();
            object histLock = new();
            cli.OnSnapshotReceived += snap =>
            {
                var me = snap.Players.FirstOrDefault(p => p.Id == 1);
                if (me != null)
                {
                    lock (histLock) history.Add(me);
                }
            };

            // 1. Verify Method 111 SceneMapInfoData & initial movement snapshot parity
            WaitUntil(() => cli.SceneMapInfo != null, 3000, "Method 111 SceneMapInfoData in competitive team_ai");
            Assert(cli.SceneMapInfo!.WorldGravity == 2032 && cli.SceneMapInfo.HumanityJumpVelocity == 681,
                $"SceneMapInfo gravity/jump mismatch: g={cli.SceneMapInfo.WorldGravity}, jv={cli.SceneMapInfo.HumanityJumpVelocity}");

            var p0 = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            Assert(Math.Abs(p0.Airaccelerate - 10f) < 0.01f, $"PlayerEntityData.Airaccelerate == 10 (got {p0.Airaccelerate})");
            Assert(p0.LimitSpeedInJumpRule, "PlayerEntityData.LimitSpeedInJumpRule == true");
            Assert(Math.Abs(p0.BeingHitFriction - 16f) < 0.01f, $"BeingHitFriction == 16 (got {p0.BeingHitFriction})");
            Assert(Math.Abs(p0.GravityEffectRate - 1f) < 0.01f, $"GravityEffectRate == 1 (got {p0.GravityEffectRate})");
            Assert(p0.Stamina < 1f, $"Initial Stamina == 0 (got {p0.Stamina})");
            Assert(p0.DuckState == 3 && Math.Abs(p0.ViewHeight - 150f) < 1f, $"Initial stand state (ds={p0.DuckState}, vh={p0.ViewHeight})");

            float baseYaw = p0.ViewYaw;

            void SendAndSync(sbyte fwd, sbyte right, int btns, byte bag, byte slot, float yaw, float pitch, byte ms = 16)
            {
                int seq = cli.SendUserCmd(fwd, right, btns, bag, slot, yaw, pitch, ms);
                WaitUntil(() => (cli.LatestSnapshot?.Header.LastCmd ?? 0) >= seq, 1500, $"Ack cmd seq={seq}");
            }

            // Settle on ground
            for (int i = 0; i < 4; i++) SendAndSync(0, 0, 0, 1, 1, baseYaw, 0f, 16);
            float z0 = cli.LatestSnapshot!.Players.First(p => p.Id == 1).Z;

            // 2. Test authentic Jump Height (~114 cm for 681 vel / 2032 gravity, NOT ~27 cm from old 330 bug),
            //    Stamina spike, LegsAnim=5, and PlayerStateFlag 8388608 (hold jump) / 4194304 (release jump in air)
            lock (histLock) history.Clear();
            SendAndSync(0, 0, Btn.Jump, 1, 1, baseYaw, 0f, 16);
            var jumpStart = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            Assert(!jumpStart.OnGround, "Player is airborne immediately after Jump");
            Assert(jumpStart.Velocity != null && jumpStart.Velocity.Z > 550f,
                $"Jump takeoff VelZ aligned to 681 (got {jumpStart.Velocity?.Z:F1})");
            Assert((jumpStart.PlayerStateFlag & 8388608) != 0,
                $"Airborne hold-jump sets PlayerStateFlag 8388608 (got 0x{jumpStart.PlayerStateFlag:X})");
            Assert(jumpStart.Stamina > 500f, $"Jump sets stamina penalty (~1315, got {jumpStart.Stamina:F1})");
            Assert(jumpStart.LegsAnim == 5, $"Airborne LegsAnim == 5 (got {jumpStart.LegsAnim})");

            float maxJumpZ = jumpStart.Z;
            bool sawAirReleaseFlag = false;
            bool landed = false;
            for (int i = 0; i < 65; i++)
            {
                SendAndSync(0, 0, 0, 1, 1, baseYaw, 0f, 16);
                var cur = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                if (cur.Z > maxJumpZ) maxJumpZ = cur.Z;
                if (!cur.OnGround && (cur.PlayerStateFlag & 4194304) != 0) sawAirReleaseFlag = true;
                if (i > 10 && cur.OnGround)
                {
                    landed = true;
                    break;
                }
            }
            float jumpRise = maxJumpZ - z0;
            Assert(landed, "Player landed cleanly after vertical jump");
            Assert(jumpRise >= 100f && jumpRise <= 125f,
                $"Authentic jump height ~114cm for 681/2032 (got {jumpRise:F1}cm)");
            Assert(sawAirReleaseFlag, "Releasing Jump in mid-air sets PlayerStateFlag 4194304");
            // Wait 1 extra ground frame without jump -> flags cleared
            SendAndSync(0, 0, 0, 1, 1, baseYaw, 0f, 16);
            var afterLand = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            Assert((afterLand.PlayerStateFlag & (8388608 | 4194304)) == 0,
                $"Ground without jump clears 8388608|4194304 (got 0x{afterLand.PlayerStateFlag:X})");

            // 3. Test anti-autohop: holding Space continuously across landing must NOT auto-rejump
            SendAndSync(0, 0, Btn.Jump, 1, 1, baseYaw, 0f, 16);
            bool landedWhileHolding = false;
            int groundFramesWhileHolding = 0;
            for (int i = 0; i < 75; i++)
            {
                SendAndSync(0, 0, Btn.Jump, 1, 1, baseYaw, 0f, 16);
                var cur = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                if (i > 10 && cur.OnGround)
                {
                    landedWhileHolding = true;
                    groundFramesWhileHolding++;
                }
                else if (landedWhileHolding)
                {
                    throw new Exception($"Anti-autohop broken: player auto-rejumped while holding Space continuously (frame={i}, flag=0x{cur.PlayerStateFlag:X})");
                }
                if (groundFramesWhileHolding >= 6) break;
            }
            Assert(landedWhileHolding && groundFramesWhileHolding >= 6,
                $"Holding Space continuously stays on ground after landing (groundFrames={groundFramesWhileHolding})");
            SendAndSync(0, 0, 0, 1, 1, baseYaw, 0f, 16);

            // 4. Test Crouch-Jump (DuckState == 2 in air -> 0 on ground, ViewHeight 93 -> 150)
            SendAndSync(0, 0, Btn.Jump, 1, 1, baseYaw, 0f, 16);
            bool sawAirDuck = false;
            bool landedCrouched = false;
            for (int i = 0; i < 70; i++)
            {
                SendAndSync(0, 0, Btn.Duck, 1, 1, baseYaw, 0f, 16);
                var cur = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                if (!cur.OnGround && cur.DuckState == 2) sawAirDuck = true;
                if (i > 10 && cur.OnGround && cur.DuckState == 0)
                {
                    landedCrouched = true;
                    Assert(Math.Abs(cur.ViewHeight - 93f) < 1f, $"Crouched ViewHeight == 93 (got {cur.ViewHeight:F1})");
                    break;
                }
            }
            Assert(sawAirDuck, "Air duck sets DuckState == 2 (DuckJumpBrush)");
            Assert(landedCrouched, "Landing while ducking transitions DuckState 2 -> 0");
            SendAndSync(0, 0, 0, 1, 1, baseYaw, 0f, 16);
            var stoodUp = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            Assert(stoodUp.DuckState == 3 && Math.Abs(stoodUp.ViewHeight - 150f) < 1f,
                $"Releasing Duck restores stand state (ds={stoodUp.DuckState}, vh={stoodUp.ViewHeight:F1})");

            static float Speed2D(PlayerEntityData p) =>
                p.Velocity == null ? 0f : (float)Math.Sqrt(p.Velocity.X * p.Velocity.X + p.Velocity.Y * p.Velocity.Y);

            static void SendAndSyncClient(BattleWireClient client, sbyte fwd, sbyte right, int btns, byte bag, byte slot, float yaw, float pitch, byte ms = 16)
            {
                int seq = client.SendUserCmd(fwd, right, btns, bag, slot, yaw, pitch, ms);
                WaitUntil(() => (client.LatestSnapshot?.Header.LastCmd ?? 0) >= seq, 1500, $"Ack cmd seq={seq}");
            }

            // 5. Helper to test strafe-bunnyhop speed cap with a given bag/slot
            static (float maxGroundSpeed, float peakBhopSpeed) MeasureWeaponGroundAndBhop(BattleWireClient client, byte bag, byte slot, string expectedWpn, float yawDir)
            {
                // Switch weapon and wait for velocity & landing stamina penalty (1315ms) to fully recover
                for (int i = 0; i < 90; i++)
                {
                    SendAndSyncClient(client, 0, 0, 0, bag, slot, yawDir, 0f, 16);
                    var cur = client.LatestSnapshot!.Players.First(p => p.Id == 1);
                    if (i >= 5 && cur.OnGround && cur.Stamina < 0.1f && Speed2D(cur) < 1f) break;
                }
                var swCheck = client.LatestSnapshot!.Players.First(p => p.Id == 1);
                Assert(swCheck.CurrentWeaponName == expectedWpn, $"Switched to {expectedWpn} (got {swCheck.CurrentWeaponName})");

                // Phase A: Ground straight run (45 frames = 720ms, enough to reach steady state under accel=5 / friction=4)
                float maxGround = 0f;
                for (int i = 0; i < 45; i++)
                {
                    SendAndSyncClient(client, 100, 0, Btn.Forward, bag, slot, yawDir, 0f, 16);
                    float spd = Speed2D(client.LatestSnapshot!.Players.First(p => p.Id == 1));
                    if (spd > maxGround) maxGround = spd;
                }

                // Phase B: Strafe-bunnyhop (single-frame Jump on ground + smooth A/D air-strafing)
                float peakBhop = 0f;
                float curYaw = yawDir;
                int strafeDir = 1; // +1 = right (yaw decreases), -1 = left (yaw increases)
                int strafeTicks = 0;
                bool prevOnGround = true;
                for (int i = 0; i < 180; i++)
                {
                    var cur = client.LatestSnapshot!.Players.First(p => p.Id == 1);
                    bool doJump = cur.OnGround;
                    if (!cur.OnGround)
                    {
                        if (prevOnGround)
                        {
                            strafeDir = -strafeDir;
                            strafeTicks = 0;
                        }
                        strafeTicks++;
                        if (strafeTicks >= 16)
                        {
                            strafeDir = -strafeDir;
                            strafeTicks = 0;
                        }
                        // Authentic SSJJ air-strafe: Right (+100) turns yaw clockwise (-deg); Left (-100) turns yaw CCW (+deg)
                        curYaw += (strafeDir > 0 ? -3.0f : 3.0f);
                        sbyte mr = (sbyte)(strafeDir > 0 ? 100 : -100);
                        int btns = strafeDir > 0 ? Btn.Right : Btn.Left;
                        SendAndSyncClient(client, 0, mr, btns, bag, slot, curYaw, 0f, 16);
                    }
                    else
                    {
                        int btns = Btn.Forward | (doJump ? Btn.Jump : 0);
                        SendAndSyncClient(client, 100, 0, btns, bag, slot, curYaw, 0f, 16);
                    }
                    prevOnGround = cur.OnGround;
                    var after = client.LatestSnapshot!.Players.First(p => p.Id == 1);
                    float spd = Speed2D(after);
                    if (spd > peakBhop) peakBhop = spd;
                }
                return (maxGround, peakBhop);
            }

            // Pick a clear open yaw direction on map12
            float openYaw = baseYaw;
            // Test 5A: dagger (MaxSpeed = 635 -> bhop cap 635 * 1.25 = 793.75)
            var (daggerGround, daggerBhop) = MeasureWeaponGroundAndBhop(cli, 1, 3, "dagger", openYaw);
            Assert(daggerGround >= 610f && daggerGround <= 637f,
                $"dagger ground speed ~635 (got {daggerGround:F1})");
            Assert(daggerBhop > 650f,
                $"dagger bhop accelerates above base run speed via AirAccel=10 (got {daggerBhop:F1})");
            Assert(daggerBhop <= 635f * 1.25f + 1.5f,
                $"dagger bhop strictly capped at 635*1.25=793.75 (got {daggerBhop:F1})");

            cli.Dispose();
            KillSafe(srv);

            // Fresh spawn in spawn LoadoutBounds so switching to Bag 2 respects authentic CanChangeBag rule
            using var srvBag2 = StartServer(cfg, "move_parity_bag2");
            try
            {
                using var cli2 = HandshakeAndSpawn(TcpPort, UdpPort);
                var p0_2 = cli2.LatestSnapshot!.Players.First(p => p.Id == 1);
                Assert(p0_2.CanChangeBag, "Fresh spawn has CanChangeBag == true to select Bag 2");
                float yaw2 = p0_2.ViewYaw;

                // Test 5B: dagger_1 (Weapon.json MaxSpeed=1000 -> FPS human cap 660 -> bhop cap 660 * 1.25 = 825.0!)
                var (cap660Ground, cap825Bhop) = MeasureWeaponGroundAndBhop(cli2, 2, 3, "dagger_1", yaw2);
                Assert(cap660Ground >= 635f && cap660Ground <= 662f,
                    $"FPS human base speed capped at 660 even for 1000-speed weapon (got {cap660Ground:F1})");
                Assert(cap825Bhop > 680f,
                    $"660-base bhop accelerates above 660 (got {cap825Bhop:F1})");
                Assert(cap825Bhop <= 825.0f + 1.5f,
                    $"Normal bhop speed strictly capped at 825.0 (got {cap825Bhop:F1})");

                // Test 5C: awp (Sniper MaxSpeedParam="380,446" -> unzoomed ground speed ~446; same-bag switch works outside spawn)
                for (int i = 0; i < 90; i++)
                {
                    SendAndSyncClient(cli2, 0, 0, 0, 2, 1, yaw2 + 180f, 0f, 16);
                    var cur = cli2.LatestSnapshot!.Players.First(p => p.Id == 1);
                    if (i >= 5 && cur.OnGround && cur.Stamina < 0.1f && Speed2D(cur) < 1f) break;
                }
                float awpGround = 0f;
                for (int i = 0; i < 45; i++)
                {
                    SendAndSyncClient(cli2, 100, 0, Btn.Forward, 2, 1, yaw2 + 180f, 0f, 16);
                    float spd = Speed2D(cli2.LatestSnapshot!.Players.First(p => p.Id == 1));
                    if (spd > awpGround) awpGround = spd;
                }
                Assert(awpGround >= 425f && awpGround <= 448f,
                    $"AWP unzoomed ground speed aligned to 446 (got {awpGround:F1})");

                Console.WriteLine($"[PASS] competitive movement & bhop parity: jumpRise={jumpRise:F1}cm, dagger={daggerGround:F1}/{daggerBhop:F1} (<=793.8), 660-cap={cap660Ground:F1}/{cap825Bhop:F1} (<=825.0), awp={awpGround:F1}");
            }
            finally { KillSafe(srvBag2); }
        }
        finally { KillSafe(srv); }
    }

    private static void TestBiohazard()
    {
        var cfg = new
        {
            map = "12", mode = "biohazard", max_human_players = 2, win_score = 2,
            ally_bot_count = 0, enemy_bot_count = 0, tcp_port = TcpPort, udp_port = UdpPort,
            biohazard = new { round_ms = 65000, respawn_ms = 1700, intermission_ms = 2100,
                mother_hp = 180, infected_hp = 150, damage_per_point = 15 },
            bags = new[] { new { primary = "awp", secondary = "deagle", melee = "dagger" } }
        };
        using var srv = StartServer(cfg, "biohazard");
        try
        {
            using var a = HandshakeAndSpawn(TcpPort, UdpPort, 440001, playerId: 1);
            using var b = HandshakeAndSpawn(TcpPort, UdpPort, 440002, playerId: 2);
            Assert(a.Room!.RaceType == 6 && a.Room.SectionTime == 65000 && a.Room.ReLiveTime == 1700
                && a.Init3!.PlayerList.Contains("doun_master") && b.Init3!.WeaponList.Contains("doun"),
                "Biohazard advertises the configured rule and preloads both native variant roles and claws");
            Assert(a.LatestSnapshot!.Players.All(p => p.Team == 2 && p.Career == "police"),
                "Biohazard starts with both wire players on the human team");
            for (int i = 0; i < 18; i++)
            {
                var p = b.LatestSnapshot!.Players.Single(p => p.Id == 2);
                b.SendUserCmd(4, 0, Btn.Forward, 1, 1, p.ViewYaw, 0);
                Thread.Sleep(33);
            }
            WaitUntil(() => a.LatestSnapshot!.Players.Count(p => p.Career == "doun_master") == 1,
                17000, "Authoritative mother conversion after incubation");
            int motherId = a.LatestSnapshot!.Players.Single(p => p.Career == "doun_master").Id;
            var mother = motherId == 1 ? a : b;
            var human = motherId == 1 ? b : a;
            int humanId = 3 - motherId;
            WaitUntil(() => mother.LatestSnapshot!.Header.BagList.Bags[0].MeleeWeapon?.WeaponName == "doun_master"
                && mother.LatestSnapshot!.Header.BagList.Bags[0].FirstWeapon == null
                && a.BioMessages.Any(m => m.Type == BioMessageType.DOUNCHANGED)
                && b.BioMessages.Any(m => m.Type == BioMessageType.DOUNCHANGED),
                2000, "Method 25 and private bag describe the same mother conversion");
            var phases = Stopwatch.StartNew();
            var start = human.LatestSnapshot!.Players.Single(p => p.Id == humanId);
            float offset = 0, lx = start.X, ly = start.Y;
            double until = 0, last = 0;
            while (!human.BioMessages.Any(m => m.Type == BioMessageType.KILLBIO) && phases.Elapsed.TotalSeconds < 11)
            {
                SteerAndShootAtClosestEnemy(human, 1, 0, ref offset, ref until, ref lx, ref ly, ref last, phases,
                    targetPlayerId: motherId);
                Thread.Sleep(34);
            }
            Assert(human.BioMessages.Any(m => m.Type == BioMessageType.KILLBIO) && human.BioGrowth.Contains(1)
                && human.BioDamage.Count > 0 && mother.BioDamage.IsEmpty,
                "Gun kills allow resurrection and send Methods 23/25 with private Method 26 damage score");
            WaitUntil(() => mother.BioMessages.Any(m => m.Type == BioMessageType.RESURRECTION)
                && mother.LatestSnapshot!.Players.Any(p => p.Id == motherId && !p.IsDead && p.Career == "doun_master"),
                3300, "Mother returns as the same entity after a gun kill");

            start = mother.LatestSnapshot!.Players.Single(p => p.Id == motherId);
            lx = start.X; ly = start.Y; offset = 0; until = 0; last = 0; phases.Restart();
            while (!a.BioMessages.Any(m => m.Type == BioMessageType.SUCCESSFULINFECTION) && phases.Elapsed.TotalSeconds < 25)
            {
                SteerAndShootAtClosestEnemy(mother, 3, 0, ref offset, ref until, ref lx, ref ly, ref last, phases,
                    targetPlayerId: humanId);
                Thread.Sleep(34);
            }
            var latest = mother.LatestSnapshot!;
            string trace = string.Join(", ", latest.Players.Select(p => $"{p.Id}:{p.Career}/{p.CurrentWeaponName} at {p.X:F0},{p.Y:F0},{p.Z:F0} yaw {p.ViewYaw:F0} hp {p.Hp}"));
            Assert(a.BioMessages.Any(m => m.Type == BioMessageType.SUCCESSFULINFECTION),
                $"Mother landed a claw hit ({trace})");
            WaitUntil(() => human.LatestSnapshot!.Players.Any(p => p.Id == humanId && p.Career == "doun" && p.Team == 1 && p.Hp == 150)
                && b.BioMessages.Any(m => m.Type == BioMessageType.SUCCESSFULINFECTION),
                2000, "Melee contact converts the remaining human without replacing their identity");
            WaitUntil(() => a.TeamScores.Any(s => s.Team1Score == 1) && a.ClearSectionCount > 0
                && a.LatestSnapshot!.Players.All(p => p.Team == 2 && p.Career == "police"),
                4200, "Full infection awards the round and restores the human roster");
            Console.WriteLine("[PASS] biohazard: real two-session incubation, growth, score, resurrection, infection and section reset");
        }
        finally { KillSafe(srv); }
    }

    private static void TestDirectJoin()
    {
        const string host = "127.0.0.2";
        const long roomId = 271004;
        const long firstId = 1000200072529;
        var config = new
        {
            map = "12", mode = "team_ai", room_id = roomId, max_human_players = 2,
            ally_bot_count = 1, enemy_bot_count = 1,
            lobby_players = new Dictionary<long, object>
            {
                [firstId] = new { name = "Lobby Host", team = 2 },
                [firstId + 1] = new { name = "糖心大掌门", team = 1 }
            }
        };
        var firstBoot = ReadBootConfig(firstId, roomId, host);
        var secondBoot = ReadBootConfig(firstId + 1, roomId, host);
        Assert(ReadBootConfig(firstId, roomId).BattleServerIp == "127.0.0.1"
            && ReadBootConfig(firstId, roomId, "localhost").BattleServerIp == "127.0.0.1"
            && firstBoot.BattleServerIp == host && firstBoot.BattleServerTcpPort == TcpPort
            && firstBoot.BattleServerUdpPort == UdpPort && firstBoot.RoomId == roomId
            && firstBoot.UserId == firstId && firstBoot.CharId == firstId
            && firstBoot.ResourceBase == "http://127.0.0.1:28081/s3/",
            "Boot config resolves battle IPv4 and retains the local asset origin");

        using var server = StartServer(config, "direct_join", IPAddress.Parse(host));
        try
        {
            using (var wrongRoom = new BattleWireClient(host, TcpPort, UdpPort))
            {
                wrongRoom.SendTcp(2, new LoginData { RoomId = roomId + 1, UserId = firstId, Sign = "test", Timestamp = "1" });
                WaitUntil(() => wrongRoom.CallBackLogin is { Res: false }, 3000, "Wrong room refused");
                Assert(wrongRoom.TcpConnId == null, "Wrong-room login does not reserve a battle session");
            }

            using (var unknownSeat = new BattleWireClient(host, TcpPort, UdpPort))
            {
                unknownSeat.SendTcp(2, new LoginData { RoomId = roomId, UserId = firstId + 2, Sign = "test", Timestamp = "1" });
                WaitUntil(() => unknownSeat.CallBackLogin is { Res: false }, 3000, "Unknown lobby seat refused");
                Assert(unknownSeat.TcpConnId == null, "Undeclared lobby account does not reserve a battle session");
            }

            BattleWireClient Join(BootConfigData boot, int id) => HandshakeAndSpawn(
                boot.BattleServerTcpPort, boot.BattleServerUdpPort, boot.CharId, id, boot.RoomId, boot.BattleServerIp);

            using var first = Join(firstBoot, 1);
            using var second = Join(secondBoot, 2);
            int firstCmd = first.SendUserCmd(0, 0, 0, 1, 1, 15f, 0f);
            second.SendUserCmd(0, 0, 0, 1, 1, 35f, 0f);
            int secondCmd = second.SendUserCmd(0, 0, 0, 1, 1, 45f, 0f);
            WaitUntil(() => first.LatestSnapshot?.Header.LastCmd == firstCmd && second.LatestSnapshot?.Header.LastCmd == secondCmd
                && first.LatestSnapshot.Players.Count == 4 && second.LatestSnapshot.Players.Count == 4
                && first.LatestSnapshot.Players.Any(p => p.Id == 1 && p.CharacterId == firstBoot.CharId && p.ViewYaw == 15f
                    && p.Team == 2 && p.PlayerName == "Lobby Host")
                && second.LatestSnapshot.Players.Any(p => p.Id == 2 && p.CharacterId == secondBoot.CharId && p.ViewYaw == 45f
                    && p.Team == 1 && p.PlayerName == "糖心大掌门"),
                4000, "Direct clients receive independent input acknowledgements and a shared roster with Bots");
            Assert(first.TcpConnId!.Id != second.TcpConnId!.Id, "Direct clients use distinct TCP connection IDs");
            Console.WriteLine("[PASS] direct join: native boot addresses, lobby seats and teams, independent TCP/UDP on alternate IPv4");
        }
        finally { KillSafe(server); }
    }

    private static BootConfigData ReadBootConfig(long id, long roomId, string? host = null)
    {
        var info = new ProcessStartInfo(ServerExe)
        {
            WorkingDirectory = Root,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        foreach (string value in new[] { "--print-la", "--tcp-port", TcpPort.ToString(), "--udp-port", UdpPort.ToString(),
            "--room-id", roomId.ToString(), "--char-id", id.ToString() })
            info.ArgumentList.Add(value);
        if (host != null)
        {
            info.ArgumentList.Add("--battle-host");
            info.ArgumentList.Add(host);
        }
        info.Environment["SSJJ_RESOURCE_PORT"] = "28081";
        using var process = Process.Start(info)!;
        var output = process.StandardOutput.ReadToEndAsync();
        var error = process.StandardError.ReadToEndAsync();
        if (!process.WaitForExit(5000))
        {
            KillSafe(process);
            throw new Exception("Boot config process timed out");
        }
        Assert(process.ExitCode == 0, $"Boot config generation succeeded: {error.GetAwaiter().GetResult()}");

        // The original Base62Utility escapes sextets 61–63 with the '9' prefix.
        const string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        string token = output.GetAwaiter().GetResult().Trim();
        using var bytes = new MemoryStream();
        int accumulator = 0, bits = 0;
        for (int i = 0; i < token.Length; i++)
        {
            int digit = token[i] == '9' ? 61 + (token[++i] - 'A') : alphabet.IndexOf(token[i]);
            accumulator = (accumulator << 6) | digit;
            bits += 6;
            if (bits < 8) continue;
            bits -= 8;
            bytes.WriteByte((byte)(accumulator >> bits));
        }
        return SSJJ.Server.Network.TcpBattleGateway.DeserializeProto<BootConfigData>(bytes.ToArray())
            ?? throw new Exception("Missing decoded BootConfigData");
    }

    private static void TestDualTransport()
    {
        var config = new SSJJ.Server.Config.ServerConfig { Map = "12", RaceType = 2003, PlayerTeam = 1 };
        config.EnsureDefaults();
        var tables = new SSJJ.Server.Config.GameTables();
        var registry = new SSJJ.Server.Network.ClientSessionRegistry(2);
        var tcp = new SSJJ.Server.Network.TcpBattleGateway(config, TcpPort, IPAddress.Loopback, tables, sessions: registry);
        var udp = new SSJJ.Server.Network.UdpSyncGateway(registry, UdpPort, IPAddress.Loopback);
        tcp.Start();
        try
        {
            udp.Start();
            using var a = new BattleWireClient("127.0.0.1", TcpPort, UdpPort);
            using var b = new BattleWireClient("127.0.0.1", TcpPort, UdpPort);
            void Login(BattleWireClient client, long cid)
            {
                client.SendTcp(2, new LoginData { RoomId = config.RoomId, UserId = cid, Sign = "test", Timestamp = "1" });
                WaitUntil(() => client.TcpConnId != null && client.Init3 != null, 2000, "Negotiated TCP session");
                client.SendTcp(3);
                WaitUntil(() => client.Init232 != null, 2000, "Model loading acknowledged");
                client.SendP2PProbe();
                WaitUntil(() => client.P2PAckReceived, 2000, "Per-session UDP probe reply");
            }
            Login(a, 111001L);
            Login(b, 111002L);
            Assert(a.TcpConnId!.Id != b.TcpConnId!.Id && a.Init3!.Team != b.Init3!.Team,
                "Sessions receive different UDP connection IDs and teams");
            var sa = registry.Snapshot().Single(s => s.ConnectionId == a.TcpConnId.Id);
            var sb = registry.Snapshot().Single(s => s.ConnectionId == b.TcpConnId.Id);
            Assert(sa.CharacterId == 111001L && sb.CharacterId == 111002L
                && sa.PlayerId != sb.PlayerId && !Equals(sa.UdpEndPoint, sb.UdpEndPoint),
                "TCP login identities and UDP endpoints are stored independently");

            a.SendUserCmd(4, 0, Btn.Forward, 1, 1, 10, 0);
            a.SendUserCmd(4, 0, Btn.Forward, 1, 1, 15, 0);
            b.SendUserCmd(0, 4, Btn.Right, 2, 2, 70, 0);
            var aCommands = new List<SSJJ.Server.Network.DecodedUserCmd>();
            var bCommands = new List<SSJJ.Server.Network.DecodedUserCmd>();
            WaitUntil(() =>
            {
                while (sa.TryDequeueCommand(out var cmdA)) aCommands.Add(cmdA);
                while (sb.TryDequeueCommand(out var cmdB)) bCommands.Add(cmdB);
                return aCommands.Count >= 2 && bCommands.Count >= 1;
            }, 2000, "Both sessions receive their UDP input");
            Assert(aCommands.Select(c => c.Yaw).SequenceEqual(new[] { 10f, 15f })
                && bCommands.Select(c => c.Yaw).SequenceEqual(new[] { 70f }),
                "Commands don't cross sessions even with overlapping command sequence numbers");

            var players = new[]
            {
                new SSJJ.Server.Snapshot.PlayerBasicInfo { Id = sa.PlayerId, CharacterId = sa.CharacterId, Team = sa.Team, CurrentClip = 7 },
                new SSJJ.Server.Snapshot.PlayerBasicInfo { Id = sb.PlayerId, CharacterId = sb.CharacterId, Team = sb.Team, CurrentClip = 19 },
                new SSJJ.Server.Snapshot.PlayerBasicInfo { Id = 200, Team = 2, IsBot = true }
            };
            void Send(SSJJ.Server.Network.ClientSession session, int ack)
            {
                var bytes = SSJJ.Server.Snapshot.SV_Snapshot.SerializeSnapshot(1, 100, ack, config, tables, players,
                    selfPlayerId: session.PlayerId);
                Assert(udp.SendSnapshot(session, bytes), "Client-specific snapshot sent");
            }
            Send(sa, aCommands[^1].Seq);
            Send(sb, bCommands[^1].Seq);
            WaitUntil(() => a.LatestSnapshot != null && b.LatestSnapshot != null, 2000, "Both snapshots received");
            Assert(a.LatestSnapshot!.Header.Self == sa.PlayerId && b.LatestSnapshot!.Header.Self == sb.PlayerId
                && a.LatestSnapshot.Header.LastCmd == 2 && b.LatestSnapshot.Header.LastCmd == 1
                && a.LatestSnapshot.Header.BagList.Bags[0].FirstWeapon.Clip == 7
                && b.LatestSnapshot.Header.BagList.Bags[0].FirstWeapon.Clip == 19
                && a.LatestSnapshot.Players.Count == 3 && b.LatestSnapshot.Players.Count == 3,
                "Each client receives its own self ID, acknowledgement and inventory with a shared roster");
            a.Dispose();
            WaitUntil(() => registry.Snapshot().Length == 1, 2000, "Disconnected TCP session removed");
            Assert(ReferenceEquals(registry.Snapshot().Single(), sb), "Other TCP and UDP session survives disconnect");
            Console.WriteLine("[PASS] dual transport fixture: TCP identities, UDP command and snapshot isolation");
        }
        finally
        {
            udp.Stop();
            tcp.Stop();
        }
    }

    private static void TestMultiplayerRoom()
    {
        var cfg = new
        {
            map = "12",
            race_type = 2003,
            room_id = 1001,
            max_human_players = 2,
            ally_bot_count = 0,
            enemy_bot_count = 1,
            god_mode = true
        };
        using var server = StartServer(cfg, "multiplayer");
        try
        {
            using var left = HandshakeAndSpawn(TcpPort, UdpPort, userId: 111001, playerId: 1);
            using var right = HandshakeAndSpawn(TcpPort, UdpPort, userId: 111002, playerId: 2);

            static bool HasLogin(BattleWireClient client, int id, long characterId)
            {
                lock (client.PlayerLogins)
                    return client.PlayerLogins.Any(player => player.Id == id && player.CharacterId == characterId && !player.IsBot);
            }

            static bool HasRoster(DecodedSnapshot snapshot) =>
                snapshot.Players.Count == 3 && snapshot.Players.Any(player => player.Id > 16)
                && snapshot.Players.Any(player => player.Id == 1) && snapshot.Players.Any(player => player.Id == 2);

            static bool SawPlayerKill(BattleWireClient client)
            {
                lock (client.Kills)
                    return client.Kills.Any(kill => kill.KillPlayerId == 1 && kill.BeKillPlayerId == 2);
            }

            WaitUntil(() => HasLogin(left, 2, 111002) && HasLogin(right, 1, 111001), 2000,
                "Both live clients receive the other player's Method 9 roster entry");
            WaitUntil(() => HasRoster(left.LatestSnapshot!) && HasRoster(right.LatestSnapshot!), 2000,
                "Both live snapshots contain the two players and the Bot");
            Assert(left.TcpConnId!.Id != right.TcpConnId!.Id && left.Init3!.Team != right.Init3!.Team,
                "The live server assigns distinct connections and balances the teams");

            var leftStart = left.LatestSnapshot!.Players.Single(player => player.Id == 1);
            var rightStart = right.LatestSnapshot!.Players.Single(player => player.Id == 2);
            int rightSequence = right.SendUserCmd(0, 0, 0, 1, 2, rightStart.ViewYaw, 0);
            for (int i = 0; i < 24; i++)
            {
                int sequence = left.SendUserCmd(4, 0, Btn.Forward, 1, 1, leftStart.ViewYaw, 0);
                WaitUntil(() => left.LatestSnapshot!.Header.LastCmd == sequence, 1500, "Live movement command acknowledged");
            }
            Assert(right.LatestSnapshot!.Header.LastCmd == rightSequence
                && Dist2(leftStart, left.LatestSnapshot!.Players.Single(player => player.Id == 1)) > 50f
                && Dist2(rightStart, right.LatestSnapshot.Players.Single(player => player.Id == 2)) < 5f,
                "Commands drive only the corresponding live player entity and acknowledgement");

            // Acknowledge a snapshot after it has spent time in flight or waiting at the client.
            int latestRight = right.SendUserCmd(0, 0, 0, 1, 2, rightStart.ViewYaw, 0);
            WaitUntil(() => right.LatestSnapshot!.Header.LastCmd == latestRight, 1500, "Second player acknowledged independently");
            WaitUntil(() => right.LatestPings?.List is { } pings
                && pings.Any(ping => ping.Id == 1 && ping.Ping > 0)
                && pings.Any(ping => ping.Id == 2 && ping.Ping > 0), 4000, "Method 24 measures both live sessions");

            int priorObserverUpdates = right.ObserverInfos.Count;
            var leftPosition = left.LatestSnapshot!.Players.Single(player => player.Id == 1);
            float steerOffset = 0, lastX = leftPosition.X, lastY = leftPosition.Y;
            double steerUntil = 0, lastCheck = 0;
            var duel = Stopwatch.StartNew();
            while (!SawPlayerKill(left) && duel.Elapsed.TotalSeconds < 28)
            {
                SteerAndShootAtClosestEnemy(left, 1, 0, ref steerOffset, ref steerUntil, ref lastX, ref lastY, ref lastCheck, duel, targetPlayerId: 2);
                Thread.Sleep(33);
            }
            Assert(SawPlayerKill(left), "The shooter receives Method 6 for killing the second player");
            WaitUntil(() => SawPlayerKill(right), 2000, "The victim receives the same Method 6");
            int victimDeathStart = 0;
            int firstDeathElapsed = -1;
            float deathYaw = 0;
            int deadCommand = 0;
            WaitUntil(() =>
            {
                var snap = right.LatestSnapshot!;
                var victim = snap.Players.Single(player => player.Id == 2);
                if (!HasNativeDeathPlayback(snap, victim) || victim.LegsAnimationTimer == 0) return false;
                Assert(snap.Header.Observer == 0 && right.ObserverInfos.Count == priorObserverUpdates,
                    "The native death camera keeps the victim as camera owner during the fall");
                if (snap.Header.BagList.Bags[victim.CurrentBagId - 1].FirstWeapon != null || victim.CurrentWeapon == 1
                    || !snap.SceneWeapons.Any(weapon => weapon.WeaponName == "m4a1")) return false;
                if (firstDeathElapsed < 0)
                {
                    victimDeathStart = victim.TorsoAnimStartTime;
                    firstDeathElapsed = victim.LegsSpeedAnimTime;
                    deathYaw = victim.ViewYaw;
                    deadCommand = right.SendUserCmd(0, 0, 0, 1, 2, deathYaw > 0 ? deathYaw - 90 : deathYaw + 90, 15);
                    return false;
                }
                return victim.TorsoAnimStartTime == victimDeathStart && victim.LegsSpeedAnimTime > firstDeathElapsed
                    && snap.Header.LastCmd >= deadCommand && victim.ViewYaw == deathYaw;
            }, 1600, "Human death snapshot plays synchronized native fall across multiple frames");
            WaitUntil(() =>
            {
                var snap = right.LatestSnapshot!;
                var victim = snap.Players.Single(player => player.Id == 2);
                int target = snap.Header.Observer;
                var observed = snap.Players.SingleOrDefault(player => player.Id == target && player.IsBot);
                if (observed == null) return false;
                var bag = snap.Header.BagList.Bags.SingleOrDefault(item => item.BagId == observed.CurrentBagId);
                return victim.IsDead && victim.TorsoAnimStartTime == victimDeathStart && victim.LegsAnimationTimer == 0
                    && bag?.FirstWeapon?.WeaponName == observed.CurrentWeaponName
                    && right.ObserverInfos.Skip(priorObserverUpdates).Any(info => info.Id == target);
            }, 2500, "After the fall, Method 30 and the weapon bag refer to the same Bot");
            Assert(left.HitPlayerCount > 0 && right.HitPlayerCount == 0 && left.LatestSnapshot!.Header.Observer == 0,
                "Hit confirmation and active observer state stay with their intended clients");

            left.Dispose();
            WaitUntil(() => right.PlayerLogouts.Any(logout => logout.Id == 1 && !logout.IsBot), 2000,
                "The remaining player receives Method 10 when the host player disconnects");
            WaitUntil(() => right.LatestSnapshot!.Players.All(player => player.Id != 1), 2000,
                "The disconnected player leaves subsequent live snapshots");

            using var replacement = HandshakeAndSpawn(TcpPort, UdpPort, userId: 111003, playerId: 1);
            WaitUntil(() => HasLogin(right, 1, 111003) && HasRoster(right.LatestSnapshot!), 2000,
                "The vacated slot can join with a new identity while the room stays open");
            Assert(replacement.TcpConnId!.Id != left.TcpConnId.Id && replacement.LatestSnapshot!.Header.LastCmd == 0,
                "A replacement session starts with a new connection ID and clean command state");
            Console.WriteLine("[PASS] multiplayer room: live join, isolated input and latency, kill and Bot observer messages, disconnect, and slot reuse");
        }
        finally { KillSafe(server); }
    }

    private static void TestMultiplayerDamageReport()
    {
        // The server uses its usual software movement when there is no map asset.
        // Use an empty arena so another actor cannot end the duel before either shot.
        var cfg = new
        {
            map = "999999989", race_type = 3, max_human_players = 2,
            ally_bot_count = 0, enemy_bot_count = 0, player_name = "Wire Duel"
        };
        using var server = StartServer(cfg, "multiplayer_damage");
        try
        {
            using var attacker = HandshakeAndSpawn(TcpPort, UdpPort, userId: 211001, playerId: 1);
            using var victim = HandshakeAndSpawn(TcpPort, UdpPort, userId: 211002, playerId: 2);
            static (PlayerEntityData From, PlayerEntityData To) ReadPlayers(BattleWireClient client)
            {
                var snap = client.LatestSnapshot!;
                return (snap.Players.Single(p => p.Id == snap.Header.Self),
                    snap.Players.Single(p => p.Id != snap.Header.Self));
            }

            static int Aim(BattleWireClient client, byte slot, float hitHeight, bool move, bool fire)
            {
                var (from, to) = ReadPlayers(client);
                float d = Dist2(from, to);
                float yaw = MathF.Atan2(to.Y - from.Y, to.X - from.X) * 180 / MathF.PI;
                float pitch = MathF.Atan2(from.Z + from.ViewHeight - 4 - to.Z - hitHeight, d) * 180 / MathF.PI;
                float length = MathF.Sqrt(from.PunchPitch * from.PunchPitch + from.PunchYaw * from.PunchYaw);
                float decay = length > 0 && from.DecayTime <= 0
                    ? MathF.Max(0, length - (10 + 0.5f * length) * 0.033f) / length : 1;
                return client.SendUserCmd(move ? (sbyte)4 : (sbyte)0, 0,
                    (move ? Btn.Forward : 0) | (fire ? Btn.Attack : 0), 1, slot,
                    yaw - 2 * decay * from.PunchYaw, pitch + 2 * decay * from.PunchPitch);
            }

            WaitUntil(() => attacker.LatestSnapshot!.Players.Count == 2, 2000, "Both duel participants are present");
            var advance = Stopwatch.StartNew();
            while (advance.Elapsed.TotalSeconds < 12)
            {
                var (from, to) = ReadPlayers(attacker);
                if (Dist2(from, to) < 460) break;
                Aim(attacker, 1, 106, move: true, fire: false);
                Aim(victim, 2, 106, move: true, fire: false);
                Thread.Sleep(33);
            }
            int stopA = Aim(attacker, 1, 106, move: false, fire: false);
            int stopB = Aim(victim, 2, 106, move: false, fire: false);
            WaitUntil(() => attacker.LatestSnapshot!.Header.LastCmd >= stopA && victim.LatestSnapshot!.Header.LastCmd >= stopB,
                2000, "Both clients acknowledge independent aim commands");
            var (left, right) = ReadPlayers(attacker);
            Assert(Dist2(left, right) < 650, "Both clients enter the test engagement range");
            string attackerName = left.PlayerName;

            // Wait for the sidearm's snapshot timer so this sends one shot, not a burst.
            var poke = Stopwatch.StartNew();
            while (victim.HitPlayerCount == 0 && poke.Elapsed.TotalSeconds < 4)
            {
                Aim(victim, 2, 106, move: false, fire: true);
                Thread.Sleep(65);
                Aim(victim, 2, 106, move: false, fire: false);
                Thread.Sleep(220);
            }
            Assert(victim.HitPlayerCount > 0 && attacker.HitPlayerCount == 0 && !ReadPlayers(attacker).From.IsDead
                && attacker.DamageCounts.IsEmpty && victim.DamageCounts.IsEmpty,
                "The first shot confirms only on B and contributes to B's current-life damage report");
            int victimHits = victim.HitPlayerCount;

            bool OwnKill(BattleWireClient client)
            {
                lock (client.Kills)
                    return client.Kills.Any(kill => kill.KillPlayerId == 1 && kill.BeKillPlayerId == 2);
            }

            var duel = Stopwatch.StartNew();
            while (!OwnKill(attacker) && duel.Elapsed.TotalSeconds < 6)
            {
                Aim(attacker, 1, 106, move: false, fire: true);
                Thread.Sleep(35);
            }
            WaitUntil(() => OwnKill(attacker) && OwnKill(victim), 2000, "Method 6 names the same attacker and victim on both connections");
            WaitUntil(() => victim.DamageCounts.Any(packet => packet.List.Any(entry =>
                    entry.PlayerName == attackerName && entry.Damage > 0 && !entry.IsDead)),
                2000, "Method 20 returns the victim's positive damage against the living attacker");
            Assert(attacker.HitPlayerCount > 0 && victim.HitPlayerCount == victimHits && attacker.DamageCounts.IsEmpty,
                "Method 131 goes only to the firing player; Method 20 goes only to the dead player");
            Console.WriteLine("[PASS] multiplayer damage: private Method 131, shared Method 6, and victim-only Method 20");
        }
        finally { KillSafe(server); }
    }

    private static void TestWeaponDropAndPickup()
    {
        // An assetless test room exercises the same battle loop with software movement and no map obstacles.
        var config = new
        {
            map = "999999989",
            race_type = 3,
            max_human_players = 2,
            ally_bot_count = 0,
            enemy_bot_count = 0,
            bags = new[] { new { primary = "m4a1", primary_skin = "skin_m4_legend_poison" } }
        };
        using var server = StartServer(config, "weapon_drop");
        try
        {
            using var sender = HandshakeAndSpawn(TcpPort, UdpPort, userId: 111001, playerId: 1);
            using var recipient = HandshakeAndSpawn(TcpPort, UdpPort, userId: 111002, playerId: 2);
            static BaseWeaponData? Primary(BattleWireClient client) => client.LatestSnapshot!.Header.BagList.Bags[0].FirstWeapon;
            static void WaitForCommand(BattleWireClient client, int sequence) =>
                WaitUntil(() => client.LatestSnapshot!.Header.LastCmd >= sequence, 1500, "Weapon command acknowledged");

            // Spend rounds away from both players so the inventory test does not depend on a combat outcome.
            var initialPrimary = Primary(sender)!;
            int fireSequence = 0;
            for (int i = 0; i < 16; i++)
            {
                fireSequence = sender.SendUserCmd(0, 0, Btn.Attack, 1, 1, 90, 80);
                Thread.Sleep(33);
            }
            WaitForCommand(sender, fireSequence);
            WaitUntil(() => Primary(sender)?.Clip < initialPrimary.Clip, 1500, "Rifle was fired before dropping it");
            int spentClip = Primary(sender)!.Clip;
            int reserve = Primary(sender)!.CarryClip;
            WaitForCommand(sender, sender.SendUserCmd(0, 0, 0, 1, 2, 90, 0));
            Assert(Primary(sender)?.Clip == spentClip, "Unequipped weapon still reports its remaining ammo");

            WaitForCommand(sender, sender.SendUserCmd(0, 0, 0, 1, 1, 90, 0));
            Assert(Primary(sender)?.Clip == spentClip, "Switching back does not refill the magazine");
            WaitForCommand(recipient, recipient.SendUserCmd(0, 0, Btn.ThrowWeapon, 1, 2, -90, 0));
            WaitUntil(() => Primary(recipient) == null && recipient.LatestSnapshot!.SceneWeapons.Count == 1,
                1500, "Recipient drops their own primary and has room for a pickup");
            int recipientDrop = recipient.LatestSnapshot!.SceneWeapons.Single().Id;

            WaitForCommand(sender, sender.SendUserCmd(0, 0, Btn.ThrowWeapon, 1, 2, 90, 0));
            WaitForCommand(sender, sender.SendUserCmd(0, 0, Btn.ThrowWeapon, 1, 2, 90, 0));
            WaitUntil(() => Primary(sender) == null && sender.LatestSnapshot!.SceneWeapons.Count == 2,
                1500, "Holding G publishes a single ground weapon and leaves the fallback slot in use");
            var transferable = sender.LatestSnapshot!.SceneWeapons.Single(weapon => weapon.Id != recipientDrop);
            Assert(transferable.WeaponSkinName == "skin_m4_legend_poison"
                && sender.LatestSnapshot.Header.BagList.Bags[0].SecondaryWeapon != null,
                "Ground snapshot retains the weapon skin and holding G leaves the sidearm equipped");

            var walk = Stopwatch.StartNew();
            while (Primary(recipient) == null && walk.Elapsed.TotalSeconds < 20)
            {
                var player = recipient.LatestSnapshot!.Players.Single(player => player.Id == 2);
                float yaw = MathF.Atan2(transferable.Y - player.Y, transferable.X - player.X) * 180f / MathF.PI;
                recipient.SendUserCmd(4, 0, Btn.Forward, 1, 2, yaw, 0);
                Thread.Sleep(33);
            }
            Assert(Primary(recipient) is { } restored && restored.Id == transferable.Id
                && restored.Clip == spentClip && restored.CarryClip == reserve
                && restored.WeaponSkinName == transferable.WeaponSkinName, "Picked-up weapon preserves magazine, reserve and skin");
            WaitUntil(() => sender.LatestSnapshot!.SceneWeapons.All(weapon => weapon.Id != transferable.Id)
                && recipient.LatestSnapshot!.SceneWeapons.All(weapon => weapon.Id != transferable.Id),
                1500, "Picked-up weapon leaves both clients' scene snapshots");
            Assert(Primary(sender) == null, "The former owner still has an empty primary slot");
            Console.WriteLine("[PASS] weapon drop: key edge, scene entity, per-player bag and ammo transfer");
        }
        finally { KillSafe(server); }
    }

    private static void TestLoadoutAndInspect()
    {
        var config = new
        {
            map = "999999989",
            race_type = 3,
            max_human_players = 2,
            ally_bot_count = 0,
            enemy_bot_count = 0,
            bags = new[] { new { primary = "m4a1" }, new { primary = "m4a1_pro" } }
        };
        using var server = StartServer(config, "loadout_inspect");
        try
        {
            using var first = HandshakeAndSpawn(TcpPort, UdpPort, userId: 241001, playerId: 1);
            using var second = HandshakeAndSpawn(TcpPort, UdpPort, userId: 241002, playerId: 2);
            PlayerEntityData Player(BattleWireClient client, int id) => client.LatestSnapshot!.Players.Single(player => player.Id == id);
            void Send(BattleWireClient client, int buttons = 0, byte bag = 0, byte slot = 0, sbyte movement = 0)
            {
                int sequence = client.SendUserCmd(movement, 0, buttons, bag, slot, 90, 0);
                WaitUntil(() => client.LatestSnapshot!.Header.LastCmd >= sequence, 1500, "Loadout user command acknowledged");
            }

            Assert(Player(first, 1).CanChangeBag && Player(second, 2).CanChangeBag, "Both players begin with loadout selection open");
            Send(first, bag: 2);
            Assert(Player(first, 1) is { CurrentBagId: 2, CurrentWeaponName: "m4a1_pro" }
                && Player(second, 2).CurrentBagId == 1, "Bag-only command selects the new primary for its own player");
            for (int i = 0; i < 40 && Player(first, 1).ViewAnim != 13; i++) Send(first);
            Assert(Player(first, 1).ViewAnim == 13, "The rifle raises before inspection");

            int clip = first.LatestSnapshot!.Header.BagList.Bags[1].FirstWeapon.Clip;
            Send(first, buttons: Btn.Inspect);
            int duration = Player(first, 1).ViewAnimationTimer;
            Assert(Player(first, 1) is { ViewAnim: 44, LeftViewAnim: 13 } && duration == 4166,
                "Inspect uses the decoded asset duration on the right-hand channel");
            Send(first, buttons: Btn.Inspect);
            Assert(Player(first, 1).ViewAnimationTimer < duration && first.LatestSnapshot!.Header.BagList.Bags[1].FirstWeapon.Clip == clip,
                "Holding inspect advances the existing animation without spending ammo");
            Send(first, buttons: Btn.Attack);
            Assert(Player(first, 1).ViewAnim == 15 && first.LatestSnapshot!.Header.BagList.Bags[1].FirstWeapon.Clip == clip - 1,
                "Firing interrupts inspection");

            for (int i = 0; i < 30 && Player(first, 1).CanChangeBag; i++)
                Send(first, buttons: Btn.Forward, movement: 4);
            Assert(!Player(first, 1).CanChangeBag && Player(second, 2).CanChangeBag,
                "Leaving the spawn area closes loadout selection for only that player");
            Send(first, bag: 1, slot: 2);
            Assert(Player(first, 1) is { CurrentBagId: 2, CurrentWeapon: 2 },
                "Outside the spawn area the bag request is ignored and the current bag's sidearm remains selectable");
            Send(second, bag: 2);
            Assert(Player(second, 2).CurrentBagId == 2 && !Player(first, 1).CanChangeBag,
                "The player still in spawn can switch independently");
            Console.WriteLine("[PASS] opening loadout and inspect: per-player spawn gate, bag-only input, inspect timing and fire interruption");
        }
        finally { KillSafe(server); }
    }

    private static void TestGrenadeFlight()
    {
        var weapons = new[] { (Name: "grenade", Effect: 4), (Name: "flashgrenade", Effect: 8), (Name: "smoke", Effect: 1278) };
        var config = new
        {
            map = "999999989",
            race_type = 3,
            max_human_players = 2,
            ally_bot_count = 0,
            enemy_bot_count = 0,
            god_mode = true,
            bags = weapons.Select(weapon => new { throwable = weapon.Name }).ToArray()
        };
        using var server = StartServer(config, "throwables");
        try
        {
            using var thrower = HandshakeAndSpawn(TcpPort, UdpPort, userId: 231001, playerId: 1);
            using var observer = HandshakeAndSpawn(TcpPort, UdpPort, userId: 231002, playerId: 2);
            for (int i = 0; i < weapons.Length; i++)
            {
                byte bag = (byte)(i + 1);
                var expected = weapons[i];
                SceneWeaponEntityData? FindFlight(BattleWireClient client) =>
                    client.LatestSnapshot!.SceneWeapons.SingleOrDefault(weapon => weapon.WeaponName == expected.Name);

                var launch = Stopwatch.StartNew();
                while (FindFlight(thrower) == null && launch.Elapsed.TotalSeconds < 3)
                {
                    thrower.SendUserCmd(0, 0, Btn.Attack, bag, 4, 90f, 0f);
                    Thread.Sleep(33);
                }
                var start = FindFlight(thrower);
                Assert(start != null && start.WeaponType == 3, $"Type 6 advertises the flying {expected.Name}");
                WaitUntil(() => FindFlight(observer) is { } observed && observed.Id == start!.Id
                    && Math.Abs(observed.Y - start.Y) > 20f,
                    1500, $"A second client receives movement for the same {expected.Name} entity");
                Assert(thrower.LatestSnapshot!.Header.BagList.Bags[i].BombWeapons0.Clip == 0,
                    $"{expected.Name} consumes its configured clip");
                Assert(thrower.LatestSnapshot!.Players.Single(player => player.Id == 1).CurrentWeaponIndex == 0,
                    $"{expected.Name} addresses BombWeapons0 in the client's weapon snapshot");

                WaitUntil(() => thrower.GrenadeExplosions.Any(e => e.WeaponName == expected.Name)
                    && observer.GrenadeExplosions.Any(e => e.WeaponName == expected.Name),
                    4200, $"Both clients receive the {expected.Name} detonation");
                var first = thrower.GrenadeExplosions.Single(e => e.WeaponName == expected.Name);
                var second = observer.GrenadeExplosions.Single(e => e.WeaponName == expected.Name);
                Assert(first.BaseEventEntity.Id == second.BaseEventEntity.Id && first.BaseEventEntity.OwnerId == 1
                    && first.BaseEventEntity.EventId == expected.Effect && first.CollisionPoint != null
                    && first.CollisionNormal != null && first.TimeRate == 1f
                    && (!expected.Name.Equals("flashgrenade") || !first.HaveBulletHole),
                    $"{expected.Name} detonation preserves effect, position, ownership and event ID");
                WaitUntil(() => FindFlight(thrower) == null && FindFlight(observer) == null,
                    1500, $"{expected.Name} flight entity disappears after detonation");
            }
            var smoke = observer.LatestSnapshot!.SceneBuffs.SingleOrDefault(zone => zone.BufName == "smoke_area");
            Assert(smoke != null && smoke.Scale.X == 1f && smoke.Scale.Y == 1f && smoke.Scale.Z == 1f,
                "The smoke outcome publishes a persistent Type 9 scene effect");
            WaitUntil(() => thrower.LatestSnapshot!.SceneBuffs.Any(zone => zone.Id == smoke!.Id), 1500,
                "Both clients see the same smoke field");
            Console.WriteLine("[PASS] throwables: flight entities, distinct frag/flash/smoke effects, and shared smoke field");
        }
        finally { KillSafe(server); }
    }

    private static void TestCombatAnnouncements()
    {
        var cfg = new SSJJ.Server.Config.ServerConfig { Map = "2", RaceType = 2, PlayerTeam = 2 };
        cfg.EnsureDefaults();
        var tables = new SSJJ.Server.Config.GameTables();
        var map = new SSJJ.Server.Config.BspMapData { MapId = 2 };
        map.BombSites.Add(new SSJJ.Server.Config.BspBombSite { X = 300, Y = 400, Z = 500 });
        using var physics = new SSJJ.Server.Physics.OfficialPhysicsWorld();
        var mode = new SSJJ.Server.GameModes.ModeCoordinator(cfg, tables, map, physics);
        var gateway = new SSJJ.Server.Network.TcpBattleGateway(cfg, TcpPort, IPAddress.Loopback, tables);
        using var spawned = new ManualResetEventSlim();
        gateway.OnPlayerSpawned += _ => spawned.Set();
        gateway.Start();
        try
        {
            using var cli = new BattleWireClient("127.0.0.1", TcpPort, UdpPort);
            cli.SendTcp(2);
            WaitUntil(() => cli.Init3 != null, 5000, "Defuse fixture handshake");
            cli.SendTcp(3);
            Assert(spawned.Wait(5000), "Defuse fixture ready for broadcasts");

            var planter = new SSJJ.Server.Snapshot.PlayerBasicInfo
            {
                Id = 2, Team = 1, PlayerName = "Planter", PosX = 300, PosY = 400, PosZ = 500,
                HasC4 = true, CurrentWeapon = 5
            };
            var defuser = new SSJJ.Server.Snapshot.PlayerBasicInfo
            {
                Id = 1, Team = 2, PlayerName = "Defuser", PosX = 500, PosY = 400, PosZ = 500
            };
            var plant = new SSJJ.Server.Network.DecodedUserCmd { Buttons = Btn.Attack };
            var defuse = new SSJJ.Server.Network.DecodedUserCmd { Buttons = Btn.Demolition };
            for (int i = 0; i < 120 && !mode.C4Planted; i++)
                mode.HandlePlayerExplodeCommand(planter, plant, 0, 0.03125f, gateway);
            Assert(mode.C4Planted, "Fixture planted C4 through normal command handler");
            WaitUntil(() => cli.ProgressEvents.Count >= 2, 2000, "Method 15 C4 plant start + completion progress");
            var plantProgs = cli.ProgressEvents.ToArray();
            Assert(plantProgs.Any(p => p.Type == ProgressType.ACTIVE && p.Time == 3000 && p.PlayerName == planter.PlayerName),
                "Method 15 emits ACTIVE plant bar (3000ms) with planter name");
            Assert(plantProgs.Any(p => p.Type == ProgressType.ACTIVE && p.Time == 0),
                "Method 15 clears ACTIVE plant bar (Time=0) on completion");

            for (int i = 0; i < 160; i++)
                mode.HandlePlayerExplodeCommand(defuser, defuse, 0, 0.03125f, gateway);
            Assert(mode.C4Planted, "Out-of-range hold cannot defuse");
            Assert(!cli.ProgressEvents.Any(p => p.Type == ProgressType.DEMOLITION && p.Time > 0),
                "Out-of-range defuse does not emit Method 15 DEMOLITION bar");

            defuser.PosX = planter.PosX;
            for (int i = 0; i < 159; i++)
                mode.HandlePlayerExplodeCommand(defuser, defuse, 0, 0.03125f, gateway);
            Assert(mode.C4Planted, "Defuse still active one command before completion");
            mode.HandlePlayerExplodeCommand(defuser, defuse, 0, 0.03125f, gateway);
            Assert(!mode.C4Planted && mode.Team2Score == 1 && mode.GetSceneDrops().Count == 0,
                "Successful defuse deactivates bomb, clears scene entity, and awards CT round");
            WaitUntil(() => cli.C4Messages.Any(m => m.Type == C4MessageType.DEMOLITIONSUCCESS)
                && cli.TeamScores.Any(s => s.Team2Score == 1)
                && cli.ProgressEvents.Count(p => p.Type == ProgressType.DEMOLITION) >= 2, 2000, "Defuse, Method 15 DEMOLITION, and CT score on TCP wire");
            var defuseProgs = cli.ProgressEvents.Where(p => p.Type == ProgressType.DEMOLITION).ToArray();
            Assert(defuseProgs.Any(p => p.Time == 5000 && p.PlayerName == defuser.PlayerName),
                "Method 15 emits DEMOLITION bar (5000ms) with defuser name");
            Assert(defuseProgs.Any(p => p.Time == 0),
                "Method 15 clears DEMOLITION bar (Time=0) on completion");
            var announcement = cli.C4Messages.Single(m => m.Type == C4MessageType.DEMOLITIONSUCCESS);
            Assert(announcement.PlayerName == defuser.PlayerName
                && announcement.X == planter.PosX && announcement.Y == planter.PosY && announcement.Z == planter.PosZ,
                "Method 16 defuse carries the actor and planted bomb coordinates");
            Console.WriteLine("[PASS] explode command fixture: Method 15 ProgressData + Method 16 DEMOLITIONSUCCESS");

            gateway.BroadcastPlayerLogout(205, "Bot_Leaving", 2, isBot: true);
            gateway.BroadcastPlayerLogout(2, "Human_Leaving", 1, isBot: false, heroWeapon: "m4a1_legend2");
            WaitUntil(() => cli.PlayerLogouts.Count >= 2, 2000, "Method 10 PlayerLogoutData on TCP wire");
            var logouts = cli.PlayerLogouts.ToArray();
            Assert(logouts.Any(l => l.Id == 205 && l.Name == "Bot_Leaving" && l.Team == 2 && l.IsBot),
                "Method 10 preserves bot logout metadata");
            Assert(logouts.Any(l => l.Id == 2 && l.Name == "Human_Leaving" && l.Team == 1 && !l.IsBot && l.HeroWeapon == "m4a1_legend2"),
                "Method 10 preserves human logout metadata and HeroWeapon");
            Console.WriteLine("[PASS] Method 10 PlayerLogoutData wire roundtrip");

            TestAssistAnnouncement(cli, gateway);
        }
        finally { gateway.Stop(); }
    }

    private static void TestAssistAnnouncement(BattleWireClient cli, SSJJ.Server.Network.TcpBattleGateway gateway)
    {
        var local = new SSJJ.Server.Snapshot.PlayerBasicInfo { Id = 1, Team = 2, PlayerName = "Assistant" };
        var killer = new SSJJ.Server.Snapshot.PlayerBasicInfo { Id = 2, Team = 2, PlayerName = "Killer" };
        var victim = new SSJJ.Server.Snapshot.PlayerBasicInfo { Id = 3, Team = 1, PlayerName = "Victim" };
        var players = new[] { local, killer, victim };
        var assists = new SSJJ.Server.QuakeServer.AssistTracker();
        assists.RecordHit(local.Id, victim.Id);
        assists.RecordHit(local.Id, victim.Id);
        assists.RecordHit(killer.Id, victim.Id);
        if (assists.AwardForKill(killer.Id, victim.Id, players, local.Id))
            gateway.NotifyLocalAssist();
        Assert(!assists.AwardForKill(killer.Id, victim.Id, players, local.Id),
            "Settling the same victim a second time does not recredit an assist");

        assists.RecordHit(local.Id, victim.Id);
        Assert(!assists.AwardForKill(victim.Id, victim.Id, players, local.Id)
            && !assists.AwardForKill(killer.Id, victim.Id, players, local.Id),
            "Self-inflicted death consumes contribution without awarding an assist");
        assists.RecordHit(local.Id, victim.Id);
        assists.Clear();
        Assert(!assists.AwardForKill(killer.Id, victim.Id, players, local.Id),
            "Round reset drops unsettled contributions");

        gateway.BroadcastScoreBoard(players);
        WaitUntil(() => cli.Scoreboards.TryPeek(out _), 2000, "Method 8 arrives after Method 28");
        Assert(cli.AssistBodyLengths.ToArray().SequenceEqual(new[] { 0 }),
            "Method 28 is emitted exactly once, with the empty client payload");
        Assert(cli.Scoreboards.TryDequeue(out var scoreboard)
            && scoreboard.List.Single(p => p.Id == local.Id).AssistsNum == 1
            && scoreboard.List.Single(p => p.Id == killer.Id).AssistsNum == 0,
            "Method 8 credits the local assist once and does not credit the killer");
        Console.WriteLine("[PASS] assist fixture: Method 28 empty notice and Method 8 assist total");
    }


    private static void TestScopedMovement()
    {
        var config = new
        {
            map = "12", mode = "team_ai", player_team = 1, ally_bot_count = 0, enemy_bot_count = 0,
            bags = new[] { new { primary = "awp", secondary = "deagle", melee = "dagger", throwable = "grenade" } }
        };
        using var server = StartServer(config, "scoped_movement");
        try
        {
            using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
            PlayerEntityData Self() => cli.LatestSnapshot!.Players.Single(p => p.Id == 1);
            var atSpawn = Self();
            Assert(atSpawn.CurrentWeaponName == "awp" && atSpawn.Fov == 90, "AWP equipped at default FOV");

            // Travel out from the stock spawn, then use the same lane to return while scoped.
            PlayerEntityData MoveAndObserve(sbyte forward, int buttons)
            {
                int seq = cli.SendUserCmd(forward, 0, buttons, 1, 1, atSpawn.ViewYaw, 0f, 16);
                WaitUntil(() => cli.LatestSnapshot!.Header.LastCmd >= seq, 1500, "Movement command acknowledged");
                return Self();
            }

            int unscoped = 0;
            for (int i = 0; i < 44; i++)
                unscoped = Math.Max(unscoped, MoveAndObserve(4, Btn.Forward).Velocity2D);
            float outwardDistance = Dist2(atSpawn, Self());
            Assert(outwardDistance > 100f, $"Unscoped course has room to accelerate ({outwardDistance:F0}cm)");

            Assert(MoveAndObserve(0, Btn.Attack2).Fov == 40, "AWP scope command appears in snapshot");
            for (int i = 0; i < 30 && Self().Velocity2D > 10; i++)
                MoveAndObserve(0, 0);
            Assert(Self().Velocity2D <= 10, "Player settled before the scoped run");

            int scoped = 0;
            for (int i = 0; i < 44; i++)
            {
                var snapshot = MoveAndObserve(-4, Btn.Backward);
                Assert(snapshot.Fov == 40, "AWP stays scoped during the return run");
                scoped = Math.Max(scoped, snapshot.Velocity2D);
            }
            Assert(Math.Abs(unscoped - 446) <= 5 && Math.Abs(scoped - 380) <= 5,
                $"map12 movement uses AWP speed values at FOV 90 and 40 (observed {unscoped}/{scoped}cm/s)");
            Console.WriteLine($"[PASS] map12 AWP movement: unscoped={unscoped}cm/s, scoped={scoped}cm/s");
        }
        finally { KillSafe(server); }
    }

    private static bool HasNativeDeathPlayback(DecodedSnapshot snap, PlayerEntityData player)
    {
        if (!player.IsDead) return false;
        int duration = (player.LegsAnim, player.TorsoAnim) switch
        {
            (11, 19) => 2033,
            (42, 42) or (43, 43) => 933,
            _ => -1,
        };
        int elapsed = snap.Header.ServerTime - player.TorsoAnimStartTime;
        return duration > 0 && elapsed >= 0 && !player.Moving && player.Velocity2D == 0
            && player.LegsSpeedAnimTime == elapsed
            && Math.Abs(player.DeadTimer - elapsed) <= 1
            && player.LegsAnimationTimer == Math.Max(0, duration - elapsed)
            && Math.Abs(player.TorsoAnimationTimer - player.LegsAnimationTimer) <= 1;
    }

    private static void TestTeamAiHitmarkerAndSettlement()
    {
        Console.WriteLine("=== [1/4] Testing team_ai (2003, win_score=2): handshake, skins, move, hitmarker (131), settlement (18/19+3->5) ===");
        var cfg = new
        {
            map = "12",
            mode = "team_ai",
            race_type = 2003,
            win_score = 4,
            god_mode = true,
            tcp_port = TcpPort,
            udp_port = UdpPort,
            ally_bot_count = 3,
            enemy_bot_count = 4,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "skin_m4_legend_poison", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_id = 10000010, throwable_skin = "", throwable2 = "flashgrenade", throwable2_id = 10000020, throwable2_skin = "", throwable3 = "smoke", throwable3_id = 10012020, throwable3_skin = "" }
            }
        };
        using var srv = StartServer(cfg, "team");
        try
        {
            using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
            Assert(cli.Room!.RaceType == 2003, $"Room.RaceType=2003 (got {cli.Room.RaceType})");
            Assert(cli.Room.WinScore == 4, $"Room.WinScore=4 (got {cli.Room.WinScore})");
            Assert(cli.LatestSnapshot!.Header.ControlId == 0 && cli.LatestSnapshot.Header.MainCameraId == 0, "NormalCameraLogic ControlId=0 MainCameraId=0");
            Assert(cli.Init3!.WeaponSkinList.Contains("skin_m4_legend_poison"), "OnGameinitData preloads skin_m4_legend_poison");

            var p1Start = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            float x0 = p1Start.X, y0 = p1Start.Y;
            var bag0Skin = cli.LatestSnapshot.Header.BagList.Bags[0].FirstWeapon.WeaponSkinName;
            Assert(bag0Skin == "skin_m4_legend_poison", $"Snapshot Bag0 Primary Skin preserved (got '{bag0Skin}')");
            var bag0 = cli.LatestSnapshot.Header.BagList.Bags[0];
            Assert(bag0.BombWeapons0?.WeaponName == "grenade" && bag0.BombWeapons0.Id == 10000010
                && bag0.BombWeapons1?.WeaponName == "flashgrenade" && bag0.BombWeapons1.Id == 10000020
                && bag0.BombWeapons2?.WeaponName == "smoke" && bag0.BombWeapons2.Id == 10012020,
                "Lobby grenade, flash and smoke storage IDs populate all three native bomb slots");

            int initialClip = cli.LatestSnapshot.Header.BagList.Bags[0].FirstWeapon.Clip;
            int shotCmd = cli.SendUserCmd(0, 0, Btn.Attack, 1, 1, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= shotCmd, 1500, "Single M4A1 shot acknowledged");
            var shot = cli.LatestSnapshot!;
            var firing = shot.Players.Single(p => p.Id == 1);
            Assert(firing.ViewAnim == 15 && firing.ViewAnimationTimer == 233 && firing.ViewAnimSpeed == 1f && firing.TorsoAnim == 15
                && shot.Header.BagList.Bags[0].FirstWeapon.Clip == initialClip - 1, "Accepted shot sends the native M4A1 clip and state");
            int holdCmd = cli.SendUserCmd(0, 0, Btn.Attack, 1, 1, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= holdCmd, 1500, "Held input acknowledged inside M4A1 cooldown");
            var held = cli.LatestSnapshot!;
            var playing = held.Players.Single(p => p.Id == 1);
            Assert(playing.ViewAnim == 15 && playing.ViewAnimationTimer == 217 && playing.TorsoAnimStartTime == firing.TorsoAnimStartTime
                && held.Header.BagList.Bags[0].FirstWeapon.Clip == initialClip - 1, "Holding the trigger during cooldown continues the clip");

            int grenadeCycleCmd = cli.SendUserCmd(0, 0, 0, 1, 5, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= grenadeCycleCmd, 1500, "Grenade cycle starts on shortcut 5");
            var grenadeSelected = cli.LatestSnapshot!.Players.Single(p => p.Id == 1);
            Assert(grenadeSelected.CurrentWeapon == 4 && grenadeSelected.CurrentWeaponIndex == 0 && grenadeSelected.CurrentWeaponName == "grenade",
                "Shortcut 5 selects the first equipped throwable");
            int flashCmd = cli.SendUserCmd(0, 0, 0, 1, 5, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= flashCmd, 1500, "Shortcut 5 advances to flash");
            var flashSelected = cli.LatestSnapshot!.Players.Single(p => p.Id == 1);
            Assert(flashSelected.CurrentWeapon == 4 && flashSelected.CurrentWeaponIndex == 1 && flashSelected.CurrentWeaponName == "flashgrenade",
                "Repeated shortcut 5 advances to the second throwable");
            int smokeCmd = cli.SendUserCmd(0, 0, 0, 1, 5, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= smokeCmd, 1500, "Shortcut 5 advances to smoke");
            var smokeSelected = cli.LatestSnapshot!.Players.Single(p => p.Id == 1);
            Assert(smokeSelected.CurrentWeapon == 4 && smokeSelected.CurrentWeaponIndex == 2 && smokeSelected.CurrentWeaponName == "smoke",
                "Repeated shortcut 5 advances to the third throwable");
            int noC4Cmd = cli.SendUserCmd(0, 0, 0, 1, 6, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= noC4Cmd, 1500, "Shortcut 6 checked without a C4 carrier");
            var noC4Selected = cli.LatestSnapshot!.Players.Single(p => p.Id == 1);
            Assert(noC4Selected.CurrentWeapon == 4 && noC4Selected.CurrentWeaponIndex == 2 && noC4Selected.CurrentWeaponName == "smoke",
                "Shortcut 6 stays reserved for C4 and cannot alter a non-carrier's throwable selection");
            int primaryCmd = cli.SendUserCmd(0, 0, 0, 1, 1, p1Start.ViewYaw, 0f, 16);
            WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= primaryCmd, 1500, "Primary weapon restored after grenade slot checks");

            float steerOff = 0f, lx = x0, ly = y0;
            double steerUntil = 0.0, lsec = 0.0;
            bool sawNativeBotFall = false;
            var sw = Stopwatch.StartNew();
            while (sw.Elapsed.TotalSeconds < 24)
            {
                SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw);
                Thread.Sleep(33);
                var frame = cli.LatestSnapshot!;
                sawNativeBotFall |= frame.Players.Any(player => player.IsBot && HasNativeDeathPlayback(frame, player));
                if (cli.HitPlayerCount >= 1 && cli.MissionResultCount >= 1 && cli.GameWinCount >= 1)
                {
                    break;
                }
            }
            if (cli.MissionResultCount >= 1 && cli.GameWinCount == 0)
            {
                WaitUntil(() => cli.GameWinCount >= 1, 8000, "Method 5 BroadcastWin after settlement");
            }
            var p1End = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            float moved = Dist2(p1End.X, p1End.Y, x0, y0);
            Assert(moved > 50f, $"Local player moved via WeEngine+PhysX ({moved:F1}cm)");
            Assert(sawNativeBotFall, "Bot death snapshot uses the native fall and shared death clock");
            Assert(cli.Kills.Count >= 2, $"Combat generated KillPlayerInfoData packets ({cli.Kills.Count})");
            Assert(cli.HitPlayerCount >= 1, $"Player 1 landed gun hit -> Method 131 HitPlayer ({cli.HitPlayerCount})");
            Assert(cli.MissionResultCount >= 1, $"Settlement Method 18/19 received ({cli.MissionResultCount})");
            Assert(cli.SimpleProtos.Any(sp => sp.Key == 3), "Settlement SimpleProto Key=3 received");
            Assert(cli.GameWinCount >= 1, $"Settlement Method 5 Win received ({cli.GameWinCount})");
            Assert(cli.LatestPings?.List.Count == 8 && cli.LatestPings.List.Any(p => p.Id == 1 && p.Ping > 0),
                "Method 24 includes local measured latency and all seven bots");
            Assert(cli.GameMessages.Any(m => m.Type == GameMessageType.GAMESTART), "Method 35 announces game start");
            Assert(cli.GroupBest is { AceNum1: > 0, BestNum: > 0 }, "Method 29 includes kill leaders and longest streak");
            Assert(cli.LastMvp is { KillData: > 0, DamageData: > 0 }, "Method 17 includes kill and damage leaders");
            Assert(!cli.Init3.PlayerList.Contains("ct_knight1_2"), "Preload list excludes the known broken bot career");
            Console.WriteLine($"[PASS] team_ai: moved={moved:F1}cm, kills={cli.Kills.Count}, hit131={cli.HitPlayerCount}, win5={cli.GameWinCount}, snapshots={cli.SnapshotCount}");
        }
        finally { KillSafe(srv); }
    }

    private static void TestCombatFeedbackAndSpectate()
    {
        Console.WriteLine("=== [1b/4] Testing Method 22 TacticsSound, Method 37/38 Spray, Method 20 DamageCount, Method 30 Observer ===");
        var cfg = new
        {
            map = "12",
            mode = "team_ai",
            race_type = 2003,
            win_score = 40,
            god_mode = false,
            tcp_port = TcpPort,
            udp_port = UdpPort,
            ally_bot_count = 3,
            enemy_bot_count = 4,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" }
            }
        };
        using var srv = StartServer(cfg, "feedback");
        try
        {
            using var cli = HandshakeAndSpawn(TcpPort, UdpPort);

            // 1) Method 22 TacticsSound roundtrip
            cli.SendTcp(5, new TacticsSoundData { SoundId = 6 });
            WaitUntil(() => cli.TacticsSounds.Any(t => t.PlayerId == 1 && t.SoundId == 6), 3000,
                "Method 22 TacticsSoundData echo");
            Console.WriteLine("[PASS] Method 22 TacticsSoundData echo");

            // 2) Method 38 Spray distance check -> Method 37 SprayEventEntityData -> Method 38 cooldown check
            cli.SendUserCmd(0, 0, Btn.Spray, 1, 1, 0f, -85f);
            Thread.Sleep(40);
            cli.SendUserCmd(0, 0, 0, 1, 1, 0f, 0f);
            WaitUntil(() => cli.SprayMessages.Any(m => m.Type == SprayMessageType.DISTANCENOTENOUGH), 3000,
                "Method 38 DISTANCENOTENOUGH when aiming at sky");

            cli.SendUserCmd(0, 0, Btn.Spray, 1, 1, 123.5f, 85f);
            Thread.Sleep(40);
            cli.SendUserCmd(0, 0, 0, 1, 1, 123.5f, 0f);
            WaitUntil(() => cli.SprayEvents.Any(s => s.IsAdd && s.ResTypeID == 100 && Math.Abs(s.Yaw - 123.5f) < 0.2f), 3000,
                "Method 37 APC=17 SprayEventEntityData (ResTypeID=100, cmd.Yaw)");

            cli.SendUserCmd(0, 0, Btn.Spray, 1, 1, 0f, 85f);
            Thread.Sleep(40);
            cli.SendUserCmd(0, 0, 0, 1, 1, 0f, 0f);
            WaitUntil(() => cli.SprayMessages.Any(m => m.Type == SprayMessageType.NOTIMETO), 3000,
                "Method 38 NOTIMETO during spray cooldown");
            Console.WriteLine("[PASS] Method 37 SprayEventEntityData + Method 38 SprayMessageData");

            // 3) Land >= 1 hit, then walk into enemy bots without firing so player 1 dies -> Method 20 + Method 30 + Snapshot.Observer
            var p1 = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            float steerOff = 0f, lx = p1.X, ly = p1.Y;
            double steerUntil = 0.0, lsec = 0.0;
            var sw = Stopwatch.StartNew();
            while (sw.Elapsed.TotalSeconds < 16 && cli.HitPlayerCount == 0)
            {
                SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw, allowAttack: true);
                Thread.Sleep(33);
            }
            Assert(cli.HitPlayerCount >= 1, $"Player 1 landed gun hit before spectate death test ({cli.HitPlayerCount})");

            // Wait for alive if killed on the exact kill shot so lifeDamageDealt has an active hit, or proceed if DamageCount already fired
            int dmgSeenBefore = cli.DamageCounts.Count;
            if (dmgSeenBefore == 0)
            {
                var swDeath = Stopwatch.StartNew();
                while (swDeath.Elapsed.TotalSeconds < 22)
                {
                    var curMe = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                    if (curMe.IsDead) break;
                    SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, swDeath, allowAttack: false);
                    Thread.Sleep(33);
                }
            }

            WaitUntil(() => cli.DamageCounts.Count > 0, 3000, "Method 20 DamageCountData after player death");
            var dmg = cli.DamageCounts.Last();
            Assert(dmg.List.Any(d => d.Damage > 0 && !string.IsNullOrEmpty(d.PlayerName)),
                $"Method 20 DamageCountData contains dealt damage entries (count={dmg.List.Count})");

            WaitUntil(() => cli.LatestSnapshot!.Header.Observer > 0 && cli.ObserverInfos.Count > 0, 3000,
                "Snapshot.Observer > 0 and Method 30 ObserverInfoData while dead");
            int obsId = cli.LatestSnapshot!.Header.Observer;
            Assert(cli.ObserverInfos.Any(o => o.Id == obsId && !string.IsNullOrEmpty(o.TeamName) && o.Rank >= 1),
                $"Method 30 ObserverInfoData matches Snapshot.Observer={obsId}");

            var curSnap = cli.LatestSnapshot!;
            var otherMate = curSnap.Players.FirstOrDefault(p => p.Id != 1 && p.Id != obsId && p.Team == curSnap.Players.First(q => q.Id == 1).Team && !p.IsDead);
            if (otherMate != null)
            {
                cli.SendUserCmd(0, 0, Btn.Attack, 1, 1, 0f, 0f);
                Thread.Sleep(40);
                cli.SendUserCmd(0, 0, 0, 1, 1, 0f, 0f);
                WaitUntil(() => cli.LatestSnapshot!.Players.First(p => p.Id == 1).IsDead == false || cli.LatestSnapshot.Header.Observer != obsId,
                    1500, "Dead Attack click cycles observer target");
                cli.SendTcp(9, new IntData { Data = otherMate.Id });
                WaitUntil(() => cli.LatestSnapshot!.Players.First(p => p.Id == 1).IsDead == false || cli.LatestSnapshot.Header.Observer == otherMate.Id,
                    1500, "Method 9 observer target switch");
            }

            WaitUntil(() => cli.LatestSnapshot!.Players.First(p => p.Id == 1).IsDead == false && cli.LatestSnapshot.Header.Observer == 0,
                5000, "Snapshot.Observer resets to 0 upon respawn");
            Console.WriteLine($"[PASS] Method 20 DamageCountData + Method 30 ObserverInfoData (obs={obsId})");
        }
        finally { KillSafe(srv); }
    }

    private static void TestBladeAiSkillsTransformAndMelee()
    {
        Console.WriteLine("=== [2/4] Testing blade_ai (2041): skins, R-transform, F-skill, VFX, melee range ===");
        var cfg = new
        {
            map = "12",
            mode = "blade_ai",
            race_type = 2041,
            tcp_port = TcpPort,
            udp_port = UdpPort,
            ally_bot_count = 2,
            enemy_bot_count = 3,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "double_scythe_hell", melee_skin = "skin_brave_dagger_fluorescent", throwable = "grenade", throwable_skin = "" }
            }
        };
        using var srv = StartServer(cfg, "blade");
        try
        {
            using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
            Assert(cli.Room!.RaceType == 2041, $"Room.RaceType=2041");
            Assert(cli.Init3!.WeaponSkinList.Contains("skin_brave_dagger_fluorescent"), "Skin preloaded in OnGameinitData");
            var me0 = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
            Assert(me0.CurrentWeapon == 3, $"Started in melee slot 3 (got {me0.CurrentWeapon})");
            Assert(me0.CurrentWeaponName == "double_scythe_hell", $"Weapon is double_scythe_hell (got {me0.CurrentWeaponName})");
            Assert(me0.CurrentWeaponSkinName == "skin_brave_dagger_fluorescent", $"CurrentWeaponSkinName set (got '{me0.CurrentWeaponSkinName}')");

            var botFalls = new ConcurrentDictionary<(int Id, int StartTime), (bool Playing, bool Finished)>();
            cli.OnSnapshotReceived += snapshot =>
            {
                foreach (var bot in snapshot.Players)
                {
                    if (!bot.IsBot || !bot.IsDead || bot.LegsAnim != 11 || bot.TorsoAnim != 19 || bot.Moving) continue;
                    int elapsed = snapshot.Header.ServerTime - bot.TorsoAnimStartTime;
                    int remaining = Math.Max(0, 2033 - elapsed);
                    if (elapsed < 0 || bot.DeadTimer != elapsed || bot.LegsSpeedAnimTime != elapsed
                        || bot.LegsAnimationTimer != remaining || bot.TorsoAnimationTimer != remaining) continue;
                    botFalls.AddOrUpdate((bot.Id, bot.TorsoAnimStartTime), (remaining > 0, remaining == 0),
                        (_, seen) => (seen.Playing || remaining > 0, seen.Finished || remaining == 0));
                }
            };

            // Trigger Reload (R) transform on double_scythe_hell
            cli.SendUserCmd(0, 0, Btn.Reload, 1, 3, me0.ViewYaw, 0f);
            WaitUntil(() => cli.LatestSnapshot!.Header.BagList.Bags[0].MeleeWeapon.SpecialMode, 2500, "SpecialMode transform via R");
            var mw = cli.LatestSnapshot!.Header.BagList.Bags[0].MeleeWeapon;
            Assert((mw.EffectLevel & 1) != 0, $"EffectLevel bit0 set on transform ({mw.EffectLevel})");

            // Release R, then trigger Skill (F)
            cli.SendUserCmd(0, 0, 0, 1, 3, me0.ViewYaw, 0f);
            Thread.Sleep(50);
            cli.SendUserCmd(0, 0, Btn.Skill, 1, 3, me0.ViewYaw, 0f);
            WaitUntil(() => cli.SkillInfos.Count >= 1 && cli.SimpleProtos.Any(sp => sp.Key == 1), 2500, "Method 27 SkillInfoData & SimpleProto VFX tip");
            Thread.Sleep(100);
            mw = cli.LatestSnapshot!.Header.BagList.Bags[0].MeleeWeapon;
            Assert((mw.EffectLevel & 0x3E) != 0, $"Skill particle EffectLevel bits active ({mw.EffectLevel})");

            // Wait for bot melee combat kills and verify NONE happen at rifle range (> 250cm)
            var sw = Stopwatch.StartNew();
            while (sw.Elapsed.TotalSeconds < 15 && cli.Kills.Count < 2)
            {
                cli.SendUserCmd(0, 0, 0, 1, 3, me0.ViewYaw, 0f);
                Thread.Sleep(50);
            }
            Assert(cli.Kills.Count >= 1, $"Blade bots generated melee kills ({cli.Kills.Count})");
            WaitUntil(() => botFalls.Values.Any(fall => fall.Playing && fall.Finished), 5000,
                "Bot death retains the native clip from playback through final pose");
            Console.WriteLine($"[PASS] blade_ai: transform={mw.SpecialMode}, effectLvl=0x{mw.EffectLevel:X}, skillPackets={cli.SkillInfos.Count}, meleeKills={cli.Kills.Count}");
        }
        finally { KillSafe(srv); }
    }

    private static void TestExplodeC4DropPickupAndRoundReset()
    {
        Console.WriteLine("=== [3/4] Testing explode (2, map2): C4 drop/pickup & round elimination -> ClearForNewSection (62) ===");
        var cfg1 = new
        {
            map = "2",
            mode = "explode",
            race_type = 2,
            player_team = 1,
            tcp_port = TcpPort,
            udp_port = UdpPort,
            ally_bot_count = 0,
            enemy_bot_count = 3,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" }
            }
        };
        using (var srv = StartServer(cfg1, "explode1"))
        {
            try
            {
                using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
                Assert(cli.Room!.RaceType == 2, $"Room.RaceType=2");
                var bagList0 = cli.LatestSnapshot!.Header.BagList;
                Assert(bagList0.C4Weapon != null && bagList0.C4Weapon.WeaponName == "c4", "T player starts with C4Weapon");
                var me = cli.LatestSnapshot.Players.First(p => p.Id == 1);
                Assert(me.C4Flag, "T player C4Flag is true");

                int c4Cmd = cli.SendUserCmd(0, 0, 0, 1, 6, me.ViewYaw, 0f);
                WaitUntil(() => cli.LatestSnapshot?.Header.LastCmd >= c4Cmd, 1500, "Shortcut 6 selects C4");
                var c4Selected = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                Assert(c4Selected.CurrentWeapon == 5 && c4Selected.CurrentWeaponName == "c4", "Shortcut 6 selects C4 for its carrier");

                cli.SendUserCmd(-4, 0, Btn.ThrowWeapon | Btn.Backward, 1, 1, me.ViewYaw, 0f);
                for (int i = 0; i < 15; i++)
                {
                    Thread.Sleep(33);
                    cli.SendUserCmd(-4, 0, Btn.Backward, 1, 1, me.ViewYaw, 0f);
                }
                WaitUntil(() => cli.LatestSnapshot!.SceneWeapons.Any(w => w.WeaponName == "c4") && cli.LatestSnapshot.Header.BagList.C4Weapon == null,
                    2500, "Dropped C4 appears as SceneWeaponEntityData");
                var droppedC4 = cli.LatestSnapshot!.SceneWeapons.First(w => w.WeaponName == "c4");

                var sw = Stopwatch.StartNew();
                while (sw.Elapsed.TotalSeconds < 5 && cli.LatestSnapshot!.Header.BagList.C4Weapon == null)
                {
                    var cur = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                    float yawToC4 = (float)(Math.Atan2(droppedC4.Y - cur.Y, droppedC4.X - cur.X) * 180.0 / Math.PI);
                    cli.SendUserCmd(4, 0, Btn.Forward, 1, 1, yawToC4, 0f);
                    Thread.Sleep(33);
                }
                Assert(cli.LatestSnapshot!.Header.BagList.C4Weapon != null, "Picked dropped C4 back up into BagList");
                WaitUntil(() => cli.C4Messages.Any(m => m.Type == C4MessageType.FALLING && m.PlayerName == me.PlayerName)
                    && cli.C4Messages.Any(m => m.Type == C4MessageType.PICKUP && m.PlayerName == me.PlayerName),
                    2000, "Method 16 carries drop/pickup actor and type");
            }
            finally { KillSafe(srv); }
        }

        // Phase B: Verify T bot autonomously navigates map2 via BspNavGraph to BombSite[0] and plants C4 -> Method 14
        var cfg2 = new
        {
            map = "2",
            mode = "explode",
            race_type = 2,
            player_team = 2,
            ally_bot_count = 0,
            enemy_bot_count = 1,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" }
            }
        };
        using (var srv2 = StartServer(cfg2, "explode2"))
        {
            try
            {
                using var cli2 = HandshakeAndSpawn(TcpPort, UdpPort);
                var m0 = cli2.LatestSnapshot!.Players.First(p => p.Id == 1);
                var sw = Stopwatch.StartNew();
                while (sw.Elapsed.TotalSeconds < 24 && !cli2.C4Actives.Any(c => c.Active))
                {
                    cli2.SendUserCmd(0, 0, 0, 1, 1, m0.ViewYaw, 0f);
                    Thread.Sleep(50);
                }
                if (!cli2.C4Actives.Any(c => c.Active))
                {
                    var botsNow = cli2.LatestSnapshot!.Players.Where(p => p.Id != 1).Select(p => $"{p.PlayerName}(T{p.Team},c4={p.HasC4},pos=({p.X:F0},{p.Y:F0},{p.Z:F0}))");
                    throw new Exception($"Explode T bot planted C4 -> Method 14 C4ActiveData ({cli2.C4Actives.Count}). Snapshot bots: {string.Join("; ", botsNow)}");
                }
                WaitUntil(() => cli2.LatestSnapshot!.SceneWeapons.Any(w => w.WeaponName == "c4"), 2000, "Planted C4 SceneWeaponEntityData visible");
                WaitUntil(() => cli2.C4Messages.Any(m => m.Type == C4MessageType.ACTIVE
                    && !string.IsNullOrEmpty(m.PlayerName)), 2000, "Method 16 carries planting announcement");
            }
            finally { KillSafe(srv2); }
        }

        // Phase C: 4 CT bots intercept 1 T bot at BombSite -> round win (elim or defuse) -> Method 62 ClearForNewSection
        var cfg3 = new
        {
            map = "2",
            mode = "explode",
            race_type = 2,
            player_team = 2,
            tcp_port = TcpPort,
            udp_port = UdpPort,
            ally_bot_count = 4,
            enemy_bot_count = 1,
            active_bag = 1,
            bags = new[]
            {
                new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" }
            }
        };
        using (var srv3 = StartServer(cfg3, "explode3"))
        {
            try
            {
                using var cli3 = HandshakeAndSpawn(TcpPort, UdpPort);
                var m0 = cli3.LatestSnapshot!.Players.First(p => p.Id == 1);
                var sw = Stopwatch.StartNew();
                const double engagementLimit = 46;
                const double schedulerMargin = 14; // includes the round-end freeze
                double? plantedAt = null;
                while (cli3.ClearSectionCount == 0)
                {
                    if (plantedAt == null)
                    {
                        lock (cli3.C4Actives)
                            if (cli3.C4Actives.Any(message => message.Active)) plantedAt = sw.Elapsed.TotalSeconds;
                    }
                    double deadline = plantedAt is double planted
                        ? Math.Max(engagementLimit, planted + SSJJ.Server.GameModes.ModeCoordinator.C4DetonateSec + schedulerMargin)
                        : engagementLimit;
                    if (sw.Elapsed.TotalSeconds >= deadline) break;
                    cli3.SendUserCmd(0, 0, 0, 1, 1, m0.ViewYaw, 0f);
                    Thread.Sleep(50);
                }
                Assert(cli3.ClearSectionCount >= 1 && cli3.TeamScores.Any(s => s.Team1Score + s.Team2Score > 0),
                    $"Explode round finished & reset (clear62={cli3.ClearSectionCount}, plantedAt={plantedAt:F1}, elapsed={sw.Elapsed.TotalSeconds:F1})");
                Console.WriteLine("[PASS] explode: C4 drop/pickup, T-bot C4 plant (14), scored round and reset (62)");
            }
            finally { KillSafe(srv3); }
        }
    }

    private static void TestWeaponMasterFlyKnifeBigHead()
    {
        Console.WriteLine("=== [4/4] Testing weaponmaster (64 -> Method 120), flyknife (74 -> ranged), bighead (2019 -> Method 64) ===");
        var wmCfg = new
        {
            map = "12", mode = "weaponmaster", race_type = 64, win_score = 3, god_mode = true,
            ally_bot_count = 0, enemy_bot_count = 3, active_bag = 1,
            bags = new[] { new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" } }
        };
        using (var srv = StartServer(wmCfg, "wm"))
        {
            try
            {
                using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
                Assert(cli.Room!.RaceType == 64, "Room.RaceType=64");
                var m0 = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                Assert(m0.CurrentWeaponName == "m4a1", "WeaponMaster starts at m4a1");
                float steerOff = 0f, lx = m0.X, ly = m0.Y;
                double steerUntil = 0.0, lsec = 0.0;
                var sw = Stopwatch.StartNew();
                while (sw.Elapsed.TotalSeconds < 20 && cli.WeaponMasterMsgs.Count == 0)
                {
                    SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw);
                    Thread.Sleep(33);
                }
                Assert(cli.WeaponMasterMsgs.Count >= 1, $"WeaponMaster Method 120 upgrade received ({cli.WeaponMasterMsgs.Count})");
                Console.WriteLine($"[PASS] weaponmaster (64): Method 120 upgrades={cli.WeaponMasterMsgs.Count}");
            }
            finally { KillSafe(srv); }
        }

        var bhCfg = new
        {
            map = "12", mode = "bighead", race_type = 2019, win_score = 5, god_mode = true,
            ally_bot_count = 1, enemy_bot_count = 4, active_bag = 1,
            bags = new[] { new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" } }
        };
        using (var srv = StartServer(bhCfg, "bh"))
        {
            try
            {
                using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
                Assert(cli.Room!.RaceType == 2019, "Room.RaceType=2019");
                var m0 = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                float steerOff = 0f, lx = m0.X, ly = m0.Y;
                double steerUntil = 0.0, lsec = 0.0;
                var sw = Stopwatch.StartNew();
                while (sw.Elapsed.TotalSeconds < 20 && cli.BigHeadMsgs.Count == 0)
                {
                    SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw);
                    Thread.Sleep(33);
                }
                Assert(cli.BigHeadMsgs.Count >= 1, $"BigHead Method 64 progress received ({cli.BigHeadMsgs.Count})");
                Console.WriteLine($"[PASS] bighead (2019): Method 64 progress packets={cli.BigHeadMsgs.Count}");
            }
            finally { KillSafe(srv); }
        }

        var fkCfg = new
        {
            map = "12", mode = "flyknife", race_type = 74, god_mode = true,
            ally_bot_count = 0, enemy_bot_count = 3, active_bag = 1,
            bags = new[] { new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" } }
        };
        using (var srv = StartServer(fkCfg, "fk"))
        {
            try
            {
                using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
                Assert(cli.Room!.RaceType == 74, "Room.RaceType=74");
                var m0 = cli.LatestSnapshot!.Players.First(p => p.Id == 1);
                Assert(m0.CurrentWeaponName == "dagger", "FlyKnife starts at dagger");
                float steerOff = 0f, lx = m0.X, ly = m0.Y;
                double steerUntil = 0.0, lsec = 0.0;
                var sw = Stopwatch.StartNew();
                while (sw.Elapsed.TotalSeconds < 16 && cli.HitPlayerCount == 0)
                {
                    SteerAndShootAtClosestEnemy(cli, 3, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw);
                    Thread.Sleep(33);
                }
                Assert(cli.HitPlayerCount >= 1, $"FlyKnife ranged knife throw hit -> Method 131 ({cli.HitPlayerCount})");
                Console.WriteLine($"[PASS] flyknife (74): ranged knife hit131={cli.HitPlayerCount}, kills={cli.Kills.Count}");
            }
            finally { KillSafe(srv); }
        }
    }

    private static void TestPveIndustrial01WaveAndBossSettlement()
    {
        Console.WriteLine("\n=== [5] Testing Adventure Mode PVE Industrial Zone 01 (map100001, raceType=10001) ===");
        var pveCfg = new
        {
            map = "map100001", mode = "pve", race_type = 10001, god_mode = true,
            ally_bot_count = 0, enemy_bot_count = 1, active_bag = 1,
            bags = new[] { new { primary = "ak47", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" } }
        };
        using var srv = StartServer(pveCfg, "pve_ind01");
        try
        {
            using var cli = HandshakeAndSpawn(TcpPort, UdpPort);
            Assert(cli.Room!.RaceType == 10001 && cli.Room.SceneId == 100001 && cli.Room.PveLevel == 1,
                $"PVE RoomData mismatch: race={cli.Room.RaceType}, scene={cli.Room.SceneId}, pveLv={cli.Room.PveLevel}");
            Assert(cli.Init3!.EngineID == 4 && cli.Init3.ObfuscatorSeed != null && Math.Abs(cli.Init3.ObfuscatorSeed.X - (-4392f)) < 1f,
                "PVE OnGameinitData EngineID=4 and ObfuscatorSeed=(-4392,-4944,-3319)");
            Assert(cli.Init3.PlayerList.Contains("boss1001") && cli.Init3.PlayerList.Contains("rpg_minion_guard") && cli.Init3.WeaponList.Contains("botweapon"),
                "PVE OnGameinitData preloads boss1001, rpg_minion_guard, and botweapon");
            WaitUntil(() => cli.RoadBlocks != null && cli.SceneMapInfo != null && cli.RpgCounterList != null, 3000, "PVE init packets (74, 111, 126)");
            Assert(cli.RoadBlocks!.List.Count == 2 && cli.RoadBlocks.List[0].FileName == "genpve_door4_roadBlock", "Method 74 roadblocks");
            Assert(cli.SceneMapInfo!.SceneId == 100001 && cli.SceneMapInfo.WorldGravity == 2032, "Method 111 SceneMapInfoData");
            Assert(cli.RpgCounterList!.List.Count == 1 && cli.RpgCounterList.List[0].Id == 20320001 && cli.RpgCounterList.List[0].Name == "清道夫训练1",
                "Method 126 RpgCounterListData 清道夫训练1");
            Assert(cli.LatestSnapshot!.PveTowers.Count == 2, $"Initial snapshot has 2 roadblock PveTowers ({cli.LatestSnapshot.PveTowers.Count})");

            var m0 = cli.LatestSnapshot.Players.First(p => p.Id == 1);
            Assert(Math.Abs(m0.X - 7509.2f) < 50f && Math.Abs(m0.Y - 1409.1f) < 50f,
                $"PVE player spawned at authentic map100001 start ({m0.X:F1},{m0.Y:F1},{m0.Z:F1})");

            float steerOff = 0f, lx = m0.X, ly = m0.Y;
            double steerUntil = 0.0, lsec = 0.0;
            var sw = Stopwatch.StartNew();
            while (sw.Elapsed.TotalSeconds < 35 && (cli.MissionResultCount == 0 || cli.GameWinCount == 0))
            {
                SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw, useMap12Nav: false);
                Thread.Sleep(33);
            }

            Assert(cli.Kills.Count >= 4, $"Cleared all 4 PVE stages including boss1001 (kills={cli.Kills.Count})");
            Assert(cli.RpgCounterUpdates.Count >= 4 && cli.RpgCounterUpdates.Last().Now >= 213,
                $"Method 114 RpgCounterData progressed to >=213 (count={cli.RpgCounterUpdates.Count})");
            Assert(cli.ExpMsgs.Count >= 4, $"Method 66 ExpData awarded on each kill (count={cli.ExpMsgs.Count})");
            Assert(cli.PlayerLogouts.Count >= 4, $"Method 10 PlayerLogoutData sent for dead monsters (count={cli.PlayerLogouts.Count})");
            Assert(cli.PveMsgs.Any(m => (int)m.Type == 3) && cli.PveMsgs.Any(m => (int)m.Type == 47)
                && cli.PveMsgs.Any(m => (int)m.Type == 48) && cli.PveMsgs.Any(m => (int)m.Type == 59),
                "Method 71 PveMessageData emitted Type 3, 47, 48, and 59 (Boss alert)");
            Assert(cli.MissionResultCount >= 1 && cli.GameWinCount >= 1,
                $"PVE victory settlement Method 18 ({cli.MissionResultCount}) and Method 5 ({cli.GameWinCount})");
            Console.WriteLine($"[PASS] pve industrial_01 (10001): kills={cli.Kills.Count}, taskNow={cli.RpgCounterUpdates.Last().Now}, pveMsgs={cli.PveMsgs.Count}, win18={cli.MissionResultCount}, win5={cli.GameWinCount}");
        }
        finally
        {
            KillSafe(srv);
        }
    }

    private static void TestDualClientMultiplayer()
    {
        Console.WriteLine("\n=== [6] Testing Dual-Client Multiplayer: Sessions, Distinct Self/Bags, 1P/3P Anim, Combat & Disconnect ===");
        var cfg = new
        {
            map = "12",
            mode = "team_ai",
            race_type = 2003,
            win_score = 10,
            god_mode = false,
            room_id = 7777,
            max_human_players = 2,
            ally_bot_count = 0,
            enemy_bot_count = 0,
            active_bag = 1,
            lobby_players = new Dictionary<string, object>
            {
                ["1000200072528"] = new
                {
                    name = "Alpha",
                    team = 1,
                    active_bag = 1,
                    career = "police",
                    hand = "man",
                    bags = new[]
                    {
                        new { primary = "ak47", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "", throwable2 = "flashgrenade", throwable2_skin = "", throwable3 = "smoke", throwable3_skin = "" }
                    }
                },
                ["1000200072529"] = new
                {
                    name = "Bravo",
                    team = 2,
                    active_bag = 1,
                    career = "pandora_t",
                    hand = "woman",
                    bags = new[]
                    {
                        new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "bat", melee_skin = "", throwable = "grenade", throwable_skin = "" }
                    }
                }
            }
        };

        using var srv = StartServer(cfg, "dual");
        BattleWireClient? cli1 = null;
        BattleWireClient? cli2 = null;
        try
        {
            cli1 = HandshakeAndSpawn(TcpPort, UdpPort, userId: 1000200072528L, playerId: 1, roomId: 7777L);
            cli2 = HandshakeAndSpawn(TcpPort, UdpPort, userId: 1000200072529L, playerId: 2, roomId: 7777L);

            Assert(cli1.TcpConnId != null && cli2.TcpConnId != null && cli1.TcpConnId.Id != cli2.TcpConnId.Id,
                $"Distinct ConnectionIds assigned ({cli1.TcpConnId?.Id} vs {cli2.TcpConnId?.Id})");

            WaitUntil(() =>
                cli1.LatestSnapshot!.Players.Count >= 2 && cli2.LatestSnapshot!.Players.Count >= 2 &&
                cli1.PlayerLogins.Any(l => l.Id == 2) && cli2.PlayerLogins.Any(l => l.Id == 1),
                4000, "Both clients see mutual PlayerLogin and PlayerEntity snapshots");

            var bag1 = cli1.LatestSnapshot!.Header.BagList.Bags[0];
            var bag2 = cli2.LatestSnapshot!.Header.BagList.Bags[0];
            Assert(bag1.FirstWeapon?.WeaponName == "ak47" && bag1.BombWeapons0?.WeaponName == "grenade"
                && bag1.BombWeapons1?.WeaponName == "flashgrenade" && bag1.BombWeapons2?.WeaponName == "smoke",
                "Client 1 receives its own AK47 + 3 throwables bag");
            Assert(bag2.FirstWeapon?.WeaponName == "m4a1" && bag2.MeleeWeapon?.WeaponName == "bat",
                "Client 2 receives its own M4A1 + Bat bag");

            // Test shortcut 5 cycles throwables (grenade -> flashgrenade -> smoke)
            int sw5a = cli1.SendUserCmd(0, 0, 0, 1, 5, 0f, 0f);
            WaitUntil(() => cli1.LatestSnapshot!.Header.LastCmd >= sw5a, 1500, "Shortcut 5 first press");
            Assert(cli1.LatestSnapshot!.Players.First(p => p.Id == 1).CurrentWeaponName == "grenade", "Shortcut 5 slot 0 grenade");
            int sw5b = cli1.SendUserCmd(0, 0, 0, 1, 5, 0f, 0f);
            WaitUntil(() => cli1.LatestSnapshot!.Header.LastCmd >= sw5b, 1500, "Shortcut 5 second press");
            Assert(cli1.LatestSnapshot!.Players.First(p => p.Id == 1).CurrentWeaponName == "flashgrenade", "Shortcut 5 slot 1 flashgrenade");

            // Test Equip TorsoAnim=16 & return to rifle
            int sw3 = cli1.SendUserCmd(0, 0, 0, 1, 3, 0f, 0f);
            WaitUntil(() => cli1.LatestSnapshot!.Header.LastCmd >= sw3, 1500, "Switch to melee");
            var p1Melee = cli1.LatestSnapshot!.Players.First(p => p.Id == 1);
            Assert(p1Melee.ViewAnim == 16 && p1Melee.TorsoAnim == 16, "Weapon switch emits both ViewAnim=16 and TorsoAnim=16");

            int sw1 = cli1.SendUserCmd(0, 0, 0, 1, 1, 0f, 0f);
            WaitUntil(() => cli1.LatestSnapshot!.Header.LastCmd >= sw1, 1500, "Switch back to AK47");
            for (int i = 0; i < 24; i++)
            {
                cli1.SendUserCmd(0, 0, 0, 1, 1, 0f, 0f);
                Thread.Sleep(33);
            }

            // Test firing 1P ViewAnim=15 and 3P TorsoAnim=15, then remote 3P return to 13 while self stays 15
            cli1.SendUserCmd(0, 0, Btn.Attack, 1, 1, 0f, 0f);
            WaitUntil(() =>
                cli1.LatestSnapshot!.Players.First(p => p.Id == 1).ViewAnim == 15 &&
                cli2.LatestSnapshot!.Players.First(p => p.Id == 1).TorsoAnim == 15,
                2000, "Both P1 (1P/3P) and P2 (remote 3P) observe P1 attack animation");

            for (int i = 0; i < 20; i++)
            {
                cli1.SendUserCmd(0, 0, 0, 1, 1, 0f, 0f);
                Thread.Sleep(33);
            }
            WaitUntil(() =>
                cli1.LatestSnapshot!.Players.First(p => p.Id == 1).ViewAnim == 13 &&
                cli2.LatestSnapshot!.Players.First(p => p.Id == 1).TorsoAnim == 13,
                2000, "Remote viewer sees P1 return to TORSO_STAND (13) while P1 ViewAnim finishes at 13");
            Assert(cli1.LatestSnapshot!.Players.First(p => p.Id == 1).TorsoAnim == 15,
                "P1 Self TorsoAnim matches client prediction state without bogus reset");

            // Steer P1 & P2 toward each other (P1 fires once in close range; P2 stays unarmed/passive), verify hitmarker & kill
            var p1Start = cli2.LatestSnapshot!.Players.First(p => p.Id == 1);
            float x0 = p1Start.X, y0 = p1Start.Y;
            float s1Off = 0f, s1Lx = x0, s1Ly = y0;
            double s1Until = 0.0, s1Check = 0.0;
            var p2Start = cli2.LatestSnapshot!.Players.First(p => p.Id == 2);
            float s2Off = 0f, s2Lx = p2Start.X, s2Ly = p2Start.Y;
            double s2Until = 0.0, s2Check = 0.0;
            int step = 0;
            var sw = Stopwatch.StartNew();
            while (sw.Elapsed.TotalSeconds < 24 && (cli1.HitPlayerCount == 0 || cli1.Kills.Count == 0))
            {
                step++;
                var snap1 = cli1.LatestSnapshot!;
                var p1 = snap1.Players.First(p => p.Id == 1);
                var t2 = snap1.Players.FirstOrDefault(p => p.Id == 2 && !p.IsDead);
                if (t2 != null)
                {
                    float dist = Math.Max(1f, Dist2(p1, t2));
                    double sec = sw.Elapsed.TotalSeconds;
                    if (sec - s1Check >= 0.40)
                    {
                        float moved = Dist2(p1.X, p1.Y, s1Lx, s1Ly);
                        s1Lx = p1.X; s1Ly = p1.Y; s1Check = sec;
                        if (moved < 25f) { s1Off = (s1Off + 65f) % 360f; s1Until = sec + 0.8; }
                        else if (sec >= s1Until) s1Off = 0f;
                    }
                    float aimYaw = (float)(Math.Atan2(t2.Y - p1.Y, t2.X - p1.X) * 180.0 / Math.PI);
                    float aimPitch = -(float)(Math.Atan2((t2.Z + 110f) - (p1.Z + 146f), dist) * 180.0 / Math.PI);
                    float moveYaw = sec < s1Until ? aimYaw + s1Off : aimYaw;
                    int btns = Btn.Forward | ((step % 15 == 0 && sec < s1Until) ? Btn.Jump : 0);
                    if (dist < 1800f && step % 3 != 0) btns |= Btn.Attack;
                    cli1.SendUserCmd(4, 0, btns, 1, 1, sec < s1Until ? moveYaw : aimYaw, aimPitch);
                }

                var snap2 = cli2.LatestSnapshot!;
                var p2 = snap2.Players.First(p => p.Id == 2);
                var t1 = snap2.Players.FirstOrDefault(p => p.Id == 1 && !p.IsDead);
                if (t1 != null)
                {
                    double sec = sw.Elapsed.TotalSeconds;
                    if (sec - s2Check >= 0.40)
                    {
                        float moved = Dist2(p2.X, p2.Y, s2Lx, s2Ly);
                        s2Lx = p2.X; s2Ly = p2.Y; s2Check = sec;
                        if (moved < 25f) { s2Off = (s2Off - 65f) % 360f; s2Until = sec + 0.8; }
                        else if (sec >= s2Until) s2Off = 0f;
                    }
                    float aimYaw2 = (float)(Math.Atan2(t1.Y - p2.Y, t1.X - p2.X) * 180.0 / Math.PI);
                    float moveYaw2 = sec < s2Until ? aimYaw2 + s2Off : aimYaw2;
                    int btns2 = Dist2(p2, t1) > 220f ? (Btn.Forward | ((step % 15 == 0 && sec < s2Until) ? Btn.Jump : 0)) : 0;
                    cli2.SendUserCmd(4, 0, btns2, 1, 1, moveYaw2, 0f);
                }
                Thread.Sleep(33);
            }
            var p1RemoteAfter = cli2.LatestSnapshot!.Players.First(p => p.Id == 1);
            var p2RemoteAfter = cli2.LatestSnapshot!.Players.First(p => p.Id == 2);
            float remoteMoved = Dist2(x0, y0, p1RemoteAfter.X, p1RemoteAfter.Y);
            Assert(remoteMoved > 50f, $"P2 observed P1 moving ({remoteMoved:F1}cm)");
            Assert(cli1.HitPlayerCount >= 1 && cli2.HitPlayerCount == 0,
                $"Hitmarker Method 131 delivered only to attacker (P1={cli1.HitPlayerCount}, P2={cli2.HitPlayerCount}, P1pos=({p1RemoteAfter.X:F0},{p1RemoteAfter.Y:F0},{p1RemoteAfter.Z:F0}), P2pos=({p2RemoteAfter.X:F0},{p2RemoteAfter.Y:F0},{p2RemoteAfter.Z:F0}), dist={Dist2(p1RemoteAfter, p2RemoteAfter):F0})");
            Assert(cli1.Kills.Count >= 1 && cli2.Kills.Count >= 1,
                $"Kill notice broadcast to both clients (P1={cli1.Kills.Count}, P2={cli2.Kills.Count})");

            int p1Hits = cli1.HitPlayerCount;
            // Disconnect P1 and confirm P2 receives PlayerLogoutData (10) + DeleteIdList
            cli1.Dispose();
            cli1 = null;
            WaitUntil(() => cli2.PlayerLogouts.Any(l => l.Id == 1) && cli2.SeenDeletedIds.Contains(1),
                5000, "P2 receives P1 logout and snapshot DeleteIdList cleanup");
            WaitUntil(() => cli2.LatestSnapshot!.Players.All(p => p.Id != 1),
                3000, "P1 removed from P2 subsequent snapshots");

            Console.WriteLine($"[PASS] dual-client multiplayer: moved={remoteMoved:F1}cm, p1Hits={p1Hits}, kills={cli2.Kills.Count}, cleanup=OK");
        }
        finally
        {
            cli1?.Dispose();
            cli2?.Dispose();
            KillSafe(srv);
        }
    }

    private static void TestAllModeMultiplayerE2E()
    {
        Console.WriteLine("=== [5/6] Testing all-mode multiplayer E2E: Explode (2) & WeaponMaster (64) 2-human rooms ===");
        var expCfg = new
        {
            map = "2", mode = "explode", race_type = 2, room_id = 1001,
            max_human_players = 2, ally_bot_count = 0, enemy_bot_count = 1, god_mode = true
        };
        using (var srv = StartServer(expCfg, "mp_explode"))
        {
            try
            {
                using var p1 = HandshakeAndSpawn(TcpPort, UdpPort, userId: 610001, playerId: 1);
                using var p2 = HandshakeAndSpawn(TcpPort, UdpPort, userId: 610002, playerId: 2);
                WaitUntil(() => p1.LatestSnapshot!.Players.Count >= 3 && p2.LatestSnapshot!.Players.Count >= 3, 2500,
                    "Explode 2-human + 1-bot roster synced");
                Assert(p1.Room!.RaceType == 2 && p2.Room!.RaceType == 2 && p1.Init3!.Team != p2.Init3!.Team,
                    "Explode multiplayer balances teams and syncs RaceType=2");
                var p1Ent = p1.LatestSnapshot!.Players.Single(p => p.Id == 1);
                p1.SendUserCmd(4, 0, Btn.Forward, 1, 1, p1Ent.ViewYaw, 0f);
                WaitUntil(() => Dist2(p1Ent, p1.LatestSnapshot!.Players.Single(p => p.Id == 1)) > 1f, 1500,
                    "Explode P1 movement synced independently");
            }
            finally { KillSafe(srv); }
        }

        var wmCfg = new
        {
            map = "12", mode = "weaponmaster", race_type = 64, room_id = 1001,
            max_human_players = 2, ally_bot_count = 0, enemy_bot_count = 2, god_mode = true
        };
        using (var srv = StartServer(wmCfg, "mp_wm"))
        {
            try
            {
                using var p1 = HandshakeAndSpawn(TcpPort, UdpPort, userId: 620001, playerId: 1);
                using var p2 = HandshakeAndSpawn(TcpPort, UdpPort, userId: 620002, playerId: 2);
                WaitUntil(() => p1.LatestSnapshot!.Players.Count >= 4 && p2.LatestSnapshot!.Players.Count >= 4, 2500,
                    "WeaponMaster 2-human + 2-bot roster synced");
                Assert(p1.Room!.RaceType == 64 && p2.Room!.RaceType == 64, "WeaponMaster RaceType=64 across both humans");
                Console.WriteLine("[PASS] all-mode multiplayer: Explode(2) & WeaponMaster(64) multi-human sync");
            }
            finally { KillSafe(srv); }
        }
    }

    private static void TestHeroWeaponsSkillAndVfxE2E()
    {
        Console.WriteLine("=== [6/6a] Testing 21 representative Hero/Legendary/Gold weapons Skill+VFX E2E ===");
        (string Weapon, byte Slot)[] arsenal =
        {
            ("m4a1_legend2", 1), ("deagle_pulse", 2), ("double_scythe_hell", 3),
            ("ak47_legend_ct", 1), ("block_dragon_pistol", 2), ("abyss_blade", 3),
            ("awm_legend_ct", 1), ("awm_hero", 1), ("double_scythe", 3),
            ("barrett_m107_dragon", 1), ("aa12_hell_dragon", 1), ("bladeshield_hero", 3),
            ("aa12_hero", 1), ("thunder_submachinegun_legend2", 1), ("nunchakus_legend2", 3),
            ("ak47_hero", 1), ("m4a1_hero", 1), ("gold_saber", 3),
            ("rpk_hero", 1), ("p90_s", 1), ("ak47_legend_t", 1)
        };

        // Group strictly into bags of up to (1 primary, 1 secondary, 1 melee) so every weapon occupies a unique (bag, slot).
        int verifiedCount = 0;
        var bagConfigs = new List<(string Pri, string Sec, string Mel)>();
        var weaponAssignments = new List<(int Batch, byte Bag, byte Slot, string Weapon)>();
        var remPrimaries = arsenal.Where(a => a.Slot == 1).Select(a => a.Weapon).ToList();
        var remSecondaries = arsenal.Where(a => a.Slot == 2).Select(a => a.Weapon).ToList();
        var remMelees = arsenal.Where(a => a.Slot == 3).Select(a => a.Weapon).ToList();
        while (remPrimaries.Count > 0 || remSecondaries.Count > 0 || remMelees.Count > 0)
        {
            int batch = bagConfigs.Count / 5;
            byte bag = (byte)((bagConfigs.Count % 5) + 1);
            string pri = remPrimaries.Count > 0 ? remPrimaries[0] : "m4a1";
            if (remPrimaries.Count > 0) { weaponAssignments.Add((batch, bag, 1, pri)); remPrimaries.RemoveAt(0); }
            string sec = remSecondaries.Count > 0 ? remSecondaries[0] : "deagle";
            if (remSecondaries.Count > 0) { weaponAssignments.Add((batch, bag, 2, sec)); remSecondaries.RemoveAt(0); }
            string mel = remMelees.Count > 0 ? remMelees[0] : "dagger";
            if (remMelees.Count > 0) { weaponAssignments.Add((batch, bag, 3, mel)); remMelees.RemoveAt(0); }
            bagConfigs.Add((pri, sec, mel));
        }

        int totalBatches = (bagConfigs.Count + 4) / 5;
        for (int batch = 0; batch < totalBatches; batch++)
        {
            var batchBags = bagConfigs.Skip(batch * 5).Take(5)
                .Select(b => (object)new { primary = b.Pri, primary_skin = "", secondary = b.Sec, secondary_skin = "", melee = b.Mel, melee_skin = "", throwable = "grenade", throwable_skin = "" })
                .ToList();
            while (batchBags.Count < 5)
                batchBags.Add(new { primary = "m4a1", primary_skin = "", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" });

            var batchWeapons = weaponAssignments.Where(w => w.Batch == batch).ToList();
            var cfg = new
            {
                map = "12", mode = "team_ai", race_type = 2003, room_id = 1001,
                max_human_players = batchWeapons.Count, ally_bot_count = 0, enemy_bot_count = 1, god_mode = true,
                bags = batchBags
            };
            using var srv = StartServer(cfg, $"skills_b{batch}");
            try
            {
                var clients = new List<BattleWireClient>();
                try
                {
                    for (int i = 0; i < batchWeapons.Count; i++)
                    {
                        var cli = HandshakeAndSpawn(TcpPort, UdpPort, userId: 700000 + batch * 100 + i, playerId: i + 1);
                        clients.Add(cli);
                    }
                    for (int i = 0; i < batchWeapons.Count; i++)
                    {
                        var cli = clients[i];
                        var item = batchWeapons[i];
                        int pid = i + 1;
                        cli.SendUserCmd(0, 0, 0, item.Bag, item.Slot, 0f, 0f);
                        WaitUntil(() => cli.LatestSnapshot!.Players.Any(p => p.Id == pid && p.CurrentWeaponName == item.Weapon),
                            2500, $"Equip {item.Weapon}");
                        cli.SendUserCmd(0, 0, Btn.Skill, item.Bag, item.Slot, 0f, 0f);
                        WaitUntil(() => cli.SkillInfos.Count >= 1
                            && cli.SimpleProtos.Any(sp => sp.Key == 60)
                            && cli.SimpleProtos.Any(sp => sp.Key == 61),
                            3000, $"Skill Method 27 + Key 60/61 VFX for {item.Weapon}");
                        verifiedCount++;
                    }
                }
                finally
                {
                    foreach (var c in clients) c.Dispose();
                }
            }
            finally { KillSafe(srv); }
        }
        Assert(verifiedCount == arsenal.Length, $"Verified Skill+VFX end-to-end for {verifiedCount}/{arsenal.Length} hero/legendary/gold weapons");
        Console.WriteLine($"[PASS] 21 hero/legendary/gold weapons: Method 27 SkillInfo + Key 60/61 VFX verified ({verifiedCount}/21)");
    }

    private static void TestDualLobbyAndBattleBridge()
    {
        Console.WriteLine("=== [6/6b] Testing AIR Lobby multi-room + Dual concurrent Battle Server E2E ===");
        const int lobbyPort = 2011;
        string javaDir = Path.Combine(Root, "_work", "lobby_host", "java");
        BuildLobbyFixture(javaDir);
        var psi = new ProcessStartInfo
        {
            FileName = "java",
            Arguments = $"-Dfile.encoding=UTF-8 -Dssjj.lobby.headlessBattle=1 -cp \"{javaDir}\" LobbyLoginServer {lobbyPort}",
            WorkingDirectory = javaDir,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        using var lobbyProc = Process.Start(psi)!;
        var lobbyOut = new List<string>();
        var lobbyReady = new ManualResetEventSlim(false);
        lobbyProc.OutputDataReceived += (_, e) =>
        {
            if (e.Data == null) return;
            lock (lobbyOut) lobbyOut.Add(e.Data);
            if (e.Data.Contains("LobbyLoginServer listening")) lobbyReady.Set();
        };
        lobbyProc.ErrorDataReceived += (_, e) =>
        {
            if (e.Data == null) return;
            lock (lobbyOut) lobbyOut.Add("[ERR] " + e.Data);
        };
        lobbyProc.BeginOutputReadLine();
        lobbyProc.BeginErrorReadLine();
        if (!lobbyReady.Wait(10000))
        {
            KillSafe(lobbyProc);
            string dump; lock (lobbyOut) dump = string.Join("\n", lobbyOut);
            throw new Exception($"LobbyLoginServer failed to start:\n{dump}");
        }

        try
        {
            using var hostA = new LobbyWireClient("127.0.0.1", lobbyPort);
            using var joinB = new LobbyWireClient("127.0.0.1", lobbyPort);
            using var hostC = new LobbyWireClient("127.0.0.1", lobbyPort);
            using var joinD = new LobbyWireClient("127.0.0.1", lobbyPort);
            try
            {

            static long LoginLobby(LobbyWireClient lc, string name)
            {
                lc.SendRpc("loginV3", name, "pwd");
                WaitUntil(() => lc.Events.Any(e => e.FunctionName == "callBackLoginV3"), 3000, $"loginV3 {name}");
                lc.SendRpc("getUserDataByLogin", name);
                LobbyRpcEvent? ev = null;
                WaitUntil(() => (ev = lc.Events.FirstOrDefault(e => e.FunctionName == "callBackGetUserDataByLogin")) != null,
                    5000, $"getUserDataByLogin {name}");
                var uBean = ev!.Parameters[0] as Dictionary<string, object?>;
                return Convert.ToInt64(uBean!["characterId"]);
            }

            long cidA = LoginLobby(hostA, "E2E_HostA");
            long cidB = LoginLobby(joinB, "E2E_JoinerB");
            long cidC = LoginLobby(hostC, "E2E_HostC");
            long cidD = LoginLobby(joinD, "E2E_JoinerD");
            Assert(cidA != cidB && cidB != cidC && cidC != cidD,
                $"Lobby assigned 4 unique characterIds ({cidA}, {cidB}, {cidC}, {cidD})");

            // Room 1: Explode (raceType=2, sceneId=2)
            hostA.SendRpc("createRoom", new Dictionary<string, object?>
            {
                ["sceneId"] = 2, ["raceType"] = 2, ["limitNumber"] = 4, ["roomName"] = "E2E_Explode"
            });
            LobbyRpcEvent? joinAck1 = null;
            WaitUntil(() => (joinAck1 = hostA.Events.FirstOrDefault(e => e.FunctionName == "callBackJoinRoom")) != null,
                3000, "HostA createRoom");
            int roomId1 = Convert.ToInt32((joinAck1!.Parameters[1] as Dictionary<string, object?>)!["roomId"]);

            // JoinB lists rooms, joins Room 1, switches team, toggles observer, HostA updates room
            joinB.SendRpc("roomList");
            WaitUntil(() => joinB.Events.Any(e => e.FunctionName == "callBackShowRoomList"
                && e.Parameters[0] is List<object?> list
                && list.Any(r => r is Dictionary<string, object?> rm && Convert.ToInt32(rm["roomId"]) == roomId1)),
                3000, "JoinerB roomList sees Room 1");
            joinB.SendRpc("joinRoom", roomId1);
            WaitUntil(() => joinB.Events.Any(e => e.FunctionName == "callBackJoinRoom")
                && hostA.Events.Any(e => e.FunctionName == "callBackRefreshCurrentRoom"), 3000, "JoinerB joinRoom");

            joinB.SendRpc("changeTeam", 2, false);
            WaitUntil(() => joinB.Events.Any(e => e.FunctionName == "callBackChangeTeam"), 3000, "changeTeam");
            joinB.SendRpc("changeGameToObserver", true);
            WaitUntil(() => joinB.Events.Any(e => e.FunctionName == "callBackChangeGameToObserver"), 3000, "changeGameToObserver(true)");
            joinB.SendRpc("changeGameToObserver", false);
            hostA.SendRpc("updateRoom", new Dictionary<string, object?>
            {
                ["sceneId"] = 2, ["raceType"] = 2, ["limitNumber"] = 6, ["roomName"] = "E2E_Explode_6P"
            });

            // Room 2: Team (raceType=2003, sceneId=12)
            hostC.SendRpc("createRoom", new Dictionary<string, object?>
            {
                ["sceneId"] = 12, ["raceType"] = 2003, ["limitNumber"] = 4, ["roomName"] = "E2E_Team"
            });
            LobbyRpcEvent? joinAck2 = null;
            WaitUntil(() => (joinAck2 = hostC.Events.FirstOrDefault(e => e.FunctionName == "callBackJoinRoom")) != null,
                3000, "HostC createRoom");
            int roomId2 = Convert.ToInt32((joinAck2!.Parameters[1] as Dictionary<string, object?>)!["roomId"]);
            Assert(roomId2 != roomId1, $"Created 2 separate rooms ({roomId1} & {roomId2})");
            joinD.SendRpc("joinRoom", roomId2);
            WaitUntil(() => joinD.Events.Any(e => e.FunctionName == "callBackJoinRoom"), 3000, "JoinerD joinRoom");

            // Start BOTH rooms concurrently -> expect 2 onRoomBattleEndpoint notifications on separate ports
            hostA.SendRpc("startGame");
            hostC.SendRpc("startGame");

            LobbyRpcEvent? ep1A = null, ep1B = null, ep2C = null, ep2D = null;
            WaitUntil(() =>
                (ep1A = hostA.Events.FirstOrDefault(e => e.FunctionName == "onRoomBattleEndpoint")) != null
                && (ep1B = joinB.Events.FirstOrDefault(e => e.FunctionName == "onRoomBattleEndpoint")) != null
                && (ep2C = hostC.Events.FirstOrDefault(e => e.FunctionName == "onRoomBattleEndpoint")) != null
                && (ep2D = joinD.Events.FirstOrDefault(e => e.FunctionName == "onRoomBattleEndpoint")) != null,
                10000, "All 4 lobby clients receive onRoomBattleEndpoint");

            int tcp1 = Convert.ToInt32(ep1A!.Parameters[2]), udp1 = Convert.ToInt32(ep1A.Parameters[3]);
            int tcp2 = Convert.ToInt32(ep2C!.Parameters[2]), udp2 = Convert.ToInt32(ep2C.Parameters[3]);
            Assert(tcp1 != tcp2 && udp1 != udp2 && tcp1 == Convert.ToInt32(ep1B!.Parameters[2]) && tcp2 == Convert.ToInt32(ep2D!.Parameters[2]),
                $"Two battle servers started on distinct ports ({tcp1}/{udp1} & {tcp2}/{udp2})");

            using var bA = HandshakeAndSpawn(tcp1, udp1, userId: cidA, playerId: 1, roomId: roomId1);
            using var bB = HandshakeAndSpawn(tcp1, udp1, userId: cidB, playerId: 2, roomId: roomId1);
            using var bC = HandshakeAndSpawn(tcp2, udp2, userId: cidC, playerId: 1, roomId: roomId2);
            using var bD = HandshakeAndSpawn(tcp2, udp2, userId: cidD, playerId: 2, roomId: roomId2);

            Assert(bA.Room != null && bB.Room != null && bC.Room != null && bD.Room != null
                && bA.Room.RaceType == 2 && bB.Room.RaceType == 2 && bC.Room.RaceType == 2003 && bD.Room.RaceType == 2003,
                $"Both battle servers preserve mode RaceType (r1={bA.Room?.RaceType}, r2={bC.Room?.RaceType})");
            Assert(bC.Room!.RoomId == roomId2.ToString(), $"Room2 reports RoomId={bC.Room.RoomId} (expected {roomId2})");

            var a0 = bA.LatestSnapshot!.Players.Single(p => p.Id == 1);
            var c0 = bC.LatestSnapshot!.Players.Single(p => p.Id == 1);
            for (int f = 0; f < 10; f++)
            {
                bA.SendUserCmd(4, 0, Btn.Forward, 1, 1, a0.ViewYaw, 0f);
                bC.SendUserCmd(4, 0, Btn.Forward, 1, 1, c0.ViewYaw, 0f);
                Thread.Sleep(33);
            }
            WaitUntil(() => Dist2(a0, bA.LatestSnapshot!.Players.Single(p => p.Id == 1)) > 10f
                && Dist2(c0, bC.LatestSnapshot!.Players.Single(p => p.Id == 1)) > 10f, 2000,
                "Players move inside both concurrent lobby-launched battle servers");

            hostA.SendRpc("leaveRoom");
            joinB.SendRpc("leaveRoom");
            hostC.SendRpc("leaveRoom");
            joinD.SendRpc("leaveRoom");
            Thread.Sleep(250);
            Console.WriteLine($"[PASS] AIR lobby + dual battle server E2E: rooms {roomId1}(:{tcp1}/{udp1}) & {roomId2}(:{tcp2}/{udp2}) verified");
            }
            catch (Exception ex)
            {
                string ldump; lock (lobbyOut) ldump = string.Join("\n", lobbyOut.TakeLast(30));
                throw new Exception($"{ex.Message} [hostA.Err={hostA.LastError ?? "none"} seen={string.Join(",", hostA.Events.Select(e => e.FunctionName))}]\nLobby tail:\n{ldump}", ex);
            }
        }
        finally
        {
            KillSafe(lobbyProc);
        }
    }

    private static float Dist2(PlayerEntityData a, PlayerEntityData b) => Dist2(a.X, a.Y, b.X, b.Y);
    private static float Dist2(float x1, float y1, float x2, float y2)
    {
        float dx = x1 - x2, dy = y1 - y2;
        return (float)Math.Sqrt(dx * dx + dy * dy);
    }

    private static void WaitUntil(Func<bool> cond, int timeoutMs, string desc)
    {
        var sw = Stopwatch.StartNew();
        while (sw.ElapsedMilliseconds < timeoutMs)
        {
            if (cond()) return;
            Thread.Sleep(25);
        }
        throw new Exception($"Timed out waiting for: {desc}");
    }

    private static void Assert(bool ok, string msg)
    {
        if (!ok) throw new Exception($"Assertion failed: {msg}");
    }

    private static void BuildLobbyFixture(string javaDir)
    {
        string entryClass = Path.Combine(javaDir, "LobbyLoginServer.class");
        string[] sources = Directory.GetFiles(javaDir, "*.java");
        Assert(sources.Length > 0, "Lobby Java fixture sources available");
        if (File.Exists(entryClass) && sources.All(path => File.GetLastWriteTimeUtc(path) <= File.GetLastWriteTimeUtc(entryClass)))
            return;

        var startInfo = new ProcessStartInfo("javac")
        {
            WorkingDirectory = javaDir,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        foreach (string argument in new[] { "-encoding", "UTF-8", "-d", javaDir })
            startInfo.ArgumentList.Add(argument);
        foreach (string source in sources)
            startInfo.ArgumentList.Add(source);

        using var compiler = Process.Start(startInfo) ?? throw new InvalidOperationException("Could not start javac");
        var stdout = compiler.StandardOutput.ReadToEndAsync();
        var stderr = compiler.StandardError.ReadToEndAsync();
        if (!compiler.WaitForExit(30_000))
        {
            KillSafe(compiler);
            throw new Exception("Lobby Java fixture compilation timed out");
        }
        Assert(compiler.ExitCode == 0, $"Lobby Java fixture compilation failed:\n{stdout.GetAwaiter().GetResult()}\n{stderr.GetAwaiter().GetResult()}");
    }

    private static void KillSafe(Process p)
    {
        try { if (!p.HasExited) p.Kill(entireProcessTree: true); } catch { }
    }
}
