# -*- coding: utf-8 -*-
import http.server, socketserver, os, socket, threading, subprocess, time, urllib.request, urllib.parse, json, re, shutil, sys, ctypes
from ctypes import wintypes

LOBBY = r"D:\SSJJ\SSJJ-4399\Lobby"
PARAS = os.path.join(LOBBY, "paras.dat")
HTTP_PORT = 8080
MICRO_PORT = 16397
LOGIN_PORT = 2000
LOCAL_LOBBY = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_air\Lobby_efb5f870bf39d086296ba8864ca94496.swf"
LOCAL_RESC = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\res_config_cdn.xml"
LOCAL_RESC_LOCAL = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\res_config_local.xml"
LOCAL_HALL = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\hall_config.xml"
SWF_DIR = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main\output\swf"
CACHE = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cache"
CDN = "http://cdn.4399ssjj.com/s3/"

UNITY_VERSION = "76376c1d1efcf9fdc47cba965130b916_20261022110940"
UNITY_MIRROR = r"D:\SSJJ\asset_mirror\Windows"
UNITY_CACHE = r"D:\SSJJ\cache"
UNITY_CDN = "http://cdn.4399ssjj.com/s3/Windows/"
UNITY_MANIFEST = os.path.join(UNITY_MIRROR, "AssetBundles_" + UNITY_VERSION + "2019.manifest")

os.makedirs(CACHE, exist_ok=True)
# hall_config local
src = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\hall_config.xml"
txt = open(src, encoding='utf-8', errors='replace').read()
txt = re.sub(r'<servers>.*?</servers>', '<servers>127.0.0.1:%d</servers>' % LOGIN_PORT, txt, flags=re.S)
txt = re.sub(r'<compress>.*?</compress>', '<compress>false</compress>', txt, flags=re.S)
txt = re.sub(r'<reportURL>.*?</reportURL>', '<reportURL></reportURL>', txt, flags=re.S)
txt = re.sub(r'<eventLogURL>.*?</eventLogURL>', '<eventLogURL></eventLogURL>', txt, flags=re.S)
txt = re.sub(r'<statURL>.*?</statURL>', '<statURL></statURL>', txt, flags=re.S)
txt = re.sub(r'<externalURL>.*?</externalURL>', '<externalURL></externalURL>', txt, flags=re.S)
open(LOCAL_HALL, 'w', encoding='utf-8').write(txt)
# res_config local: rewrite absolute CDN urls to local http so every load is visible
rs = open(LOCAL_RESC, encoding='utf-8', errors='replace').read()
rs = rs.replace('http://cdn.4399ssjj.com/s3/', 'http://127.0.0.1:%d/' % HTTP_PORT)
open(LOCAL_RESC_LOCAL, 'w', encoding='utf-8').write(rs)
print('[host] res_config rewritten to local, %d bytes' % len(rs), flush=True)
# paras local (backup once)
if not os.path.exists(PARAS + '.orig.bak'):
    shutil.copy2(PARAS, PARAS + '.orig.bak')
