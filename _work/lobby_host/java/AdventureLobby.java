import com.strikegod.downloader.service.Amf3TypedObject;

import java.io.DataOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/** Offline state for the existing AIR adventure entry and room screens. */
final class AdventureLobby {
    private static final double USER_ID = 1000200072528.0;
    private static final int LEVEL = 50;
    private static final int BASE_POWER = 25_000;
    private static final AtomicInteger NEXT_TEAM = new AtomicInteger(100_001);

    private int teamId;
    private int difficulty;
    private int multipleId;
    private boolean inRoom;
    private boolean passwordProtected;

    static int power(ProfileManager.Profile profile) {
        int selected = Math.max(0, Math.min(profile.selectedBagIndex, profile.bags.size() - 1));
        var bag = profile.bags.get(selected);
        return BASE_POWER + gearPower(bag.master, profile) + gearPower(bag.secondary, profile)
            + gearPower(bag.closed, profile) + gearPower(bag.bom1, profile) + gearPower(profile.rpgTactical, profile);
    }

    private static int gearPower(ProfileManager.WeaponSlot slot, ProfileManager.Profile profile) {
        if (slot == null) return 0;
        var meta = LobbyLoginServer.weaponMetaMap.get(slot.tid);
        int rating = meta == null ? 0 : meta.adventureRating;
        int skinBonus = profile.equippedSkins.containsKey((long)slot.storageId) ? 500 : 0;
        return 1500 + rating * 75 + skinBonus;
    }

    private static Amf3TypedObject character(ProfileManager.Profile profile) {
        var bean = new Amf3TypedObject("bean.CharacterRpgBean", List.of(
            "uid", "lv", "exp", "silver", "medal", "bonus", "normalActionPoint",
            "raidNumRecord", "challengeNumRecord", "tiredRewardNumRecord", "brushNumRecord", "chipLabItems"), false);
        return bean.set("uid", 321282597).set("lv", LEVEL).set("exp", 0.0).set("silver", 0.0)
            .set("medal", 0).set("bonus", power(profile)).set("normalActionPoint", 100)
            .set("raidNumRecord", Map.of()).set("challengeNumRecord", Map.of())
            .set("tiredRewardNumRecord", Map.of()).set("brushNumRecord", Map.of()).set("chipLabItems", List.of());
    }

    private static Amf3TypedObject userInfo(ProfileManager.Profile profile) {
        var maps = List.of("rpgTaskProgressMap", "rpgXpSkillBeanMap", "rpgWeaponBattleProficiencyRecordBeanMap",
            "userBattleServerData", "rpgInfinityRecordMap", "weaponSlotsMap", "rpgSendTaskBeanMap", "rpgFurnaceBeanMap");
        var arrays = List.of("rpgCompletedGameDifficultyIdArray", "firstBloodRpgDiffIdList", "completedTaskSet", "rpgLevelTelnetNodeList");
        var fields = new ArrayList<>(List.of("rpgBean", "isOpenHomeland", "welcomeDays",
            "foreverLandChallengeNum", "rebirth", "lastSeasonKingScuffleScore"));
        fields.addAll(maps);
        fields.addAll(arrays);
        var info = new Amf3TypedObject("bean.ClientRpgUserInfo", fields, false);
        maps.forEach(key -> info.set(key, Map.of()));
        arrays.forEach(key -> info.set(key, List.of()));
        return info.set("rpgBean", character(profile)).set("isOpenHomeland", false).set("welcomeDays", 0)
            .set("foreverLandChallengeNum", 0).set("rebirth", 0).set("lastSeasonKingScuffleScore", 0);
    }

