import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class InspectGameData {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
        Map<?,?> cr = (Map<?,?>) m.get("channelRule");
        System.out.println("Keys: " + m.keySet());
        Map<?,?> ws = (Map<?,?>) m.get("weapon_storage");
        if (ws != null) {
            System.out.println("weapon_storage size: " + ws.size());
            for (Object k : ws.keySet()) {
                System.out.println("sample weapon_storage: " + k + " -> " + ws.get(k));
                break;
            }
        }
        Map<?,?> sw = (Map<?,?>) m.get("shop_weapon");
        if (sw != null) {
            System.out.println("shop_weapon size: " + sw.size());
            java.io.PrintWriter pw = new java.io.PrintWriter("d:/逆向/SSJJ双塔惊魂/_work/lobby_host/shop_weapon_map.json", "UTF-8");
            pw.println("{");
            int i = 0;
            for (Object k : sw.keySet()) {
                Map<?,?> item = (Map<?,?>) sw.get(k);
                String res = String.valueOf(item.get("res"));
                String codeName = String.valueOf(item.get("codeName"));
                String name = String.valueOf(item.get("name"));
                pw.printf("  \"%s\": {\"res\": \"%s\", \"codeName\": \"%s\", \"name\": \"%s\"}%s\n",
                    res, res, codeName, name.replace("\"", "\\\""), (++i == sw.size() ? "" : ","));
            }
            pw.println("}");
            pw.close();
            System.out.println("Exported " + i + " weapons to shop_weapon_map.json!");
        }
    }
}
