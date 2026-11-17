# -*- coding: utf-8 -*-
"""按人机模式（2003 团队 / 2019 大头 / 2041 刀战）安装 bot 专属资源包。

与 install_mode_weapons.py 的分工：
  - install_mode_weapons.py：模式武器池（玩家可用武器）
  - 本脚本：bot 专属资源——PVE 人机武器（botweapon/bot_bomb/pvegatling）、
    PVE 子弹（moveprefab/pve_botbullet）、首领模型（player/boss1008 + 动画）、
    大头模式 UI/特效（ui/bigheadmodel、uiprefabs/bighead、effect/bigheadmode）、
    bot 职业池模型与动画包。

对应 OfflineModeTable.cs 的 BotCfg（2026-10-24 与抓包结论对齐）：
  2003 人机团战：boss=pvegatling，精英/普通用模式枪械池
  2019 大头人机：同上 + 大头 UI/特效 + HeadEnlarge=1.6（快照字段，无需资源）
  2041 刀战人机：botweapon 近战 + bot_bomb 投掷，FFA

用法：
  python install_bot_assets.py            # 按 launch_config.json 的 mode 安装
  python install_bot_assets.py 2003       # 指定 RaceType
  python install_bot_assets.py all        # 三套人机模式全装
  python install_bot_assets.py --dry      # 只看缺什么，不写盘
"""
import json
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import prepare_launch_assets as P

# ---------- bot 职业池（与 OfflineModeTable.BotCfg / OfflineBotSpawner.InstalledCareers 一致） ----------
BOT_CAREERS = ["police", "pandora_t", "feihuwoman", "ct_knight1_2", "acg_paila", "boss1008"]

# ---------- PVE 人机武器（原版 bot 专用，不在玩家武器池里） ----------
PVE_WEAPONS = {
    "weapon/botweapon": ["weapon/botweapon$2", "sound/weapon/botweapon"],
    "weapon/bot_bomb": ["weapon/bot_bomb$2", "sound/weapon/bot_bomb"],
    "weapon/pvegatling": ["sound/weapon/pvegatling"],  # $2 官方清单里不存在
}

# ---------- 首领模型（boss1008） ----------
BOSS_BUNDLES = [
    "player/boss1008", "player/boss1008$2",
    "playeranim/boss1008",
    "ui/halfloadedres/bosstitle/boss1008",
]

# ---------- 大头人机 2019：HUD/规则 UI 与特效 ----------
BIGHEAD_BUNDLES = [
    "ui/bigheadmodel", "uiprefabs/bighead", "effect/bigheadmode",
]

# ---------- PVE 子弹预制体 ----------
MOVE_PREFABS = ["moveprefab/pve_botbullet"]

# ---------- HUD/播报资源（三套人机模式共用） ----------
# playerhpbar：敌人/精英/首领血条 prefab（BigHeadGameRule.IsShowEnemyHpBar + botQuality 分级血条）。
#   离线链路 OfflineGameController 对 2019 敌人挂血条，缺这个包时实机 WARN：
#   "asset not exist [playereffectprefab/playerhpbar:PlayerHpBar:UnityEngine.GameObject]"
# sound/kill：击杀播报音效 attackplayer.mp3，缺时每个 bot 击杀都 WARN 一次。
HUD_BUNDLES = [
    "playereffectprefab/playerhpbar",
    "sound/kill",
]

# ---------- 各模式 bot 武器池（OfflineModeTable.BotCfg.Weapons + BossWeapons 并集） ----------
MODE_BOT_WEAPONS = {
    2003: [
        "blood_machinegun", "aa12_hero1", "m4a1_g1", "deagle_g", "m4",
        "colt_boa", "barrett_m107_g", "viper", "double_infinity_g", "viper_rage",
        "pvegatling",
    ],
    2019: [
        "blood_machinegun", "aa12_hero1", "m4a1_g1", "deagle_g", "m4",
        "colt_boa", "barrett_m107_g", "viper", "double_infinity_g", "viper_rage",
        "pvegatling",
    ],
    2041: [
        "botweapon", "bot_bomb", "nbr_knife_g", "double_fangs_g", "ice_ax",
        "axe_g", "shovel_g", "blood_shadow_sword",
    ],
    15: [
        "botweapon", "nbr_knife_g", "double_fangs_g", "ice_ax", "axe_g",
        "shovel_g", "blood_shadow_sword",
    ],
}

