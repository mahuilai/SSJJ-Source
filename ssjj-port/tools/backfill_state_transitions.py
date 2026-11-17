# -*- coding: utf-8 -*-
"""
用 notes/viewanim-config/viewanim-config.json 的权威 ViewAnimConfig 数据回填
src/main/resources/assets/ssjjport/spec/state-transitions.json。

只改「能核对」的字段；仍缺的保留「未找到」并注明原因。幂等，可重复运行。

前置：先跑 tools/export_viewanim_config.py
用法：
  PY="C:/Users/Mahuilai/AppData/Local/Programs/Python/Python314/python"
  "$PY" "D:\\逆向\\SSJJ双塔惊魂\\ssjj-port\\tools\\backfill_state_transitions.py"
"""
from __future__ import annotations

import json
from pathlib import Path

P = Path(r"D:\逆向\SSJJ双塔惊魂\ssjj-port")
CFG = P / "notes" / "viewanim-config" / "viewanim-config.json"
SPEC = P / "src" / "main" / "resources" / "assets" / "ssjjport" / "spec" / "state-transitions.json"

# 状态机动作 -> ViewAnimConfig 的 action name
STATE_TO_ACTION = {
    "raise": "TORSO_RAISE",
    "fire": "TORSO_ATTACK",
    "reload": "TORSO_RELOAD",
    "bolt": "TORSO_PULL_CHARGER",
    "inspect": "TORSO_SHOWGUN",
    "melee": "TORSO_SECONDARY_ATTACK",
    "idle": "TORSO_STAND",
    "walk": "TORSO_WALK",
    # putaway 无对应 action，单独处理
}

CFG_REL = "notes/viewanim-config/viewanim-config.json"
XML_REL = "notes/viewanim-config/awm_legend_t__hand.DAE.action.xml"
WEAPON_SPEC = P / "src" / "main" / "resources" / "assets" / "ssjjport" / "spec" / "awm_legend_t.json"

# build_weapon_spec.py 重新生成 awm_legend_t.json 时会丢掉手工追加的
# inputAdaptation 段；这里保留一份权威副本用于补齐（幂等，不覆盖已有配置）。
INPUT_ADAPTATION = {
    "schema": "ssjj-spread-inputs/1",
    "note": "ENG-02 新增：MC 输入域 -> 原版输入域的适配配置。所有数值都有逐行可核对的出处；查不到的写「未找到」并做成可配置常量。",
    "fov": {
        "originalUnscoped": 90,
        "originalUnscopedSource": "SSJJEntitas_Library/.../FovComponent.cs:9 (public int Fov = 90)；configNet/share.constant/PlayerConf.cs:31 DefFov()=90；AwmLegendSpreadLogic.cs:40 判 Fov!=90",
        "originalScoped": 40,
        "originalScopedStatus": "确认（本枪 FovRightAction 第一级开镜）",
        "originalScopedSource": "Assembly-CSharp/Assets.Sources.Modules.Player.Attack.Action/FovRightAction.cs:26-30 (90 -> 40)；由 AwmLegendBasePredicationSystem.cs RightActions.Add(new FovRightAction(contexts)) 挂到本枪",
        "originalScopedSecondZoom": 10,
        "originalScopedSecondZoomSource": "FovRightAction.cs:31-35 (40 -> 10 -> 90)；二级开镜 10，同样 != 90，散布逻辑等价",
        "mcDefaultFov": 70,
        "mcDefaultFovSource": "1.21.1 Yarn GameOptions 构造中 options.fov 的 SimpleOption 默认值 bipush 70（已用 javap -c 核实）；滑杆范围 30..110",
        "mcScopedFov": "未找到",
        "mcScopedFovNote": "MC 没有与 SSJJ 开镜 FOV 一一对应的数值（MC 开镜由模组自行改 FOV，且 FOV 还受疾跑/药水/FOV effect scale 影响）。因此适配层用布尔 isScoping 判定，不把 mcFov 当开镜依据；开镜时返回 originalScoped（可配置）。",
        "mappingRule": "语义映射，不是线性换算：未开镜 -> 90；开镜 -> 非 90。mcFov 只作诊断输入，绝不直接透传给 computeSpread。",
        "scopedFovConfigurable": True,
    },
    "speed": {
        "scale": 2000.0,
        "scaleStatus": "确认（量纲推导，源码 + 项目文档双重佐证）",
        "scaleFormula": "原版 cm/s = MC blocks/tick * 100 (cm/block) * 20 (tick/s) = * 2000",
        "originalUnit": "cm/s",
        "mcUnit": "blocks/tick",
        "originalUnitSource": "STATE.md:134「SSJJ 原生 / 物理 / 快照 | 厘米 (cm) | Z-up」；docs/AI-设计与优化.md:36「位置 X Y Z 物理厘米坐标」、:38「Velocity2D 水平速度（cm/s）」；docs/archive/历史技术摘要.md:87「快照 / 物理（厘米）」",
        "sourceSideCorroboration": "configNet/share.constant/PlayerConf.cs:13 height=170(cm)、:35 RunSpeed()=635(cm/s)、:40 WalkSpeed()=305、:45 CrouchMoveSpeed()=203；physics.net/data/SceneMoveData.cs:8 worldGravity=2032(cm/s^2)、:10 jumpVelocity=681(cm/s)；physics.net/physics.move/PmoveBase.cs:1188 pml.frametime = msec*0.001f（秒）且与 gravity/velocity 相乘 → velocity 为每秒量",
        "mcUnitSource": "1.21.1 Yarn Entity.getVelocity() 返回 Vec3d，量纲 blocks/tick；MC 固定 20 tick/s；1 block = 1 m = 100 cm",
        "threshold1": 350,
        "threshold2": 25,
        "thresholdSource": "AwmLegendSpreadLogic.cs:10-12 (Length2D1=350 / Length2D2=25)；Weapon.json SpreadParam 同值见 spec.spread.length2D1/2",
        "configurable": True,
        "fallback": "若该字段缺失/非数值，SpreadInputs 回落 1.0 并打 WARN（不静默）；此时 350/25 阈值几乎不会触发，属显式降级。",
        "note": "scale 是量纲推导值，不是源码里写死的常量；做成 spec 可配置，便于后续用真实录屏逐帧校准。",
    },
}


