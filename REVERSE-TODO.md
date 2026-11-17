# 还需要逆什么（清单与优先级）

> 2026-11-16 22:55
> 前提：走「服务端优先」路线（见 `SERVER-FIRST-PLAN.md`）。
> 本文只列**还缺的东西**，已完成的单独列一节，避免重复劳动。

---

## 0. 一个必须先纠正的认知

**客户端源码里没有服务端。** 没有一份"藏起来的服务端源码"等着被反编译出来。

客户端里只有两样东西：
1. **协议契约**：methodId 表、包体结构、Buttons 位、UserCmd 编码
2. **客户端预测**：`*PredicationSystem`（733 个 `*System.cs` 里的一部分），它按服务端规则在本地先算一遍

所以"反推服务端"准确说法是：**按契约把服务端实现出来**，不是找回源码。
这也决定了工作量——是"照图纸施工"，不是"搬一套现成的"。

---

## 1. 重要发现：有两套源码，之前看的是不全的那套

| 目录 | 规模 | 组织 | 完整度 |
|---|---|---|---|
| `Game-SSJJ-Source\Assets\Decompiled` | 5,629 .cs / 888,773 行 | 全平铺 | **缺类型**：`PlayerEntityData`、`BinaryDataWriter` 都没有 |
| `Game source\02_managed_src` | **62 个程序集 / 11,267 .cs / 1,481,252 行** | 按程序集分目录 | **基本齐全** |

关键类型实际位置：
```
Game source\02_managed_src\SSJJ.Contract\NetData\PlayerEntityData.cs
Game source\02_managed_src\SSJJBase_Library\SSJJBase.Utility\BinaryDataWriter.cs
Game source\02_managed_src\Assembly-CSharp\Assets.Sources.Snapshots\Snapshot.cs
Game source\02_managed_src\Assembly-CSharp\Assets.Generated.Table\WeaponSkillTable.cs
```

**结论：不需要再跑反编译工具了，换到 `02_managed_src` 找。** 之前"找不到某类型"多半是因为在扁平版里翻。

---

## 2. 已经逆完的（可以直接写代码，不用再查）

| 项 | 证据位置 | 产出 |
|---|---|---|
| **UserCmd 二进制编码** | `Assembly-CSharp\Assets.Sources.Systems.UserCommand\SendUserCommandSystem.cs` `GetUserCmdBytes()` | 完整布局，见下 |
| **Buttons 位掩码** | `AbstractFireAction.cs:63/67`、`ComputeUserCommandSystem.cs:117/164`、`JudgeEyeRifle1:53` | 0x10/0x20/0x40/0x80/0x200/0x800/0x10000/0x40000000 |
| **Snapshot 字段表** | `Assembly-CSharp\Assets.Sources.Snapshots\Snapshot.cs` | 40+ 个 `Dictionary<int, *EntityData>` + 标量字段 |
| **武器表 / 技能表** | `Assets.Generated.Table\*Table.cs`、`..\tables_json\` | 数据驱动，直接读，不用逆代码 |
| **模型/动画/音效资源** | 已导出到 `ssjj-port`、`资源全集` | 已完成 |
| **协议 methodId 全表** | `Assets.Sources.Networking.Packet\*.cs` | 285 + 100 + 4 |

### UserCmd 编码（已完整拿到）

```
[TCP 模式：先写 byte 31]
byte   ReceiveSnapshotLatency   (0..255)
int    Seq
int    RenderTime
int    LatestSnapshotSeqId
byte   flags                    (首包固定 0xBF)
byte   FrameInterval
byte   MoveForward
byte   MoveRight
int    Buttons
byte   (BagId << 5) | Weapon
short  CameraYaw
short  CameraPitch
--- 后续 cmd 走 delta ---
byte   flags（按需回填）
  bit0 FrameInterval / bit1 MoveXY / bit2 Buttons / bit3 Weapon+Bag
  bit4 CameraYaw / bit5 CameraPitch / bit6 RenderTime 差值(≤127) / bit7 RenderTime 全量
