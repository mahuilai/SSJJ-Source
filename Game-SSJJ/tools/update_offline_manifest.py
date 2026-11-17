# -*- coding: utf-8 -*-
"""扩展本地清单：补 LoadTables 链所需 bundle + 重建 XML。"""
import hashlib
import os
import shutil

WUDUAN = r'D:\WuDuan'
WIN = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows'

# 逻辑名 -> 缓存 md5 目录（从 local_bundle_catalog.json 匹配结果中挑选）
PICKS = {
    'tables': 'c790d0cb8c1f0515838ff7f407dffa83',
    # OfflineGameController 默认角色/动作；与 build_full_manifest.py 保持一致。
    'player/police': 'db5deaa84e9b11f4144c356e51f6b9ab',
    'playeranim/manCT': '2e02590d41e913b0bac151b3f805edcb',
    'weapon/default': '281e5978e20e5bf1c5fa1f40383102c8',
    'sound/autosound': '7d5c124e37305dee551b96476e4d26ed',
    'sound/bgm': '520d67961860c0ae896cefa6074d3d81',
    'accessory/other': '5ab5ce817895b704352bc35a85286098',
    'weapon/colorskin': 'c8d600f2e55205661c694c6a37f614e0',
    'uiprefabs/common': '0a44a2bbdde4006491117c68ae3a852d',
    'effect/other': '0025068589e76d797b34cbd2f48de444',
}

MAP_BUNDLE = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Assets\StreamingAssets\AssetBundles\Windows\unitymaps\map_3043'


def md5f(p):
    h = hashlib.md5()
    with open(p, 'rb') as f:
        for c in iter(lambda: f.read(1 << 20), b''):
            h.update(c)
    return h.hexdigest()


def main():
    entries = []
    for name, md5dir in PICKS.items():
        src = os.path.join(WUDUAN, md5dir, 'data')
        if not os.path.exists(src):
            print('MISS', name, md5dir)
            continue
        m = md5f(src)
        # 逻辑名含 / → 保留子目录结构
        sub = name.rsplit('/', 1)[0] if '/' in name else ''
        fname = '%s_%s' % (name.rsplit('/', 1)[-1], m)
        dst_dir = os.path.join(WIN, sub) if sub else WIN
        os.makedirs(dst_dir, exist_ok=True)
        dst = os.path.join(dst_dir, fname)
        shutil.copy2(src, dst)
        entries.append((name, m))
        print('OK %-22s %8d bytes' % (name, os.path.getsize(dst)))

    # 自建地图
    m2 = md5f(MAP_BUNDLE)
    dst2 = os.path.join(WIN, 'unitymaps', 'map_3043_%s' % m2)
    os.makedirs(os.path.dirname(dst2), exist_ok=True)
    shutil.copy2(MAP_BUNDLE, dst2)
    entries.append(('unitymaps/map_3043', m2))
    print('OK %-22s %8d bytes' % ('unitymaps/map_3043', os.path.getsize(dst2)))

    xml = ['<?xml version="1.0" encoding="utf-8"?>', '<AssetBundles>']
    for name, mm in sorted(entries):
        xml.append('  <AssetBundle name="%s" md5="%s" crc="0" />' % (name, mm))
    xml.append('</AssetBundles>')
    open(os.path.join(WIN, 'AssetBundles'), 'w', encoding='utf-8').write('\n'.join(xml) + '\n')
    print('manifest entries:', len(entries))


if __name__ == '__main__':
    main()
