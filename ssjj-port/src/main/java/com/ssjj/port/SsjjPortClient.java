package com.ssjj.port;

import com.ssjj.port.weapon.AnimationTimeline;
import com.ssjj.port.weapon.SoundEventMap;
import com.ssjj.port.weapon.SpreadInputs;
import com.ssjj.port.weapon.WeaponState;
import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.fabricmc.fabric.api.client.keybinding.v1.KeyBindingHelper;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.option.KeyBinding;
import net.minecraft.client.util.InputUtil;
import net.minecraft.item.ItemStack;
import org.lwjgl.glfw.GLFW;

/**
 * 客户端入口：持有本地武器状态 + 动画时间轴，并把输入接到 {@link WeaponState}。
 *
 * <p>本阶段只做：左键开火、R 换弹、事件帧派发。
 * <b>不实现</b>渲染 / 模型 / HUD / 开镜 / 实际音频播放 / 命中判定 / 网络同步。</p>
 *
 * <p>已核对在 1.21.1 Yarn 存在的 API（见 notes/state-transitions.md）：
 * {@code GameOptions.attackKey}、{@code KeyBinding(String, InputUtil.Type, int, String)}、
 * {@code KeyBinding.wasPressed()}、{@code MinecraftClient.currentScreen}、
 * {@code GameOptions.getFov()}、{@code Entity.getVelocity()/isOnGround()/isSneaking()}、
 * {@code Fabric KeyBindingHelper.registerKeyBinding}、{@code GLFW.GLFW_KEY_R=82}。</p>
 *
 * <p><b>ENG-03：两个并行时钟已合并，{@link AnimationTimeline} 是唯一时钟。</b>
 * 每个客户端 tick 只调一次 {@link AnimationTimeline#tick(long)}，它同时完成
 * 事件帧派发、权威时长到点后的自动转移、以及通过
 * {@link AnimationTimeline.StateListener} 通知 {@link WeaponState} 更新相位/攻击计时器/补弹。
 * {@code WeaponState} 不再有自行计时的 {@code tick(long)}，也不再读 spec clip 长度。
 * 原来的 {@code settleTimelineToIdle} 兜底已删除：bolt(18) 有权威 33ms 会自行推进，
 * putaway 确认原版不存在、保留为骨架不自动推进。</p>
 *
 * <p>散布输入一律经 {@link SpreadInputs} 适配（R3 FOV / R4 速度单位），
 * 由 {@code SpreadInputs.computeSpread(...)} 显式传 {@code isWeightlessness=false}
 * —— MC 无失重态。本阶段散布只做诊断日志，不参与命中判定。</p>
 *
 * <p>音效：{@link SoundEventMap} 把动画事件名映射到
 * {@code audio-event-map.json} 的目标键（只建映射；无 .ogg、无 SoundEvent 注册）。</p>
 */
public final class SsjjPortClient implements ClientModInitializer {

    private static final String RELOAD_KEY = "key.ssjjport.reload";
    private static final String KEY_CATEGORY = "key.category.ssjjport";

    private static WeaponState state;
    private static AnimationTimeline timeline;
    private static SoundEventMap soundEventMap;
    private static SpreadInputs spreadInputs;
    private static boolean spreadInputsAttempted;
    private static KeyBinding reloadKey;
    private static boolean logged;
    private static boolean prevAttackDown;

    public static WeaponState state() {
        return state;
    }

    public static AnimationTimeline timeline() {
        return timeline;
    }