    private Amf3TypedObject team(ProfileManager.Profile profile) {
        var user = new Amf3TypedObject("bean.RpgUserInfo", List.of("gCid", "uid", "characterName", "camp",
            "inGameServer", "isReady", "teamId", "desperateFightFlag", "rpgBean",
            "rpgCompletedGameDifficultyIdSet", "vipLv", "isMicroClient"), false);
        user.set("gCid", 1000200072528.0).set("uid", 321282597).set("characterName", profile.playerName)
            .set("camp", 1).set("inGameServer", false).set("isReady", true).set("teamId", (double)teamId)
            .set("desperateFightFlag", false).set("rpgBean", character(profile))
            .set("rpgCompletedGameDifficultyIdSet", Map.of()).set("vipLv", 0).set("isMicroClient", 1);
        var result = new Amf3TypedObject("bean.RpgTeamInfo", List.of("teamId", "rpgGameDifficultyId",
            "owner", "users", "teamStatus", "capacity", "isPswTeam", "multipleId"), false);
        return result.set("teamId", (double)teamId).set("rpgGameDifficultyId", difficulty).set("owner", user)
            .set("users", List.of(user)).set("teamStatus", 0).set("capacity", 4)
            .set("isPswTeam", passwordProtected).set("multipleId", multipleId);
    }

    private Amf3TypedObject room() {
        var result = new Amf3TypedObject("bean.ClientRpgRoomInfo", List.of("id", "roomId", "rpgGameDifficultyId",
            "capacity", "currentUserCount", "roomStatus", "isPswRoom", "bonus", "rpgLevel", "multipleId"), false);
        return result.set("id", teamId).set("roomId", (double)teamId).set("rpgGameDifficultyId", difficulty)
            .set("capacity", 4).set("currentUserCount", 1).set("roomStatus", 1)
            .set("isPswRoom", passwordProtected).set("bonus", 0).set("rpgLevel", 0).set("multipleId", multipleId);
    }

    boolean dispatch(String request, List<?> args, ProfileManager.Profile profile,
                     DataOutputStream out, int port) throws Exception {
        switch (request) {
            case "getGameChannelServerInfo" -> {
                if (args.isEmpty() || !"rpg".equals(args.get(0))) return false;
                var endpoint = new Amf3TypedObject("com.wooduan.hallserver.services.Endpoint",
                    List.of("id", "name", "domain", "port", "type", "ip"), false);
                endpoint.set("id", "offline-rpg").set("name", "本地冒险频道").set("domain", "127.0.0.1")
                    .set("port", port).set("type", "rpg").set("ip", "127.0.0.1");
                LobbyLoginServer.send(out, "callbackGetGameChannelServerInfo", List.of(1, endpoint));
            }
            case "getClientRpgUserInfo" -> LobbyLoginServer.send(out, "callbackGetClientRpgUserInfo", List.of(userInfo(profile)));
            case "enterRpgServer" -> LobbyLoginServer.send(out, "callbackEnterRpgServerSuccess", List.of(false));
            case "createRpgTeam", "createMultipleRpgTeam", "changeRpgTeam", "changeMultipleRpgTeam" -> {
                difficulty = (int)LobbyLoginServer.numberArgument(args.isEmpty() ? 0 : args.get(0));
                multipleId = args.size() > 1 ? (int)LobbyLoginServer.numberArgument(args.get(1)) : 0;
                if (request.startsWith("create")) {
                    if (teamId == 0) teamId = NEXT_TEAM.getAndIncrement();
                    if (difficulty <= 0) difficulty = 1011;
                    LobbyLoginServer.send(out, "callbackCreateRpgTeam", List.of(1, team(profile)));
                    LobbyLoginServer.send(out, "callbackRpgTeamChangeStatus", List.of(1));
                    LobbyLoginServer.send(out, "callbackRpgTeamChangeStatus", List.of(2));
                } else {
                    LobbyLoginServer.send(out, "callbackChangeRpgTeam", List.of(1, difficulty, multipleId));
                }
            }
            case "getRpgTeamInfo" -> {
                if (teamId == 0) teamId = NEXT_TEAM.getAndIncrement();
                if (difficulty <= 0) difficulty = 1011;
                LobbyLoginServer.send(out, "callbackGetRpgTeamInfo", List.of(team(profile)));
            }
            case "getRpgRoomList" -> LobbyLoginServer.send(out, "callbackGetRpgRoomList", List.of(inRoom ? List.of(room()) : List.of()));
            case "getRpgTeamList" -> LobbyLoginServer.send(out, "callbackGetRpgTeamList", List.of(List.of()));
            case "createRpgRoom", "createRpgRestrictionRoom" -> {
                if (teamId == 0) {
                    LobbyLoginServer.send(out, "callbackCreateRpgRoom", List.of(-1, List.of()));
                    return true;
                }
                passwordProtected = args.size() > 1 && args.get(1) instanceof String password && !password.isBlank();
                inRoom = true;
                LobbyLoginServer.send(out, "callbackCreateRpgRoom", List.of(1, List.of()));
                LobbyLoginServer.send(out, "callbackAddRpgRoom", List.of(room()));
            }
            case "leaveRpgTeam" -> {
                teamId = 0;
                inRoom = false;
                passwordProtected = false;
                LobbyLoginServer.send(out, "callbackLeaveRpgTeam", List.of());
            }
            case "reconnectGame" -> LobbyLoginServer.send(out, "callbackReconnectGameFail", List.of());
            case "notUsePlotWeapon" -> LobbyLoginServer.send(out, "callbackNotUsePlotWeapon", List.of(1));
            case "loginBattle" -> LobbyLoginServer.send(out, "callbackLoginBattle",
                List.of("{\"isMicroClient\":1,\"loginUnity\":1,\"id\":0,\"loginTime\":0,\"microClientVersion\":\"1.0.1.477\"}"));
            case "startRpgMatch" -> startRpgMatch(profile, out);
            case "finishRpgBattle" -> sendBattleEnd(profile, out);
            default -> { return false; }
        }
        return true;
    }

