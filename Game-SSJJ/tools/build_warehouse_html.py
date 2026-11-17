"""生成「全武器仓库」界面：原版图集（格子/背景/按钮） + 全量武器数据。

视觉素材全部来自原版：
  WeaponStorageAssets.weapon_storage_bg   仓库底图 1024x640
  BagAssets.stuff_cell_bg_unequiped       物品格 40x40（九宫格拉伸到 80px）
  MainAssets.pvp_btn1..5                  tab 按钮
武器图标来自客户端 AB 包离屏渲染的 assets/previews/weapons/*.png。
"""
import json, os, html, re

ROOT = r"D:\逆向\SSJJ双塔惊魂"
LAUNCHER = os.path.join(ROOT, "lobby-launcher")
REPO = os.path.join(ROOT, "资源下载", "大厅资源", "SSJJ-main")
IDX = json.load(open(os.path.join(LAUNCHER, "data", "sprite_index.json"), encoding="utf-8"))
INV = json.load(open(os.path.join(LAUNCHER, "data", "asset_inventory.json"), encoding="utf-8"))
I18N = {}
for line in open(os.path.join(ROOT, "_work", "lobby_ui", "i18n.dec.txt"), encoding="utf-8-sig"):
    if "=" in line:
        k, v = line.rstrip("\n").split("=", 1)
        I18N[k] = v

OUT_DIR = os.path.join(ROOT, "_work", "lobby_ui", "out")
ASSET_DIR = os.path.join(OUT_DIR, "assets")
os.makedirs(ASSET_DIR, exist_ok=True)

PLAYER = {
    "name": "你来时冬至",
    "vip": 18,
    "level": 91,
    "gold": 91,
    "gp": 91,
    "district": "联通一区",
    "owned_all": True,
}

CATS = [
    ("rifle", "步枪", "步"),
    ("sniper", "狙击", "狙"),
    ("pistol", "手枪", "手"),
    ("melee", "近战", "刀"),
    ("grenade", "投掷", "雷"),
    ("shotgun", "霰弹", "霰"),
    ("other", "特殊", "特"),
]

KIND2CAT = {
    "步枪": "rifle", "狙击": "sniper", "手枪": "pistol", "近战": "melee",
    "投掷": "grenade", "霰弹": "shotgun",
}


def sprite(key):
    """sprite key -> 可访问的相对路径（复制到 out/assets）。"""
    rec = IDX["items"].get(key)
    if not rec:
        for i in range(1, 10):
            rec = IDX["items"].get(key + str(i))
            if rec:
                break
    if not rec:
        return None
    src = os.path.join(REPO, "export", rec["bundle"], "sprites", rec["dir"], rec["frames"][0])
    if not os.path.exists(src):
        return None
    dst_name = f"{rec['bundle']}_{re.sub(r'[^A-Za-z0-9_.-]', '_', rec['dir'])}.png"
    dst = os.path.join(ASSET_DIR, dst_name)
    if not os.path.exists(dst):
        import shutil
        shutil.copy2(src, dst)
    return "assets/" + dst_name


def classify(w):
    """asset_inventory 里武器的字段名是 type（不是 kind）。"""
    kind = (w.get("type") or w.get("kind") or "").lower()
    if "sniper" in kind:
        return "sniper"
    # GrenadeRifleSpecial 是发射榴弹的枪，占主武器槽，要先判 rifle
    if "rifle" in kind:
        return "rifle"
    if "shotgun" in kind:
        return "shotgun"
    if "pistol" in kind:
        return "pistol"
    if "grenade" in kind or "bomb" in kind:
        return "grenade"
    if "knife" in kind or "sword" in kind or "blade" in kind or "melee" in kind or "axe" in kind:
        return "melee"
    return "other"


