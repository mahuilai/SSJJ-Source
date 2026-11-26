using System;
using System.Collections.Generic;
using System.IO.Compression;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;

namespace SSJJUserCmd
{
    public static class ButtonConstant
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
        public const int Q = 16384;
        public const int Y = 32768;
        public const int Showgun = 65536;
    }

    public static class CmdFieldMask
    {
        public const int MaskFrameInterval = 1;
        public const int MaskMove = 2;
        public const int MaskButton = 4;
        public const int MaskBagWeapon = 8;
        public const int MaskYaw = 16;
        public const int MaskPitch = 32;
        public const int MaskRenderDiff = 64;
        public const int MaskRender = 128;
    }
}

namespace SSJJ.Server.Network
{
    using SSJJUserCmd;
    public sealed class DecodedUserCmd
    {
        public int Seq { get; set; }
        public int RenderTime { get; set; }
        public int LatestSnapSeq { get; set; }
        public int FrameInterval { get; set; } = 16;
        public int MoveForward { get; set; }   // 0=none, 1=forward, 255(-1)=backward (sbyte)
        public int MoveRight { get; set; }     // 0=none, 1=right, 255(-1)=left (sbyte)
        public int Buttons { get; set; }
        public int BagId { get; set; } = 1;
        public int WeaponSlot { get; set; } = 1;
        public float Yaw { get; set; }
        public float Pitch { get; set; }
    }

    /// <summary>
    /// UDP 帧同步与 Snapshot 广播网关（支持 Method 0 P2P Probe、Method 1 Zlib Snapshot、Method 2 / TCP 31 UserCmd2 差分链解析）
    /// </summary>
    public sealed class UdpSyncGateway
    {
        private readonly ClientSessionRegistry _sessions;
        private readonly int _port;
        private readonly IPAddress _bindAddr;
        private UdpClient? _udp;
        private volatile bool _running;
        private int _loggedProbe;
        private int _loggedUserCmd;

        public UdpSyncGateway(ClientSessionRegistry sessions, int port = 27101, IPAddress? bindAddress = null)
        {
            _sessions = sessions;
            _port = port;
            _bindAddr = bindAddress ?? BindPolicy.Resolve();
        }

        public bool HasClientEndpoint => _sessions.Snapshot().Any(s => s.UdpEndPoint != null);

        public void Start()
        {
            _running = true;
            _udp = new UdpClient(new IPEndPoint(_bindAddr, _port));
            try
            {
                // Windows SIO_UDP_CONNRESET disable to avoid ICMP port unreachable exceptions
                const int SIO_UDP_CONNRESET = -1744830452;
                _udp.Client.IOControl((IOControlCode)SIO_UDP_CONNRESET, new byte[] { 0, 0, 0, 0 }, null);
            }
            catch { }
            Console.WriteLine($"[SSJJ-Server] UDP Sync Gateway listening on {BindPolicy.Describe(_bindAddr)}:{_port}");
            Task.Run(ReceiveLoop);
        }

        private async Task ReceiveLoop()
        {
            while (_running && _udp != null)
            {
                try
                {
                    var result = await _udp.ReceiveAsync();
                    ProcessUdpPacket(result.Buffer, result.RemoteEndPoint);
                }
                catch when (!_running)
                {
                    break;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[SSJJ-Server] UDP Receive warn: {ex.Message}");
                }
            }
        }

