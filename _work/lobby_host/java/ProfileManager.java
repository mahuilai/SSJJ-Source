import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

public class ProfileManager {
    public static class WeaponSlot {
        public double storageId;
        public int tid;
        public String codeName;
        public WeaponSlot(double storageId, int tid, String codeName) {
            this.storageId = storageId;
            this.tid = tid;
            this.codeName = codeName;
        }
    }

    public static class BagSlot {
        public WeaponSlot master;
        public WeaponSlot secondary;
        public WeaponSlot closed;
        public WeaponSlot bom1;
        public int roleTID = 3;
        public int roleCTID = 4;
    }

    public static class MountSlot {
        public String mountId;
        public String targetId;
        public String subType;

        public MountSlot(String mountId, String targetId, String subType) {
            this.mountId = mountId;
            this.targetId = targetId;
            this.subType = subType;
        }
    }

    public static class Profile {
        public int selectedBagIndex = 0;
        public int selectedAvatarBagIndex = 0;
        public int defaultAvatar = 3;
        public String defaultCareer = "baofeng";
        public String playerName = "你来时冬至";
        public long lastChangePlayerName = 0L;
        public int team = 1;
        public List<BagSlot> bags = new ArrayList<>();
        public Map<Long, Long> equippedSkins = new LinkedHashMap<>(); // weaponStorageId -> skinStorageId
        public Map<Long, Integer> storageAmounts = new LinkedHashMap<>(); // storageId -> amount override
        public Map<Integer, Integer> equippedPersonalise = new LinkedHashMap<>(); // personalise tid -> equip index
        public String equippedTitle = "";
        public Map<String, MountSlot> mounts = new LinkedHashMap<>(); // mountType|subType -> mounted object
        public int activeMedalLine = 0;
        public WeaponSlot pvpTactical = null;
        public WeaponSlot rpgTactical = null;

        public Profile() {
            for (int i = 0; i < 5; i++) {
                BagSlot bs = new BagSlot();
                bs.master = new WeaponSlot(10000001.0, 1, "m4a1");
                bs.secondary = new WeaponSlot(10000006.0, 6, "deagle");
                bs.closed = new WeaponSlot(10000009.0, 9, "dagger");
                bs.bom1 = new WeaponSlot(10000010.0, 10, "grenade");
                bags.add(bs);
            }
        }
    }

    private static File getProfileFile() {
        File f1 = new File("../user_profile.json");
        if (f1.exists()) return f1;
        File f2 = new File("user_profile.json");
        if (f2.exists()) return f2;
        File f3 = new File("D:/逆向/SSJJ双塔惊魂/_work/lobby_host/user_profile.json");
        if (f3.exists()) return f3;
        return f1;
    }

