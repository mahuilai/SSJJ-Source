# QA-01 独立只读审查报告

| 项 | 内容 |
|---|---|
| 任务 | QA-01 · `ssjj-port` 独立只读质量审查 |
| 审查人 | quality-lead（严守真） |
| 审查对象 | `D:\逆向\SSJJ双塔惊魂\ssjj-port`（含 `build/libs/ssjj-port-0.1.0.jar`，文件时间戳 2026-11-09 10:09） |
| 审查方式 | **只读**：读取源码 / 配置 / jar 条目 / 原版反编译源码 / 数据表；未修改任何源码、配置、脚本 |
| 未执行 | 未运行构建、未运行测试、未启动游戏、**未执行 `cleanup_tacz.py`** |
| 判定性质 | 建议性质量门（advisory），最终放行由用户决定 |

> 说明：本报告所有结论均来自实际读到的文件内容；推断项与无法确认项均显式标注「推断／未验证」，不作虚构。

---

## 1. 依赖门 — **PASS**

### 1.1 实际读到的 `src/main/resources/fabric.mod.json`（474 B，全文）

```json
{
  "schemaVersion": 1,
  "id": "ssjjport",
  "version": "${version}",
  "name": "SSJJ Port",
  "description": "SSJJ (生死狙击) 原版枪械手感与视模型 1:1 移植，独立于 TaCZ",
  "authors": ["ssjj-port"],
  "license": "MIT",
  "environment": "*",
  "entrypoints": {
    "main": ["com.ssjj.port.SsjjPort"],
    "client": ["com.ssjj.port.SsjjPortClient"]
  },
  "depends": {
    "fabricloader": ">=0.16.0",
    "minecraft": "~1.21.1",
    "java": ">=21"
  }
}
```

### 1.2 实际读到的 `build/libs/ssjj-port-0.1.0.jar` 内 `fabric.mod.json`（469 B，全文）

```json
{
  "schemaVersion": 1,
  "id": "ssjjport",
  "version": "0.1.0",
  "name": "SSJJ Port",
  "description": "SSJJ (生死狙击) 原版枪械手感与视模型 1:1 移植，独立于 TaCZ",
  "authors": ["ssjj-port"],
  "license": "MIT",
  "environment": "*",
  "entrypoints": {
    "main": ["com.ssjj.port.SsjjPort"],
    "client": ["com.ssjj.port.SsjjPortClient"]
  },
  "depends": {
    "fabricloader": ">=0.16.0",
    "minecraft": "~1.21.1",
    "java": ">=21"
  }
}
```

两者唯一差异：`"version": "${version}"` → `"0.1.0"`，由 `build.gradle` 的 `processResources / expand "version"` 产生，属预期行为。`build/resources/main/fabric.mod.json` 与 jar 内一致（469 B）。

### 1.3 逐项检查

| # | 检查点 | 实际结果 | 判定 |
|---|---|---|---|
| 1 | `depends` 中是否含 `tacz` / `taczmeshloader` / `forgeconfigapiport` | 实际键集合仅 `fabricloader >=0.16.0`、`minecraft ~1.21.1`、`java >=21` | PASS |
| 2 | 是否有 `recommends`（含其它软依赖键） | 顶层键集合为 `schemaVersion, id, version, name, description, authors, license, environment, entrypoints, depends`；**无** `recommends` / `suggests` / `breaks` / `conflicts` / `provides` 键 | PASS |
| 3 | `build.gradle` 依赖 | `minecraft`、`mappings (yarn)`、`modImplementation fabric-loader`、`modImplementation fabric-api`；无 TaCZ / TML / ForgeConfigAPIPort 依赖 | PASS |
| 4 | jar 内全部条目大小写不敏感扫描 `tacz` | 4 个 jar（`build/libs` 2 个 + `build/devlibs` 2 个）中命中项仅为**文字串**：`fabric.mod.json` 的 `description`「独立于 TaCZ」、`SsjjPort.class` 的日志常量 `registered item ssjjport:awm_legend_t (no TaCZ dependency)`、sources jar 内 `.java` 注释。**无** `com/tacz`、`tacz/`、`taczmeshloader`、`forgeconfigapiport` 类引用或常量池引用；**无** `recommends` 命中 | PASS |
| 5 | dev jar / sources jar 内 `fabric.mod.json` | `devlibs/...-dev.jar` 与 libs 主 jar 同为 469 B（version 已展开）；两个 sources jar 为 474 B（version 仍为 `${version}`）；内容中 `depends` 同上，无软依赖键 | PASS |
| 6 | 运行时入口 | `entrypoints.main = com.ssjj.port.SsjjPort`、`client = com.ssjj.port.SsjjPortClient`，均为本模组自有类 | PASS |

**结论：零 TaCZ / TML / ForgeConfigAPIPort 依赖成立，且不存在 `recommends` 软依赖。** 唯一出现的 "TaCZ" 字面量属描述文本与日志文本，不是依赖声明，不构成依赖门失败。

---

## 2. 资产门 — **CONCERNS**（1 项待补）

### 2.1 打包资产实测

主 jar `build/libs/ssjj-port-0.1.0.jar` = **12,059 B**，共 16 个条目（含目录项）。资源类条目：

| 资产 | 源路径 | 源大小 | jar 内路径 | jar 内大小 | sha256（前 16） | 结论 |
|---|---|---|---|---|---|---|
| `awm_legend_t.json` | `src/main/resources/assets/ssjjport/spec/awm_legend_t.json` | **5,031 B** | `assets/ssjjport/spec/awm_legend_t.json` | **5,031 B** | 源 `02e627ed89c26fb9` / jar `02e627ed89c26fb9` | **一致，PASS** |
| `state-transitions.json` | — | — | — | — | — | **未生成 / 未验证** |

补充事实：

- `WeaponSpec.load()` 的资源路径为 `/assets/ssjjport/spec/<id>.json`，与 jar 内路径匹配，`awm_legend_t` 运行时可解析（静态核对，未运行游戏验证）。
- `assets/ssjjport/spec/awm_legend_t.json` 在 **4 个 jar 全部存在**，均为 5,031 B、同一哈希。
- `build/resources/main/` 当前仅 2 个文件：`fabric.mod.json`(469 B) 与 `assets/ssjjport/spec/awm_legend_t.json`(5,031 B)。
- `state-transitions.json`：**未生成**。证据：`find D:/逆向/SSJJ双塔惊魂 -iname "*state*transition*"` 无结果；`D:/逆向` 深度 4 内亦无同名文件；4 个 jar 内无 `state*transition*` 条目；`grep -rin "state-transitions\|state_transitions"` 在 `ssjj-port` 全目录（排除 HTML）无命中。
- 推断（**未验证**）：`build.gradle` 未对 `processResources` 设置 include 过滤，新增文件放入 `src/main/resources/` 后应会随 jar 打包；此结论未通过实跑构建验证，仅依据现有 `build/resources/main` 与 jar 内容对应关系推断，生成后必须重跑资产门实测。

**结论：已生成资产 `awm_legend_t.json` 打包完整且字节一致（PASS）；`state-transitions.json` 尚未生成，无法校验，故本门整体记 CONCERNS，不计为通过。**

---

## 3. 数值一致性门 — **CONCERNS**

### 3.1 对照基准

| 侧 | 文件 | 位置 |
|---|---|---|
| 原版 | `Game source/02_managed_src/Assembly-CSharp/Assets.Sources.Info.Weapon.Logic.SpreadLogic/AwmLegendSpreadLogic.cs` | `BeforeFire` L37–57；`Length2D1/2` L10–12；`Parse` L26–35 |
| 移植 | `ssjj-port/src/main/java/com/ssjj/port/weapon/WeaponState.java` | `computeSpread` L131–161 |
| 数据 | `src/main/resources/assets/ssjjport/spec/awm_legend_t.json` → `spread` 段 | L35–63 |
| 原表 | `Game source/06_singleplayer/tables_json/Weapon.json` → `Name = awm_legend_t` 行 | 唯一匹配行 |

### 3.2 数值前置核对（spec ↔ 原版表 / 源码）

| 项 | 原版值 | spec 值 | 判定 |
|---|---|---|---|
| `SpreadParam` | `0.85,0.20,0.10,0,0.001,0.04` | `rawParam` 同值；`params` = AirParam 0.85 / LengthParam1 0.2 / LengthParam2 0.1 / DuckParam 0.0 / DefaultParam 0.001 / FovAddParam 0.04 | 一致 |
| 参数顺序 | `Parse(..., 6)` → Air, Length1, Length2, Duck, Default, FovAdd | `paramOrder` 同上 6 项，且 Java 按名取值 | 一致 |
| `Length2D1` / `Length2D2` | `protected int Length2D1 = 350` / `= 25` | `length2D1: 350` / `length2D2: 25`；Java 经 `spec.spreadLength2D1/2()` 读取，无硬编码 | 一致 |
| 散布类型 / 动画组等 | `SpreadType=AwmLegend`, `AnimationWeaponName=ak47`, `DefaultAccuracy=0.2` | `type: AwmLegend` / `weaponName: ak47` / `defaultAccuracy: 0.2` | 一致 |

### 3.3 `computeSpread()` ↔ `BeforeFire()` 逐条对照表

| # | 分支 | 原版 `BeforeFire` | Java `computeSpread` | 判定 |
|---|---|---|---|---|
| 1 | **FOV != 90** | `if (player.fov.Fov != 90) num = DefaultParam;` (L40–43) | `if (fov != 90.0 \|\| specialMode) value = def;` (L142–143) | **✔ 等价**（Java 把 #2 合并进同一条件，输出同为 `def`）。`FovComponent.Fov` 为 `int` 默认 90，Java 用 `double` 与 `90.0` 精确比较，整型值下等价。输入域风险见 R3 |
| 2 | **specialMode** | `else if (IsBioMode(RaceType) \|\| IsPve(...) \|\| IsRpg(...)) num = DefaultParam;` (L44–47) | 由 `\|\| specialMode` 覆盖 (L142) | **✔ 输出等价**：C# 仅在 `fov == 90` 时求值该条件，Java 恒求值；但两者结果均为 `DefaultParam` 且均**不**加 FovAddParam，故输出一致。Javadoc 注释「PVE/生化/RPG 等特殊模式（原版直接取 DefaultParam）」准确 |
| 3 | **空中** | `(!player.OnGround() && !isWeightlessness) ? AirParam : ...` (L50)，`BeforeFire` 签名含 `bool isWeightlessness` (L37) | `if (!onGround) value = air;` (L145–146)，方法签名**无** `isWeightlessness` | **✘ 确认不一致**：Java 缺失失重标志。原版在「腾空且失重」时不取 AirParam，而是继续落到速度／蹲分支；Java 一律返回 `AirParam = 0.85` |
| 4 | **速度档 1** | `PlayerLength2D(player) > (float)Length2D1` (> 350) → `LengthParam1` (0.2) (L50) | `speed2D > spec.spreadLength2D1()` (> 350) → `l1` (0.2) (L147–148) | **✔ 结构/数值一致**，比较符同为严格 `>`。单位域未验证，见 R4 |
| 5 | **速度档 2** | `PlayerLength2D(player) > (float)Length2D2` (> 25) → `LengthParam2` (0.1) (L50) | `speed2D > spec.spreadLength2D2()` (> 25) → `l2` (0.1) (L149–150) | **✔ 一致**，同上 |
| 6 | **蹲 / 站立** | `player.DuckState() != 0 ? DefaultParam : DuckParam` (L50) | `ducking ? def(0.001) : duck(0.0)` (L151–155) | **⚠ 参数契约冲突**：分支表达式是直译，但 Java Javadoc 把 `ducking` 写为「是否蹲下」。原版证据：`HunterVssSpreadLogic.cs:52` 明确写 `(player.DuckState() == 0) ? DuckParam : ...`；`config/PlayerSpeedUtil.cs:18,26` 以 `DuckState == 0 \|\| == 1` 取 `CrouchMoveSpeed()`；`physics.net/physics/DuckManager.cs:84–89` 中 state 0 对应 `LEGS_CROUCH_IDLE` + `duckViewHeight`。即 **`DuckState() == 0` 才是完全蹲下 → 应得 DuckParam(0.0)**，`!= 0` 为未蹲/过渡态 → DefaultParam(0.001)。若按 Javadoc 字面「蹲下 = true」接线，会反接。当前无调用方，实际取值**未验证** |
| 7 | **FOV90 附加** | `if (player.fov.Fov == 90) num += FovAddParam;` (L51–54)，位于最终 `else` 内，该分支下恒真 | `if (fov == 90.0) value += fovAdd;` (L156–158)，位于 `else` 内，该分支下恒真 | **✔ 等价**，冗余判断但忠实；`fovAdd = 0.04`。在 #1/#2 分支（含 specialMode）均不加，与原版一致 |

其它核对（已读，无异常）：

- 原版 `AwmLegendSpreadLogic` 的 6 参数分支**未**乘 `currentWeapon.GetAccuracy()`（对比 `RifleSpreadLogic` 等会乘）；Java 同样未乘。`defaultAccuracy = 0.2` 仅存于 spec、`computeSpread` 未使用 —— 与本逻辑一致，非缺陷。
- `PlayerUtility.PlayerLength2D(player)` 实现为 `sqrt(Velocity.x² + Velocity.y²)`（`Assets.Sources.Utils.Player/PlayerUtility.cs:134–137`），即原版速度量纲。
- 返回类型 C# `float` → Java `double`，数值精度差异可忽略；未列为不一致。

