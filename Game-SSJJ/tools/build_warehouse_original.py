# -*- coding: utf-8 -*-
"""按原版 XML 坐标 1:1 重建仓库界面（WeaponStorage2View 的真实布局）。

坐标全部取自解密后的 resource/view/WeaponStorage2View_*.xml：
  back            0,0     1024x640  WeaponStorageAssets.weapon_storage_bg
  crystal_bg    144,44    type1_bg（原版声明 876x552）
  storageName   469,155   text_title1 230x38
  buttonList      4,45    140x549，每项 138 高 → type1_btn_1..5
  tileList      151,51    16 个 weapon_bg_type1_0 (220x86)，x 步长 214、y 步长 80
  singleBtn     445,268   107x89  type1_zr_btn_
  multiBtn      545,268   174x89  type1_nl_btn_
  powerProgress 160,544   progress_bar
  closeBtn      967,9      48x30   close_btn_
  icon_type     449,2      24x30
  crystalText   478,5     100x29
"""
import json, os, re, html, shutil

ROOT = r"D:\逆向\SSJJ双塔惊魂"
LAUNCHER = os.path.join(ROOT, "lobby-launcher")
REPO = os.path.join(ROOT, "资源下载", "大厅资源", "SSJJ-main")
OUT = os.path.join(ROOT, "_work", "lobby_ui", "out")
ASSETS = os.path.join(OUT, "assets")

IDX = json.load(open(os.path.join(LAUNCHER, "data", "sprite_index.json"), encoding="utf-8"))["items"]
INV = json.load(open(os.path.join(LAUNCHER, "data", "asset_inventory.json"), encoding="utf-8"))

PLAYER = {"name": "你来时冬至", "district": "联通一区", "vip": 18, "level": 91, "gold": 91, "gp": 91}
CATS = [("all", "全部"), ("rifle", "步枪"), ("sniper", "狙击"), ("pistol", "手枪"),
        ("melee", "近战"), ("grenade", "投掷"), ("shotgun", "霰弹"), ("other", "特殊")]

# 原版 tileList 的 16 个格位（name -> x,y），照抄 XML
TILES = [
    ("icon0", 0, 0), ("icon1", 214, 0), ("icon2", 428, 0), ("icon3", 642, 0),
    ("icon15", 0, 80), ("icon14", 0, 160), ("icon13", 0, 240), ("icon12", 0, 320),
    ("icon11", 0, 400), ("icon10", 214, 400), ("icon9", 428, 400), ("icon8", 642, 80),
    ("icon4", 642, 160), ("icon5", 642, 240), ("icon6", 642, 320), ("icon7", 642, 400),
]
TILE_W, TILE_H = 220, 86


def sprite(key, scale=None):
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


def fpath(*p):
    return "file:///" + os.path.join(*p).replace("\\", "/")


