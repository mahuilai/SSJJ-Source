# -*- coding: utf-8 -*-
"""[OFFLINE-MATDIAG] 给 OfflineGameController.cs 打三补丁：
1. camText 增加全局光照实况（ambient/sun）——SSJJ/Diffuse 无光照属性，
   若环境光为黑且 shader 走顶点光照，角色会整体发黑而地形（lightmap）正常。
2. bot 诊断块增加 matdiag=：运行时材质 _MainTex 是否解析成功、_Color、
   _WeaponColor、shader 变体数、passCount、lightmap/lightprobe 绑定。
   （静态 bundle 侧已核实 _MainTex=REF、_Color=白；运行时 mt=NULL 即外部引用解析失败）
3. UpdateDbgCam 增加 RenderBotCloseups：每个 bot 一张"瞄准特写"PNG
   （相机留玩家眼位、转向 bot 胸部、FOV 按 bounds 身高/距离自适应，单位无关）。
用法：python patch_matdiag.py   （幂等，已打过则跳过）
"""
import io, sys

PATH = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
src = io.open(PATH, encoding="utf-8", errors="surrogatepass").read()
orig_len = len(src)
patched = []

# ---------- Patch 1: camText += 光照实况 ----------
anchor1 = 'string camText = (cam != null) ? (cam.transform.position.ToString("F2") + " rot=" + cam.transform.eulerAngles.ToString("F1") + " far=" + cam.farClipPlane) : "null";'
if anchor1 in src and "ambMode=" not in src:
    add1 = anchor1 + "\n" + (
        "\t\t\t// [OFFLINE-MATDIAG] \u5168\u5c40\u5149\u7167\u5b9e\u51b5\uff1aSSJJ/Diffuse \u65e0\u5149\u7167\u5c5e\u6027\uff0c\n"
        "\t\t\t// \u82e5\u73af\u5883\u5149/\u592a\u9633\u5149\u4e3a\u9ed1\u4e14 shader \u8d70\u9876\u70b9\u5149\u7167\uff0c\u89d2\u8272\u6a21\u578b\u4f1a\u6574\u4f53\u53d1\u9ed1\u800c\u5730\u5f62\uff08lightmap\uff09\u6b63\u5e38\u3002\n"
        "\t\t\tcamText += \" amb=\" + UnityEngine.RenderSettings.ambientLight.ToString(\"F2\")\n"
        "\t\t\t\t+ \" ambMode=\" + ((int)UnityEngine.RenderSettings.ambientMode).ToString()\n"
        "\t\t\t\t+ \" sun=\" + ((UnityEngine.RenderSettings.sun == null) ? \"null\" : (UnityEngine.RenderSettings.sun.color.ToString(\"F2\") + \"@\" + UnityEngine.RenderSettings.sun.intensity.ToString(\"F2\")));"
    )
    src = src.replace(anchor1, add1, 1)
    patched.append("camText+light")

