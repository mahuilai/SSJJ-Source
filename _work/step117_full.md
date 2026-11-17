[石井 ROUTE] workflow=REV | stages=triage→static→dynamic→recover→prove | skill=coldbrew-breakout

[STAGE] triage — 核对 [HANDOVER-AIR大厅-20261027.md](file:///d:/逆向/SSJJ双塔惊魂/HANDOVER-AIR大厅-20261027.md) 与源码现场

老板，交接文档和相关源码（[Probe.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_probe/Probe.as)、[Mini.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_preloader/scripts/Mini.as)、[FUIAssets.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_preloader/scripts/fl/FUIAssets.as)、[NewMainView.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_out/scripts/lobby/view/main/NewMainView.as)、[MainMediator.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_out/scripts/lobby/view/main/MainMediator.as)、[LobbyLoginServer.java](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_host/java/LobbyLoginServer.java)）已经全部过了一遍。

除了交接文档里指出的 `Probe.as` 两处必改点（删 `Security.allowDomain` + 修正 `LoaderContext`），老子在对照原版预加载器 [Mini.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_preloader/scripts/Mini.as#L694-L740) 时还顺手揪出两个关键细节，已一并写进计划：
1. **预加载器内嵌资产依赖**：原版 `Mini.as` 在加载 `Lobby.swf` 前会先通过 [FUIAssets.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_preloader/scripts/fl/FUIAssets.as) 往当前域 `loadBytes` 注入 `FLUI_ASSETS_swf` 基础组件库，且在 `startLobby` 前会调 `lobby["setJsCallable"](_airJsAdapter)`。`Probe.as` 直接替换根 SWF 时若漏掉这两步，大概率会在主视图初始化时触发空引用或皮肤缺失。
2. **背景音乐弹窗阻塞**：[MainMediator.as](file:///d:/逆向/SSJJ双塔惊魂/_work/lobby_air/ffdec_out/scripts/lobby/view/main/MainMediator.as#L308-L319) 在 `onRegister` 里检查到 `settingBean.isBackgroundMusicNotice == true`（当前 `LobbyLoginServer.java` 第 84 行正好设成了 `true`）会直接调 `AlertManager.show(...)` 弹框并改设置，建议在登录服里直接设为 `false` 排除干扰。

[STAGE] prove — 生成《1:1还原生死狙击》五阶段实施计划

完整执行计划已写入 [implementation_plan.md](file:///C:/Users/Mahuilai/.gemini/antigravity/brain/a81afa3a-ff8f-4868-b75e-fb18da89ec49/implementation_plan.md)，请老板审阅。若无异议，点 Proceed 老子立刻从**阶段 1（修 `Probe.as` → 抓 `LOBBY_UNCAUGHT` → 点亮原版 AIR 大厅）**动手。

当前: [implementation_plan.md](file:///C:/Users/Mahuilai/.gemini/antigravity/brain/a81afa3a-ff8f-4868-b75e-fb18da89ec49/implementation_plan.md) / 五阶段还原计划就绪 / 等待老板拍板执行阶段 1