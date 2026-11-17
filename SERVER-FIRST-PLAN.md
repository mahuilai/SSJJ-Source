# 路线重定：服务端优先（Server-First）

> 2026-11-16 22:35  
> 触发原因：在客户端/武器层逐个还原技能，等于把半个游戏重写一遍，没有收敛点。  
> 本文档是**决策与排期**，不是实现记录。所有数字来自磁盘实测。

---

## 1. 结论先行

老板的判断成立：**技能、特效、AI、结算都在服务端，客户端只是表现层。**

证据（都在源码里，可复核）：

| 事实                                                         | 文件                                                                                      |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| 267 个包处理器，覆盖 285 个客户端→服务端 methodId + 100 个服务端→客户端 methodId | `Assets.Sources.Systems.PacketHandle.Handlers`、`Assets.Sources.Networking.Packet\*.cs`  |
| 技能由包驱动                                                     | `BiozSkillHandler`、`CrazeSkillChooseHandler`、`CrazeSkillLearnHandler`                   |
| 特效的创建/显示/更新/删除全由包驱动                                        | `Assets.Sources.Free.Effect\{EffectCreate,EffectShow,EffectUpdate,EffectDelete}Handler` |
| UI 提示字段由包写入                                                | `GameTipsShowHandler.cs:268` → `rpgTreasureBossData.topTipsId = data.TypeId`            |
| UDP 只有 3 个命令                                               | `ServerUdpMethod.cs`：`P2P=0`、`OnUserCmd=1`、`OnUserCmd2=2`                               |

所以「在 MC 里一件武器一件武器还原技能」这条路，等于把 267 个消息的语义在另一个引擎里重写一遍——**方向错了，不是效率问题**。

---

## 2. 先把目标定死（两条路互斥）

|       | A. MC 武器还原（TaCZ 路线） | B. SSJJ 离线版（服务端路线）       |
| ----- | ------------------- | ------------------------ |
| 目标    | 在 MC 里玩到血魔 AWM      | 原版客户端 + 本地服务端，完整离线       |
| 复用    | 我们的逆向数据 + TaCZ 渲染   | 原版客户端（不改）+ 自写服务端         |
| 技能/特效 | 要一个个手写              | 补完协议自动生效                 |
| 工作量   | 每把枪线性增长             | 前 50 条消息很重，之后递减          |
| 当前状态  | 几何卡住，未成功成像          | 已有物理/网络骨架（16 文件/2,674 行） |
| 适合    | 只要几把枪、想在 MC 里玩      | 要完整体验、愿意投 2-4 周          |

**我的判断**：老板要的是「离线版/单人版」，选 **B**。A 线保留为副产品（数据层已经做完，随时可回）。

如果只是「MC 里能玩血魔」，那不要碰服务端，继续修 TaCZ 那条渲染链就行——但那条已经证明是硬骨头（见 `HANDOVER-GPT.md`）。

---

## 3. 协议面实测（决定工作量的硬数字）

```
ClientTcpMethod.cs   285 个 methodId   客户端 → 服务端
ServerTcpMethod.cs   100 个 methodId   服务端 → 客户端
ServerUdpMethod.cs     4 个             P2P / OnUserCmd / OnUserCmd2 / InvalidConnectId
Handlers             267 个 .cs        每个对应一类包
```

关键结构判断：

- **实时同步走 UDP，且只有一个 `OnUserCmd`**。移动、开火、技能释放很可能都塞在这一个包的 payload 里，按内部子类型分。**这是服务端第一个要逆的东西**。
- 业务逻辑（登录、房间、进图、结算、技能树、商店）全走 TCP，**285 个方法里绝大多数可以后置**。
- `ClientTcpMethod.IgnoreTcpList = {203,124,213,242,31,259,260,261,262}` —— 客户端主动忽略的 9 个方法，可以排除。

---

## 4. 范围收敛：只做「最小可玩主链」

不要 285 个全做。第一版目标：

> **单张地图（map1）+ 单人 + 9 个 bot + 能出生、能跑、能开枪、能打死人、能死、能复活、能结束一局。**

按这个目标，主链只需要 **约 50 个消息**（P0+P1），不是 285 个。

| 阶段     | 内容                                               | 消息量（估） | 验收标准               |
| ------ | ------------------------------------------------ | ------ | ------------------ |
| **P0** | 连接：Policy → Login → TcpConnectionId → OnGameInit | ~10    | 客户端能进到主界面、不卡连接     |
| **P1** | 进图：房间/匹配 → 加载 → 出生 → 玩家列表                        | ~12    | 能进 map1，能看到自己和 bot |
| **P2** | 同步：快照/位置/朝向/AOI                                  | ~8     | 别人动，你屏幕上也在动        |
| **P3** | 战斗：OnUserCmd（移动+开火）→ Pmove → 命中判定 → 伤害/死亡/复活     | ~15    | 能打死 bot，能被 bot 打死  |
| **P4** | 结算：比分、回合结束、房间生命周期                                | ~8     | 一局能正常结束回到房间        |
| **P5** | 技能/特效/商店/皮肤                                      | 30–50  | 按需，逐把武器开           |