def build():
    bg = sprite("WeaponStorageAssets.weapon_storage_bg")
    inner = sprite("WeaponStorageAssets.type1_bg")
    tile = sprite("WeaponStorageAssets.weapon_bg_type1_0")
    title = sprite("WeaponStorageAssets.text_title1")
    close_btn = sprite("WeaponStorageAssets.close_btn_1")
    icon_type = sprite("WeaponStorageAssets.icon_type1")
    btn_zr = sprite("WeaponStorageAssets.type1_zr_btn_1")
    btn_nl = sprite("WeaponStorageAssets.type1_nl_btn_1")
    btn_tab = [sprite(f"WeaponStorageAssets.type1_btn_{i}") for i in range(1, 6)]
    prog = sprite("WeaponStorageAssets.progress_bar")

    weapons = []
    for key, w in INV["weapons"].items():
        p = os.path.join(LAUNCHER, "assets", "previews", "weapons", key + ".png")
        weapons.append({"k": key, "n": w.get("cn") or key, "c": classify(w),
                        "p": fpath(p) if os.path.exists(p) else ""})
    weapons.sort(key=lambda x: x["n"])

    cells = "".join(
        f'<div class="tile" data-i="{i}" style="left:{x}px;top:{y}px;width:{TILE_W}px;height:{TILE_H}px">'
        f'<div class="tbg" style="background-image:url(\'{tile}\')"></div>'
        f'<div class="tic"></div><div class="tnm"></div></div>'
        for i, (_, x, y) in enumerate(TILES)
    )

    tabs = "".join(
        f'<div class="tab{" on" if i == 0 else ""}" data-c="{c}" style="background-image:url(\'{btn_tab[i] if i < len(btn_tab) and btn_tab[i] else ""}\')">'
        f'<span>{n}</span></div>'
        for i, (c, n) in enumerate(CATS[:5])
    )

    doc = f"""<!doctype html><meta charset="utf-8"><title>个人仓库</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#000;font-family:"Microsoft YaHei",sans-serif;
     display:flex;align-items:center;justify-content:center;min-height:100vh}}
#stage{{position:relative;width:1024px;height:640px;overflow:hidden;
   background:url("{bg}") 0 0/1024px 640px no-repeat}}
.abs{{position:absolute}}
#inner{{left:144px;top:44px;width:876px;height:552px;
   background:url("{inner}") center/100% 100% no-repeat}}
#title{{left:469px;top:155px;width:230px;height:38px;
   background:url("{title}") center/100% 100% no-repeat;
   display:flex;align-items:center;justify-content:center;
   font-size:14px;color:#3a2a10;font-weight:700;letter-spacing:2px}}
#close{{left:967px;top:9px;width:48px;height:30px;background:url("{close_btn}") center/contain no-repeat;cursor:pointer}}
#iconType{{left:449px;top:2px;width:24px;height:30px;background:url("{icon_type}") center/contain no-repeat}}
#crystal{{left:478px;top:5px;width:150px;height:29px;display:flex;align-items:center;
   font-size:15px;color:#ffe6a8;text-shadow:0 0 6px rgba(255,190,60,.8)}}
#tileList{{left:151px;top:51px;width:876px;height:552px;position:absolute}}
.tile{{position:absolute;cursor:pointer}}
.tbg{{position:absolute;inset:0;background-size:100% 100%;background-repeat:no-repeat}}
.tic{{position:absolute;left:4px;top:4px;width:132px;height:78px;display:flex;align-items:center;justify-content:center}}
.tic img{{max-width:100%;max-height:100%;object-fit:contain;filter:drop-shadow(0 2px 3px rgba(0,0,0,.9))}}
.tnm{{position:absolute;left:140px;top:12px;width:74px;font-size:11px;line-height:14px;
   color:#d8e6f2;text-shadow:0 1px 2px #000;overflow:hidden}}
.tile:hover .tbg{{filter:brightness(1.3)}}
#tabBar{{left:4px;top:45px;width:140px;height:549px;position:absolute;display:flex;flex-direction:column;gap:0}}
.tab{{position:relative;width:140px;height:138px;background-size:100% 100%;background-repeat:no-repeat;
   cursor:pointer;display:flex;align-items:center;justify-content:center}}
.tab span{{font-size:14px;color:#cfe0ee;text-shadow:0 1px 3px #000;letter-spacing:2px}}
.tab:hover span{{color:#fff}}
.tab.on span{{color:#ffe9a8;font-weight:700}}
#prog{{left:160px;top:544px;width:695px;height:20px;background:url("{prog}") center/100% 100% no-repeat}}
#progFill{{position:absolute;left:0;top:0;height:100%;width:0%;border-radius:3px;
   background:linear-gradient(180deg,#9be3ff,#2f8ec9);opacity:.85}}
#single{{left:445px;top:268px;width:107px;height:89px;background:url("{btn_zr}") center/100% 100% no-repeat;cursor:pointer;display:flex;align-items:center;justify-content:center}}
#multi{{left:545px;top:268px;width:174px;height:89px;background:url("{btn_nl}") center/100% 100% no-repeat;cursor:pointer;display:flex;align-items:center;justify-content:center}}
#single span,#multi span{{font-size:15px;font-weight:700;color:#2a1c04;text-shadow:0 1px 0 rgba(255,230,160,.7)}}
#pager{{left:151px;top:604px;width:876px;height:24px;display:flex;align-items:center;
   justify-content:center;gap:10px;font-size:12px;color:#a8c8e0}}
#pager button{{padding:2px 12px;font-family:inherit;font-size:12px;cursor:pointer;color:#cfe4f5;
   background:rgba(20,44,66,.85);border:1px solid rgba(120,180,230,.5);border-radius:3px}}
#pager button:hover{{background:rgba(40,80,120,.9);color:#fff}}
#who{{left:640px;top:604px;font-size:11px;color:#7f9cb6}}
</style>
<div id="stage">
  <div class="abs" id="inner"></div>
  <div class="abs" id="title">个人仓库</div>
  <div class="abs" id="iconType"></div>
  <div class="abs" id="crystal">水晶 0</div>
  <div class="abs" id="close"></div>
  <div id="tabBar">{tabs}</div>
  <div id="tileList">{cells}</div>
  <div class="abs" id="prog"><div id="progFill"></div></div>
  <div class="abs" id="single"><span>上一页</span></div>
  <div class="abs" id="multi"><span>下一页</span></div>
  <div id="pager"><button id="prev">◀</button><span id="pinfo">1 / 1</span><button id="next">▶</button></div>
  <div id="who">VIP{PLAYER['vip']} · Lv.{PLAYER['level']} · {PLAYER['district']} · {PLAYER['name']} · 金币 {PLAYER['gold']} · GP {PLAYER['gp']}</div>
</div>
<script>
const W = {json.dumps(weapons, ensure_ascii=False)};
const PER = {len(TILES)};
let cat = "all", page = 0;
const tiles = [...document.querySelectorAll('.tile')];
const tabs = [...document.querySelectorAll('.tab')];
function list(){{ return cat==='all' ? W : W.filter(w=>w.c===cat); }}
function draw(){{
  const L = list(), pages = Math.max(1, Math.ceil(L.length/PER));
  if(page>=pages) page = pages-1;
  tiles.forEach((t,i)=>{{
    const w = L[page*PER+i];
    t.style.display = w ? '' : 'none';
    if(!w) return;
    const ic = t.querySelector('.tic');
    ic.innerHTML = w.p ? `<img src="${{w.p}}" loading="lazy">` : '';
    t.querySelector('.tnm').textContent = w.n;
    t.title = w.n;
  }});
  document.getElementById('pinfo').textContent = (page+1)+' / '+pages+'   '+L.length+' 件';
  document.getElementById('progFill').style.width = ((page+1)/pages*100)+'%';
}}
tabs.forEach(t=>t.onclick=()=>{{tabs.forEach(x=>x.classList.remove('on'));t.classList.add('on');cat=t.dataset.c;page=0;draw();}});
document.getElementById('prev').onclick=()=>{{if(page>0){{page--;draw();}}}};
document.getElementById('next').onclick=()=>{{const n=Math.ceil(list().length/PER);if(page<n-1){{page++;draw();}}}};
document.addEventListener('keydown',e=>{{if(e.key==='ArrowLeft')document.getElementById('prev').click();if(e.key==='ArrowRight')document.getElementById('next').click();}});
draw();
</script>
"""
    out = os.path.join(OUT, "warehouse_original.html")
    open(out, "w", encoding="utf-8").write(doc)
    print("wrote", out, f"{len(doc)/1024:.0f} KB", "weapons", len(weapons))
    print("assets:", "bg", bool(bg), "inner", bool(inner), "tile", bool(tile),
          "title", bool(title), "tabs", sum(1 for x in btn_tab if x))


if __name__ == "__main__":
    build()
