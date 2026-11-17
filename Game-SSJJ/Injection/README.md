# 离线入口插件（BepInEx 注入 / Unity Mono）

把官方客户端（Unity 2019.4.14f1 + Mono，非 IL2CPP）在注入期切换为**内置离线模式**：
本地资源目录 + `OfflineGameController`/`OfflineGameSetting`，免去登录/房间/服务端。
仅生成源码工程，不编译、不运行游戏、不改动游戏目录。

---

## 一、BepInEx 5.4.x (x64, Mono) 安装

1. 下载 **BepInEx 5.4.x x64 for Mono / Unity Mono** 官方 Release：
   https://github.com/BepInEx/BepInEx/releases
   （选文件名类似 `BepInEx_x64_5.4.x.x.zip`，不要选 IL2CPP 版。）
2. 解压到游戏根目录 `D:\SSJJ-4399\battle\3_64\`（与 `SSJJ_BattleClient_Unity.exe` 同级）。
   解压后应出现 `BepInEx\`、`winhttp.dll`、`doorstop_config.ini` 等。
3. 首次启动一次客户端（让 BepInEx 生成 `BepInEx\config\` 与 `BepInEx\plugins\`）。
   若启动器有反作弊/签名校验，先确认可在无注入时正常进入大厅，再放插件。
4. 关闭客户端，把编译产物 `SSJJ.OfflineEntry.dll` 放入 `BepInEx\plugins\`。

---

## 二、构建（不在此环境编译，仅给命令）

需要 .NET Framework 4.7.2  targeting pack 或 `dotnet` (>=6) 的 net472 支持。

### 用 MSBuild / Visual Studio
在 `SSJJ.OfflineEntry.csproj` 里把三个占位路径替换成实际值：
- `BepInExDir` → `D:\SSJJ-4399\battle\3_64\BepInEx\core`（含 `BepInEx.Core.dll`、`0Harmony.dll`）
- `GameManaged` → `D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed`
- `DecryptedAsm` → `D:\逆向\SSJJ双塔惊魂\Game source\01_metadata\recovered\Assembly-CSharp.decrypted.dll`

然后 `生成` / `dotnet build`。

### 用 dotnet build（传参覆盖）
```bat
dotnet build "D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Injection\SSJJ.OfflineEntry.csproj" ^
  /p:BepInExDir="D:\SSJJ-4399\battle\3_64\BepInEx\core" ^
  /p:GameManaged="D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed" ^
  /p:DecryptedAsm="D:\逆向\SSJJ双塔惊魂\Game source\01_metadata\recovered\Assembly-CSharp.decrypted.dll" ^
  /p:Configuration=Release
```
产物：`bin\Release\net472\SSJJ.OfflineEntry.dll` → 拷到 `BepInEx\plugins\`。

> 引用说明：插件只直接引用 `Assembly-CSharp`（离线类）、`UnityEngine`/`UnityEngine.CoreModule`、`BepInEx.Core`、`0Harmony`。
> `SSJJAsset_Library.dll` 由游戏在运行期加载，插件通过**反射**访问 `SSJJAsset.AssetBundle.AssetBundleManager`，
> 因此 csproj 不需要引用它（想直接引用亦可，把反射调用换成直接静态调用即可）。

---

## 三、本地 bundle 目录约定（按源码核对，非猜测）

以下规则来自 `SSJJAsset_Library` 反编译源码，是插件目录重定向的唯一依据。

### 1. 资源基址怎么算
- `SetSourceAssetBundleDirectory(relPath)`
  → `BaseDownloadingURL = "file://" + Application.streamingAssetsPath + relPath`
  - 例：`relPath = "AssetBundles/"` → `…/StreamingAssets/AssetBundles/`
  - **注意**：该方法**不追加平台名**；只有 `SetSourceAssetBundleURL` 才会补 `Windows/`。
    （所以若沿用打包产出里的 `Windows` 子目录，应传 `"AssetBundles/Windows/"`。）

### 2. 清单文件名与格式（关键，与既有误解不同）
- `AssetBundleManager.Initialize("AssetBundles", null)` 加载的清单是**文本 XML**，
  经 `WebClientStringDownloader` 下载、`XmlDocument` 解析，根节点 `<AssetBundles>`，
  每个条目 `<AssetBundle name="..." md5="..." crc="...">`。
  - **不是** Unity 资源包，也**不是** `*.manifest` 文本。
  - 清单文件名**固定为 `AssetBundles`**（无扩展名），位置 = `BaseDownloadingURL + "AssetBundles"`。
- 若 `versionHash` 非空，清单名会变成 `AssetBundles_{hash}2019.manifest`；离线模式用空 hash 即可，
  故清单名就是 `AssetBundles`。

### 3. 每个 bundle 的文件名
- 加载时 `url = BaseDownloadingURL + GetAssetBundleNameWithHash(name)`，
  而 `GetAssetBundleNameWithHash` 返回 `name + "_" + md5`。
- 因此**磁盘文件名必须是 `<逻辑名>_<md5>`**，例如 `unitymaps/map_3043_<32位md5>`。
  （Unity 默认打包不会带 md5 后缀，需要另行重命名或打包时开启 AppendHashToAssetBundleName。）
- 加载前先查缓存：`Application.persistentDataPath/Preload/<md5>/data`
  （`AssetBundleLoader.GetCachePath`）。若该 md5 已缓存则直接用缓存文件，不再请求 URL。
  故换本地包前，必要时清掉 `Preload` 下对应缓存以防命中旧数据。

### 4. 推荐目录布局
以默认 `LocalBundleRelativePath = AssetBundles/` 为例，放在客户端 StreamingAssets 下：

```
SSJJ_BattleClient_Unity_Data/
  StreamingAssets/
    AssetBundles/                      <- relPath 指向这里（结尾带 /）
      AssetBundles                     <- 文本 XML 清单（文件名固定，见第 2 节）
      unitymaps/
        map_3043_<md5hex>             <- 场景包，文件名 = 逻辑名_+md5
      （其余 bundle 同理：<逻辑名>_<md5>，按各自目录归类）
