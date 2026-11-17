# -*- coding: utf-8 -*-
"""全量离线清单生成：前缀匹配自动定位缓存包 + XML 清单 + 复制。"""
import hashlib
import json
import os
import shutil

CATALOG = r'D:\逆向\SSJJ双塔惊魂\Game source\01_metadata\local_bundle_catalog.json'
WIN = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows'
WUDUAN = r'D:\WuDuan'
MAP_BUNDLE = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Assets\StreamingAssets\AssetBundles\Windows\unitymaps\map_3043'
WEAPONS = ['slingshot', 'usp45', 'double_deagle', 'ghost_rider', 'uav', 'ar15', 'thomson', 'gatling',
           'double_uzi', 'ak47', 'm4a1', 'rpk', 'auga3', 'saw', 'bat', 'dagger', 'gloves',
           'double_baton', 'm3', 'double_maul', 'bow', 'awp', 'grenade', 'sawed_pirate', 'botweapon']

# 逻辑名 -> 容器路径前缀（精确匹配）
PREFIX_MAP = {
    'tables': 'assets/res/assets/tables/',
    # 离线入口默认使用 police/manCT；不加入这两个包时角色实体会创建，
    # 但模型和动作资源为空，随后会在每帧刷 NRE。
    'player/police': 'assets/res/assets/player/police/',
    'playeranim/manCT': 'assets/res/assets/playeranim/manct/',
    # CareerData 从 playeranim/default 的 animConfig 读 职业->动画类型 映射（police->manCT），
    # 缺了它 _animConfig 为空，AnimBundleName 会退化成 playeranim/police 而找不到包。
    'playeranim/default': 'assets/res/assets/playeranim/animconfig.xml',
    'weapon/default': 'assets/res/assets/weapon/predicableconfig.xml',
    'sound/autosound': 'assets/res/assets/sound/autosound/',
    'sound/bgm': 'assets/res/assets/sound/bgm/',
    'accessory/other': 'assets/res/assets/accessory/accessorybigswordct/',
    'weapon/colorskin': 'assets/res/assets/weapon/colorskin/',
    'uiprefabs/common': 'assets/res/assets/uiprefabs/common/',
    'uiprefabs/weapon': 'assets/res/assets/uiprefabs/weapon/',
    'ui/common': 'assets/res/assets/ui/',
    'fonts': 'assets/res/assets/fonts/',
    'number': 'assets/res/assets/number/',
    'uimaterial': 'assets/res/assets/uimaterial/',
    'skybox': 'assets/res/assets/skybox',
    'uiconfig': 'assets/res/assets/uiconfig/',
    'sound/common': 'assets/res/assets/sound/common/',
    'sound/player': 'assets/res/assets/sound/player/',
    'effect/common': 'assets/res/assets/effect/common/',
    'effect/rpgcommon': 'assets/res/assets/effect/rpgcommon/',
    'effect/pvecommon': 'assets/res/assets/effect/pvecommon/',
    'effectprefab/hole': 'assets/res/assets/effectprefab/',
    'uiprefabs/rpg': 'assets/res/assets/uiprefabs/rpg/',
}
for w in WEAPONS:
    PREFIX_MAP['weapon/%s' % w] = 'assets/res/assets/weapon/%s/' % w


def md5f(p):
    h = hashlib.md5()
    with open(p, 'rb') as f:
        for c in iter(lambda: f.read(1 << 20), b''):
            h.update(c)
    return h.hexdigest()


def main():
    d = json.load(open(CATALOG, encoding='utf-8'))
    recs = d['records']
    entries = []
    missing = []
    for name, prefix in PREFIX_MAP.items():
        best = None
        for r in recs:
            cs = r.get('containers') or []
            hit = [c for c in cs if c.lower().startswith(prefix)]
            if hit and (best is None or len(hit) > best[0]):
                best = (len(hit), r['file'])
        if best:
            src = best[1]
            m = md5f(src)
            sub = name.rsplit('/', 1)[0] if '/' in name else ''
            fname = '%s_%s' % (name.rsplit('/', 1)[-1], m)
            dst_dir = os.path.join(WIN, sub) if sub else WIN
            os.makedirs(dst_dir, exist_ok=True)
            dst = os.path.join(dst_dir, fname)
            shutil.copy2(src, dst)
            entries.append((name, m))
            print('OK   %-26s %9d B  (%d matched)' % (name, os.path.getsize(dst), best[0]))
        else:
            missing.append(name)
            print('MISS %-26s (no candidate)' % name)

    # 自建地图
    m2 = md5f(MAP_BUNDLE)
    dst2 = os.path.join(WIN, 'unitymaps', 'map_3043_%s' % m2)
    os.makedirs(os.path.dirname(dst2), exist_ok=True)
    shutil.copy2(MAP_BUNDLE, dst2)
    entries.append(('unitymaps/map_3043', m2))
    print('OK   %-26s %9d B' % ('unitymaps/map_3043', os.path.getsize(dst2)))

    xml = ['<?xml version="1.0" encoding="utf-8"?>', '<AssetBundles>']
    for name, mm in sorted(entries):
        xml.append('  <AssetBundle name="%s" md5="%s" crc="0" />' % (name, mm))
    xml.append('</AssetBundles>')
    open(os.path.join(WIN, 'AssetBundles'), 'w', encoding='utf-8').write('\n'.join(xml) + '\n')
    print('\nmanifest entries: %d   missing: %s' % (len(entries), missing))


if __name__ == '__main__':
    main()
