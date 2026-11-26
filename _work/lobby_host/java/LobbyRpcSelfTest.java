import com.strikegod.downloader.service.Amf3Decoder;
import com.strikegod.downloader.service.Amf3Encoder;
import com.strikegod.downloader.service.Amf3TypedObject;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.List;
import java.util.Map;

/** Run against a lobby started with an isolated profile and headless battle enabled. */
public final class LobbyRpcSelfTest {
    private static final class Client implements AutoCloseable {
        private final Socket socket;
        private final DataInputStream in;
        private final DataOutputStream out;

        Client(int port) throws Exception {
            socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1", port), 3000);
            socket.setSoTimeout(12000);
            in = new DataInputStream(socket.getInputStream());
            out = new DataOutputStream(socket.getOutputStream());
        }

        List<?> call(String request, String response, Object... parameters) throws Exception {
            byte[] frame = Amf3Encoder.encodeOnce(Amf3TypedObject.apc(request, List.of(parameters)));
            out.writeInt(frame.length + 1);
            out.writeByte(0);
            out.write(frame);
            out.flush();
            return receive(response);
        }

        List<?> receive(String response) throws Exception {
            for (int i = 0; i < 30; i++) {
                int length = in.readInt();
                in.readByte();
                Map<?, ?> frame = fields(new Amf3Decoder(in.readNBytes(length - 1)).decodeOne());
                Object got = frame.get("functionName");
                if (response.equals(got)) return (List<?>)frame.get("parameters");
                if ("callBackStartGameFail".equals(got)) throw new AssertionError(frame);
            }
            throw new AssertionError("Callback missing: " + response);
        }

        Map<?, ?> login(String name) throws Exception {
            call("loginV3", "callBackLoginV3");
            return fields(call("getUserDataByLogin", "callBackGetUserDataByLogin", name).get(0));
        }

        @Override public void close() throws Exception { socket.close(); }
    }

    private static Map<?, ?> fields(Object bean) { return (Map<?, ?>)bean; }
    private static int integer(Object value) { return ((Number)value).intValue(); }

