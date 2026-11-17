# -*- coding: utf-8 -*-
"""FairyGUI 运行时（离线版）：把解密后的布局 XML 严格按源码渲染成 HTML。

原版是 Flash + FairyGUI，界面全部由 XML 描述：
  <config lib="">
     <UIImage|UIButton|UILabel|UICheckBox|UIContainer|UIComponent|UIList|MovieClip .../>
     <组件名> ...子节点... </组件名>          <- 组件定义（元素名 = 组件类名）
  </config>
实例用 <UIComponent className="组件名"/> 引用；定义里的坐标相对组件原点。

本渲染器只认 XML 里的 properties，不发明任何样式：
  x/y/width/height/skin/skins/definition/fontSize/textColor/align/wordWrap/
  leading/alpha/visible/scaleX/scaleY/rotation/title/text/zLanID/fontLanID
"""
import os, re, json, html, shutil
import xml.etree.ElementTree as ET

ROOT = r"D:\逆向\SSJJ双塔惊魂"
REPO = os.path.join(ROOT, "资源下载", "大厅资源", "SSJJ-main")
OUT = os.path.join(ROOT, "_work", "lobby_ui", "out")
ASSETS = os.path.join(OUT, "assets")
IDX_PATH = os.path.join(ROOT, "lobby-launcher", "data", "sprite_index.json")
I18N_PATH = os.path.join(ROOT, "_work", "lobby_ui", "i18n.dec.txt")

# FairyGUI 的控件标签
WIDGETS = {
    "UIImage", "UIButton", "UILabel", "UICheckBox", "UIContainer", "UIComponent",
    "UIList", "UIScrollPane", "UIScrollBar", "MovieClip", "UITextInput",
    "ExtComponent", "UIAsset", "UIAssetsLoader", "UISprite", "UIClip",
    "UIMovieClip", "UITabButton", "UIProgressBar", "UISlider", "UISwitch",
    "UIRichTextField", "UITextField", "UIGraph",
}

PROP_RE = re.compile(r"'([^']+)'\s*:\s*('[^']*'|true|false|-?[0-9.]+|[^,}]+)")

_idx = None
_i18n = None


def idx():
    global _idx
    if _idx is None:
        _idx = json.load(open(IDX_PATH, encoding="utf-8"))["items"]
    return _idx


def i18n():
    global _i18n
    if _i18n is None:
        _i18n = {}
        try:
            for line in open(I18N_PATH, encoding="utf-8-sig"):
                line = line.rstrip("\r\n")
                if "=" in line:
                    k, v = line.split("=", 1)
                    _i18n[k] = v
        except FileNotFoundError:
            pass
    return _i18n


def parse_props(text):
    out = {}
    if not text:
        return out
    for k, v in PROP_RE.findall(text):
        v = v.strip()
        if v.startswith("'") and v.endswith("'"):
            out[k] = v[1:-1]
        elif v == "true":
            out[k] = True
        elif v == "false":
            out[k] = False
        else:
            try:
                out[k] = float(v) if "." in v else int(v)
            except ValueError:
                out[k] = v
    return out


_asset_cache = {}


def asset(skin):
    """skin -> assets/ 下文件名。多帧按钮基础名缺数字后缀，退回加 1..9。"""
    if not skin:
        return None
    if skin in _asset_cache:
        return _asset_cache[skin]
    rec = idx().get(skin)
    if rec is None:
        for i in range(1, 10):
            rec = idx().get(skin + str(i))
            if rec:
                break
    if rec is None and skin.endswith("_"):
        for i in range(1, 10):
            rec = idx().get(skin[:-1] + str(i))
            if rec:
                break
    if rec is None:
        _asset_cache[skin] = None
        return None
    src = os.path.join(REPO, "export", rec["bundle"], "sprites", rec["dir"], rec["frames"][0])
    if not os.path.exists(src):
        _asset_cache[skin] = None
        return None
    os.makedirs(ASSETS, exist_ok=True)
    name = f"{rec['bundle']}_{re.sub(r'[^A-Za-z0-9_.-]', '_', rec['dir'])}.png"
    dst = os.path.join(ASSETS, name)
    if not os.path.exists(dst):
        shutil.copy2(src, dst)
    _asset_cache[skin] = "assets/" + name
    return _asset_cache[skin]


