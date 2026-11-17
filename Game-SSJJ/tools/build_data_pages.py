# -*- coding: utf-8 -*-
"""按原版格子结构铺数据：武器(军火库 16 横条) / 喷漆(FaceStuffItem) / 人类角色。

数据全部本地写死，不等服务器后端。玩家档案：VIP18 / Lv.91 / 联通一区 / 你来时冬至 / 金币91 / GP91。
"""
import os, sys, json, re, html, shutil
import xml.etree.ElementTree as ET

ROOT = r"D:\逆向\SSJJ双塔惊魂"
sys.path.insert(0, os.path.join(ROOT, "Game-SSJJ", "tools"))
import fairygui_render as F

LAUNCHER = os.path.join(ROOT, "lobby-launcher")
VIEW = os.path.join(ROOT, "_work", "lobby_ui", "view_dec")
OUT = os.path.join(ROOT, "_work", "lobby_ui", "out")
DELIVERY = os.path.join(ROOT, "离线大厅")
INV = json.load(open(os.path.join(LAUNCHER, "data", "asset_inventory.json"), encoding="utf-8"))

PLAYER = {"name": "你来时冬至", "district": "联通一区", "vip": 18, "level": 91, "gold": 91, "gp": 91}


def fpath(*p):
    return os.path.join(*p)


def classify(w):
    k = (w.get("type") or "").lower()
    if "sniper" in k:
        return "sniper"
    if "rifle" in k:
        return "rifle"
    if "shotgun" in k:
        return "shotgun"
    if "pistol" in k:
        return "pistol"
    if "grenade" in k or "bomb" in k:
        return "grenade"
    if any(x in k for x in ("knife", "sword", "blade", "melee", "axe")):
        return "melee"
    return "other"


def weapon_list(cat=None):
    out = []
    for key, w in INV["weapons"].items():
        if cat and classify(w) != cat:
            continue
        p = fpath(LAUNCHER, "assets", "previews", "weapons", key + ".png")
        out.append({"k": key, "n": w.get("cn") or key, "icon": p if os.path.exists(p) else ""})
    out.sort(key=lambda x: x["n"])
    return out


def char_list():
    out = []
    for key, c in INV["characters"].items():
        p = fpath(LAUNCHER, "assets", "previews", "characters", key + ".png")
        out.append({"k": key, "n": c.get("cn") or key, "icon": p if os.path.exists(p) else "",
                    "g": c.get("kind", "other")})
    out.sort(key=lambda x: x["n"])
    return out


def spray_list():
    out = []
    for k, v in INV["sprays"].items():
        p = fpath(LAUNCHER, "assets", "previews", "sprays", k + ".png")
        if os.path.exists(p):
            out.append({"k": k, "n": f"喷漆 #{k}", "icon": p, "time": "永久", "selected": k == "0"})
    out.sort(key=lambda x: int(x["k"]))
    return out


def file_uri(path):
    """把本地预览图转换成 Chrome 可直接读取的 file URI。"""
    return "file:///" + path.replace("\\", "/")


def render_component(xml_path, component_name):
    """只展开完整大厅 XML 中的一个原版组件定义。"""
    r = F.Renderer(xml_path)
    root = ET.Element("UIComponent", {"name": component_name, "className": component_name})
    parts = []
    r.node(root, parts)
    return "".join(parts)


def page(xml_name, data, out_name, size=(1024, 650), extra_css="", extra_js=""):
    r = F.Renderer(os.path.join(VIEW, xml_name + ".dec.xml"), data=data)
    body = r.render()
    w, h = size
    doc = f"""<!doctype html><meta charset="utf-8"><title>{html.escape(xml_name)}</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;font-family:"Microsoft YaHei",sans-serif;overflow:auto}}
#wrap{{position:relative;width:{w}px;height:{h}px;margin:12px auto;background:#000;overflow:hidden;flex:none}}
.n{{position:absolute}}
.cell{{position:absolute}}
img{{max-width:100%;max-height:100%}}
#hud{{position:fixed;right:10px;top:10px;z-index:20;font:11px/1.7 monospace;color:#8fb4d4;
  background:rgba(0,0,0,.7);padding:6px 10px;border-radius:4px;max-width:260px}}
{extra_css}
</style>
<div id="wrap">{body}</div>
<div id="hud"></div>
<script>
const PLAYER={json.dumps(PLAYER, ensure_ascii=False)};
document.getElementById('hud').innerHTML=
  'VIP'+PLAYER.vip+' · Lv.'+PLAYER.level+' · '+PLAYER.district+'<br>'+PLAYER.name+
  ' · 金币 '+PLAYER.gold+' · GP '+PLAYER.gp;
{extra_js}
</script>
"""
    out = os.path.join(OUT, out_name)
    open(out, "w", encoding="utf-8").write(doc)
    print(f"{xml_name} -> {out_name}  {len(doc)/1024:.0f} KB")
    return out


