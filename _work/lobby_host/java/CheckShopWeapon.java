import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class CheckShopWeapon {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/lobby_host/cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
        Map<?,?> sw = (Map<?,?>) m.get("shop_weapon");
        int count = 0;
        for (Object k : sw.keySet()) {
            System.out.println("Key: [" + k + "] -> " + sw.get(k));
            if (++count >= 3) break;
        }
    }
}