### 3.4 不一致 / 未验证 / 证据缺口清单

| 编号 | 类型 | 内容 | 严重度 |
|---|---|---|---|
| R1 | **确认不一致** | `isWeightlessness` 参数与 `!OnGround() && !isWeightlessness` 条件缺失（对照表 #3）。失重腾空场景原版走速度/蹲分支，Java 直接给 `AirParam=0.85` | Major |
| R2 | **确认契约冲突** | `ducking` 语义（对照表 #6）。Javadoc「是否蹲下」与原版 `DuckState() != 0`（未蹲）相反，按字面接线会反接蹲/站立取值 | Major |
| R3 | **未验证** | `fov` 输入域：原版 `FovComponent.Fov` 是 `int`、默认 90 表示未开镜（`FovComponent.cs:9`）；Minecraft FOV 为浮点且默认 70。若调用方直接传 MC FOV，则 `fov != 90.0` 恒真 → 永远返回 `DefaultParam(0.001)`，移动/空中/蹲/FOV90 附加全部分支失效。需适配层（MC FOV → 原版 90 语义）并测试 | Major |
| R4 | **未验证** | `speed2D` 单位域：原版阈值为该游戏 `Velocity.x/y` 长度量纲（350 / 25），MC 玩家速度为 blocks/tick 量级；当前无任何换算层，直接比较会使两档阈值几乎永不触发。需明确换算并补边界用例（25 / 26 / 350 / 351） | Major |
| R5 | **未验证** | `specialMode` / `onGround` / `ducking` / `fov` / `speed2D` 的调用方来源：`grep computeSpread` 在 `src/` 中仅命中定义与 Javadoc，**全项目 0 处调用**（`SsjjPortClient` 仅调 `tick`）。参数映射无法确认 | Major |
| R6 | **证据缺口** | `ssjj-port` 无 `tests/` 目录（`find` 仅命中 `.gradle` 缓存内的 Fabric gametest API），`build.gradle` 无 `test` 任务 / JUnit 依赖。数值门**零自动化回归保护**，本次核对为纯静态人工比对 | Major |
| R7 | 次要（文档） | `notes/weapon-spec.md` 与 `tools/build_weapon_spec.py:247` 把 `DefaultParam` 语义标为「默认(开镜/特殊模式)」，实际原版还用于「未蹲且低速站立」分支（#6），人读表不完整；`DuckParam` 标「蹲下」是对的。建议补注，避免接线时按标签反接 | Minor |

**建议的最小测试集（供 engineering-lead 补回归，本次未创建）**：参数化覆盖 7 个分支 + `fov` 89/90/91 + `speed2D` 边界 25/26/350/351 + `specialMode` true/false + `isWeightlessness` true/false + `ducking` true/false，断言期望散布值（例如 hipfire 静止站立：`0.001 + 0.04 = 0.041`；蹲下：`0.0 + 0.04 = 0.04`；腾空：`0.85 + 0.04 = 0.89`；>350：`0.2 + 0.04 = 0.24`；>25：`0.1 + 0.04 = 0.14`；开镜或 specialMode：`0.001`，无附加）。

**结论：公式主体（7 条分支中 5 条）忠实直译且 spec 数值与原版表逐项一致；但存在 2 项确认不一致、3 项输入域未验证、0 项自动化测试，不能作为「1:1 手感」的签收依据。判定 CONCERNS。**

---

## 4. 清理脚本安全门 — **CONCERNS（未生成）**

### 4.1 存在性检查

| 检查 | 实际结果 |
|---|---|
| `ssjj-port/tools/cleanup_tacz.py` | **未生成**。`ssjj-port/tools/` 仅 `build_weapon_spec.py`（13,431 B） |
| `find D:/逆向/SSJJ双塔惊魂 -iname "*cleanup*tacz*" -o -iname "*cleanup*.py"` | 仅命中 `rea-lab/src/rea/tests/fixtures/hopperCleanupTimeout.py` 与 `src/rea/tests/fixtures/hopperCleanupTimeout.py`（无关测试夹具），**无 `cleanup_tacz.py`** |
| `find D:/逆向 -maxdepth 4 -iname "cleanup_tacz.py"` | 无结果 |
| 是否执行过该脚本 | **否**（约束要求，且对象不存在） |

### 4.2 四项安全审查（对象缺失，均为「未验证/不适用」）

| 要求 | 判定 | 说明 |
|---|---|---|
| 是否会误删（白名单 / 精确匹配） | **未验证** | 脚本未生成 |
| 是否有进程检测（游戏/启动器运行中拒绝执行） | **未验证** | 脚本未生成 |
| 是否可逆（移动到隔离目录而非 `os.remove` / `shutil.rmtree`） | **未验证** | 脚本未生成 |
| 是否保留 `mc-port\tools` 与 `mc-port\fpmod` | **未验证** | 脚本未生成 |

### 4.3 现状事实（供生成脚本时的验收基线）

- `D:\逆向\SSJJ双塔惊魂\mc-port\tools` **存在且非空**：44 个文件（含 `make_polymesh.py`、`make_playable_pack.py`、`ssjj2gltf` 相关脚本等）。
- `D:\逆向\SSJJ双塔惊魂\mc-port\fpmod` **存在且非空**：258 个文件。
- 两者均为上一版资产/工具链，任何清理脚本必须**显式白名单保留**，不得按「含 TaCZ/TML 关键字」的模糊规则整目录删除。

### 4.4 生成后必须满足的验收标准（本次不预设立场，仅列门控条件）

1. 删除目标为精确白名单（具体文件路径或明确 mod id 的 jar），不递归删除父目录；禁止 `shutil.rmtree` 指向 `mc-port` 或其子目录。
2. 执行前检测 OneClient / Java 游戏进程，运行中直接拒绝并退出。
3. **移动而非删除**：统一移入带时间戳的隔离目录，并输出可回滚清单；不得 `os.remove`。
4. `mc-port\tools`、`mc-port\fpmod` 全程只读，脚本内显式列入保留名单并在 dry-run 输出中列出。
5. 提供 `--dry-run` 默认开启；实际移动须人工审批后方可执行。

**结论：审查对象缺失，无法给出 PASS；本门记 CONCERNS（未生成），不构成对 `ssjj-port` 本体的失败判定，但列为放行前必须闭环的待办。**

---

## 5. 质量门总判定

| 门 | 判定 | 一句话依据 |
|---|---|---|
| 1. 依赖门 | **PASS** | 源码与 4 个 jar 的 `fabric.mod.json` 均无 `tacz` / `taczmeshloader` / `forgeconfigapiport` 依赖，无 `recommends`；仅描述/日志中出现 "TaCZ" 文本 |
| 2. 资产门 | **CONCERNS** | `awm_legend_t.json` 5,031 B 已打包且与源哈希一致；`state-transitions.json` 未生成、未验证 |
| 3. 数值一致性门 | **CONCERNS** | 5/7 分支忠实；`isWeightlessness` 缺失、`ducking` 语义冲突、FOV/速度输入域未定义、零自动化测试 |
| 4. 清理脚本安全门 | **CONCERNS（未生成）** | `tools/cleanup_tacz.py` 不存在，四项安全要求无法审查；`mc-port\tools`(44 文件) 与 `mc-port\fpmod`(258 文件) 现状非空需保留 |
| **总判定** | **CONCERNS — 未达签收** | 架构依赖目标已达成，但数值 1:1 与清理安全性尚未闭环；**不建议按「已完成」放行**（建议性门控，最终决定权在用户） |

### 阻塞项清单（按优先级）

| ID | 阻塞项 | 归属建议 | 验收标准 |
|---|---|---|---|
| **B1** | `computeSpread()` 补 `isWeightlessness`（或书面论证 MC 侧无失重态并明确排除） | engineering-lead | 签名/分支与 `BeforeFire` L37/L50 对齐，或排除结论写入代码注释 + 报告；配套单测覆盖失重腾空 |
| **B2** | 修正 `ducking` 契约：要么改 Javadoc 为「原版 `DuckState() != 0`（未完全蹲下）」，要么改为 `!ducking` 取 `def` 并同步改注释 | engineering-lead | 调用方映射与原版 `HunterVssSpreadLogic.cs:52` / `PlayerSpeedUtil.cs` 一致；单测断言蹲下=0.04、站立静止=0.041 |
| **B3** | 定义 `fov` 适配层（原版 int FOV，90 = 未开镜 ↔ MC FOV），禁止直接透传 MC FOV | engineering-lead | 单测覆盖 `fov` 89/90/91 与开镜态，验证 `FovAddParam` 只在 90 时附加 |
| **B4** | 定义 `speed2D` 单位换算（原版 `sqrt(Velocity.x²+Velocity.y²)` ↔ MC 速度），并验证 350/25 阈值 | engineering-lead | 边界用例 25/26/350/351 逐档命中正确散布值 |
| **B5** | 补 `computeSpread` 参数化自动化测试与 `build.gradle` 测试配置 | engineering-lead（QA 提供用例表） | 分支覆盖 7/7 + 特殊模式 + 失重；CI 可重复 PASS |
| **B6** | `state-transitions.json` 生成后放入 `src/main/resources/`，重跑构建并复测资产门 | engineering-lead | jar 内出现该资源，记录大小与哈希；`WeaponSpec`/状态机可实际读取（本次未验证打包机制） |
| **B7** | `tools/cleanup_tacz.py` 生成后按本报告 4.4 的 5 条标准复核，人工审批后方可执行 | engineering-lead / 用户审批 | dry-run 输出白名单保留 `mc-port\tools` 与 `mc-port\fpmod`；无 `os.remove`；有进程检测与回滚清单 |
| **B8**（次要） | 修订 `notes/weapon-spec.md` 与 `build_weapon_spec.py:247` 中 `DefaultParam` 的语义标注 | engineering-lead | 人读表注明 `DefaultParam` 亦用于「未蹲且低速站立」分支 |

### 复测触发条件

B1–B5 任一改动、B6 生成资产、B7 生成脚本后，需重跑本报告第 2/3/4 门；本报告结论仅在「当前文件快照」下有效。

---

## 附录 A · 证据文件清单

| 文件 | 用途 |
|---|---|
| `ssjj-port/src/main/resources/fabric.mod.json` (474 B) | 依赖门源码侧 |
| `ssjj-port/build/resources/main/fabric.mod.json` (469 B) | 依赖门构建中间产物 |
| `ssjj-port/build/libs/ssjj-port-0.1.0.jar` (12,059 B) | 依赖门 jar 侧、资产门 |
| `ssjj-port/build/libs/ssjj-port-0.1.0-sources.jar` (9,672 B) | 依赖门交叉核对 |
| `ssjj-port/build/devlibs/ssjj-port-0.1.0-dev.jar` (11,582 B) | 依赖门交叉核对 |
| `ssjj-port/build/devlibs/ssjj-port-0.1.0-sources.jar` (8,309 B) | 依赖门交叉核对 |
| `ssjj-port/src/main/resources/assets/ssjjport/spec/awm_legend_t.json` (5,031 B, sha256 `02e627ed89c26fb9…`) | 资产门、数值门 |
| `ssjj-port/src/main/java/com/ssjj/port/weapon/WeaponState.java` | 数值门（`computeSpread` L131–161） |
| `ssjj-port/src/main/java/com/ssjj/port/weapon/WeaponSpec.java` | 资源加载路径、阈值读取 |
| `ssjj-port/src/main/java/com/ssjj/port/SsjjPort.java` / `SsjjPortClient.java` | 入口与调用方核对 |
| `ssjj-port/build.gradle` / `gradle.properties` / `README.md` / `install.py` | 依赖、构建、现状 |
| `ssjj-port/tools/build_weapon_spec.py` / `notes/weapon-spec.md` | spec 生成逻辑与人读对照表 |
| `Game source/.../SpreadLogic/AwmLegendSpreadLogic.cs` | 数值门基准 |
| `Game source/.../SpreadLogic/HunterVssSpreadLogic.cs`、`VssSpreadLogic.cs`、`Assembly-CSharp/config/PlayerSpeedUtil.cs` | `DuckState` 语义佐证 |
| `Game source/02_managed_src/SSJJEntitas_Library/.../FovComponent.cs`、`PlayerEntity.cs`、`MoveComponent.cs` | FOV 类型、`DuckState()` / `OnGround()` 定义 |
| `Game source/02_managed_src/physics.net/physics/DuckManager.cs` | 蹲状态编码佐证 |
| `Game source/02_managed_src/.../PlayerUtility.cs` | `PlayerLength2D` 定义 |
| `Game source/06_singleplayer/tables_json/Weapon.json` (`Name=awm_legend_t` 行) | spec 数值溯源 |

## 附录 B · 审查边界

- 本次为**只读审查**：未创建/修改任何源码、配置、脚本；本报告 `notes/qa-report.md` 为新增 QA 产物。
- 未运行 `gradle build`、未运行任何测试、未启动游戏，因此所有「运行时行为」结论均为静态核对或标注「未验证」。
- 未执行 `cleanup_tacz.py`（对象不存在，且受约束禁止执行）。
- 未对 `mc-port\fpmod` 旧架构做可达性复核（超出 QA-01 范围）。

