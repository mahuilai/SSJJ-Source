using System;
using System.Collections.Generic;
using Assets.Sources.Systems.PacketHandle.Handlers;
using NetData;
using UnityEngine;

/// <summary>
/// [OFFLINE-KILLCHAIN] 把原版击杀链在离线下跑通。
///
/// 原版这两条链完全由服务端驱动，离线环境从来没有下发过，所以 UI 全空：
///   method 6  KillPlayerInfoData -> KillPlayerInfoDataHandler
///              -> killPlayerInfo.InfoList（屏幕击杀播报）
///              -> playerInfo.CurrKillNums（连杀数）
///              -> NotifyManager.ForceInvoke(22)（刷新播报 UI）
///              -> PlayKillSound / PlayAutoSoundEvent（击杀音效、连杀语音）
///              -> ReplaceKiller（死亡时显示凶手名）
///   method 8  AllKillInfoData    -> AllKillInfoDataHandler
///              -> playerInfo.All / Team1 / Team2（Tab 计分板、队伍分栏）
///              -> NotifyManager.ForceInvoke(19)
///
/// 这里的做法不是自己画一套 HUD，而是构造同样的消息对象直接喂给原版 handler，
/// 排序、分队、音效、连杀判定全部复用原版代码。
/// </summary>
public static class OfflineKillChain
{
	static bool _ready;
	static bool _failLogged;
	static bool _killFailLogged;
	static bool _boardFailLogged;

	public static bool Ready { get { return _ready; } }

	/// <summary>确保 playerInfo / killPlayerInfo / gunGlory 三个组件存在。</summary>
	public static void Ensure()
	{
		if (_ready) return;
		try
		{
			var ctx = Contexts.sharedInstance;
			var br = ctx.battleRoom;
			if (!br.hasPlayerInfo)
			{
				// 22 个参数里只填计分板真正需要的四个，其余 null 交给原版按需填充。
				br.SetPlayerInfo(
					null, null, null, null, null, null, null,
					new Dictionary<int, int>(),          // CurrKillNums（连杀数）
					null,
					new List<OneKillInfoData>(),         // All
					new List<OneKillInfoData>(),         // Team1
					new List<OneKillInfoData>(),         // Team2
					null, null, null, null, null, null, null,
					0, null, null);
			}

			var gr = ctx.gameRule;
			if (!gr.hasKillPlayerInfo)
				gr.CreateEntity().AddKillPlayerInfo(new Queue<KillPlayerInfoData>(), false, null);
			if (!gr.hasGunGlory)
				gr.CreateEntity().AddGunGlory(new List<int>(), 0);

			_ready = true;
			Debug.Log("[OFFLINE-KILLCHAIN] scoreboard components ready");
		}
		catch (Exception e)
		{
			if (!_failLogged) { _failLogged = true; Debug.LogError("[OFFLINE-KILLCHAIN] ensure failed: " + e); }
		}
	}

	/// <summary>
	/// [OFFLINE-KILLCHAIN] bot 击杀 bot：同样走原版 KillPlayerInfo 链。
	/// 原版服务端对每一杀都下发 KillPlayerInfoData（不论是不是玩家杀的），
	/// 离线只有玩家击杀时播报过，bot 互杀静默 —— 战场看起来就是"死人但没战报"。
	/// </summary>
	public static void PushBotKill(int killerId, int victimId, int killNum, bool headshot, bool firstBlood, string weaponName = null)
	{
		Ensure();
		if (!_ready) return;
		var ctx = Contexts.sharedInstance;
		try
		{
			var snap = ctx.snapshot.hasSnapshots ? ctx.snapshot.snapshots.LatestSnapshot : null;
			if (snap == null) return;
			PlayerEntityData killerData;
			PlayerEntityData victimData;
			int killerTeam = 0, victimTeam = 0;
			if (snap.PlayerEntityDataDict.TryGetValue(killerId, out killerData) && killerData != null) killerTeam = killerData.Team;
			if (snap.PlayerEntityDataDict.TryGetValue(victimId, out victimData) && victimData != null) victimTeam = victimData.Team;

			var kd = new KillPlayerInfoData();
			kd.KillPlayerId = killerId;
			kd.BeKillPlayerId = victimId;
			kd.KillPlayerName = (killerId == snap.Self)
				? "你" : Assets.Sources.Systems.Snapshot.OfflineBotSpawner.GetBotName(killerId);
			kd.BeKillPlayerName = (victimId == snap.Self)
				? "你" : Assets.Sources.Systems.Snapshot.OfflineBotSpawner.GetBotName(victimId);
			kd.KillTeam = killerTeam;
			kd.BekillTeam = victimTeam;
			kd.CurKillNum = killNum;
			kd.FirstBlood = firstBlood;
			string kWeapon = weaponName;
			if (string.IsNullOrEmpty(kWeapon) && killerData != null) kWeapon = killerData.CurrentWeaponName;
			if (!string.IsNullOrEmpty(kWeapon)) kd.WeaponName = kWeapon;
			ApplyWeaponIconData(kd, killerData);
			kd.Headshot = headshot;
			Debug.Log("[OFFLINE-KILLCHAIN] push killer=" + killerId + " victim=" + victimId
				+ " weapon=" + (kd.WeaponName ?? "") + " skin=" + (kd.WeaponSkinName ?? "")
				+ " level=" + kd.WeaponLevel + " secondary=" + kd.IsSecondary + " headshot=" + headshot);
			kd.IsWoman = false;
			if (kd.GunGloryList != null) kd.GunGloryList.Clear();

			new KillPlayerInfoDataHandler(ctx).Handle(kd);
		}
		catch (Exception e)
		{
			if (!_killFailLogged) { _killFailLogged = true; Debug.LogError("[OFFLINE-KILLCHAIN] botKill failed: " + e); }
		}
	}