def ensure_input_adaptation() -> None:
    """build_weapon_spec.py 重生成后补回配置段；已有配置时不覆盖。"""
    data = json.loads(WEAPON_SPEC.read_text(encoding="utf-8"))
    if "inputAdaptation" in data:
        print(f"[keep ] {WEAPON_SPEC.name} 已有 inputAdaptation")
        return
    data["inputAdaptation"] = INPUT_ADAPTATION
    WEAPON_SPEC.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    print(f"[fix  ] {WEAPON_SPEC} 补回 inputAdaptation（build_weapon_spec.py 重生成会丢）")


def main() -> int:
    ensure_input_adaptation()
    cfg = json.loads(CFG.read_text(encoding="utf-8"))
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    actions = {a["name"]: a for a in cfg["bundles"]["awm_legend_t"]["actions"]}
    dur = cfg["getViewAnimDurationMs"]

    # ---------------------------------------------------------------- 顶层元数据
    spec["viewAnimConfig"] = {
        "status": "已导出（ENG-02）",
        "rawXml": XML_REL,
        "parsedJson": CFG_REL,
        "exporter": "tools/export_viewanim_config.py",
        "authoritySource": cfg["authority"],
        "actionCount": len(actions),
        "reloadDurationMs": cfg["reloadDurationMs"],
        "getViewAnimDurationMs": dur,
        "hasEventFrameAttr": cfg["bundles"]["awm_legend_t"]["hasEventFrameAttr"],
        "hasNextAnimationAttr": cfg["bundles"]["awm_legend_t"]["hasNextAnimationAttr"],
        "scan": {
            "textAssetsScanned": cfg["scan"]["textAssetsScanned"],
            "bundlesWithEventFrame": cfg["scan"]["withEventFrame"],
            "bundlesWithNextAnimation": cfg["scan"]["withNextAnimation"],
        },
        "note": "C# 的 (int) 是向零截断，故 36 帧 = 1199ms 而不是 1200ms；本表数值已按截断复现。",
    }

    spec["durationRule"]["weaponSpecificViewAnimConfig"] = (
        f"已导出：{CFG_REL}（原始 XML {XML_REL}）。每个 StateId 的权威 GetViewAnimDuration "
        "已写入各状态的 runtimeDurationMs。"
    )
    spec["durationRule"]["reload"] = (
        f"GetReloadDuration = GetViewAnimDuration(17) + GetViewAnimDuration(18) = "
        f"{dur.get('TORSO_RELOAD')} + {dur.get('TORSO_PULL_CHARGER')} = "
        f"{cfg['reloadDurationMs']} ms（权威值，DefaultReloadSystem.cs:33-41）"
    )
    spec["durationRule"]["specProxy"] = (
        "specClipLengthMs 来自 ak47.anm decode（build_weapon_spec.py:104-113），是 .anm 骨骼 clip 长度，"
        "与 GetViewAnimDuration 不是同一概念。AnimationTimeline 现在优先使用 runtimeDurationMs，"
        "specClipLengthMs 仅保留作对照，不再用于调度。"
    )

    spec["eventFrameRule"]["weaponSpecificEventFrames"] = (
        "权威结论：awm_legend_t 的 ViewAnimConfig 中每个 <action> 都**没有 eventFrame 属性**。"
        "按 WeaponAnimationData.cs:27-33，EventTime 仅在 eventFrame 存在时赋值，否则保持 "
        "AnimationDesc 的 int 默认值 0；WeaponNoticePlayBackSystem.cs:76-118 判断 currentTime > "
        "EventTime，因此音效在动画起点（第 1 个越过 0 的 tick）触发。全库 2691 个 TextAsset 中仅 4 个"
        "无关武器(highgrenade_deathray* / rpk_hero)含 eventFrame，本枪不属于。"
    )
    spec["eventFrameRule"]["nextAnimation"] = (
        "权威结论：本枪 24 条 <action> 全部**没有 nextAnimation 属性** → AnimationDesc.NextId 默认 -1 "
        "(AnimationDesc.cs:19) → DefaultWeaponAnimInfo.ViewGetNextAnim 返回 -1 → "
        "ViewAnimStateInfo.NextState 的 weaponNextId > 0 判否，回落 "
        "AnimationConstantUtility.GetTorsoAnimNextId()。故阶段 1 记录的回落转移对本枪即为权威规则。"
    )

    # ---------------------------------------------------------------- 逐状态回填
    for state, action_name in STATE_TO_ACTION.items():
        s = spec["states"][state]
        a = actions.get(action_name)
        if a is None:
            print(f"[WARN ] {state}: ViewAnimConfig 无 {action_name}，保持未找到")
            continue

        assert s["stateId"] == a["stateId"], (state, s["stateId"], a["stateId"])
        s["runtimeDurationMs"] = a["totalTimeMs"]
        s["runtimeDurationSource"] = (
            f"{CFG_REL} -> {action_name}: start={a['start']} end={a['end']} "
            f"FrameCount={a['frameCount']}；AnimationDesc.TotalTime=(int)(FrameCount*33.333332f) "
            f"= {a['totalTimeMs']} ms（C# (int) 截断）"
        )
        s["durationAuthoritative"] = True
        s["frameRange"] = {"start": a["start"], "end": a["end"], "frameCount": a["frameCount"]}
        # 幂等：剥离上一次回填追加的尾注后重写，避免重复累积
        base_id_src = str(s.get("stateIdSource", "")).split("；ViewAnimConfig 交叉验证")[0]
        s["stateIdSource"] = (
            base_id_src + f"；ViewAnimConfig 交叉验证：{action_name} -> {a['stateId']} ({CFG_REL})"
        )
        base_proxy_src = str(s.get("specClipLengthSource", "")).split("；【ENG-02】")[0]
        s["specClipLengthSource"] = (
            base_proxy_src + "；【ENG-02】代理值已弃用，调度改用 runtimeDurationMs"
        )

        # XML 的 loop 与 ViewAnimStateInfo.IsLoop 可能不一致，二者都记录
        s["viewAnimConfigLoop"] = a["loop"]
        if bool(a["loop"]) != bool(s.get("loop", False)):
            s["loopDiscrepancyNote"] = (
                f"ViewAnimConfig 写 loop={str(a['loop']).lower()}，但 ViewAnimStateInfo.cs:14-36 的 "
                "IsLoop 硬编码白名单不含该 StateId。ViewAnimSystem.PlayHandAnimation 用 IAnimStateInfo.IsLoop，"
                "WeaponNoticePlayBackSystem 用 IWeaponAnimInfo.ViewAnimIsLoop(XML)。两处语义不同，"
                "本表现在两者都记录，不擅自判定谁覆盖谁。"
            )

        # 音效事件帧：eventName 存在 -> SOUND @ EventTime(0)
        if a["eventName"]:
            ev = {
                "atMs": a["eventTimeMs"],
                "type": "SOUND",
                "name": a["eventName"],
                "source": (
                    f"{XML_REL} <action name={action_name} eventName={a['eventName']}>；"
                    f"eventFrame 属性不存在 -> EventTime=0 (WeaponAnimationData.cs:27-33)"
                ),
                "note": "音效走动画事件帧；EventTime=0 表示动画起点，不是定时器。",
            }
            # 保留已有的非 SOUND 事件（如近战延迟帧）
            s["eventFrames"] = [ev] + [e for e in s.get("eventFrames", []) if e.get("type") != "SOUND"]
        s["animationEventName"] = a["eventName"]
        s["eventTimeMs"] = a["eventTimeMs"]
        s["eventTimeSource"] = a["eventTimeSource"]
        s["nextAnimationAttr"] = a["nextAnimation"]
        s["nextId"] = a["nextId"]
        s["nextIdSource"] = a["nextIdSource"]

        if a["eventName"]:
            s["eventFramesNote"] = (
                f"权威（ENG-02）：{action_name} 的 eventName={a['eventName']}，"
                "eventFrame 属性不存在 → EventTime=0（动画起点触发）。"
                "音效走事件帧，不用定时器。"
            )
        else:
            s["eventFramesNote"] = (
                f"权威（ENG-02）：{action_name} 在 ViewAnimConfig 中没有 eventName 属性 → "
                "该动作不产生动画音效事件；相关音效不来自此配置（见 eventFrameRule）。"
            )
        if state == "melee":
            s["eventFramesNote"] += (
                " 另有 5 个 MELEE_DELAY 事件是 AwmLegendBaseAction.SetDelayAttackTime 的近战延迟帧，"
                "不是音效 eventFrame。"
            )

        # transition 权威性（幂等：覆盖而非追加）
        for t in s.get("transitions", []):
            t["authority"] = (
                "确认（ENG-02）：本枪 ViewAnimConfig 无 nextAnimation → NextId=-1 → "
                "回落 AnimationConstantUtility.GetTorsoAnimNextId 为权威"
            )
        note = "【ENG-02】已确认无 nextAnimation 覆盖，回落转移即权威。"
        if state == "reload":
            note += (
                f" 17->18 两段式与 GetReloadDuration 一致：{dur.get('TORSO_RELOAD')} + "
                f"{dur.get('TORSO_PULL_CHARGER')} = {cfg['reloadDurationMs']} ms；"
                "18 段时长现在为权威 33ms，不再是未找到。"
            )
        if state == "bolt":
            note += (
                "【ENG-02/03】本状态时长现为权威 33ms，AnimationTimeline（唯一时钟）"
                "会按 duration 自动推进；ENG-03 已删除 settleTimelineToIdle 兜底。"
            )
        s["transitionNote"] = note
        print(f"[fill ] {state:<8} id={a['stateId']:>3} dur={a['totalTimeMs']:>5}ms "
              f"event={a['eventName'] or '-'} nextId={a['nextId']}")

    # 清掉所有「未找到」占位型 transition（已确认不存在覆盖）
    for state, s in spec["states"].items():
        s["transitions"] = [
            t for t in s.get("transitions", [])
            if "未找到" not in str(t.get("to", "")) and "未找到" not in str(t.get("when", ""))
        ]

    # 其他陈旧字段清理
    spec["states"]["bolt"]["anmClip"] = "确认不存在（spec clips 无 bolt/18 条目；ViewAnimConfig 有 0 帧占位 action）"
    spec["states"]["bolt"]["specClipLengthMs"] = None
    spec["states"]["bolt"]["specClipLengthSource"] = (
        "确认不存在：spec/awm_legend_t.json animation.clips 无 bolt clip；"
        "权威时长已由 runtimeDurationMs=33ms 给出。"
    )
    spec["states"]["melee"]["audioEventNames"] = ["awm_legend_t_sec_fire"]
    spec["states"]["melee"]["audioEventNamesSource"] = (
        "ViewAnimConfig <action name=TORSO_SECONDARY_ATTACK eventName=awm_legend_t_sec_fire>；"
        "近战帧链另有 awm_legend_t_skill2 (TORSO_KNIFE_ATTACK4)"
    )

    # ---------------------------------------------------------------- putaway
    pw = spec["states"]["putaway"]
    pw["stateId"] = None
    pw["stateIdName"] = "确认不存在"
    pw["stateIdStatus"] = (
        "确认不存在（非未找到）：ViewAnimConfig 24 条 <action> 与 AnimationConstant.cs 505 个常量中"
        "均无 putaway/PUT_AWAY；spec audio.events 的 put_away 只是音频事件名。"
    )
    pw["stateIdSource"] = (
        "configNet/share.constant/AnimationConstant.cs 全表 + " + XML_REL + " 24 条 action + "
        "02_managed_src 全树 grep put_away/putaway/PutAway 均无结果。"
    )
    pw["clip"] = "确认不存在"
    pw["clipSource"] = "确认不存在：ViewAnimConfig 无对应 action"
    pw["anmClip"] = "确认不存在"
    pw["specClipLengthMs"] = "确认不存在"
    pw["specClipLengthSource"] = "确认不存在：无该动作"
    pw["runtimeDurationMs"] = None
    pw["runtimeDurationSource"] = "确认不存在：无该动作"
    pw["loop"] = None
    pw["eventFrames"] = []
    pw["eventFramesNote"] = "确认不存在：无该动作，故无动画事件帧。"
    pw["audioEventNamesSource"] = (
        "spec/awm_legend_t.json audio.events —— 仅证明存在 put_away 音频事件名，"
        "不能证明存在对应 StateId/clip；收枪音效可能由切枪系统直接播放。"
    )
    pw["transitionNote"] = "确认不存在：无该动作，无 transition。"
    pw["resolution"] = (
        "ENG-02 结论：本枪没有独立收枪视图动画。WeaponState 的 PUTAWAY 相位是移植侧骨架，"
        "下阶段应改为「切枪时直接隐藏 viewmodel」，不要伪造一个 StateId。"
    )

    # ---------------------------------------------------------------- gaps
    spec["gaps"] = [
        "【已清零】ViewAnimConfig 已导出（ENG-02）：每个 StateId 的权威 GetViewAnimDuration 毫秒数、"
        "eventName、eventFrame 缺失结论、nextAnimation 缺失结论均已回填。原始 XML 见 " + XML_REL,
        "【已结论，非缺口】本枪所有 <action> 均无 eventFrame 属性 → EventTime 恒为 0；"
        "ENG-03 细化：WeaponNoticePlayBackSystem.cs:90 判严格 currentTime > EventTime，"
        "故在动画起点之后的第一个预测帧触发。均无 nextAnimation → NextId=-1 → "
        "回落 GetTorsoAnimNextId 为权威。",
        "【已结论，非缺口】putaway：确认不存在独立收枪视图动画（不是「未找到」）。",
        "【ENG-03 部分解决】shoot 的触发来源已确认（开火命令链，同一预测帧同步），"
        "其余 shoot_3p / bolt / inspect / inspect_empty 仍为未找到；"
        "详见 notes/audio-events/audio-events.json 与 P1 回填后的 gaps。",
        "【仍缺】后坐(Kickback Sniper 2.0) 与枪口特效的动画事件帧：ViewAnimConfig 无相关 action 属性，"
        "源码里只在开火命令链出现，未找到绑定到动画事件帧的 FrameAction。",
        "【仍缺/待下阶段】ViewAnimConfig 的 loop 属性与 ViewAnimStateInfo.IsLoop 硬编码白名单在 "
        "TORSO_SHOWGUN(44) / TORSO_SPECIAL_ATTACK_END(150) 上不一致，两处消费者不同，未擅自判定优先级。",
        "【ENG-03 已解决】两个并行时钟已合并：AnimationTimeline 为唯一时钟，"
        "WeaponState 通过 StateListener 订阅其状态与权威时长，不再自行计时。",
        "【仍缺】MC 侧开镜 FOV 数值未找到（适配层用布尔 isScoping + spec 可配置常量，见 SpreadInputs）。",
    ]

    SPEC.write_text(json.dumps(spec, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[write] {SPEC}  {SPEC.stat().st_size:,} B")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