# ---------- Patch 2: bot 诊断块追加 matdiag ----------
anchor2 = "for (int bi = 0; bi < brs.Length && bi < 4; bi++)"
if anchor2 in src and "matdiag=" not in src:
    matdiag = (
        "\t\t\t\t\t// [OFFLINE-MATDIAG] \"\u6a21\u578b\u5f88\u9ed1\"\u8bca\u65ad\uff1a\u8fd0\u884c\u65f6\u6750\u8d28\u5b9e\u51b5\u3002\n"
        "\t\t\t\t\t// \u9759\u6001 bundle \u4fa7\u5df2\u6838\u5b9e _MainTex=REF\u3001_Color=\u767d\uff1b\u8fd0\u884c\u65f6 mt=NULL \u5373\n"
        "\t\t\t\t\t// \u5916\u90e8\u5f15\u7528\u89e3\u6790\u5931\u8d25\uff08tex2D(null)\u2192\u9ed1\uff09\uff1bcol \u975e\u767d\u5373 tint \u88ab\u6539\u9ed1\u3002\n"
        "\t\t\t\t\ttry\n"
        "\t\t\t\t\t{\n"
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
        "\t\t\t\t\t\tif (bodyR == null)\n"
        "\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\tbotText += \" matdiag=nobody\";\n"
        "\t\t\t\t\t\t}\n"
        "\t\t\t\t\t\telse\n"
        "\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\tMaterial bm = bodyR.sharedMaterial;\n"
        "\t\t\t\t\t\t\tif (bm == null)\n"
        "\t\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\t\tbotText += \" matdiag=matnull\";\n"
        "\t\t\t\t\t\t\t}\n"
        "\t\t\t\t\t\t\telse\n"
        "\t\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\t\tstring mt = \"NULL\";\n"
        "\t\t\t\t\t\t\t\ttry\n"
        "\t\t\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\t\t\tTexture mtt = bm.mainTexture;\n"
        "\t\t\t\t\t\t\t\t\tif (mtt != null) mt = mtt.name;\n"
        "\t\t\t\t\t\t\t\t}\n"
        "\t\t\t\t\t\t\t\tcatch (System.Exception) { }\n"
        "\t\t\t\t\t\t\t\tstring bcol = \"-\";\n"
        "\t\t\t\t\t\t\t\ttry { bcol = bm.color.ToString(\"F2\"); }\n"
        "\t\t\t\t\t\t\t\tcatch (System.Exception) { }\n"
        "\t\t\t\t\t\t\t\tstring bwcol = \"-\";\n"
        "\t\t\t\t\t\t\t\ttry\n"
        "\t\t\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\t\t\tif (bm.HasProperty(\"_WeaponColor\")) bwcol = bm.GetColor(\"_WeaponColor\").ToString(\"F2\");\n"
        "\t\t\t\t\t\t\t\t}\n"
        "\t\t\t\t\t\t\t\tcatch (System.Exception) { }\n"
        "\t\t\t\t\t\t\t\tint bkw = -1;\n"
        "\t\t\t\t\t\t\t\ttry { bkw = bm.shaderKeywords.Length; }\n"
        "\t\t\t\t\t\t\t\tcatch (System.Exception) { }\n"
        "\t\t\t\t\t\t\t\tint bpass = -1;\n"
        "\t\t\t\t\t\t\t\ttry { bpass = bm.passCount; }\n"
        "\t\t\t\t\t\t\t\tcatch (System.Exception) { }\n"
        "\t\t\t\t\t\t\t\tbotText += \" matdiag=\" + bm.name\n"
        "\t\t\t\t\t\t\t\t\t+ \" mt=\" + mt\n"
        "\t\t\t\t\t\t\t\t\t+ \" col=\" + bcol\n"
        "\t\t\t\t\t\t\t\t\t+ \" wcol=\" + bwcol\n"
        "\t\t\t\t\t\t\t\t\t+ \" kw=\" + bkw\n"
        "\t\t\t\t\t\t\t\t\t+ \" pass=\" + bpass\n"
        "\t\t\t\t\t\t\t\t\t+ \" lmi=\" + bodyR.lightmapIndex\n"
        "\t\t\t\t\t\t\t\t\t+ \" lpu=\" + ((int)bodyR.lightProbeUsage).ToString();\n"
        "\t\t\t\t\t\t\t}\n"
        "\t\t\t\t\t\t}\n"
        "\t\t\t\t\t}\n"
        "\t\t\t\t\tcatch (System.Exception) { }\n"
        "\n"
    )
    # 插到 anchor2 行前，保持 anchor2 原有缩进（7 tab）
    idx = src.find(anchor2)
    # 找到该行起始（行首缩进）
    line_start = src.rfind("\n", 0, idx) + 1
    indent = ""
    j = line_start
    while j < len(src) and src[j] in " \t":
        indent += src[j]
        j += 1
    src = src[:line_start] + matdiag + indent + src[line_start:]
    patched.append("matdiag")

