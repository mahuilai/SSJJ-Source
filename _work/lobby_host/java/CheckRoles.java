import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class CheckRoles {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
        Map<?,?> ra = (Map<?,?>) m.get("rootAvatar");
        System.out.println("Total rootAvatar rows: " + ra.size());
        int count = 0;
        for (var e : ra.entrySet()) {
            Map<?,?> row = (Map<?,?>) e.getValue();
            System.out.println("id: " + row.get("id") + ", tid: " + row.get("tid") + ", name: " + row.get("name") + ", carrer: " + row.get("carrer"));
            if (++count >= 15) break;
        }
    }
}
