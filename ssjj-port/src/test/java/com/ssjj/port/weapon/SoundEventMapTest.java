package com.ssjj.port.weapon;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** ENG-03 / P1 + ENG-04 裁决：音效事件名映射（只建映射，不播放、不注册 SoundEvent）。 */
class SoundEventMapTest {

    private static SoundEventMap map;

    @BeforeAll
    static void setUp() {
        map = SoundEventMap.load();
    }

    @DisplayName("ENG-04：sounds.json 已撤销，jar 内不应再有该资源")
    @Test
    void soundsJsonRemoved() {
        assertTrue(SoundEventMap.class.getResourceAsStream("/assets/ssjjport/sounds.json") == null,
                "sounds.json 必须已从 resources 移除（占位键会造成静默无声音）");
    }

    @DisplayName("映射表自洽：8 个事件名、8 个目标键、无告警")
    @Test
    void mappingIsSelfConsistent() {
        assertTrue(map.warnings().isEmpty(), "告警: " + map.warnings());
        assertEquals(8, map.size());
        assertEquals(8, map.soundKeys().size());
        assertTrue(map.soundKeys().containsAll(map.eventNameToKey().values()));
    }

    @DisplayName("raise/reload/melee 的真实 eventName 都能解析到目标键")
    @Test
    void confirmedEventNamesResolve() {
        assertEquals("awm_legend_t_raise", map.resolve("awm_legend_t_raise").orElseThrow());
        assertEquals("awm_legend_t_reload", map.resolve("awm_legend_t_reload").orElseThrow());
        assertEquals("awm_legend_t_sec_fire", map.resolve("awm_legend_t_sec_fire").orElseThrow());
        assertEquals("awm_legend_t_fire", map.resolve("awm_legend_t_fire").orElseThrow());
    }

    @DisplayName("AnimationTimeline 里所有 SOUND 事件名都能解析（不会派发到不存在的键）")
    @Test
    void everyTimelineSoundEventResolves() {
        AnimationTimeline t = AnimationTimeline.load("state-transitions");
        for (String action : List.of("raise", "fire", "reload", "bolt", "inspect",
                "melee", "idle", "walk", "putaway")) {
            assertTrue(t.start(action, 0L), action);
            for (AnimationTimeline.EventFrame e : t.currentEventFrames()) {
                if ("SOUND".equals(e.type())) {
                    assertTrue(map.resolve(e.name()).isPresent(),
                            action + " 的 SOUND 事件 " + e.name() + " 必须有映射键");
                }
            }
        }
    }

    @DisplayName("仍未找到的 spec 事件不编造键：resolve 为空")
    @Test
    void missingEventsAreNotFabricated() {
        assertTrue(map.resolveSpecEvent("shoot_3p").isEmpty());
        assertTrue(map.resolveSpecEvent("bolt").isEmpty());
        assertTrue(map.resolveSpecEvent("inspect").isEmpty());
        assertTrue(map.resolveSpecEvent("inspect_empty").isEmpty());
        assertTrue(map.resolveSpecEvent("put_away").isEmpty());
        assertTrue(map.resolve("不存在的事件名").isEmpty());
        assertTrue(map.resolve(null).isEmpty());
        assertFalse(map.unmappedSpecEvents().isEmpty());
    }

    @DisplayName("spec.audio.events 的通用名 → 真实资产键（只映射能确认的 4 个）")
    @Test
    void specEventAliases() {
        assertEquals("awm_legend_t_raise", map.resolveSpecEvent("draw").orElseThrow());
        assertEquals("awm_legend_t_fire", map.resolveSpecEvent("shoot").orElseThrow());
        assertEquals("awm_legend_t_reload", map.resolveSpecEvent("reload_empty").orElseThrow());
        assertEquals("awm_legend_t_reload", map.resolveSpecEvent("reload_tactical").orElseThrow());
    }
}
