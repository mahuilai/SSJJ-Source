using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace VerifyE2E;

internal static class MiniAmf3
{
    public static byte[] EncodeApc(string functionName, params object?[] parameters)
    {
        var obj = new Dictionary<string, object?>
        {
            ["functionName"] = functionName,
            ["parameters"] = new List<object?>(parameters)
        };
        return Encode(obj);
    }

    public static byte[] Encode(object? value)
    {
        using var ms = new MemoryStream(256);
        WriteValue(ms, value);
        return ms.ToArray();
    }

    public static object? Decode(byte[] data)
    {
        var dec = new Decoder(data);
        return dec.ReadValue();
    }

    private static void WriteValue(MemoryStream ms, object? value)
    {
        switch (value)
        {
            case null:
                ms.WriteByte(0x01);
                break;
            case bool b:
                ms.WriteByte(b ? (byte)0x03 : (byte)0x02);
                break;
            case int i:
                if (i >= -(1 << 28) && i < (1 << 28))
                {
                    ms.WriteByte(0x04);
                    WriteU29(ms, i & 0x1FFFFFFF);
                }
                else
                {
                    ms.WriteByte(0x05);
                    WriteDouble(ms, i);
                }
                break;
            case long l:
                if (l >= -(1L << 28) && l < (1L << 28))
                {
                    ms.WriteByte(0x04);
                    WriteU29(ms, (int)(l & 0x1FFFFFFF));
                }
                else
                {
                    ms.WriteByte(0x05);
                    WriteDouble(ms, l);
                }
                break;
            case double d:
                ms.WriteByte(0x05);
                WriteDouble(ms, d);
                break;
            case float f:
                ms.WriteByte(0x05);
                WriteDouble(ms, f);
                break;
            case string s:
                ms.WriteByte(0x06);
                WriteStringBody(ms, s);
                break;
            case IList<object?> list:
                ms.WriteByte(0x09);
                WriteU29(ms, (list.Count << 1) | 1);
                WriteStringBody(ms, "");
                foreach (var item in list) WriteValue(ms, item);
                break;
            case IDictionary<string, object?> map:
                ms.WriteByte(0x0A);
                WriteU29(ms, 0x0B); // inline dynamic anonymous object, 0 sealed
                WriteStringBody(ms, "");
                foreach (var kv in map)
                {
                    if (string.IsNullOrEmpty(kv.Key)) continue;
                    WriteStringBody(ms, kv.Key);
                    WriteValue(ms, kv.Value);
                }
                WriteStringBody(ms, "");
                break;
            default:
                throw new NotSupportedException($"Unsupported AMF3 type: {value.GetType()}");
        }
    }

    private static void WriteStringBody(MemoryStream ms, string s)
    {
        if (string.IsNullOrEmpty(s))
        {
            WriteU29(ms, 1);
            return;
        }
        byte[] utf8 = Encoding.UTF8.GetBytes(s);
        WriteU29(ms, (utf8.Length << 1) | 1);
        ms.Write(utf8, 0, utf8.Length);
    }

    private static void WriteU29(MemoryStream ms, int val)
    {
        uint v = (uint)val & 0x1FFFFFFFu;
        if (v < 0x80) ms.WriteByte((byte)v);
        else if (v < 0x4000)
        {
            ms.WriteByte((byte)(((v >> 7) & 0x7F) | 0x80));
            ms.WriteByte((byte)(v & 0x7F));
        }
        else if (v < 0x200000)
        {
            ms.WriteByte((byte)(((v >> 14) & 0x7F) | 0x80));
            ms.WriteByte((byte)(((v >> 7) & 0x7F) | 0x80));
            ms.WriteByte((byte)(v & 0x7F));
        }
        else
        {
            ms.WriteByte((byte)(((v >> 22) & 0x7F) | 0x80));
            ms.WriteByte((byte)(((v >> 15) & 0x7F) | 0x80));
            ms.WriteByte((byte)(((v >> 8) & 0x7F) | 0x80));
            ms.WriteByte((byte)(v & 0xFF));
        }
    }

    private static void WriteDouble(MemoryStream ms, double v)
    {
        ulong bits = (ulong)BitConverter.DoubleToInt64Bits(v);
        for (int i = 7; i >= 0; i--)
        {
            ms.WriteByte((byte)((bits >> (i * 8)) & 0xFF));
        }
    }