def build_spray_page(sprays):
    """在原版 PersonalizePanel/FaceStuffItem 格子中绑定全部喷漆。"""
    xml = os.path.join(VIEW, "PersonalizePanelView.dec.xml")
    # 先让渲染器生成一个原版 FaceStuffItem 模板；剩余格子由 JS 复制这个原版模板。
    r = F.Renderer(xml, data={"listSpray": sprays[:3]})
    body = r.render()
    payload = [
        {"k": s["k"], "n": s["n"], "icon": file_uri(s["icon"]), "time": s["time"], "selected": s["selected"]}
        for s in sprays
    ]
    doc = f"""<!doctype html><meta charset=\"utf-8\"><title>喷漆仓库</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;font-family:\"Microsoft YaHei\",sans-serif;overflow:hidden}}
#wrap{{position:relative;width:1024px;height:650px;margin:12px auto;background:#000;overflow:hidden;flex:none}}
.n{{position:absolute}}
.cell{{position:absolute}}
img{{max-width:100%;max-height:100%}}
#hud{{position:fixed;right:10px;top:10px;z-index:20;font:11px/1.7 monospace;color:#8fb4d4;
  background:rgba(0,0,0,.7);padding:6px 10px;border-radius:4px;max-width:280px}}
</style>
<div id=\"wrap\">{body}</div>
<div id=\"hud\"></div>
<script>
const PLAYER={json.dumps(PLAYER, ensure_ascii=False)};
const SPRAYS={json.dumps(payload, ensure_ascii=False)};
const list=document.querySelector('[data-name=\"listSpray\"]');
const template=list && list.querySelector(\".cell\");
if(list && template){{
  // PersonalizePanelView 原版参数：4 列、列宽 108、行高 110、可滚动。
  list.style.height=\"432px\";
  list.style.overflowY=\"auto\";
  list.style.overflowX=\"hidden\";
  list.innerHTML=\"\";
  SPRAYS.forEach((item,index)=>{{
    const cell=template.cloneNode(true);
    cell.style.left=((index%4)*108)+\"px\";
    cell.style.top=(Math.floor(index/4)*110)+\"px\";
    cell.title=item.n+\" · \"+item.k;
    const icon=cell.querySelector('[data-name=\"icon\"]');
    if(icon){{
      icon.style.width=\"100px\"; icon.style.height=\"100px\";
      icon.innerHTML='<img src=\"'+item.icon+'\" alt=\"\" style=\"position:absolute;left:12%;top:12%;width:76%;height:76%;object-fit:contain\">';
    }}
    const name=cell.querySelector('[data-name=\"txtName\"]');
    if(name){{name.textContent=item.n;name.style.color=\"#ffffff\";}}
    const time=cell.querySelector('[data-name=\"txtTime\"]');
    if(time){{time.textContent=item.time;}}
    const equip=cell.querySelector('[data-name=\"imgEquip\"]');
    if(equip){{equip.style.display=item.selected?\"\":\"none\";}}
    list.appendChild(cell);
  }});
}}
document.getElementById(\"hud\").innerHTML=\"VIP\"+PLAYER.vip+\" · Lv.\"+PLAYER.level+\" · \"+PLAYER.district+\"<br>\"+
  PLAYER.name+\" · 金币 \"+PLAYER.gold+\" · GP \"+PLAYER.gp+\"<br>喷漆 \"+SPRAYS.length+\" 个 · 鼠标滚轮查看全部\";
</script>
"""
    out = os.path.join(OUT, "data_spray.html")
    open(out, "w", encoding="utf-8").write(doc)
    print(f"PersonalizePanelView -> data_spray.html  {len(doc)/1024:.0f} KB  sprays={len(sprays)}")
    return out


def build_role_page(out_name, title):
    """只给原版 roleView 的 UIAssetsLoader 绑定人类角色数据。"""
    xml = os.path.join(VIEW, "roleView.dec.xml")
    r = F.Renderer(xml)
    body = r.render()
    chars = [c for c in char_list() if c["g"] == "human"]
    payload = [{"k": c["k"], "n": c["n"], "icon": file_uri(c["icon"]) if c.get("icon") else ""} for c in chars]
    up = F.asset("RoleAssets.upBtnF") or ""
    down = F.asset("RoleAssets.downBtnF") or ""
    doc = f"""<!doctype html><meta charset=\"utf-8\"><title>{html.escape(title)}</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;font-family:\"Microsoft YaHei\",sans-serif;overflow:hidden}}
#wrap{{position:relative;width:1024px;height:650px;margin:12px auto;background:#000;overflow:hidden;flex:none}}
.n{{position:absolute}}
img{{max-width:100%;max-height:100%}}
#hud{{position:fixed;right:10px;top:10px;z-index:20;font:11px/1.7 monospace;color:#8fb4d4;
  background:rgba(0,0,0,.7);padding:6px 10px;border-radius:4px;max-width:280px}}
.role-page-btn{{position:absolute;z-index:20;width:18px;height:24px;border:0;padding:0;background-color:transparent;
  background-repeat:no-repeat;background-size:100% 100%;cursor:pointer}}
.role-page-btn.prev{{left:112px;top:597px;background-image:url('{up}')}}
.role-page-btn.next{{left:191px;top:597px;background-image:url('{down}')}}
.role-page-btn.prev.blue{{left:762px}}.role-page-btn.next.blue{{left:841px}}
.role-page-btn:disabled{{opacity:.35;cursor:default}}
.role-page-info{{position:absolute;z-index:20;top:602px;color:#cfe5fa;font:11px monospace}}
.role-page-info.red{{left:139px}}.role-page-info.blue{{left:789px}}
</style>
<div id=\"wrap\">{body}
  <button class=\"role-page-btn prev red\" data-dir=\"prev\" aria-label=\"上一页\"></button>
  <button class=\"role-page-btn next red\" data-dir=\"next\" aria-label=\"下一页\"></button>
  <span class=\"role-page-info red\"></span>
  <button class=\"role-page-btn prev blue\" data-dir=\"prev\" aria-label=\"上一页\"></button>
  <button class=\"role-page-btn next blue\" data-dir=\"next\" aria-label=\"下一页\"></button>
  <span class=\"role-page-info blue\"></span>
</div>
<div id=\"hud\"></div>
<script>
const PLAYER={json.dumps(PLAYER, ensure_ascii=False)};
const CHARACTERS={json.dumps(payload, ensure_ascii=False)};
const PER_PAGE=12;
let pageIndex=0;
const red=document.querySelector('[data-name=\"redRoleContainer\"]');
const blue=document.querySelector('[data-name=\"blueRoleContainer\"]');
const redCards=red?[...red.children].filter(x=>/^item[1-6]$/.test(x.dataset.name||\"\")):[];
const blueCards=blue?[...blue.children].filter(x=>/^item[1-6]$/.test(x.dataset.name||\"\")):[];
const cards=[...redCards,...blueCards];
function bind(card,item){{
  const icon=card.querySelector('[data-name=\"roleIcon\"]');
  if(!icon)return;
  // UIAssetsLoader 的显示区域按原版 110x200 卡片保留，只替换动态图片内容。
  icon.style.width=\"94px\"; icon.style.height=\"184px\"; icon.style.overflow=\"hidden\";
  icon.innerHTML=item.icon?'<img src=\"'+item.icon+'\" alt=\"\" style=\"width:100%;height:100%;object-fit:contain;display:block\">':\"\";
  card.title=item.n+\" · \"+item.k;
}}
function clear(card){{
  const icon=card.querySelector('[data-name=\"roleIcon\"]'); if(icon)icon.innerHTML=\"\";
  card.title=\"\";
}}
function draw(){{
  const pages=Math.max(1,Math.ceil(CHARACTERS.length/PER_PAGE));
  pageIndex=Math.max(0,Math.min(pageIndex,pages-1));
  const start=pageIndex*PER_PAGE;
  redCards.forEach((card,i)=>CHARACTERS[start+i]?bind(card,CHARACTERS[start+i]):clear(card));
  blueCards.forEach((card,i)=>CHARACTERS[start+6+i]?bind(card,CHARACTERS[start+6+i]):clear(card));
  document.querySelectorAll(\".role-page-btn\").forEach(btn=>{{
    btn.disabled=(btn.dataset.dir===\"prev\"?pageIndex===0:pageIndex>=pages-1);
  }});
  document.querySelectorAll(\".role-page-info\").forEach(el=>el.textContent=(pageIndex+1)+\" / \"+pages);
  document.getElementById(\"hud\").innerHTML=\"VIP\"+PLAYER.vip+\" · Lv.\"+PLAYER.level+\" · \"+PLAYER.district+\"<br>\"+
    PLAYER.name+\" · 金币 \"+PLAYER.gold+\" · GP \"+PLAYER.gp+\"<br>人类角色 \"+CHARACTERS.length+
    \" 个 · 第 \"+(pageIndex+1)+\" / \"+pages+\" 页\";
}}
document.querySelectorAll(\".role-page-btn\").forEach(btn=>btn.onclick=()=>{{pageIndex+=btn.dataset.dir===\"next\"?1:-1;draw();}});
document.addEventListener(\"keydown\",e=>{{
  if(e.key===\"ArrowRight\"||e.key===\"PageDown\"){{pageIndex++;draw();}}
  if(e.key===\"ArrowLeft\"||e.key===\"PageUp\"){{pageIndex--;draw();}}
}});
draw();
</script>
"""
    out = os.path.join(OUT, out_name)
    open(out, "w", encoding="utf-8").write(doc)
    print(f"roleView -> {out_name}  {len(doc)/1024:.0f} KB  human_chars={len(chars)}")
    return out


