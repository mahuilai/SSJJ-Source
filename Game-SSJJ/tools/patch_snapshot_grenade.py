# -*- coding: utf-8 -*-
"""
[OFFLINE-SNAPSHOT-GRENADE] 把 bot 手雷爆炸从「自建 OfflineGrenadeFx」切到原版快照链路。

原版链路（已核实）：
  快照 GrenadeExplosionEventEntityDataDict
    -> GrenadeExplosionEntityCreateSystem.OnPlaybackInit()
    -> SceneObjectFactory.CreateExplosion(data)
    -> ParticleManager.GetEventEntityData(EventId)  [有] 或 ResConfigFactory.GetExplosionConfig(EventId, ResTypeID) [无]
    -> effectprefab/explosion + grenade.prefab（EventId=4, ResTypeId=0）

坐标：unity(x,y,z) --*100--> net(X=z, Y=-x, Z=y)
"""
import io, os, sys

GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'
s = io.open(GP, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-SNAPSHOT-GRENADE' in s:
    print('already patched')
    sys.exit(0)

NL = chr(10)
T = chr(9)

# ---------- 1) 字段 ----------
anchor_field = '    private readonly List<BotGrenade> _botGrenades = new List<BotGrenade>();'
if anchor_field not in s:
    # 宽松定位
    import re
    m = re.search(r'[ \t]*private readonly List<BotGrenade> _botGrenades[^;]*;', s)
    assert m, 'cannot locate _botGrenades field'
    anchor_field = m.group(0)

fields = (anchor_field + NL +
          '    // [OFFLINE-SNAPSHOT-GRENADE] 手雷爆炸事件：写入快照交给原版 Playback 消费' + NL +
          '    private int _nextExplosionEventId = 910000;' + NL +
          '    private readonly List<int> _liveExplosionEventIds = new List<int>();' + NL +
          '    private readonly List<int> _explosionEventFrames = new List<int>();' + NL +
          '    private int _explosionFrameCounter;' + NL)

s = s.replace(anchor_field, fields, 1)

# ---------- 2) 发射方法（插在 ThrowBotGrenade 之前） ----------
emit = (
'    /// <summary>[OFFLINE-SNAPSHOT-GRENADE] 往快照写一条手雷爆炸事件。' + NL +
'    /// 原版 GrenadeExplosionEntityCreateSystem 每帧遍历该字典 -> SceneObjectFactory.CreateExplosion。' + NL +
'    /// 事件保留 3 帧后移除，避免每帧重复 ReplaceLoadUnityObjects 重播。' + NL +
'    private void EmitGrenadeExplosionEvent(Vector3 unityPos, int ownerId, int ownerTeam, int eventId, int resTypeId, string weaponName)' + NL +
'    {' + NL +
T + 'try' + NL +
T + '{' + NL +
T*2 + 'ISnapshot snap = Snap();' + NL +
T*2 + 'if (snap == null || snap.GrenadeExplosionEventEntityDataDict == null) return;' + NL +
T*2 + 'int eid = _nextExplosionEventId++;' + NL +
T*2 + 'GrenadeExplosionEventEntityData ev = new GrenadeExplosionEventEntityData();' + NL +
T*2 + 'BaseEventEntityData be = new BaseEventEntityData();' + NL +
T*2 + 'be.Id = eid;' + NL +
T*2 + 'be.EType = 5;                       // AbstractSnapshotParser case 5 = GrenadeExplosion' + NL +
T*2 + '// Unity 米 -> SSJJ 原生 cm：net.X = z, net.Y = -x, net.Z = y' + NL +
T*2 + 'be.X = unityPos.z * 100f;' + NL +
T*2 + 'be.Y = -unityPos.x * 100f;' + NL +
T*2 + 'be.Z = unityPos.y * 100f;' + NL +
T*2 + 'be.EventId = eventId;' + NL +
T*2 + 'be.EventIdSpecified = true;' + NL +
T*2 + 'be.OwnerId = ownerId;' + NL +
T*2 + 'be.OwnerIdSpecified = true;' + NL +
T*2 + 'be.Team = ownerTeam;' + NL +
T*2 + 'be.TeamSpecified = true;' + NL +
T*2 + 'be.Scale = new Vector3DData { X = 1f, Y = 1f, Z = 1f };' + NL +
T*2 + 'ev.BaseEventEntity = be;' + NL +
T*2 + 'ev.ResTypeID = resTypeId;' + NL +
T*2 + 'ev.ResTypeIDSpecified = true;' + NL +
T*2 + 'ev.WeaponName = weaponName;' + NL +
T*2 + 'snap.GrenadeExplosionEventEntityDataDict[eid] = ev;' + NL +
T*2 + '_liveExplosionEventIds.Add(eid);' + NL +
T*2 + '_explosionEventFrames.Add(_explosionFrameCounter);' + NL +
T*2 + 'Debug.Log("[OFFLINE-SNAPSHOT-GRENADE] emit id=" + eid + " eventId=" + eventId' + NL +
T*3 + '+ " resType=" + resTypeId + " pos=" + unityPos.ToString("F1") + " owner=" + ownerId);' + NL +
T + '}' + NL +
T + 'catch (System.Exception ex)' + NL +
T + '{' + NL +
T*2 + 'Debug.LogWarning("[OFFLINE-SNAPSHOT-GRENADE] emit failed: " + ex.Message);' + NL +
T + '}' + NL +
'}' + NL + NL +
'    /// <summary>[OFFLINE-SNAPSHOT-GRENADE] 每帧推进事件年龄，超过 3 帧的从快照移除。' + NL +
'    private void CleanupExplosionEvents()' + NL +
'    {' + NL +
T + '_explosionFrameCounter++;' + NL +
T + 'if (_liveExplosionEventIds.Count == 0) return;' + NL +
T + 'ISnapshot snap = Snap();' + NL +
T + 'if (snap == null || snap.GrenadeExplosionEventEntityDataDict == null) return;' + NL +
T + 'for (int i = _liveExplosionEventIds.Count - 1; i >= 0; i--)' + NL +
T + '{' + NL +
T*2 + 'if (_explosionFrameCounter - _explosionEventFrames[i] < 3) continue;' + NL +
T*2 + 'int eid = _liveExplosionEventIds[i];' + NL +
T*2 + 'try { snap.GrenadeExplosionEventEntityDataDict.Remove(eid); } catch (System.Exception) { }' + NL +
T*2 + '_liveExplosionEventIds.RemoveAt(i);' + NL +
T*2 + '_explosionEventFrames.RemoveAt(i);' + NL +
T + '}' + NL +
'}' + NL + NL)

anchor_throw = '    /// <summary>[OFFLINE-TDM] Bot 投出投掷物：Unity 米制抛物线，1.4s 命中 + 0.2s 引信。</summary>'
assert anchor_throw in s, 'ThrowBotGrenade doc anchor missing'
s = s.replace(anchor_throw, emit + anchor_throw, 1)

# ---------- 3) 爆炸分支改为写快照 ----------
old_explode = (
'                if (g.Kind == 2)' + NL +
'                {' + NL +
'                    OfflineGrenadeFx.Smoke(g.Pos);' + NL +
'                    Debug.Log("[OFFLINE-BOT-GRENADE] explode smoke at " + g.Pos.ToString("F1") + " bot=" + g.OwnerId);' + NL +
'                    continue;' + NL +
'                }' + NL +
'                OfflineGrenadeFx.Explosion(g.Pos, g.Kind);' + NL +
'                if (g.Kind == 1)' + NL +
'                {' + NL +
'                    OfflineGrenadeFx.TriggerFlash(g.Pos);' + NL +
'                    Debug.Log("[OFFLINE-BOT-GRENADE] explode flash at " + g.Pos.ToString("F1") + " bot=" + g.OwnerId);' + NL +
'                    continue;' + NL +
'                }')

new_explode = (
'                // [OFFLINE-SNAPSHOT-GRENADE] 不再自建特效：写快照事件，交给原版' + NL +
'                // GrenadeExplosionEntityCreateSystem -> SceneObjectFactory.CreateExplosion。' + NL +
'                // EventId: 4=破片手雷（Explosion 表 ResTypeId 0 -> grenade.prefab）；8=闪光（CreateExplosion 内专用分支）' + NL +
'                if (g.Kind == 2)' + NL +
'                {' + NL +
'                    // 烟雾：原版走 LocalEntityEffect/EventId 体系，暂沿用自建（无伤害）' + NL +
'                    OfflineGrenadeFx.Smoke(g.Pos);' + NL +
'                    Debug.Log("[OFFLINE-BOT-GRENADE] explode smoke at " + g.Pos.ToString("F1") + " bot=" + g.OwnerId);' + NL +
'                    continue;' + NL +
'                }' + NL +
'                if (g.Kind == 1)' + NL +
'                {' + NL +
'                    EmitGrenadeExplosionEvent(g.Pos, g.OwnerId, g.OwnerTeam, 8, 0, "grenade");' + NL +
'                    OfflineGrenadeFx.TriggerFlash(g.Pos);   // 屏幕致盲仍是客户端逻辑' + NL +
'                    Debug.Log("[OFFLINE-BOT-GRENADE] explode flash at " + g.Pos.ToString("F1") + " bot=" + g.OwnerId);' + NL +
'                    continue;' + NL +
'                }' + NL +
'                EmitGrenadeExplosionEvent(g.Pos, g.OwnerId, g.OwnerTeam, 4, 0, "grenade");')

assert old_explode in s, 'explode branch anchor missing'
s = s.replace(old_explode, new_explode, 1)

io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('patched: fields + emit method + explode branch')
print('file size:', len(s))
