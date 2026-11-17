package com.ssjj.port.weapon;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * ENG-03 / P0：证明 {@link AnimationTimeline} 是<b>唯一时钟</b>，
 * {@link WeaponState} 只订阅它，且 fire→bolt→idle 时间轴与 1200ms 射速不冲突。
 */
class MergedClockTest {

    private static WeaponSpec spec() {
        return WeaponSpec.load("awm_legend_t");
    }

    /** 每个用例都拿全新的一对，避免共享 timeline 的静态状态互相干扰。 */
    private static AnimationTimeline timeline() {
        return AnimationTimeline.load("state-transitions");
    }

    @DisplayName("ENG-03：WeaponState 不再有自行计时的 tick(long)，也不再有 phaseStartMs/durationMs")
    @Test
    void noSecondClockInWeaponState() {
        assertThrows(NoSuchMethodException.class,
                () -> WeaponState.class.getMethod("tick", long.class),
                "WeaponState.tick(long) 必须删除，否则仍是并行时钟");
        for (java.lang.reflect.Field f : WeaponState.class.getDeclaredFields()) {
            assertNotEquals("phaseStartMs", f.getName(), "不应再持有相位起始时间");
        }
        for (java.lang.reflect.Method m : WeaponState.class.getDeclaredMethods()) {
            assertNotEquals("durationMs", m.getName(), "不应再从 spec clip 读时长");
            assertNotEquals("tick", m.getName(), "不应存在任何自行计时的 tick 方法");
        }
    }

    @DisplayName("唯一时钟：三参构造绑定订阅者并启动 raise，权威 499ms 设定攻击计时器")
    @Test
    void bindingAndRaise() {
        AnimationTimeline t = timeline();
        WeaponState s = new WeaponState(spec(), t, 1000L);

        assertTrue(s.hasTimeline());
        assertEquals(WeaponState.Phase.RAISING, s.phase());
        assertEquals("raise", t.currentAction());
        assertEquals(t.durationOf("raise"), 499L);
        assertEquals(1000L + 499L, s.nextAttackMs(),
                "原版 DefaultRaiseSystem.cs:17-22 用 GetViewAnimDuration(16) 设 NextAttackTimer");

        assertFalse(s.tryFire(1000L + 498L), "抬枪未结束不可开火");
        t.tick(1000L + 499L);
        assertEquals(WeaponState.Phase.READY, s.phase());
        assertEquals("idle", t.currentAction());
    }

    @DisplayName("唯一时钟：只有 timeline.tick 能推进相位；不 tick 则相位永远不动")
    @Test
    void phaseOnlyAdvancesViaTimelineTick() {
        AnimationTimeline t = timeline();
        WeaponState s = new WeaponState(spec(), t, 0L);
        t.tick(499L);                       // raise -> idle
        assertTrue(s.tryFire(499L));
        assertEquals(WeaponState.Phase.FIRING, s.phase());

        // 不调用 timeline.tick：即使外部时间过去了 10 秒，相位也不变
        assertEquals(WeaponState.Phase.FIRING, s.phase(), "WeaponState 不得自行计时");
        assertEquals("fire", t.currentAction());

        t.tick(499L + 1166L);               // 旧的 .anm 代理 1166.7ms 不应触发
        assertEquals(WeaponState.Phase.FIRING, s.phase(),
                "fire 必须按权威 1199ms 推进，不能按 spec clip 1166.7ms");
        t.tick(499L + 1199L);               // 权威到点 -> bolt
        assertEquals(WeaponState.Phase.BOLTING, s.phase());
        assertEquals("bolt", t.currentAction());
        t.tick(499L + 1199L + 33L);         // bolt 权威 33ms -> idle
        assertEquals(WeaponState.Phase.READY, s.phase());
        assertEquals("idle", t.currentAction());
    }

