# 工具链与 MCP 对接记录（2026-11-07）

## 结论
只接一个 MCP，接的是 **Blender 官方 Lab 实现**，不是第三方 `ahujasid/blender-mcp`。
用户本机早就装好了官方 MCP 的 Blender 侧 add-on，只是没注册到 WorkBuddy 的 `mcp.json`。

## 实现归属
| | 第三方（曾误装） | 官方（实际采用） |
|---|---|---|
| 项目 | `ahujasid/blender-mcp` / PyPI `mcp-for-blender` | Blender Lab `projects.blender.org/lab/blender_mcp` |
| Blender 侧 | 传统 `addon.py` | 扩展 `bl_ext.user_default.mcp`，GPL-3.0，要求 Blender >= 5.1 |
| Server | `uvx mcp-for-blender` | `uv --directory <repo>/mcp run blender-mcp` |
| 传输 | stdio -> addon socket | stdio -> addon socket `localhost:9876` |

官方 add-on（已装且已启用）：
`C:/Users/Mahuilai/AppData/Roaming/Blender Foundation\Blender\5.4\extensions\user_default\mcp\`
`mcp_to_blender_server.py:39-40` -> `DEFAULT_HOST="localhost"`, `DEFAULT_PORT=9876`。
`__init__.py` 的 `_AUTOSTART_DELAY=1.0`：注册 1 秒后自动起 socket server，打开 Blender GUI 即可。

Blender 便携版：`D:/blender/blender-5.4.0-alpha+main.3fe0f2ab2a29-windows.amd64-release/blender.exe`（5.4.0 Alpha）。
`addon_utils.modules()` 实测只返回 `bl_ext.user_default.mcp` -> 便携版 `scripts/addons` 不被扫描。

## 最终 MCP 配置
`C:/Users/Mahuilai/.workbuddy/mcp.json`（dnspy-mcp / ida-mcp 两条 `disabled:true` 保留）：

    "blender": {
      "command": "C://Users//Mahuilai//.local//bin//uv.exe",
      "args": ["--directory", "D://mcport-tools//blender_mcp//mcp", "run", "blender-mcp"],
      "env": { "PYTHONPATH": "", "PYTHONHOME": "", "VIRTUAL_ENV": "" }
    }

来源：https://projects.blender.org/lab/blender_mcp/wiki/Setup
仓库：`git clone --depth 1 https://projects.blender.org/lab/blender_mcp.git` -> `D:/mcport-tools/blender_mcp/`（4712 文件）。
`uv run` 首次装 41 包，`blender-mcp --help` 正常（默认 `--transport stdio`）。

## 踩过的坑
1. PYTHONPATH 污染：WorkBuddy 注入
   `D:/workbuddy/.../shim;D:/项目/File manger\Lib\site-packages`，
   导致 uv 隔离环境导入外部 httpx，报 `ModuleNotFoundError: No module named 'httpx._decoders'`。
   -> 配置里清空 PYTHONPATH/PYTHONHOME/VIRTUAL_ENV；命令行用 `env -u PYTHONPATH ...`。
2. Blender 5.4 用扩展系统，不扫 `scripts/addons`。第三方 addon 曾装到
   `D:/blender/.../5.4/scripts/addons/blender_mcp.py`（309487 B），无效；
   `rm` 被 safe-delete fail-closed 拦下，文件残留，可手动删，不影响运行。
3. `mcp.json` 的 `os.replace` 原子写第二次报 `PermissionError WinError 5`，改用直接 `open(P,'w')`（已留 `.bak-blender`）。
4. server 启动探针会发 telemetry 到 `*.supabase.co`；别把 Blender socket 暴露到非 localhost。

## 验证状态
- mcp.json 可解析、三条 server、原两条 disabled：OK
- `uv --directory ... run blender-mcp --help`：OK（41 包装好，CLI 正常）
- 官方 add-on 已启用：OK（`bpy.context.preferences.addons` 含 `bl_ext.user_default.mcp`）
- WorkBuddy 侧 MCP 激活：**未验证**，需在连接器管理页点「信任」
- Blender socket 9876 监听：**未验证**，需用户打开 Blender GUI 后探测
- 官方 server 与 add-on 实际握手：**未验证**，需上面两项就绪

