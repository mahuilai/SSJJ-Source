# -*- coding: utf-8 -*-
"""搭建离线本地资源目录：StreamingAssets/AssetBundles/ 下放 XML 清单 + bundle 文件。"""
import hashlib
import os
import shutil

GAME = r'D:\SSJJ-4399\battle\3_64'
SA = os.path.join(GAME, 'SSJJ_BattleClient_Unity_Data', 'StreamingAssets', 'AssetBundles')
WUDUAN = r'D:\WuDuan'
MAP_BUNDLE = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Assets\StreamingAssets\AssetBundles\Windows\unitymaps\map_3043'

# tables 包候选（catalog 中 4 个，取最新的）
TABLES_CANDIDATES = [
    'c790d0cb8c1f0515838ff7f407dffa83',
    'bdf3bc79393d3a29599f3590fc31007c',
    '610a381509f56f92e2226c8955b02aad',
    'f8315a45f6b3c5a477784b4174393616',
]


def md5f(p):
    h = hashlib.md5()
    with open(p, 'rb') as f:
        for c in iter(lambda: f.read(1 << 20), b''):
            h.update(c)
    return h.hexdigest()


def main():
    os.makedirs(os.path.join(SA, 'unitymaps'), exist_ok=True)
    entries = []  # (name, md5)

    # 1) tables
    tables_src = None
    for md5dir in TABLES_CANDIDATES:
        p = os.path.join(WUDUAN, md5dir, 'data')
        if os.path.exists(p):
            tables_src = p
            break
    assert tables_src, 'tables bundle not found in WuDuan cache'
    m = md5f(tables_src)
    dst = os.path.join(SA, 'tables_%s' % m)
    shutil.copy2(tables_src, dst)
    entries.append(('tables', m))
    print('tables: %s -> %s (%d bytes)' % (os.path.basename(tables_src), dst, os.path.getsize(dst)))

    # 2) unitymaps/map_3043（自建）
    assert os.path.exists(MAP_BUNDLE), 'map_3043 bundle missing: ' + MAP_BUNDLE
    m2 = md5f(MAP_BUNDLE)
    dst2 = os.path.join(SA, 'unitymaps', 'map_3043_%s' % m2)
    shutil.copy2(MAP_BUNDLE, dst2)
    entries.append(('unitymaps/map_3043', m2))
    print('map_3043: %s (%d bytes)' % (dst2, os.path.getsize(dst2)))

    # 3) XML 清单
    xml = ['<?xml version="1.0" encoding="utf-8"?>', '<AssetBundles>']
    for name, mm in entries:
        xml.append('  <AssetBundle name="%s" md5="%s" crc="0" />' % (name, mm))
    xml.append('</AssetBundles>')
    manifest = os.path.join(SA, 'AssetBundles')
    open(manifest, 'w', encoding='utf-8').write('\n'.join(xml) + '\n')
    print('manifest written:', manifest)

    # 4) LookSceneDebug.txt（研发后门开关）
    flag = os.path.join(GAME, 'LookSceneDebug.txt')
    if not os.path.exists(flag):
        open(flag, 'w').write('offline\n')
    print('flag file:', flag)

    # 5) 预置 Preload 缓存（双保险：loader 直接命中缓存不下载）
    preload = os.path.join(os.environ['LOCALAPPDATA'], 'Wooduan', 'Preload')
    print('preload dir exists:', os.path.isdir(preload), preload)


if __name__ == '__main__':
    main()
