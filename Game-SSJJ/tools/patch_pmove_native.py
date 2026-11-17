# -*- coding: utf-8 -*-
"""对齐原版玩家移动链（PlayerMovePredicationSystem）：
E1) GetBotPmove 改引擎单例 PyEngine.GetPmove()（原版所有玩家共用，独立实例 ground 恒 false）
E2) CameraYaw 用 ViewYaw（玩家=视线），摇杆旋转到视线系（数学等价但 cmd 记录值与玩家一致）
E3) jump 边沿化：落地帧才给跳位（真人 bhop 输入模式；持续按住=外挂式无限跳）
E4) 诊断日志补 air/jumpEdge 字段
E5) BspStep 保底路径标注（不再动逻辑）
"""
import io, re

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-PMOVE-NATIVE' in g:
    print('already patched')
    raise SystemExit(0)

# ============ E1) GetBotPmove -> 引擎单例 ============
old = '''        try
        {
            var eng = Contexts.sharedInstance.battleRoom.pyEngine.PyEngine;
            if (eng == null) return null;
            pm = new SSJJPhysics.Pmove(eng.GetEntityMove(), eng.GetWorld(), eng.GetEntityManager());
            _botPmove[id] = pm;
            UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + id + " created独立 Pmove 实例");
        }'''
new = '''        try
        {
            // [OFFLINE-PMOVE-NATIVE] 对齐原版：所有玩家（本地+远端）共用引擎单例 pmove
            // （PlayerMovePredicationSystem.cs L88: PyEngine.GetPmove()）。
            // 旧实现给每个 bot new 独立 Pmove 实例 → 实例缺少正确的世界/地面上下文 →
            // IsOnGround() 恒 false → 引擎按空中物理算（wishspeed cap 极小、vel≈76）→
            // 空中跳位持续生效 → bot 悬空爬墙（截图实况）。
            var eng = Contexts.sharedInstance.battleRoom.pyEngine.PyEngine;
            if (eng == null) return null;
            pm = eng.GetPmove();
            _botPmove[id] = pm;
            UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + id + " using engine singleton pmove");
        }'''
assert old in g, 'E1 anchor missing'
g = g.replace(old, new, 1)
print('E1 done: engine singleton pmove')

# ============ E2) CameraYaw=ViewYaw + 摇杆旋转 ============
old = '''        st.Cmd.Seq = UnityEngine.Time.frameCount;
        st.Cmd.FrameInterval = Mathf.Clamp((int)(dt * 1000f), 10, 50);
        st.Cmd.CameraYaw = (short)(it.MoveYaw * 100f);
        st.Cmd.CameraPitch = (short)(it.ViewPitch * 100f);
        bool stickMode = (it.MoveForward != 1f || it.MoveRight != 0f);
        float mf = stickMode ? Mathf.Clamp(it.MoveForward, -1f, 1f) * 100f : 100f;
        float mr = stickMode ? Mathf.Clamp(it.MoveRight, -1f, 1f) * 100f : 0f;'''
new = '''        st.Cmd.Seq = UnityEngine.Time.frameCount;
        st.Cmd.FrameInterval = Mathf.Clamp((int)(dt * 1000f), 10, 50);
        // [OFFLINE-PMOVE-NATIVE] CameraYaw/Pitch = 视线（与玩家一致：输入系统录的就是视角）。
        // AI 摇杆相对 MoveYaw 定义，旋转到视线系后给引擎——位移结果与旧写法等价，
        // 但 cmd 里记录的 CameraYaw 就是真人视角值（引擎若用它做视角相关处理也一致）。
        st.Cmd.CameraYaw = (short)(it.ViewYaw * 100f);
        st.Cmd.CameraPitch = (short)(it.ViewPitch * 100f);
        bool stickMode = (it.MoveForward != 1f || it.MoveRight != 0f);
        float mf, mr;
        if (stickMode)
        {
            float rel = (it.MoveYaw - it.ViewYaw) * Mathf.Deg2Rad;
            float inF = Mathf.Clamp(it.MoveForward, -1f, 1f) * 100f;
            float inR = Mathf.Clamp(it.MoveRight, -1f, 1f) * 100f;
            mf = inF * Mathf.Cos(rel) - inR * Mathf.Sin(rel);
            mr = inF * Mathf.Sin(rel) + inR * Mathf.Cos(rel);
        }
        else
        {
            // 寻路模式：dir 已由 MoveYaw 合成（上方 ExecuteBotMove），视线系下等效前移
            float rel = (it.MoveYaw - it.ViewYaw) * Mathf.Deg2Rad;
            mf = Mathf.Cos(rel) * 100f;
            mr = Mathf.Sin(rel) * 100f;
        }'''
