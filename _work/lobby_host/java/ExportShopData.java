import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class ExportShopData {
    public static void main(String[] args) throws Exception {
        String path = "d:/逆向/SSJJ双塔惊魂/_work/GameData.final.bin";
        byte[] bytes = Files.readAllBytes(Paths.get(path));
        Amf3Decoder dec = new Amf3Decoder(bytes);
        Map<?, ?> root = (Map<?, ?>) dec.decodeOne();

        // 1. Export Weapons
        Map<?, ?> sw = (Map<?, ?>) root.get("shop_weapon");
        StringBuilder sbW = new StringBuilder("[\n");
        boolean first = true;
        for (var e : sw.entrySet()) {
            if (e.getValue() instanceof Map<?, ?> wm) {
                Object id = wm.get("id");
                Object name = wm.get("name");
                Object codeName = wm.get("codeName");
                Object weaponType = wm.get("weaponType");
                if (id == null) continue;
                if (!first) sbW.append(",\n");
                first = false;
                sbW.append(String.format("  {\"id\": %s, \"name\": \"%s\", \"codeName\": \"%s\", \"weaponType\": %s}",
                    id, escape(String.valueOf(name)), escape(String.valueOf(codeName)), weaponType != null ? weaponType : 0));
            }
        }
        sbW.append("\n]\n");
        Files.writeString(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/all_weapons.json"), sbW.toString());
        System.out.println("Exported all_weapons.json!");

        // 2. Export Roles
        Map<?, ?> sa = (Map<?, ?>) root.get("shop_avatar");
        StringBuilder sbR = new StringBuilder("[\n");
        first = true;
        for (var e : sa.entrySet()) {
            if (e.getValue() instanceof Map<?, ?> am) {
                Object id = am.get("id");
                Object name = am.get("name");
                Object carrer = am.get("carrer");
                Object group = am.get("group");
                Object roleType = am.get("roleType");
                Object isSkin = am.get("isSkin");
                Object rootAvatarId = am.get("rootAvatarId");
                if (id == null) continue;
                if (!first) sbR.append(",\n");
                first = false;
                sbR.append(String.format("  {\"id\": %s, \"name\": \"%s\", \"carrer\": \"%s\", \"group\": %s, \"roleType\": %s, \"isSkin\": %s, \"rootAvatarId\": %s}",
                    id, escape(String.valueOf(name)), escape(String.valueOf(carrer)),
                    group != null ? group : 1,
                    roleType != null ? roleType : 1,
                    isSkin != null ? isSkin : 0,
                    rootAvatarId != null ? rootAvatarId : 0));
            }
        }
        sbR.append("\n]\n");
        Files.writeString(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/all_roles.json"), sbR.toString());
        System.out.println("Exported all_roles.json!");
    }

    static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
