# -*- coding: utf-8 -*-
"""大厅主界面 + 顶栏导航：点顶栏按钮用 iframe 打开对应系统界面。

原版顶栏按钮名（从 TopButtonPanel 组件定义里取）：
  mallBtn 商城 / titaniumBtn 神器工厂 / storageBtn 个人仓库 / ssjjBigActivityBtn 精彩活动
  teamSystemBtn 战队 / gameHallBtn 游戏大厅 / vitaeBtn 个人生涯 / activityBtn 活动
  valorBtn 排行总览 / festivalListBtn 节日 / stardustBtn 星尘 / temporaryBagBtn 临时仓库
  timeShopBtn 时空商城 / playerListBtn 玩家列表 / rankBtn 排行
"""
import os, sys, json, html, glob

ROOT = r"D:\逆向\SSJJ双塔惊魂"
sys.path.insert(0, os.path.join(ROOT, "Game-SSJJ", "tools"))
import fairygui_render as F

VIEW = os.path.join(ROOT, "_work", "lobby_ui", "view_dec", "mainView.dec.xml")
OUT = os.path.join(ROOT, "_work", "lobby_ui", "out")
SCREENS = os.path.join(OUT, "screens")

# 按钮 -> 界面（界面名对应 screens/<name>.html）
# 原版 UI 里没有单独「喷漆/角色仓库」顶栏按钮，这里用 activityBtn 之外的两个入口补：
#   角色仓库 -> roleView（原版角色面板）  喷漆 -> PersonalizePanelView（原版个性化面板）
NAV = {
    "vitaeBtn": "data_career",
    "storageBtn": "data_warehouse",
    "temporaryBagBtn": "data_warehouse",
    "mallBtn": "newMallView",
    "timeShopBtn": "newMallView",
    "teamSystemBtn": "teamListView",
    "rankBtn": "newRankView",
    "valorBtn": "newRankView",
    "gameHallBtn": "hallView",
    
    "titaniumBtn": "weaponFactoryView",
    "playerListBtn": "friendView",
    "ssjjBigActivityBtn": "activitySummaryXML",
    "activityBtn": "activitySummaryXML",
    "festivalListBtn": "holidayMatchView",
    "stardustBtn": "rpgWeaponShow",
    # activityBtn 下拉菜单里的真实军火库入口：它是抽奖系统，不是个人仓库。
    "luckyDrawBtn": "data_arsenal",
    "weaponFactoryBtn": "weaponFactoryView",
    "weaponFragmentBtn": "weaponFragmentView",
}
LABEL = {
    "storageBtn": "个人仓库", "temporaryBagBtn": "临时仓库", "mallBtn": "商城",
    "timeShopBtn": "时空商城", "teamSystemBtn": "战队信息", "rankBtn": "排行榜",
    "valorBtn": "排行总览", "gameHallBtn": "游戏大厅", "vitaeBtn": "个人生涯",
    "titaniumBtn": "神器工厂", "playerListBtn": "玩家列表",
    "ssjjBigActivityBtn": "精彩活动", "activityBtn": "活动", "festivalListBtn": "节日活动",
    "stardustBtn": "星尘",
    "luckyDrawBtn": "军火库",
    "weaponFactoryBtn": "神器工厂",
    "weaponFragmentBtn": "武器碎片",
}
PLAYER = {"name": "你来时冬至", "district": "联通一区", "vip": 18, "level": 91, "gold": 91, "gp": 91}


