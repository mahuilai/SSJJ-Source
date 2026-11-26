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
using SSJJ.Server.GameModes;
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
        private readonly IReadOnlyCollection<string> _botCareers;
        private TcpListener? _listener;
        private volatile bool _running;
        private NetworkStream? _flashProxyStream;
        private readonly object _flashLock = new object();

        public ClientSessionRegistry Sessions { get; }
        public bool IsClientSpawned => Sessions.Snapshot().Any(s => s.IsSpawned);

        public event Action<TcpClient>? OnClientConnected;
        public event Action<ClientSession>? OnPlayerSpawned;
        public event Action<ClientSession, byte[]>? OnTcpUserCmd2Received;
        public event Action<ClientSession, TacticsSoundData>? OnTacticsSoundRequested;
        public event Action<ClientSession, int>? OnObserverTargetRequested;
        public event Action<ClientSession>? OnClientDisconnected;
        public event Action? OnPveGameWinReceived;

        public TcpBattleGateway(
            ServerConfig cfg,
            int port = 27100,
            IPAddress? bindAddress = null,
            GameTables? tables = null,
            IReadOnlyCollection<string>? botCareers = null,
            ClientSessionRegistry? sessions = null)
        {
            _cfg = cfg;
            _port = port;
            _bindAddr = bindAddress ?? BindPolicy.Resolve();
            _tables = tables;
            _botCareers = botCareers ?? Array.Empty<string>();
            Sessions = sessions ?? new ClientSessionRegistry();
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
            using var socket = client;
            using var stream = client.GetStream();
            using var loginTimeout = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            ClientSession? session = null;
            Task? writer = null;
            bool isFlashProxy = false;

            byte[] lenBuf = new byte[4];
            try
            {
                while (_running && client.Connected)
                {
                    CancellationToken readToken = (session == null && !isFlashProxy) ? loginTimeout.Token : CancellationToken.None;
                    int read = await ReadExactAsync(stream, lenBuf, 4, readToken);
                    if (read < 4) break;
                    if (BitConverter.IsLittleEndian) Array.Reverse(lenBuf);
                    int len = BitConverter.ToInt32(lenBuf, 0);
                    if (len <= 0 || len > 4 * 1024 * 1024) break;

                    byte[] payload = new byte[len];
                    if (await ReadExactAsync(stream, payload, len, readToken) < len) break;

                    var apc = DeserializeProto<APC>(payload);
                    if (apc == null) break;

                    if (session == null && !isFlashProxy)
                    {
                        if (apc.Id != 2 && apc.Id != 32) break;
                        byte[] content = apc.Content ?? Array.Empty<byte>();
                        if (apc.Id == 2 && IsFlashProxyLogin(content))
                        {
                            isFlashProxy = true;
                            lock (_flashLock)
                            {
                                _flashProxyStream = stream;
                            }
                            Console.WriteLine("[SSJJ-Server] -> Flash Proxy Login (f200=2) accepted; sending Method 1 CallBackLoginData.");
                            await stream.WriteAsync(BuildFrame(1, SerializeProto(new CallBackLoginData { Res = true })), loginTimeout.Token);
                            continue;
                        }

                        var login = apc.Id == 2 ? DeserializeProto<LoginData>(content) : null;
                        bool isPve = ServerConfig.IsPve(_cfg.EffectiveRaceType);
                        long roomId = _cfg.RoomId > 0 ? _cfg.RoomId : (isPve ? 11109969719885L : 1001L);
                        long userId = Sessions.Capacity > 1 ? login?.UserId ?? 0 : (_cfg.CharId > 0 ? _cfg.CharId : 1000200072528L);
                        _cfg.LobbyPlayers.TryGetValue(userId, out var lobbyPlayer);
                        bool roomMatches = login is not { RoomId: > 0 } || login.RoomId == roomId;
                        bool seatMatches = Sessions.Capacity == 1 || _cfg.LobbyPlayers.Count == 0 || (lobbyPlayer != null && login?.RoomId == roomId);
                        if (roomMatches && seatMatches)
                        {
                            long defaultCid = _cfg.CharId > 0 ? _cfg.CharId : 1000200072528L;
                            session = Sessions.TryAdd(
                                client,
                                _cfg.PlayerTeam,
                                defaultCid,
                                Sessions.Capacity > 1 ? userId : 0,
                                oneTeam: isPve,
                                assignedTeam: lobbyPlayer?.Team is 1 or 2 ? lobbyPlayer.Team : null);
                        }
                        if (session == null)
                        {
                            await stream.WriteAsync(BuildFrame(1, SerializeProto(new CallBackLoginData { Res = false })), loginTimeout.Token);
                            break;
                        }
                        writer = session.WriteFramesAsync();
                        SendHandshakeStage1(session);
                        continue;
                    }

                    if (isFlashProxy)
                    {
                        ProcessFlashProxyPacket(apc);
                        continue;
                    }

                    ProcessPacket(session!, apc);
                }
            }
            catch (OperationCanceledException) when (loginTimeout.IsCancellationRequested)
            {
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
                if (isFlashProxy)
                {
                    lock (_flashLock)
                    {
                        if (_flashProxyStream == stream) _flashProxyStream = null;
                    }
                    Console.WriteLine("[SSJJ-Server] Flash Proxy TCP Client disconnected.");
                }
                if (session != null)
                {
                    Sessions.Remove(session);
                    OnClientDisconnected?.Invoke(session);
                    if (writer != null) await writer;
                    Console.WriteLine($"[SSJJ-Server] Battle Client P{session.PlayerId} (cid={session.CharacterId}) disconnected.");
                }
            }
        }

        private static async Task<int> ReadExactAsync(NetworkStream stream, byte[] buf, int count, CancellationToken token)
        {
            int total = 0;
            while (total < count)
            {
                int r = await stream.ReadAsync(buf.AsMemory(total, count - total), token);
                if (r <= 0) return total;
                total += r;
            }
            return total;
        }

        private static bool IsFlashProxyLogin(byte[] content)
        {
            if (content == null || content.Length < 40) return false;
            string ascii = Encoding.UTF8.GetString(content);
            return ascii.Contains("isMicroClient", StringComparison.Ordinal);
        }

        private void ProcessFlashProxyPacket(APC apc)
        {
            if (apc.Id == 23)
            {
                var proxy = DeserializeProto<UnityProxyData>(apc.Content ?? Array.Empty<byte>());
                if (proxy != null)
                {
                    Console.WriteLine($"[SSJJ-Server] Flash Proxy UnityProxy Func={proxy.Func} Type={proxy.Type}");
                    SendProtoActive(199, proxy);
                }
            }
        }

        private void ProcessPacket(ClientSession session, APC apc)
        {
            int mid = apc.Id;
            byte[] content = apc.Content ?? Array.Empty<byte>();

            if (mid != 31)
            {
                Console.WriteLine($"[SSJJ-Server] TCP Recv P{session.PlayerId} Method={mid} (contentLen={content.Length})");
            }

            if (mid == 3 && !session.IsSpawned) // LoadingSuccess
            {
                SendSpawnStage2(session);
            }
            else if (mid == 23) // UnityProxyData
            {
                var proxy = DeserializeProto<UnityProxyData>(content);
                if (proxy != null)
                {
                    Console.WriteLine($"[SSJJ-Server] TCP UnityProxy Func={proxy.Func} Type={proxy.Type}");
                    SendProtoFlash(199, proxy);

                    if (proxy.Func == "setBattleRaceType")
                    {
                        var reply = new UnityProxyData
                        {
                            Type = proxy.Type,
                            Key = string.IsNullOrEmpty(proxy.Key) ? "bc8f2078ee5ec726bc4631d4a47d5d2e" : proxy.Key,
                            Func = "setBattleRaceType"
                        };
                        reply.Params.Add(Encoding.UTF8.GetBytes($"{{\"raceType\":{_cfg.EffectiveRaceType}}}"));
                        SendTo(session, 199, reply);
                    }
                    else if (proxy.Func == "getRoomInfo")
                    {
                        SendGetRoomInfoAck(session);
                    }
                    else if (proxy.Func == "LoginStart" || proxy.Func == "getFriendlyFlag" || proxy.Func == "askForHelp")
                    {
                        SendTo(session, 199, proxy);
                    }
                    else if (proxy.Func == "GAME_WIN")
                    {
                        BroadcastFlashGameClose(proxy.Key);
                        OnPveGameWinReceived?.Invoke();
                    }
                }
            }
            else if (mid == 31) // OnUserCmdTcp2
            {
                if (content.Length > 0)
                {
                    OnTcpUserCmd2Received?.Invoke(session, content);
                }
            }
            else if (mid == 5) // Client -> Server TacticsSoundData
            {
                var ts = DeserializeProto<TacticsSoundData>(content);
                if (ts != null)
                {
                    OnTacticsSoundRequested?.Invoke(session, ts);
                }
            }
            else if (mid == 9) // Client -> Server Observer target switch
            {
                int? targetId = null;
                try { targetId = DeserializeProto<IntData>(content)?.Data; } catch { }
                if (targetId == null && content.Length == 4)
                {
                    targetId = (content[0] << 24) | (content[1] << 16) | (content[2] << 8) | content[3];
                }
                if (targetId.HasValue)
                {
                    OnObserverTargetRequested?.Invoke(session, targetId.Value);
                }
            }
            else if (mid == 18) // BackLobby
            {
                Console.WriteLine($"[SSJJ-Server] Client P{session.PlayerId} requested BackLobby.");
            }
        }

        private void SendHandshakeStage1(ClientSession session)
        {
            int raceType = _cfg.EffectiveRaceType;
            bool isPve = ServerConfig.IsPve(raceType);
            int sectionMs = GetConfiguredSectionTimeMs();
            int winScore = _cfg.WinScoreOverride > 0 ? _cfg.WinScoreOverride : GetWinScore(raceType);
            int playerNum = isPve ? Math.Max(1, Sessions.Capacity) : Math.Max(2, Sessions.Capacity + _cfg.AllyBots + _cfg.EnemyBots);

            Console.WriteLine($"[SSJJ-Server] -> Sending Dynamic Handshake to P{session.PlayerId} (map={_cfg.MapId}, raceType={raceType}, team={session.Team}, cid={session.CharacterId}, bags={_cfg.GetHumanBags(session.CharacterId).Count})");

            // 1. CallbackLogin (Method 1)
            SendTo(session, 1, new CallBackLoginData { Res = true });

            // 2. TcpConnectionIDData (Method 1000)
            SendTo(session, 1000, new TcpConnectionIDData { Id = session.ConnectionId });

            // 3. RoomData (Method 12)
            var room = new RoomData
            {
                RaceType = raceType,
                SceneId = _cfg.MapId,
                WinCondition = isPve ? 0 : 1,
                WinScore = isPve ? 0 : winScore,
                SubRaceType = 0,
                SectionTime = isPve ? 0 : sectionMs,
                ReLiveTime = ReliveTimeMs,
                PlayerNum = playerNum,
                PveLevel = isPve ? 1 : 0,
                ChannelData = isPve ? 0 : 1,
                RoomId = (_cfg.RoomId > 0 ? _cfg.RoomId : (isPve ? 11109969719885L : 1001L)).ToString(),
                UdpOptimize = false,       // 客户端使用 ParseOld 稳定解析路径
                IsLoadFreeTypeRes = true,  // 允许 Method 100 (FreeEvent / 特效 / 结算 UI) 生效
                IsMatch = false,
                NeedAce = false,
                CanVote = false
            };
            SendTo(session, 12, room);

            // 4. OnGameinitData (Method 3)
            var init = BuildOnGameInitData(raceType, session);
            SendTo(session, 3, init);

            // 5. GameServerSetupData (Method 44)
            SendTo(session, 44, new GameServerSetupData { HitPlayerInfo = !isPve });

            // 6. PVE SceneItemInfoList (Method 74) for map100001 roadblocks
            if (isPve && _cfg.MapId == 100001)
            {
                SendPveRoadBlocks(session);
            }
        }

        private void SendPveRoadBlocks(ClientSession session)
        {
            var list = new PeekabooItemListTmpData();
            list.List.Add(new PeekabooItemTmpData
            {
                Id = 1,
                FileName = "genpve_door4_roadBlock",
                Name = "roadBlock",
                MinX = -400,
                MinY = -35,
                MinZ = 0,
                MaxX = 400,
                MaxY = 35,
                MaxZ = 600,
                PosX = 5328,
                PosY = 2412,
                PosZ = 522
            });
            list.List.Add(new PeekabooItemTmpData
            {
                Id = 2,
                FileName = "genpve_door4_roadBlock",
                Name = "roadBlock",
                MinX = -400,
                MinY = -35,
                MinZ = 0,
                MaxX = 400,
                MaxY = 35,
                MaxZ = 600,
                PosX = 3312,
                PosY = 7581,
                PosZ = 517
            });
            SendTo(session, 74, list);
        }

        private OnGameinitData BuildOnGameInitData(int raceType, ClientSession session)
        {
            bool isPve = ServerConfig.IsPve(raceType);
            bool isWeSceMap = _cfg.MapId == 100001;
            string handName = _cfg.GetHumanHand(session.CharacterId);
            var init = new OnGameinitData
            {
                SceneId = _cfg.MapId,
                IsObserver = false,
                Team = session.Team,
                IsWoman = string.Equals(handName, "woman", StringComparison.OrdinalIgnoreCase),
                Debug = false,
                DefaultUseTcp = false,
                EngineID = isWeSceMap ? 4 : 0,
                BspAsTriMesh = false
            };
            if (isWeSceMap)
            {
                init.ObfuscatorSeed = new Vector3DData { X = -4392f, Y = -4944f, Z = -3319f };
                init.SceneObjectList.Add("genpve_door4_roadBlock");
            }
            if (isPve)
            {
                init.NewbieGuide = -1;
                init.NewbieGuideBag = -1;
                init.BossTipsHpRage = 0.8f;
                init.OpenYinYangDun = true;
                init.ExtraInfoBool = 1;
            }
            init.HandName.Add(string.IsNullOrWhiteSpace(handName) ? "man" : handName);

            var careers = new HashSet<string>(_botCareers, StringComparer.OrdinalIgnoreCase) { "police", "pandora_t" };
            if (!string.IsNullOrWhiteSpace(_cfg.Career)) careers.Add(_cfg.Career);
            if (!string.IsNullOrWhiteSpace(_cfg.BotCareer)) careers.Add(_cfg.BotCareer);
            var careerSkins = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (!string.IsNullOrWhiteSpace(_cfg.CareerSkin)) careerSkins.Add(_cfg.CareerSkin);
            foreach (var lp in _cfg.LobbyPlayers.Values)
            {
                if (!string.IsNullOrWhiteSpace(lp.Career)) careers.Add(lp.Career);
                if (!string.IsNullOrWhiteSpace(lp.CareerSkin)) careerSkins.Add(lp.CareerSkin);
            }
            if (isPve)
            {
                string[] pveCareers =
                {
                    "boss1001", "type2", "researcher", "mercenary",
                    "rpg_minion_builder", "mercenary_2", "rpg_minion_guard", "researcher_1"
                };
                foreach (var pc in pveCareers) careers.Add(pc);
            }
            if (ServerConfig.IsBiohazard(raceType))
            {
                careers.Add(BiohazardRound.Mother);
                careers.Add(BiohazardRound.Infected);
                careers.Add(BiohazardRound.HeroCareer);
            }
            foreach (var c in careers) init.PlayerList.Add(c);
            foreach (var cs in careerSkins) init.CareerSkinList.Add(cs);

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
            if (isPve)
            {
                weapons.Add("botweapon");
                weapons.Add("hero");
            }
            if (ServerConfig.IsBiohazard(raceType))
            {
                weapons.Add(BiohazardRound.Mother);
                weapons.Add(BiohazardRound.Infected);
                weapons.Add(BiohazardRound.HeroWeapon);
            }

            var weaponSkins = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            void AddBagItems(IEnumerable<BagSlotConfig>? bags)
            {
                if (bags == null) return;
                foreach (var bag in bags)
                {
                    AddWeaponAndSkin(bag.Primary, bag.PrimarySkin, weapons, weaponSkins);
                    AddWeaponAndSkin(bag.Secondary, bag.SecondarySkin, weapons, weaponSkins);
                    AddWeaponAndSkin(bag.Melee, bag.MeleeSkin, weapons, weaponSkins);
                    AddWeaponAndSkin(bag.Throwable, bag.ThrowableSkin, weapons, weaponSkins);
                    AddWeaponAndSkin(bag.Throwable2, bag.Throwable2Skin, weapons, weaponSkins);
                    AddWeaponAndSkin(bag.Throwable3, bag.Throwable3Skin, weapons, weaponSkins);
                }
            }
            AddBagItems(_cfg.Bags);
            foreach (var lp in _cfg.LobbyPlayers.Values)
            {
                AddBagItems(lp.Bags);
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

        private void SendSpawnStage2(ClientSession session)
        {
            int raceType = _cfg.EffectiveRaceType;
            bool isPve = ServerConfig.IsPve(raceType);
            int sectionMs = GetConfiguredSectionTimeMs();
            int reliveMs = ReliveTimeMs;
            string playerName = _cfg.GetHumanName(session.CharacterId, session.PlayerId);

            Console.WriteLine($"[SSJJ-Server] -> Client P{session.PlayerId} ({playerName}) Map Loading Complete (Method 3)! Dispatching PlayerLogin + StartNewSection...");

            // 1. PlayerLoginOnInitData (Method 232)
            SendTo(session, 232, BuildOnGameInitData(raceType, session));

            // 1.5 SceneMapInfoData (Method 111): 显式同步重力 2032 与起跳速度 681，确保所有模式与服务端 SceneMoveData 1:1 对齐
            SendTo(session, 111, new SceneMapInfoData
            {
                SceneId = _cfg.MapId,
                WorldGravity = 2032,
                HumanityJumpVelocity = 681,
                DounJumpVelocity = 681,
                HeroJumpVelocity = 681,
                JumpDamage = !isPve
            });

            if (isPve)
            {
                // PVE init sequence from industrial_01.pcapng
                SendTo(session, 71, new PveMessageData
                {
                    Type = (TowerDefenseMessageType)3,
                    Time = -2121
                });

                var counterList = new RpgCounterListData();
                counterList.List.Add(new RpgCounterData
                {
                    Type = 101,
                    Id = 20320001,
                    Now = 209,
                    Max = 1000,
                    Name = "清道夫训练1"
                });
                SendTo(session, 126, counterList);
            }

            // 2. PlayerLogin (Method 9) for local player
            SendTo(session, 9, new PlayerLoginData
            {
                Id = session.PlayerId,
                PlayerName = playerName,
                Team = session.Team,
                CharacterId = session.CharacterId,
                IsObserver = false,
                IsBot = false,
                CurKillNum = 0,
                VipLv = 5,
                Show = !isPve
            });

            if (isPve)
            {
                SendTo(session, 21, new ResetYawData { Yaw = 180f });
            }

            // 2b. PlayerInfo (Method 61) -> 必须下发，否则客户端 PlayerOrientationPredicationSystem.OnPredicate 找不到 Cid 导致无法本地预测 Yaw
            SendTo(session, 61, new PlayerInfoData
            {
                Cid = session.CharacterId,
                MaxReliveTime = reliveMs,
                CanReliveTime = reliveMs,
                ThirdModeNoViewChange = false,
                BagGoldWeaponNum = isPve ? 3 : 0,
                NewPlayer = isPve,
                CanUsingNewbieHelp = isPve
            });

            if (isPve)
            {
                SendTo(session, 620, new ChallengeMessageData
                {
                    PveLevelRage = 1000
                });
                SendTo(session, 117, new RpgTipsEventData
                {
                    TypeId = -3011,
                    Show = false
                });
            }

            // 3. StartNewSection (Method 13)
            SendTo(session, 13, new TimeData { Time = sectionMs });
            if (!isPve)
            {
                SendTo(session, 35, new GameMessageData { Type = GameMessageType.GAMESTART });
            }

            session.MarkSpawned();
            OnPlayerSpawned?.Invoke(session);
        }

        private void SendGetRoomInfoAck(ClientSession session)
        {
            bool isPve = ServerConfig.IsPve(_cfg.EffectiveRaceType);
            int total = isPve ? Math.Max(1, Sessions.Capacity) : Math.Max(2, Sessions.Capacity + _cfg.AllyBots + _cfg.EnemyBots);
            string json = JsonSerializer.Serialize(new
            {
                roomId = _cfg.RoomId > 0 ? _cfg.RoomId : (isPve ? 11109969719885L : 1001L),
                limitNumber = total,
                battleType = 3,
                roomName = isPve ? "工业区01" : $"SSJJ离线-{_cfg.Mode}",
                channelName = isPve ? "冒险模式" : "离线战场"
            });
            var proxy = new UnityProxyData
            {
                Type = (UnityProxyType)0,
                Key = "bc8f2078ee5ec726bc4631d4a47d5d2e",
                Func = "onGetRoomInfo"
            };
            proxy.Params.Add(Encoding.UTF8.GetBytes(json));
            SendTo(session, 199, proxy);
        }

        private int ReliveTimeMs => ServerConfig.IsPve(_cfg.EffectiveRaceType) ? 1000
            : ServerConfig.IsExplode(_cfg.EffectiveRaceType) ? 0
            : ServerConfig.IsBiohazard(_cfg.EffectiveRaceType) ? _cfg.Biohazard?.RespawnMs ?? 0 : 3000;

        public int GetConfiguredSectionTimeMs() =>
            ServerConfig.IsBiohazard(_cfg.EffectiveRaceType) && _cfg.Biohazard is { } bio
                ? bio.RoundMs : GetSectionTimeMs(_cfg.EffectiveRaceType);

        public void BroadcastBioGrowth(int level) => SendProtoActive(23, new IntData { Data = level });

        public void BroadcastBioMessage(BioMessageType type, string playerName, string otherName = "") =>
            SendProtoActive(25, new BioMessageData { Type = type, PlayerName = playerName, PlayerName2 = otherName });

        public void SendBioDamage(ClientSession recipient, int value) => SendTo(recipient, 26, new IntData { Data = value });

        public void BroadcastBioLvUp(int lv, int addHp, bool deadLvUp = false) =>
            SendProtoActive(83, new BioLvUpData { Lv = lv, LvUpAddHp = addHp, DeadLvUp = deadLvUp });

        public static int GetSectionTimeMs(int raceType) => raceType switch
        {
            2 => 150_000,   // 爆破每回合 2分30秒
            5 or 12 => 480_000,
            64 or 74 => 480_000,
            10001 => 900_000, // 工业区01 PVE 15分钟
            _ => 600_000    // 团队/刀战 10分钟
        };

        public static int GetWinScore(int raceType) => raceType switch
        {
            2 => 5,   // 爆破抢5回合
            5 => 30,
            15 or 2041 => 40,
            10001 => 4, // 工业区01 PVE 4阶段
            _ => 50
        };

        // =========================================================================
        // 服务端权威战斗 RPC 下发接口
        // =========================================================================

        public void BroadcastPlayerLogin(int id, string name, int team, long charId, bool isBot)
        {
            bool isPve = ServerConfig.IsPve(_cfg.EffectiveRaceType);
            SendProtoActive(9, new PlayerLoginData
            {
                Id = id,
                PlayerName = name,
                Team = team,
                CharacterId = charId,
                IsObserver = false,
                IsBot = isBot,
                Show = isPve ? isBot : !isBot
            });
        }

        public void BroadcastPlayerLogout(int id, string name, int team = 2, bool isBot = true, bool isObserver = false, string heroWeapon = "", string legendWeapon = "")
        {
            var msg = new PlayerLogoutData
            {
                Id = id,
                Name = name ?? "",
                IsObserver = isObserver,
                Team = team,
                IsBot = isBot
            };
            if (!string.IsNullOrEmpty(heroWeapon)) msg.HeroWeapon = heroWeapon;
            if (!string.IsNullOrEmpty(legendWeapon)) msg.LegendWeapon = legendWeapon;
            SendProtoActive(10, msg);
        }

        public void BroadcastPveScore(float aliveMonsters, int winStage, int currentStage)
        {
            SendProtoActive(4, new BroadcastScoreData
            {
                Team2Score = aliveMonsters,
                WinScore = winStage,
                CurrentScore = currentStage
            });
        }

        public void BroadcastPveMessage(int type, int time = 0)
        {
            var msg = new PveMessageData
            {
                Type = (TowerDefenseMessageType)type
            };
            if (time != 0) msg.Time = time;
            SendProtoActive(71, msg);
        }

        public void BroadcastRpgCounterUpdate(int now, int max = 1000, int id = 20320001, string name = "清道夫训练1")
        {
            SendProtoActive(114, new RpgCounterData
            {
                Type = 101,
                Id = id,
                Now = now,
                Max = max,
                Name = name
            });
        }

        public void BroadcastPveExp(int baseExp)
        {
            SendProtoActive(66, new ExpData
            {
                BaseExp = baseExp,
                HeroWeaponAddExp = 2000,
                DecorationAddExp = 90,
                VipAddExpRatio = 60
            });
        }

        public void BroadcastRpgTipsHide(int typeId = -3011)
        {
            SendProtoActive(117, new RpgTipsEventData
            {
                TypeId = typeId,
                Show = false
            });
        }

        public void BroadcastFlashGameClose(string? key = null)
        {
            var closeProxy = new UnityProxyData
            {
                Type = (UnityProxyType)0,
                Key = string.IsNullOrEmpty(key) ? "bc8f2078ee5ec726bc4631d4a47d5d2e" : key,
                Func = "GAME_CLOSE"
            };
            SendProtoFlash(199, closeProxy);
        }

        public void BroadcastHitPlayer()
        {
            SendProtoActive(131, new GameServerSetupData { HitPlayerInfo = true });
        }

        public void SendHitPlayer(ClientSession recipient)
        {
            SendTo(recipient, 131, new GameServerSetupData { HitPlayerInfo = true });
        }

        public void BroadcastGroupBest(GroupBestKillData best)
        {
            SendProtoActive(29, best);
        }

        public void BroadcastLastMvp(LastMvpData mvp)
        {
            SendProtoActive(17, mvp);
        }

        public void NotifyLocalAssist()
        {
            // AssistsnumDataHandler consumes object/empty content, NOT an AssistsnumData contract.
            SendFrameActive(28, Array.Empty<byte>());
        }

        public void NotifyAssist(ClientSession recipient)
        {
            SendEmptyTo(recipient, 28);
        }

        public void BroadcastProgress(ProgressType type, int totalTimeMs, string playerName = "", string detail = "", float speed = 1f, float currentTimeMs = 0f)
        {
            var msg = new ProgressData
            {
                Type = type,
                Time = Math.Max(0, totalTimeMs),
                Speed = speed,
                CurrentTime = Math.Max(0f, currentTimeMs)
            };
            if (!string.IsNullOrEmpty(playerName)) msg.PlayerName = playerName;
            if (!string.IsNullOrEmpty(detail)) msg.Detail = detail;
            SendProtoActive(15, msg);
        }

        public void BroadcastC4Message(C4MessageType type, string playerName, float x = 0f, float y = 0f, float z = 0f)
        {
            SendProtoActive(16, new C4MessageData
            {
                Type = type,
                PlayerName = playerName ?? "",
                X = x,
                Y = y,
                Z = z
            });
        }

        public void BroadcastGameMessage(GameMessageType type, string playerName = "", int time = 0)
        {
            SendProtoActive(35, new GameMessageData
            {
                Type = type,
                PlayerName = playerName ?? "",
                Time = time
            });
        }

        public void BroadcastSprayEvent(SprayEventEntityData spray)
        {
            SendProtoActive(37, new APC
            {
                Id = 17,
                Content = SerializeProto(spray)
            });
        }

        public void BroadcastSprayMessage(SprayMessageType type)
        {
            SendProtoActive(38, new SprayMessageData { Type = type });
        }

        public void BroadcastDamageCount(IEnumerable<DamageData> entries, ClientSession? recipient = null)
        {
            var msg = new DamageCountData();
            foreach (var entry in entries)
            {
                if (entry != null && entry.Damage != 0) msg.List.Add(entry);
            }
            if (msg.List.Count == 0) return;
            if (recipient == null) SendProtoActive(20, msg);
            else SendTo(recipient, 20, msg);
        }

        public void BroadcastTacticsSound(int playerId, string playerName, int soundId, bool isWoman)
        {
            SendProtoActive(22, new TacticsSoundData
            {
                PlayerId = playerId,
                PlayerName = playerName ?? "",
                SoundId = soundId,
                IsWoman = isWoman
            });
        }

        public void BroadcastObserverInfo(ObserverInfoData info)
        {
            SendProtoActive(30, info);
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
            var pings = new PingListData();
            foreach (var p in players)
            {
                pings.List.Add(new PlayerPingData { Id = p.Id, Ping = p.IsBot ? 0 : p.PingMs });
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
                    Score = p.Score,
                    Ping = p.IsBot ? 0 : p.PingMs,
                    AssistsNum = p.Assists
                });
            }
            SendProtoActive(8, all);
            SendProtoActive(24, pings);
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
            if (!ServerConfig.IsPve(_cfg.EffectiveRaceType))
            {
                BroadcastGameMessage(GameMessageType.GAMESTART);
            }
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

        public void BroadcastWeaponMaster(IList<bool> states, int targetPlayerId = 0)
        {
            var msg = new MessageListData();
            foreach (var b in states) msg.BoolList.Add(b);
            if (targetPlayerId > 0)
            {
                var session = Sessions.Snapshot().FirstOrDefault(s => s.IsSpawned && s.PlayerId == targetPlayerId);
                if (session != null) SendTo(session, 120, msg);
                return;
            }
            SendProtoActive(120, msg);
        }

        public void BroadcastBigHeadProgress(int lv, int progress, int targetPlayerId = 0)
        {
            var msg = new BigHeadProgressData { Lv = lv, Progress = progress };
            if (targetPlayerId > 0)
            {
                var session = Sessions.Snapshot().FirstOrDefault(s => s.IsSpawned && s.PlayerId == targetPlayerId);
                if (session != null) SendTo(session, 64, msg);
                return;
            }
            SendProtoActive(64, msg);
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
            {
                if (ServerConfig.IsPve(_cfg.EffectiveRaceType))
                {
                    SendFrameActive(18, Array.Empty<byte>());
                    BroadcastFlashGameClose();
                }
                else
                {
                    SendProtoActive(18, new StringData { Data = winnerName ?? "" });
                }
            }
            else
            {
                SendFrameActive(19, Array.Empty<byte>());
            }
        }

        public void SendMissionResult(ClientSession recipient, bool win, string winnerName)
        {
            if (win)
            {
                if (ServerConfig.IsPve(_cfg.EffectiveRaceType))
                {
                    SendEmptyTo(recipient, 18);
                    BroadcastFlashGameClose();
                }
                else
                {
                    SendTo(recipient, 18, new StringData { Data = winnerName ?? "" });
                }
            }
            else
            {
                SendEmptyTo(recipient, 19);
            }
        }

        public void BroadcastWin()
        {
            SendFrameActive(5, Array.Empty<byte>());
        }

        private void SendProtoFlash<T>(int mid, T message)
        {
            byte[] frame = BuildFrame(mid, SerializeProto(message));
            lock (_flashLock)
            {
                if (_flashProxyStream == null) return;
                try
                {
                    _flashProxyStream.Write(frame, 0, frame.Length);
                    _flashProxyStream.Flush();
                }
                catch { }
            }
        }

        private void SendProtoActive<T>(int mid, T message)
        {
            byte[] body = SerializeProto(message);
            SendFrameActive(mid, body);
        }

        private void SendFrameActive(int mid, byte[] body)
        {
            byte[] frame = BuildFrame(mid, body);
            foreach (var session in Sessions.Snapshot())
            {
                if (session.IsSpawned) session.Send(frame);
            }
        }

        public void SendTo<T>(ClientSession session, int method, T message) =>
            session.Send(BuildFrame(method, SerializeProto(message)));

        public void SendEmptyTo(ClientSession session, int method) =>
            session.Send(BuildFrame(method, Array.Empty<byte>()));

        private static byte[] BuildFrame(int mid, byte[] body)
        {
            var apc = new APC { Id = mid };
            if (body != null && body.Length > 0)
            {
                apc.Content = body;
            }
            byte[] apcBytes = SerializeProto(apc);
            var frame = new byte[4 + apcBytes.Length];
            System.Buffers.Binary.BinaryPrimitives.WriteInt32BigEndian(frame, apcBytes.Length);
            apcBytes.CopyTo(frame, 4);
            return frame;
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
            foreach (var session in Sessions.Snapshot()) session.Close();
        }
    }
}