    private sealed class Decoder
    {
        private readonly byte[] _data;
        private int _pos;
        private readonly List<string> _stringRefs = new();
        private readonly List<object?> _objectRefs = new();
        private readonly List<(string ClassName, bool Dynamic, bool Externalizable, List<string> Sealed)> _traitRefs = new();

        public Decoder(byte[] data) => _data = data;

        public object? ReadValue()
        {
            int marker = ReadU8();
            return marker switch
            {
                0x00 or 0x01 => null,
                0x02 => false,
                0x03 => true,
                0x04 => ReadInt(),
                0x05 => ReadDouble(),
                0x06 => ReadString(),
                0x07 or 0x0B => ReadXml(),
                0x08 => ReadDate(),
                0x09 => ReadArray(),
                0x0A => ReadObject(),
                0x0C => ReadByteArray(),
                _ => throw new InvalidDataException($"Unsupported AMF3 marker 0x{marker:X2} at {_pos - 1}")
            };
        }

        private int ReadU8() => _pos < _data.Length ? _data[_pos++] : throw new EndOfStreamException();

        private int ReadU29()
        {
            int result = 0;
            for (int i = 0; i < 4; i++)
            {
                int b = ReadU8();
                if (i == 3) return (result << 8) | b;
                result = (result << 7) | (b & 0x7F);
                if ((b & 0x80) == 0) return result;
            }
            return result;
        }

        private int ReadInt()
        {
            int v = ReadU29();
            if ((v & 0x10000000) != 0) v |= unchecked((int)0xE0000000);
            return v;
        }

        private double ReadDouble()
        {
            long bits = 0;
            for (int i = 0; i < 8; i++) bits = (bits << 8) | (uint)ReadU8();
            return BitConverter.Int64BitsToDouble(bits);
        }

        private string ReadString()
        {
            int header = ReadU29();
            if ((header & 1) == 0) return _stringRefs[header >> 1];
            int len = header >> 1;
            if (len == 0) return "";
            if (_pos + len > _data.Length) throw new EndOfStreamException();
            string s = Encoding.UTF8.GetString(_data, _pos, len);
            _pos += len;
            _stringRefs.Add(s);
            return s;
        }

        private string ReadXml()
        {
            int header = ReadU29();
            if ((header & 1) == 0) return _objectRefs[header >> 1]?.ToString() ?? "";
            int len = header >> 1;
            string s = Encoding.UTF8.GetString(_data, _pos, len);
            _pos += len;
            _objectRefs.Add(s);
            return s;
        }

        private object? ReadDate()
        {
            int header = ReadU29();
            if ((header & 1) == 0) return _objectRefs[header >> 1];
            double ms = ReadDouble();
            _objectRefs.Add(ms);
            return ms;
        }

        private byte[] ReadByteArray()
        {
            int header = ReadU29();
            if ((header & 1) == 0) return (byte[])(_objectRefs[header >> 1] ?? Array.Empty<byte>());
            int len = header >> 1;
            var arr = new byte[len];
            Buffer.BlockCopy(_data, _pos, arr, 0, len);
            _pos += len;
            _objectRefs.Add(arr);
            return arr;
        }

        private object? ReadArray()
        {
            int header = ReadU29();
            if ((header & 1) == 0) return _objectRefs[header >> 1];
            int denseCount = header >> 1;
            var list = new List<object?>(denseCount);
            int refIdx = _objectRefs.Count;
            _objectRefs.Add(list);
            var assoc = new Dictionary<string, object?>();
            while (true)
            {
                string k = ReadString();
                if (k.Length == 0) break;
                assoc[k] = ReadValue();
            }
            for (int i = 0; i < denseCount; i++) list.Add(ReadValue());
            if (assoc.Count == 0) return list;
            if (denseCount > 0) assoc["$dense"] = list;
            _objectRefs[refIdx] = assoc;
            return assoc;
        }

        private object? ReadObject()
        {
            int header = ReadU29();
            if ((header & 1) == 0) return _objectRefs[header >> 1];

