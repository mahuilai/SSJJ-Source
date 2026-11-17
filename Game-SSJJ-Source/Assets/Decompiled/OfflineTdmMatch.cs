using System;
using System.Collections.Generic;
using Assets.Sources.Systems.PacketHandle.Handlers;
using Assets.Sources.Utils;
using NetData;
using UnityEngine;

/// <summary>
/// [OFFLINE-TDM] 离线人机团战比赛核心：队伍比分 / 回合计时 / 复活倒计时 / 胜负结算 / 自动重开。
///
/// 不自己画 HUD，全部写回原版 Entitas 组件：
///   gameRule.broadcastScore  -> TeamScoreModel（队伍比分、WinScore）
///   battleRoom.sectionTime   -> TeamScoreModel（计时）；SectionTimeSystem 仍会按 Unix 时间刷新
///   battleRoom.gameOver      -> CommonGameOverModel（胜负图 + 音效，由 Mission*Handler 驱动）
///   battleRoom.roomData      -> ReLiveTime 供 PlayerRebornModel 显示复活 CD
///   OfflineKillChain         -> method 6/8 击杀播报与 Tab 计分板
///
/// 集成约定：
///   - OfflineGameplay.Update 每帧调用 OfflineTdmMatch.Tick()；
///   - 玩家死亡调用 OnPlayerDeath()，复活调用 OnPlayerRespawn()；
///   - 任意实体死亡调用 ReportKill()（只计分，不重复发播报）；
///   - 伤害入口用 IsProtected() 过滤出生保护；
///   - 重开依赖 OfflineGameplay.ResetForMatch()（由玩法接入任务提供）。
/// </summary>
public static class OfflineTdmMatch
{
    public const int DefaultScoreLimit = 50;
    public const int DefaultRoundSeconds = 600;
    public const int RespawnDelayMs = 5000;
    public const int SpawnProtectMs = 3000;

    private const int OvertimeSeconds = 60;
    private const int AutoRestartDelaySeconds = 12;
    private const float HudSyncInterval = 0.25f;

    private static OfflineGameplay _gameplay;
    private static bool _initialized;
    private static bool _active;
    private static bool _teamMode;
    private static int _raceType = 3;
    private static int _playerTeam = 1;

    private static int _team1Score;
    private static int _team2Score;
    private static float _remainingSeconds = DefaultRoundSeconds;
    private static bool _overtime;
    private static bool _roundOver;
    private static int _winnerTeam;
    private static string _resultText = string.Empty;

    private static bool _playerDead;
    private static float _respawnAt;
    private static int _playerRespawnRemainMs;

    private static float _restartAt;
    private static float _nextHudSync;

    private static readonly Dictionary<int, float> _protectedUntil = new Dictionary<int, float>();
    private static readonly HashSet<string> _errorOnce = new HashSet<string>();

    // ---------------- 只读状态 ----------------

    public static bool Active { get { return _active; } }
    public static bool TeamMode { get { return _teamMode; } }
    public static int PlayerTeam { get { return _playerTeam; } }
    public static int Team1Score { get { return _team1Score; } }
    public static int Team2Score { get { return _team2Score; } }
    public static int ScoreLimit { get { return DefaultScoreLimit; } }
    public static int RoundSeconds { get { return DefaultRoundSeconds; } }

    public static float RemainingSeconds
    {
        get { return _remainingSeconds > 0f ? _remainingSeconds : 0f; }
    }

    public static bool RoundOver { get { return _roundOver; } }
    public static bool PlayerDead { get { return _playerDead; } }
    public static int PlayerRespawnRemainMs { get { return _playerRespawnRemainMs; } }
    public static int WinnerTeam { get { return _winnerTeam; } }
    public static string ResultText { get { return _resultText; } }

    public static string StatusLine
    {
        get
        {
            if (!_active) return "TDM 未启用";
            if (_roundOver)
            {
                return "比赛结束  " + _team1Score + " : " + _team2Score + "  " + _resultText;
            }

            int remain = Mathf.CeilToInt(RemainingSeconds);
            string clock = (remain / 60).ToString("00") + ":" + (remain % 60).ToString("00");
            string tail = _overtime
                ? " 加时 " + clock + " 下一分决胜"
                : " 剩余 " + clock + " 先到 " + DefaultScoreLimit + " 分";
            string dead = _playerDead
                ? " 复活 " + Mathf.CeilToInt(_playerRespawnRemainMs / 1000f) + "s"
                : string.Empty;
            return "比分 " + _team1Score + " : " + _team2Score + tail + dead;
        }
    }

