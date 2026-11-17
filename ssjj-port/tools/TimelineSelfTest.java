import com.ssjj.port.weapon.AnimationTimeline;
import com.ssjj.port.weapon.SoundEventMap;
import com.ssjj.port.weapon.WeaponSpec;
import com.ssjj.port.weapon.WeaponState;

import java.util.List;

/**
 * 独立运行时自检（不经 Gradle / JUnit）：用已构建的 jar + Gson 直接跑。
 * ENG-02 更新：断言已回填的<b>权威</b> ViewAnimConfig 时长与事件帧。
 *
 * 编译/运行：
 * <pre>
 * JDK="C:/Program Files/Eclipse Adoptium/jdk-21.0.11.10-hotspot"
 * JAR="D:/逆向/SSJJ双塔惊魂/ssjj-port/build/libs/ssjj-port-0.1.0.jar"
 * GSON="C:/Users/Mahuilai/.gradle/caches/modules-2/files-2.1/com.google.code.gson/gson/2.10.1/b3add478d4382b78ea20b1671390a858002feb6c/gson-2.10.1.jar"
 * "$JDK/bin/javac" -cp "$JAR;$GSON" -d &lt;out&gt; TimelineSelfTest.java
 * "$JDK/bin/java"  -cp "&lt;out&gt;;$JAR;$GSON" TimelineSelfTest
 * </pre>
 */
