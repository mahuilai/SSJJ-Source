# Claude 交接：SSJJ AWM 第一人称 Fabric 还原

> 记录时间：2026-11-08（Asia/Shanghai）  
> 目标：继续把 SSJJ 的 `awm_legend_t` 第一人称尽量还原到 Minecraft 1.21.1 Fabric。  
> **当前未完成验收。** 用户刚反馈最新包“动画转圈还发红，一点都不还原原版”。不要把“模型已提交到渲染队列”说成“还原成功”。

## 1. 用户目标与沟通要求

- 游戏 Minecraft Java 1.21.1 Fabric；武器为 TaCZ 物品 `ssjj:awm_legend_t`（AWM 传说皮肤）。
- 尽可能复现 SSJJ 原版第一人称：枪和双手构图/材质/颜色、持枪和展示、切枪、开火、换弹、拉栓动画及原版音效。
- 用户不接受 TaCZ 像素枪包风格或仅仅“能看出是枪”。当前效果明显错误。
- 用户已经多次亲自启动验证。**由用户启动 Minecraft；不要替用户启动。** 必须根据实机截图/录屏确认外观与动作后，才能报告完成。
- 用户对未经验证就声称“修好”的做法非常不满。沟通简短直接、承担责任，区分源码事实、推测和实机验证。

## 2. 最新状态：模组接管成功，画面验收失败

用户最新反馈：最新包进游戏后仍“动画转圈还发红”。用户之前还发过一张红色、尖角状、偏右下并被屏幕裁切的模型截图。问题是实现错误，不是用户操作问题。

日志：

`C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\clusters\1.21.1 Fabric\logs\latest.log`

2026-11-08 17:32 启动的运行：

```text
[17:33:27] [ssjjfp] anim loaded: 33 clips
[17:33:27] [ssjjfp] config loaded from ...\.minecraft\config\ssjjfp.json
[17:33:27] [ssjjfp] init done (model=true, anim=true)
[17:34:23] [ssjjfp] custom model submitted item=tacz:modern_kinetic_gun gunId=ssjj:awm_legend_t clip=idle ads=0.0 handVertices=1478 gunVertices=3070 putaway=false
[17:34:24] [ssjjfp] replaced outer first-person hands render; custom buffers flushed; TaCZ/vanilla pass cancelled
[17:35:48] Stopping!
```

日志证明 TaCZ gun ID 检测成功，Mixin 接管成功，手/枪顶点被提交，原版/TaCZ 第一人称通道被取消。**它不证明矩阵、颜色、动画或外观正确。** 本次游戏已经退出。

当前已安装包：

- `C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft\mods\1.21.1 Fabric\ssjj-fp-0.1.0.jar`
- SHA-256：`DFAEC797303D647CA06A311336B2B8DF02D3207CC785C75EDCF152FA548B4D51`；大小 1,206,189 B。
- 对应源码通过 Gradle `clean remapJar --rerun-tasks` 编译；只验证了构建与安装哈希，**没有视觉验收**。
- 配置 `C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft\config\ssjjfp.json`：scale=1.0，offX/offY=0，offZ=-0.25，yaw/pitch/roll=0，ADS 偏移为0。
- 最近覆盖前备份：`C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\clusters\1.21.1 Fabric\ssjjfp-backups\ssjj-fp-0.1.0-20261108-173058.jar`。目录下还有更早备份。不要删除。

## 3. 工程和文件