### 旁注（非本门范围，不作阻塞项）

`ssjj-port/install.py:18–20` 使用 `os.remove()` 删除目标 mods 目录下旧的 `ssjj-port-*.jar`，无备份、无进程检测。其作用域被限定为单一 mods 目录中的同名前缀 jar，风险可控；但「可逆性」与清理脚本门要求不一致，建议后续统一改为移动隔离 + dry-run。

---

# QA-02 · 复跑资产门 + 清理脚本安全门

| 项 | 内容 |
|---|---|
| 任务 | QA-02（续 QA-01，快照已变） |
| 审查人 | quality-lead（严守真） |
| 审查方式 | 只读审查：读取源码 / 资源 / jar 条目 / 清理脚本；**仅执行 `cleanup_tacz.py --dry-run`（QA-02 任务书明确允许的只读例外）**，未执行无参调用 |
| 未执行 | 未跑构建、未跑测试、未启动游戏、未修改任何源码/配置/脚本、未改 jar |
| **本轮范围** | 仅复跑 **资产门** 与 **清理脚本安全门**；**数值门 R1–R4 按要求不审**（ENG-02 修正单由 engineering-lead 处理，留待 QA-03） |
| 报告操作 | 在 QA-01 之后**追加**本章节，QA-01 原文未改动 |

## QA-02.0 快照对账（重要：任务书中的数字已过期）

任务书给的「新快照」是 jar 29,783 B / `state-transitions.json` 23,162 B / `awm_legend_t.json` 5,031 B；**实际磁盘已是 ENG-02 之后的第二次重建**。engineering-lead 的事前提醒与主理人任务书不一致，故以下一律以本次实测为准：

| 项 | QA-01 快照(10:09) | 任务书所述(10:54) | **本次实测(11:46–11:47)** |
|---|---|---|---|
| `build/libs/ssjj-port-0.1.0.jar` | 12,059 B | 29,783 B | **39,102 B** |
| `awm_legend_t.json` | 5,031 B | 5,031 B | **8,441 B**（新增 `inputAdaptation` 段） |
| `state-transitions.json` | 未生成 | 23,162 B / 42 处「未找到」 | **42,328 B / 9 states / 8 gaps / 8 处「未找到」** |
| `lang/en_us.json` / `zh_cn.json` | 无 | 142 / 136 B | **142 / 136 B**（未变） |
| `tools/cleanup_tacz.py` | 未生成 | 10,540 B | **10,540 B**，sha256(16) `0be0ec6d62693f18`，未改动 |
| `AnimationTimeline.java` | 无 | 14,792 B | 14,792 B（本轮未审查） |

> 结论：QA-02 审的是**当前实际快照**，不是任务书里那份陈旧清单。后续任何复跑请先重新 `stat`。

## QA-02.1 资产门复跑 — **PASS**（升级 QA-01 的 CONCERNS）

审查对象：`build/libs/ssjj-port-0.1.0.jar`（39,102 B，2026-11-09 11:46:51）。

### 四个资源：源文件 ↔ jar 条目逐字节比对

| 资源（jar 内路径） | 源大小 | jar 内大小 | 源 sha256(前16) | jar sha256(前16) | 字节相等 |
|---|---|---|---|---|---|
| `assets/ssjjport/spec/awm_legend_t.json` | **8,441 B** | **8,441 B** | `b294b1f1560d0f5c` | `b294b1f1560d0f5c` | **True** |
| `assets/ssjjport/spec/state-transitions.json` | **42,328 B** | **42,328 B** | `2574ed87801d03a4` | `2574ed87801d03a4` | **True** |
| `assets/ssjjport/lang/en_us.json` | **142 B** | **142 B** | `56d1070bbae40e52` | `56d1070bbae40e52` | **True** |
| `assets/ssjjport/lang/zh_cn.json` | **136 B** | **136 B** | `acdc236143d05faf` | `acdc236143d05faf` | **True** |

（sha256 全值：`b294b1f1560d0f5ca2307cc54a582775b98edb92f139d245216d8ed13f7af0a7` / `2574ed87801d03a42cddb8c4e3db733bc2fcff97634514c983b2327c933cb5fc` / `56d1070bbae40e52d6ee632ab21429065e0d85eba69f8b900baf6746f5ef1868` / `acdc236143d05faffad91acc6911d391101db0007a0f9d1c335f094836a35bd1`）

### 完整性与一致性核对

| # | 检查 | 实际结果 | 判定 |
|---|---|---|---|
| 1 | `src/main/resources` 全部 5 个文件是否都进 jar | `lang/en_us.json`、`lang/zh_cn.json`、`spec/awm_legend_t.json`、`spec/state-transitions.json`、`fabric.mod.json` → **5/5 命中**；无源文件缺失，无 jar 内多余资源 | PASS |
| 2 | `fabric.mod.json` 差异 | 源 474 B / jar 469 B，`EQUAL=False`，差异为 `"version": "${version}"` → `"0.1.0"`（`processResources expand` 预期行为）；jar 内顶层键仍为 `schemaVersion,id,version,name,description,authors,license,environment,entrypoints,depends`，**无 `recommends`/`suggests`**（本轮未重开依赖门，仅附带核对无回归） | PASS |
| 3 | 其余 3 个 jar | `libs/...-sources.jar`(36,499 B)、`devlibs/...-dev.jar`(38,367 B)、`devlibs/...-sources.jar`(34,599 B) 均含 4 个资源，字节数与 sha256(16) 与上表**逐一一致** | PASS |
| 4 | JSON 可解析性 | 4 个资源均为合法 JSON；`state-transitions.json` 解析出 `states=9`、`gaps=8`，文本中「未找到」计 **8** 处；`awm_legend_t.json` 含 `inputAdaptation` 段，`spread.params` 6 值仍为 `0.85/0.2/0.1/0.0/0.001/0.04` | PASS |
| 5 | 运行时可解析路径 | `WeaponSpec.load()` 用 `/assets/ssjjport/spec/<id>.json`，与 jar 内路径匹配（静态核对，未启动游戏） | PASS |

**遗留观察（非资产门失败）**：`state-transitions.json` 仍有 8 处「未找到」/ 8 个 `gaps`，属 ENG-02 明示的「解释性文字与仍缺项说明」，是**内容完整性**问题不是打包问题；`awm_legend_t.json` 的 `inputAdaptation` 与 `loop` 属性／双时钟一致性问题 engineering-lead 已显式标注未裁决。以上均**不在 QA-02 判定范围**，转 QA-03 / ENG 跟踪。

**判定：PASS** —— QA-01 的 B6（`state-transitions.json` 未生成）已闭环：文件已生成、已打进 4 个 jar、与源逐字节一致；新增两个 lang 同样一致。

## QA-02.2 清理脚本安全门复跑 — **CONCERNS**（5 条中 4 条满足，第 4 条 FAIL）

审查对象：`tools/cleanup_tacz.py`，10,540 B，sha256(16) `0be0ec6d62693f18`（ENG-01 交付版本，ENG-02 未改动，本次复跑前后哈希一致）。

### 独立验证动作（不照抄主理人 dry-run 结论）

- 已独立执行 `python tools/cleanup_tacz.py --dry-run`（只读例外），**未执行无参调用**。
- 实测输出：`tasklist 返回 229 行，命中 ['oneclient_app.exe']`；`[0]` 打印 2 个 `[KEEP]`（245,562 B / 237,187,893 B）；`[2]` 打印 5 个 `[BLOCK]`（4 个精确 jar + `.minecraft\tacz` 98.21 MiB），mods junction 真实路径解析为 `...\clusters\1.21.1 Fabric\mods`；`[3]` 3 项 `[DRY-RUN]`（1.55 / 50.24 / 55.37 MiB）；`[4]` 异常/冲突 **0 项**；**`EXIT_CODE=2`**。与主理人描述一致（本次为独立复现，非引用）。
- 独立 `tasklist` 探针（Python `subprocess`）：`returncode=0`、229 行、命中 `"oneclient_app.exe","15004",...`。注：Git Bash 直接敲 `tasklist /FO CSV /NH` 会被 MSYS 把 `/FO` 转成路径而报错，是 shell 特性，不是脚本缺陷；脚本用 `subprocess.run` 传字面参数，工作正常。
- **dry-run 无落盘证明**：运行后 `_archive` 仍不存在；`mc-port\tools` 仍 44 文件、`mc-port\fpmod` 仍 258 文件；运行时 mods 仍 144 个 jar 且 4 个目标 jar 全部在位；脚本自身哈希未变。

### 五条标准逐条复核（行号以本次读到的 10,540 B 版本为准）

| # | QA-01 4.4 标准 | 行号证据 | 判定 |
|---|---|---|---|
| 1 | **精确白名单 / 禁止误删 / KEEP 两目录只读** | `RUNTIME_MOD_JARS` L48–53 为 4 个**精确文件名**（L47 注释「不做模糊匹配」）；`DEAD_JARS` L56–59 为 2 个精确文件名（L55「其他 jar 一律不动」）；`KEEP_PATHS` L62–65 显式列出 `mc-port/tools` 与 `mc-port/fpmod`，L191–195 在 dry-run 输出 `[KEEP]` 并打印大小；`guard_keep()` L132–138 用 `real()` 解析 junction 后做 `t == k or t.startswith(k+os.sep)` 判定并 `raise`，在 `archive_one` 中对 src 与 dst 各调一次（L147–148）。独立 grep：**无** `shutil.rmtree` 指向 `mc-port`，无任何写操作落到 KEEP 目录（`size_of()` L75–88 仅 `os.walk` 只读） | **PASS** |
| 2 | **进程检测 / 运行中拒绝改运行时 mods / 退出码 2** | `GAME_PROCESSES` L67；`detect_game_process()` L99–124 用 `subprocess.run(["tasklist","/FO","CSV","/NH"], timeout=30)` L106–109，异常→保守 `True` L110–111，大小写不敏感子串匹配 L118–122；`main()` 把检测放在**第一步** L198–208；running 时 L214–221 对 4 jar + tacz 打印 `[BLOCK]` 且 `runtime_states = []`（**不调用 `archive_one`**），L265–267 `return 2`。本次 dry-run 独立复现 `EXIT_CODE=2` 与 5 个 BLOCK | **CONCERNS**（主路径 PASS，2 个边界缺陷见 D1/D2） |
| 3 | **移动而非删除 + 可回滚清单 + 带时间戳隔离目录** | `ARCHIVE_ROOT` L37 = `_archive/tacz-legacy-20261109`（日期隔离）；唯一变更动作为 `shutil.move(str(src_r), str(dst_r))` L172，L171 `dst.parent.mkdir(...)` 仅创建归档目录；独立 grep 全文件**无** `os.remove` / `os.unlink` / `os.rmdir` / `shutil.rmtree` / `unlink(` / `remove(` / `open(...,w)` / `write_text` / `write_bytes`，L14 仅为注释提及「不 os.remove / 不 rmtree」；每次移动打印 `from:`/`to:`/`size:` L164–167 及 `done:` L173，`real()` L91–96 解析 junction；`dst` 已存在先判 CONFLICT 不覆盖 L157–161 | **PASS**（1 项改进建议 D4） |
| 4 | **`--dry-run` 默认开启 + 实际移动须人工审批** | L180 `ap.add_argument("--dry-run", action="store_true", ...)` → **默认 False**；L188 无该参数时打印「实际执行」；无 `--apply` / 无确认提示 / 无审批门；docstring L16–19 的用法是「先 `--dry-run`，再无参执行」的**两步人工流程**，不是技术默认。裸调用会真实 `shutil.move` 工程侧 3 项（L238–246），若游戏未运行还会移动 5 个运行时目标（L224–232） | **FAIL**（本门主要阻塞项，见 D3） |
| 5 | **幂等 + CONFLICT 保护** | `archive_one` L150–155：源不存在且归档已存在 → `skipped_archived`，源不存在且归档不存在 → `skipped_missing`；L157–161 源与归档同时存在 → `conflict` 且不动；L251–253 汇总 `conflicts`/`ok`/`anomalies`，L262–264 有冲突 `return 1`；running 时 `runtime_states=[]` L221，关服后重跑才处理运行时目标 | **PASS** |

### 具体缺陷 / 观察清单

