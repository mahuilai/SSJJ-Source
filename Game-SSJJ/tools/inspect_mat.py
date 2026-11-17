import UnityPy, glob, os

BASE = r"D:\逆向\SSJJ双塔惊魂\资源全集\player"

# ct_knight1$2：mesh+shader+material 分包
src = glob.glob(os.path.join(BASE, "ct_knight1$2_*"))[0]
env = UnityPy.load(src)
print("=== %s ===" % os.path.basename(src))

mats = []
for obj in env.objects:
    if obj.type.name == "Material":
        try:
            d = obj.read_typed()
        except Exception as e:
            print("mat read fail", e); continue
        mats.append(d)

print("materials:", len(mats))
for m in mats[:6]:
    name = getattr(m, "m_Name", "?")
    shader = getattr(m, "m_Shader", None)
    # m_Shader 是 PPtr，取其 m_FileID/PathID 无法直接解名；看 saved properties
    texs = []
    for env_name in ("m_SavedProperties",):
        sp = getattr(m, env_name, None)
        if sp is None: continue
        texenvs = getattr(sp, "m_TexEnvs", None)
        if texenvs:
            for te in texenvs:
                tname = getattr(te, "name", "?")
                tex = getattr(te, "texture", None)
                has = tex is not None and getattr(tex, "m_PathID", 0) != 0
                texs.append("%s=%s" % (tname, "REF" if has else "NULL"))
    print("  mat %-28s shader=? tex: %s" % (name, ", ".join(texs) if texs else "(none)"))

# 主包贴图清单
src2 = glob.glob(os.path.join(BASE, "ct_knight1_183c*"))[0]
env2 = UnityPy.load(src2)
tex_names = []
for obj in env2.objects:
    if obj.type.name == "Texture2D":
        try:
            d = obj.read_typed()
            tex_names.append(d.m_Name)
        except Exception:
            pass
print("=== main bundle textures (%d) ===" % len(tex_names))
print(tex_names[:30])
