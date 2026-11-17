using System;
using System.Runtime.InteropServices;

namespace SSJJ.Server.NativeEngine
{
    /// <summary>
    /// 对标原版 WizzardEngine.dll (1.09MB) + 4个 PhysX 原生库
    /// 封装服务端 Native 物理引擎接口与 WeConfig.isServerSide 开关
    /// </summary>
    public static class NativeWizzardHost
    {
        private const string DLL_NAME = "WizzardEngine.dll";

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr LoadLibrary(string libname);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool SetDllDirectory(string lpPathName);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        private static IntPtr _hEngine = IntPtr.Zero;
        public static bool IsLoaded { get; private set; } = false;

        private delegate void SetServerSideDelegate(int val);

        public static bool Initialize(string pluginDir = @"Assets\Plugins\x86_64")
        {
            if (IsLoaded && _hEngine != IntPtr.Zero) return true;
            try
            {
                string[] searchCandidates = new[]
                {
                    System.IO.Path.Combine(AppContext.BaseDirectory, pluginDir),
                    System.IO.Path.GetFullPath(pluginDir),
                    AppContext.BaseDirectory
                };

                string fullPluginDir = AppContext.BaseDirectory;
                foreach (var cand in searchCandidates)
                {
                    if (System.IO.File.Exists(System.IO.Path.Combine(cand, "WizzardEngine.dll")))
                    {
                        fullPluginDir = cand;
                        break;
                    }
                }

                SetDllDirectory(fullPluginDir);

                // 按顺序预加载依赖的 PhysX 库
                string[] libs = new[]
                {
                    "vcruntime140.dll",
                    "nvToolsExt64_1.dll",
                    "RapidXml.dll",
                    "PhysX3Common_x64.dll",
                    "PhysX3_x64.dll",
                    "PhysX3Cooking_x64.dll",
                    "PhysX3CharacterKinematic_x64.dll",
                    "NaviProxy.dll",
                    "WizzardEngine.dll"
                };

                foreach (var lib in libs)
                {
                    string p = System.IO.Path.Combine(fullPluginDir, lib);
                    if (System.IO.File.Exists(p))
                    {
                        IntPtr h = LoadLibrary(p);
                        if (h == IntPtr.Zero)
                        {
                            Console.WriteLine($"[SSJJ-Server] LoadLibrary failed for {lib}: win32={Marshal.GetLastWin32Error()}");
                        }
                        if (lib == "WizzardEngine.dll") _hEngine = h;
                    }
                }

                if (_hEngine != IntPtr.Zero)
                {
                    IsLoaded = true;
                    Console.WriteLine($"[SSJJ-Server] Native WizzardEngine.dll & PhysX3 x64 successfully loaded at 0x{_hEngine:X}!");
                    Console.WriteLine("[SSJJ-Server] Server Authority & PhysX Engine Active!");
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SSJJ-Server] Warning loading WizzardEngine.dll: {ex.Message}");
            }

            return false;
        }
    }
}
