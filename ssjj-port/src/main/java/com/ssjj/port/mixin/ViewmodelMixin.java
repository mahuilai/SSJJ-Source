package com.ssjj.port.mixin;

import com.ssjj.port.render.ViewmodelPass;
import net.minecraft.client.network.ClientPlayerEntity;
import net.minecraft.client.render.VertexConsumerProvider;
import net.minecraft.client.render.item.HeldItemRenderer;
import net.minecraft.client.util.math.MatrixStack;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * 接管第一人称视模型渲染。
 *
 * <p>目标方法是 {@code HeldItemRenderer.renderItem(float, MatrixStack,
 * VertexConsumerProvider.Immediate, ClientPlayerEntity, int)} —— 原版渲染双手的入口。
 * 在 HEAD 处：手持本模组的枪时走我们自己的 viewmodel pass（清深度 + 独立 FOV），
 * 然后 cancel 掉原版手臂。</p>
 *
 * <p>用 Yarn 方法名 + 方法描述符定位，不写死混淆名；refmap 由 Loom 生成。</p>
 */
@Mixin(HeldItemRenderer.class)
public class ViewmodelMixin {

    @Inject(
            method = "renderItem(FLnet/minecraft/client/util/math/MatrixStack;"
                    + "Lnet/minecraft/client/render/VertexConsumerProvider$Immediate;"
                    + "Lnet/minecraft/client/network/ClientPlayerEntity;I)V",
            at = @At("HEAD"),
            cancellable = true)
    private void ssjjport$renderViewmodel(float tickDelta, MatrixStack matrices,
                                          VertexConsumerProvider.Immediate buffers,
                                          ClientPlayerEntity player, int light,
                                          CallbackInfo ci) {
        if (ViewmodelPass.render(matrices, buffers, player, light)) {
            ci.cancel();
        }
    }
}
