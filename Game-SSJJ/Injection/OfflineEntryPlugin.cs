// SSJJ 离线入口插件（BepInEx 5 / Unity Mono）
//
// 作用（工程语言）：
//   在官方客户端注入期把 AssetBundle 资源目录重定向到本地，触发内置的离线模式
//   （OfflineGameController + OfflineGameSetting），省去登录/房间/服务端连接。
//
// 设计要点（来自源码核对，非猜测）：
//   * SSJJAsset.AssetBundle.AssetBundleManager.SetSourceAssetBundleDirectory(relPath)
//        -> BaseDownloadingURL = "file://" + Application.streamingAssetsPath + relPath
//        （注意：该方法不追加平台名；而 SetSourceAssetBundleURL 才会追加 "Windows/"）
//   * AssetBundleManager.Initialize("AssetBundles", null) 加载的是【文本 XML 清单】
//        （经 WebClientStringDownloader 下载、XmlDocument 解析 <AssetBundles><AssetBundle name md5 crc>），
//        不是 Unity 资源包，也不是 *.manifest 文本。清单文件名固定为 "AssetBundles"。
//   * 每个 bundle 的下载/文件名 = BaseDownloadingURL + name + "_" + md5
//        （即磁盘上文件名必须是 <逻辑名>_<md5>），加载前先查缓存
//        Application.persistentDataPath/Preload/<md5>/data。
//   因此 SetSourceAssetBundleDirectory 之后，必须重新 Initialize 才能用本地清单覆盖 HTTP 清单。
//
// 依赖：仅引用 Assembly-CSharp（离线类型）与 UnityEngine；SSJJAsset_Library 由游戏在运行期加载，
//       本插件用反射访问 AssetBundleManager（见下方 CallAbm 辅助方法）。
//       如需改为直接引用，可把 SSJJAsset_Library.dll 加入 csproj，并把反射调用换成直接调用。

using System;
using System.Collections;
using System.Reflection;
using BepInEx;
using BepInEx.Configuration;
using UnityEngine;

namespace SSJJ.OfflineEntry
{
    [BepInPlugin("ssjj.offline.entry", "SSJJ Offline Entry", "1.0.0")]
    public class OfflineEntryPlugin : BaseUnityPlugin
    {
        // ---- 配置 ----
        private ConfigEntry<string> _player;
        private ConfigEntry<string> _hand;
        private ConfigEntry<string> _weapon;
        private ConfigEntry<int> _sceneId;
        private ConfigEntry<string> _localBundleRelPath;

        private bool _booted;

        // SSJJAsset_Library 中的 AssetBundleManager 全名（运行期反射定位）。
        // 若要直接引用，改为 using SSJJAsset.AssetBundle; 并直接调用静态方法即可。
        private const string AbmTypeName = "SSJJAsset.AssetBundle.AssetBundleManager, SSJJAsset_Library";

