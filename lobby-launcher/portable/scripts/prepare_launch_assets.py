# -*- coding: utf-8 -*-
"""按 launch_config.json 把所选角色/武器包接入离线客户端。

启动器只写配置，不碰游戏目录；本脚本在游戏启动前运行：
  1. 读取配置里的角色、武器、bot 职业；
  2. 从资源全集（缺失时回退资源缓存）复制 player/weapon/$2/动画/音效包；
  3. 按官方 _manifest_cache.xml 的 md5、crc 与 Dependency 更新 AssetBundles 清单。

只新增/更新配置所需条目，不改动其他资源。资源全集还在下载时，
会先校验 md5，半截文件不会被复制。
"""
import hashlib
import json
import os
import re
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

_SCRIPT = Path(__file__).resolve()
_DEFAULT_ROOT = _SCRIPT.parents[3] if _SCRIPT.parent.parent.name == "portable" else _SCRIPT.parents[1]
ROOT = Path(os.environ.get("SSJJ_BUNDLE_ROOT", _DEFAULT_ROOT)).resolve()
GAME = Path(os.environ.get("SSJJ_GAME_DIR", ROOT / "battle" / "3_64")).resolve()
BUNDLE_ROOT = GAME / "SSJJ_BattleClient_Unity_Data" / "StreamingAssets" / "AssetBundles" / "Windows"
MANIFEST = BUNDLE_ROOT / "AssetBundles"
CONFIG = GAME / "launch_config.json"
POOL = Path(os.environ.get("SSJJ_RESOURCE_POOL", ROOT / "resources" / "pool" if (ROOT / "resources" / "pool").is_dir() else ROOT / "资源全集"))
CACHE = Path(os.environ.get("SSJJ_RESOURCE_CACHE", ROOT / "resources" / "cache" if (ROOT / "resources" / "cache").is_dir() else ROOT / "资源缓存"))
FULL_MANIFEST = ROOT / "_manifest_cache.xml"
ANIM_MAP = Path(__file__).with_name("career_anim_map.json")

DEFAULT_CHARACTER = "police"
DEFAULT_WEAPON = "nbr_knife_g"

# 被手工替换过资源的包：清单条目由自定义脚本维护，启动器不去改它的 md5。
# 目前只有换了自定义贴图的角色 sanjiaozhouwoman（主包 + $2 网格包）。
PROTECTED_BUNDLES = {
    "player/sanjiaozhouwoman",
    "player/sanjiaozhouwoman$2",
}

# 原版 HUD 走 MVVM：XxxModel -> XxxViewModel -> uiprefabs/<mode> 预制体 -> ui/<mode> 贴图。
# 这些包缺任何一个，对应 HUD 元素都会静默停在默认图/空白状态。
UI_BUNDLES = [
    "uiprefabs/common",
    "uiprefabs/group",
    "uiprefabs/weapon",
    "uiprefabs/pvecommon",
    "uiprefabs/biounionbase",
    "ui/common",
    "ui/commonfree",
    "ui/peekaboomodel",
    "ui/rpgmodel",
    "ui/pvecommon",
    "ui/howtoplayer",
    "ui/halfloadedres/gamemodetitle",
    "ui/halfloadedres/gamemodel",
    "ui/halfloadedres/gunglory",
    "ui/halfloadedres/newbieguide",
    "ui/halfloadedres/playerpersonalized",
    "ui/halfloadedres/playerraceranksect",
    "ui/halfloadedres/scenebuffermessage",
    "ui/halfloadedres/weaponpendantdrop",
    "ui/halfloadedres/report",
    "ui/halfloadedres/rpgskillstate",
    "ui/halfloadedres/bighead2",
    "ui/halfloadedres/skillprogress",
    "ui/broadswordmodel",
    "ui/bigheadmodel",
    "ui/biomodel",
    "ui/jumpmodel",
    "ui/mechwarriormodel",
    "ui/rpgduelmodel",
    "ui/towerdefensemodel",
    # UiModelRefrence.xml 里还被 blastlikes / rpgarmamentpickinfo 引用，
    # 之前漏配会让这两个 HUD 图标一直加载失败。
    "ui/blastmodel",
    "ui/rpgarmamentmodel",
    "fonts",
    "number",
    "uiconfig",
    "uimaterial",
    "ssjj_shader/ui",
    "ssjj_shader/other",
    "ssjj_shader/common",
]