    // ---------------- 初始化 ----------------

    /// <summary>幂等初始化；同一 OfflineGameplay 重复调用直接返回。</summary>
    public static void Initialize(OfflineGameplay gameplay)
    {
        try
        {
            if (_initialized && (gameplay == null || object.ReferenceEquals(_gameplay, gameplay))) return;

            _gameplay = gameplay != null ? gameplay : OfflineGameplay.Instance;
            _protectedUntil.Clear();

            int raceType = ResolveRaceType();
            _raceType = raceType;
            _teamMode = IsTeamRaceType(raceType);
            _active = _teamMode;
            _playerTeam = 1;
            ResetRuntimeState();

            if (!_teamMode)
            {
                // [OFFLINE-KILLCHAIN] 即使是个人竞技/非团队模式，也要在 UI 订阅前把
                // gameRule.killPlayerInfo / battleRoom.playerInfo 建好；否则
                // KillMessageModel.DoSubscribe 读实体时抛 NRE，通知 22 永远注册不上，
                // 之后首杀再 Ensure 已经来不及（Reinvoke 全仓无调用）。
                OfflineKillChain.Ensure();
                string mode = OfflineGameSetting.IsFreeForAll(raceType) ? "ffa" : "inactive";
                _initialized = true;
                Debug.Log("[OFFLINE-TDM] init raceType=" + raceType + " mode=" + mode
                    + " scoreLimit=0 round=0s bots=0");
                return;
            }

            EnsureBattleComponents();
            PushScoresToHud();
            SyncSectionTime(true);
            OfflineKillChain.Ensure();
            OfflineKillChain.RebuildBoard();

            _initialized = true;
            Debug.Log("[OFFLINE-TDM] init raceType=" + raceType + " mode=team"
                + " scoreLimit=" + DefaultScoreLimit
                + " round=" + DefaultRoundSeconds + "s"
                + " bots=" + CountBots(raceType));
        }
        catch (Exception e)
        {
            LogError("init", e);
        }
    }

    // ---------------- 每帧驱动 ----------------

    public static void Tick()
    {
        if (!_active) return;
        try
        {
            if (_roundOver)
            {
                // 结束后冻结原版计时显示，12 秒后自动开下一局。
                if (Time.time >= _nextHudSync)
                {
                    _nextHudSync = Time.time + HudSyncInterval;
                    SyncSectionTime(false);
                }
                if (_restartAt > 0f && Time.time >= _restartAt) RestartMatch();
                return;
            }

            float dt = Time.deltaTime;
            if (dt > 0f)
            {
                _remainingSeconds -= dt;
                if (_remainingSeconds <= 0f)
                {
                    _remainingSeconds = 0f;
                    HandleTimeUp();
                    if (_roundOver) return;
                }
            }

            if (_playerDead) TickPlayerRespawn();

            if (Time.time >= _nextHudSync)
            {
                _nextHudSync = Time.time + HudSyncInterval;
                SyncSectionTime(false);
            }
        }
        catch (Exception e)
        {
            LogError("tick", e);
        }
    }

    // ---------------- 击杀计分 ----------------

    /// <summary>
    /// 任意实体死亡后调用。OfflineGameplay 已负责 method 6 播报（PushPlayerKill/PushBotKill），
    /// 这里只累计队伍分并刷新 broadcastScore / 计分板。
    /// </summary>
    public static void ReportKill(int killerId, int killerTeam, int victimId, int victimTeam, bool headshot)
    {
        if (!_active || _roundOver) return;
        try
        {
            int scorer;
            if (killerTeam == 1)
            {
                _team1Score++;
                scorer = 1;
            }
            else if (killerTeam == 2)
            {
                _team2Score++;
                scorer = 2;
            }
            else
            {
                Debug.Log("[OFFLINE-TDM] kill ignored killer=" + killerId + " team=" + killerTeam);
                return;
            }

            PushScoresToHud();
            OfflineKillChain.RebuildBoard();

            Debug.Log("[OFFLINE-TDM] kill " + killerId + "(" + killerTeam + ") -> "
                + victimId + "(" + victimTeam + ") hs=" + headshot
                + " score=" + _team1Score + ":" + _team2Score);

            if (_overtime)
            {
                // 加时赛先得分者胜（无论赛前分差）。
                EndMatch(scorer, "overtime-score");
            }
            else if (_team1Score >= DefaultScoreLimit || _team2Score >= DefaultScoreLimit)
            {
                EndMatch(scorer, "score");
            }
        }
        catch (Exception e)
        {
            LogError("reportKill", e);
        }
    }

