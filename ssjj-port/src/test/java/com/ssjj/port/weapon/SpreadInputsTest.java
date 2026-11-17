package com.ssjj.port.weapon;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;

import java.lang.reflect.Constructor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** ENG-02 / R3 + R4：MC 输入域 -> 原版输入域适配层测试。 */
class SpreadInputsTest {

    private static final double EPS = 1e-9;

    private static WeaponSpec spec;
    private static WeaponState state;
    private static SpreadInputs inputs;

    @BeforeAll
    static void setUp() {
        spec = WeaponSpec.load("awm_legend_t");
        state = new WeaponState(spec, 0L);
        inputs = SpreadInputs.fromSpec(spec);
    }

    // ---------------------------------------------------------------- R3 FOV

    @DisplayName("R3 映射表：未开镜恒 90（MC 默认 70 及 89/91 都不改变语义）")
    @ParameterizedTest(name = "mcFov={0} -> 90")
    @ValueSource(doubles = {30.0, 70.0, 89.0, 90.0, 91.0, 110.0})
    void unscopedMapsTo90(double mcFov) {
        assertEquals(90.0, inputs.toOriginalFov(mcFov, false), EPS);
        assertEquals(90.0, inputs.toOriginalFov(mcFov), EPS);
    }

    @DisplayName("R3 映射表：开镜 -> 非 90（spec 可配置，默认本枪 40）")
    @ParameterizedTest(name = "mcFov={0} isScoping=true")
    @ValueSource(doubles = {30.0, 70.0, 90.0, 110.0})
    void scopedMapsToNon90(double mcFov) {
        double v = inputs.toOriginalFov(mcFov, true);
        assertEquals(40.0, v, EPS);
        assertTrue(v != 90.0);
    }

    @DisplayName("开镜态下散布恒为 DefaultParam(0.001)，且不受速度/蹲伏影响")
    @Test
    void scopedSpreadIsDefault() {
        assertEquals(0.001, state.computeSpread(inputs.toOriginalFov(70.0, true),
                400.0, false, false, false), EPS);
    }

    @DisplayName("回归保护：直接透传 MC 默认 FOV=70 会错误地恒得 0.001 —— 证明适配层必需")
    @Test
    void directMcFovPassthroughIsWrong() {
        double wrong = state.computeSpread(70.0, 0.0, true, false, false);
        assertEquals(0.001, wrong, EPS, "这就是 R3 描述的 bug");
        double adapted = inputs.computeSpread(state, 70.0, 0.0, true, true, false, false);
        assertEquals(0.04, adapted, EPS, "经适配层后应为完全蹲下 0.04");
    }

    // ---------------------------------------------------------------- R4 速度

    @DisplayName("R4 单位换算：blocks/tick * 2000 -> cm/s")
    @ParameterizedTest(name = "{0} blocks/tick -> {1} cm/s")
    @CsvSource({
            "0.0,    0.0",
            "0.0125, 25.0",     // 恰为 Length2D2 阈值
            "0.175,  350.0",    // 恰为 Length2D1 阈值
            "0.28,   560.0"     // 典型 MC 疾跑
    })
    void speedScale(double mcSpeed, double expectedCmPerS) {
        assertEquals(expectedCmPerS, inputs.toOriginalSpeed2D(mcSpeed), EPS);
    }

    @DisplayName("R4 配置已生效，无降级告警")
    @Test
    void speedScaleConfigured() {
        assertEquals(2000.0, inputs.speedScale(), EPS);
        assertTrue(inputs.isSpeedScaleConfigured());
        assertTrue(inputs.warnings().isEmpty(), "正常配置下不应有 WARN: " + inputs.warnings());
    }

