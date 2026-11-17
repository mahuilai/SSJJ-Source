package com.ssjj.port.weapon;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * 散布输入的适配层（ENG-02 / R3 + R4）——把 <b>Minecraft 输入域</b>映射到
 * <b>SSJJ 原版输入域</b>，再喂给 {@link WeaponState#computeSpread}。
 *
 * <p><b>为什么必须有这一层</b>：原版 {@code AwmLegendSpreadLogic.BeforeFire}
 * （{@code Assembly-CSharp/Assets.Sources.Info.Weapon.Logic.SpreadLogic/AwmLegendSpreadLogic.cs:37-57}）
 * 判的是 {@code player.fov.Fov != 90}，而 {@code FovComponent.Fov} 是 {@code int} 默认 90
 * （{@code FovComponent.cs:9}），90 是「未开镜」的<b>逻辑标记</b>，不是渲染视场角。
 * MC 的 {@code GameOptions.getFov()} 默认 70（1.21.1 Yarn 构造里 bipush 70），
 * 若把 MC FOV 直接透传，{@code fov != 90.0} 恒真 → 永远走 DefaultParam(0.001)，
 * 移动 / 腾空 / 蹲下 / FovAdd 全部分支失效。</p>
 *
 * <h3>FOV 映射表（依据逐条见 spec 的 inputAdaptation.fov）</h3>
 * <pre>
 * | MC 输入                          | 原版 Fov | 散布分支                          |
 * |---------------------------------|----------|-----------------------------------|
 * | isScoping=false, mcFov=70(默认) | 90       | 完整分支 + FovAdd(0.04)           |
 * | isScoping=false, mcFov=89/91    | 90       | 同上（mcFov 只作诊断，不参与判定）|
 * | isScoping=true                  | 40 (可配)| DefaultParam(0.001)，无 FovAdd    |
 * | isScoping=true 二级开镜         | 10 (可配)| 同上（同样 != 90）                |
 * </pre>
 * <p>原版开镜 FOV 数值已确认：{@code FovRightAction.cs:26-35} 由
 * {@code AwmLegendBasePredicationSystem} 挂到本枪，90 → 40 → 10 → 90 循环。
 * <b>MC 侧对应 FOV 数值为「未找到」</b>（MC 没有一一对应的开镜 FOV，且 FOV 会受
 * 疾跑 / 药水 / fovEffectScale 影响），所以适配层用布尔 {@code isScoping} 判定，
 * 不把 {@code mcFov} 当开镜依据；{@code originalScoped} 做成 spec 可配置常量。</p>
 *
 * <h3>速度单位换算（R4）</h3>
 * <pre>
 * 原版 PlayerLength2D = sqrt(Velocity.x² + Velocity.y²)   [PlayerUtility.cs:129-137]
 * 原版单位 = cm/s      （STATE.md:134、docs/AI-设计与优化.md:36/38；
 *                        PlayerConf.cs height=170/RunSpeed=635、SceneMoveData.cs worldGravity=2032 佐证）
 * MC 单位  = blocks/tick（1.21.1 Yarn Entity.getVelocity()；20 tick/s；1 block = 100 cm）
 * scale    = 100 * 20 = 2000.0
 * </pre>
 * <p>{@code scale} 是量纲推导值，不是源码里写死的常量，因此做成 spec 可配置
 * （{@code inputAdaptation.speed.scale}）。字段缺失 / 非数值时回落 1.0 并记 WARN，
 * 不静默吞掉；降级状态下 350/25 阈值几乎不会触发，会在 {@link #warnings()} 里明确报出。</p>
 *
 * <p>本类只做输入适配与诊断，不持有游戏状态、不注册事件、不碰渲染。</p>
 */
public final class SpreadInputs {

    /** 原版未开镜 Fov（FovComponent.cs:9 / PlayerConf.DefFov()）。 */
    public static final double ORIGINAL_FOV_UNSCOPED = 90.0;

    /** MC 1.21.1 默认 FOV（GameOptions options.fov SimpleOption 默认 bipush 70）。 */
    public static final double MC_DEFAULT_FOV = 70.0;

    /** 系数缺失时的保守默认值：1.0（不做换算），并显式 WARN。 */
    public static final double FALLBACK_SPEED_SCALE = 1.0;

    private static final double DEFAULT_SCOPED_FOV = 40.0;
    private static final double DERIVED_SPEED_SCALE = 2000.0;

    private final double scopedFov;
    private final double speedScale;
    private final boolean speedScaleConfigured;
    private final List<String> warnings;

    private SpreadInputs(double scopedFov, double speedScale,
                         boolean speedScaleConfigured, List<String> warnings) {
        this.scopedFov = scopedFov;
        this.speedScale = speedScale;
        this.speedScaleConfigured = speedScaleConfigured;
        this.warnings = Collections.unmodifiableList(warnings);
    }

    /**
     * 从 spec 的 {@code inputAdaptation} 段构造。不改 {@link WeaponSpec} 既有逻辑，
     * 只读它已公开的 {@link WeaponSpec#raw()}；字段缺失时全部走有记录的降级。
     */
    public static SpreadInputs fromSpec(WeaponSpec spec) {
        List<String> warns = new ArrayList<>();
        JsonObject root = spec.raw();
        JsonObject adapt = obj(root, "inputAdaptation");
        JsonObject fov = obj(adapt, "fov");
        JsonObject speed = obj(adapt, "speed");

        double scoped = number(fov, "originalScoped", DEFAULT_SCOPED_FOV);
        if (scoped == ORIGINAL_FOV_UNSCOPED) {
            // 开镜值必须 != 90，否则会与未开镜混淆；退回本枪已确认的 40
            warns.add("inputAdaptation.fov.originalScoped 被配成 90（与未开镜相同），"
                    + "已强制回落到 FovRightAction.cs:28 的 40");
            scoped = DEFAULT_SCOPED_FOV;
        }
        if (fov == null || !hasNumber(fov, "originalScoped")) {
            warns.add("inputAdaptation.fov.originalScoped 未配置，"
                    + "使用本枪已确认值 40（FovRightAction.cs:28）");
        }

        Double configured = nullableNumber(speed, "scale");
        double scale;
        boolean configuredOk;
        if (configured == null || configured <= 0.0) {
            scale = FALLBACK_SPEED_SCALE;
            configuredOk = false;
            warns.add("inputAdaptation.speed.scale 未配置/非正数：回落 1.0（不换算）。"
                    + "原版 cm/s 与 MC blocks/tick 量纲不同，350/25 阈值此时几乎不会触发；"
                    + "请按 STATE.md:134 的 cm 量纲把 scale 配成 2000.0。");
        } else {
            scale = configured;
            configuredOk = true;
            if (Math.abs(scale - DERIVED_SPEED_SCALE) > 1e-9) {
                warns.add("inputAdaptation.speed.scale=" + scale
                        + " 与量纲推导值 2000.0 不同（可能是有意校准，请确认）");
            }
        }
        return new SpreadInputs(scoped, scale, configuredOk, warns);
    }

    // ------------------------------------------------------------------ FOV (R3)

    /**
     * MC FOV → 原版 {@code FovComponent.Fov} 语义。
     *
     * @param mcFov      MC 当前 FOV（默认 70）。<b>只作诊断</b>：MC FOV 会受疾跑/药水/
     *                   fovEffectScale 影响，不能当开镜标志；本方法不会把它线性映射成原版值。
     * @param isScoping  是否开镜（由模组自己的开镜状态提供；MC 侧对应 FOV 数值「未找到」）
     * @return 未开镜恒为 90；开镜返回 spec 可配置的非 90 值（默认 40）
     */
    public double toOriginalFov(double mcFov, boolean isScoping) {
        // mcFov 刻意不参与判定：见类 Javadoc 的映射表与 R3 说明。
        return isScoping ? scopedFov : ORIGINAL_FOV_UNSCOPED;
    }

    /** 便捷重载：未开镜。 */
    public double toOriginalFov(double mcFov) {
        return toOriginalFov(mcFov, false);
    }

    public double scopedFov() { return scopedFov; }

    // ---------------------------------------------------------------- 速度 (R4)

    /** MC blocks/tick → 原版 PlayerLength2D (cm/s)。 */
    public double toOriginalSpeed2D(double mcSpeedBlocksPerTick) {
        return mcSpeedBlocksPerTick * speedScale;
    }

    public double speedScale() { return speedScale; }

    public boolean isSpeedScaleConfigured() { return speedScaleConfigured; }

    // ------------------------------------------------------- 蹲伏 / 失重 语义适配

    /**
     * MC「完全蹲下」→ 原版 {@code notFullyDucked}（{@code DuckState() != 0}）。
     *
     * <p>原版语义与直觉相反，必须显式转换：
     * {@code AwmLegendSpreadLogic.cs:50} 是
     * {@code DuckState() != 0 ? DefaultParam : DuckParam}；
     * {@code HunterVssSpreadLogic.cs:52} 是 {@code DuckState() == 0 ? DuckParam : ...}；
     * {@code DuckManager.cs:77-89} 在蹲下动画完成时才 {@code SetDuckState(0)}。
     * 即 <b>DuckState()==0 = 完全蹲下 → DuckParam(0.0)</b>，
     * DuckState()!=0 = 站立/未完全蹲下 → DefaultParam(0.001)。</p>
     *
     * @param mcFullyCrouched MC 侧是否完全蹲下（潜行到位）
     * @return 原版 {@code notFullyDucked} 入参
     */
    public static boolean toNotFullyDucked(boolean mcFullyCrouched) {
        return !mcFullyCrouched;
    }

    /**
     * MC 无失重态，恒 false。
     * 原版 {@code AwmLegendSpreadLogic.cs:50} 的 {@code !OnGround() && !isWeightlessness}
     * 分支保留不删；将来接低重力 / 失重玩法时由调用方给真值，不要改散布公式本身。
     */
    public static boolean isWeightlessness() {
        return false;
    }

    /**
     * MC 域便捷入口：一次完成 FOV / 速度 / 蹲伏 / 失重适配后调用
     * {@link WeaponState#computeSpread(double, double, boolean, boolean, boolean, boolean)}。
     * 显式传 {@code isWeightlessness=false}，符合「调用方传 false」的约束。
     */
    public double computeSpread(WeaponState state, double mcFov, double mcSpeedBlocksPerTick,
                                boolean onGround, boolean mcFullyCrouched,
                                boolean specialMode, boolean isScoping) {
        return state.computeSpread(
                toOriginalFov(mcFov, isScoping),
                toOriginalSpeed2D(mcSpeedBlocksPerTick),
                onGround,
                toNotFullyDucked(mcFullyCrouched),
                specialMode,
                isWeightlessness());
    }

    // ------------------------------------------------------------------ 诊断

    public List<String> warnings() { return warnings; }

    /** 人读映射表（用于日志 / 文档核对）。 */
    public String mappingTable() {
        return "SpreadInputs{fov: MC " + MC_DEFAULT_FOV + " -> 原版 " + ORIGINAL_FOV_UNSCOPED
                + "(未开镜) | isScoping -> " + scopedFov
                + "(FovRightAction.cs:28, 二级 10) | mcFov 仅诊断; "
                + "speed: blocks/tick * " + speedScale + " -> cm/s"
                + (speedScaleConfigured ? " (spec 配置)" : " (降级 1.0, 见 warnings())")
                + "; duck: !fullyCrouched -> DuckState()!=0; weightlessness: false}";
    }

    // ------------------------------------------------------------------ helpers
    // 宽松解析：spec 里同一个字段可能是数字，也可能是字符串「未找到」。

    private static JsonObject obj(JsonObject o, String key) {
        if (o == null || !o.has(key) || !o.get(key).isJsonObject()) {
            return null;
        }
        return o.getAsJsonObject(key);
    }

    private static boolean hasNumber(JsonObject o, String key) {
        if (o == null || !o.has(key) || o.get(key).isJsonNull()) {
            return false;
        }
        JsonElement e = o.get(key);
        return e.isJsonPrimitive() && e.getAsJsonPrimitive().isNumber();
    }

    private static Double nullableNumber(JsonObject o, String key) {
        return hasNumber(o, key) ? o.get(key).getAsDouble() : null;
    }

    private static double number(JsonObject o, String key, double fallback) {
        Double v = nullableNumber(o, key);
        return v == null ? fallback : v;
    }
}
