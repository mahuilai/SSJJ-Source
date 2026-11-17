# -*- coding: utf-8 -*-
"""[OFFLINE-FLY2] 实机按键测试：启动游戏 -> 发 F/W/Space -> 验证 [OFFLINE-FLY] pos 变化。"""
import ctypes, io, re, subprocess, sys, time

user32 = ctypes.windll.user32
VK = {'F': 0x46, 'W': 0x57, 'S': 0x53, 'D': 0x44, 'A': 0x41, 'SPACE': 0x20, 'C': 0x43}

def tap(vk, hold=0.05):
    user32.keybd_event(vk, 0, 0, 0)
    time.sleep(hold)
    user32.keybd_event(vk, 0, 2, 0)

def hold(vk, secs):
    user32.keybd_event(vk, 0, 0, 0)
    time.sleep(secs)
    user32.keybd_event(vk, 0, 2, 0)

def find_game_hwnd():
    found = []
    cb = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)
    def proc(hwnd, lparam):
        if not user32.IsWindowVisible(hwnd):
            return 1
        n = user32.GetWindowTextLengthW(hwnd)
        if n == 0:
            return 1
        buf = ctypes.create_unicode_buffer(n + 1)
        user32.GetWindowTextW(hwnd, buf, n + 1)
        t = buf.value
        if any(k in t for k in ('SSJJ', 'Battle', '生死狙击', 'UnityLobby')):
            found.append((hwnd, t))
        return 1
    user32.EnumWindows(cb(proc), 0)
    return found

LOG = r'D:\SSJJ-4399\battle\3_64\log\offline.log'

def fly_logs():
    s = io.open(LOG, encoding='utf-8', errors='replace').read()
    return re.findall(r'\[OFFLINE-FLY\][^\n]*', s)

print('[test] launching game...', flush=True)
subprocess.Popen(['python', 'run_game.py', '--wait', '90'],
                 cwd=r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\tools',
                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

print('[test] waiting 28s for map load...', flush=True)
time.sleep(28)

wins = find_game_hwnd()
print('[test] windows:', wins[:3])
if wins:
    user32.ShowWindow(wins[0][0], 9)
    user32.SetForegroundWindow(wins[0][0])
    time.sleep(1.5)
    print('[test] focused:', wins[0][1])
else:
    print('[test] WARN: game window not found, keys go to foreground window')

base = len(fly_logs())
print('[test] base fly logs: %d' % base)

print('[test] tap F (fly on)...', flush=True)
tap(VK['F'])
time.sleep(1.5)

print('[test] hold W 3s...', flush=True)
hold(VK['W'], 3.0)
time.sleep(0.5)

print('[test] hold SPACE 2s...', flush=True)
hold(VK['SPACE'], 2.0)
time.sleep(0.5)

print('[test] tap D 1.5s...', flush=True)
hold(VK['D'], 1.5)
time.sleep(1.0)

print('[test] tap F (fly off)...', flush=True)
tap(VK['F'])
time.sleep(1.0)

logs = fly_logs()
print('[test] fly logs total: %d (new %d)' % (len(logs), len(logs) - base))
for l in logs[-8:]:
    print('   ', l.strip()[:130])
if len(logs) > base:
    print('[test] RESULT: FLY MOVEMENT CONFIRMED')
else:
    print('[test] RESULT: NO FLY LOGS - fly not executing')
