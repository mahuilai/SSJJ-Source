# -*- coding: utf-8 -*-
"""
修三处（承接 patch_five_fixes 的误判）：
 1. 回滚玩家 ThrowGrenade 单位：SSJJ 的 Eye 相机 transform 是 **厘米** 空间
    （实测 thrown from (-1041,1887,4630)），原来的 40cm / 1800cm/s / 球12cm / 重力980 是对的。
 2. EmitGrenadeExplosionEvent 统一收「Unity 米」；玩家传 g.Pos/100f。
 3. **特效不出的真因**：CollisionPoint / CollisionNormal 为 null ->
    CreateExplosion 里 VectorTypeConverter.Net2Unity(null) 抛 NPE，
    中断在 ReplaceGrenadeExplosion 通知链上，特效永远不加载。
"""
import io, sys

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
s = io.open(GP, encoding='utf-8', errors='surrogatepass').read()

# ---------- 1) 回滚单位 ----------
old1 = '''        // [OFFLINE-PGRENADE] 单位统一成米制（旧实现 Pos 用了 40 米、Vel 1800 m/s、
        // 球 scale 12 米、重力 980 —— 米和厘米混用，手雷出膛就飞出视野）。
        g.Pos = cam.transform.position + cam.transform.forward * 0.5f - cam.transform.up * 0.15f;
        g.Vel = cam.transform.forward * 18f + cam.transform.up * 3.2f;'''
new1 = '''        // [OFFLINE-PGRENADE] 注意：SSJJ 的 Eye 相机 transform 位于 **厘米** 空间
        // （实测 thrown from (-1041,1887,4630)），这里沿用厘米：40cm 出手 / 1800cm/s。
        g.Pos = cam.transform.position + cam.transform.forward * 40f - cam.transform.up * 8f;
        g.Vel = cam.transform.forward * 1800f + cam.transform.up * 320f;'''
if old1 in s:
    s = s.replace(old1, new1, 1)
    print('[1a] pos/vel rolled back to cm')
else:
    print('[1a] pos/vel pattern not found (maybe already)')

old2 = '''        ball.transform.localScale = Vector3.one * 0.12f;   // [OFFLINE-PGRENADE] 12 -> 0.12 米'''
new2 = '''        ball.transform.localScale = Vector3.one * 12f;   // [OFFLINE-PGRENADE] 厘米空间：12cm 球'''
if old2 in s:
    s = s.replace(old2, new2, 1)
    print('[1b] scale rolled back to cm')
else:
    print('[1b] scale pattern not found')

old3 = '''                g.Vel.y -= 9.8f * dt;   // [OFFLINE-PGRENADE] 980 -> 9.8（米制重力）'''
new3 = '''                g.Vel.y -= 980f * dt;   // [OFFLINE-PGRENADE] 厘米空间重力 980 cm/s^2'''
if old3 in s:
    s = s.replace(old3, new3, 1)
    print('[1c] gravity rolled back to cm')
else:
    print('[1c] gravity pattern not found')

# ---------- 2) 玩家爆炸传米制 ----------
old4 = '''            EmitGrenadeExplosionEvent(g.Pos, Snap() != null ? Snap().Self : 0, -1,
                g.Kind == 1 ? 8 : 4, 0, g.Kind == 1 ? "flashbang" : "grenade");'''
new4 = '''            // g.Pos 是相机厘米空间 -> 除 100 转米，EmitGrenadeExplosionEvent 只收米
            EmitGrenadeExplosionEvent(g.Pos / 100f, Snap() != null ? Snap().Self : 0, -1,
                g.Kind == 1 ? 8 : 4, 0, g.Kind == 1 ? "flashbang" : "grenade");'''
if old4 in s:
    s = s.replace(old4, new4, 1)
    print('[2] player emit converts cm->m')
else:
    print('[2] player emit pattern not found')

# ---------- 3) CollisionPoint / CollisionNormal ----------
old5 = '''T + 'ev.WeaponName = weaponName;' '''
# 用真实文本匹配
old5 = '''\t\tev.WeaponName = weaponName;'''
new5 = '''\t\t// [OFFLINE-SNAPSHOT-GRENADE] 必须填 CollisionPoint/CollisionNormal：
\t\t// CreateExplosion 里直接 VectorTypeConverter.Net2Unity(data.CollisionPoint)，
\t\t// 为 null 时抛 NullReferenceException，整条特效加载链中断（实测特效不出的真因）。
\t\tev.CollisionPoint = new Vector3DData { X = be.X, Y = be.Y, Z = be.Z };
\t\tev.CollisionNormal = new Vector3DData { X = 0f, Y = 0f, Z = 1f };
\t\tev.WeaponName = weaponName;'''
if old5 in s:
    s = s.replace(old5, new5, 1)
    print('[3] CollisionPoint/Normal filled')
else:
    print('[3] WeaponName anchor not found')

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('done')