    // ---------------- 玩家死亡 / 复活 ----------------

    /// <summary>玩家死亡时由 OfflineGameplay 调用；真正的复活在 Tick 倒计时结束后执行。</summary>
    public static void OnPlayerDeath(int killerId, int killerTeam)
    {
        if (!_active || _roundOver || _playerDead) return;
        try
        {
            _playerDead = true;
            _respawnAt = Time.time + RespawnDelayMs / 1000f;
            _playerRespawnRemainMs = RespawnDelayMs;

            PlayerEntityData me = SelfData();
            if (me != null)
            {
                me.IsDead = true;
                me.Hp = 0f;
                me.DeadTimer = RespawnDelayMs;
            }

            ApplyRespawnDelayToRoom();

            Debug.Log("[OFFLINE-TDM] player dead killer=" + killerId + " team=" + killerTeam
                + " respawnIn=" + (RespawnDelayMs / 1000) + "s");
        }
        catch (Exception e)
        {
            LogError("playerDeath", e);
        }
    }

    /// <summary>复活完成后调用（由 Tick 在 RespawnPlayer 之后调用）。</summary>
    public static void OnPlayerRespawn()
    {
        try
        {
            _playerDead = false;
            _respawnAt = 0f;
            _playerRespawnRemainMs = 0;

            int selfId = 0;
            var ctx = Contexts.sharedInstance;
            if (ctx != null && ctx.snapshot.hasSnapshots)
            {
                var snap = ctx.snapshot.snapshots.LatestSnapshot;
                if (snap != null)
                {
                    selfId = snap.Self;
                    PlayerEntityData me;
                    if (snap.PlayerEntityDataDict != null
                        && snap.PlayerEntityDataDict.TryGetValue(selfId, out me) && me != null)
                    {
                        me.IsDead = false;
                        me.DeadTimer = 0;
                        if (me.Hp <= 0f) me.Hp = me.MaxHp > 0f ? me.MaxHp : 100f;
                    }
                }
            }

            MarkSpawnProtected(selfId);
            OfflineKillChain.RebuildBoard();

            Debug.Log("[OFFLINE-TDM] player respawn protect=" + SpawnProtectMs + "ms");
        }
        catch (Exception e)
        {
            LogError("playerRespawn", e);
        }
    }

    /// <summary>出生保护（毫秒），由 OfflineGameplay.DamagePlayer/DamageBot 查询。</summary>
    public static void MarkSpawnProtected(int playerId)
    {
        if (playerId <= 0) return;
        try
        {
            _protectedUntil[playerId] = Time.time + SpawnProtectMs / 1000f;
        }
        catch (Exception e)
        {
            LogError("markProtected", e);
        }
    }

    public static bool IsProtected(int playerId)
    {
        if (playerId <= 0) return false;
        try
        {
            float until;
            if (!_protectedUntil.TryGetValue(playerId, out until)) return false;
            if (Time.time < until) return true;
            _protectedUntil.Remove(playerId);
            return false;
        }
        catch (Exception e)
        {
            LogError("isProtected", e);
            return false;
        }
    }

    // ---------------- 重开 / 强制结束 ----------------

    public static void RestartMatch()
    {
        if (!_active) return;
        try
        {
            OfflineGameplay gp = Gameplay();
            ResetRuntimeState();
            _protectedUntil.Clear();

            var ctx = Contexts.sharedInstance;
            if (ctx != null)
            {
                var br = ctx.battleRoom;
                if (br == null) return;
                if (!br.hasGameOver)
                {
                    br.SetGameOver(false, false, false, string.Empty, false, null, false, null);
                }
                br.gameOver.IsGameOver = false;
                br.gameOver.IsGameOverDataChange = true;
                br.gameOver.IsWin = false;
                br.gameOver.WinnerName = string.Empty;
                br.gameOver.IsJumpGameOver = false;

                var gr = ctx.gameRule;
                if (gr != null && gr.hasBroadcastScore)
                {
                    gr.broadcastScore.Team1Score = 0f;
                    gr.broadcastScore.Team2Score = 0f;
                    gr.broadcastScore.CurrentScore = 0;
                    gr.broadcastScore.WinScore = DefaultScoreLimit;
                    gr.broadcastScore.Team1Kill = 0L;
                    gr.broadcastScore.Team2Kill = 0L;
                }
            }

            ApplyRoomDefaults();

            if (gp != null)
            {
                gp.RoundOver = false;
                gp.RoundResult = string.Empty;
                try
                {
                    // 由 OfflineGameplay 玩法接入任务提供：清空本局计数、复活玩家、重置 Bot 状态。
                    gp.ResetForMatch();
                }
                catch (Exception e)
                {
                    LogError("ResetForMatch", e);
                }
            }

            SyncSectionTime(true);
            PushScoresToHud();
            OfflineKillChain.Ensure();
            OfflineKillChain.RebuildBoard();

            Debug.Log("[OFFLINE-TDM] restart score=0:0 round=" + DefaultRoundSeconds + "s"
                + " limit=" + DefaultScoreLimit);
        }
        catch (Exception e)
        {
            LogError("restart", e);
        }
    }