d = json.load(open(PARAS, encoding='utf-8'))
d['resurl'] = 'http://127.0.0.1:%d/' % HTTP_PORT
d['server'] = '127.0.0.1:%d' % LOGIN_PORT
d['microPort'] = MICRO_PORT
d['lobbyFileName'] = 'Lobby_efb5f870bf39d086296ba8864ca94496.swf'
d['roleCreatorFileName'] = 'HallCreateRole_416563d4b1132ac0544c508f36c41f13.swf'
d['resConfigFileName'] = 'res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml'
d['isDebug'] = True
json.dump(d, open(PARAS, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('[host] paras updated server=%s resurl=%s' % (d['server'], d['resurl']), flush=True)

class H(http.server.SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args): print('[http] %s' % (fmt % args), flush=True)
    def _serve(self, path, ctype='application/octet-stream'):
        data = open(path, 'rb').read()
        self.send_response(200); self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data)
        print('[http] local %s %d' % (path, len(data)), flush=True)
    def do_GET(self):
        p = urllib.parse.urlparse(self.path).path.lstrip('/')
        if p == 'probe':
            q = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            print('[probe] %s' % (q.get('msg',[''])[0]), flush=True)
            body = b'ok'
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        fail_path = os.environ.get('FAIL_PATH')
        if fail_path and p == fail_path:
            print('[http] FORCED 404 %s' % p, flush=True)
            return self.send_error(404)
        if p.endswith('version.php'):
            body = UNITY_VERSION.encode()
            self.send_response(200); self.send_header('Content-Type', 'text/plain')
            self.send_header('Content-Length', str(len(body))); self.end_headers(); self.wfile.write(body)
            print('[http] version.php -> %s' % UNITY_VERSION, flush=True); return
        if 'AssetBundles_' in p and p.endswith('.manifest'):
            if os.path.isfile(UNITY_MANIFEST):
                return self._serve(UNITY_MANIFEST, 'text/xml')
        if 'Windows/' in p:
            name = p.split('Windows/', 1)[1]
            local = os.path.join(UNITY_MIRROR, name.replace('/', os.sep))
            if os.path.isfile(local):
                return self._serve(local, 'application/octet-stream')
            c_name = os.path.join(UNITY_CACHE, os.path.basename(name))
            if os.path.isfile(c_name):
                return self._serve(c_name, 'application/octet-stream')
            url = UNITY_CDN + name
            try:
                os.makedirs(os.path.dirname(local), exist_ok=True)
                with urllib.request.urlopen(url, timeout=30) as r:
                    data = r.read()
                open(local, 'wb').write(data)
                print('[http] mirrored unity %s %d' % (name, len(data)), flush=True)
                self.send_response(200); self.send_header('Content-Type', 'application/octet-stream')
                self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data)
                return
            except Exception as e:
                print('[http] MISS unity %s %s' % (name, e), flush=True)
                return self.send_error(404)
        if p == 'config/hall_config.xml': return self._serve(LOCAL_HALL, 'text/xml')
        if p == 'Lobby_efb5f870bf39d086296ba8864ca94496.swf': return self._serve(LOCAL_LOBBY, 'application/x-shockwave-flash')
        if p == 'config/res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml': return self._serve(LOCAL_RESC_LOCAL, 'text/xml')
        if p == 'FLUI_ASSETS_dec.swf':
            return self._serve(os.path.join(CACHE, 'FLUI_ASSETS_dec.swf'), 'application/x-shockwave-flash')
        if p == 'ComponentAssets_dec.swf':
            return self._serve(r'D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cache_prepared\resource_flas_ComponentAssets_062df38ddb6b6e778a8e00d792df7bcf.swf', 'application/x-shockwave-flash')
        if p == 'RightButtonAssets_dec.swf':
            return self._serve(r'D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cache_prepared\resource_flas_RightButtonAssets_bf3fe9c74d592220229f27b11e534ed6.swf', 'application/x-shockwave-flash')
        if p == 'HallModelAssets_dec.swf':
            return self._serve(r'D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cache_prepared\resource_flas_HallModelAssets_051e678bb680fd0609ad61503d71d9da.swf', 'application/x-shockwave-flash')
        base = os.path.basename(p)
        key = p.replace('/', '_')
        for d in [CACHE, r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cdn_pristine", r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\plain"]:
            cand = os.path.join(d, key)
            if os.path.isfile(cand):
                return self._serve(cand, 'application/octet-stream')

        # Fast weapon generator fallback
        if 'WeaponAssets' in p:
            try:
                import sys
                sys.path.insert(0, r"D:\逆向\SSJJ双塔惊魂\_work")
                import generate_all_weapon_swfs
                tpl_path = os.path.join(CACHE, "resource_swf_WeaponAssets_weapon_001.swf")
                if os.path.isfile(tpl_path):
                    tpl_bytes = open(tpl_path, "rb").read()
                    # extract res
                    m = re.search(r'weapon_([a-zA-Z0-9_-]+)\.swf', base)
                    if m:
                        res = m.group(1)
                        map_path = os.path.join(os.path.dirname(__file__), "shop_weapon_map.json")
                        if os.path.isfile(map_path):
                            wmap = json.load(open(map_path, encoding='utf-8'))
                            winfo = wmap.get(res)
                            if winfo:
                                png_dir = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\assets\previews\weapons"
                                png_file = os.path.join(png_dir, winfo['codeName'].lower() + '.png')
                                if os.path.isfile(png_file):
                                    swf_data = generate_all_weapon_swfs.make_weapon_swf(tpl_bytes, png_file)
                                    if swf_data:
                                        open(cache, 'wb').write(swf_data)
                                        print('[http] auto-generated weapon swf %s' % base, flush=True)
                                        return self._serve(cache, 'application/octet-stream')
            except Exception as ex:
                print('[http] err gen weapon %s: %s' % (base, ex), flush=True)

        try:
            data = None
            last_err = None
            for attempt in range(1):
                try:
                    req = urllib.request.Request(CDN + p, headers={'User-Agent':'Mozilla/5.0'})
                    with urllib.request.urlopen(req, timeout=2) as r:
                        data = r.read(); ctype = r.headers.get('Content-Type','application/octet-stream')
                    break
                except Exception as e:
                    last_err = e
            if data is None:
                local = os.path.join(SWF_DIR, os.path.basename(p))
                if os.path.isfile(local):
                    return self._serve(local, 'application/octet-stream')
                raise last_err
            open(cache, 'wb').write(data)
            self.send_response(200); self.send_header('Content-Type', ctype)
            self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data)
            print('[http] proxy %s %d' % (p, len(data)), flush=True)
        except Exception as e:
            print('[http] MISS %s %s' % (p, e), flush=True)
            self.send_error(404)
    def do_POST(self):
        p = urllib.parse.urlparse(self.path).path
        n = int(self.headers.get('Content-Length') or 0)
        body = self.rfile.read(n) if n else b''
        if p == '/shot':
            tick = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query).get('tick', ['0'])[0]
            shot_file = os.path.join(SHOT_DIR, 'lobby_air_internal_%s.png' % tick)
            open(shot_file, 'wb').write(body)
            print('[shot] SAVED INTERNAL STAGE SHOT: %s %d bytes' % (shot_file, len(body)), flush=True)
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.send_header('Content-Length', '2')
            self.end_headers()
            self.wfile.write(b'ok')
            return
        stamp = time.strftime('%H%M%S')
        fn = os.path.join(CACHE, 'post_%s_%s.bin' % (stamp, p.strip('/').replace('/', '_') or 'root'))
        open(fn, 'wb').write(body)
        try:
            txt = body.decode('utf-8', 'replace')
        except Exception:
            txt = body[:200].hex()
        print('[post] %s %d -> %s\n%s' % (p, len(body), fn, txt[:3000]), flush=True)
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.send_header('Content-Length', '8')
        self.end_headers()
        self.wfile.write(b'recorded')