# ---------- Patch 3: RenderBotCloseups 方法 + 调用 ----------
if "RenderBotCloseups" not in src:
    anchor3 = "private void UpdateDbgCam()"
    idx = src.find(anchor3)
    if idx < 0:
        print("FATAL: UpdateDbgCam anchor not found")
        sys.exit(1)
    line_start = src.rfind("\n", 0, idx) + 1
    method = (
        "\t\t// [OFFLINE-BOTCAM] \u6bcf\u4e2a bot \u7684\"\u719f\u51c6\u7279\u5199\"\uff1a\u76f8\u673a\u7559\u5728\u73a9\u5bb6\u773c\u4f4d\u3001\u8f6c\u5411 bot \u80f8\u90e8\uff0c\n"
        "\t\t// FOV \u6309 bounds \u8eab\u9ad8/\u8ddd\u79bb\u81ea\u9002\u5e94\uff08\u5355\u4f4d\u65e0\u5173\uff09\uff0c\u7b49\u4ef7\u4e8e\u7528\u6237\u76ef\u7740\u8be5 bot \u770b\u7684\u753b\u9762\u3002\n"
        "\t\tprivate void RenderBotCloseups(Camera main, string dir)\n"
        "\t\t{\n"
        "\t\t\ttry\n"
        "\t\t\t{\n"
        "\t\t\t\tint n = 0;\n"
        "\t\t\t\tforeach (PlayerEntity bp in Contexts.sharedInstance.player.GetGroup(PlayerMatcher.EntityId))\n"
        "\t\t\t\t{\n"
        "\t\t\t\t\tif (n >= 6) break;\n"
        "\t\t\t\t\tif (!bp.hasThirdPersonUnityObjects) continue;\n"
        "\t\t\t\t\tvar tpx = bp.thirdPersonUnityObjects.ThirdTran;\n"
        "\t\t\t\t\tif (tpx == null || tpx.RootContainer == null) continue;\n"
        "\t\t\t\t\tif (bp.hasBasicInfo && (bp.basicInfo.Current.IsDead || bp.basicInfo.Current.Hp <= 0f)) continue;\n"
        "\t\t\t\t\tRenderer[] rs = tpx.RootContainer.GetComponentsInChildren<Renderer>(true);\n"
        "\t\t\t\t\tRenderer body = null;\n"
        "\t\t\t\t\tfor (int i = 0; i < rs.Length; i++)\n"
        "\t\t\t\t\t{\n"
        "\t\t\t\t\t\tif (rs[i] != null && rs[i].enabled && rs[i].gameObject.activeInHierarchy && rs[i].bounds.size.y > 50f)\n"
        "\t\t\t\t\t\t{\n"
        "\t\t\t\t\t\t\tbody = rs[i];\n"
        "\t\t\t\t\t\t\tbreak;\n"
        "\t\t\t\t\t\t}\n"
        "\t\t\t\t\t}\n"
        "\t\t\t\t\tif (body == null) continue;\n"
        "\t\t\t\t\tVector3 chest = body.bounds.center;\n"
        "\t\t\t\t\tfloat bodyH = body.bounds.size.y;\n"
        "\t\t\t\t\tfloat bdist = (chest - main.transform.position).magnitude;\n"
        "\t\t\t\t\tif (bdist < 0.01f || bodyH <= 0.01f) continue;\n"
        "\t\t\t\t\tfloat bfov = 2f * Mathf.Atan(bodyH * 0.325f / bdist) * Mathf.Rad2Deg;\n"
        "\t\t\t\t\tif (bfov < 6f) bfov = 6f;\n"
        "\t\t\t\t\tif (bfov > 60f) bfov = 60f;\n"
        "\t\t\t\t\tif (_dbgCam == null)\n"
        "\t\t\t\t\t{\n"
        "\t\t\t\t\t\tvar goc = new GameObject(\"OfflineDbgCam\");\n"
        "\t\t\t\t\t\t_dbgCam = goc.AddComponent<Camera>();\n"
        "\t\t\t\t\t}\n"
        "\t\t\t\t\t_dbgCam.transform.position = main.transform.position;\n"
        "\t\t\t\t\t_dbgCam.transform.rotation = Quaternion.LookRotation(chest - main.transform.position, Vector3.up);\n"
        "\t\t\t\t\t_dbgCam.clearFlags = CameraClearFlags.SolidColor;\n"
        "\t\t\t\t\t_dbgCam.backgroundColor = new Color(0.1f, 0.1f, 0.2f);\n"
        "\t\t\t\t\tRenderCamToFile(_dbgCam, -1,\n"
        "\t\t\t\t\t\tSystem.IO.Path.Combine(dir, \"dbg_bot\" + bp.entityId.Value + \"_\" + _dbgCamN + \".png\"),\n"
        "\t\t\t\t\t\t400, 300, bfov, Mathf.Max(0.05f, bodyH * 0.05f), bdist + bodyH * 10f);\n"
        "\t\t\t\t\tn++;\n"
        "\t\t\t\t}\n"
        "\t\t\t}\n"
        "\t\t\tcatch (System.Exception) { }\n"
        "\t\t}\n"
        "\n"
    )
    src = src[:line_start] + method + src[line_start:]
    patched.append("RenderBotCloseups-method")

    anchor4 = 'RenderCamToFile(_dbgCam, -1, System.IO.Path.Combine(dir, "dbg_all_" + _dbgCamN + ".png"), w, h, main.fieldOfView, main.nearClipPlane, main.farClipPlane);'
    if anchor4 in src:
        add4 = anchor4 + "\n\n\t\t\t// [OFFLINE-BOTCAM] \u6bcf\u4e2a bot \u7684\u719f\u51c6\u7279\u5199\n\t\t\tRenderBotCloseups(main, dir);"
        src = src.replace(anchor4, add4, 1)
        patched.append("RenderBotCloseups-call")
    else:
        print("WARN: dbg_all render anchor not found, call not added")

io.open(PATH, "w", encoding="utf-8", errors="surrogatepass").write(src)
print("patched: %s" % ", ".join(patched) if patched else "nothing")
print("len %d -> %d" % (orig_len, len(src)))
