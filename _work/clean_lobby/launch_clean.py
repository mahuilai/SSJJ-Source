# -*- coding: utf-8 -*-
"""
Clean Lobby Launcher
1. Kills stale processes on port 8080 & old lobby processes.
2. Starts asset_server.py in a dedicated background subprocess.
3. Waits until http://127.0.0.1:8080/__catalog returns HTTP 200.
4. Starts D:\SSJJ\SSJJ-4399\Lobby\AirLobbyPreloader.exe.
"""
import os
import sys
import time
import socket
import urllib.request
import subprocess

ROOT = r"D:\逆向\SSJJ双塔惊魂"
LOBBY_DIR = r"D:\SSJJ\SSJJ-4399\Lobby"
EXE = os.path.join(LOBBY_DIR, "AirLobbyPreloader.exe")
ASSET_SERVER = os.path.join(ROOT, "_work", "clean_lobby", "asset_server.py")
HTTP_PORT = 8080

def kill_port(port):
    try:
        out = subprocess.run(['netstat', '-ano', '-p', 'TCP'],
                             capture_output=True, text=True, errors='replace').stdout or ''
        for ln in out.splitlines():
            parts = ln.split()
            if len(parts) >= 5 and parts[1].endswith(f':{port}') and parts[3] == 'LISTENING':
                pid = parts[4]
                print(f"[Launcher] Killing stale process on port {port} (PID: {pid})...")
                subprocess.run(['taskkill', '/f', '/pid', pid], capture_output=True)
    except Exception as e:
        print(f"[Launcher] Error killing port {port}: {e}")

def kill_existing_lobby():
    try:
        subprocess.run(['taskkill', '/f', '/im', 'AirLobbyPreloader.exe'], capture_output=True)
    except Exception:
        pass

def remove_signature_lock():
    sig = os.path.join(LOBBY_DIR, "META-INF", "signatures.xml")
    if os.path.isfile(sig):
        try:
            bak = sig + ".bak"
            if os.path.exists(bak):
                os.remove(bak)
            os.rename(sig, bak)
            print("[Launcher] 已解除 Adobe AIR 官方签名锁 (signatures.xml -> .bak)")
        except Exception as e:
            print(f"[Launcher] 解除签名锁提示: {e}")

def main():
    print("=" * 60)
    print("  4399 生死狙击 · 纯净离线大厅启动器 (方案1A 原版UI+Stage3D)")
    print("=" * 60)

    kill_existing_lobby()
    kill_port(HTTP_PORT)
    remove_signature_lock()
    time.sleep(0.5)

    print(f"[Launcher] 启动本地资源服务器: {ASSET_SERVER}...")
    server_proc = subprocess.Popen(
        [sys.executable, ASSET_SERVER],
        cwd=os.path.dirname(ASSET_SERVER),
        creationflags=subprocess.CREATE_NEW_CONSOLE
    )

    # Wait for server ready
    ready = False
    for i in range(20):
        try:
            req = urllib.request.Request("http://127.0.0.1:8080/__catalog")
            with urllib.request.urlopen(req, timeout=1.0) as resp:
                if resp.status == 200:
                    ready = True
                    break
        except Exception:
            time.sleep(0.3)

    if not ready:
        print("[Launcher] 错误: 本地资源服务器未能及时启动，请检查 8080 端口！")
        return

    print("[Launcher] 本地资源服务器就绪 (http://127.0.0.1:8080/)！")
    print(f"[Launcher] 正在拉起大厅客户端: {EXE}...")

    lobby_proc = subprocess.Popen([EXE], cwd=LOBBY_DIR)
    print("[Launcher] 大厅客户端已成功拉起！")
    print("=" * 60)
    print("提示: 客户端加载完成后，全量 21,669 件武器/角色/皮肤、背包 1~5 切换、")
    print("个人仓库、角色选择、商城及作战进图均可直接交互！")
    print("=" * 60)

if __name__ == "__main__":
    main()
