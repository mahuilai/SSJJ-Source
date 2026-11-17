"""把解出的大厅 FairyGUI 布局 XML 渲染成 HTML，用于 1:1 比对原版界面。

FairyGUI 的布局是绝对坐标 + 图集切图，XML 结构：
    <config lib="">
      <UIImage name=.. properties="{'x':..,'y':..,'width':..,'height':..,'skin':'BagAssets.xxx'}"/>
      <UIContainer name=.. properties="{'x':..,'y':..}">  ...子节点...  </UIContainer>
      <UIButton | UILabel | UICheckBox | MovieClip .../>
    </config>

skin 形如 "<Bundle>.<sprite>"，实际文件在
    <repo>/export/<Bundle>/sprites/DefineSprite_<id>_<Bundle>.<sprite>/1.png
多帧按钮的基础名会缺数字后缀（pvp_btn -> pvp_btn1..5），需前缀回退。
"""
import os, re, json, sys, shutil, html

REPO = r"D:\逆向\SSJJ双塔静魂\资源下载\大厅资源\SSJJ-main"  # 兼容旧写法
REPO = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main"
INDEX = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\data\sprite_index.json"

PROP_RE = re.compile(r"'([^']+)'\s*:\s*('[^']*'|true|false|-?[0-9.]+|[^,}]+)")

I18N_PATH = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\i18n.dec.txt"
_I18N = None


def i18n():
    """语言表：WORD_7358=水晶数量 / WORD_19=宋体（字体名也在这张表里）。"""
    global _I18N
    if _I18N is None:
        _I18N = {}
        try:
            for line in open(I18N_PATH, encoding="utf-8-sig"):
                line = line.rstrip("\r\n")
                if "=" in line:
                    k, v = line.split("=", 1)
                    _I18N[k] = v
        except FileNotFoundError:
            pass
    return _I18N


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


class SpriteResolver:
    def __init__(self, index_path=INDEX):
        d = json.load(open(index_path, encoding="utf-8"))
        self.items = d["items"]

    def find(self, skin):
        """返回 (sprite_key, [frame 文件绝对路径...]) 或 None。"""
        if not skin:
            return None
        rec = self.items.get(skin)
        if rec is None:
            # 多帧：基础名 + 数字
            frames = []
            for i in range(1, 10):
                r = self.items.get(skin + str(i))
                if r:
                    frames.append(r)
            if not frames:
                # 有些 skin 以 _ 结尾，实际 sprite 是 _1.._n
                if skin.endswith("_"):
                    for i in range(1, 10):
                        r = self.items.get(skin[:-1] + str(i))
                        if r:
                            frames.append(r)
            if not frames:
                return None
            base = frames[0]["bundle"]
            paths = [
                os.path.join(REPO, "export", f["bundle"], "sprites", f["dir"], f["frames"][0])
                for f in frames
            ]
            return (skin, paths, frames[0].get("w", 0), frames[0].get("h", 0))
        paths = [os.path.join(REPO, "export", rec["bundle"], "sprites", rec["dir"], f) for f in rec["frames"]]
        return (skin, paths, rec.get("w", 0), rec.get("h", 0))


