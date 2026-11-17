# -*- coding: utf-8 -*-
"""Phase 0 前置：读 PlayerLegAnimPlaybackSystem / PlayerPositionPlaybackSystem 的消费条件。"""
import io, os

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\playback_cond.txt'
buf = []

def read(f):
    for dp, dn, fn in os.walk(ROOT):
        if f in fn:
            return io.open(os.path.join(dp, f), encoding='utf-8', errors='surrogatepass').read(), os.path.join(dp, f)
    return None, None

for f in ['PlayerLegAnimPlaybackSystem.cs', 'PlayerPositionPlaybackSystem.cs',
          'PlayerTorseAnimPlaybackSystem.cs', 'PlayerVisiablePlaybackSystem.cs']:
    t, p = read(f)
    buf.append('################ %s ################' % f)
    if not t:
        buf.append('(not found)')
        buf.append('')
        continue
    buf.append('path: %s | %d 行' % (p, t.count('\n')))
    buf.append(t[:4000])
    buf.append('')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