```

发送通道：`Server.State == 2` 时，TCP 发 method **31**，否则 UDP 发 method **2**。

---

## 3. 还需要逆的（按优先级）

### P0 —— 不做就无法进入 P0~P2 阶段

| # | 要逆什么 | 在哪 | 产出形态 | 难度 |
|---|---|---|---|---|
| **R1** | 快照**读取端**：`SnapShotDeCompress` / `SnapShotDeCompress2` 的位流布局 | `Assembly-CSharp\Assets.Sources.Snapshots\SnapshotUtility.cs:22/38` | 逐字段读取顺序 + 压缩算法（`SnapShotCompress`） | 中 |
| **R2** | 各 `*EntityData` 的字段读写顺序（决定快照二进制） | `SSJJ.Contract\NetData\*EntityData.cs`（PlayerEntityData 等） | 每类的字段 → 写入顺序表 | 中（量大） |
| **R3** | 登录/握手：`PolicyRequest`(-1) → `PolicyResult`(-1) → `Login`(2) → `TcpConnectionId`(1000) | `ConnectToServerUtility.cs` + `*LoginHandler.cs` | 时序图 + 包体字段 | 中 |
| **R4** | 267 个 handler 的**包体字段**（`data.Xxx` 赋给谁） | `Assembly-CSharp\Assets.Sources.Systems.PacketHandle.Handlers\*.cs` | methodId → 字段表 | 低（可脚本提取） |

> R4 可以让 protocol-mapper 的产出直接覆盖；R1/R2 是服务端能否"写出客户端能读的快照"的关键。

### P1 —— 决定"能不能打死人"

| # | 要逆什么 | 在哪 | 产出 |
|---|---|---|---|
| **R5** | 命中判定链：客户端发 Buttons，服务端要算什么 | `Assets.Sources.Modules.Player.Attack.*`（`AbstractFireAction`、`*PredicationSystem`） | 服务端判定伪代码 |
| **R6** | 伤害/护甲公式 | `Assets.Sources.Info.Weapon.Logic.ShotDistanceLogic\*` | 公式 |
| **R7** | 房间/匹配状态机（进图、准备、开始、结束） | `*Room*Handler.cs`、`BattleRoomEventHandler.cs` | 状态图 |
| **R8** | 玩家实体同步字段（位置/朝向/状态位） | `PlayerEntityData.cs`、`Snapshot.cs` | 字段表 |

### P2 —— 可以后置

| # | 要逆什么 | 说明 |
|---|---|---|
| R9 | 技能触发链（`0x800` 按下后服务端做什么） | 技能表已有，缺的是"什么时候允许" |
| R10 | 特效包字段（EffectCreate/Show/Update/Delete） | 服务端下发即可，客户端已有 handler |
| R11 | 反作弊/心跳/票据校验 | 可能可绕过，先跑明文 |
| R12 | 结算字段（比分、MVP、掉落） | `GameWinDataHandler`、`KillPlayerInfoDataHandler` |

---

## 4. 不需要逆的（别再花时间）

| 项 | 原因 |
|---|---|
| 反编译整个工程 | `02_managed_src` 已齐 |
| protobuf 定义 | 战斗协议是**手写二进制**（`BinaryDataWriter`），不是 protobuf |
| 技能数值/等级/CD | `WeaponSkillTable` / `PlayerInfoSkillTable` 是数据表 |
| 武器数值 | `Weapon.json` 1,445 行已提取 |
| 模型/动画/贴图/音效 | 已从 bundle 导出 |
| 地图几何 | 已有 BSP 提取 + `NativeBspPhysicsHost` |

---

## 5. 建议的逆向顺序（一次只做一项，做完就能验证）

```
R3 登录握手   → 能连上（客户端不踢你）
R1 快照解压   → 能收到一帧不乱码
R2 EntityData → 能看到自己/bot 的位置
R4 包体字段   → 按 267 handler 逐个补，先补 P0 那 50 个
R5/R6 命中    → 能打死人
R7 房间状态机 → 能开一局、能结束
```

每项都产出**一张表或一段伪代码**，落到 `D:\逆向\SSJJ双塔惊魂\reverse\` 下，服务端按表实现。

---

## 6. 一句话

**源码够用，缺的是"把契约抄成表"。**
真正要写代码的是服务端本身；要逆的是**快照位流**（R1/R2）和**握手时序**（R3），其余多是体力活。
