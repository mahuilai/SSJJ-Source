import com.strikegod.downloader.service.Amf3Encoder;
import com.strikegod.downloader.service.Amf3TypedObject;
import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;
import java.util.zip.Inflater;

public class LobbyLoginServer {
    static Path projectRoot() throws Exception {
        Path codeLocation = Paths.get(
            LobbyLoginServer.class.getProtectionDomain().getCodeSource().getLocation().toURI()
        ).toAbsolutePath().normalize();
        Path classesDir = Files.isDirectory(codeLocation) ? codeLocation : codeLocation.getParent();
        Path root = classesDir.resolve("../../..").normalize();
        if (!Files.isDirectory(root.resolve("_work").resolve("lobby_host"))) {
            throw new FileNotFoundException("Cannot locate project root from " + classesDir);
        }
        return root;
    }

    static byte[] inflate(byte[] data) throws Exception {
        Inflater inf = new Inflater();
        inf.setInput(data);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        while (!inf.finished()) {
            int n = inf.inflate(buf);
            if (n == 0) break;
            out.write(buf, 0, n);
        }
        inf.end();
        return out.toByteArray();
    }

    static Amf3TypedObject makeWeaponData(double storageId, String codeName, int tid) {
        var wd = new Amf3TypedObject("netdata.WeaponData", List.of(
            "storageId", "codeName", "durable", "permanent", "tid"), false);
        wd.set("storageId", storageId);
        wd.set("codeName", codeName);
        wd.set("durable", 1.0);
        wd.set("permanent", true);
        wd.set("tid", tid);
        return wd;
    }

    static Amf3TypedObject makeStorageExtBean(double id, double weaponStorageId) {
        var ext = new Amf3TypedObject("bean.StorageExtBean", List.of(
            "id", "model", "weaponStorageId", "worn", "useNum", "quenchId", "store", "texture", "tradeCount"), false);
        ext.set("id", id);
        ext.set("model", 0);
        ext.set("weaponStorageId", weaponStorageId);
        ext.set("worn", 0);
        ext.set("useNum", 0);
        ext.set("quenchId", 0);
        ext.set("store", false);
        ext.set("texture", "");
        ext.set("tradeCount", 0);
        return ext;
    }

    static Amf3TypedObject makeStorageBean(double id, int type, int tid, int equipedBag, int equipedBoom, int amount) {
        var sb = new Amf3TypedObject("bean.StorageBean", List.of(
            "id", "type", "tid", "damaged", "time", "moneyType", "cost",
            "equipedBag", "equipedBoom", "isDirty", "amount", "expiredTime",
            "expiredWarn", "selectFlag", "weaponStorageFlag", "isGlobalRoomAvailable",
            "equipedWeapon", "extBean"), false);
        sb.set("id", id);
        sb.set("type", type);
        sb.set("tid", tid);
        sb.set("damaged", 0);
        sb.set("time", 1700000000000.0);
        sb.set("moneyType", 1);
        sb.set("cost", 0);
        sb.set("equipedBag", equipedBag);
        sb.set("equipedBoom", equipedBoom);
        sb.set("isDirty", false);
        sb.set("amount", amount);
        sb.set("expiredTime", 0.0);
        sb.set("expiredWarn", 0);
        sb.set("selectFlag", 0);
        sb.set("weaponStorageFlag", 0);
        sb.set("isGlobalRoomAvailable", true);
        sb.set("equipedWeapon", 0.0);
        sb.set("extBean", (type == 8 || type == 1) ? makeStorageExtBean(id, 0.0) : null);
        return sb;
    }

    static Amf3TypedObject makeBagData(boolean isGlobalBag, Amf3TypedObject master, Amf3TypedObject secondary, Amf3TypedObject closed, Amf3TypedObject bom1) {
        var bd = new Amf3TypedObject("netdata.BagData", List.of(
            "masterWeapon", "secondaryWeapon", "closedWeapon", "bom1", "bom2", "bom3",
            "isGlobalBag", "bagDataScore"), false);
        bd.set("masterWeapon", master);
        bd.set("secondaryWeapon", secondary);
        bd.set("closedWeapon", closed);
        bd.set("bom1", bom1);
        bd.set("bom2", null);
        bd.set("bom3", null);
        bd.set("isGlobalBag", isGlobalBag);
        bd.set("bagDataScore", 1000);
        return bd;
    }

    static Amf3TypedObject makeAvatarBagData(int tid, int ctid) {
        var abd = new Amf3TypedObject("bean.AvatarBagData", List.of("rootAvatarTID", "rootAvatarCTID"), false);
        abd.set("rootAvatarTID", tid);
        abd.set("rootAvatarCTID", ctid);
        return abd;
    }

    static Amf3TypedObject makeRootAvatarData(int rootAvatarId, String career, double storageId) {
        var ra = new Amf3TypedObject("netdata.RootAvatarData", List.of(
            "uid", "rootAvatarId", "storageId", "storageSkinId", "envoyAppearanceId",
            "career", "careerSkin", "avatarLv", "expiredTime", "avatarPartDataMap",
            "rootAvatarSoundMap", "facadePartId", "propertyWingStorageId",
            "avatarTalentList", "luckyScore", "variantSkillList", "equipFlag",
            "careerColor", "careerSkinColor", "suitId"), false);
        ra.set("uid", 321282597);
        ra.set("rootAvatarId", rootAvatarId);
        ra.set("storageId", storageId);
        ra.set("storageSkinId", 0.0);
        ra.set("envoyAppearanceId", 0);
        ra.set("career", career);
        ra.set("careerSkin", "");
        ra.set("avatarLv", 1);
        ra.set("expiredTime", 0.0);
        ra.set("avatarPartDataMap", new LinkedHashMap<String, Object>());
        ra.set("rootAvatarSoundMap", new LinkedHashMap<String, Object>());
        ra.set("facadePartId", 0);
        ra.set("propertyWingStorageId", 0.0);
        ra.set("avatarTalentList", List.of());
        ra.set("luckyScore", 0);
        ra.set("variantSkillList", List.of());
        ra.set("equipFlag", 1);
        ra.set("careerColor", "");
        ra.set("careerSkinColor", "");
        ra.set("suitId", 0);
        return ra;
    }

    static Amf3TypedObject makeVip4399Bean() {
        var vip = new Amf3TypedObject("bean.ClientCharacterVipBean", List.of(
            "cid", "endTime", "lastTime", "point", "status", "totalDay", "totalPoint"), false);
        vip.set("cid", 100072528);
        vip.set("endTime", 0.0);
        vip.set("lastTime", 0.0);
        vip.set("point", 0);
        vip.set("status", 0);
        vip.set("totalDay", 0);
        vip.set("totalPoint", 0);
        return vip;
    }

    static Amf3TypedObject makeChannelInfo(int id, String name, int position, int allowedRoomTypeId) {
        var ch = new Amf3TypedObject("bean.ChannelInfo", List.of(
            "id", "name", "clientCount", "limitMinRank", "limitMaxRank", "isRecommend",
            "status", "type", "subType", "order", "maxClient", "limitMinLV",
            "limitMaxLV", "moreServerFlag", "position", "promiseToFightFlag",
            "maxRoom", "session", "allowedRoomTypeId"), false);
        ch.set("id", id);
        ch.set("name", name);
        ch.set("clientCount", 1);
        ch.set("limitMinRank", 1);
        ch.set("limitMaxRank", 100);
        ch.set("isRecommend", false);
        ch.set("status", 1);
        ch.set("type", 1);
        ch.set("subType", 0);
        ch.set("order", id);
        ch.set("maxClient", 1000);
        ch.set("limitMinLV", 1);
        ch.set("limitMaxLV", 100);
        ch.set("moreServerFlag", false);
        ch.set("position", position);
        ch.set("promiseToFightFlag", false);
        ch.set("maxRoom", null);
        ch.set("session", null);
        ch.set("allowedRoomTypeId", allowedRoomTypeId);
        return ch;
    }

    static Amf3TypedObject makeLobbyRoomChannel(int id, String name, int position, int allowedRoomTypeId) {
        var ch = new Amf3TypedObject("bean.ChannelInfo", List.of(
            "id", "name", "ip", "serverDomain", "port", "number", "maxClient", "limitMinLV", "limitMaxLV",
            "moreServerFlag", "position", "promiseToFightFlag", "maxRoom", "session",
            "allowedRoomTypeId"), false);
        ch.set("id", id);
        ch.set("name", name);
        ch.set("ip", "127.0.0.1");
        ch.set("serverDomain", "127.0.0.1");
        ch.set("port", 2000);
        ch.set("number", 0);
        ch.set("maxClient", 1000);
        ch.set("limitMinLV", 1);
        ch.set("limitMaxLV", 100);
        ch.set("moreServerFlag", false);
        ch.set("position", position);
        ch.set("promiseToFightFlag", false);
        ch.set("maxRoom", null);
        ch.set("session", null);
        ch.set("allowedRoomTypeId", allowedRoomTypeId);
        return ch;
    }

    static class WeaponMeta {
        int tid;
        int type; // 1=Master, 2=Secondary, 3=Melee, 4=Boom, 6=Tactical
        int subType;
        String codeName;
        String name;
        String res;
    }
    static Map<Integer, WeaponMeta> weaponMetaMap = new HashMap<>();

