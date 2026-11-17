# -*- coding: utf-8 -*-
"""补丁：
D1) BspStep 加 bhop 链路诊断（限频 2s/bot）：WantJump/Grounded/HasMove/step/airborne
D2) ApplyAirAcceleration 按 CS Source 引擎 AirAccelerate 公式重写：
    - wishspd = min(wishspeed, AIR_WISH_CAP)      ← CS: sv_air_max_wishspeed=30u/s 等效
    - currentspeed = dot(velocity, wishdir)
    - addspeed = wishspd - currentspeed; <=0 不加
    - accelspeed = min(addspeed, sv_airaccelerate*wishspd*dt)   ← CS 默认 10
    - 空中 strafe：wishdir 取垂直于当前速度的方向（sign 由导航意图决定左右），
      等效真人「按住 A/D + 鼠标同步转向」——CS 教学核心机制
    - 总速硬顶 AIR_MAX_SPEED（CS 无软上限但 sv_maxvelocity 存在，取合理值）
"""
import io, re

PHYS = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotPhysics.cs'
GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'

# ================= D2) ApplyAirAcceleration 重写 =================
p = io.open(PHYS, encoding='utf-8', errors='surrogatepass').read()

# 找方法完整体（花括号配对替换）
sig = 'public static Vector3 ApplyAirAcceleration'
i = p.find(sig)
assert i >= 0, 'ApplyAirAcceleration not found'
j = p.find('{', i); depth = 0; q = j
while q < len(p):
    if p[q] == '{': depth += 1
    elif p[q] == '}':
        depth -= 1
        if depth == 0: break
    q += 1
old_body = p[i:q+1]

NL = '\n'
T = '\t'
new_body = '''public static Vector3 ApplyAirAcceleration(int id, Vector3 wishDirection, float wishSpeed, float dt, bool airborne)
    {
        VerticalState s;
        if (!_vertical.TryGetValue(id, out s)) { s = new VerticalState(); _vertical[id] = s; }
        Vector3 wish = new Vector3(wishDirection.x, 0f, wishDirection.z);
        if (wish.sqrMagnitude < 0.0001f)
        {
            if (!airborne) s.HorizontalVelocity = Vector3.zero;
            return s.HorizontalVelocity;
        }
        wish.Normalize();

        // ===== CS Source 引擎 AirAccelerate 等效实现 =====
        // 源码（CGameMovement::AirAccelerate）：
        //   wishspd      = min(wishspeed, sv_air_max_wishspeed)   // 30 u/s
        //   currentspeed = velocity.dot(wishdir)
        //   addspeed     = wishspd - currentspeed                 // <=0 不加速（不减速）
        //   accelspeed   = min(addspeed, sv_airaccelerate*wishspd*frametime)  // 默认 10
        //   velocity    += accelspeed * wishdir
        // CS 身法教学核心：按 A/D + 鼠标同步转向，让 wishdir 与速度方向保持约 90°
        // （垂直）→ currentspeed≈0 → addspeed 满额 → 每 tick 全额加速侧向 →
        // 速度向量旋转， Pythagoras 合成后总速增长（bhop/kz 增速原理）。
        const float AIR_WISH_CAP = 40f;      // ≈CS 30u/s（占跑步速度 12% 比例）
        const float AIR_ACCEL = 12f;         // ≈CS sv_airaccelerate=10，bot +20% 效果明显
        const float AIR_MAX_SPEED = 1800f;   // 总速硬顶（cm/s，防失控穿飞）

        if (!airborne)
        {
            // 地面：直接用希望速度（简化地面加速，摩擦由 BSP 步进负责）
            s.HorizontalVelocity = wish * Mathf.Clamp(wishSpeed, 260f, 520f);
            return s.HorizontalVelocity;
        }

        // 空中 strafe：把 wishdir 旋到垂直于当前水平速度的方向（等效真人鼠标同步），
        // 左右侧由"导航意图在速度哪一侧"决定——AI 想左就跟左，想右就跟右。
        Vector3 hv = s.HorizontalVelocity;
        if (hv.sqrMagnitude > 2500f)   // >50cm/s 才值得 strafe
        {
            Vector3 vdir = hv.normalized;
            Vector3 perp = new Vector3(-vdir.z, 0f, vdir.x);   // 速度方向的左侧垂直向量
            float side = (Vector3.Dot(perp, wish) >= 0f) ? 1f : -1f;
            wish = perp * side;                                 // 纯侧向 → dot≈0 → 满额加速
        }

        float wishspd = Mathf.Min(AIR_WISH_CAP, wishSpeed);
        float currentspeed = Vector3.Dot(s.HorizontalVelocity, wish);
        float addspeed = wishspd - currentspeed;
        if (addspeed <= 0f) return s.HorizontalVelocity;        // 不减速（CS 语义）
        float accelspeed = Mathf.Min(addspeed, AIR_ACCEL * wishspd * dt);
        s.HorizontalVelocity += wish * accelspeed;
        if (s.HorizontalVelocity.magnitude > AIR_MAX_SPEED)
            s.HorizontalVelocity = s.HorizontalVelocity.normalized * AIR_MAX_SPEED;

        float now = Time.realtimeSinceStartup;
        float last;
        if (!_airAccelDiagTime.TryGetValue(id, out last) || now - last >= 2f)
        {
            _airAccelDiagTime[id] = now;
            Debug.Log("[OFFLINE-AIRACCEL] id=" + id + " speed="
                + s.HorizontalVelocity.magnitude.ToString("F0") + " wish=" + wish.ToString("F2"));
        }
        return s.HorizontalVelocity;
    }'''
