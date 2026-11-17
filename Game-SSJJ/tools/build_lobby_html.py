# -*- coding: utf-8 -*-
"""生成 1:1 原版大厅：背景/按钮/格子全部取自原版图集，数据取客户端全量清单。

素材来源
  ResourceAssets.game_bg            大厅背景 1024x650（原版定义）
  BagAssets.stuff_cell_bg_unequiped  物品格 40x40
  MainAssets.pvp_btn1..5             tab 按钮（5 帧状态）
  WeaponStorageAssets.weapon_storage_bg  仓库底图
数据来源
  lobby-launcher/data/asset_inventory.json （武器 1451 / 角色 811 / 皮肤 90 / 喷漆 393 / 饰品 419）
"""
import json, os, re, html, shutil

ROOT = r"D:\逆向\SSJJ双塔惊魂"
LAUNCHER = os.path.join(ROOT, "lobby-launcher")
REPO = os.path.join(ROOT, "资源下载", "大厅资源", "SSJJ-main")
OUT = os.path.join(ROOT, "_work", "lobby_ui", "out")
ASSETS = os.path.join(OUT, "assets")

IDX = json.load(open(os.path.join(LAUNCHER, "data", "sprite_index.json"), encoding="utf-8"))["items"]
INV = json.load(open(os.path.join(LAUNCHER, "data", "asset_inventory.json"), encoding="utf-8"))

PLAYER = {
    "name": "你来时冬至",
    "district": "联通一区",
    "vip": 18,
    "level": 91,
    "gold": 91,
    "gp": 91,
}

KIND_CN = {"human": "人类", "zombie": "僵尸", "mech": "机甲", "pet": "宠物", "other": "其他"}
CAT_CN = [
    ("rifle", "步枪"), ("sniper", "狙击"), ("pistol", "手枪"),
    ("melee", "近战"), ("grenade", "投掷"), ("shotgun", "霰弹"), ("other", "特殊"),
]


def sprite(key):
    rec = IDX.get(key)
    if not rec:
        for i in range(1, 10):
            rec = IDX.get(key + str(i))
            if rec:
                break
    if not rec:
        return None
    src = os.path.join(REPO, "export", rec["bundle"], "sprites", rec["dir"], rec["frames"][0])
    if not os.path.exists(src):
        return None
    os.makedirs(ASSETS, exist_ok=True)
    dst = os.path.join(ASSETS, f"{rec['bundle']}_{re.sub(r'[^A-Za-z0-9_.-]', '_', rec['dir'])}.png")
    if not os.path.exists(dst):
        shutil.copy2(src, dst)
    return "assets/" + os.path.basename(dst)


def fpath(*parts):
    return "file:///" + os.path.join(*parts).replace("\\", "/")


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


