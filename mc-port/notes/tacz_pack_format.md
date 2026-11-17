# TaCZ 枪包格式模板（P5/P6 依据）

来源：本机已安装的 `tacz_default_gun`（只看结构，**未复制任何资产**）。
路径：`C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft\tacz\tacz_default_gun\`

## 目录约定（重要：不是 `models/`，是 `geo_models/`）

```
<pack>/
  gunpack.meta.json                       {"namespace":"tacz","dependencies":{"minecraft":"[1.20.1],[1.21.1]"},
                                          "overlays":{"entries":[{"directory":"compat_1_21_1","minecraft":"[1.21.1]"}]}}
  assets/<ns>/
    gunpack_info.json                     version/name/desc/license/authors/date/url/logo
    geo_models/gun/<gun>_geo.json         Bedrock geometry（TML 读 poly_mesh 的地方）
    textures/gun/uv/<gun>.png             主贴图
    display/guns/<gun>_display.json       显示配置
    animations/<gun>.animation.json       动作（display 的 "animation": "<ns>:<gun>"）
    ads_presets/ hud/ slot/ ...           可选
  data/<ns>/
    index/guns/<gun>.json                 注册项
    data/guns/<gun>_data.json             枪械参数
    recipes/gun/<gun>.json                合成
    tacz_tags/ scripts/ ...               可选
  compat_1_21_1/data/...                  1.21.1 overlay（可选）
```

## display（P4 已生成 draft）

```json
{
  "model_type": "mesh",
  "model": "ssjj:gun/awm_legend_t_geo",
  "texture": "ssjj:gun/uv/awm_legend_t",
  "animation": "ssjj:awm_legend_t",
  "use_default_animation": "rifle",
  "third_person_animation": "default",
  "state_machine": "tacz:default_state_machine_v2",
  "ads_preset": "tacz:renew",
  "transform": {"scale": {"thirdperson":[0.6,0.6,0.6], "ground":[0.6,0.6,0.6], "fixed":[1.2,1.2,1.2]}},
  "model_fov": 60, "zoom_model_fov": 45, "iron_zoom": 1.2,
  "muzzle_flash": {...}, "shell": {...}, "sounds": {...}
}
```

`model_type: "mesh"` 是 TML 的开关。**注意**：TML 0.2.0 Fabric 分支
`TaczPolyMeshGunModel.register()` 里注册的是 `registerModelType("mesh", ...)`，
但日志打印成 `Registered TacZ model type: meshy`（笔误）。写 `"meshy"` 会
`getOrDefault` 回退成普通 `BedrockGunModel`，poly_mesh 永远加载不了。
`model`/`texture` 省略扩展名与 `geo_models`/`textures` 前缀。

## animation.json（P5 目标格式）

```json
{
  "format_version": "1.8.0",
  "animations": {
    "static_idle": {
      "loop": true,
      "animation_length": 0.4,
      "bones": {
        "righthand": { "rotation": [94.5, 4.9, -179.6],
                       "position": [-6.7, -12.4, 7.4],
                       "scale": [1, 1.5, 1] }
      }
    },
    "reload": {
      "animation_length": 0.9,
      "bones": {
        "bolt": {
          "rotation": { "0.0": [0,0,0], "0.2": [12,0,0], "0.45": [0,0,0] },
          "position": { "0.0": [0,0,0], "0.45": [0,0,-4] }
        }
      }
    }
  }
}
```

- 两种写法并存：**静态姿态**（`rotation` 直接给数组）与**时间轴关键帧**（`rotation` 给 `{"0.0":..., "0.2":...}`）
- 旋转单位是**度**、三位欧拉；位置是模型单位（÷16 前），scale 可给标量或三元组
- `.anm` 解码结果（四元数 + 位置、8 float/帧）需转成欧拉角并按时间戳写入

## index/guns/<gun>.json

```json
{ "name": "ssjj.gun.awm_legend_t.name",
  "display": "ssjj:awm_legend_t_display",
  "data": "ssjj:awm_legend_t_data",
  "tooltip": "ssjj.gun.awm_legend_t.desc",
  "type": "sniper", "sort": 1 }
```

## data/guns/<gun>_data.json（关键字段）

`allow_ammo_unload / ammo / rpm / ammo_amount / extended_mag_ammo_amount / bullet{life,damage,speed,gravity,extra_damage{head_shot_multiplier,damage_adjust[]},pierce} / ...`

## P4 已完成 / 后续待办

- 已生成：`mc-port/pack/ssjj/` 下 5 个文件（meta / gunpack_info / geo / texture / display draft）
- 未生成：animation.json、`data/ssjj/index/guns/*`、`data/ssjj/data/guns/*`、sounds(ogg)、hud、lang
- 未验证：geo.json 能否被 TaCZ 的 `BedrockModelPOJO` 接受（`cubes: []` + 额外 `poly_mesh` 字段）；需实机加载该枪包才能确认
- 授权：只借用格式与字段定义，`tacz_default_gun` 的任何模型/贴图/音效都未复制
