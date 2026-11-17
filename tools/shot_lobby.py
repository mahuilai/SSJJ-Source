# -*- coding: utf-8 -*-
"""只截「大厅窗口」本身（不再截整个桌面）

为什么需要这个工具：用全屏截图判定大厅是否渲染过，会被桌面上的其它窗口污染。
本项目实测踩过：桌面上同时开着一个 Unity 战斗客户端，全屏图的
mean/stddev/unique_colors 全部"改善"，但大厅视口其实仍是黑的。

策略：
  1. 定位大厅窗口（标题 SSJJ_FlashAir_Battle16397，兜底用 AirLobbyPreloader 的 MainWindowHandle）
  2. 优先 PrintWindow(PW_RENDERFULLCONTENT)，可截被遮挡的窗口内容
  3. 若 PrintWindow 结果近乎全同色（Flash/AIR 常见），回退到「置前 + 按窗口矩形 BitBlt 屏幕」
  4. 只保存该窗口矩形，绝不包含桌面其它区域

用法:
    python tools/shot_lobby.py out.png
    python tools/shot_lobby.py out.png --json
退出码: 0 成功 / 2 找不到窗口 / 3 截图为空
"""
import argparse
import ctypes
import json
import os
import sys
import time
from ctypes import wintypes

user32 = ctypes.windll.user32
gdi32 = ctypes.windll.gdi32

SW_RESTORE = 9
PW_RENDERFULLCONTENT = 0x00000002
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
    _fields_ = [("biSize", wintypes.DWORD), ("biWidth", wintypes.LONG), ("biHeight", wintypes.LONG),
                ("biPlanes", wintypes.WORD), ("biBitCount", wintypes.WORD),
                ("biCompression", wintypes.DWORD), ("biSizeImage", wintypes.DWORD),
                ("biXPelsPerMeter", wintypes.LONG), ("biYPelsPerMeter", wintypes.LONG),
                ("biClrUsed", wintypes.DWORD), ("biClrImportant", wintypes.DWORD)]


def find_lobby():
    for title in ("SSJJ_FlashAir_Battle16397", "SSJJ_FlashAir_Battle", "SSJJ_BattleClient"):
        h = user32.FindWindowW(None, title)
        if h:
            return h, title
    return 0, None


def force_foreground(hwnd):
    """Bring the lobby viewport to the foreground.

    BitBlt from the screen is only valid when this exact window is foreground;
    otherwise it captures whatever window happens to be on top.  This bit us in
    the 2026-11-01 e2e: the IDE window was captured and produced a 2868-color
    "lobby" that was actually the desktop (false positive).
    """
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
    time.sleep(0.35)
    return user32.GetForegroundWindow() == hwnd


def grab(hwnd, use_printwindow):
    rc = RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rc))
    w, h = rc.right - rc.left, rc.bottom - rc.top
    if w <= 0 or h <= 0:
        return None, 0, 0

    hdc_src = user32.GetWindowDC(hwnd) if use_printwindow else user32.GetDC(0)
    hdc_mem = gdi32.CreateCompatibleDC(hdc_src)
    hbm = gdi32.CreateCompatibleBitmap(hdc_src, w, h)
    gdi32.SelectObject(hdc_mem, hbm)

    if use_printwindow:
        ok = user32.PrintWindow(hwnd, hdc_mem, PW_RENDERFULLCONTENT)
        if not ok:
            user32.PrintWindow(hwnd, hdc_mem, 0)
    else:
        gdi32.BitBlt(hdc_mem, 0, 0, w, h, hdc_src, rc.left, rc.top, SRCCOPY)

    bi = BITMAPINFOHEADER()
    bi.biSize = ctypes.sizeof(BITMAPINFOHEADER)
    bi.biWidth = w
    bi.biHeight = -h          # 负数 = 自顶向下
    bi.biPlanes = 1
    bi.biBitCount = 32
    bi.biCompression = BI_RGB
    stride = w * 4
    buf = ctypes.create_string_buffer(stride * h)
    gdi32.GetDIBits(hdc_mem, hbm, 0, h, buf, ctypes.byref(bi), DIB_RGB_COLORS)

    raw = bytes(buf)
    # BGRA -> PPM(RGB)；同时统计不同色数，用于判断 PrintWindow 是否截空
    rows = []
    seen = set()
    for row in range(h):
        base = row * stride
        line = bytearray()
        for col in range(w):
            p = base + col * 4
            b, g, r = raw[p], raw[p + 1], raw[p + 2]
            line += bytes((r, g, b))
            if len(seen) < 64:
                seen.add((r, g, b))
        rows.append(bytes(line))
    ppm = b"P6\n%d %d\n255\n" % (w, h) + b"".join(rows)

    gdi32.DeleteObject(hbm)
    gdi32.DeleteDC(hdc_mem)
    if use_printwindow:
        user32.ReleaseDC(hwnd, hdc_src)
    else:
        user32.ReleaseDC(0, hdc_src)
    return ppm, w, h