    @DisplayName("★ fire→bolt→idle 时间轴与 1200ms 射速约束不冲突")
    @Test
    void fireTimelineDoesNotBlockFireRate() {
        AnimationTimeline t = timeline();
        WeaponState s = new WeaponState(spec(), t, 0L);
        long interval = spec().fireIntervalMs();
        long fire = t.durationOf("fire");
        long bolt = t.durationOf("bolt");

        assertEquals(1200L, interval);
        assertEquals(1199L, fire);
        assertEquals(33L, bolt);
        assertTrue(fire <= interval, "fire 动画本身应在射击间隔内完成");
        assertTrue(fire + bolt > interval,
                "fire+bolt=1232ms 确实长于 1200ms；因此必须用计时器而非动画相位门控");

        t.tick(499L);                        // raise -> READY
        long shot1 = 499L;
        assertTrue(s.tryFire(shot1));
        assertEquals(WeaponState.Phase.FIRING, s.phase());
        assertEquals(shot1 + interval, s.nextAttackMs());

        // 推进到 fire->bolt（权威 1199ms），此时动画时间轴尚未回到 idle
        t.tick(shot1 + fire - 1);
        assertEquals(WeaponState.Phase.FIRING, s.phase());
        t.tick(shot1 + fire);
        assertEquals(WeaponState.Phase.BOLTING, s.phase());
        assertEquals("bolt", t.currentAction(), "第二发到点时 bolt 仍在播放");

        // 关键断言：在 lastShot+1200ms（= shot1+1200）时，虽然动画还在 bolt，
        // tryFire 仍必须成功（对应原版 ForceRightViewAnim 覆盖视图动画）。
        long shot2 = shot1 + interval;      // 1699ms，落在 [1199, 1232) 的 bolt 窗口内
        assertTrue(shot2 < shot1 + fire + bolt, "第二发应落在 fire+bolt 序列尚未结束的窗口内");
        assertTrue(s.tryFire(shot2), "1200ms 射速不得被 1232ms 动画时间轴阻塞");
        assertEquals(WeaponState.Phase.FIRING, s.phase());
        assertEquals("fire", t.currentAction(), "新的一发应覆盖仍在播放的 bolt");
        assertEquals(shot2 + interval, s.nextAttackMs());

        // 射速门槛仍然生效：未满 1200ms 不得连发
        assertFalse(s.tryFire(shot2 + interval - 1));
        assertTrue(s.tryFire(shot2 + interval));
    }

    @DisplayName("换弹补弹由唯一时钟到达 idle 时完成（2533+33=2566ms）")
    @Test
    void reloadRefillDrivenByTimeline() {
        AnimationTimeline t = timeline();
        WeaponState s = new WeaponState(spec(), t, 0L);
        t.tick(499L);
        assertTrue(s.tryFire(499L));         // clip 15 -> 14
        assertEquals(14, s.clip());
        t.tick(499L + 1199L);                // bolt
        t.tick(499L + 1199L + 33L);          // idle / READY

        assertTrue(s.tryReload(499L + 1199L + 33L));
        assertEquals(WeaponState.Phase.RELOADING, s.phase());
        assertTrue(s.isReloadPending());
        assertEquals(14, s.clip(), "补弹不能发生在换弹开始处");

        t.tick(499L + 1199L + 33L + 2533L - 1);
        assertEquals(14, s.clip(), "reload 2533ms 未到点不补弹");
        t.tick(499L + 1199L + 33L + 2533L);   // reload -> bolt
        assertEquals(WeaponState.Phase.BOLTING, s.phase());
        assertEquals(14, s.clip(), "bolt 阶段仍未补弹");
        t.tick(499L + 1199L + 33L + 2533L + 33L); // bolt -> idle
        assertEquals(WeaponState.Phase.READY, s.phase());
        assertEquals(15, s.clip());
        assertEquals(29, s.carry());
        assertFalse(s.isReloadPending());
    }

    @DisplayName("putaway 确认原版不存在，保留为移植侧骨架：不自动推进")
    @Test
    void putawaySkeleton() {
        AnimationTimeline t = timeline();
        WeaponState s = new WeaponState(spec(), t, 0L);
        t.tick(499L);
        assertTrue(t.start("putaway", 5000L));
        assertEquals(WeaponState.Phase.PUTAWAY, s.phase());
        t.tick(99999L);
        assertEquals(WeaponState.Phase.PUTAWAY, s.phase());
        assertFalse(s.tryFire(99999L), "收枪骨架态不可开火");
    }

    @DisplayName("降级构造（无时钟）只用于 computeSpread，tryFire/tryReload 恒 false")
    @Test
    void degradedModeHasNoClock() {
        WeaponState s = new WeaponState(spec(), 0L);
        assertFalse(s.hasTimeline());
        assertEquals(WeaponState.Phase.RAISING, s.phase());
        assertFalse(s.tryFire(100000L));
        assertFalse(s.tryReload(100000L));
        // 散布公式仍可用（ENG-02 契约不回归）
        assertEquals(0.041, s.computeSpread(90.0, 0.0, true, true, false), 1e-9);
    }

    @DisplayName("订阅回调交付权威时长与 via（explicit / transition）")
    @Test
    void listenerReceivesAuthoritativeDuration() {
        AnimationTimeline t = timeline();
        List<String> log = new ArrayList<>();
        t.setListener((action, stateId, durationMs, nowMs, via) ->
                log.add(action + "|" + stateId + "|" + durationMs + "|" + via));
        t.start("fire", 0L);
        t.tick(1199L);
        t.tick(1199L + 33L);
        assertEquals(List.of(
                "fire|15|1199|explicit",
                "bolt|18|33|transition",
                "idle|13|33|transition"), log);
    }
}
