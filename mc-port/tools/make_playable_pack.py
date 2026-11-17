# -*- coding: utf-8 -*-
"""把 P4 的 draft 枪包补成「进游戏能拿到枪」的最小可玩版本，并安装到 tacz 目录。

补齐:
  data/ssjj/index/guns/awm_legend_t.json        注册项（缺了 TaCZ 不会生成物品）
  data/ssjj/data/guns/awm_legend_t_data.json    枪械参数
  assets/ssjj/lang/{en_us,zh_cn}.json            名称（否则显示翻译键）
  assets/ssjj/display/guns/*_display.json       补全 state_machine / sounds / 默认动画
参数结构参照 tacz_default_gun 的 ai_awp_data.json（只借字段结构，数值自定义），
音效/枪口火焰仅用字符串引用默认包资源，**不复制任何模型/贴图/音频文件**。

用法:
  python make_playable_pack.py            只补齐工作区 mc-port/pack/ssjj/
  python make_playable_pack.py --install 同时安装到 <.minecraft>/tacz/ssjj/
"""
import argparse
import json
import os
import shutil

ROOT = r"D:\逆向\SSJJ双塔惊魂"
PACK = os.path.join(ROOT, "mc-port", "pack", "ssjj")
DEFAULT = (r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient\.minecraft"
           r"\tacz\tacz_default_gun")
TACZ = (r"C:\Users\Mahuilai\AppData\Roaming\Polyfrost\OneClient"
        r"\.minecraft\tacz")
DEST = os.path.join(TACZ, "ssjj")
GUN = "awm_legend_t"
NS = "ssjj"


def write_json(path, obj):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write("\n")


def read_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def read_jsonc(path):
    """TaCZ 默认包的配置是 JSONC（整行 // 注释），Gson 能读，标准 json 不能。"""
    lines = []
    with open(path, "r", encoding="utf-8") as f:
        for ln in f:
            if ln.lstrip().startswith("//"):
                continue
            lines.append(ln)
    return json.loads("\n".join(lines))


