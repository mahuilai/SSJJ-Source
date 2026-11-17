# -*- coding: utf-8 -*-
"""恢复游戏窗口 -> 置顶 -> BitBlt 截屏 -> 缩放到 <=1280px 预览图"""
import ctypes, sys, os
from ctypes import wintypes

out = sys.argv[1] if len(sys.argv) > 1 else r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-logs\shots\bighead_now.png"
os.makedirs(os.path.dirname(out), exist_ok=True)

user32 = ctypes.windll.user32
gdi32 = ctypes.windll.gdi32

SW_RESTORE = 9
hwnd = user32.FindWindowW(None, "SSJJ_BattleClient_Unity")
if not hwnd:
    # 类名兜底
    hwnd = user32.FindWindowW("UnityWndClass", None)
print("hwnd=", hwnd)
if hwnd:
    user32.ShowWindow(hwnd, SW_RESTORE)
    user32.SetForegroundWindow(hwnd)
    user32.SetWindowPos(hwnd, -1, 0, 0, 0, 0, 0x0001 | 0x0002)  # TOPMOST NOSIZE
    import time
    time.sleep(1.2)

SM_XVIRTUALSCREEN, SM_YVIRTUALSCREEN = 76, 77
SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN = 78, 79
SRCCOPY = 0x00CC0020

x = user32.GetSystemMetrics(SM_XVIRTUALSCREEN)
y = user32.GetSystemMetrics(SM_YVIRTUALSCREEN)
w = user32.GetSystemMetrics(SM_CXVIRTUALSCREEN)
h = user32.GetSystemMetrics(SM_CYVIRTUALSCREEN)
print(f"virtual screen {x},{y} {w}x{h}")

hdc_screen = user32.GetDC(0)
hdc_mem = gdi32.CreateCompatibleDC(hdc_screen)
hbm = gdi32.CreateCompatibleBitmap(hdc_screen, w, h)
gdi32.SelectObject(hdc_mem, hbm)
gdi32.BitBlt(hdc_mem, 0, 0, w, h, hdc_screen, x, y, SRCCOPY)


class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [("biSize", wintypes.DWORD), ("biWidth", wintypes.LONG), ("biHeight", wintypes.LONG),
                ("biPlanes", wintypes.WORD), ("biBitCount", wintypes.WORD),
                ("biCompression", wintypes.DWORD), ("biSizeImage", wintypes.DWORD),
                ("biXPelsPerMeter", wintypes.LONG), ("biYPelsPerMeter", wintypes.LONG),
                ("biClrUsed", wintypes.DWORD), ("biClrImportant", wintypes.DWORD)]


bi = BITMAPINFOHEADER()
bi.biSize = ctypes.sizeof(BITMAPINFOHEADER)
bi.biWidth = w
bi.biHeight = -h
bi.biPlanes = 1
bi.biBitCount = 32
bi.biCompression = 0
stride = w * 4
buf = ctypes.create_string_buffer(stride * h)
gdi32.GetDIBits(hdc_mem, hbm, 0, h, buf, ctypes.byref(bi), 0)

# BGRA -> RGB 去 alpha，写 PPM 再由 PIL 缩放存 PNG
raw = bytes(buf)
lines = []
for row in range(h):
    base = row * stride
    line = bytearray()
    for col in range(w):
        p = base + col * 4
        b, g, r = raw[p], raw[p + 1], raw[p + 2]
        line += bytes((r, g, b))
    lines.append(bytes(line))
ppm = b"P6\n%d %d\n255\n" % (w, h) + b"".join(lines)

from PIL import Image
import io
img = Image.open(io.BytesIO(ppm))
if img.width > 1280:
    nh = int(img.height * 1280 / img.width)
    img = img.resize((1280, nh), Image.LANCZOS)
img.save(out)
print("saved", out, img.size, os.path.getsize(out))
