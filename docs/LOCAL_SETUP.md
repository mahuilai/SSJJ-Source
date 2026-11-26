# 本地运行说明

先按 [README](../README.md) 安装开发环境与战斗服依赖。请使用相互匹配的客户端、资源和数据表版本。

## 本地文件

| 文件或目录 | 作用 |
| --- | --- |
| `D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity.exe` | 战斗客户端 |
| `D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets` | 地图和客户端流式资源。服务端优先读取对应地图目录内的 BSP |
| `Game source/06_singleplayer/tables_json/` | 本地战斗数据表。使用与客户端版本匹配的导出数据 |
| `D:\SSJJ\SSJJ-4399\Lobby\AirLobbyPreloader.exe` 和同目录的 AIR 文件 | 图形大厅。双大厅模式还需要可创建临时副本 |
| `_work/lobby_air/` 和 `_work/lobby_host/` 下的本地资源缓存目录 | 大厅 SWF 和本地资源网关输入。实际来源见 `gateway_8080.py` |
| `D:\SSJJ\asset_mirror\Windows` | 资源网关使用的可选 Windows AssetBundle 镜像 |

如需指定本机已有的大厅 SWF，启动前同时设置路径和入口文件名：

```powershell
$env:SSJJ_LOBBY_SWF = 'D:\本地资源\大厅\已就绪的大厅文件.swf'
$env:SSJJ_LOBBY_NAME = Split-Path -Leaf $env:SSJJ_LOBBY_SWF
python -u _work\launch_lobby.py --local-dual
```

客户端 DLL 的兼容 SHA256 为 `28D8901BCEAEF5ED39000D1603F094532120EDA15D46F2AB0DEBF4C6EE45F089`。使用 PowerShell 核对：

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed\Assembly-CSharp.dll'
```

## 故障排查

| 现象 | 从哪里查起 |
| --- | --- |
| 编译报 `NetData`、`SSJJ.Data` 或找不到程序集 | 核对 `SSJJ-Server/Assets/Plugins/Managed/` 中的引用，确认使用对应客户端版本 |
| 加载 PhysX 或 BSP 失败 | 核对原生库架构与 `SSJJ-Server/Assets/Plugins/x86_64/`，以及该地图是否已安装 |
| 缺少大厅资源或大厅黑屏 | 看 `Game-SSJJ-logs/gateway.log` 的请求路径与缺失项，比较本地文件、清单、资源版本和 SWF 入口名 |
| 大厅无法开局 | 看 `Game-SSJJ-logs/server.log` 和 `_work/lobby_host/battle-bridge.log`。双端开局还应查看 `Game-SSJJ-logs/room-*/server.log` |
| 两个端看到不同对局或动作有回退 | 查看同一个房间日志目录中的两份 `client-*.log`，记录房间、玩家、武器和复现步骤 |
| 握手或端口失败 | 确认相应端口没有被上一次启动占用。战斗联调还可用 `dotnet run --project _work\VerifyE2E\VerifyE2E.csproj -- --direct-join-only` 检查握手 |

玩家资料保存在 `_work/lobby_host/user_profile*.json`。提交日志前请移除账号、会话令牌及其他本地信息。