```

若沿用你已有的 `AssetBundles/Windows/` 产出目录，则：
- 设 `LocalBundleRelativePath = AssetBundles/Windows/`
- 把该自定义文本 XML 清单命名为 `AssetBundles` 放进 `AssetBundles/Windows/AssetBundles`
- bundle 文件重命名为 `Windows/unitymaps/map_3043_<md5hex>` 等

### 5. 清单 XML 示例
```xml
<?xml version="1.0" encoding="utf-8"?>
<AssetBundles>
  <AssetBundle name="unitymaps/map_3043" md5="<32位小写md5>" crc="0">
    <Dependency name="shared/shaders" />
  </AssetBundle>
  <!-- 其它 bundle 条目 … -->
</AssetBundles>
```
`name` 必须与代码里请求的逻辑名一致（地图走 `MapRuleUtility.IsUnityScene`，即 `unitymaps/map_<id>`）；
`md5` 必须等于对应 bundle 文件实际内容的 md5，且文件名 `<name>_<md5>` 与之对应；
`crc` 加载路径未强制校验，可填 0。

---

## 四、使用

| 操作 | 行为 |
|------|------|
| 启动客户端后按 **F9** | 重定向本地资源目录 → 重新加载本地清单 → 调用 `OfflineGameController.InitOfflineData()` 进入离线战斗（默认 SceneId=3043，双塔惊魂） |

配置项（首次运行后生成于 `BepInEx\config\ssjj.offline.entry.cfg`）：
`Player` / `Hand` / `Weapon` / `SceneId` / `LocalBundleRelativePath`。
示例见 `bepinex.cfg.example`。

> 说明：`OfflineGameController.Start()` 是 Unity 协程，组件加上的第一帧会自己跑（含 `InitResourceUrl` 把基址指回 HTTP）。
> 插件在 F9 后等 1~2 帧，再覆盖为本地目录并重新 `Initialize`，确保最后生效的是本地清单。
> 因此不要在 `Awake` 立刻调 `InitOfflineData`。

---

## 五、已知风险 / 未验证项

- **环境检测**：客户端含运行期环境检测逻辑，可能在非原版运行环境下行为异常或拒绝继续。
  本插件仅做注入与本地资源目录重定向，不涉及任何检测规避；如遇检测拦截需另行评估。
- **`BattleLoading` 场景**：离线流程首帧 `LoadSceneAsync("BattleLoading")`，该场景必须存在于原客户端
  （已确认存在，故注入方案可行）。
- **bundle 版本兼容**：本地 bundle 须与 2019.4 系列兼容；你用 2019.4.11f1 打包，原客户端为 2019.4.14f1，
  微小版本差可能引发布局/序列化差异，需运行时确认。
- **资源完整性**：离线模式仅挂了战斗房间相关模块，缺包会卡在 `AssetBundleManager` 加载；
  地图（map_3043）、角色/武器/UI 等 bundle 必须齐备，且 md5/文件名规则与上一致。
- **重入**：重复按 F9 已做 `_booted` 守卫；但首次 `Initialize` 与 `OfflineGameController.Start()` 内的
  HTTP `Initialize` 存在竞态（同静态清单字段），属已知小瑕疵，开发调试用可接受。
- **未验证**：本地 XML 清单与 bundle 的具体 md5 / 依赖项是否与你打包产出完全对应，需运行时日志确认
  （关注 `AssetBundleManager` 的 `Loading Asset Bundle …` 与可能的 `not exist in AssetBundleManifest` 报错）。
```