    @DisplayName("R4 端到端：MC 速度经换算后能真正命中 350/25 两档阈值")
    @ParameterizedTest(name = "mcSpeed={0} -> {1}")
    @CsvSource({
            "0.0,     0.041",   // 0 cm/s，站立静止
            "0.0125,  0.041",   // 25 cm/s，严格 >25 不含 25
            "0.013,   0.14",    // 26 cm/s -> L2
            "0.175,   0.14",    // 350 cm/s，严格 >350 不含 350
            "0.1755,  0.24"     // 351 cm/s -> L1
    })
    void endToEndSpeed(double mcSpeedBlocksPerTick, double expected) {
        assertEquals(expected,
                inputs.computeSpread(state, 70.0, mcSpeedBlocksPerTick, true, false, false, false),
                EPS);
    }

    // ---------------------------------------------------------------- 蹲伏/失重

    @DisplayName("R1 适配：MC 完全蹲下 -> 原版 notFullyDucked=false")
    @Test
    void duckMapping() {
        assertFalse(SpreadInputs.toNotFullyDucked(true));
        assertTrue(SpreadInputs.toNotFullyDucked(false));
        assertTrue(SpreadInputs.ORIGINAL_FOV_UNSCOPED == 90.0);
        assertFalse(SpreadInputs.isWeightlessness(), "MC 无失重态，恒 false");
    }

    @DisplayName("MC 域便捷入口：站立 0.041 / 蹲下 0.04 / 腾空 0.89 / 开镜 0.001")
    @ParameterizedTest(name = "{0} -> {6}")
    @CsvSource({
            "站立静止, 70.0, 0.0,   true,  false, false, false, 0.041",
            "完全蹲下, 70.0, 0.0,   true,  true,  false, false, 0.04",
            "腾空,     70.0, 0.0,   false, false, false, false, 0.89",
            "开镜,     70.0, 0.28,  true,  false, false, true,  0.001",
            "特殊模式, 70.0, 0.0,   true,  false, true,  false, 0.001"
    })
    void mcDomainEntry(String label, double mcFov, double mcSpeed, boolean onGround,
                       boolean fullyCrouched, boolean specialMode, boolean isScoping,
                       double expected) {
        assertEquals(expected,
                inputs.computeSpread(state, mcFov, mcSpeed, onGround, fullyCrouched,
                        specialMode, isScoping),
                EPS, label);
    }

    // ---------------------------------------------------------------- 降级路径

    @DisplayName("R4 防御：inputAdaptation 缺失时回落 scale=1.0 并记 WARN（不静默）")
    @Test
    void missingConfigFallsBackWithWarning() throws Exception {
        JsonObject minimal = JsonParser.parseString("{\"id\":\"test\",\"fire\":{},\"ammo\":{}}")
                .getAsJsonObject();
        Constructor<WeaponSpec> ctor = WeaponSpec.class.getDeclaredConstructor(JsonObject.class);
        ctor.setAccessible(true);
        WeaponSpec bare = ctor.newInstance(minimal);
        SpreadInputs degraded = SpreadInputs.fromSpec(bare);

        assertEquals(1.0, degraded.speedScale(), EPS);
        assertFalse(degraded.isSpeedScaleConfigured());
        assertTrue(degraded.warnings().stream().anyMatch(w -> w.contains("scale")));
        assertEquals(40.0, degraded.scopedFov(), EPS, "开镜值仍用已确认的 40，不编造");
        assertTrue(degraded.mappingTable().contains("降级"));
    }

    @DisplayName("防御：scoped FOV 被误配成 90 时强制回落到 40 并告警")
    @Test
    void badScopedFovIsRejected() throws Exception {
        JsonObject cfg = JsonParser.parseString(
                "{\"inputAdaptation\":{\"fov\":{\"originalScoped\":90},"
                        + "\"speed\":{\"scale\":2000.0}}}").getAsJsonObject();
        Constructor<WeaponSpec> ctor = WeaponSpec.class.getDeclaredConstructor(JsonObject.class);
        ctor.setAccessible(true);
        SpreadInputs s = SpreadInputs.fromSpec(ctor.newInstance(cfg));
        assertEquals(40.0, s.scopedFov(), EPS);
        assertTrue(s.warnings().stream().anyMatch(w -> w.contains("90")));
    }
}
