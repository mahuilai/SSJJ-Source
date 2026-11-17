import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class CheckRootAvatar {
    public static void main(String[] args) throws Exception {
        String p1 = "d:/逆向/SSJJ双塔惊魂/_work/lobby_host/cache/gamedata1.amf3";
        String p2 = "d:/逆向/SSJJ双塔惊魂/_work/lobby_host/cache/gamedata2.amf3";
        for (String f : new String[]{p1, p2}) {
            if (!Files.exists(Paths.get(f))) {
                System.out.println("Not exists: " + f);
                continue;
            }
            byte[] b = Files.readAllBytes(Paths.get(f));
            Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
            Map<?,?> ra = (Map<?,?>) m.get("rootAvatar");
            if (ra != null) {
                System.out.println(f + " rootAvatar size: " + ra.size());
                int count = 0;
                for (Object k : ra.keySet()) {
                    System.out.println("  " + k + " -> " + ra.get(k));
                    if (++count > 5) break;
                }
            } else {
                System.out.println(f + " has no rootAvatar, keys: " + m.keySet());
            }
        }
    }
}
