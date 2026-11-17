# -*- coding: utf-8 -*-
"""找最新截图文件（用户上传的）。"""
import os, glob, time

cands = []
for base in [os.path.expanduser(r'~\Pictures'),
             os.path.expanduser(r'~\Pictures\Screenshots'),
             os.path.expanduser(r'~\Desktop'),
             os.path.expanduser(r'~\Downloads'),
             r'D:\逆向\SSJJ双塔惊魂\_work']:
    if not os.path.isdir(base):
        continue
    for pat in ['*.png', '*.jpg', '*.jpeg']:
        for f in glob.glob(os.path.join(base, pat)):
            try:
                mt = os.path.getmtime(f)
            except OSError:
                continue
            cands.append((mt, f, os.path.getsize(f)))

cands.sort(reverse=True)
now = time.time()
for mt, f, sz in cands[:10]:
    age_min = (now - mt) / 60
    print('%.1f 分钟前  %10d  %s' % (age_min, sz, f))
