using System;
using System.Net;

namespace SSJJ.Server.Network
{
    /// <summary>
    /// 监听地址策略（M2 · P0-10）。
    ///
    /// 背景：修复前 TCP 27100 / UDP 27101 / Java 2000 三个端口全部绑 0.0.0.0，
    /// 且全程零鉴权、Java 侧 RPC 还能派生进程 —— 局域网任意主机可直接接管整套服务。
    ///
    /// 策略：默认只绑回环（单机离线场景本就只需本机可达）；
    /// 需要局域网联机时显式设置环境变量 SSJJ_BIND_ADDR=0.0.0.0 放开。
    /// </summary>
    public static class BindPolicy
    {
        public const string EnvVar = "SSJJ_BIND_ADDR";

        public static IPAddress Resolve()
        {
            var raw = Environment.GetEnvironmentVariable(EnvVar);
            if (string.IsNullOrWhiteSpace(raw)) return IPAddress.Loopback;
            raw = raw.Trim();
            if (raw == "0.0.0.0" || raw == "*" || raw.Equals("any", StringComparison.OrdinalIgnoreCase))
                return IPAddress.Any;
            if (raw == "::" || raw.Equals("ipv6any", StringComparison.OrdinalIgnoreCase))
                return IPAddress.IPv6Any;
            return IPAddress.TryParse(raw, out var ip) ? ip : IPAddress.Loopback;
        }

        public static string Describe(IPAddress addr)
        {
            if (addr.Equals(IPAddress.Loopback))
                return "127.0.0.1 (loopback only; set " + EnvVar + "=0.0.0.0 to allow LAN)";
            return addr.ToString();
        }
    }
}
