import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class FindRoleTid {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/lobby_host/cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();
        Map<?,?> ra = (Map<?,?>) m.get("rootAvatar");
        for (Object k : ra.keySet()) {
            Map<?,?> item = (Map<?,?>) ra.get(k);
            Object tid = item.get("tid");
            Object name = item.get("name");
            Object group = item.get("group");
            Object carrer = item.get("carrer");
            System.out.println("rootAvatar id=" + k + " -> tid=" + tid + ", group=" + group + ", carrer=" + carrer + ", name=" + name);
        }
    }
}