    /// <summary>调试用：立即结束比赛。winnerTeam 1/2 为队伍，其他值按平局处理。</summary>
    public static void ForceEnd(int winnerTeam, string reason)
    {
        if (!_active) return;
        if (_roundOver) return;
        try
        {
            string why = string.IsNullOrEmpty(reason) ? "force" : reason;
            if (winnerTeam == 1 || winnerTeam == 2) EndMatch(winnerTeam, why);
            else EndTie(why);
        }
        catch (Exception e)
        {
            LogError("forceEnd", e);
        }
    }

    // ---------------- 内部：计时 / 结算 ----------------

    private static void HandleTimeUp()
    {
        if (_overtime)
        {
            if (_team1Score > _team2Score) EndMatch(1, "overtime-time");
            else if (_team2Score > _team1Score) EndMatch(2, "overtime-time");
            else EndTie("overtime-tie");
            return;
        }

        if (_team1Score > _team2Score)
        {
            EndMatch(1, "time");
            return;
        }
        if (_team2Score > _team1Score)
        {
            EndMatch(2, "time");
            return;
        }

        // 常规时间打平：进入 60 秒加时，先得分者胜。
        _overtime = true;
        _remainingSeconds = OvertimeSeconds;
        SyncSectionTime(true);
        Debug.Log("[OFFLINE-TDM] overtime score=" + _team1Score + ":" + _team2Score
            + " +" + OvertimeSeconds + "s");
    }

    private static void EndMatch(int winnerTeam, string reason)
    {
        if (_roundOver) return;
        _roundOver = true;
        _winnerTeam = winnerTeam;
        bool playerWin = winnerTeam == _playerTeam;
        _resultText = playerWin ? "胜利" : "失败";
        _restartAt = Time.time + AutoRestartDelaySeconds;

        OfflineGameplay gp = Gameplay();
        if (gp != null)
        {
            gp.RoundOver = true;
            gp.RoundResult = _resultText;
        }

        var ctx = Contexts.sharedInstance;
        if (ctx != null)
        {
            var br = ctx.battleRoom;
            if (br != null)
            {
                if (!br.hasGameOver)
                {
                    br.SetGameOver(false, false, false, string.Empty, false, null, false, null);
                }

                var go = br.gameOver;
                go.WinnerName = TeamName(winnerTeam);
                go.IsJumpGameOver = false;

                try
                {
                    // 走原版胜负链：CommonGameOverModel 显示 WIN/LOSE 并播放 AutoSound。
                    if (playerWin) new MissionSuccessDataHandler(ctx).Handle(null);
                    else new MissionFailedDataHandler(ctx).Handle(null);
                }
                catch (Exception e)
                {
                    LogError("missionHandler", e);
                }

                // handler 中途异常时兜底，保证 UI 仍能弹出。
                go.IsWin = playerWin;
                go.IsGameOver = true;
                go.IsGameOverDataChange = true;
            }
        }

        PushScoresToHud();
        Debug.Log("[OFFLINE-TDM] end winner=" + winnerTeam + "(" + TeamName(winnerTeam) + ")"
            + " reason=" + reason + " result=" + _resultText
            + " score=" + _team1Score + ":" + _team2Score);
    }

