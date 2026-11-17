# -*- coding: utf-8 -*-
"""[OFFLINE-SCREENDIAG] 最后一块拼图：bot 为什么在 Eye 画面里看不见。
在 Camera.onPreRender 采样里追加三项硬指标：
1. layer=：RootContainer.layer + 是否在 Eye.cullingMask 内（maskIn=T/F）
   —— 若 maskIn=False，Eye 根本不渲染它（isVisible=True 只说明"某个相机"能看到）。
2. scr=：Eye.WorldToScreenPoint(bot 头顶) 归一化屏幕坐标 + 是否在视野内（onScreen）。
3. px=：按 FOV 估算的像素高度（屏幕 1080p 下），<30px 基本等于"看不见"。
用法：python patch_screendiag.py（幂等）
"""
import io

PATH = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
src = io.open(PATH, encoding="utf-8", errors="surrogatepass").read()

old = (
    "\t\t\t\tfloat d2 = (rc2.transform.position - c.transform.position).magnitude;\n"
    "\t\t\t\ts += \" #\" + bp2.entityId.Value + \"(act=\" + rc2.activeInHierarchy\n"
    "\t\t\t\t\t+ \" d=\" + d2.ToString(\"F0\")\n"
    "\t\t\t\t\t+ \" far=\" + c.farClipPlane.ToString(\"F0\")\n"
    "\t\t\t\t\t+ \" inFar=\" + (d2 <= c.farClipPlane)\n"
    "\t\t\t\t\t+ \" body=\" + ((body2 == null) ? \"none\" : (body2.enabled + \"/\" + body2.isVisible))\n"
    "\t\t\t\t\t+ \")\";\n"
)
new = (
    "\t\t\t\tfloat d2 = (rc2.transform.position - c.transform.position).magnitude;\n"
    "\t\t\t\t// [OFFLINE-SCREENDIAG] layer 是否被主相机剔除 + 屏幕位置 + 像素高度。\n"
    "\t\t\t\tint blayer = rc2.layer;\n"
    "\t\t\t\tbool maskIn = (c.cullingMask & (1 << blayer)) != 0;\n"
    "\t\t\t\tVector3 chest3 = (body2 != null) ? body2.bounds.center : (rc2.transform.position + new Vector3(0f, 100f, 0f));\n"
    "\t\t\t\tVector3 sp3 = c.WorldToScreenPoint(chest3);\n"
    "\t\t\t\tbool onScr = sp3.z > 0f && sp3.x >= 0f && sp3.x <= c.pixelWidth && sp3.y >= 0f && sp3.y <= c.pixelHeight;\n"
    "\t\t\t\tfloat pxH = 0f;\n"
    "\t\t\t\tif (d2 > 1f)\n"
    "\t\t\t\t{\n"
    "\t\t\t\t\tfloat bodyH3 = (body2 != null) ? body2.bounds.size.y : 200f;\n"
    "\t\t\t\t\tpxH = 1080f * bodyH3 / (2f * d2 * Mathf.Tan(c.fieldOfView * 0.5f * Mathf.Deg2Rad));\n"
    "\t\t\t\t}\n"
    "\t\t\t\ts += \" #\" + bp2.entityId.Value + \"(act=\" + rc2.activeInHierarchy\n"
    "\t\t\t\t\t+ \" d=\" + d2.ToString(\"F0\")\n"
    "\t\t\t\t\t+ \" far=\" + c.farClipPlane.ToString(\"F0\")\n"
    "\t\t\t\t\t+ \" inFar=\" + (d2 <= c.farClipPlane)\n"
    "\t\t\t\t\t+ \" body=\" + ((body2 == null) ? \"none\" : (body2.enabled + \"/\" + body2.isVisible))\n"
    "\t\t\t\t\t+ \" layer=\" + blayer + \"/\" + (maskIn ? \"Y\" : \"N\")\n"
    "\t\t\t\t\t+ \" scr=\" + (onScr ? \"Y\" : \"N\") + \"@\" + sp3.x.ToString(\"F0\") + \",\" + sp3.y.ToString(\"F0\")\n"
    "\t\t\t\t\t+ \" px=\" + pxH.ToString(\"F0\")\n"
    "\t\t\t\t\t+ \")\";\n"
)
if old in src:
    src = src.replace(old, new, 1)
    print("patched pre-render sample with layer/screen/px")
else:
    print("WARN: pattern not found")
    # 打印附近内容帮助定位
    i = src.find("inFar=")
    if i > 0:
        print(repr(src[max(0, i - 500):i + 500]))

io.open(PATH, "w", encoding="utf-8", errors="surrogatepass").write(src)
