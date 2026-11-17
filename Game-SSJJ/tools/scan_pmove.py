# -*- coding: utf-8 -*-
"""读 PmoveStep 完整体 + DirectStep 完整体 + 玩家原版移动入口。"""
import io, os

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
gp = io.open(os.path.join(ROOT, 'OfflineGameplay.cs'), encoding='utf-8', errors='surrogatepass').read()
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\pmove_full.txt'
buf = []

def extract_by_sig(s, sig, span=6000):
    i = s.find(sig)
    if i < 0: return '(not found: %s)' % sig
    return s[i:i+span]

buf.append('################ PmoveStep ################')
buf.append(extract_by_sig(gp, 'private bool PmoveStep', 7000))
buf.append('')
buf.append('################ DirectStep ################')
buf.append(extract_by_sig(gp, 'private void DirectStep', 4000))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
