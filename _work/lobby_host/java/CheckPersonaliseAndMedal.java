import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class CheckPersonaliseAndMedal {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/lobby_host/cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();

        Map<?,?> p = (Map<?,?>) m.get("shop_item_personalise");
        System.out.println("shop_item_personalise count: " + (p != null ? p.size() : 0));
        if (p != null) {
            Set<Object> types = new TreeSet<>();
            for (Object k : p.keySet()) {
                Map<?,?> item = (Map<?,?>) p.get(k);
                types.add(item.get("type"));
            }
            System.out.println("personalise types: " + types);
        }

        Map<?,?> med = (Map<?,?>) m.get("medal");
        System.out.println("medal count: " + (med != null ? med.size() : 0));
        if (med != null) {
            Set<Object> lines = new TreeSet<>();
            for (Object k : med.keySet()) {
                Map<?,?> item = (Map<?,?>) med.get(k);
                lines.add(item.get("medalLine"));
            }
            System.out.println("medal lines: " + lines.size() + " unique lines -> " + lines);
        }
    }
}
