package com.ssjj.port.render;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mojang.blaze3d.systems.RenderSystem;
import com.mojang.blaze3d.systems.VertexSorter;
import com.ssjj.port.SsjjPort;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.network.ClientPlayerEntity;
import net.minecraft.client.render.RenderLayer;
import net.minecraft.client.render.VertexConsumer;
import net.minecraft.client.render.VertexConsumerProvider;
import net.minecraft.client.util.math.MatrixStack;
import net.minecraft.util.Identifier;
import org.joml.Matrix4f;
import org.joml.Matrix4fStack;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * 第一人称视模型独立渲染通道（viewmodel pass）：手 + 枪。
 *
 * <p>三件事普通物品渲染做不到：</p>
 * <ol>
 *   <li><b>不穿墙</b>：世界画完之后 {@code clearDepth}，视模型永远在最前。</li>
 *   <li><b>透视固定</b>：用 {@link net.minecraft.client.render.GameRenderer#getBasicProjectionMatrix(double)}
 *       的独立投影（原版 HandCamera FOV 75），不随玩家 FOV 变。</li>
 *   <li><b>空间独立</b>：modelview 压成单位阵，模型直接按相机空间提交。</li>
 * </ol>
 *
 * <p><b>手和枪不是同一套空间</b>（原版如此，不是 bug）：sjfp 导出文件里
 * hand 标 "Unity XYZ"（z 98..150 是前臂延伸方向），gun 标 "SSJJ view XYZ"
 * （z -22..10，已烘焙到相机相对空间）。所以两者各有一套独立变换，参数都在 config。</p>
 */
public final class ViewmodelPass {

    /** 纹理 id 必须写完整资源路径：MC 不会自动补 textures/ 前缀和 .png。 */
    private static final Identifier TEX_HAND = Identifier.of("ssjjport", "textures/fp/awm.png");
    private static final Identifier TEX_GUN = Identifier.of("ssjjport", "textures/fp/gun.png");
    private static final int FULL_LIGHT = 0xF000F0;

    private static GltfModel handModel;
    private static SkeletonPose handPose;
    private static GltfModel gunModel;
    private static Map<String, float[]> idlePose;
    private static boolean loadFailed;
    private static boolean firstDrawLogged;

    public static boolean isReady() {
        return handPose != null;
    }

    public static boolean render(MatrixStack matrices, VertexConsumerProvider.Immediate buffers,
                                 ClientPlayerEntity player, int light) {
        if (player == null || !player.getMainHandStack().isOf(SsjjPort.AWM_LEGEND_T)) {
            return false;
        }
        // GemRender 接管时不 cancel 原版，让它的 hand pass 去画。
        if (VmConfig.get().useGemRender && GemRenderBridge.isRegistered()) {
            return false;
        }
        if (!ensureLoaded()) {
            return false;
        }

        VmConfig cfg = VmConfig.get();
        if (cfg.useIdlePose && idlePose != null) {
            handPose.evaluatePose(idlePose);
        } else {
            handPose.evaluateBind();
        }
        float[] handPos = handPose.positions();

        Matrix4fStack mv = RenderSystem.getModelViewStack();
        RenderSystem.backupProjectionMatrix();
        mv.pushMatrix();
        try {
            if (cfg.clearDepth) {
                RenderSystem.clearDepth(1.0);
            }
            MinecraftClient mc = MinecraftClient.getInstance();
            RenderSystem.setProjectionMatrix(
                    mc.gameRenderer.getBasicProjectionMatrix(cfg.fov), VertexSorter.BY_DISTANCE);
            mv.identity();
            RenderSystem.applyModelViewMatrix();

            // 先枪后手：手挡在枪前面，交给深度测试。
            if (gunModel != null && cfg.gunVisible) {
                MatrixStack gs = new MatrixStack();
                gs.multiplyPositionMatrix(gunTransform(cfg));
                emitMesh(gunModel, gunModel.mesh.positions, gs.peek().getPositionMatrix(),
                        buffers, light, TEX_GUN, 0);
                buffers.draw();
            }

            MatrixStack ms = new MatrixStack();
            ms.multiplyPositionMatrix(handTransform(cfg));
            emitMesh(handModel, handPos, ms.peek().getPositionMatrix(),
                    buffers, light, TEX_HAND, cfg.armSide);
            buffers.draw();
        } catch (Throwable t) {
            SsjjPort.LOG.error("[ssjjport] viewmodel pass failed", t);
        } finally {
            mv.popMatrix();
            RenderSystem.restoreProjectionMatrix();
            RenderSystem.applyModelViewMatrix();
        }

        if (!firstDrawLogged) {
            firstDrawLogged = true;
            SsjjPort.LOG.info("[ssjjport] viewmodel drawn: hand {}v/{}t, gun {}v/{}t, fov={} clearDepth={}",
                    handPose.vertexCount(), handModel.mesh.triangleCount(),
                    gunModel == null ? 0 : gunModel.mesh.vertexCount(),
                    gunModel == null ? 0 : gunModel.mesh.triangleCount(),
                    cfg.fov, cfg.clearDepth);
        }
        return true;
    }

    private static boolean ensureLoaded() {
        if (handPose != null) {
            return true;
        }
        if (loadFailed) {
            return false;
        }
        try {
            handModel = GltfModel.loadFromClasspath("/assets/ssjjport/fp/awm.gltf");
            handPose = new SkeletonPose(handModel);
            SsjjPort.LOG.info("[ssjjport] hand loaded: {}v / {}t / {} joints",
                    handPose.vertexCount(), handModel.mesh.triangleCount(), handPose.jointCount());
        } catch (Throwable t) {
            loadFailed = true;
            SsjjPort.LOG.error("[ssjjport] hand asset load failed; first-person override disabled", t);
            return false;
        }
        try {
            gunModel = GltfModel.loadFromClasspath("/assets/ssjjport/fp/gun.gltf");
            SsjjPort.LOG.info("[ssjjport] gun loaded: {}v / {}t",
                    gunModel.mesh.vertexCount(), gunModel.mesh.triangleCount());
        } catch (Throwable t) {
            gunModel = null;
            SsjjPort.LOG.error("[ssjjport] gun asset load failed (hand will still render)", t);
        }
        idlePose = loadPose("/assets/ssjjport/fp/idle_pose.json");
        if (idlePose != null) {
            SsjjPort.LOG.info("[ssjjport] idle pose loaded: {} bones (原版握枪姿势)", idlePose.size());
        }
        return true;
    }

    /** 单侧手臂中心（cm）：右手 y∈[42.5,91.3] 中心 66.9，左手对称。 */
    private static float armCenterCm(VmConfig cfg) {
        if (cfg.armSide > 0) {
            return 66.9f;
        }
        if (cfg.armSide < 0) {
            return -66.9f;
        }
        return 0f;
    }

    /**
     * 构建「模型空间 → MC 相机空间」变换。
     *
     * @param axes     三个轴名，依次对应屏幕右/上/前，前缀 - 取反
     * @param scaleCm  额外缩放倍率（顶点单位是 cm）
     * @param centerCm 该轴上要扣掉的居中偏移（cm），枪传 0
     */
    public static Matrix4f build(String axes, float scaleCm, float x, float y, float z, float centerCm) {
        float s = 0.01f * scaleCm;
        String[] ax = axes.split(",");
        int[] axis = new int[3];
        float[] sign = new float[3];
        for (int r = 0; r < 3; r++) {
            String a = r < ax.length ? ax[r].trim() : "";
            if (a.isEmpty()) {
                a = String.valueOf("xyz".charAt(r));
            }
            sign[r] = a.startsWith("-") ? -1f : 1f;
            String base = a.startsWith("-") ? a.substring(1) : a;
            axis[r] = switch (base.toLowerCase()) {
                case "x" -> 0;
                case "y" -> 1;
                case "z" -> 2;
                default -> throw new IllegalArgumentException("非法轴名: " + a);
            };
        }
        float[] v = new float[16];
        for (int r = 0; r < 3; r++) {
            v[axis[r] * 4 + r] = sign[r] * s;
        }
        // 列主序：平移在最后一列 v[12..14]
        v[12] = x;
        v[13] = y - s * centerCm;
        v[14] = z;
        v[15] = 1f;
        return new Matrix4f(v[0], v[1], v[2], v[3],
                v[4], v[5], v[6], v[7],
                v[8], v[9], v[10], v[11],
                v[12], v[13], v[14], v[15]);
    }

    /** 手模变换（含单侧手臂居中）。 */
    public static Matrix4f handTransform(VmConfig cfg) {
        return build(cfg.axes, cfg.scale, cfg.x, cfg.y, cfg.z, armCenterCm(cfg));
    }

    /** 枪模变换（枪顶点已在相机相对空间，不做居中）。 */
    public static Matrix4f gunTransform(VmConfig cfg) {
        return build(cfg.gunAxes, cfg.gunScale, cfg.gunX, cfg.gunY, cfg.gunZ, 0f);
    }

    /** 读「骨名 → 7 个 float（pos3 + quat4）」的姿势表。 */
    private static Map<String, float[]> loadPose(String res) {
        try (InputStream in = ViewmodelPass.class.getResourceAsStream(res)) {
            if (in == null) {
                return null;
            }
            JsonObject root = JsonParser.parseString(
                    new String(in.readAllBytes(), StandardCharsets.UTF_8)).getAsJsonObject();
            JsonObject bones = root.getAsJsonObject("bones");
            Map<String, float[]> out = new HashMap<>();
            for (var e : bones.entrySet()) {
                JsonArray a = e.getValue().getAsJsonArray();
                float[] v = new float[a.size()];
                for (int i = 0; i < v.length; i++) {
                    v[i] = a.get(i).getAsFloat();
                }
                out.put(e.getKey(), v);
            }
            return out;
        } catch (Throwable t) {
            SsjjPort.LOG.error("[ssjjport] idle pose load failed: " + res, t);
            return null;
        }
    }

    private static void emitMesh(GltfModel m, float[] pos, Matrix4f mat,
                                 VertexConsumerProvider.Immediate buffers, int light,
                                 Identifier tex, int armSide) {
        GltfModel.Mesh mesh = m.mesh;
        float[] uv = mesh.uvs;
        int[] idx = mesh.indices;
        float[] raw = mesh.positions;
        VertexConsumer vc = buffers.getBuffer(RenderLayer.getEntityCutoutNoCull(tex));

        for (int i = 0; i < idx.length; i += 3) {
            int a = idx[i], b = idx[i + 1], c = idx[i + 2];
            // 手模里两条手臂分居 y 正负两侧（跨 y=0 的三角形为 0）；枪不过滤。
            if (armSide != 0 && raw.length == pos.length) {
                float ya = raw[a * 3 + 1], yb = raw[b * 3 + 1], yc = raw[c * 3 + 1];
                boolean keep = armSide > 0
                        ? (ya > 0 && yb > 0 && yc > 0)
                        : (ya < 0 && yb < 0 && yc < 0);
                if (!keep) {
                    continue;
                }
            }
            emitVertex(vc, mat, pos, uv, a);
            emitVertex(vc, mat, pos, uv, c);
            emitVertex(vc, mat, pos, uv, b);
        }
    }

    private static void emitVertex(VertexConsumer vc, Matrix4f m, float[] pos, float[] uv, int v) {
        float x = pos[v * 3], y = pos[v * 3 + 1], z = pos[v * 3 + 2];
        float tx = m.m00() * x + m.m10() * y + m.m20() * z + m.m30();
        float ty = m.m01() * x + m.m11() * y + m.m21() * z + m.m31();
        float tz = m.m02() * x + m.m12() * y + m.m22() * z + m.m32();
        float u = v * 2 < uv.length ? uv[v * 2] : 0f;
        float w = v * 2 + 1 < uv.length ? uv[v * 2 + 1] : 0f;
        vc.vertex(tx, ty, tz)
                .color(255, 255, 255, 255)
                .texture(u, w)
                .overlay(net.minecraft.client.render.OverlayTexture.DEFAULT_UV)
                .light(FULL_LIGHT)
                .normal(0f, 1f, 0f);
    }

    private ViewmodelPass() {
    }
}