    private static void EndTie(string reason)
    {
        if (_roundOver) return;
        _roundOver = true;
        _winnerTeam = 0;
        _resultText = "平局";
        _restartAt = Time.time + AutoRestartDelaySeconds;

        OfflineGameplay gp = Gameplay();
        if (gp != null)
        {
            gp.RoundOver = true;
            gp.RoundResult = _resultText;
        }

        var ctx = Contexts.sharedInstance;
        if (ctx != null)
        {
            var br = ctx.battleRoom;
            if (br != null)
            {
                if (!br.hasGameOver)
                {
                    br.SetGameOver(false, false, false, string.Empty, false, null, false, null);
                }
                var go = br.gameOver;
                // 平局不调用 MissionSuccess/MissionFailed，避免误播胜负音效。
                go.IsWin = false;
                go.IsGameOver = true;
                go.IsGameOverDataChange = true;
                go.WinnerName = string.Empty;
                go.IsJumpGameOver = false;
            }
        }

        PushScoresToHud();
        Debug.Log("[OFFLINE-TDM] end tie reason=" + reason
            + " score=" + _team1Score + ":" + _team2Score);
    }

    private static void TickPlayerRespawn()
    {
        float left = _respawnAt - Time.time;
        _playerRespawnRemainMs = left > 0f ? Mathf.CeilToInt(left * 1000f) : 0;
        if (left > 0f) return;

        OfflineGameplay gp = Gameplay();
        if (gp != null) gp.RespawnPlayer();
        OnPlayerRespawn();
    }

    // ---------------- 内部：组件同步 ----------------

    private static void EnsureBattleComponents()
    {
        var ctx = Contexts.sharedInstance;
        if (ctx == null) return;

        var gr = ctx.gameRule;
        if (gr != null && !gr.hasBroadcastScore)
        {
            gr.CreateEntity().AddBroadcastScore(0f, 0f, 0, DefaultScoreLimit, 0L, 0L);
        }

        var br = ctx.battleRoom;
        if (br == null) return;

        ApplyRoomDefaults();

        if (!br.hasSectionTime)
        {
            long now = TimeUtility.UnixTimeNow();
            br.SetSectionTime(DefaultRoundSeconds * 1000, now, 0, now,
                DefaultRoundSeconds, 0, 0);
        }

        if (!br.hasGameOver)
        {
            br.SetGameOver(false, false, false, string.Empty, false, null, false, null);
        }
        else
        {
            br.gameOver.IsGameOver = false;
            br.gameOver.IsGameOverDataChange = false;
            br.gameOver.IsWin = false;
            br.gameOver.WinnerName = string.Empty;
            br.gameOver.IsJumpGameOver = false;
        }
    }

    private static void ApplyRoomDefaults()
    {
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null) return;
            var br = ctx.battleRoom;
            if (br == null || !br.hasRoomData)
            {
                Debug.LogWarning("[OFFLINE-TDM] roomData missing, WinScore/SectionTime not applied");
                return;
            }

            var rd = br.roomData;
            if (rd == null) return;
            if (rd.Data == null)
            {
                rd.Data = new RoomData();
                rd.Data.RaceType = _raceType;
                try
                {
                    if (OfflineGameController.setting != null)
                        rd.Data.SceneId = OfflineGameController.setting.SceneId;
                }
                catch (Exception) { }
            }
            // 离线控制器正常会先填 RaceType；这里只补空值，避免模式 UI 读到 0。
            if (rd.Data.RaceType <= 0) rd.Data.RaceType = _raceType;

