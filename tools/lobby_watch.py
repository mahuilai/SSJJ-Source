# -*- coding: utf-8 -*-
"""High-frequency lobby viewport watcher (screen BitBlt, no PrintWindow).

Why: the 2026-11-01 user observation is "the lobby renders for ~0.5s then goes
black". A single screenshot cannot catch that. PrintWindow on an AIR/D3D window
can also block for seconds, so this tool deliberately uses only a fast screen
BitBlt and records a JSONL timeline of colors/mean brightness/foreground state.

Safety: BitBlt from the screen is only trusted when the lobby viewport is the
foreground window. If it is occluded, the frame is marked `foreground=false`
and no pixel claim is made (this avoids the 2026-11-01 false positive where an
IDE window was captured as a "2868-color lobby").

Usage:
    python tools/lobby_watch.py Game-SSJJ-logs/watch --wait 90 --duration 35 --interval 0.1
Output: <out>/watch.jsonl + selected <out>/frame_XXX.png
"""
import argparse
import ctypes
import io
import json
import os
import sys
import time
from ctypes import wintypes

try:
    from PIL import Image, ImageStat
except ImportError:
    print(json.dumps({'ok': False, 'error': 'Pillow not available'}))
    sys.exit(1)

user32 = ctypes.windll.user32
gdi32 = ctypes.windll.gdi32

SW_RESTORE = 9
SRCCOPY = 0x00CC0020
DIB_RGB_COLORS = 0
BI_RGB = 0

try:
    hDesk = user32.OpenDesktopW('Default', 0, False, 0x01FF)
    if hDesk:
        user32.SetThreadDesktop(hDesk)
except Exception:
    pass


class RECT(ctypes.Structure):
    _fields_ = [('left', wintypes.LONG), ('top', wintypes.LONG),
                ('right', wintypes.LONG), ('bottom', wintypes.LONG)]


class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [("biSize", wintypes.DWORD), ("biWidth", wintypes.LONG),
                ("biHeight", wintypes.LONG), ("biPlanes", wintypes.WORD),
                ("biBitCount", wintypes.WORD), ("biCompression", wintypes.DWORD),
                ("biSizeImage", wintypes.DWORD), ("biXPelsPerMeter", wintypes.LONG),
                ("biYPelsPerMeter", wintypes.LONG), ("biClrUsed", wintypes.DWORD),
                ("biClrImportant", wintypes.DWORD)]


def find_lobby():
    for title in (
        "4399生死狙击 - SSJJ_FlashAir",
        "SSJJ_FlashAir_Battle16397",
        "SSJJ_FlashAir_Battle",
        "SSJJ_BattleClient",
    ):
        h = user32.FindWindowW(None, title)
        if h:
            return h, title
    return 0, None


def force_foreground(hwnd):
    try:
        user32.GetForegroundWindow.restype = wintypes.HWND
        user32.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
        user32.GetWindowThreadProcessId.restype = wintypes.DWORD
        user32.AttachThreadInput.argtypes = [wintypes.DWORD, wintypes.DWORD, wintypes.BOOL]
        user32.AttachThreadInput.restype = wintypes.BOOL
    except Exception:
        pass
    fg = user32.GetForegroundWindow()
    if fg == hwnd:
        return True
    fg_tid = user32.GetWindowThreadProcessId(fg, None)
    cur_tid = ctypes.windll.kernel32.GetCurrentThreadId()
    attached = user32.AttachThreadInput(cur_tid, fg_tid, True)
    try:
        user32.BringWindowToTop(hwnd)
        user32.SetForegroundWindow(hwnd)
    finally:
        if attached:
            user32.AttachThreadInput(cur_tid, fg_tid, False)
    time.sleep(0.2)
    return user32.GetForegroundWindow() == hwnd


