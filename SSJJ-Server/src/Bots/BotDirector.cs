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

                string career = ffa ? (botIdx % 2 == 0 ? "police" : _cfg.BotCareer)
                    : (team == 1 ? _cfg.Career : _cfg.BotCareer);
                if (string.IsNullOrWhiteSpace(career)) career = team == 1 ? "police" : "pandora_t";

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
                    isMeleeOnly: meleeOnly);

                _officialPhysics.RegisterEntity(id, team, career, true, x, y, z);
                _agents.Add(agent);
            }

            if (ffa)
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

        public void Tick(float dt, List<PlayerBasicInfo> allEntities, bool allowRespawn, float[]? objectivePoint = null)
        {
            for (int i = 0; i < _agents.Count; i++)
            {
                _agents[i].Tick(dt, allEntities, allowRespawn, objectivePoint);
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
