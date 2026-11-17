# -*- coding: utf-8 -*-
"""查 UnityToRaw/RawToUnity 轴映射 + Cast 的坐标系 + VerticalState 定义。"""
import io, os, re

ROOT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\_work\axis_check.txt'
buf = []

nav = io.open(os.path.join(ROOT, 'OfflineBotNav.cs'), encoding='utf-8', errors='surrogatepass').read()

def extract(s, sig):
    i = s.find(sig)
    if i < 0: return '(not found: %s)' % sig
    j = s.find('{', i); depth = 0; p = j
    while p < len(s):
        if s[p] == '{': depth += 1
        elif s[p] == '}':
            depth -= 1
            if depth == 0: break
        p += 1
    return s[i:p+1]

buf.append('===== UnityToRaw =====')
buf.append(extract(nav, 'public static Vector3 UnityToRaw'))
buf.append('')
buf.append('===== RawToUnity =====')
buf.append(extract(nav, 'public static Vector3 RawToUnity'))
buf.append('')

phys = io.open(os.path.join(ROOT, 'OfflineBotPhysics.cs'), encoding='utf-8', errors='surrogatepass').read()
buf.append('===== VerticalState 定义 =====')
i = phys.find('class VerticalState')
buf.append(phys[i:i+400] if i > 0 else '(not found)')
buf.append('')
buf.append('===== Cast 完整体 =====')
buf.append(extract(phys, 'public static bool Cast'))
buf.append('')
buf.append('===== TryWalk 完整体 =====')
buf.append(extract(phys, 'public static bool TryWalk'))

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf))
print('written', OUT)