def build():
    os.makedirs(OUT, exist_ok=True)
    bg = sprite("ResourceAssets.game_bg") or sprite("WeaponStorageAssets.weapon_storage_bg")
    cell = sprite("BagAssets.stuff_cell_bg_unequiped")

    # 武器
    weapons = []
    for key, w in INV["weapons"].items():
        p = os.path.join(LAUNCHER, "assets", "previews", "weapons", key + ".png")
        weapons.append({"k": key, "n": w.get("cn") or key, "c": classify(w),
                        "p": fpath(p) if os.path.exists(p) else ""})
    weapons.sort(key=lambda x: x["n"])

    # 角色
    chars = []
    for key, c in INV["characters"].items():
        p = os.path.join(LAUNCHER, "assets", "previews", "characters", key + ".png")
        chars.append({"k": key, "n": c.get("cn") or key, "g": c.get("kind", "other"),
                      "p": fpath(p) if os.path.exists(p) else ""})
    chars.sort(key=lambda x: x["n"])

    # 角色皮肤
    skins = [{"k": k, "o": v.get("player", "")} for k, v in INV["career_skins"].items()]

    # 喷漆
    sprays = []
    for k, v in INV["sprays"].items():
        p = os.path.join(LAUNCHER, "assets", "previews", "sprays", k + ".png")
        if os.path.exists(p):
            sprays.append({"k": k, "p": fpath(p)})
    sprays.sort(key=lambda x: int(x["k"]))

    # 饰品
    acc = [{"k": k} for k in INV["accessories"]]
    parts = [{"k": k} for k in INV["avatar_parts"]]

    def wcell(w):
        img = f'<img src="{html.escape(w["p"])}" loading="lazy">' if w["p"] else f'<i>{html.escape(w["n"][:1])}</i>'
        return (f'<div class="cell" data-c="{w["c"]}" title="{html.escape(w["n"])}">'
                f'<div class="slot">{img}</div><div class="nm">{html.escape(w["n"])}</div></div>')

    def ccell(c):
        img = f'<img src="{html.escape(c["p"])}" loading="lazy">' if c["p"] else f'<i>{html.escape(c["n"][:1])}</i>'
        return (f'<div class="cell tall" data-g="{c["g"]}" title="{html.escape(c["n"])}">'
                f'<div class="slot">{img}</div><div class="nm">{html.escape(c["n"])}</div></div>')

    doc = f"""<!doctype html><meta charset="utf-8"><title>生死狙击 · 离线大厅</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:#05080b;font-family:"Microsoft YaHei",sans-serif;color:#cfe3f5;
     display:flex;align-items:center;justify-content:center;min-height:100vh}}
#lobby{{position:relative;width:1024px;height:650px;overflow:hidden;
    background:url("{bg or ''}") center/cover no-repeat #0d1319}}
#lobby::after{{content:"";position:absolute;inset:0;
    background:linear-gradient(180deg,rgba(5,9,13,.28) 0,rgba(5,9,13,.52) 42%,rgba(4,8,12,.86) 100%);
    pointer-events:none}}
.top{{position:relative;z-index:5;display:flex;align-items:center;gap:6px;height:52px;
     padding:0 12px;background:linear-gradient(180deg,rgba(10,18,26,.96),rgba(8,14,20,.72));
     border-bottom:1px solid rgba(96,150,200,.4)}}
.logo{{font-size:16px;font-weight:700;letter-spacing:3px;color:#ffe9a8;
      text-shadow:0 0 12px rgba(255,190,80,.55)}}
.logo small{{display:block;font-size:8.5px;letter-spacing:1px;color:#8fb4d4;font-weight:400}}
.nav{{display:flex;gap:3px;margin-left:18px}}
.nav button{{padding:6px 13px;font-size:12.5px;font-family:inherit;cursor:pointer;color:#b9d3e8;
     border:1px solid transparent;border-radius:3px;background:transparent;transition:.12s}}
.nav button:hover{{color:#fff;background:rgba(40,70,100,.55)}}
.nav button.on{{color:#0b1620;font-weight:700;border-color:#a9d6ff;
     background:linear-gradient(180deg,#d6ecff,#8bc2ee);box-shadow:0 0 10px rgba(120,190,255,.5)}}
.me{{margin-left:auto;display:flex;align-items:center;gap:7px;font-size:12px}}
.vip{{padding:2px 7px;border-radius:3px;font-weight:700;color:#3a2600;
     background:linear-gradient(180deg,#ffe4a0,#eda62f);box-shadow:0 0 9px rgba(237,166,47,.6)}}
.lv{{padding:2px 7px;border-radius:3px;color:#c6e4ff;border:1px solid rgba(110,170,230,.55);
    background:rgba(18,36,54,.8)}}
.srv{{padding:2px 7px;border-radius:3px;font-size:11px;color:#a8d0f0;
     border:1px solid rgba(90,150,210,.45)}}
.mny{{color:#ffd86b}}.mny b{{color:#fff;font-weight:600}}
.nick{{color:#fff;font-weight:600;text-shadow:0 0 8px rgba(120,190,255,.6)}}
.bar{{position:relative;z-index:5;display:flex;gap:5px;padding:7px 12px;flex-wrap:wrap}}
.chip{{padding:4px 12px;font-size:12px;cursor:pointer;font-family:inherit;color:#a9c6e0;
      border:1px solid rgba(90,140,190,.35);border-radius:3px;background:rgba(14,26,38,.8)}}
.chip:hover{{color:#fff;border-color:rgba(120,190,255,.8)}}
.chip.on{{color:#0a1620;font-weight:700;border-color:#9fd0ff;
     background:linear-gradient(180deg,#cfe8ff,#8fc4f0)}}
.chip i{{font-style:normal;opacity:.55;margin-left:4px;font-size:10.5px}}
.body{{position:relative;z-index:5;height:512px;overflow-y:auto;padding:4px 12px 10px}}
.body::-webkit-scrollbar{{width:7px}}
.body::-webkit-scrollbar-thumb{{background:rgba(100,160,220,.45);border-radius:4px}}
.grid{{display:grid;grid-template-columns:repeat(12,1fr);gap:5px;align-content:start}}
.cell{{position:relative;aspect-ratio:1;cursor:pointer}}
.cell.tall{{aspect-ratio:.82}}
.slot{{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
  border:1px solid rgba(96,140,180,.5);border-radius:3px;
  background:{"url(\"" + cell + "\")" if cell else "rgba(18,30,42,.9)"} center/100% 100% no-repeat,rgba(12,20,28,.9)}}
.cell:hover .slot{{border-color:#8fd0ff;box-shadow:0 0 9px rgba(90,180,255,.6) inset}}
.slot img{{width:88%;height:88%;object-fit:contain;filter:drop-shadow(0 2px 3px rgba(0,0,0,.9))}}
.slot i{{font-size:15px;color:#6f8ba4;font-style:normal}}
.nm{{position:absolute;left:0;right:0;bottom:0;text-align:center;font-size:8.5px;line-height:10px;
   color:#9fbdd6;background:linear-gradient(180deg,transparent,rgba(4,8,12,.96));
   overflow:hidden;white-space:nowrap;text-overflow:ellipsis;padding:2px 1px 1px}}
.spraygrid{{display:grid;grid-template-columns:repeat(9,1fr);gap:6px}}
.spray{{position:relative;aspect-ratio:1;border:1px solid rgba(96,140,180,.45);border-radius:4px;
  background:rgba(12,20,28,.9);display:flex;align-items:center;justify-content:center;cursor:pointer}}
.spray img{{width:88%;height:88%;object-fit:contain}}
.spray:hover{{border-color:#8fd0ff;box-shadow:0 0 10px rgba(90,180,255,.5) inset}}
.spray span{{position:absolute;bottom:1px;right:3px;font-size:9px;color:#7f9cb6}}
.list{{display:grid;grid-template-columns:repeat(6,1fr);gap:5px}}
.item{{padding:7px 9px;border:1px solid rgba(90,140,190,.3);border-radius:4px;
  background:rgba(14,24,34,.85);font-size:10.5px;color:#a8c4dc;overflow:hidden;
  white-space:nowrap;text-overflow:ellipsis}}
.foot{{position:absolute;z-index:6;left:0;right:0;bottom:0;height:24px;display:flex;align-items:center;
  gap:16px;padding:0 14px;font-size:10.5px;color:#7f9cb6;
  background:linear-gradient(180deg,transparent,rgba(4,8,12,.9))}}
.page{{display:none}}.page.on{{display:block}}
</style>
<div id="lobby">
  <div class="top">
    <div class="logo">生死狙击<small>OFFLINE LOBBY</small></div>
    <div class="nav">
      <button class="on" data-p="warehouse">个人仓库</button>
      <button data-p="career">角色仓库</button>
      <button data-p="spray">喷漆仓库</button>
      <button data-p="cosmetic">饰品仓库</button>
    </div>
    <div class="me">
      <span class="vip">VIP{PLAYER['vip']}</span>
      <span class="lv">Lv.{PLAYER['level']}</span>
      <span class="srv">{PLAYER['district']}</span>
      <span class="mny">金币 <b>{PLAYER['gold']}</b></span>
      <span class="mny">GP <b>{PLAYER['gp']}</b></span>
      <span class="nick">{PLAYER['name']}</span>
    </div>
  </div>

  <div class="bar" id="bar"></div>
  <div class="body" id="body">
    <div class="page on" id="p-warehouse"><div class="grid" id="g-weapon">{''.join(wcell(w) for w in weapons)}</div></div>
    <div class="page" id="p-career"><div class="grid" id="g-career">{''.join(ccell(c) for c in chars)}</div></div>
    <div class="page" id="p-spray"><div class="spraygrid" id="g-spray">{''.join(f'<div class="spray"><img src="{html.escape(s["p"])}" loading="lazy"><span>#{s["k"]}</span></div>' for s in sprays)}</div></div>
    <div class="page" id="p-cosmetic"><div class="list">{''.join(f'<div class="item" title="{html.escape(a["k"])}">{html.escape(a["k"])}</div>' for a in acc + parts)}</div></div>
  </div>
  <div class="foot"><span id="stat"></span><span style="margin-left:auto">素材：原版图集 + 客户端离线渲染</span></div>
</div>
<script>
const PAGES = {{
  warehouse: {{title:"个人仓库", cats:[["all","全部",{len(weapons)}],["rifle","步枪",{sum(1 for w in weapons if w['c']=='rifle')}],["sniper","狙击",{sum(1 for w in weapons if w['c']=='sniper')}],["pistol","手枪",{sum(1 for w in weapons if w['c']=='pistol')}],["melee","近战",{sum(1 for w in weapons if w['c']=='melee')}],["grenade","投掷",{sum(1 for w in weapons if w['c']=='grenade')}],["shotgun","霰弹",{sum(1 for w in weapons if w['c']=='shotgun')}],["other","特殊",{sum(1 for w in weapons if w['c']=='other')}]]}},
  career: {{title:"角色仓库", cats:[["all","全部",{len(chars)}],["human","人类",{sum(1 for c in chars if c['g']=='human')}],["zombie","僵尸",{sum(1 for c in chars if c['g']=='zombie')}],["mech","机甲",{sum(1 for c in chars if c['g']=='mech')}],["pet","宠物",{sum(1 for c in chars if c['g']=='pet')}],["other","其他",{sum(1 for c in chars if c['g']=='other')}]]}},
  spray: {{title:"喷漆仓库", cats:[["all","全部",{len(sprays)}]]}},
  cosmetic: {{title:"饰品仓库", cats:[["all","全部",{len(acc)+len(parts)}]]}}
}};
let cur="warehouse", curCat="all";
const bar=document.getElementById('bar'), stat=document.getElementById('stat');
function renderBar(){{
  const p=PAGES[cur];
  bar.innerHTML=p.cats.map(([k,n,c])=>`<button class="chip${{k===curCat?' on':''}}" data-c="${{k}}">${{n}}<i>${{c}}</i></button>`).join('');
  bar.querySelectorAll('.chip').forEach(b=>b.onclick=()=>{{curCat=b.dataset.c;renderBar();apply();}});
}}
function apply(){{
  const box=document.querySelector('#'+({{warehouse:'g-weapon',career:'g-career',spray:'g-spray',cosmetic:'p-cosmetic'}})[cur]);
  let n=0;
  if(cur==='warehouse'||cur==='career'){{
    const attr=cur==='warehouse'?'c':'g';
    box.querySelectorAll('.cell').forEach(e=>{{const ok=curCat==='all'||e.dataset[attr]===curCat;e.style.display=ok?'':'none';if(ok)n++;}});
  }} else {{ n=box.querySelectorAll(box.classList.contains('list')?'.item':'.spray').length; }}
  stat.textContent=`${{PAGES[cur].title}} · 共 ${{n}} 件`;
}}
document.querySelectorAll('.nav button').forEach(b=>b.onclick=()=>{{
  document.querySelectorAll('.nav button').forEach(x=>x.classList.remove('on'));
  b.classList.add('on');
  document.querySelectorAll('.page').forEach(p=>p.classList.remove('on'));
  cur=b.dataset.p; curCat='all';
  document.getElementById('p-'+cur).classList.add('on');
  renderBar(); apply();
}});
renderBar(); apply();
(function(){{const h=location.hash.slice(1);if(!h)return;const b=document.querySelector('.nav button[data-p="'+h+'"]');if(b)b.click();}})();
</script>
"""
    out = os.path.join(OUT, "lobby.html")
    open(out, "w", encoding="utf-8").write(doc)
    print("wrote", out, f"{len(doc)/1024:.0f} KB")
    print(f"weapons={len(weapons)} chars={len(chars)} skins={len(skins)} sprays={len(sprays)} acc={len(acc)} parts={len(parts)}")
    print("bg:", bg, "cell:", cell)


if __name__ == "__main__":
    build()