class Micro(threading.Thread):
    def __init__(self): super().__init__(daemon=True)
    def run(self):
        s=socket.socket(); s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
        s.bind(('127.0.0.1',MICRO_PORT)); s.listen(8); print('[micro] listening',MICRO_PORT,flush=True)
        conns=[]
        while True:
            c,a=s.accept(); print('[micro] accept',a,flush=True); conns.append(c)
            threading.Thread(target=self.h,args=(c,),daemon=True).start()
    def h(self,c):
        try:
            while True:
                d=c.recv(65535)
                if not d: break
                print('[micro] recv %d %s' % (len(d), d[:100].hex()),flush=True)
        except Exception: pass

def kill_port(port):
    out = subprocess.run(['netstat','-ano','-p','TCP'], capture_output=True, text=True, errors='replace').stdout or ''
    pids = set()
    for ln in out.splitlines():
        parts = ln.split()
        if len(parts) >= 5 and parts[1].endswith(':%d' % port) and parts[3] == 'LISTENING':
            pids.add(parts[4])
    for pid in pids:
        print('[host] killing pid %s on port %d' % (pid, port), flush=True)
        subprocess.run(['taskkill','/f','/pid',pid], capture_output=True)

SHOT_DIR = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-logs\shots"

def find_air_window():
    user32 = ctypes.windll.user32
    found = []
    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cb(hwnd, lparam):
        if not user32.IsWindowVisible(hwnd):
            return True
        n = user32.GetWindowTextLengthW(hwnd)
        if n:
            buf = ctypes.create_unicode_buffer(n + 1)
            user32.GetWindowTextW(hwnd, buf, n + 1)
            if 'SSJJ' in buf.value or 'AirLobby' in buf.value or '生死狙击' in buf.value:
                found.append((hwnd, buf.value))
        return True
    user32.EnumWindows(cb, 0)
    return found

class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [("biSize", wintypes.DWORD), ("biWidth", wintypes.LONG), ("biHeight", wintypes.LONG),
                ("biPlanes", wintypes.WORD), ("biBitCount", wintypes.WORD),
                ("biCompression", wintypes.DWORD), ("biSizeImage", wintypes.DWORD),
                ("biXPelsPerMeter", wintypes.LONG), ("biYPelsPerMeter", wintypes.LONG),
                ("biClrUsed", wintypes.DWORD), ("biClrImportant", wintypes.DWORD)]

