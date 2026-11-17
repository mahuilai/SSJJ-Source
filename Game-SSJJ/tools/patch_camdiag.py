# -*- coding: utf-8 -*-
"""[OFFLINE-CAMDIAG] 相机/可见性全套诊断（一次启动拿全证据）
补丁内容：
1. 相机清单 camlist=：遍历 Camera.allCameras，打印 name/pos/far/near/fov/mask/depth/active。
   —— 验证 worldCamera.unityObjects.mainCamera 到底是 "Eye"（玩家眼位）还是原点附近的废弃 Main Camera。
2. 眼位相机实测 eye=：单独打印真正渲染相机（优先 name=="Eye"）的 farClipPlane，
   并与每个 bot 的距离对比 —— far 若=1000（Unity 默认，cm=10m）而 bot 在 11~32m，
   即「bot 被远裁剪面裁掉、老板看不见」的直接原因。
3. 渲染时刻采样 prerender=：挂 Camera.onPreRender，在渲染前瞬间记录 bot 的
   RootContainer.activeInHierarchy + 首个身体 Renderer.enabled/isVisible
   —— HidePlayerSystem(IPreRenderSystem) 在渲染前 SetActive(false) 的真实结果。
用法：python patch_camdiag.py（幂等）
"""
import io

PATH = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
src = io.open(PATH, encoding="utf-8", errors="surrogatepass").read()
done = []

# ---------- 1) camText 后追加相机清单 + 眼位相机 ----------
anchor = '\t\t\tstring camText = (cam != null) ? (cam.transform.position.ToString("F2") + " rot=" + cam.transform.eulerAngles.ToString("F1") + " far=" + cam.farClipPlane) : "null";'
if anchor in src and "camlist=" not in src:
    add = anchor + "\n" + (
        "\t\t\t// [OFFLINE-CAMDIAG] 相机清单：验证 mainCamera 指向哪个相机、真实渲染相机的裁剪面。\n"
        "\t\t\ttry\n"
        "\t\t\t{\n"
        "\t\t\t\tCamera[] allCams = Camera.allCameras;\n"
        "\t\t\t\tstring cl = \"\";\n"
        "\t\t\t\tfor (int ci2 = 0; ci2 < allCams.Length && ci2 < 8; ci2++)\n"
        "\t\t\t\t{\n"
        "\t\t\t\t\tCamera c2 = allCams[ci2];\n"
        "\t\t\t\t\tif (c2 == null) continue;\n"
        "\t\t\t\t\tcl += \" [\" + c2.name + \" far=\" + c2.farClipPlane.ToString(\"F0\")\n"
        "\t\t\t\t\t\t+ \" near=\" + c2.nearClipPlane.ToString(\"F2\")\n"
        "\t\t\t\t\t\t+ \" fov=\" + c2.fieldOfView.ToString(\"F0\")\n"
        "\t\t\t\t\t\t+ \" mask=\" + c2.cullingMask\n"
        "\t\t\t\t\t\t+ \" d=\" + c2.depth.ToString(\"F0\")\n"
        "\t\t\t\t\t\t+ \" en=\" + c2.enabled + \"]\";\n"
        "\t\t\t\t}\n"
        "\t\t\t\tcamText += \" camlist=\" + cl;\n"
        "\t\t\t\tvar wcu = Contexts.sharedInstance.worldCamera;\n"
        "\t\t\t\tif (wcu.hasUnityObjects && wcu.unityObjects.mainCamera != null)\n"
        "\t\t\t\t\tcamText += \" wcMain=\" + wcu.unityObjects.mainCamera.name;\n"
        "\t\t\t\tCamera eyeCam = null;\n"
        "\t\t\t\tfor (int ci3 = 0; ci3 < allCams.Length; ci3++)\n"
        "\t\t\t\t{\n"
        "\t\t\t\t\tif (allCams[ci3] != null && allCams[ci3].name == \"Eye\") { eyeCam = allCams[ci3]; break; }\n"
        "\t\t\t\t}\n"
        "\t\t\t\tif (eyeCam != null)\n"
        "\t\t\t\t\tcamText += \" eye=\" + eyeCam.farClipPlane.ToString(\"F0\") + \"/\" + eyeCam.nearClipPlane.ToString(\"F2\") + \" fov\" + eyeCam.fieldOfView.ToString(\"F0\");\n"
        "\t\t\t\telse\n"
        "\t\t\t\t\tcamText += \" eye=none\";\n"
        "\t\t\t}\n"
        "\t\t\tcatch (System.Exception cex) { camText += \" camlistEX=\" + cex.GetType().Name; }\n"
        "\t\t\tcamText += \" pre=\" + _preSnap;"
    )
    src = src.replace(anchor, add, 1)
    done.append("camlist")