# 原版战斗里由系统直接请求、不在 UI 包依赖链上的资源。
# 注意：playerhpbar（头顶血条）必须保持未暂存——血条对象在离线环境下实体销毁时
# 触发原生崩溃（sys_trace 实测，2026-10-22），16:55 可玩版本即无此包。
# 缺它只会在 offline.log 每帧刷一条 asset not exist WARN（无害）。
GAMEPLAY_BUNDLES = [
    "effectprefab/hole",
    "effectprefab/rail",
    "ui/load/loadconfig",
    "ui/halfloadedres/bossdescribe",
    "accessory/other",
]


def log(msg):
    print(msg)
    try:
        (GAME / "log").mkdir(exist_ok=True)
        with open(GAME / "log" / "launcher.log", "a", encoding="utf-8") as f:
            f.write(msg + "\n")
    except Exception:
        pass


def load_config():
    try:
        with open(CONFIG, encoding="utf-8") as f:
            return json.load(f)
    except Exception as ex:
        log("prepare: config not readable (%r), using defaults" % ex)
        return {}


def md5_file(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def load_official_manifest():
    """小写 name -> {'md5': str, 'crc': str, 'deps': [str]}。"""
    result = {}
    if not FULL_MANIFEST.is_file():
        log("prepare: official manifest missing: %s" % FULL_MANIFEST)
        return result
    try:
        root = ET.parse(FULL_MANIFEST).getroot()
    except Exception as ex:
        log("prepare: official manifest parse failed: %r" % ex)
        return result
    for node in root.findall("AssetBundle"):
        name = node.get("name")
        if not name:
            continue
        result[name.lower()] = {
            "name": name,
            "md5": (node.get("md5") or "").lower(),
            "crc": node.get("crc") or "0",
            "deps": [d.get("name") for d in node.findall("Dependency") if d.get("name")],
        }
    return result


def load_anim_map():
    try:
        with open(ANIM_MAP, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def split_bundle(name):
    if "/" not in name:
        return "", name
    return name.rsplit("/", 1)


def find_source(name, info):
    """返回 (源文件, md5)。优先按官方 md5 找资源全集，再按文件名/资源缓存找。"""
    category, leaf = split_bundle(name)
    md5 = info.get("md5") or ""
    pool_dir = POOL / category if category else POOL

    if pool_dir.is_dir():
        if md5:
            exact = pool_dir / ("%s_%s" % (leaf, md5))
            if exact.is_file():
                return exact, md5
        matches = sorted(pool_dir.glob(leaf + "_*"))
        matches = [p for p in matches if re.fullmatch(re.escape(leaf) + r"_[0-9a-f]{32}", p.name, re.IGNORECASE)]
        if matches:
            found_md5 = matches[0].name.rsplit("_", 1)[1].lower()
            return matches[0], found_md5

    if md5:
        cached = CACHE / md5 / "data"
        if cached.is_file():
            return cached, md5
    return None, md5


def ensure_bundle(name, official, changed, skipped):
    info = official.get(name.lower())
    if not info:
        log("prepare: %s not in official manifest, skipped" % name)
        skipped.append(name)
        return None
    source, md5 = find_source(name, info)
    if source is None:
        log("prepare: MISSING source for %s (md5=%s)" % (name, info["md5"]))
        skipped.append(name)
        return None
    if md5 != info["md5"]:
        log("prepare: md5 mismatch name=%s found=%s expected=%s" % (name, md5, info["md5"]))
        skipped.append(name)
        return None
    actual = md5_file(source)
    if actual != md5:
        log("prepare: source md5 mismatch (partial download?) %s actual=%s expected=%s, skipped" % (source, actual, md5))
        skipped.append(name)
        return None

    category, leaf = split_bundle(name)
    dest_dir = BUNDLE_ROOT / category if category else BUNDLE_ROOT
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / ("%s_%s" % (leaf, md5))
    if not dest.is_file() or dest.stat().st_size != source.stat().st_size:
        shutil.copy2(source, dest)
        changed.append(name)
        log("prepare: copied %s <- %s" % (name, source))
    return {
        "name": info["name"],
        "md5": md5,
        "crc": info["crc"],
        "deps": info["deps"],
        "file": dest,
    }


def read_config_names(cfg):
    career = (cfg.get("career") or "").strip()
    if not career or career.lower() == "terrorist":
        career = DEFAULT_CHARACTER
    weapon = (cfg.get("weapon") or "").strip() or DEFAULT_WEAPON
    bot_career = (cfg.get("bot_career") or "").strip()
    if bot_career.lower() == "terrorist":
        bot_career = "pandora_t"
    if not bot_career:
        bot_career = DEFAULT_CHARACTER
    try:
        bot_count = max(0, min(int(cfg.get("bot_count") or 0), 8))
    except Exception:
        bot_count = 0
    return career, weapon, bot_career, bot_count


def resolve_hand(career, requested, official, anim_map=None):
    """与 OfflineGameSetting.ResolveHand 保持一致：角色专属手模优先，
    没有专属包时按骨架性别回退（女角色用 viewhand/woman），最后才用配置的手模。"""
    hand = (career or "").strip()
    if hand and ("viewhand/" + hand).lower() in official:
        return hand
    anim_type = (anim_map or {}).get(hand)
    if anim_type is None and anim_map and hand:
        for key, value in anim_map.items():
            if key.lower() == hand.lower():
                anim_type = value
                break
    if (anim_type or "").lower() == "woman" and "viewhand/woman" in official:
        return "woman"
    return "woman" if (requested or "man").lower() == "woman" else "man"


def write_back_hand(cfg, hand):
    """把手模回退结果写回 launch_config.json（启动器先写配置，再跑本脚本）。"""
    current = (cfg.get("hand") or "").strip()
    if current == hand:
        return
    try:
        cfg["hand"] = hand
        tmp = str(CONFIG) + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(cfg, f, ensure_ascii=False, indent=2)
            f.write("\n")
        os.replace(tmp, CONFIG)
        log("prepare: hand %r -> %r in launch_config.json" % (current, hand))
    except Exception as ex:
        log("prepare: write hand failed %r" % ex)


def anim_bundles_for(career, anim_map, official):
    """与 DefaultCareerInfo 一致：查 animConfig 映射；未收录的职业按原版语义
    直接使用同名动画包（playeranim/<career>），都没有时才回退 manCT。"""
    anim_type = anim_map.get(career)
    if anim_type is None and career and ("playeranim/" + career).lower() in official:
        anim_type = career
    candidates = []
    if anim_type:
        candidates.append(anim_type)
    candidates.append("manCT")
    names = []
    for candidate in candidates:
        if ("playeranim/" + candidate).lower() in official:
            names.append("playeranim/" + candidate)
            dyn = "playerAnimDynamic/" + candidate
            if dyn.lower() in official:
                names.append(dyn)
            break
    if not names:
        log("prepare: no animation bundle available for career %s" % career)
    return names


def main():
    cfg = load_config()
    career, weapon, bot_career, bot_count = read_config_names(cfg)
    log("prepare: career=%s weapon=%s bot=%s x%d" % (career, weapon, bot_career, bot_count))

    official = load_official_manifest()
    anim_map = load_anim_map()
    changed = []
    skipped = []
    required = []

    def add(name):
        if name not in required:
            required.append(name)

    # 配置类包：careerConfig（角色属性）、animConfig（职业->动画类型映射）、第一人称动画混合配置。
    # 缺 playeranim/default 时 CareerData 会把职业名当动画类型，导致女性角色套男性动画。
    add("player/default")
    add("playeranim/default")
    add("weapon/default")

    add("player/" + career)
    add("player/" + career + "$2")
    for name in anim_bundles_for(career, anim_map, official):
        add(name)
    if bot_count > 0 and bot_career != career:
        add("player/" + bot_career)
        add("player/" + bot_career + "$2")
        for name in anim_bundles_for(bot_career, anim_map, official):
            add(name)

    # 5 个背包 × 4 槽（与 OfflineSnapshotSystem 一致）：主 / 副 / 近战 / 投掷。
    slot_weapons = []
    for bag in cfg.get("bags") or []:
        if not isinstance(bag, dict):
            continue
        for key in ("primary", "secondary", "melee", "throwable"):
            w = (bag.get(key) or "").strip()
            if w and w not in slot_weapons:
                slot_weapons.append(w)
    # 客户端缺包时会回落到这些默认槽位，预热清单里必须同时带上。
    for w in (weapon, "92fs" if weapon == "deagle" else "deagle", "nbr_knife_g", "grenade"):
        if w not in slot_weapons:
            slot_weapons.append(w)
    for w in slot_weapons:
        add("weapon/" + w)
        add("weapon/" + w + "$2")
        add("sound/weapon/" + w)
    hand = resolve_hand(career, cfg.get("hand"), official, anim_map)
    add("viewhand/" + hand)
    write_back_hand(cfg, hand)

    # [SKIN] 皮肤包：weaponskin/<weapon_skin>、playerskin/<career_skin>。
    # 皮肤与基础武器/角色分包（weaponskin/X 与 weapon/X 是两个独立 bundle），
    # 不预装的话 SkinName 写了也会因缺包静默回落默认外观。
    w_skin = (cfg.get("weapon_skin") or "").strip()
    c_skin = (cfg.get("career_skin") or "").strip()
    if w_skin:
        if ("weaponskin/" + w_skin).lower() in official:
            add("weaponskin/" + w_skin)
            add("weaponskin/" + w_skin + "$2")
        else:
            log("prepare: weaponskin %r not in official manifest, ignored" % w_skin)
    if c_skin:
        if ("playerskin/" + c_skin).lower() in official:
            add("playerskin/" + c_skin)
            add("playerskin/" + c_skin + "$2")
        else:
            log("prepare: playerskin %r not in official manifest, ignored" % c_skin)
    if w_skin or c_skin:
        log("prepare: skin weapon=%r career=%r" % (w_skin, c_skin))

    # [SKIN-PER-SLOT] 每个背包槽位独立皮肤（bags[i].<slot>_skin）。
    # 皮肤跟武器走：换背包/换枪时 ApplyOfflineSkin 按槽位取，缺包会静默回落默认外观，
    # 所以这里必须把全部槽位skin一起装进清单。
    slot_skin_keys = ("primary_skin", "secondary_skin", "melee_skin", "throwable_skin")
    bag_skins = []
    for bag in (cfg.get("bags") or []):
        if not isinstance(bag, dict):
            continue
        for key in slot_skin_keys:
            skin = (bag.get(key) or "").strip()
            if skin and skin not in bag_skins:
                bag_skins.append(skin)
    for skin in bag_skins:
        if ("weaponskin/" + skin).lower() in official:
            add("weaponskin/" + skin)
            add("weaponskin/" + skin + "$2")
        else:
            log("prepare: weaponskin %r (slot) not in official manifest, ignored" % skin)
    if bag_skins:
        log("prepare: slot skins=%d %s" % (len(bag_skins), ",".join(bag_skins)))

    for name in UI_BUNDLES:
        add(name)
    # [OFFLINE-PATCH] HUD 角色头像/荣誉/战绩等是按“每个职业一个 bundle”拆分的
    # （ui/halfloadedres/pvpplayerstate/<career>），必须整目录暂存，否则左下角角色信息无图。
    for sub in ("ui/halfloadedres/pvpplayerstate", "ui/halfloadedres/pveplayerstate"):
        sub_dir = POOL / sub
        if sub_dir.is_dir():
            for f in sub_dir.iterdir():
                m = re.match(r"^(.*)_[0-9a-f]{32}$", f.name)
                if m:
                    add(sub + "/" + m.group(1))
    for extra in ("ui/halfloadedres/achievement", "ui/halfloadedres/monsterskillicons",
                  "ui/halfloadedres/pve2skilltree", "ui/halfloadedres/pveskilltree",
                  "ui/halfloadedres/expression", "ui/halfloadedres/bossTitle",
                  "ui/halfloadedres/gameModeTitle"):
        add(extra)
    for name in GAMEPLAY_BUNDLES:
        add(name)

    entries = {}
    for name in required:
        entry = ensure_bundle(name, official, changed, skipped)
        if entry:
            entries[name] = entry

    # 依赖：官方有的照抄；没有时主包<->$2 互依（保证 $2 里的网格被加载）。
    # 传递闭包（HUD 包 -> ui/common -> ssjj_shader/other -> ...），一层不够。
    deps_by_name = {}
    dep_queue = list(required)
    dep_seen = set()
    while dep_queue:
        name = dep_queue.pop(0)
        if name.lower() in dep_seen:
            continue
        dep_seen.add(name.lower())
        entry = entries.get(name)
        if not entry:
            continue
        deps = list(entry["deps"])
        if not deps and name.endswith("$2") and name[:-2] in entries:
            deps = [name[:-2]]
        elif not deps and (name + "$2") in entries:
            deps = [name + "$2"]
        deps_by_name[name] = deps
        for dep in deps:
            if dep in entries:
                if dep not in deps_by_name:
                    dep_queue.append(dep)
                continue
            dep_entry = ensure_bundle(dep, official, changed, skipped)
            if dep_entry:
                entries[dep] = dep_entry
                if dep not in required:
                    required.append(dep)
                deps_by_name[dep] = list(dep_entry["deps"])
                dep_queue.append(dep)
            else:
                log("prepare: dependency missing %s (needed by %s)" % (dep, name))

    manifest_backup = BUNDLE_ROOT / "AssetBundles.launcher.bak"
    if MANIFEST.is_file() and not manifest_backup.is_file():
        shutil.copy2(MANIFEST, manifest_backup)

    try:
        tree = ET.parse(MANIFEST)
        root = tree.getroot()
    except Exception as ex:
        log("prepare: current manifest parse failed: %r" % ex)
        return 1

    existing = {node.get("name").lower(): node for node in root.findall("AssetBundle") if node.get("name")}
    dirty = False
    for name in required:
        # 自定义改过的包：清单里的 md5 指向我们自己重打的文件，不能被官方 md5 覆盖回去。
        # 取消保护就把名字从这里删掉。
        if name.lower() in PROTECTED_BUNDLES:
            log("prepare: keep custom bundle %s (protected)" % name)
            continue
        entry = entries.get(name)
        if not entry:
            continue
        node = existing.get(name.lower())
        if node is None:
            node = ET.SubElement(root, "AssetBundle", {
                "name": entry["name"], "md5": entry["md5"], "crc": entry["crc"],
            })
            existing[name.lower()] = node
            dirty = True
            log("prepare: manifest + %s" % name)
        else:
            if node.get("md5") != entry["md5"]:
                node.set("md5", entry["md5"])
                dirty = True
            if node.get("crc") is None:
                node.set("crc", entry["crc"])
                dirty = True
        wanted = [dep for dep in deps_by_name.get(name, []) if dep in entries]
        current = {d.get("name").lower() for d in node.findall("Dependency") if d.get("name")}
        for dep in wanted:
            if dep.lower() not in current:
                ET.SubElement(node, "Dependency", {"name": dep})
                dirty = True
                log("prepare: manifest %s -> dep %s" % (name, dep))

    if dirty:
        if hasattr(ET, "indent"):
            ET.indent(tree, space="  ")
        tmp = MANIFEST.with_suffix(".tmp")
        tree.write(tmp, encoding="utf-8", xml_declaration=True)
        ET.parse(tmp)  # 自校验，坏 XML 不落地
        os.replace(tmp, MANIFEST)
        log("prepare: manifest updated, total=%d" % len(existing))
    else:
        log("prepare: manifest unchanged, total=%d" % len(existing))

    if changed:
        log("prepare: files copied=%d" % len(changed))
    if skipped:
        log("prepare: skipped=%d (%s)" % (len(skipped), ", ".join(skipped)))
    log("prepare: done career=%s weapon=%s" % (career, weapon))
    return 0


if __name__ == "__main__":
    sys.exit(main())
