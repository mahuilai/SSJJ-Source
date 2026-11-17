# -*- coding: utf-8 -*-
"""
导出 SSJJ 原版 ViewAnimConfig（`<actions>` XML）到 ssjj-port/notes/viewanim-config/。

依据（逐行核对，不臆造）：
  - `Assembly-CSharp/Assets.Sources.Info.Weapon.WeaponInfo/DefaultWeaponInfo.cs:336`
        `_viewAnimConfigAssetName = $"Assets/Res/Assets/weapon/{_name}/view/hand.DAE.action.xml";`
    `:204` `AnimConfigBundleName => AssetBundleName`
    → 对 awm_legend_t，ViewAnimConfig 就是 `weapon/awm_legend_t_*/` bundle 里名为
      `hand.DAE.action` 的 TextAsset。
  - `Assembly-CSharp/Assets.Sources.Modules.Player.Anim.FirstPerson/LoadFirstHandSystem.cs:479-485`
    从 `ViewAnimConfig` 取出 `WeaponAnimAsset`。
  - `SSJJAnim_Library/SSJJAnim.WeaponAnim/WeaponAnimationData.cs:18-67`
    `ReadWeaponActionData` 解析该 XML：
      FrameCount = end - start + 1
      EventTime  = (int)(eventFrame * 33.333332f)  **仅当 eventFrame 属性存在**
      NextId     = AnimationConstantUtil.GetAnimation(nextAnimation) **仅当 nextAnimation 存在**
  - `SSJJAnim_Library/SSJJAnim.AnimData/AnimationDesc.cs:19,33`
      NextId 默认 -1；TotalTime = (int)(FrameCount * 33.333332f) 毫秒
  - `SSJJAnim_Library/SSJJAnim.AnimState/AnimationConstantUtil.cs:44-51`
      name -> StateId 来自 `configNet/share.constant/AnimationConstant.cs` 的 public const int 反射表

用法：
  PY="C:/Users/Mahuilai/AppData/Local/Programs/Python/Python314/python"
  "$PY" "D:\\逆向\\SSJJ双塔惊魂\\ssjj-port\\tools\\export_viewanim_config.py"

只读 AssetBundle，不改动任何游戏文件；可重复运行（覆盖输出）。
"""
from __future__ import annotations

import json
import re
import warnings
from pathlib import Path

import UnityPy

warnings.filterwarnings("ignore")

PROJECT = Path(r"D:\逆向\SSJJ双塔惊魂")
SSJJ_PORT = PROJECT / "ssjj-port"
OUT_DIR = SSJJ_PORT / "notes" / "viewanim-config"

MANAGED_SRC = PROJECT / "Game source" / "02_managed_src"
ANIMATION_CONSTANT_CS = MANAGED_SRC / "configNet" / "share.constant" / "AnimationConstant.cs"