# ---------- 2) 渲染时刻采样：字段 + 回调 + 挂载 ----------
if "OnCamPreSample" not in src:
    # 字段
    fld_anchor = "private Camera _dbgCam;"
    fld = ("private Camera _dbgCam;\n\n"
           "\t// [OFFLINE-CAMDIAG] 渲染前瞬间的 bot 可见性快照（由 Camera.onPreRender 写入）。\n"
           "\tprivate static string _preSnap = \"-\";\n"
           "\tprivate static bool _preHooked;\n")
    if fld_anchor in src:
        src = src.replace(fld_anchor, fld, 1)
        done.append("fields")

    # 回调方法：插到 UpdateDbgCam 前
    method = (
        "\t// [OFFLINE-CAMDIAG] 渲染前瞬间采样：此时 HidePlayerSystem(IPreRenderSystem) 已执行完，\n"
        "\t// 记录 bot RootContainer 的真实 active 状态 + 首个身体 Renderer 的 enabled/isVisible。\n"
        "\tprivate static void OnCamPreSample(Camera c)\n"
        "\t{\n"
        "\t\ttry\n"
        "\t\t{\n"
        "\t\t\tif (c == null || c.name != \"Eye\") return;\n"
        "\t\t\tstring s = \"\";\n"
        "\t\t\tforeach (PlayerEntity bp2 in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))\n"
        "\t\t\t{\n"
        "\t\t\t\tif (!bp2.hasThirdPersonUnityObjects) continue;\n"
        "\t\t\t\tvar tp2 = bp2.thirdPersonUnityObjects.ThirdTran;\n"
        "\t\t\t\tif (tp2 == null || tp2.RootContainer == null) continue;\n"
        "\t\t\t\tGameObject rc2 = tp2.RootContainer;\n"
        "\t\t\t\tRenderer body2 = null;\n"
        "\t\t\t\tRenderer[] rs2 = rc2.GetComponentsInChildren<Renderer>(true);\n"
        "\t\t\t\tfor (int i2 = 0; i2 < rs2.Length; i2++)\n"
        "\t\t\t\t{\n"
        "\t\t\t\t\tif (rs2[i2] == null || !rs2[i2].enabled || !rs2[i2].gameObject.activeInHierarchy) continue;\n"
        "\t\t\t\t\tfloat sy2 = rs2[i2].bounds.size.y;\n"
        "\t\t\t\t\tif (sy2 <= 50f || sy2 >= 3000f) continue;\n"
        "\t\t\t\t\tbody2 = rs2[i2];\n"
        "\t\t\t\t\tbreak;\n"
        "\t\t\t\t}\n"
        "\t\t\t\tfloat d2 = (rc2.transform.position - c.transform.position).magnitude;\n"
        "\t\t\t\ts += \" #\" + bp2.entityId.Value + \"(act=\" + rc2.activeInHierarchy\n"
        "\t\t\t\t\t+ \" d=\" + d2.ToString(\"F0\")\n"
        "\t\t\t\t\t+ \" far=\" + c.farClipPlane.ToString(\"F0\")\n"
        "\t\t\t\t\t+ \" inFar=\" + (d2 <= c.farClipPlane)\n"
        "\t\t\t\t\t+ \" body=\" + ((body2 == null) ? \"none\" : (body2.enabled + \"/\" + body2.isVisible))\n"
        "\t\t\t\t\t+ \")\";\n"
        "\t\t\t}\n"
        "\t\t\t_preSnap = s;\n"
        "\t\t}\n"
        "\t\tcatch (System.Exception) { }\n"
        "\t}\n"
        "\n"
    )
    ins_anchor = "\tprivate void UpdateDbgCam()"
    if ins_anchor in src:
        src = src.replace(ins_anchor, method + ins_anchor, 1)
        done.append("callback")

    # 挂载（Update 里，只挂一次）
    hook_anchor = "\t\tUpdateDbgCam();"
    hook = ("\t\tif (!_preHooked) { _preHooked = true; Camera.onPreRender += OnCamPreSample; }\n"
            "\t\tUpdateDbgCam();")
    if hook_anchor in src:
        src = src.replace(hook_anchor, hook, 1)
        done.append("hook")

io.open(PATH, "w", encoding="utf-8", errors="surrogatepass").write(src)
print("patched:", ", ".join(done) if done else "nothing (already patched?)")
