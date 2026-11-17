package com.ssjj.port.weapon;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * ENG-02：AnimationTimeline 用回填后的<b>权威</b> ViewAnimConfig 时长/事件帧调度。
 * 权威值来自 notes/viewanim-config/viewanim-config.json
 * （{@code FrameCount*33.333332f} 后 C# (int) 截断）。
 */
class AnimationTimelineTest {

    private static AnimationTimeline timeline;

    @BeforeAll
    static void setUp() {
        timeline = AnimationTimeline.load("state-transitions");
    }

    @DisplayName("9 个状态全部加载")
    @Test
    void stateCount() {
        assertEquals(9, timeline.stateCount());
    }

    @DisplayName("ENG-02 回填：8 个状态的权威 GetViewAnimDuration(StateId) 毫秒数")
    @ParameterizedTest(name = "{0}: StateId={1} dur={2}ms")
    @CsvSource({
            "raise,   16,  499",
            "fire,    15, 1199",
            "reload,  17, 2533",
            "bolt,    18,   33",
            "inspect, 44, 3366",
            "melee,   20, 1166",
            "idle,    13,   33",
            "walk,    14,  833"
    })
    void authoritativeDurations(String action, int stateId, long expectedMs) {
        assertTrue(timeline.start(action, 0L), "start " + action);
        assertEquals(stateId, timeline.currentStateId(), action + " StateId");
        assertEquals(expectedMs, timeline.currentDurationMs(), action + " 权威时长");
        assertTrue(timeline.isDurationAuthoritative(), action + " 必须标记为权威值");
    }

    @DisplayName("权威 clip 名与 StateId 常量名一致")
    @ParameterizedTest(name = "{0} -> {1}")
    @CsvSource({
            "raise,   TORSO_RAISE",
            "fire,    TORSO_ATTACK",
            "reload,  TORSO_RELOAD",
            "bolt,    TORSO_PULL_CHARGER",
            "inspect, TORSO_SHOWGUN",
            "melee,   TORSO_SECONDARY_ATTACK",
            "idle,    TORSO_STAND",
            "walk,    TORSO_WALK"
    })
    void clipNames(String action, String expectedClip) {
        timeline.start(action, 0L);
        assertEquals(expectedClip, timeline.currentClip());
        assertEquals(expectedClip, timeline.currentStateIdName());
    }

    @DisplayName("有 eventName 的状态产生 SOUND 事件帧 @0ms（eventFrame 缺失 -> EventTime=0）")
    @ParameterizedTest(name = "{0} -> {1}")
    @CsvSource({
            "raise,  awm_legend_t_raise",
            "reload, awm_legend_t_reload",
            "melee,  awm_legend_t_sec_fire"
    })
    void soundEventFrames(String action, String expectedName) {
        timeline.start(action, 0L);
        List<AnimationTimeline.EventFrame> sound = timeline.currentEventFrames().stream()
                .filter(e -> "SOUND".equals(e.type())).toList();
        assertEquals(1, sound.size(), action);
        assertEquals(expectedName, sound.get(0).name());
        assertEquals(0L, sound.get(0).atMs(), "eventFrame 属性不存在 -> EventTime=0");
        assertEquals(action, sound.get(0).action());
    }

    @DisplayName("fire/bolt/inspect 在 ViewAnimConfig 中无 eventName -> 无 SOUND 事件帧")
    @ParameterizedTest
    @CsvSource({"fire", "bolt", "inspect", "idle", "walk"})
    void noSoundEventFrames(String action) {
        timeline.start(action, 0L);
        assertTrue(timeline.currentEventFrames().stream()
                .noneMatch(e -> "SOUND".equals(e.type())), action);
    }

    @DisplayName("melee = 1 SOUND + 5 MELEE_DELAY（270/300/270/360/600）")
    @Test
    void meleeFrameChain() {
        timeline.start("melee", 0L);
        assertEquals(6, timeline.currentEventFrames().size());
        List<AnimationTimeline.EventFrame> delays = timeline.currentEventFrames().stream()
                .filter(e -> "MELEE_DELAY".equals(e.type())).toList();
        assertEquals(5, delays.size());
        assertEquals(List.of(270L, 270L, 300L, 360L, 600L),
                delays.stream().map(AnimationTimeline.EventFrame::atMs).toList(),
                "tick 按 atMs 升序派发");
    }

    @DisplayName("事件帧只触发一次，且按 atMs 越过顺序派发")
    @Test
    void eventFramesFireOnceInOrder() {
        timeline.start("melee", 0L);
        assertEquals(1, timeline.tick(0L).size(), "atMs=0 的 SOUND");
        assertEquals(0, timeline.tick(1L).size());
        assertEquals(2, timeline.tick(270L).size(), "两个 270ms 延迟帧");
        assertEquals(1, timeline.tick(300L).size());
        assertEquals(2, timeline.tick(600L).size(), "360 / 600");
        assertEquals(0, timeline.tick(601L).size(), "不重复触发");
    }

    @DisplayName("转移：fire->bolt->idle；reload->bolt；raise->idle（无 nextAnimation 覆盖，回落为权威）")
    @Test
    void transitions() {
        timeline.start("fire", 0L);
        assertEquals("bolt", timeline.currentTransitions().get(0).to());
        timeline.tick(1199L);
        assertEquals("bolt", timeline.currentAction(), "fire 1199ms 后自动推进到 bolt");
        timeline.tick(1199L + 33L);
        assertEquals("idle", timeline.currentAction(), "bolt 33ms 后自动推进到 idle");

        timeline.start("reload", 0L);
        assertEquals("bolt", timeline.currentTransitions().get(0).to());
        timeline.start("raise", 0L);
        assertEquals("idle", timeline.currentTransitions().get(0).to());
    }

    @DisplayName("putaway 确认不存在：StateId=-1、时长未知、无转移、不可凭空推进")
    @Test
    void putawayIsConfirmedAbsent() {
        assertTrue(timeline.start("putaway", 0L));
        assertEquals(-1, timeline.currentStateId());
        assertEquals(-1L, timeline.currentDurationMs());
        assertTrue(timeline.currentTransitions().isEmpty());
        assertFalse(timeline.advance(9999L));
        timeline.tick(9999L);
        assertEquals("putaway", timeline.currentAction(), "未知时长不自动推进");
    }

    @DisplayName("权威时长与 ENG-01 的 .anm 代理值不同，代码已优先取权威值")
    @Test
    void proxyNoLongerUsed() {
        timeline.start("fire", 0L);
        assertEquals(1199L, timeline.currentDurationMs());
        assertFalse(timeline.currentDurationMs() == 1166L, "不能再用 1166.7ms 的代理值");
        timeline.start("reload", 0L);
        assertEquals(2533L, timeline.currentDurationMs());
        timeline.start("inspect", 0L);
        assertEquals(3366L, timeline.currentDurationMs());
    }
}