| ID | 严重度 | 内容 | 建议 |
|---|---|---|---|
| **D3** | **Major（阻塞）** | **`--dry-run` 不是默认开启**（L180 `store_true` 默认 False，L188）。QA-01 4.4 第 5 条明确要求「dry-run 默认开启；实际移动须人工审批后方可执行」。裸调用即真实移动，审批仅为文档里的两步流程，代码无任何确认门 | 改为默认 dry-run、用 `--apply` 显式开启真实移动；或增加交互确认 + 审批标志。**此项修复前不得批准实际执行** |
| **D1** | Major | **进程检测「保守判定」不完整**：L106–109 的 `subprocess.run` 未设 `check=True`，全文件**未读取 `proc.returncode`**，也未检查 `proc.stderr`；若 `tasklist` 以非零码返回且 stdout 为空，L113–115 两次解码后仍为空 → L118–122 循环 0 行 → L124 返回 `False`（视为未运行）→ 会放行 5 个运行时目标的归档。这与 L103 文档承诺「调用失败时保守地返回 True」不符。当前实测 `returncode=0`、229 行、命中 1 项，主路径正常，缺陷只在 tasklist 异常场景触发 | 在 L112 之后增加 `if proc.returncode != 0 or not proc.stdout.strip(): return True, [], "...保守判定为运行中"` |
| **D2** | Minor | **退出码优先级**：L262–264 `if conflicts: return 1` 位于 L265–267 `if running: return 2` 之前。若「游戏运行中 + 存在 CONFLICT」同时成立，返回 1 而非文档 L24 承诺的 2。运行时目标仍被 BLOCK（安全无回退），但契约不符 | 调整优先级为 conflict 与 running 分开上报，或文档注明 conflict 优先 |
| **D4** | Minor | **回滚清单只落 stdout**：L164–167 / L173 打印 from/to/size，但未落盘 manifest。归档目录结构固定、可推导回滚，满足「输出清单」字面要求；若 stdout 未留存则无持久化凭证 | 建议在归档根写一份 `manifest.json`（含 src/dst/size/时间），便于审计与回滚 |
| **D5** | Minor | `guard_keep()` L138 抛 `RuntimeError`，而 `main()` 无顶层 `try/except`；一旦触发会输出 traceback（**失败安全**：不会移动，但不优雅） | 顶层捕获并给清晰错误 + 非零退出码 |
| **D6** | 观察（非缺陷） | 两个目标是**目录级移动**而非逐文件白名单：`.minecraft\tacz` 整目录（L41 / L229–232，98.21 MiB）与 `mc-port/pack/ssjj` 整目录（L44 / L238–241，1.55 MiB）。两者均为显式命名、受 `guard_keep` 与进程检测保护、且是 move 而非 delete，符合「不递归删除父目录」；但范围比「具体文件路径」宽，执行前应人工确认目录内容 | 执行前 dry-run 列出目录内文件数/清单 |

### 门判定

**CONCERNS** —— 精确白名单、KEEP 保护、移动而非删除、幂等、运行时进程 BLOCK + 退出码 2 均已独立验证通过，且 dry-run 实测无落盘；但 **QA-01 4.4 第 5 条（dry-run 默认开启）明确不满足（FAIL）**，另有 D1 的保守判定缺口。按 QA-01 的验收标准，**该脚本当前不得被批准实际执行**；D3（并建议连同 D1）修复后需重跑本门。若把「dry-run 默认开启」视为硬性放行条件，则本门应直接判 **FAIL**，此处按「核心破坏性风险已全部缓解、仅默认安全态与边界检测待修」取 CONCERNS。

## QA-02.3 本轮门汇总与总判定

| 门 | QA-01 | **QA-02** | 变化 |
|---|---|---|---|
| 1. 依赖门 | PASS | **未重跑**（本轮范围外）；附带核对 jar 内 `fabric.mod.json` 键无 `recommends` 回归 | 维持 |
| 2. 资产门 | CONCERNS | **PASS** | B6 闭环，4 资源逐字节一致 |
| 3. 数值一致性门 | CONCERNS | **未审（本轮明确排除）** | 待 QA-03 |
| 4. 清理脚本安全门 | CONCERNS（未生成） | **CONCERNS（对象已存在；4/5 条通过，第 5 条 FAIL）** | 有实质进展，但未达放行 |
| **总判定** | CONCERNS — 未达签收 | **CONCERNS — 未达签收** | 资产门已闭环，清理脚本与数值门仍阻塞 |

### QA-02 阻塞项

| ID | 阻塞项 | 归属 | 验收标准 |
|---|---|---|---|
| **C1** | `cleanup_tacz.py` 默认改为 dry-run（或 `--apply` 显式开启）+ 人工审批门 | engineering-lead | 裸调用不产生任何 `shutil.move`；dry-run 输出与本次一致；复跑本门第 4 条判 PASS |
| **C2** | 修 D1：`proc.returncode` / 空 stdout → 保守判定「运行中」 | engineering-lead | 构造 tasklist 失败场景（可注入 stub）验证返回 `True` 且运行时目标 BLOCK |
| **C3** | 修 D2 退出码优先级；补 D4 落盘 manifest、D5 顶层异常处理（建议项） | engineering-lead | conflict + running 组合返回码符合文档；归档根产生 manifest.json |
| **C4** | 实际执行 `cleanup_tacz.py` 前须**人工审批**（用户掌舵） | team-lead / 用户 | C1/C2 闭环 + 审批记录 + 执行前后 KEEP 目录与 mods jar 计数对账 |
| **C5** | QA-03 数值门复跑：验证 QA-01 的 6 个期望散布值 `0.041 / 0.04 / 0.89 / 0.24 / 0.14 / 0.001` **被测试真实断言覆盖**，而非只看「92 tests 存在」 | quality-lead（待 team-lead 派单） | 逐值定位到具体测试方法与 assert 语句；R1–R4 逐项复判 |

### 已知未裁决项（engineering-lead 主动标注，QA-02 不判定）

1. `WeaponState` 用 `.anm` 骨骼 clip 长度、`AnimationTimeline` 用 ViewAnimConfig 权威时长，**两个并行时钟尚未合并**。
2. ViewAnimConfig 的 `loop` 属性（44/150 为 true）与 `ViewAnimStateInfo.IsLoop` 硬编码白名单不一致，两个消费者不同，两者均记录未裁决。
3. `state-transitions.json` 残留 8 处「未找到」/ 8 gaps。

## QA-02.4 审查边界补记

- QA-01 附录 B 中「未执行 `cleanup_tacz.py`」**仅对 QA-01 快照成立**（当时对象不存在）。QA-02 依任务书的 dry-run 例外**独立执行了一次 `--dry-run`**，未执行无参调用；执行后已验证 `_archive` 不存在、KEEP 两目录文件数不变、运行时 mods 仍 144 jar，证明该次执行为只读。
- 未运行 `gradle build` / `gradle test`，因此「BUILD SUCCESSFUL」「92 tests / 0 failures」等均为 engineering-lead / team-lead 陈述，**本轮未独立复现**（任务书亦要求不跑构建）；数值门相关测试的存在性与断言覆盖留待 QA-03。
- 未启动游戏、未修改任何源码/配置/脚本/jar；本报告仅在 `notes/qa-report.md` 追加章节。
- 未对 `mc-port\fpmod` 旧架构做可达性复核（超出范围）。

---

# QA-02 补记 · ENG-03 快照漂移增量核对

> 触发：engineering-lead 在 QA-02 完成之后告知 ENG-03 又重建了产物。**本补记为增量事实核对，不作新的门判定**（团队未派 QA-03 单）；QA-01 / QA-02 两章及其判定原样保留、不撤回、不改写。
> 审查方式：只读；未跑构建/测试、未启动游戏、未改源码/配置/脚本/jar、未执行 `cleanup_tacz.py`（本补记连 dry-run 也未跑）。

## 补记.1 快照第三次变更（QA-02.0 的对账表再次过期）

| 项 | QA-01(10:09) | QA-02 实测(11:46) | **补记实测(12:19)** |
|---|---|---|---|
| `build/libs/ssjj-port-0.1.0.jar` | 12,059 B | 39,102 B | **48,418 B** |
| `awm_legend_t.json` | 5,031 B | 8,441 B | 8,441 B（未变） |
| `state-transitions.json` | 未生成 | 42,328 B | **45,978 B**（新增 `audioEvents`，gaps 10 条） |
| `lang/en_us.json` / `zh_cn.json` | 无 | 142 / 136 B | 142 / 136 B（未变） |
| `sounds.json` / `spec/audio-event-map.json` | 无 | 无 | **420 B / 13,699 B（新增）** |
| `WeaponState.java` / `AnimationTimeline.java` | 未记录 / 无 | 未实测 / 无 | **13,224 B / 18,351 B** |
| `tools/cleanup_tacz.py` | 未生成 | 10,540 B | 10,540 B（**哈希未变**） |

**结论：QA-02.1 记录的具体字节数与哈希已过期**，若以 QA-02 报告作为当前产物证据会引用错误数值。资产门的正式签收须按本补记新数值在 QA-03 重发判定。

## 补记.2 资产增量核对（6 个资源，源↔jar 逐字节）

主 jar 48,418 B；`src/main/resources` 共 **7 个文件（6 资源 + fabric.mod.json）**，**7/7 进 jar**，无源缺失、无 jar 内多余资源。

| 资源（jar 内路径） | 源/jar 大小 | sha256(前16) | 相等 |
|---|---|---|---|
| `assets/ssjjport/lang/en_us.json` | 142 / 142 | `56d1070bbae40e52` | True |
| `assets/ssjjport/lang/zh_cn.json` | 136 / 136 | `acdc236143d05faf` | True |
| `assets/ssjjport/sounds.json` | 420 / 420 | `0915f327fa262afc` | True |
| `assets/ssjjport/spec/audio-event-map.json` | 13,699 / 13,699 | `c3adcb702b038c74` | True |
| `assets/ssjjport/spec/awm_legend_t.json` | 8,441 / 8,441 | `b294b1f1560d0f5c` | True |
| `assets/ssjjport/spec/state-transitions.json` | 45,978 / 45,978 | `0bd222d3a70533a6` | True |
| `fabric.mod.json` | 474 / 469 | src `d9c2c58057f2f3b6` / jar `cdbfe14f7dd3d70b` | False（**预期**：`${version}`→`0.1.0` expand，与 QA-02.1 一致） |

其余 3 个 jar（`libs/...-sources.jar` 45,565 B、`devlibs/...-dev.jar` 47,571 B、`devlibs/...-sources.jar` 43,398 B）中 6 个资源的字节数与 sha256(16) 与上表**逐一一致**。6 个资源均为合法 JSON；`sounds.json` 解析为 8 个键、每个 `sounds` 数组长度 **0**；`state-transitions.json` 解析为 `states=9`、`gaps=10`、`audioEvents=12`、文本「未找到」计 **14** 处、`loopDiscrepancyNote` 1 处。

**判定（事实层，非正式门判定）**：当前快照下资源打包完整性成立；新增 2 个资源（`sounds.json`、`audio-event-map.json`）是 QA-02 资产门**未覆盖**的对象，须纳入 QA-03 正式复跑。

## 补记.3 清理脚本安全门无回归（QA-02.2 判定继续有效）

| 受保护对象 | 本次实测 | 与 QA-02 对比 |
|---|---|---|
| `tools/cleanup_tacz.py` | 10,540 B，sha256(16) `0be0ec6d62693f18` | **完全一致**（QA-02 同值） |
| `install.py` | 891 B，`979383b49c32dcf3` | 未改动 |
| `src/main/resources/fabric.mod.json` | 474 B，`d9c2c58057f2f3b6` | 未改动 |
| `mc-port\tools` / `mc-port\fpmod` | 44 / 258 文件 | 未变 |
| `_archive` | 不存在 | 未执行 |
| 运行时 mods | 144 个 jar | 未变 |

因此 **QA-02.2 的五条判定、D1–D6 缺陷清单、C1–C4 阻塞项全部原样有效**：`--dry-run` 仍非默认（D3）、`proc.returncode` 仍未检查（D1）。**本补记未重跑安全门、未执行脚本**；C1/C2 修复后再复跑。

## 补记.4 `sounds.json` 空占位键 — 应 engineering-lead 提问的 QA 意见

**静态事实**（未启动游戏，运行期行为一律标注「未验证」）：

- `sounds.json` 420 B，8 个键（`awm_legend_t_change/change2/fire/fire3/raise/reload/sec_fire/skill2`），全部仅 `{"sounds": []}`，无 `replace`、无 `subtitle`、无 `.ogg` 引用。
- `SoundEventMap.load()`（L63–104）从 classpath 读 `sounds.json` 与 `audio-event-map.json`，只做三类校验：映射目标键存在性 L80–86、键名合法性 L87–91、键数一致性 L92–95。**不校验 `sounds` 数组是否为空**，也不解析音频条目。
- 全 `src/main/java` 中**唯一** `Registry.register` 是 `SsjjPort.java:32` 的 `Registries.ITEM`；**没有** `Registries.SOUND_EVENT` / `SoundEvent.of` / 任何 SoundEvent 注册调用。`SoundEventMap.java:22` 注释「Minecraft 会注册该 SoundEvent id」是**设计假设，模组代码未实现该注册**。
- `SsjjPortClient.java:79–81` 只 `SoundEventMap.load()` 并打印 warnings；L141 注释明确「只有占位键，不产生实际音频」。

**QA 判定：CONCERNS（不是 FAIL，但不得当作「已完成」）**。理由：
1. 静态未见崩溃路径 —— 空数组是合法 JSON 形状，`SoundEventMap` 不取数组元素，`load()` 有资源缺失的显式异常（L129–138），失败模式可控；
2. 但「空占位键是否被 MC 资源加载静默接受 / 是否告警」**运行期未验证**（约束禁止启动游戏），Javadoc 的「会注册 SoundEvent id」也**无对应注册代码**支撑，属证据缺口；
3. 8 个无声 id 若被静默加载，会形成**难以察觉的静默降级**（有事件、没声音），正是 QA 最需要显式标记的风险；当前**无任何测试断言**占位键形状或 emptiness，无法防止后续误以为音效已接通。

