import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class FindRolesWithSkins {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
        Map<?,?> ra = (Map<?,?>) m.get("rootAvatar");
        int count = 0;
        for (var e : ra.entrySet()) {
            Map<?,?> row = (Map<?,?>) e.getValue();
            Object skins = row.get("skins");
            if (skins != null) {
                System.out.println("Role with skins: id=" + row.get("id") + " name=" + row.get("name") + " skins=" + skins);
                if (++count >= 10) break;
            }
        }
    }
}
