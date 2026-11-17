# -*- coding: utf-8 -*-
"""提取武器皮肤预览图（大厅皮肤选择器用）。

源：资源全集/weaponskin/<skin>_<md5>（Unity AssetBundle）
取包内 "ui" 贴图——原版皮肤图标就是 ui_jy_skin_<skin>（128x32 的武器渲染条），
优先级：ui_jy_skin_* > ui_jy_* > 其它 ui*，同级别取面积最大的；backcolor / *_name 是
底图和武器名，不作为预览。

输出：lobby-launcher/data/previews/weapon_skins/<skin>.png
（900 张图不内嵌进 exe，启动器运行期从 data 目录读，缺图回落到武器默认图）

可重复运行：已存在的 png 默认跳过；--force 重提；--limit N 只处理前 N 个（调试）。
只读原始资源目录，不做任何修改。

用法：python extract_weapon_skin_previews.py [--force] [--limit N]
"""
import argparse
import os
import re
import sys

import UnityPy

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, "资源全集", "weaponskin")
OUT = os.path.join(ROOT, "lobby-launcher", "data", "previews", "weapon_skins")
NAME_RE = re.compile(r"^(.*)_([0-9a-f]{32})$")
BAD_CHARS = set('<>:"/\\|?*')


def bundle_skin_name(fname):
    match = NAME_RE.match(fname)
    return match.group(1) if match else None


def score_texture(name, width, height):
    """越大越优先；返回 None 表示不是预览图。"""
    low = name.lower()
    if not low.startswith("ui"):
        return None
    if "backcolor" in low:
        return None
    if low.endswith("_name") and "skin" not in low:
        # ui_jy_<weapon>_name 是武器中文名条，不是皮肤图
        return None
    if "ui_jy_skin_" in low:
        tier = 3
    elif low.startswith("ui_jy_"):
        tier = 2
    else:
        tier = 1
    return (tier, width * height)


def extract(bundle_path):
    """返回 (名称, PIL.Image)；包里没有 UI 贴图则 (None, None)。"""
    env = UnityPy.load(bundle_path)
    best = None
    best_key = None
    for obj in env.objects:
        if obj.type.name != "Texture2D":
            continue
        data = obj.read()
        key = score_texture(data.m_Name, data.m_Width, data.m_Height)
        if key is None:
            continue
        if best_key is None or key > best_key:
            best, best_key = data, key
    if best is None:
        return None, None
    return best.m_Name, best.image


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true", help="已存在也重新提取")
    parser.add_argument("--limit", type=int, default=0, help="只处理前 N 个（调试）")
    args = parser.parse_args()

    if not os.path.isdir(SRC):
        sys.exit("资源目录不存在：%s" % SRC)
    os.makedirs(OUT, exist_ok=True)

    files = sorted(os.listdir(SRC))
    if args.limit:
        files = files[: args.limit]

    done = skipped = no_ui = failed = 0
    no_ui_names = []
    for fname in files:
        path = os.path.join(SRC, fname)
        if not os.path.isfile(path):
            continue
        skin = bundle_skin_name(fname)
        if not skin or any(ch in BAD_CHARS for ch in skin):
            failed += 1
            continue
        target = os.path.join(OUT, skin + ".png")
        if os.path.exists(target) and not args.force:
            skipped += 1
            continue
        try:
            tex_name, image = extract(path)
        except Exception as exc:  # 坏包不能中断整批
            print("  [FAIL] %s: %s" % (skin, exc))
            failed += 1
            continue
        if image is None:
            no_ui += 1
            no_ui_names.append(skin)
            continue
        image.convert("RGBA").save(target)
        done += 1
        if done % 50 == 0:
            print("  ... %d 张" % done)

    total = len([n for n in os.listdir(OUT) if n.endswith(".png")])
    print("bundle 总数 %d" % len(files))
    print("本次提取 %d / 跳过已存在 %d / 无 UI 图 %d / 失败 %d" % (done, skipped, no_ui, failed))
    if no_ui_names:
        print("无 UI 图（启动器回落武器默认图）：%d 个，例：%s"
              % (len(no_ui_names), ", ".join(no_ui_names[:6])))
    print("输出目录 %s（现有 %d 张）" % (OUT, total))


if __name__ == "__main__":
    main()
