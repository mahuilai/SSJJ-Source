package com.ssjj.port.weapon;

/**
 * 客户端武器状态机（ENG-03 后：<b>玩法规则 + 唯一时钟的订阅者</b>）。
 *
 * <p><b>ENG-03：两个并行时钟已合并。</b>本类不再持有 {@code phaseStartMs}、
 * 不再读 {@code spec.animation.clips[].lengthS}、不再有自行计时的 {@code tick(long)}。
 * 唯一的动画时钟是 {@link AnimationTimeline}：每个客户端 tick 只调一次
 * {@link AnimationTimeline#tick(long)}，它在时长到点时自动转移，并通过
 * {@link AnimationTimeline.StateListener#onStateEntered} 把权威时长
 * （{@code ViewAnimConfig.GetViewAnimDuration}）同步交付给本类，本类据此更新
 * {@link Phase}、攻击计时器与换弹补弹。</p>
 *
 * <p>本类仍负责<b>玩法</b>：弹匣/备弹、开火门槛、射击间隔、散布计算。
 * 开火门槛刻意用<b>攻击计时器</b>而非动画相位门控——原版
 * {@code AbstractFireAction.CanFireTimeCondition} 只判
 * {@code ClientTime > NextAttackTimer}（{@code AbstractFireAction.cs:35-38}），
 * 与视图动画相位无关。因此 fire 权威 1199ms + bolt 33ms = 1232ms
 * 虽长于 1200ms 射击间隔，下一发仍可在 1200ms 覆盖仍在播放的 bolt
 * （对应原版 {@code ForceRightViewAnim(player, 15)}），两者不冲突。
 * 见 {@code MergedClockTest} / {@code TimelineSelfTest} 的断言。</p>
 *
 * <p>设计原则：
 *  - 弹药/散布数值全部来自 {@link WeaponSpec}，不写死。
 *  - 所有<b>动画时长</b>来自 {@link AnimationTimeline}（唯一时钟），不再来自 spec clip。
 *  - 不使用 TaCZ 的任何类/字段/反射。
 *  - 音效/后坐/枪口特效挂在动画事件帧上（FrameAction 语义），不是 startAction + 定时器。
 *  - {@link Phase#PUTAWAY} 是<b>移植侧骨架</b>：ENG-02 已确认原版
 *    {@code ViewAnimConfig} 与 {@code AnimationConstant.cs} 均无独立收枪动作，
 *    该相位保留仅为切枪流程占位，不代表原版事实。</p>
 */
public final class WeaponState implements AnimationTimeline.StateListener {

    public enum Phase {
        RAISING, READY, FIRING, BOLTING, RELOADING, INSPECTING, MELEE,
        /** 移植侧骨架；原版确认不存在独立收枪视图动画，见 notes/viewanim-config/。 */
        PUTAWAY
    }

    private final WeaponSpec spec;
    /** 唯一动画时钟；null 表示降级模式（仅 computeSpread 等纯计算可用）。 */
    private final AnimationTimeline timeline;

    private Phase phase = Phase.RAISING;
    private int clip;
    private int carry;
    /** 原版 {@code NextAttackTimer}：由 raise / fire 的权威时长设置。 */
    private long nextAttackMs;
    private long lastShotMs = Long.MIN_VALUE;
    private boolean boltPending;
    private boolean reloadPending;

    /**
     * 降级构造（无时钟）。仅用于 {@link #computeSpread} 等不依赖相位的纯计算；
     * 此模式下 {@link #tryFire(long)} / {@link #tryReload(long)} 恒返回 false，
     * 因为没有任何东西可以推进相位——这正是「唯一时钟」的约束。
     */
    public WeaponState(WeaponSpec spec, long nowMs) {
        this(spec, null, nowMs);
    }

    /**
     * ENG-03 主构造：绑定唯一时钟、注册本类为订阅者，并立即启动 raise。
     * {@code timeline.start("raise", nowMs)} 会同步回调
     * {@link #onStateEntered}，用 raise 的权威 499ms 设定攻击计时器
     * （原版 {@code DefaultRaiseSystem.cs:17-22}）。
     */
    public WeaponState(WeaponSpec spec, AnimationTimeline timeline, long nowMs) {
        this.spec = spec;
        this.timeline = timeline;
        this.clip = spec.clipSize();
        this.carry = spec.carrySize();
        // 尚未收到 raise 权威时长之前禁止开火，避免凭空放行。
        this.nextAttackMs = Long.MAX_VALUE;
        if (timeline != null) {
            timeline.setListener(this);
            timeline.start("raise", nowMs);
        }
    }

    public boolean hasTimeline() {
        return timeline != null;
    }

    public Phase phase() {
        return phase;
    }