工程根：`D:\逆向\SSJJ双塔惊魂\mc-port\`

- Fabric 模组：`fpmod\`
- 数据导出：`tools\export_fp_model.py`、`tools\export_fp_anim.py`
- 模组源码：`fpmod\src\main\java\com\ssjj\fp\`
- 资源：`fpmod\src\main\resources\assets\ssjjfp\fp\awm.sjfp.json`、`awm.anm.json`、`awm.png`、`hand.png`
- 声音 OGG 已有：`fpmod\src\main\resources\assets\ssjjfp\sounds\fp\`，事件定义 `assets\ssjjfp\sounds.json`。存在资源不代表触发时序已验收。
- 旧交接：`HANDOVER-GPT.md`（路径、版本和资源信息有用，但“当前状态”和一些坐标断言已经过期；本文件记录最新失败状态，矩阵请重新推导）。

重要源码：

- `FpConfig.java`：单位、枪/手基矩阵、偏移。**当前矩阵未经视觉验证，注释不是正确性证明。**
- `FpRender.java`：骨骼求值、CPU 蒙皮、顶点提交、动画时钟。
- `Anm.java`：clip 和四元数采样。
- `FpRenderHook.java`：TaCZ 枪识别、状态机和声音触发。
- `mixin\GunFirstPersonMixin.java`：在 `HeldItemRenderer.renderItem` HEAD 接管主手，并取消原通道。

原始资产/源码：

- SSJJ 源码：`D:\逆向\SSJJ双塔惊魂\Game source\02_managed_src\Assembly-CSharp\Assets.Sources.Modules.Player.Anim.FirstPerson\LoadFirstHandSystem.cs`
- 武器主 bundle：`D:\逆向\SSJJ双塔惊魂\资源全集\weapon\awm_legend_t_4e41f53852ab64dd135a4278f48fd8fe`
- 武器 `$2` bundle：`D:\逆向\SSJJ双塔惊魂\资源全集\weapon\awm_legend_t$2_e9a49f8793d99257e2385e31752fd94a`
- 手模 bundle：`D:\逆向\SSJJ双塔惊魂\资源全集\viewhand\man_7054af81a181fa550c92e563decf7cb1`
- HandCamera prefab：`D:\逆向\SSJJ双塔惊魂\资源全集\effectprefab\handcamera_1f3d561656155c2038ed3387fb3ec028`

## 4. 源码/资源中直接确认的事实

在 `LoadFirstHandSystem.cs`（约 763–822、868 行后）：

- `AdjustForDontClearOptimize` 把 `weaponObj`、`handObj` 根节点缩放设成 `0.2`。
- `AdjustCamera` 把 HandCamera 设为 handObj 的子对象，并设置 `PlayerMesh` 的 Model3D 变换。
- `AdjustCameraTransform` 把矩阵分解出的位移设为 `(-x, z, -y)`。
- 原版由独立手持相机渲染，不是 Minecraft 普通物品的 held-item 变换。

bundle 中读取到：

- `p1_xm` 局部位置为 0，局部旋转四元数约 `(-0.7071068,0,0,0.7071068)`（X 轴 -90°）。
- `Camera01` Transform 位置约 `(13.9321,166.5704,-22.4655)`。
- `PlayerMesh`/Model3D 记录的位置约 `(0,153.8164,0)`。
- HandCamera prefab 旋转约 `(0,+0.7071,0,-0.7071)`，FOV 75、near clip 0.5。
- 这些单项事实**尚未证明**它们如何组成 MC 相机空间。完整 prefab 父子关系、运行时挂点、投影还未被正确复现。

导出链条的高风险处：

- `export_assets.py` 直接读 Mesh 顶点流并把顶点 X 取反写入 OBJ；没有显式烘焙完整 GameObject Transform 层级。
- `export_fp_model.py` 仅保留 `p1_xm`，用 `gun_xform(p)=(p.z,p.x,p.y)` 转坐标，注释称结果是 SSJJ view axes；但脚本没把 `p1_xm` 的 Unity Transform 旋转烘焙进顶点。
- 最新 `FpConfig` 又把枪坐标 `(x,y,z)` 映射到 MC `(x,z,y)`。这是上一轮根据导出注释作出的推断；用户实测它仍红且旋转异常，必须审计，不能当正确映射。
- `export_fp_anim.py` 把枪动画节点 `Dummy02` 改名为独立 `gun_root`，并用它驱动整枪。源 hierarchy 中 `Dummy02` 是 `WeaponAnchor` 子节点；父级/挂点关系没有明显保留，可能造成整枪姿态和动画错乱。
- `FpModel` 当前有 48 骨，手 1,478 顶点；旧交接写 45 骨/8 clip 已过时。最新日志加载 33 clips。

## 5. 首要排查线索

### 发红：overlay 调用疑似错误

`FpRender.java` 约第 201 行调用 `.overlay(overlay, overlay)`，而调用者传入的是打包值 `OverlayTexture.DEFAULT_UV`。`VertexConsumer` 有 `overlay(int packed)` 和 `overlay(int u,int v)` 两个重载；当前像是把一个 packed 值当成两个分量传入。优先核对是否把顶点采到红色受伤 overlay，并正确用 packed overload 或解包 UV，再通过单独的小改动验证颜色。**这只是高度可疑的代码线索，还未证明是红色唯一原因。**

### 转圈：当前 idle 轨本身是静止的

- 最新启动首次渲染日志为 `clip=idle`。
- `idle` 是约 0.0333 秒的单帧循环，`gun_root` 唯一关键帧为零位移、单位四元数。
- 因此，若待机时持续转圈，导出的 idle gun_root 轨本身解释不了它；需检查基矩阵、坐标基/四元数顺序、矩阵重复应用或实际运行时 clip。若只在开火/拉栓/展示动作时转圈，再追 `Dummy02`、WeaponAnchor 父级、`VIEW_BASIS` 转换和动作时间。
- 现有渲染日志只在首次画模型时打印一次 clip，不能证明后续转圈时播放哪个 clip。加低频诊断，不要每帧刷屏。

### 视觉/绑定问题

- 自研渲染层目前用 `RenderLayer.getEntityCutoutNoCull` 并在 CPU 上重算法线，不等于 Unity 原材质/着色器、透明、染色、受击 overlay、光照或后处理。
- hook 成功不表示手模/枪模在正确空间。要核对 SkinnedMeshRenderer Transform、bindpose 输出空间、PlayerSkin Rx(-90)、HandCamera 与 PlayerMesh、weapon root、WeaponAnchor/Dummy02 的关系。
- 持续用“静止 idle、不红、正确方向、完整枪手构图”作为第一阶段验收，再逐项接 draw/switch/fire/reload/bolt/inspect/melee 与音效。

## 6. 环境、构建与安装

- JDK：`C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot`
- Gradle：`D:\mcport-tools\gradle-8.12\bin\gradle.bat`
- Fabric 项目：`D:\逆向\SSJJ双塔惊魂\mc-port\fpmod`
- 构建命令：

```powershell
$env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot'
& 'D:\mcport-tools\gradle-8.12\bin\gradle.bat' -p 'D:\逆向\SSJJ双塔惊魂\mc-port\fpmod' clean remapJar --rerun-tasks
```

- `install.py` 会先删除目标目录旧的 `ssjj-fp-*.jar` 再复制新包。覆盖前先检查 Minecraft 已退出，手动备份当前 jar 并核对 SHA-256。
- `.minecraft\mods\1.21.1 Fabric` 指向真实 cluster mods；日志在 `clusters\1.21.1 Fabric\logs\latest.log`。
- 不要改相邻 SSJJ 单机/服务端/Unity 工程的未提交改动，也不要替用户启动 Minecraft。

## 7. Claude 接手顺序

1. 读取本文件和 `HANDOVER-GPT.md`，核对当前安装包 hash、最新日志、`FpConfig`/`FpRender`/`FpRenderHook` 和 exporter，先确认源码与日志完全对应。
2. 先查 packed overlay 误用，隔离验证红色；同时检查 idle clip 和运行时矩阵，定位旋转来源。
3. 回到原版 Transform 层级完整推导坐标。标明每次换轴、取反、旋转在哪一阶段发生；禁止同一变换既在 exporter 又在 Java 重复/漏应用。
4. 先让静止 idle 画面颜色正确、枪方向和手枪构图接近原版，再恢复各动作和音效；每个阶段都让用户启动后看图，未经用户画面确认不得说完成。
5. 每次安装先备份，记录新旧 hash。只做与当前移植目标相关的工作。

