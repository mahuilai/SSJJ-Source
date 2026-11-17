using System;
using Assets.Sources.Components.Interface;
using Assets.Sources.Snapshots;
using NetData;
using UnityEngine;
using physics.trace;

/// <summary>
/// 离线机器人共用的 BSP 查询。渲染坐标保持厘米 (-Y,Z,X)，绝不除以 100。
/// 原版 BoundBoxConfig：半宽 45、高 170；不能用 Unity Collider 替代 BSP 移动检测。
/// </summary>
public static class OfflineBotPhysics
{
    public const float Radius = 45f;
    public const float Height = 170f;
    private static readonly Trace Result = new Trace();
    private static readonly float[] Start = new float[3], End = new float[3];
    private static readonly float[] Min = new float[3], Max = new float[3];
    private static bool _traceWarning;
    private sealed class VerticalState
    {
        public float Velocity;
        public bool Grounded = true;
    }
    private sealed class AirVelocityState
    {
        public Vector3 HorizontalVelocity;
        public bool AirStrafeActive;
        public float AirStrafeSign = 1f;
        public int AirStrafeStep;
        public float NextAirStrafeTime;
    }
    private static readonly System.Collections.Generic.Dictionary<int, VerticalState> _vertical =
        new System.Collections.Generic.Dictionary<int, VerticalState>();
    private static readonly System.Collections.Generic.Dictionary<int, AirVelocityState> _airVelocity =
        new System.Collections.Generic.Dictionary<int, AirVelocityState>();
    // 跳/蹲诊断按 bot 独立限频，避免每帧刷屏，同时能确认意图确实进入物理层。
    private static readonly System.Collections.Generic.Dictionary<int, float> _jumpDiagTime =
        new System.Collections.Generic.Dictionary<int, float>();
    private static readonly System.Collections.Generic.Dictionary<int, float> _duckDiagTime =
        new System.Collections.Generic.Dictionary<int, float>();
    private static readonly System.Collections.Generic.Dictionary<int, float> _airAccelDiagTime =
        new System.Collections.Generic.Dictionary<int, float>();

    public static Vector3 Position(PlayerEntityData data)
    {
        return new Vector3(-data.Y, data.Z, data.X);
    }

    public static void SetPosition(PlayerEntityData data, Vector3 position)
    {
        data.X = position.z;
        data.Y = -position.x;
        data.Z = position.y;
    }

    // 主线程串行使用共用 Trace/数组，避免每帧为每个 bot 分配临时对象。
    public static bool Cast(Vector3 from, Vector3 to, float radius, float height,
        out Vector3 end, out Vector3 normal, out float fraction)
    {
        end = from;
        normal = Vector3.zero;
        fraction = 0f;
        var room = Contexts.sharedInstance.battleRoom;
        if (!room.hasPyEngine || room.pyEngine.PyEngine == null) return false;
        Start[0] = from.z; Start[1] = -from.x; Start[2] = from.y;
        End[0] = to.z; End[1] = -to.x; End[2] = to.y;
        Min[0] = Min[1] = -radius; Min[2] = 0f;
        Max[0] = Max[1] = radius; Max[2] = height;
        try
        {
            Result.Reset();
            room.pyEngine.PyEngine.GetWorld().WorldTrace(Result, Start, End, Min, Max, 33619977);
            if (Result.allsolid || Result.startsolid) return false;
            fraction = Result.fraction;
            end = Vector3.Lerp(from, to, fraction);
            normal = new Vector3(-Result.plane.normal[1], Result.plane.normal[2], Result.plane.normal[0]);
            return true;
        }
        catch (Exception ex)
        {
            if (!_traceWarning)
            {
                _traceWarning = true;
                Debug.LogWarning("[OFFLINE-AI] BSP trace unavailable; bots stop safely: " + ex.Message);
            }
            return false;
        }
    }