def build():
    weapons = []
    for key, w in INV["weapons"].items():
        cat = classify(w)
        prev = os.path.join(LAUNCHER, "assets", "previews", "weapons", key + ".png")
        has_prev = os.path.exists(prev)
        weapons.append({
            "key": key,
            "cn": w.get("cn") or key,
            "cat": cat,
            "complete": w.get("complete", False),
            "prev": has_prev,
        })
    weapons.sort(key=lambda x: (not x["complete"], x["cn"]))

    bg = sprite("WeaponStorageAssets.weapon_storage_bg")
    cell = sprite("BagAssets.stuff_cell_bg_unequiped")
    cell_over = sprite("BagAssets.stuff_cell_bg_over")
    tabup = sprite("MainAssets.pvp_btn1")
    tabon = sprite("MainAssets.pvp_btn4")

    counts = {}
    for w in weapons:
        counts[w["cat"]] = counts.get(w["cat"], 0) + 1

    cells = []
    prev_dir = os.path.join(LAUNCHER, "assets", "previews", "weapons")
    for i, w in enumerate(weapons):
        if w["prev"]:
            # file:// 下用绝对 URI，避免相对路径跨目录解析失败
            src = "file:///" + os.path.join(prev_dir, w["key"] + ".png").replace("\\", "/")
            img = f'<img src="{html.escape(src)}" loading="lazy">'
        else:
            img = f'<span class="ph">{html.escape(w["cn"][:2])}</span>'
        cells.append(
            f'<div class="cell{" dim" if not w["complete"] else ""}" data-cat="{w["cat"]}" '
            f'data-name="{html.escape(w["cn"])} {html.escape(w["key"])}" title="{html.escape(w["cn"])}">'
            f'<div class="slot">{img}</div>'
            f'<div class="nm">{html.escape(w["cn"])}</div></div>'
        )

    tabs = "".join(
        f'<button class="tab" data-cat="{c}">{n}<i>{counts.get(c,0)}</i></button>'
        for c, n, _ in CATS
    )

    doc = f"""<!doctype html><meta charset="utf-8"><title>个人仓库 · 生死狙击</title>
<style>
*{{box-sizing:border-box}}
body{{margin:0;background:#0a0d10;font-family:"Microsoft YaHei",sans-serif;color:#cfe3f5;
     display:flex;align-items:center;justify-content:center;min-height:100vh}}
#app{{position:relative;width:1024px;height:640px;overflow:hidden;
     background:url("{bg or ''}") center/cover no-repeat #0d1319;
     box-shadow:0 20px 60px rgba(0,0,0,.8)}}
#app::before{{content:"";position:absolute;inset:0;background:linear-gradient(180deg,rgba(6,10,14,.86),rgba(6,10,14,.94))}}
.top{{position:relative;display:flex;align-items:center;gap:14px;height:46px;padding:0 14px;
     background:linear-gradient(180deg,rgba(24,38,52,.95),rgba(12,20,28,.9));
     border-bottom:1px solid rgba(90,140,190,.35)}}
.title{{font-size:17px;font-weight:700;color:#eaf4ff;letter-spacing:2px;text-shadow:0 0 10px rgba(90,170,255,.5)}}
.who{{display:flex;align-items:center;gap:8px;margin-left:auto;font-size:12.5px}}
.vip{{padding:2px 7px;border-radius:3px;font-weight:700;color:#3a2600;
     background:linear-gradient(180deg,#ffdf8a,#f0a93a);box-shadow:0 0 8px rgba(240,169,58,.55)}}
.lv{{padding:2px 7px;border-radius:3px;color:#bfe0ff;border:1px solid rgba(110,170,230,.5);background:rgba(20,40,60,.7)}}
.money{{display:flex;align-items:center;gap:5px;color:#ffd86b}}
.money b{{color:#fff;font-weight:600}}
.srv{{padding:2px 7px;border-radius:3px;font-size:11.5px;color:#a8d0f0;
     border:1px solid rgba(90,150,210,.45);background:rgba(18,36,54,.75)}}
.tabs{{position:relative;display:flex;gap:6px;padding:8px 14px;flex-wrap:wrap}}
.tab{{position:relative;padding:5px 14px;font-size:12.5px;color:#a9c6e0;cursor:pointer;
     border:1px solid rgba(90,140,190,.35);border-radius:3px;background:rgba(16,28,40,.8);
     font-family:inherit;transition:.15s}}
.tab i{{font-style:normal;opacity:.55;margin-left:5px;font-size:11px}}
.tab:hover{{color:#fff;border-color:rgba(120,190,255,.8);background:rgba(30,55,80,.9)}}
.tab.on{{color:#0a1620;font-weight:700;border-color:#9fd0ff;
     background:linear-gradient(180deg,#cfe8ff,#8fc4f0)}}
.tab.on i{{opacity:.7}}
.grid{{position:relative;display:grid;grid-template-columns:repeat(11,1fr);gap:5px;
     padding:4px 14px 8px;height:512px;overflow-y:auto;align-content:start}}
.grid::-webkit-scrollbar{{width:7px}}
.grid::-webkit-scrollbar-thumb{{background:rgba(100,160,220,.5);border-radius:4px}}
.cell{{position:relative;aspect-ratio:1;cursor:pointer}}
.slot{{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
     border:1px solid rgba(96,140,180,.55);border-radius:3px;
     background:{"url(\"" + cell + "\")" if cell else "rgba(20,32,44,.9)"} center/100% 100% no-repeat, rgba(14,22,30,.92)}}
.cell:hover .slot{{border-color:#8fd0ff;box-shadow:0 0 10px rgba(90,180,255,.55) inset,0 0 8px rgba(90,180,255,.4)}}
.slot img{{width:86%;height:86%;object-fit:contain;filter:drop-shadow(0 2px 3px rgba(0,0,0,.9))}}
.ph{{font-size:13px;color:#6f8ba4}}
.nm{{position:absolute;left:0;right:0;bottom:-1px;text-align:center;font-size:9px;line-height:11px;
     color:#9fbdd6;background:linear-gradient(180deg,transparent,rgba(6,10,14,.95));
     overflow:hidden;white-space:nowrap;text-overflow:ellipsis;padding:2px 1px 1px}}
.dim{{opacity:.42}}
.foot{{position:absolute;left:0;right:0;bottom:0;height:26px;display:flex;align-items:center;
     gap:16px;padding:0 16px;font-size:11px;color:#7f9cb6;
     background:linear-gradient(180deg,transparent,rgba(6,10,14,.95))}}
</style>
<div id="app">
  <div class="top">
    <span class="title">个人仓库</span>
    <div class="who">
      <span class="vip">VIP{PLAYER['vip']}</span>
      <span class="lv">Lv.{PLAYER['level']}</span>
      <span class="money">金币 <b>{PLAYER['gold']:,}</b></span>
      <span class="money">GP <b>{PLAYER['gp']:,}</b></span>
      <span class="srv">{PLAYER['district']}</span>
      <span style="color:#eaf4ff">{PLAYER['name']}</span>
    </div>
  </div>
  <div class="tabs">
    <button class="tab on" data-cat="all">全部<i>{len(weapons)}</i></button>
    {tabs}
  </div>
  <div class="grid" id="grid">{''.join(cells)}</div>
  <div class="foot"><span>共 {len(weapons)} 件武器</span><span id="shown"></span><span style="margin-left:auto">素材：原版图集 + 客户端渲染</span></div>
</div>
<script>
const tabs=[...document.querySelectorAll('.tab')],cells=[...document.querySelectorAll('.cell')];
function apply(cat){{
  let n=0;
  cells.forEach(c=>{{const ok=cat==='all'||c.dataset.cat===cat;c.style.display=ok?'':'none';if(ok)n++;}});
  document.getElementById('shown').textContent='当前显示 '+n+' 件';
}}
tabs.forEach(t=>t.onclick=()=>{{tabs.forEach(x=>x.classList.remove('on'));t.classList.add('on');apply(t.dataset.cat);}});
apply('all');
</script>
"""
    out = os.path.join(OUT_DIR, "warehouse.html")
    open(out, "w", encoding="utf-8").write(doc)
    print("wrote", out, len(doc), "bytes; weapons", len(weapons))
    print("counts:", counts)
    print("assets:", bg, "|", cell, "|", tabup)


if __name__ == "__main__":
    build()
