using System;
using System.IO;
using System.Reflection;
using UnityEngine;

/// <summary>
/// 单机版启动器（壳工程）。
/// 目标：本工程只负责“启动 + 装配”，游戏逻辑仍用原客户端的托管程序集与资源包。
///
/// 目录约定：
///   StreamingAssets/Managed/   放原始 Managed DLL（含解密后的 Assembly-CSharp.dll、Magic.dll）
///   StreamingAssets/Bundles/   放 AssetBundle（tables、角色、武器、地图）
/// </summary>
public class BootLoader : MonoBehaviour
{
    [Header("启动参数")]
    public bool autoStartOffline = true;
    public int sceneId = 0;
    public string player = "police";
    public string hand = "man";
    public string weapon = "dagger";

    private string _managedDir;
    private string _status = "初始化…";
    private bool _ready;

    private void Awake()
    {
        _managedDir = Path.Combine(Application.streamingAssetsPath, "Managed");
        AppDomain.CurrentDomain.AssemblyResolve += ResolveFromManaged;
        Application.logMessageReceived += (msg, stack, type) =>
        {
            if (type == LogType.Error || type == LogType.Exception)
                Debug.Log("[SSJJ-SP] " + msg);
        };
    }

    private Assembly ResolveFromManaged(object sender, ResolveEventArgs args)
    {
        try
        {
            var simple = new AssemblyName(args.Name).Name;
            var path = Path.Combine(_managedDir, simple + ".dll");
            if (File.Exists(path)) return Assembly.LoadFrom(path);
        }
        catch (Exception e)
        {
            Debug.LogWarning("[SSJJ-SP] resolve fail " + args.Name + " : " + e.Message);
        }
        return null;
    }

    private void Start()
    {
        Debug.Log("[SSJJ-SP] Start. managed=" + _managedDir + " exists=" + Directory.Exists(_managedDir));
        if (!Directory.Exists(_managedDir))
        {
            _status = "缺少 StreamingAssets/Managed（把原客户端 Managed 拷进来）";
            Debug.LogError("[SSJJ-SP] " + _status);
            return;
        }

        try
        {
            var asmPath = Path.Combine(_managedDir, "Assembly-CSharp.dll");
            if (!File.Exists(asmPath))
            {
                _status = "缺少 Assembly-CSharp.dll（先用 decrypt_managed.py 解密）";
                Debug.LogError("[SSJJ-SP] " + _status);
                return;
            }

            // 注意：壳工程自己的脚本也编译成 Assembly-CSharp.dll，LoadFrom 会命中原有程序集（同名去重），
            // 所以这里必须用内存加载，才能拿到游戏那份 Assembly-CSharp。
            var asm = Assembly.Load(File.ReadAllBytes(asmPath));
            Debug.Log("[SSJJ-SP] assembly loaded: " + asm.FullName);
            try
            {
                var types = asm.GetTypes();
                var names = new System.Text.StringBuilder();
                for (int i = 0; i < types.Length && i < 6; i++) names.Append(types[i].FullName).Append(", ");
                Debug.Log("[SSJJ-SP] types=" + types.Length + " first=" + names);
                for (int i = 0; i < types.Length; i++)
                {
                    if (types[i].Name == "GameController")
                    {
                        Debug.Log("[SSJJ-SP] found GameController -> " + types[i].FullName);
                        break;
                    }
                }
            }
            catch (ReflectionTypeLoadException rtle)
            {
                Debug.Log("[SSJJ-SP] GetTypes partial: " + (rtle.Types == null ? 0 : rtle.Types.Length));
                if (rtle.LoaderExceptions != null && rtle.LoaderExceptions.Length > 0)
                    Debug.Log("[SSJJ-SP] first loader ex: " + rtle.LoaderExceptions[0].Message);
            }
            var gameControllerType = asm.GetType("GameController");
            Debug.Log("[SSJJ-SP] GameController type: " + (gameControllerType != null));
            if (gameControllerType == null)
            {
                _status = "Assembly-CSharp 里找不到 GameController";
                return;
            }

            var go = GameObject.Find("GameController") ?? new GameObject("GameController");
            DontDestroyOnLoad(go);

            Debug.Log("[SSJJ-SP] adding GameController component");
            // 先把联网控制器挂上（Awake 里会设置 Instance，离线控制器继承它）
            if (go.GetComponent(gameControllerType) == null)
                go.AddComponent(gameControllerType);
            Debug.Log("[SSJJ-SP] GameController component added");

            if (autoStartOffline)
                StartCoroutine(StartOfflineNextFrame(asm, go));

            _status = "已装配 GameController，等待离线启动";
            _ready = true;
        }
        catch (Exception e)
        {
            _status = "装配失败: " + e.Message;
            Debug.LogException(e);
        }
    }

    private System.Collections.IEnumerator StartOfflineNextFrame(Assembly asm, GameObject go)
    {
        yield return null; // 等 GameController.Awake

        var offlineType = asm.GetType("OfflineGameController");
        var settingType = asm.GetType("OfflineGameSetting");
        if (offlineType == null || settingType == null)
        {
            _status = "找不到 OfflineGameController / OfflineGameSetting";
            yield break;
        }

        var online = go.GetComponent("GameController") as Behaviour;
        if (online != null) online.enabled = false;

        if (go.GetComponent(offlineType) == null) go.AddComponent(offlineType);
        var setting = go.GetComponent(settingType) ?? go.AddComponent(settingType);

        SetField(setting, "TurnOn", true);
        SetField(setting, "SceneId", sceneId);
        SetField(setting, "Player", player);
        SetField(setting, "Hand", hand);
        SetField(setting, "Weapon", weapon);

        yield return null; // 等 OfflineGameController.Start 里的 BattleLoading 协程

        var init = offlineType.GetMethod("InitOfflineData", BindingFlags.Public | BindingFlags.Instance);
        if (init != null)
        {
            init.Invoke(go.GetComponent(offlineType), null);
            _status = "已调用 InitOfflineData（scene=" + sceneId + "）";
        }
        else _status = "OfflineGameController.InitOfflineData 不存在";
    }

    private static void SetField(object obj, string name, object value)
    {
        var f = obj.GetType().GetField(name, BindingFlags.Public | BindingFlags.Instance);
        if (f != null) f.SetValue(obj, value);
    }

    private void OnGUI()
    {
        GUI.Box(new Rect(10, 10, 620, 76), "");
        GUI.Label(new Rect(22, 18, 600, 24), "SSJJ 单机壳工程 · " + _status);
        GUI.Label(new Rect(22, 44, 600, 34),
            _ready ? "F9 手动重试离线启动" : "请把原客户端 Managed 与 Bundles 放进 StreamingAssets");
    }
}
