# SSJJ Port — 自研模组（阶段 0 → ENG-02）

从 SSJJ（生死狙击）原版数据表、反编译源码、AssetBundle 与 `.anm` 动画，
在 Minecraft Java **1.21.1 + Fabric** 里 1:1 还原枪械手感与视模型。

**独立 mod id `ssjjport`，不依赖 TaCZ / TML / ForgeConfigAPIPort。**

## 当前状态（2026-11-09 · ENG-02 后）

已完成：

| 项 | 内容 |
|---|---|
| 武器规格 | `awm_legend_t`（血魔）全数值从 `tables_json` 抽出，附源码语义 |
| 散布公式 | `AwmLegendSpreadLogic.BeforeFire` 直译；**ENG-02 修正蹲伏语义 + 保留 `isWeightlessness` 分支** |
| 输入域适配 | `SpreadInputs`：MC FOV(默认 70) → 原版 90 语义、MC blocks/tick → 原版 cm/s（scale 2000，spec 可配） |
| 近战帧链 | `AwmLegendBaseAction` 的 5 段 `WeaponKnifeAttackAction`（270/300/270/360/600 ms） |
| 物品注册 | `ssjjport:awm_legend_t`，本模组自己注册，不借 TaCZ 的 IGun |
| 输入接线 | 左键开火（`attackKey` 上升沿）、R 换弹（注册 KeyBinding），仅持枪且无 GUI 时生效 |
| 状态转移表 | `state-transitions.json` + `notes/state-transitions.md`，9 个状态 |
| **ViewAnimConfig 导出** | **ENG-02**：从 AssetBundle 导出 `awm_legend_t` 的 `<actions>` XML（24 条），回填权威时长 / eventName / nextAnimation 结论 |
| 动画时间轴 | `AnimationTimeline`：按 `state-transitions.json` 调度 clip 与事件帧；**音效走事件帧，不用定时器** |
| **单一时钟** | **ENG-03**：`AnimationTimeline` 为唯一时钟；`WeaponState` 通过 `StateListener` 订阅其状态与权威时长，**不再自行计时** |
| 音效映射 | `SoundEventMap` + `assets/ssjjport/spec/audio-event-map.json`（ENG-04 撤掉 `sounds.json` 占位键；只有映射，无 .ogg、无 SoundEvent 注册） |
| 回归测试 | JUnit 5 参数化测试（`gradle test` **106 tests**）+ 独立 `TimelineSelfTest` 运行时自检 |
| 清理脚本 | `tools/cleanup_tacz.py`（只写未执行；游戏运行中拒绝改动运行时 mods） |
| 编译产物 | `build/libs/ssjj-port-0.1.0.jar` |

**还没做**（别以为能玩了）：命中判定、实际音频播放（只有映射表，无 `.ogg`、无 SoundEvent 注册）、
后坐/相机抖动、第一/第三人称渲染、HUD、开镜（ADS）、网络同步。
当前进游戏能拿到物品、能触发开火/换弹输入与事件帧/映射键日志、能打散布诊断日志，
但**没有模型与画面、没有声音**。

## ENG-03：单一时钟（两个并行时钟已合并）

| 角色 | 职责 | 时长来源 |
|---|---|---|
| `AnimationTimeline`（**唯一时钟**） | `tick(now)` 一次完成：事件帧派发、权威时长到点自动转移、通知订阅者 | `ViewAnimConfig.GetViewAnimDuration`（fire **1199ms** / bolt 33ms） |
| `WeaponState`（**订阅者**） | 弹匣/备弹、开火门槛、射击间隔、散布；`onStateEntered` 更新 `Phase`/`NextAttackTimer`/补弹 | 由唯一时钟通过回调交付，**不再读 `spec.animation.clips[].lengthS`** |

具体改动：
- `WeaponState` 删除了 `phaseStartMs`、`durationMs(String)`、`tick(long)`；新增
  `implements AnimationTimeline.StateListener`、`nextAttackMs`、`reloadPending`、
  `WeaponState(spec, timeline, now)` 三参构造（绑定 + 启动 raise）。
- `AnimationTimeline` 新增 `StateListener` / `setListener()` / `durationOf()`，
  `start()` 与 `followTransition()` 都会同步回调订阅者（带 `via=explicit|transition`）。
- `SsjjPortClient` 每 tick 只调一次 `timeline.tick(now)`；原来的 `state.tick(now)`、
  `prevPhase`、`settleTimelineToIdle` 全部删除（bolt 有权威 33ms 自行推进）。