    // [OFFLINE-LOS] 诊断计数器（限频，避免刷屏）
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
    }

    /// <summary>先扫身体，再试台阶，最后下探地面；拒绝深坑及陡坡。</summary>
    public static bool TryWalk(Vector3 from, Vector3 destination, out Vector3 result)
    {
        result = from;
        Vector3 end, normal; float fraction;
        Vector3 baseStart = from + Vector3.up * 2f;
        Vector3 desired = new Vector3(destination.x, baseStart.y, destination.z);
        if (!Cast(baseStart, desired, Radius, Height, out end, out normal, out fraction)) return false;
        if (fraction < 0.999f)
        {
            Vector3 raised; float upFraction;
            if (!Cast(baseStart, baseStart + Vector3.up * 45f, Radius, Height,
                out raised, out normal, out upFraction) || upFraction < 0.999f) return false;
            if (!Cast(raised, desired + Vector3.up * 45f, Radius, Height,
                out end, out normal, out fraction) || fraction < 0.999f) return false;
        }
        Vector3 ground;
        if (!Cast(end, end - Vector3.up * 180f, Radius, Height,
            out ground, out normal, out fraction) || fraction >= 0.999f || normal.y < 0.65f) return false;
        result = ground + Vector3.up;
        return true;
    }

    public static bool IsAirborne(int id)
    {
        VerticalState s;
        return _vertical.TryGetValue(id, out s) && !s.Grounded;
    }

    public static bool IsGrounded(int id)
    {
        VerticalState s;
        return _vertical.TryGetValue(id, out s) && s.Grounded;
    }

    public static bool HasVerticalState(int id)
    {
        return _vertical.ContainsKey(id);
    }

    public static float VerticalVelocity(int id)
    {
        VerticalState s;
        return _vertical.TryGetValue(id, out s) ? s.Velocity : 0f;
    }

    public static void ResetVertical(int id, bool resetAirAcceleration = true)
    {
        _vertical.Remove(id);
        _jumpDiagTime.Remove(id);
        _duckDiagTime.Remove(id);
        if (resetAirAcceleration)
        {
            _airVelocity.Remove(id);
            _airAccelDiagTime.Remove(id);
        }
    }

    /// <summary>
    /// Bot-only 空中加速。只接收 AI 已经合成的八方向 wishDirection，最终位移仍由
    /// OfflineGameplay 的 BSP Cast 执行，不接入 Vape 的玩家输入或封包钩子。
    /// 速度单位为厘米/秒。
    /// </summary>
    public static Vector3 ApplyAirAcceleration(int id, Vector3 wishDirection, float wishSpeed, float dt, bool airborne)
    {
        AirVelocityState s;
        if (!_airVelocity.TryGetValue(id, out s)) { s = new AirVelocityState(); _airVelocity[id] = s; }
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
            s.AirStrafeActive = false;
            s.AirStrafeStep = 0;
            s.NextAirStrafeTime = 0f;
            return s.HorizontalVelocity;
        }

        // 空中 strafe：把 wishdir 旋到垂直于当前水平速度的方向（等效真人鼠标同步），
        // 左右侧由"导航意图在速度哪一侧"决定——AI 想左就跟左，想右就跟右。
        Vector3 hv = s.HorizontalVelocity;
        if (hv.sqrMagnitude > 2500f)   // >50cm/s 才值得 strafe
        {
            Vector3 vdir = hv.normalized;
            Vector3 perp = new Vector3(-vdir.z, 0f, vdir.x);   // 速度方向的左侧垂直向量
            if (!s.AirStrafeActive)
            {
                s.AirStrafeActive = true;
                s.AirStrafeStep = 0;
                s.AirStrafeSign = Vector3.Dot(perp, wish) >= 0f ? 1f : -1f;
                s.NextAirStrafeTime = Time.time + 0.085f;
            }
            else if (s.AirStrafeStep < 5 && Time.time >= s.NextAirStrafeTime)
            {
                s.AirStrafeStep++;
                s.AirStrafeSign = -s.AirStrafeSign;
                s.NextAirStrafeTime = Time.time + 0.085f;
            }
            wish = perp * s.AirStrafeSign;                      // 左右交替侧向加速
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
    }

    /// <summary>适配器不可用时的 BSP 垂直兜底；map12 正常使用原版 Pmove。</summary>
    public static bool ApplyVertical(int id, Vector3 position, bool jump, bool crouch, float dt,
        float jumpVelocityScale, out Vector3 result)
    {
        VerticalState s;
        if (!_vertical.TryGetValue(id, out s)) { s = new VerticalState(); _vertical[id] = s; }
        float now = Time.realtimeSinceStartup;
        if (jump && s.Grounded)
        {
            // 只在原版 Pmove 适配器不可用时使用固定厘米制近似值。
            float scale = Mathf.Clamp(jumpVelocityScale, 0.50f, 1f);
            s.Velocity = 360f * scale;
            s.Grounded = false;
            float lastJump;
            if (!_jumpDiagTime.TryGetValue(id, out lastJump) || now - lastJump >= 2f)
            {
                _jumpDiagTime[id] = now;
                Debug.Log("[OFFLINE-BHOP] id=" + id + " jump grounded=true vel=" + s.Velocity.ToString("F0")
                    + " scale=" + scale.ToString("F2"));
            }
        }
        if (crouch)
        {
            float lastDuck;
            if (!_duckDiagTime.TryGetValue(id, out lastDuck) || now - lastDuck >= 2f)
            {
                _duckDiagTime[id] = now;
                Debug.Log("[OFFLINE-DUCK] id=" + id + " crouch=true grounded=" + s.Grounded
                    + " height=120");
            }
        }
        float nextY = position.y + s.Velocity * dt;
        if (!s.Grounded && s.Velocity > 0f)
        {
            Vector3 hit, normal; float frac;
            if (Cast(position + Vector3.up * 2f, new Vector3(position.x, nextY, position.z), Radius, crouch ? 120f : Height,
                out hit, out normal, out frac)) nextY = hit.y;
        }
        if (s.Velocity <= 0f || s.Grounded)
        {
            Vector3 hit, normal; float frac;
            if (Cast(new Vector3(position.x, position.y + 2f, position.z), new Vector3(position.x, nextY - 2f, position.z),
                Radius, crouch ? 120f : Height, out hit, out normal, out frac) && frac < 0.999f && normal.y >= 0.55f)
            {
                nextY = hit.y + 1f;
                s.Velocity = 0f;
                s.Grounded = true;
            }
            else s.Grounded = false;
        }
        s.Velocity -= 980f * dt;
        result = new Vector3(position.x, nextY, position.z);
        return true;
    }

    /// <summary>圆柱连续扫描：水平圆与竖直区间同时求交，避免高速穿人和跨楼层碰撞。</summary>
    public static bool SweepBody(Vector3 from, Vector3 to, Vector3 obstacle, float ownHeight,
        out float fraction, out Vector3 normal)
    {
        Vector3 delta = to - from;
        float enter = 0f, exit = 1f;
        fraction = 1f; normal = Vector3.zero;
        float low = obstacle.y - ownHeight, high = obstacle.y + Height;
        if (Mathf.Abs(delta.y) < 0.0001f)
        {
            if (from.y <= low || from.y >= high) return false;
        }
        else
        {
            float a = (low - from.y) / delta.y, b = (high - from.y) / delta.y;
            enter = Mathf.Max(enter, Mathf.Min(a, b));
            exit = Mathf.Min(exit, Mathf.Max(a, b));
        }
        Vector3 offset = from - obstacle;
        float aa = delta.x * delta.x + delta.z * delta.z;
        float bb = offset.x * delta.x + offset.z * delta.z;
        float cc = offset.x * offset.x + offset.z * offset.z - 4f * Radius * Radius;
        if (aa < 0.0001f)
        {
            if (cc >= 0f) return false;
        }
        else
        {
            float disc = bb * bb - aa * cc;
            if (disc < 0f) return false;
            float root = Mathf.Sqrt(disc);
            enter = Mathf.Max(enter, (-bb - root) / aa);
            exit = Mathf.Min(exit, (-bb + root) / aa);
        }
        if (exit < enter || exit < 0f || enter > 1f) return false;
        Vector3 contact = from + delta * enter - obstacle;
        normal = new Vector3(contact.x, 0f, contact.z).normalized;
        if (normal.sqrMagnitude < 0.01f)
            normal = new Vector3(-delta.x, 0f, -delta.z).normalized;
        // 初始重叠时允许远离，不把玩家锁在队友体内。
        if (cc < 0f && bb >= 0f) return false;
        fraction = Mathf.Clamp01(enter);
        return true;
    }

    public static Vector3 BlockActors(ISnapshot snapshot, int actorId, Vector3 from, Vector3 to, float height)
    {
        if (snapshot == null || snapshot.PlayerEntityDataDict == null) return to;
        float earliest = 1f; Vector3 hitNormal = Vector3.zero;
        foreach (var pair in snapshot.PlayerEntityDataDict)
        {
            PlayerEntityData other = pair.Value;
            if (pair.Key == actorId || other == null || other.IsDead || other.Hp <= 0f) continue;
            float t; Vector3 normal;
            if (SweepBody(from, to, Position(other), height, out t, out normal) && t < earliest)
            {
                earliest = t; hitNormal = normal;
            }
        }
        if (earliest >= 1f) return to;
        Vector3 blocked = Vector3.Lerp(from, to, Mathf.Max(0f, earliest - 0.01f));
        // 保留竖直运动，允许跳上/越过角色；水平停在接触点。
        blocked.y = to.y;
        return blocked;
    }
}
