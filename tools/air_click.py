# -*- coding: utf-8 -*-
"""点击 AIR 大厅窗口（M2 端到端验收用）

背景：AIR 大厅启动后会显示一个「点击继续」遮罩，不点击就不会加载大厅模块、
也不会向 AMF3 服务端发任何 RPC（表现为窗口停在「正在登录。。。」且服务端零请求）。
历史驱动脚本 _work/click_and_capture.py 里就有一行注释：
    # Click the window to dismiss 'click to continue'

用法:
    python tools/air_click.py                 # 找窗口 -> 居中点击一次
    python tools/air_click.py --list          # 只列出候选窗口
    python tools/air_click.py --title 4399    # 按标题关键字筛选
    python tools/air_click.py --times 2 --delay 1.5

退出码: 0 = 找到窗口并完成点击, 2 = 未找到窗口
"""
import argparse
import ctypes
import sys
import time
from ctypes import wintypes

user32 = ctypes.windll.user32

# 让本进程能看到桌面上的真实窗口
try:
    hDesk = user32.OpenDesktopW('Default', 0, False, 0x01FF)
    if hDesk:
        user32.SetThreadDesktop(hDesk)
except Exception:
    pass


class RECT(ctypes.Structure):
    _fields_ = [('left', wintypes.LONG), ('top', wintypes.LONG),
                ('right', wintypes.LONG), ('bottom', wintypes.LONG)]


WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)


def enum_windows():
    out = []

    def cb(h, l):
        if not user32.IsWindowVisible(h):
            return True
        n = user32.GetWindowTextLengthW(h)
        buf = ctypes.create_unicode_buffer(n + 1) if n > 0 else ctypes.create_unicode_buffer(8)
        user32.GetWindowTextW(h, buf, len(buf))
        rc = RECT()
        user32.GetWindowRect(h, ctypes.byref(rc))
        w, hgt = rc.right - rc.left, rc.bottom - rc.top
        if w > 200 and hgt > 150:
            out.append({'hwnd': h, 'title': buf.value, 'rect': (rc.left, rc.top, w, hgt)})
        return True

    user32.EnumWindows(WNDENUMPROC(cb), 0)
    return out


def pick(windows, title_kw):
    # 优先级：标题含关键字 > 标题含 SSJJ/4399/官方 > 面积最大
    if title_kw:
        for w in windows:
            if title_kw in w['title']:
                return w
    for kw in ('4399', '官方', 'SSJJ', 'FlashAir', 'Battle'):
        for w in windows:
            if kw in w['title']:
                return w
    return max(windows, key=lambda w: w['rect'][2] * w['rect'][3]) if windows else None


def click(hwnd, rel_x=0.5, rel_y=0.5):
    child = user32.FindWindowExW(hwnd, None, 'ApolloRuntimeContentWindow', None)
    target = child if child else hwnd
    rc = RECT()
    user32.GetWindowRect(target, ctypes.byref(rc))
    w, h = rc.right - rc.left, rc.bottom - rc.top
    if w <= 0 or h <= 0:
        return False
    cx, cy = int(w * rel_x), int(h * rel_y)
    lparam = (cy << 16) | (cx & 0xFFFF)
    user32.PostMessageW(target, 0x0201, 1, lparam)      # WM_LBUTTONDOWN
    time.sleep(0.08)
    user32.PostMessageW(target, 0x0202, 0, lparam)      # WM_LBUTTONUP
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--list', action='store_true')
    ap.add_argument('--title', default=None)
    ap.add_argument('--times', type=int, default=1)
    ap.add_argument('--delay', type=float, default=1.2)
    ap.add_argument('--relx', type=float, default=0.5)
    ap.add_argument('--rely', type=float, default=0.5)
    ap.add_argument('--json', action='store_true')
    a = ap.parse_args()

    wins = enum_windows()
    if a.list:
        for w in wins:
            print(f"{w['hwnd']:>12}  {w['rect'][2]}x{w['rect'][3]:<5} {w['title'][:70]}")
        return 0

    tgt = pick(wins, a.title)
    if not tgt:
        print('NO_WINDOW')
        return 2

    hwnd = tgt['hwnd']
    user32.ShowWindow(hwnd, 9)          # SW_RESTORE
    user32.SetForegroundWindow(hwnd)
    time.sleep(0.4)

    ok = True
    for i in range(max(1, a.times)):
        ok = click(hwnd, a.relx, a.rely) and ok
        if i + 1 < a.times:
            time.sleep(a.delay)

    if a.json:
        import json
        print(json.dumps({'ok': ok, 'hwnd': hwnd, 'title': tgt['title'], 'rect': tgt['rect']}, ensure_ascii=False))
    else:
        print(f"CLICKED hwnd={hwnd} title={tgt['title']!r} rect={tgt['rect']} times={a.times}")
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
