import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class DumpGameData {
    public static void main(String[] args) throws Exception {
        String path1 = "d:/逆向/SSJJ双塔惊魂/_work/GameData.final.bin";
        byte[] b1 = Files.readAllBytes(Paths.get(path1));
        System.out.println("Decoding GameData.final.bin (" + b1.length + " bytes)...");
        Amf3Decoder dec1 = new Amf3Decoder(b1);
        Object obj1 = dec1.decodeOne();
        if (obj1 instanceof Map<?, ?> m1) {
            System.out.println("GameData tables count: " + m1.size());
            for (Object k : m1.keySet()) {
                Object v = m1.get(k);
                int count = (v instanceof Map<?, ?> vm) ? vm.size() : -1;
                if (count > 0 || String.valueOf(k).contains("weapon") || String.valueOf(k).contains("avatar") || String.valueOf(k).contains("item") || String.valueOf(k).contains("spray")) {
                    System.out.println("  Table: " + k + " (rows: " + count + ")");
                }
            }
            // Detail for shop_weapon
            Object sw = m1.get("shop_weapon");
            if (sw instanceof Map<?, ?> swMap) {
                System.out.println("\n--- shop_weapon details: total " + swMap.size() + " ---");
                int shown = 0;
                for (var e : swMap.entrySet()) {
                    System.out.println("  Weapon key=" + e.getKey() + " val=" + e.getValue());
                    if (++shown >= 3) break;
                }
            }
            // Detail for shop_avatar
            Object sa = m1.get("shop_avatar");
            if (sa instanceof Map<?, ?> saMap) {
                System.out.println("\n--- shop_avatar details: total " + saMap.size() + " ---");
                int shown = 0;
                for (var e : saMap.entrySet()) {
                    System.out.println("  Avatar key=" + e.getKey() + " val=" + e.getValue());
                    if (++shown >= 3) break;
                }
            }
            // Detail for shop_item
            Object si = m1.get("shop_item");
            if (si instanceof Map<?, ?> siMap) {
                System.out.println("\n--- shop_item details: total " + siMap.size() + " ---");
                int shown = 0;
                for (var e : siMap.entrySet()) {
                    System.out.println("  Item key=" + e.getKey() + " val=" + e.getValue());
                    if (++shown >= 3) break;
                }
            }
        }
    }
}
