# SSJJ 战斗快照协议审计

此前公开版本的 267 项客户端处理器扫描见 [历史清单](PROTOCOL_HANDLER_MATRIX.md)。下文记录当前主目录的实际行为。

## 本地双大厅联机

运行 `启动大厅_双端联机.bat` 后，两个 AIR 大厅分别使用本地适配端口 16397 和 16398，并连接同一个 Java AMF3 大厅。第二个本地账号使用独立存档 `_work/lobby_host/user_profile_local_2.json`。第二个 AIR 应用从临时副本启动，使两个窗口可以同时存在。

两个大厅都进入「本地联机频道」。房主创建房间，另一端在同频道房间列表加入并准备。房主开始游戏后，桥接器只启动一个多人战斗服，并按两个大厅席位分别生成原版 Unity 启动令牌。「本地联机频道」和「经典竞技频道」的空位保留给真人，「人机娱乐频道」才按房间容量补 Bot。两个战斗窗口关闭后返回大厅。

`LobbyProtocol` 注册的频道进入成功回调是 `callEnterChannelSuccess`。登录 socket 的独立令牌随 `enterChannel(token, channelId)` 绑定到新建的频道 socket，房间列表使用 `bean.ClientRoom`，进入已创建房间使用 `bean.RoomInfoEx`。战斗服沿用大厅房间号、角色 ID、昵称和对局阵营，监听回环地址。桥接器默认启动当前检出目录中 `SSJJ-Server/bin/Release/net10.0/` 下的战斗服。

房间详情与列表都发送 `gameLimitNumber`。原版 `RoomMediator.drawPlayerListBg` 根据它绘制两边的可用席位背景，超出容量的位置保持灰色。

## 真人与 Bot 的死亡动画

原版 `AnimationConstantUtility` 将 `LEGS_DIE`（11）和 `TORSO_DIE`（19）解析为 `head`，将 42 和 43 分别解析为 `headshot` 和 `headshot_f`。`police` 使用 `manCT`，`pandora_t` 使用 `woman`。两个动画包都含有这三个片段，腿部状态 59 查找的 `die_b` 在这两个包中缺失。普通受击致死发 `11/19`，爆头正面及侧面发 `42/42`，后半球来袭发 `43/43`。

两份角色资源的 `model.DAE.action` 为普通倒地指定第 200 至 260 帧，为两种爆头倒地指定第 0 至 27 帧。`DefaultCareerAnimInfo` 按包含首尾的帧数读取，`AnimationDesc.TotalTime` 计算出 2033 ms 和 933 ms。服务端在致死帧记录 `TorsoAnimStartTime`，清除速度和 `Moving`，从零开始推进 `LegsSpeedAnimTime`、`DeadTimer` 和两层剩余时间。剩余时间归零后持续发送非循环死亡状态，直到复活或新回合清除两层动画状态。死者的后续输入继续确认命令序号，角色朝向保持致死帧的值。

原版 `DefaultCareerAnimInfo` 将 `animWarps` 子节点直接转换为 `XmlElement`。旧版 `manCT` 和 `woman` 各有两处 XML 注释会触发 `InvalidCastException`。资源网关发现已校验 MD5 和大小的兼容版本时更新清单的 MD5、CRC 和大小。两组资源的 `leg.anm`、`torso.anm` 及上述死亡帧区间逐项相同。原版客户端 DLL 和资源文件保持原样。

`SSJJ-Server.Tests` 覆盖真人和 Bot 的普通致死、正面/侧面/背后爆头、两层同步、末帧及复活复位。`VerifyE2E` 在刀战房从 UDP 解码同一 Bot 死亡的播放期及末帧，校验服务端时钟、两层剩余时间和静止状态。
