# -*- coding: utf-8 -*-
"""从 SSJJ 原版数据表 + 反编译源码生成 awm_legend_t 的武器规格。

输出：
  src/main/resources/assets/ssjjport/spec/awm_legend_t.json   模组运行时直读
  notes/weapon-spec.md                                         人读对照表

来源全部是本地实测文件，不做任何猜测：数值取 tables_json，参数含义取反编译源码。
可重复运行（幂等）。
"""
import datetime
import json
import os
import re

ROOT = r"D:\逆向\SSJJ双塔惊魂"
TABLES = os.path.join(ROOT, r"Game source\06_singleplayer\tables_json")
SRC = os.path.join(ROOT, r"Game source\02_managed_src")
OUT = os.path.join(ROOT, r"ssjj-port")
SPEC_PATH = os.path.join(OUT, r"src\main\resources\assets\ssjjport\spec\awm_legend_t.json")
NOTE_PATH = os.path.join(OUT, r"notes\weapon-spec.md")

GUN = "awm_legend_t"


def load_table(name):
    with open(os.path.join(TABLES, name), "r", encoding="utf-8") as f:
        return json.load(f)


def rows_by(table, key, value):
    return [r for r in table.get("rows", []) if str(r.get(key, "")).strip() == str(value)]


def num(v, default=0.0):
    try:
        return float(v)
    except (TypeError, ValueError):
        return default


def nums(s):
    return [num(x) for x in str(s).split(",") if x.strip() != ""]


