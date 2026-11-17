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

HTTP_PORT = 8080
LOGIN_PORT = 2000
MICRO_PORT = 16397

def is_port_listening(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        return s.connect_ex(('127.0.0.1', port)) == 0

def kill_port(port):
    out = subprocess.run(['netstat', '-ano', '-p', 'TCP'], capture_output=True, text=True).stdout
    for ln in out.splitlines():
        parts = ln.split()
        if len(parts) >= 5 and parts[1].endswith(f':{port}') and parts[3] == 'LISTENING':
            subprocess.run(['taskkill', '/f', '/pid', parts[4]], capture_output=True)

class MicroServer(threading.Thread):
    def __init__(self, port=16397):
        super().__init__(daemon=True)
        self.port = port
        self.conns = []
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
                threading.Thread(target=self._handle, args=(c,), daemon=True).start()
            except Exception:
                break
    def _send(self, c, name, param=''):
        # AirJsAdapter/ClientSocket framing: little-endian int32 length, then two
        # little-endian length-prefixed UTF strings (writeUTF honours endianness).
        nb = name.encode('utf-8')
        pb = param.encode('utf-8')
        body = struct.pack('<H', len(nb)) + nb + struct.pack('<H', len(pb)) + pb
        c.sendall(struct.pack('<I', len(body)) + body)

    def _drive(self, c):
        # AIR positions the viewport itself. Avoid changing its native size.
        time.sleep(0.5)
        try:
            self._send(c, 'microSetVisible', 'true')
        except Exception:
            return

    def restore_viewport(self):
        """Request visibility without sending a second resize to AIR."""
        for c in tuple(self.conns):
            try:
                self._send(c, 'microSetVisible', 'true')
                return True
            except Exception:
                continue
        return False

    def _handle(self, c):
        threading.Thread(target=self._drive, args=(c,), daemon=True).start()
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
        except Exception:
            pass

def ensure_services():
    kill_port(HTTP_PORT)
    kill_port(LOGIN_PORT)
    time.sleep(0.5)

    # 1. Check Gateway :8080
    if not is_port_listening(HTTP_PORT):
        print("[Lobby] Starting Master HTTP Gateway on :8080...", flush=True)
        subprocess.Popen([sys.executable, os.path.join(ROOT, "_work", "gateway_8080.py")],
                         cwd=ROOT, creationflags=0x00000008 | 0x00000200)
        for _ in range(30):
            time.sleep(0.5)
            if is_port_listening(HTTP_PORT): break
        print("[Lobby] Master HTTP Gateway ready on :8080!", flush=True)

    # 2. Check Java AMF3 Lobby Server :2000
    if not is_port_listening(LOGIN_PORT):
        print("[Lobby] Starting Java AMF3 LobbyLoginServer on :2000...", flush=True)
        srv_log = open(r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-logs\server.log", "a", encoding="utf-8")
        java_cmd = ['java', '-Dfile.encoding=UTF-8']
        if os.environ.get('SSJJ_RPC_VERBOSE') == '1':
            java_cmd.append('-Dssjj.verbose=1')
        java_cmd.extend(['-cp', JAVA_DIR, 'LobbyLoginServer', str(LOGIN_PORT)])
        subprocess.Popen(java_cmd,
                         cwd=JAVA_DIR, stdout=srv_log, stderr=srv_log, creationflags=0x00000008 | 0x00000200)
        for _ in range(20):
            time.sleep(0.5)
            if is_port_listening(LOGIN_PORT): break
        print("[Lobby] Java AMF3 Server ready on :2000!", flush=True)


PLAIN_MANIFEST = os.path.join(ROOT, "_work", "lobby_host", "plain_manifest.json")

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
        txt = re.sub(r'<reportURL>.*?</reportURL>', f'<reportURL>http://127.0.0.1:{HTTP_PORT}/log_error</reportURL>', txt, flags=re.S)
        txt = re.sub(r'<eventLogURL>.*?</eventLogURL>', f'<eventLogURL>http://127.0.0.1:{HTTP_PORT}/log_event</eventLogURL>', txt, flags=re.S)
        txt = re.sub(r'<statURL>.*?</statURL>', f'<statURL>http://127.0.0.1:{HTTP_PORT}/log_stat</statURL>', txt, flags=re.S)
        txt = re.sub(r'<externalURL>.*?</externalURL>', f'<externalURL>http://127.0.0.1:{HTTP_PORT}/log_plugin</externalURL>', txt, flags=re.S)
        open(LOCAL_HALL, 'w', encoding='utf-8').write(txt)

    # res_config_local.xml
    if os.path.exists(LOCAL_RESC):
        rs = open(LOCAL_RESC, encoding='utf-8', errors='replace').read()
        rs = rs.replace('http://cdn.4399ssjj.com/s3/', f'http://127.0.0.1:{HTTP_PORT}/')
        # Repoint every entry that has a plain payload at the bytes the gateway
        # actually serves for it: md5/size of those bytes and encode/compress
        # off, so the client's decode and uncompress stages stay out of the way.
        rs = apply_plain_manifest(rs)
        # Locally prepared SWFs are already decoded, have DoABC/DoABC2 removed,
        # and retain their original SymbolClass tags. Keep the loader's content
        # hash and transformation flags aligned with the actual bytes served.
        prepared_manifest = os.path.join(
            ROOT, "_work", "lobby_host", "cache_prepared", "prepared_flasha_manifest.json"
        )
        if os.path.isfile(prepared_manifest):
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
        # TypeError #1007 at StyledProgress/init. Unless explicitly opted in with
        # SSJJ_USE_PREPARED=1, re-apply plain-payload metadata so the gateway serves
        # the decode-only SWFs that still carry their full DoABC.
        if os.environ.get('SSJJ_USE_PREPARED') != '1':
            rs = apply_plain_manifest(rs)
            print("[Lobby] prepared DoABC-stripped overrides disabled; serving plain payloads.", flush=True)
        open(LOCAL_RESC_LOCAL, 'w', encoding='utf-8').write(rs)

    # paras.dat
    if os.path.exists(PARAS):
        if not os.path.exists(PARAS + '.orig.bak'):
            shutil.copy2(PARAS, PARAS + '.orig.bak')
        d = json.load(open(PARAS, encoding='utf-8'))
        d['resurl'] = f'http://127.0.0.1:{HTTP_PORT}/'
        d['server'] = f'127.0.0.1:{LOGIN_PORT}'
        d['microPort'] = MICRO_PORT
        # Patched build: addInnerLoadPanel is returnvoid. The name is the file's
        # own MD5, so the preloader's hash check succeeds immediately.
        d['lobbyFileName'] = 'Lobby_29b1b7b7353f6501aafd6fc66cdc6964_diag_asm.swf'
        d['roleCreatorFileName'] = 'HallCreateRole_416563d4b1132ac0544c508f36c41f13.swf'
        d['resConfigFileName'] = 'res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml'
        d['isDebug'] = True
        json.dump(d, open(PARAS, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))

def ensure_official_window_flags():
    """Restore only the official transparent flag on AIR's initial host window.

    Leave visibility, render mode, size, chrome and every other descriptor value
    untouched. Back up the descriptor before correcting this one documented flag.
    """
    path = os.path.join(LOBBY_DIR, "META-INF", "AIR", "application.xml")
    if not os.path.isfile(path):
        return
    try:
        text = open(path, encoding="utf-8").read()
        match = re.search(r"<transparent>\s*(.*?)\s*</transparent>", text, re.S)
        value = match.group(1).strip().lower() if match else "default"
        if value != "true":
            if match is None:
                print("[Lobby] ERROR: AIR initialWindow has no transparent flag; descriptor left unchanged.", flush=True)
                return
            stamp = time.strftime("%Y%m%d-%H%M%S")
            backup = path + ".bak-" + stamp
            shutil.copy2(path, backup)
            updated, count = re.subn(
                r"<transparent>\s*.*?\s*</transparent>",
                "<transparent>true</transparent>",
                text,
                count=1,
                flags=re.S,
            )
            if count != 1:
                print("[Lobby] ERROR: could not restore transparent host flag.", flush=True)
                return
            temp_path = path + ".tmp"
            with open(temp_path, "w", encoding="utf-8", newline="") as output:
                output.write(updated)
            os.replace(temp_path, path)
            print(f"[Lobby] Restored official transparent=true (backup: {os.path.basename(backup)}).", flush=True)
        else:
            print("[Lobby] Verified official transparent=true; all other AIR window flags preserved.", flush=True)
    except Exception as exc:
        print(f"[Lobby] Window descriptor verification failed: {exc}", flush=True)

def stop_old_air_chat():
    """Close a leftover official chat AIR before starting a fresh lobby session."""
    image_name = os.path.basename(CHAT_EXE)
    result = subprocess.run(
        ["taskkill", "/f", "/t", "/im", image_name],
        capture_output=True, text=True,
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

    viewport_activated = False
    viewport_hwnd = None
    viewport_activated_at = 0.0
    startup_recovery_attempted = False
    try:
        while True:
            time.sleep(2)
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
                    if user32.IsWindowVisible(h):
                        p = wintypes.DWORD()
                        user32.GetWindowThreadProcessId(h, ctypes.byref(p))
                        if p.value == pid:
                            title = ctypes.create_unicode_buffer(256)
                            class_name = ctypes.create_unicode_buffer(128)
                            user32.GetWindowTextW(h, title, len(title))
                            user32.GetClassNameW(h, class_name, len(class_name))
                            rect = wintypes.RECT()
                            if user32.GetWindowRect(h, ctypes.byref(rect)):
                                width = rect.right - rect.left
                                height = rect.bottom - rect.top
                                if os.environ.get('SSJJ_WINDOW_DEBUG') == '1':
                                    print(
                                        f"[Lobby] AIR window candidate HWND={int(h):#x} "
                                        f"visible={bool(user32.IsWindowVisible(h))} "
                                        f"title={title.value!r} class={class_name.value!r} "
                                        f"rect={rect.left},{rect.top},{rect.right},{rect.bottom}",
                                        flush=True,
                                    )
                                # This exact title is set by Mini on the actual game
                                # viewport. The transparent shell has a different
                                # title and remains untouched even if equally large.
                                # GetWindowRect may report DPI-scaled physical pixels,
                                # so identify the 16:10 viewport by ratio rather than
                                # assuming the unscaled 1024x650 dimensions.
                                if (title.value == viewport_title
                                        and class_name.value == "ApolloRuntimeContentWindow"):
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
                    viewport_activated_at = time.monotonic()
            elif viewport_hwnd and not startup_recovery_attempted:
                # The micro host can park its content window during startup. Make
                # one recovery attempt after the lobby has had time to initialize;
                # after that, respect the user's minimize/focus actions.
                startup_age = time.monotonic() - viewport_activated_at
                if startup_age >= 8 and startup_age <= 60:
                    rect = wintypes.RECT()
                    user32.GetWindowRect(viewport_hwnd, ctypes.byref(rect))
                    iconic = user32.IsIconic(viewport_hwnd)
                    parked = iconic or rect.left < -10000 or rect.top < -10000
                    if parked:
                        resent = micro.restore_viewport()
                        time.sleep(0.2)
                        restored = user32.ShowWindow(viewport_hwnd, 9) if iconic else False
                        user32.GetWindowRect(viewport_hwnd, ctypes.byref(rect))
                        moved = False
                        if rect.left < -10000 or rect.top < -10000:
                            user32.SetWindowPos.argtypes = [wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, wintypes.UINT]
                            user32.SetWindowPos.restype = wintypes.BOOL
                            moved = bool(user32.SetWindowPos(viewport_hwnd, None, 100, 50, 1024, 650, 0x0014))
                        focused = user32.SetForegroundWindow(viewport_hwnd)
                        raised = user32.BringWindowToTop(viewport_hwnd)
                        startup_recovery_attempted = True
                        print(
                            f"[Lobby] AIR parked the startup viewport; requested visible={resent}, "
                            f"restore={bool(restored)} moved={moved} focus={bool(focused)} top={bool(raised)}.",
                            flush=True,
                        )
                elif startup_age > 60:
                    startup_recovery_attempted = True
    except KeyboardInterrupt:
        print("[Lobby] Session ended by user.", flush=True)

if __name__ == '__main__':
    main()
