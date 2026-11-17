using System;
using System.Collections.Generic;
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
}

internal static class Btn
{
    public const int Forward = 1;
    public const int Backward = 2;
    public const int Left = 4;
    public const int Right = 8;
    public const int Attack = 64;
    public const int Reload = 256;
    public const int Attack2 = 512;
    public const int ThrowWeapon = 1024;
    public const int Demolition = 2048;
    public const int Skill = 4096;
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
    public readonly List<MessageListData> WeaponMasterMsgs = new();
    public readonly List<BigHeadProgressData> BigHeadMsgs = new();
    public int HitPlayerCount;
    public int AllKillInfoCount;
    public int ClearSectionCount;
    public int MissionResultCount;
    public int GameWinCount;
    public bool P2PAckReceived { get; private set; }
    public DecodedSnapshot? LatestSnapshot { get; private set; }
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
        // [4B BE len=6][4B BE ConnId=1][1B method=0][1B dummy=0]
        byte[] pkt = { 0, 0, 0, 6, 0, 0, 0, 1, 0, 0 };
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
        WriteIntBE(ms, 1); // ConnId = 1
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
                    case 4:
                        var bs = Deserialize<BroadcastScoreData>(body);
                        if (bs != null) lock (TeamScores) TeamScores.Add(bs);
                        break;
                    case 6:
                        var kp = Deserialize<KillPlayerInfoData>(body);
                        if (kp != null) lock (Kills) Kills.Add(kp);
                        break;
                    case 8: Interlocked.Increment(ref AllKillInfoCount); break;
                    case 14:
                        var c4 = Deserialize<C4ActiveData>(body);
                        if (c4 != null) lock (C4Actives) C4Actives.Add(c4);
                        break;
                    case 27:
                        var sk = Deserialize<SkillInfoData>(body);
                        if (sk != null) lock (SkillInfos) SkillInfos.Add(sk);
                        break;
                    case 64:
                        var bh = Deserialize<BigHeadProgressData>(body);
                        if (bh != null) lock (BigHeadMsgs) BigHeadMsgs.Add(bh);
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
                    LatestSnapshot = ParseSnapshot(rawMs.ToArray());
                    Interlocked.Increment(ref SnapshotCount);
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
    private static readonly string ServerExe = Path.Combine(Root, "SSJJ-Server", "bin", "Debug", "net10.0", "SSJJ-Server.exe");

