# -*- coding: utf-8 -*-
import ctypes
from ctypes import wintypes
import os

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

def main():
    si = STARTUPINFOW()
    si.cb = ctypes.sizeof(STARTUPINFOW)
    si.lpDesktop = 'WinSta0\\Default'
    pi = PROCESS_INFORMATION()
    exe = r'D:\逆向\SSJJ双塔惊魂\离线大厅启动器.exe'
    cwd = r'D:\逆向\SSJJ双塔惊魂'
    ok = ctypes.windll.kernel32.CreateProcessW(
        None, f'"{exe}"', None, None, False, 0, None, cwd,
        ctypes.byref(si), ctypes.byref(pi)
    )
    print('CreateProcess ok:', bool(ok), 'PID:', pi.dwProcessId)
    if not ok:
        print('Error code:', ctypes.windll.kernel32.GetLastError())

if __name__ == '__main__':
    main()