**建议（供 team-lead 裁决，二选一）**：
- **A（保留占位键）**：必须同时满足 ① 单测断言 8 个键、每个 `sounds` 为空、映射表对齐（把「有意为之」固化成可执行证据）；② 客户端启动日志显式打印「N 个占位 SoundEvent、0 个 .ogg」，让静默降级可见；③ 明确 .ogg 回填的下阶段任务与验收标准；④ 补一次「启动烟雾测试」验证 MC 是否告警（需人工审批后进入游戏，本轮不做）。
- **B（不注册占位键）**：只保留 `spec/audio-event-map.json` 作为映射数据，不随 jar 发布 `sounds.json` 占位键，避免发布死 registry 条目；`SoundEventMap.load()` 需相应去掉对 `SOUNDS_PATH` 的强依赖（L65、L78、L92–95、L130–132）。这是 engineering-lead 已给 team-lead 的备选方案。

QA 倾向：**在 .ogg 回填与启动烟雾测试落地前采用 B**，或采用 A 但把上述 ①②③ 作为硬性验收项；无论哪种，都不接受「占位键已打进 jar」等价于「音效已接通」。

## 补记.5 「两个并行时钟已闭合」静态核验（不重开数值门）

| 检查 | 实测 | 判定 |
|---|---|---|
| `WeaponState` 是否还自计时 | `implements AnimationTimeline.StateListener`（L32）；全文**无** `phaseStartMs`、`durationMs(String)`、`tick(long)`、无 `spec.clipLengthS` 读取；`onStateEntered(...)` L121 由时间轴回调推进 | 闭合 |
| 唯一时钟驱动 | `SsjjPortClient` 每 tick 只调 `timeline.tick(now)`（L131–133），并注释「★ 唯一时钟」；`AnimationTimeline` 提供 `StateListener` L146–154、`setListener` L169、`durationOf` L356、回调派发 L270 | 闭合 |
| 时间源 | `SsjjPortClient` L105 仍用 `System.currentTimeMillis()` 作为**单一时间源**（不是第二个时钟） | 无冲突 |
| 降级路径 | `WeaponState` 保留无 timeline 的降级构造（L54、L108–110：`timeline == null` 时 `new WeaponState(spec, now)`）；`SsjjPortClient` L71–75 `AnimationTimeline.load` 失败会 `timeline=null` 并打 error | **观察**：降级路径下相位/攻击计时行为本轮未验证，建议 QA-03 补一条「timeline 加载失败」用例 |

`state-transitions.json` 的 gaps 0/1 确为「ENG-03 已解决」说明（与 engineering-lead 陈述一致）；gaps 7 明确标注 `loop` 矛盾「保留·不裁决」，gaps 9 明确标注「实际音频播放仍缺」。**残留项**：`未找到` 由 QA-02 的 8 处上升到 **14 处**（因新增 gaps 详细写明原因与源码行号，属文档展开而非数值回归）；`shoot_3p`/`bolt`/`inspect` 触发时刻、MC 开镜 FOV、raiseSpeed、.ogg 仍为明示未解决项。这些 engineering-lead 均**没有编造数据**，符合 QA 证据要求。

## 补记.6 结论与 QA-03 派单建议

- **QA-01 / QA-02 判定不撤回**：总判定仍为 **CONCERNS — 未达签收**；资产门 PASS 的具体数值已过期，清理脚本门 CONCERNS（D3 FAIL）未修。
- 本补记**未重开数值门 R1–R4**（团队明确要求等 ENG-02 改完再安排；现 ENG-02 与 ENG-03 均已完成，数值门已具备复跑条件，但需 team-lead 派单）。
- 建议 **QA-03 一次跑完**：① 资产门按补记.2 的 6 组新哈希正式重发判定，并把 `sounds.json` / `audio-event-map.json` 纳入覆盖；② 数值门逐项复判 R1–R4，并**逐值定位断言**，验证 QA-01 的 `0.041 / 0.04 / 0.89 / 0.24 / 0.14 / 0.001` 六个期望值被 `SpreadContractTest` / `SpreadInputsTest` **真实 assert 覆盖**，不以「105 tests 存在」代替覆盖判定；③ 清理脚本门在 C1/C2 修复后复跑；④ 补 `sounds.json` 占位键形状单测与 timeline 加载失败降级用例；⑤ 确认 `loop` 矛盾与残留 14 处「未找到」的处置归属。
- 「BUILD SUCCESSFUL / 105 tests 全绿 / TimelineSelfTest 90 断言」均为 engineering-lead 陈述，**本补记未独立复现**（未跑构建/测试）。

## 补记.7 边界

- 未运行构建、测试、游戏；未执行 `cleanup_tacz.py`（含 dry-run）；未修改任何源码/配置/脚本/jar；仅追加本补记章节。
- `sounds.json` 的 MC 运行期行为、`SoundEvent` 是否自动注册、降级路径行为均为**静态推断 / 未验证**，不作已验证结论。
- QA-02.4 中「未跑构建/测试」的说明对本补记同样成立。

---

## 补记.8 证据补强与三处口径修正（QA 产物内更正，不触碰冻结快照）

> 触发：engineering-lead 接受 CONCERNS 并提供 `javap` 静态字节码证据、主动认领 `SoundEventMap.java:22` 的事实断言错误，且声明本轮冻结快照不改文件。我**独立复核**了该证据，并复核了自己此前两处表述的准确性。
> **本节只编辑 `notes/qa-report.md`（QA 产物）**，不触碰 `SoundEventMap.java` / `sounds.json` / jar，故冻结哈希不因本节漂移（见 8.7）。

### 8.1 独立 `javap` 复核：结论成立，且比原先判断更「静默」

审查对象：`.gradle/loom-cache/minecraftMaven/net/minecraft/minecraft-merged-f556725616/1.21.1-net.fabricmc.yarn.1_21_1.1.21.1+build.3-v2/minecraft-merged-...-v2.jar`（1.21.1 Yarn 命名 merged jar），`javap -c -p` 只读反汇编。

| 证据 | 反汇编结果 | 含义 |
|---|---|---|
| `SoundManager` 字段 | `TYPE` = `Map<String, SoundEntry>`；`sounds` = `Map<Identifier, WeightedSoundSet>`（字段声明 L19/L21）；`sounds.json` 字符串常量出现于资源加载路径 | 键进的是 SoundManager 自己的加权音集 map |
| `SoundManager.apply(...)` | 两处 `Registries.SOUND_EVENT.containsId(id)`（字节码偏移 92 / 175）；`LOGGER.error("Missing subtitle {} for sound event: {}")`（偏移 100–113）；`LOGGER.debug("Not having sound event for: {}")`（偏移 183–191，且外包 `isDebugEnabled()` 判断） | **只查询 registry，不写入** |
| 全类扫描 | **无** `Registry.register` / `registerDynamic` / `SoundEvent.of` / 任何把 id 写进 `Registries.SOUND_EVENT` 的调用 | `SoundEventMap.java:22`「Minecraft 会注册该 SoundEvent id」是**被静态证据否定的断言**，非「待验证」 |
| `SoundManager$SoundList.register(...)` | 仅 `loadedSounds.put(id, WeightedSoundSet)`、遍历 `SoundEntry.getSounds()` 调 `WeightedSoundSet.add(...)`；无任何 registry 写 | 同上，确认无自动注册 |

我额外追了两条与「空占位键」直接相关的 vanilla 路径（engineering-lead 未展开）：

- `WeightedSoundSet(Identifier, String)` 构造：`subtitle == null → this.subtitle = null`；`Texts.hasTranslation(Text)`：`ifnull → iconst_1`（**null 返回 true**）。本模组 `sounds.json` 8 个键**均无 subtitle** → `getSubtitle()` 为 null → `hasTranslation(null)==true` → `apply()` 里 `ifne` 直接跳过 error 分支；又因未注册，`containsId==false` → 只可能落 `LOGGER.debug("Not having sound event for: {}")`，且需 DEBUG 开启。**默认日志级别下完全静默、无 ERROR**。
- `WeightedSoundSet.getSound(Random)`：`sounds.isEmpty()` 或权重为 0 → 返回 `SoundManager.MISSING_SOUND`（不是 null、不抛异常）。即**静态确认无崩溃路径，但也确实不会发声**；播放时是否另有 MC 告警未实测。

**判定影响**：补记.4 的「静默降级」由**推测升级为静态字节码确认**；风险描述从「设计假设/未实现注册」升级为「占位键不进 `SOUND_EVENT` registry、默认日志级别无任何可见提示、播放回落到 MISSING_SOUND」。**倾向方案 B 的理由加强**。仍为 **CONCERNS**（无崩溃路径、可逆、范围可控），非 FAIL；运行期日志与播放行为依旧**未实测**（约束禁止启动游戏）。

### 8.2 口径修正 ①（我自己的表述过宽，主动更正）

补记.4 写「当前**无任何测试断言**占位键形状或 emptiness」——**不准确**。实读 `src/test/java/com/ssjj/port/weapon/SoundEventMapTest.java`：
- `alignedWithSoundsJson()` L25–30 已断言 `warnings().isEmpty()`、`map.size()==8`、`map.soundKeys().size()==8`、映射目标键全部被 `soundKeys` 包含；
- `confirmedEventNamesResolve()` L34–39、`everyTimelineSoundEventResolves()` L43–55、`missingEventsAreNotFabricated()` L59–68、`specEventAliases()` L72–77 覆盖了映射解析与「不编造未找到事件」。

**仍缺的**是：断言 `sounds: []` 数组为空、断言无 `.ogg`、断言运行期行为。故补记.6 中 A 方案第 ① 项应精确表述为「补 **emptiness / 无 .ogg** 断言并让静默降级可见」，不是「补键数断言」。结论（CONCERNS）不变。

### 8.3 口径修正 ②（降级路径范围细化，采纳 engineering-lead 的区分）

补记.5 写「降级路径下相位/攻击计时行为本轮未验证」易被读成「无用例」。实读 `MergedClockTest.java`：
- `degradedModeHasNoClock()` L172–182 **已覆盖**二参降级构造：`hasTimeline()==false`、`phase()==RAISING`、`tryFire/tryReload` 恒 false、`computeSpread(...)==0.041` 仍可用；
- `noSecondClockInWeaponState()` L30–43 用反射断言无 `tick(long)` / `phaseStartMs` / `durationMs`。
- **确实未覆盖**的是：`SsjjPortClient` L71–75 `AnimationTimeline.load()` 抛 `RuntimeException` → `timeline=null` → L108–110 选择二参构造的**客户端分支**（含后续 `timeline.tick` 的 null 保护 L132）。

补记.6 的「补 timeline 加载失败降级用例」据此细化为「补 **SsjjPortClient 客户端分支**的加载失败用例」，并入 QA-03。

### 8.4 口径修正 ③（engineering-lead 消息中一处条件描述与字节码相反，不影响其主结论）

其消息写「有 subtitle 但 registry 里没有 → `LOGGER.error`」。实际 `apply()` 字节码：
- error 分支条件为 `!Texts.hasTranslation(subtitle) && Registries.SOUND_EVENT.containsId(id)`（即 **id 已注册但缺 subtitle 翻译**）；
- `!Registries.SOUND_EVENT.containsId(id)` → **DEBUG** 而非 error。

其总体结论「`sounds.json` 键不会自动进 `Registries.SOUND_EVENT`」与我的独立复核**完全一致**，A/B 裁决不受影响；此处仅按 QA 证据准确性记录在案。

### 8.5 顺带记录：QA-03 数值门的一个起点（不作覆盖结论）

`MergedClockTest.degradedModeHasNoClock()` L181 已断言 `computeSpread(90.0, 0.0, true, true, false) == 0.041`（容差 1e-9），对应 QA-01 六值中的「站立静止 hipfire = 0.001 + 0.04」。这是 QA-03 的**起点**，**不等于**六值全覆盖；QA-03 仍须逐值定位 `SpreadContractTest` / `SpreadInputsTest` 的 assert，验证 `0.041 / 0.04 / 0.89 / 0.24 / 0.14 / 0.001`。本轮**未审数值门 R1–R4**。

### 8.6 冻结快照核对（支持 engineering-lead「本轮不改文件」的决定）

| 文件 | 本次实测 sha256(前8 / 前16) | 与 engineering-lead 陈述 |
|---|---|---|
| `SoundEventMap.java` (6,224 B) | `1044f863` / `1044f863bb9bfeff` | 一致 |
| `sounds.json` (420 B) | `0915f327` / `0915f327fa262afc` | 一致（亦与补记.2 一致） |
| `build/libs/ssjj-port-0.1.0.jar` (48,418 B) | `cc0c3d84` / `cc0c3d84745c4709` | 一致 |
| `tools/cleanup_tacz.py` (10,540 B) | `0be0ec6d` / `0be0ec6d62693f18` | 未变，D3/D1 仍开口 |

我支持「A/B 裁决与那行注释修正捆绑为同一批改动、让 jar 只变更一次」的做法，可避免 QA-03 再次重发资产门判定。B 与我一致；额外一点：静态证据显示 A 不只是补测试与日志，还得为 8 个本就不发声的 id 增加一条**真实 SoundEvent 注册路径**（`SsjjPort.java` 受保护不可动，只能落 `SsjjPortClient`），反而扩大静默降级的表面积 —— 与 engineering-lead 的判断一致。删除 `sounds.json` 属对 team-lead ENG-03 指令的偏离，**应由 team-lead 一次性裁决**。