    private void startRpgMatch(ProfileManager.Profile profile, DataOutputStream out) throws Exception {
        if (teamId == 0) teamId = NEXT_TEAM.getAndIncrement();
        if (difficulty <= 0) difficulty = 1011;
        int sceneId = 100001;
        int raceType = 10001;
        int tcpPort = 27100;
        int udpPort = 27101;
        String roomIdStr = "11109969719885";
        String startTimeMsStr = String.valueOf(System.currentTimeMillis());
        String connectionKey = "bc8f2078ee5ec726bc4631d4a47d5d2e";

        LobbyLoginServer.send(out, "callbackRpgTeamChangeStatus", List.of(3));
        LobbyLoginServer.send(out, "callBackStartRpgGame",
            List.of(roomIdStr, "127.0.0.1", tcpPort, startTimeMsStr, connectionKey));
        LobbyLoginServer.send(out, "callbackRpgUserChangeInGameServer", List.of(true));

        if (!LobbyLoginServer.isHeadlessBattleBridge()) {
            LobbyLoginServer.launchBattleClient(
                profile.defaultCareer, profile.selectedBagIndex,
                sceneId, raceType, 1, 0, 4, 1, tcpPort, udpPort);
            Process proc = LobbyLoginServer.activeBattleProc;
            if (proc != null) {
                Thread watcher = new Thread(() -> {
                    try {
                        proc.waitFor();
                        sendBattleEnd(profile, out);
                    } catch (Exception ignored) {
                    }
                }, "rpg-battle-end-watcher");
                watcher.setDaemon(true);
                watcher.start();
            }
        }
    }

    private void sendBattleEnd(ProfileManager.Profile profile, DataOutputStream out) throws Exception {
        LobbyLoginServer.send(out, "callbackSyncRpgTeamMemberStatus", List.of(10, true));
        LobbyLoginServer.send(out, "callbackRpgUserChangeInGameServer", List.of(false));
        LobbyLoginServer.send(out, "callBackBattleEnd", List.of(battleReport(profile)));
        LobbyLoginServer.send(out, "callbackUpdateRpgTask", List.of(rpgTask(20320001, 251)));
    }