**★ 1200ms 射速与 fire→bolt→idle 不冲突**：`1199 + 33 = 1232ms > 1200ms`。
原版 `AbstractFireAction.cs:35-38` 的 `CanFireTimeCondition` 只判
`ClientTime > NextAttackTimer`，不判视图动画相位；下一发到点用
`timeline.start("fire", now)` 覆盖仍在播放的 bolt（`ForceRightViewAnim(15)`）。
故 `WeaponState.tryFire` 用**攻击计时器**门控而非相位门控。
`MergedClockTest.fireTimelineDoesNotBlockFireRate` 与 `TimelineSelfTest` 都有断言：
在 `shot+1200ms`（落在 `[1199,1232)` 的 bolt 窗口内）第二次 `tryFire` 仍成功。

`putaway` 原版确认不存在，`Phase.PUTAWAY` 保留为**移植侧骨架**，不自动推进、不可开火。

## ENG-02：ViewAnimConfig 权威数据

`DefaultWeaponInfo.cs:336` 决定 `ViewAnimConfigAssetName =
Assets/Res/Assets/weapon/{name}/view/hand.DAE.action.xml`，
`LoadFirstHandSystem.cs:479-485` 从 `ViewAnimConfig` 取 `WeaponAnimAsset`，
`WeaponAnimationData.ReadWeaponActionData` 解析 `<actions>` XML。

- 原始文本：`notes/viewanim-config/awm_legend_t__hand.DAE.action.xml`（2,477 B / 24 条 action）
- 交叉验证：`awm_legend_ct__hand.DAE.action.xml`（2,488 B）、`ak47__hand.DAE.action.xml`（581 B）
- 解析结果：`notes/viewanim-config/viewanim-config.json`
- 导出脚本：`tools/export_viewanim_config.py`；回填脚本：`tools/backfill_state_transitions.py`

关键结论（都能逐行核对，详见 `notes/state-transitions.md`）：

- 时长 `AnimationDesc.TotalTime = (int)(FrameCount * 33.333332f)`；**C# `(int)` 向零截断**，
  故 36 帧 = **1199 ms** 而非 1200。
- `GetReloadDuration = dur(17) + dur(18) = 2533 + 33 = 2566 ms`。
- 本枪 **24 条 action 全部没有 `eventFrame` 属性** → `EventTime = 0`；
  ENG-03 细化：`WeaponNoticePlayBackSystem.cs:90` 判的是严格 `currentTime > EventTime`，
  而 `ViewAnimSystem.cs:144` 的 `currentTime` 在动画起点为 0，故带 `eventName` 的动作在
  **起点之后的第一个预测帧**触发音效，不是第 0 帧本身。
- 本枪 **24 条 action 全部没有 `nextAnimation` 属性** → `NextId = -1` →
  回落 `AnimationConstantUtility.GetTorsoAnimNextId()` 即权威（阶段 1 的转移表因此坐实）。
- `putaway` **确认不存在**（不是「未找到」）：ViewAnimConfig 与 `AnimationConstant.cs` 都没有该动作。

## 散布输入域契约（R1–R4）

`notFullyDucked` 对齐原版 `DuckState() != 0`，**与直觉相反**：
`HunterVssSpreadLogic.cs:52` + `DuckManager.cs:77-89` 表明 `DuckState()==0` 才是完全蹲下 → `DuckParam(0.0)`。
原版签名里的 `isWeightlessness` 分支保留不删，MC 无失重态由 `SpreadInputs` 显式传 `false`。

**FOV 映射表**（`SpreadInputs`；`FovComponent.cs:9` 原版 90=未开镜，MC `GameOptions` 默认 70）：

| MC 输入 | 原版 Fov | 散布分支 |
|---|---|---|
| `isScoping=false`，mcFov=70/89/91 | **90** | 完整分支 + `FovAdd(0.04)` |
| `isScoping=true` | **40**（本枪 `FovRightAction.cs:28`，spec 可配；二级 10） | `DefaultParam(0.001)`，无 FovAdd |
| MC 侧开镜 FOV 数值 | **未找到** | MC 无一一对应用值，故用布尔 `isScoping` 判定，`mcFov` 只作诊断 |

**速度单位换算**：原版 `PlayerUtility.PlayerLength2D = sqrt(Velocity.x²+Velocity.y²)`，
单位 **cm/s**（`STATE.md:134`、`docs/AI-设计与优化.md:36/38`；`PlayerConf.cs` height=170 /
RunSpeed=635、`SceneMoveData.cs` worldGravity=2032、`PmoveBase.cs:1188` frametime 为秒佐证）；
MC `Entity.getVelocity()` 为 **blocks/tick**（20 tick/s，1 block = 100 cm）。

