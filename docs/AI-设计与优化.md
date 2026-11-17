# AI Bot 设计分析与拟人化优化

> 本文分两部分：**一、原版驱动链逆向分析**（bot 到底要在客户端产出什么）；**二、拟人化机制设计与落地**（为什么现在的 bot 看起来傻，改了什么）。

---

# 第一部分：原版驱动链逆向分析

## 1.1 一个玩家实体是怎么"活"起来的

```
UserCmd（输入）
   ↓ PlayerMovePredicationSystem
pmove（物理）
   ↓ 上传服务器
服务端快照 PlayerEntityData
   ↓ AbstractSnapshotParser
ISnapshot
   ↓ PlaybackInitSystem（同一份数据应用给所有非预测实体）
PlayerEntity.basicInfo.Current / Next
   ↓ 各 Playback 系统
orientation / legAnim / torseAnim / viewAnim / thirdPersonUnityObjects
   ↓
渲染
```

关键点：**bot 不是预测实体**（`isPrediction == false`），所以它走的是「快照 → 组件」这条被动路径。它自己不产生输入，一切外观都由 `PlayerEntityData` 的字段决定。

## 1.2 服务端下发的玩家字段全集

从 `AbstractSnapshotParser` 逐字段提取：

| 分组 | 字段 | 作用 | 我们是否写过 |
|---|---|---|---|
| 身份 | `Id` | 实体 ID | ✅ |
| 位置 | `X` `Y` `Z` | 物理厘米坐标 | ✅ |
| 朝向 | `ViewYaw` `ViewPitch` `MoveYaw` | 视线/身体朝向 | ✅ |
| 运动 | `Velocity2D` | 水平速度（cm/s），腿动画速度源 | ❌ **未写** |
| 运动 | `Moving` | 是否在移动（服务端语义） | ❌ 未写 |
| 运动 | `OnGround` | 是否着地 | ❌ 未写 |
| 动画 | `LegsAnim` | 腿部状态 ID（1/2/3/4/7/8/9/10…） | ✅ |
| 动画 | `LegsSpeedAnimTime` | 腿部动画进度（毫秒） | ✅ 由 SyncOfflineAnimStates 推进 |
| 动画 | `LegsAnimationTimer` | 腿部动画剩余时间 | ❌ 未写 |
| 动画 | `ViewAnimationTimer` | 第一人称视图动画进度 | ❌ 未写（对 bot 无意义） |
| 动画 | `LeftViewAnimationTimer` | 左手动画进度 | ❌ |
| 动画 | `TorsoAnimationTimer` | 上半身动画进度 | ❌ |
| 战斗 | `PunchYaw` `PunchPitch` | 后坐力视觉偏移 | ❌ 未写 |
| 状态 | `IsDead` | 死亡 | ✅ |
| 状态 | `DeadTimer` | 死亡计时（尸体停留） | ❌ |
| 时间 | `ClientTime` `CmdSequence` | 客户端时间/命令序号 | ❌ |

### 已确认的结论

1. **`Moving` / `OnGround` 客户端几乎不消费**（全工程仅 `VoidLinkSpreadLogic` 用到 `player.OnGround()`，且那是实体扩展方法）。这两个字段是**给服务端**做命中判定/AI 用的，客户端渲染不依赖。所以不写不会导致"看起来傻"。
2. **`Velocity2D` 是腿动画速度源**。`PlayerLegAnimInitSystem` 里 `comp.ScaledEclipsedTime = current.LegsSpeedAnimTime`，而速度缩放通过 `LegsAnimInfo.GetAnimSpeed(horizSpeed)` 取。我们目前只在 `SyncOfflineAnimStates` 里对**本地玩家**做了 `legMul`，bot 恒为 1 倍速 —— 跑起来腿频率不随速度变。
3. **`LegsSpeedAnimTime` 已经被 `SyncOfflineAnimStates` 对所有实体推进**（`adv = dt*1000*legMul`），所以 bot 的腿动画**是在播的**。
4. **`TorsoAnimationTimer` 未写** → 上半身动画进度可能为 0。但对第三方视角的 bot 影响有限（上半身姿态由 `TorsoAnim` 状态决定）。

### 结论：渲染层不是"傻"的原因

bot 的位置、朝向、腿动画状态、动画进度都在动。看起来傻，是**行为层**问题：瞄准轨迹机械、移动恒速直线、没有预瞄、没有 peek、所有 bot 参数相同。

---

# 第二部分：拟人化机制设计与落地

## 2.1 现有 AI 的差距表

