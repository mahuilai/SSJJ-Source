package com.ssjj.port.render;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 对 {@code notes/assets/awm_fp.gltf}（由 mc-port/tools/ssjj2gltf.py 从 viewhand bundle 导出）做结构校验。
 *
 * 这些数字全部来自导出脚本的实测输出，不是估计值：
 * 1478 顶点 / 1964 三角 / 44 关节 / 115 节点。
 */
class GltfModelTest {

    private static final Path GLTF = Path.of("notes", "assets", "awm_fp.gltf");
    private static GltfModel model;

    @BeforeAll
    static void setUp() throws IOException {
        assertTrue(Files.isRegularFile(GLTF), "缺少测试资产: " + GLTF.toAbsolutePath());
        model = GltfModel.load(GLTF);
    }

    @DisplayName("网格规模与导出实测一致")
    @Test
    void meshSizes() {
        assertEquals(1478, model.mesh.vertexCount(), "顶点数");
        assertEquals(1964, model.mesh.triangleCount(), "三角数");
        assertEquals(1478 * 4, model.mesh.joints.length, "每顶点 4 个骨骼索引");
        assertEquals(1478 * 4, model.mesh.weights.length, "每顶点 4 个权重");
        assertEquals(1478 * 2, model.mesh.uvs.length, "每顶点 1 组 UV");
        assertEquals(1478 * 3, model.mesh.normals.length, "每顶点 1 个法线");
    }

    @DisplayName("skin：44 关节 + 44×16 逆绑定矩阵")
    @Test
    void skinShape() {
        assertNotNull(model.skin, "模型必须带 skin");
        assertEquals(44, model.skin.joints.length, "关节数");
        assertEquals(44 * 16, model.skin.inverseBind.length, "逆绑定矩阵元素数");
    }

    @DisplayName("权重已归一化，骨骼索引不越界")
    @Test
    void weightsNormalizedAndJointIndicesValid() {
        int badSum = 0, badIdx = 0;
        for (int v = 0; v < model.mesh.vertexCount(); v++) {
            float sum = 0f;
            for (int k = 0; k < 4; k++) {
                sum += model.mesh.weights[v * 4 + k];
                int j = model.mesh.joints[v * 4 + k];
                if (j < 0 || j >= model.skin.joints.length) {
                    badIdx++;
                }
            }
            if (Math.abs(sum - 1f) > 1e-3f) {
                badSum++;
            }
        }
        assertEquals(0, badSum, "权重和偏离 1 的顶点数");
        assertEquals(0, badIdx, "骨骼索引越界的槽位数");
    }

    @DisplayName("节点树完整，且存在挂 mesh+skin 的节点")
    @Test
    void nodeTreeAndMeshNode() {
        assertEquals(115, model.nodes.length, "节点数");
        boolean found = false;
        int roots = 0;
        boolean[] isChild = new boolean[model.nodes.length];
        for (GltfModel.Node n : model.nodes) {
            for (int c : n.children) {
                isChild[c] = true;
            }
            if (n.mesh == 0 && n.skin == 0) {
                found = true;
            }
        }
        for (boolean b : isChild) {
            if (!b) {
                roots++;
            }
        }
        assertTrue(found, "必须存在一个同时挂 mesh=0 与 skin=0 的节点");
        assertEquals(3, roots, "实测 3 个根节点（bundle 内两个 model 副本 + SSJJ_Mesh）");
    }

    @DisplayName("顶点包围盒与导出实测一致（cm，X 镜像后 -7.55..11.62）")
    @Test
    void boundsMatchExport() {
        float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
        float minZ = Float.MAX_VALUE, maxZ = -Float.MAX_VALUE;
        for (int i = 0; i < model.mesh.positions.length; i += 3) {
            minX = Math.min(minX, model.mesh.positions[i]);
            maxX = Math.max(maxX, model.mesh.positions[i]);
            minZ = Math.min(minZ, model.mesh.positions[i + 2]);
            maxZ = Math.max(maxZ, model.mesh.positions[i + 2]);
        }
        assertEquals(-7.55f, minX, 0.05f, "x min（导出时 X 镜像）");
        assertEquals(11.62f, maxX, 0.05f, "x max（导出时 X 镜像）");
        assertEquals(98.29f, minZ, 0.05f, "z min（离地高度）");
        assertEquals(149.75f, maxZ, 0.05f, "z max（离地高度）");
    }

    @DisplayName("本测试资产不含动画（动画走单独导出），不静默编造")
    @Test
    void noAnimationsInThisAsset() {
        assertEquals(0, model.clips.length, "该 glTF 未导出动画，clip 数应为 0");
    }

    @DisplayName("缺文件时明确抛异常，不返回空模型")
    @Test
    void missingFileFailsLoudly() {
        assertThrows(IOException.class,
                () -> GltfModel.load(Path.of("notes", "assets", "does_not_exist.gltf")));
    }
}