### 8.7 本节边界

- `javap` 结论均为**静态字节码**，运行期是否真的输出 DEBUG/ERROR、播放时是否另有告警，**未实测**（约束禁止启动游戏）；不写成实测结论。
- 未跑构建/测试、未修改任何源码/配置/脚本/jar、未执行 `cleanup_tacz.py`；本节仅追加 QA 报告文本。
- QA-01 / QA-02 各章判定不撤回；**总判定仍为 CONCERNS — 未达签收**。本节不作新的门判定，等 team-lead 派 QA-03。

---

# QA-03 · 按 ENG-04 快照正式复判（五门）

| 项 | 内容 |
|---|---|
| 任务 | QA-03（按 ENG-04 裁决 B 后的快照复判） |
| 审查人 | quality-lead（严守真） |
| 审查方式 | 只读；**仅执行 `cleanup_tacz.py` 默认（无参数）dry-run**，未执行 `--apply`；未跑构建/测试/游戏；未改任何文件（仅追加本章节） |
| 审查对象 | 实测当前磁盘快照：jar **58,274 B**，`build/libs/ssjj-port-0.1.0.jar`，sha256(16) `3293fca77f5e6258` |
| QA-01/02 | 原文与判定逐字保留，不撤回 |

## QA-03.0 快照对账 —— 任务书所述「已冻结」不成立（必须先看）

任务书给的快照是 jar **47,915 B**、并声明「工程已冻结，本轮不会再改」。实测**审查期间快照又变了一次**：

| 项 | 任务书所述 | **本次实测** | 差异 |
|---|---|---|---|
| `build/libs/ssjj-port-0.1.0.jar` | 47,915 B | **58,274 B**（13:54:09） | **+10,359 B** |
| jar sha256(16) | 未给 | `3293fca77f5e6258` | — |
| 新增包 | 未提 | **`com/ssjj/port/render/`：`GltfModel` + 6 个内部类（13,013 B）** | 新子系统 |
| 新增测试 | 未提 | **`src/test/java/com/ssjj/port/render/GltfModelTest.java`（7 个 @Test）** | 测试类 +1 |
| 新增测试资产 | 未提 | `notes/assets/awm_fp.gltf`(28,218 B) / `awm_fp.bin`(109,152 B) / `awm_fp_tex.png`(232,489 B)（**不随 jar 发布**） | 非发布物 |
| 5 个资源 | 45,978 / 13,699 / 8,441 / 142 / 136 B | **完全一致，哈希未变**（见 QA-03.1） | 无变化 |
| `sounds.json` | 已撤 | **已撤**（jar 与 src 均无，副本在 `notes/_removed/sounds.json` 420 B） | 符合 B |

`src` 侧变更时间戳：`GltfModel.java` 13:53、`GltfModelTest.java` 13:53、jar 13:54；`SsjjPortClient.java` 13:26:35、`SoundEventMap.java` 13:24（属 ENG-04 那批）。**结论：本轮五门按实测 58,274 B 快照判定；新增 `render/GltfModel` 子系统不在五门范围内，本轮未审查**（未读其实现、未评估其质量），请 team-lead 确认是否另开范围。

> 对结论的影响：5 个资源内容与哈希未变、`sounds.json` 仍不存在，故第 1/2/3/5 门的结论对 47,915 B 与 58,274 B 两个快照**同时成立**；但「冻结」与 jar 字节数/哈希、测试数量（任务书 106；当前新增 `GltfModelTest` 7 个 @Test，未跑测试无法确认总数）**均已过期**，引用时请以本节为准。

## QA-03.1 门 1 · 资产门重签 — **PASS**

实测 jar 58,274 B。`src/main/resources` 共 **6 个文件 = 5 个资源 + `fabric.mod.json`**（任务书口径的「6 个资源」实际是 5 资源 + manifest；`sounds.json` 不在其中）。

| 文件（jar 内路径） | 源/jar 大小 | 源 sha256(16) | jar sha256(16) | 逐字节相等 |
|---|---|---|---|---|
| `assets/ssjjport/lang/en_us.json` | 142 / 142 | `56d1070bbae40e52` | `56d1070bbae40e52` | **True** |
| `assets/ssjjport/lang/zh_cn.json` | 136 / 136 | `acdc236143d05faf` | `acdc236143d05faf` | **True** |
| `assets/ssjjport/spec/audio-event-map.json` | 13,699 / 13,699 | `c3adcb702b038c74` | `c3adcb702b038c74` | **True** |
| `assets/ssjjport/spec/awm_legend_t.json` | 8,441 / 8,441 | `b294b1f1560d0f5c` | `b294b1f1560d0f5c` | **True** |
| `assets/ssjjport/spec/state-transitions.json` | 45,978 / 45,978 | `0bd222d3a70533a6` | `0bd222d3a70533a6` | **True** |
| `fabric.mod.json` | 474 / 469 | `d9c2c58057f2f3b6` | `cdbfe14f7dd3d70b` | False（**预期**：`${version}`→`0.1.0` expand） |

### ENG-04 核心断言：`sounds.json` 已不在 jar 内 —— **确认成立**

| 检查 | 结果 |
|---|---|
| 主 jar `namelist` 含 `assets/ssjjport/sounds.json` | **False** |
| 主 jar 内任何含 `sounds.json` 的条目 | **[]（0 条）** |
| `src/main/resources/.../sounds.json` 是否存在 | **False（已移除）** |
| 副本去向 | `notes/_removed/sounds.json` **420 B**（不在 `resources`，不随 jar 发布） |
| 其余 3 个 jar（sources / dev / dev-sources） | 均 **不含** `sounds.json`；5 个资源字节数与哈希与主 jar 逐一一致 |
| 5 个资源 JSON 可解析性 | 全部合法 JSON；`state-transitions.json` = 9 states / 10 gaps / 「未找到」14 处 |

**判定：PASS。**（注：`audio-event-map.json` 内部仍残留对 `sounds.json` 的引用与过期 note，属门 5 文档一致性问题，不影响本门的「打包字节一致 / 文件已撤」结论。）

## QA-03.2 门 2 · 数值门逐值定位 + R1–R4 复判 — **PASS**

### R1–R4 逐项复判

| 编号 | QA-01 原缺口 | 当前实现（文件:行） | 测试证据（方法:行） | 判定 |
|---|---|---|---|---|
| **R1** | `isWeightlessness` 分支缺失 | `WeaponState.java` `computeSpread(..., boolean isWeightlessness)` 6 参；分支 `if (!onGround && !isWeightlessness)`（与 C# `!OnGround() && !isWeightlessness` 一致）；5 参重载显式传 false | `SpreadContractTest.weightlessnessBranchIsLive` L74–81（0.89 vs 0.041 + `assertNotEquals`）；`sevenBranches` L52 行「腾空但失重 → 0.041」 | **CLOSED** |
| **R2** | `ducking` 语义反接 | 参数改名 `notFullyDucked`；分支 `else if (notFullyDucked) def; else duck;` → **完全蹲下(false) → DuckParam 0.0 + 0.04 = 0.04**；站立(true) → 0.001 + 0.04 = 0.041；Javadoc 写明依据 `HunterVssSpreadLogic.cs:52`、`DuckManager.cs:77-89` | `SpreadContractTest.DuckContract.fullyCrouchedGetsDuckParam` L146–148（**0.04**）；`notFullyDuckedGetsDefaultParam` L152–154（0.041）；`mustNotBeSwapped` L158–162；`SpreadInputsTest.duckMapping` L110–115（`toNotFullyDucked(true)==false`） | **CLOSED** |
| **R3** | FOV 输入域未适配（MC 70 透传恒 0.001） | `SpreadInputs.toOriginalFov(mcFov, isScoping)` L131–138：未开镜恒 **90**、开镜 → `scopedFov`（spec 默认 **40**）；`ORIGINAL_FOV_UNSCOPED = 90.0` L54 | `unscopedMapsTo90` L39–42（30/70/89/90/91/110 → 90）；`scopedMapsToNon90` L47–51；`directMcFovPassthroughIsWrong` L62–67（明确断言「透传 MC 70 = 恒 0.001」这一 bug）；`badScopedFovIsRejected` L156–165；`adaptationConfigPresent` L193–206 | **CLOSED** |
| **R4** | speed2D 单位域未换算 | `SpreadInputs.toOriginalSpeed2D` L146–148 = `mcSpeed * speedScale`（spec `speed.scale = 2000.0`，L63）；降级回退 1.0 + WARN（L105–113） | `speedScale` L79–81（0.0125→25、0.175→350、0.28→560）；`endToEndSpeed` L100–104（0.175→0.14、0.1755→0.24）；`speedScaleConfigured` L85–89；`missingConfigFallsBackWithWarning` L139–152 | **CLOSED** |

**R4 单位换算的独立量纲核验**：1 block = 1 m、1 tick = 0.05 s ⇒ 1 block/tick = 1 m ÷ 0.05 s = 20 m/s = **2000 cm/s**。因此 `scale=2000.0` 不是拍脑袋常数，量纲自洽；且 `SpreadInputsTest` 用 0.28 blocks/tick（典型疾跑）→ 560 cm/s 做端到端验证，能真实跨过 350/25 两档。

### 六个期望值 —— 逐值定位到具体断言（不以「106 tests 全绿」代替）

| 期望值 | 语义 | 覆盖位置（方法 + 行号 + 断言机制） |
|---|---|---|
| **0.041** | 站立静止（Default 0.001 + FovAdd 0.04） | `SpreadContractTest.sevenBranches` CsvSource **L45** → assert **L58–60**；`DuckContract.notFullyDuckedGetsDefaultParam` **L153**（直接 assert）；`weightlessnessBranchIsLive` **L80**；`fovBoundary` CsvSource L89 → assert L93；`speedBoundary` CsvSource L109–110 → assert L117；`SpreadInputsTest.endToEndSpeed` CsvSource L94–95 → assert L101–103；`mcDomainEntry` CsvSource L120 → assert L129–132；`MergedClockTest.degradedModeHasNoClock` **L181** |
| **0.04** | 完全蹲下（Duck 0.0 + 0.04） | `SpreadContractTest.DuckContract.fullyCrouchedGetsDuckParam` **L147**（直接 assert）；`sevenBranches` CsvSource L46 → assert L58；`fovAddOnlyAt90` **L101**（差值为 0.04）；`speedBeatsDuck` CsvSource L124 → assert L129；`SpreadInputsTest.directMcFovPassthroughIsWrong` **L66**（直接 assert）；`mcDomainEntry` CsvSource L121 → assert L129 |
| **0.89** | 腾空（Air 0.85 + 0.04） | `SpreadContractTest.fiveArgOverloadDelegatesWithFalse` **L70**（直接 assert）；`weightlessnessBranchIsLive` **L78**；`airBeatsSpeed` **L135**；`sevenBranches` CsvSource L47；`SpreadInputsTest.mcDomainEntry` CsvSource L122 |
| **0.24** | speed > 350（L1 0.2 + 0.04） | `SpreadContractTest.sevenBranches` CsvSource **L48**；`speedBoundary` CsvSource **L114**（351.0）；`speedBeatsDuck` CsvSource **L126**（351.0）；`SpreadInputsTest.endToEndSpeed` CsvSource **L98**（0.1755）。**注**：无独立 `assertEquals(0.24, …)` 字面量，全部经参数化 `assertEquals(expected, …)`，属真实断言 |
| **0.14** | speed > 25（L2 0.1 + 0.04） | `SpreadContractTest.sevenBranches` CsvSource **L49**；`speedBoundary` CsvSource **L111/112/113**（26 / 349 / 350）；`speedBeatsDuck` CsvSource **L125**；`SpreadInputsTest.endToEndSpeed` CsvSource **L96/97**（0.013→0.14、0.175→0.14） |
| **0.001** | 开镜 / 特殊模式（Default，无 FovAdd） | `SpreadContractTest.sevenBranches` CsvSource **L50**（开镜 40）/ **L51**（特殊模式）/ **L53**（开镜+特殊模式 10.0）；`fovBoundary` CsvSource **L88**（89→0.001）/ **L90**（91→0.001）；`DuckContract.duckIgnoredInDefaultBranch` **L168–169**（直接 assert）；`SpreadInputsTest.scopedSpreadIsDefault` **L56**；`directMcFovPassthroughIsWrong` **L64**；`mcDomainEntry` CsvSource **L123/124** |

**结论：六个值均有真实 `assertEquals` 断言覆盖（4 个有直接字面量断言，2 个经参数化 CsvSource 行），不是「测试数量代替覆盖」。**

### 数值门残留观察（不阻塞，但需登记）

1. **运行时输入是近似映射，不是严格等价**：`SsjjPortClient.logSpread`（L170–197）用 `player.isSneaking()` 当「完全蹲下」、`isScoping=false`（开镜未实现）。Javadoc 已如实写明「与 DuckState()==0 并非严格等价，后续需替换」。**公式契约已 1:1，但运行期输入仍是近似**，故「1:1 手感」尚不能据此宣称完成。
2. `SpreadInputs.toOriginalFov(mcFov, isScoping)` **完全忽略 `mcFov`**（L131–133）：MC FOV 滑条/缩放对散布无影响。设计上以「原版 FOV 域 + isScoping 布尔」为准，可接受，但后续接 ADS 必须走 `isScoping`，不能传 MC FOV。
3. `mcScopedFov = "未找到"`（`adaptationConfigPresent` L201 断言该字符串），开镜值固定用 spec 的 40 —— 属**明示未知**，未编造，可接受。
4. 阈值比较严格 `>`（25/350 本身落低档），与 C# 一致；`speedBoundary` L109–114 已覆盖。

