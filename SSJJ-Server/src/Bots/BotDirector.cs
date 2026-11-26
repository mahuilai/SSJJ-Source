using System;
using System.Collections.Generic;
using SSJJ.Server.Config;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.Bots
{
    /// <summary>
    /// 服务端人机导演系统：按 ServerConfig 与真实 BSP 出生点生成友方/敌方或个人竞技 Bot
    /// </summary>
    public sealed class BotDirector
    {
        public const int FirstBotId = 200;

        private readonly List<BotAgent> _agents = new List<BotAgent>();
        private readonly ServerConfig _cfg;
        private readonly GameTables _tables;
        private readonly BspMapData _bsp;
        private readonly OfficialPhysicsWorld _officialPhysics;
        private readonly BspNavGraph _navGraph = new BspNavGraph();
        private readonly Random _rng;

        public BotDirector(ServerConfig cfg, GameTables tables, BspMapData bsp, OfficialPhysicsWorld officialPhysics)
        {
            _cfg = cfg;
            _tables = tables;
            _bsp = bsp;
            _officialPhysics = officialPhysics;
            _rng = new Random(cfg.Seed);
            _navGraph.Build(bsp, officialPhysics);
        }

        public BspNavGraph NavGraph => _navGraph;

        public IReadOnlyList<BotAgent> Agents => _agents;

        public void SpawnAll()
        {
            _agents.Clear();
            int raceType = _cfg.EffectiveRaceType;
            bool ffa = ServerConfig.IsFreeForAll(raceType);
            bool meleeOnly = ServerConfig.IsMeleeOnly(raceType);

            var activeBag = _cfg.Bags[Math.Clamp(_cfg.ActiveBag - 1, 0, _cfg.Bags.Count - 1)];
            string meleeWpn = string.IsNullOrWhiteSpace(activeBag.Melee) ? "dagger" : activeBag.Melee;

            int botIdx = 0;

            void AddBot(int team, string label, int num)
            {
                int id = FirstBotId + botIdx++;
                var sp = _bsp.PickSpawn(team, num, ffa);
                float jitterX = ((botIdx % 3) - 1) * 55f;
                float jitterY = ((botIdx / 3) % 2 == 0 ? 1 : -1) * 35f;
                float x = sp.X + jitterX;
                float y = sp.Y + jitterY;
                float z = sp.Z;
                if (_officialPhysics.IsReady && _officialPhysics.SampleGround(x, y, z, out float gz))
                {
                    z = gz + 2f;
                }

                string allyCareer = ResolveSafeBotCareer(_cfg.Career, team);
                string enemyCareer = ResolveSafeBotCareer(_cfg.BotCareer, team);
                string career = ffa ? (botIdx % 2 == 0 ? allyCareer : enemyCareer)
                    : (team == _cfg.PlayerTeam ? allyCareer : enemyCareer);

                string weapon = meleeOnly ? meleeWpn
                    : (raceType == 74 ? "dagger" : (num % 3 == 0 ? "ak47" : "m4a1"));

                var agent = new BotAgent(
                    id: id,
                    team: team,
                    name: label,
                    career: career,
                    weapon: weapon,
                    weaponSkin: "",
                    x: x,
                    y: y,
                    z: z,
                    yaw: sp.Yaw,
                    tables: _tables,
                    officialPhysics: _officialPhysics,
                    navGraph: _navGraph,
                    freeForAll: ffa,
                    isMeleeOnly: meleeOnly,
                    quality: _cfg.BotDifficulty == "hard" ? 3 : (_cfg.BotDifficulty == "easy" ? 0 : 1),
                    difficulty: _cfg.BotDifficulty);

                _officialPhysics.RegisterEntity(id, team, career, true, x, y, z);
                _agents.Add(agent);
            }

            if (ServerConfig.IsPve(raceType))
            {
                int count = Math.Max(1, _cfg.EnemyBots);
                for (int i = 0; i < count; i++)
                {
                    int id = FirstBotId + botIdx++;
                    var sp = _bsp.PickSpawn(2, i, false);
                    float x = sp.X, y = sp.Y, z = sp.Z;
                    if (_officialPhysics.IsReady && _officialPhysics.SampleGround(x, y, z, out float gz))
                    {
                        z = gz + 2f;
                    }
                    GetPveMonsterProfile(1, i, out string mName, out string mCareer, out int mHp);
                    var agent = new BotAgent(
                        id: id,
                        team: 2,
                        name: mName,
                        career: mCareer,
                        weapon: "botweapon",
                        weaponSkin: "",
                        x: x,
                        y: y,
                        z: z,
                        yaw: sp.Yaw,
                        tables: _tables,
                        officialPhysics: _officialPhysics,
                        navGraph: _navGraph,
                        freeForAll: false,
                        isMeleeOnly: true);
                    agent.Snap.Hp = mHp;
                    agent.Snap.MaxHp = mHp;
                    _officialPhysics.RegisterEntity(id, 2, mCareer, true, x, y, z);
                    _agents.Add(agent);
                }
            }
            else if (ffa)
            {
                int totalBots = Math.Max(0, _cfg.AllyBots + _cfg.EnemyBots);
                for (int i = 0; i < totalBots; i++)
                {
                    // 个人竞技给每个 Bot 分配唯一 Team ID >= 10，便于客户端差异化阵营判断
                    AddBot(10 + i, $"战友AI_{i + 1}", i + 1);
                }
            }
            else
            {
                for (int i = 0; i < _cfg.AllyBots; i++)
                {
                    AddBot(_cfg.PlayerTeam, $"友方AI_{i + 1}", i + 1);
                }
                int enemyTeam = _cfg.PlayerTeam == 1 ? 2 : 1;
                for (int i = 0; i < _cfg.EnemyBots; i++)
                {
                    AddBot(enemyTeam, $"敌方AI_{i + 1}", i);
                }
            }

            Console.WriteLine($"[SSJJ-Server][BOT-DIRECTOR] Spawned {_agents.Count} bots (ally={_cfg.AllyBots}, enemy={_cfg.EnemyBots}, raceType={raceType}, map={_cfg.MapId})");
        }

        public void Tick(float dt, List<PlayerBasicInfo> allEntities, bool allowRespawn, float[]? objectivePoint = null, int serverTimeMs = 0, bool isBiohazardMode = false)
        {
            for (int i = 0; i < _agents.Count; i++)
            {
                _agents[i].Tick(dt, allEntities, allowRespawn, objectivePoint, serverTimeMs, isBiohazardMode);
            }
        }

        public void RespawnAll()
        {
            int raceType = _cfg.EffectiveRaceType;
            bool ffa = ServerConfig.IsFreeForAll(raceType);
            for (int i = 0; i < _agents.Count; i++)
            {
                var a = _agents[i];
                var sp = _bsp.PickSpawn(a.Team, i, ffa);
                float x = sp.X + ((i % 3) - 1) * 55f;
                float y = sp.Y;
                float z = sp.Z;
                if (_officialPhysics.IsReady && _officialPhysics.SampleGround(x, y, z, out float gz))
                {
                    z = gz + 2f;
                }
                a.Respawn(x, y, z, sp.Yaw);
            }
        }

        public void SpawnPveStageWave(int stage)
        {
            int baseIdx = Math.Max(0, (stage - 1) * 4);
            for (int i = 0; i < _agents.Count; i++)
            {
                var a = _agents[i];
                var sp = _bsp.PickSpawn(2, baseIdx + i, false);
                float x = sp.X, y = sp.Y, z = sp.Z;
                if (_officialPhysics.IsReady && _officialPhysics.SampleGround(x, y, z, out float gz))
                {
                    z = gz + 2f;
                }
                GetPveMonsterProfile(stage, i, out string mName, out string mCareer, out int mHp);
                a.Snap.PlayerName = mName;
                a.Snap.Career = mCareer;
                a.Snap.MaxHp = mHp;
                a.Respawn(x, y, z, sp.Yaw);
                a.Snap.Hp = mHp;
                a.Snap.MaxHp = mHp;
                a.Snap.CurrentWeaponName = "botweapon";
            }
        }

        public static void GetPveMonsterProfile(int stage, int slotIndex, out string name, out string career, out int hp)
        {
            int idx = Math.Abs(slotIndex) % 4;
            if (stage >= 4)
            {
                if (idx == 0)
                {
                    name = "雷霆加特林";
                    career = "boss1001";
                    hp = 800;
                }
                else
                {
                    name = "变异工人";
                    career = "rpg_minion_builder";
                    hp = 61;
                }
                return;
            }
            if (stage == 3)
            {
                if (idx % 2 == 0) { name = "变异工人"; career = "rpg_minion_builder"; hp = 61; }
                else { name = "变异佣兵"; career = "mercenary"; hp = 76; }
                return;
            }
            if (stage == 2)
            {
                switch (idx)
                {
                    case 0: name = "变异工人"; career = "rpg_minion_builder"; hp = 61; break;
                    case 1: name = "变异保安"; career = "rpg_minion_guard"; hp = 61; break;
                    case 2: name = "变异工程师"; career = "researcher_1"; hp = 61; break;
                    default: name = "变异佣兵"; career = "mercenary"; hp = 76; break;
                }
                return;
            }
            // Stage 1
            switch (idx)
            {
                case 0: name = "变异保安"; career = "rpg_minion_guard"; hp = 61; break;
                case 1: name = "变异工程师"; career = "researcher_1"; hp = 61; break;
                case 2: name = "变异保安"; career = "rpg_minion_guard"; hp = 61; break;
                default: name = "变异佣兵"; career = "mercenary"; hp = 76; break;
            }
        }

        private static string ResolveSafeBotCareer(string? career, int team)
        {
            if (string.IsNullOrWhiteSpace(career)) return team == 1 ? "police" : "pandora_t";
            string trimmed = career.Trim();
            // ct_knight1_2 is a melee transformation form without third-person gun anims; map to base ct_knight1 (uses fixed playeranim/woman).
            if (trimmed.Equals("ct_knight1_2", StringComparison.OrdinalIgnoreCase))
            {
                return "ct_knight1";
            }
            // Bare "pandora" / "woman" have no standalone player/ bundle; map to real team/female bundles (fixed playeranim/woman in gateway).
            if (trimmed.Equals("pandora", StringComparison.OrdinalIgnoreCase))
            {
                return team == 1 ? "pandora_t" : "pandora_ct";
            }
            if (trimmed.Equals("woman", StringComparison.OrdinalIgnoreCase))
            {
                return "feihuwoman";
            }
            return trimmed;
        }

        public BotAgent? FindBot(int id)
        {
            for (int i = 0; i < _agents.Count; i++)
            {
                if (_agents[i].Id == id) return _agents[i];
            }
            return null;
        }
    }
}
