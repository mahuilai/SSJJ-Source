# -*- coding: utf-8 -*-
"""Read-only window topology dump for the AIR lobby.

Lists top-level windows in z-order (top first), flags overlapping windows above
the lobby viewport, and recurses into the lobby process's child windows. This
answers the "two windows / transparent host / viewport lost" question without
touching any window style.
"""
import ctypes
import json
import os
import sys
from ctypes import wintypes

user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

try:
    hDesk = user32.OpenDesktopW('Default', 0, False, 0x01FF)
    if hDesk:
        user32.SetThreadDesktop(hDesk)
except Exception:
    pass

GW_HWNDNEXT = 2
GW_CHILD = 5
WS_EX_TOPMOST = 0x8
WS_EX_LAYERED = 0x80000


class RECT(ctypes.Structure):
    _fields_ = [('left', wintypes.LONG), ('top', wintypes.LONG),
                ('right', wintypes.LONG), ('bottom', wintypes.LONG)]


def get_text(h):
    n = user32.GetWindowTextLengthW(h)
    buf = ctypes.create_unicode_buffer(max(n + 1, 2))
    user32.GetWindowTextW(h, buf, len(buf))
    return buf.value


def get_class(h):
    buf = ctypes.create_unicode_buffer(256)
    user32.GetClassNameW(h, buf, len(buf))
    return buf.value


def rect(h):
    rc = RECT()
    user32.GetWindowRect(h, ctypes.byref(rc))
    return [rc.left, rc.top, rc.right, rc.bottom]


def pid_of(h):
    p = wintypes.DWORD()
    user32.GetWindowThreadProcessId(h, ctypes.byref(p))
    return p.value


def process_name(pid):
    try:
        import psutil
        return psutil.Process(pid).name()
    except Exception:
        return ''


def info(h):
    ex = user32.GetWindowLongW(h, -20)
    return {
        'hwnd': int(h),
        'class': get_class(h),
        'title': get_text(h),
        'pid': pid_of(h),
        'process': process_name(pid_of(h)),
        'rect': rect(h),
        'visible': bool(user32.IsWindowVisible(h)),
        'iconic': bool(user32.IsIconic(h)),
        'exstyle': int(ex & 0xffffffff),
        'topmost': bool(ex & WS_EX_TOPMOST),
        'layered': bool(ex & WS_EX_LAYERED),
    }


def intersects(a, b):
    return not (a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1])


def main():
    target_title = 'SSJJ_FlashAir_Battle16397'
    lobby = user32.FindWindowW(None, target_title)
    out = {'lobby_hwnd': int(lobby) if lobby else 0,
           'lobby': info(lobby) if lobby else None,
           'top_level': [],
           'above_overlaps': [],
           'children': []}
    print(json.dumps(out, ensure_ascii=False, indent=1))
    if not lobby:
        return 2

    # Top-level windows in z-order (EnumWindows is top-to-bottom).
    WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    tops = []
    def cb(h, _):
        tops.append(h)
        return True
    user32.EnumWindows(WNDENUMPROC(cb), 0)

    lrect = rect(lobby)
    seen_lobby = False
    for h in tops:
        rec = info(h)
        out['top_level'].append(rec)
        if h == lobby:
            seen_lobby = True
            continue
        if not seen_lobby and rec['visible'] and intersects(lrect, rec['rect']):
            out['above_overlaps'].append(rec)

    # Child windows recursively.
    def children(h, depth):
        child = user32.GetWindow(h, GW_CHILD)
        while child:
            rec = info(child)
            rec['depth'] = depth
            out['children'].append(rec)
            children(child, depth + 1)
            child = user32.GetWindow(child, GW_HWNDNEXT)
    children(lobby, 1)

    print(json.dumps(out, ensure_ascii=False, indent=1))
    return 0


if __name__ == '__main__':
    sys.exit(main())
