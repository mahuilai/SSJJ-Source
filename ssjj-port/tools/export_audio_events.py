# -*- coding: utf-8 -*-
"""
ENG-03 / P1：导出 awm_legend_t 的音效资产清单 + 逐事件触发规则。

只读输入（不改动任何游戏/资源文件）：
  - AssetBundle: .../AssetBundles/Windows/sound/weapon/awm_legend_t_055d...（AudioClip 清单）
  - AssetBundle: .../AssetBundles/Windows/weapon/awm_legend_t_4e41...（soundconfig TextAsset）
  - notes/viewanim-config/viewanim-config.json（ENG-02 导出的 ViewAnimConfig eventName）
  - Game source/02_managed_src/ 反编译源码（触发链，逐行行号写进结果里）

输出（ssjj-port/notes/audio-events/）：
  - soundconfig.xml           武器包内原始 <soundConfig> TextAsset
  - audio-clips.json          UnityPy 枚举出的真实 AudioClip 名（权威资产清单）
  - audio-events.json         逐事件规则表：能确认的写确认+源码行号；查不到的写「未找到」+原因

严禁编造帧号或时刻：所有 trigger 都是源码里的调用点/语义，
EventTime 只有 ViewAnimConfig 的 eventFrame 属性（本枪全缺）才会产生数值。

用法：
  PY="C:/Users/Mahuilai/AppData/Local/Programs/Python/Python314/python"
  "$PY" "D:\\逆向\\SSJJ双塔惊魂\\ssjj-port\\tools\\export_audio_events.py"
"""
from __future__ import annotations

import json
import warnings
from pathlib import Path

import UnityPy

warnings.filterwarnings("ignore")

PROJECT = Path(r"D:\逆向\SSJJ双塔惊魂")
PORT = PROJECT / "ssjj-port"
OUT = PORT / "notes" / "audio-events"
MANAGED = PROJECT / "Game source" / "02_managed_src"
CFG = PORT / "notes" / "viewanim-config" / "viewanim-config.json"

