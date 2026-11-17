package com.ssjj.port.weapon;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * ENG-02 散布契约回归测试。
 *
 * 期望值来自 QA-01 报告 §「建议的最小测试集」与原版
 * {@code AwmLegendSpreadLogic.BeforeFire} 逐分支计算：
 * 参数 Air=0.85 / L1=0.20 / L2=0.10 / Duck=0.0 / Default=0.001 / FovAdd=0.04。
 *
 * 入参全部是<b>原版输入域</b>（fov 语义 90=未开镜、speed2D 单位 cm/s）；
 * MC 域的适配另见 {@link SpreadInputsTest}。
 */
class SpreadContractTest {

    private static final double EPS = 1e-9;

    private static WeaponSpec spec;
    private static WeaponState state;

    @BeforeAll
    static void setUp() {
        spec = WeaponSpec.load("awm_legend_t");
        state = new WeaponState(spec, 0L);
    }

    // ---------------------------------------------------------------- 7 个分支

    @DisplayName("原版 7 分支：QA 给的期望值逐条对齐")
    @ParameterizedTest(name = "{0} -> {7}")
    @CsvSource({
            // label,        fov, speed2D, onGround, notFullyDucked, specialMode, weightless, expected
            "站立静止,        90.0,   0.0,  true,   true,   false,  false,  0.041",
            "完全蹲下,        90.0,   0.0,  true,   false,  false,  false,  0.04",
            "腾空,            90.0,   0.0,  false,  true,   false,  false,  0.89",
            "速度>350,        90.0, 351.0,  true,   true,   false,  false,  0.24",
            "速度>25,         90.0,  26.0,  true,   true,   false,  false,  0.14",
            "开镜(非90),      40.0,   0.0,  true,   true,   false,  false,  0.001",
            "特殊模式,        90.0,   0.0,  true,   true,   true,   false,  0.001",
            "腾空但失重,      90.0,   0.0,  false,  true,   false,  true,   0.041",
            "开镜+特殊模式,   10.0, 400.0,  false,  false,  true,   false,  0.001"
    })
    void sevenBranches(String label, double fov, double speed2D, boolean onGround,
                       boolean notFullyDucked, boolean specialMode, boolean weightless,
                       double expected) {
        assertEquals(expected,
                state.computeSpread(fov, speed2D, onGround, notFullyDucked, specialMode, weightless),
                EPS, label);
    }

    @DisplayName("5 参重载显式传 weightless=false，与 6 参主方法一致")
    @Test
    void fiveArgOverloadDelegatesWithFalse() {
        assertEquals(
                state.computeSpread(90.0, 0.0, false, true, false, false),
                state.computeSpread(90.0, 0.0, false, true, false),
                EPS);
        assertEquals(0.89, state.computeSpread(90.0, 0.0, false, true, false), EPS);
    }

    @DisplayName("R2：失重分支保留 —— 腾空时 weightless 能改变结果")
    @Test
    void weightlessnessBranchIsLive() {
        double normal = state.computeSpread(90.0, 0.0, false, true, false, false);
        double weightless = state.computeSpread(90.0, 0.0, false, true, false, true);
        assertEquals(0.89, normal, EPS);
        assertNotEquals(normal, weightless, "isWeightlessness 必须是活的分支，不能被优化掉");
        assertEquals(0.041, weightless, EPS);
    }

    // ---------------------------------------------------------------- FOV 边界

    @DisplayName("R3 前置：fov 89/90/91 —— 只有 90 走完整分支并加 FovAdd")
    @ParameterizedTest(name = "fov={0}")
    @CsvSource({
            "89.0, 0.001",
            "90.0, 0.041",
            "91.0, 0.001"
    })
    void fovBoundary(double fov, double expected) {
        assertEquals(expected, state.computeSpread(fov, 0.0, true, true, false), EPS);
    }

    @DisplayName("FovAdd 只在 fov==90 时附加")
    @Test
    void fovAddOnlyAt90() {
        double at90 = state.computeSpread(90.0, 0.0, true, true, false);
        double at40 = state.computeSpread(40.0, 0.0, true, true, false);
        assertEquals(0.04, at90 - at40, EPS);
    }

    // ---------------------------------------------------------------- 速度边界

    @DisplayName("R4 边界：speed 24/25/26/349/350/351 逐档命中正确散布值")
    @ParameterizedTest(name = "speed2D={0} -> {1}")
    @CsvSource({
            "24.0,  0.041",   // <=25，未完全蹲下 -> Default + FovAdd
            "25.0,  0.041",   // 严格 >25 不含 25
            "26.0,  0.14",    // >25 -> L2
            "349.0, 0.14",    // 仍 <=350 -> L2
            "350.0, 0.14",    // 严格 >350 不含 350
            "351.0, 0.24"     // >350 -> L1
    })
    void speedBoundary(double speed2D, double expected) {
        assertEquals(expected, state.computeSpread(90.0, speed2D, true, true, false), EPS,
                "speed2D=" + speed2D);
    }

