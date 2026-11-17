package com.ssjj.port.weapon;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 动画时间轴（阶段 3）—— 原版 {@code ViewAnimSystem} + {@code WeaponNoticePlayBackSystem}
 * 语义的最小可运行移植。
 *
 * <p>数据全部来自 {@code assets/ssjjport/spec/state-transitions.json}（阶段 1 产物），
 * 不在代码里写死任何 StateId、clip 名、时长或事件帧号。</p>
 *
 * <p><b>音效/事件走事件帧，不用定时器</b>：本类没有 {@code Timer}、没有
 * {@code ScheduledExecutorService}、没有 {@code Thread.sleep}。调用方在每个客户端 tick
 * 传一个单调递增的时间进来，{@link #tick(long)} 计算 elapsed 并把
 * {@code atMs <= elapsed} 且尚未触发过的事件帧一次性派发出去——对应原版
 * {@code WeaponNoticePlayBackSystem.ProcessNotice} 里 {@code currentTime > ViewAnimEventTime} 的判断。</p>
 *
 * <p><b>ENG-02 权威回填</b>：{@code state-transitions.json} 的
 * {@code runtimeDurationMs} 现取自导出的 {@code ViewAnimConfig}
 * （{@code notes/viewanim-config/}，{@code GetViewAnimDuration(StateId)}），
 * 优先于 {@code specClipLengthMs}（{@code ak47.anm} 骨骼 clip 代理值）。
 * {@link #isDurationAuthoritative()} 为 true 表示用的是权威值。
 * bolt(18) 现有权威 33ms，会按 duration 自动推进；
 * <b>仅</b>仍标「确认不存在 / 未找到」的状态（putaway）不自动推进。</p>
 *
 * <p><b>ENG-03：本类是工程的唯一动画时钟，两个并行时钟已合并。</b>
 * {@link WeaponState} 不再用 {@code spec.animation.clips[].lengthS} 自行计时推进相位，
 * 而是通过 {@link #setListener(StateListener)} 订阅本类的
 * {@code onStateEntered(action, stateId, durationMs, nowMs, via)}，由本类的
 * 权威时长驱动相位与换弹补弹。调用方每个客户端 tick 只调一次 {@link #tick(long)}，
 * 它同时完成：事件帧派发、时长到点后的自动转移、订阅者通知。</p>
 *
 * <p><b>1200ms 射速与 fire→bolt→idle 时间轴不冲突</b>：fire 权威 1199ms、
 * bolt 33ms（合计 1232ms &gt; 1200ms 射击间隔）。原版
 * {@code AbstractFireAction.CanFireTimeCondition} 只判
 * {@code ClientTime > NextAttackTimer}，并不判视图动画相位；
 * 下一发到点时用 {@code start("fire", now)} 覆盖仍在播放的 bolt
 * （对应原版 {@code ForceRightViewAnim(player, 15)}）。
 * 因此 {@link WeaponState#tryFire(long)} 用攻击计时器门控而非相位门控，
 * 详见 {@code MergedClockTest} / {@code TimelineSelfTest} 的断言。</p>
 *
 * <p>本阶段只负责 clip 调度与事件帧派发，<b>不实现</b>渲染 / 模型 / HUD / 开镜 /
 * 实际音频播放 / 命中判定 / 网络同步。</p>
 */
public final class AnimationTimeline {

    /** 一个动画事件帧（音效 / 近战延迟 / 后坐 / 枪口等）。 */
    public static final class EventFrame {
        private final String action;
        private final long atMs;
        private final String type;
        private final String name;
        private final String source;

        EventFrame(String action, long atMs, String type, String name, String source) {
            this.action = action;
            this.atMs = atMs;
            this.type = type;
            this.name = name;
            this.source = source;
        }

        public String action() { return action; }
        public long atMs() { return atMs; }
        public String type() { return type; }
        public String name() { return name; }
        public String source() { return source; }

        @Override
        public String toString() {
            return "EventFrame{action=" + action + ", atMs=" + atMs + ", type=" + type
                    + ", name=" + name + ", source=" + source + '}';
        }
    }

    /** 状态转移规则。 */
    public static final class Transition {
        private final String to;
        private final String toStateId;
        private final String when;
        private final String source;

        Transition(String to, String toStateId, String when, String source) {
            this.to = to;
            this.toStateId = toStateId;
            this.when = when;
            this.source = source;
        }

        public String to() { return to; }
        public String toStateId() { return toStateId; }
        public String when() { return when; }
        public String source() { return source; }
    }

    /** 单个动作的状态定义。 */
    private static final class StateDef {
        final String action;
        final int stateId;                 // -1 = 未找到
        final String stateIdName;
        final String clip;
        final String anmClip;
        final boolean loop;
        final long durationMs;             // -1 = 未找到
        final boolean durationAuthoritative; // true 仅当 runtimeDurationMs 有值
        final List<EventFrame> events;
        final List<Transition> transitions;
        final String eventFramesNote;

        StateDef(String action, int stateId, String stateIdName, String clip, String anmClip,
                 boolean loop, long durationMs, boolean durationAuthoritative,
                 List<EventFrame> events, List<Transition> transitions, String eventFramesNote) {
            this.action = action;
            this.stateId = stateId;
            this.stateIdName = stateIdName;
            this.clip = clip;
            this.anmClip = anmClip;
            this.loop = loop;
            this.durationMs = durationMs;
            this.durationAuthoritative = durationAuthoritative;
            this.events = events;
            this.transitions = transitions;
            this.eventFramesNote = eventFramesNote;
        }
    }

    /**  unknown 状态的哨兵：时长未知时不自动推进。 */
    private static final long UNKNOWN_DURATION = -1L;

    /**
     * 状态订阅者（ENG-03）。{@link WeaponState} 实现此接口，
     * 由本类——唯一时钟——在每次进入状态时把权威时长一并交付。
     */
    public interface StateListener {
        /**
         * @param action     进入的动作（raise/fire/bolt/reload/idle/...）
         * @param stateId    原版 StateId，-1 表示确认不存在
         * @param durationMs 本类采用的权威时长（ms）；-1 表示未知/不自动推进
         * @param nowMs      进入时刻（调用方传入的单调递增时间）
         * @param via        "explicit"（外部 start）或 "transition"（时长到点自动转移）
         */
        void onStateEntered(String action, int stateId, long durationMs, long nowMs, String via);
    }

    private final Map<String, StateDef> states;

    private StateDef current;
    private long startMs;
    private boolean[] fired;
    private StateListener listener;

    private AnimationTimeline(Map<String, StateDef> states) {
        this.states = Collections.unmodifiableMap(states);
    }

    /** 注册唯一订阅者（ENG-03：WeaponState）。可被替换，便于测试注入。 */
    public void setListener(StateListener listener) {
        this.listener = listener;
    }

    public StateListener listener() {
        return listener;
    }

    /** 读取 {@code /assets/ssjjport/spec/<id>.json}。 */
    public static AnimationTimeline load(String id) {
        String path = "/assets/ssjjport/spec/" + id + ".json";
        try (InputStream in = AnimationTimeline.class.getResourceAsStream(path)) {
            if (in == null) {
                throw new IllegalStateException("[ssjjport] missing state-transitions resource: " + path);
            }
            String text = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            JsonObject root = JsonParser.parseString(text).getAsJsonObject();
            return new AnimationTimeline(parseStates(root));
        } catch (IOException e) {
            throw new IllegalStateException("[ssjjport] cannot read " + path, e);
        }
    }

    private static Map<String, StateDef> parseStates(JsonObject root) {
        JsonObject statesObj = root.getAsJsonObject("states");
        Map<String, StateDef> out = new LinkedHashMap<>();
        for (Map.Entry<String, JsonElement> entry : statesObj.entrySet()) {
            String action = entry.getKey();
            JsonObject s = entry.getValue().getAsJsonObject();

            int stateId = intOrMinusOne(s, "stateId");
            // ENG-02：优先 ViewAnimConfig 的权威 GetViewAnimDuration；
            // 仅当未回填时才退回 .anm 骨骼 clip 代理值（并标记非权威）。
            long runtimeMs = longOrMinusOne(s, "runtimeDurationMs");
            long proxyMs = longOrMinusOne(s, "specClipLengthMs");
            long duration = runtimeMs > 0 ? runtimeMs : proxyMs;
            boolean authoritative = runtimeMs > 0;

            List<EventFrame> events = new ArrayList<>();
            JsonArray arr = s.has("eventFrames") && s.get("eventFrames").isJsonArray()
                    ? s.getAsJsonArray("eventFrames") : new JsonArray();
            for (JsonElement el : arr) {
                JsonObject e = el.getAsJsonObject();
                events.add(new EventFrame(
                        action,
                        (long) numOrZero(e, "atMs"),
                        str(e, "type", "未找到"),
                        str(e, "name", "未找到"),
                        str(e, "source", "未找到")));
            }
            events.sort((a, b) -> Long.compare(a.atMs(), b.atMs()));

            List<Transition> transitions = new ArrayList<>();
            JsonArray tArr = s.has("transitions") && s.get("transitions").isJsonArray()
                    ? s.getAsJsonArray("transitions") : new JsonArray();
            for (JsonElement el : tArr) {
                JsonObject t = el.getAsJsonObject();
                transitions.add(new Transition(
                        str(t, "to", "未找到"),
                        str(t, "toStateId", "未找到"),
                        str(t, "when", "未找到"),
                        str(t, "source", "未找到")));
            }

            out.put(action, new StateDef(
                    action,
                    stateId,
                    str(s, "stateIdName", "未找到"),
                    str(s, "clip", "未找到"),
                    str(s, "anmClip", "未找到"),
                    boolOrFalse(s, "loop"),
                    duration > 0 ? duration : UNKNOWN_DURATION,
                    authoritative,
                    Collections.unmodifiableList(events),
                    Collections.unmodifiableList(transitions),
                    str(s, "eventFramesNote", "未找到")));
        }
        return out;
    }

    // ---------------------------------------------------------------- playback

    /**
     * 启动一个动作的时间轴。会重置 elapsed 与所有事件帧的 fired 标记。
     *
     * @return 该动作在表里是否存在
     */
    public boolean start(String action, long nowMs) {
        return startInternal(action, nowMs, "explicit");
    }

    private boolean startInternal(String action, long nowMs, String via) {
        StateDef def = states.get(action);
        if (def == null) {
            return false;
        }
        current = def;
        startMs = nowMs;
        fired = new boolean[def.events.size()];
        // ENG-03：唯一时钟在状态进入时同步通知订阅者，交付权威时长。
        if (listener != null) {
            listener.onStateEntered(action, def.stateId, def.durationMs, nowMs, via);
        }
        return true;
    }

    /**
     * 每个客户端 tick 调一次。
     *
     * <p>返回本次越过、且此前未触发过的事件帧（按 atMs 升序）。
     * <b>音效必须由调用方在拿到这些事件帧时播放</b>，不要在开火处起定时器。</p>
     *
     * <p>若当前状态时长已知且已走完，自动按 {@code transitions} 推进到下一状态；
     * 时长为「未找到」时不自动推进，等待 {@link #advance(long)}。</p>
     */
    public List<EventFrame> tick(long nowMs) {
        if (current == null) {
            return Collections.emptyList();
        }
        long elapsed = Math.max(0L, nowMs - startMs);
        List<EventFrame> newlyFired = new ArrayList<>();
        for (int i = 0; i < current.events.size(); i++) {
            EventFrame e = current.events.get(i);
            if (!fired[i] && e.atMs() <= elapsed) {
                fired[i] = true;
                newlyFired.add(e);
            }
        }

        if (current.durationMs > 0 && elapsed >= current.durationMs) {
            followTransition(nowMs);
        }
        return newlyFired;
    }

    /**
     * 显式推进到第一个「已核对」的转移目标。
     * ENG-03 后仅用于时长为「未找到」的状态（putaway，确认原版不存在、属移植侧骨架）。
     * bolt(18) 已有权威 33ms，会由 {@link #tick(long)} 自动推进，不再依赖外部兜底。
     *
     * @return 是否成功推进
     */
    public boolean advance(long nowMs) {
        if (current == null) {
            return false;
        }
        return followTransition(nowMs);
    }

    private boolean followTransition(long nowMs) {
        for (Transition t : current.transitions) {
            if ("未找到".equals(t.to()) || t.when().contains("未找到")) {
                continue; // 只跟随能核对的规则
            }
            if (!states.containsKey(t.to())) {
                continue;
            }
            return startInternal(t.to(), nowMs, "transition");
        }
        return false;
    }

    // ---------------------------------------------------------------- queries

    public boolean hasState(String action) { return states.containsKey(action); }

    public String currentAction() { return current == null ? null : current.action; }

    /** -1 表示「未找到」。 */
    public int currentStateId() { return current == null ? -1 : current.stateId; }

    public String currentStateIdName() { return current == null ? "未找到" : current.stateIdName; }

    public String currentClip() { return current == null ? "未找到" : current.clip; }

    public String currentAnmClip() { return current == null ? "未找到" : current.anmClip; }

    public boolean isLoop() { return current != null && current.loop; }

    /** -1 表示时长未找到（不会自动推进）。 */
    public long currentDurationMs() { return current == null ? UNKNOWN_DURATION : current.durationMs; }

    /**
     * 查询任意动作的权威时长，无需切换当前状态（ENG-03 供唯一时钟的订阅者/测试使用）。
     *
     * @return 毫秒；-1 表示该动作不存在或时长未找到
     */
    public long durationOf(String action) {
        StateDef d = states.get(action);
        return d == null ? UNKNOWN_DURATION : d.durationMs;
    }

    /** 时长是否为权威运行时值（false = 用的是 spec 代理值或未知）。 */
    public boolean isDurationAuthoritative() {
        return current != null && current.durationAuthoritative;
    }

    public long elapsedMs(long nowMs) {
        return current == null ? 0L : Math.max(0L, nowMs - startMs);
    }

    /** -1 表示时长未知。 */
    public long remainingMs(long nowMs) {
        if (current == null || current.durationMs <= 0) {
            return UNKNOWN_DURATION;
        }
        return Math.max(0L, current.durationMs - elapsedMs(nowMs));
    }

    public String currentEventFramesNote() {
        return current == null ? "未找到" : current.eventFramesNote;
    }

    /** 当前状态的全部事件帧（只读，用于调试/自检）。 */
    public List<EventFrame> currentEventFrames() {
        return current == null ? Collections.emptyList() : current.events;
    }

    /** 当前状态的全部转移规则（只读）。 */
    public List<Transition> currentTransitions() {
        return current == null ? Collections.emptyList() : current.transitions;
    }

    public int stateCount() { return states.size(); }

    // ---------------------------------------------------------------- helpers
    // 表里同一个字段可能是数字也可能是字符串「未找到」，统一做宽松解析。

    private static String str(JsonObject o, String key, String fallback) {
        if (o == null || !o.has(key) || o.get(key).isJsonNull()) {
            return fallback;
        }
        return o.get(key).getAsString();
    }

    private static double numOrZero(JsonObject o, String key) {
        if (o == null || !o.has(key) || o.get(key).isJsonNull()) {
            return 0.0;
        }
        JsonElement e = o.get(key);
        if (!e.isJsonPrimitive() || !e.getAsJsonPrimitive().isNumber()) {
            return 0.0;
        }
        return e.getAsDouble();
    }

    private static int intOrMinusOne(JsonObject o, String key) {
        if (o == null || !o.has(key) || o.get(key).isJsonNull()) {
            return -1;
        }
        JsonElement e = o.get(key);
        if (!e.isJsonPrimitive() || !e.getAsJsonPrimitive().isNumber()) {
            return -1;
        }
        return e.getAsInt();
    }

    private static long longOrMinusOne(JsonObject o, String key) {
        if (o == null || !o.has(key) || o.get(key).isJsonNull()) {
            return -1L;
        }
        JsonElement e = o.get(key);
        if (!e.isJsonPrimitive() || !e.getAsJsonPrimitive().isNumber()) {
            return -1L;
        }
        return (long) e.getAsDouble();
    }

    private static boolean boolOrFalse(JsonObject o, String key) {
        if (o == null || !o.has(key) || o.get(key).isJsonNull()) {
            return false;
        }
        JsonElement e = o.get(key);
        if (!e.isJsonPrimitive() || !e.getAsJsonPrimitive().isBoolean()) {
            return false;
        }
        return e.getAsBoolean();
    }
}
