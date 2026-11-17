package com.ssjj.port.render;

import org.joml.Matrix4f;
import org.joml.Quaternionf;

import java.util.Arrays;

/**
 * 骨骼求值 + CPU 蒙皮。
 *
 * <p>输入是 {@link GltfModel}（节点树 + skin 的逆绑定矩阵 + 每顶点 4 组骨骼索引/权重），
 * 输出是变形后的顶点数组。渲染层只需要拿 {@link #positions()} 的缓冲逐顶点提交。</p>
 *
 * <p><b>为什么先做 CPU 蒙皮</b>：模型只有 1,478 顶点、2,640 三角以内，
 * CPU 每帧算一次的开销可以忽略；GPU 蒙皮需要自定义 shader 与顶点属性布局，
 * 在 1.21.1 的 RenderLayer 体系里要先解决兼容问题。先用 CPU 版把「画对」验证完，
 * 再决定要不要上 shader。</p>
 *
 * <p><b>绑定姿态自检</b>：不播放任何动画时（{@link #evaluateBind()}），
 * 蒙皮结果应当还原原始顶点——因为 skin 矩阵 = world(joint) × inverseBind，
 * 而 inverseBind 就是绑定姿态世界矩阵的逆。误差超过 0.05cm 说明数据或求值错了。
 * 这条性质被 {@code SkeletonPoseTest} 用作硬断言。</p>
 */
public final class SkeletonPose {

    private final GltfModel model;
    private final int[] parent;
    private final int[] order;
    private final Matrix4f[] world;
    private final Matrix4f[] skin;
    private final Matrix4f[] ibm;
    /** 绑定姿态补偿：inverse(world(joint0) × ibm0)，见类注释「空间补偿」。 */
    private final Matrix4f bindComp = new Matrix4f();
    /** 求值时的临时 local 矩阵（避免每节点 new）。 */
    private final Matrix4f tmpLocal = new Matrix4f();
    private final float[] outPos;

    /** 每节点临时 TRS（动画采样写入，未采样的节点回落到 glTF 里的默认值）。 */
    private final float[][] nodeT;
    private final float[][] nodeR;
    private final float[][] nodeS;
    private final boolean hasSkin;

    public SkeletonPose(GltfModel model) {
        this.model = model;
        int n = model.nodes.length;
        this.parent = new int[n];
        Arrays.fill(parent, -1);
        for (int i = 0; i < n; i++) {
            for (int c : model.nodes[i].children) {
                if (parent[c] != -1 && parent[c] != i) {
                    throw new IllegalStateException("节点 " + c + " 有两个父节点");
                }
                parent[c] = i;
            }
        }
        this.order = topologicalOrder();
        this.world = newMatrixArray(n);
        this.nodeT = new float[n][];
        this.nodeR = new float[n][];
        this.nodeS = new float[n][];
        for (int i = 0; i < n; i++) {
            nodeT[i] = model.nodes[i].translation.clone();
            nodeR[i] = model.nodes[i].rotation.clone();
            nodeS[i] = model.nodes[i].scale.clone();
        }
        this.hasSkin = model.skin != null;
        if (hasSkin) {
            int k = model.skin.joints.length;
            this.skin = newMatrixArray(k);
            this.ibm = newMatrixArray(k);
            for (int i = 0; i < k; i++) {
                setColumnMajor(ibm[i], model.skin.inverseBind, i * 16);
            }
        } else {
            this.skin = newMatrixArray(0);
            this.ibm = newMatrixArray(0);
        }
        this.outPos = model.mesh().positions.clone();

        // 空间补偿（实测结论，不是猜）：world(joint) × inverseBind 在绑定姿态下
        // 得到的不是单位阵，而是一个固定的 -90°X 旋转 —— 顶点在 mesh 空间是 Z-up
        // （z 98..150 是离地高度），而节点世界矩阵是 Y-up（joint0 的 y=145.87 才是高度）。
        // 导出时 SSJJ_Mesh 节点写成了 identity，缺了这个轴变换。
        // 这里用 joint0 反推一次并固定下来：skin = bindComp × world(joint) × inverseBind。
        if (hasSkin && skin.length > 0) {
            solve();
            Matrix4f raw = new Matrix4f(world[model.skin.joints[0]]).mul(ibm[0]);
            bindComp.set(raw).invert();
        }
    }

    public int jointCount() {
        return skin.length;
    }

    /** 绑定姿态补偿矩阵（诊断用）：应等于 inverse(world(joint0) × inverseBind[0])。 */
    public Matrix4f bindCompensation() {
        return new Matrix4f(bindComp);
    }

