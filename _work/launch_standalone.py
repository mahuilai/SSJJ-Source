import os, sys, time, ctypes
from ctypes import wintypes

GAME = r"D:\SSJJ-4399\battle\3_64"
EXE = os.path.join(GAME, "SSJJ_BattleClient_Unity.exe")

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
        print(f'[Standalone] CreateProcess failed err={err}', flush=True)
        return None
    print(f'[Standalone] Launched on WinSta0\\Default PID={pi.dwProcessId}', flush=True)
    return pi.dwProcessId

if __name__ == '__main__':
    log_file = os.path.join(GAME, "log", "offline.log")
    cmd = f'"{EXE}" -force-d3d11 -window-mode windowed -screen-fullscreen 0 -screen-width 1920 -screen-height 1080 -logFile "{log_file}"'
    pid = launch_on_user_desktop(cmd, GAME)
    print("Launched:", pid)