def grab_gdi_window(hwnd):
    from PIL import Image
    user32 = ctypes.windll.user32
    gdi32 = ctypes.windll.gdi32
    rect = wintypes.RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rect))
    w = max(1, rect.right - rect.left)
    h = max(1, rect.bottom - rect.top)
    hdc_screen = user32.GetDC(0)
    hdc_mem = gdi32.CreateCompatibleDC(hdc_screen)
    hbm = gdi32.CreateCompatibleBitmap(hdc_screen, w, h)
    old = gdi32.SelectObject(hdc_mem, hbm)
    # Try PrintWindow first (PW_RENDERFULLCONTENT = 2), then BitBlt from screen
    PW_RENDERFULLCONTENT = 2
    ok = user32.PrintWindow(hwnd, hdc_mem, PW_RENDERFULLCONTENT)
    if not ok:
        SRCCOPY = 0x00CC0020
        gdi32.BitBlt(hdc_mem, 0, 0, w, h, hdc_screen, rect.left, rect.top, SRCCOPY)
    bi = BITMAPINFOHEADER()
    bi.biSize = ctypes.sizeof(BITMAPINFOHEADER)
    bi.biWidth = w
    bi.biHeight = -h
    bi.biPlanes = 1
    bi.biBitCount = 32
    bi.biCompression = 0
    buf = ctypes.create_string_buffer(w * h * 4)
    gdi32.GetDIBits(hdc_mem, hbm, 0, h, buf, ctypes.byref(bi), 0)
    gdi32.SelectObject(hdc_mem, old)
    gdi32.DeleteObject(hbm)
    gdi32.DeleteDC(hdc_mem)
    user32.ReleaseDC(0, hdc_screen)
    img = Image.frombuffer("RGBA", (w, h), buf, "raw", "BGRA", 0, 1).convert("RGB")
    # If PrintWindow returned all-black, fallback to virtual screen BitBlt
    extrema = img.getextrema()
    if extrema == ((0, 0), (0, 0), (0, 0)):
        hdc_screen = user32.GetDC(0)
        hdc_mem = gdi32.CreateCompatibleDC(hdc_screen)
        hbm = gdi32.CreateCompatibleBitmap(hdc_screen, w, h)
        old = gdi32.SelectObject(hdc_mem, hbm)
        gdi32.BitBlt(hdc_mem, 0, 0, w, h, hdc_screen, rect.left, rect.top, 0x00CC0020)
        gdi32.GetDIBits(hdc_mem, hbm, 0, h, buf, ctypes.byref(bi), 0)
        gdi32.SelectObject(hdc_mem, old)
        gdi32.DeleteObject(hbm)
        gdi32.DeleteDC(hdc_mem)
        user32.ReleaseDC(0, hdc_screen)
        img = Image.frombuffer("RGBA", (w, h), buf, "raw", "BGRA", 0, 1).convert("RGB")
    return img

def shot(tag):
    from PIL import ImageGrab
    os.makedirs(SHOT_DIR, exist_ok=True)
    wins = find_air_window()
    if not wins:
        print('[shot] no AIR window for %s' % tag, flush=True)
        return
    hwnd, title = wins[0]
    user32 = ctypes.windll.user32
    user32.ShowWindow(hwnd, 9) # SW_RESTORE
    user32.SetForegroundWindow(hwnd)
    time.sleep(0.8)
    try:
        img = grab_gdi_window(hwnd)
    except Exception as e:
        print('[shot] gdi fallback err %s, trying ImageGrab' % e, flush=True)
        img = ImageGrab.grab(all_screens=True)
    path = os.path.join(SHOT_DIR, 'lobby_air_%s.png' % tag)
    img.save(path)
    thumb = img.copy()
    thumb.thumbnail((1600, 1000))
    thumb.save(os.path.join(SHOT_DIR, 'lobby_air_%s_small.png' % tag))
    print('[shot] %s %s %dx%d' % (path, title, img.width, img.height), flush=True)

class STARTUPINFOW(ctypes.Structure):
    _fields_ = [
        ('cb', wintypes.DWORD), ('lpReserved', wintypes.LPWSTR), ('lpDesktop', wintypes.LPWSTR),
        ('lpTitle', wintypes.LPWSTR), ('dwX', wintypes.DWORD), ('dwY', wintypes.DWORD),
        ('dwXSize', wintypes.DWORD), ('dwYSize', wintypes.DWORD), ('dwXCountChars', wintypes.DWORD),
        ('dwYCountChars', wintypes.DWORD), ('dwFillAttribute', wintypes.DWORD), ('dwFlags', wintypes.DWORD),
        ('wShowWindow', wintypes.WORD), ('cbReserved2', wintypes.WORD), ('lpReserved2', ctypes.c_void_p),
        ('hStdInput', wintypes.HANDLE), ('hStdOutput', wintypes.HANDLE), ('hStdError', wintypes.HANDLE)
    ]

