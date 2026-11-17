# SSJJ-Server 评估（2026-11-17 10:30）

## 定位

这不是"重写半个游戏"，是**用原版 DLL 当库、只补服务端逻辑**的实现。架构选对了。

`SSJJ-Server.csproj` 直接引用原版程序集：
```
SSJJ.Contract.dll            ← 协议结构体（protobuf-net 契约）
SSJJ.Contract.Serializer.dll ← ProtobufSerializer，业务包序列化
base.net.dll / configNet.dll ← 基础/配置
physics.net.dll              ← PhysX 物理
weaponPredicateNet.net.dll   ← 原版武器预测
ssjj.net.dll / itween.net.dll
```
意味着协议结构不用逆、物理不用重写、武器判定可以直接调原版。

规模：**23 个 .cs / 5,737 行**，`bin/Debug/net10.0/SSJJ-Server.exe` 构建于 **11-17 09:56**（可编译）。

---

## 已实现（有代码为证）

| 模块 | 文件 | 说明 |
|---|---|---|
| 主循环 | `Program.cs` 20,426 B | 初始化物理/表/bot/模式/网关；每帧解析 cmd → 步进玩家 → tick bot → 发快照 |
| TCP 握手 | `Network/TcpBattleGateway.cs` 19,654 B | Method **1** CallbackLogin → **1000** TcpConnectionID → **12** RoomData → **3** OnGameinit → **44** GameServerSetup → **232** PlayerLoginOnInit → **9** PlayerLogin → **13** StartNewSection + GetRoomInfoAck |
| UDP 同步 | `Network/UdpSyncGateway.cs` 12,437 B | `DecodedUserCmd` 字段与客户端 `SendUserCommandSystem` 编码**完全对应**；支持 P2P Probe / Zlib Snapshot / UserCmd2 差分链 |
| 快照 | `Snapshot/SV_Snapshot.cs` 15,052 B | `SerializeSnapshot(...)` → `udp.SendSnapshot` |
| 物理 | `Physics/OfficialPhysicsWorld.cs` 20,626 B + `Quake3Pmove.cs` + `ClipMap.cs` | 走原版 `physics.net`，不是自写 |
| BSP | `Config/BspMapData.cs` + `Bots/BspNavGraph.cs` | 地图加载 + 导航图 |
| Bot | `Bots/BotDirector.cs` + `BotAgent.cs` 18,578 B | 有 telemetry、有目标点（`modeCoord.GetBotObjectiveFor`） |
| 技能/特效 | `QuakeServer/SkillAndVfxSystem.cs` 11,700 B | `ProcessCommand`（技能按键）→ `ApplySkillGameplayEffect` → `EmitWeaponSkillEffect` 下发 |
| 模式 | `GameModes/ModeCoordinator.cs` 25,832 B | 爆破 C4（planted/dropped/defusing）、个人、刀战、武器大师、飞刀、大头；比分/胜负 |
| 武器切换 | `Program.cs:407 ApplyWeaponSlotSwitch` | Bag/WeaponSlot → 当前武器 |

---

## 缺口

1. **协议覆盖窄**：`TcpBattleGateway` 只处理 8 个 methodId，客户端 `ClientTcpMethod` 有 285 个。主链够用，但房间/结算/商店/活动全缺。
2. **未见完整一局日志**：`Game-SSJJ-logs/` 里的 `server.log` / `gateway.log` 是**大厅服务**（AIR/Flash 资源代理 + ProfileManager RPC）的，不是战斗服务端。战斗端日志在控制台，没落盘。
3. **267 个 handler 没逐项对照**：`protocol-mapper` 正在产出 `SERVER-HANDLER-MAP.md`，出来后可以精确算覆盖率。
4. **技能只做了"能触发"，没做"全武器"**：`EmitWeaponSkillEffect` 依赖 `WeaponSkillTable`，具体覆盖几把枪未统计。
5. **没有自动化验收**：缺"启动 → 连上 → 进图 → 击杀 → 结算"的脚本化验证。

---

## 建议的验证顺序

```powershell
# 1. 冷启动，确认握手链全绿
cd D:\逆向\SSJJ双塔惊魂\SSJJ-Server
.\bin\Debug\net10.0\SSJJ-Server.exe --map map1 --bots 9

# 2. 客户端连，看控制台是否依次出现
#    Method 1 → 1000 → 12 → 3 → 44 → 232 → 9 → 13

# 3. 进图后按顺序验证
#    能看到 bot / bot 会动 / 能开枪 / 能打死 / 能被打死 / 比分变化

# 4. 落盘日志（现在只在控制台）
#    建议把 Console.WriteLine 同时写 logs\battle-YYYYMMDD.log
```

---

## 结论

**这套服务端不是"一坨屎"，是主链已经通了、协议层只铺了 8 条。**
架构（复用原版 DLL）是最省力的一条路，方向没问题。
下一步不是"再逆什么"，而是：
1. 用 `SERVER-HANDLER-MAP.md` 的 P0 清单，把主链缺的 methodId 补上；
2. 把战斗日志落盘，跑一局拿证据；
3. 技能按 `WeaponSkillTable` 统计覆盖率，缺的逐把补。