**判定：PASS**（R1–R4 全部闭环且六值逐条可定位；上述 4 点为运行期/配置层的明示近似与未知，已在门 3/门 6 记录，不否定数值契约本门）。

## QA-03.3 门 3 · 清理脚本安全门复跑 — **PASS**（3 项 Minor）

对象：`tools/cleanup_tacz.py` 11,824 B，sha256(16) `73b9569155945d9b`（ENG-04 已改，旧版 10,540 B）。

### 独立默认 dry-run（无参数，只读）

`python tools/cleanup_tacz.py` 实测：模式 **`DRY-RUN（默认，不落盘）`**；`tasklist 返回 238 行，命中 ['oneclient_app.exe']`；2 个 `[KEEP]`（245,562 B / 237,187,893 B）；5 个 `[BLOCK]`（4 精确 jar + `.minecraft\tacz` 98.21 MiB，junction 解析到 `clusters\1.21.1 Fabric\mods`）；3 项工程侧 `[DRY-RUN]`（1.55 / 50.24 / 55.37 MiB）；异常/冲突 **0 项**；**`EXIT_CODE=2`**。
**无落盘证明**（跑完后复查）：`_archive` **不存在**；`mc-port\tools` 仍 **44** 文件、`mc-port\fpmod` 仍 **258** 文件；运行时 mods 仍 **144** jar；脚本哈希未变。

### D1 / D2 / D3 闭环核验（行号为本 11,824 B 版本）

| 缺陷 | 修复证据 | 判定 |
|---|---|---|
| **D3**：dry-run 非默认 | `--apply` 为 opt-in（L188–189），`dry_run = not args.apply`（L193）；L200 打印 `DRY-RUN（默认，不落盘）`；**确认门 L222–234 位于任何归档调用之前**（归档从 L236 `[2]` 才开始）：`input("> ")` 必须等于 `YES`，否则 `return 3`；`EOFError` 也安全取消 | **CLOSED** |
| **D1**：检测失败未保守判定 | `detect_game_process` L115–119 新增 `if proc.returncode != 0 or not (proc.stdout or b"").strip(): return True, [], "…保守判定为「运行中」"`，并把 `stderr` 写入诊断；原有异常分支 L110–111 仍返回 True | **CLOSED** |
| **D2**：退出码优先级 | L288–290 `if running: return 2` **先于** L291–293 `if conflicts: return 1` | **CLOSED** |

其余三条保持：精确白名单（`RUNTIME_MOD_JARS` L48–53 / `DEAD_JARS` L56–59，L47/L55 注明不做模糊匹配）、KEEP 硬保护（`KEEP_PATHS` L62–65、`guard_keep` L140–146、L155–156 对 src/dst 双检）、移动而非删除（唯一变更 `shutil.move` L180；独立 grep 全文件**无** `os.remove`/`os.unlink`/`os.rmdir`/`shutil.rmtree`/`unlink(`/`remove(`/`write_text`/`write_bytes`，仅 L14 注释提及）、幂等/CONFLICT（L158–169）、带日期隔离目录（L37）。

### Minor 发现（不影响 PASS，建议修）

| ID | 内容 | 建议 |
|---|---|---|
| F1 | **`--dry-run` 与 `--apply` 同时出现时 `--apply` 生效**：`dry_run = not args.apply`（L193），`--dry-run` 被静默忽略。命令行里写了 dry-run 却真实执行，属安全反直觉 | `if args.dry_run: dry_run = True` 让 dry-run 优先，或对冲突参数报错退出 |
| F2 | **退出码 3 未写入 docstring**：L21–24 只列 0/1/2，L232 `return 3`（取消）无说明 | 补 `3 = APPLY 未确认，未移动任何文件` |
| F3 | **docstring 用法过期**：L16–19 仍写「先 `--dry-run`，再裸命令」，但裸命令现在也是 dry-run，真实执行是 `--apply` | 更新用法为 `（默认 dry-run）` / `--apply`（需输入 YES） |

**判定：PASS。** 五条验收标准全部满足；D1/D2/D3 闭环已独立复核；未执行 `--apply`（遵守约束），其确认门为静态核对 + 默认 dry-run 实测。

## QA-03.4 门 4 · 降级路径（`timeline=null` 客户端分支）— **CONCERNS（非阻塞）**

**事实**：`grep -rn "SsjjPortClient" src/test tools` → **无任何引用**；现有 6 个测试类均不覆盖 `SsjjPortClient.onInitializeClient()`。故「`AnimationTimeline.load()` 抛异常 → `timeline=null` → 走二参构造」这条客户端分支**确实无用例**（与 team-lead 自述一致）。

**失败模式静态分析**（`SsjjPortClient.java`，10,320 B）：

| 检查 | 结果 |
|---|---|
| `AnimationTimeline.load` 异常处理 | L70–76 `try/catch (RuntimeException)` → `LOG.error` + `timeline=null`，不抛出 |
| `WeaponState` 构造 | L106–110：`timeline != null ? 三参 : 二参`，两条路都建 state，无 NPE |
| 二参构造行为 | 已由 `MergedClockTest.degradedModeHasNoClock` L172–182 覆盖：`hasTimeline=false`、`tryFire/tryReload` 恒 false、`computeSpread` 仍可用 |
| 后续 `timeline` 解引用 | L132 `if (timeline != null)` 守卫包住 `tick`/`currentStateId`/`durationOf` 全部调用 |
| `soundEventMap` 失败 | L78–86 独立 `try/catch` → null；L134–135 用 `soundEventMap == null ? "未找到" : …` 三元保护 |
| `spreadInputs` 失败 | L95–103 `try/catch`；`logSpread` L170–172 首行 `if (spreadInputs == null || client.player == null) return;` |

**判定依据**：失败模式是**安全降级**（不崩溃、打 ERROR、散布诊断仍可用、只是不能开火/换弹），且降级后的核心行为已有 WeaponState 级单测；未覆盖的仅是 6 行 wiring。因此：

- **结论：不作为本轮放行的阻塞项，记 CONCERNS。**
- **但必须登记为后续必补用例**：建议把「加载失败选择器」抽成可注入函数（或提供 `AnimationTimeline.loadOrNull()`），用「不存在的 spec id」触发异常并断言 `timeline==null`、`state` 为二参构造、`tryFire` 返回 false、不抛异常。**在该用例补齐前，不应把「降级路径已测试」写进任何完成声明。**

## QA-03.5 门 5 · 文档一致性 — **CONCERNS**

### 已一致（通过）

| 文件 | 现状 |
|---|---|
| `README.md` L24 / L29 / L138–142 / L175 / L182 / L250 | 已写明「ENG-04 撤掉 `sounds.json` 占位键；只有映射，无 .ogg、无 SoundEvent 注册」；L142 声明「`SoundEventMapTest` 断言 jar 内不存在 sounds.json」——**实读 `SoundEventMapTest.soundsJsonRemoved` L23–28 确实如此断言，属实** |
| `notes/state-transitions.md` L212 / L233 | 已写明「ENG-04 已撤掉占位键，只保留映射表；无 .ogg、无 SoundEvent 注册」 |
| `tools/TimelineSelfTest.java` L169–171 | 注释「ENG-03/P1 + ENG-04：音效映射（无 sounds.json）」 |
| `SoundEventMap.java` L19–46 | 类注释已按 javap 证据改写：「不注册任何 SoundEvent」「默认日志级别下完全静默」，无「会注册」的旧断言 |

### 仍不一致（4 处过期表述 + 1 个回写陷阱）

| # | 位置 | 问题 | 影响 |
|---|---|---|---|
| 1 | **`src/main/resources/assets/ssjjport/spec/audio-event-map.json`**（**随 jar 发布**） | `"soundsJson": "assets/ssjjport/sounds.json"` 指向已删除文件；`"note"` 仍写「sounds.json 里的键是空 sounds 数组的占位键；只有占位……」 | 发布物内自带与 ENG-04 决定相矛盾的说明 |
| 2 | **`src/main/resources/assets/ssjjport/spec/state-transitions.json`**（**随 jar 发布**） | `gaps[9]` 仍写「sounds.json 只有空 sounds 数组的占位键……没有 .ogg」；`audioEvents.soundsJson` 同样指向已删文件 | 同上；且与 `notes/state-transitions.md` L212 自相矛盾 |
| 3 | **`tools/backfill_audio_events.py`** | L91 `SOUNDS_OUT.write_text(...)` **仍会重新生成 `assets/ssjjport/sounds.json`**；L66–67 / L104 仍写入 `soundsJson` 与过期 note；L177 仍写「sounds.json 只有空占位键」；**L89 注释仍断言「空 sounds 数组 = 注册 SoundEvent 但静音」——正是被 javap 否定的错误结论** | **重跑该生成器会静默撤销 ENG-04 的 B 决定**，重新引入静默降级物 |
| 4 | `tools/export_audio_events.py` 等上游说明 | 未逐一核（不在本轮文件清单）；建议与 #3 同批排查 | 潜在同类过期 |

**判定：CONCERNS。** 当前 jar 运行时不受影响（`SoundEventMap` 只读 `audio-event-map.json` 的映射段，不解析 `soundsJson`/`note`），但：① 发布物内存在 2 处与决定矛盾的说明；② 生成器仍能一键回退 B 决定。**门 5 的修复是「重新生成/发布」的前置条件。**

## QA-03.6 总判定与条件

| 门 | 判定 |
|---|---|
| 1. 资产门重签 | **PASS**（5 资源 + manifest 逐字节/哈希一致；`sounds.json` 在 4 个 jar 中均 0 条） |
| 2. 数值门逐值定位 | **PASS**（R1–R4 全闭环；六值均有具体 assert 方法与行号；含 4 项运行期近似观察） |
| 3. 清理脚本安全门 | **PASS**（D1/D2/D3 闭环；默认 dry-run 实测 EXIT=2、5 BLOCK、0 异常、无落盘；3 项 Minor：F1/F2/F3） |
| 4. 降级路径 | **CONCERNS**（非阻塞；失败模式安全，用例仍缺，登记必补） |
| 5. 文档一致性 | **CONCERNS**（README/md/自检脚本已改对；**jar 内 2 处 + 生成器回写陷阱**未清） |
| **总判定** | **CONCERNS（有条件通过）** |

**结论：本轮交付可作为该阶段签收，但不得宣称「无遗留」。放行附 5 项条件（按优先级）：**

| ID | 条件 | 归属 | 验收标准 |
|---|---|---|---|
| **Q1** | 清理 `audio-event-map.json` 的 `soundsJson` + 过期 `note`，与 `state-transitions.json` 的 `gaps[9]` + `audioEvents.soundsJson` | 落地人 | 两个 JSON 中 `sounds.json` 出现次数 = 0；jar 内两文件哈希更新并重跑门 1 |
| **Q2** | `tools/backfill_audio_events.py` 停止生成 `sounds.json`、删除 L89 的「注册 SoundEvent」错误断言、同步更新写入的 note/字段 | 落地人 | 干跑生成器不再产出 `sounds.json`；产物与 Q1 一致；`git diff` 无 `sounds.json` 新增 |
| **Q3** | 客户端降级分支补用例（`AnimationTimeline.load` 抛异常 → `timeline=null`） | 落地人 | 新用例断言 `timeline==null`、二参构造、`tryFire==false`、不抛异常 |
| **Q4** | 清理脚本 F1（`--dry-run --apply` 冲突优先 dry-run）、F2（补退出码 3）、F3（更新 docstring 用法） | 落地人 | 三项改完复跑门 3 |
| **Q5** | **快照漂移需 team-lead 明确**：`render/GltfModel` + `GltfModelTest` + `notes/assets/*.gltf|bin|png` 于 13:52–13:54 落地（jar 58,274 B，非任务书 47,915 B），**不在本轮五门范围** | team-lead | 确认是否另开范围审查；若涉及发布，须补资产/依赖/降级/文档门 |

> 说明：`sounds.json` 的撤除（ENG-04 裁决 B）已按静态字节码证据执行到位，门 1 核心断言成立；门 5 的问题是「撤了文件，但说明与生成器没跟着撤」，属可修的一致性问题，不是 B 决定本身错误。

## QA-03.7 边界

- 未跑构建/测试/游戏：任务书所述「BUILD SUCCESSFUL / 106 tests / TimelineSelfTest 90 断言」**未独立复现**；仅静态清点当前 6 个测试类的 `@Test` 方法与参数化行（`GltfModelTest` 7 / `MergedClockTest` 8 / `SoundEventMapTest` 6 / `SpreadContractTest` 9 方法+21 行 / `SpreadInputsTest` 6 方法+14 行 / `AnimationTimelineTest` 6），与「106」的对应关系未验证（新增测试类后总数大概率已变）。
- 仅执行 `cleanup_tacz.py` **默认 dry-run**；**未执行 `--apply`**（含确认门），其安全性为静态核对。
- 未修改任何源码/配置/脚本/jar；仅追加本 QA-03 章节。未对新增 `render/GltfModel` 做任何审查。

