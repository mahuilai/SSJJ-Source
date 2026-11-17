"""扫描 FuckWooduan/SSJJ 的 export 目录，建立 FairyGUI 图集索引。

FairyGUI 的 skin 引用形如 "BagAssets.stuff_cell_bg_unequiped"，
实际文件在 export/BagAssets/sprites/DefineSprite_30_BagAssets.stuff_cell_bg_unequiped/1.png。

产出 data/sprite_index.json：
  {
    "root": ".../export",
    "items": {
      "BagAssets.stuff_cell_bg_unequiped": {"bundle":"BagAssets","sprite":"DefineSprite_30_...","frames":["1.png"],"w":..,"h":..},
      ...
    },
    "sets": {"BagAssets.btn_repair_all": ["...1","...2","...3","...4"]}   # 多帧归并
  }
"""
import os, re, json, sys
from PIL import Image

ROOT = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main\export"
OUT = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\data\sprite_index.json"

DIR_RE = re.compile(r"^DefineSprite_(\d+)_(.+)$")


def main():
    items = {}
    bundles = sorted(d for d in os.listdir(ROOT) if os.path.isdir(os.path.join(ROOT, d)))
    total_sprites = 0
    for bundle in bundles:
        sp_dir = os.path.join(ROOT, bundle, "sprites")
        if not os.path.isdir(sp_dir):
            continue
        for name in os.listdir(sp_dir):
            m = DIR_RE.match(name)
            if not m:
                continue
            sid, key = int(m.group(1)), m.group(2)  # key = "BagAssets.xxx"
            frames = sorted(f for f in os.listdir(os.path.join(sp_dir, name)) if f.endswith(".png"))
            if not frames:
                continue
            rec = {"bundle": bundle, "id": sid, "dir": name, "frames": frames}
            first = os.path.join(sp_dir, name, frames[0])
            try:
                with Image.open(first) as im:
                    rec["w"], rec["h"] = im.size
            except Exception:
                rec["w"], rec["h"] = 0, 0
            items[key] = rec
            total_sprites += 1

    # 多帧归并：xxx1..xxx4 视为同一 UIButton 的 4 个状态
    sets = {}
    for key in items:
        m = re.match(r"^(.*?)(\d)$", key)
        if m and m.group(1) in items:
            sets.setdefault(m.group(1), []).append(key)
    for base in sets:
        sets[base].sort()

    payload = {"root": ROOT, "bundles": len(bundles), "count": len(items), "items": items, "sets": sets}
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, ensure_ascii=False, indent=0)
    print(f"bundles={len(bundles)} sprites={total_sprites} sets={len(sets)}")
    print("out:", OUT, f"{os.path.getsize(OUT)/1048576:.2f} MB")
    # 抽样
    for k in ["BagAssets.stuff_cell_bg_unequiped", "BagAssets.bag_bg_layer1", "MainAssets.pvp_btn"]:
        print(" ", k, "->", items.get(k))


if __name__ == "__main__":
    main()