p = p[:i] + new_body + p[q+1:]
io.open(PHYS, 'w', encoding='utf-8', errors='surrogatepass').write(p)
print('D2 done: ApplyAirAcceleration rewritten to CS formula')

# ================= D1) BspStep 链路诊断 =================
g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
if 'OFFLINE-BHOPCHAIN' in g:
    print('D1 already patched')
    raise SystemExit(0)

old = ('\t\tVector3 verticalRaw;' + '\n'
       + '\t\tOfflineBotPhysics.ApplyVertical(b.Id, walkedRaw, it.WantJump, it.WantCrouch, dt, out verticalRaw);')
new = ('\t\t// [OFFLINE-BHOPCHAIN] 链路诊断（限频）：确认 WantJump 是否到达物理层、Grounded 状态' + '\n'
       + '\t\tif (prof.Bhop && s_chainLogN < 20)' + '\n'
       + '\t\t{' + '\n'
       + '\t\t\ts_chainLogN++;' + '\n'
       + '\t\t\tUnityEngine.Debug.Log("[OFFLINE-BHOPCHAIN] id=" + b.Id + " wantJump=" + it.WantJump' + '\n'
       + '\t\t\t\t+ " grounded=" + OfflineBotPhysics.IsGrounded(b.Id)' + '\n'
       + '\t\t\t\t+ " airborne=" + airborne + " step=" + step.ToString("F4")' + '\n'
       + '\t\t\t\t+ " hasMove=" + it.HasMove + " crouch=" + it.WantCrouch);' + '\n'
       + '\t\t}' + '\n'
       + '\t\tVector3 verticalRaw;' + '\n'
       + '\t\tOfflineBotPhysics.ApplyVertical(b.Id, walkedRaw, it.WantJump, it.WantCrouch, dt, out verticalRaw);')
assert old in g, 'D1 anchor missing'
g = g.replace(old, new, 1)

# 计数器字段（放 s_moveLog 旁边，用正则定位）
m = re.search(r'(private static int s_moveLog;)', g)
assert m, 's_moveLog not found'
indent = re.match(r'[\t ]*', g[max(0, m.start()-30):m.start()]).group(0) or '\t '
g = g[:m.end()] + '\n' + indent + 'private static int s_chainLogN;' + g[m.end():]

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
print('D1 done: chain diagnostic added')
