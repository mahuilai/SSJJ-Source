import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class CheckRileySkins {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
        Map<?,?> ra = (Map<?,?>) m.get("rootAvatar");
        Map<?,?> riley = (Map<?,?>) ra.get("3");
        if (riley == null) riley = (Map<?,?>) ra.get(3);
        System.out.println("Riley: " + riley);
        if (riley != null) {
            System.out.println("Riley skins: " + riley.get("skins"));
        }
        Map<?,?> skins = (Map<?,?>) m.get("shop_skin");
        System.out.println("Total shop_skin: " + (skins != null ? skins.size() : 0));
        if (skins != null) {
            int found = 0;
            for (var e : skins.entrySet()) {
                Map<?,?> s = (Map<?,?>) e.getValue();
                Object st = s.get("skinType");
                if (st != null && ((Number)st).intValue() == 2) {
                    System.out.println("Role skin: id=" + e.getKey() + " name=" + s.get("name") + " avatarId=" + s.get("avatarId") + " carrer=" + s.get("carrer"));
                    if (++found >= 15) break;
                }
            }
        }
    }
}
