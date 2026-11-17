package com.ssjj.port.weapon;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * 原版武器规格的运行时视图。
 *
 * 数据由 tools/build_weapon_spec.py 从
 *   Game source/06_singleplayer/tables_json/Weapon.json (+ 关联表)
 *   Game source/02_managed_src/.../AwmLegendSpreadLogic.cs 等源码
 * 生成，运行时只读，不硬编码任何手感参数。
 */
public final class WeaponSpec {

    private final JsonObject root;

    private WeaponSpec(JsonObject root) {
        this.root = root;
    }

    public static WeaponSpec load(String id) {
        String path = "/assets/ssjjport/spec/" + id + ".json";
        try (InputStream in = WeaponSpec.class.getResourceAsStream(path)) {
            if (in == null) {
                throw new IllegalStateException("[ssjjport] missing spec resource: " + path);
            }
            String text = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            return new WeaponSpec(JsonParser.parseString(text).getAsJsonObject());
        } catch (IOException e) {
            throw new IllegalStateException("[ssjjport] cannot read " + path, e);
        }
    }

    public JsonObject raw() {
        return root;
    }

    public String id() {
        return str(root, "id");
    }

    public String displayName() {
        return str(root, "displayName");
    }

    // ------------------------------------------------------------ fire
    public int fireIntervalMs() {
        return obj(root, "fire").get("intervalMs").getAsInt();
    }

    public double rpm() {
        return obj(root, "fire").get("rpm").getAsDouble();
    }

    public int bulletsPerShot() {
        return obj(root, "fire").get("bulletsPerShot").getAsInt();
    }

    // ------------------------------------------------------------ ammo
    public int clipSize() {
        return obj(root, "ammo").get("clip").getAsInt();
    }

    public int carrySize() {
        return obj(root, "ammo").get("carry").getAsInt();
    }

    public String reloadType() {
        return str(obj(root, "ammo"), "reloadType");
    }

    public String reloadDurationRule() {
        return str(obj(root, "ammo"), "reloadDurationRule");
    }

    // ------------------------------------------------------------ spread
    public String spreadType() {
        return str(obj(root, "spread"), "type");
    }

    public JsonObject spreadParams() {
        return obj(obj(root, "spread"), "params");
    }

    public int spreadLength2D1() {
        return obj(root, "spread").get("length2D1").getAsInt();
    }

    public int spreadLength2D2() {
        return obj(root, "spread").get("length2D2").getAsInt();
    }

    public double defaultAccuracy() {
        return obj(root, "spread").get("defaultAccuracy").getAsDouble();
    }

    // ------------------------------------------------------------ movement / recoil
    public double kickbackParam() {
        return obj(root, "kickback").get("param").getAsDouble();
    }

    public List<Double> movementParams() {
        List<Double> out = new ArrayList<>();
        for (var e : obj(root, "movement").getAsJsonArray("params")) {
            out.add(e.getAsDouble());
        }
        return out;
    }

    // ------------------------------------------------------------ animation
    public String animationWeaponName() {
        return str(obj(root, "animation"), "weaponName");
    }

    public String raiseType() {
        return str(obj(root, "animation"), "raiseType");
    }

    public JsonArray clips() {
        return obj(root, "animation").getAsJsonArray("clips");
    }

    /** 按 clip id 查时长（秒）；原版换弹/抬枪节奏由动画时长驱动。 */
    public double clipLengthS(String clipId) {
        for (var e : clips()) {
            JsonObject c = e.getAsJsonObject();
            if (clipId.equals(str(c, "id"))) {
                return c.get("lengthS").getAsDouble();
            }
        }
        return -1.0;
    }

    public JsonArray meleeFrameChain() {
        return obj(root, "melee").getAsJsonArray("frameChain");
    }

    // ------------------------------------------------------------ helpers
    private static JsonObject obj(JsonObject o, String key) {
        return o.getAsJsonObject(key);
    }

    private static String str(JsonObject o, String key) {
        return o.has(key) && !o.get(key).isJsonNull() ? o.get(key).getAsString() : "";
    }
}
