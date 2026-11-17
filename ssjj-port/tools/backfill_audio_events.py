# -*- coding: utf-8 -*-
"""
ENG-03 / P1 回填：用 notes/audio-events/audio-events.json 生成
  - assets/ssjjport/spec/audio-event-map.json   事件名 -> 音频键映射
  （ENG-04 起不再生成 sounds.json：见 docs/README「音效」一节）
并更新 assets/ssjjport/spec/state-transitions.json 的 gaps / audioEvents / eventFrameRule。

同时清理 ENG-03 已合并的「两个并行时钟」架构债条目。

只读 notes/audio-events/；幂等，可重复运行。
前置：先跑 tools/export_audio_events.py。

用法：
  PY="C:/Users/Mahuilai/AppData/Local/Programs/Python/Python314/python"
  "$PY" "D:\\逆向\\SSJJ双塔惊魂\\ssjj-port\\tools\\backfill_audio_events.py"
"""
from __future__ import annotations

import json
from pathlib import Path

PORT = Path(r"D:\逆向\SSJJ双塔惊魂\ssjj-port")
RES = PORT / "src" / "main" / "resources" / "assets" / "ssjjport"
AUDIO = PORT / "notes" / "audio-events" / "audio-events.json"
MAP_OUT = RES / "spec" / "audio-event-map.json"
STATES = RES / "spec" / "state-transitions.json"

AUDIO_REL = "notes/audio-events/audio-events.json"
CLIPS_REL = "notes/audio-events/audio-clips.json"
XML_REL = "notes/audio-events/soundconfig.xml"