public class TimelineSelfTest {
    public static void main(String[] args) {
        AnimationTimeline t = AnimationTimeline.load("state-transitions");
        check(t.stateCount() == 9, "9 states loaded from JSON");

        // --- fire：权威 StateId / clip / 时长 / 无动画音效事件
        check(t.start("fire", 1000L), "start(fire)");
        check(t.currentStateId() == 15, "fire StateId==15");
        check("TORSO_ATTACK".equals(t.currentClip()), "fire clip==TORSO_ATTACK");
        check("TORSO_ATTACK_blend0".equals(t.currentAnmClip()), "fire anmClip");
        check(t.currentDurationMs() == 1199L, "fire 权威时长==1199ms (36帧*(int)33.333332)");
        check(t.isDurationAuthoritative(), "fire 时长标记为权威（不再是 .anm 代理值）");
        check(t.currentEventFrames().isEmpty(), "fire 在 ViewAnimConfig 中无 eventName -> 无音效事件帧");
        check(t.tick(1000L).isEmpty(), "no event frame at t=0");
        check(t.tick(1100L).isEmpty(), "no event frame at t=100ms");
        t.tick(2199L);
        check("bolt".equals(t.currentAction()), "fire 1199ms 后自动推进 fire->bolt");
        check(t.currentStateId() == 18, "bolt StateId==18");
        check(t.currentDurationMs() == 33L, "bolt 权威时长==33ms (1帧)");
        t.tick(2199L + 33L);
        check("idle".equals(t.currentAction()), "bolt 33ms 后自动推进 bolt->idle");
        check(t.currentStateId() == 13, "idle StateId==13");
        check(t.isLoop(), "idle is loop");

        // --- raise：eventName -> SOUND @0ms（eventFrame 属性不存在）
        check(t.start("raise", 0L), "start(raise)");
        check(t.currentStateId() == 16, "raise StateId==16");
        check(t.currentDurationMs() == 499L, "raise 权威时长==499ms");
        check(t.currentEventFrames().size() == 1, "raise 1 个 SOUND 事件帧");
        AnimationTimeline.EventFrame snd = t.tick(0L).get(0);
        check("SOUND".equals(snd.type()) && "awm_legend_t_raise".equals(snd.name()),
                "raise 事件帧 = SOUND/awm_legend_t_raise");
        check(snd.atMs() == 0L, "eventFrame 缺失 -> EventTime=0（动画起点）");
        check(t.tick(1L).isEmpty(), "事件帧不重复触发");
        check(t.currentTransitions().get(0).to().equals("idle"), "raise -> idle (16->13)");

        // --- reload：权威 2533ms + reload 事件名
        check(t.start("reload", 0L), "start(reload)");
        check(t.currentStateId() == 17, "reload StateId==17");
        check(t.currentDurationMs() == 2533L, "reload 权威时长==2533ms");
        check(t.currentTransitions().get(0).to().equals("bolt"), "reload -> bolt (17->18)");
        check("awm_legend_t_reload".equals(t.currentEventFrames().get(0).name()),
                "reload 事件名 awm_legend_t_reload");

        // --- bolt / inspect
        check(t.start("bolt", 0L), "start(bolt)");
        check(t.currentDurationMs() == 33L, "bolt 权威时长==33ms");
        check(t.start("inspect", 0L), "start(inspect)");
        check(t.currentStateId() == 44, "inspect StateId==44");
        check(t.currentDurationMs() == 3366L, "inspect 权威时长==3366ms");
        check(t.currentEventFrames().isEmpty(), "inspect 无 eventName -> 无音效事件帧");

        // --- melee：1 SOUND + 5 MELEE_DELAY，按 atMs 升序、只触发一次
        check(t.start("melee", 0L), "start(melee)");
        check(t.currentStateId() == 20, "melee StateId==20");
        check(t.currentDurationMs() == 1166L, "melee 权威时长==1166ms");
        check(t.currentEventFrames().size() == 6, "melee = 1 SOUND + 5 MELEE_DELAY");
        check("awm_legend_t_sec_fire".equals(t.currentEventFrames().get(0).name()),
                "melee 音效事件名 awm_legend_t_sec_fire");
        List<AnimationTimeline.EventFrame> e0 = t.tick(0L);
        check(e0.size() == 1 && "SOUND".equals(e0.get(0).type()), "atMs=0 触发 SOUND");
        List<AnimationTimeline.EventFrame> e1 = t.tick(270L);
        check(e1.size() == 2, "2 个 MELEE_DELAY 在 270ms");
        check(e1.get(0).atMs() == 270L && "MELEE_DELAY".equals(e1.get(0).type()),
                "frame type MELEE_DELAY");
        List<AnimationTimeline.EventFrame> e2 = t.tick(300L);
        check(e2.size() == 1 && e2.get(0).atMs() == 300L, "1 帧在 300ms");
        List<AnimationTimeline.EventFrame> e3 = t.tick(600L);
        check(e3.size() == 2, "2 帧在 360/600ms");
        check(t.tick(601L).isEmpty(), "事件帧不重复触发");

        // --- putaway：确认不存在，不凭空推进
        check(t.start("putaway", 0L), "start(putaway)");
        check(t.currentStateId() == -1, "putaway StateId 确认不存在 -> -1");
        check("确认不存在".equals(t.currentClip()), "putaway clip 确认不存在");
        check(t.currentDurationMs() == -1L, "putaway 时长未知");
        check(t.currentTransitions().isEmpty(), "putaway 无转移");
        check(!t.advance(9999L), "putaway 不可凭空推进");
        t.tick(9999L);
        check("putaway".equals(t.currentAction()), "未知时长不自动推进");

        // --- 权威值与 ENG-01 代理值必须不同（防止回退）
        t.start("fire", 0L);
        check(t.currentDurationMs() != 1166L, "fire 不再用 1166.7ms 的 .anm 代理值");
        t.start("reload", 0L);
        check(t.currentDurationMs() != 2500L, "reload 不再用 2500ms 的 .anm 代理值");
        t.start("inspect", 0L);
        check(t.currentDurationMs() != 3333L, "inspect 不再用 3333.3ms 的 .anm 代理值");

        // ================= ENG-03 / P0：唯一时钟 =================
        AnimationTimeline ct = AnimationTimeline.load("state-transitions");
        WeaponSpec cs = WeaponSpec.load("awm_legend_t");
        WeaponState cw = new WeaponState(cs, ct, 0L);
        check(cw.hasTimeline(), "ENG-03 三参构造绑定唯一时钟");
        check(cw.phase() == WeaponState.Phase.RAISING, "构造后相位 RAISING（由 start(raise) 回调设定）");
        check(cw.nextAttackMs() == 499L, "raise 权威 499ms 设定 NextAttackTimer");
        check(!cw.tryFire(498L), "抬枪未结束不可开火");
        ct.tick(499L);
        check(cw.phase() == WeaponState.Phase.READY, "唯一时钟推进 raise->idle 后相位 READY");
        check("idle".equals(ct.currentAction()), "相位由 AnimationTimeline 驱动，无第二个时钟");

        // ★ fire→bolt→idle 与 1200ms 射速约束不冲突
        long interval = cs.fireIntervalMs();
        long fireDur = ct.durationOf("fire");
        long boltDur = ct.durationOf("bolt");
        check(interval == 1200L && fireDur == 1199L && boltDur == 33L,
                "射速 1200ms / fire 1199ms / bolt 33ms（权威值）");
        check(fireDur <= interval, "fire 动画本身在射击间隔内完成");
        check(fireDur + boltDur > interval,
                "fire+bolt=1232ms 长于 1200ms，故必须计时器门控而非动画相位门控");
        long shot1 = 499L;
        check(cw.tryFire(shot1), "第一发开火成功");
        check(cw.nextAttackMs() == shot1 + interval, "SetGunAttackTimer = shot + 1200ms");
        ct.tick(shot1 + fireDur - 1);
        check(cw.phase() == WeaponState.Phase.FIRING, "旧的 1166.7ms 代理值不能推进相位");
        ct.tick(shot1 + fireDur);
        check(cw.phase() == WeaponState.Phase.BOLTING, "fire 1199ms 到点 -> BOLTING");
        check("bolt".equals(ct.currentAction()), "bolt 仍在播放");
        long shot2 = shot1 + interval;   // 1699ms，落在 [1199,1232) 的 bolt 窗口内
        check(shot2 < shot1 + fireDur + boltDur, "第二发落在 fire+bolt 序列结束之前");
        check(cw.tryFire(shot2), "★ 1200ms 射速不被 1232ms 动画时间轴阻塞");
        check("fire".equals(ct.currentAction()), "新的一发覆盖仍在播放的 bolt");
        check(!cw.tryFire(shot2 + interval - 1), "未满 1200ms 不得连发");
        check(cw.tryFire(shot2 + interval), "满 1200ms 可再次开火");

        // 换弹补弹由唯一时钟到达 idle 时完成
        AnimationTimeline rt = AnimationTimeline.load("state-transitions");
        WeaponState rw = new WeaponState(cs, rt, 0L);
        rt.tick(499L);
        check(rw.tryFire(499L), "换弹测试：先打一发");
        check(rw.clip() == 14, "弹匣 15 -> 14");
        rt.tick(499L + 1199L);
        rt.tick(499L + 1199L + 33L);
        check(rw.phase() == WeaponState.Phase.READY, "fire->bolt->idle 回到 READY");
        check(rw.tryReload(499L + 1199L + 33L), "开始换弹");
        check(rw.clip() == 14, "换弹开始处不补弹");
        rt.tick(499L + 1199L + 33L + 2533L);
        check(rw.clip() == 14, "reload->bolt 阶段不补弹");
        rt.tick(499L + 1199L + 33L + 2533L + 33L);
        check(rw.phase() == WeaponState.Phase.READY && rw.clip() == 15 && rw.carry() == 29,
                "bolt->idle 到达即补弹（2533+33=2566ms）");

        // putaway 骨架
        check(rt.start("putaway", 99999L), "start(putaway)");
        check(rw.phase() == WeaponState.Phase.PUTAWAY, "putaway 保留为移植侧骨架相位");
        rt.tick(999999L);
        check(rw.phase() == WeaponState.Phase.PUTAWAY, "putaway 不自动推进");

        // ============ ENG-03 / P1 + ENG-04：音效映射（无 sounds.json） ============
        SoundEventMap sm = SoundEventMap.load();
        check(sm.warnings().isEmpty(), "映射表自洽，无告警（sounds.json 已撤销）");
        check(sm.size() == 8, "8 个音效映射目标键");
        check(sm.resolve("awm_legend_t_raise").isPresent()
                && sm.resolve("awm_legend_t_reload").isPresent()
                && sm.resolve("awm_legend_t_sec_fire").isPresent(),
                "raise/reload/melee 的真实 eventName 都能解析到目标键");
        check(sm.resolveSpecEvent("bolt").isEmpty()
                && sm.resolveSpecEvent("shoot_3p").isEmpty()
                && sm.resolveSpecEvent("inspect").isEmpty(),
                "bolt/shoot_3p/inspect 仍为未找到，不编造键");
        check(sm.resolve("awm_legend_t_fire").isPresent(),
                "shoot 来自开火命令链，目标键已对齐");

        System.out.println("ALL TIMELINE SELF-TESTS PASSED");
    }

    private static void check(boolean cond, String msg) {
        if (!cond) throw new AssertionError("FAIL: " + msg);
        System.out.println("PASS: " + msg);
    }
}