    @Override
    public void onInitializeClient() {
        // 若装了 GemRender，把第一人称渲染交给它（GLB/glTF + GPU 蒙皮 + hand pass）。
        // 未安装时自动跳过，继续走内置的 ViewmodelPass。
        com.ssjj.port.render.GemRenderBridge.register(
                net.minecraft.util.Identifier.of(SsjjPort.MOD_ID, "awm_legend_t"),
                SsjjPort.AWM_LEGEND_T);

        reloadKey = KeyBindingHelper.registerKeyBinding(
                new KeyBinding(RELOAD_KEY, InputUtil.Type.KEYSYM, GLFW.GLFW_KEY_R, KEY_CATEGORY));

        try {
            timeline = AnimationTimeline.load("state-transitions");
        } catch (RuntimeException e) {
            // 资源缺失不让模组崩；时间轴为 null 时输入仍可用，只是没有事件帧/时钟。
            SsjjPort.LOG.error("[ssjjport] animation timeline unavailable: {}", e.getMessage());
            timeline = null;
        }

        try {
            soundEventMap = SoundEventMap.load();
            for (String w : soundEventMap.warnings()) {
                SsjjPort.LOG.warn("[ssjjport] SoundEventMap: {}", w);
            }
        } catch (RuntimeException e) {
            SsjjPort.LOG.error("[ssjjport] sound event map unavailable: {}", e.getMessage());
            soundEventMap = null;
        }

        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            if (SsjjPort.SPEC == null) {
                return;
            }
            // SPEC 由 ModInitializer 设置；惰性初始化，避免入口点顺序导致 NPE。
            if (!spreadInputsAttempted) {
                spreadInputsAttempted = true;
                try {
                    spreadInputs = SpreadInputs.fromSpec(SsjjPort.SPEC);
                    for (String w : spreadInputs.warnings()) {
                        SsjjPort.LOG.warn("[ssjjport] SpreadInputs: {}", w);
                    }
                    SsjjPort.LOG.info("[ssjjport] {}", spreadInputs.mappingTable());
                } catch (RuntimeException e) {
                    SsjjPort.LOG.error("[ssjjport] spread inputs unavailable: {}", e.getMessage());
                }
            }
            long now = System.currentTimeMillis();
            if (state == null) {
                // ENG-03：三参构造绑定唯一时钟、注册订阅者、并启动 raise。
                state = (timeline != null)
                        ? new WeaponState(SsjjPort.SPEC, timeline, now)
                        : new WeaponState(SsjjPort.SPEC, now);
            }

            boolean allowInput = isHoldingWeapon(client) && client.currentScreen == null;

            // 左键开火：用 isPressed() 自己做上升沿，不消费原版按键状态。
            // 半自动点击（每次按下最多一发），匹配 1200ms 栓动步枪节奏。
            // tryFire 内部会调 timeline.start("fire")，此处不再重复启动时间轴。
            boolean attackDown = allowInput && client.options.attackKey.isPressed();
            if (attackDown && !prevAttackDown && state.tryFire(now)) {
                logSpread(client);
            }
            prevAttackDown = attackDown;

            // R 换弹：wasPressed() 是本模组自己注册的键位，可以安全消费。
            // 无论是否持枪都读一次，避免按键计数堆积到下次持枪才触发。
            boolean reloadPressed = reloadKey.wasPressed();
            if (allowInput && reloadPressed) {
                state.tryReload(now); // 内部启动 timeline("reload")
            }

            // ★ 唯一时钟：一次 tick 同时派发事件帧 + 自动转移 + 通知 WeaponState。
            if (timeline != null) {
                for (AnimationTimeline.EventFrame ev : timeline.tick(now)) {
                    String soundKey = soundEventMap == null
                            ? "未找到" : soundEventMap.resolve(ev.name()).orElse("未找到");
                    SsjjPort.LOG.info(
                            "[ssjjport] event-frame action={} stateId={} clip={} type={} name={} atMs={} soundKey={} source={}",
                            ev.action(), timeline.currentStateId(), timeline.currentClip(),
                            ev.type(), ev.name(), ev.atMs(), soundKey, ev.source());
                    // TODO(阶段 4): 用 soundKey 播放实际 .ogg；
                    // 本阶段只有映射表：无 .ogg、无 SoundEvent 注册，不产生实际音频。
                }
            }

            if (!logged) {
                logged = true;
                SsjjPort.LOG.info("[ssjjport] client ready phase={} clip={}/{} states={} timeline={} singleClock={}",
                        state.phase(), state.clip(), state.carry(),
                        timeline == null ? 0 : timeline.stateCount(),
                        timeline == null ? "unavailable" : timeline.currentAction(),
                        state.hasTimeline());
                if (timeline != null) {
                    SsjjPort.LOG.info("[ssjjport] AnimationTimeline 为唯一时钟（ViewAnimConfig 权威时长）；"
                            + "WeaponState 订阅其状态，fire={}ms bolt={}ms 射速={}ms",
                            timeline.durationOf("fire"), timeline.durationOf("bolt"),
                            SsjjPort.SPEC.fireIntervalMs());
                }
            }
        });
    }

    /**
     * 诊断用：开火时把 MC 输入经 {@link SpreadInputs} 适配后算一次散布并打日志。
     *
     * <p>这是 {@code WeaponState.computeSpread} 在 MC 侧唯一的调用方，
     * 通过 {@link SpreadInputs#computeSpread} 显式传 {@code isWeightlessness=false}
     * （MC 无失重态）。本阶段不做命中判定 / 后坐 / 枪口特效，只验证输入域契约。</p>
     *
     * <p>注意：{@code isScoping} 本阶段恒 false（开镜未实现）；{@code isSneaking()}
     * 近似当作「完全蹲下」，与 SSJJ 的 DuckState()==0 并非严格等价，后续接低重力/
     * 精确蹲伏状态机时需替换。</p>
     */
    private static void logSpread(MinecraftClient client) {
        if (spreadInputs == null || client.player == null) {
            return;
        }
        double mcFov = client.options.getFov().getValue();
        double mcSpeed = client.player.getVelocity().horizontalLength(); // blocks/tick
        boolean onGround = client.player.isOnGround();
        boolean fullyCrouched = client.player.isSneaking();
        boolean specialMode = false;
        boolean isScoping = false; // 开镜未实现（本阶段不实现 ADS）
        double spread = spreadInputs.computeSpread(state, mcFov, mcSpeed, onGround,
                fullyCrouched, specialMode, isScoping);
        SsjjPort.LOG.info(
                "[ssjjport] spread={} mcFov={} mcSpeed={}blocks/tick onGround={} crouched={} "
                        + "-> fov={} speed2D={}cm/s notFullyDucked={} weightless=false",
                spread, mcFov, mcSpeed, onGround, fullyCrouched,
                spreadInputs.toOriginalFov(mcFov, isScoping),
                spreadInputs.toOriginalSpeed2D(mcSpeed),
                SpreadInputs.toNotFullyDucked(fullyCrouched));
    }

    private static boolean isHoldingWeapon(MinecraftClient client) {
        if (client.player == null || client.world == null) {
            return false;
        }
        ItemStack stack = client.player.getMainHandStack();
        return !stack.isEmpty() && stack.getItem() == SsjjPort.AWM_LEGEND_T;
    }
}