# 与 OfflineGameSetting.ModeIdFromName 对齐（启动器模式名 -> RaceType）
MODE_NAME_TO_ID = {
    "team": 3, "group": 3,
    "team_ai": 2003, "bot_team": 2003, "botteam": 2003, "team2003": 2003, "2003": 2003,
    "bighead": 2019, "big_head": 2019, "bot_bighead": 2019, "bighead_ai": 2019,
    "bighead2019": 2019, "mode2019": 2019, "2019": 2019,
    "blade_ai": 2041, "bot_knife": 2041, "bot_knifefight": 2041, "knife_ai": 2041,
    "knife2041": 2041, "blade2041": 2041, "mode2041": 2041, "2041": 2041,
    "blade": 15, "blade_fight": 15, "bladefight": 15, "blade_warrior": 15, "blade15": 15,
    "personal": 5, "explode": 2, "deathmatch": 12, "death_match": 12,
    "flyknife": 74, "weaponmaster": 64,
}

BOT_MODE_IDS = (2003, 2019, 2041)


def read_config_mode():
    """读 launch_config.json 的 mode，返回 (mode_name, raceType)。"""
    path = P.CONFIG
    try:
        with open(path, encoding="utf-8") as f:
            cfg = json.load(f)
        mode = (cfg.get("mode") or "").strip()
    except Exception:
        mode = ""
    return mode, MODE_NAME_TO_ID.get(mode.lower(), 0)


