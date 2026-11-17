# TML poly_mesh 规格与转换约定（P4）

## schema（源码实证）
文件: `assets/ssjj/geo_models/gun/awm_legend_t_geo.json`

顶层 `format_version: "1.12.0"`，`minecraft:geometry[0].description` 必须有
`identifier / texture_width / texture_height`；`bones[*]` 需 `name / pivot`，
`cubes: []` 可空，关键是 `poly_mesh`：

| 字段 | 类型 | 说明 |
|---|---|---|
| `normalized_uvs` | bool | true 时 UV 直接当 0–1，不再除 texWidth/texHeight |
| `positions` | [[x,y,z]] | 模型单位，渲染时 ÷16 |
| `normals` | [[x,y,z]] | TML `FORCE_FLAT_SHADING=true` 实际用面法线，但数组仍需合法 |
| `uvs` | [[u,v]] | v 渲染时取 `1-v` |
| `polys` | [[[p,n,u]×3..4]] | 三角或四边形；三角会补一个退化顶点成 quad |

display 加 `"model_type": "mesh"`（TML 0.2.0 Fabric 实际注册 key 是 `mesh`，日志误报 `meshy`），`model` 指向 `<ns>:gun/<name>_geo`，
`texture` 指向 `<ns>:gun/uv/<name>`。

## 本包转换约定
- OBJ 由 `export_assets.py` 生成（已翻 X、f 写成 a,c,b）
- 坐标: `positions = [x*S, -y*S, z*S]`，`S = target_blocks*16 / bbox_max_dim`
  渲染时 `x=(px)/16, y=-(-y*S)/16=y*S/16, z=z*S/16` → 与 OBJ 等比还原
- UV: `normalized_uvs=true`，uvs 直接用 OBJ vt；TML 的 `FLIP_UV_V` 补上 Unity→PNG 方向
- 绕序: 开启（OBJ 的 a,c,b 还原成 a,b,c），因 TML 还要翻 Y
- 单材质: 12/12 PPtr 精确解析，全部指向 `awm_legend_t` 512×512 → 不写
  `meshy:materials`，走 TML 的 VBO 快路径

## 实测统计
{"bones": 20, "positions": 11225, "normals": 11225, "uvs": 11225, "polys": 8018, "triangles": 8018}

## 主贴图
`awm_legend_t_5206705448884915159.png`（512x512）→ `assets/ssjj/textures/gun/uv/awm_legend_t.png`。
同名 UI 小图（229x73）已被排除。

## 自检
PASS
平铺 UV 告警（合法，不判错）: liuti_3, liuti01_4