def build_warehouse_page(weapons, human_chars):
    """把大厅主界面、装备栏和 NewStorageView 合成一个完整的个人仓库页面。"""
    xml = os.path.join(VIEW, "newMallView.dec.xml")
    base = render_component(xml, "NewStorageView")
    weapon_tpl = render_component(xml, "NewStorageWeaponItem")
    role_tpl = render_component(xml, "NewStorageRoleItem")
    pager2 = render_component(xml, "Pager2").replace('data-name="btnPre"', 'id="prev" data-name="btnPre"').replace('data-name="btnNext"', 'id="next" data-name="btnNext"').replace('data-name="btnFirst"', 'id="first" data-name="btnFirst"').replace('data-name="btnEnd"', 'id="last" data-name="btnEnd"')
    main_body = F.Renderer(os.path.join(VIEW, "mainView.dec.xml")).render()

    # 参考图第一页的装备顺序。其余武器继续使用本地清单，保证仓库仍可翻完全部数据。
    featured_keys = [
        "ak47_legend_ct", "barrett_m107_g", "spirits_sword", "dagger_bullet_burster",
        "shotgun_laser", "kriss", "dawn_light_shotgun2", "mental_burster2",
        "m4a1_g1", "ak47_g1", "awm_g", "m4a1_legend",
    ]
    by_key = {w["k"]: w for w in weapons}
    ordered_weapons = [by_key[k] for k in featured_keys if k in by_key]
    ordered_weapons += [w for w in weapons if w["k"] not in {x["k"] for x in ordered_weapons}]
    # NewStorageWeaponItem.as 的真实品质分层：speciality=2/3/6/8
    # 分别对应黄金、brilliant、god、legend 卡片底图。
    quality_assets = {
        "gold": {
            "bg": F.asset("MallAssets.goldItemBg") or "",
            "nameBg": F.asset("MallAssets.goldItemNameBg") or "",
            "iconQuality": F.asset("MallAssets.goldItemIcon") or "",
        },
        "brilliant": {
            "bg": F.asset("MallAssets.brilliant_bg") or "",
            "nameBg": F.asset("MallAssets.brilliant_NameBg") or "",
            "iconQuality": F.asset("MallAssets.brilliant_Icon") or "",
        },
        "god": {
            "bg": F.asset("MallAssets.god_ItemBg") or "",
            "nameBg": F.asset("MallAssets.god_nameBg") or "",
            "iconQuality": F.asset("MallAssets.god_icon") or "",
        },
        "legend": {
            "bg": F.asset("MallAssets.ledengBg") or "",
            "nameBg": F.asset("MallAssets.goldItemNameBg") or "",
            "iconQuality": F.asset("MallAssets.ledeng_icon") or "",
        },
    }
    featured_quality = {
        "ak47_legend_ct": "legend",
        "barrett_m107_g": "gold",
        "spirits_sword": "god",
        "dagger_bullet_burster": "god",
        "shotgun_laser": "god",
        "kriss": "god",
        "dawn_light_shotgun2": "god",
        "mental_burster2": "god",
    }
    def quality_for(key):
        if key in featured_quality:
            return featured_quality[key]
        lk = key.lower()
        if lk.endswith("_g") or "gold" in lk:
            return "gold"
        if "legend" in lk or "ledeng" in lk:
            return "legend"
        return ""
    def quality_payload(key):
        q = quality_for(key)
        return quality_assets.get(q, {})

    weapon_payload = [
        {"k": w["k"], "n": w["n"], "icon": file_uri(w["icon"]) if w.get("icon") else "",
         **{k: v for k, v in quality_payload(w["k"]).items() if v}}
        for w in ordered_weapons
    ]
    role_payload = [
        {"k": c["k"], "n": c["n"], "icon": file_uri(c["icon"]) if c.get("icon") else ""}
        for c in human_chars
    ]
    # 皮肤、礼包和道具共用已经整理好的本地图标，页面行为完整，数据仍然可继续扩充。
    skin_payload = [{"k": w["k"], "n": w["n"] + "（皮肤）", "icon": file_uri(w["icon"]) if w.get("icon") else "",
                     **{k: v for k, v in quality_payload(w["k"]).items() if v}}
                    for w in ordered_weapons[:499]]
    stuff_payload = [{"k": w["k"], "n": w["n"], "icon": file_uri(w["icon"]) if w.get("icon") else "",
                      **{k: v for k, v in quality_payload(w["k"]).items() if v}}
                     for w in ordered_weapons]
    tab_skin = F.asset("ResourceAssets.mall_tog_big") or ""
    sub_skins = [
        F.asset("MallAssets.lightWeapon") or "",
        F.asset("MallAssets.closeInWeapon") or "",
        F.asset("MallAssets.throwWeapon") or "",
        F.asset("MallAssets.tacticalWeapon") or "",
    ]
    equip_bg = F.asset("NewBagAssets.bg") or ""
    equip_slot_bg = F.asset("NewBagAssets.weapon_bg") or ""
    equip_remove_bg = F.asset("NewBagAssets.unequip") or ""
    character_preview = file_uri(os.path.join(LAUNCHER, "assets", "previews", "characters", "heihongluoli.png"))
    equip_items = [
        ("主武器", "m4a1_g1"), ("副武器", "kriss"), ("近战武器", "spirits_sword"), ("投掷武器", "vip_grenade")
    ]
    equip_json = []
    for label, key in equip_items:
        w = by_key.get(key) or by_key.get("m4a1_g")
        equip_json.append({"label": label, "name": w["n"] if w else key,
                           "icon": file_uri(w["icon"]) if w and w.get("icon") else ""})
    warehouse_player = {"name": "你来时冬至", "district": "联通一区", "vip": 49,
                        "level": 100, "gold": 0, "gp": 39559681}
    doc = f"""<!doctype html><meta charset=\"utf-8\"><title>个人仓库</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:100%;height:100%;background:#05080b;font-family:\"Microsoft YaHei\",sans-serif;overflow:hidden}}
#wrap{{position:relative;width:1268px;height:834px;margin:0 auto;background:#000;overflow:hidden;flex:none}}
.n{{position:absolute}}
#app{{position:absolute;left:0;top:0;width:1024px;height:650px;transform:scale(1.23828125);transform-origin:top left}}
#main{{position:absolute;inset:0;z-index:0}}
#main > .n:not([data-name=\"bg\"]):not([data-name=\"topButtonPanel\"]):not([data-name=\"currencyBar\"]):not([data-name=\"playerProtrait\"]):not([data-name=\"sbag\"]):not([data-name=\"bottomBar\"]):not([data-name=\"mcRoleSelecter\"]):not([data-name=\"selectRoleBtn\"]):not([data-name=\"automaticEquipBtn\"]):not([data-name=\"switchBagBtn\"]):not([data-name=\"setBtn\"]){{display:none!important}}
#main > .n[data-name=\"currencyBar\"]{{display:block!important}}
#main [data-name=\"playInfoListPanel\"],#main [data-name=\"gameModeListPanel\"],#main [data-name=\"activityListPanel\"],
#main [data-name=\"rigthButton\"],#main [data-name=\"matchInfo\"],#main [data-name=\"trailerItem\"],
#main [data-name=\"newPlayerSp\"],#main [data-name=\"maskSp\"],#main [data-name=\"titleLB\"],#main [data-name=\"tipsImage\"],
#main [data-name=\"activityMc\"],#main [data-name=\"titanMc\"],#main [data-name=\"imgTitaniumOpening\"],#main [data-name=\"backGameBtn\"],
#main [data-name=\"btnArea\"],
#main [data-name=\"tenBtn\"],
#main [data-name=\"nationalFlag\"],#main [data-name=\"setBtn\"],#main [data-name=\"facebookInviteBtn\"],#main [data-name=\"btnExceptional\"]{{display:none!important}}
#main [data-name=\"currencyBar\"] [data-name=\"shoppingCartBtn\"]{{display:none!important}}
#main [data-name=\"currencyBar\"] [data-name=\"onOffBtn\"],#main [data-name=\"currencyBar\"] [data-name=\"btnHelp\"],#main [data-name=\"currencyBar\"] [data-name=\"labelArrears\"]{{display:none!important}}
#main [data-name=\"playerNameTF\"] span{{font-size:15px!important;color:#fff!important}}
#main [data-name=\"rankTf\"] span{{font-size:12px!important;color:#55d7ff!important}}
#main [data-name=\"playerNameTF\"],#main [data-name=\"rankTf\"]{{color:#fff!important;font-family:"Microsoft YaHei"!important;text-shadow:0 1px 2px #000}}
#main [data-name=\"rankTf\"]{{color:#55d7ff!important}}
#main [data-name=\"gpLB\"]{{color:#42f06a!important}}
#main [data-name=\"rpLB\"]{{color:#ffc43f!important}}
#main [data-name=\"yqLB\"]{{display:none!important}}
#main > [data-name=\"currencyBar\"]{{left:438px!important;transform:scaleX(1.07);transform-origin:left top}}
#main [data-name=\"playerProtrait\"]{{display:block!important}}
#main [data-name=\"sbag\"]{{display:block!important}}
#main [data-name=\"bottomBar\"]{{display:block!important}}
#main [data-name=\"mcRoleSelecter\"],#main [data-name=\"selectRoleBtn\"],#main [data-name=\"automaticEquipBtn\"],#main [data-name=\"switchBagBtn\"],#main [data-name=\"setBtn\"]{{display:block!important}}
#warehouse{{position:absolute;left:316px;top:102px;width:653px;height:531px;z-index:5;transform:scale(1.07);transform-origin:top left}}
#warehouse .base{{position:absolute;inset:0}}
#warehouse [data-name=\"gotoShop\"]{{display:none!important}}
#warehouse [data-name=\"bgName\"]{{display:none!important}}
#warehouse [data-name=\"mcNameFilter\"]{{display:none!important}}
#warehouse [data-name=\"labelLB\"],#warehouse [data-name=\"itemlb\"]{{color:#93a9ba!important;font:12px/20px "Microsoft YaHei"!important;text-shadow:0 1px 2px #000}}
#warehouse [data-name=\"orderlinessBtn\"],#warehouse [data-name=\"allClearExpiredBtn\"]{{color:#d8e9f8!important;font:12px/24px "Microsoft YaHei"!important;text-align:center;text-shadow:0 1px 2px #000}}
#warehouse .tabs{{position:absolute;left:194px;top:0;width:455px;height:29px;display:flex;gap:2px;z-index:8}}
.tab{{position:relative;width:75px;height:28px;background:url('{tab_skin}') center/100% 100% no-repeat;border:0;color:#d3e7ff;font:12px/28px \"Microsoft YaHei\";text-shadow:0 1px 2px #000;cursor:pointer}}
.tab.on{{color:#ffe45c;background-image:url('{tab_skin}');filter:brightness(1.28)}}
#warehouse .subtabs{{position:absolute;left:194px;top:31px;height:25px;width:455px;display:flex;gap:4px;z-index:8}}
.subtab{{height:24px;min-width:62px;padding:0 7px;border:1px solid #385878;background:linear-gradient(#405b76,#172435);color:#d6e8ff;font:12px/22px \"Microsoft YaHei\";cursor:pointer}}
.subtab.on{{background:linear-gradient(#e5cb66,#795b1a);color:#171717;border-color:#ffe98e}}
.subtab img{{width:25px;height:18px;vertical-align:middle;object-fit:contain;filter:brightness(1.25)}}
#items{{position:absolute;left:194px;top:59px;width:452px;height:428px;overflow-y:auto;overflow-x:hidden;z-index:7;padding-right:2px;scrollbar-color:#587493 #111923;scrollbar-width:thin}}
.cell{{position:relative!important;display:inline-block;width:224px;height:103px;margin:0 1px 4px 0;overflow:hidden;vertical-align:top;border:1px solid #324c62;background:#121c27;box-shadow:inset 0 0 0 1px rgba(0,0,0,.45)}}
.cell::before{{display:none}}
.cell .quality-bg{{position:absolute;left:1px;top:1px;width:222px;height:77px;object-fit:fill;z-index:1}}
.cell .quality-name-bg{{position:absolute;left:2px;top:56px;width:99px;height:19px;object-fit:fill;z-index:3}}
.cell .quality-icon{{position:absolute;left:0;top:50px;width:33px;height:30px;object-fit:contain;z-index:4}}
.cell > .n{{position:absolute}}
.cell .UIButton{{display:none!important}}
.cell [data-name=\"overBg\"],.cell [data-name=\"selectedBg\"],.cell [data-name=\"weaponStorageIcon\"],
.cell [data-name=\"countryIcon\"],.cell [data-name=\"refromIcon\"],.cell [data-name=\"creditFrozenMaskImage\"],.cell [data-name=\"frozenFlagImage\"],.cell [data-name=\"forbiddenImage\"]{{display:none!important}}
.cell [data-name=\"itemName\"],.cell [data-name=\"bagLB\"],.cell [data-name=\"validityPeriodLB\"]{{display:none!important}}
.cell .data-icon{{position:absolute;left:30px;top:4px;width:164px;height:53px;object-fit:contain;z-index:2;filter:drop-shadow(0 2px 1px #000)}}
.card-rare{{position:absolute;left:4px;top:3px;padding:1px 4px;color:#fff3ad;background:rgba(92,21,27,.88);border:1px solid #f4c65d;font:bold 11px/15px \"Microsoft YaHei\";z-index:3}}
.card-name{{position:absolute;left:6px;bottom:22px;right:5px;color:#fff;font:14px/18px \"Microsoft YaHei\";white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-shadow:0 1px 2px #000;z-index:3}}
.card-actions{{position:absolute;left:0;right:0;bottom:0;height:20px;border-top:1px solid rgba(190,220,245,.22);text-align:right;z-index:3}}
.card-actions button{{border:0;background:transparent;color:#dceafa;font:12px/19px \"Microsoft YaHei\";cursor:pointer;padding:0 7px}}
.card-actions button:hover{{color:#ffe56b}}
#templates{{display:none}}
#equipment{{position:absolute;left:322px;top:103px;width:188px;height:474px;z-index:9;background:url('{equip_bg}') center/100% 100% no-repeat;padding:6px 5px}}
#equipment h3{{height:25px;color:#f4d56d;text-align:center;font:15px/25px \"Microsoft YaHei\";text-shadow:0 1px 2px #000}}
.equip-slot{{position:relative;width:178px;height:94px;margin:3px 0;border:1px solid #334b61;background:url('{equip_slot_bg}') center/100% 100% no-repeat;overflow:hidden}}
.equip-slot::after{{content:\"\";position:absolute;left:0;right:0;bottom:0;height:18px;background:rgba(0,0,0,.55);border-top:1px solid #1d3348}}
.equip-label{{position:absolute;left:6px;top:5px;color:#e7f5ff;font:12px/16px \"Microsoft YaHei\";z-index:3}}
.equip-name{{position:absolute;left:6px;bottom:2px;color:#d7eaff;font:11px/16px \"Microsoft YaHei\";z-index:4;white-space:nowrap;max-width:125px;overflow:hidden;text-overflow:ellipsis}}
.equip-slot img{{position:absolute;left:31px;top:23px;width:142px;height:53px;object-fit:contain;z-index:2;filter:drop-shadow(0 2px 1px #000)}}
.equip-remove{{position:absolute;right:13px;bottom:1px;color:#d7eaff;font:11px/16px "Microsoft YaHei";z-index:4}}
#player-card{{position:absolute;left:4px;top:84px;width:288px;height:500px;z-index:4;pointer-events:none}}
#player-card .player-name{{position:absolute;left:70px;top:0;color:#fff;font:bold 15px/22px \"Microsoft YaHei\";text-shadow:0 1px 2px #000}}
#player-card .player-rank{{position:absolute;left:70px;top:22px;color:#64d9ff;font:12px/18px \"Microsoft YaHei\"}}
#player-card .player-level{{position:absolute;left:68px;top:-2px;color:#fff;font:bold 15px/22px \"Microsoft YaHei\"}}
#player-card .player-model{{position:absolute;left:42px;top:52px;width:210px;height:350px;object-fit:contain;filter:drop-shadow(0 12px 8px rgba(0,0,0,.7))}}
#player-card .player-glow{{position:absolute;left:26px;top:42px;width:240px;height:370px;border:1px solid rgba(58,170,220,.22);border-radius:50%;box-shadow:0 0 35px rgba(37,145,218,.22) inset}}
#player-card .role-select{{position:absolute;left:71px;top:397px;width:135px;height:25px;background:linear-gradient(#4c9ace,#1b4d7d);border:1px solid #6cc8ff;color:#eaf7ff;font:13px/23px \"Microsoft YaHei\";text-align:center}}
#player-card .bag-select{{position:absolute;left:0;top:433px;width:105px;height:22px;background:#192b3c;border:1px solid #65869e;color:#d7edff;font:12px/20px \"Microsoft YaHei\";text-align:center}}
#player-card .small-bag{{position:absolute;left:103px;top:433px;width:103px;height:22px;background:#192b3c;border:1px solid #65869e;color:#d7edff;font:12px/20px \"Microsoft YaHei\";text-align:center}}
#player-card .player-level,#player-card .player-name,#player-card .player-rank,#player-card .role-select,#player-card .bag-select,#player-card .small-bag{{display:none}}
#pagebar{{position:absolute;left:524px;top:640px;width:220px;height:40px;z-index:10;color:#cfe5fa;font:12px/25px \"Microsoft YaHei\";text-align:center}}
#pagebar .UIButton{{display:block!important}}
#pagebar button{{border:1px solid #4d6e8e;background:#243c55;color:#d9efff;width:26px;height:24px;cursor:pointer;margin:0 6px}}
#pagebar button:hover{{background:#3d6591;color:#fff}}
#pageInfo{{position:absolute;left:58px;top:9px;width:80px;height:20px;display:block;line-height:20px}}
#countInfo{{display:none}}
#hud{{display:none}}

</style>
<div id=\"wrap\"><div id=\"app\">
  <div id=\"main\">{main_body}</div>
  <div id=\"player-card\"><div class=\"player-level\">Lv:100</div><div class=\"player-name\">你来时冬至</div><div class=\"player-rank\">[战刃无人情]</div><div class=\"player-glow\"></div><img class=\"player-model\" src=\"{character_preview}\"><div class=\"role-select\">角色选择</div><div class=\"bag-select\">⚙ 背包配置</div><div class=\"small-bag\">▤ 道具袋⌃</div></div>
  <div id=\"warehouse\"><div class=\"base\">{base}</div>
    <div class=\"tabs\"><button class=\"tab\" data-kind=\"pack\">礼包</button><button class=\"tab on\" data-kind=\"weapon\">武器</button><button class=\"tab\" data-kind=\"role\">角色</button><button class=\"tab\" data-kind=\"skin\">皮肤</button><button class=\"tab\" data-kind=\"stuff\">道具</button></div>
    <div class=\"subtabs\"><button class=\"subtab on\" data-filter=\"all\">全部</button><button class=\"subtab\" data-filter=\"rifle\"><img src=\"{sub_skins[0]}\"></button><button class=\"subtab\" data-filter=\"melee\"><img src=\"{sub_skins[1]}\"></button><button class=\"subtab\" data-filter=\"grenade\"><img src=\"{sub_skins[2]}\"></button><button class=\"subtab\" data-filter=\"other\"><img src=\"{sub_skins[3]}\"></button><button class=\"subtab search\" data-filter=\"all\">⌕</button></div>
    <div id=\"items\"></div><div id=\"countInfo\">数量/上限：1/99</div>
  </div>
  <div id=\"equipment\"><h3>竞技背包</h3>{''.join(f'<div class="equip-slot"><div class="equip-label">{e["label"]}</div><img src="{e["icon"]}"><div class="equip-name">{e["name"]}</div><span class="equip-remove">卸下</span></div>' for e in equip_json)}</div>
  <div id=\"pagebar\">{pager2}<span id=\"pageInfo\"></span></div>
</div></div>
<div id=\"templates\"><div id=\"tplWeapon\">{weapon_tpl}</div><div id=\"tplRole\">{role_tpl}</div></div><div id=\"hud\"></div>
<script>
const PLAYER={json.dumps(warehouse_player, ensure_ascii=False)};
function setSourceText(sel,value){{const el=document.querySelector(sel);if(!el)return;const span=el.querySelector("span");if(span)span.textContent=value;else el.textContent=value;}}
setSourceText('#main [data-name=\"gpLB\"]',String(PLAYER.gp));
setSourceText('#main [data-name=\"rpLB\"]',String(PLAYER.gold));
setSourceText('#main [data-name=\"playerNameTF\"]',PLAYER.name);
setSourceText('#main [data-name=\"rankTf\"]','[战刃无人情]');
setSourceText('#warehouse [data-name=\"labelLB\"]','数量/上限：');
setSourceText('#warehouse [data-name=\"itemlb\"]','1/99');
setSourceText('#warehouse [data-name=\"orderlinessBtn\"]','整理');
setSourceText('#warehouse [data-name=\"allClearExpiredBtn\"]','清除');

const WEAPONS={json.dumps(weapon_payload, ensure_ascii=False)};
const ROLES={json.dumps(role_payload, ensure_ascii=False)};
const SKINS={json.dumps(skin_payload, ensure_ascii=False)};
const STUFF={json.dumps(stuff_payload, ensure_ascii=False)};
const EMPTY=[];
const PER_PAGE=19;
let kind='weapon', page=0, filter='all';
function source(){{
  if(kind==='role')return ROLES;
  if(kind==='skin')return SKINS;
  if(kind==='stuff'||kind==='pack')return STUFF;
  if(filter==='all')return WEAPONS;
  return WEAPONS.filter(x=>x.k.toLowerCase().includes(filter));
}}
function cloneTemplate(){{const el=document.querySelector('#'+(kind==='role'?'tplRole':'tplWeapon')+' > .UIComponent').cloneNode(true);el.querySelectorAll('.UIButton').forEach(n=>n.remove());return el;}}
function esc(s){{return String(s).replace(/[&<>\"]/g,m=>({{'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}}[m]));}}
function addIcon(el,item){{
  const old=el.querySelector('.data-icon'); if(old)old.remove();
  el.querySelectorAll('.quality-bg,.quality-name-bg,.quality-icon').forEach(n=>n.remove());
  if(item.bg){{const bg=document.createElement('img'); bg.className='quality-bg'; bg.src=item.bg; el.appendChild(bg);}}
  if(item.nameBg){{const bg=document.createElement('img'); bg.className='quality-name-bg'; bg.src=item.nameBg; el.appendChild(bg);}}
  if(item.iconQuality){{const qi=document.createElement('img'); qi.className='quality-icon'; qi.src=item.iconQuality; el.appendChild(qi);}}
  const icon=document.createElement('img'); icon.className='data-icon'; icon.src=item.icon||''; el.appendChild(icon);
  const rare=document.createElement('span'); rare.className='card-rare'; rare.textContent=(kind==='weapon'?'黄金套装':kind==='role'?'角色':'永久'); el.appendChild(rare);
  const name=document.createElement('span'); name.className='card-name'; name.textContent=item.n||item.k; if(item.nameBg)name.style.left='30px'; el.appendChild(name);
  const actions=document.createElement('div'); actions.className='card-actions'; actions.innerHTML='<button data-action="skin">皮肤</button><button data-action="equip">装备</button>'; el.appendChild(actions);
  actions.querySelectorAll('button').forEach(btn=>btn.onclick=ev=>{{ev.stopPropagation(); document.getElementById('hud').textContent=btn.dataset.action==='equip'?'已装备：'+(item.n||item.k):'打开皮肤：'+(item.n||item.k);}});
}}
function draw(){{
  const data=source(), pages=Math.max(1,Math.ceil(data.length/PER_PAGE)); page=Math.max(0,Math.min(page,pages-1));
  const box=document.getElementById('items'); box.innerHTML='';
  data.slice(page*PER_PAGE,page*PER_PAGE+PER_PAGE).forEach((item,i)=>{{const el=cloneTemplate();el.classList.add('cell');if(item.k==='barrett_m107_g')el.classList.add('gold-card');el.style.position='relative';addIcon(el,item);el.title=(item.n||item.k)+' · '+item.k;box.appendChild(el);}});
  document.querySelectorAll('.tab').forEach(x=>x.classList.toggle('on',x.dataset.kind===kind));
  document.querySelectorAll('.subtab').forEach(x=>x.classList.toggle('on',x.dataset.filter===filter));
  document.getElementById('pageInfo').textContent=(page+1)+' / '+pages;
  document.getElementById('prev').disabled=page===0; document.getElementById('next').disabled=page>=pages-1;
  document.getElementById('hud').innerHTML='Lv.'+PLAYER.level+' · '+PLAYER.district+'<br>'+PLAYER.name+' · GP '+PLAYER.gp+' · 金币 '+PLAYER.gold+'<br>'+data.length+' 件 · 第 '+(page+1)+' / '+pages+' 页';
}}
document.querySelectorAll('.tab').forEach(x=>x.onclick=()=>{{kind=x.dataset.kind;page=0;filter='all';draw();}});
document.querySelectorAll('.subtab').forEach(x=>x.onclick=()=>{{filter=x.dataset.filter;page=0;draw();}});
document.getElementById('prev').onclick=()=>{{page--;draw();}}; document.getElementById('next').onclick=()=>{{page++;draw();}}; document.getElementById('first').onclick=()=>{{page=0;draw();}}; document.getElementById('last').onclick=()=>{{page=999999;draw();}};
document.addEventListener('keydown',e=>{{if(e.key==='ArrowRight'||e.key==='PageDown'){{page++;draw();}}if(e.key==='ArrowLeft'||e.key==='PageUp'){{page--;draw();}}}});
draw();
</script>"""
    out = os.path.join(OUT, "data_warehouse.html")
    open(out, "w", encoding="utf-8").write(doc)
    print(f"NewStorageSubView -> data_warehouse.html  {len(doc)/1024:.0f} KB  weapons={len(weapons)} human_roles={len(human_chars)}")
    return out