            (string ClassName, bool Dynamic, bool Externalizable, List<string> Sealed) trait;
            if ((header & 3) == 1)
            {
                trait = _traitRefs[header >> 2];
            }
            else
            {
                bool ext = (header & 4) != 0;
                bool dyn = (header & 8) != 0;
                int sealedCount = header >> 4;
                string cls = ReadString();
                var sealedNames = new List<string>(sealedCount);
                for (int i = 0; i < sealedCount; i++) sealedNames.Add(ReadString());
                trait = (cls, dyn, ext, sealedNames);
                _traitRefs.Add(trait);
            }

            var obj = new Dictionary<string, object?>();
            _objectRefs.Add(obj);
            if (!string.IsNullOrEmpty(trait.ClassName)) obj["$class"] = trait.ClassName;
            if (trait.Externalizable)
            {
                obj["$value"] = ReadValue();
                return obj;
            }
            foreach (var name in trait.Sealed) obj[name] = ReadValue();
            if (trait.Dynamic)
            {
                while (true)
                {
                    string k = ReadString();
                    if (k.Length == 0) break;
                    obj[k] = ReadValue();
                }
            }
            return obj;
        }
    }
}

internal sealed record LobbyRpcEvent(string FunctionName, List<object?> Parameters);

internal sealed class LobbyWireClient : IDisposable
{
    private readonly TcpClient _tcp = new();
    private readonly NetworkStream _stream;
    private readonly object _sendLock = new();
    private volatile bool _running = true;

    public readonly ConcurrentQueue<LobbyRpcEvent> Events = new();
    public string? LastError { get; private set; }

    public LobbyWireClient(string host, int port)
    {
        _tcp.Connect(host, port);
        _stream = _tcp.GetStream();
        new Thread(ReadLoop) { IsBackground = true }.Start();
    }

    public void SendRpc(string fn, params object?[] args)
    {
        byte[] amf = MiniAmf3.EncodeApc(fn, args);
        int len = amf.Length + 1;
        var frame = new byte[4 + len];
        frame[0] = (byte)(len >> 24);
        frame[1] = (byte)(len >> 16);
        frame[2] = (byte)(len >> 8);
        frame[3] = (byte)len;
        frame[4] = 0; // uncompressed
        Buffer.BlockCopy(amf, 0, frame, 5, amf.Length);
        lock (_sendLock)
        {
            _stream.Write(frame, 0, frame.Length);
            _stream.Flush();
        }
    }

    private void ReadLoop()
    {
        try
        {
            var hdr = new byte[4];
            while (_running)
            {
                if (!ReadExact(hdr, 4)) break;
                int len = (hdr[0] << 24) | (hdr[1] << 16) | (hdr[2] << 8) | hdr[3];
                if (len <= 0 || len > 16 * 1024 * 1024) break;
                var body = new byte[len];
                if (!ReadExact(body, len)) break;
                byte flag = body[0];
                var payload = new byte[len - 1];
                Buffer.BlockCopy(body, 1, payload, 0, payload.Length);
                if (flag == 1)
                {
                    using var src = new MemoryStream(payload, 2, Math.Max(0, payload.Length - 2));
                    using var ds = new DeflateStream(src, CompressionMode.Decompress);
                    using var outMs = new MemoryStream();
                    ds.CopyTo(outMs);
                    payload = outMs.ToArray();
                }
                if (MiniAmf3.Decode(payload) is Dictionary<string, object?> map)
                {
                    string fn = map.TryGetValue("functionName", out var fObj) && fObj != null ? fObj.ToString() ?? "" : "";
                    var pList = map.TryGetValue("parameters", out var pObj) && pObj is List<object?> list ? list : new List<object?>();
                    if (!string.IsNullOrEmpty(fn)) Events.Enqueue(new LobbyRpcEvent(fn, pList));
                }
            }
        }
        catch (Exception ex)
        {
            if (_running) LastError = ex.ToString();
        }
    }

    private bool ReadExact(byte[] buf, int count)
    {
        int read = 0;
        while (read < count)
        {
            int n = _stream.Read(buf, read, count - read);
            if (n <= 0) return false;
            read += n;
        }
        return true;
    }

    public void Dispose()
    {
        _running = false;
        try { _stream.Dispose(); } catch { }
        try { _tcp.Dispose(); } catch { }
    }
}