    private Amf3TypedObject rpgTask(int id, int progress) {
        return new Amf3TypedObject("bean.RpgTask", List.of("id", "progress", "rewarded"), false)
            .set("id", id)
            .set("progress", progress)
            .set("rewarded", false);
    }

    private Amf3TypedObject battleReport(ProfileManager.Profile profile) {
        var playerPve = new Amf3TypedObject("bean.PvePlayerEndInfo", List.of(
            "id", "pveScore", "pveKillMonster", "pveBeKilled", "pveKillBoss",
            "pveCompleteStage", "firstPrize", "normalPrize", "evaluation"
        ), false)
            .set("id", USER_ID)
            .set("pveScore", 0)
            .set("pveKillMonster", 208)
            .set("pveBeKilled", 0)
            .set("pveKillBoss", 0)
            .set("pveCompleteStage", 3)
            .set("firstPrize", "4-70029-1-0")
            .set("normalPrize", "")
            .set("evaluation", 0);

        var pveData = new Amf3TypedObject("bean.PveBattleEndInfo", List.of(
            "pveKillBoss", "playerData", "firstPrize", "normalPrize", "boxScore"
        ), false)
            .set("pveKillBoss", 1)
            .set("playerData", List.of(playerPve))
            .set("firstPrize", "4-70029-1-0")
            .set("normalPrize", "")
            .set("boxScore", 50);

        var playerReport = new Amf3TypedObject("bean.ClientPlayerBattleReport", List.of(
            "cid", "name", "team", "kill", "beKilled", "assist", "headshot",
            "gp", "exp", "Career", "isWin", "score", "damage", "playTime",
            "pveDamage", "pveHurt", "pveKill", "pveScore"
        ), false)
            .set("cid", USER_ID)
            .set("name", profile.playerName)
            .set("team", 1)
            .set("kill", 208)
            .set("beKilled", 0)
            .set("assist", 0)
            .set("headshot", 58)
            .set("gp", 39)
            .set("exp", 5039)
            .set("Career", profile.defaultCareer)
            .set("isWin", true)
            .set("score", 424)
            .set("damage", 20140)
            .set("playTime", 186)
            .set("pveDamage", 20140.0)
            .set("pveHurt", 4.0)
            .set("pveKill", 208)
            .set("pveScore", 0);

        var evalInfo = new Amf3TypedObject("bean.PveEvaluationInfo", List.of(
            "cid", "name", "kill", "death", "headshot", "evaluation",
            "Career", "boxScore", "damage", "pveCompleteStage", "firstPrize", "normalPrize"
        ), false)
            .set("cid", USER_ID)
            .set("name", profile.playerName)
            .set("kill", 208)
            .set("death", 0)
            .set("headshot", 58)
            .set("evaluation", 3)
            .set("Career", profile.defaultCareer)
            .set("boxScore", 0)
            .set("damage", 20140.0)
            .set("pveCompleteStage", 0)
            .set("firstPrize", "")
            .set("normalPrize", "");

        return new Amf3TypedObject("bean.ClientBattleReport", List.of(
            "raceType", "sceneId", "pveLevel", "winTeam", "playSeconds",
            "roomId", "isSingleRound", "team1Score", "team2Score",
            "pveData", "playerList", "pveEvaluations"
        ), false)
            .set("raceType", 10001)
            .set("sceneId", 100001)
            .set("pveLevel", 1)
            .set("winTeam", 1)
            .set("playSeconds", 186)
            .set("roomId", "11109969719885")
            .set("isSingleRound", false)
            .set("team1Score", 0)
            .set("team2Score", 0)
            .set("pveData", pveData)
            .set("playerList", List.of(playerReport))
            .set("pveEvaluations", List.of(evalInfo));
    }
}
