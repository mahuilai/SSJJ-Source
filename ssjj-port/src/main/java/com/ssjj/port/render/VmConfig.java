package com.ssjj.port.render;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.nio.file.Files;
import java.nio.file.Path;

/**
 * 第一人称视模型构图参数，写在 {@code config/ssjjport.json}，改完重启即可，不用重编译。
 *
 * <p>这些值是**构图微调**，不是「1:1 还原」的依据——真正的相机变换要从原版
 * {@code LoadFirstHandSystem.AdjustCameraTransform} 逐行移植。当前阶段先用一组
 * 能看见的默认值把渲染通道跑通，再逐项校准。</p>
 */
public final class VmConfig {

    /** 在 cm→m 基础上再乘的缩放。 */
    public float scale = 1.0f;
    /** 相机空间偏移（格）。x 右、y 上、z 前（负值为前方）。 */
    public float x = 0.25f;
    public float y = -0.15f;
    public float z = 0.45f;
    /**
     * 轴映射：三个逗号分隔的轴名，依次对应「屏幕右 / 屏幕上 / 相机前方」。
     * 单字母 x/y/z，前缀 - 表示取反。默认 {@code x,y,-z}。
     * 模型实测：x=掌宽、y=双臂分居±67cm、z=前臂延伸方向(98..150)。
     */
    public String axes = "x,y,-z";
    /**
     * 只渲染单侧手臂：0=全部（会出现两条），1=只留 y&gt;0 那侧，-1=只留 y&lt;0 那侧。
     * 模型里两条手臂分居 y 两侧，正常第一人称只需一条。
     */
    public int armSide = 1;

    // ---- 枪模（顶点已在相机相对空间，独立一套变换）----
    public boolean gunVisible = true;
    public float gunScale = 1.0f;
    public float gunX = 0.25f;
    public float gunY = -0.15f;
    public float gunZ = -0.90f;
    /** 枪：x=宽、y=枪长、z=高。映射到屏幕右/上/前 → 默认 {@code x,z,-y}。 */
    public String gunAxes = "x,z,-y";
    /** 独立视模型 FOV，原版 HandCamera 为 75。 */
    public float fov = 75.0f;
    /** 画之前是否清深度（让枪永远在前景，不穿墙）。 */
    public boolean clearDepth = true;
    /** 用 .anm 的 idle 帧（原版握枪姿势）替代 glTF bind pose。 */
    public boolean useIdlePose = true;
    /** 装了 GemRender 时把渲染交给它（我们不再 cancel 原版）。 */
    public boolean useGemRender = true;

    private static VmConfig INSTANCE;

    public static VmConfig get() {
        if (INSTANCE == null) {
            INSTANCE = load();
        }
        return INSTANCE;
    }

    public static void invalidate() {
        INSTANCE = null;
    }

    private static VmConfig load() {
        VmConfig c = new VmConfig();
        try {
            Path p = net.fabricmc.loader.api.FabricLoader.getInstance()
                    .getConfigDir().resolve("ssjjport.json");
            if (Files.exists(p)) {
                JsonObject o = JsonParser.parseString(Files.readString(p)).getAsJsonObject();
                if (o.has("scale")) c.scale = o.get("scale").getAsFloat();
                if (o.has("x")) c.x = o.get("x").getAsFloat();
                if (o.has("y")) c.y = o.get("y").getAsFloat();
                if (o.has("z")) c.z = o.get("z").getAsFloat();
                if (o.has("axes")) c.axes = o.get("axes").getAsString();
                if (o.has("armSide")) c.armSide = o.get("armSide").getAsInt();
                if (o.has("gunVisible")) c.gunVisible = o.get("gunVisible").getAsBoolean();
                if (o.has("gunScale")) c.gunScale = o.get("gunScale").getAsFloat();
                if (o.has("gunX")) c.gunX = o.get("gunX").getAsFloat();
                if (o.has("gunY")) c.gunY = o.get("gunY").getAsFloat();
                if (o.has("gunZ")) c.gunZ = o.get("gunZ").getAsFloat();
                if (o.has("gunAxes")) c.gunAxes = o.get("gunAxes").getAsString();
                if (o.has("fov")) c.fov = o.get("fov").getAsFloat();
                if (o.has("clearDepth")) c.clearDepth = o.get("clearDepth").getAsBoolean();
                if (o.has("useIdlePose")) c.useIdlePose = o.get("useIdlePose").getAsBoolean();
                if (o.has("useGemRender")) c.useGemRender = o.get("useGemRender").getAsBoolean();
            } else {
                Files.writeString(p, """
                        {
                          "scale": 1.0,
                          "x": 0.25, "y": -0.15, "z": 0.45,
                          "axes": "x,y,-z",
                          "armSide": 1,
                          "gunVisible": true,
                          "gunScale": 1.0,
                          "gunX": 0.25, "gunY": -0.15, "gunZ": -0.90,
                          "gunAxes": "x,z,-y",
                          "fov": 75.0,
                          "clearDepth": true,
                          "useIdlePose": true,
                          "useGemRender": true
                        }
                        """);
            }
        } catch (Exception e) {
            com.ssjj.port.SsjjPort.LOG.warn("[ssjjport] viewmodel config load failed, using defaults", e);
        }
        return c;
    }
}