    public static synchronized void save(Profile p) {
        try {
            StringBuilder sb = new StringBuilder();
            sb.append("{\n");
            sb.append("  \"selectedBagIndex\": ").append(p.selectedBagIndex).append(",\n");
            sb.append("  \"defaultAvatar\": ").append(p.defaultAvatar).append(",\n");
            sb.append("  \"defaultCareer\": ").append(jsonQuote(p.defaultCareer)).append(",\n");
            sb.append("  \"playerName\": ").append(jsonQuote(p.playerName)).append(",\n");
            sb.append("  \"lastChangePlayerName\": ").append(p.lastChangePlayerName).append(",\n");
            sb.append("  \"team\": ").append(p.team).append(",\n");
            sb.append("  \"bags\": [\n");
            for (int i = 0; i < p.bags.size(); i++) {
                BagSlot b = p.bags.get(i);
                sb.append("    {\n");
                sb.append("      \"roleTID\": ").append(b.roleTID).append(",\n");
                sb.append("      \"roleCTID\": ").append(b.roleCTID).append(",\n");
                sb.append("      \"master\": ").append(formatSlot(b.master)).append(",\n");
                sb.append("      \"secondary\": ").append(formatSlot(b.secondary)).append(",\n");
                sb.append("      \"closed\": ").append(formatSlot(b.closed)).append(",\n");
                sb.append("      \"bom1\": ").append(formatSlot(b.bom1)).append("\n");
                sb.append("    }").append(i < p.bags.size() - 1 ? "," : "").append("\n");
            }
            sb.append("  ],\n");
            sb.append("  \"equippedSkins\": {\n");
            int sIdx = 0;
            for (var e : p.equippedSkins.entrySet()) {
                sb.append("    \"").append(e.getKey()).append("\": ").append(e.getValue());
                if (++sIdx < p.equippedSkins.size()) sb.append(",");
                sb.append("\n");
            }
            sb.append("  },\n");
            sb.append("  \"storageAmounts\": {\n");
            int aIdx = 0;
            for (var e : p.storageAmounts.entrySet()) {
                sb.append("    \"").append(e.getKey()).append("\": ").append(e.getValue());
                if (++aIdx < p.storageAmounts.size()) sb.append(",");
                sb.append("\n");
            }
            sb.append("  },\n");
            sb.append("  \"equippedPersonalise\": {\n");
            int pIdx = 0;
            for (var e : p.equippedPersonalise.entrySet()) {
                sb.append("    \"").append(e.getKey()).append("\": ").append(e.getValue());
                if (++pIdx < p.equippedPersonalise.size()) sb.append(",");
                sb.append("\n");
            }
            sb.append("  },\n");
            sb.append("  \"activeMedalLine\": ").append(p.activeMedalLine).append(",\n");
            sb.append("  \"pvpTactical\": ").append(formatSlot(p.pvpTactical)).append(",\n");
            sb.append("  \"rpgTactical\": ").append(formatSlot(p.rpgTactical)).append(",\n");
            sb.append("  \"equippedTitle\": ").append(jsonQuote(p.equippedTitle)).append(",\n");
            sb.append("  \"mounts\": {\n");
            int mIdx = 0;
            for (var e : p.mounts.entrySet()) {
                MountSlot mount = e.getValue();
                sb.append("    ").append(jsonQuote(e.getKey())).append(": {\"mountId\": ")
                  .append(jsonQuote(mount.mountId)).append(", \"targetId\": ")
                  .append(jsonQuote(mount.targetId)).append(", \"subType\": ")
                  .append(jsonQuote(mount.subType)).append("}");
                if (++mIdx < p.mounts.size()) sb.append(",");
                sb.append("\n");
            }
            sb.append("  }\n");
            sb.append("}\n");
            File target = getProfileFile();
            java.nio.file.Path dst = target.toPath().toAbsolutePath();
            java.nio.file.Path dir = dst.getParent();
            if (dir != null) Files.createDirectories(dir);
            // 原子写：临时文件 -> 原子 rename。
            // 原实现在目标文件上直接截断覆盖，进程被杀会留下半截 JSON，
            // 下次 load() 静默回落默认值 —— 表现为"存档悄悄回档"。
            java.nio.file.Path tmp = Files.createTempFile(dir, "user_profile", ".tmp");
            try {
                Files.writeString(tmp, sb.toString(), java.nio.charset.StandardCharsets.UTF_8);
                // 保留上一版，便于人工回滚
                if (Files.exists(dst)) {
                    try {
                        Files.copy(dst, dst.resolveSibling("user_profile.json.prev"),
                                java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                    } catch (Exception ignore) {}
                }
                try {
                    Files.move(tmp, dst, java.nio.file.StandardCopyOption.REPLACE_EXISTING,
                            java.nio.file.StandardCopyOption.ATOMIC_MOVE);
                } catch (java.nio.file.AtomicMoveNotSupportedException ame) {
                    Files.move(tmp, dst, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                }
            } finally {
                try { Files.deleteIfExists(tmp); } catch (Exception ignore) {}
            }
            System.out.println("[ProfileManager] Saved user_profile.json to " + dst);
        } catch (Exception e) {
            // 存档失败必须可见：原来只 printStackTrace，失败后流程继续跑默认值
            System.out.println("[ProfileManager][FATAL] save FAILED, profile NOT persisted: " + e);
            e.printStackTrace();
        }
    }

    private static String formatSlot(WeaponSlot ws) {
        if (ws == null) return "null";
        return String.format(Locale.ROOT, "{\"storageId\": %.1f, \"tid\": %d, \"codeName\": \"%s\"}",
            ws.storageId, ws.tid, ws.codeName);
    }

    private static String jsonQuote(String value) {
        StringBuilder out = new StringBuilder("\"");
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '\\': out.append("\\\\"); break;
                case '"': out.append("\\\""); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                default: out.append(c);
            }
        }
        return out.append('"').toString();
    }

