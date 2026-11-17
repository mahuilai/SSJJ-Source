# 在 OfflineGameController.cs 的 private void Update() 前插入 UpdateDbgCam 方法块
path = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
with open(path, "r", encoding="utf-8", errors="surrogateescape") as f:
    src = f.read()

if "private void UpdateDbgCam()" in src:
    print("method already defined, skip")
    raise SystemExit(0)

marker = "\tprivate void Update()\r"
# 反编译文件是 CR-CR-LF 混行尾，稳妥起见用 \r 前缀定位
idx = src.find(marker)
if idx < 0:
    # 退而求其次：纯 LF
    marker = "\tprivate void Update()\n"
    idx = src.find(marker)
if idx < 0:
    raise SystemExit("marker not found")

block = (
"\t// [OFFLINE-DBGCAM] 渲染探针相机：每 2.5 秒从游戏主相机视角渲染两张 PNG 到\r\n"
"\t// Game-SSJJ-logs\\dbgcam\\：\r\n"
"\t//   dbg_main_N.png = 主相机原样渲染（= 用户屏幕上应该看到的内容）\r\n"
"\t//   dbg_all_N.png  = 同视角全 layer 渲染（cullingMask=-1）\r\n"
"\t// 对比两张图即可定位\"日志说 isVisible=true 但用户看不见\"的断层：\r\n"
"\t//   main 有 / all 有 → 模型正常渲染（截图工具问题，非游戏 bug）\r\n"
"\t//   main 无 / all 有 → 主相机 cullingMask/layer 把 bot 层剔掉了\r\n"
"\t//   main 无 / all 无 → 模型根本没渲染出来（材质/深度/缩放问题）\r\n"
"\tprivate Camera _dbgCam;\r\n"
"\r\n"
"\tprivate float _dbgCamT;\r\n"
"\r\n"
"\tprivate int _dbgCamN;\r\n"
"\r\n"
"\tprivate void UpdateDbgCam()\r\n"
"\t{\r\n"
"\t\tif (UnityEngine.Time.realtimeSinceStartup - _dbgCamT < 2.5f) return;\r\n"
"\t\t_dbgCamT = UnityEngine.Time.realtimeSinceStartup;\r\n"
"\t\ttry\r\n"
"\t\t{\r\n"
"\t\t\tCamera main = null;\r\n"
"\t\t\tvar wc = Contexts.sharedInstance.worldCamera;\r\n"
"\t\t\tif (wc.hasUnityObjects && wc.unityObjects.mainCamera != null)\r\n"
"\t\t\t\tmain = wc.unityObjects.mainCamera;\r\n"
"\t\t\tif (main == null) main = Camera.main;\r\n"
"\t\t\tif (main == null) return;\r\n"
"\r\n"
"\t\t\tstring dir = @\"D:\\逆向\\SSJJ双塔惊魂\\Game-SSJJ-logs\\dbgcam\";\r\n"
"\t\t\tSystem.IO.Directory.CreateDirectory(dir);\r\n"
"\t\t\tint w = 640, h = 400;\r\n"
"\r\n"
"\t\t\tRenderCamToFile(main, main.cullingMask, System.IO.Path.Combine(dir, \"dbg_main_\" + _dbgCamN + \".png\"), w, h, main.fieldOfView, main.nearClipPlane, main.farClipPlane);\r\n"
"\r\n"
"\t\t\tif (_dbgCam == null)\r\n"
"\t\t\t{\r\n"
"\t\t\t\tvar go = new GameObject(\"OfflineDbgCam\");\r\n"
"\t\t\t\t_dbgCam = go.AddComponent<Camera>();\r\n"
"\t\t\t}\r\n"
"\t\t\t_dbgCam.transform.position = main.transform.position;\r\n"
"\t\t\t_dbgCam.transform.rotation = main.transform.rotation;\r\n"
"\t\t\t_dbgCam.clearFlags = CameraClearFlags.SolidColor;\r\n"
"\t\t\t_dbgCam.backgroundColor = new Color(0.1f, 0.1f, 0.2f);\r\n"
"\t\t\tRenderCamToFile(_dbgCam, -1, System.IO.Path.Combine(dir, \"dbg_all_\" + _dbgCamN + \".png\"), w, h, main.fieldOfView, main.nearClipPlane, main.farClipPlane);\r\n"
"\r\n"
"\t\t\t_dbgCamN++;\r\n"
"\t\t}\r\n"
"\t\tcatch (System.Exception ex)\r\n"
"\t\t{\r\n"
"\t\t\tif (_dbgCamN < 3) UnityEngine.Debug.Log(\"[OFFLINE-DBGCAM] fail \" + ex.Message);\r\n"
"\t\t}\r\n"
"\t}\r\n"
"\r\n"
"\tprivate static void RenderCamToFile(Camera cam, int mask, string path, int w, int h, float fov, float nearC, float farC)\r\n"
"\t{\r\n"
"\t\tRenderTexture rt = RenderTexture.GetTemporary(w, h, 24);\r\n"
"\t\tint oldMask = cam.cullingMask;\r\n"
"\t\tfloat oldFov = cam.fieldOfView;\r\n"
"\t\tfloat oldNear = cam.nearClipPlane;\r\n"
"\t\tfloat oldFar = cam.farClipPlane;\r\n"
"\t\tRenderTexture oldRt = cam.targetTexture;\r\n"
"\t\tcam.cullingMask = mask;\r\n"
"\t\tcam.fieldOfView = fov;\r\n"
"\t\tcam.nearClipPlane = nearC;\r\n"
"\t\tcam.farClipPlane = farC;\r\n"
"\t\tcam.targetTexture = rt;\r\n"
"\t\tcam.Render();\r\n"
"\t\tRenderTexture.active = rt;\r\n"
"\t\tTexture2D tex = new Texture2D(w, h, TextureFormat.RGB24, false);\r\n"
"\t\ttex.ReadPixels(new Rect(0f, 0f, w, h), 0, 0);\r\n"
"\t\ttex.Apply();\r\n"
"\t\tSystem.IO.File.WriteAllBytes(path, tex.EncodeToPNG());\r\n"
"\t\tUnityEngine.Object.Destroy(tex);\r\n"
"\t\tRenderTexture.active = null;\r\n"
"\t\tcam.targetTexture = oldRt;\r\n"
"\t\tcam.cullingMask = oldMask;\r\n"
"\t\tcam.fieldOfView = oldFov;\r\n"
"\t\tcam.nearClipPlane = oldNear;\r\n"
"\t\tcam.farClipPlane = oldFar;\r\n"
"\t\tRenderTexture.ReleaseTemporary(rt);\r\n"
"\t}\r\n"
"\r\n"
)

src = src[:idx] + block + src[idx:]
with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
    f.write(src)
print("inserted UpdateDbgCam before Update() at offset", idx)