```
spreadSpeedScale = 100 * 20 = 2000.0   （spec: inputAdaptation.speed.scale，可配）
```

这是量纲推导值、不是源码写死常量，故做成 spec 可配置；字段缺失时回落 `1.0` 并打 WARN
（不静默），此时 350/25 阈值几乎不会触发。

## ENG-03：音效事件规则（P1）

`notes/audio-events/`（由 `tools/export_audio_events.py` 导出）：

| 文件 | 内容 |
|---|---|
| `soundconfig.xml` | 武器包内原始 `<soundConfig>` TextAsset（258 B，仅 eventId 10047/10048 两个特效音） |
| `audio-clips.json` | UnityPy 枚举出的 **9 个真实 AudioClip** 名 |
| `audio-events.json` | 逐事件触发规则：**确认 4 条 / 未找到或确认不存在 5 条**，附源码行号 |

**关键发现**：`spec.audio.events` 的 `draw`/`shoot`/`bolt`/`inspect` 等是<b>通用事件名清单</b>，
不是资产名。本枪真实资产只有 `awm_legend_t_{fire,fire3,sec_fire,raise,reload,change,change2,skill,skill2}`。

| spec 事件 | 状态 | 实际 clip / 触发时机 |
|---|---|---|
| `draw` | 确认 | `awm_legend_t_raise`；ViewAnimConfig `eventName`(StateId 16)，`EventTime=0`，起点后第一个预测帧 |
| `reload_empty` / `reload_tactical` | 确认 | 合并到 `awm_legend_t_reload`（StateId 17），原版无区分；TPS 侧 `TpsWeaponSoundPredicateSystem.cs:26` 也只注册 17 |
| `shoot` | 确认 | `awm_legend_t_fire`；fire(15) 无 `eventName`，走开火命令链 `AbstractFireAction.cs:23-26,61-64` → `FireFunctions.cs:376-398` → `WeaponUtil.cs:161-217`，**与开火同一预测帧同步** |
| 近战 / 二级开火 | 确认 | `awm_legend_t_sec_fire`（StateId 20/31/170/172/174） |
| `shoot_3p` | **未找到** | 9 个 clip 无 `*_3p`；TPS 系统只注册 17；`PlayerSound` 用 `isMyPlayer` 控制衰减而非切 clip |
| `bolt` | **未找到** | 无 `*_bolt` clip；StateId 18 无 `eventName` → `WeaponNoticePlayBackSystem.cs:70-72` 直接 return |
| `inspect` / `inspect_empty` | **未找到** | 无 `*_inspect` clip；StateId 44 无 `eventName`；源码未发现独立 `Play2DSound` |
| `put_away` | 确认不存在 | 无收枪动作、无音效资产 |
| 后坐 / 枪口特效事件帧 | **未找到** | ViewAnimConfig 无相关属性，`AddFireSparks` 无 `eventFrame` 数值 |

> 所有「未找到」都写明了原因与源码位置，**没有编造任何帧号或毫秒数**。

`SoundEventMap` + `assets/ssjjport/spec/audio-event-map.json` 把 8 个能确认的 `eventName`
映射到 `audio-event-map.json` 里的目标键。**ENG-04 已撤掉 `sounds.json` 占位键**：
经 javap 静态核实，`sounds.json` 的键不会自动进 `Registries.SOUND_EVENT`，且无 subtitle 时
连 ERROR 分支都被跳过，默认日志级别下完全静默——保留占位键等于「有事件帧、没声音、无报警」。
`SoundEventMapTest` 断言 jar 内**不存在** `sounds.json`、映射表自洽、且所有 `SOUND` 事件都能解析。

## 目录

