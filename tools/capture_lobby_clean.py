# -*- coding: utf-8 -*-
"""Capture the lobby viewport with overlapping windows temporarily minimized.

Read-only for the lobby: no SetWindowPos/SetWindowLong/ShowWindow on the lobby.
Other visible windows above the lobby that intersect its rect are minimized for
the capture and restored immediately afterwards. This avoids the false positive
where BitBlt captured the IDE/desktop instead of the lobby.
"""
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lobby_watch as lw  # noqa: E402

user32 = lw.user32
SW_MINIMIZE = 6
SW_RESTORE = 9


def above_windows(lobby):
    tops = []
    WNDENUMPROC = lw.ctypes.WINFUNCTYPE(lw.ctypes.c_bool, lw.wintypes.HWND, lw.wintypes.LPARAM)
    def cb(h, _):
        tops.append(h)
        return True
    user32.EnumWindows(WNDENUMPROC(cb), 0)
    lrect = lw.RECT()
    user32.GetWindowRect(lobby, lw.ctypes.byref(lrect))
    lb = [lrect.left, lrect.top, lrect.right, lrect.bottom]
    out = []
    seen = False
    for h in tops:
        if h == lobby:
            seen = True
            continue
        if seen:
            continue
        rc = lw.RECT()
        user32.GetWindowRect(h, lw.ctypes.byref(rc))
        rb = [rc.left, rc.top, rc.right, rc.bottom]
        inter = not (rb[2] <= lb[0] or lb[2] <= rb[0] or rb[3] <= lb[1] or lb[3] <= rb[1])
        if not inter or not user32.IsWindowVisible(h):
            continue
        n = user32.GetWindowTextLengthW(h)
        if n <= 0:
            continue
        buf = lw.ctypes.create_unicode_buffer(n + 1)
        user32.GetWindowTextW(h, buf, len(buf))
        out.append((h, buf.value))
    return out


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else 'Game-SSJJ-logs/lobby_clean.png'
    hwnd, title = lw.find_lobby()
    if not hwnd:
        print(json.dumps({'ok': False, 'error': 'NO_WINDOW'}))
        return 2
    victims = above_windows(hwnd)
    print('overlapping:', [(int(h), t[:40]) for h, t in victims])
    for h, _ in victims:
        user32.ShowWindow(h, SW_MINIMIZE)
    time.sleep(0.6)
    user32.ShowWindow(hwnd, SW_RESTORE)
    user32.BringWindowToTop(hwnd)
    user32.SetForegroundWindow(hwnd)
    time.sleep(0.6)
    focused = (user32.GetForegroundWindow() == hwnd)
    img, w, h = lw.grab_fast(hwnd)
    if img is None:
        result = {'ok': False, 'error': 'capture_failed', 'focused': bool(focused)}
    else:
        os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
        img.save(out_path)
        colors = img.getcolors(maxcolors=4096)
        result = {
            'ok': True, 'hwnd': int(hwnd), 'title': title, 'w': w, 'h': h,
            'unique_colors': len(colors) if colors else 4096,
            'focused': bool(focused), 'path': os.path.abspath(out_path),
            'overlapping': [int(h) for h, _ in victims],
        }
    for h, _ in victims:
        user32.ShowWindow(h, SW_RESTORE)
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    sys.exit(main())