    public int vertexCount() {
        return outPos.length / 3;
    }

    /**
     * 用一个「骨名 → [px,py,pz, qx,qy,qz,qw]」的姿势表驱动骨架。
     *
     * <p>来自 {@code .anm} 的 idle 帧（原版握枪姿势），而不是 glTF 的 bind pose。
     * 绑不上的骨名忽略（模型里没有对应的就用默认 TRS）。</p>
     */
    public void evaluatePose(java.util.Map<String, float[]> pose) {
        resetTrs();
        if (pose != null) {
            for (int i = 0; i < model.nodes.length; i++) {
                float[] v = pose.get(model.nodes[i].name);
                if (v != null && v.length >= 7) {
                    nodeT[i][0] = v[0];
                    nodeT[i][1] = v[1];
                    nodeT[i][2] = v[2];
                    nodeR[i][0] = v[3];
                    nodeR[i][1] = v[4];
                    nodeR[i][2] = v[5];
                    nodeR[i][3] = v[6];
                }
            }
        }
        solve();
        skinAndDeform();
    }

    /** 绑定姿态：不采样任何动画，直接按 glTF 节点默认 TRS 求值。 */
    public void evaluateBind() {
        resetTrs();
        solve();
        skinAndDeform();
    }

    /**
     * 播放某个 clip 到指定时间（秒）。{@code clip} 为 null 时等价于 {@link #evaluateBind()}。
     * 超过末尾按钳制处理（不循环，循环由调用方取模）。
     */
    public void evaluate(GltfModel.Clip clip, float timeSec) {
        resetTrs();
        if (clip != null) {
            for (int i = 0; i < clip.channels.length; i++) {
                GltfModel.Channel ch = clip.channels[i];
                GltfModel.Sampler sm = clip.samplers[ch.sampler];
                int node = ch.node;
                if (node < 0 || node >= model.nodes.length) {
                    continue;
                }
                switch (ch.path) {
                    case "translation" -> sampleVec3(clip.times[ch.sampler], clip.values[ch.sampler], timeSec, nodeT[node]);
                    case "rotation" -> sampleQuat(clip.times[ch.sampler], clip.values[ch.sampler], timeSec, nodeR[node]);
                    case "scale" -> sampleVec3(clip.times[ch.sampler], clip.values[ch.sampler], timeSec, nodeS[node]);
                    default -> { /* weights / 其它通道本导出器不产出，忽略 */ }
                }
            }
        }
        solve();
        skinAndDeform();
    }

    /** 变形后的顶点（与 {@link GltfModel.Mesh#positions} 同长度，单位 cm）。 */
    public float[] positions() {
        return outPos;
    }

    // ------------------------------------------------------------------ 内部

    private void resetTrs() {
        for (int i = 0; i < model.nodes.length; i++) {
            System.arraycopy(model.nodes[i].translation, 0, nodeT[i], 0, 3);
            System.arraycopy(model.nodes[i].rotation, 0, nodeR[i], 0, 4);
            System.arraycopy(model.nodes[i].scale, 0, nodeS[i], 0, 3);
        }
    }

    private void solve() {
        for (int idx : order) {
            // 注意：必须先把 local 存到独立对象，再 set(world[parent]).mul(local)。
            // 写成 world[idx].set(world[p]).mul(world[idx]) 会变成自乘 —— set 已经
            // 把 local 覆盖掉了，结果是 world[p]²，整棵树都会错。
            Matrix4f local = tmpLocal;
            local.identity()
                    .translate(nodeT[idx][0], nodeT[idx][1], nodeT[idx][2])
                    .rotate(new Quaternionf(nodeR[idx][0], nodeR[idx][1], nodeR[idx][2], nodeR[idx][3]).normalize())
                    .scale(nodeS[idx][0], nodeS[idx][1], nodeS[idx][2]);
            int p = parent[idx];
            if (p >= 0) {
                world[idx].set(world[p]).mul(local);
            } else {
                world[idx].set(local);
            }
        }
        if (hasSkin) {
            for (int k = 0; k < skin.length; k++) {
                skin[k].set(bindComp).mul(world[model.skin.joints[k]]).mul(ibm[k]);
            }
        }
    }

