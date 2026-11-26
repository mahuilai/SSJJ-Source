import com.strikegod.downloader.service.Amf3Encoder;
import com.strikegod.downloader.service.Amf3TypedObject;
import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;
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

    static Amf3TypedObject makeBagData(ProfileManager.BagSlot bag) {
        var bd = new Amf3TypedObject("netdata.BagData", List.of(
            "masterWeapon", "secondaryWeapon", "closedWeapon", "bom1", "bom2", "bom3",
            "isGlobalBag", "bagDataScore"), false);
        bd.set("masterWeapon", makeWeaponData(bag.master));
        bd.set("secondaryWeapon", makeWeaponData(bag.secondary));
        bd.set("closedWeapon", makeWeaponData(bag.closed));
        bd.set("bom1", makeWeaponData(bag.bom1));
        bd.set("bom2", makeWeaponData(bag.bom2));
        bd.set("bom3", makeWeaponData(bag.bom3));
        bd.set("isGlobalBag", false);
        bd.set("bagDataScore", 1000);
        return bd;
    }

    static Amf3TypedObject makeWeaponData(ProfileManager.WeaponSlot slot) {
        return slot == null ? null : makeWeaponData(slot.storageId, slot.codeName, slot.tid);
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
        int adventureRating;
    }
    static Map<Integer, WeaponMeta> weaponMetaMap = new HashMap<>();
    static Map<?, ?> avatarCatalog = Map.of();
    static Map<?, ?> skinCatalog = Map.of();
    static Map<?, ?> avatarPartCatalog = Map.of();

    static void loadWeaponMeta() {
        try {
            byte[] b = Files.readAllBytes(Paths.get("../cache/gamedata1.amf3"));
            Map<?, ?> m = (Map<?, ?>) new Amf3Decoder(b).decodeOne();
            if (m.get("shop_avatar") instanceof Map<?, ?> avatars) avatarCatalog = avatars;
            if (m.get("shop_skin") instanceof Map<?, ?> skins) skinCatalog = skins;
            if (m.get("shop_avatarParts") instanceof Map<?, ?> parts) avatarPartCatalog = parts;
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
                    wm.adventureRating = (int)Math.max(0, Math.min(400,
                        numberArgument(row.get("attackLv")) + numberArgument(row.get("defenseLv"))
                        + numberArgument(row.get("coordLv"))));
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
    static final String LOCAL_SECOND_ACCOUNT = "900000002";
    static final long LOCAL_SECOND_CHARACTER = 1000200072529L;
    static final int BOT_CHANNEL_ID = 2;

    static final class LobbySession {
        final DataOutputStream out;
        final Object sendLock = new Object();
        volatile double characterId = 1000200072528.0;
        volatile String playerName = "离线玩家";
        volatile String career = "police";
        volatile int selectedBagIndex = 0;
        volatile int team = 1;
        volatile boolean observerFlag = false;
        volatile int readyGame = 1;
        volatile int roomId = 0;
        volatile int channelId = 1;
        volatile String loginName = "";
        volatile String lobbyToken = "";
        volatile String clanName = "无端离线战队";
        volatile int clanId = 1;
        volatile File profileFile = ProfileManager.getProfileFile();
        LobbySession(DataOutputStream out) { this.out = out; }
    }

    static final class LobbyRoom {
        final int roomId;
        final int channelId;
        final List<LobbySession> members = new CopyOnWriteArrayList<>();
        volatile Amf3TypedObject rawRoom;
        volatile double hostCharId;
        volatile String hostName;
        volatile String roomName = "Server-First 联机房";
        volatile int sceneId = 12;
        volatile int raceType = 2003;
        volatile int limitNumber = 10;
        volatile int tcpPort = 27100;
        volatile int udpPort = 27101;
        volatile Process battleServerProc = null;
        volatile Path battleControl = null;
        volatile int battleSeats = 0;

        LobbyRoom(int roomId, LobbySession host, Amf3TypedObject baseRoom) {
            this.roomId = roomId;
            this.channelId = host.channelId;
            this.rawRoom = baseRoom;
            this.hostCharId = host.characterId;
            this.hostName = host.playerName;
        }

        synchronized Amf3TypedObject toAmf3() {
            var keys = new ArrayList<>(List.of(
                "roomId", "roomDisplayId", "roomName", "sceneId", "raceType", "limitNumber",
                "createCharacterId", "createCharName", "createCharVipLv", "status", "gameStatus",
                "accessNumber", "battleNumber", "gameLimitNumber"));
            Amf3TypedObject r = new Amf3TypedObject("bean.RoomInfoEx", keys, true);
            if (rawRoom != null) {
                for (var e : rawRoom.fields().entrySet()) {
                    if (e.getKey() != null && !keys.contains(e.getKey())) r.set(e.getKey(), e.getValue());
                }
            }
            r.set("roomId", (double) roomId);
            r.set("roomDisplayId", (double) roomId);
            r.set("roomName", roomName);
            r.set("sceneId", sceneId);
            r.set("raceType", raceType);
            r.set("limitNumber", limitNumber);
            r.set("createCharacterId", hostCharId);
            r.set("createCharName", hostName);
            r.set("createCharVipLv", 15);
            r.set("status", 0);
            r.set("gameStatus", battleServerProc != null && battleServerProc.isAlive() ? 1 : 0);
            r.set("accessNumber", members.size());
            r.set("battleNumber", battleServerProc != null && battleServerProc.isAlive() ? battleSeats : 0);
            r.set("gameLimitNumber", limitNumber);
            return r;
        }

        synchronized Amf3TypedObject toListAmf3() {
            var item = new Amf3TypedObject("bean.ClientRoom", List.of(
                "roomId", "roomDisplayId", "roomName", "sceneId", "raceType", "limitNumber",
                "createCharacterId", "createCharName", "createCharVipLv", "status", "gameStatus",
                "accessNumber", "battleNumber", "gameLimitNumber", "isJoin", "channelId"
            ), false);
            var room = toAmf3();
            for (String key : item.sealedNames()) {
                if (room.fields().containsKey(key)) item.set(key, room.fields().get(key));
            }
            item.set("gameLimitNumber", limitNumber);
            item.set("battleNumber", members.size());
            item.set("isJoin", true);
            item.set("channelId", channelId);
            return item;
        }

        List<Object> userListAmf3() {
            var list = new ArrayList<Object>(members.size());
            for (LobbySession m : members) {
                list.add(makeClientRoomUser(m));
            }
            return list;
        }

        void broadcast(String fn, List<Object> params) {
            for (LobbySession m : members) {
                try {
                    synchronized (m.sendLock) {
                        send(m.out, fn, params);
                    }
                } catch (Exception ignored) {}
            }
        }
    }

    static final ConcurrentHashMap<Integer, LobbyRoom> ROOMS = new ConcurrentHashMap<>();
    static final ConcurrentHashMap<Double, LobbySession> ACTIVE_SESSIONS = new ConcurrentHashMap<>();
    static final ConcurrentHashMap<String, LobbySession> LOBBY_TOKENS = new ConcurrentHashMap<>();
    static final ConcurrentHashMap<Double, LobbySession> ACTIVE_CHANNELS = new ConcurrentHashMap<>();
    static final AtomicInteger NEXT_ROOM_ID = new AtomicInteger(1001);
    static final AtomicInteger NEXT_GUEST_ID = new AtomicInteger(1);

    static void broadcastRoomListChange(LobbyRoom room, String event, List<Object> params) {
        for (var member : ACTIVE_CHANNELS.values()) {
            if (member.channelId != room.channelId || member.roomId != 0) continue;
            try { send(member.out, event, params); }
            catch (IOException ignored) {}
            catch (Exception e) { System.err.println("[LobbyServer] Room list broadcast: " + e.getMessage()); }
        }
    }

    static LobbyRoom findRoomForJoin(int requestedRoomId, int channelId) {
        if (requestedRoomId > 0) {
            var room = ROOMS.get(requestedRoomId);
            return room != null && room.channelId == channelId ? room : null;
        }
        for (LobbyRoom r : ROOMS.values()) {
            if (r.channelId == channelId && r.members.size() < r.limitNumber) return r;
        }
        return null;
    }

    static Amf3TypedObject makeClientRoomUser(LobbySession session) {
        var u = new Amf3TypedObject("bean.ClientRoomUser", List.of(
            "playerName", "characterId", "readyGame", "inGameServer", "team",
            "lv", "vipLv", "teamName", "teamId", "observerFlag",
            "dId", "dName", "lastInviteTime", "raceRankSect", "raceIsKing", "raceRankLv"
        ), false);
        u.set("playerName", session.playerName);
        u.set("characterId", session.characterId);
        u.set("readyGame", session.readyGame);
        u.set("inGameServer", false);
        u.set("team", session.team);
        u.set("lv", 91);
        u.set("vipLv", 15);
        u.set("teamName", session.clanName);
        u.set("teamId", session.clanId);
        u.set("observerFlag", session.observerFlag);
        u.set("dId", 1);
        u.set("dName", "离线服");
        u.set("lastInviteTime", 0.0);
        u.set("raceRankSect", 5);
        u.set("raceIsKing", 0);
        u.set("raceRankLv", 25);
        return u;
    }

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

    static void launchBattleClient(String career, int bag, int sceneId, int raceType, int team, int allyBots, int enemyBots, int maxHumans, int tcpPort, int udpPort) {
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
                "--profile", ProfileManager.getProfileFile().getAbsolutePath(),
                "--career", career,
                "--bag", String.valueOf(bag),
                "--scene-id", String.valueOf(sceneId),
                "--race-type", String.valueOf(raceType),
                "--team", String.valueOf(team),
                "--ally-bots", String.valueOf(allyBots),
                "--enemy-bots", String.valueOf(enemyBots),
                "--max-human-players", String.valueOf(Math.max(1, maxHumans)),
                "--tcp-port", String.valueOf(tcpPort),
                "--udp-port", String.valueOf(udpPort)
            ).directory(root.toFile())
                .redirectErrorStream(true)
                .redirectOutput(ProcessBuilder.Redirect.appendTo(root.resolve("Game-SSJJ-logs/room-battle.log").toFile()))
                .start();
            System.out.println("[LobbyServer] Spawned " + script + " (career=" + career + ", bag=" + bag
                + ", scene=" + sceneId + ", race=" + raceType + ", team=" + team
                + ", ally=" + allyBots + ", enemy=" + enemyBots + ", humans=" + maxHumans
                + ", tcp=" + tcpPort + ", udp=" + udpPort + ")");
        } catch (Exception e) {
            System.err.println("[LobbyServer] Failed to launch battle client: " + e.getMessage());
        }
    }

    static boolean isHeadlessBattleBridge() {
        return "1".equals(System.getProperty("ssjj.lobby.headlessBattle"))
            || "1".equals(System.getenv("SSJJ_LOBBY_HEADLESS_BATTLE"));
    }

    static boolean isLocalDualBattle() {
        return "1".equals(System.getenv("SSJJ_LOBBY_LOCAL_DUAL"));
    }

    record BattleSeat(long characterId, int team, String playerName, File profileFile) {}

    static boolean launchRoomBattle(LobbyRoom room, LobbySession host, List<BattleSeat> seats, int allyBots, int enemyBots) {
        synchronized (room) {
            return launchRoomBattleLocked(room, host, seats, allyBots, enemyBots);
        }
    }

    private static boolean launchRoomBattleLocked(LobbyRoom room, LobbySession host, List<BattleSeat> seats, int allyBots, int enemyBots) {
        try {
            if (room.battleServerProc != null && room.battleServerProc.isAlive())
                return Files.isRegularFile(room.battleControl.resolve("ready"));
            Path root = projectRoot();
            Path control = Files.createTempDirectory(Files.createDirectories(root.resolve("Game-SSJJ-logs")), "room-" + room.roomId + "-");
            Path script = root.resolve("_work/launch_battle_from_lobby.py");
            var command = new ArrayList<>(List.of("python", script.toString(),
                "--profile", host.profileFile.getAbsolutePath(),
                "--scene-id", String.valueOf(room.sceneId),
                "--race-type", String.valueOf(room.raceType),
                "--team", String.valueOf(host.team),
                "--room-id", String.valueOf(room.roomId),
                "--tcp-port", String.valueOf(room.tcpPort),
                "--udp-port", String.valueOf(room.udpPort),
                "--ally-bots", String.valueOf(Math.max(0, allyBots)),
                "--enemy-bots", String.valueOf(Math.max(0, enemyBots)),
                "--room-control", control.toString()));
            for (BattleSeat seat : seats) {
                command.addAll(List.of("--seat", String.valueOf(seat.characterId()), String.valueOf(seat.team()),
                    seat.playerName(), seat.profileFile().getAbsolutePath()));
            }
            if (isHeadlessBattleBridge()) command.add("--server-only");
            room.battleControl = control;
            room.battleSeats = seats.size();
            var launcher = new ProcessBuilder(command).directory(root.toFile())
                .redirectErrorStream(true)
                .redirectOutput(control.resolve("bridge.log").toFile());
            launcher.environment().put("PYTHONIOENCODING", "utf-8");
            room.battleServerProc = launcher.start();
            long deadline = System.currentTimeMillis() + 10000;
            while (System.currentTimeMillis() < deadline && room.battleServerProc.isAlive()) {
                if (Files.isRegularFile(control.resolve("ready"))) {
                    System.out.println("[LobbyServer] Battle room " + room.roomId + " ready at 127.0.0.1:"
                        + room.tcpPort + "/" + room.udpPort + " seats=" + seats.size() + " logs=" + control);
                    return true;
                }
                Thread.sleep(50);
            }
            stopRoomBattle(room);
            System.err.println("[LobbyServer] Room bridge did not become ready. See " + control.resolve("bridge.log"));
        } catch (Exception e) {
            stopRoomBattle(room);
            System.err.println("[LobbyServer] Failed to launch room battle: " + e.getMessage());
        }
        return false;
    }

    private static void stopRoomBattle(LobbyRoom room) {
        if (room.battleControl == null) return;
        try { Files.writeString(room.battleControl.resolve("stop"), ""); }
        catch (IOException e) { System.err.println("[LobbyServer] Failed to stop room " + room.roomId + ": " + e.getMessage()); }
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

    static Amf3TypedObject copyBean(Amf3TypedObject source) {
        var copy = new Amf3TypedObject(source.className(), source.sealedNames(), source.dynamic());
        source.fields().forEach(copy::set);
        source.dynamicFields().forEach(copy::set);
        return copy;
    }

    static Amf3TypedObject avatarFor(Map<String, Object> avatars, int id) {
        return avatars.get(String.valueOf(id)) instanceof Amf3TypedObject avatar ? avatar : null;
    }

    static boolean selectAvatar(ProfileManager.Profile profile, Map<String, Object> avatars, int id) {
        var avatar = avatarFor(avatars, id);
        if (avatar == null) return false;
        profile.defaultAvatar = id;
        profile.defaultCareer = String.valueOf(avatar.fields().get("career"));
        return true;
    }

    static Amf3TypedObject makeUserSettings(ProfileManager.Profile profile) {
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
        for (var entry : profile.userSettings.entrySet()) {
            String name = entry.getKey();
            String saved = entry.getValue();
            Object fallback = sb.fields().get(name);
            if (fallback instanceof Boolean) sb.set(name, Boolean.parseBoolean(saved));
            else if (fallback instanceof Number) {
                try { sb.set(name, Integer.parseInt(saved)); } catch (NumberFormatException ignored) {}
            } else if (fallback instanceof String) sb.set(name, saved);
        }
        return sb;
    }

    static long numberArgument(Object value) {
        if (value instanceof Number n) return n.longValue();
        try { return (long)Double.parseDouble(String.valueOf(value)); }
        catch (NumberFormatException ignored) { return 0; }
    }

    static Amf3TypedObject storageCatalogItem(long id) {
        return grandSlamStorageMap.get(String.valueOf(id)) instanceof Amf3TypedObject bean ? bean : null;
    }

    static Map<?, ?> catalogEntry(Map<?, ?> catalog, int id) {
        Object row = catalog.get(String.valueOf(id));
        if (row == null) row = catalog.get(id);
        if (row == null) row = catalog.get((double)id);
        return row instanceof Map<?, ?> fields ? fields : Map.of();
    }

    static int avatarPartSlot(Amf3TypedObject storage) {
        if (intField(storage, "type", 0) != 16) return -1;
        var config = catalogEntry(avatarPartCatalog, intField(storage, "tid", 0));
        Object slot = config.get("type");
        return slot == null ? -1 : (int)numberArgument(slot);
    }

    static void applyAvatarAppearance(Amf3TypedObject avatar, ProfileManager.Profile profile, int roleId) {
        var appearance = profile.avatarAppearances.get(roleId);
        long skinId = appearance == null ? 0 : appearance.storageSkinId();
        int facadeId = appearance == null ? 0 : appearance.facadePartId();
        var skinStorage = storageCatalogItem(skinId);
        int avatarId = intField(skinStorage, "tid", 0);
        if (intField(skinStorage, "type", 0) == 8) {
            var skin = catalogEntry(skinCatalog, avatarId);
            avatarId = (int)numberArgument(skin.get("originCharId"));
        }
        avatar.set("storageSkinId", (double)skinId);
        avatar.set("careerSkin", Objects.toString(catalogEntry(avatarCatalog, avatarId).get("carrer"), ""));
        avatar.set("facadePartId", facadeId);
        var parts = new LinkedHashMap<String, Object>();
        profile.avatarParts.getOrDefault(roleId, Map.of()).forEach((slot, id) -> {
            int tid = intField(storageCatalogItem(id), "tid", 0);
            Object career = catalogEntry(avatarPartCatalog, tid).get("carrer");
            if (career == null) return;
            var part = new Amf3TypedObject("netdata.AvatarPartData", List.of(
                "avatarPartStorageId", "avatarPartId", "avatarPartCodeName", "backDecorationExp", "backDecorationGp"), false);
            part.set("avatarPartStorageId", (double)id).set("avatarPartId", tid).set("avatarPartCodeName", career)
                .set("backDecorationExp", 0).set("backDecorationGp", 0);
            parts.put(String.valueOf(slot), part);
        });
        avatar.set("avatarPartDataMap", parts);
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

    static Amf3TypedObject storageForProfile(ProfileManager.Profile profile, long id) {
        var source = grandSlamStorageMap.get(String.valueOf(id));
        if (!(source instanceof Amf3TypedObject bean)) return null;
        int amount = profile.storageAmounts.getOrDefault(id, intField(bean, "amount", 1));
        return copyStorageBean(id, amount);
    }

    static List<Object> updateWeaponSkin(ProfileManager.Profile profile, long weaponId, long skinId, boolean equip) {
        var weapon = storageForProfile(profile, weaponId);
        var skin = storageForProfile(profile, skinId);
        if (intField(weapon, "type", 0) != 1 || intField(skin, "type", 0) != 8) return List.of();
        var changes = new ArrayList<Object>();
        changes.add(weapon);
        Long previous = profile.equippedSkins.get(weaponId);
        if (equip) {
            profile.equippedSkins.values().removeIf(id -> id == skinId);
            profile.equippedSkins.put(weaponId, skinId);
            if (previous != null && previous != skinId) {
                var oldSkin = storageForProfile(profile, previous);
                if (oldSkin != null) changes.add(oldSkin);
            }
        } else {
            profile.equippedSkins.remove(weaponId, skinId);
        }
        if (skin.fields().get("extBean") instanceof Amf3TypedObject ext) {
            ext.set("weaponStorageId", equip ? (double)weaponId : 0.0);
        }
        changes.add(skin);
        ProfileManager.save(profile);
        return changes;
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
            addEquippedWeaponId(ownedIds, equippedIds, bag.bom2);
            addEquippedWeaponId(ownedIds, equippedIds, bag.bom3);
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
    static final java.util.Set<String> NO_REPLY_OK = java.util.Set.of("heartBeat", "firstHitSetButton");
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
        LobbySession session = null;
        try (DataInputStream in = new DataInputStream(new BufferedInputStream(s.getInputStream()));
             DataOutputStream out = new DataOutputStream(new BufferedOutputStream(s.getOutputStream()))) {
            
            ProfileManager.Profile profile = ProfileManager.load();
            session = new LobbySession(out);
            session.playerName = profile.playerName;
            session.career = profile.defaultCareer;
            session.selectedBagIndex = profile.selectedBagIndex;
            session.team = profile.team;
            Amf3TypedObject settings = makeUserSettings(profile);
            List<Amf3TypedObject> sessionAvatarBags = new ArrayList<>();
            List<Amf3TypedObject> bagArray = new ArrayList<>();
            Map<String, Object> rootAvatarDataHashMap = new LinkedHashMap<>();
            AdventureLobby adventure = new AdventureLobby();

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
                    var ch1 = makeLobbyRoomChannel(1, "本地联机频道", 1, 1);
                    var ch2 = makeLobbyRoomChannel(BOT_CHANNEL_ID, "人机娱乐频道", 2, 217);
                    var ch3 = makeLobbyRoomChannel(3, "经典竞技频道", 3, 215);
                    send(out, "callChannelList", List.of(List.of(ch1, ch2, ch3), new LinkedHashMap<String, Object>()));
                } else if ("getGlobalRoomChannel".equals(fn)) {
                    send(out, "callbackGetGlobalRoomChannel", List.of(List.of()));
                    send(out, "onGetGlobalChannelList", List.of(List.of()));
                } else if ("getPatchca".equals(fn)) {
                    var params = new java.util.ArrayList<Object>(); params.add(null);
                    send(out, "callbackGetPatchca", params);
                } else if ("loginV3".equals(fn)) {
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof String name) session.loginName = name;
                    send(out, "callBackLoginV3", List.of(1));
                } else if ("getUserDataByLogin".equals(fn)) {
                    boolean localSecond = LOCAL_SECOND_ACCOUNT.equals(session.loginName);
                    session.profileFile = localSecond ? ProfileManager.localSecondProfileFile() : ProfileManager.getProfileFile();
                    profile = ProfileManager.load(session.profileFile, localSecond ? "糖心大掌门" : null);
                    synchronized (ACTIVE_SESSIONS) {
                        if (ACTIVE_SESSIONS.get(session.characterId) == session) {
                            // Keep the room identity on repeated user-data requests.
                        } else if (localSecond) {
                            if (ACTIVE_SESSIONS.containsKey((double)LOCAL_SECOND_CHARACTER)) {
                                System.out.println("[LobbyServer] Local second account is already logged in");
                                break;
                            }
                            session.characterId = LOCAL_SECOND_CHARACTER;
                            session.playerName = profile.playerName;
                            session.clanName = "91传媒";
                            session.clanId = 91;
                        } else if (ACTIVE_SESSIONS.containsKey(1000200072528.0)) {
                            int seq = NEXT_GUEST_ID.incrementAndGet();
                            session.characterId = 1000200072528.0 + seq;
                            session.playerName = "联机玩家" + seq;
                        } else {
                            session.characterId = 1000200072528.0;
                            session.playerName = profile.playerName;
                        }
                        if (!rpcParams.isEmpty() && rpcParams.get(0) != null) {
                            String requestedName = String.valueOf(rpcParams.get(0)).trim();
                            if (!requestedName.isEmpty() && !"321282597".equals(requestedName) && !"local".equalsIgnoreCase(requestedName)) {
                                session.playerName = requestedName;
                            }
                        }
                        session.career = profile.defaultCareer;
                        session.selectedBagIndex = profile.selectedBagIndex;
                        session.team = profile.team;
                        ACTIVE_SESSIONS.put(session.characterId, session);
                        if (session.lobbyToken.isEmpty()) session.lobbyToken = UUID.randomUUID().toString();
                        LOBBY_TOKENS.put(session.lobbyToken, session);
                    }
                    profile.persistent = localSecond || session.characterId == 1000200072528.0;
                    System.out.println("[LobbyServer] Lobby player=" + (long)session.characterId + " profile=" + session.profileFile.getName());
                    ensureDefaultRenameCard(profile);
                    final ProfileManager.Profile loadedProfile = profile;
                    rootAvatarDataHashMap.clear();
                    grandSlamRootAvatarMap.forEach((id, value) -> {
                        if (!(value instanceof Amf3TypedObject original)) return;
                        var avatar = copyBean(original);
                        applyAvatarAppearance(avatar, loadedProfile, Integer.parseInt(id));
                        rootAvatarDataHashMap.put(id, avatar);
                    });

                    settings = makeUserSettings(profile);

                    // Build session avatar bags and loadout bags from profile
                    sessionAvatarBags.clear();
                    bagArray.clear();
                    for (int i = 0; i < profile.bags.size(); i++) {
                        ProfileManager.BagSlot bs = profile.bags.get(i);
                        sessionAvatarBags.add(makeAvatarBagData(bs.roleTID, bs.roleCTID));

                        bagArray.add(makeBagData(bs));
                    }

                    var rpgBagArray = new ArrayList<Amf3TypedObject>();
                    for (var bag : bagArray) rpgBagArray.add(copyBean(bag));
                    rpgBagArray.get(Math.max(0, Math.min(profile.selectedBagIndex, rpgBagArray.size() - 1)))
                        .set("bagDataScore", AdventureLobby.power(profile));
                    var globalBag = bagArray.get(0);

                    // The static storage catalog is metadata, not the player's inventory.
                    // Sending all 21k catalog rows makes StorageProxy treat catalog packs
                    // as owned items and spam thousands of missing shop_pack errors.
                    var storageMap = buildPlayerStorageMap(profile);

                    var activeAvatarBag = profile.bags.get(profile.selectedAvatarBagIndex);
                    var raT = avatarFor(rootAvatarDataHashMap, activeAvatarBag.roleTID);
                    var raCT = avatarFor(rootAvatarDataHashMap, activeAvatarBag.roleCTID);

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
                        "bagArray", "rpgBagArray", "globalBag", "pvpTacticalBag", "rpgTacticalBag", "boomCnt",
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
                    u.set("userId", localSecond ? Integer.parseInt(LOCAL_SECOND_ACCOUNT) : 321282597);
                    u.set("username", localSecond ? LOCAL_SECOND_ACCOUNT : "321282597");
                    u.set("playerName", session.playerName);
                    u.set("lastChangePlayerName", (double)profile.lastChangePlayerName);
                    u.set("changename", "");
                    u.set("characterId", session.characterId);
                    u.set("vipLv", 18);
                    u.set("goldTotal", 91);
                    u.set("gold", 91);
                    u.set("gp", 91);
                    u.set("gift", 91);
                    u.set("reputationScore", 100);
                    u.set("isadult", 1);
                    u.set("accountTag", 3);
                    u.set("teamId", localSecond ? session.clanId : 0);
                    u.set("token", session.lobbyToken);
                    u.set("regTime", 0.0);
                    u.set("selectedBagIndex", profile.selectedBagIndex);
                    u.set("settingBean", settings);
                    u.set("charMedalBean", charMedalMap.containsKey(profile.activeMedalLine)
                        ? copyCharMedalBean(charMedalMap.get(profile.activeMedalLine)) : null);
                    u.set("defaultAvatar", profile.defaultAvatar);
                    u.set("avatarT", activeAvatarBag.roleTID);
                    u.set("avatarCT", activeAvatarBag.roleCTID);
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
                    u.set("boomCnt", 3);
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
                    String token = !rpcParams.isEmpty() && rpcParams.get(0) instanceof String value ? value : "";
                    LobbySession account = LOBBY_TOKENS.get(token);
                    if (account == null && ACTIVE_SESSIONS.get(session.characterId) != session) {
                        send(out, "callEnterChannelSuccess", List.of(-2, chId));
                        continue;
                    }
                    if (account != null && account != session) {
                        session.characterId = account.characterId;
                        session.loginName = account.loginName;
                        session.clanId = account.clanId;
                        session.clanName = account.clanName;
                        session.profileFile = account.profileFile;
                        boolean second = LOCAL_SECOND_ACCOUNT.equals(account.loginName);
                        profile = ProfileManager.load(session.profileFile, second ? "糖心大掌门" : null);
                        profile.persistent = second || session.characterId == 1000200072528.0;
                        session.playerName = profile.persistent ? profile.playerName : account.playerName;
                        session.career = profile.defaultCareer;
                        session.selectedBagIndex = profile.selectedBagIndex;
                        session.team = profile.team;
                    }
                    if (session.channelId != chId) leaveCurrentRoom(session);
                    session.channelId = chId;
                    var previous = ACTIVE_CHANNELS.put(session.characterId, session);
                    if (previous != null && previous != session) leaveCurrentRoom(previous);
                    send(out, "callEnterChannelSuccess", List.of(1, chId));
                    System.out.println("[LobbyServer] Channel " + chId + " entered by " + (long)session.characterId);
                } else if ("getRoomList".equals(fn)) {
                    var rooms = new ArrayList<Object>();
                    for (LobbyRoom r : ROOMS.values()) if (r.channelId == session.channelId) rooms.add(r.toListAmf3());
                    send(out, "callBackGetRoomList", List.of(rooms, 1));
                } else if ("createRoom".equals(fn)) {
                    Amf3TypedObject roomObj = rpcParams.isEmpty() ? null : toRoomInfoObject(rpcParams.get(0));
                    if (roomObj == null) {
                        roomObj = new Amf3TypedObject("bean.RoomInfoEx", List.of("sceneId", "raceType", "limitNumber", "roomName"), false);
                    }
                    int rid = NEXT_ROOM_ID.getAndIncrement();
                    LobbyRoom room = new LobbyRoom(rid, session, roomObj);
                    room.sceneId = Math.max(1, intField(roomObj, "sceneId", 12));
                    room.raceType = intField(roomObj, "raceType", 2003);
                    room.limitNumber = Math.max(2, intField(roomObj, "limitNumber", 10));
                    Object rn = roomObj.fields().get("roomName");
                    if (rn != null && !String.valueOf(rn).isBlank()) room.roomName = String.valueOf(rn);
                    if (isHeadlessBattleBridge() || isLocalDualBattle() || rid > 1001) {
                        room.tcpPort = 27200 + (rid - 1001) * 2;
                        room.udpPort = room.tcpPort + 1;
                    }
                    leaveCurrentRoom(session);
                    session.team = 1;
                    session.observerFlag = false;
                    session.roomId = rid;
                    room.members.add(session);
                    ROOMS.put(rid, room);
                    currentRoomInfo = room.toAmf3();
                    roomSceneId = room.sceneId;
                    roomRaceType = room.raceType;
                    roomLimitNumber = room.limitNumber;
                    send(out, "callBackJoinRoom", List.of(1, room.toAmf3(), room.userListAmf3()));
                    broadcastRoomListChange(room, "callBackAddRoom", List.of(room.channelId, room.toListAmf3(), 0));
                } else if ("joinRoom".equals(fn) || "fastJoinRoom".equals(fn)) {
                    int reqRoomId = 0;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) reqRoomId = n.intValue();
                    else if (rpcParams.size() > 1 && rpcParams.get(1) instanceof Amf3TypedObject ro) reqRoomId = intField(ro, "roomId", 0);
                    LobbyRoom room = findRoomForJoin(reqRoomId, session.channelId);
                    if (room == null) {
                        send(out, "callBackRoomNotExist", List.of((double)reqRoomId));
                    } else if (room.members.contains(session)) {
                        send(out, "callBackJoinRoom", List.of(1, room.toAmf3(), room.userListAmf3()));
                    } else if (room.members.size() >= room.limitNumber) {
                        send(out, "callBackRoomFull", List.of());
                    } else {
                        leaveCurrentRoom(session);
                        int t1 = 0, t2 = 0;
                        for (LobbySession m : room.members) {
                            if (m.team == 1) t1++; else t2++;
                        }
                        session.team = (t1 <= t2) ? 1 : 2;
                        session.observerFlag = false;
                        session.roomId = room.roomId;
                        room.members.add(session);
                        Amf3TypedObject refreshed = room.toAmf3();
                        send(out, "callBackJoinRoom", List.of(1, refreshed, room.userListAmf3()));
                        for (LobbySession other : room.members) {
                            if (other != session) {
                                synchronized (other.sendLock) {
                                    try {
                                        send(other.out, "callBackUserJoin", List.of(makeClientRoomUser(session)));
                                        send(other.out, "callBackRefreshCurrentRoom", List.of(refreshed));
                                    } catch (Exception ignored) {}
                                }
                            }
                        }
                        broadcastRoomListChange(room, "callBackChangeRoomData", List.of(room.channelId, room.toListAmf3(), 0));
                    }
                } else if ("updateRoom".equals(fn)) {
                    Amf3TypedObject roomObj = rpcParams.isEmpty() ? null : toRoomInfoObject(rpcParams.get(0));
                    LobbyRoom room = ROOMS.get(session.roomId);
                    if (roomObj != null && room != null && room.hostCharId == session.characterId) {
                        room.rawRoom = roomObj;
                        room.sceneId = Math.max(1, intField(roomObj, "sceneId", room.sceneId));
                        room.raceType = intField(roomObj, "raceType", room.raceType);
                        room.limitNumber = Math.max(Math.max(2, room.members.size()), intField(roomObj, "limitNumber", room.limitNumber));
                        Object rn = roomObj.fields().get("roomName");
                        if (rn != null && !String.valueOf(rn).isBlank()) room.roomName = String.valueOf(rn);
                        currentRoomInfo = room.toAmf3();
                        roomSceneId = room.sceneId;
                        roomRaceType = room.raceType;
                        roomLimitNumber = room.limitNumber;
                        room.broadcast("callBackRefreshCurrentRoom", List.of(room.toAmf3()));
                    } else {
                        send(out, "callbackCanNotCreateRoom", List.of(-1));
                    }
                } else if ("changeTeam".equals(fn)) {
                    int newTeam = (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) ? n.intValue() : 1;
                    boolean obs = rpcParams.size() > 1 && Boolean.TRUE.equals(rpcParams.get(1));
                    if (!obs && (newTeam == 1 || newTeam == 2)) {
                        session.team = newTeam;
                        if (profile.persistent) {
                            profile.team = newTeam;
                            ProfileManager.save(profile);
                        }
                    }
                    session.observerFlag = obs;
                    LobbyRoom room = ROOMS.get(session.roomId);
                    if (room != null) {
                        room.broadcast("callBackChangeTeam", List.of(session.characterId, newTeam, obs));
                    } else {
                        send(out, "callBackChangeTeam", List.of(session.characterId, newTeam, obs));
                    }
                } else if ("changeGameToObserver".equals(fn)) {
                    boolean obs = rpcParams.isEmpty() || Boolean.TRUE.equals(rpcParams.get(rpcParams.size() - 1));
                    session.observerFlag = obs;
                    LobbyRoom room = ROOMS.get(session.roomId);
                    if (room != null) {
                        room.broadcast("callBackChangeGameToObserver", List.of(session.characterId, obs));
                    } else {
                        send(out, "callBackChangeGameToObserver", List.of(session.characterId, obs));
                    }
                } else if ("readyGame".equals(fn)) {
                    Object value = rpcParams.isEmpty() ? null : rpcParams.get(0);
                    session.readyGame = value instanceof Number n ? (n.intValue() == 0 ? 0 : 1)
                        : value instanceof Boolean b ? (b ? 1 : 0) : (1 - session.readyGame);
                    var room = ROOMS.get(session.roomId);
                    var status = List.<Object>of(session.characterId, session.readyGame, false, 0);
                    if (room != null) room.broadcast("callBackRefreshUserStatus", status);
                    else send(out, "callBackRefreshUserStatus", status);
                } else if ("kickUser".equals(fn) || "kickPlayer".equals(fn)) {
                    var room = ROOMS.get(session.roomId);
                    LobbySession target = null;
                    if (room != null && room.hostCharId == session.characterId && !rpcParams.isEmpty()) {
                        try { target = ACTIVE_CHANNELS.get(Double.parseDouble(String.valueOf(rpcParams.get(0)))); }
                        catch (NumberFormatException ignored) {}
                    }
                    if (target != null && target != session && target.roomId == room.roomId) {
                        leaveCurrentRoom(target);
                        send(target.out, "callBackWasKickedRoom", List.of());
                    } else if (room != null) {
                        send(out, "callBackRefreshCurrentRoom", List.of(room.toAmf3()));
                    }
                } else if ("leaveRoom".equals(fn)) {
                    leaveCurrentRoom(session);
                    currentRoomInfo = null;
                    send(out, "callBackLeaveRoom", List.of());
                } else if ("startGame".equals(fn)) {
                    LobbyRoom room = ROOMS.get(session.roomId);
                    if (room != null && room.hostCharId != session.characterId) {
                        send(out, "callBackStartGameFail", List.of(162));
                        continue;
                    }
                    if (room == null) {
                        var defaultRoomObj = new Amf3TypedObject("bean.RoomInfoEx", List.of("sceneId", "raceType", "limitNumber"), false);
                        room = new LobbyRoom(1001, session, defaultRoomObj);
                        room.sceneId = roomSceneId;
                        room.raceType = roomRaceType;
                        room.limitNumber = roomLimitNumber;
                        room.members.add(session);
                        session.roomId = room.roomId;
                        ROOMS.put(room.roomId, room);
                    }
                    int totalSlots = Math.max(2, room.limitNumber);
                    var seats = new ArrayList<BattleSeat>();
                    int t1Humans = 0, t2Humans = 0;
                    var charIds = new ArrayList<Object>(room.members.size());
                    for (LobbySession m : room.members) {
                        charIds.add(m.characterId);
                        if (m.observerFlag) continue;
                        seats.add(new BattleSeat((long)m.characterId, m.team, m.playerName, m.profileFile));
                        if (m.team == 1) t1Humans++; else t2Humans++;
                    }
                    int humanCount = seats.size();
                    int perSide = totalSlots / 2;
                    boolean fillBots = room.channelId == BOT_CHANNEL_ID;
                    int t1Bots = fillBots ? Math.max(0, perSide - t1Humans) : 0;
                    int t2Bots = fillBots ? Math.max(0, totalSlots - perSide - t2Humans) : 0;
                    int allyBots = session.team == 1 ? t1Bots : t2Bots;
                    int enemyBots = session.team == 1 ? t2Bots : t1Bots;
                    if (isLocalDualBattle() && !isHeadlessBattleBridge() && humanCount < 2) {
                        send(out, "callBackStartGameFail", List.of(162));
                        continue;
                    }
                    if (isHeadlessBattleBridge() || humanCount > 1 || isLocalDualBattle()) {
                        if (humanCount == 0 || humanCount > 16 || !launchRoomBattle(room, session, seats, allyBots, enemyBots)) {
                            send(out, "callBackStartGameFail", List.of(162));
                            continue;
                        }
                        room.broadcast("onRoomBattleEndpoint", List.of(room.roomId, "127.0.0.1", room.tcpPort, room.udpPort, room.raceType, room.sceneId, room.battleSeats));
                        room.broadcast("callBackRefreshUserEndGame", List.of(charIds));
                    } else {
                        launchBattleClient(profile.defaultCareer, profile.selectedBagIndex,
                            room.sceneId, room.raceType, session.team, allyBots, enemyBots, 1, room.tcpPort, room.udpPort);
                        send(out, "callBackRefreshUserEndGame", List.of(charIds));
                    }
                } else if ("getRoomBattleEndpoint".equals(fn)) {
                    LobbyRoom room = ROOMS.get(session.roomId);
                    if (room != null) {
                        int seats = room.battleServerProc != null && room.battleServerProc.isAlive() ? room.battleSeats : room.members.size();
                        send(out, "onRoomBattleEndpoint", List.of(room.roomId, "127.0.0.1", room.tcpPort, room.udpPort, room.raceType, room.sceneId, Math.max(1, seats)));
                    } else {
                        send(out, "onRoomBattleEndpoint", List.of(0, "127.0.0.1", 27100, 27101, 2003, 12, 1));
                    }
                } else if ("roomList".equals(fn)) {
                    var rooms = new ArrayList<Object>();
                    for (LobbyRoom r : ROOMS.values()) if (r.channelId == session.channelId) rooms.add(r.toListAmf3());
                    send(out, "callBackShowRoomList", List.of(rooms, 1));
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
                    r.put("rpgPower", AdventureLobby.power(profile));
                    r.put("challengeScore", 8888);
                    send(out, "callbackGetOtherRecordNew", List.of(r));
                } else if ("getCorpsInfo".equals(fn)) {
                    send(out, "callBackGetCorpsInfo", List.of(new java.util.ArrayList<Object>()));
                } else if ("getRankTopList".equals(fn)) {
                    send(out, "callBackGetRankTopList", List.of(List.of()));
                } else if ("getMatchState".equals(fn)) {
                    send(out, "callBackGetMatchState", List.of(0));
                } else if ("startRaceMatch".equals(fn)) {
                    launchBattleClient(profile.defaultCareer, profile.selectedBagIndex, 12, 2003, profile.team, 4, 5, 1, 27100, 27101);
                    send(out, "onStartRaceMatch", List.of(1));
                } else if ("equip".equals(fn)) {
                    int bagIdx = 0;
                    double sid = 0;
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Number n) bagIdx = n.intValue();
                    if (rpcParams.size() > 1) {
                        try { sid = Double.parseDouble(String.valueOf(rpcParams.get(1))); } catch(Exception e){}
                    }
                    long sidLong = (long)sid;
                    var sbObj = (Object)storageForProfile(profile, sidLong);
                    if (sbObj instanceof Amf3TypedObject sb) {
                        int tid = ((Number)sb.fields().get("tid")).intValue();
                        WeaponMeta wm = weaponMetaMap.get(tid);
                        if (wm != null && bagIdx >= 0 && bagIdx < bagArray.size()) {
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
                                var grenade = new ProfileManager.WeaponSlot(sid, tid, wm.codeName);
                                if (hasSlot(bagSlot.bom1, sid) || hasSlot(bagSlot.bom2, sid) || hasSlot(bagSlot.bom3, sid)) {
                                    send(out, "onEquip", List.of(bagIdx, sid, 0));
                                    continue;
                                }
                                if (bagSlot.bom1 == null) { bagSlot.bom1 = grenade; bagBean.set("bom1", wData); }
                                else if (bagSlot.bom2 == null) { bagSlot.bom2 = grenade; bagBean.set("bom2", wData); }
                                else if (bagSlot.bom3 == null) { bagSlot.bom3 = grenade; bagBean.set("bom3", wData); }
                                else {
                                    send(out, "onEquip", List.of(bagIdx, sid, -1));
                                    continue;
                                }
                            }
                            sb.set("equipedBag", bagIdx);
                            List<Object> updateList = new ArrayList<>();
                            if (oldSlot != null && oldSlot.storageId != sid) {
                                var oldBean = (Object)storageForProfile(profile, (long)oldSlot.storageId);
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
                    var sbObj = (Object)storageForProfile(profile, sidLong);
                    if (sbObj instanceof Amf3TypedObject sb) {
                        int tid = ((Number)sb.fields().get("tid")).intValue();
                        WeaponMeta wm = weaponMetaMap.get(tid);
                        if (wm != null && bagIdx >= 0 && bagIdx < bagArray.size()) {
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
                                if (hasSlot(bagSlot.bom1, sid)) { bagSlot.bom1 = null; bagBean.set("bom1", null); }
                                else if (hasSlot(bagSlot.bom2, sid)) { bagSlot.bom2 = null; bagBean.set("bom2", null); }
                                else if (hasSlot(bagSlot.bom3, sid)) { bagSlot.bom3 = null; bagBean.set("bom3", null); }
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
                    if (subIndex >= 0 && subIndex < sessionAvatarBags.size()
                            && selectAvatar(profile, rootAvatarDataHashMap, roleId)) {
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
                        session.career = profile.defaultCareer;
                        ProfileManager.save(profile);
                        send(out, "callBackEquipRootAvatar", List.of(1, sessionAvatarBags, roleId));
                    } else {
                        send(out, "callBackEquipRootAvatar", List.of(-1, sessionAvatarBags, roleId));
                    }
                } else if ("equipRootAvatarInfo".equals(fn)) {
                    int roleId = rpcParams.isEmpty() ? 0 : (int)numberArgument(rpcParams.get(0));
                    long storageId = rpcParams.size() > 1 ? numberArgument(rpcParams.get(1)) : 0;
                    int facadeId = rpcParams.size() > 2 ? (int)numberArgument(rpcParams.get(2)) : 0;
                    var avatar = avatarFor(rootAvatarDataHashMap, roleId);
                    var item = storageCatalogItem(storageId);
                    int type = intField(item, "type", 0);
                    int slot = avatarPartSlot(item);
                    int result = -1;
                    if (avatar != null && (slot >= 0 || type == 2 || type == 8)) {
                        long primarySkin = ((Number)avatar.fields().get("storageSkinId")).longValue();
                        if (slot >= 0) profile.avatarParts.computeIfAbsent(roleId, key -> new LinkedHashMap<>()).put(slot, storageId);
                        else primarySkin = storageId;
                        profile.avatarAppearances.put(roleId, new ProfileManager.AvatarAppearance(primarySkin, facadeId));
                        applyAvatarAppearance(avatar, profile, roleId);
                        ProfileManager.save(profile);
                        result = 1;
                    }
                    send(out, "callBackEquipRootAvatarInfo", List.of(result, roleId, (double)storageId, facadeId));
                } else if ("unEquipRootAvatarInfo".equals(fn)) {
                    int roleId = rpcParams.isEmpty() ? 0 : (int)numberArgument(rpcParams.get(0));
                    long storageId = rpcParams.size() > 1 ? numberArgument(rpcParams.get(1)) : 0;
                    var avatar = avatarFor(rootAvatarDataHashMap, roleId);
                    if (avatar != null) {
                        var slots = profile.avatarParts.get(roleId);
                        if (slots != null) {
                            slots.values().removeIf(id -> id == storageId);
                            if (slots.isEmpty()) profile.avatarParts.remove(roleId);
                        }
                        var current = profile.avatarAppearances.get(roleId);
                        if (current != null) {
                            long skinId = current.storageSkinId() == storageId ? 0 : current.storageSkinId();
                            profile.avatarAppearances.put(roleId, new ProfileManager.AvatarAppearance(skinId, 0));
                        }
                        applyAvatarAppearance(avatar, profile, roleId);
                        ProfileManager.save(profile);
                    }
                    send(out, "callBackUnEquipRootAvatarInfo", List.of(avatar == null ? -1 : 1,
                        avatar == null ? List.of() : List.of(roleId), (double)storageId, 0));
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
                    long weaponId = 0, skinId = 0;
                    if (rpcParams.size() >= 2) {
                        try {
                            weaponId = (long)Double.parseDouble(String.valueOf(rpcParams.get(0)));
                            skinId = (long)Double.parseDouble(String.valueOf(rpcParams.get(1)));
                        } catch (NumberFormatException ignored) {}
                    }
                    int op = rpcParams.size() > 2 && rpcParams.get(2) instanceof Number n ? n.intValue() : 1;
                    var updates = updateWeaponSkin(profile, weaponId, skinId, op == 1);
                    send(out, "callbackUpdateStorages", List.of(updates.isEmpty() ? -1 : 1, updates));
                } else if ("getAvatarLimitInfo".equals(fn)) {
                    send(out, "callbackGetAvatarLimitInfo", List.of(new LinkedHashMap<String, Object>()));
                } else if ("change3dRole".equals(fn)) {
                    boolean changed = false;
                    if (!rpcParams.isEmpty()) {
                        try {
                            int newAvatarId = (int)Double.parseDouble(String.valueOf(rpcParams.get(0)));
                            changed = selectAvatar(profile, rootAvatarDataHashMap, newAvatarId);
                            if (changed) ProfileManager.save(profile);
                        } catch (Exception ignored) {}
                    }
                    send(out, "callbackChange3dRole", List.of(changed));
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
                    var selected = profile.bags.get(bagIdx);
                    int id = roleGroupMap.getOrDefault(profile.defaultAvatar, 1) == 2 ? selected.roleCTID : selected.roleTID;
                    selectAvatar(profile, rootAvatarDataHashMap, id);
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
                } else if ("changeUserSetting".equals(fn)) {
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof Map<?, ?> requested) {
                        for (String field : settings.sealedNames()) {
                            Object current = settings.fields().get(field);
                            Object value = requested.get(field);
                            if (current instanceof Boolean && value instanceof Boolean
                                || current instanceof Number && value instanceof Number
                                || current instanceof String && value instanceof String text && text.length() <= 4096) {
                                settings.set(field, value);
                                profile.userSettings.put(field, String.valueOf(value));
                            }
                        }
                        ProfileManager.save(profile);
                    }
                    send(out, "onChangeUserSetting", List.of(settings));
                } else if ("createMessage".equals(fn)) {
                    if (!rpcParams.isEmpty() && rpcParams.get(0) instanceof String message) {
                        var room = ROOMS.get(session.roomId);
                        if (room != null) room.broadcast("callBackAddMessage", List.of(message));
                        else send(out, "callBackAddMessage", List.of(message));
                    }
                } else if (NO_REPLY_OK.contains(fn)) {
                    // The AIR client defines no response callback for these messages.
                } else if (adventure.dispatch(fn, rpcParams, profile, out, s.getLocalPort())) {
                    // Adventure has its own channel callbacks and per-connection team state.
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
            if (session != null) {
                ACTIVE_SESSIONS.remove(session.characterId, session);
                if (!session.lobbyToken.isEmpty()) LOBBY_TOKENS.remove(session.lobbyToken, session);
                ACTIVE_CHANNELS.remove(session.characterId, session);
                leaveCurrentRoom(session);
            }
            System.out.println("[conn] CLOSE " + peer + " frames=" + frameCount
                + " lived=" + (System.currentTimeMillis() - t0) + "ms");
            try { s.close(); } catch (IOException e) {}
        }
    }

    static boolean hasSlot(ProfileManager.WeaponSlot slot, double storageId) {
        return slot != null && slot.storageId == storageId;
    }

    static void leaveCurrentRoom(LobbySession session) {
        int rid = session.roomId;
        if (rid <= 0) return;
        session.roomId = 0;
        LobbyRoom room = ROOMS.get(rid);
        if (room == null) return;
        room.members.remove(session);
        if (room.members.isEmpty()) {
            ROOMS.remove(rid);
            stopRoomBattle(room);
            broadcastRoomListChange(room, "callBackDeleteRoom", List.of(room.channelId, (double)rid));
        } else {
            if (room.hostCharId == session.characterId) {
                LobbySession nextHost = room.members.get(0);
                room.hostCharId = nextHost.characterId;
                room.hostName = nextHost.playerName;
            }
            room.broadcast("callBackRefreshCurrentRoom", List.of(room.toAmf3()));
            room.broadcast("callBackUserLeave", List.of((double)rid, session.characterId));
            broadcastRoomListChange(room, "callBackChangeRoomData", List.of(room.channelId, room.toListAmf3(), 0));
        }
    }

    static void send(DataOutputStream out, String fn, java.util.List<Object> params) throws Exception {
        byte[] amf = Amf3Encoder.encodeOnce(Amf3TypedObject.apc(fn, params));
        synchronized (out) {
            out.writeInt(amf.length + 1);
            out.writeByte(0);
            out.write(amf);
            out.flush();
        }
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