def sync_delivery():
    """把生成后的页面和原版切图同步到交付目录。"""
    os.makedirs(DELIVERY, exist_ok=True)
    for name in ("data_career.html", "data_role.html", "data_spray.html", "data_warehouse.html", "data_arsenal.html", "data_weapon.html"):
        src = os.path.join(OUT, name)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(DELIVERY, name))
    src_assets = os.path.join(OUT, "assets")
    dst_assets = os.path.join(DELIVERY, "assets")
    if os.path.isdir(src_assets):
        shutil.copytree(src_assets, dst_assets, dirs_exist_ok=True)


def main():
    # 1) 喷漆：PersonalizePanelView 的 listSpray + FaceStuffItem 格子
    sprays = spray_list()
    build_spray_page(sprays)

    # 2) 角色：原版 roleView 双阵营六格 + 全量分页
    chars = char_list()
    build_role_page("data_career.html", "角色仓库")
    build_role_page("data_role.html", "选择角色")
    print("  human chars:", sum(1 for c in chars if c["g"] == "human"))

    # 3) 仓库：大厅右上角 storageBtn -> NewStorageSubView，仓库只绑定武器和人类角色。
    build_warehouse_page(weapon_list(), [c for c in chars if c["g"] == "human"])

    # 4) 军火库：ActivityListPanel.luckyDrawBtn -> weaponStorage2View 抽奖系统。
    build_weapons()

    # 5) 同步交付目录；Rust 启动器路线不参与本次生成。
    sync_delivery()


