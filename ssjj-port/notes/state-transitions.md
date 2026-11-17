# awm_legend_t 状态转移表（阶段 1 产物 · ENG-02 权威回填）

机器可读版：`src/main/resources/assets/ssjjport/spec/state-transitions.json`
**ENG-02 新增权威数据**：`notes/viewanim-config/`（原始 XML + 解析 JSON + 导出/回填脚本）

数据源：`D:\逆向\SSJJ双塔惊魂\Game source\02_managed_src\`（反编译源码）、
`D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows\weapon\`（AssetBundle）。
**原则：只写能逐行核对的事实；查不到写「未找到」，确认不存在的写「确认不存在」。严禁编造 StateId、clip 名或事件帧号。**

---

## 0. ENG-02 关键突破：ViewAnimConfig 已导出

`Assembly-CSharp/Assets.Sources.Info.Weapon.WeaponInfo/DefaultWeaponInfo.cs:336`：

```csharp
_viewAnimConfigAssetName = $"Assets/Res/Assets/weapon/{_name}/view/hand.DAE.action.xml";
public string AnimConfigBundleName => AssetBundleName;   // :204
```

`LoadFirstHandSystem.cs:479-485` 从 `ViewAnimConfig` 取 `WeaponAnimAsset`，
`WeaponAnimationData.ReadWeaponActionData` 解析其 `<actions>` XML。
因此对 `awm_legend_t`，**权威配置就是 `weapon/awm_legend_t_4e41f53852ab64dd135a4278f48fd8fe` bundle 里名为
`hand.DAE.action` 的 TextAsset（2,477 B / 24 条 action）**。

导出脚本：`tools/export_viewanim_config.py` → `notes/viewanim-config/`
回填脚本：`tools/backfill_state_transitions.py` → `state-transitions.json`

| 产物 | 大小 / 内容 |
|---|---|
| `awm_legend_t__hand.DAE.action.xml` | 2,477 B，24 条 action（权威） |
| `awm_legend_ct__hand.DAE.action.xml` | 2,488 B，交叉验证（同结构，仅音效名前缀不同） |
| `ak47__hand.DAE.action.xml` | 581 B，`AnimationWeaponName=ak47` 的动画组配置（7 条，帧区间不同） |
| `viewanim-config.json` | 61,701 B，逐条解析 + 全库扫描汇总 |

**全库扫描**（`Windows/` 下 2,691 个 TextAsset）：
- 含 `eventFrame` 属性：仅 4 个无关武器（`highgrenade_deathray1/2`、`highgrenade_deathray`、`rpk_hero`）
- 含 `nextAnimation` 属性：仅 11 个无关武器/皮肤
- **awm_legend_t 两者都没有** → 见 §4 的结论

---

## 1. StateId 来源（唯一权威）

`configNet/share.constant/AnimationConstant.cs` 定义 505 个 `public const int`，
`SSJJAnim_Library/SSJJAnim.AnimState/AnimationConstantUtil.cs:44-60` 用反射把
`int -> 字段名` 反查成 `ViewAnimStateInfo.AnimationName`（`ViewAnimStateInfo.cs:8`）。
导出脚本直接解析该 C# 常量文件建映射，**24 条 action 全部成功解析，无未解析名**。

| StateId | 常量名 | 用途 |
|---:|---|---|
| 13 | `TORSO_STAND` | idle（loop） |
| 14 | `TORSO_WALK` | walk（loop） |
| 15 | `TORSO_ATTACK` | fire / 开火 |
| 16 | `TORSO_RAISE` | raise / 抬枪 |
| 17 | `TORSO_RELOAD` | reload |
| 18 | `TORSO_PULL_CHARGER` | bolt / 拉栓 |
| 19 | `TORSO_DIE` | — |
| 20 | `TORSO_SECONDARY_ATTACK` | melee |
| 30/31 | `TORSO_ATTACK_RAISE` / `TORSO_KNIFE_ATTACK` | 近战帧链 |
| 36/37 | `TORSO_NORMAL_TO_SPECIAL` / `TORSO_SPECIAL_TO_NORMAL` | 模式切换 |
| 39/48 | `TORSO_SPECIAL_STAND` / `TORSO_SPECIAL_WALK` | — |
| 44 | `TORSO_SHOWGUN` | inspect |
| 150 | `TORSO_SPECIAL_ATTACK_END` | — |
| 169/171/173/175 | `TORSO_ATTACK_RAISE1..4` | 近战帧链 raise |
| 170/172/174/176 | `TORSO_KNIFE_ATTACK1..4` | 近战帧链 attack |

> `AnimationWeaponName = ak47`（`Weapon.json`）—— 用的是 ak47 骨骼动画组，别按 awm 名字找 `.anm` clip；
> 但 **ViewAnimConfig 来自武器自身 bundle（`awm_legend_t`）**，两者不是一回事。

## 2. 播放 / 时序规则（逐行核对）

| 规则 | 源码 | 内容 |
|---|---|---|
| 播放 | `ViewAnimSystem.cs:130-148` | `PlayAtFixedTime(0, AnimationName, currentTime*0.001f, 1f, isLoop, false, transitionTime, true)`；hand 与 weapon 两个 animator 同参数各播一次 |
| currentTime | `ViewAnimSystem.cs:139-145` | 非 loop：`currentTime = GetViewAnimDuration(StateId) - RemainTime`；若时长为 0 回落 `handAnimator.GetAnimDuration(0, name)*1000` |
| transitionTime | `ViewAnimSystem.cs:70-74` | 默认 `0.25f`；`IsViewAnimBlendDisable(weaponName)` 时 `0f`；`StateId==662` 强制 `0f` |
| RemainTime | `PlayerViewPredictionSystem.cs:23-39` | 每预测帧 `RemainTime -= FrameInterval*RightSpeed`（下限 0）；归零触发 `Sequencing()` |
| Sequencing | `PlayerViewPredictionSystem.cs:173-198` | `NextState(ViewGetNextAnim(StateId))`；同 id 只重置 RemainTime，换 id 调 `SetViewAnimation` |
| SetViewAnimation | `PlayerAnimationUtility.cs:50-66` | `RightCurrentTime=0`；`RemainTime=GetViewAnimDuration(id)`；`RightSpeed=speed`；isNewEvent 时 `AnimSeq++` |
| NextState | `ViewAnimStateInfo.cs:49-57` | 仅当 `weaponNextId > 0` 用 XML `nextAnimation`；否则回落 `AnimationConstantUtility.GetTorsoAnimNextId()` |
| 时长公式 | `AnimationDesc.cs:33`、`WeaponAnimationData.cs:26` | `TotalTime = (int)(FrameCount * 33.333332f)` ms，`FrameCount = end-start+1` |
| 换弹时长 | `DefaultReloadSystem.cs:33-41` | `GetViewAnimDuration(17) + GetViewAnimDuration(18)` |
| 抬枪时长 | `DefaultRaiseSystem.cs:17-22` | `NextAttackTimer = ClientTime + GetViewAnimDuration(16)/raiseSpeed` |
| 音效事件帧 | `WeaponNoticePlayBackSystem.cs:63-120` | `currentTime > ViewAnimEventTime(id)` 时 `Play2DSound("sound/weapon/{EventName}.mp3")` —— **事件帧越过触发，不是定时器** |
| 混合 | `SJAnimationPlayer.cs:286-318` | 多 layer + 每 state `Weight`；同 layer 按 `t = 1 - wA/(wA+wB)` Lerp 并累加 Weight |

> **C# `(int)` 是向零截断**：36 帧 → `(int)(36*33.333332f) = 1199` ms，不是 1200。
> 导出脚本已按截断复现，下表数值可直接当权威值用。

## 3. 权威动作表（24 条，来自 `awm_legend_t__hand.DAE.action.xml`）

`dur` = `GetViewAnimDuration(StateId)` ms；`evt` = `eventName`（`eventTime` 全为 0，见 §4）；
`nextId` 全为 -1（无 `nextAnimation`，见 §4）。

| StateId | name | start..end | frames | dur(ms) | loop(XML) | evt |
|---:|---|---:|---:|---:|---|---|
| 13 | `TORSO_STAND` | 0..0 | 1 | 33 | true | — |
| 14 | `TORSO_WALK` | 1..25 | 25 | 833 | true | — |
| 15 | `TORSO_ATTACK` | 571..606 | 36 | 1199 | false | — |
| 16 | `TORSO_RAISE` | 26..40 | 15 | 499 | false | `awm_legend_t_raise` |
| 19 | `TORSO_DIE` | 0..0 | 1 | 33 | false | — |
| 17 | `TORSO_RELOAD` | 41..116 | 76 | 2533 | false | `awm_legend_t_reload` |
| 18 | `TORSO_PULL_CHARGER` | 0..0 | 1 | 33 | false | — |
| 31 | `TORSO_KNIFE_ATTACK` | 128..138 | 11 | 366 | false | `awm_legend_t_sec_fire` |
| 30 | `TORSO_ATTACK_RAISE` | 138..156 | 19 | 633 | false | — |
| 170 | `TORSO_KNIFE_ATTACK1` | 167..178 | 12 | 399 | false | `awm_legend_t_sec_fire` |
| 169 | `TORSO_ATTACK_RAISE1` | 178..195 | 18 | 599 | false | — |
| 172 | `TORSO_KNIFE_ATTACK2` | 217..228 | 12 | 399 | false | `awm_legend_t_sec_fire` |
| 171 | `TORSO_ATTACK_RAISE2` | 228..240 | 13 | 433 | false | — |
| 174 | `TORSO_KNIFE_ATTACK3` | 273..286 | 14 | 466 | false | `awm_legend_t_sec_fire` |
| 173 | `TORSO_ATTACK_RAISE3` | 286..298 | 13 | 433 | false | — |
| 176 | `TORSO_KNIFE_ATTACK4` | 344..369 | 26 | 866 | false | `awm_legend_t_skill2` |
| 175 | `TORSO_ATTACK_RAISE4` | 369..382 | 14 | 466 | false | — |
| 20 | `TORSO_SECONDARY_ATTACK` | 383..417 | 35 | 1166 | false | `awm_legend_t_sec_fire` |
| 36 | `TORSO_NORMAL_TO_SPECIAL` | 418..425 | 8 | 266 | false | `awm_legend_t_change` |
| 37 | `TORSO_SPECIAL_TO_NORMAL` | 462..469 | 8 | 266 | false | `awm_legend_t_change2` |
| 39 | `TORSO_SPECIAL_STAND` | 426..426 | 1 | 33 | true | — |
| 48 | `TORSO_SPECIAL_WALK` | 427..451 | 25 | 833 | true | — |
| 150 | `TORSO_SPECIAL_ATTACK_END` | 610..646 | 37 | 1233 | **true** | `awm_legend_t_fire3` |
| 44 | `TORSO_SHOWGUN` | 470..570 | 101 | 3366 | **true** | — |

**换弹时长（权威）**：`dur(17) + dur(18) = 2533 + 33 = 2566 ms`。

**loop 不一致（保留，不擅自裁决）**：XML 给 44 / 150 写 `loop="true"`，但
`ViewAnimStateInfo.cs:14-36` 的 `IsLoop` 硬编码白名单不含这两个 id。
`ViewAnimSystem.PlayHandAnimation` 用 `IAnimStateInfo.IsLoop`（硬编码），
`WeaponNoticePlayBackSystem` 用 `IWeaponAnimInfo.ViewAnimIsLoop`（XML）——两个消费者不同，
JSON 里 `loop` 与 `viewAnimConfigLoop` 都记录，并把差异写进 `loopDiscrepancyNote`。

## 4. eventFrame / nextAnimation 的权威结论

| 项 | 结论 | 依据 |
|---|---|---|
| `eventFrame` | **本枪 24 条 action 全部没有该属性** → `AnimationDesc.EventTime` 保持默认 `0` → 音效在动画起点（`currentTime > 0` 的首个 tick）触发 | `WeaponAnimationData.cs:27-33`：`EventTime` 仅在 `HasAttribute("eventFrame")` 时赋值；`WeaponNoticePlayBackSystem.cs:76,105-118` |
| `nextAnimation` | **本枪 24 条 action 全部没有该属性** → `AnimationDesc.NextId` 保持默认 `-1` → `ViewGetNextAnim` 返回 -1 → `NextState` 的 `weaponNextId > 0` 判否 → **回落 `GetTorsoAnimNextId()` 即权威** | `AnimationDesc.cs:19`（`NextId = -1`）、`DefaultWeaponAnimInfo.cs:38-41`、`ViewAnimStateInfo.cs:51` |
| 全库佐证 | 2,691 个 TextAsset 中 `eventFrame` 仅 4 个、`nextAnimation` 仅 11 个，全部是无关武器/皮肤 | `viewanim-config.json` 的 `scan` 字段 |

因此 ENG-01 记录的回落转移（15→18、16→13、17→18、18→13、20→13、44→13、13/14 自循环、
31→30→13、170→169→13 …）对本枪**不再是「回落猜测」，而是权威规则**。

## 5. 每个动作的状态转移表（ENG-02 回填后）

| 动作 | StateId | clip（逻辑 / .anm） | 权威时长 | 动画音效事件帧 | transition（权威） |
|---|---:|---|---:|---|---|
| raise | 16 | `TORSO_RAISE` / `TORSO_RAISE_blend0` | **499 ms** | `awm_legend_t_raise` @0ms | `16 -> 13` |
| fire | 15 | `TORSO_ATTACK` / `TORSO_ATTACK_blend0` | **1199 ms** | 无 eventName | `15 -> 18` |
| reload | 17 | `TORSO_RELOAD` / `TORSO_RELOAD_blend0` | **2533 ms** | `awm_legend_t_reload` @0ms | `17 -> 18` |
| bolt | 18 | `TORSO_PULL_CHARGER` / **确认无 .anm clip** | **33 ms** | 无 eventName | `18 -> 13` |
| putaway | **确认不存在** | **确认不存在** | — | — | — |
| inspect | 44 | `TORSO_SHOWGUN` / `TORSO_SHOWGUN_blend0` | **3366 ms** | 无 eventName | `44 -> 13` |
| melee | 20 | `TORSO_SECONDARY_ATTACK` / `..._blend0` | **1166 ms** | `awm_legend_t_sec_fire` @0ms | `20 -> 13` |
| idle | 13 | `TORSO_STAND` / `..._blend0` | **33 ms**（loop） | — | `13 -> 13` |
| walk | 14 | `TORSO_WALK` / `..._blend0` | **833 ms**（loop） | — | `14 -> 14` |

> ENG-01 的 `specClipLengthMs`（ak47.anm decode）是**代理值**，与权威时长不同
> （例：fire 1166.7 vs 1199、reload 2500 vs 2533、inspect 3333.3 vs 3366）。
> `AnimationTimeline` 现在优先读 `runtimeDurationMs`，代理值仅留作对照。

### 5.1 开火 / 换弹 / 近战补充

- fire：`AbstractFireAction.cs:50-58` `SetFireAnim()` → `ForceRightViewAnim(player,15)` + `ForceTorsoAnim(player,15)`；
  `:35-43` 门槛 `ClientTime > NextAttackTimer && Clip >= 1`；`:45-48` `NextAttackTimer = ClientTime + AttackInterval(1200ms)`。
  `CommonFireEvent -> FireFunctions.FireEvent(args)`（`:61-64`）——**后坐 / 枪口特效在开火命令链触发，
  源码里未找到把它们绑定到动画事件帧的 FrameAction**，所以不填帧号。
- reload：`StartReload`（`DefaultReloadSystem.cs:66-88`）设 `ReloadEndTime/NextAttackTimer = ClientTime + 2566ms`、
  `ForceTorsoAnim(17)`、`ForceRightViewAnim(17)`、`ResetFov(90)`、`Deploy()`；
  `CheckReloadEnd`（`:152-164`）到点 `ReloadClip()` 补弹；`CanReloadAnim`（`:236-244`）排除近战/攻击动画。
- melee：`AwmLegendBaseAction.cs:34-46` 的 5 段 `WeaponKnifeAttackAction` 帧链
  （`currentAttackRaise / nextKnifeAttackAnim / nextKnifeAttackRaise / delayAttackTime`）：

  | # | current | nextAnim | nextRaise | delay(ms) | 权威 dur(nextRaise)/dur(nextAnim) |
  |---:|---:|---:|---:|---:|---|
  | 0 | -1 | 31 | 30 | 270 | 633 / 366 |
  | 1 | 30 | 170 | 169 | 300 | 599 / 399 |
  | 2 | 169 | 172 | 171 | 270 | 433 / 399 |
  | 3 | 171 | 174 | 173 | 360 | 433 / 466 |
  | 4 | 173 | 176 | 175 | 600 | 466 / 866 |

  `WeaponKnifeAttackAction.NextKnife` 的 `NextAttackTimer = ClientTime + dur(nextRaise) + dur(nextAnim)`
  ——现在这两段时长都是权威值，可用于后续精确复现。`delayAttackTime` 是
  `SetDelayAttackTime` 的近战延迟帧（FrameAction 语义），**不是音效 eventFrame**。

### 5.2 putaway：确认不存在

`AnimationConstant.cs` 505 个常量 + ViewAnimConfig 24 条 action + 02_managed_src 全树
grep `put_away` / `putaway` / `PutAway` 均无结果。**本枪没有独立收枪视图动画**（结论，不是「未找到」）。
`spec audio.events` 的 `put_away` 只是音频事件名；`WeaponState.PUTAWAY` 相位是移植侧骨架。
下阶段应改为「切枪时直接隐藏 viewmodel」，不要伪造 StateId。

## 6. 剩余缺口（ENG-03 后）

**ENG-03 已解决**：两个并行时钟已合并（见 §7）；`draw` / `reload_empty` / `reload_tactical` /
`shoot` / 近战的触发来源已从 `notes/audio-events/` 确认。详见 `state-transitions.json` 的
`audioEvents` 段与 `gaps`（10 条，其中 2 条是「已解决」说明）。

仍保留的缺口（逐条注明原因，未编帧号/时刻）：

1. `shoot_3p` 触发时刻 **未找到**：9 个真实 AudioClip 无 `*_3p`；
   `TpsWeaponSoundPredicateSystem.cs:26` 只为 StateId 17 注册 reload；`PlayerSound` 用
   `isMyPlayer` 控制衰减而非切 clip。
2. `bolt` 触发时刻 **未找到**：无 `*_bolt` clip；StateId 18 无 `eventName` →
   `WeaponNoticePlayBackSystem.cs:70-72` 直接 return；TPS 系统只注册 17。
3. `inspect` / `inspect_empty` 触发时刻 **未找到**：无 `*_inspect` clip；StateId 44 无
   `eventName`；源码未发现独立 `Play2DSound`；两个事件名无空/非空弹匣区分依据。
4. 后坐（`Kickback Sniper 2.0`）与枪口特效的动画事件帧 **未找到**：ViewAnimConfig 无相关属性，
   `AddFireSparks` 由开火命令链同步调用但无 `eventFrame` 数值。
5. `loop` 属性与 `ViewAnimStateInfo.IsLoop` 硬编码白名单在 44 / 150 上不一致，
   **两者都记录、不擅自裁决**（ENG-03 约束）。
6. MC 侧开镜 FOV 数值 **未找到**（`SpreadInputs` 用 `isScoping` 布尔 + spec 可配置 40）；
   `raiseSpeed`（开火后 1.3f）尚未接入攻击计时器。
7. 实际音频播放 **未实现**：ENG-04 已撤掉 `sounds.json` 占位键，只保留映射表；无 `.ogg`、无 SoundEvent 注册。

## 7. 与阶段 3 代码的对应（ENG-03 状态：单一时钟）

- `AnimationTimeline` 是**唯一时钟**，直读 `state-transitions.json` 按
  `clip / runtimeDurationMs / eventFrames / transitions` 调度。8 个状态都有权威
  `runtimeDurationMs`；`bolt(18)` 33ms 自动推进。
- 新增 `StateListener` / `setListener()` / `durationOf()`；`start()` 与 `followTransition()`
  在状态进入时同步回调订阅者（带 `via=explicit|transition` 与权威时长）。
- `WeaponState` **删除** `phaseStartMs` / `durationMs(String)` / `tick(long)`，改为
  `implements AnimationTimeline.StateListener`：`onStateEntered` 更新 `Phase`、
  `NextAttackTimer`（用 raise 权威 499ms）、换弹补弹（reload 2533 + bolt 33 = 2566ms）。
- `SsjjPortClient` 每 tick 只调一次 `timeline.tick(now)`；原来的 `state.tick(now)`、
  `prevPhase`、`settleTimelineToIdle` 已删除。
- **★ 1200ms 射速与 fire→bolt→idle 不冲突**：`1199+33=1232ms > 1200ms`。
  原版 `AbstractFireAction.cs:35-38` 只判 `ClientTime > NextAttackTimer`，不判动画相位；
  下一发到点 `start("fire")` 覆盖 bolt（`ForceRightViewAnim(15)`）。
  `MergedClockTest` / `TimelineSelfTest` 断言在 `shot+1200ms`（bolt 窗口内）第二发成功。
- `putaway` 确认原版不存在，`Phase.PUTAWAY` 保留为移植侧骨架，不自动推进。
- 音效走 `eventFrames`（`WeaponNoticePlayBackSystem.cs:90` 的严格
  `currentTime > EventTime`；`EventTime=0` → 起点后第一个预测帧），
  **没有 `startAction + Timer`**。`SoundEventMap` 把事件名映射到音频键（ENG-04 后无占位文件），
  本阶段只建映射与日志派发，不实现实际音频播放。
- 本阶段**不实现**：渲染 / 模型 / HUD / 开镜 / 实际音频播放 / 命中判定 / 网络同步。
