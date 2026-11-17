"""生成 lobby-launcher/src/previews_spray.rs：把喷漆预览图编进二进制。

用法：python gen_spray_previews_rs.py
"""
import os

ROOT = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher"
SRC = os.path.join(ROOT, "assets", "previews", "sprays")
OUT = os.path.join(ROOT, "src", "previews_spray.rs")


def main():
    files = sorted(
        (f for f in os.listdir(SRC) if f.endswith(".png")),
        key=lambda f: int(os.path.splitext(f)[0]),
    )
    lines = [
        "// 由 Game-SSJJ/tools/gen_spray_previews_rs.py 生成，请勿手改。",
        "// 喷漆贴图：assets/previews/sprays/<ResId>.png（128px 缩略图，源自 spray/<id> bundle 内 Texture2D）。",
        "pub fn bytes(kind: &str, key: &str) -> Option<&'static [u8]> {",
        '    if kind != "spray" {',
        "        return None;",
        "    }",
        "    match key {",
    ]
    for f in files:
        sid = os.path.splitext(f)[0]
        lines.append(
            f'        "{sid}" => Some(include_bytes!("../assets/previews/sprays/{f}")),'
        )
    lines += ["        _ => None,", "    }", "}", ""]
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines))
    print("wrote", OUT, "entries", len(files))


if __name__ == "__main__":
    main()
