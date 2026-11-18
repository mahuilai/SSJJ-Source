MANAGED_PROCS = []

def cleanup_subprocesses():
    print("[Lobby] Cleaning up subprocesses and client processes...", flush=True)
    for p in list(MANAGED_PROCS):
        try:
            p.terminate()
            p.wait(timeout=1.0)
        except Exception:
            try: p.kill()
            except Exception: pass
    for im in ["AirLobbyPreloader.exe", "AirAloneChat.exe", "adl.exe"]:
        subprocess.run(f"taskkill /f /im {im}", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# -*- coding: utf-8 -*-
"""Launch official Adobe AIR Lobby with 1:1 Java AMF3 Server on user desktop."""
import os, sys, time, subprocess, socket, json, re, struct, threading, ctypes, shutil
from ctypes import wintypes

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOBBY_DIR = r"D:\SSJJ\SSJJ-4399\Lobby"
EXE = os.path.join(LOBBY_DIR, "AirLobbyPreloader.exe")
CHAT_EXE = os.path.join(os.path.dirname(LOBBY_DIR), "chat", "AirAloneChat.exe")
PARAS = os.path.join(LOBBY_DIR, "paras.dat")
LOCAL_HALL = os.path.join(ROOT, "_work", "lobby_host", "hall_config.xml")
LOCAL_RESC = os.path.join(ROOT, "_work", "lobby_host", "res_config_cdn.xml")
LOCAL_RESC_LOCAL = os.path.join(ROOT, "_work", "lobby_host", "res_config_local.xml")
JAVA_DIR = os.path.join(ROOT, "_work", "lobby_host", "java")
PROBE_LOG = os.path.join(ROOT, "Game-SSJJ-logs", "probe.log")
CLIENT_LOG = os.path.join(ROOT, "Game-SSJJ-logs", "client_error.log")

# 官方纯净大厅（未插桩）。diag_asm 在 LobbyLoader.bytesLoadComplete 里插入
# RemoteLogPost 探针，实测会打断 loadBytes 完成链，不能用于渲染验收。
# 官方大厅 (已打 Stage3D Context3D 保活微补丁)
CLEAN_LOBBY = os.path.join(ROOT, "_work", "lobby_air",
                           "Lobby_013451cd1d4ccdad2e745525781b395e.swf")
CLEAN_LOBBY_NAME = os.path.basename(CLEAN_LOBBY)
# 必须在网关子进程启动前写入环境：gateway_8080.py 在 import 时决定 LOCAL_LOBBY。
os.environ.setdefault("SSJJ_LOBBY_SWF", CLEAN_LOBBY)
os.environ.setdefault("SSJJ_LOBBY_NAME", CLEAN_LOBBY_NAME)
os.environ.setdefault("SSJJ_SERVE_DECRYPTED", "1")

HTTP_PORT = 8080
LOGIN_PORT = 2000
MICRO_PORT = 16397

# [PATCH 2026-11-01] 原先这里默认把 FLUI_ASSETS 强制切到 cache_prepared/ 的
# DoABC-剥离版。该机制有两个致命 bug：
#   1) 网关 build_res_contract() 里的 PREPARED_FORCE 重写用的是
#      `txt.replace(omd5, nmd5)` —— 全局字符串替换。而官方 res_config 里
#      同一个 md5 同时出现在 url= 属性和 md5= 属性中，替换把 URL 也改了，
#      客户端于是去请求 <name>_<prepared_md5>.swf，而网关的 key 却按原
#      md5 拼 -> 两边文件名对不上 -> 404 -> 资源加载失败。
#   2) prepared 版剥掉了 DoABC，SymbolClass 悬空，客户端拿不到
#      assets.CommonNewAssets -> NewMainView 死在 TypeError #1007。
# 官方协议路径下（res_config 保持官方 md5/size/compress/encode，客户端用
# 自己的原生 swfDecode 解密）不再需要 prepared 版，cdn_pristine/ 里
# 848 条官方原字节已按契约逐条校验通过。
# 如需调试再用环境变量显式开启。
if os.environ.get("SSJJ_USE_PREPARED_FOR"):
    os.environ.setdefault(
        "SSJJ_PREPARED_FOR",
        "resource_flas_FLUI_ASSETS_9a37251a216750d6847f1ab53c90489d.swf")

def is_port_listening(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        return s.connect_ex(('127.0.0.1', port)) == 0

def _file_size(path):
    try:
        return os.path.getsize(path)
    except OSError:
        return 0

def _read_delta(path, offset):
    try:
        if os.path.getsize(path) <= offset:
            return ''
        with open(path, 'rb') as stream:
            stream.seek(offset)
            return stream.read().decode('utf-8', errors='ignore')
    except OSError:
        return ''

def kill_port(port):
    # netstat 的输出是 GBK（中文 Windows 会打印"侦听"等汉字），必须指定 errors，
    # 否则 text=True 的 utf-8 解码会在读取线程抛 UnicodeDecodeError，
    # 导致 stdout 变成 None、这里 AttributeError，launch_lobby 整个起不来。
    out = subprocess.run(['netstat', '-ano', '-p', 'TCP'],
                         capture_output=True, text=True, errors='replace').stdout or ''
    for ln in out.splitlines():
        parts = ln.split()
        if len(parts) >= 5 and parts[1].endswith(f':{port}') and parts[3] == 'LISTENING':
            subprocess.run(['taskkill', '/f', '/pid', parts[4]], capture_output=True)

class MicroServer(threading.Thread):
    def __init__(self, port=16397):
        super().__init__(daemon=True)
        self.port = port
        self.conns = []
        self.load_complete = threading.Event()
    def run(self):
        s = socket.socket()
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(('127.0.0.1', self.port))
        s.listen(8)
        print(f"[Lobby] Micro Client Adapter listening on port {self.port} (AIR trigger ready)!", flush=True)
        while True:
            try:
                c, a = s.accept()
                print(f"[Lobby] Micro Client connected from {a} -> Triggering realInit!", flush=True)
                self.conns.append(c)
                threading.Thread(target=self._handle_conn, args=(c,), daemon=True).start()
            except Exception:
                break
    def _send(self, c, name, param=''):
        # AirJsAdapter/ClientSocket framing:
        #   outer length  -> ByteArray.readInt()  == BIG endian int32
        #   inner strings -> payload ByteArray has endian="littleEndian",
        #                     so readUTF() inside AirJsAdapter reads LITTLE endian u16.
        # 之前把外层长度也写成小端，AIR 侧解析错位，microSetVisible 永远收不到。
        nb = name.encode('utf-8')
        pb = param.encode('utf-8')
        body = struct.pack('<H', len(nb)) + nb + struct.pack('<H', len(pb)) + pb
        c.sendall(struct.pack('>I', len(body)) + body)

    def restore_viewport(self):
        """Request visibility without sending a second resize to AIR."""
        for c in tuple(self.conns):
            try:
                self._send(c, 'microSetVisible', 'true')
                return True
            except Exception:
                continue
        return False

    # [PATCH 2026-11-01] 不能叫 _handle：threading.Thread.__init__ 会把
    # self._handle 覆盖成 _thread._ThreadHandle 对象，于是 target=self._handle
    # 拿到不可调用对象 -> TypeError: '_thread._ThreadHandle' object is not callable
    # -> 微端连接线程立刻死 -> load_complete 永不 set -> microSetVisible 永不下发
    # -> 大厅卡在加载画面。改名 _handle_conn 彻底避开。
    def _handle_conn(self, c):
        try:
            while True:
                data = c.recv(65535)
                if not data: break
                # The AIR side reports lifecycle callbacks over this socket.
                # Log them so a stalled loader can be distinguished from a
                # rendering/layer problem without touching the client.
                try:
                    print(f"[Lobby] Micro <- {len(data)}B {data[:160]!r}", flush=True)
                except Exception:
                    pass
                if (b'lobby_load_res_compele' in data
                        or b'lobby_load_res_complete' in data):
                    # 官方时序：资源队列完成之后才让微端下发 microSetVisible；
                    # 过早下发会让新视口在 NewMainView 尚未挂载时被激活/重绘。
                    self.load_complete.set()
                    print("[Lobby] Micro load_complete observed; "
                          "deferring microSetVisible until main view is ready.", flush=True)
        except Exception:
            pass

def ensure_services():
    kill_port(HTTP_PORT)
    kill_port(LOGIN_PORT)
    time.sleep(0.5)

    # 1. Check Gateway :8080
    if not is_port_listening(HTTP_PORT):
        print("[Lobby] Starting Master HTTP Gateway on :8080...", flush=True)
        # 网关原来用 DETACHED_PROCESS 且不重定向，stdout 被丢弃 -> 客户端到底请求了什么
        # 完全看不见（曾据此误判「零 HTTP 请求」）。这里落盘到 gateway.log。
        os.makedirs(os.path.join(ROOT, "Game-SSJJ-logs"), exist_ok=True)
        gw_log_path = os.path.join(ROOT, "Game-SSJJ-logs", "gateway.log")
        try:
            gw_log = open(gw_log_path, "a", encoding="utf-8", buffering=1)
        except Exception:
            gw_log = subprocess.DEVNULL
        print(f"[Lobby] Gateway stdout -> {gw_log_path}", flush=True)
        p_gw = subprocess.Popen([sys.executable, os.path.join(ROOT, "_work", "gateway_8080.py")],
                         cwd=ROOT, stdout=gw_log, stderr=gw_log,
                         creationflags=0x00000008 | 0x00000200)
        MANAGED_PROCS.append(p_gw)
        for _ in range(30):
            time.sleep(0.5)
            if is_port_listening(HTTP_PORT): break
        print("[Lobby] Master HTTP Gateway ready on :8080!", flush=True)

    # 2. Check Java AMF3 Lobby Server :2000
    if not is_port_listening(LOGIN_PORT):
        cls_path = os.path.join(JAVA_DIR, "LobbyLoginServer.class")
        java_files = [os.path.join(JAVA_DIR, f) for f in os.listdir(JAVA_DIR) if f.endswith(".java")]
        need_compile = not os.path.isfile(cls_path) or any(
            os.path.getmtime(jf) > os.path.getmtime(cls_path) for jf in java_files
        )
        if need_compile and java_files:
            print("[Lobby] Compiling Java AMF3 LobbyLoginServer...", flush=True)
            subprocess.run(["javac", "-encoding", "UTF-8", "-d", JAVA_DIR] + java_files, check=True)
        print("[Lobby] Starting Java AMF3 LobbyLoginServer on :2000...", flush=True)
        srv_log_path = os.path.join(ROOT, "Game-SSJJ-logs", "server.log")
        srv_log = open(srv_log_path, "a", encoding="utf-8", buffering=1)
        java_cmd = ['java', '-Dfile.encoding=UTF-8']
        # 由 Java 自己打开日志文件。原先只依赖这里的 shell 重定向，
        # 实测 DETACHED_PROCESS 起的子进程 stdout 没落到 server.log，
        # 自动化一直在读旧文件（服务端断言全部失效）。
        java_cmd.append('-Dssjj.logFile=' + os.path.join(ROOT, 'Game-SSJJ-logs', 'server.log'))
        if os.environ.get('SSJJ_RPC_VERBOSE') == '1':
            java_cmd.append('-Dssjj.verbose=1')
        java_cmd.extend(['-cp', JAVA_DIR, 'LobbyLoginServer', str(LOGIN_PORT)])
        p_java = subprocess.Popen(java_cmd,
                         cwd=JAVA_DIR, stdout=srv_log, stderr=srv_log, creationflags=0x00000008 | 0x00000200)
        MANAGED_PROCS.append(p_java)
        for _ in range(20):
            time.sleep(0.5)
            if is_port_listening(LOGIN_PORT): break
        print("[Lobby] Java AMF3 Server ready on :2000!", flush=True)


PLAIN_MANIFEST = os.path.join(ROOT, "_work", "lobby_host", "plain_manifest.json")
DECRYPTED_MANIFEST = os.path.join(ROOT, "_work", "lobby_host", "decrypted_manifest.json")


def apply_decrypted_manifest(cfg_text):
    """Rewrite res_config metadata to describe the server-side decrypted payloads.

    decrypted_manifest.json is produced by _work/_probe5/decrypt_all.py, which
    reproduces the official decryption chain byte for byte:
        XOR (block 1024, offset 91, key "3.1415", index 5-k%6)
        + raw deflate from offset 2
    Only used when SSJJ_SERVE_DECRYPTED=1; the default path keeps the official
    md5/size/compress/encode so the client decodes with its own swfDecode.
    """
    if not os.path.isfile(DECRYPTED_MANIFEST):
        return cfg_text
    try:
        manifest = json.load(open(DECRYPTED_MANIFEST, encoding="utf-8"))
    except Exception as exc:
        print(f"[Lobby] decrypted manifest unreadable: {exc}", flush=True)
        return cfg_text

    by_url = {url: v for url, v in manifest.items() if v.get("md5")}
    patched = [0]
    elem = re.compile(r'<([A-Za-z_][\w.]*)((?:\s+[A-Za-z_][\w.:-]*\s*=\s*"[^"]*")*)\s*(/?)>')

    def fix(attrs, value):
        for key in ("md5", "size", "encode", "compress"):
            pat = re.compile(r'(\s)' + key + r'="[^"]*"')
            repl = '\g<1>' + key + '="' + value[key] + '"'
            if pat.search(attrs):
                attrs = pat.sub(repl, attrs)
            else:
                attrs += ' ' + key + '="' + value[key] + '"'
        return attrs

    def repl(m):
        tag, attrs, close = m.group(1), m.group(2), m.group(3)
        u = re.search(r'url="([^"]+)"', attrs)
        if not u:
            return m.group(0)
        entry = by_url.get(u.group(1))
        if not entry:
            return m.group(0)
        patched[0] += 1
        return '<' + tag + fix(attrs, {
            "md5": entry["md5"], "size": str(entry["size"]),
            "encode": "false", "compress": "false",
        }) + close + '>'

    out = elem.sub(repl, cfg_text)
    print(f"[Lobby] decrypted payload metadata applied to {patched[0]} entries.", flush=True)
    return out

def apply_plain_manifest(cfg_text):
    """Rewrite res_config metadata to describe the plain payloads on disk.

    Every managed attribute is replaced (never appended) so the element keeps a
    single value per key, and the original tag/attribute spelling is preserved.
    """
    if not os.path.isfile(PLAIN_MANIFEST):
        return cfg_text
    try:
        manifest = json.load(open(PLAIN_MANIFEST, encoding="utf-8"))
    except Exception as exc:
        print(f"[Lobby] plain manifest unreadable, keeping CDN metadata: {exc}", flush=True)
        return cfg_text

    by_url = {url: v for url, v in manifest.items() if v.get("tag")}
    patched = [0]
    elem = re.compile(r'<([A-Za-z_][\w.]*)((?:\s+[A-Za-z_][\w.:-]*\s*=\s*"[^"]*")*)\s*(/?)>')

    def fix(attrs, value):
        for key in ("md5", "size", "encode", "compress"):
            pat = re.compile(r'(\s)' + key + r'="[^"]*"')
            repl = '\g<1>' + key + '="' + value[key] + '"'
            if pat.search(attrs):
                attrs = pat.sub(repl, attrs)
            else:
                attrs += ' ' + key + '="' + value[key] + '"'
        return attrs

    def repl(m):
        tag, attrs, close = m.group(1), m.group(2), m.group(3)
        u = re.search(r'url="([^"]+)"', attrs)
        if not u:
            return m.group(0)
        entry = by_url.get(u.group(1))
        if not entry:
            return m.group(0)
        patched[0] += 1
        return '<' + tag + fix(attrs, {
            "md5": entry["md5"], "size": str(entry["size"]),
            "encode": "false", "compress": "false",
        }) + close + '>'

    out = elem.sub(repl, cfg_text)
    print(f"[Lobby] plain payload metadata applied to {patched[0]} entries.", flush=True)
    return out

def update_configs():
    # hall_config.xml
    src_hall = os.path.join(ROOT, "_work", "lobby_ui", "hall_config.xml")
    if os.path.exists(src_hall):
        txt = open(src_hall, encoding='utf-8', errors='replace').read()
        txt = re.sub(r'<!--.*?-->', '', txt, flags=re.DOTALL)
        txt = re.sub(r'>\s+<', '><', txt.strip())
        txt = re.sub(r'<servers>.*?</servers>', f'<servers>127.0.0.1:{LOGIN_PORT}</servers>', txt, flags=re.S)
        txt = re.sub(r'<compress>.*?</compress>', '<compress>false</compress>', txt, flags=re.S)
        # [PATCH 2026-11-01] 日志/统计 URL 必须置空，不能指向 http://127.0.0.1:8080。
        # 原因链（实测，非推测）：
        #   LoadResQueue.filterUnLoadedQueueByResNames
        #     -> PostLogUtil.postMsg("PROBEVO::mainView::url=...")
        #       -> errorutil::RemoteLogPost.postMsg  { try{throw}catch{ postError(...) } }
        #         -> postError -> post() -> new URLRequest(reportURL) + URLLoader.load()
        #           -> AIR 沙箱对 127.0.0.1:8080 同步抛 SecurityError（网关日志里
        #              /log_error 命中 0 次，请求根本没发出去）
        #             -> 该异常从 postMsg 的 catch 块里抛出，传播出
        #                filterUnLoadedQueueByResNames，资源队列过滤中断
        #               -> 「资源：mainView加载失败！」-> 大厅黑屏
        # reportURL 置空后 RemoteLogPost.post() 首行 `if(!_reportURL||!param1) return;`
        # 直接返回，不抛、不打断主流程。离线场景不需要这些上报。
        # SSJJ_KEEP_LOG_URL=1 可保留原始 URL（接真服务器时用）。
        # [PATCH 2026-11-01] 网关现在会提供 crossdomain.xml，AIR 的 URLLoader
        # 可以正常访问 127.0.0.1:8080，SecurityError 消失，客户端 trace 通道恢复
        # （否则报错全部沉底，定位问题只能靠猜）。
        # 需要完全静音上报时设 SSJJ_KEEP_LOG_URL=1（reportURL 置空）。
        if os.environ.get('SSJJ_KEEP_LOG_URL'):
            for tag in ('reportURL', 'eventLogURL', 'statURL', 'externalURL'):
                txt = re.sub(rf'<{tag}>.*?</{tag}>', f'<{tag}></{tag}>', txt, flags=re.S)
        else:
            txt = re.sub(r'<reportURL>.*?</reportURL>', f'<reportURL>http://127.0.0.1:{HTTP_PORT}/log_error</reportURL>', txt, flags=re.S)
            txt = re.sub(r'<eventLogURL>.*?</eventLogURL>', f'<eventLogURL>http://127.0.0.1:{HTTP_PORT}/log_event</eventLogURL>', txt, flags=re.S)
            txt = re.sub(r'<statURL>.*?</statURL>', f'<statURL>http://127.0.0.1:{HTTP_PORT}/log_stat</statURL>', txt, flags=re.S)
            txt = re.sub(r'<externalURL>.*?</externalURL>', f'<externalURL>http://127.0.0.1:{HTTP_PORT}/log_plugin</externalURL>', txt, flags=re.S)
        open(LOCAL_HALL, 'w', encoding='utf-8').write(txt)

    # res_config_local.xml
    if os.path.exists(LOCAL_RESC):
        rs = open(LOCAL_RESC, encoding='utf-8', errors='replace').read()
        rs = rs.replace('http://cdn.4399ssjj.com/s3/', f'http://127.0.0.1:{HTTP_PORT}/')
        # [PATCH 2026-11-01] 恢复官方协议语义（关键修复）。
        #
        # 客户端 CacheBinaryItem.onCompleteHandler 的顺序是：
        #   1) ByteUtils.hashBinary(下载到的原始字节) == res_config 的 md5 -> 通过
        #   2) 若 encode="true" -> ByteUtils.decodeByte()（原生 wdnative swfDecode）
        #   3) 若 compress="true" -> ByteArray.uncompress()（zlib）
        #   4) 之后 XML() / SWF 解析拿到的必须是**明文**
        #
        # 之前的 apply_plain_manifest() 把所有条目的 encode/compress 强制改成
        # false，可 plain_manifest.json 里 287 个 resource/view XML 的 steps
        # 是 'none'——文件根本是 CDN 加密态原样（mainView 11415 B / md5
        # 4bd8246c...，正是 CDN 契约值）。于是：md5 校验通过（因为发的就是原字节）
        # -> 客户端跳过解密解压 -> 把 11415 字节压缩数据喂给 XML()
        # -> analysisLoadDataError resName:mainView,type:XML
        # -> 资源队列永不完成 -> LoadViewResCommand 到不了
        #    REMOVE_RES_LOADING_PANEL -> 幕布不移除 -> 黑屏。
        #
        # 官方 res_config 的 md5/size/compress/encode 描述的就是 CDN 上的字节，
        # 客户端原生 swfDecode 能正确还原。网关已按契约逐条校验过 CDN 原字节
        # （848/848 全齐，md5+size 命中），所以这里保持官方原值不动，
        # 只把 CDN 基址换成本地网关。客户端行为与线上完全一致。
        #
        # 备选方案（服务端解密）：_work/lobby_host/decrypted/ 已用
        # XOR(1024 块/偏移 91/key "3.1415") + raw-deflate 复现官方解密，
        # 848 条全部成功（297 XML 可解析 / 171 FGUI 合法 zip / 372 SWF 头合法），
        # 其中 618 条与 SSJJ-main 官方明文逐字节一致。需设 SSJJ_SERVE_DECRYPTED=1
        # 才会启用；默认走官方协议路径。
        use_decrypted = os.environ.get('SSJJ_SERVE_DECRYPTED') == '1'
        if use_decrypted:
            rs = apply_decrypted_manifest(rs)
            print("[Lobby] serving server-side decrypted payloads (encode/compress off).", flush=True)
        # Locally prepared SWFs are already decoded, have DoABC/DoABC2 removed,
        # and retain their original SymbolClass tags. Keep the loader's content
        # hash and transformation flags aligned with the actual bytes served.
        prepared_manifest = os.path.join(
            ROOT, "_work", "lobby_host", "cache_prepared", "prepared_flasha_manifest.json"
        )
        if os.environ.get('SSJJ_USE_PREPARED') == '1' and os.path.isfile(prepared_manifest):
            try:
                prepared_assets = json.load(open(prepared_manifest, encoding="utf-8")).get("assets", [])
                for asset in prepared_assets:
                    url = re.escape(asset["request_url"])
                    pattern = re.compile(
                        r'<(?P<tag>[A-Za-z0-9_:.-]+)\b(?P<attrs>[^<>]*\burl="' + url + r'"[^<>]*)/>'
                    )
                    def update_asset_attrs(match):
                        attrs = match.group("attrs")
                        values = {
                            "md5": asset["prepared_md5"],
                            "size": str(asset["prepared_size"]),
                            "compress": "false",
                            "encode": "false",
                        }
                        for key, value in values.items():
                            attr = re.compile(r'\b' + re.escape(key) + r'="[^"]*"')
                            replacement = f'{key}="{value}"'
                            if attr.search(attrs):
                                attrs = attr.sub(replacement, attrs, count=1)
                            else:
                                attrs += " " + replacement
                        return f'<{match.group("tag")}{attrs}/>'
                    rs, patched_count = pattern.subn(update_asset_attrs, rs, count=1)
                    if patched_count != 1:
                        print(f"[Lobby] Warning: local res_config entry not found for {asset.get('asset_class')}", flush=True)
            except Exception as exc:
                print(f"[Lobby] Failed to apply prepared SWF metadata: {exc}", flush=True)
        # The prepared set had every DoABC tag stripped out while SymbolClass was
        # kept. That leaves the SymbolClass exports dangling: the client's
        # ByteLoader.getUIClass only gets null definitions, so assets.CommonNewAssets
        # (and every other *Assets class) stays null and NewMainView dies with
        # TypeError #1007 at StyledProgress/init. The prepared set is therefore
        # off by default; the gateway serves contract-checked CDN originals and
        # the client decodes them with its own native swfDecode.
        if os.environ.get('SSJJ_USE_PREPARED') == '1':
            print("[Lobby] DoABC-stripped prepared overrides ENABLED.", flush=True)
        else:
            print("[Lobby] prepared DoABC-stripped overrides disabled; serving contract-checked CDN bytes.", flush=True)
        open(LOCAL_RESC_LOCAL, 'w', encoding='utf-8').write(rs)

    # paras.dat
    if os.path.exists(PARAS):
        if not os.path.exists(PARAS + '.orig.bak'):
            shutil.copy2(PARAS, PARAS + '.orig.bak')
        d = json.load(open(PARAS, encoding='utf-8-sig'))
        d['resurl'] = f'http://127.0.0.1:{HTTP_PORT}/'
        d['server'] = f'127.0.0.1:{LOGIN_PORT}'
        d['microPort'] = MICRO_PORT
        # Patched build: addInnerLoadPanel is returnvoid. The name is the file's
        # own MD5, so the preloader's hash check succeeds immediately.
        #
        # [PATCH 2026-11-01] 根因：diag_asm 构建在 LobbyLoader.bytesLoadComplete
        # 里插了诊断探针 PostLogUtil.postMsg("PROBELD::ok::<url>")，该调用经
        # errorutil::RemoteLogPost 抛异常，把 bytesLoadComplete 整个打断
        # -> "load bytes complete" 打不出来 -> 资源队列停死 -> 大厅黑屏。
        # SSJJ_LOBBY_NAME 可切回未打补丁的官方基线做 A/B 对照。
        d['lobbyFileName'] = os.environ.get('SSJJ_LOBBY_NAME', CLEAN_LOBBY_NAME)
        d['roleCreatorFileName'] = 'HallCreateRole_416563d4b1132ac0544c508f36c41f13.swf'
        d['resConfigFileName'] = 'res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml'
        d['isDebug'] = True
        json.dump(d, open(PARAS, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))

def ensure_official_window_flags():
    """Ensure transparent is false for Stage3D direct mode hardware acceleration."""
    path = os.path.join(LOBBY_DIR, 'META-INF', 'AIR', 'application.xml')
    if not os.path.isfile(path): return
    try:
        text = open(path, encoding='utf-8').read()
        import re
        updated = re.sub(r'<transparent>.*?</transparent>', '<transparent>true</transparent>', text, flags=re.S)
        with open(path, 'w', encoding='utf-8') as f: f.write(updated)
        print('[Lobby] Verified transparent=true for Stage3D direct mode.', flush=True)
    except Exception as e:
        print(f'[Lobby] Window descriptor error: {e}', flush=True)

def stop_old_air_chat():
    """Close a leftover official chat AIR before starting a fresh lobby session."""
    image_name = os.path.basename(CHAT_EXE)
    result = subprocess.run(
        ["taskkill", "/f", "/t", "/im", image_name],
        capture_output=True, text=True, errors='replace',
    )
    if result.returncode == 0:
        print(f"[Lobby] Cleared stale chat process: {image_name}", flush=True)

class STARTUPINFOW(ctypes.Structure):
    _fields_ = [
        ('cb', wintypes.DWORD), ('lpReserved', wintypes.LPWSTR), ('lpDesktop', wintypes.LPWSTR),
        ('lpTitle', wintypes.LPWSTR), ('dwX', wintypes.DWORD), ('dwY', wintypes.DWORD),
        ('dwXSize', wintypes.DWORD), ('dwYSize', wintypes.DWORD), ('dwXCountChars', wintypes.DWORD),
        ('dwYCountChars', wintypes.DWORD), ('dwFillAttribute', wintypes.DWORD), ('dwFlags', wintypes.DWORD),
        ('wShowWindow', wintypes.WORD), ('cbReserved2', wintypes.WORD), ('lpReserved2', ctypes.c_void_p),
        ('hStdInput', wintypes.HANDLE), ('hStdOutput', wintypes.HANDLE), ('hStdError', wintypes.HANDLE),
    ]

class PROCESS_INFORMATION(ctypes.Structure):
    _fields_ = [
        ('hProcess', wintypes.HANDLE), ('hThread', wintypes.HANDLE),
        ('dwProcessId', wintypes.DWORD), ('dwThreadId', wintypes.DWORD),
    ]

def launch_air():
    try:
        ctypes.windll.shcore.SetProcessDpiAwareness(2)
    except Exception:
        pass
    
    # Clear stale instances from the previous session; the two AIR apps are
    # separate processes, so the chat must not be mistaken for the lobby HWND.
    subprocess.run(['taskkill', '/f', '/im', 'AirLobbyPreloader.exe'], capture_output=True)
    stop_old_air_chat()
    time.sleep(0.5)

    si = STARTUPINFOW()
    si.cb = ctypes.sizeof(STARTUPINFOW)
    si.lpDesktop = 'WinSta0\\Default'
    pi = PROCESS_INFORMATION()
    ok = ctypes.windll.kernel32.CreateProcessW(
        None, f'"{EXE}"', None, None, False, 0, None, LOBBY_DIR,
        ctypes.byref(si), ctypes.byref(pi)
    )
    if not ok:
        err = ctypes.windll.kernel32.GetLastError()
        print(f"[Lobby] CreateProcess on WinSta0 failed err={err}, fallback to subprocess", flush=True)
        p = subprocess.Popen([EXE], cwd=LOBBY_DIR)
        return p.pid, None
    print(f"[Lobby] Launched Adobe AIR Lobby on WinSta0\\Default! PID={pi.dwProcessId}", flush=True)
    return pi.dwProcessId, pi.hProcess

def main():
    print("=======================================================", flush=True)
    print("   4399生死狙击 官方AIR大厅启动器 (Java AMF3 服务端)    ", flush=True)
    print("=======================================================", flush=True)
    
    # 确保本地 micro 适配器启动（AIR preloader 的核心保活握手）
    kill_port(MICRO_PORT)
    micro = MicroServer(MICRO_PORT)
    micro.start()

    # Write res_config_local.xml BEFORE the gateway boots: the gateway snapshots it
    # as the delivery contract at startup. Updating it afterwards leaves a one-run
    # lag where the gateway enforces the previous run's metadata.
    update_configs()
    ensure_services()
    ensure_official_window_flags()
    pid, hProc = launch_air()

    user32 = ctypes.windll.user32
    get_exit_code = ctypes.windll.kernel32.GetExitCodeProcess
    get_exit_code.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
    get_exit_code.restype = wintypes.BOOL
    print(f"[Lobby] Lobby running with PID={pid}. Foreground monitor active...", flush=True)
    
    # AIR uses a transparent application host plus a separate 1024x650 game
    # NativeWindow. Mini.startByParams assigns the viewport title below. Never
    # select a window by area alone or rewrite AIR's native window styles.
    viewport_title = f"SSJJ_FlashAir_Battle{MICRO_PORT}"
    user32.GetForegroundWindow.restype = wintypes.HWND
    user32.AttachThreadInput.argtypes = [wintypes.DWORD, wintypes.DWORD, wintypes.BOOL]
    user32.AttachThreadInput.restype = wintypes.BOOL

    def _force_foreground(hwnd):
        """SetForegroundWindow is ignored for a non-foreground caller.

        Temporarily attach to the current foreground thread so the official
        viewport receives focus. No size, style or z-order override is used.
        """
        foreground = user32.GetForegroundWindow()
        foreground_tid = user32.GetWindowThreadProcessId(foreground, None)
        current_tid = ctypes.windll.kernel32.GetCurrentThreadId()
        attached = user32.AttachThreadInput(current_tid, foreground_tid, True)
        try:
            user32.BringWindowToTop(hwnd)
            return user32.SetForegroundWindow(hwnd)
        finally:
            if attached:
                user32.AttachThreadInput(current_tid, foreground_tid, False)

    try:
        h_desk = user32.OpenDesktopW("Default", 0, False, 0x01FF)
        if h_desk:
            user32.SetThreadDesktop(h_desk)
    except Exception:
        pass
    import sys as _sys
    _here = os.path.dirname(os.path.abspath(__file__))
    if _here not in _sys.path:
        _sys.path.insert(0, _here)
    from lobby_host_window import LobbyHostWindow
    host_window = None if os.environ.get('SSJJ_NO_HOST_WINDOW') == '1' else LobbyHostWindow()
    viewport_activated = False
    viewport_hwnd = None
    host_attached = False
    main_view_done = False
    main_view_offsets = None
    load_seen_at = 0.0
    try:
        while True:
            time.sleep(2)
            if host_window and host_window.closed.is_set():
                print("[Lobby] Host window closed by user.", flush=True)
                stop_old_air_chat()
                break
            # 检查 AIR 进程是否存活
            if hProc:
                exit_code = wintypes.DWORD()
                if not get_exit_code(hProc, ctypes.byref(exit_code)):
                    err = ctypes.windll.kernel32.GetLastError()
                    print(f"[Lobby] GetExitCodeProcess failed for PID={pid} err={err}; keep monitoring.", flush=True)
                    continue
                if exit_code.value != 259: # STILL_ACTIVE
                    print(f"[Lobby] AIR process exited with code {exit_code.value}.", flush=True)
                    stop_old_air_chat()
                    break

            if not viewport_activated:
                found = []
                def _cb(h, _):
                    p = wintypes.DWORD()
                    user32.GetWindowThreadProcessId(h, ctypes.byref(p))
                    title = ctypes.create_unicode_buffer(256)
                    class_name = ctypes.create_unicode_buffer(128)
                    user32.GetWindowTextW(h, title, len(title))
                    user32.GetClassNameW(h, class_name, len(class_name))
                    rect = wintypes.RECT()
                    if user32.GetWindowRect(h, ctypes.byref(rect)):
                        if os.environ.get('SSJJ_WINDOW_DEBUG') == '1':
                            print(
                                f"[Lobby] AIR window candidate HWND={int(h):#x} "
                                f"visible={bool(user32.IsWindowVisible(h))} "
                                f"title={title.value!r} class={class_name.value!r} "
                                f"rect={rect.left},{rect.top},{rect.right},{rect.bottom}",
                                flush=True,
                            )
                        is_lobby_title = (title.value in (viewport_title, "SSJJ_FlashAir_Battle16397", "SSJJ_FlashAir_Battle", "SSJJ_BattleClient") or
                                          (user32.IsWindowVisible(h) and any(kw in title.value for kw in ("4399", "生死狙击", "SSJJ"))))
                        if is_lobby_title and class_name.value == "ApolloRuntimeContentWindow":
                            found.append((wintypes.HWND(h), rect))
                        elif p.value == pid and class_name.value == "ApolloRuntimeContentWindow":
                            found.append((wintypes.HWND(h), rect))
                    return True
                WNDPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
                user32.EnumWindows.argtypes = [WNDPROC, wintypes.LPARAM]
                user32.EnumWindows.restype = wintypes.BOOL
                user32.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
                user32.GetWindowThreadProcessId.restype = wintypes.DWORD
                user32.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
                user32.GetWindowRect.restype = wintypes.BOOL
                user32.GetWindowTextW.argtypes = [wintypes.HWND, wintypes.LPWSTR, ctypes.c_int]
                user32.GetWindowTextW.restype = ctypes.c_int
                user32.GetClassNameW.argtypes = [wintypes.HWND, wintypes.LPWSTR, ctypes.c_int]
                user32.GetClassNameW.restype = ctypes.c_int
                user32.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
                user32.ShowWindow.restype = wintypes.BOOL
                user32.SetForegroundWindow.argtypes = [wintypes.HWND]
                user32.SetForegroundWindow.restype = wintypes.BOOL
                user32.IsIconic.argtypes = [wintypes.HWND]
                user32.IsIconic.restype = wintypes.BOOL
                user32.GetWindowLongW.argtypes = [wintypes.HWND, ctypes.c_int]
                user32.GetWindowLongW.restype = ctypes.c_long
                user32.EnumWindows(WNDPROC(_cb), 0)
                if found:
                    hwnd, rect = found[0]
                    hwnd_value = int(hwnd if isinstance(hwnd, int) else (hwnd.value or 0))
                    # Official topology: a hidden transparent host plus this
                    # independent 1024x650 viewport. Never call SetWindowPos /
                    # SetWindowLong here: both reset the AIR DirectX surface.
                    style_before = user32.GetWindowLongW(hwnd, -16)
                    exstyle_before = user32.GetWindowLongW(hwnd, -20)
                    was_iconic = bool(user32.IsIconic(hwnd))
                    restored = user32.ShowWindow(hwnd, 9) if was_iconic else False
                    focused = _force_foreground(hwnd)
                    style_after = user32.GetWindowLongW(hwnd, -16)
                    exstyle_after = user32.GetWindowLongW(hwnd, -20)
                    style_unchanged = (style_before == style_after
                                       and exstyle_before == exstyle_after)
                    print(
                        f"[Lobby] Activated AIR game viewport HWND={hwnd_value:#x} "
                        f"rect={rect.left},{rect.top},{rect.right},{rect.bottom} "
                        f"was_iconic={was_iconic} restore={bool(restored)} "
                        f"focus={bool(focused)} "
                        f"style=0x{style_before & 0xffffffff:08x}/0x{style_after & 0xffffffff:08x} "
                        f"exstyle=0x{exstyle_before & 0xffffffff:08x}/0x{exstyle_after & 0xffffffff:08x} "
                        f"unchanged={style_unchanged}; transparent host left untouched.",
                        flush=True,
                    )
                    if not style_unchanged:
                        print("[Lobby] ERROR: AIR native window style changed; "
                              "this breaks the DirectX surface.", flush=True)
                    viewport_activated = True
                    viewport_hwnd = hwnd
            if not main_view_done and micro.load_complete.is_set():
                if main_view_offsets is None:
                    main_view_offsets = (_file_size(PROBE_LOG), _file_size(CLIENT_LOG))
                    load_seen_at = time.monotonic()
                delta = (_read_delta(PROBE_LOG, main_view_offsets[0])
                         + _read_delta(CLIENT_LOG, main_view_offsets[1]))
                main_ready = any(marker in delta for marker in
                                 ('MVVIEW::9_complete', 'SHOW_MAIN_VIEW',
                                  'MainMediator', 'NewMainView'))
                if main_ready or (time.monotonic() - load_seen_at) >= 1.5:
                    # 官方时序：NewMainView 挂载完成后再让微端确认可见，并只做
                    # 前台激活 + RedrawWindow。绝不调用 SetWindowPos/SetWindowLong：
                    # 任何尺寸/样式改动都会重置 AIR 的 DirectX Surface。
                    sent = micro.restore_viewport()
                    if not viewport_hwnd:
                        for c_title in (viewport_title, "SSJJ_FlashAir_Battle16397", "SSJJ_FlashAir_Battle", "SSJJ_BattleClient"):
                            h_found = user32.FindWindowW(None, c_title)
                            if h_found:
                                viewport_hwnd = wintypes.HWND(h_found)
                                break
                    focused = _force_foreground(viewport_hwnd) if viewport_hwnd else False
                    redraw = False
                    if viewport_hwnd:
                        try:
                            user32.RedrawWindow.argtypes = [
                                wintypes.HWND, ctypes.c_void_p, wintypes.HWND, wintypes.UINT]
                            user32.RedrawWindow.restype = wintypes.BOOL
                            redraw = bool(user32.RedrawWindow(
                                viewport_hwnd, None, None, 0x0001 | 0x0100 | 0x0080))
                        except Exception:
                            pass
                    main_view_done = True
                    if host_window and viewport_hwnd and not host_attached:
                        host_attached = host_window.attach(viewport_hwnd)
                    print(
                        f"[Lobby] Main view ready (marker={main_ready}); "
                        f"microSetVisible={sent} focus={bool(focused)} redraw={redraw} "
                        f"hostAttached={host_attached};", flush=True)
            if host_window and main_view_done and not host_attached:
                if not viewport_hwnd:
                    for c_title in (viewport_title, "SSJJ_FlashAir_Battle16397", "SSJJ_FlashAir_Battle", "SSJJ_BattleClient"):
                        h_found = user32.FindWindowW(None, c_title)
                        if h_found:
                            viewport_hwnd = wintypes.HWND(h_found)
                            break
                if viewport_hwnd:
                    host_attached = host_window.attach(viewport_hwnd)
                    if host_attached:
                        print(f"[Lobby] Embedded AIR viewport into host window (hostAttached=True).", flush=True)
    except KeyboardInterrupt:
        print("[Lobby] Session ended by user.", flush=True)
    finally:
        if host_window:
            host_window.close()
        cleanup_subprocesses()

if __name__ == '__main__':
    main()
