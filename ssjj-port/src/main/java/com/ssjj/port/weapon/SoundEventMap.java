package com.ssjj.port.weapon;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/**
 * 音效事件名 → 音频键的映射（ENG-03 / P1；ENG-04 裁决撤掉占位键）。
 *
 * <p><b>只建映射，不实现实际 .ogg 播放，也不注册任何 SoundEvent。</b>
 * ENG-04 已删除 {@code assets/ssjjport/sounds.json}：经 javap 静态核实，
 * {@code sounds.json} 的键只会进 {@code SoundManager} 内部 map，
 * {@code apply()} 仅做 {@code Registries.SOUND_EVENT.containsId} 查询，
 * 全类没有注册路径；8 个键都没有 subtitle，{@code Texts.hasTranslation(null)}
 * 返回 true 直接跳过 ERROR 分支，默认日志级别下完全静默。
 * 也就是说「保留占位键」= 有事件帧、没声音、且无任何报警，比不发更危险。
 * 本类在事件帧派发时仅提供键名供日志/后续播放使用。</p>
 *
 * <p><b>当前状态：音效未接通</b>。没有 .ogg、没有 SoundEvent 注册，
 * 只有映射表本身。</p>
 *
 * <p>数据来源：
 * <ul>
 *   <li>{@code notes/audio-events/audio-clips.json} —— UnityPy 枚举出的 9 个真实 AudioClip</li>
 *   <li>{@code notes/audio-events/audio-events.json} —— 逐事件触发规则（确认 / 未找到）</li>
 *   <li>{@code assets/ssjjport/spec/audio-event-map.json} —— 本类读取的映射表</li>
 * </ul>
 * 由 {@code tools/export_audio_events.py} + {@code tools/backfill_audio_events.py} 生成，
 * 不在 Java 里硬编码事件名。</p>
 *
 * <p><b>知识诚实</b>：只有 {@code eventNameToSoundKey} 里的 8 个键能映射。
 * {@code shoot_3p} / {@code bolt} / {@code inspect} / {@code inspect_empty} /
 * {@code put_away} 仍为「未找到」或「确认不存在」，映射表里放在
 * {@code unmappedSpecEvents}，{@link #resolve(String)} 对它们返回空——不编造键、不编帧号。</p>
 */
public final class SoundEventMap {

    private static final String MAP_PATH = "/assets/ssjjport/spec/audio-event-map.json";

    private final Map<String, String> eventNameToKey;
    private final Map<String, String> specEventToKey;
    private final Set<String> soundKeys;
    private final List<String> unmappedSpecEvents;
    private final List<String> warnings;

    private SoundEventMap(Map<String, String> eventNameToKey,
                          Map<String, String> specEventToKey,
                          Set<String> soundKeys,
                          List<String> unmappedSpecEvents,
                          List<String> warnings) {
        this.eventNameToKey = Collections.unmodifiableMap(eventNameToKey);
        this.specEventToKey = Collections.unmodifiableMap(specEventToKey);
        this.soundKeys = Collections.unmodifiableSet(soundKeys);
        this.unmappedSpecEvents = Collections.unmodifiableList(unmappedSpecEvents);
        this.warnings = Collections.unmodifiableList(warnings);
    }

    public static SoundEventMap load() {
        JsonObject map = readJson(MAP_PATH);
        List<String> warns = new ArrayList<>();

        Map<String, String> nameToKey = new LinkedHashMap<>();
        for (Map.Entry<String, JsonElement> e : map.getAsJsonObject("eventNameToSoundKey").entrySet()) {
            nameToKey.put(e.getKey(), e.getValue().getAsString());
        }
        Map<String, String> specToKey = new LinkedHashMap<>();
        if (map.has("specEventToSoundKey")) {
            for (Map.Entry<String, JsonElement> e : map.getAsJsonObject("specEventToSoundKey").entrySet()) {
                specToKey.put(e.getKey(), e.getValue().getAsString());
            }
        }

        // ENG-04：sounds.json 已撤销。键集合直接取自映射表的目标值，
        // 不再有「映射键 vs 占位键」的对齐校验（那种校验只因占位文件存在才有意义）。
        Set<String> keys = new LinkedHashSet<>(nameToKey.values());
        for (String k : keys) {
            if ("".equals(k) || k.contains(":")) {
                warns.add("映射目标键非法（应为不含命名空间的相对 id）: " + k);
            }
        }

        List<String> unmapped = new ArrayList<>();
        if (map.has("unmappedSpecEvents")) {
            for (JsonElement e : map.getAsJsonArray("unmappedSpecEvents")) {
                unmapped.add(e.getAsString());
            }
        }
        return new SoundEventMap(nameToKey, specToKey, keys, unmapped, warns);
    }

    /** 动画事件名（ViewAnimConfig 的 {@code eventName}）→ 映射键。 */
    public Optional<String> resolve(String eventName) {
        if (eventName == null) {
            return Optional.empty();
        }
        return Optional.ofNullable(eventNameToKey.get(eventName));
    }

    /** spec.audio.events 的通用事件名 → 映射键（仅能确认的 4 个）。 */
    public Optional<String> resolveSpecEvent(String specEvent) {
        return Optional.ofNullable(specEventToKey.get(specEvent));
    }

    public Set<String> soundKeys() { return soundKeys; }

    public Map<String, String> eventNameToKey() { return eventNameToKey; }

    public List<String> unmappedSpecEvents() { return unmappedSpecEvents; }

    public List<String> warnings() { return warnings; }

    public int size() { return eventNameToKey.size(); }

    private static JsonObject readJson(String path) {
        try (InputStream in = SoundEventMap.class.getResourceAsStream(path)) {
            if (in == null) {
                throw new IllegalStateException("[ssjjport] missing audio resource: " + path);
            }
            String text = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            return JsonParser.parseString(text).getAsJsonObject();
        } catch (IOException e) {
            throw new IllegalStateException("[ssjjport] cannot read " + path, e);
        }
    }
}