## 待办（P0.5 D/E/F/G）
- D：Modrinth v2 下 `TACZ-Refabricated-1.21.1-0.5.0` 与 `tacz-mesh-loader-fabric-1.21.1-0.2.0`，sha512 校验，落到 `clusters\1.21.1 Fabric\mods\`
- E：新建 `envs\mcport` venv（`--system-site-packages`），装 numpy/trimesh/pygltflib/pydub/soundfile/imageio/scipy，跑 `decode_anm.py` 回归
- F：Blockbench 便携版到 `D:/mcport-tools/Blockbench/`
- G：JDK 21 会话级切换 + 1.21.1 冒烟，读 `latest.log` 确认两模组载入

## 不变
mcp.json 原有两条 disabled server；OneClient 的 1.8.9 / 26.1.2 / 26.2 集群；现有 140 个 jar；
`mc-port/stack.lock.json`、`tools/decode_anm.py`、`notes/anm_spec.md`、`material_binding.md`。

## P0.5 D/E/F/G 实测结果（2026-11-07 晚，已全部闭环）

| 项 | 结果 |
|---|---|
| Blender MCP 握手 | **OK**。协议 `{"type":"execute","code":...,"strict_json":true}\x00`，返回 `{"status":"ok","result":{"blender":"5.4.0 Alpha","scene":"Scene","objects":3}}`。进程 PID 23096，`127.0.0.1:9876 LISTENING` |
| 自启动脚本 | `mc-port/tools/start_blender.py`（幂等：端口在听就跳过，否则 DETACHED 拉起 Blender 并等 9876）。用户已授权以后自行打开 |
| Fabric Loader | **0.20.1**（`metadata/versions/1.21.1-0.20.1/...json` + `libraries/net/fabricmc/fabric-loader/0.20.1`），满足 TML `>=0.17.2` |
| jar 组合修正 | TML 0.2.0 的 `fabric.mod.json` 写死 `depends: {"tacz": ">=1.0.0-"}`，**0.5.0 / 0.7.1 不兼容**。最终装 `tacz-refabricated-1.0.0-neo1.2.0+mc1.21.1.jar`(69.27 MB) + `tacz-mesh-loader-fabric-1.21.1-0.2.0.jar`(135 KB) + `ForgeConfigAPIPort-v21.1.6-1.21.1-Fabric.jar`(633 KB)，sha512 全部校验通过；集群 140 -> 143 jar |
| 实机冒烟 | 20:15:50 启动的实例 `Loading 395 mods`，含 `forgeconfigapiport 21.1.6` / `tacz 1.0.0-neo1.2.0+mc1.21.1` / `taczmeshloader 0.2.0`；`[TacZMeshLoader] Initialized.` + `Registered TacZ model type: meshy`；枪包扫描已启动 |
| 冒烟脚本坑 | `cluster-output.log` 里 `--accessToken` 被启动器写成 `[censored]`，直接复用该命令 javaw 会 `rc=0` 立即退出。**要启动 MC 用启动器 GUI**，脚本只用于解析/取参 |
| venv | `envs/mcport`（Python 3.13.14，`--system-site-packages` 未继承 UnityPy，需显式装）；numpy 2.5.4 / trimesh 5.2.0 / scipy 1.18.1 / pygltflib 1.16.5 / soundfile 0.14.0 / Pillow 13 / UnityPy 1.25.4 / pydub + audioop-lts；`decode_anm.py` 双文件回归 OK |
| Blockbench | `D:\mcport-tools\Blockbench\Blockbench_5.2.2_portable.exe`（105,436,440 B），备用，主流程脚本直出 JSON |

## P1-P3 资产链路（已跑通）

- `tools/probe_bundle.py` -> `out/bundle_probe.json` + `notes/bundle_probe.md`：主包 558 对象 / `$2` 396 对象，20 Mesh / 11,225 顶点 / 24,054 索引 / 8,018 三角，130 贴图 / 55 Material / 11 TextAsset / 23 SkinnedMeshRenderer
- `tools/export_assets.py` -> `out/textures/*.png`(130，零错误) + `out/mesh/awm_legend_t.obj`(20 个 o 组 / 11,225 v / 8,018 f) + `out/asset_manifest.json`
- **顶点格式定论**：Unity 2019 typetree 无 `m_Streams`；`m_DataSize` 是顶点字节流；`m_IndexBuffer` 是 `list[int]` 逐字节。`stride[s]=align4(max(offset+dim*fmtSize))`，流段紧密排列，blob 尾部 <=16B 填充。fmt: 0=float4 / 1=half2 / 2=UNorm8×1 / 10=uint32×4
- 坐标系：导出翻转 X（Unity LH -> RH Y-up），面绕序同步反转

## P4 已跑通（2026-11-07 20:3x）

- schema 从 **TML 开源源码**坐实：`VellEagle/TacZMeshLoader`，已下载 5 个 .java 到 `mc-port/upstream/TacZMeshLoader/`。`PolyMeshModel.java` 读 `minecraft:geometry[0].bones[*].poly_mesh`；`PolyMesh.java` 渲染时 Y 取负 / UV 的 V 取负 / 坐标 ÷16 / `FORCE_FLAT_SHADING=true`。格式模板见 `notes/polymesh_spec.md`、`notes/tacz_pack_format.md`
- **材质绑定重大修正**：`m_TexEnvs` 的 PPtr **并非为空**，之前判断是探针取值方式错。`resolve_materials.py` 实跑：12/12 个 SkinnedMeshRenderer 的 PPtr 全部命中主包 Texture2D，且**全部指向 `awm_legend_t` 512²**。单材质走 TML VBO 快路径，不用猜名字
- `make_polymesh.py` 产物：`mc-port/pack/ssjj/`（meta / gunpack_info / geo / texture / display draft）+ `out/material_map.json`。**20 bones / 11,225 positions / 8,018 polys**（与 OBJ 完全一致、丢面 0），`selfcheck: PASS`
- 两个已修的坑：① OBJ 索引是 **1-based**，生成器 vbase 必须从 1 起（否则每组末尾 1–3 面越界，共丢 25 面）；② 130 张贴图里 `awm_legend_t` 有同名多个，229×73 是 UI 图，真主贴图是 `awm_legend_t_5206705448884915159.png`(512², 439 KB)
- 绕序：OBJ 的 a,c,b 在 polys 里还原成 a,b,c（TML 还要翻 Y）；平铺 UV 超 [0,1] 合法，只告警不判错

## 最小可玩枪包（2026-11-07 20:5x，已安装）

`tools/make_playable_pack.py --install` 把 P4 draft 补成可注册枪包并装到
`C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft\tacz\ssjj\`（9 文件）：

| 文件 | 作用 |
|---|---|
| `data/ssjj/index/guns/awm_legend_t.json` | **注册项**（缺了 TaCZ 不生成物品）：name/display/data/tooltip/type=sniper/sort |
| `data/ssjj/data/guns/awm_legend_t_data.json` | 参数：ammo=`tacz:338`、5 发、栓动、rpm 40、damage 115、pierce 5、爆头 2.5× |
| `assets/ssjj/lang/{en_us,zh_cn}.json` | 名称，否则显示翻译键 |
| `assets/ssjj/display/guns/*_display.json` | 补 `state_machine=tacz:default_state_machine_v2`、`use_default_animation=rifle`、muzzle_flash 与 sounds **字符串引用**默认包（不复制音频文件） |

- 默认包 `ai_awp_data.json` 是 **JSONC**（整行 `//` 注释），标准 `json.load` 会炸 → 脚本里用 `read_jsonc` 去注释
- 音效/枪口火焰只做跨包引用 `tacz:ai_awp/*`、`tacz:flash/*`，**未复制** TaCZ 资产
- 安装用 `copytree(dirs_exist_ok=True)` 幂等覆盖，不 rmtree

**实机扫描未验证**：OneClient 需要正版 token，`cluster-output.log` 里 `--accessToken` 是 `[censored]`，
外部直接拉 javaw 会 rc=0 立退。用户自行点启动器启动；启动后应查 `latest.log` 里是否出现
`ssjj` 枪包、`[MeshyLoader]` 是否加载 `ssjj:gun/awm_legend_t_geo`。
拿枪：创造模式 TaCZ 标签搜 "AWM"，或 `/give @s ssjj:awm_legend_t`；弹药 `tacz:338`。

## 实机首秀失败与修复（21:0x，待重载验证）

现象：物品/tooltip 正常，第一人称无模型，物品图标紫黑。
日志：枪包扫描成功、`meshy` 类型已注册、无 `loadPolyMesh failed`。
源码：`GunDisplayInstanceMixin` 只在 `gunModel instanceof TaczPolyMeshGunModel` 时加载 geo；
`checkTextureAndModel` 用 `@SerializedName("model_type")` 的 `getModelType()` 选模型类（键名没错）；
`PolyMeshModel.renderBonesConsumer:271` 用 `meshAncestorBones` 按**骨骼名**过滤，
而骨骼树来自 TaCZ `getShouldRender()` —— `cubes: []` 的 bone 很可能未进 `modelMap`。

修复：`make_polymesh.py` 给 20 个 bone 各加 0.5³ 占位 cube（TML 加载后 `cubes.clear()` 清掉）；
`make_playable_pack.py` 生成 64² slot/hud 图标并写入 display。重装 11 文件，
geo 20 bones / 20 cubes / 8,018 polys，selfcheck PASS。

**验证判据**：重启或 F3+T 后按 F3 看 `[TacZMeshLoader] Guns: N | Vertices: M`。
- Guns=1 且 Vertices>0 但仍看不见 → 坐标 / 贴图 / 绕序问题
- Guns=0 或 Vertices=0 → `model_type` 分支未生效，改走 `meshy:materials` 多材质路径

## 真正根因（21:18 二次诊断，源码级确认）

之前读的是 GitHub `main` 分支源码，**与 0.2.0 的 Fabric jar 不同步**（jar 里多出
`DisplayGunMeshGroupMixin` / `ExternalGunItemVboRendererMixin` / `MeshPresence`）。
改读 `1.21.1_fabric` 分支后拿到决定性证据：

```java
// TaczPolyMeshGunModel.register()  @ 1.21.1_fabric
GunModelTypeManager.registerModelType("mesh", TaczPolyMeshGunModel::new);  // 真实 key = "mesh"
MESH_LOG.info("[TacZMeshLoader] Registered TacZ model type: meshy");       // 日志却打印 meshy
```

`GunModelTypeManager.getModelInstanceConstructor()` 是 `Map.getOrDefault(key, default)`：
写 `"meshy"` 查不到 → 回退普通 `BedrockGunModel` → `GunDisplayInstanceMixin` 的
`instanceof TaczPolyMeshGunModel` 不成立 → **geo 的 poly_mesh 一次都没加载**。
上轮「cubes 空导致骨骼树缺失」是次要推断（占位 cube 保留，无害，但不是主因）。

修复：`make_playable_pack.py` 写 `disp["model_type"] = "mesh"`，已重装。
`notes/tacz_pack_format.md` / `polymesh_spec.md` / `make_polymesh.py` 的模板文本同步纠正。

### 图标
用户指出图标是 UV 展开贴图，应该用大厅 2D 预览图。已定位
`mc-port/out/textures/awm_legend_t.png`（229×73、66% 透明的枪械侧面展示图；
512² 那张 `awm_legend_t_5206705448884915159.png` 是 UV 展开、全不透明）。
`make_playable_pack.py` 改为按比例居中缩放进 64×64 透明画布，生成 slot/hud 图标（90% 透明）。
大厅主包 `lobbyweapon/awm_legend_t_2b114...` 的 24 张贴图里只有 1 张装饰卡面 + 特效，无枪械立绘。

### 验证
重启后第一人称应直接看到枪；日志会出现 `ssjj:geo_models/gun/awm_legend_t_geo.json` 相关的
`[MeshyLoader]` 加载行，F3 右侧 `[TacZMeshLoader] Guns: 1 | Vertices: ...`。
**本轮仍未实机验证**（正版 token 在用户侧）。

## v2 几何修正（21:33 实机反馈：枪横着 / 全黑 / 偏小）

实机第三人称已能看到枪（`model_type=mesh` 生效），但暴露四个结构问题，均已按数据核对：

1. **枪的长轴是 Unity X，不是 Z**：枪身 `p1_xm` x −80…+41、`p3_xm` −49…+66、`d_xm` −50…+67；
   枪口特效（glow/saoguang/liuti）全部集中在 **−X** → 枪口朝 −X。Bedrock 枪口朝 −Z，
   映射改为 `(x,y,z)_unity → ((z−cz)·S, −(y−cy)·S, (x−cx)·S)`
2. **手模 `PlayerSkin` 在 z 98…149**，与枪身（z −18…+13）不在同一空间（相机空间手网格），
   默认剔除；TaCZ 自带第一人称手模。剔除后 8,018−1,964 = **6,054 面**
3. **面法线朝内导致全黑**：按「面法线 · 面中心方向」自动判据，3 个组被翻转绕序
4. **骨架缺失**：补 `positioning / thirdperson_hand / ground / fixed / gun_pos / muzzle_flash / shell`，
   网格骨骼 `parent=gun_pos`，`muzzle_flash` pivot z=−10（模型单位）
5. 定标改用**枪身体包围盒**（147.5 cm）而非全模型：`S=0.13559`，目标 1.25 方块

**踩到的坑**：排除某组后仍必须按「全部原始组」累加 `vbase`，否则 OBJ 的 1-based 全局索引
整体错位（第一次跑面数从 8,018 掉到 2,598）。修正后 19 bones / 8,995 verts / 6,054 polys，
`selfcheck PASS`，z range −10…+10。

**仍未验证**：左右镜像（`x_b=z_u` 的符号）、握持位置（骨架 pivot 全 0，默认枪是
`positioning [0,0,-8]` / `thirdperson_hand [0,8.05,2.425]`，可能需要按手中位置微调）。

## v3 模型空间对齐（21:43 实机反馈：第一人称塞满屏幕 / 第三人称看不见）

现象：第一人称枪巨大糊满屏、第三人称只在手里露一点。**纹理完全正确**（红金黑都在），
说明 UV/贴图/材质都没问题，纯属模型空间没对齐 TaCZ 的枪坐标系。

实测默认狙击枪 `ai_awp_geo.json` 的空间规律：

| 项 | 值 |
|---|---|
| 枪口 `muzzle_flash` | `[0, 7.68651, -35.225]` |
| 枪身中心 y | ≈ 7.68651 |
| 枪托端 z | ≈ +20 |
| 骨架链 | `root[0,4,9] → AWP[0,4,9] → gun_and_righthand[0,5,8] → AWP_body[0,0,0] → gun_pos[0,0,0]` |

我们之前把模型中心放在原点（z −10…+10、y 居中），等于把枪塞进相机。
v3 改为对齐默认枪空间：

```
MUZZLE_Z=-35.225  MUZZLE_Y=7.68651  SPAN_Z=55.225  S=SPAN_Z/body_len=0.3744
z_b = (x_u - x_min)·S + MUZZLE_Z      # 枪口 -X → -Z，枪口固定 -35.225
y_b = -(y_u - cy)·S + MUZZLE_Y        # 枪身中心抬到 7.68651
x_b = (z_u - cz)·S
```

校验：`x −5.82…5.82 / y −4.67…16.71 / z −35.23…+20.00`，19 mesh bones / 6,054 polys，
骨架与默认枪一致，`selfcheck PASS`。

**仍未验证**：左右镜像（`x_b=z_u` 符号）与握持角度。若左右反了翻 `x_b`；若枪口上扬/下压，
调 `y_b` 的符号或加固定旋转。

## 下一步
P5：把 `.anm` 24 组逐帧（3,132 / 22,446 关键帧，四元数）转成 TaCZ `animation.json` 的欧拉时间轴关键帧，
替掉当前的 `use_default_animation=rifle`；P6 补 SSJJ 原声 ogg、HUD、准星；P7/P8 实机验收模型与玩法。
