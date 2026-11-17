# -*- coding: utf-8 -*-
"""[OFFLINE-AI7] 修「bot 看不见」+「卡顿」
A. 卡顿：UpdateDbgCam 每 2.5s 渲染 8 张 PNG（RenderTexture+ReadPixels+EncodeToPNG，
   强制 GPU 同步），是老板感受到的周期性卡顿唯一来源 → 默认关闭。
B. 看不见：pre 渲染采样实测 bot 全部 layer=0/Y、body=True/True、inFar=True、px=49~98
   （1080p 下 49~98 像素高，进画面就一定能看清），唯一问题是 scr=N@4006 ——
   bot 在玩家视野外 34m。原版人机的行为是主动向玩家/交战区推进，这里把
   OfflineBotAI 的「主动推进兜底」阈值收紧，并加无条件远距召回：
     · 队友：>14m 归队 → >8m 归队（贴身护航）
     · 敌人：8s 未接敌且 >25m 才压上 → 3s 未接敌且 >18m 就压上
     · 新增：任何 bot 距玩家 >30m 无条件 Advance 到玩家（防止跑散到地图角落）
用法：python patch_ai_proximity.py（幂等）
"""
import io

# ---------- A. 关 debug 相机 ----------
p1 = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
s1 = io.open(p1, encoding="utf-8", errors="surrogatepass").read()
old_call = "\t\tif (!_preHooked) { _preHooked = true; Camera.onPreRender += OnCamPreSample; }\n\t\tUpdateDbgCam();"
new_call = (
    "\t\tif (!_preHooked) { _preHooked = true; Camera.onPreRender += OnCamPreSample; }\n"
    "\t\t// [OFFLINE-PERF] debug 相机每 2.5s 渲染 8 张 PNG（RenderTexture+ReadPixels 强制\n"
    "\t\t// GPU 同步）会造成周期性卡顿，默认关闭；需要取证时把下面一行改回 UpdateDbgCam();\n"
    "\t\t// UpdateDbgCam();"
)
if old_call in s1:
    s1 = s1.replace(old_call, new_call, 1)
    io.open(p1, "w", encoding="utf-8", errors="surrogatepass").write(s1)
    print("A. UpdateDbgCam disabled (卡顿已消除)")
elif "\t\t// UpdateDbgCam();" in s1:
    print("A. already disabled")
else:
    print("A. WARN: call site not found")

# ---------- B. 收紧推进阈值 + 无条件召回 ----------
p2 = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs"
s2 = io.open(p2, encoding="utf-8", errors="surrogatepass").read()

old_ally = "\t\t\t\t\tif (distToPlayer > 14f && State != BotState.Reload)"
new_ally = "\t\t\t\t\t// [OFFLINE-AI7] 8m 贴身护航（原 14m 太远，玩家看不到队友）\n\t\t\t\t\tif (distToPlayer > 8f && State != BotState.Reload)"
ok_a = old_ally in s2
if ok_a:
    s2 = s2.replace(old_ally, new_ally, 1)

old_enemy = "\t\t\t\telse if (idle > 8f && distToPlayer > 25f)"
new_enemy = "\t\t\t\t// [OFFLINE-AI7] 3s 未接敌且 >18m 就压上（原 8s/25m 会让 bot 在地图另一头各自交火）\n\t\t\t\telse if (idle > 3f && distToPlayer > 18f)"
ok_b = old_enemy in s2
if ok_b:
    s2 = s2.replace(old_enemy, new_enemy, 1)

# 无条件远距召回：插在 else 分支结束前（敌人/队友共通）
anchor = "\t\t\t\telse if (idle > 3f && distToPlayer > 18f)\n\t\t\t\t{\n\t\t\t\t\tState = BotState.Advance;\n\t\t\t\t\tLastKnownPos = w.PlayerPos;\n\t\t\t\t\tLastKnownTime = now;\n\t\t\t\t\tStateEnter = now;\n\t\t\t\t\tLastContact = now;   // 重置计时，避免每帧刷新 StateEnter\n\t\t\t\t}"
recall = anchor + (
    "\n\t\t\t\t// [OFFLINE-AI7] 无条件远距召回：任何情况下距玩家 >30m 都往玩家方向跑，\n"
    "\t\t\t\t// 防止 bot 追着别处的目标跑到地图角落，玩家整局看不到人。\n"
    "\t\t\t\tif (distToPlayer > 30f && State != BotState.Combat && State != BotState.TakeCover\n"
    "\t\t\t\t\t&& State != BotState.Reload)\n"
    "\t\t\t\t{\n"
    "\t\t\t\t\tState = BotState.Advance;\n"
    "\t\t\t\t\tLastKnownPos = w.PlayerPos;\n"
    "\t\t\t\t\tLastKnownTime = now;\n"
    "\t\t\t\t\tStateEnter = now;\n"
    "\t\t\t\t}"
)
ok_c = anchor in s2 and "OFFLINE-AI7] 无条件远距召回" not in s2
if ok_c:
    s2 = s2.replace(anchor, recall, 1)

io.open(p2, "w", encoding="utf-8", errors="surrogatepass").write(s2)
print("B. ally8m=%s enemy3s18m=%s recall30m=%s" % (ok_a, ok_b, ok_c))
