# awm_legend_t 原版武器规格（阶段 0 产物）

生成：`tools/build_weapon_spec.py`，数据源 `Game source/06_singleplayer/tables_json` + 反编译源码。
模组运行时直读 `assets/ssjjport/spec/awm_legend_t.json`。

| 项 | 原版值 | 来源 |
|---|---|---|
| 名称 | 血魔 | Weapon.json / StringName |
| 射击间隔 | 1200 ms (50.0 RPM) | AttackInterval |
| 弹匣 / 备弹 | 15 / 30 | MaxClip / MaxCarryClip |
| 换弹类型 | NotSpecial | ReloadType |
| 换弹时长规则 | `GetViewAnimDuration(reloadAnim) + GetViewAnimDuration(18)` | DefaultReloadSystem.GetReloadDuration |
| 散布类型 | AwmLegend | SpreadType |
| 散布 6 参数 | `0.85,0.20,0.10,0,0.001,0.04` | SpreadParam，顺序见源码 Parse(...,6) |
| 散布速度阈值 | Length2D1=350, Length2D2=25 | AwmLegendSpreadLogic |
| 后坐 | Sniper 2.0 | KickbackType/Param |
| 持枪移动速度 | 420,520 (Sniper) | MaxSpeedParam |
| 射击距离 | Melee 160,20000 | ShotDistType/Param |
| 抬枪 | AwmLegend | RaiseType |
| 动画组 | ak47 | AnimationWeaponName（注意不是 awm） |
| 第三人称动画 | ak47 | ThirdAnimationType |
| 准星 |  | WeaponCross.json |

## 散布 6 参数含义（源码逐行对照）

`AwmLegendSpreadLogic.Parse` 用 `ParamParseHelp.ParseFloat(..., param, 6)` 按固定顺序读入：

| 序 | 字段 | 值 | 语义 |
|---|---|---|---|
| 0 | `AirParam` | 0.85 | 空中 |
| 1 | `LengthParam1` | 0.2 | 速度 > Length2D1 |
| 2 | `LengthParam2` | 0.1 | 速度 > Length2D2 |
| 3 | `DuckParam` | 0.0 | 蹲下 |
| 4 | `DefaultParam` | 0.001 | 默认(开镜/特殊模式) |
| 5 | `FovAddParam` | 0.04 | FOV=90 附加 |

## 近战连击帧表（FrameAction，不是定时器）

| # | currentAttackRaise | nextAnim | nextRaise | delay(ms) |
|---|---|---|---|---|
| 0 | -1 | 31 | 30 | 270 |
| 1 | 30 | 170 | 169 | 300 |
| 2 | 169 | 172 | 171 | 270 |
| 3 | 171 | 174 | 173 | 360 |
| 4 | 173 | 176 | 175 | 600 |

## 结论

- 手感的数值/时序/事件帧全部可从原版照抄，不需要 TaCZ 的 `default_state_machine_v2`。
- `AnimationWeaponName = ak47` —— 这把枪用的是 ak47 动画组，别按 awm 名字找 clip。
- 换弹时长不是表里常量，是 `GetViewAnimDuration(reload) + GetViewAnimDuration(18)`，
  所以必须先有完整动画时长表才能精确还原换弹节奏。