**P0–P4 完成 = 可玩的离线版骨架**，这时才谈技能。技能不需要"还原"，只需要服务端按同样的包下发。

---

## 5. 现有资产怎么用

### 5.1 已有的服务端骨架（`D:\逆向\SSJJ双塔惊魂\SSJJ-Server`）

```
16 个 .cs / 2,674 行
src/Network/{TcpBattleGateway,UdpSyncGateway,BindPolicy}.cs   ← TCP/UDP 入口已有
src/Physics/{Quake3Pmove,ClipMap}.cs                          ← Quake3 移动/碰撞，可直接用
src/QuakeServer/{G_Active,G_Combat}.cs                        ← 服务端主循环/战斗
src/Bots/{BotAgent,BotDirector,BotTelemetry}.cs                ← bot
src/Snapshot/*                                                ← 快照
src/NativeEngine/{NativeBspPhysicsHost,NativeWizzardHost}.cs   ← BSP/原生引擎桥
```

实测覆盖：

```
OnUserCmd 1 个文件 · Snapshot 10 · Hit 4 · Damage 4 · Dead 8 · Respawn 2 · Login 1 · Room 1
Skill 0 · Effect 0
```

**结论**：这是个「能跑物理和 bot 的 Quake 风格内核」，但**业务协议几乎没接**（Room/Login 各 1 个文件，技能特效 0）。  
所以不是从零，也不是"做了一坨屎"——是**内核有了、协议层没铺**。新计划就是铺协议层。

### 5.2 客户端源码的正确用法

不是拿来编译，是拿来当**接口契约**：

1. `Assets.Sources.Networking.Packet\ClientTcpMethod.cs` → 服务端要实现的 methodId 全表（285）
2. `Handlers\*.cs` → 每个包客户端在等什么字段（`data.Xxx` 赋给哪个组件）
3. `Assets.Sources.Networking.Packet` 里的包体 → protobuf 结构（字段号/类型）
4. `Assets.Sources.Components.GameRule.*` → 服务端该维护哪些状态
5. `GameTipsShowHandler` 这类 → 反推服务端**主动下发**清单

### 5.3 数据表

`Game source\...\tables_json\Weapon.json` 等 1,445 行武器表、散布/后坐/技能参数，服务端判定直接用，不用逆。

---

## 6. 技术攻坚点（按风险排序）

| # | 难点                     | 为什么难                       | 应对                                      |
| - | ---------------------- | -------------------------- | --------------------------------------- |
| 1 | `OnUserCmd` payload 结构 | 移动/开火/技能共用一个 UDP 包，内部子类型未知 | 反编译客户端 `UserCmd` 序列化代码 + 抓包对照           |
| 2 | 快照格式                   | 服务端→客户端的位置/状态二进制           | 反编译 `SnapshotByTcp` 的读端，按读端写端           |
| 3 | 登录/握手                  | 可能有加密/时间戳/票据               | 先跑通明文，再补校验；客户端可 Harmony 跳过              |
| 4 | 命中判定权威                 | 客户端只发开火，服务端算命中             | 复用 `G_Combat` + 武器表参数                   |
| 5 | 地图/碰撞                  | BSP 私有格式                   | 已有 `NativeBspPhysicsHost`、`Quake3Pmove` |
| 6 | 反作弊/心跳                 | 可能拒绝非常规客户端                 | 抓正常客户端包对齐时序                             |



---

## 7. 止损点（必须先约定）

- **P0 阶段**：如果 2 天内连不上（登录/握手过不去），停下来重新评估，不要硬啃加密。
- **P2 阶段**：如果快照格式 3 天逆不出来，改用「客户端 Harmony 绕过渲染同步、只做本地模拟」的降级方案。
- **P5 阶段**：技能只做老板要的那几把，不做全量。

---

## 8. 立刻可做的三步（不等结论）

1. **protocol-mapper（进行中）**：把 267 个 handler 分级成 P0/P1/P2，产出 `SERVER-HANDLER-MAP.md`。
2. **逆 `OnUserCmd`**：反编译客户端 `UdpSyncGateway` 对端 + `UserCmd` 结构，产出字段表。
3. **对齐现有服务端**：把 `SSJJ-Server/src/Network` 的消息循环与 `ClientTcpMethod` 的 285 个 ID 建映射表，标出已实现/未实现。

---

## 9. 一句话

**不是"重做半个游戏"，是"把已有内核的协议层铺完"。**  
先铺 50 条主链，离线版就能跑；技能是后面按需开，不是前置。
