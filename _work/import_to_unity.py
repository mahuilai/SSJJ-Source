# -*- coding: utf-8 -*-
"""把战斗端代码 + 托管 DLL + 游戏真实 TagManager 导入当前打开的 Unity 空工程。"""
import os
import shutil
import time

ROOT = r"D:\逆向\SSJJ双塔惊魂"
SRC = os.path.join(ROOT, r"Game-SSJJ-Source\Assets\Decompiled")
PLUG = os.path.join(ROOT, r"Game-SSJJ-Source\Assets\Plugins\GameManaged")
PROJ = os.path.join(ROOT, r"Game-SSJJ\New Unity Project")
DST = os.path.join(PROJ, "Assets")

assert os.path.isdir(PROJ), "project not found: " + PROJ

def copy_tree(src, dst):
    n = 0
    for root, _, files in os.walk(src):
        rel = os.path.relpath(root, src)
        out = os.path.join(dst, rel) if rel != "." else dst
        os.makedirs(out, exist_ok=True)
        for f in files:
            if f.endswith(".meta"):
                continue
            shutil.copy2(os.path.join(root, f), os.path.join(out, f))
            n += 1
    return n


t0 = time.time()
n_cs = copy_tree(SRC, os.path.join(DST, "Decompiled"))
n_dll = copy_tree(PLUG, os.path.join(DST, "Plugins", "GameManaged"))

LAYERS = ['Default', 'TransparentFX', 'Ignore Raycast', '', 'Water', 'UI', '', '',
          'FPSArm', 'FirstHandEffect', 'SceneMap', 'UIModel3D', '', '',
          'FPSArmWeapon', 'spine'] + [''] * 15 + ['UIParticle']
TAGS = ['Scene', 'TerrainLODGroup', 'SceneMap', 'HandCamera', 'ShootSmoke',
        'SceneObjects', 'Buildings']
lines = ["%YAML 1.1", "%TAG !u! tag:unity3d.com,2011:", "--- !u!78 &1", "TagManager:",
         "  serializedVersion: 2", "  tags:"]
lines += ["  - " + t for t in TAGS]
lines.append("  layers:")
lines += [("  - " + x if x else "  - ") for x in LAYERS]
lines += ["  m_SortingLayers:", "  - name: Default", "    uniqueID: 0", "    locked: 0", ""]

tm = os.path.join(PROJ, "ProjectSettings", "TagManager.asset")
if os.path.isfile(tm):
    shutil.copy2(tm, tm + ".bak-" + time.strftime("%H%M%S"))
open(tm, "w", encoding="utf-8", newline="\n").write("\n".join(lines))

print("project:", PROJ)
print("cs:", n_cs, "dll:", n_dll, "sec:", round(time.time() - t0, 1))
print("TagManager written, backup:", os.path.basename(tm) + ".bak-*")