def render(xml_text, resolver, asset_out, depth=0):
    """返回 HTML 片段。asset_out 用于复制图片。"""
    html_parts = []
    pos = 0
    stack = []
    # 用简易的标签扫描器：只关心 <Tag ...> </Tag> <Tag .../>
    tag_re = re.compile(r"<(/?)([A-Za-z_][\w.]*)([^>]*?)(/?)>", re.S)
    for m in tag_re.finditer(xml_text):
        closing, tag, attrs, selfclose = m.group(1), m.group(2), m.group(3), m.group(4)
        if tag.lower() in ("config", "?xml"):
            continue
        if closing:
            if stack:
                stack.pop()
                html_parts.append("</div>")
            continue
        props = {}
        pm = re.search(r'properties="(.*?)"', attrs, re.S)
        if pm:
            props = parse_props(html.unescape(pm.group(1)))
        name = ""
        nm = re.search(r'name="([^"]*)"', attrs)
        if nm:
            name = nm.group(1)

        x = props.get("x", 0) or 0
        y = props.get("y", 0) or 0
        w = props.get("width")
        h = props.get("height")
        style = [f"left:{x}px", f"top:{y}px"]
        inner = ""

        sprite = None
        # skin / skins / definition 三种引用方式：MovieClip 与 UIAsset 用 definition
        skin = props.get("skin") or props.get("skins") or props.get("definition")
        if skin:
            sprite = resolver.find(skin)
        if sprite:
            key, paths, sw, sh = sprite
            if not w:
                w = sw
            if not h:
                h = sh
            src = copy_asset(paths[0], asset_out)
            inner = f'<img src="{src}" style="width:100%;height:100%;display:block">'

        if tag in ("UILabel", "UIButton", "UICheckBox"):
            color = props.get("textColor", "0xffffff")
            try:
                c = int(str(color), 0)
                css_color = "#%06x" % (c & 0xFFFFFF)
            except ValueError:
                css_color = "#ffffff"
            fs = props.get("fontSize", 14)
            font = i18n().get(str(props.get("fontLanID", "")), "微软雅黑")
            # 文案来源：直接 text > zLanID 查表；fontLanID 是字体名不是文案
            txt = props.get("text") or props.get("title") or ""
            zid = props.get("zLanID")
            if not txt and zid:
                txt = i18n().get(str(zid), "")
            if txt:
                align = props.get("align", "center" if tag != "UILabel" else "left")
                justify = {"center": "center", "right": "flex-end"}.get(str(align), "flex-start")
                wrap = "pre-wrap" if props.get("wordWrap") else "nowrap"
                lead = props.get("leading")
                lh = f"line-height:{fs + (lead if isinstance(lead, (int, float)) else 2)}px;"
                inner += (
                    f'<span style="position:absolute;left:0;top:0;width:100%;height:100%;'
                    f'display:flex;align-items:center;justify-content:{justify};'
                    f'color:{css_color};font-size:{fs}px;font-family:\'{font}\';'
                    f'white-space:{wrap};{lh}'
                    f'text-shadow:0 1px 2px rgba(0,0,0,.85)">{html.escape(str(txt))}</span>'
                )

        if w:
            style.append(f"width:{w}px")
        if h:
            style.append(f"height:{h}px")
        if props.get("visible") is False:
            style.append("display:none")
        if props.get("alpha") not in (None, 1, 1.0):
            style.append(f"opacity:{props['alpha']}")
        if props.get("scaleX") and props.get("scaleX") != 1:
            style.append(f"transform:scaleX({props['scaleX']})")

        cls = f"fgui fgui-{tag}"
        html_parts.append(
            f'<div class="{cls}" data-name="{html.escape(name)}" style="{";".join(style)}">{inner}'
        )
        if selfclose:
            html_parts.append("</div>")
        else:
            stack.append(tag)
    while stack:
        stack.pop()
        html_parts.append("</div>")
    return "".join(html_parts)


def copy_asset(src, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    dst = os.path.join(out_dir, os.path.basename(os.path.dirname(src)) + "_" + os.path.basename(src))
    if not os.path.exists(dst):
        try:
            shutil.copy2(src, dst)
        except Exception:
            return ""
    return "assets/" + os.path.basename(dst)


def measure(text, default=(1024, 640)):
    """按所有节点的 x/y/width/height 估一个舞台尺寸（原版是 1024x650）。"""
    maxx, maxy = 0, 0
    for m in re.finditer(r'properties="(.*?)"', text, re.S):
        p = parse_props(html.unescape(m.group(1)))
        try:
            x = float(p.get("x", 0) or 0)
            y = float(p.get("y", 0) or 0)
            w = float(p.get("width", 0) or 0)
            h = float(p.get("height", 0) or 0)
        except (TypeError, ValueError):
            continue
        maxx = max(maxx, x + w)
        maxy = max(maxy, y + h)
    return (max(int(maxx), default[0]), max(int(maxy), default[1]))


def serve_one(xml_path, out_html, title=None, size=None):
    resolver = SpriteResolver()
    raw = open(xml_path, "rb").read()
    text = raw.decode("utf-8", "replace")
    if size is None:
        size = measure(text)
    base = os.path.dirname(out_html)
    asset_out = os.path.join(base, "assets")
    body = render(text, resolver, asset_out)
    w, h = size
    doc = f"""<!doctype html><meta charset="utf-8"><title>{html.escape(title or os.path.basename(xml_path))}</title>
<style>
  body{{margin:0;background:#1b1f24;display:flex;align-items:center;justify-content:center;min-height:100vh;font-family:"Microsoft YaHei",sans-serif}}
  #stage{{position:relative;width:{w}px;height:{h}px;overflow:hidden;background:#000;transform-origin:top left}}
  .fgui{{position:absolute}}
  .fgui-UIContainer{{position:absolute}}
</style>
<div id="stage">{body}</div>
"""
    open(out_html, "w", encoding="utf-8").write(doc)
    print("wrote", out_html, len(body), "bytes")


if __name__ == "__main__":
    xml = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else xml.replace(".xml", ".html")
    serve_one(xml, out)
