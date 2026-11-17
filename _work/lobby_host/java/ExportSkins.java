import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class ExportSkins {
    public static void main(String[] args) throws Exception {
        String path = "d:/逆向/SSJJ双塔惊魂/_work/GameData.final.bin";
        byte[] bytes = Files.readAllBytes(Paths.get(path));
        Amf3Decoder dec = new Amf3Decoder(bytes);
        Map<?, ?> root = (Map<?, ?>) dec.decodeOne();

        Map<?, ?> skins = (Map<?, ?>) root.get("shop_skin");
        System.out.println("Total shop_skin entries: " + (skins != null ? skins.size() : 0));

        if (skins != null) {
            int count = 0;
            StringBuilder sb = new StringBuilder("[\n");
            boolean first = true;
            for (var e : skins.entrySet()) {
                count++;
                if (e.getValue() instanceof Map<?, ?> sm) {
                    Object id = sm.get("id");
                    Object name = sm.get("name");
                    Object weaponId = sm.get("weaponId");
                    Object codeName = sm.get("codeName");
                    Object res = sm.get("res");
                    Object skinType = sm.get("skinType");
                    if (id == null) continue;
                    if (!first) sb.append(",\n");
                    first = false;
                    sb.append(String.format("  {\"id\": %s, \"name\": \"%s\", \"weaponId\": \"%s\", \"codeName\": \"%s\", \"res\": \"%s\", \"skinType\": %s}",
                        id, escape(String.valueOf(name)), escape(String.valueOf(weaponId)),
                        escape(String.valueOf(codeName)), escape(String.valueOf(res)), skinType != null ? skinType : 0));
                }
            }
            sb.append("\n]\n");
            Files.writeString(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/all_skins.json"), sb.toString());
            System.out.println("Exported all_skins.json with " + count + " items!");
        }
    }

    static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
