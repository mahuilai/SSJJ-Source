# -*- coding: utf-8 -*-
"""Capture the lobby viewport via DWM thumbnail (occlusion-independent).

Creates a temporary host window, registers a DWM thumbnail of the AIR lobby
viewport, pumps messages for a moment, captures the host, then unregisters and
destroys the host. The lobby window itself is never moved, resized or restyled.
"""
import ctypes
import json
import os
import sys
import time
from ctypes import wintypes

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lobby_watch as lw  # noqa: E402

user32 = lw.user32
gdi32 = lw.gdi32
dwmapi = ctypes.windll.dwmapi

DWM_TNP_RECTDESTINATION = 0x1
DWM_TNP_VISIBLE = 0x8
DWM_TNP_SOURCECLIENTAREAONLY = 0x10
WS_OVERLAPPEDWINDOW = 0x00CF0000
WS_VISIBLE = 0x10000000
SW_SHOW = 5
SW_HIDE = 0
PM_REMOVE = 0x1

WNDPROC = ctypes.WINFUNCTYPE(ctypes.c_longlong, wintypes.HWND, wintypes.UINT,
                             wintypes.WPARAM, wintypes.LPARAM)
user32.DefWindowProcW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
user32.DefWindowProcW.restype = ctypes.c_longlong


class WNDCLASSW(ctypes.Structure):
    _fields_ = [
        ('style', wintypes.UINT),
        ('lpfnWndProc', WNDPROC),
        ('cbClsExtra', ctypes.c_int),
        ('cbWndExtra', ctypes.c_int),
        ('hInstance', wintypes.HINSTANCE),
        ('hIcon', wintypes.HICON),
        ('hCursor', wintypes.HANDLE),
        ('hbrBackground', wintypes.HBRUSH),
        ('lpszMenuName', wintypes.LPCWSTR),
        ('lpszClassName', wintypes.LPCWSTR),
    ]


class DWM_THUMBNAIL_PROPERTIES(ctypes.Structure):
    _fields_ = [
        ('dwFlags', wintypes.DWORD),
        ('rcDestination', wintypes.RECT),
        ('rcSource', wintypes.RECT),
        ('opacity', ctypes.c_ubyte),
        ('fVisible', wintypes.BOOL),
        ('fSourceClientAreaOnly', wintypes.BOOL),
    ]


def pump(ms):
    msg = wintypes.MSG()
    end = time.time() + ms / 1000.0
    while time.time() < end:
        while user32.PeekMessageW(ctypes.byref(msg), None, 0, 0, PM_REMOVE):
            user32.TranslateMessage(ctypes.byref(msg))
            user32.DispatchMessageW(ctypes.byref(msg))
        time.sleep(0.01)


def capture_host(host, out_path):
    import io
    from PIL import Image
    hdc = user32.GetWindowDC(host)
    mem = gdi32.CreateCompatibleDC(hdc)
    bmp = gdi32.CreateCompatibleBitmap(hdc, 1024, 650)
    gdi32.SelectObject(mem, bmp)
    ok = user32.PrintWindow(host, mem, 2)  # PW_RENDERFULLCONTENT
    bi = lw.BITMAPINFOHEADER()
    bi.biSize = ctypes.sizeof(lw.BITMAPINFOHEADER)
    bi.biWidth = 1024
    bi.biHeight = -650
    bi.biPlanes = 1
    bi.biBitCount = 32
    bi.biCompression = 0
    stride = 1024 * 4
    buf = ctypes.create_string_buffer(stride * 650)
    gdi32.GetDIBits(mem, bmp, 0, 650, buf, ctypes.byref(bi), 0)
    gdi32.DeleteObject(bmp)
    gdi32.DeleteDC(mem)
    user32.ReleaseDC(host, hdc)
    img = Image.frombuffer('RGBA', (1024, 650), buf.raw, 'raw', 'BGRA', stride, 1).convert('RGB')
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    img.save(out_path)
    colors = img.getcolors(maxcolors=4096)
    return {'printwindow': bool(ok), 'unique_colors': len(colors) if colors else 4096,
            'path': os.path.abspath(out_path)}


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else 'Game-SSJJ-logs/lobby_dwm.png'
    lobby, title = lw.find_lobby()
    if not lobby:
        print(json.dumps({'ok': False, 'error': 'NO_WINDOW'}))
        return 2

    hinst = ctypes.windll.kernel32.GetModuleHandleW(None)
    class_name = 'SSJJThumbHost'
    wc = WNDCLASSW()
    wc.lpfnWndProc = WNDPROC(lambda h, m, w, l: user32.DefWindowProcW(h, m, w, l))
    wc.hInstance = hinst
    wc.lpszClassName = class_name
    wc.hbrBackground = gdi32.GetStockObject(4)  # BLACK_BRUSH
    user32.RegisterClassW(ctypes.byref(wc))

    host = user32.CreateWindowExW(
        0, class_name, 'SSJJ lobby DWM capture', WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        50, 50, 1024, 650, None, None, hinst, None)
    if not host:
        print(json.dumps({'ok': False, 'error': 'CreateWindow failed'}))
        return 3
    user32.ShowWindow(host, SW_SHOW)
    user32.UpdateWindow(host)

    thumb = ctypes.c_ulonglong(0)
    hr = dwmapi.DwmRegisterThumbnail(host, lobby, ctypes.byref(thumb))
    if hr != 0:
        print(json.dumps({'ok': False, 'error': 'DwmRegisterThumbnail', 'hr': hr}))
        user32.DestroyWindow(host)
        return 4

    props = DWM_THUMBNAIL_PROPERTIES()
    props.dwFlags = DWM_TNP_RECTDESTINATION | DWM_TNP_VISIBLE | DWM_TNP_SOURCECLIENTAREAONLY
    props.rcDestination = wintypes.RECT(0, 0, 1024, 650)
    props.opacity = 255
    props.fVisible = True
    props.fSourceClientAreaOnly = True
    hr = dwmapi.DwmUpdateThumbnailProperties(thumb, ctypes.byref(props))
    pump(1200)
    try:
        dwmapi.DwmFlush()
    except Exception:
        pass
    result = capture_host(host, out_path)
    result.update({'ok': True, 'lobby': int(lobby), 'title': title, 'dwm_hr': hr})
    dwmapi.DwmUnregisterThumbnail(thumb)
    user32.DestroyWindow(host)
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    sys.exit(main())