class PROCESS_INFORMATION(ctypes.Structure):
    _fields_ = [
        ('hProcess', wintypes.HANDLE), ('hThread', wintypes.HANDLE),
        ('dwProcessId', wintypes.DWORD), ('dwThreadId', wintypes.DWORD)
    ]

def launch_on_user_desktop(exe_path, cwd):
    si = STARTUPINFOW()
    si.cb = ctypes.sizeof(STARTUPINFOW)
    si.lpDesktop = 'WinSta0\\Default'
    pi = PROCESS_INFORMATION()
    ok = ctypes.windll.kernel32.CreateProcessW(
        None, f'"{exe_path}"', None, None, False, 0, None, cwd,
        ctypes.byref(si), ctypes.byref(pi)
    )
    if not ok:
        err = ctypes.windll.kernel32.GetLastError()
        print(f'[host] CreateProcess on WinSta0\\\\Default failed err={err}, fallback to subprocess', flush=True)
        return subprocess.Popen([exe_path], cwd=cwd)
    print(f'[host] launched on WinSta0\\\\Default! PID={pi.dwProcessId}', flush=True)
    class ProcessWrapper:
        def __init__(self, pi):
            self.pid = pi.dwProcessId
            self._hProcess = pi.hProcess
            self._hThread = pi.hThread
            self.returncode = None
        def poll(self):
            if self.returncode is not None:
                return self.returncode
            res = ctypes.windll.kernel32.WaitForSingleObject(self._hProcess, 0)
            if res == 0:
                code = wintypes.DWORD()
                ctypes.windll.kernel32.GetExitCodeProcess(self._hProcess, ctypes.byref(code))
                self.returncode = code.value
                return self.returncode
            return None
        def wait(self):
            ctypes.windll.kernel32.WaitForSingleObject(self._hProcess, 0xFFFFFFFF)
            return self.poll()
    return ProcessWrapper(pi)

def main():
    try:
        ctypes.windll.shcore.SetProcessDpiAwareness(2)
    except Exception:
        pass
    # kill old AIR lobby / stale login server
    subprocess.run(['taskkill','/f','/im','AirLobbyPreloader.exe'], capture_output=True)
    kill_port(LOGIN_PORT)
    kill_port(MICRO_PORT)
    kill_port(HTTP_PORT)
    httpd=socketserver.ThreadingTCPServer(('127.0.0.1',HTTP_PORT),H); httpd.daemon_threads=True
    threading.Thread(target=httpd.serve_forever,daemon=True).start()
    Micro().start()
    java=subprocess.Popen(['java','-Dfile.encoding=UTF-8','-cp',r'D:\逆向\SSJJ双塔惊魂\_work\lobby_host\java','LobbyLoginServer',str(LOGIN_PORT)],
                          stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,encoding='utf-8',errors='replace')
    def jlog():
        for ln in java.stdout:
            print('[java] '+ln.rstrip(),flush=True)
    threading.Thread(target=jlog,daemon=True).start()
    time.sleep(1)
    print('[host] launching AIR lobby on user desktop WinSta0\\Default',flush=True)
    p = launch_on_user_desktop(os.path.join(LOBBY,'AirLobbyPreloader.exe'), LOBBY)
    print('[host] pid',p.pid,flush=True)
    
    keep_alive = '--keep-alive' in sys.argv or os.environ.get('KEEP_ALIVE') == '1'
    times = tuple(int(x) for x in os.environ.get('SHOT_TIMES', '15,25,35').split(',')) if not keep_alive else (10, 20)
    for t in times:
        while time.monotonic() - t0 < t:
            if p.poll() is not None:
                print('[host] AIR exited code %s at %.1fs' % (p.returncode, time.monotonic() - t0), flush=True)
                return
            time.sleep(0.5)
        try:
            shot('login_%ds' % t)
        except Exception as se:
            print('[shot] err %s: %s' % (t, se), flush=True)
            
    if keep_alive:
        print('[host] >>> KEEP-ALIVE ACTIVE: Lobby is running on your desktop. Close the window or stop task when done. <<<', flush=True)
        # Periodically ensure window is visible and active
        def keep_foreground():
            user32 = ctypes.windll.user32
            while p.poll() is None:
                wins = find_air_window()
                if wins:
                    hwnd, title = wins[0]
                    user32.ShowWindow(hwnd, 9) # SW_RESTORE
                time.sleep(5)
        threading.Thread(target=keep_foreground, daemon=True).start()
        p.wait()
        print('[host] AIR lobby closed by user code %s' % p.returncode, flush=True)
    else:
        print('[host] done',flush=True)

if __name__=='__main__':
    t0 = time.monotonic()
    main()