assert old in g, 'E2 anchor missing'
g = g.replace(old, new, 1)
print('E2 done: CameraYaw=ViewYaw + stick rotation')

# ============ E3) jump 边沿化 ============
old = '''        int buttons = 0;
        if (mf > 0.01f) buttons |= 1;
        else if (mf < -0.01f) buttons |= 2;
        if (mr > 0.01f) buttons |= 8;
        else if (mr < -0.01f) buttons |= 4;
        if (it.WantJump) buttons |= 0x20;
        if (it.WantCrouch) buttons |= 0x80;
        st.Cmd.Buttons = buttons;'''
new = '''        int buttons = 0;
        if (mf > 0.01f) buttons |= 1;
        else if (mf < -0.01f) buttons |= 2;
        if (mr > 0.01f) buttons |= 8;
        else if (mr < -0.01f) buttons |= 4;
        // [OFFLINE-PMOVE-NATIVE] 跳位边沿化：只有落地帧给 0x20（真人 bhop 的输入模式——
        // 落地瞬间按跳；空中不按）。旧实现 WantJump 持续置位 = 外挂式按住不放，
        // 引擎在异常 ground 状态下会把 bot 一直往上推（悬空爬墙截图实况）。
        bool onGroundNow = true;
        try { onGroundNow = pe.move.PyPlayerMove.IsOnGround(); } catch (System.Exception) { }
        bool jumpEdge = it.WantJump && onGroundNow;
        if (jumpEdge) buttons |= 0x20;
        if (it.WantCrouch) buttons |= 0x80;
        st.Cmd.Buttons = buttons;
        // 边沿记忆：落地帧已跳过的 bot，离地前不再给跳位（防同帧多重跳）
        if (jumpEdge && !_botJumpLatch.Contains(b.Id)) _botJumpLatch.Add(b.Id);
        if (!onGroundNow && _botJumpLatch.Contains(b.Id)) { /* 空中保持 latch */ }
        if (onGroundNow && _botJumpLatch.Contains(b.Id) && !it.WantJump) _botJumpLatch.Remove(b.Id);'''
assert old in g, 'E3 anchor missing'
g = g.replace(old, new, 1)
print('E3 done: jump edge-triggered')

# latch 容器（放 _botPmove 声明旁）
m = re.search(r'private\s+readonly\s+System\.Collections\.Generic\.Dictionary<int, physics\.IPyMove>\s+_botPmove', g)
assert m, '_botPmove decl not found'
line_start = g.rfind('\n', 0, m.start()) + 1
indent = g[line_start:m.start()]
g = g[:m.end()] + '\n' + indent + 'private readonly System.Collections.Generic.HashSet<int> _botJumpLatch =' + '\n' + indent + '    new System.Collections.Generic.HashSet<int>();' + g[m.end():]
print('E3b done: jump latch field')

# ============ E4) 日志补字段 ============
old = '''            UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + b.Id + " mode=pmove"
                + " vel=" + velocity.ToString("F0") + " max=" + speed.ToString("F0")
                + " ground=" + pe.move.PyPlayerMove.IsOnGround()
                + " cmdF=" + st.Cmd.MoveForward.ToString("F0") + " btn=" + st.Cmd.Buttons);'''
new = '''            UnityEngine.Debug.Log("[OFFLINE-BOT-MOVE] id=" + b.Id + " mode=pmove"
                + " vel=" + velocity.ToString("F0") + " max=" + speed.ToString("F0")
                + " ground=" + pe.move.PyPlayerMove.IsOnGround()
                + " jumpEdge=" + jumpEdge
                + " cmdF=" + st.Cmd.MoveForward.ToString("F0") + " btn=" + st.Cmd.Buttons);'''
assert old in g, 'E4 anchor missing'
g = g.replace(old, new, 1)
print('E4 done: log fields')

# ============ E5) BspStep 保底标注 ============
old = '''        if (prof.Bhop)
        {
            // [OFFLINE-BHOP50] 复用 AI 的 MoveForward/MoveRight 合成方向做八向空中加速。
            // 仍走下方 BSP Cast，不能穿墙或直接瞬移。'''
new = '''        if (prof.Bhop)
        {
            // [OFFLINE-BHOP50] 保底路径专用：实体拿到 PyPlayerMove 后走 PmoveStep
            // （引擎原生 bhop：落地跳位 + 引擎空中加速），这里只在适配器创建失败时
            // 用自建近似顶上。自建八向空中加速与引擎行为不同，仅止损用。'''
assert old in g, 'E5 anchor missing'
g = g.replace(old, new, 1)
print('E5 done: fallback annotation')

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
print('all patches applied')
