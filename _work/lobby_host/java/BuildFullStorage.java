import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.nio.file.*;
import java.util.*;

public class BuildFullStorage {
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
        Map<?, ?> m = (Map<?, ?>) new Amf3Decoder(b).decodeOne();

        File sf = new File("d:/逆向/SSJJ双塔惊魂/_work/storage_grand_slam.bin");
        ByteArrayOutputStream baos = new ByteArrayOutputStream(1024 * 1024 * 8);
        DataOutputStream dos = new DataOutputStream(baos);

        int totalCount = 0;

        // 1. shop_weapon (Type 1)
        Map<?, ?> weapons = (Map<?, ?>) m.get("shop_weapon");
        if (weapons != null) {
            for (var e : weapons.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 10000000.0 + tid;
                writeItem(dos, sid, 1, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + weapons.size() + " weapons (Type 1)");
        }

        // 2. shop_avatar (Type 2)
        Map<?, ?> avatars = (Map<?, ?>) m.get("shop_avatar");
        if (avatars != null) {
            for (var e : avatars.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 20000000.0 + tid;
                writeItem(dos, sid, 2, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + avatars.size() + " roles (Type 2)");
        }

        // 3. shop_item (Type 3) - Props, Rename cards, Megaphones, EXP cards, etc.
        Map<?, ?> items = (Map<?, ?>) m.get("shop_item");
        if (items != null) {
            for (var e : items.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 30000000.0 + tid;
                writeItem(dos, sid, 3, tid, -1, 0, 9999);
                totalCount++;
            }
            System.out.println("Exported " + items.size() + " prop items (Type 3)");
        }

        // 4. shop_compositePack (Type 4) - Packs & Gift Boxes
        Map<?, ?> packs = (Map<?, ?>) m.get("shop_compositePack");
        if (packs != null) {
            for (var e : packs.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 40000000.0 + tid;
                writeItem(dos, sid, 4, tid, -1, 0, 99);
                totalCount++;
            }
            System.out.println("Exported " + packs.size() + " packs (Type 4)");
        }

        // 5. shop_skin (Type 8) - All 525 weapon skins
        Map<?, ?> skins = (Map<?, ?>) m.get("shop_skin");
        if (skins != null) {
            for (var e : skins.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 80000000.0 + tid;
                writeItem(dos, sid, 8, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + skins.size() + " skins (Type 8)");
        }

        // 6. shop_item_personalise (Type 10) - Sprays, chat bubbles, kill icons
        Map<?, ?> pers = (Map<?, ?>) m.get("shop_item_personalise");
        if (pers != null) {
            for (var e : pers.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 100000000.0 + tid;
                writeItem(dos, sid, 10, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + pers.size() + " personalize items/sprays (Type 10)");
        }

        // 7. dyeing_box (Type 11) - Weapon dyes
        Map<?, ?> dyes = (Map<?, ?>) m.get("dyeing_box");
        if (dyes != null) {
            for (var e : dyes.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 110000000.0 + tid;
                writeItem(dos, sid, 11, tid, -1, 0, 99);
                totalCount++;
            }
            System.out.println("Exported " + dyes.size() + " dye boxes (Type 11)");
        }

        // 8. shop_weapon_slot (Type 15) - Weapon accessories & reform slots
        Map<?, ?> accSlots = (Map<?, ?>) m.get("shop_weapon_slot");
        if (accSlots != null) {
            for (var e : accSlots.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 150000000.0 + tid;
                writeItem(dos, sid, 15, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + accSlots.size() + " weapon accessories (Type 15)");
        }

        // 9. shop_avatarParts (Type 16) - 370 character accessories/wings/masks
        Map<?, ?> parts = (Map<?, ?>) m.get("shop_avatarParts");
        if (parts != null) {
            for (var e : parts.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 16000000.0 + tid;
                writeItem(dos, sid, 16, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + parts.size() + " avatar parts (Type 16)");
        }

        // 10. medal (Type 17) - Medals and Titles
        Map<?, ?> medals = (Map<?, ?>) m.get("medal");
        if (medals != null) {
            for (var e : medals.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 170000000.0 + tid;
                writeItem(dos, sid, 17, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + medals.size() + " medals/titles (Type 17)");
        }

        // 11. shop_ring (Type 21) - Rings
        Map<?, ?> rings = (Map<?, ?>) m.get("shop_ring");
        if (rings != null) {
            for (var e : rings.entrySet()) {
                int tid = Integer.parseInt(String.valueOf(e.getKey()));
                double sid = 210000000.0 + tid;
                writeItem(dos, sid, 21, tid, -1, 0, 1);
                totalCount++;
            }
            System.out.println("Exported " + rings.size() + " rings (Type 21)");
        }

        dos.close();

        // Write final file with totalCount prepended
        DataOutputStream fdos = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(sf)));
        fdos.writeInt(totalCount);
        fdos.write(baos.toByteArray());
        fdos.close();
        System.out.println("Successfully generated storage_grand_slam.bin with " + totalCount + " TOTAL ITEMS!");
    }

    private static void writeItem(DataOutputStream dos, double id, int type, int tid, int equipedBag, int equipedBoom, int amount) throws IOException {
        dos.writeDouble(id);
        dos.writeInt(type);
        dos.writeInt(tid);
        dos.writeInt(equipedBag);
        dos.writeInt(equipedBoom);
        dos.writeInt(amount);
    }
}
