# -*- coding: utf-8 -*-
"""[OFFLINE-FLY2] v2 测试：定位 Unity 子窗口（UnityWndClass）+ SendInput 硬件级输入。"""
import ctypes, io, re, subprocess, time
from ctypes import wintypes

user32 = ctypes.windll.user32
LONG = ctypes.c_long
ULONG_PTR = ctypes.c_ulonglong

class MOUSEINPUT(ctypes.Structure):
    _fields_ = [('dx', LONG), ('dy', LONG), ('mouseData', wintypes.DWORD),
                ('dwFlags', wintypes.DWORD), ('time', wintypes.DWORD),
                ('dwExtraInfo', ULONG_PTR)]

class KEYBDINPUT(ctypes.Structure):
    _fields_ = [('wVk', wintypes.WORD), ('wScan', wintypes.WORD),
                ('dwFlags', wintypes.DWORD), ('time', wintypes.DWORD),
                ('dwExtraInfo', ULONG_PTR)]

class HARDWAREINPUT(ctypes.Structure):
    _fields_ = [('uMsg', wintypes.DWORD), ('wParamL', wintypes.SHORT),
                ('wParamH', wintypes.WORD)]

class _INPUTUNION(ctypes.Union):
    _fields_ = [('mi', MOUSEINPUT), ('ki', KEYBDINPUT), ('hi', HARDWAREINPUT)]

class INPUT(ctypes.Structure):
    _anonymous_ = ('u',)
    _fields_ = [('type', wintypes.DWORD), ('u', _INPUTUNION)]

def send_key(vk, down):
    inp = INPUT()
    inp.type = 1  # INPUT_KEYBOARD
    inp.ki.wVk = vk
    inp.ki.wScan = 0
    inp.ki.dwFlags = 0 if down else 2  # KEYEVENTF_KEYUP
    inp.ki.time = 0
    inp.ki.dwExtraInfo = 0
    user32.SendInput(1, ctypes.byref(inp), ctypes.sizeof(INPUT))

def tap(vk, hold=0.08):
    send_key(vk, True); time.sleep(hold); send_key(vk, False)

def hold(vk, secs):
    send_key(vk, True); time.sleep(secs); send_key(vk, False)

VK = {'F': 0x46, 'W': 0x57, 'D': 0x44, 'SPACE': 0x20}

def find_unity_windows():
    """按窗口类名找 Unity 窗口（含子窗口枚举）。"""
    hits = []
    WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)
    def enum_proc(hwnd, lparam):
        cls = ctypes.create_unicode_buffer(256)
        user32.GetClassNameW(hwnd, cls, 256)
        title = ctypes.create_unicode_buffer(256)
        user32.GetWindowTextW(hwnd, title, 256)
        cn, tn = cls.value, title.value
        if 'Unity' in cn or 'SSJJ' in tn or '生死狙击' in tn:
            hits.append((hwnd, cn, tn, user32.IsWindowVisible(hwnd)))
        return 1
    user32.EnumWindows(WNDENUMPROC(enum_proc), 0)
    return hits

LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'
def fly_logs():
    s = io.open(LOG, encoding='utf-8', errors='replace').read()
    return re.findall(r'\[OFFLINE-FLY\][^\n]*', s)

print('[test] launching...', flush=True)
subprocess.Popen(['python', 'run_game.py', '--wait', '80'],
                 cwd=r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\tools',
                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print('[test] waiting 28s...', flush=True)
time.sleep(28)

wins = find_unity_windows()
print('[test] unity-ish windows:')
for h, cn, tn, vis in wins:
    print('   hwnd=%d cls=%s title=%s vis=%s' % (h, cn, tn, vis))

# 优先可见的 Unity 类窗口，否则第一个
target = None
for h, cn, tn, vis in wins:
    if vis and ('Unity' in cn):
        target = h; break
if target is None and wins:
    target = wins[0][0]
if target is None:
    print('[test] FATAL: no window'); raise SystemExit(1)

user32.ShowWindow(target, 9)
user32.SetForegroundWindow(target)
time.sleep(1.5)
fg = user32.GetForegroundWindow()
print('[test] target hwnd=%d foreground=%d match=%s' % (target, fg, target == fg))

base = len(fly_logs())
tap(VK['F']); time.sleep(1.2)
hold(VK['W'], 3.0); time.sleep(0.4)
hold(VK['SPACE'], 2.0); time.sleep(0.4)
hold(VK['D'], 1.5); time.sleep(0.8)
tap(VK['F']); time.sleep(0.8)

logs = fly_logs()
new = logs[base:]
print('[test] new fly logs: %d' % len(new))
for l in new: print('   ', l.strip()[:135])
nonzero = [l for l in new if 'in=0/0/0' not in l and 'pos=' in l]
print('[test] RESULT:', 'MOVEMENT CONFIRMED (in!=0)' if nonzero else 'still in=0 - input not reaching Unity')
