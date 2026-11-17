package com.ssjj.port.render;

import com.ssjj.port.SsjjPort;
import com.wf.gemrender.asset.GemRenderModels;
import com.wf.gemrender.asset.ModelCache;
import com.wf.gemrender.direct.DirectPass;
import com.wf.gemrender.direct.DirectRenderer;
import com.wf.gemrender.fabric.HandRenderEvents;
import com.wf.gemrender.gltf.GemRenderGltfModel;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.render.OverlayTexture;
import net.minecraft.item.Item;
import net.minecraft.util.Identifier;
import org.joml.Matrix4f;

/**
 * 用 GemRender 画第一人称的手 + 枪。
 *
 * <p><b>为什么不是 GemRenderItemRenderer</b>：它继承的是 {@code BuiltinModelItemRenderer}
 * （Yarn: {@code class_756}），那是「builtin/entity 物品模型」的抽象基类，不是 Fabric 的
 * {@code BuiltinItemRenderer} 接口，无法通过 {@code BuiltinItemRendererRegistry} 注册，
 * 第一人称也走不到它。GemRender 自己给的第一人称入口是
 * {@link HandRenderEvents#BEFORE_HAND} + {@link DirectRenderer#submit} 到
 * {@link DirectPass#HAND}。</p>
 *
 * <p><b>为什么位置能自动对</b>：{@code beforeHand} 交给我们的是原版第一人称的
 * {@code MatrixStack}（已经包含手持位置），直接把它当模型变换提交即可，
 * 不需要我们手搓相机矩阵。</p>
 */
public final class GemRenderBridge {

    private static final Identifier FP_MODEL = Identifier.of("ssjjport", "fp/fp.glb");

    /** 声明即注册；static final 保证资源重载后自动重新导入。 */
    private static final ModelCache.Handle<GemRenderGltfModel> HANDLE =
            GemRenderModels.handle(FP_MODEL);

    private static boolean registered;
    private static boolean attempted;
    private static boolean readyLogged;
    private static boolean drewOnce;

    public static boolean available() {
        return FabricLoader.getInstance().isModLoaded("gemrender");
    }

    public static boolean isRegistered() {
        return registered;
    }

    private static GemRenderGltfModel model() {
        GemRenderGltfModel m = HANDLE.get();
        if (m != null && !readyLogged) {
            readyLogged = true;
            SsjjPort.LOG.info("[ssjjport] GemRender 模型就绪: joints={} slots={}", m.jointCount(), m.slots());
        }
        return m;
    }

    public static synchronized boolean register(Identifier itemId, Item item) {
        if (registered) {
            return true;
        }
        if (attempted) {
            return false;
        }
        attempted = true;
        if (!available()) {
            SsjjPort.LOG.warn("[ssjjport] GemRender 未安装，回退到内置 viewmodel pass");
            return false;
        }
        try {
            HandRenderEvents.BEFORE_HAND.register((matrices, buffers, light, tickDelta) -> {
                MinecraftClient mc = MinecraftClient.getInstance();
                if (mc.player == null || !mc.player.getMainHandStack().isOf(item)) {
                    return;
                }
                GemRenderGltfModel m = model();
                if (m == null) {
                    return;   // 还在后台导入，本帧不画
                }
                // fp.glb 的顶点已在导出时烘焙到 MC 相机空间（tools/sjfp2glb_static.py），
                // 所以这里必须用单位阵——绝不能叠加原版手持变换，否则位置双重偏移。
                Matrix4f mat = new Matrix4f();
                // idle = hand_man.anm 的 TORSO_STAND 帧（逆向原始数据，44 骨 TRS），
                // 已转成 glTF animation 烘在 fp.glb 里，播 0 时刻即原版握枪姿势。
                com.wf.gemrender.gltf.GltfAnimation anim = null;
                try {
                    anim = m.animation("idle");
                } catch (Throwable ignored) {
                }
                DirectRenderer.submit(m, anim, 0f, mat, light,
                        OverlayTexture.DEFAULT_UV, -1, DirectPass.HAND);
                if (!drewOnce) {
                    drewOnce = true;
                    SsjjPort.LOG.info("[ssjjport] GemRender 首帧提交完成: item={}", itemId);
                }
            });
            registered = true;
            SsjjPort.LOG.info("[ssjjport] GemRender BEFORE_HAND 已注册: item={} asset={}", itemId, FP_MODEL);
        } catch (Throwable t) {
            SsjjPort.LOG.error("[ssjjport] GemRender 注册失败", t);
        }
        return registered;
    }

    private GemRenderBridge() {
    }
}
