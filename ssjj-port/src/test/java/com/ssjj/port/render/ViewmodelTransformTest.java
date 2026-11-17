package com.ssjj.port.render;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.joml.Matrix4f;

import static org.junit.jupiter.api.Assertions.assertTrue;

/** 验证视模型从 cm/Z-up 变换到相机空间后的包围盒是否合理（不能飞到无穷远）。 */
class ViewmodelTransformTest {

    @DisplayName("变换后包围盒应落在相机前方合理范围（|x|<2, |y|<2, z 在 -3..0.5）")
    @Test
    void transformedBoundsAreSane() {
        GltfModel model = GltfModel.loadFromClasspath("/assets/ssjjport/fp/awm.gltf");
        SkeletonPose pose = new SkeletonPose(model);
        pose.evaluateBind();
        float[] pos = pose.positions();

        VmConfig cfg = new VmConfig();
        Matrix4f m = ViewmodelPass.handTransform(cfg);

        float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
        float minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
        float minZ = Float.MAX_VALUE, maxZ = -Float.MAX_VALUE;
        int nonFinite = 0;
        for (int v = 0; v < pos.length / 3; v++) {
            float x = pos[v * 3], y = pos[v * 3 + 1], z = pos[v * 3 + 2];
            float tx = m.m00() * x + m.m10() * y + m.m20() * z + m.m30();
            float ty = m.m01() * x + m.m11() * y + m.m21() * z + m.m31();
            float tz = m.m02() * x + m.m12() * y + m.m22() * z + m.m32();
            if (!Float.isFinite(tx) || !Float.isFinite(ty) || !Float.isFinite(tz)) {
                nonFinite++;
                continue;
            }
            minX = Math.min(minX, tx); maxX = Math.max(maxX, tx);
            minY = Math.min(minY, ty); maxY = Math.max(maxY, ty);
            minZ = Math.min(minZ, tz); maxZ = Math.max(maxZ, tz);
        }
        System.out.println("transformed bbox x[" + minX + "," + maxX + "] y[" + minY + "," + maxY
                + "] z[" + minZ + "," + maxZ + "] nonFinite=" + nonFinite);

        assertTrue(nonFinite == 0, "有 " + nonFinite + " 个顶点变换后非有限值");
        assertTrue(Math.abs(minX) < 2f && Math.abs(maxX) < 2f, "x 超出合理范围");
        assertTrue(Math.abs(minY) < 2f && Math.abs(maxY) < 2f, "y 超出合理范围");
        assertTrue(minZ > -3f && maxZ < 0.5f, "z 超出合理范围");
    }
}