    public int clip() {
        return clip;
    }

    public int carry() {
        return carry;
    }

    public boolean boltPending() {
        return boltPending;
    }

    public boolean isReloadPending() {
        return reloadPending;
    }

    /** 原版 {@code NextAttackTimer}，供测试核对射速约束。 */
    public long nextAttackMs() {
        return nextAttackMs;
    }

    public long lastShotMs() {
        return lastShotMs;
    }

    // ------------------------------------------------------ 唯一时钟订阅 (ENG-03)

    /**
     * 由 {@link AnimationTimeline} 在每次进入状态时同步调用。
     * 本方法<b>不计时、不推进、不回调时间轴</b>——只把权威时长翻译成玩法状态。
     */
    @Override
    public void onStateEntered(String action, int stateId, long durationMs, long nowMs, String via) {
        Phase mapped = phaseFor(action);
        if (mapped != null) {
            phase = mapped;
        }

        if ("raise".equals(action)) {
            // DefaultRaiseSystem.cs:17-22：NextAttackTimer = ClientTime + GetViewAnimDuration(16)/raiseSpeed。
            // ENG-03 用唯一时钟交付的权威 499ms；raiseSpeed（开火后 1.3f）尚未建模，见 gaps。
            nextAttackMs = durationMs > 0 ? nowMs + durationMs : nowMs;
        }

        if (mapped == Phase.READY) {
            // reload(2533) -> bolt(33) -> idle 到达即换弹结束，
            // 与 DefaultReloadSystem.GetReloadDuration = 2533+33 = 2566ms 一致。
            if (reloadPending) {
                refillClip();
                reloadPending = false;
            }
            boltPending = false;
        }
    }

    private static Phase phaseFor(String action) {
        if (action == null) {
            return null;
        }
        return switch (action) {
            case "raise" -> Phase.RAISING;
            case "fire" -> Phase.FIRING;
            case "bolt" -> Phase.BOLTING;
            case "reload" -> Phase.RELOADING;
            case "inspect" -> Phase.INSPECTING;
            case "melee" -> Phase.MELEE;
            case "putaway" -> Phase.PUTAWAY;
            case "idle", "walk" -> Phase.READY;
            default -> null; // 未知动作不改变相位
        };
    }

    // ---------------------------------------------------------------- 玩法入口

    /**
     * 尝试开火；成功则让唯一时钟从 {@code fire} 重新开始（覆盖可能仍在播放的 bolt）。
     *
     * <p>门控只用攻击计时器 + 弹匣 + 允许相位，<b>不</b>要求相位为 READY：
     * 原版 {@code AbstractFireAction.cs:35-43} 只判
     * {@code ClientTime > NextAttackTimer && Clip >= 1}，视图动画由
     * {@code SetFireAnim} 强制覆盖。这是 1200ms 射速与 1232ms 动画时间轴不冲突的关键。</p>
     */
    public boolean tryFire(long nowMs) {
        if (timeline == null) {
            return false; // 降级模式没有时钟，不能推进相位
        }
        if (phase == Phase.RAISING || phase == Phase.PUTAWAY
                || phase == Phase.RELOADING || phase == Phase.INSPECTING
                || phase == Phase.MELEE) {
            return false;
        }
        if (clip <= 0) {
            return false;
        }
        if (nowMs < nextAttackMs) {
            return false;
        }
        clip -= spec.bulletsPerShot();
        lastShotMs = nowMs;
        // AbstractFireAction.cs:45-48 SetGunAttackTimer = ClientTime + AttackInterval(1200)
        nextAttackMs = nowMs + spec.fireIntervalMs();
        boltPending = true;
        return timeline.start("fire", nowMs);
    }

    /** 尝试开始换弹；补弹由唯一时钟到达 idle 时的回调完成。 */
    public boolean tryReload(long nowMs) {
        if (timeline == null) {
            return false;
        }
        if (phase != Phase.READY || clip >= spec.clipSize() || carry <= 0) {
            return false;
        }
        reloadPending = true;
        return timeline.start("reload", nowMs);
    }

    private void refillClip() {
        int need = spec.clipSize() - clip;
        int take = Math.min(need, carry);
        clip += take;
        carry -= take;
    }

    // ------------------------------------------------------------------- 散布