def main():
    have = {os.path.basename(p).replace(".html", "") for p in glob.glob(os.path.join(SCREENS, "*.html"))}
    have |= {os.path.basename(p).replace(".html", "") for p in glob.glob(os.path.join(OUT, "data_*.html"))}
    nav = {k: v for k, v in NAV.items() if v in have}
    missing = [f"{k}->{v}" for k, v in NAV.items() if v not in have]

    r = F.Renderer(VIEW)
    body = r.render()
    w, h = 1024, 650
    nav_js = json.dumps(nav, ensure_ascii=False)
    label_js = json.dumps({k: LABEL[k] for k in nav}, ensure_ascii=False)

    doc = f"""<!doctype html><meta charset="utf-8"><title>生死狙击 · 离线大厅</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;font-family:"Microsoft YaHei",sans-serif;overflow:hidden}}
#stage{{position:relative;width:{w}px;height:{h}px;overflow:hidden;background:#000;margin:0 auto}}
.n{{position:absolute}}
.hit{{cursor:pointer}}
.hit::after{{content:"";position:absolute;inset:0;border:1px solid transparent;border-radius:3px;
  transition:.12s;pointer-events:none}}
.hit:hover::after{{border-color:rgba(140,210,255,.9);box-shadow:0 0 12px rgba(90,180,255,.6) inset}}
#mask{{position:fixed;inset:0;background:rgba(0,0,0,.72);display:none;z-index:50;
  align-items:center;justify-content:center}}
#mask.on{{display:flex}}
#box{{position:relative;width:1040px;height:700px;background:#0a1016;
  border:1px solid rgba(110,170,230,.6);border-radius:6px;overflow:hidden;
  box-shadow:0 24px 80px rgba(0,0,0,.9)}}
#bar{{display:flex;align-items:center;gap:10px;height:32px;padding:0 10px;
  background:linear-gradient(180deg,#14202c,#0d151d);border-bottom:1px solid rgba(90,140,190,.4)}}
#bar b{{font-size:12.5px;color:#ffe9a8}}
#bar button{{margin-left:auto;font-family:inherit;font-size:12px;padding:3px 12px;cursor:pointer;
  color:#cfe4f5;background:rgba(24,44,64,.9);border:1px solid rgba(120,180,230,.5);border-radius:3px}}
#bar button:hover{{background:rgba(44,84,124,.95);color:#fff}}
#frame{{width:100%;height:calc(100% - 32px);border:0;background:#000;display:block}}
#who{{position:fixed;left:50%;transform:translateX(-50%);bottom:6px;z-index:9;
  font-size:11px;color:#7f9cb6;background:rgba(0,0,0,.55);padding:3px 12px;border-radius:3px}}
</style>
<div id="stage">{body}</div>
<div id="who">VIP{PLAYER['vip']} · Lv.{PLAYER['level']} · {PLAYER['district']} · {PLAYER['name']} · 金币 {PLAYER['gold']} · GP {PLAYER['gp']}</div>
<div id="mask"><div id="box">
  <div id="bar"><b id="ttl"></b><button id="cls">关闭 ✕</button></div>
  <iframe id="frame"></iframe>
</div></div>
<script>
const NAV={nav_js}, LABEL={label_js};
function open(n){{
  const f=document.getElementById('frame');
  f.src=n.indexOf('.html')>=0?n:('screens/'+n+'.html');
  document.getElementById('ttl').textContent=LABEL[n]||n;
  document.getElementById('mask').classList.add('on');
}}
document.getElementById('cls').onclick=()=>{{
  document.getElementById('mask').classList.remove('on');
  document.getElementById('frame').src='about:blank';
}};
document.addEventListener('keydown',e=>{{if(e.key==='Escape')document.getElementById('cls').click();}});
Object.keys(NAV).forEach(name=>{{
  const el=document.querySelector('[data-name="'+name+'"]');
  if(!el) return;
  el.classList.add('hit');
  el.title=LABEL[name]||name;
  el.addEventListener('click',ev=>{{ev.stopPropagation();open(NAV[name]);}});
}});
</script>
"""
    out = os.path.join(OUT, "lobby_nav.html")
    open(out, "w", encoding="utf-8").write(doc)
    print("wrote", out)
    print("可点击导航:", len(nav), "个 ->", ", ".join(f"{LABEL[k]}:{v}" for k, v in nav.items()))
    if missing:
        print("缺界面（跳过）:", ", ".join(missing))


if __name__ == "__main__":
    main()
