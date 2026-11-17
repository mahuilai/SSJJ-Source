# -*- coding: utf-8 -*-
import subprocess
import time
import os
import sys

exe = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity.exe'
work_dir = r'D:\SSJJ-4399\battle\3_64'
log_file = r'D:\SSJJ-4399\battle\3_64\log\offline.log'
shot_file = r'D:\SSJJ-4399\battle\3_64\fp_auto_current.png'

if os.path.exists(shot_file):
    try:
        os.remove(shot_file)
        print("Removed old screenshot")
    except Exception as e:
        print("Could not remove old screenshot:", e)

args = [exe, '-screen-fullscreen', '0', '-screen-width', '1600', '-screen-height', '900', '-logFile', log_file]
print("Launching:", exe)
proc = subprocess.Popen(args, cwd=work_dir)
print("Spawned PID:", proc.pid)

start_time = time.time()
found_shot = False
for t in range(40):
    time.sleep(1)
    ret = proc.poll()
    if ret is not None:
        print(f"Process terminated with exit code {ret} at t={t+1}s")
        break
    
    if os.path.exists(shot_file) and os.path.getsize(shot_file) > 10000:
        print(f"Captured fresh screenshot at t={t+1}s, size={os.path.getsize(shot_file)}")
        found_shot = True
        # wait a couple seconds more so game stays running smoothly
        time.sleep(3)
        break

print("Checking offline.log status...")
if os.path.exists(log_file):
    with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    print(f"Total log lines: {len(lines)}")
    # Print lines containing OFFLINE-SHOT, OFFLINE-INIT, or errors
    for l in lines:
        if any(k in l for k in ['OFFLINE-SHOT', 'OFFLINE-FPREANCHOR', 'myPlayerEntity', 'Exception', 'Crash']):
            print("LOG:", l.strip())
else:
    print("No log file found!")

if proc.poll() is None:
    print(f"Game process {proc.pid} is running smoothly.")
