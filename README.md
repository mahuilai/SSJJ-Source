# SSJJ-Source

《生死狙击》本地联调项目。使用 C# / .NET 10 实现权威战斗服务端，以 Java AMF3 大厅和 Python 资源网关连接本地 AIR 大厅与 Unity 战斗客户端。战斗端保留原版 `Assembly-CSharp.dll`，启动器会校验其 SHA256。

## 当前功能

- **本地双端联机**：两个大厅账号加入同频道、同房间；开局后两个 Unity 战斗窗口连接同一个房间服务端。角色身份、队伍、背包、输入和快照按会话区分。
- **局内同步**：TCP 房间和战斗信令、UDP 输入与快照、移动与连跳、受击与死亡、开火与换弹动画、计分和回合结算。
- **仓库和背包**：装备及皮肤随账号进入战斗。雷包可同时装手雷、闪光弹和烟雾弹，按 **5** 轮换，持有 C4 时按 **6** 切到 C4。
- **玩法**：团队、个人竞技、死斗、爆破、刀战、武器大师、飞刀、大头英雄、生化，以及实验性的冒险模式。各模式的覆盖范围以现有测试和协议文档为准。
- **人机频道**：本地联机和经典竞技频道的空位留给真人，人机娱乐频道按房间设置补 Bot。

## 准备环境

| 依赖 | 用途 |
| --- | --- |
| Windows x64、.NET 10 SDK | 构建 C# 项目并加载原生战斗物理库 |
| Python 3.10 或更新版本、Pillow | 启动脚本和本地 HTTP 资源网关 |
| JDK 17 或更新版本 | 构建 Java 大厅服务及运行大厅联调测试 |
| 自备兼容版本的 Unity 战斗客户端 | 默认路径为 `D:\SSJJ-4399\battle\3_64` |
| 自备 AIR 大厅和匹配的本地资源 | 大厅默认路径为 `D:\SSJJ\SSJJ-4399\Lobby`，仅在图形大厅联调时使用 |

以下命令从仓库根目录运行。现有启动配置在 `D:\逆向\SSJJ双塔惊魂` 验证；使用其他路径时请核对 `ServerConfig.cs`、启动脚本中的客户端路径以及资源位置。

```powershell
git clone https://github.com/mahuilai/SSJJ-Source.git
Set-Location SSJJ-Source
python -m pip install Pillow
```

仓库中的项目文件引用本地客户端的依赖。构建前，从你已安装且有权使用的对应客户端复制以下文件到服务端目录。原始客户端文件保留在原位。

```powershell
$gameData = 'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data'
$managedDest = 'SSJJ-Server\Assets\Plugins\Managed'
$nativeDest = 'SSJJ-Server\Assets\Plugins\x86_64'
New-Item -ItemType Directory -Force -Path $managedDest, $nativeDest | Out-Null

$managedFiles = @(
    'protobuf-net.dll', 'SSJJ.Contract.dll', 'SSJJ.Contract.Serializer.dll',
    'base.net.dll', 'configNet.dll', 'physics.net.dll',
    'weaponPredicateNet.net.dll', 'ssjj.net.dll', 'itween.net.dll'
)
foreach ($name in $managedFiles) {
    Copy-Item -LiteralPath (Join-Path "$gameData\Managed" $name) -Destination $managedDest
}

$nativeFiles = @(
    'vcruntime140.dll', 'nvToolsExt64_1.dll', 'RapidXml.dll',
    'PhysX3Common_x64.dll', 'PhysX3_x64.dll', 'PhysX3Cooking_x64.dll',
    'PhysX3CharacterKinematic_x64.dll', 'NaviProxy.dll', 'WizzardEngine.dll'
)
foreach ($name in $nativeFiles) {
    Copy-Item -LiteralPath (Join-Path "$gameData\Plugins\x86_64" $name) -Destination $nativeDest
}
```

- 战斗测试使用本机客户端的地图 BSP，并从 `Game source/06_singleplayer/tables_json/` 加载匹配版本的武器、技能及皮肤表。缺表时运行会降级，依赖原版数据的测试可能失败。
- 图形大厅还需要匹配的大厅 SWF、资源清单及资源文件。构建成功只验证代码依赖就绪。仓库默认的资源位置和故障排查见[本地运行说明](docs/LOCAL_SETUP.md)。

## 构建和测试

```powershell
dotnet build SSJJ-Server\SSJJ-Server.csproj -c Release
dotnet build SSJJ-Server\SSJJ-Server.csproj -c Debug
dotnet run --project SSJJ-Server.Tests\SSJJ-Server.Tests.csproj
dotnet run --project _work\VerifyE2E\VerifyE2E.csproj
```

`SSJJ-Server.Tests` 检查逻辑和数据表行为。`VerifyE2E` 使用测试客户端检查协议、游戏规则和多会话，包含双大厅房间及战斗桥接用例。原版窗口中的动画、资源和输入手感另做实机验证。

## 启动大厅

1. 双端启动运行 [启动大厅_双端联机.bat](启动大厅_双端联机.bat)，也可执行 `python -u _work\launch_lobby.py --local-dual`。双端启动器默认使用当前检出目录的 **Release** 战斗服。
2. 在两个大厅分别进入「本地联机频道」。第一端创建房间，第二端加入并准备。房主开局后会启动两个战斗窗口。
3. 单大厅运行 [启动大厅.bat](启动大厅.bat)。独立战斗调试器使用当前检出目录的 **Debug** 战斗服，可执行 `python -u _work\launch_server_client.py --map map12 --mode team_ai`。

本地大厅通过回环地址使用 TCP 2000、HTTP 8080 与 AIR 桥接端口 16397/16398。独立战斗服默认使用 TCP 27100、UDP 27101。大厅房间由桥接器分配战斗端口。

## 目录与开发资料

| 目录 | 内容 |
| --- | --- |
| [SSJJ-Server](SSJJ-Server/) | 战斗主循环、网络会话、物理、武器、快照、Bot 和模式规则 |
| [SSJJ-Server.Tests](SSJJ-Server.Tests/) | 单元和回归测试 |
| [_work/VerifyE2E](_work/VerifyE2E/) | 战斗和大厅协议端到端测试 |
| [_work/lobby_host](_work/lobby_host/) | Java AMF3 大厅、账号资料与 RPC 配置 |
| [docs/PROTOCOL_AUDIT.md](docs/PROTOCOL_AUDIT.md) | 协议审计和兼容行为说明 |
| [docs/LOCAL_SETUP.md](docs/LOCAL_SETUP.md) | 本地依赖、日志与常见故障 |

提交 Issue 时请附上 commit、模式、地图、复现步骤和去除账号信息后的相关日志。提交 PR 时请写明更改的行为和已运行的验证命令。

## 源码与资源

这是非官方项目。源码公开供查看，项目目前未授予通用的开源许可证。本地运行所需的原版客户端、原版资源和第三方库请从有权使用的本地安装获取。相关名称和资源的权利属于各自权利人。
