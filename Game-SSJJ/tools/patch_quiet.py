# -*- coding: utf-8 -*-
"""[OFFLINE-QUIET] 关掉高频诊断，恢复可玩帧率 + 降低闪退风险
问题：
  · _dbgTimer >= 0.35f  → 每 0.35s 拼接数千字符字符串 + 每个 bot GetComponentsInChildren，
    是常态卡顿的主要来源，也给 GC/渲染线程增加压力。
  · Camera.onPreRender 每帧对 5 个 bot 调 GetComponentsInChildren<Renderer>(true)，
    每帧新建数组，同样吃 GC。
处理：
  1) DBG 频率 0.35s → 5s（保留最低限度监控，不再影响手感）
  2) 不挂 onPreRender 渲染时刻采样（数据已采完，层/屏幕/像素三项都拿到了）
用法：python patch_quiet.py（幂等）
"""
import io

PATH = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs"
src = io.open(PATH, encoding="utf-8", errors="surrogatepass").read()
done = []

old1 = "if (_dbgTimer >= 0.35f)"
new1 = "if (_dbgTimer >= 5.0f)  // [OFFLINE-QUIET] 0.35s→5s：高频诊断本身造成卡顿"
if old1 in src:
    src = src.replace(old1, new1, 1)
    done.append("dbg 0.35s->5s")

old2 = "\t\tif (!_preHooked) { _preHooked = true; Camera.onPreRender += OnCamPreSample; }"
new2 = "\t\t// [OFFLINE-QUIET] onPreRender 每帧 5 个 bot GetComponentsInChildren，吃 GC；数据已采完，停用。\n\t\t// if (!_preHooked) { _preHooked = true; Camera.onPreRender += OnCamPreSample; }"
if old2 in src:
    src = src.replace(old2, new2, 1)
    done.append("onPreRender unhooked")
elif "// if (!_preHooked)" in src:
    done.append("onPreRender already off")

io.open(PATH, "w", encoding="utf-8", errors="surrogatepass").write(src)
print("patched:", ", ".join(done) if done else "nothing")
