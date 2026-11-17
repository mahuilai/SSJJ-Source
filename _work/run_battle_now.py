import subprocess, time, os

p = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity.exe'
args = [p, '-screen-fullscreen', '0', '-screen-width', '1600', '-screen-height', '900', '-logFile', r'D:\SSJJ-4399\battle\3_64\log\offline.log']
proc = subprocess.Popen(args, cwd=r'D:\SSJJ-4399\battle\3_64')
print('Spawned Battle Client PID:', proc.pid)
# Keep checking for screenshot
cap = r'D:\SSJJ-4399\battle\3_64\fp_auto_current.png'
for i in range(25):
    time.sleep(1)
    if os.path.exists(cap):
        print(f'Screenshot found at t={i+1}s! Size={os.path.getsize(cap)}')
        break
    ret = proc.poll()
    if ret is not None:
        print(f'Process exited early with code {ret}')
        break
