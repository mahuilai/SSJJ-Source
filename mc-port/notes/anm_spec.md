# `.anm` 逐帧动画格式规格（P0 已实测验证）

## 规格来源

不是黑盒逆向，直接照反编译源码写：

- `Game source/02_managed_src/SSJJAnim_Library/SSJJAnim.Parser/SJAnimationPaser.cs` — `GenerateAnimations(byte[])` 是唯一解析入口
- `Game source/02_managed_src/Assembly-CSharp/Assets.Libs.SJAnimation.Parser/SJAnimationLoader.cs` — 从 `TextAsset.bytes` 喂进去，产出 `SJAnimationAsset.Clips`
- `Game source/02_managed_src/SSJJAnim_Library/SSJJAnim.Parser/SJAnimationAsset.cs` — `GetClip(name)` 按名取 clip
- `SSJJAnim_Library/SSJJAnim.Player/{SJAnimationClip,SJAnimationCurve,SJKeyFrame,SJAnimationPlayer}.cs` — 播放层
- `Assembly-CSharp/Assets.Libs.SJAnimation.Parser/DAEUtility.cs` — `FixImportRotation` 给导入模型加 `Quaternion.Euler(90° * Vector3.left)` 修正
- `Assembly-CSharp/Assets.Sources.Info.Career/DefaultCareerInfo.cs:174,194,199` — 动画资源命名规则 `{weapon}.anm.bytes` / `{type}_leg.anm.bytes` / `{type}_body.anm.bytes`
- `Assembly-CSharp/Assets.Sources.Modules.Player.Anim.ThirdPerson/LoadThirdPersonSystem.cs:225-300` — 第三人称动画资产注册清单

## 二进制布局（小端）

`ReadUTF` = `uint16 长度` + 该长度的 UTF-8 字节。

```
int32  version                    读后丢弃，实测均为 0
int32  groupCount                 实测 24
  UTF  groupName                  如 TORSO_STAND / TORSO_ATTACK / TORSO_RAISE
  int32 clipCount                 实测每组 1
    UTF   clipName                 通常为 <groupName>_blend0
    int32 curveCount               骨骼轨道数
    float length (秒)               <= 0 时取 1/30
    [ UTF   boneName
      int32 frameCount
      [ float time, float px, float py, float pz,
        float qx, float qy, float qz, float qw ] * frameCount   // 每帧 32 字节
    ] * curveCount
  ] * clipCount
] * groupCount
```

**源码里的坐标系变换，必须保留，否则动画左右镜像**：

```
Position    = (-px,  py,  pz)
Rotation    = Quaternion(qx, -qy, -qz, qw)
FrameRate   = (frameCount - 1) / length   当 frameCount > 1，否则 30
```

## 实测结果（`mc-port/tools/decode_anm.py` 已跑通）

| 文件 | 字节 | consumed | 组 | clip | 骨骼轨道 | 关键帧 | distinct bones |
|---|---|---|---|---|---|---|---|
| `gun.anm` | 103,554 | **103,554 / 103,554 OK** | 24 | 24 | 144 | 3,132 | 6 |
| `hand_man.anm` | 741,114 | **741,114 / 741,114 OK** | 24 | 24 | 1,032 | 22,446 | 43 |

`consumed == total` 证明格式理解 100% 正确，没有隐藏尾部或变长字段。

- `gun.anm` 骨骼：`Bip01`, `Dummy01`–`Dummy04`, `WeaponAnchor`（枪体 + 挂点）
- `hand_man.anm` 骨骼：完整 `Bip01_*` 手部/手臂/头骨链（43 根），`PlayerSkin` 的 42 骨与之对应
- 24 个动作组示例：`TORSO_STAND`, `TORSO_WALK`, `TORSO_ATTACK`, `TORSO_ATTACK_RAISE1..4`, `TORSO_RAISE`, `TORSO_SHOWGUN`, `TORSO_SPECIAL_STAND/WALK`, `TORSO_KNIFE_ATTACK1..3`, `TORSO_DIE`
- 每个 clip 的 `length` 与帧率可直接算；`hand.DAE.action` 给的 `start/end` 是**帧号**，用于把长 clip 切成动作段

## 动作时间轴（`hand.DAE.action`，主包 TextAsset，2,477 B，XML）

```
<action name="TORSO_STAND"  start="0"   end="0"   loop="true"/>
<action name="TORSO_WALK"   start="1"   end="25"  loop="true"/>
<action name="TORSO_ATTACK" start="571" end="606" loop="false"/>
<action name="TORSO_RAISE"  start="26"  end="40"  eventName="awm_legend_t_raise" loop="false"/>
<action name="TORSO_DIE"    ... />
```

`eventName` 关联音效/特效事件。这份表决定 TaCZ 侧 `idle / fire / reload / ads / draw / bolt` 六段动画该从哪段帧区间取。

## 到 Minecraft 的映射要点

1. **坐标系再翻一次**：`.anm` 已经是"取负后的 Unity 坐标"。Minecraft 是 Y-up、单位是方块/16。需按 `camera_man` 里的 `model3D` 矩阵定标（矩阵含平移 `153.8164` 等 cm 值），再按比例缩到 MC 手持物品尺寸。
2. `gun.anm` 与 `hand_man.anm` 是**同步的两套轨道**（同为 24 组、同组名），要按组名配对播放：枪体 6 骨 + 手 43 骨。
3. TaCZ/TML 侧动画容器是 `*.animation.json`（Bedrock 骨骼关键帧），骨骼名必须与 `geo.json` 里的 bone 名一致 → 保留 `Bip01_*` 原名。
4. `WeaponAnchor` / `Dummy0x` 是挂点（枪口、瞄具、弹壳抛出点），转 MC 时用来定位枪口火焰与弹道起点。
5. 用户要求逐帧还原，**不做关键帧抽稀降级**；22,446 帧全量导出，由 TML/渲染层决定插值。

## 复现

```
C:/Users/Mahuilai/.workbuddy/binaries/python/envs/default/Scripts/python.exe D:/逆向/SSJJ双塔惊魂/mc-port/tools/decode_anm.py
C:/Users/Mahuilai/.workbuddy/binaries/python/envs/default/Scripts/python.exe D:/逆向/SSJJ双塔惊魂/mc-port/tools/decode_anm.py --dump D:/逆向/SSJJ双塔惊魂/mc-port/out/anim
```

`--dump` 会输出 `gun_anm.json` / `hand_man_anm.json`（全量逐帧，体积较大）。