        private void Awake()
        {
            _player = Config.Bind("Offline", "Player", "police", "角色资源名（police / terrorist …）");
            _hand = Config.Bind("Offline", "Hand", "man", "手臂资源名");
            _weapon = Config.Bind("Offline", "Weapon", "dagger", "初始武器");
            _sceneId = Config.Bind("Offline", "SceneId", 3043, "场景 id（MapRuleUtility.IsUnityScene 约定 3000<=id<5000 走 unitymaps/map_<id>）");
            _localBundleRelPath = Config.Bind("Offline", "LocalBundleRelativePath", "AssetBundles/",
                "本地 bundle 相对 StreamingAssets 的目录（结尾带 /）。清单文件名固定为 AssetBundles（文本 XML）。" +
                "若沿用打包产出里的 Windows 子目录，可改为 AssetBundles/Windows/，并把清单 XML 放到该目录下名为 AssetBundles 的文件。");

            Logger.LogInfo("SSJJ Offline Entry 已加载。按 F9 进入离线战斗（SceneId=" + _sceneId.Value + "）。");
        }

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.F9))
            {
                try
                {
                    StartOffline();
                }
                catch (Exception ex)
                {
                    // 不吞异常：必须上报，方便定位离线启动失败原因。
                    Logger.LogError("F9 离线启动失败: " + ex);
                }
            }
        }

        private void StartOffline()
        {
            if (_booted)
            {
                Logger.LogWarning("离线模式已启动，忽略重复触发。");
                return;
            }

            // 1) 找到（或新建）挂 GameController 的 GameObject
            var go = GameObject.Find("GameController");
            if (go == null)
            {
                go = new GameObject("GameController");
                DontDestroyOnLoad(go);
                Logger.LogInfo("新建 GameController GameObject。");
            }

            // 2) 关掉联网的 GameController，挂离线控制器（与 TestBattleServer 研发按钮一致）
            var online = go.GetComponent<GameController>();
            if (online != null)
            {
                online.enabled = false;
                Logger.LogInfo("已禁用联网 GameController。");
            }

            if (go.GetComponent<OfflineGameController>() == null)
            {
                go.AddComponent<OfflineGameController>();
            }

            var setting = go.GetComponent<OfflineGameSetting>();
            if (setting == null)
            {
                setting = go.AddComponent<OfflineGameSetting>();
            }

            // 3) 填充离线配置
            setting.TurnOn = true;
            setting.SceneId = _sceneId.Value;
            setting.Player = _player.Value;
            setting.Hand = _hand.Value;
            setting.Weapon = _weapon.Value;
            setting.X = setting.Y = setting.Z = 0f;
            Logger.LogInfo($"离线配置: SceneId={setting.SceneId} Player={setting.Player} Hand={setting.Hand} Weapon={setting.Weapon}");

            // 4) 用协程等 OfflineGameController.Start()（异步加载 BattleLoading 的启动协程）
            //    真正跑完，再确认/执行离线资源与数据初始化。
            StartCoroutine(BootOfflineRoutine(go));
        }

        // OfflineGameController.Start() 是协程：先 LoadSceneAsync("BattleLoading")，再
        // InitBootConfigFromCommand / InitResourceUrl / InitAssetBundleManager / 建 ECS，
        // 最后 AutoStartOffline -> InitOfflineData 并把 InitFinish 置真。
        // 固定等两帧时这些都没跑完，随后 InitResourceUrl 还会把本地目录覆盖回 HTTP。
        private const float BootTimeoutSeconds = 60f;

        private IEnumerator BootOfflineRoutine(GameObject go)
        {
            var offline = go.GetComponent<OfflineGameController>();
            if (offline == null)
            {
                Logger.LogError("未找到 OfflineGameController 组件，无法确认离线初始化状态。");
                yield break;
            }

            // ---- 等控制器自己的启动协程真正跑完（以 InitFinish 为准，而不是数帧）----
            float deadline = Time.realtimeSinceStartup + BootTimeoutSeconds;
            while (!offline.InitFinish && Time.realtimeSinceStartup < deadline)
            {
                yield return null;
            }

            if (offline.InitFinish)
            {
                // 离线版 Assembly-CSharp 的 Start() 里 AutoStartOffline 已经完成资源重定向与 InitOfflineData，
                // 再调一次会重复建实体/快照，因此这里只确认状态。
                _booted = true;
                Logger.LogInfo($"离线启动完成（OfflineGameController.InitFinish）: scene={_sceneId.Value} player={_player.Value}");
                yield break;
            }

            Logger.LogWarning($"等待 OfflineGameController 初始化超时（{BootTimeoutSeconds:F0}s），改为插件侧手动初始化。");

            // ---- 手动兜底：重定向本地目录 + 重新加载本地清单 ----
            string error = null;
            IEnumerator initEnum = null;
            try
            {
                CallAbm("SetSourceAssetBundleDirectory",
                        new object[] { _localBundleRelPath.Value },
                        new[] { typeof(string) });
                Logger.LogInfo("已将 AssetBundle 资源目录重定向到本地: " + _localBundleRelPath.Value);
                // Initialize("AssetBundles", null) -> 清单 URL = BaseDownloadingURL + "AssetBundles"（文本 XML）。
                initEnum = (IEnumerator)CallAbm("Initialize",
                    new object[] { "AssetBundles", null },
                    new[] { typeof(string), typeof(string) });
            }
            catch (Exception ex)
            {
                error = ex.ToString();
            }

            if (error != null)
            {
                Logger.LogError("本地资源初始化失败: " + error);
                yield break;
            }

            // yield return 不能放在带 catch 的 try 块内（CS1626），所以上面只做调用、这里做等待。
            if (initEnum != null)
            {
                yield return initEnum;
            }

            // 再等一帧，给清单文本下载/解析留时间（file:// 很快，但保险起见）。
            yield return null;

            try
            {
                offline.InitOfflineData();
                _booted = true;
                Logger.LogInfo($"离线启动完成（插件兜底）: scene={_sceneId.Value} player={_player.Value} weapon={_weapon.Value}");
            }
            catch (Exception ex)
            {
                Logger.LogError("调用 InitOfflineData 失败: " + ex);
            }
        }

        // ---------------------------------------------------------------
        // 反射访问 SSJJAsset.AssetBundle.AssetBundleManager（运行期由游戏加载）。
        // 若改为直接引用 SSJJAsset_Library.dll，可删除本方法并直接调用对应静态方法。
        // ---------------------------------------------------------------
        private static object CallAbm(string methodName, object[] args, Type[] paramTypes)
        {
            var t = Type.GetType(AbmTypeName, false);
            if (t == null)
            {
                throw new InvalidOperationException(
                    "未能在已加载程序集中找到 " + AbmTypeName +
                    "（游戏是否未加载 SSJJAsset_Library.dll？请确认 BepInEx 插件加载顺序）。");
            }
            var m = (paramTypes == null) ? t.GetMethod(methodName) : t.GetMethod(methodName, paramTypes);
            if (m == null)
            {
                throw new MissingMethodException(AbmTypeName, methodName);
            }
            return m.Invoke(null, args);
        }
    }
}
