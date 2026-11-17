"""启动离线客户端（脱离当前 shell），可选等待并抓取日志关键行。

用法：
  python run_game.py            # 启动
  python run_game.py --wait 45  # 启动并等待 45 秒后抓关键日志
"""
import os
import subprocess
import sys
import time

GAME = r"D:\SSJJ-4399\battle\3_64"
EXE = os.path.join(GAME, "SSJJ_BattleClient_Unity.exe")
LOG = os.path.join(GAME, "log", "offline.log")
ERR = os.path.join(GAME, "log", "error.log")

DETACHED = 0x00000008 | 0x00000200  # DETACHED_PROCESS | CREATE_NEW_PROCESS_GROUP


def kill():
    subprocess.run(["taskkill", "/f", "/im", "SSJJ_BattleClient_Unity.exe"],
                   capture_output=True)


def launch():
    kill()
    time.sleep(0.6)
    for p in (LOG, ERR):
        try:
            open(p, "w").close()
        except OSError:
            pass
    args = [EXE, "-screen-fullscreen", "0", "-screen-width", "1600",
            "-screen-height", "900", "-logFile", LOG]
    p = subprocess.Popen(args, cwd=GAME, creationflags=DETACHED,
                         stdin=subprocess.DEVNULL,
                         stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL)
    print("launched pid=%d" % p.pid)
    return p


def alive():
    r = subprocess.run(
        ["tasklist", "/fi", "imagename eq SSJJ_BattleClient_Unity.exe", "/fo", "csv", "/nh"],
        capture_output=True, text=True, errors="ignore")
    return "SSJJ_BattleClient_Unity" in r.stdout


def tail_lines(path, n=40):
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.readlines()[-n:]


if __name__ == "__main__":
    wait = 45
    if "--wait" in sys.argv:
        wait = int(sys.argv[sys.argv.index("--wait") + 1])
    launch()
    time.sleep(wait)
    print("alive=%s logsize=%d" % (alive(), os.path.getsize(LOG) if os.path.exists(LOG) else -1))
    for ln in tail_lines(LOG, 200):
        if any(k in ln for k in ("OFFLINE-", "ERROR", "Exception")):
            print(ln.rstrip()[:400])