	/// <summary>
	/// 玩家击杀一个 bot：走原版 KillPlayerInfo 链（播报 + 音效 + 连杀），再刷新计分板。
	/// </summary>
	public static void PushPlayerKill(int victimId, int victimTeam, int killNum, bool headshot, bool firstBlood, string weaponName = null)
	{
		Ensure();
		if (!_ready) return;
		var ctx = Contexts.sharedInstance;
		try
		{
			var snap = ctx.snapshot.hasSnapshots ? ctx.snapshot.snapshots.LatestSnapshot : null;
			int selfId = (snap != null) ? snap.Self : 0;
			int selfTeam = 0;
			string selfWeapon = weaponName ?? "";
			PlayerEntityData me = null;
			if (snap != null && snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me != null)
			{
				selfTeam = me.Team;
				if (string.IsNullOrEmpty(selfWeapon)) selfWeapon = me.CurrentWeaponName;
			}

			var kd = new KillPlayerInfoData();
			kd.KillPlayerId = selfId;
			kd.BeKillPlayerId = victimId;
			kd.KillPlayerName = "你";
			kd.KillTeam = selfTeam;
			kd.BekillTeam = victimTeam;
			kd.CurKillNum = killNum;
			// [OFFLINE-KILLCHAIN] 击杀播报要显示玩家武器图标（KillMessageModel.GetWeapon 读 WeaponName）
			if (!string.IsNullOrEmpty(selfWeapon)) kd.WeaponName = selfWeapon;
			ApplyWeaponIconData(kd, me);
			kd.FirstBlood = firstBlood;
			kd.Headshot = headshot;
			kd.IsWoman = false;
			// GunGloryList 是只读属性（集合本身可写），清空后按需 Add
			if (kd.GunGloryList != null) kd.GunGloryList.Clear();

			new KillPlayerInfoDataHandler(ctx).Handle(kd);
			Debug.Log("[OFFLINE-KILLCHAIN] killInfo self=" + selfId + " victim=" + victimId
				+ " team=" + selfTeam + "/" + victimTeam + " killNum=" + killNum
				+ " weapon=" + (kd.WeaponName ?? "") + " skin=" + (kd.WeaponSkinName ?? "")
				+ " level=" + kd.WeaponLevel + " secondary=" + kd.IsSecondary);
		}
		catch (Exception e)
		{
			if (!_killFailLogged) { _killFailLogged = true; Debug.LogError("[OFFLINE-KILLCHAIN] killInfo failed: " + e); }
		}

		if (!OfflineTdmMatch.Active) RebuildBoard();
	}

	/// <summary>按原版 KillMessageModel 的资源键规则补齐皮肤、武器等级和副武器标记。</summary>
	private static void ApplyWeaponIconData(KillPlayerInfoData kill, PlayerEntityData shooter)
	{
		if (kill == null || shooter == null) return;
		if (!string.IsNullOrEmpty(shooter.CurrentWeaponSkinName)) kill.WeaponSkinName = shooter.CurrentWeaponSkinName;
		kill.WeaponLevel = Mathf.Max(0, shooter.CurrentWeaponLevel);
		kill.IsSecondary = shooter.CurrentWeapon == 2;
	}

	/// <summary>
	/// 重建 Tab 计分板：按当前快照里所有活着的实体（玩家 + bot）生成 OneKillInfoData，
	/// 交给原版 AllKillInfoDataHandler 做排序、分队伍、发通知。
	/// </summary>
	public static void RebuildBoard()
	{
		Ensure();
		if (!_ready) return;
		var ctx = Contexts.sharedInstance;
		try
		{
			var snap = ctx.snapshot.hasSnapshots ? ctx.snapshot.snapshots.LatestSnapshot : null;
			if (snap == null) return;

			var list = new List<OneKillInfoData>(8);
			var gp = OfflineGameplay.Instance;

			PlayerEntityData me;
			if (snap.PlayerEntityDataDict.TryGetValue(snap.Self, out me) && me != null)
			{
				OneKillInfoData row = MakeRow(snap.Self, me.Team, "你",
					gp != null ? gp.PlayerKills : 0,
					gp != null ? gp.PlayerDeaths : 0,
					me.Career);
				list.Add(row);
			}

			if (gp != null) gp.AppendBotScoreRows(list);

			ctx.battleRoom.playerInfo.All.Clear();
			var data = new AllKillInfoData();
			// List 是只读属性（集合本身可写）
			if (data.List != null) { data.List.Clear(); data.List.AddRange(list); }
			new AllKillInfoDataHandler(ctx).Handle(data);

			Debug.Log("[OFFLINE-KILLCHAIN] board rows=" + list.Count
				+ " all=" + ctx.battleRoom.playerInfo.All.Count
				+ " t1=" + ctx.battleRoom.playerInfo.Team1.Count
				+ " t2=" + ctx.battleRoom.playerInfo.Team2.Count);
		}
		catch (Exception e)
		{
			if (!_boardFailLogged) { _boardFailLogged = true; Debug.LogError("[OFFLINE-KILLCHAIN] board failed: " + e); }
		}
	}

	public static OneKillInfoData MakeRow(int id, int team, string name, int kills, int deaths, string career)
	{
		var row = new OneKillInfoData();
		row.Id = id;
		row.Team = team;
		row.PlayerName = name;
		row.KillNum = kills;
		row.BeKillNum = deaths;
		row.Score = kills * 100 - deaths * 20;
		if (!string.IsNullOrEmpty(career)) row.Career = career;
		return row;
	}
}
