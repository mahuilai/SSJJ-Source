"""导出喷漆仓库数据：spray/<id> bundle -> PNG 预览 + JSON 索引。

原版结构（每个 bundle 9 个对象）：
  Texture2D  名字=id，256x256 RGBA  -> 喷漆图案
  GameObject/MeshFilter/MeshRenderer/Mesh -> 贴墙 quad
  SparyTextures(MonoBehaviour) -> ResId / HasName / colorId / Name / NameColors
  TextAsset effectConfig -> <Texture name="ID.atf" resID="ID" hasname="1" colorID="0"/>
"""
import os, sys, json, re, traceback
import UnityPy
from PIL import Image

SRC = r"D:\逆向\SSJJ双塔惊魂\资源全集\spray"
OUT_PNG = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\assets\previews\sprays"
OUT_JSON = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\data\sprays.json"
SIZE = 128
LIMIT = int(sys.argv[1]) if len(sys.argv) > 1 else 0

os.makedirs(OUT_PNG, exist_ok=True)

def id_of(fname):
    return fname.split("_", 1)[0]

def parse_effect(script):
    if not isinstance(script, str):
        try:
            script = bytes(script).decode("utf-8", "ignore")
        except Exception:
            return {}
    m = re.search(r'resID="(\d+)"', script)
    hn = re.search(r'hasname="(\d+)"', script)
    cid = re.search(r'colorID="(\d+)"', script)
    return {
        "res_id": int(m.group(1)) if m else None,
        "has_name": int(hn.group(1)) if hn else False,
        "color_id": int(cid.group(1)) if cid else 0,
    }

def main():
    files = sorted(os.listdir(SRC), key=lambda f: (len(id_of(f)), id_of(f)))
    # spray/ 下还有 common、materials 两个共享资源包，不是喷漆本体，跳过。
    files = [f for f in files if id_of(f).isdigit()]
    if LIMIT:
        files = files[:LIMIT]
    rows = []
    bad = []
    for i, f in enumerate(files):
        sid = id_of(f)
        rec = {"id": sid, "complete": False, "has_name": False, "color_id": 0, "preview": False}
        try:
            env = UnityPy.load(os.path.join(SRC, f))
            tex = None
            for obj in env.objects:
                t = obj.type.name
                if t == "Texture2D" and tex is None:
                    tex = obj.read()
                elif t == "TextAsset":
                    ta = obj.read()
                    if getattr(ta, "m_Name", "") == "effectConfig":
                        rec.update({k: v for k, v in parse_effect(ta.m_Script).items() if v is not None})
            if tex is not None:
                img = tex.image.convert("RGBA")
                # 保持正方形，缩放到 SIZE
                w, h = img.size
                side = max(w, h)
                canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
                canvas.paste(img, ((side - w) // 2, (side - h) // 2))
                canvas = canvas.resize((SIZE, SIZE), Image.LANCZOS)
                canvas.save(os.path.join(OUT_PNG, f"{sid}.png"), "PNG", optimize=True)
                rec["complete"] = True
                rec["preview"] = True
                rec["w"], rec["h"] = w, h
        except Exception as e:
            bad.append((f, f"{type(e).__name__}: {e}"))
        rows.append(rec)
        if (i + 1) % 50 == 0:
            print(f"  ... {i+1}/{len(files)}")

    payload = {"sprays": {r["id"]: {k: v for k, v in r.items() if k != "id"} for r in rows}}
    with open(OUT_JSON, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, ensure_ascii=False, indent=1, sort_keys=True)
    ok = sum(1 for r in rows if r["complete"])
    named = sum(1 for r in rows if r["has_name"])
    print(f"done total={len(rows)} ok={ok} has_name={named} bad={len(bad)}")
    for f, e in bad[:10]:
        print("  BAD", f, e)

if __name__ == "__main__":
    main()