    private static void check(boolean condition, String description) {
        if (!condition) throw new AssertionError(description);
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(args[0]);
        try (Client host = new Client(port); Client guest = new Client(port)) {
            Map<?, ?> owner = host.login("local");
            Map<?, ?> peer = guest.login("SmokeGuest");
            check(!owner.get("characterId").equals(peer.get("characterId")), "distinct room identities");
            host.call("selectAvatarBag", "callBackSelectAvatarBag", 1);
            host.call("equipRootAvatar", "callBackEquipRootAvatar", 1, 5);
            host.call("equipRootAvatar", "callBackEquipRootAvatar", 1, 6);
            var skinUpdate = host.call("equipRootAvatarInfo", "callBackEquipRootAvatarInfo", 133, "80001024", 0);
            check(integer(skinUpdate.get(0)) == 1, "avatar skin accepted");
            var partUpdate = host.call("equipRootAvatarInfo", "callBackEquipRootAvatarInfo", 133, "16001024", 0);
            check(integer(partUpdate.get(0)) == 1, "avatar accessory accepted");
            var settings = new Amf3TypedObject("bean.UserSettingBean", List.of("isBackgroundMusic"), false);
            settings.set("isBackgroundMusic", false);
            host.call("changeUserSetting", "onChangeUserSetting", settings);
            host.call("selectBag", "onSelectBag", 4);
            host.call("equip", "onEquip", 4, "10000001");
            host.call("weaponEquipSkin", "callbackUpdateStorages", "10015722", "80002063", 1);

            host.call("getZoneGroup", "callBackGetZoneGroup");
            host.call("getRoomChannel", "callChannelList");
            host.call("enterChannel", "callEnterChannelSuccess", "local", 1);
            var room = new Amf3TypedObject("bean.RoomInfoEx", List.of("sceneId", "raceType", "limitNumber", "roomName"), false);
            room.set("sceneId", 12).set("raceType", 3).set("limitNumber", 2).set("roomName", "Lobby smoke test");
            List<?> created = host.call("createRoom", "callBackJoinRoom", room);
            int id = integer(fields(created.get(1)).get("roomId"));
            check(((List<?>)guest.call("roomList", "callBackShowRoomList").get(0)).size() == 1, "visible room");
            List<?> joined = guest.call("joinRoom", "callBackJoinRoom", id, "");
            check(((List<?>)joined.get(2)).size() == 2, "two members");
            host.receive("callBackUserJoin");
            host.receive("callBackRefreshCurrentRoom");
            room.set("raceType", 2);
            var updated = fields(host.call("updateRoom", "callBackRefreshCurrentRoom", room).get(0));
            check(integer(updated.get("raceType")) == 2, "updated room mode");
            guest.call("changeTeam", "callBackChangeTeam", 2, false);
            var observing = guest.call("changeGameToObserver", "callBackChangeGameToObserver");
            check(Boolean.TRUE.equals(observing.get(1)), "observer without arguments");
            guest.call("changeTeam", "callBackChangeTeam", 2, false);
            guest.call("readyGame", "callBackRefreshUserStatus", 1);
            var endpoint = host.call("startGame", "onRoomBattleEndpoint");
            check(integer(endpoint.get(6)) == 2, "battle endpoint for two players");
            try (var battle = new Socket()) {
                battle.connect(new InetSocketAddress((String)endpoint.get(1), integer(endpoint.get(2))), 3000);
            }
            guest.receive("onRoomBattleEndpoint");
            guest.call("leaveRoom", "callBackLeaveRoom");
            host.call("leaveRoom", "callBackLeaveRoom");
            System.out.println("Room, observing, ready and two-client battle endpoint passed");
        }
        try (Client reloaded = new Client(port)) {
            Map<?, ?> user = reloaded.login("local");
            check(integer(user.get("selectedBagIndex")) == 4, "weapon bag restored");
            check(integer(user.get("selectAvatarBagIndex")) == 1, "avatar bag restored");
            check(integer(user.get("avatarT")) == 5 && integer(user.get("avatarCT")) == 6, "both avatars restored");
            check(Boolean.FALSE.equals(fields(user.get("settingBean")).get("isBackgroundMusic")), "setting restored");
            var avatars = fields(user.get("rootAvatarDataHashMap"));
            var appearance = fields(avatars.get("133"));
            check(integer(appearance.get("storageSkinId")) == 80001024, "avatar skin restored");
            check(!"".equals(appearance.get("careerSkin")), "avatar skin career restored");
            var parts = fields(appearance.get("avatarPartDataMap"));
            check(integer(fields(parts.get("1")).get("avatarPartStorageId")) == 16001024, "avatar accessory restored");
            Map<?, ?> storages = fields(user.get("storageMap"));
            Map<?, ?> skin = fields(storages.get("80002063"));
            check(integer(fields(skin.get("extBean")).get("weaponStorageId")) == 10015722, "weapon skin restored");
            System.out.println("Avatar, bag, weapon and skin persistence passed");
            var firstRpgInfo = fields(reloaded.call("getClientRpgUserInfo", "callbackGetClientRpgUserInfo").get(0));
            int initialPower = integer(fields(firstRpgInfo.get("rpgBean")).get("bonus"));
            check(initialPower >= 25_000, "adventure profile has starting power");
            reloaded.call("unequip", "onUnequip", 4, "10000001");
            var secondRpgInfo = fields(reloaded.call("getClientRpgUserInfo", "callbackGetClientRpgUserInfo").get(0));
            check(integer(fields(secondRpgInfo.get("rpgBean")).get("bonus")) < initialPower, "power reflects the equipped weapon");
            var entry = reloaded.call("getGameChannelServerInfo", "callbackGetGameChannelServerInfo", "rpg");
            check(integer(entry.get(0)) == 1, "adventure endpoint accepted");
            var address = fields(entry.get(1));
            check("rpg".equals(address.get("type")) && "127.0.0.1".equals(address.get("domain")), "loopback adventure channel");
            try (var adventure = new Client(integer(address.get("port")))) {
                check(Boolean.FALSE.equals(adventure.call("enterRpgServer", "callbackEnterRpgServerSuccess", "local").get(0)),
                    "adventure channel ready");
                check(integer(adventure.call("notUsePlotWeapon", "callbackNotUsePlotWeapon", 1, 1).get(0)) == 1,
                    "adventure plot weapon toggle");
                var team = adventure.call("createRpgTeam", "callbackCreateRpgTeam", 1011);
                check(integer(team.get(0)) == 1, "adventure team created");
                check(integer(adventure.receive("callbackRpgTeamChangeStatus").get(0)) == 1, "rpg team status 1");
                check(integer(adventure.receive("callbackRpgTeamChangeStatus").get(0)) == 2, "rpg team status 2");
                var startMatch = adventure.call("startRpgMatch", "callBackStartRpgGame");
                check("11109969719885".equals(startMatch.get(0)) && "127.0.0.1".equals(startMatch.get(1))
                    && integer(startMatch.get(2)) == 27100, "startRpgMatch endpoint");
                check(Boolean.TRUE.equals(adventure.receive("callbackRpgUserChangeInGameServer").get(0)),
                    "rpg user in game server");
                var loginBattle = adventure.call("loginBattle", "callbackLoginBattle", "1000200072528", 1);
                check(String.valueOf(loginBattle.get(0)).contains("\"loginUnity\":1"), "loginBattle payload");
                var battleEnd = adventure.call("finishRpgBattle", "callBackBattleEnd");
                var report = fields(battleEnd.get(0));
                check(integer(report.get("raceType")) == 10001 && integer(report.get("sceneId")) == 100001
                    && integer(report.get("winTeam")) == 1, "adventure battle report");
                var taskUpdate = fields(adventure.receive("callbackUpdateRpgTask").get(0));
                check(integer(taskUpdate.get("id")) == 20320001, "adventure task update");
                adventure.call("createRpgRoom", "callbackCreateRpgRoom", 1011, "");
                var rooms = adventure.call("getRpgRoomList", "callbackGetRpgRoomList");
                check(((List<?>)rooms.get(0)).size() == 1, "adventure room listed");
                adventure.call("leaveRpgTeam", "callbackLeaveRpgTeam");
                check(((List<?>)adventure.call("getRpgRoomList", "callbackGetRpgRoomList").get(0)).isEmpty(), "left adventure room");
            }
            System.out.println("Adventure entry, power, team, match launch, battle report, and room passed");
        }
    }
}