            rd.Data.WinScore = DefaultScoreLimit;
            rd.Data.WinCondition = 0;
            rd.Data.SectionTime = DefaultRoundSeconds * 1000;
            rd.Data.ReLiveTime = RespawnDelayMs;
            rd.ReLiveTime = RespawnDelayMs;
        }
        catch (Exception e)
        {
            LogError("roomData", e);
        }
    }

    private static void ApplyRespawnDelayToRoom()
    {
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null) return;
            var br = ctx.battleRoom;
            if (br == null || !br.hasRoomData) return;
            br.roomData.ReLiveTime = RespawnDelayMs;
            if (br.roomData.Data != null) br.roomData.Data.ReLiveTime = RespawnDelayMs;
        }
        catch (Exception e)
        {
            LogError("reLiveTime", e);
        }
    }

    private static void PushScoresToHud()
    {
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null) return;

            var gr = ctx.gameRule;
            if (gr != null && gr.hasBroadcastScore)
            {
                var bs = gr.broadcastScore;
                bs.Team1Score = (float)_team1Score;
                bs.Team2Score = (float)_team2Score;
                bs.CurrentScore = _team1Score + _team2Score;
                bs.WinScore = DefaultScoreLimit;
                bs.Team1Kill = (long)_team1Score;
                bs.Team2Kill = (long)_team2Score;
            }

            var br = ctx.battleRoom;
            if (br != null && br.hasRoomData && br.roomData.Data != null)
            {
                br.roomData.Data.WinScore = DefaultScoreLimit;
                br.roomData.Data.WinCondition = 0;
            }
        }
        catch (Exception e)
        {
            LogError("pushScores", e);
        }
    }

    /// <summary>
    /// 把自有倒计时写回原版 sectionTime。用 SectionStartTimeClient 反推，使 SectionTimeSystem
    /// 下一帧按 Unix 时间重算时得到的剩余时间与 _remainingSeconds 一致（暂停时也不会跳）。
    /// </summary>
    private static void SyncSectionTime(bool resetLoadingTime)
    {
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null) return;
            var br = ctx.battleRoom;
            if (br == null || !br.hasSectionTime) return;

            int totalMs = (_overtime ? OvertimeSeconds : DefaultRoundSeconds) * 1000;
            int remainMs = Mathf.Max(0, Mathf.RoundToInt(_remainingSeconds * 1000f));
            if (remainMs > totalMs) remainMs = totalMs;
            int passedMs = totalMs - remainMs;

            var st = br.sectionTime;
            st.SectionTime = remainMs;
            st.Passed = passedMs;
            st.Minutes = remainMs / 60000;
            st.Seconds = (remainMs / 1000) % 60;
            st.CannotMoveTime = 0;
            st.SectionStartTimeClient = TimeUtility.UnixTimeNow() - passedMs;
            if (resetLoadingTime) st.LoadingSuccessTime = TimeUtility.UnixTimeNow();

            if (br.hasRoomData && br.roomData.Data != null)
            {
                br.roomData.Data.SectionTime = totalMs;
            }
        }
        catch (Exception e)
        {
            LogError("syncSectionTime", e);
        }
    }

    // ---------------- 内部：工具 ----------------

    private static void ResetRuntimeState()
    {
        _team1Score = 0;
        _team2Score = 0;
        _remainingSeconds = DefaultRoundSeconds;
        _overtime = false;
        _roundOver = false;
        _winnerTeam = 0;
        _resultText = string.Empty;
        _playerDead = false;
        _respawnAt = 0f;
        _playerRespawnRemainMs = 0;
        _restartAt = 0f;
        _nextHudSync = 0f;
    }

    private static int ResolveRaceType()
    {
        try
        {
            if (OfflineGameController.setting != null && OfflineGameController.setting.RaceType > 0)
                return OfflineGameController.setting.RaceType;
        }
        catch (Exception) { }

        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx != null && ctx.battleRoom.hasRoomData
                && ctx.battleRoom.roomData.Data != null
                && ctx.battleRoom.roomData.Data.RaceType > 0)
            {
                return ctx.battleRoom.roomData.Data.RaceType;
            }
        }
        catch (Exception) { }

        return 3;
    }

    private static bool IsTeamRaceType(int raceType)
    {
        if (OfflineGameSetting.IsFreeForAll(raceType)) return false;
        return raceType == 3 || raceType == 2003 || raceType == 2019;
    }

    private static int CountBots(int raceType)
    {
        try
        {
            OfflineModeTable.Profile p = OfflineModeTable.Get(raceType);
            if (p != null && p.Bot != null) return p.Bot.AllyBots + p.Bot.EnemyBots;
        }
        catch (Exception) { }
        return 0;
    }

    private static OfflineGameplay Gameplay()
    {
        if (_gameplay != null) return _gameplay;
        try
        {
            _gameplay = OfflineGameplay.Instance;
        }
        catch (Exception) { }
        return _gameplay;
    }

    private static PlayerEntityData SelfData()
    {
        try
        {
            var ctx = Contexts.sharedInstance;
            if (ctx == null || !ctx.snapshot.hasSnapshots) return null;
            var snap = ctx.snapshot.snapshots.LatestSnapshot;
            if (snap == null || snap.PlayerEntityDataDict == null) return null;
            PlayerEntityData me;
            if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me)) return me;
        }
        catch (Exception e)
        {
            LogError("selfData", e);
        }
        return null;
    }

    private static string TeamName(int team)
    {
        if (team == 1) return "红队";
        if (team == 2) return "蓝队";
        return "平局";
    }

    private static void LogError(string where, Exception e)
    {
        try
        {
            if (_errorOnce.Add(where))
                Debug.LogError("[OFFLINE-TDM] " + where + " failed: " + e);
        }
        catch (Exception) { }
    }
}
