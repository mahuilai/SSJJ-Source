package com.ssjj.port;

import com.ssjj.port.weapon.WeaponSpec;
import net.fabricmc.api.ModInitializer;
import net.minecraft.item.Item;
import net.minecraft.registry.Registries;
import net.minecraft.registry.Registry;
import net.minecraft.util.Identifier;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * SSJJ 专属模组入口（零 TaCZ 依赖）。
 *
 * 本工程从原版数据表/源码重建枪械手感与视模型，物品由本模组自行注册：
 * 不借用 TaCZ 的 IGun / IClientPlayerGunOperator / LocalPlayerDataHolder，
 * 也不加载 TaCZ 枪包或 TML poly_mesh。
 */
public final class SsjjPort implements ModInitializer {

    public static final String MOD_ID = "ssjjport";
    public static final Logger LOG = LoggerFactory.getLogger("ssjjport");

    /** 原版 awm_legend_t（血魔）对应的物品。行为逻辑后续挂 WeaponState。 */
    public static final Item AWM_LEGEND_T = new Item(new Item.Settings());

    public static WeaponSpec SPEC;

    @Override
    public void onInitialize() {
        SPEC = WeaponSpec.load("awm_legend_t");
        Registry.register(Registries.ITEM,
                Identifier.of(MOD_ID, "awm_legend_t"), AWM_LEGEND_T);

        LOG.info("[ssjjport] spec={} name={} interval={}ms rpm={} clip={}/{} spread={}",
                SPEC.id(), SPEC.displayName(), SPEC.fireIntervalMs(), SPEC.rpm(),
                SPEC.clipSize(), SPEC.carrySize(), SPEC.spreadType());
        LOG.info("[ssjjport] animation group={} raise={} reloadRule={}",
                SPEC.animationWeaponName(), SPEC.raiseType(), SPEC.reloadDurationRule());
        LOG.info("[ssjjport] registered item ssjjport:awm_legend_t (no TaCZ dependency)");
    }
}