```
ssjj-port/
├── build.gradle / gradle.properties / settings.gradle
├── install.py                         装机（幂等）
├── tools/
│   ├── build_weapon_spec.py           从原版表+源码生成 spec
│   ├── export_viewanim_config.py      ENG-02：UnityPy 导出 ViewAnimConfig
│   ├── backfill_state_transitions.py ENG-02：回填权威值到 state-transitions.json
│   ├── export_audio_events.py        ENG-03：导出音效资产/触发规则
│   ├── backfill_audio_events.py      ENG-03：生成映射并回填 gaps
│   ├── TimelineSelfTest.java          独立运行时自检（不经 Gradle）
│   └── cleanup_tacz.py               TACZ 遗留归档（只写未执行）
├── notes/
│   ├── weapon-spec.md                 规格人读对照表
│   ├── state-transitions.md           状态转移表（ENG-02/03 权威回填）
│   ├── viewanim-config/               原始 XML ×3 + viewanim-config.json
│   └── audio-events/                  soundconfig.xml + audio-clips.json + audio-events.json
├── src/main/resources/
│   ├── fabric.mod.json
│   └── assets/ssjjport/
│       ├── lang/{en_us,zh_cn}.json
│       └── spec/{awm_legend_t,state-transitions,audio-event-map}.json
├── src/main/java/com/ssjj/port/
│   ├── SsjjPort.java                 ModInitializer，注册物品
│   ├── SsjjPortClient.java           客户端 tick：输入 / 唯一时钟 / 散布适配
│   └── weapon/
│       ├── WeaponSpec.java           Gson 包装 spec
│       ├── WeaponState.java          玩法规则 + 唯一时钟订阅者 + AwmLegend 散布
│       ├── SpreadInputs.java         MC→原版输入域适配（R3/R4）
│       ├── SoundEventMap.java        事件名 → 映射键（不注册 SoundEvent）
│       └── AnimationTimeline.java    唯一时钟：clip / 事件帧 / 状态订阅
└── src/test/java/com/ssjj/port/weapon/
    ├── SpreadContractTest.java       7 分支 / FOV / 速度边界 / R1 契约
    ├── SpreadInputsTest.java         FOV 映射 / 单位换算 / 降级路径
    ├── AnimationTimelineTest.java    权威时长 / 事件帧 / 转移
    ├── MergedClockTest.java          ★ 单一时钟 + 1200ms 射速不冲突
    └── SoundEventMapTest.java        sounds.json 已移除 / 映射自洽 / 不编造键
```

## 渲染层（进行中）

| 组件 | 状态 |
|---|---|
| `render/GltfModel.java` | **已完成**：极简 glTF 2.0 读取器（POSITION/NORMAL/TEXCOORD_0/JOINTS_0/WEIGHTS_0/indices/skin/animations），支持文件路径与 classpath 两种加载，字段缺失直接抛错不静默降级 |
| `render/SkeletonPose.java` | **已完成**：节点拓扑求值 + 四元数/位置采样 + CPU 蒙皮。**绑定姿态往返实测误差 9.16e-5 cm**（0.0009mm），1478 顶点全部还原 |
| `assets/ssjjport/fp/awm.{gltf,bin,png}` | **已打进 jar**：1,478 顶点 / 1,964 三角 / 44 关节 / 115 节点，X 已镜像（-7.55..11.62） |
| 独立 viewmodel pass（清深度 + 原版 FOV） | 未开始 |
| GPU 蒙皮（如需上 shader） | 未开始 |
| 第三人称 / HUD / 开镜 | 未开始 |

**两个已修的空间 bug（记下来，别再踩）**：
1. `world(joint) × inverseBind` 在绑定姿态下不是单位阵，而是一个固定的 -90°X 旋转——顶点在 mesh 空间是 Z-up，节点世界矩阵是 Y-up，导出时 `SSJJ_Mesh` 节点写成了 identity。`SkeletonPose` 在构造时用 joint0 反推一次固定补偿。
2. 求值里 `world[i].set(world[parent]).mul(world[i])` 会变成**自乘**（set 已覆盖 local）。必须先把 local 存到独立对象。

资产重导：
```bash
"$PY" "D://逆向//SSJJ双塔惊魂//mc-port//tools//ssjj2gltf.py" --bundle "man_7054af81a181fa550c92e563decf7cb1" --out "D://逆向//SSJJ双塔惊魂//ssjj-port//notes//assets//awm_fp"
```

## 重建