| 机制 | 真人表现 | 原实现 | 差距 |
|---|---|---|---|
| **瞄准轨迹** | 加速→减速→轻微过冲，200~400ms 完成 | `Mathf.MoveTowardsAngle` 恒速 | **最致命**，机械感来源 |
| **反应时间** | 80~250ms，每次不同 | 固定 `ReactionTime` | 缺方差 |
| **急停射击** | 移动中开枪前先减速 80~200ms | 边跑边精准开火 | 缺 |
| **预瞄** | 提前把准心放在敌人可能出现的位置 | 无 | 完全缺失 |
| **Peek 节奏** | 探头→射击→缩回，循环 | TakeCover 只是躲 | 缺交火节奏 |
| **个体差异** | 激进/保守/架枪/绕后 | 同难度参数完全相同 | 缺人格 |
| **记忆漂移** | 丢人后记的位置会偏 | `LastKnownPos` 永久精确 | 缺漂移 |
| **非理性** | 5~15% 次优动作 | 永远最优 | 太"完美"反而假 |

## 2.2 落地的 8 条机制

### ① 二阶弹簧瞄准（替代恒速插值）

人手臂转动是「目标-阻尼」系统，用临界阻尼方程驱动：

```
ω  = 2 / settleTime
a  = ω² · Δθ − 2ω · v
v += a · dt
θ += v · dt
```

- 天然产生「起步加速 → 中段最快 → 接近减速 → 轻微过冲回修」
- `settleTime` 按角度差缩放（Fitts 定律：转得越多越慢）
- 叠加每帧微抖动（手抖）

### ② 反应时间方差

每次锁定新目标时重抽：`ReactionTime × Rand(0.7, 1.5)`。

### ③ 急停射击

若水平速度 > 250 cm/s 且想开火：
- 先给自己 `StopUntil = now + Rand(0.08, 0.18)`
- 期间移动目标设为脚下 → 减速
- 窗口结束才允许扣扳机

### ④ 预瞄

目标不可见但有记忆时，准心不指正前方，而是指向：
- 最后已知位置（70%）
- 从自己到该位置路径上的「门框/拐角」（30%）—— 用导航节点的 Tactical 点近似

### ⑤ Peek 节奏（掩体内）

TakeCover 拆成 4 段循环：
```
CoverEnter 0.35s → PeekOut 0.4s → Shoot 0.9s → Hide 1.1s → (重复 1~2 次) → 离开
```
只有 PeekOut/Shoot 阶段允许开火，Hide 阶段强制不露头。

### ⑥ 个体人格

每个 bot 从 `Id` 派生四个参数：
- `Aggression` 0.25~1.0 → 影响偏好距离、推进意愿
- `AimSkill` 0.7~1.3 → 影响误差基准与收敛速度
- `CoverBias` 0.3~0.9 → 影响进掩体阈值
- `JitterScale` 0.6~1.4 → 影响瞄准抖动幅度

### ⑦ 记忆漂移

目标消失后，`LastKnownPos` 每秒向随机方向漂移 `0.4~1.2m`，`MemoryTime` 越长漂得越多 —— 模拟「记不清具体位置」。

### ⑧ 非理性行为注入

按难度 5~15% 概率触发一次：
- 残血不撤（忽略 Retreat 判定 2 秒）
- 换弹不进掩体
- 追击超过正常距离上限

## 2.3 参考资料

| 来源 | 采纳的点 |
|---|---|
| [FPS 游戏 AI 拟人化技术拆解](http://www.145z.com/html/rexuechuanqi/jishujiaocheng/232289.html) | 急停射击窗口 80~200ms、决策延迟 200~500ms、非理性行为 5~15%、记忆漂移、行为指纹多样性 |
| [游戏 AI 高度拟人化设计的思考](https://blog.csdn.net/u010913001/article/details/141384400) | 预瞄/peek/扫点、转向轨迹不连贯是"不像人"的主因 |
| [Humanized Aimbot 技术说明](https://rawcheats.com/answers/what-is-a-humanized-aimbot) | 贝塞尔/弹簧曲线替代直线、反应时间方差、瞄准点随机化、开火冷却 |
| [AI Aimbot 硬件分析](https://zhexcheats.com/zh-CN/blog/game-hacking-guides/ai-aimbot-hardware-fuser-explained) | Fitts 定律：移动时间随距离缩放；加速度峰值在 40% 处 |
| [Kieeran/FPS-Game](https://github.com/Kieeran/FPS-Game) | FSM + BT 分层、ZoneData/InfoPoint 空间推理 |
| [karasakal/haner-ai](https://github.com/karasakal/haner-ai) | 14 状态机、感知累加器、情绪系统、小队协同、掩体打分 |

## 2.4 实现位置

全部改动集中在 `OfflineBotAI.cs`（决策层），执行层 `OfflineGameplay.TickBot` 只需补 `SelfSpeed` 与 `CanFire` 两个入参。

| 机制 | 函数 |
|---|---|
| 弹簧瞄准 | `OfflineBotAgent.AimStep()` |
| 反应时间方差 | 状态转移时重抽 |
| 急停射击 | `Tick()` 开火分支 + `StopUntil` |
| 预瞄 | `PlanAimPoint()` |
| Peek 循环 | `CoverPhase` + `TickCover()` |
| 人格 | `BotProfile.Personalize(id)` |
| 记忆漂移 | `Tick()` 无目标分支 |
| 非理性 | `RollIrrational()` |
