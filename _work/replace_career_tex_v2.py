# -*- coding: utf-8 -*-
"""角色贴图替换（带完整 mip 链）v2

相比 v1 的改动：
  - set_image 显式传 mipmap_count，重建 512->4 的 8 级 mip 链（原来只有 1 级）
  - 清单用 ElementTree 改，不再正则拼接
  - 顺带把旧的自定义包清掉
"""
import hashlib
import os
import shutil
import sys
import xml.etree.ElementTree as ET

import UnityPy
from PIL import Image

ROOT = r"D:\逆向\SSJJ双塔惊魂"
POOL = os.path.join(ROOT, "资源全集", "player")
BUNDLE_DIR = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows"
# 包按前缀分目录：player/weapon/sound/... 放错地方运行时会 "Could not find file"
PLAYER_DIR = os.path.join(BUNDLE_DIR, "player")
MANIFEST = os.path.join(BUNDLE_DIR, "AssetBundles")
IMG = r"C:\Users\Mahuilai\Documents\Tencent Files\2300375396\nt_qq\nt_data\Pic\2026-11\Thumb\0a8660318366a3d673f3aefade79bc6f_720.jpg"

MAIN_NAME = "player/sanjiaozhouwoman"
SUB_NAME = "player/sanjiaozhouwoman$2"
SRC_MAIN = os.path.join(POOL, "sanjiaozhouwoman_757c4a3c3e460203bc592c5101efdadd")

DXT5 = 10

# ---------- 1. 改贴图 ----------
env = UnityPy.load(SRC_MAIN)
tex = None
for o in env.objects:
    if o.type.name == "Texture2D":
        d = o.read()
        if d.m_Name == "sanjiaozhouwoman":
            tex = d
            print("texture: %s %dx%d fmt=%s mip(before)=%s"
                  % (d.m_Name, d.m_Width, d.m_Height, d.m_TextureFormat, d.m_MipCount))
            break
if tex is None:
    print("TEXTURE NOT FOUND")
    sys.exit(1)

img = Image.open(IMG).convert("RGBA")
print("source image: %dx%d" % img.size)
img = img.resize((tex.m_Width, tex.m_Height), Image.LANCZOS)

tex.set_image(img, target_format=DXT5, mipmap_count=10)
print("mip(after)=%s imageData=%d completeSize=%d fmt=%s"
      % (tex.m_MipCount, len(tex.image_data), tex.m_CompleteImageSize, tex.m_TextureFormat))
tex.save()

tmp_out = os.path.join(ROOT, "_work", "sanjiaozhouwoman_custom.bundle")
with open(tmp_out, "wb") as f:
    f.write(env.file.save(packer="lz4"))
print("rebuilt bundle:", os.path.getsize(tmp_out), "bytes")

md5 = hashlib.md5(open(tmp_out, "rb").read()).hexdigest()
dst_main = os.path.join(PLAYER_DIR, "sanjiaozhouwoman_" + md5)
shutil.copy2(tmp_out, dst_main)
print("deployed:", os.path.relpath(dst_main, BUNDLE_DIR))

# $2 网格包也要在 player/ 下，缺了模型同样渲染不出来
SRC_SUB = os.path.join(POOL, "sanjiaozhouwoman$2_e9245a58bcfc380f9a49d83fbb76e7c7")
sub_md5_actual = hashlib.md5(open(SRC_SUB, "rb").read()).hexdigest()
dst_sub = os.path.join(PLAYER_DIR, "sanjiaozhouwoman$2_" + sub_md5_actual)
if not os.path.isfile(dst_sub):
    shutil.copy2(SRC_SUB, dst_sub)
print("deployed:", os.path.relpath(dst_sub, BUNDLE_DIR), "md5=" + sub_md5_actual)

# ---------- 2. 校验读回 ----------
chk = UnityPy.load(dst_main)
for o in chk.objects:
    if o.type.name == "Texture2D":
        d = o.read()
        print("verify: %dx%d fmt=%s mip=%s bytes=%d"
              % (d.m_Width, d.m_Height, d.m_TextureFormat, d.m_MipCount, d.m_CompleteImageSize))
        break

# ---------- 3. 清单 ----------
shutil.copy2(MANIFEST, MANIFEST + ".bak-texv2")
tree = ET.parse(MANIFEST)
root = tree.getroot()

sub_el = None
for node in list(root.findall("AssetBundle")):
    n = (node.get("name") or "")
    if n.lower() == SUB_NAME.lower():
        sub_el = node
    if n.lower() == MAIN_NAME.lower():
        root.remove(node)

sub_md5 = sub_el.get("md5") if sub_el is not None else None
print("sub entry md5:", sub_md5)

main_el = ET.SubElement(root, "AssetBundle", {"name": MAIN_NAME, "md5": md5, "crc": "0"})
if sub_md5:
    ET.SubElement(main_el, "Dependency", {"name": SUB_NAME})

if hasattr(ET, "indent"):
    ET.indent(tree, space="  ")
tmp = MANIFEST + ".tmp"
tree.write(tmp, encoding="utf-8", xml_declaration=True)
ET.parse(tmp)
os.replace(tmp, MANIFEST)
print("manifest updated: %s -> %s" % (MAIN_NAME, md5))

# ---------- 4. 清理旧自定义包与放错位置的副本 ----------
keep = {
    "sanjiaozhouwoman_" + md5,
    "sanjiaozhouwoman_757c4a3c3e460203bc592c5101efdadd",
}
for f in os.listdir(PLAYER_DIR):
    if f.startswith("sanjiaozhouwoman_") and f not in keep:
        os.remove(os.path.join(PLAYER_DIR, f))
        print("removed stale:", "player/" + f)

# 之前误放在 Windows 根目录的副本会让运行时找不到（它只认 player/ 子目录）
for f in os.listdir(BUNDLE_DIR):
    if f.startswith("sanjiaozhouwoman"):
        os.remove(os.path.join(BUNDLE_DIR, f))
        print("removed misplaced:", f)

print("DONE md5=" + md5)