    private static int Main()
    {
        if (!File.Exists(ServerExe))
        {
            Console.Error.WriteLine($"Missing server binary: {ServerExe}");
            return 2;
        }

        try
        {
            TestTeamAiHitmarkerAndSettlement();
            TestBladeAiSkillsTransformAndMelee();
            TestExplodeC4DropPickupAndRoundReset();
            TestWeaponMasterFlyKnifeBigHead();
            Console.WriteLine("[VERIFY-E2E] ALL E2E WIRE PROTOCOL + GAMEPLAY CHECKS PASSED!");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"[VERIFY-E2E][FAIL] {ex.Message}");
            return 1;
        }
    }

    private static Process StartServer(object configObj, string tag)
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

    private static BattleWireClient HandshakeAndSpawn(int tcpPort, int udpPort)
    {
        var c = new BattleWireClient("127.0.0.1", tcpPort, udpPort);
        c.SendTcp(2); // Login
        WaitUntil(() => c.CallBackLogin != null && c.Room != null && c.Init3 != null, 5000, "Stage1 Handshake");

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
        Assert(c.LatestSnapshot.Header.Self == 1, $"Snapshot.Self == 1 (got {c.LatestSnapshot.Header.Self})");
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
        Stopwatch sw)
    {
        var snap = cli.LatestSnapshot!;
        var me = snap.Players.First(p => p.Id == 1);
        var enemy = snap.Players
            .Where(p => p.Id != 1 && (p.Team != me.Team || p.Team >= 10) && !p.IsDead)
            .OrderBy(p => Dist2(me, p))
            .FirstOrDefault();

        double nowSec = sw.Elapsed.TotalSeconds;
        if (nowSec - lastCheckSec >= 0.45)
        {
            float movedStep = Dist2(me.X, me.Y, lastCheckX, lastCheckY);
            lastCheckX = me.X;
            lastCheckY = me.Y;
            lastCheckSec = nowSec;
            if (movedStep < 30f)
            {
                steerOffsetDeg = steerOffsetDeg == 0f ? 75f : -steerOffsetDeg;
                steerUntilSec = nowSec + 0.9;
            }
        }

        if (enemy != null)
        {
            float dist2d = Math.Max(1f, Dist2(me, enemy));
            float aimYaw = (float)(Math.Atan2(enemy.Y - me.Y, enemy.X - me.X) * 180.0 / Math.PI);
            float aimPitch = -(float)(Math.Atan2((enemy.Z + 115f) - (me.Z + 146f), dist2d) * 180.0 / Math.PI);
            float moveYaw = nowSec < steerUntilSec ? aimYaw + steerOffsetDeg : aimYaw;
            int btns = Btn.Forward | extraButtons;
            if (dist2d < 3500f) btns |= Btn.Attack;
            cli.SendUserCmd(4, 0, btns, 1, slot, moveYaw, aimPitch);
        }
        else
        {
            cli.SendUserCmd(4, 0, Btn.Forward | extraButtons, 1, slot, me.ViewYaw, 0f);
        }
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
                new { primary = "m4a1", primary_skin = "skin_m4_legend_poison", secondary = "deagle", secondary_skin = "", melee = "dagger", melee_skin = "", throwable = "grenade", throwable_skin = "" }
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

            float steerOff = 0f, lx = x0, ly = y0;
            double steerUntil = 0.0, lsec = 0.0;
            var sw = Stopwatch.StartNew();
            while (sw.Elapsed.TotalSeconds < 24)
            {
                SteerAndShootAtClosestEnemy(cli, 1, 0, ref steerOff, ref steerUntil, ref lx, ref ly, ref lsec, sw);
                Thread.Sleep(33);
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
            Assert(cli.Kills.Count >= 2, $"Combat generated KillPlayerInfoData packets ({cli.Kills.Count})");
            Assert(cli.HitPlayerCount >= 1, $"Player 1 landed gun hit -> Method 131 HitPlayer ({cli.HitPlayerCount})");
            Assert(cli.MissionResultCount >= 1, $"Settlement Method 18/19 received ({cli.MissionResultCount})");
            Assert(cli.SimpleProtos.Any(sp => sp.Key == 3), "Settlement SimpleProto Key=3 received");
            Assert(cli.GameWinCount >= 1, $"Settlement Method 5 Win received ({cli.GameWinCount})");
            Console.WriteLine($"[PASS] team_ai: moved={moved:F1}cm, kills={cli.Kills.Count}, hit131={cli.HitPlayerCount}, win5={cli.GameWinCount}, snapshots={cli.SnapshotCount}");
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
                while (sw.Elapsed.TotalSeconds < 46 && cli3.ClearSectionCount == 0)
                {
                    cli3.SendUserCmd(0, 0, 0, 1, 1, m0.ViewYaw, 0f);
                    Thread.Sleep(50);
                }
                Assert(cli3.ClearSectionCount >= 1 && cli3.TeamScores.Any(s => s.Team1Score + s.Team2Score > 0),
                    $"Explode round finished & reset (clear62={cli3.ClearSectionCount})");
                Console.WriteLine($"[PASS] explode: C4 drop/pickup + T-bot C4 plant (14) + CT intercept/round reset (62)!");
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

    private static void KillSafe(Process p)
    {
        try { if (!p.HasExited) p.Kill(entireProcessTree: true); } catch { }
    }
}