def build_weapons():
    """weaponStorage2View 的格子是固定 16 个 UIImage（tileList），逐个注入。"""
    r = F.Renderer(os.path.join(VIEW, "weaponStorage2View.dec.xml"))
    body = r.render()
    weapons = weapon_list()
    per = 16
    js_weapons = json.dumps(weapons, ensure_ascii=False)

    doc = f"""<!doctype html><meta charset="utf-8"><title>军火库</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;font-family:"Microsoft YaHei",sans-serif;overflow:auto}}
#wrap{{position:relative;width:1024px;height:650px;margin:12px auto;background:#000;overflow:hidden;flex:none}}
.n{{position:absolute}}
img{{max-width:100%;max-height:100%}}
#hud{{position:fixed;right:10px;top:10px;z-index:20;font:11px/1.7 monospace;color:#8fb4d4;
  background:rgba(0,0,0,.7);padding:6px 10px;border-radius:4px}}
</style>
<div id="wrap">{body}</div>
<div id="hud"></div>
<script>
const PLAYER={json.dumps(PLAYER, ensure_ascii=False)};
const W={js_weapons};
const PER={per};
let cat='all',page=0;
// WeaponStorage2View.changeView 的普通抽奖初始状态：互斥控件只保留普通开启状态。
['superOpenBtn','backNomalBtn','buyGoldBoxBtn','bigBtnEffectC','nlBtnEffectC_2','ts_bg','ts_text','timerTipsMc','tipsMC']
  .forEach(n=>{{const el=document.querySelector('[data-name="'+n+'"]');if(el)el.style.display='none';}});
['showSuperBtn','singleBtn','multiBtn','bulkCheck','nlBtnEffectC'].forEach(n=>{{const el=document.querySelector('[data-name="'+n+'"]');if(el)el.style.display='';}});
function list(){{return cat==='all'?W:W.filter(w=>w.c===cat);}}
function draw(){{
  const L=list(),pages=Math.max(1,Math.ceil(L.length/PER));
  if(page>=pages)page=pages-1;
  const tiles=[...document.querySelectorAll('[data-name^=\"icon\"]')];
  tiles.forEach((t,i)=>{{
    const w=L[page*PER+i];
    if(!w){{t.innerHTML='';return;}}
    t.innerHTML='<img src=\"file:///'+w.icon.replace(/\\\\/g,'/')+'\" style=\"width:78%;height:78%;object-fit:contain;position:absolute;left:11%;top:11%\">'
      +'<span style=\"position:absolute;left:6px;right:6px;bottom:4px;font-size:11px;color:#e6f2fb;text-align:center;text-shadow:0 1px 2px #000;overflow:hidden;white-space:nowrap;text-overflow:ellipsis\">'+w.n+'</span>';
    t.style.cursor='pointer'; t.title=w.n;
  }});
  document.getElementById('hud').innerHTML=
    'VIP'+PLAYER.vip+' · Lv.'+PLAYER.level+' · '+PLAYER.district+'<br>'+PLAYER.name+
    ' · 金币 '+PLAYER.gold+' · GP '+PLAYER.gp+'<br>军火库抽奖物品 '+L.length+' 把 · 第 '+(page+1)+'/'+pages+' 页';
}}
document.addEventListener('keydown',e=>{{
  if(e.key==='ArrowRight'||e.key==='PageDown'){{page++;draw();}}
  if(e.key==='ArrowLeft'||e.key==='PageUp'){{page--;draw();}}
}});
draw();
</script>
"""
    out = os.path.join(OUT, "data_arsenal.html")
    open(out, "w", encoding="utf-8").write(doc)
    shutil.copy2(out, os.path.join(OUT, "data_weapon.html"))
    print(f"weaponStorage2View -> data_arsenal.html  {len(doc)/1024:.0f} KB  weapons={len(weapons)}")


if __name__ == "__main__":
    main()
