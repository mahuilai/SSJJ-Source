# -*- coding: utf-8 -*-
"""
[OFFLINE-LOS] 修 bot 视线检测 startsolid。

根因：CanSee 的射线起点在 bot 自己的眼睛位置，而 bot 自身也是物理实体
（PmoveStep 每帧 UpdateEntityNormalBrush(2) 注册 brush），
WorldTrace 命中自身 -> Result.startsolid -> Cast 返回 false -> CanSee 恒 false
-> AI 永远 bestId=-1 -> 不进 Combat、不开枪、不扔雷。

修法：起点沿朝向目标方向前移 60cm（离开自身 brush），
终点不变；若 60cm 内就有遮挡（贴墙），前移后那段不检查，接受这个折损。
"""
import io, sys

PH = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotPhysics.cs'
s = io.open(PH, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-LOS' in s:
    print('already patched')
    sys.exit(0)

NL = chr(10)
T = chr(9)

old = '''    public static bool CanSee(Vector3 from, Vector3 to)
    {
        Vector3 end, normal; float fraction;
        return Cast(from, to, 0f, 0f, out end, out normal, out fraction) && fraction >= 0.999f;
    }'''

new = '''    // [OFFLINE-LOS] 诊断计数器（限频，避免刷屏）
    private static float s_losLogT;
    private static int s_losOk;
    private static int s_losFail;

    public static bool CanSee(Vector3 from, Vector3 to)
    {
        // [OFFLINE-LOS] 起点前移 60cm 离开自身 brush。
        // 原实现从眼睛位置直接 trace：bot 自己有物理实体（brush），
        // WorldTrace 命中自身 -> startsolid -> Cast 返回 false -> 全员永久失明。
        Vector3 d = to - from;
        float len = d.magnitude;
        if (len < 0.01f) return true;
        Vector3 start = from + d * (60f / len);   // 60cm（raw cm 空间）
        Vector3 end, normal; float fraction;
        bool hitSomething = Cast(start, to, 0f, 0f, out end, out normal, out fraction);
        bool ok = hitSomething && fraction >= 0.999f;
        if (ok) s_losOk++; else s_losFail++;
        if (UnityEngine.Time.realtimeSinceStartup - s_losLogT > 4f)
        {
            s_losLogT = UnityEngine.Time.realtimeSinceStartup;
            UnityEngine.Debug.Log("[OFFLINE-LOS] ok=" + s_losOk + " fail=" + s_losFail
                + " sample=" + from.ToString("F0") + "->" + to.ToString("F0")
                + " hit=" + hitSomething + " frac=" + fraction.ToString("F3"));
        }
        return ok;
    }'''

assert old in s, 'CanSee anchor missing'
s = s.replace(old, new, 1)
io.open(PH, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('LOS patched')
