import com.strikegod.downloader.service.Amf3Decoder;
import java.io.File;
import java.nio.file.Files;
import java.util.*;

public class InspectTables {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(new File("../cache/gamedata1.amf3").toPath());
        Map<?, ?> m = (Map<?, ?>) new Amf3Decoder(b).decodeOne();

        String[] tables = {
            "shop_weapon", "shop_avatar", "shop_skin", "shop_avatarParts",
            "shop_item", "shop_compositePack", "shop_item_personalise",
            "dyeing_box", "weapon_accessory", "shop_weapon_slot", "medal",
            "global_achv_medal", "mount", "shop_ring"
        };

        for (String t : tables) {
            Object obj = m.get(t);
            if (obj instanceof Map<?, ?> sub) {
                System.out.println("Table (Map): " + t + " -> " + sub.size() + " items");
                if (!sub.isEmpty()) {
                    var first = sub.entrySet().iterator().next();
                    System.out.println("  Sample: " + first.getKey() + " -> " + first.getValue());
                }
            } else if (obj instanceof List<?> list) {
                System.out.println("Table (List): " + t + " -> " + list.size() + " items");
                if (!list.isEmpty()) {
                    System.out.println("  Sample: " + list.get(0));
                }
            } else {
                System.out.println("Table: " + t + " -> " + (obj != null ? obj.getClass().getName() : "null"));
            }
        }
    }
}