---

# QA-04 · 复验 Q1/Q2/Q4 修复（Q3 未做、Q5 已裁决范围外）

| 项 | 内容 |
|---|---|
| 任务 | QA-04：复验 Q1（生成物字段）/ Q2（生成器不回退 B）/ Q4（清理脚本 F1/F2/F3） |
| 审查人 | quality-lead（严守真） |
| 审查对象 | 实测快照：jar **58,410 B**（13:59:53），sha256(16) `ec0957696007beb0` |
| 允许动作 | 只读；**运行了 `backfill_audio_events.py` 做幂等验证**（任务书明确允许：只读 notes + 写 resources）；运行了 `cleanup_tacz.py` 默认 dry-run 与 `--dry-run --apply`（F1 验证，按设计不落盘）；**未执行 `--apply` 单独调用**；未跑构建/测试/游戏；未改任何文件（仅追加本章节） |
| QA-01/02/03 | 原文与判定逐字保留 |

## QA-04.1 快照对账

| 项 | QA-03 快照 | **QA-04 实测** | 变化 |
|---|---|---|---|
| `build/libs/ssjj-port-0.1.0.jar` | 58,274 B | **58,410 B** | +136 B（资源改动后重编） |
| jar sha256(16) | `3293fca77f5e6258` | **`ec0957696007beb0`** | 已重签 |
| `audio-event-map.json` | 13,699 B | **13,815 B** | +116 B（Q1 字段改写） |
| `state-transitions.json` | 45,978 B | **45,992 B** | +14 B（Q1 gaps 改写） |
| `cleanup_tacz.py` | 11,824 B | **12,249 B** | +425 B（Q4 F1/F2/F3） |
| `backfill_audio_events.py` | — | **11,049 B** | Q2 改写 |
| `sounds.json` | 不存在 | **仍不存在**（jar/src 均无） | 符合 B |

> Q5 已由 team-lead 裁决：`render/GltfModel` + `GltfModelTest` + `notes/assets/` 属渲染层，**不纳入本轮五门**；QA-03 中「本轮一字未审」的表述保留，等渲染层成形后另派。本轮仍**未审查**该子系统。

## QA-04.2 门 1 · 资产门重签 — **PASS**

| 文件（jar 内路径） | 源/jar 大小 | 源 sha256(16) | jar sha256(16) | 逐字节相等 |
|---|---|---|---|---|
| `assets/ssjjport/lang/en_us.json` | 142 / 142 | `56d1070bbae40e52` | `56d1070bbae40e52` | True |
| `assets/ssjjport/lang/zh_cn.json` | 136 / 136 | `acdc236143d05faf` | `acdc236143d05faf` | True |
| `assets/ssjjport/spec/audio-event-map.json` | 13,815 / 13,815 | **`a92959c8d2daae92`** | **`a92959c8d2daae92`** | True |
| `assets/ssjjport/spec/awm_legend_t.json` | 8,441 / 8,441 | `b294b1f1560d0f5c` | `b294b1f1560d0f5c` | True |
| `assets/ssjjport/spec/state-transitions.json` | 45,992 / 45,992 | **`460cf0921167a698`** | **`460cf0921167a698`** | True |
| `fabric.mod.json` | 474 / 469 | `d9c2c58057f2f3b6` | `cdbfe14f7dd3d70b` | False（预期 `${version}`→`0.1.0`） |

- `src/main/resources` 共 6 个文件（5 资源 + manifest），**6/6 进 jar**，无缺失、无多余。
- **`sounds.json` 断言**：主 jar 内 `assets/ssjjport/sounds.json` **False**，任何含 `sounds.json` 的条目 **0**；sources / dev / dev-sources 三个 jar 同样 **False**；`src/main/resources` 亦无；副本仍在 `notes/_removed/sounds.json`（不在 resources，不发布）。
- 其余 3 个 jar 的 5 个资源字节数与哈希与主 jar 逐一一致。

**判定：PASS。**

## QA-04.3 门 5 · 文档一致性复查 — **PASS**（1 项术语 nit）

### Q1 生成物字段（随 jar 发布的两文件）—— 4 处不一致已消失

| 原不一致 | 现状 | 判定 |
|---|---|---|
| `audio-event-map.json` `soundsJson` 指向已删文件 | **`"soundsJson": null`**（原始文本 L6 确认） | 已修 |
| 同文件 `note` 仍称「占位键存在」 | 已改写：「不生成 sounds.json：ENG-04 经 javap 核实，sounds.json 的键不会自动进 `Registries.SOUND_EVENT`，无 subtitle 时连 ERROR 分支都被跳过，默认日志级别下完全静默——保留占位键等于『有事件帧、没声音、无报警』」 | 已修 |
| 同文件 `unmappedClipsNote` 用「占位键」 | 改为「不注册为映射键、不编帧号」 | 已修 |
| `state-transitions.json` `audioEvents.soundsJson` 过期 | **`"soundsJson": null`**（原始文本 L692） | 已修 |
| 同文件 `gaps[9]` 仍称「sounds.json 只有空占位键」 | 改为「ENG-04 已撤掉 sounds.json 占位键，只保留映射表；没有 .ogg、没有 SoundEvent 注册、没有播放调用」 | 已修 |

**口径校正（细节）**：team-lead 说「两文件里 `sounds.json` 各只剩 1 处」——实测 `audio-event-map.json` 有 **2 处**（均在同一条 `note` 内：「不生成 sounds.json」+「sounds.json 的键不会自动进…」），`state-transitions.json` 有 **1 处**（`gaps[9]`）。**两处都是解释「已撤销」的正当陈述，无过期指向**，不影响结论，仅把数字校准为 2/1。
结构未回归：`state-transitions.json` states **9** / gaps **10** / `audioEvents` 键仍存在（status / rawSoundConfig / audioClips / derivedTable / eventMap / soundsJson=null / exporter / backfill / authority / confirmedSpecEvents / stillMissing / note）。

### Q2 生成器不再回退 B —— 已修 + 幂等实测

- 代码层：`tools/backfill_audio_events.py` 已无 `SOUNDS_OUT` 常量、无 `sounds.json` 生成段；唯一写目标是 `MAP_OUT`（L86）与 `STATES`（L180）；`soundsJson` 写 `None`（序列化为 `null`）；L90–91 新增残留检测「若 `RES/sounds.json` 存在则 warn 提示手动删除」；**原 L89「空 sounds 数组 = 注册 SoundEvent 但静音」的错误断言已删除**，替换为 javap 依据的正确表述（「不会自动进 `Registries.SOUND_EVENT`」）。
- **幂等实测（我亲自跑）**：`python tools/backfill_audio_events.py` → EXIT=0，输出 `audio-event-map.json 13,815 B (8 个映射键)` / `state-transitions.json 45,992 B (gaps=10)`；
  - 运行前哈希 `a92959c8d2daae92` / `460cf0921167a698`，运行后**逐字节不变**（哈希一致）→ **幂等成立，且不会让已构建的 jar 变旧**；
  - 运行后 `src/main/resources/assets/ssjjport/sounds.json` **不存在**；`notes/_removed/sounds.json` 保留。
- 上游 `tools/export_audio_events.py`：grep `sounds.json|注册 SoundEvent|占位键` **无命中**，无同类过期表述。

### 全仓误导表述扫描（排除 qa-report）

命中均为**正确表述**：README L24/L139–141/L175「已撤掉 / 不注册 / 保留占位键更危险」、L265「下阶段补 .ogg 并注册 SoundEvent」（未来任务，正确）、`notes/state-transitions.md` L212、`backfill` L69/L175、`audio-event-map.json` note、`state-transitions.json` gap[9]、`SoundEventMap.java` L20/L28/L86。**未发现「sounds.json 会注册 SoundEvent」的残留错误断言。**

### 唯一 Minor（术语 nit，不阻塞）

`SoundEventMap.java` L103 / L111 的 Javadoc 仍写「动画事件名 → **占位键**」「spec 事件 → **占位键**」。ENG-04 后已无占位文件，准确说法应是「映射键」。仅注释术语，无功能影响；建议下次触碰该文件时顺手改。

**判定：PASS**（4 处不一致全部消失、生成器幂等且不回退 B；仅 1 项注释术语 nit）。

## QA-04.4 门 3 · 清理脚本安全门复跑 — **PASS**

对象：`tools/cleanup_tacz.py` 12,249 B，sha256(16) `639c254bd52a6b88`。

### F1/F2/F3 独立验证

| 项 | 证据 | 判定 |
|---|---|---|
| **F1 `--dry-run` 优先** | 代码 L196–199：`if args.apply and args.dry_run: args.apply = False` + 提示，**位于 `dry_run = not args.apply`（L199）、确认门（L229–238）、任何归档调用之前**；实测 `python tools/cleanup_tacz.py --dry-run --apply` → 打印 `[i] 同时给了 --apply 与 --dry-run：以 --dry-run 为准，本次不落盘。`、模式 `DRY-RUN（默认，不落盘）`、**EXIT=2**、5 个 BLOCK、3 个 dry_run、0 异常 | **CLOSED** |
| **F2 退出码 3 入文档** | docstring L21–26 现含 `3 = --apply 的确认门未通过（输入不是 YES 或 EOF），未移动任何文件` | **CLOSED** |
| **F3 用法更新** | docstring L16–19 现为「默认就是 dry-run」+ 两行命令（默认 dry-run / `--apply` 真实移动需输入 YES） | **CLOSED** |

### 默认无参复跑

`python tools/cleanup_tacz.py` → 模式 **`DRY-RUN（默认，不落盘）`**、tasklist 命中 `oneclient_app.exe`、2 个 `[KEEP]`、5 个 `[BLOCK]`、3 项 `[DRY-RUN]`、异常/冲突 **0**、**EXIT=2**。

### 无落盘证明（两次运行后复查）

`_archive` **不存在**；`mc-port\tools` 仍 **44** 文件、`mc-port\fpmod` 仍 **258** 文件；运行时 mods 仍 **144** jar。未执行 `--apply` 单独调用；确认门为静态核对（输入 YES 才继续，否则 `return 3`，EOF 也取消）。

**判定：PASS。** F1/F2/F3 全部闭环；D1/D2/D3（QA-03 已闭环）未回归。

## QA-04.5 Q3（降级路径用例）— **CONCERNS（登记，非阻塞）**

`grep -rn "SsjjPortClient" src/test tools` 仍**无任何引用**；该客户端分支（`AnimationTimeline.load()` 抛异常 → `timeline=null` → 二参构造）**仍无用例**，与 team-lead 自述一致。
维持 QA-03.4 判定：失败模式为安全降级（不崩、ERROR 日志、散布仍可用、仅不能开火/换弹），二参构造行为已有 `MergedClockTest.degradedModeHasNoClock` 覆盖，未覆盖的仅是 wiring → **不作为本轮放行阻塞项**；方案（抽可注入 loader / `loadOrNull()`，用不存在 spec id 触发）留待渲染层接入时一并做。**在补齐前不得宣称「降级路径已测试」。**

## QA-04.6 总判定

| 门 | QA-03 | **QA-04** |
|---|---|---|
| 1. 资产门 | PASS | **PASS**（按新哈希重签） |
| 3. 清理脚本安全门 | PASS | **PASS**（F1/F2/F3 闭环，无回归） |
| 5. 文档一致性 | CONCERNS | **PASS**（4 处不一致清零，生成器幂等且不回退 B） |
| Q3 降级用例 | CONCERNS（非阻塞） | **CONCERNS（登记，非阻塞，未做）** |
| Q5 渲染层 | 待裁决 | **范围外**（team-lead 已裁决另开） |
| **总判定** | CONCERNS（有条件通过） | **PASS — 本轮可签收** |

**结论：Q1/Q2/Q4 复验通过，本轮可签收。** 附 2 项非阻塞登记：

| ID | 登记项 | 处理建议 |
|---|---|---|
| N1 | `SsjjPortClient` 降级分支无用例（Q3 未做） | 渲染层接入该分支会被真实执行时补；补齐前不宣称「降级路径已测试」 |
| N2 | `SoundEventMap.java` L103/L111 Javadoc 仍称「占位键」 | 下次触碰该文件时改为「映射键」 |

> 说明：Q1 的 `audioEventMap`/`stateTransitions` 两处 `soundsJson` 落为 `null` 而非删除字段，属保留结构兼容，可接受；`sounds.json` 在 4 个 jar 中均为 0 条，ENG-04 裁决 B 已完整落地。

## QA-04.7 边界

- 未跑构建/测试/游戏：team-lead 所述「BUILD SUCCESSFUL / 113 tests / TimelineSelfTest 90 断言」**未独立复现**；静态清点 6 个测试类（GltfModelTest 7 / MergedClockTest 8 / SoundEventMapTest 6 / SpreadContractTest 9 方法+21 行 / SpreadInputsTest 6 方法+14 行 / AnimationTimelineTest 6），与「113」的对应关系未验证。
- 运行了 `backfill_audio_events.py`（幂等验证，任务书允许）与 `cleanup_tacz.py` 默认/`--dry-run --apply`（均不落盘）；**未执行 `--apply` 单独调用**。
- 未修改任何源码/配置/脚本/jar；仅追加本 QA-04 章节。未审查渲染层（范围外）。