def grab_fast(hwnd):
    """Screen BitBlt of the window rect -> PIL RGB image (no per-pixel Python)."""
    rc = RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rc))
    w, h = rc.right - rc.left, rc.bottom - rc.top
    if w <= 0 or h <= 0:
        return None, 0, 0
    hdc_src = user32.GetDC(0)
    hdc_mem = gdi32.CreateCompatibleDC(hdc_src)
    hbm = gdi32.CreateCompatibleBitmap(hdc_src, w, h)
    gdi32.SelectObject(hdc_mem, hbm)
    gdi32.BitBlt(hdc_mem, 0, 0, w, h, hdc_src, rc.left, rc.top, SRCCOPY)

    bi = BITMAPINFOHEADER()
    bi.biSize = ctypes.sizeof(BITMAPINFOHEADER)
    bi.biWidth = w
    bi.biHeight = -h
    bi.biPlanes = 1
    bi.biBitCount = 32
    bi.biCompression = BI_RGB
    stride = w * 4
    buf = ctypes.create_string_buffer(stride * h)
    gdi32.GetDIBits(hdc_mem, hbm, 0, h, buf, ctypes.byref(bi), DIB_RGB_COLORS)
    gdi32.DeleteObject(hbm)
    gdi32.DeleteDC(hdc_mem)
    user32.ReleaseDC(0, hdc_src)
    img = Image.frombuffer('RGBA', (w, h), buf.raw, 'raw', 'BGRA', stride, 1)
    return img.convert('RGB'), w, h


def measure(img):
    colors = img.getcolors(maxcolors=4096)
    nunique = len(colors) if colors else 4096
    mean = ImageStat.Stat(img.convert('L').resize((128, 72))).mean[0]
    return nunique, round(mean, 2)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out')
    ap.add_argument('--wait', type=float, default=60.0)
    ap.add_argument('--duration', type=float, default=30.0)
    ap.add_argument('--interval', type=float, default=0.1)
    ap.add_argument('--save-every', type=int, default=10)
    ap.add_argument('--min-save-colors', type=int, default=3)
    a = ap.parse_args()

    hwnd, title = find_lobby()
    deadline = time.time() + a.wait
    while not hwnd and time.time() < deadline:
        time.sleep(0.3)
        hwnd, title = find_lobby()
    if not hwnd:
        print(json.dumps({'ok': False, 'error': 'NO_WINDOW'}))
        return 2

    os.makedirs(a.out, exist_ok=True)
    jsonl = os.path.join(a.out, 'watch.jsonl')
    force_foreground(hwnd)
    start = time.time()
    idx = 0
    last_colors = None
    transitions = []
    saved = 0

    with open(jsonl, 'w', encoding='utf-8') as stream:
        while time.time() - start < a.duration:
            h, t = find_lobby()
            if not h:
                stream.write(json.dumps({'index': idx, 't': round(time.time() - start, 3),
                                         'error': 'no_window'}, ensure_ascii=False) + '\n')
                break
            hwnd, title = h, t
            fg = (user32.GetForegroundWindow() == hwnd)
            if not fg:
                force_foreground(hwnd)
                fg = (user32.GetForegroundWindow() == hwnd)
            rec = {'index': idx, 't': round(time.time() - start, 3),
                   'hwnd': int(hwnd), 'title': title, 'foreground': bool(fg)}
            if fg:
                img, w, hh = grab_fast(hwnd)
                if img is not None:
                    nunique, mean = measure(img)
                    rec.update({'colors': nunique, 'mean': mean, 'w': w, 'h': hh})
                    if nunique != last_colors:
                        transitions.append((rec['t'], nunique, mean))
                        last_colors = nunique
                    if nunique >= a.min_save_colors or idx % max(1, a.save_every) == 0:
                        path = os.path.join(a.out, f'frame_{idx:04d}.png')
                        img.save(path)
                        rec['path'] = os.path.abspath(path)
                        saved += 1
            else:
                rec['occluded'] = True
            stream.write(json.dumps(rec, ensure_ascii=False) + '\n')
            stream.flush()
            idx += 1
            time.sleep(max(0.0, a.interval))

    summary = {'ok': True, 'frames': idx, 'saved': saved,
               'jsonl': os.path.abspath(jsonl), 'transitions': transitions}
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())