    static void loadWeaponMeta() {
        try {
            byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
            Map<?, ?> m = (Map<?, ?>) new Amf3Decoder(b).decodeOne();
            Map<?, ?> sw = (Map<?, ?>) m.get("shop_weapon");
            if (sw != null) {
                for (var e : sw.entrySet()) {
                    int tid = Integer.parseInt(String.valueOf(e.getKey()));
                    Map<?, ?> row = (Map<?, ?>) e.getValue();
                    WeaponMeta wm = new WeaponMeta();
                    wm.tid = tid;
                    wm.type = 1;
                    Object tObj = row.get("type");
                    if (tObj instanceof Number n) wm.type = n.intValue();
                    wm.subType = 1;
                    Object stObj = row.get("subType");
                    if (stObj instanceof Number n) wm.subType = n.intValue();
                    wm.codeName = String.valueOf(row.get("codeName"));
                    wm.name = String.valueOf(row.get("name"));
                    wm.res = String.valueOf(row.get("res"));
                    weaponMetaMap.put(tid, wm);
                }
                System.out.println("Loaded " + weaponMetaMap.size() + " weapon metadata entries!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static Map<String, Object> grandSlamStorageMap = new LinkedHashMap<>();
    static Map<String, Object> grandSlamRootAvatarMap = new LinkedHashMap<>();
    static Map<Integer, Integer> roleGroupMap = new LinkedHashMap<>();

    static volatile int roomSceneId = 12;
    static volatile int roomRaceType = 2003;
    static volatile int roomLimitNumber = 10;
    static volatile Amf3TypedObject currentRoomInfo = null;

    static int intField(Amf3TypedObject obj, String key, int defVal) {
        if (obj == null) return defVal;
        Object v = obj.fields().get(key);
        if (v instanceof Number n) return n.intValue();
        try { return Integer.parseInt(String.valueOf(v)); } catch (Exception e) { return defVal; }
    }

    static Amf3TypedObject toRoomInfoObject(Object raw) {
        if (raw instanceof Amf3TypedObject t) return t;
        if (!(raw instanceof Map<?, ?> m)) return null;
        List<String> keys = new ArrayList<>();
        for (Object k : m.keySet()) {
            String ks = String.valueOf(k);
            if (!"$class".equals(ks)) keys.add(ks);
        }
        String cls = m.get("$class") != null ? String.valueOf(m.get("$class")) : "bean.RoomInfo";
        var obj = new Amf3TypedObject(cls, keys, false);
        for (String k : keys) obj.set(k, m.get(k));
        return obj;
    }

    static Amf3TypedObject makeClientRoomUser(ProfileManager.Profile profile, int team) {
        var u = new Amf3TypedObject("bean.ClientRoomUser", List.of(
            "playerName", "characterId", "readyGame", "inGameServer", "team",
            "lv", "vipLv", "teamName", "teamId", "observerFlag",
            "dId", "dName", "lastInviteTime", "raceRankSect", "raceIsKing", "raceRankLv"
        ), false);
        u.set("playerName", profile.playerName);
        u.set("characterId", 1000200072528.0);
        u.set("readyGame", 1);
        u.set("inGameServer", false);
        u.set("team", team);
        u.set("lv", 91);
        u.set("vipLv", 15);
        u.set("teamName", "无端离线战队");
        u.set("teamId", 1);
        u.set("observerFlag", false);
        u.set("dId", 1);
        u.set("dName", "离线服");
        u.set("lastInviteTime", 0.0);
        u.set("raceRankSect", 5);
        u.set("raceIsKing", 0);
        u.set("raceRankLv", 25);
        return u;
    }

    static volatile Process activeBattleProc = null;

    static void launchBattleClient(String career, int bag, int sceneId, int raceType, int team, int allyBots, int enemyBots) {
        try {
            if (activeBattleProc != null && activeBattleProc.isAlive()) {
                System.out.println("[LobbyServer] Battle launcher already running; ignoring duplicate startGame.");
                return;
            }
            Path root = projectRoot();
            Path script = root.resolve("_work").resolve("launch_battle_from_lobby.py");
            if (!Files.isRegularFile(script)) throw new FileNotFoundException(script.toString());
            activeBattleProc = new ProcessBuilder(
                "python", script.toString(),
                "--career", career,
                "--bag", String.valueOf(bag),
                "--scene-id", String.valueOf(sceneId),
                "--race-type", String.valueOf(raceType),
                "--team", String.valueOf(team),
                "--ally-bots", String.valueOf(allyBots),
                "--enemy-bots", String.valueOf(enemyBots)
            ).directory(root.toFile()).start();
            System.out.println("[LobbyServer] Spawned " + script + " (career=" + career + ", bag=" + bag
                + ", scene=" + sceneId + ", race=" + raceType + ", team=" + team
                + ", ally=" + allyBots + ", enemy=" + enemyBots + ")");
        } catch (Exception e) {
            System.err.println("[LobbyServer] Failed to launch battle client: " + e.getMessage());
        }
    }

    static void loadStorageBinFile(String filePath) {
        try {
            File f = new File(filePath);
            if (f.exists()) {
                try (DataInputStream dis = new DataInputStream(new BufferedInputStream(new FileInputStream(f)))) {
                    int count = dis.readInt();
                    for (int i = 0; i < count; i++) {
                        double id = dis.readDouble();
                        int type = dis.readInt();
                        int tid = dis.readInt();
                        int equipedBag = dis.readInt();
                        int equipedBoom = dis.readInt();
                        int amount = dis.readInt();
                        Amf3TypedObject sb = makeStorageBean(id, type, tid, equipedBag, equipedBoom, amount);
                        grandSlamStorageMap.put(String.valueOf((long)id), sb);
                    }
                    System.out.println("Loaded " + count + " items from " + f.getName());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static void loadGrandSlamStorage() {
        try {
            Path root = projectRoot();
            loadStorageBinFile(root.resolve("_work").resolve("storage_grand_slam.bin").toString());

            // storage_grand_slam normally includes avatar parts; use the dedicated
            // snapshot only when that category is absent from the combined file.
            boolean hasAvatarParts = grandSlamStorageMap.values().stream().anyMatch(value ->
                value instanceof Amf3TypedObject bean && bean.fields().get("type") instanceof Number type && type.intValue() == 16);
            if (!hasAvatarParts) {
                loadStorageBinFile(root.resolve("_work").resolve("avatarparts_grand_slam.bin").toString());
            }

            // Load all 335 roles with exact career and group
            File rf2 = root.resolve("_work").resolve("roles_grand_slam_v2.bin").toFile();
            if (rf2.exists()) {
                try (DataInputStream rdis = new DataInputStream(new BufferedInputStream(new FileInputStream(rf2)))) {
                    int rcount = rdis.readInt();
                    byte[] cbuf = new byte[32];
                    for (int i = 0; i < rcount; i++) {
                        int rid = rdis.readInt();
                        rdis.readFully(cbuf);
                        int group = rdis.readInt();
                        int clen = 0;
                        while (clen < 32 && cbuf[clen] != 0) clen++;
                        String carrer = new String(cbuf, 0, clen, java.nio.charset.StandardCharsets.UTF_8);
                        double sid = 20000000.0 + rid;
                        var ra = makeRootAvatarData(rid, carrer, sid);
                        grandSlamRootAvatarMap.put(String.valueOf(rid), ra);
                        roleGroupMap.put(rid, group);
                        grandSlamStorageMap.put(String.valueOf((long)sid), makeStorageBean(sid, 2, rid, 0, 0, 1));
                    }
                    System.out.println("Loaded " + rcount + " roles from roles_grand_slam_v2.bin!");
                }
            }
            if (grandSlamRootAvatarMap.isEmpty()) {
                loadRolesFromJsonFallback(root.resolve("_work").resolve("all_roles.json").toFile());
            }
            System.out.println("Loaded " + grandSlamStorageMap.size() + " grand slam storage items, " + grandSlamRootAvatarMap.size() + " avatars!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static void loadRolesFromJsonFallback(File rolesFile) {
        if (!rolesFile.isFile()) return;
        try {
            String json = Files.readString(rolesFile.toPath(), java.nio.charset.StandardCharsets.UTF_8);
            Matcher objectMatcher = Pattern.compile("\\{([^{}]*)\\}").matcher(json);
            Pattern idPattern = Pattern.compile("\\\"id\\\"\\s*:\\s*(\\d+)");
            Pattern careerPattern = Pattern.compile("\\\"carrer\\\"\\s*:\\s*\\\"([^\\\"]*)\\\"");
            Pattern groupPattern = Pattern.compile("\\\"group\\\"\\s*:\\s*(\\d+)");
            int count = 0;
            while (objectMatcher.find()) {
                String object = objectMatcher.group(1);
                Matcher idMatch = idPattern.matcher(object);
                Matcher careerMatch = careerPattern.matcher(object);
                Matcher groupMatch = groupPattern.matcher(object);
                if (!idMatch.find() || !careerMatch.find() || !groupMatch.find()) continue;
                int roleId = Integer.parseInt(idMatch.group(1));
                String career = careerMatch.group(1);
                int group = Integer.parseInt(groupMatch.group(1));
                double storageId = 20000000.0 + roleId;
                grandSlamRootAvatarMap.put(String.valueOf(roleId), makeRootAvatarData(roleId, career, storageId));
                roleGroupMap.put(roleId, group);
                grandSlamStorageMap.put(String.valueOf((long)storageId), makeStorageBean(storageId, 2, roleId, 0, 0, 1));
                count++;
            }
            System.out.println("Loaded " + count + " roles from all_roles.json fallback!");
        } catch (Exception e) {
            System.err.println("Could not load all_roles.json fallback: " + e.getMessage());
        }
    }

    static long findStorageId(int type, int tid) {
        for (var entry : grandSlamStorageMap.entrySet()) {
            if (!(entry.getValue() instanceof Amf3TypedObject bean)) continue;
            Map<String, Object> fields = bean.fields();
            if (!(fields.get("type") instanceof Number itemType) || itemType.intValue() != type) continue;
            if (!(fields.get("tid") instanceof Number itemTid) || itemTid.intValue() != tid) continue;
            try { return Long.parseLong(entry.getKey()); } catch (NumberFormatException ignored) {}
        }
        return -1L;
    }

    static void ensureDefaultRenameCard(ProfileManager.Profile profile) {
        long fastCardId = findStorageId(3, 1078);
        long regularCardId = findStorageId(3, 33);
        if ((fastCardId >= 0 && profile.storageAmounts.containsKey(fastCardId)) ||
            (regularCardId >= 0 && profile.storageAmounts.containsKey(regularCardId))) return;
        long cardId = fastCardId >= 0 ? fastCardId : regularCardId;
        if (cardId >= 0) {
            profile.storageAmounts.put(cardId, 1);
            ProfileManager.save(profile);
        }
    }

    static Amf3TypedObject copyStorageBean(long storageId, int amount) {
        Amf3TypedObject source = (Amf3TypedObject)grandSlamStorageMap.get(String.valueOf(storageId));
        if (source == null) return null;
        Map<String, Object> fields = source.fields();
        int type = fields.get("type") instanceof Number n ? n.intValue() : 0;
        int tid = fields.get("tid") instanceof Number n ? n.intValue() : 0;
        int equippedBag = fields.get("equipedBag") instanceof Number n ? n.intValue() : 0;
        int equippedBoom = fields.get("equipedBoom") instanceof Number n ? n.intValue() : 0;
        Amf3TypedObject copy = makeStorageBean(storageId, type, tid, equippedBag, equippedBoom, amount);
        Object sourceExt = fields.get("extBean");
        Object copyExt = copy.fields().get("extBean");
        if (sourceExt instanceof Amf3TypedObject oldExt && copyExt instanceof Amf3TypedObject newExt) {
            for (String key : List.of("model", "worn", "useNum", "quenchId", "store", "texture", "tradeCount")) {
                newExt.set(key, oldExt.fields().get(key));
            }
        }
        return copy;
    }

    static final Set<Integer> FULL_STORAGE_DISPATCH_TYPES =
        Set.of(1, 2, 3, 8, 10, 11, 15, 16, 17, 21);
    static final int STORAGE_COMPOSITE_PACK_TYPE = 4;
    static final int TYPE3_DISPATCH_LIMIT = Integer.getInteger("ssjj.type3.limit", 0);

    static Map<String, Object> buildPlayerStorageMap(ProfileManager.Profile profile) {
        LinkedHashSet<Long> ownedIds = new LinkedHashSet<>();
        LinkedHashSet<Long> equippedIds = new LinkedHashSet<>();

        int type3Count = 0;
        for (var entry : grandSlamStorageMap.entrySet()) {
            if (!(entry.getValue() instanceof Amf3TypedObject bean)) continue;
            if (!(bean.fields().get("type") instanceof Number type)) continue;
            int t = type.intValue();
            if (t == STORAGE_COMPOSITE_PACK_TYPE) continue;
            if (!FULL_STORAGE_DISPATCH_TYPES.contains(t)) continue;
            if (t == 3 && TYPE3_DISPATCH_LIMIT > 0 && type3Count >= TYPE3_DISPATCH_LIMIT) continue;
            try {
                ownedIds.add(Long.parseLong(entry.getKey()));
                if (t == 3) type3Count++;
            } catch (NumberFormatException ignored) {}
        }
        ownedIds.add(20000000L + profile.defaultAvatar);
        for (ProfileManager.BagSlot bag : profile.bags) {
            ownedIds.add(20000000L + bag.roleTID);
            ownedIds.add(20000000L + bag.roleCTID);
            addEquippedWeaponId(ownedIds, equippedIds, bag.master);
            addEquippedWeaponId(ownedIds, equippedIds, bag.secondary);
            addEquippedWeaponId(ownedIds, equippedIds, bag.closed);
            addEquippedWeaponId(ownedIds, equippedIds, bag.bom1);
        }
        for (var skin : profile.equippedSkins.entrySet()) {
            ownedIds.add(skin.getValue());
        }
        for (var amount : profile.storageAmounts.entrySet()) {
            if (amount.getValue() > 0) ownedIds.add(amount.getKey());
        }

        Map<String, Object> playerStorage = new LinkedHashMap<>();
        for (long id : ownedIds) {
            Object source = grandSlamStorageMap.get(String.valueOf(id));
            if (!(source instanceof Amf3TypedObject sourceBean)) continue;
            Map<String, Object> fields = sourceBean.fields();
            int sourceAmount = fields.get("amount") instanceof Number n ? n.intValue() : 0;
            int amount = profile.storageAmounts.getOrDefault(id, sourceAmount);
            if (equippedIds.contains(id) && amount <= 0) amount = 1;
            if (amount <= 0) continue;
            Amf3TypedObject bean = copyStorageBean(id, amount);
            if (bean == null) continue;
            if (fields.get("type") instanceof Number type && type.intValue() == 8) {
                for (var skin : profile.equippedSkins.entrySet()) {
                    if (skin.getValue() == id && bean.fields().get("extBean") instanceof Amf3TypedObject ext) {
                        ext.set("weaponStorageId", (double)skin.getKey());
                        break;
                    }
                }
            }
            playerStorage.put(String.valueOf(id), bean);
        }
        return playerStorage;
    }

    static void addEquippedWeaponId(Set<Long> ownedIds, Set<Long> equippedIds, ProfileManager.WeaponSlot slot) {
        if (slot == null) return;
        long id = (long)slot.storageId;
        ownedIds.add(id);
        equippedIds.add(id);
    }

    static List<Amf3TypedObject> allPersonaliseBeans = new ArrayList<>();
    static List<Amf3TypedObject> allCharMedalBeans = new ArrayList<>();
    static Map<Integer, Amf3TypedObject> charMedalMap = new LinkedHashMap<>();
    static Map<Integer, Integer> personaliseTypeByTid = new LinkedHashMap<>();

    static void loadPersonaliseAndMedals() {
        try {
            Path dataFile = projectRoot().resolve("_work").resolve("lobby_host").resolve("cache").resolve("gamedata1.amf3");
            if (Files.isRegularFile(dataFile)) {
                byte[] b = Files.readAllBytes(dataFile);
                Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();

                // 1. Personalise items (1179 items: sprays, kill icons, titles, emotes, avatars)
                Map<?,?> pMap = (Map<?,?>) m.get("shop_item_personalise");
                if (pMap != null) {
                    for (Object k : pMap.keySet()) {
                        Map<?,?> item = (Map<?,?>) pMap.get(k);
                        int tid = ((Number)item.get("id")).intValue();
                        int itemType = item.get("type") instanceof Number n ? n.intValue() : 0;
                        var pb = new Amf3TypedObject("bean.UserPersonaliseBean", List.of("tid", "equipIndex", "expired"), false);
                        pb.set("tid", tid);
                        pb.set("equipIndex", 0);
                        pb.set("expired", 0.0);
                        allPersonaliseBeans.add(pb);
                        personaliseTypeByTid.put(tid, itemType);
                    }
                    System.out.println("Loaded " + allPersonaliseBeans.size() + " personalise beans!");
                }

                // 2. Medals (32 unique medal lines)
                Map<?,?> medMap = (Map<?,?>) m.get("medal");
                if (medMap != null) {
                    Set<Integer> seenLines = new HashSet<>();
                    for (Object k : medMap.keySet()) {
                        Map<?,?> item = (Map<?,?>) medMap.get(k);
                        int line = ((Number)item.get("medalLine")).intValue();
                        int mid = ((Number)item.get("id")).intValue();
                        if (seenLines.add(line)) {
                            var mb = new Amf3TypedObject("bean.CharMedalBean", List.of(
                                "medalId", "charId", "status", "medalLine", "medalIndex", "expiredTime", "extraValue"), false);
                            mb.set("medalId", mid);
                            mb.set("charId", 321282597);
                            mb.set("status", 1);
                            mb.set("medalLine", line);
                            mb.set("medalIndex", 0);
                            mb.set("expiredTime", 0.0);
                            mb.set("extraValue", 0);
                            allCharMedalBeans.add(mb);
                            charMedalMap.put(line, mb);
                        }
                    }
                    System.out.println("Loaded " + allCharMedalBeans.size() + " char medal beans!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static Amf3TypedObject makePersonaliseBean(int tid, int equipIndex) {
        var bean = new Amf3TypedObject("bean.UserPersonaliseBean", List.of("tid", "equipIndex", "expired"), false);
        bean.set("tid", tid);
        bean.set("equipIndex", equipIndex);
        bean.set("expired", 0.0);
        return bean;
    }

    static List<Amf3TypedObject> getPersonaliseBeans(ProfileManager.Profile profile) {
        List<Amf3TypedObject> beans = new ArrayList<>(allPersonaliseBeans.size());
        for (Amf3TypedObject item : allPersonaliseBeans) {
            int tid = ((Number)item.fields().get("tid")).intValue();
            beans.add(makePersonaliseBean(tid, profile.equippedPersonalise.getOrDefault(tid, 0)));
        }
        return beans;
    }

    static Amf3TypedObject copyCharMedalBean(Amf3TypedObject source) {
        var copy = new Amf3TypedObject("bean.CharMedalBean", List.of(
            "medalId", "charId", "status", "medalLine", "medalIndex", "expiredTime", "extraValue"), false);
        for (String field : List.of("medalId", "charId", "status", "medalLine", "medalIndex", "expiredTime", "extraValue")) {
            copy.set(field, source.fields().get(field));
        }
        return copy;
    }

    static List<Amf3TypedObject> getCharMedalBeans() {
        List<Amf3TypedObject> beans = new ArrayList<>(allCharMedalBeans.size());
        for (Amf3TypedObject item : allCharMedalBeans) beans.add(copyCharMedalBean(item));
        return beans;
    }

    static String mountKey(String mountType, String subType) {
        return mountType + "|" + ((subType == null || subType.isBlank()) ? "default" : subType);
    }

    static Amf3TypedObject makeMountUserBean(String mountId, String targetId, String subType) {
        var bean = new Amf3TypedObject("bean.MountUserBean", List.of("mountId", "targetId", "subType"), false);
        bean.set("mountId", mountId);
        bean.set("targetId", targetId);
        bean.set("subType", subType == null || subType.isBlank() ? "default" : subType);
        return bean;
    }

    // ================= 连接 / 帧 硬性边界 (M2 P0) =================
    // 原实现：无 SoTimeout、无帧长上限、每连接裸 new Thread 无上限。
    // 后果：单个 len=0x7FFFFFFF 的包即可 OOM 带走整个 JVM；
    //       半开连接永久占用线程。
    static final int MAX_CONN         = Integer.getInteger("ssjj.maxConn", 32);
    static final int MAX_FRAME        = Integer.getInteger("ssjj.maxFrame", 1 << 20); // 1MB
    static final int IDLE_TIMEOUT_MS  = Integer.getInteger("ssjj.idleTimeoutMs", 180_000);
    static final java.util.concurrent.atomic.AtomicInteger ACTIVE_CONN =
            new java.util.concurrent.atomic.AtomicInteger();
    // 观测：本轮是否已回包（用于捕获"客户端永久 pending"这一类静默失败）
    static final ThreadLocal<Boolean> SENT = ThreadLocal.withInitial(() -> Boolean.FALSE);
    static final java.util.Set<String> NO_REPLY_OK = java.util.Set.of("heartBeat");
    static final java.util.concurrent.atomic.AtomicLong NO_REPLY_COUNT =
            new java.util.concurrent.atomic.AtomicLong();
    static final java.util.concurrent.atomic.AtomicLong RPC_ERR_COUNT =
            new java.util.concurrent.atomic.AtomicLong();

    /** 标记当前连接已回过包（send() 与 RpcTable.dispatch() 都必须调用）。 */
    static void markSent() { SENT.set(Boolean.TRUE); }

    static {
        // 日志通道必须由 Java 自己打开文件，不能依赖启动器的 shell 重定向：
        // 实测 launch_lobby.py 用 DETACHED_PROCESS 起的进程，stdout 没落到 server.log，
        // 导致自动化脚本一直在读一个昨天的旧文件（所有服务端断言等于没测）。
        // 优先用 -Dssjj.logFile=<path> 直接写文件，其次退回逐行 flush 的 stdout。
        try {
            String lf = System.getProperty("ssjj.logFile");
            if (lf != null && !lf.isEmpty()) {
                java.io.File f = new java.io.File(lf);
                if (f.getParentFile() != null) f.getParentFile().mkdirs();
                System.setOut(new java.io.PrintStream(
                    new java.io.FileOutputStream(f, true), true,
                    java.nio.charset.StandardCharsets.UTF_8));
                System.setErr(new java.io.PrintStream(
                    new java.io.FileOutputStream(f, true), true,
                    java.nio.charset.StandardCharsets.UTF_8));
                System.out.println("[log] direct file sink -> " + f.getAbsolutePath());
            } else {
                System.setOut(new java.io.PrintStream(
                    new java.io.FileOutputStream(java.io.FileDescriptor.out), true,
                    java.nio.charset.StandardCharsets.UTF_8));
            }
        } catch (Throwable ignored) {}
    }

    static void handle(Socket s) {
        try { s.setTcpNoDelay(true); } catch (Exception ignored) {}
        // P0: 空闲超时，杜绝半开连接永久占用线程
        try { s.setSoTimeout(IDLE_TIMEOUT_MS); } catch (Exception ignored) {}
        String peer = "?";
        try { peer = String.valueOf(s.getRemoteSocketAddress()); } catch (Exception ignored) {}
        // 连接级埋点：用来区分「客户端没连」/「连了但一个字节没发」/「发了解析失败」。
        System.out.println("[conn] ACCEPT " + peer);
        long t0 = System.currentTimeMillis();
        int frameCount = 0;
        try (DataInputStream in = new DataInputStream(new BufferedInputStream(s.getInputStream()));
             DataOutputStream out = new DataOutputStream(new BufferedOutputStream(s.getOutputStream()))) {
            
            ProfileManager.Profile profile = ProfileManager.load();
            List<Amf3TypedObject> sessionAvatarBags = new ArrayList<>();
            List<Amf3TypedObject> bagArray = new ArrayList<>();
            Map<String, Object> rootAvatarDataHashMap = new LinkedHashMap<>(grandSlamRootAvatarMap);

            while (true) {
                int len;
                try {
                    len = in.readInt();
                } catch (EOFException e) {
                    break;
                }
                frameCount++;
                if (frameCount == 1) {
                    System.out.println("[conn] FIRST FRAME len=" + len + " from " + peer);
                }
                // P0: 帧长校验。原实现 len<=1 直接 continue，且 len==1 时漏读 flag 字节，
                // 会造成协议错位；而超大 len 直接 new byte[len-1] 即 OOM。
                if (len < 1) {
                    System.out.println("[WARN] illegal frame len=" + len + ", closing conn");
                    break;
                }
                if (len > MAX_FRAME) {
                    System.out.println("[WARN] frame too large len=" + len + " > MAX_FRAME(" + MAX_FRAME + "), closing conn");
                    break;
                }
                if (len == 1) {
                    in.readByte();   // 只有 flag、无载荷
                    continue;
                }
                SENT.set(Boolean.FALSE);
                String fn = null;
                List<?> rpcParams = List.of();
                try {
                byte flag = in.readByte();
                byte[] payload = new byte[len - 1];
                in.readFully(payload);

                byte[] dec = payload;
                if (flag == 1) {
                    dec = inflate(payload);
                }

                Object obj = new Amf3Decoder(dec).decodeOne();
                if (obj instanceof Map<?,?> map) {
                    fn = (String) (map.get("functionName") != null ? map.get("functionName") : map.get("fn"));
                    Object p = map.get("parameters") != null ? map.get("parameters") : map.get("params");
                    if (p instanceof List<?> l) rpcParams = l;
                } else if (obj instanceof Amf3TypedObject to) {
                    fn = (String) (to.fields().get("functionName") != null ? to.fields().get("functionName") : to.fields().get("fn"));
                    Object p = to.fields().get("parameters") != null ? to.fields().get("parameters") : to.fields().get("params");
                    if (p instanceof List<?> l) rpcParams = l;
                }
                if (VERBOSE) System.out.println("<- " + fn + " params=" + rpcParams);

                if ("ping".equals(fn)) {
                    // ServerSelector considers the login socket ready only after
                    // it receives an AMF packet in response to its initial ping.
                    send(out, "pong", List.of());
                } else if ("getPolicy".equals(fn)) {
                    send(out, "onGetPolicy", List.of(true));
                } else if ("getTimeSync".equals(fn)) {
                    send(out, "onGetTimeSync", List.of(System.currentTimeMillis()));
                } else if ("randomPlayerName".equals(fn)) {
                    send(out, "onRandomPlayerName", List.of(1, "离线玩家321282597"));
                } else if ("checkPlayerName".equals(fn)) {
                    String candidate = rpcParams.isEmpty() ? "" : String.valueOf(rpcParams.get(0)).trim();
                    int status = candidate.isEmpty() ? 0 : (candidate.codePointCount(0, candidate.length()) <= 20 ? 1 : -1);
                    send(out, "callBackCheckPlayerName", List.of(status));
                } else if ("changePlayerName".equals(fn)) {
                    String candidate = rpcParams.isEmpty() ? "" : String.valueOf(rpcParams.get(0)).trim();
                    int status = candidate.isEmpty() ? -1 : (candidate.codePointCount(0, candidate.length()) <= 20 ? 1 : -1);
                    Amf3TypedObject consumedCard = null;
                    if (status == 1) {
                        long noCooldownId = -1L;
                        long standardCardId = -1L;
                        Amf3TypedObject noCooldownCard = null;
                        Amf3TypedObject standardCard = null;
                        int noCooldownAmount = 0;
                        int standardAmount = 0;
                        for (var entry : grandSlamStorageMap.entrySet()) {
                            if (!(entry.getValue() instanceof Amf3TypedObject itemBean)) continue;
                            Map<String, Object> fields = itemBean.fields();
                            if (!(fields.get("type") instanceof Number type) || type.intValue() != 3) continue;
                            if (!(fields.get("tid") instanceof Number tid)) continue;
                            long storageId = Long.parseLong(entry.getKey());
                            int amount = profile.storageAmounts.getOrDefault(storageId, 0);
                            if (tid.intValue() == 1078 && amount > noCooldownAmount) {
                                noCooldownId = storageId;
                                noCooldownCard = itemBean;
                                noCooldownAmount = amount;
                            } else if (tid.intValue() == 33 && amount > standardAmount) {
                                standardCardId = storageId;
                                standardCard = itemBean;
                                standardAmount = amount;
                            }
                        }
                        long now = System.currentTimeMillis();
                        long cardId = noCooldownAmount > 0 ? noCooldownId : standardCardId;
                            consumedCard = noCooldownAmount > 0 ? noCooldownCard : standardCard;
                        int cardAmount = noCooldownAmount > 0 ? noCooldownAmount : standardAmount;
                        if (noCooldownAmount <= 0 && standardAmount > 0 && now - profile.lastChangePlayerName < 15552000000L) {
                            status = -15;
                        } else {
                            profile.playerName = candidate;
                            profile.lastChangePlayerName = now;
                            if (consumedCard != null && cardId >= 0) {
                                int remaining = Math.max(0, cardAmount - 1);
                                profile.storageAmounts.put(cardId, remaining);
                                consumedCard = copyStorageBean(cardId, remaining);
                            } else {
                                consumedCard = null;
                            }
                            ProfileManager.save(profile);
                        }
                    }
                    if (status == 1 && consumedCard != null) {
                        send(out, "callbackUpdateStorages", List.of(1, List.of(consumedCard)));
                    }
                    send(out, "onChangePlayerName", List.of(status));
                } else if ("useStorageItem".equals(fn)) {
                    send(out, "callBackUseStorageItem", List.of(1));
                } else if ("getHallConfig".equals(fn)) {
                    var cfg = new LinkedHashMap<String, Object>();
                    cfg.put("isReport", false);
                    cfg.put("logTrace", 45);
                    send(out, "onGetHallConfig", List.of(cfg));
                } else if ("getHallServerConfig".equals(fn)) {
                    send(out, "onGetServerHallConfig", List.of(new java.util.LinkedHashMap<String,Object>()));
                } else if ("getUserCharacterState".equals(fn)) {
                    // The official AIR preloader blocks here before it loads the lobby module.
                    send(out, "callbackGetUserCharacterState", List.of(Boolean.TRUE));
                } else if ("getRoomChannel".equals(fn)) {
                    var ch1 = makeLobbyRoomChannel(1, "本地离线频道", 1, 1);
                    var ch2 = makeLobbyRoomChannel(2, "人机娱乐频道", 2, 217);
                    var ch3 = makeLobbyRoomChannel(3, "经典竞技频道", 3, 215);
                    send(out, "callChannelList", List.of(List.of(ch1, ch2, ch3), new LinkedHashMap<String, Object>()));
                } else if ("getGlobalRoomChannel".equals(fn)) {
                    send(out, "callbackGetGlobalRoomChannel", List.of(List.of()));
                    send(out, "onGetGlobalChannelList", List.of(List.of()));
                } else if ("getPatchca".equals(fn)) {
                    var params = new java.util.ArrayList<Object>(); params.add(null);
                    send(out, "callbackGetPatchca", params);
                } else if ("loginV3".equals(fn)) {
                    send(out, "callBackLoginV3", List.of(1));
                } else if ("getUserDataByLogin".equals(fn)) {
                    profile = ProfileManager.load();
                    ensureDefaultRenameCard(profile);

                    var sb = new Amf3TypedObject("bean.UserSettingBean", List.of(
                        "isRecommendDenied", "isChatFromStrangersDenied", "isInviteJoinTeamDenied",
                        "isCreateFriendDenied", "isBackgroundMusic", "isBackgroundMusicNotice",
                        "isCache", "isShowMedalInBattle", "isChromeNotice", "unityWindowModel",
                        "otherSettingString", "battleClientValue", "playerCareerLevel", "enableLoginIpProtect"), false);
                    sb.set("isRecommendDenied", false);
                    sb.set("isChatFromStrangersDenied", false);
                    sb.set("isInviteJoinTeamDenied", false);
                    sb.set("isCreateFriendDenied", false);
                    sb.set("isBackgroundMusic", true);
                    sb.set("isBackgroundMusicNotice", false);
                    sb.set("isCache", false);
                    sb.set("isShowMedalInBattle", true);
                    sb.set("isChromeNotice", true);
                    sb.set("unityWindowModel", "0");
                    sb.set("otherSettingString", "");
                    sb.set("battleClientValue", "2");
                    sb.set("playerCareerLevel", 1);
                    sb.set("enableLoginIpProtect", false);

                    // Build session avatar bags and loadout bags from profile
                    sessionAvatarBags.clear();
                    bagArray.clear();
                    for (int i = 0; i < profile.bags.size(); i++) {
                        ProfileManager.BagSlot bs = profile.bags.get(i);
                        sessionAvatarBags.add(makeAvatarBagData(bs.roleTID, bs.roleCTID));

                        var wm = bs.master != null ? makeWeaponData(bs.master.storageId, bs.master.codeName, bs.master.tid) : null;
                        var ws = bs.secondary != null ? makeWeaponData(bs.secondary.storageId, bs.secondary.codeName, bs.secondary.tid) : null;
                        var wc = bs.closed != null ? makeWeaponData(bs.closed.storageId, bs.closed.codeName, bs.closed.tid) : null;
                        var wb = bs.bom1 != null ? makeWeaponData(bs.bom1.storageId, bs.bom1.codeName, bs.bom1.tid) : null;
                        bagArray.add(makeBagData(false, wm, ws, wc, wb));
                    }

                    var rpgBagArray = new ArrayList<>(bagArray);
                    var globalBag = bagArray.get(0);

                    // The static storage catalog is metadata, not the player's inventory.
                    // Sending all 21k catalog rows makes StorageProxy treat catalog packs
                    // as owned items and spam thousands of missing shop_pack errors.
                    var storageMap = buildPlayerStorageMap(profile);

                    var raT = rootAvatarDataHashMap.get(String.valueOf(profile.defaultAvatar));
                    if (raT == null) {
                        raT = makeRootAvatarData(profile.defaultAvatar, profile.defaultCareer, 20000000.0 + profile.defaultAvatar);
                        rootAvatarDataHashMap.put(String.valueOf(profile.defaultAvatar), raT);
                    }
                    var raCT = rootAvatarDataHashMap.get("4");
                    if (raCT == null) {
                        raCT = makeRootAvatarData(4, "sas", 20000004.0);
                        rootAvatarDataHashMap.put("4", raCT);
                    }

                    var pvpTacBag = new Amf3TypedObject("netdata.TacticalBagData", List.of("idx", "isLock", "tacticalWeapon"), false);
                    pvpTacBag.set("idx", 0);
                    pvpTacBag.set("isLock", false);
                    pvpTacBag.set("tacticalWeapon", profile.pvpTactical != null ? makeWeaponData(profile.pvpTactical.storageId, profile.pvpTactical.codeName, profile.pvpTactical.tid) : null);

                    var rpgTacBag = new Amf3TypedObject("netdata.TacticalBagData", List.of("idx", "isLock", "tacticalWeapon"), false);
                    rpgTacBag.set("idx", 1);
                    rpgTacBag.set("isLock", false);
                    rpgTacBag.set("tacticalWeapon", profile.rpgTactical != null ? makeWeaponData(profile.rpgTactical.storageId, profile.rpgTactical.codeName, profile.rpgTactical.tid) : null);

                    var vip4399 = makeVip4399Bean();

                    var u = new Amf3TypedObject("bean.UserInfo", List.of(
                        "loginRet", "loginId", "operatorId", "userId", "username", "playerName", "characterId",
                        "vipLv", "goldTotal", "gold", "gp", "gift", "reputationScore",
                        "isadult", "accountTag", "teamId", "token", "regTime",
                        "selectedBagIndex", "settingBean", "charMedalBean", "defaultAvatar", "avatarT", "avatarCT", "avatarSH",
                        "selectAvatarBagIndex", "avatarBagData", "rootAvatarDataHashMap",
                        "rootAvatarDataT", "rootAvatarDataCT",
                        "bagArray", "rpgBagArray", "globalBag", "pvpTacticalBag", "rpgTacticalBag",
                        "storageMap", "vip4399Bean", "lv", "maxLv", "exp", "roomId",
                        "blockFunctionMap", "propertyUnits", "rpgBlindCodeMap",
                        "gameCoinMap", "storageArrearsMap", "gameCoinArrearsMap", "buffEffectMap",
                        "variantSkillBeanMap", "homelandPropertyBeanMap", "installmentRefundMap",
                        "charRaceBeanMap", "allWeaponBattleDataMap", "holidayStatusObj",
                        "lastChangePlayerName", "changename",
                        "wrestleChallengeTaskProgressMap", "FestivalTaskProgressMap",
                        "HeroRoleTaskProgressMap", "RunesTaskProgressMap", "WelcomeTaskProgressMap",
                        "NewbieTaskProgressMap",
                        "pveProgressList", "closedActivityIdArr",
                        "completedWrestleChallengeTaskIds", "completedFestivalTaskIds",
                        "completedHeroRoleTaskIds", "completedRunesTaskIds",
                        "completedWelcomeTaskIds", "completedNewbieTaskIds",
                        "userRpgDataArray", "xpSkillBeans", "rpgTeamlogAry"), false);
                    u.set("loginRet", 1);
                    u.set("loginId", 1);
                    u.set("operatorId", 1);
                    u.set("userId", 321282597);
                    u.set("username", "321282597");
                    u.set("playerName", profile.playerName);
                    u.set("lastChangePlayerName", (double)profile.lastChangePlayerName);
                    u.set("changename", "");
                    u.set("characterId", 100072528);
                    u.set("vipLv", 18);
                    u.set("goldTotal", 91);
                    u.set("gold", 91);
                    u.set("gp", 91);
                    u.set("gift", 91);
                    u.set("reputationScore", 100);
                    u.set("isadult", 1);
                    u.set("accountTag", 3);
                    u.set("teamId", 0);
                    u.set("token", "local");
                    u.set("regTime", 0.0);
                    u.set("selectedBagIndex", profile.selectedBagIndex);
                    u.set("settingBean", sb);
                    u.set("charMedalBean", charMedalMap.containsKey(profile.activeMedalLine)
                        ? copyCharMedalBean(charMedalMap.get(profile.activeMedalLine)) : null);
                    u.set("defaultAvatar", profile.defaultAvatar);
                    u.set("avatarT", profile.defaultAvatar);
                    u.set("avatarCT", 4);
                    u.set("avatarSH", 2001);
                    u.set("selectAvatarBagIndex", Math.max(0, Math.min(1, profile.selectedAvatarBagIndex)));
                    u.set("avatarBagData", sessionAvatarBags);
                    // MainMediator's original 3D role display resolves the equipped
                    // RootAvatarData through UserInfo.rootAvatarDataHashMap. Sending
                    // only rootAvatarDataT/rootAvatarDataCT leaves that accessor null
                    // and aborts MainMediator.onRegister before the stage is populated.
                    u.set("rootAvatarDataHashMap", rootAvatarDataHashMap);
                    u.set("rootAvatarDataT", raT);
                    u.set("rootAvatarDataCT", raCT);
                    u.set("bagArray", bagArray);
                    u.set("rpgBagArray", rpgBagArray);
                    u.set("globalBag", globalBag);
                    u.set("pvpTacticalBag", pvpTacBag);
                    u.set("rpgTacticalBag", rpgTacBag);
                    u.set("storageMap", storageMap);
                    u.set("vip4399Bean", vip4399);
                    u.set("lv", 91);
                    u.set("maxLv", 100);
                    u.set("exp", 0.0);
                    u.set("roomId", -1.0);
                    u.set("blockFunctionMap", new LinkedHashMap<String, Object>());
                    u.set("propertyUnits", new LinkedHashMap<String, Object>());
                    u.set("rpgBlindCodeMap", new LinkedHashMap<String, Object>());
                    u.set("gameCoinMap", new LinkedHashMap<String, Object>());
                    u.set("storageArrearsMap", new LinkedHashMap<String, Object>());
                    u.set("gameCoinArrearsMap", new LinkedHashMap<String, Object>());
                    u.set("buffEffectMap", new LinkedHashMap<String, Object>());
                    u.set("variantSkillBeanMap", new LinkedHashMap<String, Object>());
                    u.set("homelandPropertyBeanMap", new LinkedHashMap<String, Object>());
                    u.set("installmentRefundMap", new LinkedHashMap<String, Object>());
                    var charRaceMap = new LinkedHashMap<String, Object>();
                    var raceFields = List.of(
                        "season", "rankState", "rankResult1", "rankResult2", "rankResult3", "rankResult4", "rankResult5",
                        "rankSect", "rankLv", "rankScore", "isKing", "historyReport",
                        "continuousWinNum", "curLvForReward", "kingRanking", "battleCount", "fetched"
                    );
                    for (int seasonId = 1; seasonId <= 80; seasonId++) {
                        var rb = new Amf3TypedObject("bean.CharRaceBean", raceFields, false);
                        rb.set("season", seasonId);
                        rb.set("rankState", 2);
                        rb.set("rankResult1", 1);
                        rb.set("rankResult2", 1);
                        rb.set("rankResult3", 1);
                        rb.set("rankResult4", 1);
                        rb.set("rankResult5", 1);
                        rb.set("rankSect", 5); // 5 = 钻石
                        rb.set("rankLv", 25);  // 钻石5
                        rb.set("rankScore", 2500);
                        rb.set("isKing", 0);
                        rb.set("historyReport", List.of());
                        rb.set("continuousWinNum", 5);
                        rb.set("curLvForReward", 25);
                        rb.set("kingRanking", 0);
                        rb.set("battleCount", 50);
                        rb.set("fetched", false);
                        charRaceMap.put(String.valueOf(seasonId), rb);
                    }
                    u.set("charRaceBeanMap", charRaceMap);
                    u.set("allWeaponBattleDataMap", new LinkedHashMap<String, Object>());
                    u.set("holidayStatusObj", new LinkedHashMap<String, Object>());
                    u.set("wrestleChallengeTaskProgressMap", new LinkedHashMap<String, Object>());
                    u.set("FestivalTaskProgressMap", new LinkedHashMap<String, Object>());
                    u.set("HeroRoleTaskProgressMap", new LinkedHashMap<String, Object>());
                    u.set("RunesTaskProgressMap", new LinkedHashMap<String, Object>());
                    u.set("WelcomeTaskProgressMap", new LinkedHashMap<String, Object>());
                    u.set("NewbieTaskProgressMap", new LinkedHashMap<String, Object>());
                    u.set("pveProgressList", List.of());
                    u.set("closedActivityIdArr", List.of());
                    u.set("completedWrestleChallengeTaskIds", List.of());
                    u.set("completedFestivalTaskIds", List.of());
                    u.set("completedHeroRoleTaskIds", List.of());
                    u.set("completedRunesTaskIds", List.of());
                    u.set("completedWelcomeTaskIds", List.of());
                    u.set("completedNewbieTaskIds", List.of());
                    u.set("userRpgDataArray", List.of());
                    u.set("xpSkillBeans", List.of());
                    u.set("rpgTeamlogAry", List.of());
                    send(out, "callBackGetUserDataByLogin", List.of(u));
                } else if ("getZoneGroup".equals(fn)) {
                    var zg = new Amf3TypedObject("bean.ZoneGroupInfo", List.of("id", "name", "order", "status"), false);
                    zg.set("id", 1); zg.set("name", "联通一区"); zg.set("order", 1); zg.set("status", 1);
                    send(out, "callBackGetZoneGroup", List.of(List.of(zg)));
                } else if ("getChannelList".equals(fn)) {
                    int groupId = 1;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) groupId = n.intValue();
                    var ch1 = makeChannelInfo(101, "竞技频道-1", 1, 0);
                    var ch2 = makeChannelInfo(102, "竞技频道-2", 2, 0);
                    var ch3 = makeChannelInfo(103, "变异频道-1", 3, 0);
                    var ch4 = makeChannelInfo(104, "挑战/冒险频道", 4, 0);
                    send(out, "callBackGetChannelList", List.of(groupId, List.of(ch1, ch2, ch3, ch4)));
                } else if ("channelAvaliable".equals(fn)) {
                    int chId = 1;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) chId = n.intValue();
                    send(out, "onChannelAvaliable", List.of(chId, 1));
                } else if ("enterChannel".equals(fn)) {
                    int chId = 1;
                    if (rpcParams.size() > 1 && rpcParams.get(1) instanceof Number n) chId = n.intValue();
                    else if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) chId = n.intValue();
                    send(out, "callEnterChannelSuccess", List.of(1, chId));
                } else if ("getRoomList".equals(fn)) {
                    send(out, "callBackGetRoomList", List.of(List.of(), 1));
                } else if ("getPersonalRecord".equals(fn)) {
                    var pr = new Amf3TypedObject("bean.PersonalRecord", List.of("score", "totalBattle", "winCount", "killCount", "headShot", "deathCount", "assistCount"), false);
                    pr.set("score", 9999);
                    pr.set("totalBattle", 888);
                    pr.set("winCount", 666);
                    pr.set("killCount", 12345);
                    pr.set("headShot", 5432);
                    pr.set("deathCount", 100);
                    pr.set("assistCount", 300);
                    send(out, "callBackGetPersonalRecord", List.of(pr));
                } else if ("getOtherRecordNew".equals(fn)) {
                    var r = new LinkedHashMap<String, Object>();
                    r.put("rpgPower", 999999);
                    r.put("challengeScore", 8888);
                    send(out, "callbackGetOtherRecordNew", List.of(r));
                } else if ("getCorpsInfo".equals(fn)) {
                    send(out, "callBackGetCorpsInfo", List.of(new java.util.ArrayList<Object>()));
                } else if ("getRankTopList".equals(fn)) {
                    send(out, "callBackGetRankTopList", List.of(List.of()));
                } else if ("getMatchState".equals(fn)) {
                    send(out, "callBackGetMatchState", List.of(0));
                } else if ("startRaceMatch".equals(fn)) {
                    launchBattleClient(profile.defaultCareer, profile.selectedBagIndex, 12, 2003, profile.team, 4, 5);
                    send(out, "onStartRaceMatch", List.of(1));
                } else if ("createRoom".equals(fn)) {
                    Amf3TypedObject room = rpcParams.isEmpty() ? null : toRoomInfoObject(rpcParams.get(0));
                    if (room != null) {
                        room.set("roomId", 1001.0);
                        room.set("roomDisplayId", 1001.0);
                        room.set("createCharacterId", 1000200072528.0);
                        room.set("createCharName", profile.playerName);
                        room.set("createCharVipLv", 15);
                        room.set("status", 0);
                        room.set("gameStatus", 0);
                        room.set("accessNumber", 1);
                        room.set("battleNumber", 0);
                        currentRoomInfo = room;
                        roomSceneId = Math.max(1, intField(room, "sceneId", 12));
                        roomRaceType = intField(room, "raceType", 2003);
                        roomLimitNumber = Math.max(2, intField(room, "limitNumber", 10));
                        var userList = new ArrayList<Object>();
                        userList.add(makeClientRoomUser(profile, profile.team));
                        send(out, "callBackJoinRoom", List.of(1, room, userList));
                    }
                } else if ("updateRoom".equals(fn)) {
                    Amf3TypedObject room = rpcParams.isEmpty() ? null : toRoomInfoObject(rpcParams.get(0));
                    if (room != null) {
                        room.set("roomId", 1001.0);
                        room.set("roomDisplayId", 1001.0);
                        room.set("createCharacterId", 1000200072528.0);
                        room.set("createCharName", profile.playerName);
                        currentRoomInfo = room;
                        roomSceneId = Math.max(1, intField(room, "sceneId", 12));
                        roomRaceType = intField(room, "raceType", 2003);
                        roomLimitNumber = Math.max(2, intField(room, "limitNumber", 10));
                        send(out, "callBackRefreshCurrentRoom", List.of(room));
                    }
                } else if ("changeTeam".equals(fn)) {
                    int newTeam = (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) ? n.intValue() : 1;
                    boolean obs = rpcParams.size() > 1 && Boolean.TRUE.equals(rpcParams.get(1));
                    if (!obs && (newTeam == 1 || newTeam == 2)) {
                        profile.team = newTeam;
                        ProfileManager.save(profile);
                    }
                    send(out, "callBackChangeTeam", List.of(1000200072528.0, newTeam, obs));
                } else if ("leaveRoom".equals(fn)) {
                    currentRoomInfo = null;
                    send(out, "callBackLeaveRoom", List.of());
                } else if ("startGame".equals(fn)) {
                    int totalSlots = Math.max(2, roomLimitNumber);
                    int perSide = totalSlots / 2;
                    int allyBots = Math.max(0, perSide - 1);
                    int enemyBots = Math.max(1, totalSlots - perSide);
                    launchBattleClient(profile.defaultCareer, profile.selectedBagIndex,
                        roomSceneId, roomRaceType, profile.team, allyBots, enemyBots);
                    send(out, "callBackRefreshUserEndGame", List.of(List.of(1000200072528.0)));
                } else if ("roomList".equals(fn)) {
                    send(out, "callBackShowRoomList", List.of(List.of(), 1));
                } else if ("equip".equals(fn)) {
                    int bagIdx = 0;
                    double sid = 0;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) bagIdx = n.intValue();
                    if (rpcParams.size() > 1) {
                        try { sid = Double.parseDouble(String.valueOf(rpcParams.get(1))); } catch(Exception e){}
                    }
                    long sidLong = (long)sid;
                    var sbObj = grandSlamStorageMap.get(String.valueOf(sidLong));
                    if (sbObj instanceof Amf3TypedObject sb) {
                        int tid = ((Number)sb.fields().get("tid")).intValue();
                        WeaponMeta wm = weaponMetaMap.get(tid);
                        if (wm != null && bagIdx >= 0 && bagIdx < profile.bags.size()) {
                            var bagSlot = profile.bags.get(bagIdx);
                            var bagBean = bagArray.get(bagIdx);
                            var wData = makeWeaponData(sid, wm.codeName, tid);
                            ProfileManager.WeaponSlot oldSlot = null;
                            if (wm.type == 1) {
                                oldSlot = bagSlot.master;
                                bagSlot.master = new ProfileManager.WeaponSlot(sid, tid, wm.codeName);
                                bagBean.set("masterWeapon", wData);
                            } else if (wm.type == 2) {
                                oldSlot = bagSlot.secondary;
                                bagSlot.secondary = new ProfileManager.WeaponSlot(sid, tid, wm.codeName);
                                bagBean.set("secondaryWeapon", wData);
                            } else if (wm.type == 3) {
                                oldSlot = bagSlot.closed;
                                bagSlot.closed = new ProfileManager.WeaponSlot(sid, tid, wm.codeName);
                                bagBean.set("closedWeapon", wData);
                            } else if (wm.type == 4) {
                                oldSlot = bagSlot.bom1;
                                bagSlot.bom1 = new ProfileManager.WeaponSlot(sid, tid, wm.codeName);
                                bagBean.set("bom1", wData);
                            }
                            sb.set("equipedBag", bagIdx);
                            List<Object> updateList = new ArrayList<>();
                            if (oldSlot != null && oldSlot.storageId != sid) {
                                var oldBean = grandSlamStorageMap.get(String.valueOf((long)oldSlot.storageId));
                                if (oldBean instanceof Amf3TypedObject osb) {
                                    osb.set("equipedBag", -1);
                                    updateList.add(osb);
                                }
                                send(out, "onUnequip", List.of(bagIdx, oldSlot.storageId));
                            }
                            updateList.add(sb);
                            ProfileManager.save(profile);
                            send(out, "callbackUpdateStorages", List.of(1, updateList));
                        }
                    }
                    send(out, "onEquip", List.of(bagIdx, sid, 1));
                } else if ("unequip".equals(fn)) {
                    int bagIdx = 0;
                    double sid = 0;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) bagIdx = n.intValue();
                    if (rpcParams.size() > 1) {
                        try { sid = Double.parseDouble(String.valueOf(rpcParams.get(1))); } catch(Exception e){}
                    }
                    long sidLong = (long)sid;
                    var sbObj = grandSlamStorageMap.get(String.valueOf(sidLong));
                    if (sbObj instanceof Amf3TypedObject sb) {
                        int tid = ((Number)sb.fields().get("tid")).intValue();
                        WeaponMeta wm = weaponMetaMap.get(tid);
                        if (wm != null && bagIdx >= 0 && bagIdx < profile.bags.size()) {
                            var bagSlot = profile.bags.get(bagIdx);
                            var bagBean = bagArray.get(bagIdx);
                            if (wm.type == 1) {
                                bagSlot.master = null;
                                bagBean.set("masterWeapon", null);
                            } else if (wm.type == 2) {
                                bagSlot.secondary = null;
                                bagBean.set("secondaryWeapon", null);
                            } else if (wm.type == 3) {
                                bagSlot.closed = null;
                                bagBean.set("closedWeapon", null);
                            } else if (wm.type == 4) {
                                bagSlot.bom1 = null;
                                bagBean.set("bom1", null);
                            }
                            sb.set("equipedBag", -1);
                            ProfileManager.save(profile);
                            send(out, "callbackUpdateStorages", List.of(1, List.of(sb)));
                        }
                    }
                    send(out, "onUnequip", List.of(bagIdx, sid));
                } else if ("equipRootAvatar".equals(fn)) {
                    int subIndex = 0;
                    int roleId = 150;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) subIndex = n.intValue();
                    if (rpcParams.size() > 1 && rpcParams.get(1) instanceof Number n) roleId = n.intValue();
                    int group = roleGroupMap.getOrDefault(roleId, 1);
                    profile.team = group;
                    if (subIndex >= 0 && subIndex < profile.bags.size()) {
                        var bs = profile.bags.get(subIndex);
                        // sessionAvatarBags 只在 loginV3 里填充；未登录直接发本 RPC 会
                        // IndexOutOfBounds（RpcProbe 实测触发）。
                        var ab = subIndex < sessionAvatarBags.size() ? sessionAvatarBags.get(subIndex) : null;
                        if (group == 2) {
                            bs.roleCTID = roleId;
                            if (ab != null) ab.set("rootAvatarCTID", roleId);
                        } else {
                            bs.roleTID = roleId;
                            if (ab != null) ab.set("rootAvatarTID", roleId);
                        }
                    }
                    profile.defaultAvatar = roleId;
                    var raObj = rootAvatarDataHashMap.get(String.valueOf(roleId));
                    if (raObj instanceof Amf3TypedObject ra && ra.fields().get("career") != null) {
                        profile.defaultCareer = String.valueOf(ra.fields().get("career"));
                    }
                    ProfileManager.save(profile);
                    send(out, "callBackEquipRootAvatar", List.of(1, sessionAvatarBags, roleId));
                } else if ("equipRootAvatarInfo".equals(fn)) {
                    double rootAvatarId = 150;
                    double storageSkinId = 0;
                    int facadePartId = 0;
                    if (!rpcParams.isEmpty()) {
                        try { rootAvatarId = Double.parseDouble(String.valueOf(rpcParams.get(0))); } catch(Exception e){}
                    }
                    if (rpcParams.size() > 1) {
                        try { storageSkinId = Double.parseDouble(String.valueOf(rpcParams.get(1))); } catch(Exception e){}
                    }
                    if (rpcParams.size() > 2 && rpcParams.get(2) instanceof Number n) facadePartId = n.intValue();
                    var raObj = rootAvatarDataHashMap.get(String.valueOf((int)rootAvatarId));
                    if (raObj instanceof Amf3TypedObject ra) {
                        ra.set("storageSkinId", storageSkinId);
                        ra.set("facadePartId", facadePartId);
                    }
                    ProfileManager.save(profile);
                    send(out, "callBackEquipRootAvatarInfo", List.of(1, rootAvatarId, storageSkinId, facadePartId));
                } else if ("unEquipRootAvatarInfo".equals(fn)) {
                    double rootAvatarId = 150;
                    double storageSkinId = 0;
                    if (!rpcParams.isEmpty()) {
                        try { rootAvatarId = Double.parseDouble(String.valueOf(rpcParams.get(0))); } catch(Exception e){}
                    }
                    if (rpcParams.size() > 1) {
                        try { storageSkinId = Double.parseDouble(String.valueOf(rpcParams.get(1))); } catch(Exception e){}
                    }
                    var raObj = rootAvatarDataHashMap.get(String.valueOf((int)rootAvatarId));
                    if (raObj instanceof Amf3TypedObject ra) {
                        ra.set("storageSkinId", 0.0);
                    }
                    ProfileManager.save(profile);
                    send(out, "callBackUnEquipRootAvatarInfo", List.of(1, List.of(), rootAvatarId, 0));
                } else if ("useStorageSkin".equals(fn)) {
                    String skinStorageId = rpcParams.isEmpty() ? "0" : String.valueOf(rpcParams.get(0));
                    String weaponStorageId = rpcParams.size() > 1 ? String.valueOf(rpcParams.get(1)) : "0";
                    long skinIdLong = 0, weaponIdLong = 0;
                    try { skinIdLong = (long)Double.parseDouble(skinStorageId); } catch(Exception e){}
                    try { weaponIdLong = (long)Double.parseDouble(weaponStorageId); } catch(Exception e){}
                    var skinBean = grandSlamStorageMap.get(String.valueOf(skinIdLong));
                    var weaponBean = grandSlamStorageMap.get(String.valueOf(weaponIdLong));
                    if (skinBean instanceof Amf3TypedObject sbSkin) {
                        var ext = sbSkin.fields().get("extBean");
                        if (!(ext instanceof Amf3TypedObject)) {
                            ext = makeStorageExtBean((double)skinIdLong, 0.0);
                            sbSkin.set("extBean", ext);
                        }
                        if (ext instanceof Amf3TypedObject extObj) {
                            extObj.set("weaponStorageId", (double)weaponIdLong);
                            profile.equippedSkins.put(weaponIdLong, skinIdLong);
                            ProfileManager.save(profile);
                        }
                    }
                    List<Object> ret = new ArrayList<>();
                    if (skinBean != null) ret.add(skinBean);
                    if (weaponBean != null) ret.add(weaponBean);
                    send(out, "callbackUseStorageSkin", List.of(1, ret));
                } else if ("weaponEquipSkin".equals(fn)) {
                    String weaponStorageId = rpcParams.isEmpty() ? "0" : String.valueOf(rpcParams.get(0));
                    String skinStorageId = rpcParams.size() > 1 ? String.valueOf(rpcParams.get(1)) : "0";
                    int opType = rpcParams.size() > 2 && rpcParams.get(2) instanceof Number n ? n.intValue() : 1;
                    long weaponIdLong = 0, skinIdLong = 0;
                    try { weaponIdLong = (long)Double.parseDouble(weaponStorageId); } catch(Exception e){}
                    try { skinIdLong = (long)Double.parseDouble(skinStorageId); } catch(Exception e){}
                    var updatedBean = grandSlamStorageMap.get(String.valueOf(weaponIdLong));
                    var skinBean = grandSlamStorageMap.get(String.valueOf(skinIdLong));
                    Amf3TypedObject oldSkinBean = null;
                    if (skinBean instanceof Amf3TypedObject sbSkin) {
                        var ext = sbSkin.fields().get("extBean");
                        if (!(ext instanceof Amf3TypedObject)) {
                            ext = makeStorageExtBean((double)skinIdLong, 0.0);
                            sbSkin.set("extBean", ext);
                        }
                        if (ext instanceof Amf3TypedObject extObj) {
                            if (opType == 1) { // equip
                                Long oldSkinId = profile.equippedSkins.get(weaponIdLong);
                                if (oldSkinId != null && oldSkinId != skinIdLong) {
                                    var oldBeanObj = grandSlamStorageMap.get(String.valueOf(oldSkinId));
                                    if (oldBeanObj instanceof Amf3TypedObject osb && osb.fields().get("extBean") instanceof Amf3TypedObject oExt) {
                                        oExt.set("weaponStorageId", 0.0);
                                        oldSkinBean = osb;
                                    }
                                }
                                extObj.set("weaponStorageId", (double)weaponIdLong);
                                profile.equippedSkins.put(weaponIdLong, skinIdLong);
                            } else { // unequip
                                extObj.set("weaponStorageId", 0.0);
                                profile.equippedSkins.remove(weaponIdLong);
                            }
                            ProfileManager.save(profile);
                        }
                    }
                    List<Object> retList = new ArrayList<>();
                    if (updatedBean != null) retList.add(updatedBean);
                    if (oldSkinBean != null) retList.add(oldSkinBean);
                    if (skinBean != null) retList.add(skinBean);
                    send(out, "callbackUpdateStorages", List.of(1, retList));
                } else if ("getAvatarLimitInfo".equals(fn)) {
                    send(out, "callbackGetAvatarLimitInfo", List.of(new LinkedHashMap<String, Object>()));
                } else if ("change3dRole".equals(fn)) {
                    if (!rpcParams.isEmpty()) {
                        try {
                            int newAvatarId = (int)Double.parseDouble(String.valueOf(rpcParams.get(0)));
                            profile.defaultAvatar = newAvatarId;
                            ProfileManager.save(profile);
                        } catch (Exception ignored) {}
                    }
                    send(out, "callbackChange3dRole", List.of(true));
                } else if ("getMyRankNew".equals(fn)) {
                    send(out, "callbackGetMyRankNew", List.of(5, List.of(4), 1, 100));
                } else if ("mountGrid".equals(fn)) {
                    String mountType = "attrTitle";
                    String mountId = "0";
                    String targetId = "0";
                    String subType = "default";
                    if (!rpcParams.isEmpty()) {
                        Object p0 = rpcParams.get(0);
                        Map<?,?> fields = p0 instanceof Amf3TypedObject typed ? typed.fields() : (p0 instanceof Map<?,?> map ? map : null);
                        if (fields != null) {
                            if (fields.get("mountType") != null) mountType = String.valueOf(fields.get("mountType"));
                            if (fields.get("mountId") != null) mountId = String.valueOf(fields.get("mountId"));
                            if (fields.get("targetId") != null) targetId = String.valueOf(fields.get("targetId"));
                            if (fields.get("subType") != null) subType = String.valueOf(fields.get("subType"));
                        }
                    }
                    subType = (subType == null || subType.isBlank()) ? "default" : subType;
                    var mb = makeMountUserBean(mountId, targetId, subType);
                    profile.mounts.put(mountKey(mountType, subType), new ProfileManager.MountSlot(mountId, targetId, subType));
                    if ("weaponSkinAppearance".equals(mountType)) {
                        try {
                            profile.equippedSkins.put((long)Double.parseDouble(mountId), (long)Double.parseDouble(targetId));
                        } catch (Exception ignored) {}
                    }
                    ProfileManager.save(profile);
                    send(out, "callbackMountGrid", List.of(1, mountType, subType, mb));
                } else if ("unmountGrid".equals(fn)) {
                    String mountType = "attrTitle";
                    String mountId = "0";
                    String targetId = "0";
                    String subType = "default";
                    if (!rpcParams.isEmpty()) {
                        Object p0 = rpcParams.get(0);
                        Map<?,?> fields = p0 instanceof Amf3TypedObject typed ? typed.fields() : (p0 instanceof Map<?,?> map ? map : null);
                        if (fields != null) {
                            if (fields.get("mountType") != null) mountType = String.valueOf(fields.get("mountType"));
                            if (fields.get("mountId") != null) mountId = String.valueOf(fields.get("mountId"));
                            if (fields.get("targetId") != null) targetId = String.valueOf(fields.get("targetId"));
                            if (fields.get("subType") != null) subType = String.valueOf(fields.get("subType"));
                        }
                    }
                    subType = (subType == null || subType.isBlank()) ? "default" : subType;
                    profile.mounts.remove(mountKey(mountType, subType));
                    if ("weaponSkinAppearance".equals(mountType)) {
                        try { profile.equippedSkins.remove((long)Double.parseDouble(mountId)); }
                        catch (Exception ignored) {}
                    }
                    ProfileManager.save(profile);
                    var mb = makeMountUserBean(mountId, "0", subType);
                    send(out, "callbackUnmountGrid", List.of(1, mountType, subType, mb));
                } else if ("getVariationWarDetailInfo".equals(fn)) {
                    var vwd = new Amf3TypedObject("bean.ClientVariationWarData", List.of(
                        "uid", "playingAvatarList", "heroItemList", "variationItemList", "variationScore", "parentRootAvatarId"), false);
                    vwd.set("uid", 1);
                    vwd.set("playingAvatarList", List.of());
                    vwd.set("heroItemList", List.of());
                    vwd.set("variationItemList", List.of());
                    vwd.set("variationScore", 0);
                    vwd.set("parentRootAvatarId", 0);
                    send(out, "callBackGetVariationWarDetailInfo", List.of(vwd));
                } else if ("selectAvatarBag".equals(fn)) {
                    int bagIdx = 0;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) bagIdx = n.intValue();
                    bagIdx = Math.max(0, Math.min(1, bagIdx));
                    profile.selectedAvatarBagIndex = bagIdx;
                    ProfileManager.save(profile);
                    send(out, "callBackSelectAvatarBag", List.of(1, bagIdx, profile.defaultAvatar));
                } else if ("selectBag".equals(fn)) {
                    int bagIdx = 0;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) bagIdx = n.intValue();
                    int maxIdx = Math.max(0, profile.bags.size() - 1);
                    int clamped = Math.max(0, Math.min(maxIdx, bagIdx));
                    profile.selectedBagIndex = clamped;
                    ProfileManager.save(profile);
                    send(out, "onSelectBag", List.of(bagIdx));
                } else if ("equipTacticalWeapon".equals(fn)) {
                    double sid = 0;
                    int bagType = 0;
                    if (!rpcParams.isEmpty()) {
                        try { sid = Double.parseDouble(String.valueOf(rpcParams.get(0))); } catch(Exception ignored){}
                    }
                    if (rpcParams.size() > 1 && rpcParams.get(1) instanceof Number n) {
                        bagType = n.intValue();
                    }
                    long sidLong = (long)sid;
                    var sbObj = grandSlamStorageMap.get(String.valueOf(sidLong));
                    if (sbObj instanceof Amf3TypedObject sb) {
                        int tid = ((Number)sb.fields().get("tid")).intValue();
                        WeaponMeta wm = weaponMetaMap.get(tid);
                        String codeName = wm != null ? wm.codeName : "tactical";
                        if (bagType == 0) {
                            profile.pvpTactical = new ProfileManager.WeaponSlot(sid, tid, codeName);
                        } else {
                            profile.rpgTactical = new ProfileManager.WeaponSlot(sid, tid, codeName);
                        }
                        ProfileManager.save(profile);
                        send(out, "callbackUpdateStorages", List.of(1, List.of(sb)));
                    }
                    send(out, "callbackEquipTacticalWeapon", List.of(1, sid, bagType, 0));
                } else if ("unEquipTacticalWeapon".equals(fn)) {
                    double sid = 0;
                    int bagType = 0;
                    if (!rpcParams.isEmpty()) {
                        try { sid = Double.parseDouble(String.valueOf(rpcParams.get(0))); } catch(Exception ignored){}
                    }
                    if (rpcParams.size() > 1 && rpcParams.get(1) instanceof Number n) {
                        bagType = n.intValue();
                    }
                    if (bagType == 0) profile.pvpTactical = null;
                    else profile.rpgTactical = null;
                    ProfileManager.save(profile);
                    send(out, "callbackUnEquipTacticalWeapon", List.of(1, sid, bagType));
                } else if ("getPersonalise".equals(fn)) {
                    send(out, "callbackGetPersonalise", List.of(getPersonaliseBeans(profile)));
                } else if ("getEquippedTitle".equals(fn)) {
                    double titleId = 0;
                    try { titleId = Double.parseDouble(profile.equippedTitle); } catch (Exception ignored) {}
                    send(out, "callbackGetEquippedTitle", List.of(1, titleId, 0));
                } else if ("useTitle".equals(fn)) {
                    boolean enabled = !rpcParams.isEmpty() && Boolean.TRUE.equals(rpcParams.get(0));
                    String titleId = rpcParams.size() > 1 ? String.valueOf(rpcParams.get(1)) : "";
                    profile.equippedTitle = enabled ? titleId : "";
                    ProfileManager.save(profile);
                } else if ("getCharMedalList".equals(fn)) {
                    send(out, "callbackGetCharMedalList", List.of(getCharMedalBeans()));
                } else if ("checkAndActiveMedal".equals(fn)) {
                    send(out, "callbackCheckAndActiveMedal", List.of(new ArrayList<>(), getCharMedalBeans()));
                } else if ("useCharMedal".equals(fn)) {
                    int medalLine = 0;
                    if (!rpcParams.isEmpty()) {
                        try { medalLine = ((Number)rpcParams.get(0)).intValue(); } catch(Exception e){}
                    }
                    if (charMedalMap.containsKey(medalLine)) {
                        profile.activeMedalLine = medalLine;
                        ProfileManager.save(profile);
                    } else {
                        medalLine = 0;
                    }
                    send(out, "callbackUseCharMedal", List.of(medalLine));
                } else if ("changeMedalStatus".equals(fn)) {
                    List<Integer> changedLines = new ArrayList<>();
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof List<?> requestedLines) {
                        for (Object value : requestedLines) {
                            if (!(value instanceof Number line)) continue;
                            int medalLine = line.intValue();
                            if (charMedalMap.containsKey(medalLine)) changedLines.add(medalLine);
                        }
                    }
                    // Every medal line is unlocked in the offline profile; echo the
                    // validated lines so the client's medal proxy can refresh status.
                    send(out, "callbackChangeMedalStatus", List.of(changedLines));
                } else if ("unlockPersonalise".equals(fn)) {
                    int pid = 0;
                    if (!rpcParams.isEmpty()) {
                        try { pid = ((Number)rpcParams.get(0)).intValue(); } catch(Exception ignored) {}
                    }
                    boolean known = personaliseTypeByTid.containsKey(pid);
                    if (known) ProfileManager.save(profile);
                    send(out, "callbackUnlockPersonalise", List.of(known ? 1 : 0, makePersonaliseBean(pid, profile.equippedPersonalise.getOrDefault(pid, 0))));
                } else if ("unlockPersonaliseWithStorageId".equals(fn)) {
                    int pid = 0;
                    if (!rpcParams.isEmpty()) {
                        try {
                            long storageId = (long)Double.parseDouble(String.valueOf(rpcParams.get(0)));
                            Object storageObj = grandSlamStorageMap.get(String.valueOf(storageId));
                            if (storageObj instanceof Amf3TypedObject storageBean) {
                                pid = ((Number)storageBean.fields().get("tid")).intValue();
                            }
                        } catch(Exception ignored) {}
                    }
                    boolean known = personaliseTypeByTid.containsKey(pid);
                    if (known) ProfileManager.save(profile);
                    send(out, "callbackUnlockPersonalise", List.of(known ? 1 : 0, makePersonaliseBean(pid, profile.equippedPersonalise.getOrDefault(pid, 0))));
                } else if ("equipPersonalise".equals(fn)) {
                    // Client call sites pass (equipIndex, personaliseTid), while
                    // callbackEquipPersonalise expects (ret, personaliseTid, equipIndex).
                    int pid = 0, pidx = 0;
                    if (rpcParams.size() >= 2) {
                        try {
                            pidx = ((Number)rpcParams.get(0)).intValue();
                            pid = ((Number)rpcParams.get(1)).intValue();
                        } catch(Exception e){}
                    }
                    boolean known = personaliseTypeByTid.containsKey(pid);
                    if (known && pidx >= 0) {
                        int itemType = personaliseTypeByTid.get(pid);
                        int requestedEquipIndex = pidx;
                        profile.equippedPersonalise.entrySet().removeIf(entry ->
                            entry.getValue() == requestedEquipIndex && personaliseTypeByTid.getOrDefault(entry.getKey(), -1) == itemType);
                        if (pidx > 0) profile.equippedPersonalise.put(pid, pidx);
                        ProfileManager.save(profile);
                    }
                    send(out, "callbackEquipPersonalise", List.of(known ? 1 : 0, pid, pidx));
                } else if ("unEquipPersonalise".equals(fn)) {
                    int pid = 0;
                    if (!rpcParams.isEmpty()) {
                        try { pid = ((Number)rpcParams.get(0)).intValue(); } catch(Exception e){}
                    }
                    boolean known = personaliseTypeByTid.containsKey(pid);
                    if (known) {
                        profile.equippedPersonalise.remove(pid);
                        ProfileManager.save(profile);
                    }
                    send(out, "callbackUnEquipPersonalise", List.of(known ? 1 : 0, pid));
                } else if ("inactivePersonalise".equals(fn)) {
                    int pid = 0;
                    if (!rpcParams.isEmpty()) {
                        try { pid = ((Number)rpcParams.get(0)).intValue(); } catch(Exception e){}
                    }
                    profile.equippedPersonalise.remove(pid);
                    ProfileManager.save(profile);
                    send(out, "callbackInactivePersonalise", List.of(1, pid));
                } else if ("mounts".equals(fn)) {
                    String mType = !rpcParams.isEmpty() ? String.valueOf(rpcParams.get(0)) : "attrTitle";
                    String subType = rpcParams.size() > 1 ? String.valueOf(rpcParams.get(1)) : "default";
                    subType = (subType == null || subType.isBlank()) ? "default" : subType;
                    List<Object> retList = new ArrayList<>();
                    if ("weaponSkinAppearance".equals(mType)) {
                        for (var entry : profile.equippedSkins.entrySet()) {
                            long wId = entry.getKey();
                            long sId = entry.getValue();
                            retList.add(makeMountUserBean(String.valueOf(wId), String.valueOf(sId), ""));
                        }
                    } else {
                        ProfileManager.MountSlot existing = profile.mounts.get(mountKey(mType, subType));
                        if (existing != null) {
                            retList.add(makeMountUserBean(existing.mountId, existing.targetId, existing.subType));
                        }
                    }
                    Map<Object, Object> retMap = new LinkedHashMap<>();
                    if ("attrTitle".equals(mType)) {
                        // MedalProxy.callbackMounts assigns param2[0] directly to a
                        // MountUserBean. Returning the generic list wrapper here
                        // makes that assignment fail with AIR Error #1034.
                        retMap.put("0", retList.isEmpty() ? null : retList.get(0));
                    } else {
                        retMap.put("default", retList);
                        retMap.put(0, retList);
                    }
                    send(out, "callbackMounts", List.of(mType, "default", retMap));
                } else if ("getFestivalData".equals(fn)) {
                    send(out, "callbackGetFestivalData", List.of(new LinkedHashMap<String, Object>()));
                } else if ("heartBeat".equals(fn)) {
                    // no-op
                } else if (!RpcTable.dispatch(out, fn)) {
                    // The table is generated from the client's registered callbacks,
                    // so a miss means this build has no handler for the reply either.
                    System.out.println("UNIMPL_RPC " + fn + " params=" + rpcParams);
                }
                } catch (Exception rpcError) {
                    // A single broken branch must not drop the whole session.
                    long n = RPC_ERR_COUNT.incrementAndGet();
                    System.out.println("[RPC-ERR #" + n + "] " + fn + ": " + rpcError);
                    if (n <= 20) rpcError.printStackTrace();
                } finally {
                    // 观测（M2）：请求已解析但没有任何回包 -> Flash 侧 callback 永久 pending，
                    // 表现为"卡加载/白屏且无报错"。这类静默失败必须可见。
                    if (Boolean.FALSE.equals(SENT.get()) && fn != null && !NO_REPLY_OK.contains(fn)) {
                        long n = NO_REPLY_COUNT.incrementAndGet();
                        if (n <= 200) System.out.println("[NO-REPLY #" + n + "] " + fn + " params=" + rpcParams);
                    }
                }
            }
        } catch (java.net.SocketTimeoutException ste) {
            System.out.println("[conn] TIMEOUT " + peer + " frames=" + frameCount
                + " after " + (System.currentTimeMillis() - t0) + "ms");
        } catch (Exception e) {
            System.out.println("[conn] END " + peer + " frames=" + frameCount + " err=" + e);
        } finally {
            System.out.println("[conn] CLOSE " + peer + " frames=" + frameCount
                + " lived=" + (System.currentTimeMillis() - t0) + "ms");
            try { s.close(); } catch (IOException e) {}
        }
    }

    static void send(DataOutputStream out, String fn, java.util.List<Object> params) throws Exception {
        byte[] amf = Amf3Encoder.encodeOnce(Amf3TypedObject.apc(fn, params));
        out.writeInt(amf.length + 1); out.writeByte(0); out.write(amf); out.flush();
        markSent();
        if (VERBOSE) System.out.println("-> " + fn + " " + amf.length);
    }

    static final boolean VERBOSE = "1".equals(System.getProperty("ssjj.verbose"));

    public static void main(String[] args) throws Exception {
        int port = args.length > 0 ? Integer.parseInt(args[0]) : 2000;
        loadWeaponMeta();
        loadGrandSlamStorage();
        loadPersonaliseAndMedals();
        RpcTable.load(projectRoot().resolve("_work").resolve("lobby_host").resolve("rpc_table.txt"));
        // P0: 只绑回环。原实现 new ServerSocket(port) 监听 0.0.0.0，
        // 且 getUserDataByLogin 直接返回 loginRet=1（无鉴权）、RPC 还能派生进程 —— 局域网任意主机可拉号。
        ServerSocket ss = new ServerSocket(port, 50, java.net.InetAddress.getLoopbackAddress());
        System.out.println("LobbyLoginServer listening 127.0.0.1:" + port
                + " [maxConn=" + MAX_CONN + " maxFrame=" + MAX_FRAME
                + " idleTimeout=" + IDLE_TIMEOUT_MS + "ms]");
        while (true) {
            Socket s = ss.accept();
            // P0: 连接数上限，防 accept 风暴打满线程
            if (ACTIVE_CONN.get() >= MAX_CONN) {
                System.out.println("[WARN] connection limit " + MAX_CONN + " reached, rejecting "
                        + s.getRemoteSocketAddress());
                try { s.close(); } catch (IOException ignored) {}
                continue;
            }
            ACTIVE_CONN.incrementAndGet();
            Thread t = new Thread(() -> {
                try { handle(s); } finally { ACTIVE_CONN.decrementAndGet(); }
            }, "lobby-conn");
            t.setDaemon(true);
            t.start();
        }
    }
}
