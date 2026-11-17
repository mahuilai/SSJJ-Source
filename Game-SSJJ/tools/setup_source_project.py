import os
import shutil

SRC_PROJ = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ'
DST_PROJ = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source'
CS_SRC = r'D:\逆向\SSJJ双塔惊魂\Game source\02_managed_src\Assembly-CSharp'
DLL_SRC = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed'

os.makedirs(DST_PROJ, exist_ok=True)
for d in ('ProjectSettings', 'Packages'):
    s = os.path.join(SRC_PROJ, d)
    t = os.path.join(DST_PROJ, d)
    if os.path.isdir(s) and not os.path.isdir(t):
        shutil.copytree(s, t)
        print('copied', d)

cs_dst = os.path.join(DST_PROJ, 'Assets', 'Decompiled')
os.makedirs(cs_dst, exist_ok=True)
count = 0
for r, sub, files in os.walk(CS_SRC):
    for f in files:
        if not f.endswith('.cs'):
            continue
        rel = os.path.relpath(os.path.join(r, f), CS_SRC)
        dst = os.path.join(cs_dst, rel)
        if os.path.exists(dst):
            continue
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(os.path.join(r, f), dst)
        count += 1
print('cs copied', count)

dll_dst = os.path.join(DST_PROJ, 'Assets', 'Plugins', 'GameManaged')
os.makedirs(dll_dst, exist_ok=True)
skip = ('UnityEngine', 'System.', 'mscorlib', 'Mono.', 'Accessibility', 'Microsoft.',
        'System.Core', 'System.dll', 'netstandard', 'Windows.')
n = 0
for f in os.listdir(DLL_SRC):
    if not f.lower().endswith('.dll') or f.startswith(skip):
        continue
    if f in ('Assembly-CSharp.dll', 'Magic.dll'):
        continue
    dst = os.path.join(dll_dst, f)
    if not os.path.exists(dst):
        shutil.copy2(os.path.join(DLL_SRC, f), dst)
        n += 1
print('dll copied', n)
print('total cs', sum(len(fs) for _, _, fs in os.walk(cs_dst)))
