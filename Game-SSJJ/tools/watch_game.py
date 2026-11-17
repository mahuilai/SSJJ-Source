"""监视离线客户端进程：以子进程方式启动，轮询存活，死亡时打印退出码与运行时长。

退出码速查：
  0               干净退出（Application.Quit / 正常关闭）
  0xC0000005      访问冲突（真崩溃，WER 应有 dump）
  0xC0000409      快速失败（栈溢出等 fail-fast，WER 常漏）
  0xC0000135      找不到 DLL
  -1073741819 等  同上有符号表示
"""
import os
import subprocess
import sys
import time

GAME = r"D:\SSJJ-4399\battle\3_64"
EXE = os.path.join(GAME, "SSJJ_BattleClient_Unity.exe")
LOG = os.path.join(GAME, "log", "offline.log")

max_wait = 240
if "--wait" in sys.argv:
    max_wait = int(sys.argv[sys.argv.index("--wait") + 1])

subprocess.run(["taskkill", "/f", "/im", "SSJJ_BattleClient_Unity.exe"], capture_output=True)
time.sleep(0.6)
for p in (LOG, os.path.join(GAME, "log", "error.log")):
    try:
        open(p, "w").close()
    except OSError:
        pass

args = [EXE, "-screen-fullscreen", "0", "-screen-width", "1600",
        "-screen-height", "900", "-logFile", LOG]
t0 = time.time()
p = subprocess.Popen(args, cwd=GAME,
                     creationflags=0x00000008 | 0x00000200,
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL)
print("launched pid=%d t0=%.1f" % (p.pid, t0), flush=True)

last_size = -1
while True:
    ret = p.poll()
    if ret is not None:
        dt = time.time() - t0
        print("PROCESS EXITED code=%d (0x%08X) after %.1fs" % (
            ret, ret & 0xFFFFFFFF, dt), flush=True)
        break
    if time.time() - t0 > max_wait:
        print("STILL ALIVE after %ds (watcher giving up, killing)" % max_wait, flush=True)
        p.kill()
        print("watcher-kill code=%d" % p.wait(), flush=True)
        break
    try:
        sz = os.path.getsize(LOG)
        if sz != last_size:
            print("t=%.0fs logsize=%d" % (time.time() - t0, sz), flush=True)
            last_size = sz
    except OSError:
        pass
    time.sleep(1.0)
