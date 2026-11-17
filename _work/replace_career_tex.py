# -*- coding: utf-8 -*-
"""把角色 sanjiaozhouwoman 的贴图换成指定图片，并装配进客户端。

做法：
1) 改 player/sanjiaozhouwoman 包里的 Texture2D（512x512）
2) 新内容 -> 新 md5 -> 文件名按 <name>_<md5>
3) 两个包（主包 + $2 网格包）复制到 AssetBundles/Windows
4) 在 AssetBundles 清单里补/改条目（含 $2 依赖），原清单先备份
5) launch_config.json 的职业/手模切到 sanjiaozhouwoman
"""
import hashlib
import io
import os
import re
import shutil
import sys

import UnityPy
from PIL import Image

ROOT = r"D:\逆向\SSJJ双塔惊魂"
POOL = os.path.join(ROOT, "资源全集", "player")
BUNDLE_DIR = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows"
MANIFEST = os.path.join(BUNDLE_DIR, "AssetBundles")
CFG = r"D:\SSJJ-4399\battle\3_64\launch_config.json"
IMG = r"C:\Users\Mahuilai\Downloads\img_y3cKzopt9hHx_1793639057_0.jpeg"

MAIN = "sanjiaozhouwoman_757c4a3c3e460203bc592c5101efdadd"
SUB = "sanjiaozhouwoman$2_e9245a58bcfc380f9a49d83fbb76e7c7"

# ---------- 1. 换贴图 ----------
src = os.path.join(POOL, MAIN)
env = UnityPy.load(src)
tex = None
for o in env.objects:
    if o.type.name == "Texture2D":
        d = o.read()
        if d.m_Name == "sanjiaozhouwoman":
            tex = d
            print("texture found:", d.m_Name, d.m_Width, d.m_Height)
            break
if tex is None:
    print("TEXTURE NOT FOUND"); sys.exit(1)

img = Image.open(IMG).convert("RGBA").resize((tex.m_Width, tex.m_Height), Image.LANCZOS)
try:
    tex.image = img
except Exception:
    tex.set_image(img)
tex.save()

tmp_out = os.path.join(ROOT, "_work", "sanjiaozhouwoman_custom.bundle")
with open(tmp_out, "wb") as f:
    f.write(env.file.save(packer="lz4"))
print("rebuilt bundle:", os.path.getsize(tmp_out))

md5 = hashlib.md5(open(tmp_out, "rb").read()).hexdigest()
dst_main = os.path.join(BUNDLE_DIR, "sanjiaozhouwoman_" + md5)
shutil.copy2(tmp_out, dst_main)
print("deployed:", os.path.basename(dst_main))

# $2 包原样装配
sub_src = os.path.join(POOL, SUB)
sub_md5 = hashlib.md5(open(sub_src, "rb").read()).hexdigest()
sub_name = "sanjiaozhouwoman$2_" + sub_md5
shutil.copy2(sub_src, os.path.join(BUNDLE_DIR, sub_name))
print("deployed:", sub_name)

# ---------- 4. 清单 ----------
shutil.copy2(MANIFEST, MANIFEST + ".bak-texreplace")
xml = io.open(MANIFEST, encoding="utf-8").read()
xml = re.sub(r'<AssetBundle name="player/sanjiaozhouwoman"[^>]*/>', "", xml)
xml = re.sub(r'<AssetBundle name="player/sanjiaozhouwoman\$2"[^>]*/>', "", xml)
entry_sub = '<AssetBundle name="player/sanjiaozhouwoman$2" md5="%s" crc="0" />' % sub_md5
entry_main = ('<AssetBundle name="player/sanjiaozhouwoman" md5="%s" crc="0">'
              '<Dependency name="player/sanjiaozhouwoman$2" /></AssetBundle>') % md5
xml = xml.replace("</AssetBundleManifest>", entry_sub + entry_main + "</AssetBundleManifest>") \
    if "</AssetBundleManifest>" in xml else xml.replace("</AssetBundles>", entry_sub + entry_main + "</AssetBundles>")
io.open(MANIFEST, "w", encoding="utf-8").write(xml)

# ---------- 5. 配置 ----------
import json
cfg = json.load(io.open(CFG, encoding="utf-8"))
cfg["career"] = "sanjiaozhouwoman"
cfg["hand"] = "woman"
for bag in cfg.get("bags", []):
    pass
json.dump(cfg, io.open(CFG, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("config career=sanjiaozhouwoman hand=woman")
