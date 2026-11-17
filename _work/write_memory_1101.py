# -*- coding: utf-8 -*-
"""记录大厅黑屏根因与修复（2026-11-01）。"""
import io

NOTE = """

## 大厅黑屏根因定位与修复（2026-11-01）

### 结论：不是 DWM 降级，是日志上报抛异常打断资源队列
AIR 弹出了原生对话框「资源：mainView加载失败！」——若真是 DWM/Surface 崩溃，AIR 不会还能弹模态框。
视口窗口实测正常：`ApolloRuntimeContentWindow visible=True rect=[311,50,1024,650] title=SSJJ_FlashAir_Battle16397`。

完整链路：
```
LoginSuccessCommand.execute
 -> ShowMainViewCommand.execute -> loadChannelsRes
   -> LoadResQueue.filterUnLoadedQueueByResNames
     -> PostLogUtil.postMsg("PROBEVO::mainView::url=resource/view/NewMainView_*.xml")
       -> errorutil::RemoteLogPost.postMsg   { try{ throw new Error(msg) } catch(e){ postError(...) } }
         -> postError -> post()
           -> new URLRequest("http://127.0.0.1:8080/log_error") + URLLoader.load()
             -> AIR 沙箱对 127.0.0.1:8080 同步抛 SecurityError
               （网关日志里 /log_error 命中 0 次，请求根本没发出去）
             -> 该异常从 postMsg 的 catch 块抛出，传播出 filterUnLoadedQueueByResNames
               -> 资源队列过滤中断 -> mainView 构建失败 -> 黑屏
```
注：`PROBEVO` 是 4399 官方埋点（在 LoadResQueue 里），不是本地插桩；
`PostLogUtil.postProxy` 由 `Mini.as:400-402`（在 AirLobbyPreloader.swf 里，realInit 时）设为 new RemoteLogPost()。

### 修复 1：reportURL 置空（launch_lobby.py update_configs）
`RemoteLogPost.post()` 首行 `if(!_reportURL || !param1) return;`，置空后直接返回，不抛、不打断。
`reportURL / eventLogURL / statURL / externalURL` 四个一起置空。
`SSJJ_KEEP_LOG_URL=1` 可保留原始 URL（接真服务器时用）。

### 修复 2：netstat GBK 解码崩溃（launch_lobby.py kill_port）
`subprocess.run(['netstat',...], text=True)` 用 utf-8 解码 GBK 输出 -> UnicodeDecodeError
-> 读取线程崩溃 -> stdout 变 None -> AttributeError -> launch_lobby 起不来。
修法：加 `errors='replace'`。

### SWF 基线的真相
- `_work/lobby_air/Lobby_0312bff9….swf`（manifest 标 "official build"）**实际带 PROBE 补丁**：
  md5 == 文件名只是改名后重算的，运行时确实报 PROBELD::ok::。
- 真正干净的官方原版：从 CDN 重新下
  `http://cdn.4399ssjj.com/s3/Lobby_efb5f870bf39d086296ba8864ca94496.swf`
  3670179 字节，md5=efb5f870bf39d086296ba8864ca94496（文件名即 md5，绕过客户端 md5 闸门）。
  已存为 `_work/lobby_air/Lobby_efb5f870bf39d086296ba8864ca94496.swf`。
- A/B 证据：diag_asm 跑一次产生 891 条客户端异常，CDN 官方原版只有 1 条。
- launch_lobby.py 新增环境变量 `SSJJ_LOBBY_NAME`（写进 paras.dat 的 lobbyFileName），
  配合既有的 `SSJJ_LOBBY_SWF`（网关下发的本体）做 A/B 切换。

### 原版 RPC 清单（从 gateway.log 提取，URL 解码后）
- 客户端->服务端请求 **70 个**（callRemote），服务端 Java 侧只实现 **13 个**，**缺 57 个**。
  缺口清单：`_work/capture/rpc_gap_final.json`
- 服务端->客户端回调 58 个（callBack），通知 62 个（Noti）。启动序列与参数样本：
  `_work/capture/rpc_table_gap.json`、`_work/capture/gateway_decoded.log`
- 协议：u32 大端长度 + AMF3，结构 `common.net.APC{functionName,parameters}`（Thrift 风格）。
  帧样本：`_work/capture/amf3_frames.txt`（208 帧）
- 登录签名参数格式：
  `getUserCharacterState params:[username, timestamp, serverId, sign(MD5), {Object}]`
  例：321282597 / 1792834649 / 1 / 78f6163518662935ea0ceb5cbad97b76
- 高频重试 = 客户端拿不到有效响应：getUpgradeInfo 1122 次、mounts 1120 次。

### 工具（本次新增）
- `_work/capture/enum_air_windows.py`  枚举 AIR 全部窗口（类名/样式/透明位）
- `_work/capture/verify_lobby.py`      启动大厅 + 窗口枚举 + 截图 + 新增异常提取（baseline/official/patched 三种模式）
- `_work/capture/extract_rpc.py`      从 gateway.log 抽 RPC 清单与启动序列
- `_work/capture/extract_remote.py`   抽 callRemote 请求方法名并与 Java 实现对表
- `_work/capture/dump_amf3_frames.py` 导出 pcap 里的真实 AMF3 帧
"""

path = r"D:\逆向\SSJJ双塔惊魂\.workbuddy\memory\2026-11-01.md"
try:
    io.open(path, "a", encoding="utf-8").write(NOTE)
    print("appended", len(NOTE))
except FileNotFoundError:
    io.open(path, "w", encoding="utf-8").write(NOTE)
    print("created", len(NOTE))
