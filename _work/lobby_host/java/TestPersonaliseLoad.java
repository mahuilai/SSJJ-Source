import com.strikegod.downloader.service.Amf3Decoder;
import java.nio.file.*;
import java.util.*;

public class TestPersonaliseLoad {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/lobby_host/cache/gamedata1.amf3"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();

        Map<?,?> pMap = (Map<?,?>) m.get("shop_item_personalise");
        System.out.println("Personalise count: " + pMap.size());

        Map<?,?> medMap = (Map<?,?>) m.get("medal");
        System.out.println("Medal count: " + medMap.size());

        Set<Integer> medalLines = new TreeSet<>();
        for (Object k : medMap.keySet()) {
            Map<?,?> item = (Map<?,?>) medMap.get(k);
            medalLines.add(((Number)item.get("medalLine")).intValue());
        }
        System.out.println("Unique medal lines count: " + medalLines.size());
    }
}