def collect(race_type):
    """返回该模式需要接入的 bundle 名列表（有序、去重）。"""
    names = []

    def add(n):
        if n and n not in names:
            names.append(n)

    # 首领模型：三套人机模式 + 刀锋（BotCfg.BossCareers=boss1008）都要
    for n in BOSS_BUNDLES:
        add(n)

    # HUD/播报：血条 + 击杀音效，所有人机模式都要
    for n in HUD_BUNDLES:
        add(n)

    if race_type in (2003, 2019, 2041, 15):
        # bot 职业池：主包 + $2 + 动画包（anim_bundles_for 解析 manCT/woman/同名包）
        official = P.load_official_manifest()
        anim_map = P.load_anim_map()
        for c in BOT_CAREERS:
            add("player/" + c)
            add("player/" + c + "$2")
            for a in P.anim_bundles_for(c, anim_map, official):
                add(a)
        # 模式 bot 武器池
        for w in MODE_BOT_WEAPONS.get(race_type, []):
            add("weapon/" + w)
            add("weapon/" + w + "$2")
            add("sound/weapon/" + w)
        # PVE 专属
        if race_type in (2003, 2019):
            add("weapon/pvegatling")
            add("sound/weapon/pvegatling")
            for m in MOVE_PREFABS:
                add(m)
        if race_type in (2041, 15):
            for w in ("botweapon", "bot_bomb"):
                add("weapon/" + w)
                for extra in PVE_WEAPONS.get("weapon/" + w, []):
                    add(extra)
        # 大头模式 UI/特效
        if race_type == 2019:
            for n in BIGHEAD_BUNDLES:
                add(n)
    return names


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry" in sys.argv

    mode_name, cfg_rt = read_config_mode()
    if "all" in [a.lower() for a in args]:
        targets = list(BOT_MODE_IDS) + [15]
    elif args:
        targets = [int(a) for a in args]
    else:
        targets = [cfg_rt] if cfg_rt in BOT_MODE_IDS + (15,) else list(BOT_MODE_IDS)
        if cfg_rt not in BOT_MODE_IDS + (15,):
            P.log("install-bot: mode=%r has no bot profile, installing all three" % mode_name)

    official = P.load_official_manifest()
    if not official:
        P.log("install-bot: official manifest missing, abort")
        return 1

    required = []
    for rt in targets:
        for n in collect(rt):
            if n not in required:
                required.append(n)

    P.log("install-bot: mode=%r rt=%s targets=%s bundles=%d%s"
          % (mode_name or "-", cfg_rt or "-", targets, len(required), " (dry)" if dry else ""))

    entries = {}
    for name in required:
        e = P.ensure_bundle(name, official, [], []) if not dry else None
        if e:
            entries[name] = e
        elif dry:
            info = official.get(name.lower())
            if info is None:
                st = "NOT-IN-MANIFEST"
            elif P.find_source(name, info)[0] is None:
                st = "NO-SOURCE"
            else:
                st = "READY"
            P.log("  [dry] %-44s %s" % (name, st))

    if dry:
        P.log("install-bot: dry run, nothing written")
        return 0

    # 依赖闭包（官方清单里抄；主包<->$2 互依兜底）
    deps_by_name = {}
    q = list(required)
    seen = set()
    while q:
        name = q.pop(0)
        if name.lower() in seen:
            continue
        seen.add(name.lower())
        e = entries.get(name)
        if not e:
            continue
        deps = list(e["deps"])
        if not deps and name.endswith("$2") and name[:-2] in entries:
            deps = [name[:-2]]
        elif not deps and (name + "$2") in entries:
            deps = [name + "$2"]
        deps_by_name[name] = deps
        for d in deps:
            if d in entries:
                if d not in deps_by_name:
                    q.append(d)
                continue
            de = P.ensure_bundle(d, official, [], [])
            if de:
                entries[d] = de
                if d not in required:
                    required.append(d)
                deps_by_name[d] = list(de["deps"])
            else:
                P.log("install-bot: dependency missing %s (needed by %s)" % (d, name))

    # 写 manifest
    if not P.MANIFEST.is_file():
        P.log("install-bot: manifest missing %s" % P.MANIFEST)
        return 1
    bak = P.BUNDLE_ROOT / "AssetBundles.bot.bak"
    if not bak.is_file():
        import shutil
        shutil.copy2(P.MANIFEST, bak)

    tree = ET.parse(P.MANIFEST)
    root = tree.getroot()
    existing = {n.get("name").lower(): n for n in root.findall("AssetBundle") if n.get("name")}
    dirty = False
    for name in required:
        e = entries.get(name)
        if not e:
            continue
        node = existing.get(name.lower())
        if node is None:
            node = ET.SubElement(root, "AssetBundle", {"name": e["name"], "md5": e["md5"], "crc": e["crc"]})
            existing[name.lower()] = node
            dirty = True
            P.log("install-bot: manifest + %s" % name)
        else:
            if node.get("md5") != e["md5"]:
                node.set("md5", e["md5"]); dirty = True
            if node.get("crc") is None:
                node.set("crc", e["crc"]); dirty = True
        wanted = [d for d in deps_by_name.get(name, []) if d in entries]
        cur = {d.get("name").lower() for d in node.findall("Dependency") if d.get("name")}
        for d in wanted:
            if d.lower() not in cur:
                ET.SubElement(node, "Dependency", {"name": d})
                dirty = True
                P.log("install-bot: manifest %s -> dep %s" % (name, d))

    if dirty:
        if hasattr(ET, "indent"):
            ET.indent(tree, space="  ")
        tmp = P.MANIFEST.with_suffix(".tmp")
        tree.write(tmp, encoding="utf-8", xml_declaration=True)
        ET.parse(tmp)
        os.replace(tmp, P.MANIFEST)
        P.log("install-bot: manifest updated, total=%d" % len(existing))
    else:
        P.log("install-bot: manifest unchanged, total=%d" % len(existing))

    ok = sum(1 for n in required if n in entries)
    P.log("install-bot: ready=%d/%d (missing bundles stay on in-code fallback)" % (ok, len(required)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
