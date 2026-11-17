# -*- coding: utf-8 -*-
"""Launch SSJJ_BattleClient_Unity on user desktop and keep running."""
import subprocess, os, time, sys, ctypes
from ctypes import wintypes

GAME = r"D:\SSJJ-4399\battle\3_64"
EXE = os.path.join(GAME, "SSJJ_BattleClient_Unity.exe")
CACHE = r"D:\SSJJ\cache"
TCP_PORT = 27100
UDP_PORT = 27101
HTTP_PORT = 8080

CODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

def b62(data):
    out=[]
    for i in range(0,len(data),3):
        b0=data[i]; b1=data[i+1] if i+1<len(data) else 0; b2=data[i+2] if i+2<len(data) else 0
        vs=[b0>>2, ((b0&3)<<4)|(b1>>4), ((b1&15)<<2)|(b2>>6), b2&63]
        cnt=4 if i+2<len(data) else (3 if i+1<len(data) else 2)
        for v in vs[:cnt]:
            if v<61: out.append(CODES[v])
            else: out.append('9'); out.append(CODES[v-61])
    return ''.join(out)

def vi(n):
    o=bytearray()
    while True:
        b=n&0x7f; n>>=7
        if n: o.append(b|0x80)
        else: o.append(b); break
    return bytes(o)

def tag(f,w): return vi((f<<3)|w)
def st(f,v):
    if v is None: return b''
    b=v.encode('utf-8'); return tag(f,2)+vi(len(b))+b
def it(f,v):
    if v is None: return b''
    return tag(f,0)+vi(int(v))
def bo(f,v):
    if v is None: return b''
    return tag(f,0)+(b'\x01' if v else b'\x00')

def boot_config(resource_base, ip, tcp, udp):
    b=b''
    b+=st(1,resource_base); b+=st(2,ip); b+=it(3,tcp); b+=it(4,udp)
    b+=it(5,1); b+=it(6,1); b+=it(7,1); b+=st(8,str(int(time.time()))); b+=st(9,"local"); b+=it(10,1)
    b+=st(12,"4399"); b+=it(13,1); b+=bo(14,False); b+=bo(15,True)
    b+=st(20,""); b+=bo(21,False); b+=st(23,"windowed"); b+=st(24,"")
    b+=st(25,"false"); b+=bo(26,True); b+=it(27,0); b+=bo(28,True)
    b+=st(36,'{"aceControlSwitch":false,"aceModeList":[]}')
    b+=st(37,'{"pluginReportRuleList":[]}')
    return b

class STARTUPINFOW(ctypes.Structure):
    _fields_ = [
        ('cb', wintypes.DWORD),
        ('lpReserved', wintypes.LPWSTR),
        ('lpDesktop', wintypes.LPWSTR),
        ('lpTitle', wintypes.LPWSTR),
        ('dwX', wintypes.DWORD),
        ('dwY', wintypes.DWORD),
        ('dwXSize', wintypes.DWORD),
        ('dwYSize', wintypes.DWORD),
        ('dwXCountChars', wintypes.DWORD),
        ('dwYCountChars', wintypes.DWORD),
        ('dwFillAttribute', wintypes.DWORD),
        ('dwFlags', wintypes.DWORD),
        ('wShowWindow', wintypes.WORD),
        ('cbReserved2', wintypes.WORD),
        ('lpReserved2', ctypes.c_void_p),
        ('hStdInput', wintypes.HANDLE),
        ('hStdOutput', wintypes.HANDLE),
        ('hStdError', wintypes.HANDLE),
    ]

class PROCESS_INFORMATION(ctypes.Structure):
    _fields_ = [
        ('hProcess', wintypes.HANDLE),
        ('hThread', wintypes.HANDLE),
        ('dwProcessId', wintypes.DWORD),
        ('dwThreadId', wintypes.DWORD),
    ]

def launch_on_user_desktop(cmd_line, cwd):
    si = STARTUPINFOW()
    si.cb = ctypes.sizeof(STARTUPINFOW)
    si.lpDesktop = 'WinSta0\\Default'
    pi = PROCESS_INFORMATION()
    ok = ctypes.windll.kernel32.CreateProcessW(
        None, cmd_line, None, None, False, 0, None, cwd,
        ctypes.byref(si), ctypes.byref(pi)
    )
    if not ok:
        err = ctypes.windll.kernel32.GetLastError()
        print(f'[BattleClient] CreateProcess on WinSta0 failed err={err}, fallback to subprocess', flush=True)
        return None
    print(f'[BattleClient] Launched on WinSta0\\Default! PID={pi.dwProcessId}', flush=True)
    return pi.dwProcessId

def launch():
    la = b62(boot_config("http://127.0.0.1:%d/"%HTTP_PORT,"127.0.0.1",TCP_PORT,UDP_PORT))
    cmd = f'"{EXE}" -force-d3d11 -configrevise 0 -npopen 0 -window-mode windowed --la {la} --ua wd --preload_dir "{CACHE}"'
    
    pid = launch_on_user_desktop(cmd, GAME)
    if not pid:
        args=[EXE,"-force-d3d11","-configrevise","0","-npopen","0","-window-mode","windowed","--la",la,"--ua","wd","--preload_dir",CACHE]
        flags = 0x00000008 | 0x00000200
        p=subprocess.Popen(args,cwd=GAME,creationflags=flags)
        pid = p.pid
        print(f"[BattleClient] Running fallback PID={pid} with --la={la[:30]}...", flush=True)
    
    print(f"[BattleClient] Active session running with PID={pid}", flush=True)
    while True:
        time.sleep(2)

if __name__ == '__main__':
    launch()