        private void ProcessUdpPacket(byte[] data, IPEndPoint sender)
        {
            if (data == null || data.Length < 9) return;
            // Client -> Server UDP framing: [4B BE len][4B BE ConnId][1B MethodId][body...]
            int offset = 0;
            if (ReadIntBE(data, ref offset) != data.Length - 4) return;
            int connectionId = ReadIntBE(data, ref offset);
            int methodId = data[8];
            if (methodId != 0 && methodId != 2) return;
            if (methodId == 0 && data.Length is not (10 or 11)) return;

            ClientSession? session = _sessions.ResolveUdp(connectionId, sender, probe: methodId == 0);
            if (session == null) return;

            if (methodId == 0) // P2P Probe -> reply 6 bytes: [spliced=0, compressed=1, udpSize=1400 BE]
            {
                if (System.Threading.Interlocked.Exchange(ref _loggedProbe, 1) == 0)
                {
                    Console.WriteLine($"[SSJJ-Server][UDP] Recv P2P Probe from {sender} (len={data.Length}, cid={connectionId}) -> sending 6-byte P2PData ack");
                }
                byte[] body = new byte[] { 0, 1, 0x00, 0x00, 0x05, 0x78 };
                byte[] ack = BuildServerUdpFrame(0, body);
                try { _udp?.Send(ack, ack.Length, sender); } catch { }
            }
            else if (methodId == 2) // OnUserCmd2
            {
                var batch = DecodeUserCmd2Chain(data, 9, data.Length - 9);
                if (System.Threading.Interlocked.Exchange(ref _loggedUserCmd, 1) == 0)
                {
                    Console.WriteLine($"[SSJJ-Server][UDP] First UserCmd2 packet from {sender}: len={data.Length}, decoded={batch.Count}");
                }
                session.EnqueueCommands(batch);
            }
        }

        public static void HandleTcpUserCmd2(ClientSession session, byte[] content)
        {
            if (content == null || content.Length < 15) return;
            // TCP 31 starts with 1 byte (31) before Latency
            int offset = content[0] == 31 ? 1 : 0;
            var batch = DecodeUserCmd2Chain(content, offset, content.Length - offset);
            session.EnqueueCommands(batch);
        }

        /// <summary>
        /// 1:1 还原 SendUserCommandSystem.GetUserCmdBytes 的多帧冗余差分编码解码
        /// </summary>
        public static List<DecodedUserCmd> DecodeUserCmd2Chain(byte[] buf, int offset, int count)
        {
            var result = new List<DecodedUserCmd>(5);
            int end = Math.Min(buf.Length, offset + count);
            int pos = offset;
            // Header: [1B latency][4B seq][4B renderTime][4B latestSnapSeq] = 13 bytes
            if (pos + 13 >= end) return result;

            pos += 1; // latency
            int seq = ReadIntBE(buf, ref pos);
            int renderTime = ReadIntBE(buf, ref pos);
            int snapSeq = ReadIntBE(buf, ref pos);

            var prev = new DecodedUserCmd
            {
                Seq = seq,
                RenderTime = renderTime,
                LatestSnapSeq = snapSeq
            };

            bool isFirst = true;
            while (pos < end)
            {
                int mask = buf[pos++];
                int frameInterval = prev.FrameInterval;
                int moveFwd = prev.MoveForward;
                int moveRight = prev.MoveRight;
                int buttons = prev.Buttons;
                int bagId = prev.BagId;
                int wpn = prev.WeaponSlot;
                float yaw = prev.Yaw;
                float pitch = prev.Pitch;
                int rt = prev.RenderTime + frameInterval;

                if ((mask & CmdFieldMask.MaskFrameInterval) != 0)
                {
                    if (pos >= end) break;
                    frameInterval = buf[pos++];
                    if (!isFirst) rt = prev.RenderTime + frameInterval;
                }
                if ((mask & CmdFieldMask.MaskMove) != 0)
                {
                    if (pos + 2 > end) break;
                    moveFwd = (sbyte)buf[pos++];
                    moveRight = (sbyte)buf[pos++];
                }
                if ((mask & CmdFieldMask.MaskButton) != 0)
                {
                    if (pos + 4 > end) break;
                    buttons = ReadIntBE(buf, ref pos);
                }
                if ((mask & CmdFieldMask.MaskBagWeapon) != 0)
                {
                    if (pos >= end) break;
                    byte bw = buf[pos++];
                    bagId = (bw >> 5) & 0x07;
                    wpn = bw & 0x1F;
                }
                if ((mask & CmdFieldMask.MaskYaw) != 0)
                {
                    if (pos + 2 > end) break;
                    yaw = ReadShortBE(buf, ref pos) / 100f;
                }
                if ((mask & CmdFieldMask.MaskPitch) != 0)
                {
                    if (pos + 2 > end) break;
                    pitch = ReadShortBE(buf, ref pos) / 100f;
                }
                if ((mask & CmdFieldMask.MaskRenderDiff) != 0)
                {
                    if (pos >= end) break;
                    rt = prev.RenderTime + (sbyte)buf[pos++];
                }
                else if ((mask & CmdFieldMask.MaskRender) != 0)
                {
                    if (!isFirst)
                    {
                        if (pos + 4 > end) break;
                        rt = ReadIntBE(buf, ref pos);
                    }
                    else
                    {
                        rt = renderTime;
                    }
                }

                var cmd = new DecodedUserCmd
                {
                    Seq = isFirst ? seq : prev.Seq + 1,
                    RenderTime = rt,
                    LatestSnapSeq = snapSeq,
                    FrameInterval = frameInterval,
                    MoveForward = moveFwd,
                    MoveRight = moveRight,
                    Buttons = buttons,
                    BagId = bagId,
                    WeaponSlot = wpn,
                    Yaw = yaw,
                    Pitch = pitch
                };
                result.Add(cmd);
                prev = cmd;
                isFirst = false;
            }

            return result;
        }