def build():
    # --- 1. 注册项 ---
    write_json(os.path.join(PACK, "data", NS, "index", "guns", GUN + ".json"), {
        "name": "%s.gun.%s.name" % (NS, GUN),
        "display": "%s:%s_display" % (NS, GUN),
        "data": "%s:%s_data" % (NS, GUN),
        "tooltip": "%s.gun.%s.desc" % (NS, GUN),
        "type": "sniper",
        "sort": 1,
    })

    # --- 2. 参数：借用默认狙击枪的字段结构，数值按 SSJJ AWM 自定义 ---
    tpl = read_jsonc(os.path.join(DEFAULT, "data", "tacz", "data", "guns", "ai_awp_data.json"))
    tpl["ammo"] = "tacz:338"
    tpl["ammo_amount"] = 5
    tpl["extended_mag_ammo_amount"] = [7, 9, 10]
    tpl["bolt"] = "manual_action"
    tpl["rpm"] = 40
    tpl["bullet"].update({"damage": 115, "speed": 600, "life": 1.2, "pierce": 5})
    tpl["bullet"]["extra_damage"].update({
        "armor_ignore": 0.8, "head_shot_multiplier": 2.5,
        "damage_adjust": [
            {"distance": 80, "damage": 115},
            {"distance": 160, "damage": 100},
            {"distance": "infinite", "damage": 85},
        ]})
    tpl["reload"]["feed"] = {"empty": 2.6, "tactical": 2.0}
    tpl["draw_time"] = 0.4
    tpl["aim_time"] = 0.3
    tpl["bolt_action_time"] = 1.0
    tpl["weight"] = 7.5
    tpl["fire_mode"] = ["semi"]
    write_json(os.path.join(PACK, "data", NS, "data", "guns", GUN + "_data.json"), tpl)

    # --- 3a. 物品栏/HUD 图标 ---
    # 用大厅端 2D 武器展示图（229x73、66% 透明的枪械侧面图），
    # 不是 512x512 的 UV 展开贴图（全不透明，当图标会显示成纹理碎片）。
    from PIL import Image
    icon_src = os.path.join(ROOT, "mc-port", "out", "textures", GUN + ".png")
    if not os.path.isfile(icon_src):
        icon_src = os.path.join(PACK, "assets", NS, "textures", "gun", "uv", GUN + ".png")
    if os.path.isfile(icon_src):
        src = Image.open(icon_src).convert("RGBA")
        canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        ratio = min(60 / src.width, 60 / src.height)
        scaled = src.resize((max(1, int(src.width * ratio)),
                             max(1, int(src.height * ratio))), Image.LANCZOS)
        canvas.paste(scaled, ((64 - scaled.width) // 2, (64 - scaled.height) // 2), scaled)
        for sub in ("slot", "hud"):
            d = os.path.join(PACK, "assets", NS, "textures", "gun", sub)
            os.makedirs(d, exist_ok=True)
            canvas.save(os.path.join(d, GUN + ".png"))
        print("icon source:", icon_src)

    # --- 3. 本地化 ---
    write_json(os.path.join(PACK, "assets", NS, "lang", "zh_cn.json"), {
        "%s.gun.%s.name" % (NS, GUN): "AWM 传奇（SSJJ 移植）",
        "%s.gun.%s.desc" % (NS, GUN): "由生死狙击 AssetBundle 转换的高还原三角网格枪械",
    })
    write_json(os.path.join(PACK, "assets", NS, "lang", "en_us.json"), {
        "%s.gun.%s.name" % (NS, GUN): "AWM Legend (SSJJ Port)",
        "%s.gun.%s.desc" % (NS, GUN): "High-fidelity poly_mesh gun converted from SSJJ AssetBundle",
    })

    # --- 4. display 补全 ---
    dpath = os.path.join(PACK, "assets", NS, "display", "guns", GUN + "_display.json")
    disp = read_json(dpath)
    disp.pop("_comment", None)
    # 保留自定义动画（gun.anm 转出来的 awm_legend_t），没设置才回退内置 rifle
    if not disp.get("animation"):
        disp.pop("animation", None)
    # TML 0.2.0 Fabric 分支 register() 实际注册的 key 是 "mesh"，
    # 但日志打印成 "Registered TacZ model type: meshy"（笔误）。
    # 写 "meshy" 会查表失败并回退成普通 BedrockGunModel，poly_mesh 永远不加载。
    disp["model_type"] = "mesh"
    # gun.anm 转出来的枪身动画（idle/shoot/reload/walk）
    disp["animation"] = "%s:%s" % (NS, GUN)
    disp["state_machine"] = "tacz:default_state_machine_v2"
    disp["use_default_animation"] = "rifle"
    disp["ads_preset"] = "tacz:renew"
    disp["iron_zoom"] = 1.5
    disp["zoom_model_fov"] = 35
    disp["slot"] = "%s:gun/slot/%s" % (NS, GUN)
    disp["hud"] = "%s:gun/hud/%s" % (NS, GUN)
    disp["muzzle_flash"] = {
        "type": "renew",
        "texture": "tacz:flash/common_muzzle_flash",
        "scale": 0.8,
        "initial_speed_scale": 1.7,
        "smoke_scale": 2,
        "smoke_particle_count": 20,
    }
    # 只做字符串引用，不复制默认包音频文件
    disp["sounds"] = {
        "draw": "tacz:ai_awp/awp_draw",
        "put_away": "tacz:ai_awp/awp_put_away",
        "shoot": "tacz:ai_awp/awp_shoot",
        "shoot_3p": "tacz:ai_awp/awp_shoot_3p",
        "reload_empty": "tacz:ai_awp/awp_reload_empty",
        "reload_tactical": "tacz:ai_awp/awp_reload_tactical",
        "bolt": "tacz:ai_awp/awp_bolt",
        "inspect": "tacz:ai_awp/awp_inspect",
        "inspect_empty": "tacz:ai_awp/awp_inspect_empty",
    }
    write_json(dpath, disp)

    # --- 5. 校验所有 JSON ---
    n = 0
    for root, _, files in os.walk(PACK):
        for f in files:
            if f.endswith(".json"):
                read_json(os.path.join(root, f))
                n += 1
    print("pack JSON files:", n, "all parseable")
    for root, _, files in os.walk(PACK):
        for f in files:
            p = os.path.join(root, f)
            print("  %8d  %s" % (os.path.getsize(p), os.path.relpath(p, PACK)))


def install():
    os.makedirs(TACZ, exist_ok=True)
    # 幂等覆盖，不做 rmtree（避免误删用户目录）
    shutil.copytree(PACK, DEST, dirs_exist_ok=True)
    print("installed ->", DEST)
    for root, _, files in os.walk(DEST):
        for f in files:
            print("  ", os.path.relpath(os.path.join(root, f), DEST))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--install", action="store_true")
    args = ap.parse_args()
    build()
    if args.install:
        install()