AB_ROOTS = [
    Path(r"D:\SSJJ-4399\battle\3_64\StreamingAssets\AssetBundles\Windows"),
    Path(r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows"),
]
SOUND_BUNDLE = "sound/weapon/awm_legend_t_055dcf5f7532af5f5e1a9ad0a98ddd6c"
WEAPON_BUNDLE = "weapon/awm_legend_t_4e41f53852ab64dd135a4278f48fd8fe"

S = lambda p: f"Game source/02_managed_src/{p}"  # noqa: E731

# 源码引用（路径:行号），全部来自本轮实际读到的文件，不臆造。
SRC = {
    "fire_chain": [
        S("weaponPredicateNet.net/weapon.predicateSystem.attackSystem.actions/AbstractFireAction.cs:23-26"),
        S("weaponPredicateNet.net/weapon.predicateSystem.attackSystem.actions/AbstractFireAction.cs:61-64"),
        S("weaponPredicateNet.net/weapon.utils/FireFunctions.cs:376-398"),
        S("Assembly-CSharp/Assets.Sources.Modules.Player.Attack.SharePredicationApapter/WeaponUtil.cs:161-217"),
        S("Assembly-CSharp/Assets.Sources.Modules.Player.Attack.SharePredicationApapter/WeaponUtil.cs:219-224"),
        S("Assembly-CSharp/Assets.Sources.Utils/SoundResourceUtility.cs:88-92"),
    ],
    "notice": [
        S("SSJJAnim_Library/SSJJAnim.WeaponAnim/WeaponAnimationData.cs:27-33"),
        S("Assembly-CSharp/Assets.Sources.Modules.Player.Sound/WeaponNoticePlayBackSystem.cs:70-72"),
        S("Assembly-CSharp/Assets.Sources.Modules.Player.Sound/WeaponNoticePlayBackSystem.cs:76"),
        S("Assembly-CSharp/Assets.Sources.Modules.Player.Sound/WeaponNoticePlayBackSystem.cs:90"),
        S("Assembly-CSharp/Assets.Sources.Modules.Player.Sound/WeaponNoticePlayBackSystem.cs:105-109"),
    ],
    "tps": [S("Assembly-CSharp/Assets.Sources.Modules.Player.Sound/TpsWeaponSoundPredicateSystem.cs:26")],
    "soundcfg": [
        S("Assembly-CSharp/Assets.Sources.XmlAsset/SounfConfigXmlAsset.cs:9-27"),
        S("Assembly-CSharp/Assets.Sources.Particle.Config/SoundConfigData.cs:41-62"),
    ],
    "preload": [S("Assembly-CSharp/Assets.Sources.Info.Weapon.WeaponInfo/DefaultWeaponInfo.cs:410-423")],
    "viewanim": ["notes/viewanim-config/awm_legend_t__hand.DAE.action.xml"],
    "bundle": [SOUND_BUNDLE, WEAPON_BUNDLE],
}


def resolve_root() -> Path:
    for r in AB_ROOTS:
        if (r / SOUND_BUNDLE).is_file() and (r / WEAPON_BUNDLE).is_file():
            return r
    raise SystemExit("[FATAL] 两个 AssetBundle 根都不含目标 bundle")


def text_assets(bundle: Path):
    env = UnityPy.load(str(bundle))
    for o in env.objects:
        if o.type.name == "TextAsset":
            d = o.read()
            raw = getattr(d, "m_Script", b"") or b""
            if isinstance(raw, str):
                raw = raw.encode("utf-8", "replace")
            yield getattr(d, "m_Name", "?"), raw


def audio_clips(bundle: Path):
    env = UnityPy.load(str(bundle))
    names = []
    for o in env.objects:
        if o.type.name == "AudioClip":
            d = o.read()
            names.append(getattr(d, "m_Name", None) or getattr(d, "name", "?"))
    return sorted(names)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    root = resolve_root()
    print(f"[root ] {root}")

    clips = audio_clips(root / SOUND_BUNDLE)
    print(f"[clips] {len(clips)} 个真实 AudioClip")
    (OUT / "audio-clips.json").write_text(
        json.dumps({
            "sourceBundle": SOUND_BUNDLE,
            "sourceRoot": str(root),
            "count": len(clips),
            "clips": clips,
            "note": "UnityPy 枚举 AudioClip.m_Name；这是本枪实际存在的全部音效资产。"
                    "spec.audio.events 的 draw/shoot/bolt/inspect 等是通用事件名，不是资产名。",
        }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    soundcfg = None
    for name, raw in text_assets(root / WEAPON_BUNDLE):
        if name == "soundconfig":
            soundcfg = raw
            (OUT / "soundconfig.xml").write_bytes(raw)
            print(f"[write] soundconfig.xml  {len(raw)} B")
    if soundcfg is None:
        print("[WARN ] 武器包中无 soundconfig TextAsset")

    cfg = json.loads(CFG.read_text(encoding="utf-8"))
    actions = cfg["bundles"]["awm_legend_t"]["actions"]
    by_name = {a["name"]: a for a in actions}

    def viewanim_event(action_name: str):
        a = by_name.get(action_name)
        if not a:
            return None
        return {
            "stateId": a["stateId"],
            "eventName": a["eventName"],
            "eventTimeMs": a["eventTimeMs"],
            "eventTimeSource": a["eventTimeSource"],
            "start": a["start"], "end": a["end"], "frameCount": a["frameCount"],
            "totalTimeMs": a["totalTimeMs"],
        }

    # ---- 已确认的触发规则（全部有源码行号，不编帧号/时刻） -------------------
    confirmed = [
        {
            "specEvent": "draw",
            "status": "确认",
            "audioClip": "awm_legend_t_raise",
            "viewAnimEventName": "awm_legend_t_raise",
            "trigger": "ViewAnimConfig <action name=TORSO_RAISE eventName=awm_legend_t_raise>；"
                       "eventFrame 属性不存在 → EventTime=0。"
                       "WeaponNoticePlayBackSystem.cs:90 判 currentTime > EventTime（严格 >），"
                       "动画起点 currentTime=ViewAnimDuration-RemainTime=0，"
                       "故在起点之后的第一个预测帧触发（非动画第 0 帧本身）。",
            "eventTimeMs": 0,
            "eventTimeMsSource": "WeaponAnimationData.cs:27-33（无 eventFrame 时 EventTime 保持默认 0）",
            "stateId": 16,
            "sources": SRC["notice"] + SRC["viewanim"],
        },
        {
            "specEvent": "reload_empty / reload_tactical",
            "status": "确认（两个 spec 事件名合并到同一 clip，原版无区分）",
            "audioClip": "awm_legend_t_reload",
            "viewAnimEventName": "awm_legend_t_reload",
            "trigger": "ViewAnimConfig <action name=TORSO_RELOAD eventName=awm_legend_t_reload>；"
                       "eventFrame 属性不存在 → EventTime=0，起点后第一个预测帧触发。"
                       "TPS 侧另有 TpsWeaponSoundPredicateSystem.cs:26 把 StateId 17 映射到 "
                       "'{weapon}_reload'，同样在动画进入 17 时播放（>1000ms 节流）。",
            "eventTimeMs": 0,
            "eventTimeMsSource": "WeaponAnimationData.cs:27-33",
            "stateId": 17,
            "sources": SRC["notice"] + SRC["tps"] + SRC["viewanim"],
        },
        {
            "specEvent": "shoot",
            "status": "确认（触发时机=开火预测帧；spec 事件名与资产名不同，需映射）",
            "audioClip": "awm_legend_t_fire",
            "viewAnimEventName": None,
            "trigger": "fire(15) 在 ViewAnimConfig 中没有 eventName，"
                       "WeaponNoticePlayBackSystem.cs:70-72 直接 return → 走开火命令链："
                       "AbstractFireAction.Action → onFireActions.Step（同步）→ CommonFireEvent → "
                       "FireFunctions.FireEvent → AddFireEvent(args,1) → BroadCastEvent → "
                       "WeaponUtil.AddSound(case 1) → SoundResourceUtility.GetWeaponSoundFireAssetInfo → "
                       "PlayerSound → Play2DSound。整条链在开火命令同一预测帧内同步执行，"
                       "没有动画事件帧延迟（不是 eventFrame 驱动）。",
            "eventTimeMs": None,
            "eventTimeMsSource": "不适用：非 ViewAnimConfig eventFrame 驱动",
            "stateId": 15,
            "sources": SRC["fire_chain"] + SRC["viewanim"],
        },
        {
            "specEvent": "（近战 / 二级开火）",
            "status": "确认",
            "audioClip": "awm_legend_t_sec_fire",
            "viewAnimEventName": "awm_legend_t_sec_fire",
            "trigger": "ViewAnimConfig 的 TORSO_SECONDARY_ATTACK(20) / TORSO_KNIFE_ATTACK(31) / "
                       "KNIFE_ATTACK1..3(170/172/174) 均带 eventName=awm_legend_t_sec_fire，"
                       "eventFrame 缺失 → EventTime=0，进入动作后第一个预测帧触发。"
                       "另 FireFunctions.FireEvent 的 case 11/59 也会经 AddSound 播 "
                       "_sec_fire / _fire3（同预测帧）。",
            "eventTimeMs": 0,
            "eventTimeMsSource": "WeaponAnimationData.cs:27-33",
            "stateId": 20,
            "sources": SRC["notice"] + SRC["fire_chain"] + SRC["viewanim"],
        },
    ]

    # ---- 仍查不到的（严禁编帧号/时刻） ---------------------------------------
    missing = [
        {
            "specEvent": "shoot_3p",
            "status": "未找到",
            "reason": "awm_legend_t 音效 bundle 的 9 个 AudioClip 中没有 *_3p / *_third 资产；"
                      "TpsWeaponSoundPredicateSystem.cs:26 只把 StateId 17 映射到 'reload'，"
                      "没有为 StateId 15 注册第三人称开火音；"
                      "WeaponUtil.PlayerSound 用 isMyPlayer 控制 2D 音衰减而非切换 clip。"
                      "因此 spec.audio.events 里的 shoot_3p 无独立 clip、无独立触发规则。",
            "sources": SRC["tps"] + SRC["fire_chain"] + SRC["bundle"],
        },
        {
            "specEvent": "bolt",
            "status": "未找到",
            "reason": "音效 bundle 中无 *_bolt / *_pull / *_charger 资产；"
                      "ViewAnimConfig 的 TORSO_PULL_CHARGER(18) 无 eventName → "
                      "WeaponNoticePlayBackSystem.cs:70-72 直接 return；"
                      "TpsWeaponSoundPredicateSystem 只注册 17。"
                      "拉栓音可能混在 awm_legend_t_reload 或 awm_legend_t_fire 里，"
                      "但源码与资源包都找不到独立触发点，故不填时刻、不猜。",
            "sources": SRC["notice"] + SRC["tps"] + SRC["bundle"] + SRC["viewanim"],
        },
        {
            "specEvent": "inspect / inspect_empty",
            "status": "未找到",
            "reason": "音效 bundle 中无 *_inspect / *_showgun 资产；"
                      "ViewAnimConfig 的 TORSO_SHOWGUN(44) 无 eventName；"
                      "源码中 CheckShowGun / ShowGunFrameAction 未发现独立 Play2DSound 调用。"
                      "两个 spec 事件名也找不到区分依据（空/非空弹匣），不编造。",
            "sources": SRC["notice"] + SRC["bundle"] + SRC["viewanim"],
        },
        {
            "specEvent": "put_away",
            "status": "确认不存在",
            "reason": "ENG-02 已确认 ViewAnimConfig 24 条 action 与 AnimationConstant.cs 505 个常量"
                      "均无收枪动作；音效 bundle 9 个 AudioClip 中也无 put_away / *_away 资产。"
                      "spec.audio.events 的 put_away 只是通用事件名清单里的一项。",
            "sources": SRC["bundle"] + SRC["viewanim"],
        },
        {
            "specEvent": "后坐 / 枪口特效的动画事件帧",
            "status": "未找到",
            "reason": "ViewAnimConfig 24 条 action 无相关属性；AddFireSparks（WeaponUtil.cs:114-135）"
                      "由开火命令链同步调用、与 muzzle flash 相关但无 eventFrame 数值；"
                      "未找到绑定到动画事件帧的 FrameAction。",
            "sources": SRC["fire_chain"] + SRC["viewanim"],
        },
    ]

    result = {
        "schema": "ssjj-audio-events/1",
        "weapon": "awm_legend_t",
        "generatedBy": "tools/export_audio_events.py",
        "sourceRoot": str(root),
        "authority": {
            "audioBundle": SOUND_BUNDLE,
            "weaponBundle": WEAPON_BUNDLE,
            "viewAnimConfig": "notes/viewanim-config/viewanim-config.json",
            "eventTimeRule": "WeaponAnimationData.cs:27-33 —— 仅当 <action eventFrame=...> 存在时"
                             "才赋值 EventTime；本枪 24 条 action 全部没有该属性 → EventTime 恒为默认 0。",
            "eventFireRule": "WeaponNoticePlayBackSystem.cs:90 —— if (currentTime > EventTime)；"
                             "currentTime = GetViewAnimDuration - RemainTime（ViewAnimSystem.cs:144），"
                             "起点为 0，故严格 >0 才播放，即起点之后的第一个预测帧。",
            "fireCommandRule": "AbstractFireAction.cs:23-26,61-64 + FireFunctions.cs:376-398 —— "
                               "开火音效在 onFireActions 链内同步触发，非动画事件帧驱动。",
            "soundConfigRule": "SounfConfigXmlAsset.cs:9-27 + SoundConfigData.cs:41-62 —— "
                               "武器包 <soundConfig> 用 eventId→url 映射，仅含 10047/10048 两个特效音。",
        },
        "audioClips": clips,
        "soundConfigRaw": "notes/audio-events/soundconfig.xml",
        "viewAnimEventNames": {
            a["name"]: a["eventName"] for a in actions if a["eventName"]
        },
        "confirmed": confirmed,
        "missing": missing,
        "specAudioEvents": json.loads(
            (PORT / "src/main/resources/assets/ssjjport/spec/awm_legend_t.json")
            .read_text(encoding="utf-8"))["audio"]["events"],
        "specAudioEventsNote": "spec.audio.events 是通用事件名清单（build_weapon_spec.py 从数据表推导），"
                               "与本枪 9 个真实 AudioClip 名不是同一套命名；"
                               "本表给出二者的映射与差异，不把 spec 事件名当作资产名。",
    }
    p = OUT / "audio-events.json"
    p.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[write] {p}  {p.stat().st_size:,} B")
    print(f"[info ] 已确认 {len(confirmed)} 条 / 未找到或确认不存在 {len(missing)} 条")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