def color(v, default="#ffffff"):
    if v is None:
        return default
    s = str(v)
    try:
        n = int(s, 0) if s.lower().startswith("0x") or s.isdigit() else int(s)
        return "#%06x" % (n & 0xFFFFFF)
    except ValueError:
        return default


def px(p, k, dv=0):
    v = p.get(k, dv)
    try:
        return float(v)
    except (TypeError, ValueError):
        return float(dv)


class Renderer:
    def __init__(self, path, data=None):
        self.path = path
        self.tree = ET.parse(path).getroot()
        self.defs = {}          # 组件名 -> Element
        self.instances = []     # 顶层实例（按文档顺序）
        for ch in self.tree:
            if ch.tag in WIDGETS:
                self.instances.append(ch)
            else:
                self.defs[ch.tag] = ch
        self.depth = 0
        self.data = data or {}  # UIList name -> [ {icon,name,time,locked,...}, ... ]
        self.seq = 0
        # 有些面板顶层只有组件定义（如 <PersonalizePanel>…</PersonalizePanel> + 21 个子组件），
        # 没有控件实例；这时把第一个定义（主组件）当作根渲染，否则整页是空的。
        if not self.instances:
            for ch in self.tree:
                if ch.tag not in WIDGETS:
                    self.instances = [ch]
                    break

    # ---- UIList：按 rowHeight 把 cellRenderer 定义铺 N 份 ----
    def list_node(self, el, out):
        p = parse_props(el.get("properties", ""))
        name = el.get("name", "")
        style = [f"left:{px(p,'x'):g}px", f"top:{px(p,'y'):g}px"]
        w = p.get("width")
        h = p.get("height")
        cellref = re.search(r"cellRendererName':'([^']*)'", el.get("properties", ""))
        comp = cellref.group(1).split(".")[-1] if cellref else None
        rh = p.get("rowHeight") or p.get("lineGap")
        try:
            rh = float(rh) if rh else 0
        except (TypeError, ValueError):
            rh = 0
        rows = 0
        if h and rh > 0:
            try:
                rows = int(float(h) // rh)
            except (TypeError, ValueError):
                rows = 0
        items = self.data.get(name) or []
        if not comp or comp not in self.defs or rows <= 0:
            if w:
                style.append(f"width:{float(w):g}px")
            if h:
                style.append(f"height:{float(h):g}px")
            out.append(f'<div class="n UIList" data-name="{html.escape(name)}" style="{";".join(style)}"></div>')
            return

        cells = []
        for i in range(min(rows, max(rows, len(items)))):
            it = items[i] if i < len(items) else None
            cells.append(self.cell_html(self.defs[comp], i * rh, it))
        style.append(f"width:{float(w or 0):g}px")
        style.append(f"height:{rows * rh:g}px")
        out.append(
            f'<div class="n UIList" data-name="{html.escape(name)}" style="{";".join(style)}">{"".join(cells)}</div>'
        )

    def cell_html(self, def_el, top, item):
        """渲染一个单元格；item 里的 icon/name/time/locked/selected 会注入到对应控件。"""
        parts = []
        for ch in def_el:
            parts.append(self.cell_child(ch, item))
        return f'<div class="cell" style="position:absolute;left:0;top:{top:g}px">{"".join(parts)}</div>'

    def cell_child(self, el, item):
        tag = el.tag
        if tag not in WIDGETS:
            return "".join(self.cell_child(c, item) for c in el)
        p = parse_props(el.get("properties", ""))
        nm = el.get("name", "")
        style = [f"left:{px(p,'x'):g}px", f"top:{px(p,'y'):g}px"]
        w = p.get("width")
        h = p.get("height")
        inner = ""
        locked = bool(item and item.get("locked"))
        if locked and nm == "imgLock":
            pass  # 未拥有遮罩：全亮时不画
        elif nm == "imgLock":
            return ""
        if nm == "imgEquip" and not (item and item.get("selected")):
            return ""
        if nm == "imgLight" and not (item and item.get("hover")):
            return ""
        skin = p.get("skin") or p.get("skins")
        img = asset(skin) if skin else None
        if img:
            style.append("background-image:url('" + img + "')")
            style.append("background-size:100% 100%")
            style.append("background-repeat:no-repeat")
        # UIAssetsLoader = 动态图标位，用数据里的图片。原版只给 x/y + isCenterPosition，
        # 没有 width/height，这里按 cell 尺寸补 100x100，并按中心点换算 left/top。
        if tag == "UIAssetsLoader" and item and item.get("icon"):
            src = item["icon"]
            if not src.startswith(("http", "file:", "assets/")):
                src = "file:///" + src.replace("\\", "/")
            if not w:
                w = 100
            if not h:
                h = 100
            if p.get("isCenterPosition"):
                style[0] = f"left:{px(p,'x') - float(w) / 2:g}px"
                style[1] = f"top:{px(p,'y') - float(h) / 2:g}px"
            inner = f'<img src="{html.escape(src)}" style="position:absolute;left:12%;top:12%;width:76%;height:76%;object-fit:contain">'
        if nm in ("txtName", "txtTime", "txtLabel") and item:
            txt = item.get("name") if nm == "txtName" else item.get("time")
            if txt:
                fs = px(p, "fontSize", 12)
                fc = color(p.get("textColor"), "#ffffff")
                align = str(p.get("textAlign") or "left")
                just = {"center": "center", "right": "flex-end"}.get(align, "flex-start")
                inner += (
                    f'<span style="position:absolute;left:0;top:0;width:100%;height:100%;'
                    f'display:flex;align-items:center;justify-content:{just};'
                    f'color:{fc};font-size:{fs:g}px;text-shadow:0 1px 2px #000">'
                    f"{html.escape(str(txt))}</span>"
                )
        if w:
            style.append(f"width:{float(w):g}px")
        if h:
            style.append(f"height:{float(h):g}px")
        kids = list(el)
        if kids:
            inner += "".join(self.cell_child(c, item) for c in kids)
        return f'<div class="n {tag}" data-name="{html.escape(nm)}" style="{";".join(style)}">{inner}</div>'

    # ---- 单个节点 ----
    def node(self, el, out, parent_abs=True):
        tag = el.tag
        # 非控件元素 = 内联使用的组件定义，当透明容器递归展开子节点
        if tag not in WIDGETS:
            self._children(el, out)
            return
        if tag == "UIList":
            self.list_node(el, out)
            return
        p = parse_props(el.get("properties", ""))
        name = el.get("name", "")
        if p.get("visible") is False:
            return
        left, top = px(p, "x"), px(p, "y")
        style = [f"left:{left:g}px", f"top:{top:g}px"]
        w = p.get("width")
        h = p.get("height")
        inner = []

        # 图片：skin > skins > definition
        skin = p.get("skin") or p.get("skins") or p.get("definition") or el.get("definition")
        img = asset(skin) if skin else None
        if img:
            if not w or not h:
                rec = None
                for k, v in idx().items():
                    if v and v.get("bundle") and skin and k.startswith(skin):
                        rec = v
                        break
                if rec:
                    w = w or rec.get("w")
                    h = h or rec.get("h")
            # style 属性本身用双引号包裹，url() 里必须用单引号，否则属性会被提前截断
            style.append("background-image:url('" + img + "')")
            style.append("background-size:100% 100%")
            style.append("background-repeat:no-repeat")

        # 文字
        txt = p.get("text") or p.get("title") or ""
        zid = p.get("zLanID") or p.get("htmlTextLanID")
        if not txt and zid:
            txt = i18n().get(str(zid), "")
        if not txt and el.get("title"):
            txt = el.get("title")
        if txt:
            fs = px(p, "fontSize", 12)
            font = i18n().get(str(p.get("fontLanID", "")), "微软雅黑")
            fc = color(p.get("textColor"), "#ffffff")
            align = str(p.get("align") or p.get("textAlign") or ("center" if tag in ("UIButton", "UICheckBox") else "left"))
            just = {"center": "center", "right": "flex-end", "middle": "center"}.get(align, "flex-start")
            wrap = "pre-wrap" if p.get("wordWrap") else "nowrap"
            lead = p.get("leading")
            lh = fs + (float(lead) if isinstance(lead, (int, float)) else 2)
            stroke = px(p, "stroke", 0)
            shadow = f"-1px 0 {fc},1px 0 {fc},0 -1px {fc},0 1px {fc}" if int(stroke) >= 1 else "0 1px 2px rgba(0,0,0,.9)"
            inner.append(
                f'<span style="position:absolute;left:0;top:0;width:100%;height:100%;'
                f'display:flex;align-items:center;justify-content:{just};'
                f'color:{fc};font-size:{fs:g}px;font-family:\'{font}\';'
                f'white-space:{wrap};line-height:{lh:g}px;text-shadow:{shadow}">'
                f"{html.escape(str(txt))}</span>"
            )

        if w:
            style.append(f"width:{float(w):g}px")
        if h:
            style.append(f"height:{float(h):g}px")
        if p.get("alpha") not in (None, 1, 1.0):
            style.append(f"opacity:{float(p['alpha']):g}")
        tr = []
        if p.get("scaleX") not in (None, 1, 1.0):
            tr.append(f"scaleX({float(p['scaleX']):g})")
        if p.get("scaleY") not in (None, 1, 1.0):
            tr.append(f"scaleY({float(p['scaleY']):g})")
        if p.get("rotation"):
            tr.append(f"rotate({float(p['rotation']):g}deg)")
        if tr:
            style.append("transform:" + " ".join(tr))
            style.append("transform-origin:center center")

        # 组件实例：展开定义
        cls = el.get("className")
        if cls and cls in self.defs and self.depth < 24:
            self.depth += 1
            self._children(self.defs[cls], inner)
            self.depth -= 1

        # 容器 / 有子节点：直接渲染子节点
        kids = list(el)
        if kids:
            self._children(el, inner)

        out.append(
            f'<div class="n {tag}" data-name="{html.escape(name)}" style="{";".join(style)}">{"".join(inner)}</div>'
        )

    def _children(self, el, out_list, skip_defs=False):
        for ch in el:
            self.node(ch, out_list)

    def render(self):
        parts = []
        for el in self.instances:
            self.node(el, parts)
        return "".join(parts)


def build(xml_path, out_html, size=None, title=""):
    r = Renderer(xml_path)
    body = r.render()
    if size is None:
        # 原版大厅设计尺寸 1024x650
        size = (1024, 650)
    w, h = size
    doc = f"""<!doctype html><meta charset="utf-8"><title>{html.escape(title or os.path.basename(xml_path))}</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#05080b;display:flex;align-items:center;justify-content:center;min-height:100vh}}
#stage{{position:relative;width:{w}px;height:{h}px;overflow:hidden;background:#000;
  font-family:"Microsoft YaHei",sans-serif}}
.n{{position:absolute}}
img{{max-width:100%;max-height:100%}}
</style>
<div id="stage">{body}</div>
"""
    open(out_html, "w", encoding="utf-8").write(doc)
    node_count = body.count('class="n ')
    print(f"{os.path.basename(xml_path)} -> {os.path.basename(out_html)}  {len(body)/1024:.0f} KB  nodes~{node_count}")
    return out_html


if __name__ == "__main__":
    import sys
    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) > 2 else src.replace(".xml", ".fgui.html")
    build(src, dst)
