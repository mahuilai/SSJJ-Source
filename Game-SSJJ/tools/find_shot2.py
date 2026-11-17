# -*- coding: utf-8 -*-
"""全盘找 30 分钟内修改的图片（用户截图附件通常在临时目录）。"""
import os, glob, time

now = time.time()
roots = [
    os.path.expanduser(r'~\AppData\Local\Temp'),
    os.path.expanduser(r'~\AppData\Roaming'),
    os.path.expanduser(r'~\Downloads'),
    r'D:\逆向\SSJJ双塔惊魂',
    os.path.expanduser(r'~\Pictures'),
]
hits = []
for root in roots:
    if not os.path.isdir(root):
        continue
    for dirpath, dirnames, filenames in os.walk(root):
        # 跳过庞大无关目录
        depth = dirpath[len(root):].count(os.sep)
        if depth > 4:
            dirnames[:] = []
            continue
        for f in filenames:
            if not f.lower().endswith(('.png', '.jpg', '.jpeg')):
                continue
            p = os.path.join(dirpath, f)
            try:
                mt = os.path.getmtime(p)
                sz = os.path.getsize(p)
            except OSError:
                continue
            age = now - mt
            if age < 3600 and sz > 30000:  # 1 小时内、>30KB（截图级）
                hits.append((age, sz, p))
hits.sort()
for age, sz, p in hits[:15]:
    print('%6.1f 分钟前 %10d  %s' % (age/60, sz, p))
if not hits:
    print('1 小时内无候选图片')