    private static String jsonUnquote(String value) {
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (c == '\\' && i + 1 < value.length()) {
                char next = value.charAt(++i);
                switch (next) {
                    case 'n': out.append('\n'); break;
                    case 'r': out.append('\r'); break;
                    case 't': out.append('\t'); break;
                    default: out.append(next);
                }
            } else {
                out.append(c);
            }
        }
        return out.toString();
    }

    public static synchronized Profile load() {
        Profile p = new Profile();
        File f = getProfileFile();
        if (!f.exists()) {
            save(p);
            return p;
        }
        try {
            String json = Files.readString(f.toPath(), java.nio.charset.StandardCharsets.UTF_8);
            Matcher m = Pattern.compile("\"selectedBagIndex\"\\s*:\\s*(\\d+)").matcher(json);
            if (m.find()) p.selectedBagIndex = Integer.parseInt(m.group(1));

            m = Pattern.compile("\"defaultAvatar\"\\s*:\\s*(\\d+)").matcher(json);
            if (m.find()) p.defaultAvatar = Integer.parseInt(m.group(1));

            m = Pattern.compile("\"defaultCareer\"\\s*:\\s*\"([^\"]+)\"").matcher(json);
            if (m.find()) p.defaultCareer = m.group(1);

            m = Pattern.compile("\"playerName\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"").matcher(json);
            if (m.find()) p.playerName = jsonUnquote(m.group(1));

            m = Pattern.compile("\"lastChangePlayerName\"\\s*:\\s*(\\d+)").matcher(json);
            if (m.find()) p.lastChangePlayerName = Long.parseLong(m.group(1));

            m = Pattern.compile("\"team\"\\s*:\\s*(\\d+)").matcher(json);
            if (m.find()) p.team = Integer.parseInt(m.group(1));

            // Parse each bag as a balanced JSON object. Slot objects contain commas,
            // so splitting their values at the first comma drops weapon data.
            int bagsKey = json.indexOf("\"bags\"");
            int bagsStart = bagsKey < 0 ? -1 : json.indexOf('[', bagsKey);
            List<String> bagObjects = bagsStart < 0 ? List.of() : extractArrayObjects(json, bagsStart);
            for (int bagIdx = 0; bagIdx < bagObjects.size() && bagIdx < p.bags.size(); bagIdx++) {
                String bagJson = bagObjects.get(bagIdx);
                Matcher roleTid = Pattern.compile("\"roleTID\"\\s*:\\s*(\\d+)").matcher(bagJson);
                Matcher roleCtid = Pattern.compile("\"roleCTID\"\\s*:\\s*(\\d+)").matcher(bagJson);
                if (!roleTid.find() || !roleCtid.find()) continue;
                BagSlot bs = p.bags.get(bagIdx);
                bs.roleTID = Integer.parseInt(roleTid.group(1));
                bs.roleCTID = Integer.parseInt(roleCtid.group(1));
                bs.master = parseSlotField(bagJson, "master");
                bs.secondary = parseSlotField(bagJson, "secondary");
                bs.closed = parseSlotField(bagJson, "closed");
                bs.bom1 = parseSlotField(bagJson, "bom1");
            }

            // Parse equippedSkins
            Matcher sm = Pattern.compile("\"equippedSkins\"\\s*:\\s*\\{([^}]*)\\}", Pattern.DOTALL).matcher(json);
            if (sm.find()) {
                String skinsBlock = sm.group(1);
                Matcher pairMatcher = Pattern.compile("\"(\\d+)\"\\s*:\\s*(\\d+)").matcher(skinsBlock);
                while (pairMatcher.find()) {
                    long wId = Long.parseLong(pairMatcher.group(1));
                    long sId = Long.parseLong(pairMatcher.group(2));
                    p.equippedSkins.put(wId, sId);
                }
            }

            Matcher am = Pattern.compile("\"storageAmounts\"\\s*:\\s*\\{([^}]*)\\}", Pattern.DOTALL).matcher(json);
            if (am.find()) {
                Matcher pairMatcher = Pattern.compile("\"(\\d+)\"\\s*:\\s*(\\d+)").matcher(am.group(1));
                while (pairMatcher.find()) {
                    p.storageAmounts.put(Long.parseLong(pairMatcher.group(1)), Integer.parseInt(pairMatcher.group(2)));
                }
            }

            Matcher pm = Pattern.compile("\"equippedPersonalise\"\\s*:\\s*\\{([^}]*)\\}", Pattern.DOTALL).matcher(json);
            if (pm.find()) {
                Matcher pairMatcher = Pattern.compile("\"(\\d+)\"\\s*:\\s*(\\d+)").matcher(pm.group(1));
                while (pairMatcher.find()) {
                    p.equippedPersonalise.put(Integer.parseInt(pairMatcher.group(1)), Integer.parseInt(pairMatcher.group(2)));
                }
            }

            p.pvpTactical = parseSlotField(json, "pvpTactical");
            p.rpgTactical = parseSlotField(json, "rpgTactical");

            m = Pattern.compile("\"activeMedalLine\"\\s*:\\s*(\\d+)").matcher(json);
            if (m.find()) p.activeMedalLine = Integer.parseInt(m.group(1));

            m = Pattern.compile("\"equippedTitle\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"").matcher(json);
            if (m.find()) p.equippedTitle = jsonUnquote(m.group(1));

            Matcher mm = Pattern.compile("\"mounts\"\\s*:\\s*\\{([\\s\\S]*?)\\n\\s*\\}").matcher(json);
            if (mm.find()) {
                Matcher mountMatcher = Pattern.compile("\"([^\"]+)\"\\s*:\\s*\\{\\s*\"mountId\"\\s*:\\s*\"([^\"]*)\"\\s*,\\s*\"targetId\"\\s*:\\s*\"([^\"]*)\"\\s*,\\s*\"subType\"\\s*:\\s*\"([^\"]*)\"\\s*\\}").matcher(mm.group(1));
                while (mountMatcher.find()) {
                    p.mounts.put(jsonUnquote(mountMatcher.group(1)), new MountSlot(
                        jsonUnquote(mountMatcher.group(2)), jsonUnquote(mountMatcher.group(3)), jsonUnquote(mountMatcher.group(4))));
                }
            }
            System.out.println("[ProfileManager] Loaded user_profile.json from " + f.getAbsolutePath() + " (selectedBag=" + p.selectedBagIndex + ", avatar=" + p.defaultAvatar + ", skins=" + p.equippedSkins.size() + ", personalise=" + p.equippedPersonalise.size() + ", mounts=" + p.mounts.size() + ")");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return p;
    }

    private static List<String> extractArrayObjects(String json, int arrayStart) {
        List<String> objects = new ArrayList<>();
        int depth = 0;
        int objectStart = -1;
        boolean inString = false;
        boolean escaped = false;
        for (int i = arrayStart + 1; i < json.length(); i++) {
            char c = json.charAt(i);
            if (inString) {
                if (escaped) escaped = false;
                else if (c == '\\') escaped = true;
                else if (c == '"') inString = false;
                continue;
            }
            if (c == '"') {
                inString = true;
            } else if (c == '{') {
                if (depth == 0) objectStart = i;
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0 && objectStart >= 0) {
                    objects.add(json.substring(objectStart, i + 1));
                    objectStart = -1;
                }
            } else if (c == ']' && depth == 0) {
                break;
            }
        }
        return objects;
    }

    private static WeaponSlot parseSlotField(String object, String field) {
        Matcher matcher = Pattern.compile("\"" + Pattern.quote(field) + "\"\\s*:\\s*(null|\\{[^}]*\\})").matcher(object);
        return matcher.find() ? parseSlot(matcher.group(1)) : null;
    }

    private static WeaponSlot parseSlot(String s) {
        if (s == null || s.trim().equals("null") || s.trim().isEmpty()) return null;
        try {
            Matcher mSid = Pattern.compile("\"storageId\"\\s*:\\s*([0-9.]+)").matcher(s);
            Matcher mTid = Pattern.compile("\"tid\"\\s*:\\s*(\\d+)").matcher(s);
            Matcher mCode = Pattern.compile("\"codeName\"\\s*:\\s*\"([^\"]+)\"").matcher(s);
            if (mSid.find() && mTid.find() && mCode.find()) {
                return new WeaponSlot(Double.parseDouble(mSid.group(1)), Integer.parseInt(mTid.group(1)), mCode.group(1));
            }
        } catch (Exception e) {}
        return null;
    }
}
