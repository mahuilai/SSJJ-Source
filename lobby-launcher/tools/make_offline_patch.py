# -*- coding: utf-8 -*-
"""生成离线模式修复补丁包：只含 3 个标记文件 + 修好的 start_offline.py。

好友解压到便携包根目录（含 battle/ 和 scripts/ 的那一层）覆盖即可。
"""
import os, zipfile, shutil, hashlib
from pathlib import Path

ROOT = Path(r"D:\逆向\SSJJ双塔惊魂\lobby-launcher")
DIST = ROOT / "dist"
GAME = Path(r"D:\SSJJ-4399\battle\3_64")
OUT = DIST / "SSJJ离线补丁-修复卡0.zip"

SOURCES = {
    "battle/3_64/LookSceneDebug.txt": (GAME / "LookSceneDebug.txt", b"offline\r\n"),
    "battle/3_64/offline_flags.json": (GAME / "offline_flags.json",
                                       b'{"modules": "anim+ui", "trace": false}'),
    "battle/3_64/unity64Check.json": (GAME / "unity64Check.json", b""),
    "scripts/start_offline.py": (ROOT / "portable" / "scripts" / "start_offline.py", None),
}

README = """SSJJ 离线大厅 · 卡 0% 修复补丁
=====================================

现象
----
点「开始战斗」后，客户端窗口出现，进度条一直停在 0%，
log\\offline.log 在 "Setting up N worker threads for Enlighten" 之后就没有内容了。

原因
----
客户端判断走「离线模式」还是「在线模式」的唯一开关是游戏目录下的
    battle\\3_64\\LookSceneDebug.txt
这个文件存在 -> 挂 OfflineGameController，直接本地开局。
这个文件不存在 -> 走在线 GameController，先去连官方战服，
                 连不上就一直卡在 0%。

上一版便携包在打包时把这个文件（以及 offline_flags.json、unity64Check.json）
当成作者本机的临时状态一起排除了，所以解压出来必然缺，必然卡 0%。

怎么修
------
把本压缩包里的 battle 和 scripts 两个文件夹，直接解压覆盖到
你解压游戏的那个根目录（就是能看到 battle、scripts、ssjj-lobby.exe 的那一层）。

以你的路径为例，覆盖后应该是：
    C:\\Users\\Administrator\\Desktop\\SSJJ\\battle\\3_64\\LookSceneDebug.txt
    C:\\Users\\Administrator\\Desktop\\SSJJ\\battle\\3_64\\offline_flags.json
    C:\\Users\\Administrator\\Desktop\\SSJJ\\battle\\3_64\\unity64Check.json
    C:\\Users\\Administrator\\Desktop\\SSJJ\\scripts\\start_offline.py

手动确认（可选）
----------------
打开 battle\\3_64 目录，确认 LookSceneDebug.txt 存在，内容是一行 offline。
没有的话自己新建一个同名文本文件，写 offline 保存即可。

验证修好了没
------------
重新点「开始战斗」，看 battle\\3_64\\log\\offline.log：
  · 修好：会出现 RuntimeCheatGuard 之外的加载日志，很快进地图。
  · 没修好：仍然停在 "Setting up N worker threads for Enlighten"。

还卡的话把 log\\offline.log 和 log\\launcher.log 发回来。

以后不会再犯
------------
scripts\\start_offline.py 已经改成每次启动前自动补齐这三个文件，
就算删了也会自己建回来。
"""

def main():
    DIST.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()

    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for arc, (src, fallback) in SOURCES.items():
            if src.is_file():
                data = src.read_bytes()
                origin = str(src)
            elif fallback is not None:
                data = fallback
                origin = "fallback(内置常量)"
            else:
                raise SystemExit(f"缺少源文件：{src}")
            info = zipfile.ZipInfo(arc)
            info.external_attr = 0o644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, data)
            print(f"  + {arc:38s} {len(data):7d} B  来自 {origin}")
        info = zipfile.ZipInfo("补丁说明.txt")
        info.external_attr = 0o644 << 16
        info.compress_type = zipfile.ZIP_DEFLATED
        z.writestr(info, README.encode("utf-8"))
        print(f"  + {'补丁说明.txt':38s} {len(README.encode('utf-8')):7d} B")

    print(f"\n补丁包：{OUT}")
    print(f"体积：{OUT.stat().st_size} B ({OUT.stat().st_size/1024:.1f} KB)")
    print("md5：", hashlib.md5(OUT.read_bytes()).hexdigest())

    # 自检：重新打开验证条目
    with zipfile.ZipFile(OUT) as z:
        bad = z.testzip()
        print("完整性自检：", "OK" if bad is None else f"损坏 {bad}")
        for n in z.namelist():
            print("   ", n, z.getinfo(n).file_size)


if __name__ == "__main__":
    main()