        public bool SendSnapshot(ClientSession session, byte[] rawSnapshotBytes)
        {
            IPEndPoint? ep = session.UdpEndPoint;
            if (!session.IsSpawned || ep == null || _udp == null || rawSnapshotBytes == null || rawSnapshotBytes.Length == 0)
                return false;

            try
            {
                using var compMs = new MemoryStream();
                // 5-byte UDP snapshot prefix expected by SnapshotUtility.SnapShotDeCompress (num=5)
                compMs.Write(new byte[5], 0, 5);
                using (var z = new ZLibStream(compMs, CompressionLevel.Fastest, leaveOpen: true))
                {
                    z.Write(rawSnapshotBytes, 0, rawSnapshotBytes.Length);
                }
                byte[] body = compMs.ToArray();
                byte[] frame = BuildServerUdpFrame(1, body);
                _udp.Send(frame, frame.Length, ep);
                return true;
            }
            catch (SocketException) { return false; }
            catch (ObjectDisposedException) { return false; }
        }

        private static byte[] BuildServerUdpFrame(int methodId, byte[] body)
        {
            int bodyLen = body?.Length ?? 0;
            // Server -> Client UdpPacket.Unpack expects: [4B BE len][1B MethodId][body...]
            byte[] packet = new byte[5 + bodyLen];
            int totalAfterLen = 1 + bodyLen;
            packet[0] = (byte)((totalAfterLen >> 24) & 0xFF);
            packet[1] = (byte)((totalAfterLen >> 16) & 0xFF);
            packet[2] = (byte)((totalAfterLen >> 8) & 0xFF);
            packet[3] = (byte)(totalAfterLen & 0xFF);
            packet[4] = (byte)methodId;
            if (body != null && bodyLen > 0)
            {
                Array.Copy(body, 0, packet, 5, bodyLen);
            }
            return packet;
        }

        private static int ReadIntBE(byte[] buf, ref int pos)
        {
            int v = (buf[pos] << 24) | (buf[pos + 1] << 16) | (buf[pos + 2] << 8) | buf[pos + 3];
            pos += 4;
            return v;
        }

        private static short ReadShortBE(byte[] buf, ref int pos)
        {
            short v = (short)((buf[pos] << 8) | buf[pos + 1]);
            pos += 2;
            return v;
        }

        public void Stop()
        {
            _running = false;
            try { _udp?.Close(); } catch { }
        }
    }
}
