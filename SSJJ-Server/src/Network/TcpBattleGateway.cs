using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using NetData;
using SSJJ.Data;
using SSJJ.Server.Config;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.Network
{
    /// <summary>
    /// 原生 TCP 战斗信令网关（零依赖 handshake_packets.json，全部由 NetData ProtoContract 动态生成）
    /// </summary>
    public sealed class TcpBattleGateway
    {
        private static readonly ProtobufSerializer _proto = new ProtobufSerializer();

        private readonly int _port;
        private readonly IPAddress _bindAddr;
        private readonly ServerConfig _cfg;
        private readonly GameTables? _tables;
        private TcpListener? _listener;
        private bool _running;
        private NetworkStream? _activeStream;
        private readonly object _streamLock = new object();

        public int ConnectionId { get; } = 1;
        public bool IsClientSpawned { get; private set; }

        public event Action<TcpClient>? OnClientConnected;
        public event Action? OnPlayerSpawned;
        public event Action<byte[]>? OnTcpUserCmd2Received;
        public event Action? OnClientDisconnected;

        public TcpBattleGateway(ServerConfig cfg, int port = 27100, IPAddress? bindAddress = null, GameTables? tables = null)
        {
            _cfg = cfg;
            _port = port;
            _bindAddr = bindAddress ?? BindPolicy.Resolve();
            _tables = tables;
        }

        public void Start()
        {
            _running = true;
            _listener = new TcpListener(_bindAddr, _port);
            _listener.Start();
            Console.WriteLine($"[SSJJ-Server] TCP Battle Gateway listening on {BindPolicy.Describe(_bindAddr)}:{_port} (Pure NetData mode)");
            Task.Run(AcceptLoop);
        }

        private async Task AcceptLoop()
        {
            while (_running)
            {
                try
                {
                    var client = await _listener!.AcceptTcpClientAsync();
                    Console.WriteLine($"[SSJJ-Server] Battle Client accepted: {client.Client.RemoteEndPoint}");
                    OnClientConnected?.Invoke(client);
                    _ = HandleClientAsync(client);
                }
                catch when (!_running)
                {
                    break;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[SSJJ-Server] TCP Accept error: {ex.Message}");
                }
            }
        }

        private async Task HandleClientAsync(TcpClient client)
        {
            using var stream = client.GetStream();
            lock (_streamLock)
            {
                _activeStream = stream;
                IsClientSpawned = false;
            }

            byte[] lenBuf = new byte[4];
            try
            {
                while (_running && client.Connected)
                {
                    int read = await ReadExactAsync(stream, lenBuf, 4);
                    if (read < 4) break;
                    if (BitConverter.IsLittleEndian) Array.Reverse(lenBuf);
                    int len = BitConverter.ToInt32(lenBuf, 0);
                    if (len <= 0 || len > 4 * 1024 * 1024) break;

                    byte[] payload = new byte[len];
                    if (await ReadExactAsync(stream, payload, len) < len) break;

                    ProcessPacket(stream, payload);
                }
            }
            catch when (!_running)
            {
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SSJJ-Server] TCP Client loop error: {ex.Message}");
            }
            finally
            {
                lock (_streamLock)
                {
                    if (_activeStream == stream)
                    {
                        _activeStream = null;
                        IsClientSpawned = false;
                    }
                }
                Console.WriteLine("[SSJJ-Server] Battle Client disconnected.");
                OnClientDisconnected?.Invoke();
            }
        }

        private static async Task<int> ReadExactAsync(NetworkStream stream, byte[] buf, int count)
        {
            int total = 0;
            while (total < count)
            {
                int r = await stream.ReadAsync(buf, total, count - total);
                if (r <= 0) return total;
                total += r;
            }
            return total;
        }

        private void ProcessPacket(NetworkStream stream, byte[] packet)
        {
            APC? apc = DeserializeProto<APC>(packet);
            if (apc == null) return;
            int mid = apc.Id;
            byte[] content = apc.Content ?? Array.Empty<byte>();

            if (mid != 31)
            {
                Console.WriteLine($"[SSJJ-Server] TCP Recv Method={mid} (contentLen={content.Length})");
            }

            if (mid == 2 || mid == 32) // Login / TestLoginUniy
            {
                SendHandshakeStage1(stream);
            }
            else if (mid == 3) // LoadingSuccess
            {
                SendSpawnStage2(stream);
            }
            else if (mid == 23) // UnityProxyData
            {
                var proxy = DeserializeProto<UnityProxyData>(content);
                if (proxy != null)
                {
                    Console.WriteLine($"[SSJJ-Server] TCP UnityProxy Func={proxy.Func} Type={proxy.Type}");
                    if (proxy.Func == "getRoomInfo")
                    {
                        SendGetRoomInfoAck(stream);
                    }
                }
            }
            else if (mid == 31) // OnUserCmdTcp2
            {
                if (content.Length > 0)
                {
                    OnTcpUserCmd2Received?.Invoke(content);
                }
            }
            else if (mid == 18) // BackLobby
            {
                Console.WriteLine("[SSJJ-Server] Client requested BackLobby.");
            }
        }

        private void SendHandshakeStage1(NetworkStream stream)
        {
            int raceType = _cfg.EffectiveRaceType;
            int sectionMs = GetSectionTimeMs(raceType);
            int winScore = _cfg.WinScoreOverride > 0 ? _cfg.WinScoreOverride : GetWinScore(raceType);
            int playerNum = Math.Max(2, 1 + _cfg.AllyBots + _cfg.EnemyBots);

            Console.WriteLine($"[SSJJ-Server] -> Sending Dynamic Handshake (map={_cfg.MapId}, raceType={raceType}, team={_cfg.PlayerTeam}, bags={_cfg.Bags.Count})");

            // 1. CallbackLogin (Method 1)
            SendProto(stream, 1, new CallBackLoginData { Res = true });

            // 2. TcpConnectionIDData (Method 1000)
            SendProto(stream, 1000, new TcpConnectionIDData { Id = ConnectionId });

            // 3. RoomData (Method 12)
            var room = new RoomData
            {
                RaceType = raceType,
                SceneId = _cfg.MapId,
                WinCondition = 1,
                WinScore = winScore,
                SubRaceType = 0,
                SectionTime = sectionMs,
                ReLiveTime = ServerConfig.IsExplode(raceType) ? 0 : 3000,
                PlayerNum = playerNum,
                ChannelData = 1,
                RoomId = (_cfg.RoomId > 0 ? _cfg.RoomId : 1001).ToString(),
                UdpOptimize = false,       // 客户端使用 ParseOld 稳定解析路径
                IsLoadFreeTypeRes = true,  // 允许 Method 100 (FreeEvent / 特效 / 结算 UI) 生效
                IsMatch = false,
                NeedAce = false,
                CanVote = false
            };
            SendProto(stream, 12, room);

            // 4. OnGameinitData (Method 3)
            var init = BuildOnGameInitData(raceType);
            SendProto(stream, 3, init);

            // 5. GameServerSetupData (Method 44)
            SendProto(stream, 44, new GameServerSetupData { HitPlayerInfo = true });
        }

        private OnGameinitData BuildOnGameInitData(int raceType)
        {
            var init = new OnGameinitData
            {
                SceneId = _cfg.MapId,
                IsObserver = false,
                Team = _cfg.PlayerTeam,
                IsWoman = string.Equals(_cfg.Hand, "woman", StringComparison.OrdinalIgnoreCase),
                Debug = false,
                DefaultUseTcp = false,
                EngineID = 0,
                BspAsTriMesh = false
            };
            init.HandName.Add(string.IsNullOrWhiteSpace(_cfg.Hand) ? "man" : _cfg.Hand);

            var careers = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "police", "pandora_t" };
            if (!string.IsNullOrWhiteSpace(_cfg.Career)) careers.Add(_cfg.Career);
            if (!string.IsNullOrWhiteSpace(_cfg.BotCareer)) careers.Add(_cfg.BotCareer);
            foreach (var c in careers) init.PlayerList.Add(c);

            if (!string.IsNullOrWhiteSpace(_cfg.CareerSkin))
            {
                init.CareerSkinList.Add(_cfg.CareerSkin);
            }

            init.HandNameList.Add("man");
            init.HandNameList.Add("woman");

            var weapons = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "m4a1", "ak47", "deagle", "dagger", "grenade"
            };
            if (ServerConfig.IsExplode(raceType))
            {
                weapons.Add("c4");
            }

            var weaponSkins = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var bag in _cfg.Bags)
            {
                AddWeaponAndSkin(bag.Primary, bag.PrimarySkin, weapons, weaponSkins);
                AddWeaponAndSkin(bag.Secondary, bag.SecondarySkin, weapons, weaponSkins);
                AddWeaponAndSkin(bag.Melee, bag.MeleeSkin, weapons, weaponSkins);
                AddWeaponAndSkin(bag.Throwable, bag.ThrowableSkin, weapons, weaponSkins);
            }

            foreach (var w in weapons)
            {
                init.WeaponList.Add(w);
                init.ViewWeaponList.Add(w);
                init.SceneWeaponList.Add(w);
            }
            foreach (var s in weaponSkins)
            {
                init.WeaponSkinList.Add(s);
            }

            return init;
        }

        private void AddWeaponAndSkin(string? weapon, string? skin, HashSet<string> weapons, HashSet<string> skins)
        {
            if (!string.IsNullOrWhiteSpace(weapon)) weapons.Add(weapon.Trim());
            if (!string.IsNullOrWhiteSpace(skin))
            {
                string s = skin.Trim();
                if (_tables == null || _tables.GetSkin(s) != null)
                {
                    skins.Add(s);
                }
            }
        }

        private void SendSpawnStage2(NetworkStream stream)
        {
            int raceType = _cfg.EffectiveRaceType;
            int sectionMs = GetSectionTimeMs(raceType);

            Console.WriteLine("[SSJJ-Server] -> Client Map Loading Complete (Method 3)! Dispatching PlayerLogin + StartNewSection...");

            // 1. PlayerLoginOnInitData (Method 232)
            SendProto(stream, 232, BuildOnGameInitData(raceType));

            // 2. PlayerLogin (Method 9) for local player
            long localCharId = _cfg.CharId > 0 ? _cfg.CharId : 1000200072528;
            SendProto(stream, 9, new PlayerLoginData
            {
                Id = 1,
                PlayerName = string.IsNullOrWhiteSpace(_cfg.PlayerName) ? "石井执行官" : _cfg.PlayerName,
                Team = _cfg.PlayerTeam,
                CharacterId = localCharId,
                IsObserver = false,
                IsBot = false,
                CurKillNum = 0,
                VipLv = 0,
                Show = true
            });

            // 2b. PlayerInfo (Method 61) -> 必须下发，否则客户端 PlayerOrientationPredicationSystem.OnPredicate 找不到 Cid 导致无法本地预测 Yaw（鼠标转视角 30Hz 卡顿）
            SendProto(stream, 61, new PlayerInfoData
            {
                Cid = localCharId,
                MaxReliveTime = 3000,
                CanReliveTime = 3000,
                ThirdModeNoViewChange = false
            });

            // 3. StartNewSection (Method 13)
            SendProto(stream, 13, new TimeData { Time = sectionMs });

            IsClientSpawned = true;
            OnPlayerSpawned?.Invoke();
        }

        private void SendGetRoomInfoAck(NetworkStream stream)
        {
            int total = Math.Max(2, 1 + _cfg.AllyBots + _cfg.EnemyBots);
            string json = JsonSerializer.Serialize(new
            {
                roomId = _cfg.RoomId > 0 ? _cfg.RoomId : 1001,
                limitNumber = total,
                battleType = 3,
                roomName = $"SSJJ离线-{_cfg.Mode}",
                channelName = "离线战场"
            });
            var proxy = new UnityProxyData
            {
                Type = (UnityProxyType)0,
                Key = "offline_local_sign",
                Func = "onGetRoomInfo"
            };
            proxy.Params.Add(Encoding.UTF8.GetBytes(json));
            SendProto(stream, 199, proxy);
        }

        public static int GetSectionTimeMs(int raceType) => raceType switch
        {
            2 => 150_000,   // 爆破每回合 2分30秒
            5 or 12 => 480_000,
            64 or 74 => 480_000,
            _ => 600_000    // 团队/刀战 10分钟
        };

        public static int GetWinScore(int raceType) => raceType switch
        {
            2 => 5,   // 爆破抢5回合
            5 => 30,
            15 or 2041 => 40,
            _ => 50
        };

        // =========================================================================
        // 服务端权威战斗 RPC 下发接口
        // =========================================================================

        public void BroadcastPlayerLogin(int id, string name, int team, long charId, bool isBot)
        {
            SendProtoActive(9, new PlayerLoginData
            {
                Id = id,
                PlayerName = name,
                Team = team,
                CharacterId = charId,
                IsObserver = false,
                IsBot = isBot,
                Show = !isBot
            });
        }

        public void BroadcastHitPlayer()
        {
            SendProtoActive(131, new GameServerSetupData { HitPlayerInfo = true });
        }

        public void BroadcastKillNotice(int killerId, string killerName, int victimId, string victimName,
            string weaponName, string weaponSkin, bool headshot, int killNum, int killerTeam, int victimTeam)
        {
            var msg = new KillPlayerInfoData
            {
                CurKillNum = killNum,
                KillNum = killNum,
                KillPlayerName = killerName,
                KillTeam = killerTeam,
                WeaponName = weaponName,
                BeKillPlayerName = victimName,
                BekillTeam = victimTeam,
                Revenge = false,
                Headshot = headshot,
                KillPlayerId = killerId,
                BeKillPlayerId = victimId,
                FirstBlood = killNum == 1
            };
            if (!string.IsNullOrEmpty(weaponSkin))
            {
                msg.WeaponSkinName = weaponSkin;
            }
            SendProtoActive(6, msg);
        }

        public void BroadcastScoreBoard(IEnumerable<PlayerBasicInfo> players)
        {
            var all = new AllKillInfoData();
            foreach (var p in players)
            {
                all.List.Add(new OneKillInfoData
                {
                    Id = p.Id,
                    Team = p.Team,
                    PlayerName = p.PlayerName,
                    KillNum = p.Kills,
                    BeKillNum = p.Deaths,
                    IsDead = p.IsDead,
                    HasC4 = p.HasC4,
                    Career = p.Career,
                    Score = p.Score
                });
            }
            SendProtoActive(8, all);
        }

        public void BroadcastTeamScore(int team1Score, int team2Score, int winScore, int team1Kill, int team2Kill)
        {
            SendProtoActive(4, new BroadcastScoreData
            {
                Team1Score = team1Score,
                Team2Score = team2Score,
                WinScore = winScore,
                CurrentScore = Math.Max(team1Score, team2Score),
                Team1Kill = team1Kill,
                Team2Kill = team2Kill
            });
        }

        public void BroadcastStartNewSection(int sectionTimeMs)
        {
            SendProtoActive(13, new TimeData { Time = sectionTimeMs });
        }

        public void BroadcastClearForNewSection()
        {
            SendFrameActive(62, Array.Empty<byte>());
        }

        public void BroadcastC4State(bool active, int remainingSec)
        {
            SendProtoActive(14, new C4ActiveData { Active = active, Time = remainingSec });
        }

        public void BroadcastSimpleProto(SimpleProto proto)
        {
            SendProtoActive(100, proto);
        }

        public void BroadcastSkillInfo(SkillInfoData skill)
        {
            SendProtoActive(27, skill);
        }

        public void BroadcastWeaponMaster(IList<bool> states)
        {
            var msg = new MessageListData();
            foreach (var b in states) msg.BoolList.Add(b);
            SendProtoActive(120, msg);
        }

        public void BroadcastBigHeadProgress(int lv, int progress)
        {
            SendProtoActive(64, new BigHeadProgressData { Lv = lv, Progress = progress });
        }

        public void BroadcastPlayerInfo(long cid, int maxReliveTime = 3000)
        {
            SendProtoActive(61, new PlayerInfoData
            {
                Cid = cid,
                MaxReliveTime = maxReliveTime,
                CanReliveTime = maxReliveTime,
                ThirdModeNoViewChange = false
            });
        }

        public void BroadcastMissionResult(bool win, string winnerName)
        {
            if (win)
                SendProtoActive(18, new StringData { Data = winnerName ?? "" });
            else
                SendFrameActive(19, Array.Empty<byte>());
        }

        public void BroadcastWin()
        {
            SendFrameActive(5, Array.Empty<byte>());
        }

        private void SendProtoActive<T>(int mid, T message)
        {
            byte[] body = SerializeProto(message);
            SendFrameActive(mid, body);
        }

        private void SendFrameActive(int mid, byte[] body)
        {
            lock (_streamLock)
            {
                if (_activeStream == null) return;
                SendFrameUnlocked(_activeStream, mid, body);
            }
        }

        private void SendProto<T>(NetworkStream stream, int mid, T message)
        {
            byte[] body = SerializeProto(message);
            lock (_streamLock)
            {
                SendFrameUnlocked(stream, mid, body);
            }
        }

        private static void SendFrameUnlocked(NetworkStream stream, int mid, byte[] body)
        {
            var apc = new APC { Id = mid };
            if (body != null && body.Length > 0)
            {
                apc.Content = body;
            }
            byte[] apcBytes = SerializeProto(apc);
            byte[] lenBytes = BitConverter.GetBytes(apcBytes.Length);
            if (BitConverter.IsLittleEndian) Array.Reverse(lenBytes);

            try
            {
                stream.Write(lenBytes, 0, 4);
                stream.Write(apcBytes, 0, apcBytes.Length);
                stream.Flush();
            }
            catch { }
        }

        public static byte[] SerializeProto<T>(T obj)
        {
            using var ms = new MemoryStream();
            _proto.Serialize(ms, obj);
            return ms.ToArray();
        }

        public static T? DeserializeProto<T>(byte[] data) where T : class
        {
            if (data == null || data.Length == 0) return null;
            using var ms = new MemoryStream(data);
            return _proto.Deserialize(ms, null, typeof(T)) as T;
        }

        public void Stop()
        {
            _running = false;
            try { _listener?.Stop(); } catch { }
        }
    }
}