def main() -> int:
    src = json.loads(AUDIO.read_text(encoding="utf-8"))
    clips = src["audioClips"]

    # 可映射的键：ViewAnimConfig 里出现过的 eventName + 开火命令链确认的 _fire
    view_names = set(src["viewAnimEventNames"].values())
    fire_clip = next((c["audioClip"] for c in src["confirmed"]
                      if c["specEvent"] == "shoot"), None)
    keys = set(view_names)
    if fire_clip:
        keys.add(fire_clip)

    unknown_keys = sorted(k for k in keys if k not in clips)
    if unknown_keys:
        print(f"[WARN ] 映射键不在真实 AudioClip 清单中: {unknown_keys}")

    event_name_to_key = {k: k for k in sorted(keys)}
    # spec.audio.events 的通用事件名 -> 实际资产键（能确认的才写）
    spec_event_to_key = {
        "draw": "awm_legend_t_raise",
        "shoot": "awm_legend_t_fire",
        "reload_empty": "awm_legend_t_reload",
        "reload_tactical": "awm_legend_t_reload",
    }
    unmapped = [m["specEvent"] for m in src["missing"]]
    unmapped_clips = sorted(c for c in clips if c not in keys)

    mapping = {
        "schema": "ssjj-audio-event-map/1",
        "weapon": "awm_legend_t",
        "namespace": "ssjjport",
        "source": AUDIO_REL,
        "soundsJson": None,
        "note": "只建映射，不实现实际 .ogg 播放，也不生成 sounds.json："
                "ENG-04 经 javap 核实，sounds.json 的键不会自动进 Registries.SOUND_EVENT，"
                "无 subtitle 时连 ERROR 分支都被跳过，默认日志级别下完全静默 —— "
                "保留占位键等于「有事件帧、没声音、无报警」。"
                "严禁把 spec.audio.events 的通用事件名当成资产名。",
        "eventNameToSoundKey": event_name_to_key,
        "specEventToSoundKey": spec_event_to_key,
        "confirmedTriggers": [
            {"specEvent": c["specEvent"], "audioClip": c["audioClip"],
             "trigger": c["trigger"], "stateId": c["stateId"],
             "eventTimeMs": c["eventTimeMs"], "sources": c["sources"]}
            for c in src["confirmed"]
        ],
        "unmappedSpecEvents": unmapped,
        "unmappedSpecEventsDetail": src["missing"],
        "unmappedClips": unmapped_clips,
        "unmappedClipsNote": "这些 AudioClip 真实存在，但本轮找不到独立触发规则，"
                             "因此不注册为映射键、不编帧号。",
        "audioClips": clips,
    }
    MAP_OUT.write_text(json.dumps(mapping, ensure_ascii=False, indent=2) + "\n",
                       encoding="utf-8")
    print(f"[write] {MAP_OUT}  {MAP_OUT.stat().st_size:,} B  ({len(keys)} 个映射键)")
    # ENG-04：刻意不生成 sounds.json。见 mapping["note"] 的 javap 依据。
    if (RES / "sounds.json").exists():
        print("[warn] 检测到残留 sounds.json，ENG-04 已撤销该文件，请手动删除")

    # ---------------------------------------------------------- state-transitions
    st = json.loads(STATES.read_text(encoding="utf-8"))

    st["audioEvents"] = {
        "status": "ENG-03 已导出（P1）",
        "rawSoundConfig": XML_REL,
        "audioClips": CLIPS_REL,
        "derivedTable": AUDIO_REL,
        "eventMap": "assets/ssjjport/spec/audio-event-map.json",
        "soundsJson": None,
        "exporter": "tools/export_audio_events.py",
        "backfill": "tools/backfill_audio_events.py",
        "authority": src["authority"],
        "confirmedSpecEvents": [c["specEvent"] for c in src["confirmed"]],
        "stillMissing": unmapped,
        "note": "spec.audio.events 是通用事件名清单，与本枪 9 个真实 AudioClip 名不同套；"
                "映射见 audio-event-map.json。仍查不到的触发时刻一律保留「未找到」并注明原因，"
                "没有编造任何帧号或毫秒数。",
    }

    st["eventFrameRule"]["weaponSpecificEventFrames"] = (
        "权威（ENG-03 细化）：awm_legend_t 的 24 条 <action> 全部没有 eventFrame 属性 → "
        "WeaponAnimationData.cs:27-33 的 EventTime 保持 AnimationDesc 默认 0。"
        "WeaponNoticePlayBackSystem.cs:90 判的是严格 `currentTime > EventTime`，"
        "而 ViewAnimSystem.cs:144 的 currentTime = GetViewAnimDuration - RemainTime 在动画起点为 0，"
        "因此带 eventName 的动作在**起点之后的第一个预测帧**触发音效，不是动画第 0 帧本身。"
        "全库 2,691 个 TextAsset 中仅 4 个无关武器含 eventFrame，本枪不属于。"
    )
    st["eventFrameRule"]["fireCommandChain"] = (
        "fire(15) 无 eventName → WeaponNoticePlayBackSystem.cs:70-72 直接 return，"
        "改由开火命令链同步触发：AbstractFireAction.cs:23-26,61-64 → "
        "FireFunctions.cs:376-398 (AddFireEvent 1/11/59) → WeaponUtil.cs:161-217 "
        "(AddSound case 1 → SoundResourceUtility.GetWeaponSoundFireAssetInfo) → "
        "Play2DSound。该链在开火命令同一预测帧内执行，非动画事件帧驱动，故没有 eventFrame 数值。"
    )

    # 逐状态回填音效说明（只改说明文字，不改时长/事件帧数值）
    per_state = {
        "raise": ("确认（P1）：eventName=awm_legend_t_raise，EventTime=0，"
                  "起点后第一个预测帧触发；映射键 ssjjport:awm_legend_t_raise。"),
        "reload": ("确认（P1）：eventName=awm_legend_t_reload，EventTime=0，"
                   "起点后第一个预测帧触发；reload_empty/reload_tactical 共用此 clip，原版无区分。"),
        "melee": ("确认（P1）：eventName=awm_legend_t_sec_fire，EventTime=0；"
                  "另有 5 个 MELEE_DELAY 近战延迟帧（SetDelayAttackTime），不是音效 eventFrame。"),
        "fire": ("确认（P1，非动画事件帧）：fire(15) 无 eventName，"
                 "音效由开火命令链 AbstractFireAction → FireFunctions.FireEvent → "
                 "WeaponUtil.AddSound(1) 在开火预测帧同步播放 awm_legend_t_fire；"
                 "shoot_3p 仍为未找到（见 gaps）。"),
        "bolt": ("未找到（P1）：音效 bundle 无 *_bolt clip，ViewAnimConfig bolt(18) 无 eventName，"
                 "TpsWeaponSoundPredicateSystem 只注册 StateId 17。不编时刻。"),
        "inspect": ("未找到（P1）：音效 bundle 无 *_inspect clip，TORSO_SHOWGUN(44) 无 eventName，"
                    "源码未发现独立 Play2DSound 调用；inspect/inspect_empty 无区分依据。"),
        "putaway": ("确认不存在（P1）：音效 bundle 无 put_away clip；本枪无独立收枪动作。"),
    }
    for action, note in per_state.items():
        st["states"][action]["eventFramesNote"] = note
        st["states"][action]["audioEventsNoteSource"] = AUDIO_REL

    # gaps：清掉已解决的条目，保留并注明仍未找到的
    st["gaps"] = [
        "【ENG-03 已解决】两个并行时钟已合并：AnimationTimeline 为唯一时钟，"
        "WeaponState 通过 StateListener 订阅其状态与权威时长，不再读 spec clip 长度、不再自行计时。",
        "【ENG-03 已解决】draw / reload_empty / reload_tactical / shoot / 近战 的触发来源已确认："
        "前三者来自 ViewAnimConfig eventName（EventTime=0、起点后第一个预测帧），"
        "shoot 来自开火命令链（同一预测帧同步）。见 " + AUDIO_REL,
        "【仍缺·未找到】shoot_3p 的触发时刻：awm_legend_t 音效 bundle 9 个 AudioClip 中无 *_3p 资产；"
        "TpsWeaponSoundPredicateSystem.cs:26 只为 StateId 17 注册 reload，未注册 15；"
        "PlayerSound 用 isMyPlayer 控制衰减而非切换 clip。无独立 clip、无独立触发规则。",
        "【仍缺·未找到】bolt 的触发时刻：无 *_bolt clip；ViewAnimConfig TORSO_PULL_CHARGER(18) "
        "无 eventName → WeaponNoticePlayBackSystem.cs:70-72 直接 return；"
        "TpsWeaponSoundPredicateSystem 只注册 17。可能混在 reload/fire 音里，但找不到独立触发点。",
        "【仍缺·未找到】inspect / inspect_empty 的触发时刻：无 *_inspect clip；"
        "TORSO_SHOWGUN(44) 无 eventName；CheckShowGun/ShowGunFrameAction 未发现独立 Play2DSound。"
        "两个事件名也找不到空/非空弹匣的区分依据。",
        "【仍缺·未找到】后坐(Kickback Sniper 2.0) / 枪口特效的动画事件帧：ViewAnimConfig 无相关属性，"
        "AddFireSparks 由开火命令链同步调用但无 eventFrame 数值，未找到绑定到动画事件帧的 FrameAction。",
        "【仍缺·确认不存在】putaway：无收枪动作、无 put_away 音效资产（ENG-02/ENG-03 双重确认），"
        "WeaponState.PUTAWAY 仅为移植侧骨架。",
        "【保留·不裁决】ViewAnimConfig 的 loop 属性与 ViewAnimStateInfo.IsLoop 硬编码白名单在 "
        "StateId 44/150 上不一致（XML true vs 硬编码 false）；两个消费者不同，两者都记录，未擅自裁决。",
        "【仍缺·待下阶段】MC 侧开镜 FOV 数值未找到（SpreadInputs 用 isScoping 布尔 + spec 可配置 40）；"
        "raiseSpeed（开火后 1.3f，AwmLegendRaisePredicactionSystem.cs）尚未接入攻击计时器。",
        "【仍缺·待下阶段】实际音频播放：ENG-04 已撤掉 sounds.json 占位键，只保留映射表；"
        "没有 .ogg 资产、没有 SoundEvent 注册、没有播放调用；音效事件帧目前只做日志派发。",
    ]
    st["gapsSource"] = AUDIO_REL

    STATES.write_text(json.dumps(st, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[write] {STATES}  {STATES.stat().st_size:,} B  (gaps={len(st['gaps'])})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