    /**
     * 原版散布：{@code AwmLegendSpreadLogic.BeforeFire} 的直译
     * （{@code Assembly-CSharp/Assets.Sources.Info.Weapon.Logic.SpreadLogic/AwmLegendSpreadLogic.cs:37-57}），
     * <b>包含原版签名里的 {@code bool isWeightlessness}</b>。
     *
     * <p>原版逐行对照：</p>
     * <pre>
     * if (player.fov.Fov != 90)                                  -> DefaultParam
     * else if (IsBioMode || IsPve || IsRpg)                      -> DefaultParam
     * else {
     *   num = (!OnGround() &amp;&amp; !isWeightlessness) ? AirParam
     *       : (PlayerLength2D &gt; Length2D1)      ? LengthParam1
     *       : (PlayerLength2D &gt; Length2D2)      ? LengthParam2
     *       : (DuckState() != 0)                  ? DefaultParam   // 未完全蹲下
     *       :                                     DuckParam;       // 完全蹲下 = 0.0
     *   if (Fov == 90) num += FovAddParam;
     * }
     * </pre>
     *
     * <p><b>R1 语义修正</b>：{@code notFullyDucked} 对齐原版 {@code DuckState() != 0}，
     * 不是直觉上的「是否蹲下」。依据：
     * {@code HunterVssSpreadLogic.cs:52} 写 {@code DuckState() == 0 ? DuckParam : ...}；
     * {@code physics.net/physics/DuckManager.cs:77-89} 只有在蹲下动画完成时才
     * {@code SetDuckState(0)} 并切到 {@code LEGS_CROUCH_IDLE}。
     * 即 <b>完全蹲下 → DuckParam(0.0) + FovAdd(0.04) = 0.04</b>；
     * <b>站立静止 → DefaultParam(0.001) + FovAdd(0.04) = 0.041</b>。
     * MC 调用方请用 {@link SpreadInputs#toNotFullyDucked(boolean)} 传
     * {@code !fullyCrouched}，或直接用 {@link SpreadInputs#computeSpread}，别自己猜。</p>
     *
     * <p><b>R2 失重分支</b>：{@code !onGround && !isWeightlessness} 保留不删。
     * MC 原版无失重态，调用方传 {@code false}；将来接低重力 / 失重玩法时给真值，
     * 不要改散布公式本身。便捷重载 {@link #computeSpread(double, double, boolean, boolean, boolean)}
     * 已显式传 false。</p>
     *
     * <p><b>输入域</b>：{@code fov} 是原版 FovComponent.Fov 语义（90=未开镜），
     * {@code speed2D} 是原版 PlayerLength2D 语义（cm/s）。
     * <b>禁止直接透传 MC 的 FOV(默认 70) 与 blocks/tick 速度</b>，
     * 必须先过 {@link SpreadInputs} 适配层（R3/R4）。</p>
     *
     * @param fov               原版 Fov（90 = 未开镜；非 90 = 开镜）
     * @param speed2D           原版水平速度 cm/s
     * @param onGround          原版 {@code player.OnGround()}
     * @param notFullyDucked    原版 {@code player.DuckState() != 0}：
     *                          true = 站立/未完全蹲下 → DefaultParam；
     *                          false = 完全蹲下 → DuckParam(0.0)
     * @param specialMode       {@code IsBioMode/IsPve/IsRpg} 等特殊模式（原版直接取 DefaultParam）
     * @param isWeightlessness  原版失重态。MC 无失重态恒 false；将来接低重力需给真值
     */
    public double computeSpread(double fov, double speed2D, boolean onGround,
                                boolean notFullyDucked, boolean specialMode,
                                boolean isWeightlessness) {
        var p = spec.spreadParams();
        double air = p.get("AirParam").getAsDouble();
        double l1 = p.get("LengthParam1").getAsDouble();
        double l2 = p.get("LengthParam2").getAsDouble();
        double duck = p.get("DuckParam").getAsDouble();
        double def = p.get("DefaultParam").getAsDouble();
        double fovAdd = p.get("FovAddParam").getAsDouble();

        double value;
        if (fov != 90.0 || specialMode) {
            value = def;
        } else {
            // 原版是 (!OnGround() && !isWeightlessness)：失重时即使腾空也不吃 AirParam。
            if (!onGround && !isWeightlessness) {
                value = air;
            } else if (speed2D > spec.spreadLength2D1()) {
                value = l1;
            } else if (speed2D > spec.spreadLength2D2()) {
                value = l2;
            } else if (notFullyDucked) {
                value = def;
            } else {
                value = duck;
            }
            if (fov == 90.0) {
                value += fovAdd;
            }
        }
        return value;
    }

    /**
     * 便捷重载：MC 无失重态，显式传 {@code isWeightlessness=false}。
     * 保留 6 参主方法以对齐原版完整签名，不靠删参数蒙混。
     */
    public double computeSpread(double fov, double speed2D, boolean onGround,
                                boolean notFullyDucked, boolean specialMode) {
        return computeSpread(fov, speed2D, onGround, notFullyDucked, specialMode, false);
    }
}