def capture(hwnd, out_path, force_fg=True):
    """Capture one frame and return a JSON-able health record."""
    import io
    from PIL import Image

    foreground = force_foreground(hwnd) if force_fg else (user32.GetForegroundWindow() == hwnd)
    ppm, w, h = grab(hwnd, True)
    used = 'printwindow'
    if ppm is None:
        return {'ok': False, 'error': 'bad_rect', 'hwnd': hwnd,
                'foreground': bool(foreground), 'path': None}
    img = Image.open(io.BytesIO(ppm))
    nunique = len(img.convert('RGB').getcolors(maxcolors=4096) or [])
    if nunique <= 2 and foreground:
        # Screen BitBlt is occlusion-safe only when this window is foreground.
        ppm2, w2, h2 = grab(hwnd, False)
        if ppm2 is not None:
            img2 = Image.open(io.BytesIO(ppm2))
            n2 = len(img2.convert('RGB').getcolors(maxcolors=4096) or [])
            if n2 > nunique:
                img, w, h, nunique, used = img2, w2, h2, n2, 'bitblt'
    elif nunique <= 2 and not foreground:
        used = 'printwindow_occluded'

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    img.save(out_path)
    return {'ok': nunique > 2, 'hwnd': hwnd, 'w': w, 'h': h,
            'unique_colors': nunique, 'method': used,
            'foreground': bool(foreground),
            'path': os.path.abspath(out_path), 'bytes': os.path.getsize(out_path)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out')
    ap.add_argument('--json', action='store_true')
    ap.add_argument('--watch', action='store_true',
                    help='capture a series into <out>/frame_XXX.png + watch.jsonl')
    ap.add_argument('--interval', type=float, default=0.25)
    ap.add_argument('--duration', type=float, default=8.0)
    ap.add_argument('--wait', type=float, default=0.0,
                    help='wait up to N seconds for the lobby window before capturing')
    a = ap.parse_args()

    hwnd, title = find_lobby()
    if not hwnd and a.wait > 0:
        deadline = time.time() + a.wait
        while time.time() < deadline and not hwnd:
            time.sleep(0.5)
            hwnd, title = find_lobby()
    if not hwnd:
        print('NO_WINDOW')
        return 2

    user32.ShowWindow(hwnd, SW_RESTORE)

    if a.watch:
        outdir = a.out
        os.makedirs(outdir, exist_ok=True)
        jsonl = os.path.join(outdir, 'watch.jsonl')
        deadline = time.time() + a.duration
        idx = 0
        with open(jsonl, 'w', encoding='utf-8') as stream:
            while time.time() < deadline:
                h, t = find_lobby()
                if h:
                    hwnd, title = h, t
                frame = os.path.join(outdir, f'frame_{idx:03d}.png')
                info = capture(hwnd, frame)
                info.update({'ts': round(time.time(), 3), 'index': idx, 'title': title})
                stream.write(json.dumps(info, ensure_ascii=False) + '\n')
                stream.flush()
                print(json.dumps(info, ensure_ascii=False), flush=True)
                idx += 1
                time.sleep(max(0.05, a.interval))
        print(json.dumps({'ok': True, 'frames': idx, 'jsonl': os.path.abspath(jsonl)},
                         ensure_ascii=False))
        return 0

    info = capture(hwnd, a.out)
    info['title'] = title
    if a.json:
        print(json.dumps(info, ensure_ascii=False))
    else:
        print(f"SAVED hwnd={info.get('hwnd')} {info.get('w')}x{info.get('h')} "
              f"colors={info.get('unique_colors')} via={info.get('method')} "
              f"fg={info.get('foreground')} -> {a.out}")
    return 0 if info.get('unique_colors', 0) > 2 else 3


if __name__ == '__main__':
    sys.exit(main())