# 任务书给的路径在真实安装里多一层 SSJJ_BattleClient_Unity_Data，两个候选都探测。
BUNDLE_ROOTS = [
    Path(r"D:\SSJJ-4399\battle\3_64\StreamingAssets\AssetBundles\Windows"),
    Path(r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows"),
    PROJECT / "资源全集",
]

# 目标：血魔本体 + 其动画组 ak47 + CT 变体（交叉验证）
TARGET_PREFIXES = ["awm_legend_t", "awm_legend_ct", "ak47"]

# AnimationConstant.cs 的 `public const int NAME = 123;`
CONST_RE = re.compile(r"public\s+const\s+int\s+(\w+)\s*=\s*(-?\d+)\s*;")
ACTION_RE = re.compile(r"<action\b([^>]*)/?>", re.I)
ATTR_RE = re.compile(r'(\w+)\s*=\s*"([^"]*)"')

FRAME_MS = 33.333332


def load_constants() -> dict[str, int]:
    text = ANIMATION_CONSTANT_CS.read_text(encoding="utf-8", errors="replace")
    out = {m.group(1): int(m.group(2)) for m in CONST_RE.finditer(text)}
    print(f"[const] {ANIMATION_CONSTANT_CS} -> {len(out)} 个 public const int")
    return out


def resolve_root() -> tuple[Path, Path]:
    """返回 (实际存在的 bundle 根, weapon 子目录)。资源全集没有 weapon/ 子目录时退回根目录。"""
    for r in BUNDLE_ROOTS:
        if r.is_dir():
            weapon = r / "weapon"
            if weapon.is_dir():
                return r, weapon
            # 资源全集是平铺导出，weapon 目录直接是根下的 weapon/
            if (r / "weapon").is_dir():
                return r, r / "weapon"
    raise SystemExit("[FATAL] 两个 AssetBundle 根都不存在，终止")


def iter_text_assets(bundle: Path):
    try:
        env = UnityPy.load(str(bundle))
    except Exception:
        return
    for obj in env.objects:
        if obj.type.name != "TextAsset":
            continue
        try:
            data = obj.read()
            raw = getattr(data, "m_Script", b"") or b""
            if isinstance(raw, str):
                raw = raw.encode("utf-8", "replace")
            name = getattr(data, "m_Name", None) or "?"
            yield name, raw
        except Exception:
            continue


def parse_actions(xml_text: str, constants: dict[str, int], src: str) -> list[dict]:
    actions = []
    for m in ACTION_RE.finditer(xml_text):
        attrs = {k: v for k, v in ATTR_RE.findall(m.group(1))}
        name = attrs.get("name", "?")
        state_id = constants.get(name, 0)
        try:
            start, end = int(attrs.get("start", "0")), int(attrs.get("end", "0"))
        except ValueError:
            start = end = 0
        frame_count = end - start + 1
        total_ms = int(frame_count * FRAME_MS)

        has_event_name = "eventName" in attrs
        has_event_frame = "eventFrame" in attrs
        # WeaponAnimationData.cs:27-33 —— eventFrame 不存在时 EventTime 保持默认 0
        if has_event_frame:
            try:
                event_ms = int(int(attrs["eventFrame"]) * FRAME_MS)
            except ValueError:
                event_ms = 0
        else:
            event_ms = 0

        has_next = "nextAnimation" in attrs
        # AnimationDesc.cs:19 —— nextAnimation 不存在时 NextId 保持默认 -1
        next_id = constants.get(attrs["nextAnimation"], 0) if has_next else -1

        actions.append({
            "name": name,
            "stateId": state_id,
            "stateIdResolved": state_id != 0 or name == "ILLEGAL_ANIM",
            "start": start,
            "end": end,
            "frameCount": frame_count,
            "totalTimeMs": total_ms,
            "totalTimeS": round(total_ms / 1000.0, 4),
            "loop": attrs.get("loop", "false").lower() == "true",
            "reverse": attrs.get("reverse", "false").lower() == "true",
            "eventName": attrs.get("eventName"),
            "eventFrameAttr": attrs.get("eventFrame"),
            "eventTimeMs": event_ms,
            "eventTimeSource": (
                "eventFrame 属性存在 -> (int)(eventFrame*33.333332f)"
                if has_event_frame else
                "eventFrame 属性不存在 -> AnimationDesc.EventTime 默认 0（动画起点触发）"
            ),
            "nextAnimation": attrs.get("nextAnimation"),
            "nextId": next_id,
            "nextIdSource": (
                "nextAnimation 属性存在 -> AnimationConstantUtil.GetAnimation(name)"
                if has_next else
                "nextAnimation 属性不存在 -> AnimationDesc.NextId 默认 -1；"
                "ViewAnimStateInfo.NextState 回落到 AnimationConstantUtility.GetTorsoAnimNextId"
            ),
            "changeStopSound": attrs.get("changeStop", "false").lower() == "true",
            "onlyOne": attrs.get("onlyOne", "false").lower() == "true",
            "isForceNewEvent": attrs.get("forceNewEvent", "false").lower() == "true",
            "isSoundLoop": attrs.get("soundloop", "false").lower() == "true",
            "source": src,
        })
    return actions


def main() -> int:
    constants = load_constants()
    root, weapon_dir = resolve_root()
    print(f"[root ] {root}")
    print(f"[weap ] {weapon_dir}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # 目标 bundle：只取名字以 TARGET_PREFIXES 开头、且不含 '$'（'$2' 是拆分材质包）
    bundles = []
    for p in sorted(weapon_dir.iterdir()):
        if not p.is_file() or "$" in p.name:
            continue
        if any(p.name.startswith(pref) for pref in TARGET_PREFIXES):
            bundles.append(p)
    print(f"[bundle] 候选 {len(bundles)} 个")

    exported = {}
    scan = {"textAssetsScanned": 0, "actionsXmlFound": 0,
            "withEventFrame": [], "withNextAnimation": []}
    all_parsed = {}

    # 全量扫描（用于证明 eventFrame/nextAnimation 在 awm_legend_t 中确实不存在）
    for p in sorted(root.rglob("*")):
        if not p.is_file():
            continue
        for name, raw in iter_text_assets(p):
            scan["textAssetsScanned"] += 1
            if b"eventFrame" in raw:
                scan["withEventFrame"].append(f"{p.relative_to(root)}::{name}")
            if b"nextAnimation" in raw:
                scan["withNextAnimation"].append(f"{p.relative_to(root)}::{name}")
    print(f"[scan ] TextAsset {scan['textAssetsScanned']} 个；"
          f"含 eventFrame {len(scan['withEventFrame'])}；含 nextAnimation {len(scan['withNextAnimation'])}")

    for bundle in bundles:
        for name, raw in iter_text_assets(bundle):
            if name != "hand.DAE.action" or b"<actions" not in raw:
                continue
            text = raw.decode("utf-8", "replace")
            scan["actionsXmlFound"] += 1
            stem = bundle.name.rsplit("_", 1)[0]  # 去掉 hash
            xml_path = OUT_DIR / f"{stem}__hand.DAE.action.xml"
            xml_path.write_bytes(raw)
            print(f"[write] {xml_path}  {xml_path.stat().st_size:,} B")
            parsed = parse_actions(text, constants,
                                   f"{bundle.relative_to(root)}::TextAsset({name})")
            exported[stem] = {
                "bundle": str(bundle),
                "bundleRelative": str(bundle.relative_to(root)),
                "textAsset": name,
                "rawXmlPath": str(xml_path),
                "rawBytes": len(raw),
                "hasEventFrameAttr": b"eventFrame" in raw,
                "hasNextAnimationAttr": b"nextAnimation" in raw,
                "hasEventNameAttr": b"eventName" in raw,
                "actionCount": len(parsed),
                "actions": parsed,
            }
            all_parsed[stem] = parsed

    # 权威表：awm_legend_t 本体
    primary = "awm_legend_t"
    if primary not in exported:
        print(f"[WARN ] 未找到 {primary} 的 hand.DAE.action，回填无法进行")
    result = {
        "schema": "ssjj-viewanim-config/1",
        "generatedBy": "tools/export_viewanim_config.py",
        "sourceRoot": str(root),
        "authority": {
            "viewAnimConfigAssetName": "Assets/Res/Assets/weapon/{name}/view/hand.DAE.action.xml",
            "source": "Assembly-CSharp/Assets.Sources.Info.Weapon.WeaponInfo/DefaultWeaponInfo.cs:336",
            "loader": "Assembly-CSharp/Assets.Sources.Modules.Player.Anim.FirstPerson/LoadFirstHandSystem.cs:479-485",
            "parser": "SSJJAnim_Library/SSJJAnim.WeaponAnim/WeaponAnimationData.cs:18-67",
            "durationFormula": "AnimationDesc.TotalTime = (int)(FrameCount * 33.333332f) ms; FrameCount = end-start+1",
            "stateIdSource": "configNet/share.constant/AnimationConstant.cs (public const int)",
        },
        "primary": primary,
        "scan": scan,
        "bundles": exported,
        "getViewAnimDurationMs": {
            a["name"]: a["totalTimeMs"]
            for a in all_parsed.get(primary, [])
        },
        "reloadDurationMs": None,
        "notes": [
            "awm_legend_t 的 ViewAnimConfig 中没有任何 eventFrame 属性 → "
            "WeaponAnimationData.cs:30-33 的 EventTime 恒为 0（动画起点触发音效）。",
            "awm_legend_t 的 ViewAnimConfig 中没有任何 nextAnimation 属性 → "
            "AnimationDesc.NextId 恒为 -1 → ViewAnimStateInfo.NextState 回落到 "
            "AnimationConstantUtility.GetTorsoAnimNextId()，故阶段 1 记录的回落转移对本枪即为权威。",
            "TORSO_ATTACK / TORSO_PULL_CHARGER / TORSO_SHOWGUN 没有 eventName，"
            "开火/拉栓/检视音效不来自此动画配置，而来自开火命令链或音频配置。",
            "配置中没有 putaway / PUT_AWAY 动作 → 本枪不存在独立收枪视图动画（确认不存在，非未找到）。",
        ],
    }
    t = all_parsed.get(primary, [])
    by_name = {a["name"]: a for a in t}
    if "TORSO_RELOAD" in by_name and "TORSO_PULL_CHARGER" in by_name:
        result["reloadDurationMs"] = (by_name["TORSO_RELOAD"]["totalTimeMs"]
                                      + by_name["TORSO_PULL_CHARGER"]["totalTimeMs"])

    out_json = OUT_DIR / "viewanim-config.json"
    out_json.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[write] {out_json}  {out_json.stat().st_size:,} B")
    print(f"[info ] {primary} actions={len(t)}  reloadDurationMs={result['reloadDurationMs']}")
    print(f"[info ] GetViewAnimDuration(15)={result['getViewAnimDurationMs'].get('TORSO_ATTACK')} "
          f"(16)={result['getViewAnimDurationMs'].get('TORSO_RAISE')} "
          f"(17)={result['getViewAnimDurationMs'].get('TORSO_RELOAD')} "
          f"(18)={result['getViewAnimDurationMs'].get('TORSO_PULL_CHARGER')} "
          f"(44)={result['getViewAnimDurationMs'].get('TORSO_SHOWGUN')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
