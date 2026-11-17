# -*- coding: utf-8 -*-
"""[OFFLINE-BODYFIX] 修 RenderBotCloseups / matdiag 的选体逻辑：
旧逻辑取"第一个 bounds.size.y>50 的渲染器"——遇到幻影网格（如 ct_knight1_2 的
knight_role_huan，size.y=10361、bounds 中心离 bot 根 2600+ 单位）会选错，
导致特写拍空、诊断抓错材质。
新逻辑：候选 = enabled+active 且 50<size.y<3000，选 bounds 中心离 bot 根
(RootContainer.position) 最近的那个。
用法：python patch_bodyselect.py（幂等）
"""
import io, sys

PATH = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
src = io.open(PATH, encoding="utf-8", errors="surrogatepass").read()
n = 0

# ---------- RenderBotCloseups 内的选体 ----------
old1 = (
    "\t\t\t\t\tRenderer body = null;\n"
    "\t\t\t\t\tfor (int i = 0; i < rs.Length; i++)\n"
    "\t\t\t\t\t{\n"
    "\t\t\t\t\t\tif (rs[i] != null && rs[i].enabled && rs[i].gameObject.activeInHierarchy && rs[i].bounds.size.y > 50f)\n"
    "\t\t\t\t\t\t{\n"
    "\t\t\t\t\t\t\tbody = rs[i];\n"
    "\t\t\t\t\t\t\tbreak;\n"
    "\t\t\t\t\t\t}\n"
    "\t\t\t\t\t}\n"
)
new1 = (
    "\t\t\t\t\t// [OFFLINE-BODYFIX] 选体：bounds 中心离 bot 根最近 + 尺寸合理（50~3000），\n"
    "\t\t\t\t\t// 防幻影网格（size.y=10361、中心偏移 2600+）被误选导致特写拍空。\n"
    "\t\t\t\t\tRenderer body = null;\n"
    "\t\t\t\t\tfloat bestD = float.MaxValue;\n"
    "\t\t\t\t\tVector3 rootPos = tpx.RootContainer.transform.position;\n"
    "\t\t\t\t\tfor (int i = 0; i < rs.Length; i++)\n"
    "\t\t\t\t\t{\n"
    "\t\t\t\t\t\tif (rs[i] == null || !rs[i].enabled || !rs[i].gameObject.activeInHierarchy) continue;\n"
    "\t\t\t\t\t\tfloat sy = rs[i].bounds.size.y;\n"
    "\t\t\t\t\t\tif (sy <= 50f || sy >= 3000f) continue;\n"
    "\t\t\t\t\t\tfloat d = (rs[i].bounds.center - rootPos).sqrMagnitude;\n"
    "\t\t\t\t\t\tif (d < bestD) { bestD = d; body = rs[i]; }\n"
    "\t\t\t\t\t}\n"
)
if old1 in src:
    src = src.replace(old1, new1, 1)
    n += 1
    print("patched: RenderBotCloseups body select")
else:
    print("WARN: RenderBotCloseups body select pattern not found")

# ---------- matdiag 块内的选体 ----------
old2 = (
    "\t\t\t\t\t\tRenderer bodyR = null;\n"
    "\t\t\t\t\t\tfor (int rri = 0; rri < brs.Length; rri++)\n"
    "\t\t\t\t\t\t{\n"
    "\t\t\t\t\t\t\tif (brs[rri] != null && brs[rri].enabled && brs[rri].gameObject.activeInHierarchy\n"
    "\t\t\t\t\t\t\t\t&& brs[rri].bounds.size.y > 50f)\n"
    "\t\t\t\t\t\t\t{\n"
    "\t\t\t\t\t\t\t\tbodyR = brs[rri];\n"
    "\t\t\t\t\t\t\t\tbreak;\n"
    "\t\t\t\t\t\t\t}\n"
    "\t\t\t\t\t\t}\n"
)
new2 = (
    "\t\t\t\t\t\t// [OFFLINE-BODYFIX] 同 RenderBotCloseups：防幻影网格误选\n"
    "\t\t\t\t\t\tRenderer bodyR = null;\n"
    "\t\t\t\t\t\tfloat bestDR = float.MaxValue;\n"
    "\t\t\t\t\t\tfor (int rri = 0; rri < brs.Length; rri++)\n"
    "\t\t\t\t\t\t{\n"
    "\t\t\t\t\t\t\tif (brs[rri] == null || !brs[rri].enabled || !brs[rri].gameObject.activeInHierarchy) continue;\n"
    "\t\t\t\t\t\t\tfloat sy = brs[rri].bounds.size.y;\n"
    "\t\t\t\t\t\t\tif (sy <= 50f || sy >= 3000f) continue;\n"
    "\t\t\t\t\t\t\tfloat d = (brs[rri].bounds.center - rc.position).sqrMagnitude;\n"
    "\t\t\t\t\t\t\tif (d < bestDR) { bestDR = d; bodyR = brs[rri]; }\n"
    "\t\t\t\t\t\t}\n"
)
if old2 in src:
    src = src.replace(old2, new2, 1)
    n += 1
    print("patched: matdiag body select")
else:
    print("WARN: matdiag body select pattern not found")

io.open(PATH, "w", encoding="utf-8", errors="surrogatepass").write(src)
print("done, %d patches" % n)
