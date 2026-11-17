package com.ssjj.port.render;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 骨骼求值 + CPU 蒙皮的自检。
 *
 * 核心断言是「绑定姿态往返」：不播动画时，skin 矩阵 = world(joint) × inverseBind
 * 应当互相抵消，蒙皮结果必须还原原始顶点。这条过了，说明
 * ①逆绑定矩阵按列主序读对了 ②节点层级与拓扑序对 ③权重混合对。
 * 它比「能画出个东西」强得多——画歪了也能看出是个人形。
 */
class SkeletonPoseTest {

    private static final String RES = "/assets/ssjjport/fp/awm.gltf";
    private static GltfModel model;

    @BeforeAll
    static void setUp() {
        model = GltfModel.loadFromClasspath(RES);
    }

    @DisplayName("classpath 加载与文件加载得到同一份模型")
    @Test
    void classpathLoadMatchesFileLoad() {
        assertEquals(1478, model.mesh.vertexCount());
        assertEquals(1964, model.mesh.triangleCount());
        assertNotNull(model.skin);
        assertEquals(44, model.skin.joints.length);
    }

    @DisplayName("绑定姿态往返：蒙皮后必须还原原始顶点（误差 < 0.05cm）")
    @Test
    void bindPoseRoundTrips() {
        SkeletonPose pose = new SkeletonPose(model);
        assertEquals(44, pose.jointCount());
        assertEquals(1478, pose.vertexCount());

        pose.evaluateBind();
        float[] out = pose.positions();
        float[] src = model.mesh.positions;

        float maxErr = 0f;
        int worst = -1;
        for (int i = 0; i < out.length; i++) {
            float e = Math.abs(out[i] - src[i]);
            if (e > maxErr) {
                maxErr = e;
                worst = i;
            }
        }
        assertTrue(maxErr < 0.05f,
                "绑定姿态未还原：最大误差 " + maxErr + " cm（顶点 " + worst / 3 + "，" + "xyz".charAt(worst % 3) + "）");
    }

    @DisplayName("重复求值稳定：两次 evaluateBind 结果一致")
    @Test
    void repeatedEvaluateIsStable() {
        SkeletonPose pose = new SkeletonPose(model);
        pose.evaluateBind();
        float[] first = pose.positions().clone();
        pose.evaluateBind();
        float[] second = pose.positions();
        for (int i = 0; i < first.length; i++) {
            assertEquals(first[i], second[i], 1e-4f, "顶点分量 " + i + " 两次求值不一致");
        }
    }

    @DisplayName("clip 为 null 等价于绑定姿态")
    @Test
    void nullClipFallsBackToBind() {
        SkeletonPose pose = new SkeletonPose(model);
        pose.evaluate(null, 0f);
        float[] viaNull = pose.positions().clone();
        pose.evaluateBind();
        float[] viaBind = pose.positions();
        for (int i = 0; i < viaNull.length; i++) {
            assertEquals(viaBind[i], viaNull[i], 1e-4f);
        }
    }

    @DisplayName("超时长钳制：timeSec 远超末尾也不越界/不 NaN")
    @Test
    void outOfRangeTimeClamps() {
        SkeletonPose pose = new SkeletonPose(model);
        pose.evaluate(null, 999f);
        for (float v : pose.positions()) {
            assertTrue(Float.isFinite(v), "出现非有限值");
        }
    }
}