    private void skinAndDeform() {
        float[] p = model.mesh().positions;
        if (!hasSkin) {
            System.arraycopy(p, 0, outPos, 0, p.length);
            return;
        }
        int[] joints = model.mesh.joints;
        float[] weights = model.mesh.weights;
        for (int v = 0; v < vertexCount(); v++) {
            float px = p[v * 3], py = p[v * 3 + 1], pz = p[v * 3 + 2];
            float x = 0f, y = 0f, z = 0f;
            for (int k = 0; k < 4; k++) {
                float w = weights[v * 4 + k];
                if (w == 0f) {
                    continue;
                }
                Matrix4f m = skin[joints[v * 4 + k]];
                x += w * (m.m00() * px + m.m10() * py + m.m20() * pz + m.m30());
                y += w * (m.m01() * px + m.m11() * py + m.m21() * pz + m.m31());
                z += w * (m.m02() * px + m.m12() * py + m.m22() * pz + m.m32());
            }
            outPos[v * 3] = x;
            outPos[v * 3 + 1] = y;
            outPos[v * 3 + 2] = z;
        }
    }

    private int[] topologicalOrder() {
        int n = model.nodes.length;
        int[] depth = new int[n];
        for (int i = 0; i < n; i++) {
            int d = 0, cur = i;
            while (parent[cur] >= 0) {
                cur = parent[cur];
                if (++d > n) {
                    throw new IllegalStateException("节点层级存在环");
                }
            }
            depth[i] = d;
        }
        Integer[] boxed = new Integer[n];
        for (int i = 0; i < n; i++) {
            boxed[i] = i;
        }
        Arrays.sort(boxed, (a, b) -> Integer.compare(depth[a], depth[b]));
        int[] out = new int[n];
        for (int i = 0; i < n; i++) {
            out[i] = boxed[i];
        }
        return out;
    }

    private static Matrix4f[] newMatrixArray(int n) {
        Matrix4f[] arr = new Matrix4f[n];
        for (int i = 0; i < n; i++) {
            arr[i] = new Matrix4f();
        }
        return arr;
    }

    /** glTF 的矩阵是列主序，JOML 的 16 参构造同样按列接收，逐位直填即可。 */
    private static void setColumnMajor(Matrix4f dst, float[] src, int off) {
        dst.set(src[off], src[off + 1], src[off + 2], src[off + 3],
                src[off + 4], src[off + 5], src[off + 6], src[off + 7],
                src[off + 8], src[off + 9], src[off + 10], src[off + 11],
                src[off + 12], src[off + 13], src[off + 14], src[off + 15]);
    }

    private static int findSegment(float[] times, float t) {
        int lo = 0, hi = times.length - 1;
        if (t <= times[0]) {
            return 0;
        }
        if (t >= times[hi]) {
            return hi - 1 < 0 ? 0 : hi - 1;
        }
        while (lo + 1 < hi) {
            int mid = (lo + hi) >>> 1;
            if (times[mid] <= t) {
                lo = mid;
            } else {
                hi = mid;
            }
        }
        return lo;
    }

    private static void sampleVec3(float[] times, float[] values, float t, float[] out) {
        int i = findSegment(times, t);
        if (i + 1 >= times.length) {
            out[0] = values[i * 3];
            out[1] = values[i * 3 + 1];
            out[2] = values[i * 3 + 2];
            return;
        }
        float t0 = times[i], t1 = times[i + 1];
        float a = t1 - t0 <= 1e-6f ? 0f : (t - t0) / (t1 - t0);
        a = Math.max(0f, Math.min(1f, a));
        for (int k = 0; k < 3; k++) {
            out[k] = values[i * 3 + k] + (values[(i + 1) * 3 + k] - values[i * 3 + k]) * a;
        }
    }

    private static void sampleQuat(float[] times, float[] values, float t, float[] out) {
        int i = findSegment(times, t);
        if (i + 1 >= times.length) {
            System.arraycopy(values, i * 4, out, 0, 4);
            return;
        }
        float t0 = times[i], t1 = times[i + 1];
        float a = t1 - t0 <= 1e-6f ? 0f : (t - t0) / (t1 - t0);
        a = Math.max(0f, Math.min(1f, a));
        Quaternionf q0 = new Quaternionf(values[i * 4], values[i * 4 + 1], values[i * 4 + 2], values[i * 4 + 3]);
        Quaternionf q1 = new Quaternionf(values[(i + 1) * 4], values[(i + 1) * 4 + 1],
                values[(i + 1) * 4 + 2], values[(i + 1) * 4 + 3]);
        q0.slerp(q1, a);
        out[0] = q0.x;
        out[1] = q0.y;
        out[2] = q0.z;
        out[3] = q0.w;
    }
}