    @DisplayName("速度边界在完全蹲下时同样成立（阈值优先级高于蹲伏）")
    @ParameterizedTest(name = "speed2D={0} -> {1}")
    @CsvSource({
            "0.0,   0.04",
            "26.0,  0.14",
            "351.0, 0.24"
    })
    void speedBeatsDuck(double speed2D, double expected) {
        assertEquals(expected, state.computeSpread(90.0, speed2D, true, false, false), EPS);
    }

    @DisplayName("腾空优先级高于速度档")
    @Test
    void airBeatsSpeed() {
        assertEquals(0.89, state.computeSpread(90.0, 400.0, false, true, false), EPS);
    }

    // ---------------------------------------------------------------- R1 契约

    @Nested
    @DisplayName("R1：notFullyDucked 语义（DuckState()!=0）")
    class DuckContract {

        @Test
        @DisplayName("完全蹲下(notFullyDucked=false) -> DuckParam 0.0 + FovAdd = 0.04")
        void fullyCrouchedGetsDuckParam() {
            assertEquals(0.04, state.computeSpread(90.0, 0.0, true, false, false), EPS);
        }

        @Test
        @DisplayName("站立/未完全蹲下(notFullyDucked=true) -> DefaultParam 0.001 + 0.04 = 0.041")
        void notFullyDuckedGetsDefaultParam() {
            assertEquals(0.041, state.computeSpread(90.0, 0.0, true, true, false), EPS);
        }

        @Test
        @DisplayName("两者差 0.001，不可互换")
        void mustNotBeSwapped() {
            assertNotEquals(
                    state.computeSpread(90.0, 0.0, true, true, false),
                    state.computeSpread(90.0, 0.0, true, false, false));
        }

        @DisplayName("specialMode / 开镜 时蹲伏参数不影响结果")
        @ParameterizedTest
        @ValueSource(booleans = {true, false})
        void duckIgnoredInDefaultBranch(boolean notFullyDucked) {
            assertEquals(0.001, state.computeSpread(90.0, 0.0, true, notFullyDucked, true), EPS);
            assertEquals(0.001, state.computeSpread(40.0, 0.0, true, notFullyDucked, false), EPS);
        }
    }

    // ---------------------------------------------------------------- spec 完整性

    @DisplayName("spec 参数与阈值未被改动（回归保护）")
    @Test
    void specValuesIntact() {
        assertEquals(1200, spec.fireIntervalMs());
        assertEquals(15, spec.clipSize());
        assertEquals(30, spec.carrySize());
        assertEquals(350, spec.spreadLength2D1());
        assertEquals(25, spec.spreadLength2D2());
        assertEquals(0.85, spec.spreadParams().get("AirParam").getAsDouble(), EPS);
        assertEquals(0.20, spec.spreadParams().get("LengthParam1").getAsDouble(), EPS);
        assertEquals(0.10, spec.spreadParams().get("LengthParam2").getAsDouble(), EPS);
        assertEquals(0.0, spec.spreadParams().get("DuckParam").getAsDouble(), EPS);
        assertEquals(0.001, spec.spreadParams().get("DefaultParam").getAsDouble(), EPS);
        assertEquals(0.04, spec.spreadParams().get("FovAddParam").getAsDouble(), EPS);
    }

    @DisplayName("ENG-02 的 inputAdaptation 配置段存在且数值正确")
    @Test
    void adaptationConfigPresent() {
        var adapt = spec.raw().getAsJsonObject("inputAdaptation");
        var fov = adapt.getAsJsonObject("fov");
        var speed = adapt.getAsJsonObject("speed");
        assertEquals(90, fov.get("originalUnscoped").getAsInt());
        assertEquals(40, fov.get("originalScoped").getAsInt());
        assertEquals(10, fov.get("originalScopedSecondZoom").getAsInt());
        assertEquals(70, fov.get("mcDefaultFov").getAsInt());
        assertEquals("未找到", fov.get("mcScopedFov").getAsString());
        assertEquals(2000.0, speed.get("scale").getAsDouble(), EPS);
        assertEquals(350, speed.get("threshold1").getAsInt());
        assertEquals(25, speed.get("threshold2").getAsInt());
        assertTrue(speed.get("configurable").getAsBoolean());
    }
}
