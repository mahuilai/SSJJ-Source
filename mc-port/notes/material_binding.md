# 材质与贴图绑定规则（P0 盘点）

## 为什么需要人工重建

`awm_legend_t` 的资源被拆在两个包里，且**引用是断的**：

| | 主包 `awm_legend_t_<md5>` | `$2` 包 `awm_legend_t$2_<md5>` |
|---|---|---|
| Texture2D | 130 | **0** |
| Mesh | **0** | 20 |
| Material | 0 | 55 |
| SkinnedMeshRenderer | 11 | 12 |
| TextAsset | 11 | 0 |

UnityPy 实测：`$2` 的 55 个 Material 扫描 `m_SavedProperties.m_TexEnvs` **贴图引用数 = 0**，跨包 PPtr 为空，包 `externals=[]`。也就是说贴图不是靠 Unity 序列化引用挂上去的，而是**运行时代码按名字绑定**。所以自动导出器拿不到材质→贴图映射，必须靠包内配置 + 名字规则重建。

## 主包里的 11 个 TextAsset（已 dump 内容）

| 名字 | 大小 | 格式 | 用途 |
|---|---|---|---|
| `gun.anm` | 103,554 | 二进制 | 枪体逐帧动画（见 `anm_spec.md`） |
| `hand_man.anm` | 741,114 | 二进制 | 第一人称手模逐帧动画 |
| `hand.DAE.action` | 2,477 | XML | 动作时间轴：name / start / end / loop / eventName |
| `camera_man` | 524 | XML | 相机与模型矩阵：`model3D`, `Camera01`–`Camera03`（含 cm 平移），第一人称持枪位姿定标用 |
| `soundconfig` | 258 | XML | **音效路径**：`sound/weapon/awm_legend_ct_fire.mp3`、`awm_legend_ct_skill.mp3`，eventId 10047/10048 |
| `uitextureconfig` | 4,082 | XML | UI 图集：`awm_legend_t`、`awm_legend_t-2` 等 SubTexture + md5，物品栏图标来源 |
| `weaponconfig` | 329 | XML | 击杀图标名（defaultkill / headshotkill / knifekill …） |
| `effectConfig` | 264 | XML | 特效粒子 URL（`awm_legend_11470_biaoji` 等 `.uf3d`） |
| `weaponeffectconfig` | 742 | XML | 按 `visiblestate` 分组的枪身粒子（`.uf3d`） |
| `particleEffectConfig` | 202 | XML | 粒子效果配置 |
| `UserNewParticle` | 0 | 空 | 占位 |

**P6 音效已定位**：`soundconfig` 明确指向 `sound/weapon/awm_legend_ct_fire.mp3` 与 `..._skill.mp3`。下一步去 `资源全集\sound\weapon\` 找对应包；TaCZ 只吃 ogg，需转码。主包本身**没有 AudioClip**。

## 贴图清单要点

- 130 张：`fmt=25` × 125、`fmt=4` × 5，`m_MipCount=1`（无 mip）。`fmt=10`(DXT1) 为 0，与角色包不同。
- 主色图 `awm_legend_t` 512×512、`awm_legend_t_cross` 960×540（准星/镜内），其余多为 128/256 的 `ui_jy_*` / `*kill*` / `glow*` / `progressFx*` / `M4_daoren1` / `M4A1_danjia00000` 等 UI 与特效小图。
- UnityPy `obj.read().image` 对 `fmt=25` 与 `fmt=4` 都能解出 RGBA PIL Image，`Game-SSJJ/tools/extract_weapon_skin_previews.py` 已跑通 `.convert("RGBA").save()` 链路，可直接复用。

## 重建策略

1. P1 的 `probe_bundle.py` 先 dump：**55 个 Material 名字 + shader 名**、20 个 Mesh 名字与 submesh 划分、11/12 个 SkinnedMeshRenderer 的 `m_Materials` 顺序。
2. 按名字启发式配对：Material 名 / Mesh 名 / 贴图名三者取公共词干。主色图 `awm_legend_t` → 枪身主体；`awm_legend_t_cross` → 准星/镜片；`*glow*` / `saoguang` / `dianqiu` → 发光面片，单独标记或剔除（TaCZ 无对应 shader）。
3. 生成 `material_map.json`，逐张目视核定后才喂给 `make_polymesh.py`。
4. 发光与粒子特效（`.uf3d`）不进第一版，先保证枪身与贴图正确。

## 尺度与位姿

`camera_man` 的 `model3D` 矩阵平移量约 `153.8`（cm 级），源模型是厘米单位；Minecraft 手持物品以方块/16 为单位。导出 OBJ 后需按此矩阵定标并做 Y-up 转换，`.anm` 的位移同样要按同一比例缩放，否则枪与手会脱节。

## 待办（交给 P1）

- dump Material / shader 全名与 SkinnedMeshRenderer 材质槽顺序
- 扫 `资源全集\sound\weapon\` 确认 `awm_legend_ct_fire` / `_skill` 是否存在
- 读 `uitextureconfig` 全文，取出物品栏图标对应的 SubTexture 与 md5