```bash
PY="C:/Users/Mahuilai/AppData/Local/Programs/Python/Python314/python"
GRADLE="D:/mcport-tools/gradle-8.12/bin/gradle.bat"
PORT="D:\逆向\SSJJ双塔惊魂\ssjj-port"
export JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot'

# 1) 重新生成武器规格（改了表或源码后；注意会覆盖 inputAdaptation 配置段，见下方注）
"$PY" "$PORT\tools\build_weapon_spec.py"

# 2) 导出 ViewAnimConfig 并回填（ENG-02，只读 AssetBundle，幂等）
"$PY" "$PORT\tools\export_viewanim_config.py"
"$PY" "$PORT\tools\backfill_state_transitions.py"

# 3) 导出音效事件并生成映射（ENG-03/04，只读 AssetBundle，幂等）
"$PY" "$PORT\tools\export_audio_events.py"
"$PY" "$PORT\tools\backfill_audio_events.py"

# 4) 编译 + 跑测试（JDK 21，JUnit 5）
"$GRADLE" -p "$PORT" clean build --console=plain
"$GRADLE" -p "$PORT" test --console=plain

# 5) 独立运行时自检（jar + Gson）
JDK="$JAVA_HOME"
JAR="$PORT\build\libs\ssjj-port-0.1.0.jar"
GSON="C:/Users/Mahuilai/.gradle/caches/modules-2/files-2.1/com.google.code.gson/gson/2.10.1/b3add478d4382b78ea20b1671390a858002feb6c/gson-2.10.1.jar"
"$JDK/bin/javac" -cp "$JAR;$GSON" -d "$PORT\build\selftest-out" "$PORT\tools\TimelineSelfTest.java"
"$JDK/bin/java"  -cp "$PORT\build\selftest-out;$JAR;$GSON" TimelineSelfTest

# 6) 装机（幂等，先删旧版）—— 未执行，需用户批准
"$PY" "$PORT\install.py"
```

> 注：`awm_legend_t.json` 的 `inputAdaptation` 段是 ENG-02 手工追加的，
> `build_weapon_spec.py` 重新生成会丢掉它。`SpreadInputs` 对此做了防御
> （缺失 → scale 1.0 + WARN），但**正常应重新执行第 2 步或补回配置段**。

> `gradle test` 在 Windows 中文路径下用 manifest-only pathing jar 绕开 Java
> `@argfile` 的字符集问题（`build.gradle` 的 `makeTestPathingJar`），否则 worker 会
> `ClassNotFoundException`。

## 关键决策

1. **手感优先于画面**。手感 = 时序 + 数值 + 动画 + 音效，全是纯数据/逻辑，
   原版源码与表齐全，逐帧对齐可行；画面受 MC 与 Unity 的全局光照/后处理差异限制，只能逼近。
2. **不借 TaCZ 状态机**。TaCZ 的 `default_state_machine_v2` / `ads_preset: renew` 与
   `Weapon.json` 里 AWM 的数值不是一套，借它永远差一层。
3. **时序挂在动画事件帧上**。原版 `DefaultReloadSystem.GetReloadDuration` 是
   `GetViewAnimDuration(reload) + GetViewAnimDuration(18)`；音效由
   `ViewAnimEventTime` 越过触发，不是 `startAction + 定时器`。
4. **动画组是 `ak47`**。`Weapon.json / AnimationWeaponName = ak47`，
   别按 awm 名字找 `.anm` clip；但 **ViewAnimConfig 来自武器自身 bundle（`awm_legend_t`）**。
5. **权威值优先、缺口明写**。ENG-02 导出 ViewAnimConfig 后，
   `AnimationTimeline` 用 `GetViewAnimDuration` 权威值；ENG-03 导出音效规则后，
   仍核对不到的（`shoot_3p`/`bolt`/`inspect` 触发时刻、MC 开镜 FOV）一律标「未找到」
   并附原因与源码位置，不编帧号/时刻。
6. **单一时钟**（ENG-03 已完成合并）：`AnimationTimeline` 驱动一切相位，
   `WeaponState` 只订阅。射速用攻击计时器门控而非动画相位门控，避免 1232ms 动画
   拖慢 1200ms 射速。
7. **`loop` 矛盾两者都记录**：ViewAnimConfig 的 `loop` 属性与
   `ViewAnimStateInfo.IsLoop` 白名单在 StateId 44/150 上不一致，消费者不同，不擅自裁决。

## 下一步路线

1. **接上实际音效**：为 8 个映射键补 `.ogg` 并注册 SoundEvent，用 `SoundEventMap.resolve()` 的结果播放；
   继续追查 `shoot_3p`/`bolt`/`inspect` 的触发规则（可能需要看服务器广播事件/其它 bundle）。
2. 阶段 4：独立 viewmodel pass（清深度 + 原版 FOV）+ 蒙皮渲染 + 第三人称 + HUD + 开镜；
   开镜实现后把 `SpreadInputs` 的 `isScoping` 接到真实 ADS 状态。
3. 命中判定 / 后坐 / 网络权威与输入校验；`raiseSpeed`（开火后 1.3f）接入攻击计时器。
4. 验收：原版客户端与 MC 并排录屏，逐帧比时间戳（盲测手感），再对画面。
5. 关闭游戏后执行 `tools/cleanup_tacz.py` 归档 TACZ 遗留（脚本会检测进程，运行时拒绝改动 mods）。