def read_source(rel):
    p = os.path.join(SRC, rel)
    if not os.path.isfile(p):
        return ""
    with open(p, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def main():
    weapon = load_table("Weapon.json")
    row = rows_by(weapon, "Name", GUN)
    if not row:
        raise SystemExit("Weapon.json 里没有 " + GUN)
    w = row[0]

    # --- 散布参数：顺序来自 AwmLegendSpreadLogic.Parse(..., 6) ---
    spread_src = read_source(
        r"Assembly-CSharp\Assets.Sources.Info.Weapon.Logic.SpreadLogic\AwmLegendSpreadLogic.cs")
    param_order = ["AirParam", "LengthParam1", "LengthParam2",
                   "DuckParam", "DefaultParam", "FovAddParam"]
    m = re.search(r"ParseFloat\(.*?,\s*6\s*\)", spread_src)
    spread_params = {}
    pv = nums(w.get("SpreadParam", ""))
    if len(pv) == 6 and m:
        spread_params = {param_order[i]: pv[i] for i in range(6)}
    l1 = re.search(r"Length2D1\s*=\s*(\d+)", spread_src)
    l2 = re.search(r"Length2D2\s*=\s*(\d+)", spread_src)

    # --- 近战连击帧表：AwmLegendBaseAction 的 WeaponKnifeAttackAction 数组 ---
    action_src = read_source(
        r"Assembly-CSharp\Assets.Sources.Modules.Player.Attack.Action\AwmLegendBaseAction.cs")
    melee = []
    for mm in re.finditer(
            r"SetCurrentAttackRaise\((-?\d+)\)\.SetNextKnifeAttackAnim\((\d+)\)"
            r"\.SetNextKnifeAttackRaise\((\d+)\)\s*\.SetDelayAttackTime\((\d+)\)", action_src):
        melee.append({
            "currentAttackRaise": int(mm.group(1)),
            "nextKnifeAttackAnim": int(mm.group(2)),
            "nextKnifeAttackRaise": int(mm.group(3)),
            "delayAttackTimeMs": int(mm.group(4)),
        })

    # --- 换弹时长来源：DefaultReloadSystem.GetReloadDuration ---
    reload_src = read_source(
        r"weaponPredicateNet.net\weapon.predicateSystem.reloadSystem\DefaultReloadSystem.cs")
    reload_formula = ("GetViewAnimDuration(reloadAnim) + GetViewAnimDuration(18)"
                      if "GetViewAnimDuration" in reload_src else "unknown")

    # --- 关联表 ---
    cross = load_table("WeaponCross.json")
    cross_row = next((r for r in cross["rows"]
                      if str(r.get("Name", "")).strip() == str(w.get("CrossType", "")).strip()
                      or str(r.get("Id", "")).strip() == str(w.get("CrossType", "")).strip()), None)
    rail = load_table("WeaponRail.json")
    rail_row = rows_by(rail, "ResId", w.get("RailParam", ""))
    hole = load_table("WeaponHole.json")
    hole_row = rows_by(hole, "ResId", w.get("HoleParam", ""))

    # --- .anm clip 名（此前 decode_anm.py 实测结果） ---
    clips = [
        {"id": "idle", "source": "TORSO_STAND_blend0", "lengthS": 0.0333, "loop": True},
        {"id": "walk", "source": "TORSO_WALK_blend0", "lengthS": 0.8, "loop": True},
        {"id": "draw", "source": "TORSO_RAISE_blend0", "lengthS": 0.4667, "loop": False},
        {"id": "reload", "source": "TORSO_RELOAD_blend0", "lengthS": 2.5, "loop": False},
        {"id": "inspect", "source": "TORSO_SHOWGUN_blend0", "lengthS": 3.3333, "loop": False},
        {"id": "melee", "source": "TORSO_SECONDARY_ATTACK_blend0", "lengthS": 1.1333, "loop": False},
        {"id": "attack", "source": "TORSO_ATTACK_blend0", "lengthS": 1.1667, "loop": False},
    ]

    spec = {
        "schema": "ssjj-weapon-spec/1",
        "id": GUN,
        "displayName": w.get("StringName", ""),
        "generatedAt": datetime.datetime.now().isoformat(timespec="seconds"),
        "source": {
            "weaponTable": "06_singleplayer/tables_json/Weapon.json",
            "weaponTableRows": weapon.get("row_count", len(weapon["rows"])),
            "weaponTableFields": len(weapon["fields"]),
            "logicSources": [
                "Assets.Sources.Info.Weapon.Logic.SpreadLogic/AwmLegendSpreadLogic.cs",
                "Assets.Sources.Modules.Player.Attack.Action/AwmLegendBaseAction.cs",
                "Assets.Sources.Modules.Player.Attack.WeaponAttack/AwmLegendBasePredicationSystem.cs",
                "Assets.Sources.Modules.Player.Attack.WeaponRaise/AwmLegendRaisePredicactionSystem.cs",
                "weapon.predicateSystem.reloadSystem/DefaultReloadSystem.cs",
            ],
        },
        "fire": {
            "intervalMs": int(num(w.get("AttackInterval", 0))),
            "rpm": round(60000.0 / max(1.0, num(w.get("AttackInterval", 1000))), 2),
            "bulletsPerShot": int(num(w.get("FireBullets", 1))),
            "clipPerShot": int(num(w.get("ClipPerShot", 1))),
            "attackType": w.get("AttackType", ""),
            "specialAttackType": w.get("SpecialAttackType", ""),
            "eventType": w.get("EventType", ""),
        },
        "ammo": {
            "clip": int(num(w.get("MaxClip", 0))),
            "carry": int(num(w.get("MaxCarryClip", 0))),
            "clipCount": int(num(w.get("ClipCount", 1))),
            "reloadType": w.get("ReloadType", ""),
            "reloadDurationRule": reload_formula,
            "cdTimeMs": int(num(w.get("CdTimePara", 0))),
        },
        "spread": {
            "type": w.get("SpreadType", ""),
            "logicClass": "AwmLegendSpreadLogic",
            "paramOrder": param_order,
            "params": spread_params,
            "rawParam": w.get("SpreadParam", ""),
            "length2D1": int(l1.group(1)) if l1 else None,
            "length2D2": int(l2.group(1)) if l2 else None,
            "defaultAccuracy": num(w.get("DefaultAccuracy", 0)),
            "spreadScaleY": num(w.get("SpreadScaleY", 0)),
            "maxInaccuracy": num(w.get("MaxInaccuracy", 0)),
            "accuracyType": w.get("AccuracyType", ""),
            "accuracyDivisor": num(w.get("AccuracyDivisor", 0)),
            "accuracyOffset": num(w.get("AccuracyOffset", 0)),
        },
        "kickback": {"type": w.get("KickbackType", ""), "param": num(w.get("KickbackParam", 0))},
        "movement": {
            "type": w.get("MaxSpeedType", ""),
            "params": nums(w.get("MaxSpeedParam", "")),
            "rawParam": w.get("MaxSpeedParam", ""),
        },
        "hit": {
            "shotDistType": w.get("ShotDistType", ""),
            "shotDistParams": nums(w.get("ShotDistParam", "")),
            "rail": {"type": w.get("RailType", ""), "resId": w.get("RailParam", ""),
                     "asset": rail_row[0].get("AssetName", "") if rail_row else ""},
            "hole": {"type": w.get("HoleType", ""), "resId": w.get("HoleParam", ""),
                     "asset": hole_row[0].get("AssetName", "") if hole_row else ""},
        },
        "melee": {
            "slashSlashMs": int(num(w.get("SlashSlashTime", 0))),
            "slashStabMs": int(num(w.get("SlashStabTime", 0))),
            "stabSlashMs": int(num(w.get("StabSlashTime", 0))),
            "stabStabMs": int(num(w.get("StabStabTime", 0))),
            "delayAttackSlashMs": int(num(w.get("DelayAttackSlashTime", 0))),
            "delayAttackStabMs": int(num(w.get("DelayAttackStabTime", 0))),
            "frameChain": melee,
        },
        "animation": {
            "weaponName": w.get("AnimationWeaponName", ""),
            "thirdType": w.get("ThirdAnimationType", ""),
            "raiseType": w.get("RaiseType", ""),
            "sceneWeaponName": w.get("SceneWeaponName", ""),
            "clips": clips,
        },
        "view": {
            "attach": w.get("Attach", ""),
            "viewEffectModels": w.get("ViewEffectModels", ""),
            "thirdEffectModels": w.get("ThirdEffectModels", ""),
            "uiModels": w.get("UiModels", ""),
            "hideViewHand": w.get("HideViewHand", ""),
            "hideThirdHand": w.get("HideThirdHand", ""),
        },
        "cross": cross_row or {},
        "audio": {
            "bundle": "sound/weapon/awm_legend_t_055dcf5f7532af5f5e1a9ad0a98ddd6c",
            "events": ["draw", "put_away", "shoot", "shoot_3p", "reload_empty",
                       "reload_tactical", "bolt", "inspect", "inspect_empty"],
        },
    }

    os.makedirs(os.path.dirname(SPEC_PATH), exist_ok=True)
    with open(SPEC_PATH, "w", encoding="utf-8") as f:
        json.dump(spec, f, ensure_ascii=False, indent=2)
        f.write("\n")

    # --- 人读对照 ---
    lines = [
        "# awm_legend_t 原版武器规格（阶段 0 产物）",
        "",
        "生成：`tools/build_weapon_spec.py`，数据源 `Game source/06_singleplayer/tables_json` + 反编译源码。",
        "模组运行时直读 `assets/ssjjport/spec/awm_legend_t.json`。",
        "",
        "| 项 | 原版值 | 来源 |",
        "|---|---|---|",
        f"| 名称 | {spec['displayName']} | Weapon.json / StringName |",
        f"| 射击间隔 | {spec['fire']['intervalMs']} ms ({spec['fire']['rpm']} RPM) | AttackInterval |",
        f"| 弹匣 / 备弹 | {spec['ammo']['clip']} / {spec['ammo']['carry']} | MaxClip / MaxCarryClip |",
        f"| 换弹类型 | {spec['ammo']['reloadType']} | ReloadType |",
        f"| 换弹时长规则 | `{reload_formula}` | DefaultReloadSystem.GetReloadDuration |",
        f"| 散布类型 | {spec['spread']['type']} | SpreadType |",
        f"| 散布 6 参数 | `{spec['spread']['rawParam']}` | SpreadParam，顺序见源码 Parse(...,6) |",
        f"| 散布速度阈值 | Length2D1={spec['spread']['length2D1']}, Length2D2={spec['spread']['length2D2']} | AwmLegendSpreadLogic |",
        f"| 后坐 | {spec['kickback']['type']} {spec['kickback']['param']} | KickbackType/Param |",
        f"| 持枪移动速度 | {spec['movement']['rawParam']} ({spec['movement']['type']}) | MaxSpeedParam |",
        f"| 射击距离 | {spec['hit']['shotDistType']} {w.get('ShotDistParam','')} | ShotDistType/Param |",
        f"| 抬枪 | {spec['animation']['raiseType']} | RaiseType |",
        f"| 动画组 | {spec['animation']['weaponName']} | AnimationWeaponName（注意不是 awm） |",
        f"| 第三人称动画 | {spec['animation']['thirdType']} | ThirdAnimationType |",
        f"| 准星 | {spec.get('cross',{}).get('Name') or spec.get('cross',{}).get('Id','')} | WeaponCross.json |",
        "",
        "## 散布 6 参数含义（源码逐行对照）",
        "",
        "`AwmLegendSpreadLogic.Parse` 用 `ParamParseHelp.ParseFloat(..., param, 6)` 按固定顺序读入：",
        "",
        "| 序 | 字段 | 值 | 语义 |",
        "|---|---|---|---|",
    ]
    semantic = ["空中", "速度 > Length2D1", "速度 > Length2D2", "蹲下", "默认(开镜/特殊模式)", "FOV=90 附加"]
    for i, k in enumerate(param_order):
        lines.append(f"| {i} | `{k}` | {spread_params.get(k, '?')} | {semantic[i]} |")
    lines += [
        "",
        "## 近战连击帧表（FrameAction，不是定时器）",
        "",
        "| # | currentAttackRaise | nextAnim | nextRaise | delay(ms) |",
        "|---|---|---|---|---|",
    ]
    for i, c in enumerate(melee):
        lines.append(f"| {i} | {c['currentAttackRaise']} | {c['nextKnifeAttackAnim']} | "
                     f"{c['nextKnifeAttackRaise']} | {c['delayAttackTimeMs']} |")
    lines += [
        "",
        "## 结论",
        "",
        "- 手感的数值/时序/事件帧全部可从原版照抄，不需要 TaCZ 的 `default_state_machine_v2`。",
        "- `AnimationWeaponName = ak47` —— 这把枪用的是 ak47 动画组，别按 awm 名字找 clip。",
        "- 换弹时长不是表里常量，是 `GetViewAnimDuration(reload) + GetViewAnimDuration(18)`，",
        "  所以必须先有完整动画时长表才能精确还原换弹节奏。",
        "",
    ]
    os.makedirs(os.path.dirname(NOTE_PATH), exist_ok=True)
    with open(NOTE_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print("spec ->", SPEC_PATH, os.path.getsize(SPEC_PATH), "B")
    print("note ->", NOTE_PATH, os.path.getsize(NOTE_PATH), "B")
    print("gun  :", spec["displayName"], "interval", spec["fire"]["intervalMs"],
          "ms / clip", spec["ammo"]["clip"], "/ spread params", len(spread_params),
          "/ melee chain", len(melee))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
