# -*- coding: utf-8 -*-
"""批量渲染全部大厅界面：287 个解密后的 FairyGUI 布局 -> HTML。

产出
  out/screens/<name>.html      每个界面的独立页面
  out/screens/index.html       缩略图索引，点进去看
  data/screens.json            清单（节点数 / 图片数 / 尺寸）
"""
import os, sys, json, glob, html, traceback

ROOT = r"D:\逆向\SSJJ双塔惊魂"
sys.path.insert(0, os.path.join(ROOT, "Game-SSJJ", "tools"))
import fairygui_render as F

SRC = os.path.join(ROOT, "_work", "lobby_ui", "view_dec")
DST = os.path.join(ROOT, "_work", "lobby_ui", "out", "screens")
MANIFEST = os.path.join(ROOT, "lobby-launcher", "data", "screens.json")

# 原版大厅设计分辨率；个别面板更大，按内容 bbox 放宽
BASE_W, BASE_H = 1024, 650


def bbox(xml_path):
    """按所有节点的 x/y/width/height 估一个画布尺寸。"""
    try:
        import xml.etree.ElementTree as ET
        root = ET.parse(xml_path).getroot()
    except Exception:
        return BASE_W, BASE_H
    mx = my = 0.0
    for el in root.iter():
        p = F.parse_props(el.get("properties", ""))
        try:
            x = float(p.get("x", 0) or 0)
            y = float(p.get("y", 0) or 0)
            w = float(p.get("width", 0) or 0)
            h = float(p.get("height", 0) or 0)
        except (TypeError, ValueError):
            continue
        mx = max(mx, x + w)
        my = max(my, y + h)
    return (max(int(mx), BASE_W), max(int(my), BASE_H))


def main():
    os.makedirs(DST, exist_ok=True)
    files = sorted(glob.glob(os.path.join(SRC, "*.dec.xml")))
    rows = []
    ok = fail = 0
    for i, path in enumerate(files, 1):
        name = os.path.basename(path).replace(".dec.xml", "")
        try:
            w, h = bbox(path)
            r = F.Renderer(path)
            body = r.render()
            nodes = body.count('class="n ')
            imgs = body.count("background-image")
            doc = f"""<!doctype html><meta charset="utf-8"><title>{html.escape(name)}</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;display:flex;align-items:flex-start;justify-content:center;min-height:100vh}}
#stage{{position:relative;width:{w}px;height:{h}px;overflow:hidden;background:#000;
  font-family:"Microsoft YaHei",sans-serif;flex:none}}
.n{{position:absolute}}
#hud{{position:fixed;left:8px;top:8px;z-index:9;font:11px/1.6 monospace;color:#7f9cb6;
  background:rgba(0,0,0,.6);padding:4px 8px;border-radius:3px}}
</style>
<div id="hud">{html.escape(name)} · {nodes} nodes · {imgs} imgs · {w}x{h}</div>
<div id="stage">{body}</div>
"""
            open(os.path.join(DST, name + ".html"), "w", encoding="utf-8").write(doc)
            rows.append({"name": name, "w": w, "h": h, "nodes": nodes, "imgs": imgs, "ok": True})
            ok += 1
        except Exception as e:
            rows.append({"name": name, "ok": False, "err": f"{type(e).__name__}: {e}"})
            fail += 1
            if fail <= 8:
                print("FAIL", name, type(e).__name__, str(e)[:90])
        if i % 40 == 0:
            print(f"  ... {i}/{len(files)}")

    rows.sort(key=lambda x: (-x.get("nodes", 0)))
    json.dump(rows, open(MANIFEST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    # 索引页
    cards = []
    for r in rows:
        if not r["ok"]:
            continue
        cards.append(
            f'<a class="c" href="{html.escape(r["name"])}.html" target="_blank">'
            f'<div class="t">{html.escape(r["name"])}</div>'
            f'<div class="m">{r["nodes"]} 节点 · {r["imgs"]} 图 · {r["w"]}×{r["h"]}</div></a>'
        )
    idx = f"""<!doctype html><meta charset="utf-8"><title>大厅界面总览</title>
<style>
body{{margin:0;background:#0b1016;font-family:"Microsoft YaHei";color:#cfe3f5;padding:20px}}
h1{{font-size:18px;margin:0 0 4px;color:#ffe9a8}}
p{{font-size:12px;color:#7f9cb6;margin:0 0 16px}}
.g{{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:8px}}
.c{{display:block;padding:10px 12px;border:1px solid rgba(90,140,190,.3);border-radius:5px;
  background:rgba(16,26,36,.9);text-decoration:none;color:inherit}}
.c:hover{{border-color:#8fd0ff;background:rgba(30,52,74,.95)}}
.t{{font-size:12.5px;color:#eaf4ff;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}}
.m{{font-size:10.5px;color:#6f8ba4;margin-top:3px}}
</style>
<h1>大厅界面总览 · {ok} 个</h1>
<p>全部由解密后的 FairyGUI 布局 XML 按源码渲染，坐标与图集来自原版。</p>
<div class="g">{''.join(cards)}</div>
"""
    open(os.path.join(DST, "index.html"), "w", encoding="utf-8").write(idx)
    print(f"\n渲染完成 ok={ok} fail={fail} -> {DST}")
    print("清单:", MANIFEST)


if __name__ == "__main__":
    main()
